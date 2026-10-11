unit h5u.Grid.Data.Memory;

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
    Rtti,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  ThiiMemoryRow = class
  private
    FKey: ThiiRowKey;
    FValues: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
  public
    constructor Create(const AKey: ThiiRowKey);
    destructor Destroy; override;
    function GetValue(const AFieldName: string): TValue;
    procedure SetValue(const AFieldName: string; const AValue: TValue);
    property Key: ThiiRowKey read FKey write FKey;
  end;

  ThiiMemoryController = class(ThiiCustomDataController)
  private
    FRows: {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiMemoryRow>;
    FNextKey: Int64;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AppendRow: ThiiMemoryRow;
    function AppendValues(const AFieldNames: array of string; const AValues: array of TValue): ThiiMemoryRow;
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    function Row(AIndex: Integer): ThiiMemoryRow;
  end;

implementation

{ ThiiMemoryRow }

constructor ThiiMemoryRow.Create(const AKey: ThiiRowKey);
begin
  inherited Create;
  FKey := AKey;
  FValues := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>.Create;
end;

destructor ThiiMemoryRow.Destroy;
begin
  FValues.Free;
  inherited;
end;

function ThiiMemoryRow.GetValue(const AFieldName: string): TValue;
begin
  if not FValues.TryGetValue(AFieldName.ToUpperInvariant, Result) then
    Result := TValue.Empty;
end;

procedure ThiiMemoryRow.SetValue(const AFieldName: string; const AValue: TValue);
begin
  FValues.AddOrSetValue(AFieldName.ToUpperInvariant, AValue);
end;

{ ThiiMemoryController }

function ThiiMemoryController.AppendRow: ThiiMemoryRow;
var
  LChange: ThiiDataChange;
begin
  Inc(FNextKey);
  Result := ThiiMemoryRow.Create(ThiiRowKey.FromInt64(FNextKey));
  FRows.Add(Result);

  LChange := Default(ThiiDataChange);
  LChange.Kind := ThiiDataChangeKind.RowsInserted;
  LChange.FirstIndex := FRows.Count - 1;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

function ThiiMemoryController.AppendValues(const AFieldNames: array of string; const AValues: array of TValue): ThiiMemoryRow;
var
  I: Integer;
begin
  if Length(AFieldNames) <> Length(AValues) then
    raise EhiiDataController.Create('Field name and value array lengths differ.');

  BeginUpdate;
  try
    Result := AppendRow;
    for I := 0 to High(AFieldNames) do
      Result.SetValue(AFieldNames[I], AValues[I]);
  finally
    EndUpdate;
  end;
end;

procedure ThiiMemoryController.Clear;
begin
  FRows.Clear;
  Invalidate;
end;

constructor ThiiMemoryController.Create(AOwner: TComponent);
begin
  inherited;
  FRows := {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiMemoryRow>.Create(True);
  FNextKey := 0;
  Cache.Mode := ThiiCacheMode.None;
end;

procedure ThiiMemoryController.DeleteRow(AIndex: Integer);
var
  LChange: ThiiDataChange;
begin
  if (AIndex < 0) or (AIndex >= FRows.Count) then
    Exit;
  FRows.Delete(AIndex);

  LChange := Default(ThiiDataChange);
  LChange.Kind := ThiiDataChangeKind.RowsDeleted;
  LChange.FirstIndex := AIndex;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

destructor ThiiMemoryController.Destroy;
begin
  FRows.Free;
  inherited;
end;

function ThiiMemoryController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count);
end;

function ThiiMemoryController.GetSourceRowCount: Int64;
begin
  Result := FRows.Count;
end;

function ThiiMemoryController.GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey;
begin
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
    Result := FRows[ASourceRowIndex].Key
  else
    Result := ThiiRowKey.Empty;
end;

function ThiiMemoryController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
begin
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit(TValue.Empty);
  Result := FRows[ASourceRowIndex].GetValue(AFieldName);
end;

function ThiiMemoryController.Row(AIndex: Integer): ThiiMemoryRow;
begin
  Result := FRows[AIndex];
end;

procedure ThiiMemoryController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LChange: ThiiDataChange;
begin
  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
    Exit;

  FRows[ASourceRowIndex].SetValue(AFieldName, AValue);

  LChange := Default(ThiiDataChange);
  LChange.Kind := ThiiDataChangeKind.CellChanged;
  LChange.FirstIndex := ASourceRowIndex;
  LChange.Count := 1;
  LChange.RowKey := FRows[ASourceRowIndex].Key;
  LChange.ColumnId := AFieldName;
  NotifyDataChanged(LChange);
end;

end.

