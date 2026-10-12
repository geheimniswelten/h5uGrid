unit h5u.FormDesigner;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$CODEPAGE UTF8}
{$ELSE}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}
{$ENDIF}

interface

// FPC/LCL support awaits its extended RTTI implementation.
{$IFNDEF FPC}
uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Rtti,
  h5u.Grid.Data.Objects, h5u.FormDesigner.Properties;

type
  // Preserve the original entry point for applications using h5u.FormDesigner.
  Th5uPropertyEditor = h5u.FormDesigner.Properties.Th5uPropertyEditor;
  Th5uPropertyItem = h5u.FormDesigner.Properties.Th5uPropertyItem;
  Th5uValueEditor = h5u.FormDesigner.Properties.Th5uValueEditor;

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

  Th5uPropertyListController = class(Th5uObjectListController)
  private
    FPropertyEditor: Th5uPropertyEditor;
    FGroupRows: TObjectList<TObject>;
    FGroupIDs: TDictionary<string, Integer>;
    FNextGroupID: Integer;
    FOnGetValue: Th5uGetPropertyValueEvent;
    FOnSetValue: Th5uSetPropertyValueEvent;
    function PropertyItem(ASourceRowIndex: Int64): Th5uPropertyItem;
    function GetHasGroups: Boolean;
  protected
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Refresh;
    procedure RebuildItems(AShowGroups: Boolean = True);
    property HasGroups: Boolean read GetHasGroups;
    property PropertyEditor: Th5uPropertyEditor read FPropertyEditor;
  published
    property OnGetValue: Th5uGetPropertyValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uSetPropertyValueEvent read FOnSetValue write FOnSetValue;
  end;

  TComponentEvent = procedure(Sender: TObject; Component: TComponent) of object;
  TComponentMoveEvent = procedure(Sender: TObject; Component, OldParent, NewParent: TComponent) of object;
  Th5uComponentList = TList<TComponent>;

  Th5uStructureItem = class(TPersistent)
  private
    FComponent: TComponent;
    FParent: Th5uStructureItem;
    FID: Integer;
    FImageIndex: Integer;
    FVisible: Boolean;
    function GetParentID: Integer;
    function GetLevel: Integer;
    function GetName: string;
    function GetComponentClassName: string;
  public
    property Component: TComponent read FComponent;
    property Parent: Th5uStructureItem read FParent;
    property Visible: Boolean read FVisible;
  published
    property ID: Integer read FID;
    property ParentID: Integer read GetParentID;
    property Level: Integer read GetLevel;
    property Name: string read GetName;
    property ComponentClassName: string read GetComponentClassName;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
  end;

  Th5uStructureItems = TObjectList<Th5uStructureItem>;
  Th5uStructureChangeListener = class
  public
    Changing: TNotifyEvent;
    Changed: TNotifyEvent;
  end;
  Th5uStructureChangeEvents = record
    Changing, Changed: TNotifyEvent;
  end;

  Th5uStructureView = class(TComponent)
  public type
    TElement = Th5uStructureItem;
  private
    FAllItems: Th5uStructureItems;
    FComponentList: Th5uStructureItems;
    FListeners: TObjectList<Th5uStructureChangeListener>;
    FRootComponent: TComponent;
    FSelectedComponent: TComponent;
    FResolveByOwner: Boolean;
    FResolveByParent: Boolean;
    FFilterText: string;
    FUpdateCount: Integer;
    FNextID: Integer;
    FDestroying: Boolean;
    FReloading: Boolean;
    FOnChanging: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnLoaded: TNotifyEvent;
    FOnCleared: TNotifyEvent;
    FOnSelect: TComponentEvent;
    procedure SetRootComponent(AValue: TComponent);
    procedure SetResolveByOwner(AValue: Boolean);
    procedure SetResolveByParent(AValue: Boolean);
    procedure SetFilterText(const AValue: string);
    procedure ApplyFilter;
    procedure AppendVisibleChildren(AParent: Th5uStructureItem);
    procedure ClearItems;
    procedure AddChildren(AItem: Th5uStructureItem);
    procedure RemoveBranch(AComponent: TComponent);
    procedure NotifyListeners(AChanging: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    // Framework adapters append visual children first, then call inherited.
    procedure CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList); virtual;
    procedure DoLoaded; virtual;
    procedure DoChanging; virtual;
    procedure DoChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure Reload;
    function AddComponent(AComponent: TComponent; AParent: Th5uStructureItem = nil; AIncludeChildren: Boolean = False): Th5uStructureItem;
    function FindComponent(AComponent: TComponent): Th5uStructureItem; reintroduce;
    function FindItemByID(AID: Integer): Th5uStructureItem;
    procedure SelectComponent(AComponent: TComponent);
    procedure AddChangeListener(AChanging, AChanged: TNotifyEvent);
    procedure RemoveChangeListener(AChanging, AChanged: TNotifyEvent);
    // Treat these lists as read-only; use AddComponent to add rows in OnLoaded.
    // Rows never own the represented components.
    property ComponentList: Th5uStructureItems read FComponentList;
    property AllItems: Th5uStructureItems read FAllItems;
    property SelectedComponent: TComponent read FSelectedComponent write SelectComponent;
  published
    property RootComponent: TComponent read FRootComponent write SetRootComponent;
    property ResolveByOwner: Boolean read FResolveByOwner write SetResolveByOwner default True;
    property ResolveByParent: Boolean read FResolveByParent write SetResolveByParent default True;
    property FilterText: string read FFilterText write SetFilterText;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnCleared: TNotifyEvent read FOnCleared write FOnCleared;
    property OnSelect: TComponentEvent read FOnSelect write FOnSelect;
  end;

  // Reserved extension points from the original FormDesigner scaffolding.
  Th5uEventEditor = class(TComponent);
  Th5uComponentPalette = class(TComponent);
  Th5uFormDesigner = class(TComponent);

