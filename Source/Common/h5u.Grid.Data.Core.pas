unit h5u.Grid.Data.Core;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  Th5uCustomDataController = class;
  Th5uDataControllerLink = class;

  Th5uDataControllerChangedEvent = procedure(Sender: TObject; const AChange: Th5uDataChange) of object;

  Th5uDataControllerLink = class(TObject)
  private
    FController: Th5uCustomDataController;
    FOnChanged: Th5uDataControllerChangedEvent;
    procedure SetController(const AValue: Th5uCustomDataController);
  public
    destructor Destroy; override;
    procedure DataChanged(const AChange: Th5uDataChange);
    property Controller: Th5uCustomDataController read FController write SetController;
    property OnChanged: Th5uDataControllerChangedEvent read FOnChanged write FOnChanged;
  end;

  Th5uDataViewSession = class(Th5uFactoryObject)
  private
    FGrid: TObject;
    FView: TObject;
    FController: Th5uCustomDataController;
    FQueryGeneration: Int64;
  public
    constructor Create(const AContext: Th5uFactoryContext); override;
    procedure NextQueryGeneration;
    property Grid: TObject read FGrid;
    property View: TObject read FView;
    property Controller: Th5uCustomDataController read FController;
    property QueryGeneration: Int64 read FQueryGeneration;
  end;

  Th5uCustomDataController = class(TComponent)
  private
    FLinks: TList<Th5uDataControllerLink>;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FCache: Th5uCacheOptions;
    FPagination: Th5uPaginationOptions;
    FEnabled: Boolean;
    FUpdateCount: Integer;
    FPendingReset: Boolean;
    procedure CacheOptionsChanged(Sender: TObject);
    procedure PaginationOptionsChanged(Sender: TObject);
    procedure SetSharedClassFactory(const AValue: Th5uClassFactory);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetSourceRowCount: Int64; virtual; abstract;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; virtual;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; virtual; abstract;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); virtual;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; virtual;
    function GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string; virtual;
    function MapViewToSourceIndex(AViewRowIndex: Int64): Int64; virtual;

    procedure DoCacheOptionsChanged; virtual;
    procedure DoPaginationChanged; virtual;

    procedure RegisterLink(ALink: Th5uDataControllerLink);
    procedure UnregisterLink(ALink: Th5uDataControllerLink);
    procedure NotifyDataChanged(const AChange: Th5uDataChange);

    function GetDataSessionClass(const AContext: Th5uFactoryContext): TClass; virtual;

    property Links: TList<Th5uDataControllerLink> read FLinks;
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
    function GetRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetDisplayText(AViewRowIndex: Int64; const AFieldName: string; const ADisplayFormat: string = ''): string;

    function CreateSession(AGrid, AView: TObject): Th5uDataViewSession; virtual;

    property FactoryScope: Th5uFactoryScope read FFactoryScope;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property SharedClassFactory: Th5uClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Cache: Th5uCacheOptions read FCache write FCache;
    property Pagination: Th5uPaginationOptions read FPagination write FPagination;
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

  if AValue.IsType<TBytes> then
  begin
    LBytes := AValue.AsType<TBytes>;
    if Length(LBytes) = 0 then
      Exit('');
    Exit(Format('[Bild: %d Bytes]', [Length(LBytes)]));
  end;

  case AValue.Kind of
    tkString, tkLString, tkWString, tkUString, tkChar, tkWChar: Result := AValue.ToString;

    tkInteger, tkInt64, tkEnumeration: if (ADisplayFormat <> '') and (AValue.Kind <> tkEnumeration) then Result := FormatFloat(ADisplayFormat, AValue.AsInt64) else Result :=
      AValue.ToString;

    tkFloat: begin if AValue.TypeInfo = TypeInfo(TDateTime) then begin LDateTime := AValue.AsType<TDateTime>;
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

    tkVariant: if VarIsNull(AValue.AsVariant) or VarIsEmpty(AValue.AsVariant) then Result := '' else Result := VarToStr(AValue.AsVariant);

    tkClass: if Assigned(AValue.AsObject) then Result := AValue.AsObject.ToString else Result := '';

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
    tkInteger, tkInt64: begin AInteger := AValue.AsInteger;
        Exit(True);
      end;

    tkEnumeration: begin if AValue.TypeInfo = TypeInfo(Boolean) then AInteger := Ord(AValue.AsBoolean) else AInteger := AValue.AsOrdinal;
        Exit(True);
      end;
  end;

  LText := AValue.ToString;
  Result := TryStrToInt(LText, AInteger);
