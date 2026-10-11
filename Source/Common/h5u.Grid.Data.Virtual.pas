unit h5u.Grid.Data.Virtual;

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
  ThiiVirtualGetRowCountEvent = procedure(Sender: TObject; var ARowCount: Int64) of object;
  ThiiVirtualGetRowKeyEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: ThiiRowKey) of object;
  ThiiVirtualGetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue) of object;
  ThiiVirtualSetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean) of object;
  ThiiVirtualCanEditEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var ACanEdit: Boolean) of object;
  ThiiVirtualPrepareRangeEvent = procedure(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64) of object;

  ThiiVirtualController = class(ThiiCustomDataController)
  private
    FOnGetRowCount: ThiiVirtualGetRowCountEvent;
    FOnGetRowKey: ThiiVirtualGetRowKeyEvent;
    FOnGetValue: ThiiVirtualGetValueEvent;
    FOnSetValue: ThiiVirtualSetValueEvent;
    FOnCanEdit: ThiiVirtualCanEditEvent;
    FOnPrepareRange: ThiiVirtualPrepareRangeEvent;
    FValueCache: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
    FQueryGeneration: Int64;
    function CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
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
    property OnGetRowCount: ThiiVirtualGetRowCountEvent read FOnGetRowCount write FOnGetRowCount;
    property OnGetRowKey: ThiiVirtualGetRowKeyEvent read FOnGetRowKey write FOnGetRowKey;
    property OnGetValue: ThiiVirtualGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiVirtualSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCanEdit: ThiiVirtualCanEditEvent read FOnCanEdit write FOnCanEdit;
    property OnPrepareRange: ThiiVirtualPrepareRangeEvent read FOnPrepareRange write FOnPrepareRange;
  end;

implementation

{ ThiiVirtualController }

procedure ThiiVirtualController.BeginNewQuery;
begin
  Inc(FQueryGeneration);
  ClearValueCache;
  Invalidate;
end;

function ThiiVirtualController.CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
begin
  Result := IntToStr(FQueryGeneration) + '|' + IntToStr(ASourceRowIndex) + '|' + AFieldName.ToUpperInvariant;
end;

procedure ThiiVirtualController.ClearValueCache;
begin
  FValueCache.Clear;
end;

constructor ThiiVirtualController.Create(AOwner: TComponent);
begin
  inherited;
  FValueCache := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>.Create;
  FQueryGeneration := 1;
  Cache.Mode := ThiiCacheMode.Viewport;
end;

destructor ThiiVirtualController.Destroy;
begin
  FValueCache.Free;
  inherited;
end;

procedure ThiiVirtualController.DoCacheOptionsChanged;
begin
  inherited;
  ClearValueCache;
end;

function ThiiVirtualController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := Assigned(FOnSetValue);
  if Assigned(FOnCanEdit) then
    FOnCanEdit(Self, ASourceRowIndex, AFieldName, Result);
end;

function ThiiVirtualController.GetSourceRowCount: Int64;
begin
  Result := 0;
  if Assigned(FOnGetRowCount) then
    FOnGetRowCount(Self, Result);
  if Result < 0 then
    Result := 0;
end;

function ThiiVirtualController.GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey;
begin
  Result := inherited;
  if Assigned(FOnGetRowKey) then
    FOnGetRowKey(Self, ASourceRowIndex, Result);
end;

function ThiiVirtualController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LKey: string;
begin
  LKey := CacheKey(ASourceRowIndex, AFieldName);
  if (Cache.Mode <> ThiiCacheMode.None) and FValueCache.TryGetValue(LKey, Result) then
    Exit;

  Result := TValue.Empty;
  if Assigned(FOnGetValue) then
    FOnGetValue(Self, ASourceRowIndex, AFieldName, Result);

  if Cache.Mode <> ThiiCacheMode.None then
    FValueCache.AddOrSetValue(LKey, Result);
end;

procedure ThiiVirtualController.NotifyReset;
begin
  ClearValueCache;
  NotifyDataChanged(ThiiDataChange.ResetAll);
end;

procedure ThiiVirtualController.NotifyRowChanged(ASourceRowIndex: Int64; const AColumnId: string);
var
  LChange: ThiiDataChange;
  LKeyPrefix: string;
  LKey: string;
  LKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<string>;
begin
  LKeyPrefix := IntToStr(FQueryGeneration) + '|' + IntToStr(ASourceRowIndex) + '|';
  LKeys := FValueCache.Keys.ToArray;
  for LKey in LKeys do
    if LKey.StartsWith(LKeyPrefix, True) then
      FValueCache.Remove(LKey);

  LChange := Default(ThiiDataChange);
  LChange.FirstIndex := ASourceRowIndex;
  LChange.Count := 1;
  LChange.RowKey := GetSourceRowKey(ASourceRowIndex);
  LChange.ColumnId := AColumnId;
  if AColumnId = '' then
    LChange.Kind := ThiiDataChangeKind.RowsChanged
  else
    LChange.Kind := ThiiDataChangeKind.CellChanged;
  NotifyDataChanged(LChange);
end;

procedure ThiiVirtualController.NotifyRowsDeleted(AFirstSourceRow, ACount: Int64);
var
  LChange: ThiiDataChange;
begin
  ClearValueCache;
  LChange := Default(ThiiDataChange);
  LChange.Kind := ThiiDataChangeKind.RowsDeleted;
  LChange.FirstIndex := AFirstSourceRow;
  LChange.Count := ACount;
  NotifyDataChanged(LChange);
end;

procedure ThiiVirtualController.NotifyRowsInserted(AFirstSourceRow, ACount: Int64);
var
  LChange: ThiiDataChange;
begin
  ClearValueCache;
  LChange := Default(ThiiDataChange);
  LChange.Kind := ThiiDataChangeKind.RowsInserted;
  LChange.FirstIndex := AFirstSourceRow;
  LChange.Count := ACount;
  NotifyDataChanged(LChange);
end;

procedure ThiiVirtualController.PrepareRange(AFirstViewRow, ACount: Int64);
var
  LFirstSource: Int64;
begin
  inherited;
  LFirstSource := MapViewToSourceIndex(AFirstViewRow);
  if (LFirstSource >= 0) and Assigned(FOnPrepareRange) then
    FOnPrepareRange(Self, LFirstSource, ACount, FQueryGeneration);
end;

procedure ThiiVirtualController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LHandled: Boolean;
begin
  LHandled := False;
  if Assigned(FOnSetValue) then
    FOnSetValue(Self, ASourceRowIndex, AFieldName, AValue, LHandled);

  if not LHandled then
    inherited;

  NotifyRowChanged(ASourceRowIndex, AFieldName);
end;

end.

