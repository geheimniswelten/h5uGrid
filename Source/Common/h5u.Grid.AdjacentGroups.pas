unit h5u.Grid.AdjacentGroups;

interface

{$SCOPEDENUMS ON}

uses
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  h5u.Grid.Types;

type
  // A run represents one contiguous block of equal adjacent IDs. The same ID
  // may therefore occur in several independent runs when other rows lie in
  // between. State is keyed by the first row of the run, not by the ID alone.
  Th5uAdjacentGroupRun = record
    StateKey: string;
    ComparisonKey: string;
    GroupId: TValue;
    AnchorRowKey: Th5uRowKey;
    FirstControllerRowIndex: Int64;
    LastControllerRowIndex: Int64;
    RowCount: Int64;
    Collapsed: Boolean;
    function IsFoldable: Boolean;
  end;

  Th5uAdjacentGroupRowInfo = record
    ViewRowIndex: Int64;
    ControllerRowIndex: Int64;
    GroupIndex: Integer;
    GroupOffset: Int64;
    GroupId: TValue;
    AnchorRowKey: Th5uRowKey;
    RowCount: Int64;
    Collapsed: Boolean;
    IsFirstRow: Boolean;
    IsLastSourceRow: Boolean;
    IsLastVisibleRow: Boolean;
    IsFoldable: Boolean;
    class function Empty: Th5uAdjacentGroupRowInfo; static;
  end;

  // Per-grid view map. It never changes the data controller or its order; it
  // only maps visible row indexes to the controller's current view indexes.
  Th5uAdjacentGroupMap = class
  private
    FRuns: TList<Th5uAdjacentGroupRun>;
    FVisibleControllerRows: TList<Int64>;
    FVisibleGroupIndexes: TList<Integer>;
    FCollapsedStates: TDictionary<string, Boolean>;
    FActive: Boolean;
    FInitialCollapsed: Boolean;
    FCaseSensitive: Boolean;
    FGroupEmptyValues: Boolean;
    FHasPendingRun: Boolean;
    FPendingRun: Th5uAdjacentGroupRun;
    procedure FinalizePendingRun;
    procedure RebuildVisibleRows;
    function BuildComparisonKey(const AGroupId: TValue; AControllerRowIndex: Int64; AAvailable: Boolean; out AKey: string): Boolean;
    function BuildStateKey(const ARowKey: Th5uRowKey; AControllerRowIndex: Int64; const AComparisonKey: string): string;
    function GetRun(AIndex: Integer): Th5uAdjacentGroupRun;
    function GetRunCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear(AClearStates: Boolean = False);
    procedure ResetStates;
    procedure BeginBuild(AInitialState: Th5uAdjacentGroupInitialState; ACaseSensitive: Boolean; AGroupEmptyValues: Boolean);
    procedure AddRow(AControllerRowIndex: Int64; const ARowKey: Th5uRowKey; const AGroupId: TValue; AAvailable: Boolean);
    procedure EndBuild;

    function GetVisibleRowCount: Int64;
    function MapViewToController(AViewRowIndex: Int64): Int64;
    function TryGetRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    function SetCollapsedAtViewRow(AViewRowIndex: Int64; ACollapsed: Boolean): Boolean;
    function ToggleAtViewRow(AViewRowIndex: Int64): Boolean;
    function ExpandAll: Boolean;
    function CollapseAll: Boolean;

    property Active: Boolean read FActive;
    property Runs[AIndex: Integer]: Th5uAdjacentGroupRun read GetRun;
    property RunCount: Integer read GetRunCount;
  end;

implementation

function h5uAdjacentValueText(const AValue: TValue): string;
var
  LVariant: Variant;
