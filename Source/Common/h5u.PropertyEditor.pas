unit h5u.PropertyEditor;

interface

{$IFnDEF FPC}

uses
  System.Classes, System.SysUtils, System.TypInfo, System.Rtti,
  System.Generics.Collections, System.Variants, System.Masks,
  h5u.Grid.Types, h5u.Grid.Sizing, h5u.Grid.Data.Objects;

type
  EhiiPropertyError = class(Exception);
  ThiiPropertyModel = class;
  ThiiPropertyItem = class;
  ThiiManualProperty = class;
  ThiiPropertySortOrder = (psoName, psoDeclaration);
  ThiiPropertyItemChangedEvent = procedure(Sender: TObject; Item: ThiiPropertyItem) of object;
  ThiiGetPropertyValueEvent = procedure(Sender: TObject; Item: ThiiPropertyItem; var Value: TValue; var Handled: Boolean) of object;
  ThiiSetPropertyValueEvent = procedure(Sender: TObject; Item: ThiiPropertyItem; const Value: TValue; var Handled: Boolean) of object;

  { Editors convert the model value to/from its editable presentation. Override
    these three methods to supply e.g. component references or method names. }
  ThiiValueEditor = class
  private
    FItem: ThiiPropertyItem;
  protected
    property Item: ThiiPropertyItem read FItem;
  public
    constructor Create(AItem: ThiiPropertyItem); virtual;
    function GetValue: string; virtual;
    procedure SetValue(const AText: string); virtual;
    procedure GetComboList(AList: TStrings); virtual;
  end;
  ThiiValueEditorClass = class of ThiiValueEditor;

  ThiiWidthValueEditor = class(ThiiValueEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const AText: string); override;
    procedure GetComboList(AList: TStrings); override;
  end;

  ThiiPropertyItem = class(TPersistent)
  private
    FOwner: ThiiPropertyModel;
    FInstance: Pointer;
    FName, FPath, FCaption, FGroupName, FDeclaringClassName, FTypeName, FReadError: string;
    FDeclaringClass: TClass;
    FValueTypeInfo: PTypeInfo;
    FProperty: TRttiProperty;
    FField: TRttiField;
    FManual: ThiiManualProperty;
    FCachedValue: TValue;
    FCacheValid, FReadOnly, FHidden, FIsManual, FObjectGroup: Boolean;
    FID, FParentID, FClassOrder, FMemberOrder: Integer;
    function GetValue: TValue;
    procedure SetValue(const AValue: TValue);
    function GetDisplayValue: string;
    procedure SetDisplayValue(const AValue: string);
    function GetCanEdit: Boolean;
    function GetIsManual: Boolean;
  public
    property Owner: ThiiPropertyModel read FOwner;
    property Instance: Pointer read FInstance;
    property Value: TValue read GetValue write SetValue;
    property ValueTypeInfo: PTypeInfo read FValueTypeInfo;
    property DeclaringClass: TClass read FDeclaringClass;
    property RttiProperty: TRttiProperty read FProperty;
    property RttiField: TRttiField read FField;
    procedure GetComboList(AList: TStrings);
  published
    property ID: Integer read FID;
    property ParentID: Integer read FParentID;
    property Name: string read FName;
    property Path: string read FPath;
    property ObjectGroup: Boolean read FObjectGroup;
    property Caption: string read FCaption write FCaption;
    property GroupName: string read FGroupName write FGroupName;
    property DisplayValue: string read GetDisplayValue write SetDisplayValue;
    property ReadError: string read FReadError;
    property DeclaringClassName: string read FDeclaringClassName;
    property TypeName: string read FTypeName;
    property ReadOnly: Boolean read FReadOnly;
    property CanEdit: Boolean read GetCanEdit;
    property Hidden: Boolean read FHidden;
    property IsManual: Boolean read GetIsManual;
  end;

  ThiiPropertyFilter = class(TCollectionItem)
  private
    FClassMask, FNameMask, FTypeMask: string;
    FReadOnly, FHidden: Boolean;
    procedure SetMask(AIndex: Integer; const AValue: string);
    procedure SetFlag(AIndex: Integer; AValue: Boolean);
  published
    property ClassMask: string index 0 read FClassMask write SetMask;
    property NameMask: string index 1 read FNameMask write SetMask;
    property TypeMask: string index 2 read FTypeMask write SetMask;
    property ReadOnly: Boolean index 0 read FReadOnly write SetFlag default False;
    property Hidden: Boolean index 1 read FHidden write SetFlag default False;
  end;

  ThiiPropertyFilters = class(TOwnedCollection)
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: ThiiPropertyFilter;
  end;

  ThiiManualProperty = class(TCollectionItem)
  private
    FTargetClass: TClass;
    FPropertyName: string;
    FValueTypeInfo: PTypeInfo;
    FDefaultValue: TValue;
    procedure SetTargetClass(AValue: TClass);
    procedure SetPropertyName(const AValue: string);
    procedure SetValueTypeInfo(AValue: PTypeInfo);
    procedure SetDefaultValue(const AValue: TValue);
    procedure ClearCachedValues;
  public
    destructor Destroy; override;
    property TargetClass: TClass read FTargetClass write SetTargetClass;
    property ValueTypeInfo: PTypeInfo read FValueTypeInfo write SetValueTypeInfo;
    property DefaultValue: TValue read FDefaultValue write SetDefaultValue;
  published
    property PropertyName: string read FPropertyName write SetPropertyName;
  end;

  ThiiManualProperties = class(TOwnedCollection)
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: ThiiManualProperty;
  end;

  ThiiPropertyModel = class(TComponent)
  private type
    TManualCacheEntry = class
      Instance: Pointer;
      Definition: ThiiManualProperty;
      Value: TValue;
      ExplicitValue: Boolean;
    end;
    TChangeListener = class
      Changing, Changed: TNotifyEvent;
      ItemChanged: ThiiPropertyItemChangedEvent;
    end;
  private
    FDataObject: TObject;
    FItems: TObjectList<ThiiPropertyItem>;
    FManualCache: TObjectList<TManualCacheEntry>;
    FListeners: TObjectList<TChangeListener>;
    FObservedComponents: TList<TComponent>;
    FNextItemID: Integer;
    FValueUpdateItem: ThiiPropertyItem;
    FValueBeforeUpdate: TValue;
    FReadErrorBeforeUpdate: string;
    FContext: TRttiContext;
    FPublishedProperties, FPublicProperties, FPublicFields, FPrivateFields: Boolean;
    FLimitClass: TClass;
    FSortOrder: ThiiPropertySortOrder;
    FExpandSubProperties: Boolean;
    FRootGroupName: string;
    FClassMask, FNameMask, FTypeMask: string;
    FFilters: ThiiPropertyFilters;
    FManualProperties: ThiiManualProperties;
    FOnLoaded, FOnChanging, FOnChange: TNotifyEvent;
    FOnItemChanged: ThiiPropertyItemChangedEvent;
    FOnGetValue: ThiiGetPropertyValueEvent;
    FOnSetValue: ThiiSetPropertyValueEvent;
    FReloading, FDestroying: Boolean;
    procedure SetExpandSubProperties(AValue: Boolean);
    procedure SetRootGroupName(const AValue: string);
    procedure SetDataObject(AValue: TObject);
    procedure SetSelection(AIndex: Integer; AValue: Boolean);
    procedure SetLimitClass(AValue: TClass);
    procedure SetSortOrder(AValue: ThiiPropertySortOrder);
    procedure SetMask(AIndex: Integer; const AValue: string);
    procedure CheckItem(AItem: ThiiPropertyItem);
    procedure NotifyChanging;
    procedure NotifyChanged;
    procedure NotifyItemChanged(AItem: ThiiPropertyItem);
    procedure ObserveInstance(AInstance: Pointer);
    procedure PrepareItems;
    procedure CompleteNewItem(AItem: ThiiPropertyItem);
    function UpdateCachedValue(AItem: ThiiPropertyItem; const APreviousValue: TValue; const APreviousError: string): Boolean;
    function ValuesEqual(const A, B: TValue): Boolean;
    function SnapshotValue(const AValue: TValue): TValue;
    procedure ApplyFilters(AItem: ThiiPropertyItem);
    procedure SortItems;
    function NewItem(AInstance: Pointer; const AName: string; AClass: TClass; ATypeInfo: PTypeInfo): ThiiPropertyItem;
    function ReadMember(AItem: ThiiPropertyItem): TValue;
    procedure WriteMember(AItem: ThiiPropertyItem; const AValue: TValue);
    function ManualCache(AItem: ThiiPropertyItem; ACreate: Boolean): TManualCacheEntry;
    procedure ForgetDefinition(ADefinition: ThiiManualProperty);
    procedure UpdateDefinitionDefault(ADefinition: ThiiManualProperty);
    function CreateValueEditor(AItem: ThiiPropertyItem): ThiiValueEditor;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoLoaded; virtual;
    procedure DoGetValue(AItem: ThiiPropertyItem; var AValue: TValue; var AHandled: Boolean); virtual;
    procedure DoSetValue(AItem: ThiiPropertyItem; const AValue: TValue; var AHandled: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure Refresh; virtual;
    procedure Invalidate;
    procedure ForgetObject(AObject: TObject);
    procedure AddChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent = nil);
    procedure RemoveChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent = nil);
    procedure NotifyItemsChanged;
    function AddProperty(AInstance: Pointer; AProperty: TRttiProperty): ThiiPropertyItem;
    function AddField(AInstance: Pointer; AField: TRttiField): ThiiPropertyItem;
    function AddManualProperty(AInstance: Pointer; const AName: string; const AValue: TValue): ThiiPropertyItem;
    function FindProperty(const AName: string): ThiiPropertyItem; overload;
    function FindProperty(AInstance: Pointer; const AName: string): ThiiPropertyItem; overload;
    function FindProperty(const AName: string; ADeclaringClass: TClass): ThiiPropertyItem; overload;
    function GetValue(AItem: ThiiPropertyItem): TValue;
    procedure SetValue(AItem: ThiiPropertyItem; const AValue: TValue);
    function GetText(AItem: ThiiPropertyItem): string;
    procedure SetText(AItem: ThiiPropertyItem; const AText: string);
    procedure GetComboList(AItem: ThiiPropertyItem; AList: TStrings);
    property DataObject: TObject read FDataObject write SetDataObject;
    property LimitClass: TClass read FLimitClass write SetLimitClass;
    property Items: TObjectList<ThiiPropertyItem> read FItems;
    property PropertyList: TObjectList<ThiiPropertyItem> read FItems;
    property Filters: ThiiPropertyFilters read FFilters;
    property ManualProperties: ThiiManualProperties read FManualProperties;
  published
    property PublishedProperties: Boolean index 0 read FPublishedProperties write SetSelection default True;
    property PublicProperties: Boolean index 1 read FPublicProperties write SetSelection default False;
    property PublicFields: Boolean index 2 read FPublicFields write SetSelection default False;
    property PrivateFields: Boolean index 3 read FPrivateFields write SetSelection default False;
    property ExpandSubProperties: Boolean read FExpandSubProperties write SetExpandSubProperties default False;
    property RootGroupName: string read FRootGroupName write SetRootGroupName;
    property SortOrder: ThiiPropertySortOrder read FSortOrder write SetSortOrder default psoName;
    property ClassMask: string index 0 read FClassMask write SetMask;
    property NameMask: string index 1 read FNameMask write SetMask;
    property TypeMask: string index 2 read FTypeMask write SetMask;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnItemChanged: ThiiPropertyItemChangedEvent read FOnItemChanged write FOnItemChanged;
    property OnGetValue: ThiiGetPropertyValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiSetPropertyValueEvent read FOnSetValue write FOnSetValue;
  end;

  Th5uPropertyGroupRow = class(TPersistent)
  private
    FID: Integer;
    FGroupName: string;
    function GetCaption: string;
    function GetDisplayValue: string;
  published
    property ID: Integer read FID;
    property Caption: string read GetCaption;
    property GroupName: string read FGroupName;
    property DisplayValue: string read GetDisplayValue;
  end;

  ThiiPropertyListController = class(ThiiObjectListController)
  private
    FPropertyEditor: ThiiPropertyModel;
    FGroupRows: TObjectList<TObject>;
    FGroupIDs: TDictionary<string, Integer>;
    FNextGroupID: Integer;
    FShowGroups: Boolean;
    FOnGetValue: ThiiGetPropertyValueEvent;
    FOnSetValue: ThiiSetPropertyValueEvent;
    function PropertyItem(ASourceRowIndex: Int64): ThiiPropertyItem;
    function GetHasGroups: Boolean;
  protected
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Refresh;
    procedure RebuildItems(AShowGroups: Boolean = True; ACollapsedGroups: TDictionary<Integer, Boolean> = nil);
    property HasGroups: Boolean read GetHasGroups;
    property PropertyEditor: ThiiPropertyModel read FPropertyEditor;
  published
    property OnGetValue: ThiiGetPropertyValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiSetPropertyValueEvent read FOnSetValue write FOnSetValue;
  end;

