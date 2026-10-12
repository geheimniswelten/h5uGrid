program TestFormDesigner;

{$APPTYPE CONSOLE}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([vcPrivate, vcPublic])}

{$SCOPEDENUMS ON}

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo, System.Masks,
  h5u.FormDesigner,
  h5u.FormDesigner.Properties,
  h5u.Grid.Data.Objects;

type
  TManagedFixtureValue = record
    Caption: string;
    Numbers: TArray<Integer>;
  end;

  TBaseFixture = class(TComponent)
  private
    FZulu: string;
    FAlpha: string;
    FPublicValue: Integer;
    FPrivateSecret: Integer;
    FLimited: Integer;
    FReads: Integer;
    FNumbers: TArray<Integer>;
    FManagedValue: TManagedFixtureValue;
    FOnAction: TNotifyEvent;
    function GetLimited: Integer;
    procedure SetLimited(AValue: Integer);
  public
    PublicNumber: Integer;
    procedure SetNumberAt(AIndex, AValue: Integer);
    procedure SetManagedNumberAt(AIndex, AValue: Integer);
    procedure SetManagedCaption(const ACaption: string);
    property PublicValue: Integer read FPublicValue write FPublicValue;
    property Reads: Integer read FReads;
    property Numbers: TArray<Integer> read FNumbers write FNumbers;
    property ManagedValue: TManagedFixtureValue read FManagedValue write FManagedValue;
  published
    property Zulu: string read FZulu write FZulu;
    property Alpha: string read FAlpha write FAlpha;
    property Limited: Integer read GetLimited write SetLimited;
    property ReadOnlyValue: string read FAlpha;
    property OnAction: TNotifyEvent read FOnAction write FOnAction;
  end;

  TDerivedFixture = class(TBaseFixture)
  private
    FPrivateSecret: Integer;
    FMiddle: string;
  published
    property Middle: string read FMiddle write FMiddle;
  end;

  THooks = class
  public
    LoadedCount, ReadCount, WriteCount: Integer;
    Stored: Integer;
    AlphaText: string;
    OverrideAlpha: Boolean;
    procedure Loaded(Sender: TObject);
    procedure GetValue(Sender: TObject; Item: Th5uPropertyItem; var Value: TValue; var Handled: Boolean);
    procedure SetValue(Sender: TObject; Item: Th5uPropertyItem; const Value: TValue; var Handled: Boolean);
  end;

  TTypeEditor = class(Th5uValueEditor)
  public
    function GetValue: string; override;
  end;

  TNamedEditor = class(Th5uValueEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const AText: string); override;
    procedure GetComboList(AItems: TStrings); override;
  end;

  TLatestEditor = class(Th5uValueEditor)
  public
    function GetValue: string; override;
  end;

  TCycleStructureView = class(Th5uStructureView)
  protected
    procedure CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList); override;
  end;

  TStructureHooks = class
  public
    Model: Th5uStructureView;
    Extra: TComponent;
    LoadedCount, ChangedCount: Integer;
    procedure Loaded(Sender: TObject);
    procedure Changed(Sender: TObject);
  end;

  TRemovingListener = class
  public
    Properties: Th5uPropertyEditor;
    Structure: Th5uStructureView;
    Other: TRemovingListener;
    Calls: Integer;
    procedure Changed(Sender: TObject);
  end;

  TPropertyNotifications = class
  public
    ChangingCount, ChangedCount, ItemChangedCount: Integer;
    LastItem: Th5uPropertyItem;
    LastInstance: Pointer;
    LastID: Integer;
    procedure Reset;
    procedure Changing(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure ItemChanged(Sender: TObject; Item: Th5uPropertyItem);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function IntValue(AValue: Integer): TValue;
begin
  Result := TValue.From<Integer>(AValue);
end;

function TextValue(const AValue: string): TValue;
begin
  Result := TValue.From<string>(AValue);
end;

function Need(AEditor: Th5uPropertyEditor; const AName: string): Th5uPropertyItem;
begin
  Result := AEditor.FindProperty(AName);
  Check(Assigned(Result), 'Missing property: ' + AName);
end;

function IndexOf(AEditor: Th5uPropertyEditor; const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to AEditor.Items.Count - 1 do
    if SameText(AEditor.Items[I].Name, AName) then
      Exit(I);
end;

function VisibleCount(AEditor: Th5uPropertyEditor): Integer;
var
  Item: Th5uPropertyItem;
begin
  Result := 0;
  for Item in AEditor.Items do
    if not Item.Hidden then
      Inc(Result);
end;

function TBaseFixture.GetLimited: Integer;
begin
  Inc(FReads);
  Result := FLimited;
end;

procedure TBaseFixture.SetLimited(AValue: Integer);
begin
  if AValue < 0 then
  begin
    FAlpha := 'setter side effect';
    raise ERangeError.Create('negative value rejected');
  end;
  if AValue > 10 then
    AValue := 10;
  FLimited := AValue;
end;

procedure TBaseFixture.SetNumberAt(AIndex, AValue: Integer);
begin
  FNumbers[AIndex] := AValue;
end;

procedure TBaseFixture.SetManagedNumberAt(AIndex, AValue: Integer);
begin
  FManagedValue.Numbers[AIndex] := AValue;
end;

procedure TBaseFixture.SetManagedCaption(const ACaption: string);
begin
  FManagedValue.Caption := ACaption;
end;

procedure THooks.Loaded(Sender: TObject);
begin
  Inc(LoadedCount);
end;

procedure THooks.GetValue(Sender: TObject; Item: Th5uPropertyItem; var Value: TValue; var Handled: Boolean);
begin
  if Item.Name = 'ManualComputed' then
  begin
    Inc(ReadCount);
    Value := IntValue(Stored);
    Handled := True;
  end
  else if OverrideAlpha and (Item.Name = 'Alpha') then
  begin
    Value := TextValue(AlphaText);
    Handled := True;
  end;
end;

procedure THooks.SetValue(Sender: TObject; Item: Th5uPropertyItem; const Value: TValue; var Handled: Boolean);
begin
  if Item.Name = 'ManualComputed' then
  begin
    Inc(WriteCount);
    Stored := Value.AsInteger;
    Handled := True;
  end
  else if OverrideAlpha and (Item.Name = 'Alpha') then
  begin
    AlphaText := Value.AsString;
    Handled := True;
  end;
end;

function TTypeEditor.GetValue: string;
begin
  Result := 'type editor';
end;

function TNamedEditor.GetValue: string;
begin
  Result := 'named editor';
end;

procedure TNamedEditor.SetValue(const AText: string);
begin
  Item.Value := TextValue('edited ' + AText);
end;

procedure TNamedEditor.GetComboList(AItems: TStrings);
begin
  AItems.Add('first');
  AItems.Add('second');
end;

function TLatestEditor.GetValue: string;
begin
  Result := 'latest editor';
end;

procedure TCycleStructureView.CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList);
begin
  inherited;
  if AComponent.Name = 'Branch' then
    AChildren.Add(RootComponent);
end;

procedure TStructureHooks.Loaded(Sender: TObject);
var
  ParentItem: Th5uStructureItem;
begin
  Inc(LoadedCount);
  ParentItem := Model.FindComponent(Model.RootComponent.FindComponent('Branch'));
  Model.AddComponent(Extra, ParentItem, True);
  Model.AddComponent(Extra, ParentItem, True);
end;

procedure TStructureHooks.Changed(Sender: TObject);
begin
  Inc(ChangedCount);
end;

procedure TRemovingListener.Changed(Sender: TObject);
begin
  Inc(Calls);
  if Properties <> nil then
  begin
    Properties.RemoveChangeListener(nil, Changed);
    if Other <> nil then
      Properties.RemoveChangeListener(nil, Other.Changed);
  end;
  if Structure <> nil then
  begin
    Structure.RemoveChangeListener(nil, Changed);
    if Other <> nil then
      Structure.RemoveChangeListener(nil, Other.Changed);
  end;
end;

procedure TPropertyNotifications.Reset;
begin
  ChangingCount := 0;
  ChangedCount := 0;
  ItemChangedCount := 0;
  LastItem := nil;
  LastInstance := nil;
  LastID := 0;
end;

procedure TPropertyNotifications.Changing(Sender: TObject);
begin
  Inc(ChangingCount);
end;

procedure TPropertyNotifications.Changed(Sender: TObject);
begin
  Inc(ChangedCount);
end;

procedure TPropertyNotifications.ItemChanged(Sender: TObject; Item: Th5uPropertyItem);
begin
  Inc(ItemChangedCount);
  LastItem := Item;
  LastInstance := Item.Instance;
  LastID := Item.ID;
end;

procedure TestMasks;
var
  Failed: Boolean;
begin
  Check(h5uMatchesMask('Unit.Sub.Type', 'Unit.*.T?pe'), 'namespace wildcard');
  Check(h5uMatchesMask('unit.sub.type', 'UNIT.*.TYPE'), 'case insensitive mask');
  Check(not h5uMatchesMask('UnitXType', 'Unit.Type'), 'dot must be literal');
  Check(h5uMatchesMask('Unit.Type', 'Unit.Type'), 'literal namespace separator');
  Check(not h5uMatchesMask('Type', 'T?'), 'question mark matches exactly one character');
  Check(h5uMatchesMask('axxbyyc', '*a*b*c'), 'wildcard backtracking with literal anchors');
  Check(not h5uMatchesMask('axxbyy', '*a*b*c'), 'wildcard cannot omit a required literal');
  Check(h5uMatchesMask('Unit.Type', ''), 'empty mask does not restrict selection');

  Check(h5uMatchesMask('Color', '[a-z]olor'), 'RTL character range is case insensitive');
  Check(h5uMatchesMask('Beta', '[abc]eta'), 'RTL bracket character set');
  Check(not h5uMatchesMask('Zeta', '[abc]eta'), 'RTL bracket set excludes other characters');
  Check(h5uMatchesMask('Value', '[!0-9]alue'), 'RTL negated range');
  Check(not h5uMatchesMask('1alue', '[!0-9]alue'), 'RTL negated range rejects matching characters');
  Check(h5uMatchesMask('Unit.Type', 'Unit.[T-V]ype'), 'namespace dot followed by range');
  Check(not h5uMatchesMask('UnitXType', 'Unit.[T-V]ype'), 'range mask does not change literal namespace dots');
  Failed := False;
  try
    h5uMatchesMask('Value', '[a-z');
  except
    on EMaskException do
      Failed := True;
  end;
  Check(Failed, 'malformed RTL masks raise EMaskException');

  Writeln('PASS: RTL masks, ranges/sets/negation, namespaces, literal dots and invalid masks');
end;

procedure TestPublishedAndFiltering;
var
  E: Th5uPropertyEditor;
  Source: TDerivedFixture;
  I: Integer;
  Failed: Boolean;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TDerivedFixture.Create(nil);
  try
    Source.Alpha := 'a';
    E.LimitClass := TBaseFixture;
    E.DataObject := Source;
    Need(E, 'Alpha');
    Need(E, 'Zulu');
    Need(E, 'OnAction');
    Need(E, 'Middle');
    Check(E.FindProperty('Name') = nil, 'inclusive limit excludes ancestors');
    Check(E.FindProperty('PublicValue') = nil, 'public property not selected by default');
    Check(E.FindProperty('PublicNumber') = nil, 'public field not selected by default');
    Check(E.FindProperty('FPrivateSecret') = nil, 'private field not selected by default');
    Check(Need(E, 'ReadOnlyValue').ReadOnly, 'RTTI read-only property');
    for I := 1 to E.Items.Count - 1 do
      Check(CompareText(E.Items[I - 1].Name, E.Items[I].Name) <= 0, 'name sort');
    E.NameMask := 'A?pha';
    Check((VisibleCount(E) = 1) and not Need(E, 'Alpha').Hidden, 'property name mask');

    E.NameMask := '[A-B]lpha';
    Check((VisibleCount(E) = 1) and not Need(E, 'Alpha').Hidden, 'property name mask accepts RTL ranges');
    Failed := False;
    try
      E.NameMask := '[a-z';
    except
      on EMaskException do
        Failed := True;
    end;
    Check(Failed and (E.NameMask = '[A-B]lpha') and (VisibleCount(E) = 1), 'invalid property mask preserves previous filter and rows');

    E.NameMask := '*';
    E.TypeMask := '*NotifyEvent';
    Check((VisibleCount(E) = 1) and not Need(E, 'OnAction').Hidden, 'event type mask');

    E.TypeMask := '*T[N-P]otifyEvent';
    Check((VisibleCount(E) = 1) and not Need(E, 'OnAction').Hidden, 'property type mask accepts RTL ranges');

    E.TypeMask := '*';
    E.NameMask := 'Alpha';
    E.ClassMask := '*TDerivedFixture';
    Check((VisibleCount(E) = 1) and not Need(E, 'Alpha').Hidden, 'derived object class mask includes inherited property');

    E.ClassMask := 'T[D-F]erivedFixture';
    Check((VisibleCount(E) = 1) and not Need(E, 'Alpha').Hidden, 'class mask accepts RTL ranges');

    E.ClassMask := '*TBaseFixture';
    Check((VisibleCount(E) = 1) and not Need(E, 'Alpha').Hidden, 'base object class mask includes descendant');
    E.ClassMask := '*TUnrelatedFixture';
    Check(VisibleCount(E) = 0, 'unrelated class mask excludes inspected object');
    E.ClassMask := '*';
    E.NameMask := '*';
    E.LimitClass := TDerivedFixture;
    Check((E.Items.Count = 1) and (E.Items[0].Name = 'Middle'), 'limit includes selected class');
    Writeln('PASS: published properties/events, inclusive class limit, name sort and three masks');
  finally
    E.Free;
    Source.Free;
  end;
end;

procedure TestExtendedRtti;
var
  E: Th5uPropertyEditor;
  Source: TDerivedFixture;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TDerivedFixture.Create(nil);
  try
    E.LimitClass := TBaseFixture;
    E.DataObject := Source;
    E.PublishedProperties := False;
    E.PublicProperties := True;
    Need(E, 'PublicValue');
    Check(E.FindProperty('Alpha') = nil, 'published properties can be deselected');
    E.PublicProperties := False;
    E.PublicFields := True;
    E.SetValue(Need(E, 'PublicNumber'), IntValue(12));
    Check(Source.PublicNumber = 12, 'extended RTTI public field write');
    Check(E.FindProperty('FPrivateSecret') = nil, 'private fields remain opt-in');
    E.PublicFields := False;
    E.PrivateFields := True;
    E.SetValue(E.FindProperty('FPrivateSecret', TBaseFixture), IntValue(31));
    E.SetValue(E.FindProperty('FPrivateSecret', TDerivedFixture), IntValue(47));
    Check(E.GetValue(E.FindProperty('FPrivateSecret', TBaseFixture)).AsInteger = 31, 'base private field retains its own storage slot');
    Check(E.GetValue(Need(E, 'FPrivateSecret')).AsInteger = 47, 'unqualified field lookup selects derived private slot');
    E.PrivateFields := False;
    E.PublishedProperties := True;
    E.SortOrder := Th5uPropertySortOrder.psoDeclaration;
    Check(IndexOf(E, 'Zulu') < IndexOf(E, 'Alpha'), 'declaration order retained within class');
    Check(IndexOf(E, 'OnAction') < IndexOf(E, 'Middle'), 'base class precedes descendant');
    Writeln('PASS: extended public/private RTTI fields, property selection and declaration/class order');
  finally
    E.Free;
    Source.Free;
  end;
end;

procedure TestEventValues;
var
  E: Th5uPropertyEditor;
  Source: TBaseFixture;
  H: THooks;
  Event, ReadEvent: TNotifyEvent;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TBaseFixture.Create(nil);
  H := THooks.Create;
  try
    E.DataObject := Source;
    Event := H.Loaded;
    E.SetValue(Need(E, 'OnAction'), TValue.From<TNotifyEvent>(Event));
    ReadEvent := E.GetValue(Need(E, 'OnAction')).AsType<TNotifyEvent>();
    Check((TMethod(ReadEvent).Code = TMethod(Event).Code) and (TMethod(ReadEvent).Data = H), 'typed event preserves method and instance');
    ReadEvent(Source);
    Check(H.LoadedCount = 1, 'read-back event remains callable');
    Check(E.GetText(Need(E, 'OnAction')) <> '', 'assigned event display');
    E.SetText(Need(E, 'OnAction'), '');
    Check(not Assigned(Source.OnAction), 'empty event edit clears method safely');
    Writeln('PASS: event TValue assignment/readback, method instance, display and clear');
  finally
    E.Free;
    Source.Free;
    H.Free;
  end;
end;

procedure TestInstanceRttiRows;
var
  E: Th5uPropertyEditor;
  A, B: TBaseFixture;
  Context: TRttiContext;
  AlphaProperty: TRttiProperty;
  NumberField: TRttiField;
  AItem, BItem, FieldItem, ManualItem, CacheItem: Th5uPropertyItem;
  BeforeCount: Integer;
begin
  E := Th5uPropertyEditor.Create(nil);
  A := TBaseFixture.Create(nil);
  B := TBaseFixture.Create(nil);
  Context := TRttiContext.Create;
  try
    A.Alpha := 'first';
    B.Alpha := 'second';
    B.PublicNumber := 19;
    E.LimitClass := TBaseFixture;
    E.DataObject := A;
    AItem := Need(E, 'Alpha');
    AlphaProperty := Context.GetType(TBaseFixture).GetProperty('Alpha');
    NumberField := Context.GetType(TBaseFixture).GetField('PublicNumber');
    Check((AItem.Instance = Pointer(A)) and (AItem.RttiProperty = AlphaProperty)
      and (AItem.RttiField = nil), 'discovered row retains its instance and extended RTTI property');
    BItem := E.AddProperty(Pointer(B), AlphaProperty);
    FieldItem := E.AddField(Pointer(B), NumberField);
    ManualItem := E.AddManualProperty(Pointer(B), 'RuntimeNote', TextValue('cached note'));
    Check((BItem.Instance = Pointer(B)) and (BItem.RttiProperty = AlphaProperty)
      and (BItem.Value.AsString = 'second'), 'added RTTI property reads the row instance immediately');
    Check((FieldItem.Instance = Pointer(B)) and (FieldItem.RttiField = NumberField)
      and (FieldItem.RttiProperty = nil) and (FieldItem.Value.AsInteger = 19),
      'added RTTI field retains its descriptor, instance and typed value');
    Check((ManualItem.Instance = Pointer(B)) and (ManualItem.RttiProperty = nil)
      and (ManualItem.RttiField = nil) and ManualItem.IsManual,
      'manual row without RTTI still retains its instance');
    Check((E.FindProperty(Pointer(A), 'Alpha') = AItem)
      and (E.FindProperty(Pointer(B), 'Alpha') = BItem), 'same member names resolve by row instance');
    BItem.Value := TextValue('second edited');
    FieldItem.Value := IntValue(23);
    ManualItem.Value := TextValue('manual edited');
    Check((A.Alpha = 'first') and (B.Alpha = 'second edited') and (B.PublicNumber = 23),
      'RTTI writes use each row instance without changing the selected object');
    B.Alpha := 'second external';
    B.PublicNumber := 29;
    Check((BItem.Value.AsString = 'second edited') and (FieldItem.Value.AsInteger = 23),
      'property and field reads use their cached TValue until refresh');
    E.Refresh;
    Check((BItem.Value.AsString = 'second external') and (FieldItem.Value.AsInteger = 29),
      'refresh rereads descriptors belonging to added instances');
    Check(ManualItem.Value.AsString = 'manual edited', 'manual row without RTTI keeps its cached value on refresh');
    BeforeCount := E.Items.Count;
    FreeAndNil(B);
    Check((E.DataObject = A) and (E.Items.Count = BeforeCount - 3)
      and (E.FindProperty(Pointer(A), 'Alpha') = AItem),
      'nonselected component destruction removes only its mapped and manual rows');
    B := TBaseFixture.Create(nil);
    B.Alpha := 'retained';
    B.PublicNumber := 37;
    BItem := E.AddProperty(Pointer(B), AlphaProperty);
    FieldItem := E.AddField(Pointer(B), NumberField);
    ManualItem := E.AddManualProperty(Pointer(B), 'RuntimeNote', TextValue('retained manual'));
    CacheItem := E.AddManualProperty(nil, 'LocalNote', TextValue('independent cache'));
    FreeAndNil(A);
    Check((E.DataObject = nil) and (E.Items.Count = 4)
      and (E.FindProperty(Pointer(B), 'Alpha') = BItem)
      and (E.FindProperty(nil, 'LocalNote') = CacheItem),
      'selected component destruction retains rows belonging to other instances and nil');
    BItem.Value := TextValue('edited after selected destruction');
    E.Refresh;
    Check((B.Alpha = 'edited after selected destruction') and (FieldItem.Value.AsInteger = 37)
      and (ManualItem.Value.AsString = 'retained manual')
      and (CacheItem.Value.AsString = 'independent cache'),
      'remaining rows stay readable, writable and refreshable without a selected object');
    FreeAndNil(B);
    Check((E.Items.Count = 1) and (E.Items[0] = CacheItem),
      'last component destruction leaves independent cache-only rows intact');
    Writeln('PASS: per-row instance, RTTI descriptors, mixed-object cache/write and component lifetime');
  finally
    E.Free;
    Context.Free;
    B.Free;
    A.Free;
  end;
end;

procedure TestRefreshNotificationsAndReorder;
var
  E: Th5uPropertyEditor;
  A, B: TBaseFixture;
  Context: TRttiContext;
  AlphaProperty: TRttiProperty;
  AItem, BItem: Th5uPropertyItem;
  AID, BID: Integer;
  Events: TPropertyNotifications;
begin
  E := Th5uPropertyEditor.Create(nil);
  A := TBaseFixture.Create(nil);
  B := TBaseFixture.Create(nil);
  Events := TPropertyNotifications.Create;
  Context := TRttiContext.Create;
  try
    A.Alpha := 'first';
    B.Alpha := 'second';
    E.PublishedProperties := False;
    E.DataObject := A;
    AlphaProperty := Context.GetType(TBaseFixture).GetProperty('Alpha');
    AItem := E.AddProperty(Pointer(A), AlphaProperty);
    BItem := E.AddProperty(Pointer(B), AlphaProperty);
    AID := AItem.ID;
    BID := BItem.ID;
    Check(AID <> BID, 'same-name rows receive different IDs');
    E.AddChangeListener(Events.Changing, Events.Changed, Events.ItemChanged);
    E.Refresh;
    Check((Events.ChangingCount = 0) and (Events.ChangedCount = 0)
      and (Events.ItemChangedCount = 0), 'unchanged refresh does not notify any consumer');
    B.Alpha := 'changed';
    E.Refresh;
    Check((Events.ItemChangedCount = 1) and (Events.LastItem = BItem)
      and (Events.LastInstance = Pointer(B)) and (Events.LastID = BID),
      'refresh identifies only the changed row by instance and stable ID');
    Check((Events.ChangingCount = 0) and (Events.ChangedCount = 0),
      'value refresh does not rebuild the object list');
    Events.Reset;
    E.Refresh;
    Check(Events.ItemChangedCount = 0, 'new cache value prevents duplicate refresh notification');
    E.Items.Exchange(0, 1);
    E.NotifyItemsChanged;
    Check((AItem.ID = AID) and (BItem.ID = BID) and (E.Items[0] = BItem),
      'manual list reordering preserves the chosen order and existing row IDs');
    Check((E.FindProperty(Pointer(A), 'Alpha') = AItem)
      and (E.FindProperty(Pointer(B), 'Alpha') = BItem), 'instance lookup is independent of list order');
    Events.Reset;
    A.Alpha := 'first changed';
    E.Refresh;
    Check((Events.ItemChangedCount = 1) and (Events.LastItem = AItem)
      and (Events.LastInstance = Pointer(A)) and (Events.LastID = AID),
      'refresh after reordering still reports the correct row identity');
    E.RemoveChangeListener(Events.Changing, Events.Changed, Events.ItemChanged);
    Events.Reset;
    A.Alpha := 'after removal';
    E.Refresh;
    Check(Events.ItemChangedCount = 0, 'removed item listener is no longer called');
    Writeln('PASS: TValue change comparison, silent unchanged refresh and stable identity after reordering');
  finally
    E.Free;
    Context.Free;
    Events.Free;
    B.Free;
    A.Free;
  end;
end;

procedure TestArrayCacheSnapshot;
var
  E: Th5uPropertyEditor;
  Source: TBaseFixture;
  Context: TRttiContext;
  Item, RecordItem: Th5uPropertyItem;
  Events: TPropertyNotifications;
  RecordValue, CachedRecord: TManagedFixtureValue;
  FreshCaption: string;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TBaseFixture.Create(nil);
  Events := TPropertyNotifications.Create;
  Context := TRttiContext.Create;
  try
    Source.Numbers := TArray<Integer>.Create(3, 5);
    Item := E.AddProperty(Pointer(Source), Context.GetType(TBaseFixture).GetProperty('Numbers'));
    E.AddChangeListener(nil, nil, Events.ItemChanged);
    Check(Item.Value.GetArrayElement(0).AsInteger = 3, 'array initial value enters the row cache');
    Source.SetNumberAt(0, 8);
    Check(Item.Value.GetArrayElement(0).AsInteger = 3,
      'in-place dynamic array edits do not mutate the previous cached value');
    E.Refresh;
    Check((Events.ItemChangedCount = 1) and (Events.LastItem = Item)
      and (Item.Value.GetArrayElement(0).AsInteger = 8),
      'array content changes notify the correct row and replace its cached snapshot');
    Events.Reset;
    E.Refresh;
    Check(Events.ItemChangedCount = 0, 'unchanged array contents do not repeat the row notification');
    RecordValue.Caption := StringOfChar('x', 64);
    RecordValue.Numbers := TArray<Integer>.Create(11, 13);
    Source.ManagedValue := RecordValue;
    RecordItem := E.AddProperty(Pointer(Source), Context.GetType(TBaseFixture).GetProperty('ManagedValue'));
    Source.SetManagedNumberAt(0, 17);
    CachedRecord := RecordItem.Value.AsType<TManagedFixtureValue>;
    Check(CachedRecord.Numbers[0] = 11, 'nested dynamic array edits do not mutate the cached record');
    E.Refresh;
    CachedRecord := RecordItem.Value.AsType<TManagedFixtureValue>;
    Check((Events.ItemChangedCount = 1) and (Events.LastItem = RecordItem)
      and (CachedRecord.Numbers[0] = 17), 'managed record content change updates only its row');
    FreshCaption := StringOfChar('x', 64);
    Check(Pointer(FreshCaption) <> Pointer(CachedRecord.Caption),
      'equal record caption fixture uses a different string allocation');
    Source.SetManagedCaption(FreshCaption);
    Events.Reset;
    E.Refresh;
    Check(Events.ItemChangedCount = 0,
      'fresh string allocation with equal content does not change the cached record value');
    E.Refresh;
    Check(Events.ItemChangedCount = 0, 'unchanged managed record contents keep refresh silent');
    Writeln('PASS: array/managed-record cache snapshots and content-based change detection');
  finally
    E.Free;
    Context.Free;
    Events.Free;
    Source.Free;
  end;
end;

procedure TestCacheAndWrites;
var
  E: Th5uPropertyEditor;
  Source: TBaseFixture;
  Item: Th5uPropertyItem;
  Before: Integer;
  Failed: Boolean;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TBaseFixture.Create(nil);
  try
    Source.Limited := 3;
    E.DataObject := Source;
    Item := Need(E, 'Limited');
    Check(E.GetValue(Item).AsInteger = 3, 'initial cached read');
    Before := Source.Reads;
    Check(E.GetValue(Item).AsInteger = 3, 'second cached read');
    Check(Source.Reads = Before, 'cache avoids repeated getters');
    Source.Limited := 7;
    Check(E.GetValue(Item).AsInteger = 3, 'external changes wait for refresh');
    E.Refresh;
    Item := Need(E, 'Limited');
    Check(E.GetValue(Item).AsInteger = 7, 'refresh invalidates live value cache');
    E.SetValue(Item, IntValue(99));
    Check((Source.Limited = 10) and (E.GetValue(Item).AsInteger = 10), 'setter normalization read back into cache');
    Check(E.GetValue(Need(E, 'Alpha')).AsString = '', 'cache dependent property before rejected write');
    Failed := False;
    try
      E.SetValue(Item, IntValue(-1));
    except
      on ERangeError do
        Failed := True;
    end;
    Check(Failed, 'setter exception propagated');
    Check((Source.Limited = 10) and (E.GetValue(Item).AsInteger = 10), 'failed setter must not cache rejected input');
    Check(E.GetValue(Need(E, 'Alpha')).AsString = 'setter side effect', 'failed setter invalidates dependent cached values');
    E.SetText(Item, '8');
    Check(Source.Limited = 8, 'default scalar editor parses text');
    Failed := False;
    try
      E.SetText(Item, 'invalid');
    except
      on Exception do
        Failed := True;
    end;
    Check(Failed and (Source.Limited = 8), 'invalid edit preserves object value');
    Writeln('PASS: cached reads, refresh, normalized setter readback and failed writes');
  finally
    E.Free;
    Source.Free;
  end;
end;

procedure TestManualDefinitionChanges;
var
  E: Th5uPropertyEditor;
  Source: TDerivedFixture;
  M: Th5uManualProperty;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TDerivedFixture.Create(nil);
  try
    M := E.ManualProperties.Add;
    M.TargetClass := TBaseFixture;
    M.PropertyName := 'Manual';
    M.ValueTypeInfo := TypeInfo(string);
    M.DefaultValue := TextValue('default');
    E.DataObject := Source;
    E.SetValue(Need(E, 'Manual'), TextValue('saved'));
    M.PropertyName := 'Renamed';
    Check(E.GetValue(Need(E, 'Renamed')).AsString = 'default', 'renaming manual definition resets obsolete cache key');
    M.ValueTypeInfo := TypeInfo(Integer);
    M.DefaultValue := IntValue(5);
    Check(E.GetValue(Need(E, 'Renamed')).AsInteger = 5, 'manual type change discards incompatible cached values');
    E.SetValue(Need(E, 'Renamed'), IntValue(9));
    M.TargetClass := TDerivedFixture;
    Check(E.GetValue(Need(E, 'Renamed')).AsInteger = 5, 'manual target class is part of cache identity');
    M.Free;
    Check(E.FindProperty('Renamed') = nil, 'deleting manual definition removes metadata and cached values');
    Writeln('PASS: manual definition rename, type/class change and deletion invalidate old cache identity');
  finally
    E.Free;
    Source.Free;
  end;
end;

procedure TestRemovingListeners;
var
  P: Th5uPropertyEditor;
  S: Th5uStructureView;
  A, B: TRemovingListener;
begin
  P := Th5uPropertyEditor.Create(nil);
  S := Th5uStructureView.Create(nil);
  A := TRemovingListener.Create;
  B := TRemovingListener.Create;
  try
    A.Properties := P;
    A.Other := B;
    P.AddChangeListener(nil, A.Changed);
    P.AddChangeListener(nil, B.Changed);
    P.NotifyItemsChanged;
    P.NotifyItemsChanged;
    Check((A.Calls = 1) and (B.Calls = 0), 'property listener may remove itself and a later listener during dispatch');
    A.Properties := nil;
    A.Structure := S;
    A.Calls := 0;
    S.AddChangeListener(nil, A.Changed);
    S.AddChangeListener(nil, B.Changed);
    S.FilterText := 'one';
    S.FilterText := 'two';
    Check((A.Calls = 1) and (B.Calls = 0), 'structure listener may remove itself and a later listener during dispatch');
    Writeln('PASS: listener removal during property/structure notifications');
  finally
    P.Free;
    S.Free;
    B.Free;
    A.Free;
  end;
end;

procedure TestManualAndHooks;
var
  E: Th5uPropertyEditor;
  A, B: TBaseFixture;
  M: Th5uManualProperty;
  H: THooks;
begin
  E := Th5uPropertyEditor.Create(nil);
  A := TBaseFixture.Create(nil);
  B := TBaseFixture.Create(nil);
  H := THooks.Create;
  try
    M := E.ManualProperties.Add;
    M.TargetClass := TBaseFixture;
    M.PropertyName := 'ManualNote';
    M.ValueTypeInfo := TypeInfo(string);
    M.DefaultValue := TextValue('default');
    E.OnLoaded := H.Loaded;
    E.DataObject := A;
    Check(Need(E, 'ManualNote').IsManual, 'manual property metadata');
    E.SetValue(Need(E, 'ManualNote'), TextValue('A value'));
    E.DataObject := B;
    Check(E.GetValue(Need(E, 'ManualNote')).AsString = 'default', 'manual values isolated by object');
    E.SetValue(Need(E, 'ManualNote'), TextValue('B value'));
    E.DataObject := A;
    E.Reload;
    E.Refresh;
    Check(E.GetValue(Need(E, 'ManualNote')).AsString = 'A value', 'manual cache survives reload/refresh/object switch');
    Check(H.LoadedCount >= 3, 'OnLoaded lifecycle');
    M := E.ManualProperties.Add;
    M.TargetClass := TBaseFixture;
    M.PropertyName := 'ManualComputed';
    M.ValueTypeInfo := TypeInfo(Integer);
    M.DefaultValue := IntValue(0);
    H.Stored := 42;
    H.OverrideAlpha := True;
    H.AlphaText := 'custom read';
    A.Alpha := 'untouched';
    E.OnGetValue := H.GetValue;
    E.OnSetValue := H.SetValue;
    E.Reload;
    Check(E.GetValue(Need(E, 'ManualComputed')).AsInteger = 42, 'manual GetValue hook');
    E.SetValue(Need(E, 'ManualComputed'), IntValue(61));
    Check((H.Stored = 61) and (H.WriteCount = 1), 'manual SetValue hook');
    Check(E.GetValue(Need(E, 'Alpha')).AsString = 'custom read', 'normal property read override');
    E.SetValue(Need(E, 'Alpha'), TextValue('custom write'));
    Check((H.AlphaText = 'custom write') and (A.Alpha = 'untouched'), 'normal property write override');
    E.ForgetObject(A);
    E.DataObject := B;
    E.DataObject := A;
    Check(E.GetValue(Need(E, 'ManualNote')).AsString = 'default', 'ForgetObject discards object-specific manual cache');
    Writeln('PASS: manual defaults, per-object cache, Loaded/GetValue/SetValue hooks and ForgetObject');
  finally
    E.Free;
    H.Free;
    B.Free;
    A.Free;
  end;
end;

procedure TestProtectionAndLifetime;
var
  E: Th5uPropertyEditor;
  Source: TBaseFixture;
  F: Th5uPropertyFilter;
  C: Th5uObjectListController;
  Item: Th5uPropertyItem;
  Failed: Boolean;
begin
  E := Th5uPropertyEditor.Create(nil);
  C := Th5uObjectListController.Create(nil);
  Source := TBaseFixture.Create(nil);
  try
    Source.Alpha := 'original';
    F := E.Filters.Add;
    F.ClassMask := '*TBaseFixture';
    F.NameMask := 'Alpha';
    F.ReadOnly := True;
    E.DataObject := Source;
    Item := Need(E, 'Alpha');
    Check(Item.ReadOnly and not Item.CanEdit, 'read-only filter state');
    C.Add(Item);
    Failed := False;
    try
      C.SetValue(0, 'DisplayValue', TextValue('forbidden'));
    except
      on Exception do
        Failed := True;
    end;
    Check(Failed and (Source.Alpha = 'original'), 'read-only guard applies through object-list RTTI setter');
    C.Clear;
    F.ReadOnly := False;
    F.Hidden := True;
    E.Reload;
    Item := Need(E, 'Alpha');
    Check(Item.Hidden and not Item.CanEdit, 'hidden filter state');
    Failed := False;
    try
      E.SetValue(Item, TextValue('forbidden'));
    except
      on Exception do
        Failed := True;
    end;
    Check(Failed and (Source.Alpha = 'original'), 'hidden properties reject direct writes');
    FreeAndNil(Source);
    Check((E.DataObject = nil) and (E.Items.Count = 0), 'component destruction clears inspected object and rows');
    Writeln('PASS: read-only/hidden editing guards and inspected component lifetime');
  finally
    C.Free;
    E.Free;
    Source.Free;
  end;
end;

procedure TestRegistry;
var
  E: Th5uPropertyEditor;
  Source: TDerivedFixture;
  List: TStringList;
  TypeToken, NamedToken, LatestToken: Integer;
begin
  E := Th5uPropertyEditor.Create(nil);
  Source := TDerivedFixture.Create(nil);
  List := TStringList.Create;
  TypeToken := 0;
  NamedToken := 0;
  LatestToken := 0;
  try
    E.DataObject := Source;
    TypeToken := h5uRegisterPropertyEditor(TypeInfo(string), nil, '', TTypeEditor);
    Check(E.GetText(Need(E, 'Alpha')) = 'type editor', 'registered type editor');
    NamedToken := h5uRegisterPropertyEditor(nil, TBaseFixture, 'Alpha', TNamedEditor);
    Check(E.GetText(Need(E, 'Alpha')) = 'named editor', 'class/name registration outranks type registration');
    E.SetText(Need(E, 'Alpha'), 'input');
    Check(Source.Alpha = 'edited input', 'registered SetValue applies custom conversion');
    E.GetComboList(Need(E, 'Alpha'), List);
    Check((List.Count = 2) and (List[1] = 'second'), 'registered combo choices');
    LatestToken := h5uRegisterPropertyEditor(nil, TBaseFixture, 'Alpha', TLatestEditor);
    Check(E.GetText(Need(E, 'Alpha')) = 'latest editor', 'newest equal registration wins');
    h5uUnregisterPropertyEditor(LatestToken);
    LatestToken := 0;
    Check(E.GetText(Need(E, 'Alpha')) = 'named editor', 'unregister restores previous matching editor');
    h5uUnregisterPropertyEditor(NamedToken);
    NamedToken := 0;
    Check(E.GetText(Need(E, 'Alpha')) = 'type editor', 'unregister falls back to type editor');
    Writeln('PASS: editor registry precedence, combo choices, tie breaking and unregister');
  finally
    if LatestToken <> 0 then
      h5uUnregisterPropertyEditor(LatestToken);
    if NamedToken <> 0 then
      h5uUnregisterPropertyEditor(NamedToken);
    if TypeToken <> 0 then
      h5uUnregisterPropertyEditor(TypeToken);
    List.Free;
    E.Free;
    Source.Free;
  end;
end;

procedure TestStructure;
var
  E: TCycleStructureView;
  Root, Branch, Leaf, Sibling, Extra, ExtraChild: TComponent;
  H: TStructureHooks;
  RootItem, BranchItem, LeafItem: Th5uStructureItem;
  Failed: Boolean;
begin
  E := TCycleStructureView.Create(nil);
  Root := TComponent.Create(nil);
  Extra := TComponent.Create(nil);
  H := TStructureHooks.Create;
  try
    Root.Name := 'Root';
    Branch := TComponent.Create(Root);
    Branch.Name := 'Branch';
    Leaf := TComponent.Create(Branch);
    Leaf.Name := 'Leaf';
    Sibling := TComponent.Create(Root);
    Sibling.Name := 'Sibling';
    Extra.Name := 'External';
    ExtraChild := TComponent.Create(Extra);
    ExtraChild.Name := 'ExternalChild';
    H.Model := E;
    H.Extra := Extra;
    E.OnLoaded := H.Loaded;
    E.OnChange := H.Changed;
    E.RootComponent := Root;
    Check(E.AllItems.Count = 6, 'owner tree plus OnLoaded components, duplicate/cycle suppression');
    Check(H.LoadedCount = 1, 'OnLoaded is not reentered by additions');
    RootItem := E.FindComponent(Root);
    BranchItem := E.FindComponent(Branch);
    LeafItem := E.FindComponent(Leaf);
    Check((RootItem.Level = 0) and (RootItem.ParentID = 0), 'root row metadata');
    Check((LeafItem.Parent = BranchItem) and (LeafItem.ParentID = BranchItem.ID) and (LeafItem.Level = 2), 'tree parent/level metadata');
    Check((E.ComponentList[3].Component = Extra)
      and (E.ComponentList[5].Component = Sibling), 'OnLoaded descendants appear in parent preorder before following siblings');
    Check(E.FindItemByID(LeafItem.ID) = LeafItem, 'stable ID lookup');
    Check(E.AddComponent(Root, LeafItem, True) = RootItem, 're-adding root reuses item without creating a cycle');
    Check(RootItem.Parent = nil, 'duplicate insertion preserves canonical parent');
    E.FilterText := 'Leaf';
    Check((E.ComponentList.Count = 3) and RootItem.Visible and BranchItem.Visible and LeafItem.Visible, 'filter keeps match ancestors');
    Check(not E.FindComponent(Sibling).Visible, 'filter excludes unrelated sibling');

    E.FilterText := '[K-M]eaf';
    Check((E.ComponentList.Count = 3) and LeafItem.Visible, 'structure accepts RTL range masks and keeps ancestors');
    E.FilterText := '[L]ea';
    Check(E.ComponentList.Count = 0, 'bracket structure masks remain anchored without implicit stars');
    E.FilterText := '[L]eaf';
    Failed := False;
    try
      E.FilterText := '[a-z';
    except
      on EMaskException do
        Failed := True;
    end;
    Check(Failed and (E.FilterText = '[L]eaf') and (E.ComponentList.Count = 3)
      and LeafItem.Visible, 'invalid structure mask preserves current filter and visible ancestors');

    E.FilterText := 'does-not-exist';
    Check(E.ComponentList.Count = 0, 'unmatched filter yields empty view');
    E.FilterText := '';
    Check(E.ComponentList.Count = 6, 'clearing filter restores full tree');
    E.OnLoaded := nil;
    FreeAndNil(Extra);
    Check(E.AllItems.Count = 4, 'external subtree destruction removes watched components');
    Check(H.ChangedCount > 0, 'structure changes notify consumers');
    FreeAndNil(Root);
    Check((E.RootComponent = nil) and (E.AllItems.Count = 0) and (E.ComponentList.Count = 0), 'root destruction clears tree');
    Writeln('PASS: structure ownership, cycles/duplicates, OnLoaded additions, ancestor filter and component lifetime');
  finally
    E.Free;
    H.Free;
    Extra.Free;
    Root.Free;
  end;
end;

begin
  try
    TestMasks;
    TestPublishedAndFiltering;
    TestExtendedRtti;
    TestEventValues;
    TestInstanceRttiRows;
    TestRefreshNotificationsAndReorder;
    TestArrayCacheSnapshot;
    TestCacheAndWrites;
    TestManualAndHooks;
    TestManualDefinitionChanges;
    TestProtectionAndLifetime;
    TestRegistry;
    TestStructure;
    TestRemovingListeners;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
