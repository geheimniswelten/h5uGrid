uses
  System.SysUtils, System.Classes, System.Rtti, System.Types,
  h5u.FormDesigner, h5u.FormDesigner.Properties, h5u.Grid.Types,
  h5u.Grid.Editors, h5u.Grid.Columns, h5u.Grid.Data.Core,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.StdCtrls, Fmx.Controls, Fmx.Layouts, Fmx.ComboEdit,
  Fmx.h5u.FormDesigner, Fmx.h5u.Grid.Editors;
  {$ELSE}
  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.h5u.FormDesigner, Vcl.h5u.Grid.Editors;
  {$ENDIF}

type
  TSample = class(TComponent)
  private
    FTitle: string;
    FNumber: Integer;
    FToggle: Boolean;
    function GetBroken: string;
  published
    property Title: string read FTitle write FTitle;
    property Number: Integer read FNumber write FNumber;
    property Toggle: Boolean read FToggle write FToggle;
    property FixedNumber: Integer read FNumber;
    property Broken: string read GetBroken;
  end;
  {$IFDEF TEST_FMX}
  TPropertyView = Th5uFmxPropertyEditor;
  TStructureView = Th5uFmxStructureView;
  TNativeEditor = Th5uFmxCustomEditor;
  TNativeCombo = TComboEdit;
  {$ELSE}
  TPropertyView = Th5uVclPropertyEditor;
  TStructureView = Th5uVclStructureView;
  TNativeEditor = Th5uVclCustomEditor;
  TNativeCombo = TComboBox;
  {$ENDIF}
  TPropertyViewAccess = class(TPropertyView);
  TEvents = class
    Changes: Integer;
    Selections: Integer;
    DataChanges: Integer;
    ReadCount, WriteCount, StoredValue: Integer;
    Selected: TComponent;
    GroupA, GroupB: TSample;
    LastInstance: Pointer;
    LastChange: Th5uDataChange;
    procedure LoadedGroups(Sender: TObject);
    procedure Changed(Sender: TObject);
    procedure Select(Sender: TObject; AComponent: TComponent);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure GetValue(Sender: TObject; Item: Th5uPropertyItem; var Value: TValue; var Handled: Boolean);
    procedure SetValue(Sender: TObject; Item: Th5uPropertyItem; const Value: TValue; var Handled: Boolean);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
  Writeln('PASS: ' + AMessage);
end;

procedure TEvents.Changed(Sender: TObject);
begin
  Inc(Changes);
end;

procedure TEvents.Select(Sender: TObject; AComponent: TComponent);
begin
  Inc(Selections);
  Selected := AComponent;
end;

procedure TEvents.DataChanged(Sender: TObject; const AChange: Th5uDataChange);
begin
  Inc(DataChanges);
  LastChange := AChange;
end;

procedure TEvents.GetValue(Sender: TObject; Item: Th5uPropertyItem; var Value: TValue; var Handled: Boolean);
begin
  if Item.Name <> 'ManualComputed' then
    Exit;
  Inc(ReadCount);
  LastInstance := Item.Instance;
  Value := TValue.From<Integer>(StoredValue);
  Handled := True;
end;

procedure TEvents.SetValue(Sender: TObject; Item: Th5uPropertyItem; const Value: TValue; var Handled: Boolean);
begin
  if Item.Name <> 'ManualComputed' then
    Exit;
  Inc(WriteCount);
  LastInstance := Item.Instance;
  StoredValue := Value.AsInteger;
  Handled := True;
end;

procedure TEvents.LoadedGroups(Sender: TObject);
var
  LModel: Th5uPropertyEditor;
  LContext: TRttiContext;
  LType: TRttiType;
  LItem: Th5uPropertyItem;