{ Delphi RTL masks: case insensitive *, ?, [a-z]; dots remain literal.
  An empty mask selects everything. }
function h5uMatchesMask(const AText, AMask: string): Boolean;
function h5uRegisterPropertyEditor(ATypeInfo: PTypeInfo; AObjectClass: TClass; const APropertyName: string; AEditorClass: ThiiValueEditorClass): Integer;
procedure h5uUnregisterPropertyEditor(ARegistration: Integer);

{$ENDIF}

implementation

{$IFnDEF FPC}

type
  Th5uEditorRegistration = class
    ID: Integer;
    ValueTypeInfo: PTypeInfo;
    ObjectClass: TClass;
    PropertyName: string;
    EditorClass: ThiiValueEditorClass;
  end;

var
  EditorRegistrations: TObjectList<Th5uEditorRegistration>;
  NextRegistration: Integer;

function h5uMatchesMask(const AText, AMask: string): Boolean;
begin
  Result := (AMask = '') or System.Masks.MatchesMask(AText, AMask);
end;

function ModelClassName(AClass: TClass): string;
begin
  if AClass = nil then
    Exit('');
  Result := AClass.QualifiedClassName;
end;

function ClassMatches(AClass: TClass; const AMask: string): Boolean;
begin
  Result := (AMask = '') or ((AClass <> nil) and (h5uMatchesMask(ModelClassName(AClass), AMask) or h5uMatchesMask(AClass.ClassName, AMask)));
end;

function h5uRegisterPropertyEditor(ATypeInfo: PTypeInfo; AObjectClass: TClass; const APropertyName: string; AEditorClass: ThiiValueEditorClass): Integer;
var
  R: Th5uEditorRegistration;
begin
  if AEditorClass = nil then
    raise EArgumentException.Create('An editor class is required.');
  Inc(NextRegistration);
  R := Th5uEditorRegistration.Create;
  R.ID := NextRegistration;
  R.ValueTypeInfo := ATypeInfo;
  R.ObjectClass := AObjectClass;
  R.PropertyName := APropertyName;
  R.EditorClass := AEditorClass;
  EditorRegistrations.Add(R);
  Result := R.ID;
end;

procedure h5uUnregisterPropertyEditor(ARegistration: Integer);
var
  I: Integer;
begin
  for I := EditorRegistrations.Count - 1 downto 0 do
    if EditorRegistrations[I].ID = ARegistration then
      EditorRegistrations.Delete(I);
end;

{ Model items }

function ThiiPropertyItem.GetValue: TValue;
begin
  Result := FOwner.GetValue(Self);
end;

procedure ThiiPropertyItem.SetValue(const AValue: TValue);
begin
  FOwner.SetValue(Self, AValue);
end;

function ThiiPropertyItem.GetDisplayValue: string;
begin
  { The published presentation is consumed during grid painting. A failing
    application getter must not abort painting the remaining rows. Direct
    GetValue/GetText calls deliberately keep their normal exception contract. }
  if FCacheValid and (FReadError <> '') then
    Exit('<' + FReadError + '>');
  try
    Result := FOwner.GetText(Self);
  except
    on E: Exception do
      Result := '<' + E.Message + '>';
  end;
end;

procedure ThiiPropertyItem.SetDisplayValue(const AValue: string);
begin
  FOwner.SetText(Self, AValue);
end;

function ThiiPropertyItem.GetCanEdit: Boolean;
begin
  Result := (FOwner <> nil) and not FReadOnly and not FHidden and ((FInstance <> nil) or ((FProperty = nil) and (FField = nil)));
end;

function ThiiPropertyItem.GetIsManual: Boolean;
begin
  Result := FIsManual;
end;

procedure ThiiPropertyItem.GetComboList(AList: TStrings);
begin
  FOwner.GetComboList(Self, AList);
end;

{ Definition collections }

procedure ThiiPropertyFilter.SetMask(AIndex: Integer; const AValue: string);
begin
  h5uMatchesMask('', AValue); // Validate before changing a live definition.
  case AIndex of
    0:
      FClassMask := AValue;
    1:
      FNameMask := AValue;
    2:
      FTypeMask := AValue;
  end;
  Changed(False);
end;

procedure ThiiPropertyFilter.SetFlag(AIndex: Integer; AValue: Boolean);
begin
  case AIndex of
    0:
      FReadOnly := AValue;
    1:
      FHidden := AValue;
  end;
  Changed(False);
end;

function ThiiPropertyFilters.Add: ThiiPropertyFilter;
begin
  Result := ThiiPropertyFilter(inherited Add);
end;

procedure ThiiPropertyFilters.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner <> nil then
    ThiiPropertyModel(GetOwner).Reload;
end;

function ThiiManualProperties.Add: ThiiManualProperty;
begin
  Result := ThiiManualProperty(inherited Add);
end;

procedure ThiiManualProperties.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner <> nil then
    ThiiPropertyModel(GetOwner).Reload;
end;

procedure ThiiManualProperty.ClearCachedValues;
begin
  if (Collection <> nil) and (Collection.Owner <> nil) then
    ThiiPropertyModel(Collection.Owner).ForgetDefinition(Self);
end;

procedure ThiiManualProperty.SetTargetClass(AValue: TClass);
begin
  if FTargetClass = AValue then
    Exit;
  ClearCachedValues;
  FTargetClass := AValue;
  Changed(False);
end;

