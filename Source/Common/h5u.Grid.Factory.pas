unit h5u.Grid.Factory;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.SysUtils,
  h5u.Grid.Types;

type
  Th5uFactoryObject = class;
  Th5uFactoryObjectClass = class of Th5uFactoryObject;
  Th5uCollectionItemClass = class of TCollectionItem;
  Th5uAnyObjectClass = class of TObject;

  Th5uClassRulePredicate = reference to function(const AContext: Th5uFactoryContext): Boolean;

  Th5uGetClassEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; var AClass: TClass; var ACacheScope: Th5uFactoryCacheScope) of object;

  Th5uCreateInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstanceClass: TClass; var AInstance: TObject; var AHandled: Boolean) of object;

  Th5uConfigureInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstance: TObject) of object;

  Th5uInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstance: TObject) of object;

  Th5uFactoryObject = class(TObject)
  public
    constructor Create(const AContext: Th5uFactoryContext); virtual;
    procedure Configure(const AContext: Th5uFactoryContext); virtual;
    procedure Bind(const AContext: Th5uFactoryContext); virtual;
    procedure Unbind; virtual;
  end;

  Th5uClassRegistration = class
  private
    FClassId: Th5uClassId;
    FExpectedBaseClass: TClass;
    FImplementationClass: TClass;
    FPredicate: Th5uClassRulePredicate;
    FPriority: Integer;
    FSequence: Int64;
  public
    property ClassId: Th5uClassId read FClassId;
    property ExpectedBaseClass: TClass read FExpectedBaseClass;
    property ImplementationClass: TClass read FImplementationClass;
    property Predicate: Th5uClassRulePredicate read FPredicate;
    property Priority: Integer read FPriority;
    property Sequence: Int64 read FSequence;
  end;

  Th5uFactoryScope = class(TPersistent)
  private
    FOwner: TObject;
    FParent: Th5uFactoryScope;
    FRegistrations: TObjectList<Th5uClassRegistration>;
    FLock: TMultiReadExclusiveWriteSynchronizer;
    FSequence: Int64;
    FOnGetClass: Th5uGetClassEvent;
    FOnCreateInstance: Th5uCreateInstanceEvent;
    FOnConfigureInstance: Th5uConfigureInstanceEvent;
    FOnInstanceCreated: Th5uInstanceEvent;
    FOnBindInstance: Th5uInstanceEvent;
    FOnUnbindInstance: Th5uInstanceEvent;
    function FindLocalClass(const AContext: Th5uFactoryContext; AExpectedBaseClass: TClass): TClass;
    procedure ValidateClass(const AClassId: Th5uClassId; AClass, AExpectedBaseClass: TClass);
    procedure SetParent(const AValue: Th5uFactoryScope);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function RegisterClass(const AClassId: Th5uClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer = 0;
      const APredicate: Th5uClassRulePredicate = nil): Th5uClassRegistration;

    procedure Unregister(ARegistration: Th5uClassRegistration);
    procedure Clear;

    function ResolveClass(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: Th5uFactoryCacheScope): TClass;

    function CreateInstance(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;

    procedure ConfigureInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    procedure BindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    procedure UnbindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    property Owner: TObject read FOwner;
    property Parent: Th5uFactoryScope read FParent write SetParent;

    property OnGetClass: Th5uGetClassEvent read FOnGetClass write FOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read FOnCreateInstance write FOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read FOnConfigureInstance write FOnConfigureInstance;
    property OnInstanceCreated: Th5uInstanceEvent read FOnInstanceCreated write FOnInstanceCreated;
    property OnBindInstance: Th5uInstanceEvent read FOnBindInstance write FOnBindInstance;
    property OnUnbindInstance: Th5uInstanceEvent read FOnUnbindInstance write FOnUnbindInstance;
  end;

  Th5uClassFactory = class(TComponent)
  private
    FScope: Th5uFactoryScope;
    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Scope: Th5uFactoryScope read FScope;
  published
    property OnGetClass: Th5uGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
  end;

function h5uGlobalFactoryScope: Th5uFactoryScope;

implementation

var
  GGlobalFactoryScope: Th5uFactoryScope;

{ Th5uFactoryObject }

procedure Th5uFactoryObject.Bind(const AContext: Th5uFactoryContext);
begin
end;

procedure Th5uFactoryObject.Configure(const AContext: Th5uFactoryContext);
begin
end;

constructor Th5uFactoryObject.Create(const AContext: Th5uFactoryContext);
begin
  inherited Create;
end;

procedure Th5uFactoryObject.Unbind;
begin
end;

{ Th5uFactoryScope }

procedure Th5uFactoryScope.BindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);
begin
  if AInstance is Th5uFactoryObject then
    Th5uFactoryObject(AInstance).Bind(AContext);

  if Assigned(FOnBindInstance) then
    FOnBindInstance(FOwner, AContext, AInstance);