{$ENDIF}

implementation

{$IFNDEF FPC}
type
  Th5uControllerPropertyEditor = class(Th5uPropertyEditor)
  private
    FController: Th5uPropertyListController;
  protected
    procedure DoGetValue(AItem: Th5uPropertyItem; var AValue: TValue; var AHandled: Boolean); override;
    procedure DoSetValue(AItem: Th5uPropertyItem; const AValue: TValue; var AHandled: Boolean); override;
  public
    procedure Refresh; override;
  end;

function Th5uPropertyGroupRow.GetCaption: string;
begin
  // Leave room for the grid's fold glyph when the row indicator is hidden.
  Result := '     ' + FGroupName;
end;

function Th5uPropertyGroupRow.GetDisplayValue: string;
begin
  Result := '';
end;

procedure Th5uControllerPropertyEditor.DoGetValue(AItem: Th5uPropertyItem;
  var AValue: TValue; var AHandled: Boolean);
begin
  inherited;
  if not AHandled and Assigned(FController.FOnGetValue) then
    FController.FOnGetValue(FController, AItem, AValue, AHandled);
end;

procedure Th5uControllerPropertyEditor.DoSetValue(AItem: Th5uPropertyItem;
  const AValue: TValue; var AHandled: Boolean);
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

constructor Th5uPropertyListController.Create(AOwner: TComponent);
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

destructor Th5uPropertyListController.Destroy;
begin
  Clear;
  FreeAndNil(FGroupRows);
  FreeAndNil(FGroupIDs);
  FreeAndNil(FPropertyEditor);
  inherited;
end;

function Th5uPropertyListController.GetHasGroups: Boolean;
begin
  Result := FGroupRows.Count > 0;
end;

procedure Th5uPropertyListController.RebuildItems(AShowGroups: Boolean);
var
  LItem: Th5uPropertyItem;
  LHeader: Th5uPropertyGroupRow;
  LPreviousGroup, LKey: string;
  LOccurrences: TDictionary<string, Integer>;
  LOccurrence, LID: Integer;
begin
  LOccurrences := TDictionary<string, Integer>.Create;
  BeginUpdate;
  try
    Clear;
    FGroupRows.Clear;
    LPreviousGroup := '';
    for LItem in FPropertyEditor.Items do
    begin
      if LItem.Hidden then
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

function Th5uPropertyListController.PropertyItem(ASourceRowIndex: Int64): Th5uPropertyItem;
begin
  Result := nil;
  if (ASourceRowIndex >= 0) and (ASourceRowIndex < Count)
    and (Item(ASourceRowIndex) is Th5uPropertyItem) then
    Result := Th5uPropertyItem(Item(ASourceRowIndex));
end;

function Th5uPropertyListController.GetSourceValue(ASourceRowIndex: Int64;
  const AFieldName: string): TValue;