procedure ThiiManualProperty.SetPropertyName(const AValue: string);
begin
  if FPropertyName = AValue then
    Exit;
  ClearCachedValues;
  FPropertyName := AValue;
  Changed(False);
end;

procedure ThiiManualProperty.SetValueTypeInfo(AValue: PTypeInfo);
begin
  if FValueTypeInfo = AValue then
    Exit;
  ClearCachedValues;
  FValueTypeInfo := AValue;
  if (not FDefaultValue.IsEmpty) and (FDefaultValue.TypeInfo <> AValue) then
    FDefaultValue := TValue.Empty;
  Changed(False);
end;

procedure ThiiManualProperty.SetDefaultValue(const AValue: TValue);
begin
  FDefaultValue := AValue;
  if FValueTypeInfo = nil then
    FValueTypeInfo := AValue.TypeInfo;
  if (Collection <> nil) and (Collection.Owner <> nil) then
    ThiiPropertyModel(Collection.Owner).UpdateDefinitionDefault(Self);
  Changed(False);
end;

destructor ThiiManualProperty.Destroy;
begin
  ClearCachedValues;
  inherited;
end;

{ Model lifetime and subscriptions }

constructor ThiiPropertyModel.Create(AOwner: TComponent);
begin
  inherited;
  FContext := TRttiContext.Create;
  FItems := TObjectList<ThiiPropertyItem>.Create(True);
  FManualCache := TObjectList<TManualCacheEntry>.Create(True);
  FListeners := TObjectList<TChangeListener>.Create(True);
  FObservedComponents := TList<TComponent>.Create;
  FFilters := ThiiPropertyFilters.Create(Self, ThiiPropertyFilter);
  FManualProperties := ThiiManualProperties.Create(Self, ThiiManualProperty);
  FPublishedProperties := True;
end;

destructor ThiiPropertyModel.Destroy;
var
  Component: TComponent;
begin
  FDestroying := True;
  NotifyChanging;
  for Component in FObservedComponents do
    Component.RemoveFreeNotification(Self);
  FItems.Free;
  FManualProperties.Free;
  FFilters.Free;
  FManualCache.Free;
  FListeners.Free;
  FObservedComponents.Free;
  FContext.Free;
  inherited;
end;

procedure ThiiPropertyModel.Loaded;
begin
  inherited;
  Reload;
end;

procedure ThiiPropertyModel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and not FDestroying then
    ForgetObject(AComponent);
end;

procedure ThiiPropertyModel.ObserveInstance(AInstance: Pointer);
var
  Component: TComponent;
begin
  if TObject(AInstance) is TComponent then
  begin
    Component := TComponent(AInstance);
    if not FObservedComponents.Contains(Component) then
    begin
      FObservedComponents.Add(Component);
      Component.FreeNotification(Self);
    end;
  end;
end;

procedure ThiiPropertyModel.ForgetObject(AObject: TObject);
var
  I: Integer;
  HasItems: Boolean;
begin
  if AObject = nil then
    Exit;
  if AObject is TComponent then
  begin
    FObservedComponents.Remove(TComponent(AObject));
    TComponent(AObject).RemoveFreeNotification(Self);
  end;
  for I := FManualCache.Count - 1 downto 0 do
    if FManualCache[I].Instance = Pointer(AObject) then
      FManualCache.Delete(I);
  if FDataObject = AObject then
    FDataObject := nil;
  HasItems := False;
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Instance = Pointer(AObject) then
    begin
      HasItems := True;
      Break;
    end;
  if not HasItems then
    Exit;
  NotifyChanging;
  try
    for I := FItems.Count - 1 downto 0 do
      if FItems[I].Instance = Pointer(AObject) then
        FItems.Delete(I);
  finally
    NotifyChanged;
  end;
end;

procedure ThiiPropertyModel.ForgetDefinition(ADefinition: ThiiManualProperty);
var
  I: Integer;
begin
  for I := FManualCache.Count - 1 downto 0 do
    if FManualCache[I].Definition = ADefinition then
      FManualCache.Delete(I);
end;

procedure ThiiPropertyModel.UpdateDefinitionDefault(ADefinition: ThiiManualProperty);
var
  Cache: TManualCacheEntry;
begin
  for Cache in FManualCache do
    if (Cache.Definition = ADefinition) and not Cache.ExplicitValue then
      Cache.Value := SnapshotValue(ADefinition.DefaultValue);
end;

function SameEvent(A, B: TNotifyEvent): Boolean;
begin
  Result := (TMethod(A).Code = TMethod(B).Code) and (TMethod(A).Data = TMethod(B).Data);
end;

function SameItemEvent(A, B: ThiiPropertyItemChangedEvent): Boolean;
begin
  Result := (TMethod(A).Code = TMethod(B).Code) and (TMethod(A).Data = TMethod(B).Data);
end;

procedure ThiiPropertyModel.AddChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent);
var
  L: TChangeListener;
begin
  for L in FListeners do
    if SameEvent(L.Changing, AChanging) and SameEvent(L.Changed, AChanged) and SameItemEvent(L.ItemChanged, AItemChanged) then
      Exit;
  L := TChangeListener.Create;
  L.Changing := AChanging;
  L.Changed := AChanged;
  L.ItemChanged := AItemChanged;
  FListeners.Add(L);
end;

procedure ThiiPropertyModel.RemoveChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent);
var
  I: Integer;
begin
  for I := FListeners.Count - 1 downto 0 do
    if SameEvent(FListeners[I].Changing, AChanging) and SameEvent(FListeners[I].Changed, AChanged)
      and SameItemEvent(FListeners[I].ItemChanged, AItemChanged) then
      FListeners.Delete(I);
end;

procedure ThiiPropertyModel.NotifyChanging;
var
  Snapshot: TArray<TNotifyEvent>;
  L: TChangeListener;
  Callback: TNotifyEvent;
  I: Integer;
begin
  SetLength(Snapshot, FListeners.Count);
  for I := 0 to FListeners.Count - 1 do
    Snapshot[I] := FListeners[I].Changing;
  for Callback in Snapshot do
    if Assigned(Callback) then
      for L in FListeners do
        if SameEvent(L.Changing, Callback) then
        begin
          Callback(Self);
          Break;
        end;
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure ThiiPropertyModel.NotifyChanged;
var
  Snapshot: TArray<TNotifyEvent>;
  L: TChangeListener;
  Callback: TNotifyEvent;
  I: Integer;
begin
  SetLength(Snapshot, FListeners.Count);
  for I := 0 to FListeners.Count - 1 do
    Snapshot[I] := FListeners[I].Changed;
  for Callback in Snapshot do
    if Assigned(Callback) then
      for L in FListeners do
        if SameEvent(L.Changed, Callback) then
        begin
          Callback(Self);
          Break;
        end;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure ThiiPropertyModel.NotifyItemChanged(AItem: ThiiPropertyItem);
var
  Snapshot: TArray<ThiiPropertyItemChangedEvent>;
  L: TChangeListener;
  Callback: ThiiPropertyItemChangedEvent;
  I: Integer;
begin
  SetLength(Snapshot, FListeners.Count);
  for I := 0 to FListeners.Count - 1 do
    Snapshot[I] := FListeners[I].ItemChanged;
  for Callback in Snapshot do
    if Assigned(Callback) and FItems.Contains(AItem) then
      for L in FListeners do
        if SameItemEvent(L.ItemChanged, Callback) then
        begin
          Callback(Self, AItem);
          Break;
        end;
  if Assigned(FOnItemChanged) and FItems.Contains(AItem) then
    FOnItemChanged(Self, AItem);
end;

procedure ThiiPropertyModel.SetDataObject(AValue: TObject);
begin
  if FDataObject = AValue then
    Exit;
  { Previously inspected components stay observed while their manual values
    remain cached. Every appended row also observes its own component. }
  FDataObject := AValue;
  ObserveInstance(Pointer(AValue));
  Reload;
end;

procedure ThiiPropertyModel.SetSelection(AIndex: Integer; AValue: Boolean);
begin

  case AIndex of
    0:
      FPublishedProperties := AValue;
    1:
      FPublicProperties := AValue;
    2:
      FPublicFields := AValue;
    3:
      FPrivateFields := AValue;
  end;
  Reload;
end;

procedure ThiiPropertyModel.SetLimitClass(AValue: TClass);
begin
  FLimitClass := AValue;
  Reload;
end;

procedure ThiiPropertyModel.SetSortOrder(AValue: ThiiPropertySortOrder);
begin

  FSortOrder := AValue;
  Reload;
end;

procedure ThiiPropertyModel.SetMask(AIndex: Integer; const AValue: string);
begin
  h5uMatchesMask('', AValue);
  case AIndex of
    0:
      FClassMask := AValue;
    1:
      FNameMask := AValue;
    2:
      FTypeMask := AValue;
  end;
  Reload;
end;

procedure ThiiPropertyModel.CheckItem(AItem: ThiiPropertyItem);
begin
  if (AItem = nil) or not FItems.Contains(AItem) or (AItem.FOwner <> Self) then
    raise EhiiPropertyError.Create('The property does not belong to this list.');
end;

function ThiiPropertyModel.FindProperty(const AName: string): ThiiPropertyItem;
var
  I: Integer;
