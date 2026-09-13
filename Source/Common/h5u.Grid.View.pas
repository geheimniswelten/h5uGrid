unit h5u.Grid.View;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Generics.Collections,
    Math,
    Rtti,
    SysUtils,
  {$ELSE}
    System.Generics.Collections,
    System.Math,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  Th5uViewGetController = function: Th5uCustomDataController of object;

  // Nonvisual, per-grid row mapping. The data controller can be shared by other views.
  // Columns and options remain owned by the native component for streaming and factories.
  Th5uGridView = class
  private
    FGrid: TObject;
    FGetController: Th5uViewGetController;
    FColumns: Th5uGridColumns;
    FTree: Th5uTreeOptions;
    FAdjacentGroupFolding: Th5uAdjacentGroupFoldingOptions;
    FAdjacentGroupMap: Th5uAdjacentGroupMap;
    FAdjacentGroupMapDirty: Boolean;
    FOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    FOnGetTreeLevel: Th5uGetTreeLevelEvent;
    FOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    FOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;
    function GetDataController: Th5uCustomDataController;
  public
    constructor Create(AGrid: TObject; AColumns: Th5uGridColumns; ATree: Th5uTreeOptions; AAdjacentGroups: Th5uAdjacentGroupFoldingOptions; AGetController: Th5uViewGetController);
    destructor Destroy; override;
    property DataController: Th5uCustomDataController read GetDataController;
    procedure InvalidateAdjacentGroupMap(AClearStates: Boolean);
    procedure EnsureAdjacentGroupMap;
    function ResolveAdjacentGroupFieldName: string;
    function TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
    function GetViewRowCount: Int64;
    function MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean = False): Int64;
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    function GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
    function IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
    procedure PrepareViewRange(AFirstViewRow, ACount: Int64);
    function TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
    function GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
    function TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
    function GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
    function ChangeAdjacentGroup(AViewRowIndex: Int64; AToggle, ACollapsed: Boolean; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    function ChangeAllAdjacentGroups(ACollapsed: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uAdjacentGroupRowInfo>;
    procedure ResetAdjacentGroupStates;
    property OnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent read FOnGetAdjacentGroupId write FOnGetAdjacentGroupId;
    property OnGetTreeLevel: Th5uGetTreeLevelEvent read FOnGetTreeLevel write FOnGetTreeLevel;
    property OnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent read FOnGetTreeBranchEnd write FOnGetTreeBranchEnd;
    property OnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent read FOnAdjacentGroupStateChanged write FOnAdjacentGroupStateChanged;
  end;

implementation

constructor Th5uGridView.Create(AGrid: TObject; AColumns: Th5uGridColumns; ATree: Th5uTreeOptions; AAdjacentGroups: Th5uAdjacentGroupFoldingOptions; AGetController: Th5uViewGetController);
begin
  inherited Create;
  FGrid := AGrid;
  FColumns := AColumns;
  FTree := ATree;
  FAdjacentGroupFolding := AAdjacentGroups;
  FGetController := AGetController;
  FAdjacentGroupMap := Th5uAdjacentGroupMap.Create;
  FAdjacentGroupMapDirty := True;
end;

destructor Th5uGridView.Destroy;
begin
  FAdjacentGroupMap.Free;
  inherited;
end;

function Th5uGridView.GetDataController: Th5uCustomDataController;
begin
  if Assigned(FGetController) then
    Result := FGetController()
  else
    Result := nil;
end;

procedure Th5uGridView.InvalidateAdjacentGroupMap(AClearStates: Boolean);
begin
  if AClearStates then
    FAdjacentGroupMap.ResetStates;
  FAdjacentGroupMapDirty := True;
end;

procedure Th5uGridView.EnsureAdjacentGroupMap;
var
  LControllerRowIndex: Int64;
  LControllerRowCount: Int64;
  LGroupId: TValue;
  LAvailable: Boolean;
begin
  if not Assigned(DataController) or not FAdjacentGroupFolding.Enabled then
  begin
    FAdjacentGroupMap.Clear(False);
    FAdjacentGroupMapDirty := False;
    Exit;
  end;

  if not FAdjacentGroupMapDirty then
    Exit;

  FAdjacentGroupMap.BeginBuild(FAdjacentGroupFolding.InitialState, FAdjacentGroupFolding.CaseSensitive, FAdjacentGroupFolding.GroupEmptyValues);
  LControllerRowCount := DataController.GetRowCount;
  if LControllerRowCount > 0 then
    DataController.PrepareRange(0, LControllerRowCount);

  {$IFDEF FPC}
    LControllerRowIndex := 0;
    while LControllerRowIndex < LControllerRowCount do
    begin
      LAvailable := TryGetAdjacentGroupIdForControllerRow(LControllerRowIndex, LGroupId);
      FAdjacentGroupMap.AddRow(LControllerRowIndex, DataController.GetRowKey(LControllerRowIndex), LGroupId, LAvailable);
      Inc(LControllerRowIndex);
    end;
  {$ELSE}
    for LControllerRowIndex := 0 to LControllerRowCount - 1 do
    begin
      LAvailable := TryGetAdjacentGroupIdForControllerRow(LControllerRowIndex, LGroupId);
      FAdjacentGroupMap.AddRow(LControllerRowIndex, DataController.GetRowKey(LControllerRowIndex), LGroupId, LAvailable);
    end;
  {$ENDIF}
  FAdjacentGroupMap.EndBuild;
  FAdjacentGroupMapDirty := False;
end;

function Th5uGridView.ResolveAdjacentGroupFieldName: string;
var
  LColumn: Th5uGridColumn;
begin
  Result := Trim(FAdjacentGroupFolding.IdColumnId);
  if Result = '' then
    Exit;

  LColumn := FColumns.FindById(Result);
  if not Assigned(LColumn) then
    LColumn := FColumns.FindByFieldName(Result);
  if Assigned(LColumn) then
    Result := LColumn.FieldName;
end;

function Th5uGridView.TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
var
  LContext: Th5uAdjacentGroupIdContext;
  LFieldName: string;
begin
  AGroupId := TValue.Empty;
  Result := False;
  if not Assigned(DataController) or not DataController.IsRowAvailable(AControllerRowIndex) then
    Exit;

  LFieldName := ResolveAdjacentGroupFieldName;
  if LFieldName <> '' then
  begin
    AGroupId := DataController.GetValue(AControllerRowIndex, LFieldName);
    Result := True;
  end;

  if Assigned(FOnGetAdjacentGroupId) then
  begin
    LContext := Default(Th5uAdjacentGroupIdContext);
    LContext.Grid := FGrid;
    LContext.DataController := DataController;
    LContext.RowKey := DataController.GetRowKey(AControllerRowIndex);
    LContext.ControllerRowIndex := AControllerRowIndex;
    LContext.SourceRowIndex := DataController.GetSourceRowIndex(AControllerRowIndex);
    FOnGetAdjacentGroupId(FGrid, LContext, AGroupId, Result);
  end;
end;

function Th5uGridView.GetViewRowCount: Int64;
begin
  if not Assigned(DataController) then
    Exit(0);
  EnsureAdjacentGroupMap;
  if FAdjacentGroupMap.Active then
    Result := FAdjacentGroupMap.GetVisibleRowCount
  else
    Result := DataController.GetRowCount;
end;

function Th5uGridView.MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean): Int64;
begin
  Result := -1;
  if not Assigned(DataController) or (AViewRowIndex < 0) then
    Exit;

  EnsureAdjacentGroupMap;
  if not FAdjacentGroupMap.Active then
    Exit(AViewRowIndex);

  Result := FAdjacentGroupMap.MapViewToController(AViewRowIndex);
  if (Result < 0) and AAllowLookAhead and (AViewRowIndex = FAdjacentGroupMap.GetVisibleRowCount) then
    Result := DataController.GetRowCount;
end;

function Th5uGridView.GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
var
  LControllerRowIndex: Int64;
begin
  Result := -1;
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  if LControllerRowIndex >= 0 then
    Result := DataController.GetSourceRowIndex(LControllerRowIndex);
end;

function Th5uGridView.GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
var
  LControllerRowIndex: Int64;
begin
  Result := Th5uRowKey.Empty;
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  if LControllerRowIndex >= 0 then
    Result := DataController.GetRowKey(LControllerRowIndex);
end;

function Th5uGridView.GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
var
  LControllerRowIndex: Int64;
begin
  Result := TValue.Empty;
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := DataController.GetValue(LControllerRowIndex, AFieldName);
end;

procedure Th5uGridView.SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LControllerRowIndex: Int64;
begin
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    DataController.SetValue(LControllerRowIndex, AFieldName, AValue);
end;

function Th5uGridView.CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
var
  LControllerRowIndex: Int64;
begin
  Result := False;
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := DataController.CanEdit(LControllerRowIndex, AFieldName);
end;

function Th5uGridView.GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
var
  LControllerRowIndex: Int64;
begin
  Result := '';
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := DataController.GetDisplayText(LControllerRowIndex, AFieldName, ADisplayFormat);
end;

function Th5uGridView.IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
var
  LControllerRowIndex: Int64;
begin
  Result := False;
  if not Assigned(DataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  Result := (LControllerRowIndex >= 0) and DataController.IsRowAvailable(LControllerRowIndex);
end;

procedure Th5uGridView.PrepareViewRange(AFirstViewRow, ACount: Int64);
var
  LFirstControllerRow: Int64;
  LLastControllerRow: Int64;
  LLastViewRow: Int64;
begin
  if not Assigned(DataController) or (ACount <= 0) then
    Exit;

  LFirstControllerRow := MapViewToControllerRowIndex(AFirstViewRow);
  LLastViewRow := Min(GetViewRowCount - 1, AFirstViewRow + ACount - 1);
  LLastControllerRow := MapViewToControllerRowIndex(LLastViewRow);
  if (LFirstControllerRow < 0) or (LLastControllerRow < 0) then
    Exit;

  DataController.PrepareRange(LFirstControllerRow, LLastControllerRow - LFirstControllerRow + 1);
end;

function Th5uGridView.TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  EnsureAdjacentGroupMap;
  Result := FAdjacentGroupMap.Active and FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, AInfo);
end;

procedure Th5uGridView.PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  if not TryGetAdjacentGroupRowInfo(AViewRowIndex, LInfo) then
    Exit;

  AContext.AdjacentGroupIndex := LInfo.GroupIndex;
  AContext.AdjacentGroupId := LInfo.GroupId;
  AContext.AdjacentGroupAnchorRowKey := LInfo.AnchorRowKey;
  AContext.AdjacentGroupRowCount := LInfo.RowCount;
  AContext.AdjacentGroupCollapsed := LInfo.Collapsed;
  AContext.AdjacentGroupFirstRow := LInfo.IsFirstRow;
  AContext.AdjacentGroupLastVisibleRow := LInfo.IsLastVisibleRow;

  if LInfo.IsFirstRow then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupFirst);
  if LInfo.IsLastVisibleRow then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupLast);
  if LInfo.Collapsed then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupCollapsed)
  else
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupExpanded);
end;