begin
  if AValue.IsEmpty then
    Exit('');

  if AValue.Kind = tkVariant then
  begin
    LVariant := AValue.AsVariant;
    if VarIsNull(LVariant) or VarIsEmpty(LVariant) then
      Exit('');
    Exit(VarToStr(LVariant));
  end;

  case AValue.Kind of
    tkInteger, tkInt64, tkEnumeration: Result := IntToStr(AValue.AsOrdinal);
    tkFloat: Result := FloatToStr(AValue.AsExtended);
    else
      Result := AValue.ToString;
  end;
end;

{ Th5uAdjacentGroupRun }

function Th5uAdjacentGroupRun.IsFoldable: Boolean;
begin
  Result := RowCount > 1;
end;

{ Th5uAdjacentGroupRowInfo }

class function Th5uAdjacentGroupRowInfo.Empty: Th5uAdjacentGroupRowInfo;
begin
  Result := Default(Th5uAdjacentGroupRowInfo);
  Result.ViewRowIndex := -1;
  Result.ControllerRowIndex := -1;
  Result.GroupIndex := -1;
  Result.GroupOffset := -1;
  Result.AnchorRowKey := Th5uRowKey.Empty;
end;

{ Th5uAdjacentGroupMap }

procedure Th5uAdjacentGroupMap.AddRow(AControllerRowIndex: Int64; const ARowKey: Th5uRowKey; const AGroupId: TValue; AAvailable: Boolean);
var
  LComparisonKey: string;
  LCanGroup: Boolean;
begin
  LCanGroup := BuildComparisonKey(AGroupId, AControllerRowIndex, AAvailable, LComparisonKey);

  if FHasPendingRun and LCanGroup and (FPendingRun.ComparisonKey = LComparisonKey) then
  begin
    FPendingRun.LastControllerRowIndex := AControllerRowIndex;
    Inc(FPendingRun.RowCount);
    Exit;
  end;

  FinalizePendingRun;

  FPendingRun := Default(Th5uAdjacentGroupRun);
  FPendingRun.ComparisonKey := LComparisonKey;
  FPendingRun.GroupId := AGroupId;
  FPendingRun.AnchorRowKey := ARowKey;
  FPendingRun.FirstControllerRowIndex := AControllerRowIndex;
  FPendingRun.LastControllerRowIndex := AControllerRowIndex;
  FPendingRun.RowCount := 1;
  FPendingRun.StateKey := BuildStateKey(ARowKey, AControllerRowIndex, LComparisonKey);
  FHasPendingRun := True;
end;

procedure Th5uAdjacentGroupMap.BeginBuild(AInitialState: Th5uAdjacentGroupInitialState; ACaseSensitive: Boolean; AGroupEmptyValues: Boolean);
begin
  FRuns.Clear;
  FVisibleControllerRows.Clear;
  FVisibleGroupIndexes.Clear;
  FInitialCollapsed := AInitialState = Th5uAdjacentGroupInitialState.Collapsed;
  FCaseSensitive := ACaseSensitive;
  FGroupEmptyValues := AGroupEmptyValues;
  FHasPendingRun := False;
  FPendingRun := Default(Th5uAdjacentGroupRun);
  FActive := True;
end;

function Th5uAdjacentGroupMap.BuildComparisonKey(const AGroupId: TValue; AControllerRowIndex: Int64; AAvailable: Boolean; out AKey: string): Boolean;
var
  LText: string;
  LTypeName: string;
begin
  Result := AAvailable;
  if not Result then
  begin
    AKey := '#unavailable:' + IntToStr(AControllerRowIndex);
    Exit;
  end;

  LText := h5uAdjacentValueText(AGroupId);
  if (LText = '') and not FGroupEmptyValues then
  begin
    AKey := '#empty:' + IntToStr(AControllerRowIndex);
    Exit(False);
  end;

  if not FCaseSensitive then
    LText := LowerCase(LText);

  if Assigned(AGroupId.TypeInfo) then
    LTypeName := string(AGroupId.TypeInfo.Name)
  else
    LTypeName := '<empty>';

  AKey := LTypeName + ':' + LText;
end;

