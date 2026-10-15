unit h5u.FormDesigner;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$CODEPAGE UTF8}
{$ELSE}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}
{$ENDIF}

interface

// FPC/LCL support awaits its extended RTTI implementation.
{$IFnDEF FPC}
uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Masks;

type
  TComponentEvent = procedure(Sender: TObject; Component: TComponent) of object;
  TComponentMoveEvent = procedure(Sender: TObject; Component, OldParent, NewParent: TComponent) of object;
  ThiiComponentList = TList<TComponent>;

  ThiiStructureItem = class(TPersistent)
  private
    FComponent: TComponent;
    FParent: ThiiStructureItem;
    FID: Integer;
    FImageIndex: Integer;
    FVisible: Boolean;
    function GetParentID: Integer;
    function GetLevel: Integer;
    function GetName: string;
    function GetComponentClassName: string;
  public
    property Component: TComponent read FComponent;
    property Parent: ThiiStructureItem read FParent;
    property Visible: Boolean read FVisible;
  published
    property ID: Integer read FID;
    property ParentID: Integer read GetParentID;
    property Level: Integer read GetLevel;
    property Name: string read GetName;
    property ComponentClassName: string read GetComponentClassName;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
  end;

  ThiiStructureItems = TObjectList<ThiiStructureItem>;
  Th5uStructureChangeListener = class
  public
    Changing: TNotifyEvent;
    Changed: TNotifyEvent;
  end;
  Th5uStructureChangeEvents = record
    Changing, Changed: TNotifyEvent;
  end;

  ThiiStructureModel = class(TComponent)
  public type
    TElement = ThiiStructureItem;
  private
    FAllItems: ThiiStructureItems;
    FComponentList: ThiiStructureItems;
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
    procedure AppendVisibleChildren(AParent: ThiiStructureItem);
    procedure ClearItems;
    procedure AddChildren(AItem: ThiiStructureItem);
    procedure RemoveBranch(AComponent: TComponent);
    procedure NotifyListeners(AChanging: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    // Framework adapters append visual children first, then call inherited.
    procedure CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList); virtual;
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
    function AddComponent(AComponent: TComponent; AParent: ThiiStructureItem = nil; AIncludeChildren: Boolean = False): ThiiStructureItem;
    function FindComponent(AComponent: TComponent): ThiiStructureItem; reintroduce;
    function FindItemByID(AID: Integer): ThiiStructureItem;
    procedure SelectComponent(AComponent: TComponent);
    procedure AddChangeListener(AChanging, AChanged: TNotifyEvent);
    procedure RemoveChangeListener(AChanging, AChanged: TNotifyEvent);
    // Treat these lists as read-only; use AddComponent to add rows in OnLoaded.
    // Rows never own the represented components.
    property ComponentList: ThiiStructureItems read FComponentList;
    property AllItems: ThiiStructureItems read FAllItems;
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
  ThiiEventEditor = class(TComponent);
  ThiiComponentPalette = class(TComponent);
  ThiiFormDesigner = class(TComponent);

{$ENDIF}

implementation

{$IFnDEF FPC}
function SameNotifyEvent(A, B: TNotifyEvent): Boolean;
begin
  Result := (TMethod(A).Code = TMethod(B).Code) and (TMethod(A).Data = TMethod(B).Data);
end;

function ThiiStructureItem.GetParentID: Integer;
begin
  if FParent = nil then
    Result := 0
  else
    Result := FParent.ID;
end;

function ThiiStructureItem.GetLevel: Integer;
var
  LParent: ThiiStructureItem;
begin
  Result := 0;
  LParent := FParent;
  while LParent <> nil do
  begin
    Inc(Result);
    LParent := LParent.Parent;
  end;
end;

function ThiiStructureItem.GetName: string;
begin
  Result := FComponent.Name;
  if Result = '' then
    Result := FComponent.ClassName;
end;

function ThiiStructureItem.GetComponentClassName: string;
begin
  Result := FComponent.ClassName;
end;

constructor ThiiStructureModel.Create(AOwner: TComponent);
begin
  inherited;
  FAllItems := ThiiStructureItems.Create(True);
  FComponentList := ThiiStructureItems.Create(False);
  FListeners := TObjectList<Th5uStructureChangeListener>.Create(True);
  FResolveByOwner := True;
  FResolveByParent := True;
  FNextID := 1;
end;

destructor ThiiStructureModel.Destroy;
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

procedure ThiiStructureModel.BeginUpdate;
begin
  if FUpdateCount = 0 then
    DoChanging;
  Inc(FUpdateCount);
end;

procedure ThiiStructureModel.EndUpdate;
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

procedure ThiiStructureModel.DoChanging;
begin
  if FDestroying then
    Exit;
  NotifyListeners(True);
  if Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure ThiiStructureModel.DoChange;
begin
  if FDestroying then
    Exit;
  NotifyListeners(False);
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure ThiiStructureModel.NotifyListeners(AChanging: Boolean);
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
      if SameNotifyEvent(LSnapshot[I].Changing, FListeners[J].Changing) and SameNotifyEvent(LSnapshot[I].Changed, FListeners[J].Changed) then
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

