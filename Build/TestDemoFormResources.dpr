program TestDemoFormResources;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Rtti, System.Math, Data.DB, h5u.Grid.SampleData,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.MultiView, Fmx.h5u.Grid, Fmx.h5u.PropertyEditor,
  FmxDatasetDemoMain, FmxObjectDemoMain, FmxVirtualDemoMain, FmxMegaDemoMain;
  {$ELSE}
  Vcl.Forms, Vcl.WinXCtrls, Vcl.h5u.Grid, Vcl.h5u.PropertyEditor,
  VclDatasetDemoMain, VclObjectDemoMain, VclVirtualDemoMain, VclMegaDemoMain;
  {$ENDIF}

type
  TDemoFormClass = class of TForm;
  TPropertyEditorAccess = class(ThiiPropertyEditor);
  TSampleStreamRoot = class(TComponent)
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  end;
  {$IFDEF TEST_FMX}
  TSidebarFormAccess = class(TFmxMegaDemoForm);
  {$ELSE}
  TSidebarFormAccess = class(TVclMegaDemoForm);
  {$ENDIF}

procedure TSampleStreamRoot.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    Proc(Components[I]);
end;

procedure TestFreshSampleDataStreaming;
var
  Root, LoadedRoot: TSampleStreamRoot;
  Sample: ThiiSampleClientDataset;
  Binary: TMemoryStream;
  Text: TStringStream;
  LegacyActive: Boolean;
  FormText: string;
begin
  RegisterClass(TSampleStreamRoot);
  Root := TSampleStreamRoot.Create(nil);
  Binary := TMemoryStream.Create;
  Text := TStringStream.Create;
  try
    Sample := ThiiSampleClientDataset.Create(Root);
    Sample.Name := 'SampleData';
    Sample.SampleRowCount := 40;
    Sample.IncludeImages := False;
    Binary.WriteComponent(Root);
    Binary.Position := 0;
    ObjectBinaryToText(Binary, Text);
    FormText := Text.DataString;
    if FormText.Contains('Active = True') then
      raise Exception.Create('Generated dataset activation was persisted');
    for LegacyActive in [False, True] do
    begin
      Text.Size := 0;
      Text.Position := 0;
      if LegacyActive then
        Text.WriteString(FormText.Replace('object SampleData: ThiiSampleClientDataset',
          'object SampleData: ThiiSampleClientDataset' + sLineBreak + '    Active = True'))
      else
        Text.WriteString(FormText);
      Text.Position := 0;
      Binary.Size := 0;
      ObjectTextToBinary(Text, Binary);
      Binary.Position := 0;
      // The child constructor sees an owner in csLoading: no pre-existing packet.
      LoadedRoot := TSampleStreamRoot(Binary.ReadComponent(nil));
      try
        Sample := ThiiSampleClientDataset(LoadedRoot.FindComponent('SampleData'));
        if not Assigned(Sample) or not Sample.Active or (Sample.RecordCount <> 40) then
          raise Exception.Create('Fresh streamed sample dataset was not generated');
        Sample.Close;
        Sample.EnsureSampleData;
        if not Sample.Active or (Sample.RecordCount <> 40) then
          raise Exception.Create('Streamed sample dataset could not reopen');
      finally
        LoadedRoot.Free;
      end;
    end;
    Sample := ThiiSampleClientDataset(Root.FindComponent('SampleData'));
    Sample.AutoCreateSampleData := False;
    Sample.Close;
    Binary.Size := 0;
    Binary.WriteComponent(Root);
    Binary.Position := 0;
    LoadedRoot := TSampleStreamRoot(Binary.ReadComponent(nil));
    try
      Sample := ThiiSampleClientDataset(LoadedRoot.FindComponent('SampleData'));
      if Sample.AutoCreateSampleData or Sample.Active then
        raise Exception.Create('Disabled automatic sample data was activated');
    finally
      LoadedRoot.Free;
    end;
    Writeln('PASS: fresh sample dataset streams without packet, including legacy Active=True, and reopens');
  finally
    Text.Free;
    Binary.Free;
    Root.Free;
  end;
end;