end;

procedure Th5uFactoryScope.Clear;
begin
  FLock.BeginWrite;
  try
    FRegistrations.Clear;
  finally
    FLock.EndWrite;
  end;
end;

procedure Th5uFactoryScope.ConfigureInstance(const AContext: Th5uFactoryContext; AInstance: TObject);
begin
  if AInstance is Th5uFactoryObject then
    Th5uFactoryObject(AInstance).Configure(AContext);

  if Assigned(FOnConfigureInstance) then
    FOnConfigureInstance(FOwner, AContext, AInstance);
end;

constructor Th5uFactoryScope.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := AOwner;
  FRegistrations := TObjectList<Th5uClassRegistration>.Create(True);
  FLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FParent := nil;
end;

function Th5uFactoryScope.CreateInstance(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;
var
  LClass: TClass;
  LCacheScope: Th5uFactoryCacheScope;
  LHandled: Boolean;
begin
  Result := nil;
  LClass := ResolveClass(
    AContext,
    AExpectedBaseClass,
    ADefaultClass,
    LCacheScope
  );

  LHandled := False;
  if Assigned(FOnCreateInstance) then
    FOnCreateInstance(
      FOwner,
      AContext,
      LClass,
      Result,
      LHandled
    );

  if not LHandled then
  begin
    if LClass.InheritsFrom(Th5uFactoryObject) then
      Result := Th5uFactoryObjectClass(LClass).Create(AContext)
    else if LClass.InheritsFrom(TComponent) then
      Result := TComponentClass(LClass).Create(AContext.Owner)
    else if LClass.InheritsFrom(TCollectionItem) then
    begin
      if not Assigned(AContext.Collection) then
        raise Eh5uFactory.CreateFmt(
          'Class "%s" requires a collection in the factory context.',
          [LClass.ClassName]
        );
      Result := Th5uCollectionItemClass(LClass).Create(AContext.Collection);
    end
    else
      Result := Th5uAnyObjectClass(LClass).Create;
  end;

  if not Assigned(Result) then
    raise Eh5uFactory.CreateFmt(
      'The factory returned no instance for "%s".',
      [string(AContext.ClassId)]
    );

  if not Result.InheritsFrom(AExpectedBaseClass) then
  begin
    Result.Free;
    Result := nil;
    raise Eh5uFactory.CreateFmt(
      'Factory instance for "%s" must inherit from "%s".',
      [string(AContext.ClassId), AExpectedBaseClass.ClassName]
    );
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

destructor Th5uFactoryScope.Destroy;
begin
  FLock.Free;
  FRegistrations.Free;
  inherited Destroy;
end;

function Th5uFactoryScope.FindLocalClass(const AContext: Th5uFactoryContext; AExpectedBaseClass: TClass): TClass;
var
  I: Integer;
  LRegistration: Th5uClassRegistration;
  LBest: Th5uClassRegistration;
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

      if Assigned(LRegistration.ExpectedBaseClass) and
         not AExpectedBaseClass.InheritsFrom(
           LRegistration.ExpectedBaseClass
         ) and
         not LRegistration.ExpectedBaseClass.InheritsFrom(
           AExpectedBaseClass
         ) then
        Continue;

      if Assigned(LRegistration.Predicate) and
         not LRegistration.Predicate(AContext) then
        Continue;

      if not Assigned(LBest) or
         (LRegistration.Priority > LBest.Priority) or
         ((LRegistration.Priority = LBest.Priority) and
          (LRegistration.Sequence > LBest.Sequence)) then
        LBest := LRegistration;
    end;

    if Assigned(LBest) then
      Result := LBest.ImplementationClass;
  finally
    FLock.EndRead;
  end;
end;

function Th5uFactoryScope.RegisterClass(const AClassId: Th5uClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer;
  const APredicate: Th5uClassRulePredicate): Th5uClassRegistration;
begin
  if string(AClassId).Trim = '' then
    raise Eh5uFactory.Create('A factory class ID must not be empty.');

  ValidateClass(AClassId, AImplementationClass, AExpectedBaseClass);

  Result := Th5uClassRegistration.Create;
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

function Th5uFactoryScope.ResolveClass(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: Th5uFactoryCacheScope): TClass;
var
  LLocalClass: TClass;
begin
  ACacheScope := Th5uFactoryCacheScope.ClassId;

  if Assigned(FParent) then
    Result := FParent.ResolveClass(
      AContext,
      AExpectedBaseClass,
      ADefaultClass,
      ACacheScope
    )
  else
    Result := ADefaultClass;

  LLocalClass := FindLocalClass(AContext, AExpectedBaseClass);
  if Assigned(LLocalClass) then
    Result := LLocalClass;

  if Assigned(FOnGetClass) then
    FOnGetClass(FOwner, AContext, Result, ACacheScope);

  ValidateClass(AContext.ClassId, Result, AExpectedBaseClass);
end;

procedure Th5uFactoryScope.SetParent(const AValue: Th5uFactoryScope);
var
  LScope: Th5uFactoryScope;
begin
  if AValue = Self then
    raise Eh5uFactory.Create('A factory scope cannot be its own parent.');

  LScope := AValue;
  while Assigned(LScope) do
  begin
    if LScope = Self then
      raise Eh5uFactory.Create('Circular factory scope parent chain.');
    LScope := LScope.Parent;
  end;

  FParent := AValue;
end;

procedure Th5uFactoryScope.UnbindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);
begin
  if Assigned(FOnUnbindInstance) then
    FOnUnbindInstance(FOwner, AContext, AInstance);

  if AInstance is Th5uFactoryObject then
    Th5uFactoryObject(AInstance).Unbind;
