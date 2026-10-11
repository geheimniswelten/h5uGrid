unit h5u.Grid.Data.Core;

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
    TypInfo,
    Variants,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
    System.TypInfo,
    System.Variants,
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  ThiiCustomDataController = class;
  ThiiDataControllerLink = class;

  ThiiDataControllerChangedEvent = procedure(Sender: TObject; const AChange: ThiiDataChange) of object;

  ThiiDataControllerLink = class(TObject)
  private
    FController: ThiiCustomDataController;
    FOnChanged: ThiiDataControllerChangedEvent;
    procedure SetController(const AValue: ThiiCustomDataController);
  public
    destructor Destroy; override;
    procedure DataChanged(const AChange: ThiiDataChange);
    property Controller: ThiiCustomDataController read FController write SetController;
    property OnChanged: ThiiDataControllerChangedEvent read FOnChanged write FOnChanged;
  end;

  ThiiDataViewSession = class(ThiiFactoryObject)
  private
    FGrid: TObject;
    FView: TObject;
    FController: ThiiCustomDataController;
    FQueryGeneration: Int64;
  public
    constructor Create(const AContext: ThiiFactoryContext); override;
    procedure NextQueryGeneration;
    property Grid: TObject read FGrid;
    property View: TObject read FView;
    property Controller: ThiiCustomDataController read FController;
    property QueryGeneration: Int64 read FQueryGeneration;
  end;

  ThiiCustomDataController = class(TComponent)
  private
    FLinks: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiDataControllerLink>;
    FFactoryScope: ThiiFactoryScope;
    FSharedClassFactory: ThiiClassFactory;
    FCache: ThiiCacheOptions;
    FPagination: ThiiPaginationOptions;
    FEnabled: Boolean;
    FUpdateCount: Integer;
    FPendingReset: Boolean;
    procedure CacheOptionsChanged(Sender: TObject);
    procedure PaginationOptionsChanged(Sender: TObject);
    procedure SetSharedClassFactory(const AValue: ThiiClassFactory);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetSourceRowCount: Int64; virtual; abstract;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; virtual;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; virtual; abstract;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); virtual;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; virtual;
    function GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string; virtual;
    function MapViewToSourceIndex(AViewRowIndex: Int64): Int64; virtual;

    procedure DoCacheOptionsChanged; virtual;
    procedure DoPaginationChanged; virtual;

    procedure RegisterLink(ALink: ThiiDataControllerLink);
    procedure UnregisterLink(ALink: ThiiDataControllerLink);
    procedure NotifyDataChanged(const AChange: ThiiDataChange);

    function GetDataSessionClass(const AContext: ThiiFactoryContext): TClass; virtual;

    property Links: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiDataControllerLink> read FLinks;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Invalidate;
    procedure PrepareRange(AFirstViewRow, ACount: Int64); virtual;

    function GetRowCount: Int64;
    function GetTotalRowCount: Int64;
    function GetSourceRowIndex(AViewRowIndex: Int64): Int64;
    // Unlike GetRowCount (the current numbered page), this also accepts the
    // immediately following logical view index so layout helpers can inspect
    // a page boundary without treating it as the end of the source.
    function IsRowAvailable(AViewRowIndex: Int64): Boolean;
    function GetRowKey(AViewRowIndex: Int64): ThiiRowKey;
    function GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetDisplayText(AViewRowIndex: Int64; const AFieldName: string; const ADisplayFormat: string = ''): string;

    function CreateSession(AGrid, AView: TObject): ThiiDataViewSession; virtual;

    property FactoryScope: ThiiFactoryScope read FFactoryScope;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property SharedClassFactory: ThiiClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Cache: ThiiCacheOptions read FCache write FCache;
    property Pagination: ThiiPaginationOptions read FPagination write FPagination;
  end;

function h5uValueToDisplayText(const AValue: TValue; const ADisplayFormat: string = ''): string;

