unit h5u.Grid.Factory;

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
    SyncObjs,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.SyncObjs,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Types;

type
  ThiiFactoryObject = class;
  ThiiFactoryObjectClass = class of ThiiFactoryObject;
  ThiiCollectionItemClass = class of TCollectionItem;
  ThiiAnyObjectClass = class of TObject;

  ThiiClassRulePredicate = {$IFnDEF FPC}reference to {$ENDIF}function(const AContext: ThiiFactoryContext): Boolean;
  ThiiGetClassEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; var AClass: TClass; var ACacheScope: ThiiFactoryCacheScope) of object;
  ThiiCreateInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstanceClass: TClass; var AInstance: TObject; var AHandled: Boolean) of object;
  ThiiConfigureInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstance: TObject) of object;
  ThiiInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstance: TObject) of object;

  ThiiFactoryObject = class(TObject)
  public
    constructor Create(const AContext: ThiiFactoryContext); virtual;
    procedure Configure(const AContext: ThiiFactoryContext); virtual;
    procedure Bind(const AContext: ThiiFactoryContext); virtual;
    procedure Unbind; virtual;
  end;

  ThiiClassRegistration = class
  private
    FClassId: ThiiClassId;
    FExpectedBaseClass: TClass;
    FImplementationClass: TClass;
    FPredicate: ThiiClassRulePredicate;
    FPriority: Integer;
    FSequence: Int64;
  public
    property ClassId: ThiiClassId read FClassId;
    property ExpectedBaseClass: TClass read FExpectedBaseClass;
    property ImplementationClass: TClass read FImplementationClass;
    property Predicate: ThiiClassRulePredicate read FPredicate;
    property Priority: Integer read FPriority;
    property Sequence: Int64 read FSequence;
  end;

  ThiiFactoryScope = class(TPersistent)
  private
    FOwner: TObject;
    FParent: ThiiFactoryScope;
    FRegistrations: {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiClassRegistration>;
    FLock: TMultiReadExclusiveWriteSynchronizer;
    FSequence: Int64;
    FOnGetClass: ThiiGetClassEvent;
    FOnCreateInstance: ThiiCreateInstanceEvent;
    FOnConfigureInstance: ThiiConfigureInstanceEvent;
    FOnInstanceCreated: ThiiInstanceEvent;
    FOnBindInstance: ThiiInstanceEvent;
    FOnUnbindInstance: ThiiInstanceEvent;
    function FindLocalClass(const AContext: ThiiFactoryContext; AExpectedBaseClass: TClass): TClass;
    procedure ValidateClass(const AClassId: ThiiClassId; AClass, AExpectedBaseClass: TClass);
    procedure SetParent(const AValue: ThiiFactoryScope);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function RegisterClass(const AClassId: ThiiClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer = 0;
      const APredicate: ThiiClassRulePredicate = nil): ThiiClassRegistration;

    procedure Unregister(ARegistration: ThiiClassRegistration);
    procedure Clear;

    function ResolveClass(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: ThiiFactoryCacheScope): TClass;

    function CreateInstance(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;

    procedure ConfigureInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    procedure BindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    procedure UnbindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    property Owner: TObject read FOwner;
    property Parent: ThiiFactoryScope read FParent write SetParent;

    property OnGetClass: ThiiGetClassEvent read FOnGetClass write FOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read FOnCreateInstance write FOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read FOnConfigureInstance write FOnConfigureInstance;
    property OnInstanceCreated: ThiiInstanceEvent read FOnInstanceCreated write FOnInstanceCreated;
    property OnBindInstance: ThiiInstanceEvent read FOnBindInstance write FOnBindInstance;
    property OnUnbindInstance: ThiiInstanceEvent read FOnUnbindInstance write FOnUnbindInstance;
  end;

  ThiiClassFactory = class(TComponent)
  private
    FScope: ThiiFactoryScope;
    function GetOnGetClass: ThiiGetClassEvent;
    procedure SetOnGetClass(const AValue: ThiiGetClassEvent);
    function GetOnCreateInstance: ThiiCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
    function GetOnConfigureInstance: ThiiConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Scope: ThiiFactoryScope read FScope;
  published
    property OnGetClass: ThiiGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
  end;

function h5uGlobalFactoryScope: ThiiFactoryScope;

implementation

var
  GGlobalFactoryScope: ThiiFactoryScope;

{ ThiiFactoryObject }

procedure ThiiFactoryObject.Bind(const AContext: ThiiFactoryContext);
begin
end;

procedure ThiiFactoryObject.Configure(const AContext: ThiiFactoryContext);
begin
end;

constructor ThiiFactoryObject.Create(const AContext: ThiiFactoryContext);
begin
  inherited Create;
end;

procedure ThiiFactoryObject.Unbind;
begin
end;

{ ThiiFactoryScope }

procedure ThiiFactoryScope.BindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);
begin
  if AInstance is ThiiFactoryObject then
    ThiiFactoryObject(AInstance).Bind(AContext);

  if Assigned(FOnBindInstance) then
    FOnBindInstance(FOwner, AContext, AInstance);
end;

procedure ThiiFactoryScope.Clear;
begin
  FLock.BeginWrite;
  try
    FRegistrations.Clear;
  finally
    FLock.EndWrite;
  end;
end;

procedure ThiiFactoryScope.ConfigureInstance(const AContext: ThiiFactoryContext; AInstance: TObject);
begin
  if AInstance is ThiiFactoryObject then
    ThiiFactoryObject(AInstance).Configure(AContext);

  if Assigned(FOnConfigureInstance) then
    FOnConfigureInstance(FOwner, AContext, AInstance);
end;

constructor ThiiFactoryScope.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FRegistrations := {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiClassRegistration>.Create(True);
  FLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FParent := nil;
end;

function ThiiFactoryScope.CreateInstance(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;
var
  LClass: TClass;
  LCacheScope: ThiiFactoryCacheScope;
  LHandled: Boolean;
begin
  Result := nil;
  LClass := ResolveClass(AContext, AExpectedBaseClass, ADefaultClass, LCacheScope);

  LHandled := False;
  if Assigned(FOnCreateInstance) then
    FOnCreateInstance(FOwner, AContext, LClass, Result, LHandled);

  if not LHandled then
  begin
    if LClass.InheritsFrom(ThiiFactoryObject) then
      Result := ThiiFactoryObjectClass(LClass).Create(AContext)
    else if LClass.InheritsFrom(TComponent) then
      Result := TComponentClass(LClass).Create(AContext.Owner)
    else if LClass.InheritsFrom(TCollectionItem) then
    begin
      if not Assigned(AContext.Collection) then
        raise EhiiFactory.CreateFmt('Class "%s" requires a collection in the factory context.', [LClass.ClassName]);
      Result := ThiiCollectionItemClass(LClass).Create(AContext.Collection);
    end
    else
      Result := ThiiAnyObjectClass(LClass).Create;
  end;

  if not Assigned(Result) then
    raise EhiiFactory.CreateFmt('The factory returned no instance for "%s".', [string(AContext.ClassId)]);

  if not Result.InheritsFrom(AExpectedBaseClass) then
  begin
    Result.Free;
    Result := nil;
    raise EhiiFactory.CreateFmt('Factory instance for "%s" must inherit from "%s".', [string(AContext.ClassId), AExpectedBaseClass.ClassName]);
  end;

  try
    ConfigureInstance(AContext, Result);
    if Assigned(FOnInstanceCreated) then
      FOnInstanceCreated(FOwner, AContext, Result);
  except
    Result.Free;
    Result := nil;
    raise;
  end;
end;

destructor ThiiFactoryScope.Destroy;
begin
  FLock.Free;
  FRegistrations.Free;
  inherited;
end;

function ThiiFactoryScope.FindLocalClass(const AContext: ThiiFactoryContext; AExpectedBaseClass: TClass): TClass;
var
  I: Integer;
  LRegistration: ThiiClassRegistration;
  LBest: ThiiClassRegistration;
begin
  Result := nil;
  LBest := nil;

  FLock.BeginRead;
  try
    for I := 0 to FRegistrations.Count - 1 do
    begin
      LRegistration := FRegistrations[I];

      if LRegistration.ClassId <> AContext.ClassId then
        Continue;

      if Assigned(LRegistration.ExpectedBaseClass) and not AExpectedBaseClass.InheritsFrom(LRegistration.ExpectedBaseClass)
        and not LRegistration.ExpectedBaseClass.InheritsFrom(AExpectedBaseClass) then
        Continue;

      if Assigned(LRegistration.Predicate) and not LRegistration.Predicate(AContext) then
        Continue;

      if not Assigned(LBest) or (LRegistration.Priority > LBest.Priority)
        or ((LRegistration.Priority = LBest.Priority) and (LRegistration.Sequence > LBest.Sequence)) then
        LBest := LRegistration;
    end;

    if Assigned(LBest) then
      Result := LBest.ImplementationClass;
  finally
    FLock.EndRead;
  end;
end;

function ThiiFactoryScope.RegisterClass(const AClassId: ThiiClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer;
  const APredicate: ThiiClassRulePredicate): ThiiClassRegistration;
begin
  if string(AClassId).Trim = '' then
    raise EhiiFactory.Create('A factory class ID must not be empty.');

  ValidateClass(AClassId, AImplementationClass, AExpectedBaseClass);

  Result := ThiiClassRegistration.Create;
  Result.FClassId := AClassId;
  Result.FExpectedBaseClass := AExpectedBaseClass;
  Result.FImplementationClass := AImplementationClass;
  Result.FPredicate := APredicate;
  Result.FPriority := APriority;

  FLock.BeginWrite;
  try
    Inc(FSequence);
    Result.FSequence := FSequence;
    FRegistrations.Add(Result);
  finally
    FLock.EndWrite;
  end;
end;

function ThiiFactoryScope.ResolveClass(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: ThiiFactoryCacheScope): TClass;
var
  LLocalClass: TClass;
begin
  ACacheScope := ThiiFactoryCacheScope.ClassId;

  if Assigned(FParent) then
    Result := FParent.ResolveClass(AContext, AExpectedBaseClass, ADefaultClass, ACacheScope)
  else
    Result := ADefaultClass;

  LLocalClass := FindLocalClass(AContext, AExpectedBaseClass);
  if Assigned(LLocalClass) then
    Result := LLocalClass;

  if Assigned(FOnGetClass) then
    FOnGetClass(FOwner, AContext, Result, ACacheScope);

  ValidateClass(AContext.ClassId, Result, AExpectedBaseClass);
end;

procedure ThiiFactoryScope.SetParent(const AValue: ThiiFactoryScope);
var
  LScope: ThiiFactoryScope;
begin
  if AValue = Self then
    raise EhiiFactory.Create('A factory scope cannot be its own parent.');

  LScope := AValue;
  while Assigned(LScope) do
  begin
    if LScope = Self then
      raise EhiiFactory.Create('Circular factory scope parent chain.');
    LScope := LScope.Parent;
  end;

  FParent := AValue;
end;

procedure ThiiFactoryScope.UnbindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);
begin
  if Assigned(FOnUnbindInstance) then
    FOnUnbindInstance(FOwner, AContext, AInstance);

  if AInstance is ThiiFactoryObject then
    ThiiFactoryObject(AInstance).Unbind;
end;

procedure ThiiFactoryScope.Unregister(ARegistration: ThiiClassRegistration);
begin
  if not Assigned(ARegistration) then
    Exit;

  FLock.BeginWrite;
  try
    FRegistrations.Extract(ARegistration);
  finally
    FLock.EndWrite;
  end;
  ARegistration.Free;
end;

procedure ThiiFactoryScope.ValidateClass(const AClassId: ThiiClassId; AClass, AExpectedBaseClass: TClass);
begin
  if not Assigned(AClass) then
    raise EhiiFactory.CreateFmt('No class is registered for "%s".', [string(AClassId)]);

  if Assigned(AExpectedBaseClass) and not AClass.InheritsFrom(AExpectedBaseClass) then
    raise EhiiFactory.CreateFmt('Class "%s" registered for "%s" must inherit from "%s".',
      [AClass.ClassName, string(AClassId), AExpectedBaseClass.ClassName]);
end;

{ ThiiClassFactory }

constructor ThiiClassFactory.Create(AOwner: TComponent);
begin
  inherited;
  FScope := ThiiFactoryScope.Create(Self);
  FScope.Parent := h5uGlobalFactoryScope;
end;

destructor ThiiClassFactory.Destroy;
begin
  FScope.Free;
  inherited;
end;

function ThiiClassFactory.GetOnConfigureInstance: ThiiConfigureInstanceEvent;
begin
  Result := FScope.OnConfigureInstance;
end;

function ThiiClassFactory.GetOnCreateInstance: ThiiCreateInstanceEvent;
begin
  Result := FScope.OnCreateInstance;
end;

function ThiiClassFactory.GetOnGetClass: ThiiGetClassEvent;
begin
  Result := FScope.OnGetClass;
end;

procedure ThiiClassFactory.SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);
begin
  FScope.OnConfigureInstance := AValue;
end;

procedure ThiiClassFactory.SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
begin
  FScope.OnCreateInstance := AValue;
end;

procedure ThiiClassFactory.SetOnGetClass(const AValue: ThiiGetClassEvent);
begin
  FScope.OnGetClass := AValue;
end;

function h5uGlobalFactoryScope: ThiiFactoryScope;
begin
  if not Assigned(GGlobalFactoryScope) then
    GGlobalFactoryScope := ThiiFactoryScope.Create(nil);
  Result := GGlobalFactoryScope;
end;

initialization
  GGlobalFactoryScope := ThiiFactoryScope.Create(nil);

finalization
  FreeAndNil(GGlobalFactoryScope);

end.

