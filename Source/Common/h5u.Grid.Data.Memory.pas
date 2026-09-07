unit h5u.Grid.Data.Memory;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uMemoryRow = class
  private
    FKey: Th5uRowKey;
    FValues: TDictionary<string, TValue>;
  public
    constructor Create(const AKey: Th5uRowKey);
    destructor Destroy; override;
    function GetValue(const AFieldName: string): TValue;
    procedure SetValue(const AFieldName: string; const AValue: TValue);
    property Key: Th5uRowKey read FKey write FKey;
  end;

  Th5uMemoryController = class(Th5uCustomDataController)
  private
    FRows: TObjectList<Th5uMemoryRow>;
    FNextKey: Int64;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AppendRow: Th5uMemoryRow;
    function AppendValues(const AFieldNames: array of string; const AValues: array of TValue): Th5uMemoryRow;
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    function Row(AIndex: Integer): Th5uMemoryRow;
  end;

implementation

{ Th5uMemoryRow }

constructor Th5uMemoryRow.Create(const AKey: Th5uRowKey);
begin
  inherited Create;
  FKey := AKey;
  FValues := TDictionary<string, TValue>.Create;
end;

destructor Th5uMemoryRow.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

function Th5uMemoryRow.GetValue(const AFieldName: string): TValue;
begin
  if not FValues.TryGetValue(AFieldName.ToUpperInvariant, Result) then
    Result := TValue.Empty;
end;

procedure Th5uMemoryRow.SetValue(const AFieldName: string; const AValue: TValue);
begin
  FValues.AddOrSetValue(AFieldName.ToUpperInvariant, AValue);
end;

{ Th5uMemoryController }

function Th5uMemoryController.AppendRow: Th5uMemoryRow;
var
  LChange: Th5uDataChange;
begin
  Inc(FNextKey);
  Result := Th5uMemoryRow.Create(Th5uRowKey.FromInt64(FNextKey));
  FRows.Add(Result);

  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsInserted;
  LChange.FirstIndex := FRows.Count - 1;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

function Th5uMemoryController.AppendValues(const AFieldNames: array of string; const AValues: array of TValue): Th5uMemoryRow;
var
  I: Integer;
begin
  if Length(AFieldNames) <> Length(AValues) then
    raise Eh5uDataController.Create('Field name and value array lengths differ.');

  BeginUpdate;
  try
    Result := AppendRow;
    for I := 0 to High(AFieldNames) do
      Result.SetValue(AFieldNames[I], AValues[I]);
  finally
    EndUpdate;
  end;
end;

procedure Th5uMemoryController.Clear;
begin
  FRows.Clear;
  Invalidate;
end;

constructor Th5uMemoryController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRows := TObjectList<Th5uMemoryRow>.Create(True);
  FNextKey := 0;
  Cache.Mode := Th5uCacheMode.None;
end;

procedure Th5uMemoryController.DeleteRow(AIndex: Integer);
var
  LChange: Th5uDataChange;
begin
  if (AIndex < 0) or (AIndex >= FRows.Count) then
    Exit;
  FRows.Delete(AIndex);

  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsDeleted;
  LChange.FirstIndex := AIndex;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

destructor Th5uMemoryController.Destroy;
begin
  FRows.Free;
  inherited Destroy;
end;

function Th5uMemoryController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count);
end;

function Th5uMemoryController.GetSourceRowCount: Int64;
begin
  Result := FRows.Count;
end;

function Th5uMemoryController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
begin
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
    Result := FRows[ASourceRowIndex].Key
  else
    Result := Th5uRowKey.Empty;
end;

function Th5uMemoryController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
begin
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit(TValue.Empty);
  Result := FRows[ASourceRowIndex].GetValue(AFieldName);
end;

function Th5uMemoryController.Row(AIndex: Integer): Th5uMemoryRow;
begin
  Result := FRows[AIndex];
end;

procedure Th5uMemoryController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LChange: Th5uDataChange;
begin
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit;

  FRows[ASourceRowIndex].SetValue(AFieldName, AValue);

  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.CellChanged;
  LChange.FirstIndex := ASourceRowIndex;
  LChange.Count := 1;
  LChange.RowKey := FRows[ASourceRowIndex].Key;
  LChange.ColumnId := AFieldName;
  NotifyDataChanged(LChange);
end;

end.
