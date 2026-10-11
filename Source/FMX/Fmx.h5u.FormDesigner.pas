unit Fmx.h5u.FormDesigner;

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Fmx.Controls, Fmx.Types, Fmx.Layouts, Fmx.Edit, Fmx.ComboEdit,
  h5u.FormDesigner,
  h5u.Grid.Data.Objects,
  Fmx.h5u.Grid;

type
  ThiiFmxStructureModel = class(ThiiStructureModel)
  protected
    procedure CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList); override;
  end;

  ThiiStructureSelectEvent = procedure(Sender: TObject; AComponent: TComponent) of object;

  ThiiStructureView = class(TLayout)
  private
    FStructureView: ThiiFmxStructureModel;
    FObjectListController: ThiiObjectListController;
    FGrid: ThiiGrid;
    FFilterEdit: TEdit;
    FUpdating: Boolean;
    FFilterError: string;
    FLoadingRoot: TComponent;
    FLoadingRootAssigned: Boolean;
    FOnSelect: ThiiStructureSelectEvent;
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure GetNameValue(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
    function ItemAtRow(ARowIndex: Int64): ThiiStructureItem;
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
    property StructureView: ThiiFmxStructureModel read FStructureView;
    property ObjectListController: ThiiObjectListController read FObjectListController;
    property Grid: ThiiGrid read FGrid;
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
    property OnSelect: ThiiStructureSelectEvent read FOnSelect write FOnSelect;
  end;

  ThiiFmxEventEditor = class(ThiiCustomGrid)
  private
  protected
  public
  published
  end;

  { Component Palette }

  Th5uFmxComponentPaletteOld = class(TComponent)
  private
    {TToolBar}
  protected
  public
  published
  end;

  ThiiFmxComponentPalette = class(TComponent)
  private
    {TListView}
  protected
  public
  published
  end;

implementation

procedure ThiiFmxStructureModel.CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList);
var
  I: Integer;
begin
  // Inspector implementation components are not part of the inspected form.
  if (AComponent is ThiiStructureView) or (AComponent is ThiiCustomGrid) then
    Exit;
  if ResolveByParent and (AComponent is TFmxObject) then
    for I := 0 to TFmxObject(AComponent).ChildrenCount - 1 do
      AChildren.Add(TFmxObject(AComponent).Children[I]);
  inherited;
end;

constructor ThiiStructureView.Create(AOwner: TComponent);
var
  LColumn: ThiiGridColumn;
begin
  inherited;
  Width := 360;
  Height := 280;
  FObjectListController := ThiiObjectListController.Create(Self);
  FObjectListController.KeyPropertyName := 'ID';
  FObjectListController.OwnsObjects := False;
  FStructureView := ThiiFmxStructureModel.Create(Self);
  FStructureView.AddChangeListener(ModelChanging, ModelChanged);
  FGrid := ThiiGrid.Create(Self);
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

destructor ThiiStructureView.Destroy;
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

procedure ThiiStructureView.ModelChanging(Sender: TObject);
begin
  FUpdating := True;
  FGrid.DataController := nil;
  FGrid.Selection.Clear;
  FObjectListController.Clear;
end;

procedure ThiiStructureView.ModelChanged(Sender: TObject);
var
  LItem: ThiiStructureItem;
  LAddress: ThiiCellAddress;
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
      if ThiiStructureItem(FObjectListController.Item(I)).Component = FStructureView.SelectedComponent then
      begin
        LAddress := ThiiCellAddress.Empty;
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

procedure ThiiStructureView.FilterChanged(Sender: TObject);
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

function ThiiStructureView.ItemAtRow(ARowIndex: Int64): ThiiStructureItem;
var
  LIndex: Int64;
begin
  Result := nil;
  LIndex := FObjectListController.GetSourceRowIndex(ARowIndex);
  if (LIndex >= 0) and (LIndex < FObjectListController.Count) then
    Result := ThiiStructureItem(FObjectListController.Item(LIndex));
end;

procedure ThiiStructureView.GetNameValue(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
var
  LItem: ThiiStructureItem;
begin
  LItem := ItemAtRow(ARowIndex);
  if ADisplayValue and Assigned(LItem) then
    AValue := StringOfChar(' ', LItem.Level * 3) + LItem.Name;
end;

function ThiiStructureView.GetSelectedComponent: TComponent;
var
  LItem: ThiiStructureItem;
begin
  Result := nil;
  LItem := ItemAtRow(FGrid.Selection.FocusedCell.RowIndex);
  if Assigned(LItem) then
    Result := LItem.Component;
end;

procedure ThiiStructureView.SelectionChanged(Sender: TObject);
begin
  if FUpdating then
    Exit;
  FStructureView.SelectComponent(SelectedComponent);
  if Assigned(FOnSelect) then
    FOnSelect(Self, SelectedComponent);
end;

function ThiiStructureView.GetRootComponent: TComponent;
begin
  if FLoadingRootAssigned then
    Result := FLoadingRoot
  else
    Result := FStructureView.RootComponent;
end;

procedure ThiiStructureView.SetRootComponent(AValue: TComponent);
begin
  if csLoading in ComponentState then
  begin
    FLoadingRoot := AValue;
    FLoadingRootAssigned := True;
  end
  else
    FStructureView.RootComponent := AValue;
end;

function ThiiStructureView.GetFilterText: string;
begin
  Result := FStructureView.FilterText;
end;

procedure ThiiStructureView.SetFilterText(const AValue: string);
begin
  FStructureView.FilterText := AValue;
end;

function ThiiStructureView.GetResolveByOwner: Boolean;
begin
  Result := FStructureView.ResolveByOwner;
end;

procedure ThiiStructureView.SetResolveByOwner(AValue: Boolean);
begin
  FStructureView.ResolveByOwner := AValue;
end;

function ThiiStructureView.GetResolveByParent: Boolean;
begin
  Result := FStructureView.ResolveByParent;
end;

procedure ThiiStructureView.SetResolveByParent(AValue: Boolean);
begin
  FStructureView.ResolveByParent := AValue;
end;

function ThiiStructureView.GetOnLoaded: TNotifyEvent;
begin
  Result := FStructureView.OnLoaded;
end;

procedure ThiiStructureView.SetOnLoaded(AValue: TNotifyEvent);
begin
  FStructureView.OnLoaded := AValue;
end;

procedure ThiiStructureView.Loaded;
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

procedure ThiiStructureView.Reload;
begin
  FStructureView.Reload;
end;

end.

