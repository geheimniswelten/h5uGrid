unit h5u.Grid.Data.DataSet;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  Data.DB,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uDataSetController = class;

  Th5uDataSetDataLink = class(TDataLink)
  private
    FOwner: Th5uDataSetController;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AOwner: Th5uDataSetController);
  end;

  Th5uDataRowSnapshot = class
  private
    FRowKey: Th5uRowKey;
    FValues: TDictionary<string, TValue>;
  public
    constructor Create;
    destructor Destroy; override;
    property RowKey: Th5uRowKey read FRowKey write FRowKey;
    property Values: TDictionary<string, TValue> read FValues;
  end;

  Th5uDataSetController = class(Th5uCustomDataController)
  private
    FDataSource: TDataSource;
    FDataLink: Th5uDataSetDataLink;
    FKeyFieldName: string;
    FSnapshotCache: TObjectDictionary<Int64, Th5uDataRowSnapshot>;
    FCacheGeneration: Int64;
    procedure SetDataSource(const AValue: TDataSource);
    function GetDataSet: TDataSet;
    function ReadFieldValue(AField: TField): TValue;
    procedure WriteFieldValue(AField: TField; const AValue: TValue);
    function CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    function GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    procedure ClearSnapshotCache;
    function GoToSourceRow(ASourceRowIndex: Int64): Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareRange(AFirstViewRow, ACount: Int64); override;
    procedure DataSetChanged(AKind: Th5uDataChangeKind; AField: TField = nil);
    property DataSet: TDataSet read GetDataSet;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property KeyFieldName: string read FKeyFieldName write FKeyFieldName;
  end;

implementation

{ Th5uDataSetDataLink }

procedure Th5uDataSetDataLink.ActiveChanged;
begin
  inherited ActiveChanged;
  FOwner.DataSetChanged(Th5uDataChangeKind.Reset);
end;

constructor Th5uDataSetDataLink.Create(AOwner: Th5uDataSetController);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure Th5uDataSetDataLink.DataSetChanged;
begin
  inherited DataSetChanged;
  FOwner.DataSetChanged(Th5uDataChangeKind.RowsChanged);
end;

procedure Th5uDataSetDataLink.DataSetScrolled(Distance: Integer);
begin
  inherited DataSetScrolled(Distance);
end;

procedure Th5uDataSetDataLink.LayoutChanged;
begin
  inherited LayoutChanged;
  FOwner.DataSetChanged(Th5uDataChangeKind.LayoutChanged);
end;

procedure Th5uDataSetDataLink.RecordChanged(Field: TField);
begin
  inherited RecordChanged(Field);
  FOwner.DataSetChanged(Th5uDataChangeKind.CellChanged, Field);
end;

{ Th5uDataRowSnapshot }

constructor Th5uDataRowSnapshot.Create;
begin
  inherited Create;
  FValues := TDictionary<string, TValue>.Create;
end;

destructor Th5uDataRowSnapshot.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

{ Th5uDataSetController }

procedure Th5uDataSetController.ClearSnapshotCache;
begin
  FSnapshotCache.Clear;
  Inc(FCacheGeneration);
end;

constructor Th5uDataSetController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := Th5uDataSetDataLink.Create(Self);
  FSnapshotCache :=
    TObjectDictionary<Int64, Th5uDataRowSnapshot>.Create([doOwnsValues]);
  Cache.Mode := Th5uCacheMode.Viewport;
end;

function Th5uDataSetController.CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
var
  LDataSet: TDataSet;
  LBookmark: TBookmark;
  LHasBookmark: Boolean;
  LField: TField;
  LKeyValue: TValue;
begin
  Result := Th5uDataRowSnapshot.Create;
  LDataSet := DataSet;
  if not Assigned(LDataSet) or not LDataSet.Active then
    Exit;

  LHasBookmark := False;
  try
    try
      LBookmark := LDataSet.Bookmark;
      LHasBookmark := LDataSet.BookmarkValid(LBookmark);
    except
      LHasBookmark := False;
    end;

    LDataSet.DisableControls;
    try
      if not GoToSourceRow(ASourceRowIndex) then
        Exit;

      for LField in LDataSet.Fields do
        Result.Values.AddOrSetValue(
          LField.FieldName,
          ReadFieldValue(LField)
        );

      if (FKeyFieldName <> '') and
         Assigned(LDataSet.FindField(FKeyFieldName)) then
      begin
        LKeyValue := ReadFieldValue(
          LDataSet.FieldByName(FKeyFieldName)
        );
        Result.RowKey := Th5uRowKey.FromString(
          h5uValueToDisplayText(LKeyValue)
        );
      end
      else
        Result.RowKey := Th5uRowKey.FromInt64(ASourceRowIndex);
    finally
      if LHasBookmark then
        try
          LDataSet.Bookmark := LBookmark;
        except
          { The source may have changed while the snapshot was built. }
        end;
      LDataSet.EnableControls;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure Th5uDataSetController.DataSetChanged(AKind: Th5uDataChangeKind; AField: TField);