var
  LItem: Th5uPropertyItem;
begin
  LItem := PropertyItem(ASourceRowIndex);
  if LItem <> nil then
  begin
    if SameText(AFieldName, 'Value') then
      Exit(LItem.Value);
    if SameText(AFieldName, 'DisplayValue') then
      Exit(TValue.From<string>(LItem.DisplayValue));
  end;
  Result := inherited;
end;

procedure Th5uPropertyListController.SetSourceValue(ASourceRowIndex: Int64;
  const AFieldName: string; const AValue: TValue);
var
  LItem: Th5uPropertyItem;
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

function Th5uPropertyListController.GetSourceCanEdit(ASourceRowIndex: Int64;
  const AFieldName: string): Boolean;
var
  LItem: Th5uPropertyItem;
begin
  LItem := PropertyItem(ASourceRowIndex);
  if (LItem <> nil) and (SameText(AFieldName, 'Value') or SameText(AFieldName, 'DisplayValue')) then
    Result := LItem.CanEdit
  else
    Result := inherited;
end;

procedure Th5uPropertyListController.Refresh;
begin
  FPropertyEditor.Refresh;
end;

function SameNotifyEvent(A, B: TNotifyEvent): Boolean;
begin
  Result := (TMethod(A).Code = TMethod(B).Code) and (TMethod(A).Data = TMethod(B).Data);
end;

function Th5uStructureItem.GetParentID: Integer;
begin
  if FParent = nil then
    Result := 0
  else
    Result := FParent.ID;
end;

function Th5uStructureItem.GetLevel: Integer;
var
  LParent: Th5uStructureItem;
begin
  Result := 0;
  LParent := FParent;
  while LParent <> nil do
  begin
    Inc(Result);
    LParent := LParent.Parent;
  end;
end;

function Th5uStructureItem.GetName: string;
begin
  Result := FComponent.Name;
  if Result = '' then
    Result := FComponent.ClassName;
end;

function Th5uStructureItem.GetComponentClassName: string;
begin
  Result := FComponent.ClassName;
end;

constructor Th5uStructureView.Create(AOwner: TComponent);
begin
  inherited;
  FAllItems := Th5uStructureItems.Create(True);
  FComponentList := Th5uStructureItems.Create(False);
  FListeners := TObjectList<Th5uStructureChangeListener>.Create(True);
  FResolveByOwner := True;
  FResolveByParent := True;
  FNextID := 1;
end;

destructor Th5uStructureView.Destroy;
begin
  FDestroying := True;
  ClearItems;
  if FRootComponent <> nil then
    FRootComponent.RemoveFreeNotification(Self);
  FListeners.Free;
  FComponentList.Free;
  FAllItems.Free;
  inherited;
end;

procedure Th5uStructureView.BeginUpdate;
begin
  if FUpdateCount = 0 then
    DoChanging;
  Inc(FUpdateCount);
end;

procedure Th5uStructureView.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    ApplyFilter;
    DoChange;
  end;
end;

procedure Th5uStructureView.DoChanging;
begin
  if FDestroying then
    Exit;
  NotifyListeners(True);
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure Th5uStructureView.DoChange;
begin
  if FDestroying then
    Exit;
  NotifyListeners(False);
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure Th5uStructureView.NotifyListeners(AChanging: Boolean);
var
  LSnapshot: array of Th5uStructureChangeEvents;
  LCallback: TNotifyEvent;
  I, J: Integer;
begin
  SetLength(LSnapshot, FListeners.Count);
  for I := 0 to FListeners.Count - 1 do
  begin
    LSnapshot[I].Changing := FListeners[I].Changing;
    LSnapshot[I].Changed := FListeners[I].Changed;
  end;
  // A subscriber can unsubscribe itself or another subscriber in a callback.
  // Copy method pointers, not subscription objects, and skip removed entries.
  for I := 0 to High(LSnapshot) do
    for J := 0 to FListeners.Count - 1 do
      if SameNotifyEvent(LSnapshot[I].Changing, FListeners[J].Changing)
        and SameNotifyEvent(LSnapshot[I].Changed, FListeners[J].Changed) then
      begin
        if AChanging then
          LCallback := LSnapshot[I].Changing
        else
          LCallback := LSnapshot[I].Changed;
        if Assigned(LCallback) then
          LCallback(Self);
        Break;
      end;
