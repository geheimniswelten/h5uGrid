unit h5u.Grid.Data.Dataset;

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
    DB,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
    Data.DB,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uDatasetController = class;

  Th5uDatasetDataLink = class(TDataLink)
  private
    FOwner: Th5uDatasetController;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AOwner: Th5uDatasetController);
  end;

  Th5uDataRowSnapshot = class
  private
    FRowKey: Th5uRowKey;
    FValues: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
  public
    constructor Create;
    destructor Destroy; override;
    property RowKey: Th5uRowKey read FRowKey write FRowKey;
    property Values: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue> read FValues;
  end;

  Th5uDatasetController = class(Th5uCustomDataController)
  private
    FDataSource: TDataSource;
    FDataLink: Th5uDatasetDataLink;
    FKeyFieldName: string;
    FSnapshotCache: {$IFDEF FPC}specialize {$ENDIF}TObjectDictionary<Int64, Th5uDataRowSnapshot>;
    FCacheGeneration: Int64;
    FInternalReadCount: Integer;
    FInternalWriteCount: Integer;
    procedure SetDataSource(const AValue: TDataSource);
    function GetDataset: TDataset;
    function ReadFieldValue(AField: TField): TValue;
    procedure WriteFieldValue(AField: TField; const AValue: TValue);
    function CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    function GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    procedure ClearSnapshotCache;
    function GoToSourceRow(ASourceRowIndex: Int64; AReadOnly: Boolean = False): Boolean;
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
    procedure DatasetChanged(AKind: Th5uDataChangeKind; AField: TField = nil);
    property Dataset: TDataset read GetDataset;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property KeyFieldName: string read FKeyFieldName write FKeyFieldName;
  end;

implementation

{ Th5uDatasetDataLink }

procedure Th5uDatasetDataLink.ActiveChanged;
begin
  inherited;
  FOwner.DatasetChanged(Th5uDataChangeKind.Reset);
end;

constructor Th5uDatasetDataLink.Create(AOwner: Th5uDatasetController);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure Th5uDatasetDataLink.DataSetChanged;
begin
  inherited;
  FOwner.DatasetChanged(Th5uDataChangeKind.RowsChanged);
end;

procedure Th5uDatasetDataLink.DataSetScrolled(Distance: Integer);
begin
  inherited;
end;

procedure Th5uDatasetDataLink.LayoutChanged;
begin
  inherited;
  FOwner.DatasetChanged(Th5uDataChangeKind.LayoutChanged);
end;

procedure Th5uDatasetDataLink.RecordChanged(Field: TField);
begin
  inherited;
  FOwner.DatasetChanged(Th5uDataChangeKind.CellChanged, Field);
end;

{ Th5uDataRowSnapshot }

constructor Th5uDataRowSnapshot.Create;
begin
  inherited;
  FValues := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>.Create;
end;

destructor Th5uDataRowSnapshot.Destroy;
begin
  FValues.Free;
  inherited;
end;

{ Th5uDatasetController }

procedure Th5uDatasetController.ClearSnapshotCache;
begin
  FSnapshotCache.Clear;
  Inc(FCacheGeneration);
end;

constructor Th5uDatasetController.Create(AOwner: TComponent);
begin
  inherited;
  FDataLink := Th5uDatasetDataLink.Create(Self);
  FSnapshotCache := {$IFDEF FPC}specialize {$ENDIF}TObjectDictionary<Int64, Th5uDataRowSnapshot>.Create([doOwnsValues]);
  Cache.Mode := Th5uCacheMode.Viewport;
end;

function Th5uDatasetController.CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
var
  LDataset: TDataset;
  LBookmark: TBookmark;
  LHasBookmark: Boolean;
  LField: TField;
  LKeyValue: TValue;
begin
  Result := Th5uDataRowSnapshot.Create;
  LDataset := Dataset;
  if not Assigned(LDataset) or not LDataset.Active then
    Exit;

  try
    try
      LBookmark := LDataset.Bookmark;
      LHasBookmark := LDataset.BookmarkValid(LBookmark);
    except
      LHasBookmark := False;
    end;

    Inc(FInternalReadCount);
    try
      LDataset.DisableControls;
      try
        if not GoToSourceRow(ASourceRowIndex, True) then
          Exit;

        for LField in LDataset.Fields do
          Result.Values.AddOrSetValue(LField.FieldName, ReadFieldValue(LField));

        if (FKeyFieldName <> '') and Assigned(LDataset.FindField(FKeyFieldName)) then
        begin
          LKeyValue := ReadFieldValue(LDataset.FieldByName(FKeyFieldName));
          Result.RowKey := Th5uRowKey.FromString(h5uValueToDisplayText(LKeyValue));
        end
        else
          Result.RowKey := Th5uRowKey.FromInt64(ASourceRowIndex);
      finally
        if LHasBookmark and not (LDataset.State in dsEditModes) then
          try
            LDataset.Bookmark := LBookmark;
          except
            { The source may have changed while the snapshot was built. }
          end;
        LDataset.EnableControls;
      end;
    finally
      Dec(FInternalReadCount);
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure Th5uDatasetController.DatasetChanged(AKind: Th5uDataChangeKind; AField: TField);
var
  LChange: Th5uDataChange;