procedure TestGeneratedSampleDataStreaming;
var
  Sample, LoadedSample: ThiiSampleClientDataset;
  Binary: TMemoryStream;
  Text: TStringStream;
begin
  RegisterClass(ThiiSampleClientDataset);
  RegisterClasses([TIntegerField, TWideStringField, TWideMemoField, TCurrencyField, TBooleanField, TDateTimeField, TBlobField]);
  Sample := ThiiSampleClientDataset.Create(nil);
  LoadedSample := nil;
  Binary := TMemoryStream.Create;
  Text := TStringStream.Create;
  try
    Sample.SampleRowCount := 40;
    Sample.IncludeImages := False;
    Binary.WriteComponent(Sample);
    Binary.Position := 0;
    ObjectBinaryToText(Binary, Text);
    if Text.DataString.Contains('PersistDataPacket') then
      raise Exception.Create('Generated sample data packet was persisted');
    Binary.Position := 0;
    // A standalone dataset auto-opens in its constructor; DFM loading normally
    // supplies an owner in csLoading. Close this standalone target before reading.
    LoadedSample := ThiiSampleClientDataset.Create(nil);
    LoadedSample.Close;
    Binary.ReadComponent(LoadedSample);
    if (LoadedSample.SampleRowCount <> 40) or LoadedSample.IncludeImages or not LoadedSample.Active or (LoadedSample.RecordCount <> 40) then
      raise Exception.Create('Sample options/data were not recreated after streaming');
    Writeln('PASS: sample data streaming omits generated packet and recreates rows from options');
  finally
    Text.Free;
    Binary.Free;
    LoadedSample.Free;
    Sample.Free;
  end;
end;

procedure TestSidebar(Form: TForm);
var
  {$IFDEF TEST_FMX}
  Demo: TFmxMegaDemoForm;
  {$ELSE}
  Demo: TVclMegaDemoForm;
  {$ENDIF}
begin
  {$IFDEF TEST_FMX}
  Demo := TFmxMegaDemoForm(Form);
  {$ELSE}
  Demo := TVclMegaDemoForm(Form);
  {$ENDIF}
  Demo.ClientWidth := 1100;
  Demo.ClientHeight := 650;
  TSidebarFormAccess(Demo).Resize;
  Demo.SetSidebarWidth(320);
  {$IFDEF TEST_FMX}
  if (Demo.MultiView1.Mode <> TMultiViewMode.Panel) or not Demo.MultiView1.Visible then
    raise Exception.Create('Wide FMX sidebar is not visible/docked');
  if Abs(Demo.Grid.Position.X - 320) > 1 then
    raise Exception.CreateFmt('FMX docked grid X=%f, expected 320', [Demo.Grid.Position.X]);
  if Demo.Splitter1.Parent <> Demo.MultiView1.MasterContent then
    raise Exception.Create('FMX resize grip is not inside the sidebar');
  {$ELSE}
  if (Demo.SplitView1.DisplayMode <> svmDocked) or not Demo.SplitView1.Opened then
    raise Exception.Create('Wide VCL sidebar is not visible/docked');
  if Demo.Grid.Left <> 320 then raise Exception.Create('VCL docked grid does not follow sidebar width');
  if Demo.Splitter1.Parent <> Demo.SplitView1 then
    raise Exception.Create('VCL resize grip is not inside the sidebar');
  {$ENDIF}
  Demo.ClientWidth := 500;
  Demo.ClientHeight := 800;
  TSidebarFormAccess(Demo).Resize;
  {$IFDEF TEST_FMX}
  if (Demo.MultiView1.Mode <> TMultiViewMode.Drawer) or Demo.MultiView1.IsShowed then
    raise Exception.CreateFmt('Narrow FMX sidebar mode=%d shown=%s width=%d',
      [Ord(Demo.MultiView1.Mode), BoolToStr(Demo.MultiView1.IsShowed, True), Demo.ClientWidth]);
  Demo.MultiView1.ShowMaster;
  Demo.SetSidebarWidth(280);
  if not Demo.MultiView1.IsShowed or (Abs(Demo.MultiView1.Width - 280) > 1) then
    raise Exception.Create('FMX overlay cannot open/resize');
  if Abs(Demo.Grid.Position.X) > 1 then raise Exception.Create('FMX overlay displaced grid');
  Demo.MultiView1.HideMaster;
  {$ELSE}
  if (Demo.SplitView1.DisplayMode <> svmOverlay) or Demo.SplitView1.Opened then
    raise Exception.Create('Narrow VCL sidebar is not initially collapsed');
  Demo.SplitView1.Open;
  Demo.SetSidebarWidth(280);
  if not Demo.SplitView1.Opened or (Demo.SplitView1.Width <> 280) then
    raise Exception.Create('VCL overlay cannot open/resize');
  if Demo.Grid.Left <> 0 then raise Exception.Create('VCL overlay displaced grid');
  Demo.SplitView1.Close;
  {$ENDIF}
  Demo.ClientWidth := 1100;
  TSidebarFormAccess(Demo).Resize;
  {$IFDEF TEST_FMX}
  if (Demo.MultiView1.Mode <> TMultiViewMode.Panel) or (Abs(Demo.Grid.Position.X - 280) > 1) then
    raise Exception.Create('FMX sidebar width lost returning to docked mode');
  {$ELSE}
  if not Demo.SplitView1.Opened or (Demo.Grid.Left <> 280) then
    raise Exception.Create('VCL sidebar width lost returning to docked mode');
  {$ENDIF}
  Writeln('PASS: ', Form.ClassName, ' docked/overlay sidebar, resizing and mode transitions');