begin
  { When private fields hide a base field, the unqualified lookup selects the
    derived declaration. The overload makes either storage slot accessible. }
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if SameText(FItems[I].Path, AName) then
      if (Result = nil) or (Result.DeclaringClass = nil)
        or ((FItems[I].DeclaringClass <> nil) and FItems[I].DeclaringClass.InheritsFrom(Result.DeclaringClass)) then
        Result := FItems[I];
end;

function ThiiPropertyModel.FindProperty(const AName: string; ADeclaringClass: TClass): ThiiPropertyItem;
var
  I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
    if SameText(FItems[I].Name, AName) and (FItems[I].DeclaringClass = ADeclaringClass) then
      Exit(FItems[I]);
  Result := nil;
end;

function ThiiPropertyModel.FindProperty(AInstance: Pointer; const AName: string): ThiiPropertyItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if (FItems[I].Instance = AInstance) and SameText(FItems[I].Name, AName) then
      if (Result = nil) or (Result.DeclaringClass = nil)
        or ((FItems[I].DeclaringClass <> nil) and FItems[I].DeclaringClass.InheritsFrom(Result.DeclaringClass)) then
        Result := FItems[I];
end;

function ThiiPropertyModel.NewItem(AInstance: Pointer; const AName: string; AClass: TClass; ATypeInfo: PTypeInfo): ThiiPropertyItem;
var
  ValueType: TRttiType;
begin
  Result := ThiiPropertyItem.Create;
  Result.FOwner := Self;
  Result.FInstance := AInstance;
  Result.FName := AName;
  Result.FPath := AName;
  Result.FCaption := AName;
  Result.FDeclaringClass := AClass;
  Result.FDeclaringClassName := ModelClassName(AClass);
  Result.FValueTypeInfo := ATypeInfo;
  if ATypeInfo <> nil then
  begin
    ValueType := FContext.GetType(ATypeInfo);
    Result.FTypeName := ValueType.Name;
    if ValueType.IsPublicType then
      Result.FTypeName := ValueType.QualifiedName;
  end;
  Inc(FNextItemID);
  Result.FID := FNextItemID;
  Result.FParentID := -1;
  Result.FIsManual := True;
  FItems.Add(Result);
  ObserveInstance(AInstance);
end;

procedure ThiiPropertyModel.CompleteNewItem(AItem: ThiiPropertyItem);
begin
  ApplyFilters(AItem);
  if not FReloading then
  begin
    UpdateCachedValue(AItem, AItem.FCachedValue, AItem.FReadError);
    NotifyChanged;
  end;
end;

function ThiiPropertyModel.AddProperty(AInstance: Pointer; AProperty: TRttiProperty): ThiiPropertyItem;
begin
  if (AInstance = nil) or (AProperty = nil) or not (AProperty.Parent is TRttiInstanceType) then
    raise EArgumentException.Create('A property and its object instance are required.');
  if not TObject(AInstance).InheritsFrom(TRttiInstanceType(AProperty.Parent).MetaclassType) then
    raise EArgumentException.Create('The property does not belong to this instance class.');
  if not AProperty.IsReadable then
    raise EhiiPropertyError.CreateFmt('Property %s is not readable.', [AProperty.Name]);
  if not FReloading then
    NotifyChanging;
  Result := NewItem(AInstance, AProperty.Name, TRttiInstanceType(AProperty.Parent).MetaclassType, AProperty.PropertyType.Handle);
  Result.FProperty := AProperty;
  Result.FReadOnly := not AProperty.IsWritable;
  CompleteNewItem(Result);
end;

function ThiiPropertyModel.AddField(AInstance: Pointer; AField: TRttiField): ThiiPropertyItem;
begin
  if (AInstance = nil) or (AField = nil) or not (AField.Parent is TRttiInstanceType) then
    raise EArgumentException.Create('A field and its object instance are required.');
  if not TObject(AInstance).InheritsFrom(TRttiInstanceType(AField.Parent).MetaclassType) then
    raise EArgumentException.Create('The field does not belong to this instance class.');
  if not FReloading then
    NotifyChanging;
  Result := NewItem(AInstance, AField.Name, TRttiInstanceType(AField.Parent).MetaclassType, AField.FieldType.Handle);
  Result.FField := AField;
  Result.FReadOnly := not AField.IsWritable;
  CompleteNewItem(Result);
end;

function ThiiPropertyModel.AddManualProperty(AInstance: Pointer; const AName: string; const AValue: TValue): ThiiPropertyItem;
var
  InstanceClass: TClass;
begin
  if AName = '' then
    raise EArgumentException.Create('A property name is required.');
  InstanceClass := nil;
  if AInstance <> nil then
    InstanceClass := TObject(AInstance).ClassType;
  if not FReloading then
    NotifyChanging;
  Result := NewItem(AInstance, AName, InstanceClass, AValue.TypeInfo);
  Result.FCachedValue := SnapshotValue(AValue);
  Result.FCacheValid := True;
  CompleteNewItem(Result);
end;

procedure ThiiPropertyModel.PrepareItems;
var
  Item: ThiiPropertyItem;
  IDs: TDictionary<Integer, Boolean>;
begin
  IDs := TDictionary<Integer, Boolean>.Create;
  try
    for Item in FItems do
    begin
      if Item = nil then
        raise EArgumentException.Create('A property list cannot contain nil items.');
      if (Item.FOwner <> nil) and (Item.FOwner <> Self) then
        raise EhiiPropertyError.Create('A property item already belongs to another list.');
      Item.FOwner := Self;
      if (Item.FID <= 0) or IDs.ContainsKey(Item.FID) then
      begin
        Inc(FNextItemID);
        Item.FID := FNextItemID;
      end;
      IDs.Add(Item.FID, True);
      if Item.FID > FNextItemID then
        FNextItemID := Item.FID;
      ObserveInstance(Item.Instance);
      ApplyFilters(Item);
      if not Item.FCacheValid then
        UpdateCachedValue(Item, Item.FCachedValue, Item.FReadError);
    end;
  finally
    IDs.Free;
  end;
end;

procedure ThiiPropertyModel.NotifyItemsChanged;
begin
  if FDestroying or FReloading then
    Exit;
  NotifyChanging;
  try
    PrepareItems;
  finally
    NotifyChanged;
  end;
end;

procedure ThiiPropertyModel.ApplyFilters(AItem: ThiiPropertyItem);
var
  I: Integer;
  Rule: ThiiPropertyFilter;

  function ObjectClassMatches(const AMask: string): Boolean;
  var
    C: TClass;
  begin
    if AMask = '' then
      Exit(True);
    if AItem.Instance = nil then
      Exit(ClassMatches(AItem.DeclaringClass, AMask));
    C := TObject(AItem.Instance).ClassType;
    while C <> nil do
    begin
      if ClassMatches(C, AMask) then
        Exit(True);
      C := C.ClassParent;
    end;
    Result := False;
  end;

  function TypeMatches(const AMask: string): Boolean;
  begin
    Result := h5uMatchesMask(AItem.TypeName, AMask) or ((AItem.ValueTypeInfo <> nil) and h5uMatchesMask(string(AItem.ValueTypeInfo^.Name), AMask));
  end;

begin
  AItem.FReadOnly := ((AItem.FProperty <> nil) and not AItem.FProperty.IsWritable) or ((AItem.FField <> nil) and not AItem.FField.IsWritable);
  AItem.FHidden := not (ObjectClassMatches(FClassMask) and h5uMatchesMask(AItem.Name, FNameMask) and TypeMatches(FTypeMask));
  for I := 0 to FFilters.Count - 1 do
  begin
    Rule := ThiiPropertyFilter(FFilters.Items[I]);
    if ObjectClassMatches(Rule.ClassMask) and h5uMatchesMask(AItem.Name, Rule.NameMask) and TypeMatches(Rule.TypeMask) then
    begin
      AItem.FHidden := AItem.FHidden or Rule.Hidden;
      AItem.FReadOnly := AItem.FReadOnly or Rule.ReadOnly;
    end;
  end;
end;

procedure ThiiPropertyModel.SortItems;
var
  I, J, C: Integer;
  A, B: ThiiPropertyItem;
begin
  { Stable insertion sort avoids comparator closure/compiler dependencies. }
  for I := 1 to FItems.Count - 1 do
  begin
    J := I;
    while J > 0 do
    begin
      A := FItems[J - 1];
      B := FItems[J];
      if FSortOrder = psoName then
        C := CompareText(A.Name, B.Name)
      else
      begin
        C := A.FClassOrder - B.FClassOrder;
        if C = 0 then
          C := A.FMemberOrder - B.FMemberOrder;
      end;
      if FExpandSubProperties or (FRootGroupName <> '') then
      begin
        if (A.GroupName = FRootGroupName) and (B.GroupName <> FRootGroupName) then C := -1
        else if (B.GroupName = FRootGroupName) and (A.GroupName <> FRootGroupName) then C := 1
        else if A.GroupName <> B.GroupName then C := CompareText(A.GroupName, B.GroupName);
      end;
      if C <= 0 then
        Break;
      FItems.Exchange(J - 1, J);
      Dec(J);
    end;
  end;
end;


procedure ThiiPropertyModel.SetExpandSubProperties(AValue: Boolean);
begin
  if FExpandSubProperties = AValue then
    Exit;
  FExpandSubProperties := AValue;
  Reload;