function Th5uGridView.GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  Result := TryGetAdjacentGroupRowInfo(AViewRowIndex, AInfo) and AInfo.IsFoldable and AInfo.IsLastVisibleRow;
  if not Result then
    Exit;

  case FAdjacentGroupFolding.EndBand.Visibility of
    Th5uAdjacentGroupEndBandVisibility.Never:
      Result := False;
    Th5uAdjacentGroupEndBandVisibility.CollapsedOnly:
      Result := AInfo.Collapsed;
    Th5uAdjacentGroupEndBandVisibility.ExpandedOnly:
      Result := not AInfo.Collapsed;
    Th5uAdjacentGroupEndBandVisibility.Always:
      Result := True;
  end;
end;

procedure Th5uGridView.DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
var
  LContext: Th5uAdjacentGroupStateChangedContext;
begin
  if not Assigned(FOnAdjacentGroupStateChanged) then
    Exit;
  LContext := Default(Th5uAdjacentGroupStateChangedContext);
  LContext.Grid := FGrid;
  LContext.DataController := DataController;
  LContext.GroupId := AInfo.GroupId;
  LContext.AnchorRowKey := AInfo.AnchorRowKey;
  LContext.FirstControllerRowIndex := AInfo.ControllerRowIndex - AInfo.GroupOffset;
  LContext.RowCount := AInfo.RowCount;
  LContext.Collapsed := AInfo.Collapsed;
  FOnAdjacentGroupStateChanged(FGrid, LContext);