function Th5uAdjacentGroupMap.BuildStateKey(const ARowKey: Th5uRowKey; AControllerRowIndex: Int64; const AComparisonKey: string): string;
begin
  if not ARowKey.IsEmpty then
    Result := 'row:' + ARowKey.ToString + '|id:' + AComparisonKey
  else
    Result := 'index:' + IntToStr(AControllerRowIndex) + '|id:' + AComparisonKey;
end;

function Th5uAdjacentGroupMap.CollapseAll: Boolean;
var
  I: Integer;
  LRun: Th5uAdjacentGroupRun;
begin
  Result := False;
  for I := 0 to FRuns.Count - 1 do
  begin
    LRun := FRuns[I];
    if LRun.IsFoldable and not LRun.Collapsed then
    begin
      LRun.Collapsed := True;
      FRuns[I] := LRun;
      FCollapsedStates.AddOrSetValue(LRun.StateKey, True);
      Result := True;
    end;
  end;
  if Result then
    RebuildVisibleRows;
end;

procedure Th5uAdjacentGroupMap.Clear(AClearStates: Boolean);
begin
  FRuns.Clear;
  FVisibleControllerRows.Clear;
  FVisibleGroupIndexes.Clear;
  FHasPendingRun := False;
  FPendingRun := Default(Th5uAdjacentGroupRun);
  FActive := False;
  if AClearStates then
    FCollapsedStates.Clear;
end;

constructor Th5uAdjacentGroupMap.Create;
begin
  inherited;
  FRuns := TList<Th5uAdjacentGroupRun>.Create;
  FVisibleControllerRows := TList<Int64>.Create;
  FVisibleGroupIndexes := TList<Integer>.Create;
  FCollapsedStates := TDictionary<string, Boolean>.Create;
end;

destructor Th5uAdjacentGroupMap.Destroy;
begin
  FCollapsedStates.Free;
  FVisibleGroupIndexes.Free;
  FVisibleControllerRows.Free;
  FRuns.Free;
  inherited;
end;

procedure Th5uAdjacentGroupMap.EndBuild;
begin
  FinalizePendingRun;
  RebuildVisibleRows;
end;

function Th5uAdjacentGroupMap.ExpandAll: Boolean;
var
  I: Integer;
  LRun: Th5uAdjacentGroupRun;
begin
  Result := False;
  for I := 0 to FRuns.Count - 1 do
  begin
    LRun := FRuns[I];
    if LRun.IsFoldable and LRun.Collapsed then
    begin
      LRun.Collapsed := False;
      FRuns[I] := LRun;
      FCollapsedStates.AddOrSetValue(LRun.StateKey, False);
      Result := True;
    end;
  end;
  if Result then
    RebuildVisibleRows;
end;

procedure Th5uAdjacentGroupMap.FinalizePendingRun;
var
  LStoredCollapsed: Boolean;
begin
  if not FHasPendingRun then
    Exit;

  if FPendingRun.IsFoldable then
  begin
    if FCollapsedStates.TryGetValue(FPendingRun.StateKey, LStoredCollapsed) then
      FPendingRun.Collapsed := LStoredCollapsed
    else
      FPendingRun.Collapsed := FInitialCollapsed;
  end
  else
    FPendingRun.Collapsed := False;

  FRuns.Add(FPendingRun);
  FHasPendingRun := False;
  FPendingRun := Default(Th5uAdjacentGroupRun);
end;

function Th5uAdjacentGroupMap.GetRun(AIndex: Integer): Th5uAdjacentGroupRun;
begin
  Result := FRuns[AIndex];
end;

function Th5uAdjacentGroupMap.GetRunCount: Integer;
begin
  Result := FRuns.Count;
end;

function Th5uAdjacentGroupMap.GetVisibleRowCount: Int64;
begin
  Result := FVisibleControllerRows.Count;
end;

