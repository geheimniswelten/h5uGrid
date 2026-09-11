unit h5u.Grid.Selection;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  h5u.Grid.Types;

type
  Th5uSelectionChangedEvent = procedure(Sender: TObject) of object;

  Th5uGridSelection = class(TPersistent)
  private
    FAllowedKinds: Th5uSelectionKinds;
    FCombinationMode: Th5uSelectionCombinationMode;
    FScope: Th5uSelectionScope;
    FMultiRange: Boolean;
    FRightClickSelect: Boolean;
    FKeepAcrossPages: Boolean;
    FSelectedRows: TDictionary<string, Byte>;
    FSelectedColumns: TDictionary<string, Byte>;
    FCellRanges: TList<Th5uCellRange>;
    FAllRowsSelected: Boolean;
    FExcludedRows: TDictionary<string, Byte>;
    FFocusedCell: Th5uCellAddress;
    FAnchorCell: Th5uCellAddress;
    FExtensionBase: Th5uGridSelection;
    FExtensionKind: Th5uSelectionKind;
    FExtensionAdd: Boolean;
    FOnChanged: Th5uSelectionChangedEvent;
    function GetSelectedColumnCount: Integer;
    procedure ResetExtension;
    procedure CopySelection(ASource: Th5uGridSelection);
    procedure PrepareSelection(AKind: Th5uSelectionKind; AAdd, AExtend: Boolean);
    procedure Changed;
    procedure SetAllowedKinds(const AValue: Th5uSelectionKinds);
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

    procedure SelectRow(const ARowKey: Th5uRowKey; AAdd: Boolean = False);
    procedure SelectRows(const ARowKeys: array of Th5uRowKey; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleRow(const ARowKey: Th5uRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: Th5uRowKey);
    function IsRowSelected(const ARowKey: Th5uRowKey): Boolean;

    procedure SelectColumn(const AColumnId: string; AAdd: Boolean = False);
    procedure SelectColumns(const AColumnIds: array of string; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;

    procedure AddCellRange(const ARange: Th5uCellRange; AAdd: Boolean = False; AExtend: Boolean = False);
    function IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;

    procedure SetFocus(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean);

    property CellRanges: TList<Th5uCellRange> read FCellRanges;
    property FocusedCell: Th5uCellAddress read FFocusedCell;
    property AnchorCell: Th5uCellAddress read FAnchorCell;
    property AllRowsSelected: Boolean read FAllRowsSelected;
    property OnChanged: Th5uSelectionChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowedKinds: Th5uSelectionKinds read FAllowedKinds write SetAllowedKinds;
    property CombinationMode: Th5uSelectionCombinationMode read FCombinationMode write FCombinationMode default Th5uSelectionCombinationMode.Mixed;
    property Scope: Th5uSelectionScope read FScope write FScope default Th5uSelectionScope.CurrentQuery;
    property RightClickSelect: Boolean read FRightClickSelect write FRightClickSelect default False;
    property MultiRange: Boolean read FMultiRange write FMultiRange default True;
    property KeepAcrossPages: Boolean read FKeepAcrossPages write FKeepAcrossPages default True;
  end;

implementation

{ Th5uGridSelection }

function Th5uGridSelection.GetSelectedColumnCount: Integer;
begin
  Result := FSelectedColumns.Count;
end;

function Th5uGridSelection.SelectedRowCount(ATotalRowCount: Int64): Int64;
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

procedure Th5uGridSelection.ResetExtension;
begin
  FreeAndNil(FExtensionBase);
end;

procedure Th5uGridSelection.CopySelection(ASource: Th5uGridSelection);
var
  LPair: TPair<string, Byte>;
  LRange: Th5uCellRange;
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

procedure Th5uGridSelection.PrepareSelection(AKind: Th5uSelectionKind; AAdd, AExtend: Boolean);
begin
  if AExtend then
  begin
    if not Assigned(FExtensionBase) or (FExtensionKind <> AKind) or (FExtensionAdd <> AAdd) then
    begin
      ResetExtension;
      FExtensionBase := Th5uGridSelection.Create;
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

  if not AAdd or ((FCombinationMode = Th5uSelectionCombinationMode.Exclusive) and (AKind <> Th5uSelectionKind.Rows)) then
  begin
    FSelectedRows.Clear;
    FExcludedRows.Clear;
    FAllRowsSelected := False;
  end;
  if not AAdd or ((FCombinationMode = Th5uSelectionCombinationMode.Exclusive) and (AKind <> Th5uSelectionKind.Columns)) then
    FSelectedColumns.Clear;
  if not AAdd or ((FCombinationMode = Th5uSelectionCombinationMode.Exclusive) and (AKind <> Th5uSelectionKind.CellRanges)) then
    FCellRanges.Clear;
end;


procedure Th5uGridSelection.AddCellRange(const ARange: Th5uCellRange; AAdd, AExtend: Boolean);
var
  LRange: Th5uCellRange;
begin
  if not (Th5uSelectionKind.CellRanges in FAllowedKinds) then
    Exit;
  PrepareSelection(Th5uSelectionKind.CellRanges, AAdd, AExtend);
  if not FMultiRange then
    FCellRanges.Clear;
  LRange := ARange;
  LRange.Normalize;
  FCellRanges.Add(LRange);
  Changed;
end;

procedure Th5uGridSelection.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure Th5uGridSelection.Clear;
begin
  ResetExtension;
  FSelectedRows.Clear;
  FSelectedColumns.Clear;
  FCellRanges.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
  FFocusedCell := Th5uCellAddress.Empty;
  FAnchorCell := Th5uCellAddress.Empty;
  Changed;
end;

procedure Th5uGridSelection.ClearExtendedSelection;
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

procedure Th5uGridSelection.ClearCellRanges;
begin
  ResetExtension;
  FCellRanges.Clear;
end;

procedure Th5uGridSelection.ClearColumns;
begin
  ResetExtension;
  FSelectedColumns.Clear;
end;

procedure Th5uGridSelection.ClearRows;
begin
  ResetExtension;
  FSelectedRows.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
end;

constructor Th5uGridSelection.Create;
begin
  inherited;
  FAllowedKinds := [Th5uSelectionKind.Rows, Th5uSelectionKind.Columns, Th5uSelectionKind.CellRanges];
  FCombinationMode := Th5uSelectionCombinationMode.Mixed;
  FScope := Th5uSelectionScope.CurrentQuery;
  FMultiRange := True;
  FKeepAcrossPages := True;
  FSelectedRows := TDictionary<string, Byte>.Create;
  FSelectedColumns := TDictionary<string, Byte>.Create;
  FCellRanges := TList<Th5uCellRange>.Create;
  FExcludedRows := TDictionary<string, Byte>.Create;
  FFocusedCell := Th5uCellAddress.Empty;
  FAnchorCell := Th5uCellAddress.Empty;
end;

destructor Th5uGridSelection.Destroy;
begin
  FExtensionBase.Free;
  FExcludedRows.Free;
  FCellRanges.Free;
  FSelectedColumns.Free;
  FSelectedRows.Free;
  inherited;
end;

procedure Th5uGridSelection.ExcludeRow(const ARowKey: Th5uRowKey);
begin
  if not FAllRowsSelected then
    Exit;
  ResetExtension;
  FExcludedRows.AddOrSetValue(ARowKey.ToString, 0);
  Changed;
end;

function Th5uGridSelection.IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
var
  LRange: Th5uCellRange;
begin
  Result := False;
  for LRange in FCellRanges do
    if LRange.Contains(ARowIndex, AColumnIndex) then
      Exit(True);
end;

function Th5uGridSelection.IsColumnSelected(const AColumnId: string): Boolean;
begin
  Result := FSelectedColumns.ContainsKey(AColumnId);
end;

function Th5uGridSelection.IsRowSelected(const ARowKey: Th5uRowKey): Boolean;
begin
  if FAllRowsSelected then
    Exit(not FExcludedRows.ContainsKey(ARowKey.ToString));

  Result := FSelectedRows.ContainsKey(ARowKey.ToString);
end;

procedure Th5uGridSelection.SelectAllRows;
begin
  if not (Th5uSelectionKind.Rows in FAllowedKinds) then
    Exit;

  if FCombinationMode = Th5uSelectionCombinationMode.Exclusive then
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

procedure Th5uGridSelection.SelectColumn(const AColumnId: string; AAdd: Boolean);
begin
  SelectColumns([AColumnId], AAdd);
end;

procedure Th5uGridSelection.SelectColumns(const AColumnIds: array of string; AAdd, AExtend: Boolean);
var
  LId: string;
begin
  if not (Th5uSelectionKind.Columns in FAllowedKinds) then
    Exit;
  PrepareSelection(Th5uSelectionKind.Columns, AAdd, AExtend);
  for LId in AColumnIds do
    FSelectedColumns.AddOrSetValue(LId, 0);
  Changed;
end;

procedure Th5uGridSelection.SelectRow(const ARowKey: Th5uRowKey; AAdd: Boolean);
begin
  SelectRows([ARowKey], AAdd);
end;

procedure Th5uGridSelection.SelectRows(const ARowKeys: array of Th5uRowKey; AAdd, AExtend: Boolean);
var
  LKey: Th5uRowKey;
begin
  if not (Th5uSelectionKind.Rows in FAllowedKinds) then
    Exit;
  PrepareSelection(Th5uSelectionKind.Rows, AAdd, AExtend);
  for LKey in ARowKeys do
    if FAllRowsSelected then
      FExcludedRows.Remove(LKey.ToString)
    else
      FSelectedRows.AddOrSetValue(LKey.ToString, 0);
  Changed;
end;

procedure Th5uGridSelection.SetAllowedKinds(const AValue: Th5uSelectionKinds);
begin
  if FAllowedKinds = AValue then
    Exit;
  ResetExtension;
  FAllowedKinds := AValue;

  if not (Th5uSelectionKind.Rows in FAllowedKinds) then
    ClearRows;
  if not (Th5uSelectionKind.Columns in FAllowedKinds) then
    ClearColumns;
  if not (Th5uSelectionKind.CellRanges in FAllowedKinds) then
    ClearCellRanges;

  Changed;
end;

procedure Th5uGridSelection.SetFocus(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean);
begin
  FFocusedCell := ACell;
  if AUpdateAnchor then
  begin
    ResetExtension;
    FAnchorCell := ACell;
  end;
  Changed;
end;

procedure Th5uGridSelection.ToggleColumn(const AColumnId: string);
begin
  if not (Th5uSelectionKind.Columns in FAllowedKinds) then
    Exit;
  PrepareSelection(Th5uSelectionKind.Columns, True, False);
  if IsColumnSelected(AColumnId) then
    FSelectedColumns.Remove(AColumnId)
  else
    FSelectedColumns.AddOrSetValue(AColumnId, 0);
  Changed;
end;

procedure Th5uGridSelection.ToggleRow(const ARowKey: Th5uRowKey);
begin
  if not (Th5uSelectionKind.Rows in FAllowedKinds) then
    Exit;
  PrepareSelection(Th5uSelectionKind.Rows, True, False);
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


procedure Th5uGridSelection.Assign(Source: TPersistent);
var
  LSource: Th5uGridSelection;
  LPair: TPair<string, Byte>;
  LRange: Th5uCellRange;
begin
  if Source = Self then
    Exit;

  if Source is Th5uGridSelection then
  begin
    ResetExtension;
    LSource := Th5uGridSelection(Source);

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