end;

procedure Th5uFactoryScope.Unregister(ARegistration: Th5uClassRegistration);
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

procedure Th5uFactoryScope.ValidateClass(const AClassId: Th5uClassId; AClass, AExpectedBaseClass: TClass);
begin
  if not Assigned(AClass) then
    raise Eh5uFactory.CreateFmt(
      'No class is registered for "%s".',
      [string(AClassId)]
    );

  if Assigned(AExpectedBaseClass) and
     not AClass.InheritsFrom(AExpectedBaseClass) then
    raise Eh5uFactory.CreateFmt(
      'Class "%s" registered for "%s" must inherit from "%s".',
      [
        AClass.ClassName,
        string(AClassId),
        AExpectedBaseClass.ClassName
      ]
    );
end;

{ Th5uClassFactory }

constructor Th5uClassFactory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScope := Th5uFactoryScope.Create(Self);
  FScope.Parent := h5uGlobalFactoryScope;
end;

destructor Th5uClassFactory.Destroy;
begin
  FScope.Free;
  inherited Destroy;
end;

function Th5uClassFactory.GetOnConfigureInstance: Th5uConfigureInstanceEvent;
begin
  Result := FScope.OnConfigureInstance;
end;

function Th5uClassFactory.GetOnCreateInstance: Th5uCreateInstanceEvent;
begin
  Result := FScope.OnCreateInstance;
end;

function Th5uClassFactory.GetOnGetClass: Th5uGetClassEvent;
begin
  Result := FScope.OnGetClass;
end;

procedure Th5uClassFactory.SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
begin
  FScope.OnConfigureInstance := AValue;
end;

procedure Th5uClassFactory.SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
begin
  FScope.OnCreateInstance := AValue;
end;

procedure Th5uClassFactory.SetOnGetClass(const AValue: Th5uGetClassEvent);
begin
  FScope.OnGetClass := AValue;
end;

function h5uGlobalFactoryScope: Th5uFactoryScope;
begin
  if not Assigned(GGlobalFactoryScope) then
    GGlobalFactoryScope := Th5uFactoryScope.Create(nil);
  Result := GGlobalFactoryScope;
end;

initialization
  GGlobalFactoryScope := Th5uFactoryScope.Create(nil);

finalization
  FreeAndNil(GGlobalFactoryScope);

end.