end;

procedure ThiiPropertyModel.SetRootGroupName(const AValue: string);
begin
  if FRootGroupName = AValue then
    Exit;
  FRootGroupName := AValue;
  Reload;
end;

procedure ThiiPropertyModel.Reload;
var
  Stack: TList<TObject>;

  procedure ReadObject(AObject: TObject; const APath: string; AParentID, ADepth: Integer);
  var
  Hierarchy: TList<TClass>;
  MemberCounts: TArray<Integer>;
  Properties: TArray<TRttiProperty>;
  Fields: TArray<TRttiField>;
  C: TClass;
  I, J: Integer;
  R: TRttiType;
  P: TRttiProperty;
  F: TRttiField;
  Item: ThiiPropertyItem;
  M: ThiiManualProperty;
    LimitClass: TClass;
    FirstItem, LastItem, ChildStart: Integer;
    Child: TObject;
    Value: TValue;
    Group: string;
  begin
    if (AObject = nil) or Stack.Contains(AObject) or (ADepth > 8) then
      Exit;
    Stack.Add(AObject);
    Hierarchy := TList<TClass>.Create;
    try
      FirstItem := FItems.Count;
      LimitClass := nil;
      if ADepth = 0 then LimitClass := FLimitClass;
      C := AObject.ClassType;
      while C <> nil do
      begin
        Hierarchy.Insert(0, C);
        if C = LimitClass then
          Break;
        C := C.ClassParent;
      end;
      if (LimitClass <> nil) and not AObject.InheritsFrom(LimitClass) then
        Hierarchy.Clear;
      SetLength(MemberCounts, Hierarchy.Count);
      R := FContext.GetType(AObject.ClassType);
      if FSortOrder = psoDeclaration then
      begin
        Fields := R.GetFieldsInDeclOrder;
        Properties := R.GetPropertiesInDeclOrder;
      end
      else
      begin
        Fields := R.GetFields;
        Properties := R.GetProperties;
      end;
      { The RTL supplies declaration order separately for fields and properties.
        Group by declaring class, with fields before properties in each group. }
      for F in Fields do
      begin
        C := TRttiInstanceType(F.Parent).MetaclassType;
        I := Hierarchy.IndexOf(C);
        if (I < 0) or not (((F.Visibility = mvPublic) and FPublicFields) or ((F.Visibility = mvPrivate) and FPrivateFields)) then
          Continue;
        Item := AddField(Pointer(AObject), F);
        Item.FIsManual := False;
        Item.FClassOrder := I;
        Item.FMemberOrder := MemberCounts[I];
        Inc(MemberCounts[I]);
      end;
      for P in Properties do
      begin
        C := TRttiInstanceType(P.Parent).MetaclassType;
        I := Hierarchy.IndexOf(C);
        if (I < 0) or not P.IsReadable
          or not (((P.Visibility = mvPublished) and FPublishedProperties) or ((P.Visibility = mvPublic) and FPublicProperties)) then
          Continue;
        if (R.GetProperty(P.Name) <> P) or P.HasAttribute<ThiiLegacyOptionAttribute> then
          Continue;
        Item := AddProperty(Pointer(AObject), P);
        Item.FIsManual := False;
        Item.FClassOrder := I;
        Item.FMemberOrder := MemberCounts[I];
        Inc(MemberCounts[I]);
      end;
      for I := 0 to Hierarchy.Count - 1 do
      begin
        C := Hierarchy[I];
        for J := 0 to FManualProperties.Count - 1 do
        begin
          M := ThiiManualProperty(FManualProperties.Items[J]);
          if (M.PropertyName = '') or not ((M.TargetClass = C) or ((M.TargetClass = nil) and (ADepth = 0) and (I = Hierarchy.Count - 1))) then
            Continue;
          Item := FindProperty(Pointer(AObject), M.PropertyName);
          if Item = nil then
          begin
            Item := NewItem(Pointer(AObject), M.PropertyName, C, M.ValueTypeInfo);
            Item.FCachedValue := M.DefaultValue;
            Item.FClassOrder := I;
            Item.FMemberOrder := MemberCounts[I];
            Inc(MemberCounts[I]);
          end;
          Item.FIsManual := True;
          Item.FManual := M;
          Item.FCacheValid := False;
        end;
      end;

      LastItem := FItems.Count - 1;
      Group := APath;
      if ADepth = 0 then Group := FRootGroupName;
      for I := FirstItem to LastItem do
      begin
        Item := FItems[I];
        Item.FGroupName := Group;
        Item.FParentID := AParentID;
        if APath <> '' then Item.FPath := APath + '.' + Item.Name;
      end;
      if FExpandSubProperties then
        for I := FirstItem to LastItem do
        begin
          Item := FItems[I];
          if Item.Hidden or (Item.ValueTypeInfo = nil) or (Item.ValueTypeInfo.Kind <> tkClass) then Continue;
          try
            Value := ReadMember(Item);
          except
            // An unreadable getter remains a regular property with its read error.
            Continue;
          end;
          if Value.IsEmpty then Continue;
          Child := Value.AsObject;
          // References and collections keep their own lifetime/editing semantics.
          if not (Child is TPersistent) or (Child is TComponent) or (Child is TCollection) then Continue;
          ChildStart := FItems.Count;
          ReadObject(Child, Item.Path, Item.ID, ADepth + 1);
          Item.FObjectGroup := FItems.Count > ChildStart;
        end;
    finally
      Hierarchy.Free;
      Stack.Delete(Stack.Count - 1);
    end;
  end;

begin
  if FDestroying or FReloading or (csLoading in ComponentState) then
    Exit;
  FReloading := True;
  Stack := TList<TObject>.Create;
  try
    NotifyChanging;
    FItems.Clear;
    ReadObject(FDataObject, '', -1, 0);
    SortItems;
    DoLoaded;
    PrepareItems;
  finally
    Stack.Free;
    FReloading := False;
    NotifyChanged;
  end;
end;

procedure ThiiPropertyModel.DoLoaded;
begin
  if Assigned(FOnLoaded) then
    FOnLoaded(Self);
end;

procedure ThiiPropertyModel.DoGetValue(AItem: ThiiPropertyItem; var AValue: TValue; var AHandled: Boolean);
begin
  if Assigned(FOnGetValue) then
    FOnGetValue(Self, AItem, AValue, AHandled);
end;

procedure ThiiPropertyModel.DoSetValue(AItem: ThiiPropertyItem; const AValue: TValue; var AHandled: Boolean);
begin
  if Assigned(FOnSetValue) then
    FOnSetValue(Self, AItem, AValue, AHandled);
end;

function ThiiPropertyModel.ManualCache(AItem: ThiiPropertyItem; ACreate: Boolean): TManualCacheEntry;
var
  C: TManualCacheEntry;
begin
  for C in FManualCache do
    if (C.Instance = AItem.Instance) and (C.Definition = AItem.FManual) then
      Exit(C);
  Result := nil;
  if not ACreate or (AItem.FManual = nil) then
    Exit;
  Result := TManualCacheEntry.Create;
  Result.Instance := AItem.Instance;
  Result.Definition := AItem.FManual;
  Result.Value := SnapshotValue(AItem.FManual.DefaultValue);
  FManualCache.Add(Result);
end;

function ThiiPropertyModel.ReadMember(AItem: ThiiPropertyItem): TValue;
begin
  if AItem.FProperty <> nil then
    Exit(AItem.FProperty.GetValue(AItem.Instance));
  if AItem.FField <> nil then
    Exit(AItem.FField.GetValue(AItem.Instance));
  if AItem.FManual <> nil then
    Exit(ManualCache(AItem, True).Value);
  Result := AItem.FCachedValue;
end;

procedure ThiiPropertyModel.WriteMember(AItem: ThiiPropertyItem; const AValue: TValue);
var
  Cache: TManualCacheEntry;
begin
  if AItem.FProperty <> nil then
    AItem.FProperty.SetValue(AItem.Instance, AValue)
  else if AItem.FField <> nil then
    AItem.FField.SetValue(AItem.Instance, AValue)
  else
  begin
    AItem.FCachedValue := SnapshotValue(AValue);
    if AItem.FManual <> nil then
    begin
      Cache := ManualCache(AItem, True);
      Cache.Value := AItem.FCachedValue;
      Cache.ExplicitValue := True;
    end;
  end;
end;

function SameVariantValue(const A, B: Variant): Boolean;
var
  Dimensions, Dimension: Integer;
  Indices: TArray<Integer>;

  function CompareDimension(ADimension: Integer): Boolean;
  var
    I: Integer;
  begin
    for I := VarArrayLowBound(A, ADimension) to VarArrayHighBound(A, ADimension) do
    begin
      Indices[ADimension - 1] := I;
      if ADimension < Dimensions then
      begin
        if not CompareDimension(ADimension + 1) then
          Exit(False);
      end
      else if not SameVariantValue(VarArrayGet(A, Indices), VarArrayGet(B, Indices)) then
        Exit(False);
    end;
    Result := True;
  end;