end;

function Th5uGridView.TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
var
  LColumn: Th5uGridColumn;
  LContext: Th5uTreeLevelContext;
  LFieldName: string;
  LValue: TValue;
begin
  ALevel := 0;
  Result := False;
  if not FTree.Enabled or not Assigned(DataController) then
    Exit;

  LFieldName := Trim(FTree.LevelColumnId);
  if LFieldName <> '' then
  begin
    LColumn := FColumns.FindById(LFieldName);
    if not Assigned(LColumn) then
      LColumn := FColumns.FindByFieldName(LFieldName);
    if Assigned(LColumn) then
      LFieldName := LColumn.FieldName;

    LValue := GetViewValue(AViewRowIndex, LFieldName);
    Result := h5uTryValueAsInteger(LValue, ALevel);
  end;

  if Assigned(FOnGetTreeLevel) then
  begin
    LContext := Default(Th5uTreeLevelContext);
    LContext.Grid := FGrid;
    LContext.DataController := DataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    FOnGetTreeLevel(FGrid, LContext, ALevel, Result);
  end;

  if Result then
    ALevel := Max(0, ALevel);
end;

function Th5uGridView.GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
var
  LContext: Th5uTreeBranchEndContext;
  LCurrentAvailable: Boolean;
  LNextAvailable: Boolean;
  LNextIndex: Int64;
  LNextKey: Th5uRowKey;
  LNextLevel: Integer;
  LHasNextRow: Boolean;
