unit h5u.Grid.Data.Virtual;

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
  Th5uVirtualGetRowCountEvent = procedure(Sender: TObject; var ARowCount: Int64) of object;

  Th5uVirtualGetRowKeyEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey) of object;

  Th5uVirtualGetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue) of object;

  Th5uVirtualSetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean) of object;

  Th5uVirtualCanEditEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var ACanEdit: Boolean) of object;

  Th5uVirtualPrepareRangeEvent = procedure(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64) of object;

  Th5uVirtualController = class(Th5uCustomDataController)
  private
    FOnGetRowCount: Th5uVirtualGetRowCountEvent;
    FOnGetRowKey: Th5uVirtualGetRowKeyEvent;
    FOnGetValue: Th5uVirtualGetValueEvent;
    FOnSetValue: Th5uVirtualSetValueEvent;
    FOnCanEdit: Th5uVirtualCanEditEvent;
    FOnPrepareRange: Th5uVirtualPrepareRangeEvent;
    FValueCache: TDictionary<string, TValue>;
    FQueryGeneration: Int64;
    function CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
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

    procedure PrepareRange(AFirstViewRow, ACount: Int64); override;

    procedure NotifyReset;
    procedure NotifyRowsInserted(AFirstSourceRow, ACount: Int64);
    procedure NotifyRowsDeleted(AFirstSourceRow, ACount: Int64);
    procedure NotifyRowChanged(ASourceRowIndex: Int64; const AColumnId: string = '');

    procedure BeginNewQuery;
    property QueryGeneration: Int64 read FQueryGeneration;
  published
    property OnGetRowCount: Th5uVirtualGetRowCountEvent read FOnGetRowCount write FOnGetRowCount;
    property OnGetRowKey: Th5uVirtualGetRowKeyEvent read FOnGetRowKey write FOnGetRowKey;
    property OnGetValue: Th5uVirtualGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uVirtualSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCanEdit: Th5uVirtualCanEditEvent read FOnCanEdit write FOnCanEdit;
    property OnPrepareRange: Th5uVirtualPrepareRangeEvent read FOnPrepareRange write FOnPrepareRange;
  end;

implementation

{ Th5uVirtualController }

procedure Th5uVirtualController.BeginNewQuery;
begin
  Inc(FQueryGeneration);
  ClearValueCache;
  Invalidate;
end;

function Th5uVirtualController.CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
begin
  Result := IntToStr(FQueryGeneration) + '|' + IntToStr(ASourceRowIndex) + '|' + AFieldName.ToUpperInvariant;
end;

procedure Th5uVirtualController.ClearValueCache;
begin
  FValueCache.Clear;
end;

constructor Th5uVirtualController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FValueCache := TDictionary<string, TValue>.Create;
  FQueryGeneration := 1;
  Cache.Mode := Th5uCacheMode.Viewport;
end;

destructor Th5uVirtualController.Destroy;
begin
  FValueCache.Free;
  inherited Destroy;
end;

procedure Th5uVirtualController.DoCacheOptionsChanged;
begin
  inherited DoCacheOptionsChanged;
  ClearValueCache;
end;

function Th5uVirtualController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := Assigned(FOnSetValue);
  if Assigned(FOnCanEdit) then
    FOnCanEdit(Self, ASourceRowIndex, AFieldName, Result);
end;

function Th5uVirtualController.GetSourceRowCount: Int64;
begin
  Result := 0;
  if Assigned(FOnGetRowCount) then
    FOnGetRowCount(Self, Result);
  if Result < 0 then
    Result := 0;
end;

function Th5uVirtualController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
begin
  Result := inherited GetSourceRowKey(ASourceRowIndex);
  if Assigned(FOnGetRowKey) then
    FOnGetRowKey(Self, ASourceRowIndex, Result);
end;

function Th5uVirtualController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LKey: string;
begin
  LKey := CacheKey(ASourceRowIndex, AFieldName);
  if (Cache.Mode <> Th5uCacheMode.None) and FValueCache.TryGetValue(LKey, Result) then
    Exit;

  Result := TValue.Empty;
  if Assigned(FOnGetValue) then
    FOnGetValue(Self, ASourceRowIndex, AFieldName, Result);

  if Cache.Mode <> Th5uCacheMode.None then
    FValueCache.AddOrSetValue(LKey, Result);
end;

procedure Th5uVirtualController.NotifyReset;
begin
  ClearValueCache;
  NotifyDataChanged(Th5uDataChange.ResetAll);
end;

procedure Th5uVirtualController.NotifyRowChanged(ASourceRowIndex: Int64; const AColumnId: string);
var
  LChange: Th5uDataChange;
  LKeyPrefix: string;
  LKey: string;
  LKeys: TArray<string>;
begin
  LKeyPrefix := IntToStr(FQueryGeneration) + '|' + IntToStr(ASourceRowIndex) + '|';
  LKeys := FValueCache.Keys.ToArray;
  for LKey in LKeys do
    if LKey.StartsWith(LKeyPrefix, True) then
      FValueCache.Remove(LKey);

  LChange := Default(Th5uDataChange);
  LChange.FirstIndex := ASourceRowIndex;
  LChange.Count := 1;
  LChange.RowKey := GetSourceRowKey(ASourceRowIndex);
  LChange.ColumnId := AColumnId;
  if AColumnId = '' then
    LChange.Kind := Th5uDataChangeKind.RowsChanged
  else
    LChange.Kind := Th5uDataChangeKind.CellChanged;
  NotifyDataChanged(LChange);
end;

procedure Th5uVirtualController.NotifyRowsDeleted(AFirstSourceRow, ACount: Int64);
var
  LChange: Th5uDataChange;
begin
  ClearValueCache;
  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsDeleted;
  LChange.FirstIndex := AFirstSourceRow;
  LChange.Count := ACount;
  NotifyDataChanged(LChange);
end;

procedure Th5uVirtualController.NotifyRowsInserted(AFirstSourceRow, ACount: Int64);
var
  LChange: Th5uDataChange;
begin
  ClearValueCache;
  LChange := Default(Th5uDataChange);
  LChange.Kind := Th5uDataChangeKind.RowsInserted;
  LChange.FirstIndex := AFirstSourceRow;
  LChange.Count := ACount;
  NotifyDataChanged(LChange);
end;

procedure Th5uVirtualController.PrepareRange(AFirstViewRow, ACount: Int64);
var
  LFirstSource: Int64;
begin
  inherited PrepareRange(AFirstViewRow, ACount);
  LFirstSource := MapViewToSourceIndex(AFirstViewRow);
  if (LFirstSource >= 0) and Assigned(FOnPrepareRange) then
    FOnPrepareRange(Self, LFirstSource, ACount, FQueryGeneration);
end;

procedure Th5uVirtualController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LHandled: Boolean;
begin
  LHandled := False;
  if Assigned(FOnSetValue) then
    FOnSetValue(Self, ASourceRowIndex, AFieldName, AValue, LHandled);

  if not LHandled then
    inherited SetSourceValue(ASourceRowIndex, AFieldName, AValue);

  NotifyRowChanged(ASourceRowIndex, AFieldName);
end;

end.