var
  LChange: Th5uDataChange;
begin
  ClearSnapshotCache;
  LChange := Th5uDataChange.ResetAll;
  LChange.Kind := AKind;
  if Assigned(AField) then
    LChange.ColumnId := AField.FieldName;
  NotifyDataChanged(LChange);
end;

destructor Th5uDataSetController.Destroy;
begin
  FDataLink.DataSource := nil;
  FSnapshotCache.Free;
  FDataLink.Free;
  inherited Destroy;
end;

procedure Th5uDataSetController.DoCacheOptionsChanged;
begin
  inherited DoCacheOptionsChanged;
  ClearSnapshotCache;
end;

function Th5uDataSetController.GetDataSet: TDataSet;
begin
  if Assigned(FDataSource) then
    Result := FDataSource.DataSet
  else
    Result := nil;
end;

function Th5uDataSetController.GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
begin
  if not FSnapshotCache.TryGetValue(ASourceRowIndex, Result) then
  begin
    Result := CreateSnapshot(ASourceRowIndex);
    FSnapshotCache.Add(ASourceRowIndex, Result);
  end;
end;

function Th5uDataSetController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
var
  LField: TField;
begin
  Result := False;
  if not Assigned(DataSet) or not DataSet.Active or
     not DataSet.CanModify then
    Exit;

  LField := DataSet.FindField(AFieldName);
  Result := Assigned(LField) and not LField.ReadOnly and
    (LField.FieldKind = fkData);
end;

function Th5uDataSetController.GetSourceRowCount: Int64;
begin
  if Assigned(DataSet) and DataSet.Active then
    Result := DataSet.RecordCount
  else
    Result := 0;
end;

function Th5uDataSetController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
var
  LSnapshot: Th5uDataRowSnapshot;
begin
  if Cache.Mode <> Th5uCacheMode.None then
  begin
    LSnapshot := GetSnapshot(ASourceRowIndex);
    Exit(LSnapshot.RowKey);
  end;

  Result := inherited GetSourceRowKey(ASourceRowIndex);
end;

function Th5uDataSetController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LSnapshot: Th5uDataRowSnapshot;
  LDataSet: TDataSet;
  LBookmark: TBookmark;
  LHasBookmark: Boolean;
  LField: TField;
begin
  Result := TValue.Empty;

  if Cache.Mode <> Th5uCacheMode.None then
  begin
    LSnapshot := GetSnapshot(ASourceRowIndex);
    LSnapshot.Values.TryGetValue(AFieldName, Result);
    Exit;
  end;

  LDataSet := DataSet;
  if not Assigned(LDataSet) or not LDataSet.Active then
    Exit;

  LHasBookmark := False;
  try
    LBookmark := LDataSet.Bookmark;
    LHasBookmark := LDataSet.BookmarkValid(LBookmark);
  except
    LHasBookmark := False;
  end;

  LDataSet.DisableControls;
  try
    if GoToSourceRow(ASourceRowIndex) then
    begin
      LField := LDataSet.FindField(AFieldName);
      if Assigned(LField) then
        Result := ReadFieldValue(LField);
    end;
  finally
    if LHasBookmark then
      try
        LDataSet.Bookmark := LBookmark;
      except
      end;
    LDataSet.EnableControls;
  end;
end;

function Th5uDataSetController.GoToSourceRow(ASourceRowIndex: Int64): Boolean;
var
  LDataSet: TDataSet;
begin
  Result := False;
  LDataSet := DataSet;
  if not Assigned(LDataSet) or not LDataSet.Active or
     (ASourceRowIndex < 0) or
     (ASourceRowIndex >= LDataSet.RecordCount) then
    Exit;

  try
    LDataSet.RecNo := ASourceRowIndex + 1;
    Result := not LDataSet.Eof;
  except
    LDataSet.First;
    if ASourceRowIndex > 0 then
      LDataSet.MoveBy(ASourceRowIndex);
    Result := not LDataSet.Eof;
  end;
end;

procedure Th5uDataSetController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSource) then
    DataSource := nil;
end;

procedure Th5uDataSetController.PrepareRange(AFirstViewRow, ACount: Int64);
var
  LViewIndex: Int64;
  LSourceIndex: Int64;
  LFirstSource: Int64;
  LLastSource: Int64;
  LKeys: TArray<Int64>;
  LKey: Int64;