begin
  LModel := Th5uPropertyEditor(Sender);
  LModel.Items.Clear;
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(TSample);
    LItem := LModel.AddProperty(Pointer(GroupA), LType.GetProperty('Title'));
    LItem.GroupName := 'Options';
    LItem.Caption := 'Grid title';
    LItem := LModel.AddProperty(Pointer(GroupB), LType.GetProperty('Number'));
    LItem.GroupName := 'Customization';
    LItem.Caption := 'Limit';
    LItem := LModel.AddProperty(Pointer(GroupB), LType.GetProperty('Toggle'));
    LItem.GroupName := 'Customization';
    LModel.AddManualProperty(nil, 'LocalNote', TValue.From<string>('memo'));
    LItem := LModel.AddProperty(Pointer(GroupA), LType.GetProperty('Number'));
    LItem.GroupName := 'Options';
  finally
    LContext.Free;
  end;
end;

function TSample.GetBroken: string;
begin
  raise Exception.Create('Getter failed');
end;

function RowOf(AView: TPropertyView; const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to AView.ObjectListController.Count - 1 do
    if (AView.ObjectListController.Item(I) is Th5uPropertyItem)
      and (Th5uPropertyItem(AView.ObjectListController.Item(I)).Name = AName) then
      Exit(I);
end;

function InstanceRowOf(AView: TPropertyView; AInstance: Pointer; const AName: string): Integer;
var
  I: Integer;
  Item: Th5uPropertyItem;
begin
  Result := -1;
  for I := 0 to AView.ObjectListController.Count - 1 do
  begin
    if not (AView.ObjectListController.Item(I) is Th5uPropertyItem) then
      Continue;
    Item := Th5uPropertyItem(AView.ObjectListController.Item(I));
    if (Item.Instance = AInstance) and (Item.Name = AName) then
      Exit(I);
  end;
end;

procedure TestProperties;
var
  LView: TPropertyView;
  LForm: TForm;
  LObject: TSample;
  LEvents: TEvents;
  LRow: Integer;
  LAllow, LFailed: Boolean;
  LEditor: TNativeEditor;
  LContext: Th5uEditorContext;
  LFilter: Th5uPropertyFilter;
begin
  LForm := TForm.CreateNew(nil);
  LView := TPropertyView.Create(nil);
  LView.Parent := LForm;
  LObject := TSample.Create(nil);
  LEvents := TEvents.Create;
  try
    LObject.Title := 'Initial';
    LObject.Number := 7;
    LView.PropertyEditor.OnChange := LEvents.Changed;
    LView.DataObject := LObject;
    Check(RowOf(LView, 'Title') >= 0, 'Property rows bound');
    Check(LEvents.Changes > 0, 'Public events coexist with grid binding');
    Check(Pos('Getter failed', LView.ObjectListController.GetValue(RowOf(LView, 'Broken'), 'DisplayValue').AsString) > 0,
      'Getter exceptions are safe for grid display');
    LRow := RowOf(LView, 'Title');
    LView.ObjectListController.SetValue(LRow, 'DisplayValue', TValue.From<string>('Updated'));
    Check(LObject.Title = 'Updated', 'Controller setter reaches object');
    Check(LView.ObjectListController.GetValue(LRow, 'DisplayValue').AsString = 'Updated', 'Controller reads updated cache');
    LRow := RowOf(LView, 'Number');
    LFailed := False;
    try
      LView.ObjectListController.SetValue(LRow, 'DisplayValue', TValue.From<string>('invalid'));
    except
      on E: Exception do
        LFailed := True;
    end;
    Check(LFailed and (LObject.Number = 7), 'Invalid edit rejected without changing object');
    LAllow := True;
    TPropertyViewAccess(LView).OnCanEdit(LView, LView.Columns[1], RowOf(LView, 'FixedNumber'), LAllow);
    Check(not LAllow, 'Readonly row cannot activate editor');
    LRow := RowOf(LView, 'Toggle');
    LEditor := TNativeEditor(LView.GetCellEditor(LView.Columns[1], LRow));
    LContext := Default(Th5uEditorContext);
    LContext.Grid := LView;
    LContext.Column := LView.Columns[1];
    LContext.RowIndex := LRow;
    LContext.RowKey := LView.ObjectListController.GetRowKey(LRow);
    LContext.Value := LView.ObjectListController.GetValue(LRow, 'DisplayValue');
    LContext.Text := LContext.Value.AsString;
    LContext.Bounds := RectF(0, 0, 200, 24);
    LEditor.BeginEdit(LContext);
    LEditor.OnShow(LEditor);
    Check(LEditor.Control is TNativeCombo, 'Native value combo');
    Check(TNativeCombo(LEditor.Control).Items.Count = 2, 'Boolean combo choices');
    Check(LEditor.GetText = LContext.Text, 'Combo population preserves current value');
    LView.PropertyEditor.Filters.BeginUpdate;
    try
      LFilter := LView.PropertyEditor.Filters.Add;
      LFilter.NameMask := 'Title';
      LFilter.Hidden := True;
    finally
      LView.PropertyEditor.Filters.EndUpdate;
    end;
    Check(RowOf(LView, 'Title') < 0, 'Hidden row removed from controller');
    FreeAndNil(LObject);
    Check((LView.DataObject = nil) and (LView.ObjectListController.Count = 0), 'Freed component detaches property rows');
  finally
    LView.Free;
    LForm.Free;
    LObject.Free;
    LEvents.Free;
  end;
end;

procedure TestGroupedPropertyRows;
var
  LView: TPropertyView;
  LForm: TForm;
  A, B: TSample;
  LEvents: TEvents;
  LFirstHeaderID: Integer;
  LAllow, LFailed: Boolean;
  LEditor: TNativeEditor;
  LContext: Th5uEditorContext;
begin
  LForm := TForm.CreateNew(nil);
  LView := TPropertyView.Create(nil);
  LView.Parent := LForm;
  A := TSample.Create(nil);
  B := TSample.Create(nil);
  LEvents := TEvents.Create;
  try
    A.Title := 'Original';
    B.Number := 7;
    LEvents.GroupA := A;
    LEvents.GroupB := B;
    LView.PropertyEditor.OnLoaded := LEvents.LoadedGroups;
    LView.DataObject := A;
    Check((LView.PropertyEditor.Items.Count = 5) and (LView.ObjectListController.Count = 8),
      'OnLoaded builds a custom list with separate controller group headings');
    Check((LView.PropertyEditor.Items[0].Name = 'Title')
      and (LView.PropertyEditor.Items[0].Caption = 'Grid title')
      and (LView.PropertyEditor.Items[0].GroupName = 'Options')
      and (LView.PropertyEditor.Items[0].Instance = Pointer(A)),
      'Group and display caption preserve property identity and instance');
    Check((LView.ObjectListController.GetValue(0, 'GroupName').AsString = 'Options')
      and (LView.ObjectListController.GetValue(2, 'GroupName').AsString = 'Customization')
      and (LView.ObjectListController.GetValue(6, 'GroupName').AsString = 'Options')
      and (InstanceRowOf(LView, Pointer(B), 'Number') = 3),
      'Group headings preserve consecutive runs and manual property order');
    Check((LView.Columns[0].FieldName = 'Caption')
      and (LView.ObjectListController.GetValue(1, 'Caption').AsString = 'Grid title')
      and (LView.ObjectListController.GetValue(0, 'DisplayValue').AsString = ''),
      'Property captions and empty heading value bind to the existing grid columns');
    LFirstHeaderID := Th5uPropertyGroupRow(LView.ObjectListController.Item(0)).ID;
    Check((LFirstHeaderID < 0)
      and (Th5uPropertyGroupRow(LView.ObjectListController.Item(6)).ID <> LFirstHeaderID)
      and (LView.ObjectListController.Item(5) is Th5uPropertyItem),
      'Repeated groups receive distinct stable keys and empty groups stay ungrouped');
    LFailed := False;
    try
      LView.ObjectListController.SetValue(0, 'DisplayValue', TValue.From<string>('changed'));
    except
      on E: Exception do
        LFailed := True;
    end;
    Check(LFailed, 'Controller rejects edits to a group heading');
    LView.SetAdjacentGroupCollapsed(0, True);
    Check(LView.IsAdjacentGroupCollapsed(0)
      and (TPropertyViewAccess(LView).GetViewSourceRowIndex(1) = 2),
      'Folding keeps the heading and hides its property rows');
    LAllow := True;
    TPropertyViewAccess(LView).OnCanEdit(LView, LView.Columns[1], 1, LAllow);
    Check(not LAllow, 'A heading after a folded group cannot activate an editor');
    LAllow := True;
    TPropertyViewAccess(LView).OnCanEdit(LView, LView.Columns[1], 2, LAllow);
    Check(LAllow, 'A property after a folded group keeps its correct edit permission');
    LEditor := TNativeEditor(LView.GetCellEditor(LView.Columns[1], 3));
    LContext := Default(Th5uEditorContext);
    LContext.Grid := LView;
    LContext.Column := LView.Columns[1];
    LContext.RowIndex := 3;
    LContext.RowKey := LView.ObjectListController.GetRowKey(4);
    LContext.Value := LView.ObjectListController.GetValue(4, 'DisplayValue');
    LContext.Text := LContext.Value.AsString;
    LContext.Bounds := RectF(0, 0, 200, 24);
    LEditor.BeginEdit(LContext);
    LEditor.OnShow(LEditor);
    Check(TNativeCombo(LEditor.Control).Items.Count = 2,
      'A property after a folded group uses the correct RTTI value editor');
    LView.PropertyEditor.Items[0].Caption := 'Updated caption';
    LView.PropertyEditor.NotifyItemsChanged;
    Check(LView.IsAdjacentGroupCollapsed(0)
      and (Th5uPropertyGroupRow(LView.ObjectListController.Item(0)).ID = LFirstHeaderID)
      and (LView.ObjectListController.GetValue(1, 'Caption').AsString = 'Updated caption'),
      'Metadata rebind preserves stable group keys and collapsed state');
    LView.ShowGroups := False;
    Check((LView.ObjectListController.Count = 5) and not LView.ObjectListController.HasGroups,
      'ShowGroups false binds only property rows');
    LView.ShowGroups := True;
    Check((LView.ObjectListController.Count = 8) and LView.IsAdjacentGroupCollapsed(0),
      'Reenabling groups restores their collapsed state');
    LView.Reload;
    Check((LView.PropertyEditor.Items[0].Caption = 'Grid title')
      and (LView.ObjectListController.Count = 8) and LView.IsAdjacentGroupCollapsed(0),
      'Reload rebuilds custom groups through OnLoaded and retains their state');
    LView.ResetAdjacentGroupStates;
    LView.PropertyEditor.NotifyItemsChanged;
    Check(not LView.IsAdjacentGroupCollapsed(0), 'Reset group states survives a subsequent rebind');
    LView.ObjectListController.SetValue(InstanceRowOf(LView, Pointer(B), 'Number'), 'Value', TValue.From<Integer>(19));
    Check((B.Number = 19) and (A.Number = 0), 'Grouped edits still target the row own instance');
  finally
    LView.Free;
    LForm.Free;
    A.Free;
    B.Free;
    LEvents.Free;
  end;
end;

procedure TestMixedPropertyRows;
var
  LView: TPropertyView;
  LForm: TForm;
  A, B: TSample;
  LEvents: TEvents;
  LLink: Th5uDataControllerLink;
  LContext: TRttiContext;
  LTitleProperty, LNumberProperty: TRttiProperty;
  LTitleItem, LManualItem: Th5uPropertyItem;
  LRow, LReads: Integer;
  LKey: string;
begin
  LForm := TForm.CreateNew(nil);
  LView := TPropertyView.Create(nil);
  LView.Parent := LForm;
  A := TSample.Create(nil);
  B := TSample.Create(nil);
  LEvents := TEvents.Create;
  LLink := Th5uDataControllerLink.Create;
  LContext := TRttiContext.Create;
  try
    A.Title := 'first';
    B.Title := 'second';
    B.Number := 7;
    LEvents.StoredValue := 41;
    LView.PropertyEditor.PublishedProperties := False;
    LView.DataObject := A;
    LView.ObjectListController.OnGetValue := LEvents.GetValue;
    LView.ObjectListController.OnSetValue := LEvents.SetValue;
    LTitleProperty := LContext.GetType(TSample).GetProperty('Title');
    LNumberProperty := LContext.GetType(TSample).GetProperty('Number');
    LView.PropertyEditor.AddProperty(Pointer(A), LTitleProperty);
    LTitleItem := LView.PropertyEditor.AddProperty(Pointer(B), LTitleProperty);
    LView.PropertyEditor.AddProperty(Pointer(B), LNumberProperty);
    LManualItem := LView.PropertyEditor.AddManualProperty(Pointer(B), 'ManualComputed', TValue.From<Integer>(0));
    LView.PropertyEditor.AddManualProperty(nil, 'LocalNote', TValue.From<string>('memo'));
    Check(LView.ObjectListController.Count = 5, 'Added mixed-instance and cache-only rows bind immediately');
    LRow := InstanceRowOf(LView, Pointer(B), 'Title');
    LKey := LView.ObjectListController.GetRowKey(LRow).ToString;
    Check(LView.ObjectListController.GetValue(LRow, 'Value').AsString = 'second',
      'Controller raw value uses the row instance');
    LView.ObjectListController.SetValue(LRow, 'Value', TValue.From<string>('second edited'));
    Check((A.Title = 'first') and (B.Title = 'second edited'),
      'Same-name row edit affects only its own instance');
    LRow := InstanceRowOf(LView, Pointer(B), 'Number');
    Check(LView.ObjectListController.GetValue(LRow, 'Value').AsInteger = 7,
      'Controller supplies typed TValue without text conversion');
    LRow := InstanceRowOf(LView, Pointer(B), 'ManualComputed');
    Check((LManualItem.RttiProperty = nil) and (LManualItem.RttiField = nil)
      and (LView.ObjectListController.GetValue(LRow, 'Value').AsInteger = 41)
      and (LEvents.LastInstance = Pointer(B)), 'Controller getter supplies a manual row without RTTI');
    LReads := LEvents.ReadCount;
    LView.ObjectListController.GetValue(LRow, 'Value');
    LView.ObjectListController.GetValue(LRow, 'DisplayValue');
    Check(LEvents.ReadCount = LReads, 'Grid reads manual raw and display values from the TValue cache');
    LView.ObjectListController.SetValue(LRow, 'Value', TValue.From<Integer>(49));
    Check((LEvents.StoredValue = 49) and (LEvents.WriteCount = 1)
      and (LManualItem.Value.AsInteger = 49), 'Controller setter handles a manual row without RTTI');
    LLink.OnChanged := LEvents.DataChanged;
    LLink.Controller := LView.ObjectListController;
    LEvents.DataChanges := 0;
    LView.PropertyEditor.Refresh;
    Check(LEvents.DataChanges = 0, 'Unchanged refresh sends no grid notification');
    B.Number := 11;
    LEvents.StoredValue := 53;
    LView.PropertyEditor.Refresh;
    Check(LEvents.DataChanges = 1, 'Refresh batches multiple changed rows into one grid notification');
    Check((LView.ObjectListController.GetValue(InstanceRowOf(LView, Pointer(B), 'Number'), 'Value').AsInteger = 11)
      and (LManualItem.Value.AsInteger = 53), 'Refresh updates mapped and controller-supplied manual values');
    LView.PropertyEditor.Items.Exchange(LView.PropertyEditor.Items.IndexOf(LTitleItem), 0);
    LView.PropertyEditor.NotifyItemsChanged;
    LRow := InstanceRowOf(LView, Pointer(B), 'Title');
    Check((LRow = 0) and (LView.ObjectListController.GetRowKey(LRow).ToString = LKey),
      'Reordered mixed-instance rows preserve their grid row keys');
    LEvents.DataChanges := 0;
    B.Title := 'after reorder';
    LView.PropertyEditor.Refresh;
    Check((LEvents.DataChanges = 1)
      and (LView.ObjectListController.GetValue(LRow, 'Value').AsString = 'after reorder')
      and (LView.ObjectListController.GetRowKey(LRow).ToString = LKey),
      'Refresh after reordering updates the matching row and keeps its identity');
    Check(LView.ObjectListController.GetValue(InstanceRowOf(LView, nil, 'LocalNote'), 'Value').AsString = 'memo',
      'Cache-only row without an instance keeps its value');
    FreeAndNil(B);
    Check((LView.DataObject = A) and (LView.ObjectListController.Count = 2)
      and (InstanceRowOf(LView, Pointer(A), 'Title') >= 0),
      'Freed nonselected instance removes its grid rows and retains unrelated rows');
    B := TSample.Create(nil);
    B.Title := 'retained';
    LView.PropertyEditor.AddProperty(Pointer(B), LTitleProperty);
    FreeAndNil(A);
    Check((LView.DataObject = nil) and (LView.ObjectListController.Count = 2)
      and (InstanceRowOf(LView, Pointer(B), 'Title') >= 0)
      and (InstanceRowOf(LView, nil, 'LocalNote') >= 0),
      'Freed selected instance retains other-instance and cache-only grid rows');
    LRow := InstanceRowOf(LView, Pointer(B), 'Title');
    LView.ObjectListController.SetValue(LRow, 'Value', TValue.From<string>('still editable'));
    Check((B.Title = 'still editable')
      and (LView.ObjectListController.GetValue(LRow, 'Value').AsString = 'still editable'),
      'Retained grid row remains editable without a selected object');
  finally
    LLink.Free;
    LView.Free;
    LForm.Free;
    LContext.Free;
    LEvents.Free;
    B.Free;
    A.Free;
  end;
end;

procedure TestStructure;
var
  LView: TStructureView;
  LForm: TForm;
  LPanel: TPanel;
  LButton: TButton;
  LEvents: TEvents;
  LItem: Th5uStructureItem;
  LAddress: Th5uCellAddress;
  I, LRow: Integer;
  LPropertyView: TPropertyView;
begin
  LView := TStructureView.Create(nil);
  LForm := TForm.CreateNew(nil);
  LView.Parent := LForm;
  LEvents := TEvents.Create;
  try
    LPanel := TPanel.Create(LForm);
    LPanel.Name := 'RootPanel';
    LPanel.Parent := LForm;
    LButton := TButton.Create(LForm);
    LButton.Name := 'NestedButton';
    LButton.Parent := LPanel;
    LView.StructureView.OnChange := LEvents.Changed;
    LView.RootComponent := LPanel;
    Check(LView.ObjectListController.Count = 2, 'Panel root follows visual parent');
    LItem := LView.StructureView.FindComponent(LButton);
    Check(Assigned(LItem) and (LItem.Parent.Component = LPanel) and (LItem.Level = 1), 'Visual hierarchy preserved');
    LView.OnSelect := LEvents.Select;
    LRow := -1;
    for I := 0 to LView.ObjectListController.Count - 1 do
      if Th5uStructureItem(LView.ObjectListController.Item(I)).Component = LButton then
        LRow := I;
    LAddress := Default(Th5uCellAddress);
    LAddress.RowIndex := LRow;
    LAddress.ColumnIndex := 0;
    LAddress.ColumnId := 'Name';
    LAddress.RowKey := LView.ObjectListController.GetRowKey(LRow);
    LView.Grid.Selection.SetFocus(LAddress, True);
    Check((LView.SelectedComponent = LButton) and (LEvents.Selected = LButton), 'Selection forwarded');
    LView.FilterText := 'NestedButton';
    Check((LView.ObjectListController.Count = 2) and (LView.FilterEdit.Text = 'NestedButton'), 'Filter keeps ancestors and edit synchronized');
    LView.FilterEdit.Text := 'Missing';
    {$IFDEF TEST_FMX}
    LView.FilterEdit.OnChangeTracking(LView.FilterEdit);
    {$ENDIF}
    Check(LView.ObjectListController.Count = 0, 'Filter edit updates grid');
    LView.FilterText := '';
    Check(LView.SelectedComponent = LButton, 'Selection restored after clearing filter');
    LView.FilterEdit.Text := '[';
    {$IFDEF TEST_FMX}
    LView.FilterEdit.OnChangeTracking(LView.FilterEdit);
    {$ENDIF}
    Check((LView.FilterError <> '') and (LView.ObjectListController.Count = 2)
      and (LView.FilterEdit.Text = '['), 'Incomplete mask keeps the last valid list and exposes error');
    LView.FilterEdit.Text := 'Nested*';
    {$IFDEF TEST_FMX}
    LView.FilterEdit.OnChangeTracking(LView.FilterEdit);
    {$ENDIF}
    Check((LView.FilterError = '') and (LView.ObjectListController.Count = 2), 'Corrected mask clears the error');
    LView.FilterText := '';
    LView.Reload;
    Check(LView.SelectedComponent = LButton, 'Selection restored after model reload');
    LPropertyView := TPropertyView.Create(LForm);
    LPropertyView.Parent := LForm;
    LView.RootComponent := LForm;
    Check((LView.StructureView.FindComponent(LView.Grid) = nil) and (LView.StructureView.FindComponent(LView.ObjectListController) = nil)
      and (LView.StructureView.FindComponent(LPropertyView.PropertyEditor) = nil), 'Inspectors hide their implementation components');
    LView.RootComponent := LPanel;
    LButton.Free;
    Check(LView.ObjectListController.Count = 1, 'Freed child removed from bound list');
    LView.Parent := nil;
    FreeAndNil(LForm);
    Check((LView.RootComponent = nil) and (LView.ObjectListController.Count = 0), 'Freed root clears grid');
  finally
    LView.Free;
    LForm.Free;
    LEvents.Free;
  end;
end;

procedure TestStreaming;
var
  LView, LCopy: TPropertyView;
  LStream: TMemoryStream;
begin
  LView := TPropertyView.Create(nil);
  LCopy := TPropertyView.Create(nil);
  LStream := TMemoryStream.Create;
  try
    LView.PropertyEditor.NameMask := 'Title*';
    LView.PropertyEditor.PublicProperties := True;
    LStream.WriteComponent(LView);
    LStream.Position := 0;
    LStream.ReadComponent(LCopy);
    Check((LCopy.PropertyEditor.NameMask = 'Title*') and LCopy.PropertyEditor.PublicProperties, 'Property model options survive streaming');
    Check(LCopy.Columns.Count = 2, 'Property columns survive streaming without duplicates');
    Check(Assigned(TPropertyViewAccess(LCopy).OnCanEdit), 'Readonly guard survives streaming');
  finally
    LView.Free;
    LCopy.Free;
    LStream.Free;
  end;
end;

procedure TestStructureStreaming;
var
  LForm, LCopy: TForm;
  LView, LReadView: TStructureView;
  LPanel: TPanel;
  LButton: TButton;
  LStream: TMemoryStream;
begin
  RegisterClasses([TStructureView, TPanel, TButton]);
  LForm := TForm.CreateNew(nil);
  LCopy := TForm.CreateNew(nil);
  LStream := TMemoryStream.Create;
  try
    LForm.Name := 'TestForm';
    // Create the view first: its streamed RootComponent references a later child.
    LView := TStructureView.Create(LForm);
    LView.Name := 'Inspector';
    LView.Parent := LForm;
    LPanel := TPanel.Create(LForm);
    LPanel.Name := 'RootPanel';
    LPanel.Parent := LForm;
    LButton := TButton.Create(LForm);
    LButton.Name := 'ChildButton';
    LButton.Parent := LPanel;
    LView.RootComponent := LPanel;
    LStream.WriteComponent(LForm);
    LStream.Position := 0;
    LStream.ReadComponent(LCopy);
    LReadView := TStructureView(LCopy.FindComponent('Inspector'));
    Check(Assigned(LReadView) and (LReadView.RootComponent = LCopy.FindComponent('RootPanel')), 'Structure root reference survives streaming');
    Check(LReadView.ObjectListController.Count = 2, 'Loaded resolves the complete visual hierarchy');
  finally
    LForm.Free;
    LCopy.Free;
    LStream.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestProperties;
    TestMixedPropertyRows;
    TestGroupedPropertyRows;
    TestStructure;
    TestStreaming;
    TestStructureStreaming;
    Writeln('PASS: adapter binding, edit guards, cache, combos, visual parents, filters, selection and lifetime');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