end;

{ Th5uDataControllerLink }

procedure Th5uDataControllerLink.DataChanged(const AChange: Th5uDataChange);
begin
  if Assigned(FOnChanged) then
    FOnChanged(FController, AChange);
end;

destructor Th5uDataControllerLink.Destroy;
begin
  Controller := nil;
  inherited Destroy;
end;

procedure Th5uDataControllerLink.SetController(const AValue: Th5uCustomDataController);
begin
  if FController = AValue then
    Exit;

  if Assigned(FController) then
    FController.UnregisterLink(Self);

  FController := AValue;

  if Assigned(FController) then
    FController.RegisterLink(Self);
end;

{ Th5uDataViewSession }

constructor Th5uDataViewSession.Create(const AContext: Th5uFactoryContext);
begin
  inherited Create(AContext);
  FGrid := AContext.Grid;
  FView := AContext.View;
  if AContext.DataController is Th5uCustomDataController then
    FController := Th5uCustomDataController(AContext.DataController);
  FQueryGeneration := 1;
end;

procedure Th5uDataViewSession.NextQueryGeneration;
begin
  Inc(FQueryGeneration);
end;

{ Th5uCustomDataController }

procedure Th5uCustomDataController.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure Th5uCustomDataController.CacheOptionsChanged(Sender: TObject);
begin
  DoCacheOptionsChanged;
  Invalidate;
end;

function Th5uCustomDataController.CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
var
  LSourceIndex: Int64;
begin
  if not FEnabled then
    Exit(False);
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  Result := (LSourceIndex >= 0) and
    GetSourceCanEdit(LSourceIndex, AFieldName);
end;

constructor Th5uCustomDataController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLinks := TList<Th5uDataControllerLink>.Create;
  FFactoryScope := Th5uFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FCache := Th5uCacheOptions.Create;
  FCache.OnChanged := CacheOptionsChanged;
  FPagination := Th5uPaginationOptions.Create;
  FPagination.OnChanged := PaginationOptionsChanged;
  FEnabled := True;
end;

function Th5uCustomDataController.CreateSession(AGrid, AView: TObject): Th5uDataViewSession;
var
  LContext: Th5uFactoryContext;
begin
  LContext := Th5uFactoryContext.Create(
    AGrid,
    AView,
    Self,
    h5uClassIdDataSession,
    Th5uElementKind.DataSession
  );
  LContext.Owner := Self;
  LContext.CreationReason := Th5uCreationReason.ControllerInternal;

  Result := Th5uDataViewSession(
    FFactoryScope.CreateInstance(
      LContext,
      Th5uDataViewSession,
      GetDataSessionClass(LContext)
    )
  );
end;

destructor Th5uCustomDataController.Destroy;
begin
  while FLinks.Count > 0 do
    FLinks[0].FController := nil;
  FPagination.Free;
  FCache.Free;
  FFactoryScope.Free;
  FLinks.Free;
  inherited Destroy;
end;

procedure Th5uCustomDataController.DoCacheOptionsChanged;
begin
end;

procedure Th5uCustomDataController.DoPaginationChanged;
begin
end;

procedure Th5uCustomDataController.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;
  Dec(FUpdateCount);

  if (FUpdateCount = 0) and FPendingReset then
  begin
    FPendingReset := False;
    NotifyDataChanged(Th5uDataChange.ResetAll);
  end;
end;

function Th5uCustomDataController.GetDataSessionClass(const AContext: Th5uFactoryContext): TClass;
begin
  Result := Th5uDataViewSession;
end;

function Th5uCustomDataController.GetDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit('');
  Result := GetSourceDisplayText(
    LSourceIndex,
    AFieldName,
    ADisplayFormat
  );
end;

function Th5uCustomDataController.GetRowCount: Int64;
var
  LTotal: Int64;
  LOffset: Int64;
