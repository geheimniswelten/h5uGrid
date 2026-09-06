unit h5u.Grid.Data.Objects;

interface

{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uObjectListController = class(Th5uCustomDataController)
  private
    FItems: TList<TObject>;
    FOwnsObjects: Boolean;
    FKeyPropertyName: string;
    FRttiContext: TRttiContext;
    FPropertyCache: TDictionary<string, TRttiProperty>;
    FValueCache: TDictionary<string, TValue>;
    function ResolveProperty(AObject: TObject; const APropertyName: string): TRttiProperty;
    function ReadPropertyPath(AObject: TObject; const APath: string): TValue;
    procedure WritePropertyPath(AObject: TObject; const APath: string; const AValue: TValue);
    function ValueCacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(AObject: TObject);
    procedure Insert(AIndex: Integer; AObject: TObject);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    procedure NotifyObjectChanged(AObject: TObject; const APropertyName: string = '');
    function Item(AIndex: Integer): TObject;

    function GetCount: Integer;
    property Count: Integer read GetCount;
  published
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects default False;
    property KeyPropertyName: string read FKeyPropertyName write FKeyPropertyName;
  end;

implementation

{ Th5uObjectListController }

procedure Th5uObjectListController.Add(AObject: TObject);
var
  LChange: Th5uDataChange;
begin
  if not Assigned(AObject) then
    Exit;
  FItems.Add(AObject);
  ClearValueCache;

  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsInserted;
  LChange.FirstIndex := FItems.Count - 1;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

procedure Th5uObjectListController.Clear;
var
  LObject: TObject;
begin
  if FOwnsObjects then
    for LObject in FItems do
      LObject.Free;

  FItems.Clear;
  ClearValueCache;
  Invalidate;
end;

procedure Th5uObjectListController.ClearValueCache;
begin
  FValueCache.Clear;
end;

constructor Th5uObjectListController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TList<TObject>.Create;
  FOwnsObjects := False;
  FRttiContext := TRttiContext.Create;
  FPropertyCache := TDictionary<string, TRttiProperty>.Create;
  FValueCache := TDictionary<string, TValue>.Create;
  Cache.Mode := Th5uCacheMode.None;
end;

procedure Th5uObjectListController.Delete(AIndex: Integer);
var
  LObject: TObject;
  LChange: Th5uDataChange;
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    Exit;

  LObject := FItems[AIndex];
  FItems.Delete(AIndex);
  if FOwnsObjects then
    LObject.Free;

  ClearValueCache;
  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsDeleted;
  LChange.FirstIndex := AIndex;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

destructor Th5uObjectListController.Destroy;
begin
  Clear;
  FValueCache.Free;
  FPropertyCache.Free;
  FRttiContext.Free;
  FItems.Free;
  inherited Destroy;
end;

procedure Th5uObjectListController.DoCacheOptionsChanged;
begin
  inherited DoCacheOptionsChanged;
  ClearValueCache;
end;

function Th5uObjectListController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
var
  LObject: TObject;
  LParts: TArray<string>;
  I: Integer;
  LProperty: TRttiProperty;
  LValue: TValue;
begin
  Result := False;
  if (ASourceRowIndex < 0) or
     (ASourceRowIndex >= FItems.Count) then
    Exit;

  LObject := FItems[ASourceRowIndex];
  LParts := AFieldName.Split(['.']);
  if Length(LParts) = 0 then
    Exit;

  for I := 0 to High(LParts) - 1 do
  begin
    LProperty := ResolveProperty(LObject, LParts[I]);
    if not Assigned(LProperty) or not LProperty.IsReadable then
      Exit;
    LValue := LProperty.GetValue(LObject);
    if not LValue.IsObject then
      Exit;
    LObject := LValue.AsObject;
    if not Assigned(LObject) then
      Exit;
  end;

  LProperty := ResolveProperty(LObject, LParts[High(LParts)]);
  Result := Assigned(LProperty) and LProperty.IsWritable;
end;

function Th5uObjectListController.GetSourceRowCount: Int64;
begin
  Result := FItems.Count;
end;

function Th5uObjectListController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
var
  LValue: TValue;
begin
  if (FKeyPropertyName <> '') and
     (ASourceRowIndex >= 0) and
     (ASourceRowIndex < FItems.Count) then
  begin
    LValue := ReadPropertyPath(
      FItems[ASourceRowIndex],
      FKeyPropertyName
    );
    if not LValue.IsEmpty then
      Exit(Th5uRowKey.FromString(LValue.ToString));
  end;

  Result := inherited GetSourceRowKey(ASourceRowIndex);
end;

function Th5uObjectListController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LCacheKey: string;
begin
  if (ASourceRowIndex < 0) or
     (ASourceRowIndex >= FItems.Count) then
    Exit(TValue.Empty);

  LCacheKey := ValueCacheKey(ASourceRowIndex, AFieldName);
  if (Cache.Mode <> Th5uCacheMode.None) and
     FValueCache.TryGetValue(LCacheKey, Result) then
    Exit;

  Result := ReadPropertyPath(
    FItems[ASourceRowIndex],
    AFieldName
  );

