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
    FKeepAcrossPages: Boolean;
    FSelectedRows: TDictionary<string, Byte>;
    FSelectedColumns: TDictionary<string, Byte>;
    FCellRanges: TList<Th5uCellRange>;
    FAllRowsSelected: Boolean;
    FExcludedRows: TDictionary<string, Byte>;
    FFocusedCell: Th5uCellAddress;
    FAnchorCell: Th5uCellAddress;
    FOnChanged: Th5uSelectionChangedEvent;
    procedure Changed;
    procedure SetAllowedKinds(const AValue: Th5uSelectionKinds);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure ClearRows;
    procedure ClearColumns;
    procedure ClearCellRanges;

    procedure SelectRow(const ARowKey: Th5uRowKey; AAdd: Boolean = False);
    procedure ToggleRow(const ARowKey: Th5uRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: Th5uRowKey);
    function IsRowSelected(const ARowKey: Th5uRowKey): Boolean;

    procedure SelectColumn(const AColumnId: string; AAdd: Boolean = False);
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;

    procedure AddCellRange(const ARange: Th5uCellRange; AAdd: Boolean = False);
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
    property MultiRange: Boolean read FMultiRange write FMultiRange default True;
    property KeepAcrossPages: Boolean read FKeepAcrossPages write FKeepAcrossPages default True;
  end;

implementation

{ Th5uGridSelection }

procedure Th5uGridSelection.AddCellRange(const ARange: Th5uCellRange; AAdd: Boolean);
var
  LRange: Th5uCellRange;
begin
  if not (Th5uSelectionKind.CellRanges in FAllowedKinds) then
    Exit;

  if not AAdd or not FMultiRange then
    ClearCellRanges;

  if (FCombinationMode = Th5uSelectionCombinationMode.Exclusive) then
  begin
    ClearRows;
    ClearColumns;
  end;

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
  FSelectedRows.Clear;
  FSelectedColumns.Clear;
  FCellRanges.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
  FFocusedCell := Th5uCellAddress.Empty;
  FAnchorCell := Th5uCellAddress.Empty;
  Changed;
end;

procedure Th5uGridSelection.ClearCellRanges;
begin
  FCellRanges.Clear;
end;

procedure Th5uGridSelection.ClearColumns;
begin
  FSelectedColumns.Clear;
end;

procedure Th5uGridSelection.ClearRows;
begin
  FSelectedRows.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := False;
end;

constructor Th5uGridSelection.Create;
begin
  inherited Create;
  FAllowedKinds := [
    Th5uSelectionKind.Rows,
    Th5uSelectionKind.Columns,
    Th5uSelectionKind.CellRanges
  ];
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
  FExcludedRows.Free;
  FCellRanges.Free;
  FSelectedColumns.Free;
  FSelectedRows.Free;
  inherited Destroy;
end;

procedure Th5uGridSelection.ExcludeRow(const ARowKey: Th5uRowKey);
begin
  if not FAllRowsSelected then
    Exit;
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

  FSelectedRows.Clear;
  FExcludedRows.Clear;
  FAllRowsSelected := True;
  Changed;
end;

procedure Th5uGridSelection.SelectColumn(const AColumnId: string; AAdd: Boolean);
begin
  if not (Th5uSelectionKind.Columns in FAllowedKinds) then
    Exit;

  if not AAdd then
    ClearColumns;

  if FCombinationMode = Th5uSelectionCombinationMode.Exclusive then
  begin
    ClearRows;
    ClearCellRanges;
  end;

  FSelectedColumns.AddOrSetValue(AColumnId, 0);
  Changed;
end;

procedure Th5uGridSelection.SelectRow(const ARowKey: Th5uRowKey; AAdd: Boolean);
begin
  if not (Th5uSelectionKind.Rows in FAllowedKinds) then
    Exit;

  if not AAdd then
    ClearRows;

  if FCombinationMode = Th5uSelectionCombinationMode.Exclusive then
  begin
    ClearColumns;
    ClearCellRanges;
  end;

  FAllRowsSelected := False;
  FSelectedRows.AddOrSetValue(ARowKey.ToString, 0);
  Changed;
end;

procedure Th5uGridSelection.SetAllowedKinds(const AValue: Th5uSelectionKinds);
begin
  if FAllowedKinds = AValue then
    Exit;
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
    FAnchorCell := ACell;
  Changed;
end;

procedure Th5uGridSelection.ToggleColumn(const AColumnId: string);
begin
  if IsColumnSelected(AColumnId) then
    FSelectedColumns.Remove(AColumnId)
  else
    SelectColumn(AColumnId, True);
  Changed;
end;

procedure Th5uGridSelection.ToggleRow(const ARowKey: Th5uRowKey);
begin
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
  LRowKey: Th5uRowKey;
  LColumnId: string;
  LRange: Th5uCellRange;
begin
  if Source is Th5uGridSelection then
  begin
    LSource := Th5uGridSelection(Source);

    FAllowedKinds := LSource.FAllowedKinds;
    FCombinationMode := LSource.FCombinationMode;
    FMultiRange := LSource.FMultiRange;
    FScope := LSource.FScope;
    FKeepAcrossPages := LSource.FKeepAcrossPages;
    FFocusedCell := LSource.FFocusedCell;
    FAnchorCell := LSource.FAnchorCell;
    FAllRowsSelected := LSource.FAllRowsSelected;

    FSelectedRows.Clear;
    for LRowKey in LSource.FSelectedRows do
      FSelectedRows.Add(LRowKey);

    FExcludedRows.Clear;
    for LRowKey in LSource.FExcludedRows do
      FExcludedRows.Add(LRowKey);

    FSelectedColumns.Clear;
    for LColumnId in LSource.FSelectedColumns do
      FSelectedColumns.Add(LColumnId);

    FCellRanges.Clear;
    for LRange in LSource.FCellRanges do
      FCellRanges.Add(LRange);

    Changed;
  end
  else
    inherited Assign(Source);
end;

end.