procedure ThiiStructureModel.DoLoaded;
begin
  if Assigned(FOnLoaded) then
    FOnLoaded(Self);
end;

procedure ThiiStructureModel.Loaded;
begin
  inherited;
  Reload;
end;

procedure ThiiStructureModel.CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList);
var
  I: Integer;
begin
  if FResolveByOwner then
    for I := 0 to AComponent.ComponentCount - 1 do
      if AComponent.Components[I] <> Self then
        AChildren.Add(AComponent.Components[I]);
end;

procedure ThiiStructureModel.AddChildren(AItem: ThiiStructureItem);
var
  LChildren: ThiiComponentList;
  LChild: TComponent;
begin
  LChildren := ThiiComponentList.Create;
  try
    CollectChildren(AItem.Component, LChildren);
    for LChild in LChildren do
      AddComponent(LChild, AItem, True);
  finally
    LChildren.Free;
  end;
end;

function ThiiStructureModel.AddComponent(AComponent: TComponent; AParent: ThiiStructureItem; AIncludeChildren: Boolean): ThiiStructureItem;
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
    Result := ThiiStructureItem.Create;
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

function ThiiStructureModel.FindComponent(AComponent: TComponent): ThiiStructureItem;
var
  LItem: ThiiStructureItem;
begin
  Result := nil;
  for LItem in FAllItems do
    if LItem.Component = AComponent then
      Exit(LItem);
end;

function ThiiStructureModel.FindItemByID(AID: Integer): ThiiStructureItem;
var
  LItem: ThiiStructureItem;
begin
  Result := nil;
  for LItem in FAllItems do
    if LItem.ID = AID then
      Exit(LItem);
end;

procedure ThiiStructureModel.ClearItems;
var
  LItem: ThiiStructureItem;
begin
  FComponentList.Clear;
  for LItem in FAllItems do
    if LItem.Component <> FRootComponent then
      LItem.Component.RemoveFreeNotification(Self);
  FAllItems.Clear;
end;

procedure ThiiStructureModel.Clear;
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

procedure ThiiStructureModel.Reload;
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

procedure ThiiStructureModel.SetRootComponent(AValue: TComponent);
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

procedure ThiiStructureModel.SetResolveByOwner(AValue: Boolean);
begin
  if FResolveByOwner = AValue then
    Exit;
  FResolveByOwner := AValue;
  Reload;
end;

procedure ThiiStructureModel.SetResolveByParent(AValue: Boolean);
begin
  if FResolveByParent = AValue then
    Exit;
  FResolveByParent := AValue;
  Reload;
end;

procedure ThiiStructureModel.SetFilterText(const AValue: string);
begin
  if FFilterText = AValue then
    Exit;
  // Compile before detaching the list, so a malformed mask leaves it intact.
  System.Masks.MatchesMask('', AValue);
  BeginUpdate;
  try
    FFilterText := AValue;
  finally
    EndUpdate;
  end;
end;

procedure ThiiStructureModel.ApplyFilter;
var
  LItem, LParent: ThiiStructureItem;
  LMask: string;
begin
  FComponentList.Clear;
  LMask := Trim(FFilterText);
  if (Pos('*', LMask) = 0) and (Pos('?', LMask) = 0) and (Pos('[', LMask) = 0) then
    LMask := '*' + LMask + '*';
  for LItem in FAllItems do
    LItem.FVisible := False;
  for LItem in FAllItems do
    if System.Masks.MatchesMask(LItem.Name, LMask) or System.Masks.MatchesMask(LItem.ComponentClassName, LMask) then
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

procedure ThiiStructureModel.AppendVisibleChildren(AParent: ThiiStructureItem);
var
  LItem: ThiiStructureItem;
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

procedure ThiiStructureModel.SelectComponent(AComponent: TComponent);
begin
  if (AComponent <> nil) and (FindComponent(AComponent) = nil) then
    raise EArgumentException.Create('The selected component does not belong to this structure view.');
  if FSelectedComponent = AComponent then
    Exit;
  FSelectedComponent := AComponent;
  if not FDestroying and Assigned(FOnSelect) then
    FOnSelect(Self, FSelectedComponent);
end;

procedure ThiiStructureModel.RemoveBranch(AComponent: TComponent);
var
  I: Integer;
  LItem, LParent: ThiiStructureItem;
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

procedure ThiiStructureModel.Notification(AComponent: TComponent; Operation: TOperation);
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

procedure ThiiStructureModel.AddChangeListener(AChanging, AChanged: TNotifyEvent);
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

procedure ThiiStructureModel.RemoveChangeListener(AChanging, AChanged: TNotifyEvent);
var
  I: Integer;
begin
  for I := FListeners.Count - 1 downto 0 do
    if SameNotifyEvent(FListeners[I].Changing, AChanging) and SameNotifyEvent(FListeners[I].Changed, AChanged) then
      FListeners.Delete(I);
end;

{$ENDIF}

end.