  if Cache.Mode <> Th5uCacheMode.None then
    FValueCache.AddOrSetValue(LCacheKey, Result);
end;

procedure Th5uObjectListController.Insert(AIndex: Integer; AObject: TObject);
var
  LChange: Th5uDataChange;
begin
  if not Assigned(AObject) then
    Exit;
  AIndex := EnsureRange(AIndex, 0, FItems.Count);
  FItems.Insert(AIndex, AObject);
  ClearValueCache;

  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsInserted;
  LChange.FirstIndex := AIndex;
  LChange.Count := 1;
  NotifyDataChanged(LChange);
end;

function Th5uObjectListController.Item(AIndex: Integer): TObject;
begin
  Result := FItems[AIndex];
end;

procedure Th5uObjectListController.NotifyObjectChanged(AObject: TObject; const APropertyName: string);
var
  LIndex: Integer;
  LChange: Th5uDataChange;
begin
  LIndex := FItems.IndexOf(AObject);
  if LIndex < 0 then
    Exit;

  ClearValueCache;
  LChange := Default(Th5uDataChange);
  LChange.FirstIndex := LIndex;
  LChange.Count := 1;
  LChange.RowKey := GetSourceRowKey(LIndex);
  LChange.ColumnId := APropertyName;

  if APropertyName = '' then
    LChange.Kind := Th5uDataChangeKind.RowsChanged
  else
    LChange.Kind := Th5uDataChangeKind.CellChanged;

  NotifyDataChanged(LChange);
end;

function Th5uObjectListController.ReadPropertyPath(AObject: TObject; const APath: string): TValue;
var
  LParts: TArray<string>;
  LPart: string;
  LProperty: TRttiProperty;
begin
  Result := TValue.Empty;
  if not Assigned(AObject) or (APath = '') then
    Exit;

  LParts := APath.Split(['.']);
  for LPart in LParts do
  begin
    LProperty := ResolveProperty(AObject, LPart);
    if not Assigned(LProperty) or not LProperty.IsReadable then
      Exit(TValue.Empty);

    Result := LProperty.GetValue(AObject);
    if LPart <> LParts[High(LParts)] then
    begin
      if not Result.IsObject then
        Exit(TValue.Empty);
      AObject := Result.AsObject;
      if not Assigned(AObject) then
        Exit(TValue.Empty);
    end;
  end;
end;

function Th5uObjectListController.ResolveProperty(AObject: TObject; const APropertyName: string): TRttiProperty;
var
  LKey: string;
  LRttiType: TRttiType;
begin
  Result := nil;
  if not Assigned(AObject) then
    Exit;

  LKey := AObject.ClassName + '|' + APropertyName.ToUpperInvariant;
  if FPropertyCache.TryGetValue(LKey, Result) then
    Exit;

  LRttiType := FRttiContext.GetType(AObject.ClassType);
  if Assigned(LRttiType) then
    Result := LRttiType.GetProperty(APropertyName);

  FPropertyCache.AddOrSetValue(LKey, Result);
end;

procedure Th5uObjectListController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LObject: TObject;
begin
  if (ASourceRowIndex < 0) or
     (ASourceRowIndex >= FItems.Count) then
    Exit;

  LObject := FItems[ASourceRowIndex];
  WritePropertyPath(LObject, AFieldName, AValue);
  NotifyObjectChanged(LObject, AFieldName);
end;

function Th5uObjectListController.ValueCacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
begin
  Result := IntToStr(ASourceRowIndex) + '|' +
    AFieldName.ToUpperInvariant;
end;

procedure Th5uObjectListController.WritePropertyPath(AObject: TObject; const APath: string; const AValue: TValue);
var
  LParts: TArray<string>;
  I: Integer;
  LProperty: TRttiProperty;
  LIntermediate: TValue;
begin
  if not Assigned(AObject) or (APath = '') then
    Exit;

  LParts := APath.Split(['.']);
  for I := 0 to High(LParts) - 1 do
  begin
    LProperty := ResolveProperty(AObject, LParts[I]);
    if not Assigned(LProperty) or not LProperty.IsReadable then
      raise Eh5uDataController.CreateFmt(
        'Property "%s" is not readable.',
        [LParts[I]]
      );

    LIntermediate := LProperty.GetValue(AObject);
    if not LIntermediate.IsObject or
       (LIntermediate.AsObject = nil) then
      raise Eh5uDataController.CreateFmt(
        'Property path "%s" contains a nil object.',
        [APath]
      );

    AObject := LIntermediate.AsObject;
  end;

  LProperty := ResolveProperty(
    AObject,
    LParts[High(LParts)]
  );
  if not Assigned(LProperty) or not LProperty.IsWritable then
    raise Eh5uDataController.CreateFmt(
      'Property "%s" is not writable.',
      [APath]
    );

  LProperty.SetValue(AObject, AValue);
end;


function Th5uObjectListController.GetCount: Integer;
var
  LCount: Int64;
begin
  LCount := GetSourceRowCount;
  if LCount < 0 then
    Result := 0
  else if LCount > High(Integer) then
    Result := High(Integer)
  else
    Result := Integer(LCount);
end;

end.