begin
  inherited PrepareRange(AFirstViewRow, ACount);
  if Cache.Mode = Th5uCacheMode.None then
    Exit;

  if ACount <= 0 then
    Exit;

  LFirstSource := MapViewToSourceIndex(AFirstViewRow);
  LLastSource := MapViewToSourceIndex(AFirstViewRow + ACount - 1);
  if LFirstSource < 0 then
    Exit;
  if LLastSource < LFirstSource then
    LLastSource := LFirstSource;

  case Cache.Mode of
    Th5uCacheMode.All:
      begin
        LFirstSource := 0;
        LLastSource := GetSourceRowCount - 1;
      end;

    Th5uCacheMode.Paged:
      begin
        LFirstSource :=
          (LFirstSource div Cache.PageSize) * Cache.PageSize;
        LLastSource := LFirstSource + Cache.PageSize - 1;
        if LLastSource >= GetSourceRowCount then
          LLastSource := GetSourceRowCount - 1;
      end;
  end;

  LViewIndex := LFirstSource;
  while LViewIndex <= LLastSource do
  begin
    if not FSnapshotCache.ContainsKey(LViewIndex) then
      FSnapshotCache.Add(
        LViewIndex,
        CreateSnapshot(LViewIndex)
      );
    Inc(LViewIndex);
  end;

  if Cache.Mode in [Th5uCacheMode.Viewport, Th5uCacheMode.Adaptive] then
  begin
    LKeys := FSnapshotCache.Keys.ToArray;
    for LKey in LKeys do
      if (LKey < LFirstSource - 32) or
         (LKey > LLastSource + 32) then
        FSnapshotCache.Remove(LKey);
  end;
end;

function Th5uDataSetController.ReadFieldValue(AField: TField): TValue;
var
  LStream: TMemoryStream;
  LBytes: TBytes;
begin
  if not Assigned(AField) or AField.IsNull then
    Exit(TValue.Empty);

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftShortint, ftByte: Result := TValue.From<Integer>(AField.AsInteger);

    ftLargeint: Result := TValue.From<Int64>(AField.AsLargeInt);

    ftBoolean: Result := TValue.From<Boolean>(AField.AsBoolean);

    ftFloat, ftSingle, ftExtended: Result := TValue.From<Double>(AField.AsFloat);

    ftCurrency, ftBCD, ftFMTBcd: Result := TValue.From<Currency>(AField.AsCurrency);

    ftDate, ftTime, ftDateTime, ftTimeStamp: Result := TValue.From<TDateTime>(AField.AsDateTime);

    ftBlob, ftGraphic, ftOraBlob: begin LStream := TMemoryStream.Create;
        try
          TBlobField(AField).SaveToStream(LStream);
          SetLength(LBytes, LStream.Size);
          if LStream.Size > 0 then
          begin
            LStream.Position := 0;
            LStream.ReadBuffer(LBytes[0], LStream.Size);
          end;
          Result := TValue.From<TBytes>(LBytes);
        finally
          LStream.Free;
        end;
      end;

  else
    Result := TValue.From<string>(AField.AsString);
  end;
end;

procedure Th5uDataSetController.SetDataSource(const AValue: TDataSource);
begin
  if FDataSource = AValue then
    Exit;

  if Assigned(FDataSource) then
    FDataSource.RemoveFreeNotification(Self);

  FDataSource := AValue;
  FDataLink.DataSource := FDataSource;

  if Assigned(FDataSource) then
    FDataSource.FreeNotification(Self);

  ClearSnapshotCache;
  Invalidate;
end;

procedure Th5uDataSetController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LDataSet: TDataSet;
  LField: TField;
begin
  LDataSet := DataSet;
  if not Assigned(LDataSet) or not LDataSet.Active then
    Exit;

  if not GoToSourceRow(ASourceRowIndex) then
    Exit;

  LField := LDataSet.FieldByName(AFieldName);
  if not (LDataSet.State in dsEditModes) then
    LDataSet.Edit;

  WriteFieldValue(LField, AValue);
  LDataSet.Post;

  ClearSnapshotCache;
  NotifyDataChanged(Th5uDataChange.ResetAll);
end;

procedure Th5uDataSetController.WriteFieldValue(AField: TField; const AValue: TValue);
var
  LBytes: TBytes;
  LStream: TBytesStream;
begin
  if AValue.IsEmpty then
  begin
    AField.Clear;
    Exit;
  end;

  if AValue.IsType<TBytes> and (AField is TBlobField) then
  begin
    LBytes := AValue.AsType<TBytes>;
    LStream := TBytesStream.Create(LBytes);
    try
      TBlobField(AField).LoadFromStream(LStream);
    finally
      LStream.Free;
    end;
    Exit;
  end;

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftShortint, ftByte: AField.AsInteger := AValue.AsInteger;

    ftLargeint: AField.AsLargeInt := AValue.AsInt64;

    ftBoolean: AField.AsBoolean := AValue.AsBoolean;

    ftFloat, ftSingle, ftExtended: AField.AsFloat := AValue.AsExtended;

    ftCurrency, ftBCD, ftFMTBcd: AField.AsCurrency := AValue.AsType<Currency>;

    ftDate, ftTime, ftDateTime, ftTimeStamp: AField.AsDateTime := AValue.AsType<TDateTime>;

  else
    AField.AsString := AValue.ToString;
  end;
end;

end.