begin
  // Internal cursor moves are reads. EnableControls also synchronously notifies
  // the data link, so the read guard must remain active until it returns.
  if (FInternalReadCount > 0) or (FInternalWriteCount > 0) then
    Exit;

  ClearSnapshotCache;
  LChange := Th5uDataChange.ResetAll;
  LChange.Kind := AKind;
  if Assigned(AField) then
    LChange.ColumnId := AField.FieldName;
  NotifyDataChanged(LChange);
end;

destructor Th5uDatasetController.Destroy;
begin
  FDataLink.DataSource := nil;
  FSnapshotCache.Free;
  FDataLink.Free;
  inherited;
end;

procedure Th5uDatasetController.DoCacheOptionsChanged;
begin
  inherited;
  ClearSnapshotCache;
end;

function Th5uDatasetController.GetDataset: TDataset;
begin
  if Assigned(FDataSource) then
    Result := FDataSource.Dataset
  else
    Result := nil;
end;

function Th5uDatasetController.GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
begin
  if not FSnapshotCache.TryGetValue(ASourceRowIndex, Result) then
  begin
    Result := CreateSnapshot(ASourceRowIndex);
    FSnapshotCache.Add(ASourceRowIndex, Result);
  end;
end;

function Th5uDatasetController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
var
  LField: TField;
begin
  Result := False;
  if not Assigned(Dataset) or not Dataset.Active or not Dataset.CanModify then
    Exit;

  LField := Dataset.FindField(AFieldName);
  Result := Assigned(LField) and not LField.ReadOnly and (LField.FieldKind = fkData);
end;

function Th5uDatasetController.GetSourceRowCount: Int64;
begin
  if Assigned(Dataset) and Dataset.Active then
    Result := Dataset.RecordCount
  else
    Result := 0;
end;

function Th5uDatasetController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
var
  LSnapshot: Th5uDataRowSnapshot;
begin
  if Cache.Mode <> Th5uCacheMode.None then
  begin
    LSnapshot := GetSnapshot(ASourceRowIndex);
    Exit(LSnapshot.RowKey);
  end;

  Result := inherited;
end;

function Th5uDatasetController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LSnapshot: Th5uDataRowSnapshot;
  LDataset: TDataset;
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

  LDataset := Dataset;
  if not Assigned(LDataset) or not LDataset.Active then
    Exit;

  try
    LBookmark := LDataset.Bookmark;
    LHasBookmark := LDataset.BookmarkValid(LBookmark);
  except
    LHasBookmark := False;
  end;

  Inc(FInternalReadCount);
  try
    LDataset.DisableControls;
    try
      if GoToSourceRow(ASourceRowIndex, True) then
      begin
        LField := LDataset.FindField(AFieldName);
        if Assigned(LField) then
          Result := ReadFieldValue(LField);
      end;
    finally
      if LHasBookmark and not (LDataset.State in dsEditModes) then
        try
          LDataset.Bookmark := LBookmark;
        except
        end;
      LDataset.EnableControls;
    end;
  finally
    Dec(FInternalReadCount);
  end;
end;

function Th5uDatasetController.GoToSourceRow(ASourceRowIndex: Int64; AReadOnly: Boolean): Boolean;
var
  LDataset: TDataset;
begin
  Result := False;
  LDataset := Dataset;
  if not Assigned(LDataset) or not LDataset.Active or (ASourceRowIndex < 0) or (ASourceRowIndex >= LDataset.RecordCount) then
    Exit;

  // Even assigning the current RecNo can call CheckBrowseMode and post an edit.
  // A read must never navigate away from an active edit/insert buffer.
  if AReadOnly and (LDataset.State in dsEditModes) then
    Exit(LDataset.RecNo = ASourceRowIndex + 1);

  try
    LDataset.RecNo := ASourceRowIndex + 1;
    Result := not LDataset.Eof;
  except
    LDataset.First;
    if ASourceRowIndex > 0 then
      LDataset.MoveBy(ASourceRowIndex);
    Result := not LDataset.Eof;
  end;
end;

procedure Th5uDatasetController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSource) then
    DataSource := nil;
end;

procedure Th5uDatasetController.PrepareRange(AFirstViewRow, ACount: Int64);
var
  LViewIndex: Int64;
  LFirstSource: Int64;
  LLastSource: Int64;
  LKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<Int64>;
  LKey: Int64;
begin
  inherited;
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
        LFirstSource := (LFirstSource div Cache.PageSize) * Cache.PageSize;
        LLastSource := LFirstSource + Cache.PageSize - 1;
        if LLastSource >= GetSourceRowCount then
          LLastSource := GetSourceRowCount - 1;
      end;
  end;

  LViewIndex := LFirstSource;
  while LViewIndex <= LLastSource do
  begin
    if not FSnapshotCache.ContainsKey(LViewIndex) then
      FSnapshotCache.Add(LViewIndex, CreateSnapshot(LViewIndex));
    Inc(LViewIndex);
  end;

  if Cache.Mode in [Th5uCacheMode.Viewport, Th5uCacheMode.Adaptive] then
  begin
    LKeys := FSnapshotCache.Keys.ToArray;
    for LKey in LKeys do
      if (LKey < LFirstSource - 32) or (LKey > LLastSource + 32) then
        FSnapshotCache.Remove(LKey);
  end;