begin
  if VarType(A) <> VarType(B) then
    Exit(False);
  if not VarIsArray(A) then
    Exit(VarSameValue(A, B));
  Dimensions := VarArrayDimCount(A);
  if Dimensions <> VarArrayDimCount(B) then
    Exit(False);
  for Dimension := 1 to Dimensions do
    if (VarArrayLowBound(A, Dimension) <> VarArrayLowBound(B, Dimension)) or (VarArrayHighBound(A, Dimension) <> VarArrayHighBound(B, Dimension)) then
      Exit(False);
  SetLength(Indices, Dimensions);
  Result := CompareDimension(1);
end;

function ThiiPropertyModel.ValuesEqual(const A, B: TValue): Boolean;
var
  I, J: Integer;
  RecordType: TRttiRecordType;
  Fields: TArray<TRttiField>;
  Field: TRttiField;
  ManagedField: TRttiManagedField;
  CoveredBytes: TArray<Boolean>;
  AField, BField: TValue;
begin
  if A.TypeInfo <> B.TypeInfo then
    Exit(False);
  if A.IsEmpty or B.IsEmpty then
    Exit(A.IsEmpty and B.IsEmpty);
  case A.Kind of
    tkString, tkLString, tkWString, tkUString:
      Result := A.AsString = B.AsString;
    tkVariant:
      begin
        try
          Result := SameVariantValue(A.AsVariant, B.AsVariant);
        except
          on E: EVariantError do
            Result := False;
        end;
      end;
    tkArray, tkDynArray:
      begin
        if A.GetArrayLength <> B.GetArrayLength then
          Exit(False);
        for I := 0 to A.GetArrayLength - 1 do
          if not ValuesEqual(A.GetArrayElement(I), B.GetArrayElement(I)) then
            Exit(False);
        Result := True;
      end;
    tkRecord, tkMRecord:
      begin
        RecordType := TRttiRecordType(FContext.GetType(A.TypeInfo));
        Fields := RecordType.GetFields;
        SetLength(CoveredBytes, A.DataSize);
        for Field in Fields do
        begin
          AField := Field.GetValue(A.GetReferenceToRawData);
          BField := Field.GetValue(B.GetReferenceToRawData);
          if not ValuesEqual(AField, BField) then
            Exit(False);
          for J := Field.Offset to Field.Offset + AField.DataSize - 1 do
            CoveredBytes[J] := True;
        end;
        { Field RTTI can cover only part of a record. Include hidden managed
          members, then compare remaining storage conservatively. }
        for ManagedField in RecordType.ManagedFields do
        begin
          if CoveredBytes[ManagedField.FieldOffset] then
            Continue;
          TValue.Make(PByte(A.GetReferenceToRawData) + ManagedField.FieldOffset, ManagedField.FieldType.Handle, AField);
          TValue.Make(PByte(B.GetReferenceToRawData) + ManagedField.FieldOffset, ManagedField.FieldType.Handle, BField);
          if not ValuesEqual(AField, BField) then
            Exit(False);
          for J := ManagedField.FieldOffset to ManagedField.FieldOffset + AField.DataSize - 1 do
            CoveredBytes[J] := True;
        end;
        for I := 0 to A.DataSize - 1 do
          if not CoveredBytes[I] and (PByte(A.GetReferenceToRawData)[I] <> PByte(B.GetReferenceToRawData)[I]) then
            Exit(False);
        Result := True;
      end;
    else
      Result := (A.DataSize = B.DataSize) and CompareMem(A.GetReferenceToRawData, B.GetReferenceToRawData, A.DataSize);
  end;
end;

function ThiiPropertyModel.SnapshotValue(const AValue: TValue): TValue;
var
  Values: TArray<TValue>;
  I: Integer;
  RecordType: TRttiRecordType;
  Field: TRttiManagedField;
  FieldValue: TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkArray, tkDynArray:
      begin
        SetLength(Values, AValue.GetArrayLength);
        for I := 0 to High(Values) do
          Values[I] := SnapshotValue(AValue.GetArrayElement(I));
        Result := TValue.FromArray(AValue.TypeInfo, Values);
      end;
    tkRecord, tkMRecord:
      begin
        TValue.Make(AValue.GetReferenceToRawData, AValue.TypeInfo, Result);
        RecordType := TRttiRecordType(FContext.GetType(AValue.TypeInfo));
        for Field in RecordType.ManagedFields do
        begin
          TValue.Make(PByte(AValue.GetReferenceToRawData) + Field.FieldOffset, Field.FieldType.Handle, FieldValue);
          FieldValue := SnapshotValue(FieldValue);
          FieldValue.ExtractRawData(PByte(Result.GetReferenceToRawData) + Field.FieldOffset);
        end;
      end;
    tkVariant:
      Result := TValue.From<Variant>(AValue.AsVariant);
  end;
end;

function ThiiPropertyModel.UpdateCachedValue(AItem: ThiiPropertyItem; const APreviousValue: TValue; const APreviousError: string): Boolean;
var
  PreviousValue, NewValue: TValue;
  PreviousError, NewError: string;
  Handled: Boolean;
  Cache: TManualCacheEntry;
begin
  { Parameters can refer to fields of AItem, so preserve them before assignment. }
  PreviousValue := APreviousValue;
  PreviousError := APreviousError;
  NewValue := AItem.FCachedValue;
  NewError := '';
  Handled := False;
  try
    DoGetValue(AItem, NewValue, Handled);
    if not Handled then
      NewValue := ReadMember(AItem);
    NewValue := SnapshotValue(NewValue);
  except
    on E: Exception do
      NewError := E.Message;
  end;
  Result := (PreviousError <> NewError) or ((NewError = '') and not ValuesEqual(PreviousValue, NewValue));
  if NewError = '' then
  begin
    AItem.FCachedValue := NewValue;
    if (AItem.FManual <> nil) and (AItem.FProperty = nil) and (AItem.FField = nil) then
    begin
      Cache := ManualCache(AItem, True);
      Cache.Value := AItem.FCachedValue;
      Cache.ExplicitValue := Cache.ExplicitValue or Handled;
    end;
  end;
  AItem.FReadError := NewError;
  AItem.FCacheValid := True;
end;

function ThiiPropertyModel.GetValue(AItem: ThiiPropertyItem): TValue;
begin
  CheckItem(AItem);
  if not AItem.FCacheValid then
    UpdateCachedValue(AItem, AItem.FCachedValue, AItem.FReadError);
  if AItem.FReadError <> '' then
    raise EhiiPropertyError.Create(AItem.FReadError);
  Result := AItem.FCachedValue;
end;

procedure ThiiPropertyModel.SetValue(AItem: ThiiPropertyItem; const AValue: TValue);
var
  Handled: Boolean;
  PreviousUpdateItem: ThiiPropertyItem;
  PreviousUpdateValue: TValue;
  PreviousUpdateError: string;
begin
  CheckItem(AItem);
  if not AItem.CanEdit then
    raise EhiiPropertyError.CreateFmt('Property %s is read-only or hidden.', [AItem.Name]);
  PreviousUpdateItem := FValueUpdateItem;
  PreviousUpdateValue := FValueBeforeUpdate;
  PreviousUpdateError := FReadErrorBeforeUpdate;
  FValueUpdateItem := AItem;
  FValueBeforeUpdate := AItem.FCachedValue;
  FReadErrorBeforeUpdate := AItem.FReadError;
  try
    try
      Handled := False;
      DoSetValue(AItem, AValue, Handled);
      if not Handled then
        WriteMember(AItem, AValue)
      else if (AItem.FProperty = nil) and (AItem.FField = nil) then
        WriteMember(AItem, AValue);
    finally
      { Refresh is virtual so the grid controller can batch all row notices. }
      Refresh;
    end;
  finally
    FValueUpdateItem := PreviousUpdateItem;
    FValueBeforeUpdate := PreviousUpdateValue;
    FReadErrorBeforeUpdate := PreviousUpdateError;
  end;
end;

procedure ThiiPropertyModel.Invalidate;
var
  Item: ThiiPropertyItem;
begin
  for Item in FItems do
    Item.FCacheValid := False;
end;

procedure ThiiPropertyModel.Refresh;
var
  Snapshot: TArray<ThiiPropertyItem>;
  Item: ThiiPropertyItem;
  ItemChanged, AnyChanged: Boolean;
  Value: TValue;
begin
  // Check object references before accessing child items from a previous reload.
  if FExpandSubProperties then
    for Item in FItems do
      if (Item.ValueTypeInfo <> nil) and (Item.ValueTypeInfo.Kind = tkClass) then
      begin
        try
          Value := ReadMember(Item);
        except
          Reload;
          Exit;
        end;
        if not ValuesEqual(Value, Item.FCachedValue)
          and (Item.ObjectGroup
          or (not Value.IsEmpty and (Value.AsObject is TPersistent) and not (Value.AsObject is TComponent)
          and not (Value.AsObject is TCollection))) then
        begin
          Reload;
          Exit;
        end;
      end;
  AnyChanged := False;
  Snapshot := FItems.ToArray;
  for Item in Snapshot do
  begin
    if not FItems.Contains(Item) then
      Continue;
    if Item = FValueUpdateItem then
      ItemChanged := UpdateCachedValue(Item, FValueBeforeUpdate, FReadErrorBeforeUpdate)
    else
      ItemChanged := UpdateCachedValue(Item, Item.FCachedValue, Item.FReadError);
    if ItemChanged then
    begin
      AnyChanged := True;
      NotifyItemChanged(Item);
    end;
  end;
  if AnyChanged and Assigned(FOnChange) then
    FOnChange(Self);