end;

procedure TestForm(AClass: TDemoFormClass);
var
  Form: TForm;
  Grid: ThiiGrid;
  Properties: ThiiPropertyEditor;
  Item: ThiiPropertyItem;
  OriginalEnabled: Boolean;
  SourceCount: Int64;
  GroupRow, VisibleRow: Int64;
  PropertyName: string;
begin
  Form := AClass.Create(nil);
  try
    if Form.Visible then
      raise Exception.Create('Demo form must remain hidden');
    if not (Form.FindComponent('Grid') is ThiiGrid) then
      raise Exception.Create('Demo resource did not resolve ThiiGrid');
    Grid := ThiiGrid(Form.FindComponent('Grid'));
    if (Grid.Columns.Count = 0) or (Grid.DataController = nil) then
      raise Exception.Create('Demo columns or controller reference missing after loading');
    if AClass.ClassName.Contains('MegaDemo') then
    begin
      if not (Form.FindComponent('Properties') is ThiiPropertyEditor) then
        raise Exception.Create('MegaDemo property editor missing');
      Properties := ThiiPropertyEditor(Form.FindComponent('Properties'));
      if Properties.DataObject <> Grid then
        raise Exception.Create('MegaDemo property editor is not bound to the demo grid');
      for PropertyName in ['Name', 'Width', 'Height', 'Align', 'Anchors', 'Visible', 'DataController'] do
      begin
        Item := Properties.PropertyEditor.FindProperty(PropertyName);
        if (Item <> nil) and not Item.Hidden then
          raise Exception.Create('Component integration property remains visible: ' + PropertyName);
      end;
      Item := Properties.PropertyEditor.FindProperty('Appearance.DefaultCellColor');
      if (Item = nil) or Item.Hidden then
        raise Exception.Create('Grid appearance properties must remain visible');
      Item := Properties.PropertyEditor.FindProperty('Enabled');
      if Item = nil then raise Exception.Create('Demo grid properties are not available in the property editor');
      OriginalEnabled := Grid.Enabled;
      Properties.PropertyEditor.SetValue(Item, TValue.From<Boolean>(not OriginalEnabled));
      if Grid.Enabled = OriginalEnabled then
        raise Exception.Create('Property editor did not update the actual demo grid');
      Properties.PropertyEditor.SetValue(Item, TValue.From<Boolean>(OriginalEnabled));
      if Item.GroupName <> 'Options' then
        raise Exception.Create('Direct grid properties are not grouped under Options');
      Item := Properties.PropertyEditor.FindProperty('Customization.AllowColumnResizing');
      if (Item = nil) or (Item.Instance <> Pointer(Grid.Customization)) or (Item.GroupName <> 'Customization') then
        raise Exception.Create('Nested customization properties are not grouped/bound to their owning object');
      OriginalEnabled := Grid.Customization.AllowColumnResizing;
      Properties.PropertyEditor.SetValue(Item, TValue.From<Boolean>(not OriginalEnabled));
      if Grid.Customization.AllowColumnResizing = OriginalEnabled then
        raise Exception.Create('Nested property editor did not update grid customization');
      Properties.PropertyEditor.SetValue(Item, TValue.From<Boolean>(OriginalEnabled));
      Item := Properties.PropertyEditor.FindProperty('AdjacentGroupFolding.EndBand.Height');
      if (Item = nil) or Item.Hidden or (Item.GroupName <> 'AdjacentGroupFolding.EndBand') then
        raise Exception.Create('Nested EndBand property group missing');
      if Properties.PropertyEditor.FindProperty('DataController.Cache.Mode') <> nil then
        raise Exception.Create('External component references must not be recursively inspected');
      if not Properties.ObjectListController.HasGroups or not TPropertyEditorAccess(Properties).AdjacentGroupFolding.Enabled then
        raise Exception.Create('Property editor group folding is disabled');
      Properties.SetAdjacentGroupCollapsed(0, True);
      if TPropertyEditorAccess(Properties).GetViewSourceRowIndex(1) <= 1 then
        raise Exception.Create('Property group did not collapse');
      Properties.Reload;
      if TPropertyEditorAccess(Properties).GetViewSourceRowIndex(1) <= 1 then
        raise Exception.Create('Property group lost its collapsed state on reload');
      Properties.SetAdjacentGroupCollapsed(0, False);
      SourceCount := Properties.ObjectListController.Count;
      GroupRow := -1;
      for VisibleRow := 0 to SourceCount - 1 do
      begin
        Item := Properties.PropertyEditor.FindProperty('AdjacentGroupFolding.Enabled');
        if Properties.ObjectListController.Item(VisibleRow) = Item then
        begin
          GroupRow := VisibleRow - 1;
          while (GroupRow >= 0) and (Properties.ObjectListController.Item(GroupRow) is ThiiPropertyItem) do
            Dec(GroupRow);
          Break;
        end;
      end;
      if GroupRow < 0 then raise Exception.Create('Parent property group anchor missing');
      if TPropertyEditorAccess(Properties).GetViewSourceRowIndex(GroupRow) <> GroupRow then
        raise Exception.Create('Parent group source/view mismatch before folding');
      Properties.SetAdjacentGroupCollapsed(GroupRow, True);
      if Properties.ObjectListController.Count >= SourceCount then
        raise Exception.Create('Collapsing parent group did not hide its nested groups');
      for VisibleRow := 0 to Properties.ObjectListController.Count - 1 do
        if TPropertyEditorAccess(Properties).GetViewSourceRowIndex(VisibleRow) = GroupRow then
        begin
          GroupRow := VisibleRow;
          Break;
        end;
      Properties.SetAdjacentGroupCollapsed(GroupRow, False);
      if Properties.ObjectListController.Count <> SourceCount then
        raise Exception.Create('Expanding parent group did not restore its nested groups');
      Writeln('PASS: ', AClass.ClassName, ' nested property groups, live edits and persistent folding');
      Writeln('PASS: ', AClass.ClassName, ' property editor binding and live grid property update');
      TestSidebar(Form);
    end;
    Writeln('PASS: ', AClass.ClassName, ' hidden form resource, ThiiGrid, columns and controller reference');
  finally
    Form.Free;
  end;
end;

begin
  try
    Application.Initialize;
    TestGeneratedSampleDataStreaming;
    TestFreshSampleDataStreaming;
    {$IFDEF TEST_FMX}
    TestForm(TFmxDatasetDemoForm);
    TestForm(TFmxObjectDemoForm);
    TestForm(TFmxVirtualDemoForm);
    TestForm(TFmxMegaDemoForm);
    {$ELSE}
    TestForm(TVclDatasetDemoForm);
    TestForm(TVclObjectDemoForm);
    TestForm(TVclVirtualDemoForm);
    TestForm(TVclMegaDemoForm);
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