function h5uTryValueAsInteger(const AValue: TValue; out AInteger: Integer): Boolean;

implementation

function h5uValueToDisplayText(const AValue: TValue; const ADisplayFormat: string): string;
var
  LBytes: TBytes;
  LFloat: Extended;
  LDateTime: TDateTime;
begin
  if AValue.IsEmpty then
    Exit('');

  if AValue.{$IFDEF FPC}specialize {$ENDIF}IsType<TBytes> then
  begin
    LBytes := AValue.{$IFDEF FPC}specialize {$ENDIF}AsType<TBytes>;
    if Length(LBytes) = 0 then
      Exit('');
    Exit(Format('[Bild: %d Bytes]', [Length(LBytes)]));
  end;

  case AValue.Kind of
    tkString, tkLString, tkWString, tkUString, tkChar, tkWChar:
      Result := {$IFDEF FPC}h5uValueAsText(AValue){$ELSE}AValue.ToString{$ENDIF};

    tkInteger, tkInt64, tkEnumeration: if (ADisplayFormat <> '') and (AValue.Kind <> tkEnumeration) then
      Result := FormatFloat(ADisplayFormat, AValue.AsInt64) else Result := AValue.ToString;

    tkFloat:
    begin
      if AValue.TypeInfo = TypeInfo(TDateTime) then
      begin
        LDateTime := AValue.{$IFDEF FPC}specialize {$ENDIF}AsType<TDateTime>;
        if ADisplayFormat <> '' then
          Result := FormatDateTime(ADisplayFormat, LDateTime)
        else
          Result := DateTimeToStr(LDateTime);
      end
      else
      begin
        LFloat := AValue.AsExtended;
        if ADisplayFormat <> '' then
          Result := FormatFloat(ADisplayFormat, LFloat)
        else
          Result := FloatToStr(LFloat);
      end;
    end;

    tkVariant:
      if VarIsNull(AValue.AsVariant) or VarIsEmpty(AValue.AsVariant) then
        Result := ''
      else
        Result := VarToStr(AValue.AsVariant);

    tkClass:
      if AValue.AsObject <> nil then
        Result := AValue.AsObject.ToString
      else
        Result := '';

    else
      Result := AValue.ToString;
  end;
end;

function h5uTryValueAsInteger(const AValue: TValue; out AInteger: Integer): Boolean;
var
  LText: string;
begin
  Result := False;
  AInteger := 0;

  if AValue.IsEmpty then
    Exit;

  case AValue.Kind of
    tkInteger, tkInt64:
    begin
      AInteger := AValue.AsInteger;
      Exit(True);
    end;

    {$IFDEF FPC}tkBool,{$ENDIF} tkEnumeration:
    begin
      if AValue.TypeInfo = TypeInfo(Boolean) then
        AInteger := Ord(AValue.AsBoolean)
      else
        AInteger := AValue.AsOrdinal;
      Exit(True);
    end;
  end;

  LText := AValue.ToString;
  Result := TryStrToInt(LText, AInteger);
end;

{ ThiiDataControllerLink }

procedure ThiiDataControllerLink.DataChanged(const AChange: ThiiDataChange);
begin
  if Assigned(FOnChanged) then
    FOnChanged(FController, AChange);
end;

destructor ThiiDataControllerLink.Destroy;
begin
  Controller := nil;
  inherited;
end;

procedure ThiiDataControllerLink.SetController(const AValue: ThiiCustomDataController);
begin
  if FController = AValue then
    Exit;

  if Assigned(FController) then
    FController.UnregisterLink(Self);

  FController := AValue;

  if Assigned(FController) then
    FController.RegisterLink(Self);
end;

{ ThiiDataViewSession }

constructor ThiiDataViewSession.Create(const AContext: ThiiFactoryContext);
begin
  inherited;
  FGrid := AContext.Grid;
  FView := AContext.View;
  if AContext.DataController is ThiiCustomDataController then
    FController := ThiiCustomDataController(AContext.DataController);
  FQueryGeneration := 1;