begin
  Result := False;
  ATreeLevel := 0;
  AClosedTreeLevels := 0;
  if not FTree.Enabled or not Assigned(DataController) then
    Exit;

  LCurrentAvailable := TryGetTreeLevelFor(AViewRowIndex, ARowKey, ATreeLevel);

  LNextIndex := AViewRowIndex + 1;
  LNextKey := Th5uRowKey.Empty;
  LNextLevel := ATreeLevel;
  LNextAvailable := False;
  LHasNextRow := IsViewRowAvailable(LNextIndex);

  if LHasNextRow then
  begin
    LNextKey := GetViewRowKey(LNextIndex);
    LNextAvailable := TryGetTreeLevelFor(LNextIndex, LNextKey, LNextLevel);
  end;

  if LCurrentAvailable and (ATreeLevel > 0) then
  begin
    if not LHasNextRow then
    begin
      Result := FTree.BranchEndBand.IncludeEndOfData;
      if Result then
        AClosedTreeLevels := ATreeLevel;
    end
    else if LNextAvailable and (LNextLevel < ATreeLevel) then
    begin
      Result := True;
      AClosedTreeLevels := ATreeLevel - LNextLevel;
    end;
  end;

  if Assigned(FOnGetTreeBranchEnd) then
  begin
    LContext := Default(Th5uTreeBranchEndContext);
    LContext.Grid := FGrid;
    LContext.DataController := DataController;
    LContext.RowKey := ARowKey;
    LContext.NextRowKey := LNextKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    LContext.CurrentLevel := ATreeLevel;
    LContext.NextLevel := LNextLevel;
    LContext.IsEndOfData := not LHasNextRow;
    FOnGetTreeBranchEnd(FGrid, LContext, Result, AClosedTreeLevels);
  end;

  if Result and (AClosedTreeLevels <= 0) then
    AClosedTreeLevels := 1;
end;

function Th5uGridView.IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  Result := TryGetAdjacentGroupRowInfo(AViewRowIndex, LInfo) and LInfo.IsFoldable and LInfo.Collapsed;
end;

function Th5uGridView.ChangeAdjacentGroup(AViewRowIndex: Int64; AToggle, ACollapsed: Boolean; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  Result := False;
  EnsureAdjacentGroupMap;
  if not FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, AInfo) or not AInfo.IsFoldable then
    Exit;
  if AToggle then
    ACollapsed := not AInfo.Collapsed;
  Result := FAdjacentGroupMap.SetCollapsedAtViewRow(AViewRowIndex, ACollapsed);
  if Result then
    AInfo.Collapsed := ACollapsed;
end;

function Th5uGridView.ChangeAllAdjacentGroups(ACollapsed: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uAdjacentGroupRowInfo>;
var
  I: Integer;
  LRun: Th5uAdjacentGroupRun;
  LChanged: {$IFDEF FPC}specialize {$ENDIF}TList<Th5uAdjacentGroupRowInfo>;
  LInfo: Th5uAdjacentGroupRowInfo;
  LChangedMap: Boolean;
begin
  Result := nil;
  EnsureAdjacentGroupMap;
  LChanged := {$IFDEF FPC}specialize {$ENDIF}TList<Th5uAdjacentGroupRowInfo>.Create;
  try
    for I := 0 to FAdjacentGroupMap.RunCount - 1 do
    begin
      LRun := FAdjacentGroupMap.Runs[I];
      if LRun.IsFoldable and (LRun.Collapsed <> ACollapsed) then
      begin
        LInfo := Th5uAdjacentGroupRowInfo.Empty;
        LInfo.ControllerRowIndex := LRun.FirstControllerRowIndex;
        LInfo.GroupId := LRun.GroupId;
        LInfo.AnchorRowKey := LRun.AnchorRowKey;
        LInfo.RowCount := LRun.RowCount;
        LInfo.Collapsed := ACollapsed;
        LChanged.Add(LInfo);
      end;
    end;
    if ACollapsed then
      LChangedMap := FAdjacentGroupMap.CollapseAll
    else
      LChangedMap := FAdjacentGroupMap.ExpandAll;
    if LChangedMap then
      Result := LChanged.ToArray;
  finally
    LChanged.Free;
  end;
end;

procedure Th5uGridView.ResetAdjacentGroupStates;
begin
  InvalidateAdjacentGroupMap(True);
end;

end.