end;

function ThiiPropertyModel.CreateValueEditor(AItem: ThiiPropertyItem): ThiiValueEditor;
var
  R: Th5uEditorRegistration;
  Best: ThiiValueEditorClass;
  C: TClass;
  Distance, NameScore, TypeScore, BestName, BestDistance, BestType: Integer;
begin
  Best := ThiiValueEditor;
  BestName := -1;
  BestDistance := MaxInt;
  BestType := -1;
  for R in EditorRegistrations do
  begin
    if (R.ValueTypeInfo <> nil) and (R.ValueTypeInfo <> AItem.ValueTypeInfo) then
      Continue;
    if (R.PropertyName <> '') and not SameText(R.PropertyName, AItem.Name) then
      Continue;
    if (R.ObjectClass <> nil) and ((AItem.Instance = nil) or not TObject(AItem.Instance).InheritsFrom(R.ObjectClass)) then
      Continue;
    NameScore := Ord(R.PropertyName <> '');
    TypeScore := Ord(R.ValueTypeInfo <> nil);
    Distance := MaxInt;
    if R.ObjectClass <> nil then
    begin
      C := TObject(AItem.Instance).ClassType;
      Distance := 0;
      while C <> R.ObjectClass do
      begin
        Inc(Distance);
        C := C.ClassParent;
      end;
    end;
    if (NameScore > BestName)
      or ((NameScore = BestName) and ((Distance < BestDistance) or ((Distance = BestDistance) and (TypeScore >= BestType)))) then
    begin
      Best := R.EditorClass;
      BestName := NameScore;
      BestDistance := Distance;
      BestType := TypeScore;
    end;
  end;
  Result := Best.Create(AItem);
end;

function ThiiPropertyModel.GetText(AItem: ThiiPropertyItem): string;
var
  E: ThiiValueEditor;
begin
  CheckItem(AItem);
  E := CreateValueEditor(AItem);
  try
    Result := E.GetValue;
  finally
    E.Free;
  end;
end;

procedure ThiiPropertyModel.SetText(AItem: ThiiPropertyItem; const AText: string);
var
  E: ThiiValueEditor;
begin
  CheckItem(AItem);
  if not AItem.CanEdit then
    raise EhiiPropertyError.CreateFmt('Property %s is read-only or hidden.', [AItem.Name]);
  E := CreateValueEditor(AItem);
  try
    E.SetValue(AText);
  finally
    E.Free;
  end;
end;

procedure ThiiPropertyModel.GetComboList(AItem: ThiiPropertyItem; AList: TStrings);
var
  E: ThiiValueEditor;
begin
  CheckItem(AItem);
  if AList = nil then
    raise EArgumentException.Create('A combo list is required.');
  AList.Clear;
  E := CreateValueEditor(AItem);
  try
    E.GetComboList(AList);
  finally
    E.Free;
  end;
end;

{ Default value editor }

constructor ThiiValueEditor.Create(AItem: ThiiPropertyItem);
begin
  inherited Create;
  FItem := AItem;
end;

function ThiiValueEditor.GetValue: string;
var
  V: TValue;
  M: TMethod;
  O: TObject;
begin
  V := Item.Value;
  if V.IsEmpty then
    Exit('');
  case V.Kind of
    tkEnumeration:
      Result := GetEnumName(V.TypeInfo, V.AsOrdinal);
    tkSet:
      Result := SetToString(V.TypeInfo, V.GetReferenceToRawData, True);
    tkMethod:
      begin
        V.ExtractRawData(@M);
        if M.Code = nil then
          Result := ''
        else if M.Data <> nil then
        begin
          Result := TObject(M.Data).MethodName(M.Code);
          if Result = '' then
            Result := '(assigned)';
        end
        else
          Result := '(assigned)';
      end;
    tkClass:
      begin
        O := V.AsObject;
        if O = nil then
          Result := '(nil)'
        else if O is TComponent then
          Result := TComponent(O).Name
        else
          Result := '(' + O.ClassName + ')';
      end;
    tkVariant:
      Result := VarToStr(V.AsVariant);
    else
      Result := V.ToString;
  end;
end;

procedure ThiiValueEditor.SetValue(const AText: string);
var
  TI, EnumTI: PTypeInfo;
  D: PTypeData;
  V: TValue;
  I: Int64;
  U: UInt64;
  E: Extended;
  S: Single;
  DB: Double;
  CY: Currency;
  M: TMethod;
  O: TObject;
  A: AnsiString;
  W: WideString;
  US: UnicodeString;
  SS: ShortString;
  CH: AnsiChar;
  WC: WideChar;
  VariantValue, CurrentVariant: Variant;
  Bits: array[0..31] of Byte;
  Tokens: TStringList;
  N, Bit, BitOffset: Integer;
  Text: string;
begin
  TI := Item.ValueTypeInfo;
  if TI = nil then
  begin
    Item.Value := TValue.From<string>(AText);
    Exit;
  end;
  D := GetTypeData(TI);
  case TI^.Kind of
    tkInteger, tkEnumeration:
      begin
        if TI^.Kind = tkInteger then
          I := StrToInt64(Trim(AText))
        else
        begin
          I := GetEnumValue(TI, Trim(AText));
          if I < 0 then
            raise EConvertError.CreateFmt('Unknown %s value: %s', [string(TI^.Name), AText]);
        end;
        if (D^.OrdType = otULong) then
        begin
          if (I < 0) or (UInt64(I) > UInt64(High(Cardinal))) then
            raise ERangeError.Create('Integer out of range.');
        end
        else if (I < D^.MinValue) or (I > D^.MaxValue) then
          raise ERangeError.Create('Ordinal value out of range.');
        V := TValue.FromOrdinal(TI, I);
      end;
    tkInt64:
      begin

        if D^.MinInt64Value = 0 then
        begin
          U := StrToUInt64(Trim(AText));
          TValue.Make(@U, TI, V);
        end
        else
        begin
          I := StrToInt64(Trim(AText));
          TValue.Make(@I, TI, V);
        end;
      end;

    tkFloat:
      begin
        E := StrToFloat(Trim(AText));
        case D^.FloatType of
          ftSingle:
            begin
              S := E;
              TValue.Make(@S, TI, V);
            end;
          ftDouble:
            begin
              DB := E;
              TValue.Make(@DB, TI, V);
            end;
          ftExtended:
            TValue.Make(@E, TI, V);
          ftCurr:
            begin
              CY := E;
              TValue.Make(@CY, TI, V);
            end;
          else
            raise EhiiPropertyError.Create('This floating-point storage requires a registered editor.');
        end;
      end;
    tkChar:
      begin
        if Length(AText) <> 1 then
          raise EConvertError.Create('Enter one character.');
        CH := AnsiChar(AText[1]);
        TValue.Make(@CH, TI, V);
      end;
    tkWChar:
      begin

        US := AText;

        if Length(US) <> 1 then
          raise EConvertError.Create('Enter one character.');
        WC := US[1];
        TValue.Make(@WC, TI, V);
      end;
    tkString:
      begin
        if Length(AText) > D^.MaxLength then
          raise EConvertError.Create('String exceeds its declared length.');
        SS := ShortString(AText);
        TValue.Make(@SS, TI, V);
      end;
    tkLString:
      begin
        A := AnsiString(AText);
        TValue.Make(@A, TI, V);
      end;
    tkWString:
      begin

        W := AText;

        TValue.Make(@W, TI, V);
      end;
    tkUString:
      begin

        US := AText;

        TValue.Make(@US, TI, V);
      end;
    tkSet:
      begin
        if D^.CompType = nil then
          raise EhiiPropertyError.Create('Set element RTTI is unavailable; use a named element type or register an editor.');
        EnumTI := D^.CompType^;
        if EnumTI = nil then
          raise EhiiPropertyError.Create('Set element RTTI is unavailable; use a named element type or register an editor.');
        BitOffset := GetTypeData(EnumTI)^.MinValue and (not 7);
        FillChar(Bits, SizeOf(Bits), 0);
        Text := Trim(AText);
        if (Length(Text) >= 2) and (Text[1] = '[') and (Text[Length(Text)] = ']') then
          Text := Copy(Text, 2, Length(Text) - 2);
        Tokens := TStringList.Create;
        try
          Tokens.StrictDelimiter := True;
          Tokens.Delimiter := ',';
          Tokens.DelimitedText := Text;
          for N := 0 to Tokens.Count - 1 do
          begin
            Bit := GetEnumValue(EnumTI, Trim(Tokens[N]));
            if (Bit < GetTypeData(EnumTI)^.MinValue) or (Bit > GetTypeData(EnumTI)^.MaxValue) or (Bit < 0) or (Bit > 255) then
              raise EConvertError.CreateFmt('Unknown set element: %s', [Tokens[N]]);
            Dec(Bit, BitOffset);
            Bits[Bit div 8] := Bits[Bit div 8] or (1 shl (Bit mod 8));
          end;
          TValue.Make(@Bits, TI, V);
        finally
          Tokens.Free;
        end;
      end;
    tkMethod:
      begin
        if Trim(AText) <> '' then
          raise EhiiPropertyError.Create('Assign event handlers through a registered editor or OnSetValue using a typed TValue.');
        FillChar(M, SizeOf(M), 0);
        TValue.Make(@M, TI, V);
      end;
    tkClass:
      begin
        if (Trim(AText) <> '') and not SameText(Trim(AText), '(nil)') and not SameText(Trim(AText), 'nil') then
          raise EhiiPropertyError.Create('Assign object references through a registered editor.');
        O := nil;
        TValue.Make(@O, TI, V);
      end;
    tkVariant:
      begin
        CurrentVariant := Item.Value.AsVariant;
        VariantValue := AText;
        if not VarIsEmpty(CurrentVariant) and not VarIsNull(CurrentVariant) and not VarIsStr(CurrentVariant) then
          VariantValue := VarAsType(VariantValue, VarType(CurrentVariant));
        V := TValue.From<Variant>(VariantValue);
      end;
    else
      raise EhiiPropertyError.CreateFmt('Type %s requires a registered property editor.', [string(TI^.Name)]);
  end;
  Item.Value := V;