begin
  if not FEnabled then
    Exit(0);

  LTotal := GetSourceRowCount;
  if FPagination.Mode <> Th5uPaginationMode.NumberedPages then
    Exit(LTotal);

  LOffset := Int64(FPagination.PageIndex) * FPagination.PageSize;
  if LOffset >= LTotal then
    Exit(0);

  Result := LTotal - LOffset;
  if Result > FPagination.PageSize then
    Result := FPagination.PageSize;
end;

function Th5uCustomDataController.GetSourceRowIndex(AViewRowIndex: Int64): Int64;
begin
  if not FEnabled then
    Exit(-1);
  Result := MapViewToSourceIndex(AViewRowIndex);
end;

function Th5uCustomDataController.IsRowAvailable(AViewRowIndex: Int64): Boolean;
begin
  Result := GetSourceRowIndex(AViewRowIndex) >= 0;
end;

function Th5uCustomDataController.GetRowKey(AViewRowIndex: Int64): Th5uRowKey;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit(Th5uRowKey.Empty);
  Result := GetSourceRowKey(LSourceIndex);
end;

function Th5uCustomDataController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := False;
end;

function Th5uCustomDataController.GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
begin
  Result := h5uValueToDisplayText(
    GetSourceValue(ASourceRowIndex, AFieldName),
    ADisplayFormat
  );
end;

function Th5uCustomDataController.GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey;
begin
  Result := Th5uRowKey.FromInt64(ASourceRowIndex);
end;

function Th5uCustomDataController.GetTotalRowCount: Int64;
begin
  if not FEnabled then
    Exit(0);
  Result := GetSourceRowCount;
end;

function Th5uCustomDataController.GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit(TValue.Empty);
  Result := GetSourceValue(LSourceIndex, AFieldName);
end;

procedure Th5uCustomDataController.Invalidate;
begin
  if FUpdateCount > 0 then
  begin
    FPendingReset := True;
    Exit;
  end;
  NotifyDataChanged(Th5uDataChange.ResetAll);
end;

function Th5uCustomDataController.MapViewToSourceIndex(AViewRowIndex: Int64): Int64;
begin
  Result := AViewRowIndex;
  if FPagination.Mode = Th5uPaginationMode.NumberedPages then
    Inc(Result, Int64(FPagination.PageIndex) * FPagination.PageSize);

  if (Result < 0) or (Result >= GetSourceRowCount) then
    Result := -1;
end;

procedure Th5uCustomDataController.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and
     (AComponent = FSharedClassFactory) then
    SharedClassFactory := nil;
end;

procedure Th5uCustomDataController.NotifyDataChanged(const AChange: Th5uDataChange);
var
  LLinks: TArray<Th5uDataControllerLink>;
  LLink: Th5uDataControllerLink;
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

procedure Th5uCustomDataController.PaginationOptionsChanged(Sender: TObject);
var
  LChange: Th5uDataChange;
begin
  DoPaginationChanged;
  LChange := Th5uDataChange.ResetAll;
  LChange.Kind := Th5uDataChangeKind.PageChanged;
  NotifyDataChanged(LChange);
end;

procedure Th5uCustomDataController.PrepareRange(AFirstViewRow, ACount: Int64);
begin
end;

procedure Th5uCustomDataController.RegisterLink(ALink: Th5uDataControllerLink);
begin
  if FLinks.IndexOf(ALink) < 0 then
    FLinks.Add(ALink);
end;

procedure Th5uCustomDataController.SetSharedClassFactory(const AValue: Th5uClassFactory);
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

procedure Th5uCustomDataController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
begin
  raise Eh5uDataController.CreateFmt(
    '%s does not support editing field "%s".',
    [ClassName, AFieldName]
  );
end;

procedure Th5uCustomDataController.SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LSourceIndex: Int64;
begin
  LSourceIndex := MapViewToSourceIndex(AViewRowIndex);
  if LSourceIndex < 0 then
    Exit;

  if not GetSourceCanEdit(LSourceIndex, AFieldName) then
    raise Eh5uDataController.CreateFmt(
      'Field "%s" cannot be edited.',
      [AFieldName]
    );

  SetSourceValue(LSourceIndex, AFieldName, AValue);
end;

procedure Th5uCustomDataController.UnregisterLink(ALink: Th5uDataControllerLink);
begin
  FLinks.Remove(ALink);
end;

end.
