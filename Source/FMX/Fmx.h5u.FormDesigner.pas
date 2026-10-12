unit Fmx.h5u.FormDesigner;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Fmx.Controls, Fmx.Types, Fmx.Layouts, Fmx.Edit, Fmx.ComboEdit,
  h5u.FormDesigner, h5u.FormDesigner.Properties,
  h5u.Grid.Columns, h5u.Grid.Types, h5u.Grid.Sizing, h5u.Grid.Data.Objects,
  Fmx.h5u.Grid, Fmx.h5u.Grid.Editors;

type
  Th5uFmxStructureModel = class(Th5uStructureView)
  protected
    procedure CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList); override;
  end;

  // The grid borrows the model's items. The model owns their lifetime and values.
  Th5uFmxPropertyEditor = class(Th5uFmxCustomGrid)
  private
    FPropertyEditor: Th5uPropertyEditor;
    FObjectListController: Th5uPropertyListController;
    FNeedsRebind: Boolean;
    FShowGroups: Boolean;
    FGroupStates: TDictionary<Integer, Boolean>;
    procedure GroupStateChanged(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext);
    procedure RestoreGroupStates;
    procedure SetShowGroups(AValue: Boolean);
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure ModelItemChanged(Sender: TObject; AItem: Th5uPropertyItem);
    procedure CanEditProperty(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AAllow: Boolean);
    procedure ShowValueEditor(Sender: TObject);
    function ItemAtRow(ARowIndex: Int64): Th5uPropertyItem;
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    function GetGrid: Th5uFmxPropertyEditor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure ResetAdjacentGroupStates; reintroduce;
    property DataObject: TObject read GetDataObject write SetDataObject;

    property ObjectListController: Th5uPropertyListController read FObjectListController;
    property Grid: Th5uFmxPropertyEditor read GetGrid;
  published
    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property PropertyEditor: Th5uPropertyEditor read FPropertyEditor;
    property ShowGroups: Boolean read FShowGroups write SetShowGroups default True;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property Columns;
    property Appearance;
    property RowHeight;
    [Th5uLegacyOption]
    property ShowHeader;
    property GridLines;
  end;

  Th5uFmxStructureSelectEvent = procedure(Sender: TObject; AComponent: TComponent) of object;

  Th5uFmxStructureView = class(TLayout)
  private
    FStructureView: Th5uFmxStructureModel;
    FObjectListController: Th5uObjectListController;
    FGrid: Th5uFmxGrid;
    FFilterEdit: TEdit;
    FUpdating: Boolean;
    FFilterError: string;
    FLoadingRoot: TComponent;
    FLoadingRootAssigned: Boolean;
    FOnSelect: Th5uFmxStructureSelectEvent;
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure GetNameValue(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
    function ItemAtRow(ARowIndex: Int64): Th5uStructureItem;
    function GetRootComponent: TComponent;
    procedure SetRootComponent(AValue: TComponent);
    function GetFilterText: string;
    procedure SetFilterText(const AValue: string);
    function GetResolveByOwner: Boolean;
    procedure SetResolveByOwner(AValue: Boolean);
    function GetResolveByParent: Boolean;
    procedure SetResolveByParent(AValue: Boolean);
    function GetOnLoaded: TNotifyEvent;
    procedure SetOnLoaded(AValue: TNotifyEvent);
    function GetSelectedComponent: TComponent;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    property StructureView: Th5uFmxStructureModel read FStructureView;
    property ObjectListController: Th5uObjectListController read FObjectListController;
    property Grid: Th5uFmxGrid read FGrid;
    property FilterEdit: TEdit read FFilterEdit;
    property SelectedComponent: TComponent read GetSelectedComponent;
    property FilterError: string read FFilterError;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property RootComponent: TComponent read GetRootComponent write SetRootComponent;
    property ResolveByOwner: Boolean read GetResolveByOwner write SetResolveByOwner default True;
    property ResolveByParent: Boolean read GetResolveByParent write SetResolveByParent default True;
    property FilterText: string read GetFilterText write SetFilterText;
    property OnLoaded: TNotifyEvent read GetOnLoaded write SetOnLoaded;
    property OnSelect: Th5uFmxStructureSelectEvent read FOnSelect write FOnSelect;
  end;

  Th5uFmxEventEditor = class(Th5uFmxCustomGrid)
  private
//    FPropertyEditor: Th5uFmxPropertyEditor
//    procedure SetPropertyEditor(Value: Th5uFmxPropertyEditor);
  protected
  public
  published
//    property PropertyEditor: Th5uFmxPropertyEditor
//    property PropertyEditor: Th5uFmxPropertyEditor read FPropertyEditor write SetPropertyEditor;
  end;

  { Component Palette }

  Th5uFmxComponentPaletteOld = class(TComponent)
  private
    {TToolBar}
  protected
  public
  published
  end;

  Th5uFmxComponentPalette = class(TComponent)
  private
    {TListView}
  protected
  public
  published
  end;

implementation

procedure Th5uFmxStructureModel.CollectChildren(AComponent: TComponent; AChildren: Th5uComponentList);
var
  I: Integer;
begin
  // Inspector implementation components are not part of the inspected form.
  if (AComponent is Th5uFmxStructureView) or (AComponent is Th5uFmxPropertyEditor) then
    Exit;
  if ResolveByParent and (AComponent is TFmxObject) then
    for I := 0 to TFmxObject(AComponent).ChildrenCount - 1 do
      AChildren.Add(TFmxObject(AComponent).Children[I]);
  inherited;
end;

constructor Th5uFmxPropertyEditor.Create(AOwner: TComponent);
var
  LColumn: Th5uGridColumn;
  LEditor: Th5uFmxCustomEditor;
begin
  inherited;
  Width := 350;
  ColumnSizing.FitMode := Th5uColumnFitMode.AllColumns;
  FGroupStates := TDictionary<Integer, Boolean>.Create;
  FObjectListController := Th5uPropertyListController.Create(Self);
  FPropertyEditor := FObjectListController.PropertyEditor;
  FPropertyEditor.AddChangeListener(ModelChanging, ModelChanged, ModelItemChanged);
  FNeedsRebind := True;
  FShowGroups := True;
  AdjacentGroupFolding.IdColumnId := 'GroupName';
  AdjacentGroupFolding.GroupEmptyValues := False;
  OnAdjacentGroupStateChanged := GroupStateChanged;
  RowIndicator.Visible := False;
  Customization.AllowRowMoving := False;
  Customization.AllowColumnHiding := False;
  Customization.ShowColumnChooser := False;
  LColumn := Columns.Add;
  LColumn.Id := 'Name';
  LColumn.FieldName := 'Caption';
  LColumn.Caption := 'Property';
  LColumn.Width := -60;
  LColumn.ReadOnly := True;
  LColumn := Columns.Add;
  LColumn.Id := 'Value';
  LColumn.FieldName := 'DisplayValue';
  LColumn.Caption := 'Value';
  LColumn.Width := -40;
  LColumn.DataType := Th5uColumnDataType.Text;
  LColumn.Editor := 'PropertyValue';
  OnCanEdit := CanEditProperty;
  LEditor := Editors.AddVariant('PropertyValue', 'TextEditor');
  LEditor.ControlClass := TComboEdit;
  LEditor.OnShow := ShowValueEditor;
  ModelChanged(FPropertyEditor);
end;

destructor Th5uFmxPropertyEditor.Destroy;
begin
  if Assigned(FPropertyEditor) then
    FPropertyEditor.RemoveChangeListener(ModelChanging, ModelChanged, ModelItemChanged);
  DataController := nil;
  FPropertyEditor := nil;
  FreeAndNil(FObjectListController);
  FreeAndNil(FGroupStates);
  inherited;
end;

procedure Th5uFmxPropertyEditor.ModelChanging(Sender: TObject);
begin
  // Detach before a Reload frees any item, including an item being edited.
  FNeedsRebind := True;
  DataController := nil;
  FObjectListController.Clear;
end;

procedure Th5uFmxPropertyEditor.ModelChanged(Sender: TObject);
begin
  if not FNeedsRebind then
    Exit;
  FObjectListController.RebuildItems(FShowGroups);
  AdjacentGroupFolding.Enabled := FShowGroups and FObjectListController.HasGroups;
  FNeedsRebind := False;
  DataController := FObjectListController;
  RestoreGroupStates;
end;

procedure Th5uFmxPropertyEditor.SetShowGroups(AValue: Boolean);
begin
  if FShowGroups = AValue then
    Exit;
  FShowGroups := AValue;
  ModelChanging(Self);
  ModelChanged(Self);
end;

procedure Th5uFmxPropertyEditor.GroupStateChanged(Sender: TObject;
  const AContext: Th5uAdjacentGroupStateChangedContext);
var
  LID: Integer;
begin
  if TryStrToInt(AContext.AnchorRowKey.ToString, LID) and (LID < 0) then
    FGroupStates.AddOrSetValue(LID, AContext.Collapsed);
end;

procedure Th5uFmxPropertyEditor.ResetAdjacentGroupStates;
begin
  FGroupStates.Clear;
  inherited;
end;

procedure Th5uFmxPropertyEditor.RestoreGroupStates;
var
  LRow, LIndex: Int64;
  LItem: TObject;
  LCollapsed: Boolean;
begin
  if not FObjectListController.HasGroups or (FGroupStates.Count = 0) then
    Exit;
  LRow := 0;
  while LRow < FObjectListController.Count do
  begin
    LIndex := GetViewSourceRowIndex(LRow);
    if (LIndex < 0) or (LIndex >= FObjectListController.Count) then
      Break;
    LItem := FObjectListController.Item(LIndex);
    if (LItem is Th5uPropertyGroupRow)
      and FGroupStates.TryGetValue(Th5uPropertyGroupRow(LItem).ID, LCollapsed) and LCollapsed then
      SetAdjacentGroupCollapsed(LRow, True);
    Inc(LRow);
  end;
end;

procedure Th5uFmxPropertyEditor.ModelItemChanged(Sender: TObject; AItem: Th5uPropertyItem);
begin
  if not FNeedsRebind then
    FObjectListController.NotifyObjectChanged(AItem);
end;

function Th5uFmxPropertyEditor.ItemAtRow(ARowIndex: Int64): Th5uPropertyItem;
var
  LIndex: Int64;
begin
  Result := nil;
  LIndex := GetViewSourceRowIndex(ARowIndex);
  if (LIndex >= 0) and (LIndex < FObjectListController.Count)
    and (FObjectListController.Item(LIndex) is Th5uPropertyItem) then
    Result := Th5uPropertyItem(FObjectListController.Item(LIndex));
end;

procedure Th5uFmxPropertyEditor.CanEditProperty(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AAllow: Boolean);
var
  LItem: Th5uPropertyItem;
begin
  LItem := ItemAtRow(ARowIndex);
  AAllow := AAllow and Assigned(LItem);
  if AAllow then
    AAllow := LItem.CanEdit;
end;

procedure Th5uFmxPropertyEditor.ShowValueEditor(Sender: TObject);
var
  LEditor: Th5uFmxCustomEditor;
  LItem: Th5uPropertyItem;
  LText: string;
begin
  LEditor := Th5uFmxCustomEditor(Sender);
  LItem := ItemAtRow(LEditor.Context.RowIndex);
  if Assigned(LItem) and (LEditor.Control is TComboEdit) then
  begin
    LText := LEditor.GetText;
    LItem.GetComboList(TComboEdit(LEditor.Control).Items);
    LEditor.SetText(LText);
  end;
end;

function Th5uFmxPropertyEditor.GetDataObject: TObject;
begin
  Result := FPropertyEditor.DataObject;
end;

procedure Th5uFmxPropertyEditor.SetDataObject(AValue: TObject);
begin
  FPropertyEditor.DataObject := AValue;
end;

function Th5uFmxPropertyEditor.GetGrid: Th5uFmxPropertyEditor;
begin
  Result := Self;
end;

procedure Th5uFmxPropertyEditor.Reload;
begin
  FPropertyEditor.Reload;
end;

constructor Th5uFmxStructureView.Create(AOwner: TComponent);
var
  LColumn: Th5uGridColumn;
begin
  inherited;
  Width := 360;
  Height := 280;
  FObjectListController := Th5uObjectListController.Create(Self);
  FObjectListController.KeyPropertyName := 'ID';
  FObjectListController.OwnsObjects := False;
  FStructureView := Th5uFmxStructureModel.Create(Self);
  FStructureView.AddChangeListener(ModelChanging, ModelChanged);
  FGrid := Th5uFmxGrid.Create(Self);
  FGrid.Stored := False;
  FGrid.Parent := Self;
  FGrid.Align := TAlignLayout.Client;
  FGrid.AllowEditing := False;
  FGrid.ShowRowIndicator := False;
  FGrid.Customization.AllowRowMoving := False;
  FGrid.Tree.Enabled := True;
  FGrid.Tree.LevelColumnId := 'Level';
  LColumn := FGrid.Columns.Add;
  LColumn.Id := 'Name';
  LColumn.FieldName := 'Name';
  LColumn.Caption := 'Component';
  LColumn.Width := 190;
  LColumn.OnGetValue := GetNameValue;
  LColumn := FGrid.Columns.Add;
  LColumn.Id := 'Class';
  LColumn.FieldName := 'ComponentClassName';
  LColumn.Caption := 'Class';
  LColumn.Width := 150;
  FGrid.OnSelectionChange := SelectionChanged;
  FFilterEdit := TEdit.Create(Self);
  FFilterEdit.Stored := False;
  FFilterEdit.Parent := Self;
  FFilterEdit.Align := TAlignLayout.Top;
  FFilterEdit.TextPrompt := 'Filter components';
  FFilterEdit.OnChangeTracking := FilterChanged;
  ModelChanged(FStructureView);
end;

destructor Th5uFmxStructureView.Destroy;
begin
  if Assigned(FStructureView) then
    FStructureView.RemoveChangeListener(ModelChanging, ModelChanged);
  if Assigned(FGrid) then
  begin
    FGrid.OnSelectionChange := nil;
    FGrid.DataController := nil;
  end;
  FreeAndNil(FGrid);
  FreeAndNil(FFilterEdit);
  FreeAndNil(FObjectListController);
  FreeAndNil(FStructureView);
  inherited;
end;

procedure Th5uFmxStructureView.ModelChanging(Sender: TObject);
begin
  FUpdating := True;
  FGrid.DataController := nil;
  FGrid.Selection.Clear;
  FObjectListController.Clear;
end;

procedure Th5uFmxStructureView.ModelChanged(Sender: TObject);
var
  LItem: Th5uStructureItem;
  LAddress: Th5uCellAddress;
  I: Integer;
begin
  FUpdating := True;
  try
    FObjectListController.BeginUpdate;
    try
      FObjectListController.Clear;
      for LItem in FStructureView.ComponentList do
        FObjectListController.Add(LItem);
    finally
      FObjectListController.EndUpdate;
    end;
    FGrid.DataController := FObjectListController;
    FFilterEdit.Text := FStructureView.FilterText;
    FFilterError := '';
    FFilterEdit.Hint := '';
    FFilterEdit.ShowHint := False;
    for I := 0 to FObjectListController.Count - 1 do
      if Th5uStructureItem(FObjectListController.Item(I)).Component = FStructureView.SelectedComponent then
      begin
        LAddress := Th5uCellAddress.Empty;
        LAddress.RowIndex := I;
        LAddress.ColumnIndex := 0;
        LAddress.ColumnId := 'Name';
        LAddress.RowKey := FObjectListController.GetRowKey(I);
        FGrid.Selection.SetFocus(LAddress, True);
        Break;
      end;
  finally
    FUpdating := False;
  end;
end;

procedure Th5uFmxStructureView.FilterChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  try
    FStructureView.FilterText := FFilterEdit.Text;
    FFilterError := '';
    FFilterEdit.Hint := '';
    FFilterEdit.ShowHint := False;
  except
    on E: EMaskException do
    begin
      // A partially typed bracket expression must not open an exception dialog.
      // Keep the last valid result and the text so the user can finish the mask.
      FFilterError := E.Message;
      FFilterEdit.Hint := FFilterError;
      FFilterEdit.ShowHint := True;
    end;
  end;
end;

function Th5uFmxStructureView.ItemAtRow(ARowIndex: Int64): Th5uStructureItem;
var
  LIndex: Int64;
begin
  Result := nil;
  LIndex := FObjectListController.GetSourceRowIndex(ARowIndex);
  if (LIndex >= 0) and (LIndex < FObjectListController.Count) then
    Result := Th5uStructureItem(FObjectListController.Item(LIndex));
end;

procedure Th5uFmxStructureView.GetNameValue(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
var
  LItem: Th5uStructureItem;
begin
  LItem := ItemAtRow(ARowIndex);
  if ADisplayValue and Assigned(LItem) then
    AValue := StringOfChar(' ', LItem.Level * 3) + LItem.Name;
end;

function Th5uFmxStructureView.GetSelectedComponent: TComponent;
var
  LItem: Th5uStructureItem;
begin
  Result := nil;
  LItem := ItemAtRow(FGrid.Selection.FocusedCell.RowIndex);
  if Assigned(LItem) then
    Result := LItem.Component;
end;

procedure Th5uFmxStructureView.SelectionChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  FStructureView.SelectComponent(SelectedComponent);
  if Assigned(FOnSelect) then
    FOnSelect(Self, SelectedComponent);
end;

function Th5uFmxStructureView.GetRootComponent: TComponent;
begin
  if FLoadingRootAssigned then
    Result := FLoadingRoot
  else
    Result := FStructureView.RootComponent;
end;

procedure Th5uFmxStructureView.SetRootComponent(AValue: TComponent);
begin
  if csLoading in ComponentState then
  begin
    FLoadingRoot := AValue;
    FLoadingRootAssigned := True;
  end
  else
    FStructureView.RootComponent := AValue;
end;

function Th5uFmxStructureView.GetFilterText: string;
begin
  Result := FStructureView.FilterText;
end;

procedure Th5uFmxStructureView.SetFilterText(const AValue: string);
begin
  FStructureView.FilterText := AValue;
end;

function Th5uFmxStructureView.GetResolveByOwner: Boolean;
begin
  Result := FStructureView.ResolveByOwner;
end;

procedure Th5uFmxStructureView.SetResolveByOwner(AValue: Boolean);
begin
  FStructureView.ResolveByOwner := AValue;
end;

function Th5uFmxStructureView.GetResolveByParent: Boolean;
begin
  Result := FStructureView.ResolveByParent;
end;

procedure Th5uFmxStructureView.SetResolveByParent(AValue: Boolean);
begin
  FStructureView.ResolveByParent := AValue;
end;

function Th5uFmxStructureView.GetOnLoaded: TNotifyEvent;
begin
  Result := FStructureView.OnLoaded;
end;

procedure Th5uFmxStructureView.SetOnLoaded(AValue: TNotifyEvent);
begin
  FStructureView.OnLoaded := AValue;
end;

procedure Th5uFmxStructureView.Loaded;
begin
  inherited;
  if FLoadingRootAssigned then
  begin
    FLoadingRootAssigned := False;
    FStructureView.RootComponent := FLoadingRoot;
    FLoadingRoot := nil;
  end
  else
    FStructureView.Reload;
end;

procedure Th5uFmxStructureView.Reload;
begin
  FStructureView.Reload;
end;

end.