end;

procedure ThiiDataViewSession.NextQueryGeneration;
begin
  Inc(FQueryGeneration);
end;

{ ThiiCustomDataController }

procedure ThiiCustomDataController.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure ThiiCustomDataController.CacheOptionsChanged(Sender: TObject);
begin
  DoCacheOptionsChanged;
  Invalidate;
end;

function ThiiCustomDataController.CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
var
  LSourceIndex: Int64;
begin
  if not FEnabled then
    Exit(False);
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  Result := (LSourceIndex >= 0) and GetSourceCanEdit(LSourceIndex, AFieldName);
end;

constructor ThiiCustomDataController.Create(AOwner: TComponent);
begin
  inherited;
  FLinks := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiDataControllerLink>.Create;
  FFactoryScope := ThiiFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FCache := ThiiCacheOptions.Create;
  FCache.OnChanged := {$IFDEF FPC}@{$ENDIF}CacheOptionsChanged;
  FPagination := ThiiPaginationOptions.Create;
  FPagination.OnChanged := {$IFDEF FPC}@{$ENDIF}PaginationOptionsChanged;
  FEnabled := True;
end;

function ThiiCustomDataController.CreateSession(AGrid, AView: TObject): ThiiDataViewSession;
var
  LContext: ThiiFactoryContext;
begin
  LContext := ThiiFactoryContext.Create(AGrid, AView, Self, h5uClassIdDataSession, ThiiElementKind.DataSession);
  LContext.Owner := Self;
  LContext.CreationReason := ThiiCreationReason.ControllerInternal;

  Result := ThiiDataViewSession(FFactoryScope.CreateInstance(LContext, ThiiDataViewSession, GetDataSessionClass(LContext)));
end;

destructor ThiiCustomDataController.Destroy;
begin
  if Assigned(FLinks) then
    while FLinks.Count > 0 do
      FLinks[0].Controller := nil;
  FPagination.Free;
  FCache.Free;
  FFactoryScope.Free;
  FLinks.Free;
  inherited;
end;

procedure ThiiCustomDataController.DoCacheOptionsChanged;
begin
end;

procedure ThiiCustomDataController.DoPaginationChanged;
begin
end;

procedure ThiiCustomDataController.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;
  Dec(FUpdateCount);

  if (FUpdateCount = 0) and FPendingReset then
  begin
    FPendingReset := False;
    NotifyDataChanged(ThiiDataChange.ResetAll);
  end;
end;

function ThiiCustomDataController.GetDataSessionClass(const AContext: ThiiFactoryContext): TClass;
begin
  Result := ThiiDataViewSession;
end;

function ThiiCustomDataController.GetDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit('');
  Result := GetSourceDisplayText(LSourceIndex, AFieldName, ADisplayFormat);
end;

function ThiiCustomDataController.GetRowCount: Int64;
var
  LTotal: Int64;
  LOffset: Int64;
begin
  if not FEnabled then
    Exit(0);

  LTotal := GetSourceRowCount;
  if FPagination.Mode <> ThiiPaginationMode.NumberedPages then
    Exit(LTotal);

  LOffset := Int64(FPagination.PageIndex) * FPagination.PageSize;
  if LOffset >= LTotal then
    Exit(0);

  Result := LTotal - LOffset;
  if Result > FPagination.PageSize then
    Result := FPagination.PageSize;
end;

function ThiiCustomDataController.GetSourceRowIndex(AViewRowIndex: Int64): Int64;
begin
  if not FEnabled then
    Exit(-1);
  Result := MapViewToSourceIndex(AViewRowIndex);
end;

function ThiiCustomDataController.IsRowAvailable(AViewRowIndex: Int64): Boolean;
begin
  Result := GetSourceRowIndex(AViewRowIndex) >= 0;
end;