end;

procedure Th5uStructureView.DoLoaded;
begin
  if Assigned(FOnLoaded) then
    FOnLoaded(Self);
end;

procedure Th5uStructureView.Loaded;
begin
  inherited;
  Reload;
end;

procedure Th5uStructureView.CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList);
var
  I: Integer;
begin
  if FResolveByOwner then
    for I := 0 to AComponent.ComponentCount - 1 do
      if AComponent.Components[I] <> Self then
        AChildren.Add(AComponent.Components[I]);
end;

procedure Th5uStructureView.AddChildren(AItem: Th5uStructureItem);
var
  LChildren: Th5uComponentList;
  LChild: TComponent;
begin
  LChildren := Th5uComponentList.Create;
  try
    CollectChildren(AItem.Component, LChildren);
    for LChild in LChildren do
      AddComponent(LChild, AItem, True);
  finally
    LChildren.Free;
  end;
end;

function Th5uStructureView.AddComponent(AComponent: TComponent; AParent: Th5uStructureItem; AIncludeChildren: Boolean): Th5uStructureItem;
begin
  Result := nil;
  if (AComponent = nil) or (AComponent = Self) or (csDestroying in AComponent.ComponentState) then
    Exit;
  if (AParent <> nil) and (FAllItems.IndexOf(AParent) < 0) then
    raise EArgumentException.Create('The parent row does not belong to this structure view.');
  Result := FindComponent(AComponent);
  // Identity deduplication also terminates cycles in custom child resolvers.
  if Result <> nil then
    Exit;
  BeginUpdate;
  try
    Result := Th5uStructureItem.Create;
    Result.FComponent := AComponent;
    Result.FParent := AParent;
    Result.FID := FNextID;
    Result.FImageIndex := -1;
    Inc(FNextID);
    FAllItems.Add(Result);
    AComponent.FreeNotification(Self);
    if AIncludeChildren then
      AddChildren(Result);
  finally
    EndUpdate;
  end;
end;

function Th5uStructureView.FindComponent(AComponent: TComponent): Th5uStructureItem;
var
  LItem: Th5uStructureItem;
begin
  Result := nil;
  for LItem in FAllItems do
    if LItem.Component = AComponent then
      Exit(LItem);
end;

function Th5uStructureView.FindItemByID(AID: Integer): Th5uStructureItem;
var
  LItem: Th5uStructureItem;
begin
  Result := nil;
  for LItem in FAllItems do
    if LItem.ID = AID then
      Exit(LItem);
end;

procedure Th5uStructureView.ClearItems;
var
  LItem: Th5uStructureItem;
begin
  FComponentList.Clear;
  for LItem in FAllItems do
    if LItem.Component <> FRootComponent then
      LItem.Component.RemoveFreeNotification(Self);
  FAllItems.Clear;
end;

procedure Th5uStructureView.Clear;
begin
  BeginUpdate;
  try
    ClearItems;
    SelectComponent(nil);
    if Assigned(FOnCleared) then
      FOnCleared(Self);
  finally
    EndUpdate;
  end;
end;

procedure Th5uStructureView.Reload;
begin
  if FReloading or FDestroying or (csLoading in ComponentState) then
    Exit;
  FReloading := True;
  try
    BeginUpdate;
    try
      ClearItems;
      AddComponent(FRootComponent, nil, True);
      DoLoaded;
      if FindComponent(FSelectedComponent) = nil then
        SelectComponent(nil);
    finally
      EndUpdate;
    end;
  finally
    FReloading := False;
  end;
end;

procedure Th5uStructureView.SetRootComponent(AValue: TComponent);
begin
  if FRootComponent = AValue then
    Exit;
  if AValue = Self then
    raise EArgumentException.Create('A structure view cannot be its own root.');
  BeginUpdate;
  try
    ClearItems;
    if FRootComponent <> nil then
      FRootComponent.RemoveFreeNotification(Self);
    FRootComponent := AValue;
    if FRootComponent <> nil then
      FRootComponent.FreeNotification(Self);
    Reload;
  finally
    EndUpdate;
  end;
end;

procedure Th5uStructureView.SetResolveByOwner(AValue: Boolean);
begin
  if FResolveByOwner = AValue then
    Exit;
  FResolveByOwner := AValue;
  Reload;
end;