end;

function Th5uDatasetController.ReadFieldValue(AField: TField): TValue;
var
  LStream: TMemoryStream;
  LBytes: TBytes;
begin
  if not Assigned(AField) or AField.IsNull then
    Exit(TValue.Empty);

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftAutoInc {$IFnDEF FPC}, ftShortint, ftByte{$ENDIF}:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(AField.AsInteger);

    ftLargeint:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Int64>(AField.AsLargeInt);

    ftBoolean:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Boolean>(AField.AsBoolean);

    ftFloat {$IFnDEF FPC}, ftSingle, ftExtended{$ENDIF}:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Double>(AField.AsFloat);

    ftCurrency, ftBCD, ftFMTBcd:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<Currency>(AField.AsCurrency);

    ftDate, ftTime, ftDateTime, ftTimeStamp:
      Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<TDateTime>(AField.AsDateTime);

    ftBlob, ftGraphic, ftOraBlob:
    begin
      LStream := TMemoryStream.Create;
      try
        TBlobField(AField).SaveToStream(LStream);
        SetLength(LBytes, LStream.Size);
        if LStream.Size > 0 then
        begin
          LStream.Position := 0;
          LStream.ReadBuffer(LBytes[0], LStream.Size);
        end;
        Result := TValue.{$IFDEF FPC}specialize {$ENDIF}From<TBytes>(LBytes);
      finally
        LStream.Free;
      end;
    end;

    else
      {$IFDEF FPC}
      Result := TValue.specialize From<string>(string(AField.AsUTF8String));
      {$ELSE}
      Result := TValue.From<string>(AField.AsString);
      {$ENDIF}
  end;
end;

procedure Th5uDatasetController.SetDataSource(const AValue: TDataSource);
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

procedure Th5uDatasetController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LDataset: TDataset;
  LField: TField;
  LOwnEdit: Boolean;
begin
  LDataset := Dataset;
  if not Assigned(LDataset) or not LDataset.Active then
    Exit;

  // Publish only the completed write. Intermediate edit notifications can make
  // grid layout read other rows and implicitly post the buffer being written.
  Inc(FInternalWriteCount);
  try
    LDataset.DisableControls;
    try
      if not GoToSourceRow(ASourceRowIndex) then
        Exit;

      LOwnEdit := False;
      try
        LField := LDataset.FieldByName(AFieldName);
        if not (LDataset.State in dsEditModes) then
        begin
          LDataset.Edit;
          LOwnEdit := True;
        end;
        WriteFieldValue(LField, AValue);
        LDataset.Post;
      except
        // The grid keeps the editor text for correction. Roll back only an
        // edit opened here, never an edit buffer owned by the application.
        if LOwnEdit and (LDataset.State in dsEditModes) then
          LDataset.Cancel;
        raise;
      end;
    finally
      ClearSnapshotCache;
      LDataset.EnableControls;
    end;
  finally
    Dec(FInternalWriteCount);
  end;
  NotifyDataChanged(Th5uDataChange.ResetAll);
end;

procedure Th5uDatasetController.WriteFieldValue(AField: TField; const AValue: TValue);
var
  LBytes: TBytes;
  LStream: TBytesStream;
begin
  if AValue.IsEmpty then
  begin
    AField.Clear;
    Exit;
  end;

  if AValue.{$IFDEF FPC}specialize {$ENDIF}IsType<TBytes> and (AField is TBlobField) then
  begin
    LBytes := AValue.{$IFDEF FPC}specialize {$ENDIF}AsType<TBytes>;
    LStream := TBytesStream.Create(LBytes);
    try
      TBlobField(AField).LoadFromStream(LStream);
    finally
      LStream.Free;
    end;
    Exit;
  end;

  case AField.DataType of
    ftSmallint, ftInteger, ftWord, ftAutoInc {$IFnDEF FPC}, ftShortint, ftByte{$ENDIF}:
      AField.AsInteger := AValue.AsInteger;

    ftLargeint:
      AField.AsLargeInt := AValue.AsInt64;

    ftBoolean:
      AField.AsBoolean := AValue.AsBoolean;

    ftFloat{$IFnDEF FPC}, ftSingle, ftExtended{$ENDIF}:
      AField.AsFloat := AValue.AsExtended;

    ftCurrency, ftBCD, ftFMTBcd:
      AField.AsCurrency := AValue.{$IFDEF FPC}specialize {$ENDIF}AsType<Currency>;

    ftDate, ftTime, ftDateTime, ftTimeStamp:
      AField.AsDateTime := AValue.{$IFDEF FPC}specialize {$ENDIF}AsType<TDateTime>;

    else
      {$IFDEF FPC}
      AField.AsUTF8String := UTF8String(h5uValueAsText(AValue));
      {$ELSE}
      AField.AsString := AValue.ToString;
      {$ENDIF}
  end;
end;

end.