function Th5uAdjacentGroupMap.MapViewToController(AViewRowIndex: Int64): Int64;
begin
  if (AViewRowIndex < 0) or (AViewRowIndex >= FVisibleControllerRows.Count) then
    Exit(-1);
  Result := FVisibleControllerRows[Integer(AViewRowIndex)];
end;

procedure Th5uAdjacentGroupMap.RebuildVisibleRows;
var
  I: Integer;
  LControllerRow: Int64;
  LRun: Th5uAdjacentGroupRun;
begin
  FVisibleControllerRows.Clear;
  FVisibleGroupIndexes.Clear;

  for I := 0 to FRuns.Count - 1 do
  begin
    LRun := FRuns[I];
    FVisibleControllerRows.Add(LRun.FirstControllerRowIndex);
    FVisibleGroupIndexes.Add(I);

    if LRun.Collapsed then
      Continue;

    LControllerRow := LRun.FirstControllerRowIndex + 1;
    while LControllerRow <= LRun.LastControllerRowIndex do
    begin
      FVisibleControllerRows.Add(LControllerRow);
      FVisibleGroupIndexes.Add(I);
      Inc(LControllerRow);
    end;
  end;
end;

procedure Th5uAdjacentGroupMap.ResetStates;
begin
  FCollapsedStates.Clear;
end;

function Th5uAdjacentGroupMap.SetCollapsedAtViewRow(AViewRowIndex: Int64; ACollapsed: Boolean): Boolean;
var
  LInfo: Th5uAdjacentGroupRowInfo;
  LRun: Th5uAdjacentGroupRun;
begin
  Result := False;
  if not TryGetRowInfo(AViewRowIndex, LInfo) or not LInfo.IsFoldable then
    Exit;

  LRun := FRuns[LInfo.GroupIndex];
  if LRun.Collapsed = ACollapsed then
    Exit;

  LRun.Collapsed := ACollapsed;
  FRuns[LInfo.GroupIndex] := LRun;
  FCollapsedStates.AddOrSetValue(LRun.StateKey, ACollapsed);
  RebuildVisibleRows;
  Result := True;
end;

function Th5uAdjacentGroupMap.ToggleAtViewRow(AViewRowIndex: Int64): Boolean;
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  if not TryGetRowInfo(AViewRowIndex, LInfo) then
    Exit(False);
  Result := SetCollapsedAtViewRow(AViewRowIndex, not LInfo.Collapsed);
end;

function Th5uAdjacentGroupMap.TryGetRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
var
  LIndex: Integer;
  LRun: Th5uAdjacentGroupRun;
begin
  AInfo := Th5uAdjacentGroupRowInfo.Empty;
  Result := FActive and (AViewRowIndex >= 0) and (AViewRowIndex < FVisibleControllerRows.Count);
  if not Result then
    Exit;

  LIndex := Integer(AViewRowIndex);
  LRun := FRuns[FVisibleGroupIndexes[LIndex]];

  AInfo.ViewRowIndex := AViewRowIndex;
  AInfo.ControllerRowIndex := FVisibleControllerRows[LIndex];
  AInfo.GroupIndex := FVisibleGroupIndexes[LIndex];
  AInfo.GroupOffset := AInfo.ControllerRowIndex - LRun.FirstControllerRowIndex;
  AInfo.GroupId := LRun.GroupId;
  AInfo.AnchorRowKey := LRun.AnchorRowKey;
  AInfo.RowCount := LRun.RowCount;
  AInfo.Collapsed := LRun.Collapsed;
  AInfo.IsFirstRow := AInfo.GroupOffset = 0;
  AInfo.IsLastSourceRow := AInfo.ControllerRowIndex = LRun.LastControllerRowIndex;
  AInfo.IsLastVisibleRow := (LRun.Collapsed and AInfo.IsFirstRow) or (not LRun.Collapsed and AInfo.IsLastSourceRow);
  AInfo.IsFoldable := LRun.IsFoldable;
end;

end.