end;

procedure ThiiValueEditor.GetComboList(AList: TStrings);
var
  D: PTypeData;
  I: Integer;
begin
  if (Item.ValueTypeInfo = nil) or not (Item.ValueTypeInfo^.Kind in [tkEnumeration]) then
    Exit;
  D := GetTypeData(Item.ValueTypeInfo);
  for I := D^.MinValue to D^.MaxValue do
    AList.Add(GetEnumName(Item.ValueTypeInfo, I));
end;

function ThiiWidthValueEditor.GetValue: string;
begin
  Result := h5uWidthToText(Item.Value.AsExtended);
end;

procedure ThiiWidthValueEditor.SetValue(const AText: string);
var
  Width: ThiiWidth;
begin
  if not h5uTryTextToWidth(AText, Width) then
    raise EhiiPropertyError.Create('Breite als Zahl, Prozentangabe oder Default erwartet.');
  Item.Value := TValue.From<ThiiWidth>(Width);
end;

procedure ThiiWidthValueEditor.GetComboList(AList: TStrings);
begin
  AList.Add('Default');
end;

type
  Th5uControllerPropertyEditor = class(ThiiPropertyModel)
  private
    FController: ThiiPropertyListController;
  protected
    procedure DoGetValue(AItem: ThiiPropertyItem; var AValue: TValue; var AHandled: Boolean); override;
    procedure DoSetValue(AItem: ThiiPropertyItem; const AValue: TValue; var AHandled: Boolean); override;
  public
    procedure Refresh; override;
  end;

function Th5uPropertyGroupRow.GetCaption: string;
begin
  // Leave room for the grid's fold glyph when the row indicator is hidden.
  Result := '     ' + StringOfChar(' ', 2 * (Length(FGroupName) - Length(FGroupName.Replace('.', ''))))
    + Copy(FGroupName, LastDelimiter('.', FGroupName) + 1, MaxInt);
end;

function Th5uPropertyGroupRow.GetDisplayValue: string;
begin
  Result := '';
end;

procedure Th5uControllerPropertyEditor.DoGetValue(AItem: ThiiPropertyItem; var AValue: TValue; var AHandled: Boolean);
begin
  inherited;
  if not AHandled and Assigned(FController.FOnGetValue) then
    FController.FOnGetValue(FController, AItem, AValue, AHandled);
end;

procedure Th5uControllerPropertyEditor.DoSetValue(AItem: ThiiPropertyItem; const AValue: TValue; var AHandled: Boolean);
begin
  inherited;
  if not AHandled and Assigned(FController.FOnSetValue) then
    FController.FOnSetValue(FController, AItem, AValue, AHandled);
end;

procedure Th5uControllerPropertyEditor.Refresh;
begin
  FController.BeginUpdate;
  try
    inherited;
  finally
    FController.EndUpdate;
  end;
end;

constructor ThiiPropertyListController.Create(AOwner: TComponent);
begin
  inherited;
  KeyPropertyName := 'ID';
  OwnsObjects := False;
  FGroupRows := TObjectList<TObject>.Create(True);
  FGroupIDs := TDictionary<string, Integer>.Create;
  FPropertyEditor := Th5uControllerPropertyEditor.Create(Self);
  Th5uControllerPropertyEditor(FPropertyEditor).FController := Self;
  FPropertyEditor.SetSubComponent(True);
end;

destructor ThiiPropertyListController.Destroy;
begin
  Clear;
  FreeAndNil(FGroupRows);
  FreeAndNil(FGroupIDs);
  FreeAndNil(FPropertyEditor);
  inherited;
end;

function ThiiPropertyListController.GetHasGroups: Boolean;
begin
  Result := FGroupRows.Count > 0;
end;

procedure ThiiPropertyListController.RebuildItems(AShowGroups: Boolean; ACollapsedGroups: TDictionary<Integer, Boolean>);
var
  LItem: ThiiPropertyItem;
  LHeader: Th5uPropertyGroupRow;
  LPreviousGroup, LKey: string;
  LOccurrences: TDictionary<string, Integer>;
  LOccurrence, LID: Integer;

  function ParentCollapsed(const AGroup: string): Boolean;
  var
    Parent: string;
    ID, Dot: Integer;
    Collapsed: Boolean;
  begin
    Result := False;
    if not AShowGroups or (ACollapsedGroups = nil) then
      Exit;
    Parent := AGroup;
    Dot := LastDelimiter('.', Parent);
    while Dot > 0 do
    begin
      Parent := Copy(Parent, 1, Dot - 1);
      if FGroupIDs.TryGetValue(Parent + #0 + '1', ID) and ACollapsedGroups.TryGetValue(ID, Collapsed) and Collapsed then
        Exit(True);
      Dot := LastDelimiter('.', Parent);
    end;
  end;

begin
  FShowGroups := AShowGroups;
  LOccurrences := TDictionary<string, Integer>.Create;
  BeginUpdate;
  try
    Clear;
    FGroupRows.Clear;
    LPreviousGroup := '';
    for LItem in FPropertyEditor.Items do
    begin
      if LItem.Hidden or LItem.ObjectGroup or ParentCollapsed(LItem.GroupName) then
        Continue;
      if AShowGroups and (LItem.GroupName <> '') and (LItem.GroupName <> LPreviousGroup) then
      begin
        if not LOccurrences.TryGetValue(LItem.GroupName, LOccurrence) then
          LOccurrence := 0;
        Inc(LOccurrence);
        LOccurrences.AddOrSetValue(LItem.GroupName, LOccurrence);
        LKey := LItem.GroupName + #0 + IntToStr(LOccurrence);
        if not FGroupIDs.TryGetValue(LKey, LID) then
        begin
          Dec(FNextGroupID);
          LID := FNextGroupID;
          FGroupIDs.Add(LKey, LID);
        end;
        LHeader := Th5uPropertyGroupRow.Create;
        LHeader.FID := LID;
        LHeader.FGroupName := LItem.GroupName;
        FGroupRows.Add(LHeader);
        Add(LHeader);
      end;
      Add(LItem);
      LPreviousGroup := LItem.GroupName;
    end;
  finally
    EndUpdate;
    LOccurrences.Free;
  end;
end;

function ThiiPropertyListController.PropertyItem(ASourceRowIndex: Int64): ThiiPropertyItem;
begin
  Result := nil;
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < Count) and (Item(ASourceRowIndex) is ThiiPropertyItem) then
    Result := ThiiPropertyItem(Item(ASourceRowIndex));
end;

function ThiiPropertyListController.GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue;
var
  LItem: ThiiPropertyItem;
begin
  LItem := PropertyItem(ASourceRowIndex);
  if LItem <> nil then
  begin
    if not FShowGroups and SameText(AFieldName, 'Caption') and FPropertyEditor.ExpandSubProperties then
      Exit(TValue.From<string>(LItem.Path));
    if SameText(AFieldName, 'Value') then
      Exit(LItem.Value);
    if SameText(AFieldName, 'DisplayValue') then
      Exit(TValue.From<string>(LItem.DisplayValue));
  end;
  Result := inherited;
end;

procedure ThiiPropertyListController.SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LItem: ThiiPropertyItem;
begin
  LItem := PropertyItem(ASourceRowIndex);
  if LItem <> nil then
  begin
    if SameText(AFieldName, 'Value') then
    begin
      LItem.Value := AValue;
      Exit;
    end;
    if SameText(AFieldName, 'DisplayValue') then
    begin
      LItem.DisplayValue := AValue.AsString;
      Exit;
    end;
  end;
  inherited;
end;

function ThiiPropertyListController.GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean;
var
  LItem: ThiiPropertyItem;
begin
  LItem := PropertyItem(ASourceRowIndex);
  if (LItem <> nil) and (SameText(AFieldName, 'Value') or SameText(AFieldName, 'DisplayValue')) then
    Result := LItem.CanEdit
  else
    Result := inherited;
end;

procedure ThiiPropertyListController.Refresh;
begin
  FPropertyEditor.Refresh;
end;


initialization
  EditorRegistrations := TObjectList<Th5uEditorRegistration>.Create(True);
  h5uRegisterPropertyEditor(TypeInfo(ThiiWidth), nil, '', ThiiWidthValueEditor);

finalization
  EditorRegistrations.Free;

{$ENDIF}

end.

