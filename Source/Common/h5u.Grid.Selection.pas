unit h5u.Grid.Selection;

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
    Classes,
    Generics.Collections,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Types;

type
  ThiiSelectionChangedEvent = procedure(Sender: TObject) of object;

  ThiiGridSelection = class(TPersistent)
  private
    FAllowedKinds: ThiiSelectionKinds;
    FCombinationMode: ThiiSelectionCombinationMode;
    FScope: ThiiSelectionScope;
    FMultiRange: Boolean;
    FRightClickSelect: Boolean;
    FKeepAcrossPages: Boolean;
    FSelectedRows: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FSelectedColumns: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FCellRanges: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiCellRange>;
    FAllRowsSelected: Boolean;
    FExcludedRows: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FFocusedCell: ThiiCellAddress;
    FAnchorCell: ThiiCellAddress;
    FExtensionBase: ThiiGridSelection;
    FExtensionKind: ThiiSelectionKind;
    FExtensionAdd: Boolean;
    FOnChanged: ThiiSelectionChangedEvent;
    function GetSelectedColumnCount: Integer;
    procedure ResetExtension;
    procedure CopySelection(ASource: ThiiGridSelection);
    procedure PrepareSelection(AKind: ThiiSelectionKind; AAdd, AExtend: Boolean);
    procedure Changed;
    procedure SetAllowedKinds(const AValue: ThiiSelectionKinds);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create;
    destructor Destroy; override;

    function SelectedRowCount(ATotalRowCount: Int64): Int64;
    property SelectedColumnCount: Integer read GetSelectedColumnCount;
    procedure Clear;
    procedure ClearExtendedSelection;
    procedure ClearRows;
    procedure ClearColumns;
    procedure ClearCellRanges;

    procedure SelectRow(const ARowKey: ThiiRowKey; AAdd: Boolean = False);
    procedure SelectRows(const ARowKeys: array of ThiiRowKey; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleRow(const ARowKey: ThiiRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: ThiiRowKey);
    function IsRowSelected(const ARowKey: ThiiRowKey): Boolean;

    procedure SelectColumn(const AColumnId: string; AAdd: Boolean = False);
    procedure SelectColumns(const AColumnIds: array of string; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;

    procedure AddCellRange(const ARange: ThiiCellRange; AAdd: Boolean = False; AExtend: Boolean = False);
    function IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;

    procedure SetFocus(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean);

    property CellRanges: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiCellRange> read FCellRanges;
    property FocusedCell: ThiiCellAddress read FFocusedCell;
    property AnchorCell: ThiiCellAddress read FAnchorCell;
    property AllRowsSelected: Boolean read FAllRowsSelected;
    property OnChanged: ThiiSelectionChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowedKinds: ThiiSelectionKinds read FAllowedKinds write SetAllowedKinds;
    property CombinationMode: ThiiSelectionCombinationMode read FCombinationMode write FCombinationMode default ThiiSelectionCombinationMode.Mixed;
    property Scope: ThiiSelectionScope read FScope write FScope default ThiiSelectionScope.CurrentQuery;
    property RightClickSelect: Boolean read FRightClickSelect write FRightClickSelect default False;
    property MultiRange: Boolean read FMultiRange write FMultiRange default True;
    property KeepAcrossPages: Boolean read FKeepAcrossPages write FKeepAcrossPages default True;
  end;

implementation

{ ThiiGridSelection }

function ThiiGridSelection.GetSelectedColumnCount: Integer;
begin
  Result := FSelectedColumns.Count;
end;

function ThiiGridSelection.SelectedRowCount(ATotalRowCount: Int64): Int64;
begin
  if FAllRowsSelected then
  begin
    Result := ATotalRowCount - FExcludedRows.Count;
    if Result < 0 then
      Result := 0;
  end
  else
    Result := FSelectedRows.Count;
end;

procedure ThiiGridSelection.ResetExtension;
begin
  FreeAndNil(FExtensionBase);
end;

procedure ThiiGridSelection.CopySelection(ASource: ThiiGridSelection);
var
  LPair: {$IFDEF FPC}specialize {$ENDIF}TPair<string, Byte>;
  LRange: ThiiCellRange;
begin
  FAllRowsSelected := ASource.FAllRowsSelected;
  FSelectedRows.Clear;
  for LPair in ASource.FSelectedRows do
    FSelectedRows.Add(LPair.Key, LPair.Value);
  FExcludedRows.Clear;
  for LPair in ASource.FExcludedRows do
    FExcludedRows.Add(LPair.Key, LPair.Value);
  FSelectedColumns.Clear;
  for LPair in ASource.FSelectedColumns do
    FSelectedColumns.Add(LPair.Key, LPair.Value);
  FCellRanges.Clear;
  for LRange in ASource.FCellRanges do
    FCellRanges.Add(LRange);
end;

procedure ThiiGridSelection.PrepareSelection(AKind: ThiiSelectionKind; AAdd, AExtend: Boolean);
begin
  if AExtend then
  begin
    if not Assigned(FExtensionBase) or (FExtensionKind <> AKind) or (FExtensionAdd <> AAdd) then
    begin
      ResetExtension;
      FExtensionBase := ThiiGridSelection.Create;
      FExtensionBase.CopySelection(Self);
      FExtensionKind := AKind;
      FExtensionAdd := AAdd;
    end;
    // Rebuild from the original selection so reversing Shift navigation can
    // shrink the new range without deleting a previously selected range.
    CopySelection(FExtensionBase);
  end
  else
    ResetExtension;

  if not AAdd or ((FCombinationMode = ThiiSelectionCombinationMode.Exclusive) and (AKind <> ThiiSelectionKind.Rows)) then
  begin
    FSelectedRows.Clear;
    FExcludedRows.Clear;
    FAllRowsSelected := False;
  end;
  if not AAdd or ((FCombinationMode = ThiiSelectionCombinationMode.Exclusive) and (AKind <> ThiiSelectionKind.Columns)) then
    FSelectedColumns.Clear;
  if not AAdd or ((FCombinationMode = ThiiSelectionCombinationMode.Exclusive) and (AKind <> ThiiSelectionKind.CellRanges)) then
    FCellRanges.Clear;
end;


procedure ThiiGridSelection.AddCellRange(const ARange: ThiiCellRange; AAdd, AExtend: Boolean);
var
  LRange: ThiiCellRange;
begin
  if not (ThiiSelectionKind.CellRanges in FAllowedKinds) then
    Exit;
  PrepareSelection(ThiiSelectionKind.CellRanges, AAdd, AExtend);
  if not FMultiRange then
    FCellRanges.Clear;
  LRange := ARange;
  LRange.Normalize;
  FCellRanges.Add(LRange);
  Changed;
end;

procedure ThiiGridSelection.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiGridSelection.Clear;
begin
  ResetExtension;
  FSelectedRows.Clear;
  FSelectedColumns.Clear;
  FCellRanges.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
  FFocusedCell := ThiiCellAddress.Empty;
  FAnchorCell := ThiiCellAddress.Empty;
  Changed;
end;

procedure ThiiGridSelection.ClearExtendedSelection;
var
  LKeepSingleCell: Boolean;
begin
  LKeepSingleCell := (FCellRanges.Count = 1);
  if LKeepSingleCell then
    LKeepSingleCell := (FCellRanges[0].StartRowIndex = FCellRanges[0].EndRowIndex)
      and (FCellRanges[0].StartColumnIndex = FCellRanges[0].EndColumnIndex);
  ClearRows;
  ClearColumns;
  if not LKeepSingleCell then
    ClearCellRanges;
  // Keyboard focus and its anchor survive Escape, including when no cell is selected.
  Changed;
end;

procedure ThiiGridSelection.ClearCellRanges;
begin
  ResetExtension;
  FCellRanges.Clear;
end;

procedure ThiiGridSelection.ClearColumns;
begin
  ResetExtension;
  FSelectedColumns.Clear;
end;

procedure ThiiGridSelection.ClearRows;
begin
  ResetExtension;
  FSelectedRows.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
end;

constructor ThiiGridSelection.Create;
begin
  inherited;
  FAllowedKinds := [ThiiSelectionKind.Rows, ThiiSelectionKind.Columns, ThiiSelectionKind.CellRanges];
  FCombinationMode := ThiiSelectionCombinationMode.Mixed;
  FScope := ThiiSelectionScope.CurrentQuery;
  FMultiRange := True;
  FKeepAcrossPages := True;
  FSelectedRows := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>.Create;
  FSelectedColumns := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>.Create;
  FCellRanges := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiCellRange>.Create;
  FExcludedRows := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>.Create;
  FFocusedCell := ThiiCellAddress.Empty;
  FAnchorCell := ThiiCellAddress.Empty;
end;

destructor ThiiGridSelection.Destroy;
begin
  FExtensionBase.Free;
  FExcludedRows.Free;
  FCellRanges.Free;
  FSelectedColumns.Free;
  FSelectedRows.Free;
  inherited;
end;

procedure ThiiGridSelection.ExcludeRow(const ARowKey: ThiiRowKey);
begin
  if not FAllRowsSelected then
    Exit;
  ResetExtension;
  FExcludedRows.AddOrSetValue(ARowKey.ToString, 0);
  Changed;
end;

function ThiiGridSelection.IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
var
  LRange: ThiiCellRange;
begin
  Result := False;
  for LRange in FCellRanges do
    if LRange.Contains(ARowIndex, AColumnIndex) then
      Exit(True);
end;

function ThiiGridSelection.IsColumnSelected(const AColumnId: string): Boolean;
begin
  Result := FSelectedColumns.ContainsKey(AColumnId);
end;

function ThiiGridSelection.IsRowSelected(const ARowKey: ThiiRowKey): Boolean;
begin
  if FAllRowsSelected then
    Exit(not FExcludedRows.ContainsKey(ARowKey.ToString));

  Result := FSelectedRows.ContainsKey(ARowKey.ToString);
end;

procedure ThiiGridSelection.SelectAllRows;
begin
  if not (ThiiSelectionKind.Rows in FAllowedKinds) then
    Exit;

  if FCombinationMode = ThiiSelectionCombinationMode.Exclusive then
  begin
    ClearColumns;
    ClearCellRanges;
  end;

  ResetExtension;
  FSelectedRows.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := True;
  Changed;
end;

procedure ThiiGridSelection.SelectColumn(const AColumnId: string; AAdd: Boolean);
begin
  SelectColumns([AColumnId], AAdd);
end;

procedure ThiiGridSelection.SelectColumns(const AColumnIds: array of string; AAdd, AExtend: Boolean);
var
  LId: string;
begin
  if not (ThiiSelectionKind.Columns in FAllowedKinds) then
    Exit;
  PrepareSelection(ThiiSelectionKind.Columns, AAdd, AExtend);
  for LId in AColumnIds do
    FSelectedColumns.AddOrSetValue(LId, 0);
  Changed;
end;

procedure ThiiGridSelection.SelectRow(const ARowKey: ThiiRowKey; AAdd: Boolean);
begin
  SelectRows([ARowKey], AAdd);
end;

procedure ThiiGridSelection.SelectRows(const ARowKeys: array of ThiiRowKey; AAdd, AExtend: Boolean);
var
  LKey: ThiiRowKey;
begin
  if not (ThiiSelectionKind.Rows in FAllowedKinds) then
    Exit;
  PrepareSelection(ThiiSelectionKind.Rows, AAdd, AExtend);
  for LKey in ARowKeys do
    if FAllRowsSelected then
      FExcludedRows.Remove(LKey.ToString)
    else
      FSelectedRows.AddOrSetValue(LKey.ToString, 0);
  Changed;
end;

procedure ThiiGridSelection.SetAllowedKinds(const AValue: ThiiSelectionKinds);
begin
  if FAllowedKinds = AValue then
    Exit;
  ResetExtension;
  FAllowedKinds := AValue;

  if not (ThiiSelectionKind.Rows in FAllowedKinds) then
    ClearRows;
  if not (ThiiSelectionKind.Columns in FAllowedKinds) then
    ClearColumns;
  if not (ThiiSelectionKind.CellRanges in FAllowedKinds) then
    ClearCellRanges;

  Changed;
end;

procedure ThiiGridSelection.SetFocus(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean);
begin
  FFocusedCell := ACell;
  if AUpdateAnchor then
  begin
    ResetExtension;
    FAnchorCell := ACell;
  end;
  Changed;
end;

procedure ThiiGridSelection.ToggleColumn(const AColumnId: string);
begin
  if not (ThiiSelectionKind.Columns in FAllowedKinds) then
    Exit;
  PrepareSelection(ThiiSelectionKind.Columns, True, False);
  if IsColumnSelected(AColumnId) then
    FSelectedColumns.Remove(AColumnId)
  else
    FSelectedColumns.AddOrSetValue(AColumnId, 0);
  Changed;
end;

procedure ThiiGridSelection.ToggleRow(const ARowKey: ThiiRowKey);
begin
  if not (ThiiSelectionKind.Rows in FAllowedKinds) then
    Exit;
  PrepareSelection(ThiiSelectionKind.Rows, True, False);
  if FAllRowsSelected then
  begin
    if FExcludedRows.ContainsKey(ARowKey.ToString) then
      FExcludedRows.Remove(ARowKey.ToString)
    else
      FExcludedRows.AddOrSetValue(ARowKey.ToString, 0);
  end
  else if FSelectedRows.ContainsKey(ARowKey.ToString) then
    FSelectedRows.Remove(ARowKey.ToString)
  else
    FSelectedRows.AddOrSetValue(ARowKey.ToString, 0);
  Changed;
end;


procedure ThiiGridSelection.Assign(Source: TPersistent);
var
  LSource: ThiiGridSelection;
  LPair: {$IFDEF FPC}specialize {$ENDIF}TPair<string, Byte>;
  LRange: ThiiCellRange;
begin
  if Source = Self then
    Exit;

  if Source is ThiiGridSelection then
  begin
    ResetExtension;
    LSource := ThiiGridSelection(Source);

    FAllowedKinds := LSource.FAllowedKinds;
    FCombinationMode := LSource.FCombinationMode;
    FMultiRange := LSource.FMultiRange;
    FRightClickSelect := LSource.FRightClickSelect;
    FScope := LSource.FScope;
    FKeepAcrossPages := LSource.FKeepAcrossPages;
    FFocusedCell := LSource.FFocusedCell;
    FAnchorCell := LSource.FAnchorCell;
    FAllRowsSelected := LSource.FAllRowsSelected;

    FSelectedRows.Clear;
    for LPair in LSource.FSelectedRows do
      FSelectedRows.Add(LPair.Key, LPair.Value);

    FExcludedRows.Clear;
    for LPair in LSource.FExcludedRows do
      FExcludedRows.Add(LPair.Key, LPair.Value);

    FSelectedColumns.Clear;
    for LPair in LSource.FSelectedColumns do
      FSelectedColumns.Add(LPair.Key, LPair.Value);

    FCellRanges.Clear;
    for LRange in LSource.FCellRanges do
      FCellRanges.Add(LRange);

    Changed;
  end
  else
    inherited;
end;

end.

