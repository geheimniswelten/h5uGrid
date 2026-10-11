unit Fmx.h5u.PropertyEditor;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Fmx.Controls, Fmx.Types, Fmx.Layouts, Fmx.Edit, Fmx.ComboEdit,
  h5u.PropertyEditor,
  Fmx.h5u.Grid, Fmx.h5u.Grid.Editors;

type
  // Property-editor API; canonical declarations live in the shared model unit.
  EhiiPropertyError = h5u.PropertyEditor.EhiiPropertyError;
  ThiiPropertyModel = h5u.PropertyEditor.ThiiPropertyModel;
  ThiiPropertyItem = h5u.PropertyEditor.ThiiPropertyItem;
  ThiiManualProperty = h5u.PropertyEditor.ThiiManualProperty;
  ThiiPropertySortOrder = h5u.PropertyEditor.ThiiPropertySortOrder;
  ThiiPropertyItemChangedEvent = h5u.PropertyEditor.ThiiPropertyItemChangedEvent;
  ThiiGetPropertyValueEvent = h5u.PropertyEditor.ThiiGetPropertyValueEvent;
  ThiiSetPropertyValueEvent = h5u.PropertyEditor.ThiiSetPropertyValueEvent;
  ThiiValueEditor = h5u.PropertyEditor.ThiiValueEditor;
  ThiiValueEditorClass = h5u.PropertyEditor.ThiiValueEditorClass;
  ThiiWidthValueEditor = h5u.PropertyEditor.ThiiWidthValueEditor;
  ThiiPropertyFilter = h5u.PropertyEditor.ThiiPropertyFilter;
  ThiiPropertyFilters = h5u.PropertyEditor.ThiiPropertyFilters;
  ThiiManualProperties = h5u.PropertyEditor.ThiiManualProperties;
  ThiiPropertyListController = h5u.PropertyEditor.ThiiPropertyListController;

  // The grid borrows the model's items. The model owns their lifetime and values.
  ThiiPropertyEditor = class(ThiiCustomGrid)
  private
    FPropertyEditor: ThiiPropertyModel;
    FObjectListController: ThiiPropertyListController;
    FNeedsRebind: Boolean;
    FShowGroups: Boolean;
    FGroupStates: TDictionary<Integer, Boolean>;
    procedure GroupStateChanged(Sender: TObject; const AContext: ThiiAdjacentGroupStateChangedContext);
    procedure RestoreGroupStates;
    procedure SetShowGroups(AValue: Boolean);
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure ModelItemChanged(Sender: TObject; AItem: ThiiPropertyItem);
    procedure CanEditProperty(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AAllow: Boolean);
    procedure ShowValueEditor(Sender: TObject);
    function ItemAtRow(ARowIndex: Int64): ThiiPropertyItem;
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    function GetGrid: ThiiPropertyEditor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure ResetAdjacentGroupStates; reintroduce;
    property DataObject: TObject read GetDataObject write SetDataObject;

    property ObjectListController: ThiiPropertyListController read FObjectListController;
    property Grid: ThiiPropertyEditor read GetGrid;
  published
    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property PropertyEditor: ThiiPropertyModel read FPropertyEditor;
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
    [ThiiLegacyOption]
    property ShowHeader;
    property GridLines;
  end;

implementation

constructor ThiiPropertyEditor.Create(AOwner: TComponent);
var
  LColumn: ThiiGridColumn;
  LEditor: ThiiFmxCustomEditor;
begin
  inherited;
  Width := 350;
  ColumnSizing.FitMode := ThiiColumnFitMode.AllColumns;
  FGroupStates := TDictionary<Integer, Boolean>.Create;
  FObjectListController := ThiiPropertyListController.Create(Self);
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
  LColumn.DataType := ThiiColumnDataType.Text;
  LColumn.Editor := 'PropertyValue';
  OnCanEdit := CanEditProperty;
  LEditor := Editors.AddVariant('PropertyValue', 'TextEditor');
  LEditor.ControlClass := TComboEdit;
  LEditor.OnShow := ShowValueEditor;
  ModelChanged(FPropertyEditor);
end;