procedure Th5uStructureView.SetResolveByParent(AValue: Boolean);
begin
  if FResolveByParent = AValue then
    Exit;
  FResolveByParent := AValue;
  Reload;
end;

procedure Th5uStructureView.SetFilterText(const AValue: string);
begin
  if FFilterText = AValue then
    Exit;
  // Compile before detaching the list, so a malformed mask leaves it intact.
  h5uMatchesMask('', AValue);
  BeginUpdate;
  try
    FFilterText := AValue;
  finally
    EndUpdate;
  end;
end;

procedure Th5uStructureView.ApplyFilter;
var
  LItem, LParent: Th5uStructureItem;
  LMask: string;
begin
  FComponentList.Clear;
  LMask := Trim(FFilterText);
  if (Pos('*', LMask) = 0) and (Pos('?', LMask) = 0) and (Pos('[', LMask) = 0) then
    LMask := '*' + LMask + '*';
  for LItem in FAllItems do
    LItem.FVisible := False;
  for LItem in FAllItems do
    if h5uMatchesMask(LItem.Name, LMask) or h5uMatchesMask(LItem.ComponentClassName, LMask) then
    begin
      LParent := LItem;
      while LParent <> nil do
      begin
        LParent.FVisible := True;
        LParent := LParent.Parent;
      end;
    end;
  AppendVisibleChildren(nil);
end;

procedure Th5uStructureView.AppendVisibleChildren(AParent: Th5uStructureItem);
var
  LItem: Th5uStructureItem;
begin
  // OnLoaded can append children to an earlier branch. Present them beside
  // that branch, rather than at the end of the flat ObjectListController.
  for LItem in FAllItems do
    if LItem.Visible and (LItem.Parent = AParent) then
    begin
      FComponentList.Add(LItem);
      AppendVisibleChildren(LItem);
    end;
end;

procedure Th5uStructureView.SelectComponent(AComponent: TComponent);
begin
  if (AComponent <> nil) and (FindComponent(AComponent) = nil) then
    raise EArgumentException.Create('The selected component does not belong to this structure view.');
  if FSelectedComponent = AComponent then
    Exit;
  FSelectedComponent := AComponent;
  if not FDestroying and Assigned(FOnSelect) then
    FOnSelect(Self, FSelectedComponent);
end;

procedure Th5uStructureView.RemoveBranch(AComponent: TComponent);
var
  I: Integer;
  LItem, LParent: Th5uStructureItem;
begin
  BeginUpdate;
  try
    FComponentList.Clear;
    // Children follow their parents: reverse deletion keeps Parent valid.
    for I := FAllItems.Count - 1 downto 0 do
    begin
      LItem := FAllItems[I];
      LParent := LItem;
      while (LParent <> nil) and (LParent.Component <> AComponent) do
        LParent := LParent.Parent;
      if LParent = nil then
        Continue;
      if FSelectedComponent = LItem.Component then
        SelectComponent(nil);
      if LItem.Component <> AComponent then
        LItem.Component.RemoveFreeNotification(Self);
      FAllItems.Delete(I);
    end;
  finally
    EndUpdate;
  end;
end;

procedure Th5uStructureView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation <> opRemove) or FDestroying or (FAllItems = nil) then
    Exit;
  if AComponent = FRootComponent then
  begin
    FRootComponent := nil;
    Clear;
  end
  else if FindComponent(AComponent) <> nil then
    RemoveBranch(AComponent);
end;

procedure Th5uStructureView.AddChangeListener(AChanging, AChanged: TNotifyEvent);
var
  LListener: Th5uStructureChangeListener;
begin
  for LListener in FListeners do
    if SameNotifyEvent(LListener.Changing, AChanging) and SameNotifyEvent(LListener.Changed, AChanged) then
      Exit;
  LListener := Th5uStructureChangeListener.Create;
  LListener.Changing := AChanging;
  LListener.Changed := AChanged;
  FListeners.Add(LListener);
end;

procedure Th5uStructureView.RemoveChangeListener(AChanging, AChanged: TNotifyEvent);
var
  I: Integer;
begin
  for I := FListeners.Count - 1 downto 0 do
    if SameNotifyEvent(FListeners[I].Changing, AChanging)
      and SameNotifyEvent(FListeners[I].Changed, AChanged) then
      FListeners.Delete(I);
end;

{$ENDIF}

end.