function ThiiCustomDataController.GetRowKey(AViewRowIndex: Int64): ThiiRowKey;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit(ThiiRowKey.Empty);
  Result := GetSourceRowKey(LSourceIndex);
end;

function ThiiCustomDataController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := False;
end;

function ThiiCustomDataController.GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
begin
  Result := h5uValueToDisplayText(GetSourceValue(ASourceRowIndex, AFieldName), ADisplayFormat);
end;

function ThiiCustomDataController.GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey;
begin
  Result := ThiiRowKey.FromInt64(ASourceRowIndex);
end;

function ThiiCustomDataController.GetTotalRowCount: Int64;
begin
  if not FEnabled then
    Exit(0);
  Result := GetSourceRowCount;
end;

function ThiiCustomDataController.GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit(TValue.Empty);
  Result := GetSourceValue(LSourceIndex, AFieldName);
end;

procedure ThiiCustomDataController.Invalidate;
begin
  if FUpdateCount > 0 then
  begin
    FPendingReset := True;
    Exit;
  end;
  NotifyDataChanged(ThiiDataChange.ResetAll);
end;

function ThiiCustomDataController.MapViewToSourceIndex(AViewRowIndex: Int64): Int64;
begin
  Result := AViewRowIndex;
  if FPagination.Mode = ThiiPaginationMode.NumberedPages then
    Inc(Result, Int64(FPagination.PageIndex) * FPagination.PageSize);

  if (Result < 0) or (Result >= GetSourceRowCount) then
    Result := -1;
end;

procedure ThiiCustomDataController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FSharedClassFactory) then
    SharedClassFactory := nil;
end;

procedure ThiiCustomDataController.NotifyDataChanged(const AChange: ThiiDataChange);
var
  LLinks: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiDataControllerLink>;
  LLink: ThiiDataControllerLink;
begin
  if FUpdateCount > 0 then
  begin
    FPendingReset := True;
    Exit;
  end;

  LLinks := FLinks.ToArray;
  for LLink in LLinks do
    LLink.DataChanged(AChange);
end;

procedure ThiiCustomDataController.PaginationOptionsChanged(Sender: TObject);
var
  LChange: ThiiDataChange;
begin
  DoPaginationChanged;
  LChange := ThiiDataChange.ResetAll;
  LChange.Kind := ThiiDataChangeKind.PageChanged;
  NotifyDataChanged(LChange);
end;

procedure ThiiCustomDataController.PrepareRange(AFirstViewRow, ACount: Int64);
begin
end;

procedure ThiiCustomDataController.RegisterLink(ALink: ThiiDataControllerLink);
begin
  if FLinks.IndexOf(ALink) < 0 then
    FLinks.Add(ALink);
end;

procedure ThiiCustomDataController.SetSharedClassFactory(const AValue: ThiiClassFactory);
begin
  if FSharedClassFactory = AValue then
    Exit;

  if Assigned(FSharedClassFactory) then
    FSharedClassFactory.RemoveFreeNotification(Self);

  FSharedClassFactory := AValue;

  if Assigned(FSharedClassFactory) then
  begin
    FSharedClassFactory.FreeNotification(Self);
    FFactoryScope.Parent := FSharedClassFactory.Scope;
  end
  else
    FFactoryScope.Parent := h5uGlobalFactoryScope;
end;

procedure ThiiCustomDataController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
begin
  raise EhiiDataController.CreateFmt('%s does not support editing field "%s".', [ClassName, AFieldName]);
end;

procedure ThiiCustomDataController.SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit;

  if not GetSourceCanEdit(LSourceIndex, AFieldName) then
    raise EhiiDataController.CreateFmt('Field "%s" cannot be edited.', [AFieldName]);

  SetSourceValue(LSourceIndex, AFieldName, AValue);
end;

procedure ThiiCustomDataController.UnregisterLink(ALink: ThiiDataControllerLink);
begin
  FLinks.Remove(ALink);
end;

end.