destructor ThiiPropertyEditor.Destroy;
begin
  if Assigned(FPropertyEditor) then
    FPropertyEditor.RemoveChangeListener(ModelChanging, ModelChanged, ModelItemChanged);
  DataController := nil;
  FPropertyEditor := nil;
  FreeAndNil(FObjectListController);
  FreeAndNil(FGroupStates);
  inherited;
end;

procedure ThiiPropertyEditor.ModelChanging(Sender: TObject);
begin
  // Detach before a Reload frees any item, including an item being edited.
  FNeedsRebind := True;
  DataController := nil;
  FObjectListController.Clear;
end;

procedure ThiiPropertyEditor.ModelChanged(Sender: TObject);
begin
  if not FNeedsRebind then
    Exit;
  FObjectListController.RebuildItems(FShowGroups);
  AdjacentGroupFolding.Enabled := FShowGroups and FObjectListController.HasGroups;
  FNeedsRebind := False;
  DataController := FObjectListController;
  RestoreGroupStates;
end;

procedure ThiiPropertyEditor.SetShowGroups(AValue: Boolean);
begin
  if FShowGroups = AValue then
    Exit;
  FShowGroups := AValue;
  ModelChanging(Self);
  ModelChanged(Self);
end;

procedure ThiiPropertyEditor.GroupStateChanged(Sender: TObject; const AContext: ThiiAdjacentGroupStateChangedContext);
var
  LID: Integer;
begin
  if TryStrToInt(AContext.AnchorRowKey.ToString, LID) and (LID < 0) then
    FGroupStates.AddOrSetValue(LID, AContext.Collapsed);
end;

procedure ThiiPropertyEditor.ResetAdjacentGroupStates;
begin
  FGroupStates.Clear;
  inherited;
end;

procedure ThiiPropertyEditor.RestoreGroupStates;
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
    if (LItem is Th5uPropertyGroupRow) and FGroupStates.TryGetValue(Th5uPropertyGroupRow(LItem).ID, LCollapsed) and LCollapsed then
      SetAdjacentGroupCollapsed(LRow, True);
    Inc(LRow);
  end;
end;

procedure ThiiPropertyEditor.ModelItemChanged(Sender: TObject; AItem: ThiiPropertyItem);
begin
  if not FNeedsRebind then
    FObjectListController.NotifyObjectChanged(AItem);
end;

function ThiiPropertyEditor.ItemAtRow(ARowIndex: Int64): ThiiPropertyItem;
var
  LIndex: Int64;
begin
  Result := nil;
  LIndex := GetViewSourceRowIndex(ARowIndex);
  if (LIndex >= 0) and (LIndex < FObjectListController.Count) and (FObjectListController.Item(LIndex) is ThiiPropertyItem) then
    Result := ThiiPropertyItem(FObjectListController.Item(LIndex));
end;

procedure ThiiPropertyEditor.CanEditProperty(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AAllow: Boolean);
var
  LItem: ThiiPropertyItem;
begin
  LItem := ItemAtRow(ARowIndex);
  AAllow := AAllow and Assigned(LItem);
  if AAllow then
    AAllow := LItem.CanEdit;
end;

procedure ThiiPropertyEditor.ShowValueEditor(Sender: TObject);
var
  LEditor: ThiiFmxCustomEditor;
  LItem: ThiiPropertyItem;
  LText: string;
begin
  LEditor := ThiiFmxCustomEditor(Sender);
  LItem := ItemAtRow(LEditor.Context.RowIndex);
  if Assigned(LItem) and (LEditor.Control is TComboEdit) then
  begin
    LText := LEditor.GetText;
    LItem.GetComboList(TComboEdit(LEditor.Control).Items);
    LEditor.SetText(LText);
  end;
end;

function ThiiPropertyEditor.GetDataObject: TObject;
begin
  Result := FPropertyEditor.DataObject;
end;

procedure ThiiPropertyEditor.SetDataObject(AValue: TObject);
begin
  FPropertyEditor.DataObject := AValue;
end;

function ThiiPropertyEditor.GetGrid: ThiiPropertyEditor;
begin
  Result := Self;
end;

procedure ThiiPropertyEditor.Reload;
begin
  FPropertyEditor.Reload;
end;

end.
