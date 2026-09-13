program TestLclDemoResources;

{$mode objfpc}{$H+}
{$codepage UTF8}
{$scopedenums on}

uses
  Interfaces,
  Forms,
  SysUtils,
  Rtti,
  DB,
  h5u.Grid.Types,
  h5u.Grid.Columns,
  LclDatasetDemoMain,
  LclObjectDemoMain,
  LclVirtualDemoMain;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
  begin
    WriteLn(StdErr, 'FAIL: ' + AMessage);
    Flush(StdErr);
    raise Exception.Create(AMessage);
  end;
end;

procedure Trace(const AMessage: string);
begin
  WriteLn(AMessage);
  Flush(Output);
end;

procedure TestDataset;
var
  LForm: TLclDatasetDemoForm;
  LNameColumn: Th5uGridColumn;
begin
  Trace('Loading ClientDataset form resource...');
  LForm := TLclDatasetDemoForm.Create(nil);
  try
    Trace('Checking ClientDataset data and options...');
    Check(not LForm.Visible, 'Dataset form must remain hidden.');
    Check(LForm.Grid.DataController = LForm.DataController, 'Dataset grid/controller reference was not streamed.');
    Check(LForm.DataSource.DataSet = LForm.SampleData, 'Dataset datasource reference was not streamed.');
    Check(LForm.SampleData.Active and (LForm.SampleData.RecordCount = 40), 'Dataset resource did not recreate its 40 sample rows.');
    Check(LForm.Grid.Columns.Count = 11, 'Dataset columns were not streamed.');
    Check(LForm.Grid.HeaderLayout.Cells.Count = 13, 'Dataset merged header cells were not streamed.');
    Check(LForm.DataController.GetValue(0, 'ID').AsInteger = 1, 'Dataset controller cannot read the sample data.');
    LForm.SampleData.First;
    Check(TBlobField(LForm.SampleData.FieldByName('PICTURE')).BlobSize > 0, 'Dataset sample PNG was not generated.');

    LForm.AutoHeightCheck.Checked := False;
    LForm.MultiHeaderCheck.Checked := False;
    LForm.EveryFifthCheck.Checked := False;
    LForm.PagedCheck.Checked := True;
    LForm.CacheCheck.Checked := False;
    LForm.DarkCheck.Checked := True;
    LForm.PictureCheck.Checked := False;
    LForm.SeparatorsCheck.Checked := False;
    LForm.TreeEndBandCheck.Checked := False;
    LForm.AdjacentGroupCheck.Checked := False;
    LForm.OptionClick(nil);
    Check(LForm.Grid.RowHeight.Mode = Th5uRowHeightMode.Fixed, 'Dataset row height option failed.');
    Check(not LForm.Grid.HeaderLayout.Enabled, 'Dataset header option failed.');
    Check(not LForm.Grid.Tree.Enabled, 'Dataset tree option failed.');
    Check(not LForm.Grid.AdjacentGroupFolding.Enabled, 'Dataset adjacent-group option failed.');
    Check(LForm.Grid.Theme = Th5uGridTheme.Dark, 'Dataset theme option failed.');
    Check(not LForm.Grid.Columns.FindById('picture').Visible, 'Dataset picture column option failed.');
    Check(not LForm.Grid.GridLines, 'Dataset separators option failed.');
    Check(LForm.DataController.Cache.Mode = Th5uCacheMode.None, 'Dataset cache option failed.');
    Check(LForm.DataController.GetRowCount = 10, 'Dataset pagination failed.');
    LForm.NextPageButtonClick(nil);
    Check(LForm.DataController.Pagination.PageIndex = 1, 'Dataset next-page button failed.');
    LNameColumn := LForm.Grid.Columns.FindById('name');
    LForm.MoveNameButtonClick(nil);
    Check(LNameColumn.VisibleIndex = High(LForm.Grid.Columns.VisibleColumns), 'Dataset move-column button failed.');

    LForm.AdjacentGroupCheck.Checked := True;
    LForm.OptionClick(nil);
    LForm.ToggleGroupsButtonClick(nil);
    Check(LForm.ToggleGroupsButton.Caption = 'Alle öffnen', 'Dataset collapse-all button failed.');
    LForm.ToggleGroupsButtonClick(nil);
    Check(LForm.ToggleGroupsButton.Caption = 'Alle falten', 'Dataset expand-all button failed.');
  finally
    LForm.Free;
  end;
  WriteLn('PASS: ClientDataset resource, sample data, options and buttons');
end;

procedure TestObjects;
var
  LForm: TLclObjectDemoForm;
  I: Integer;
  LAmountBefore, LAmountAfter: Currency;
begin
  Trace('Loading ObjectList form resource...');
  LForm := TLclObjectDemoForm.Create(nil);
  try
    LForm.UpdateTimer.Enabled := False;
    Check(not LForm.Visible, 'Object-list form must remain hidden.');
    Check(LForm.Grid.DataController = LForm.ObjectController, 'Object-list controller reference was not streamed.');
    Check(LForm.Grid.Columns.Count = 8, 'Object-list columns were not streamed.');
    Check(LForm.ObjectController.Count = 80, 'Object-list initialization failed.');
    Check(LForm.ObjectController.GetValue(0, 'Id').AsInteger = 1, 'Object-list integer RTTI failed.');
    Check(LForm.ObjectController.GetDisplayText(0, 'Name') = 'Mitarbeiter 1', 'Object-list string RTTI failed.');
    Check(LForm.ObjectController.GetValue(0, 'Active').AsBoolean, 'Object-list Boolean RTTI failed.');
    Check(not LForm.ObjectController.GetValue(0, 'UpdatedAt').IsEmpty, 'Object-list date RTTI failed.');
    LForm.ObjectController.SetValue(0, 'Name', TValue.specialize From<string>('Geändert: äöü'));
    Check(TPersonRow(LForm.ObjectController.Item(0)).Name = 'Geändert: äöü', 'Object-list RTTI editing lost UTF-8 text.');

    LForm.AddButtonClick(nil);
    Check(LForm.ObjectController.Count = 81, 'Object-list add button failed.');
    LForm.CacheCheck.Checked := True;
    LForm.CacheCheckClick(nil);
    Check(LForm.ObjectController.Cache.Mode = Th5uCacheMode.Viewport, 'Object-list cache option failed.');
    LAmountBefore := 0;
    for I := 0 to LForm.ObjectController.Count - 1 do
      LAmountBefore := LAmountBefore + TPersonRow(LForm.ObjectController.Item(I)).Amount;
    LForm.UpdateTimerTimer(nil);
    LAmountAfter := 0;
    for I := 0 to LForm.ObjectController.Count - 1 do
      LAmountAfter := LAmountAfter + TPersonRow(LForm.ObjectController.Item(I)).Amount;
    Check(LAmountAfter = LAmountBefore + 12.5, 'Object-list live update failed.');
    LForm.DarkCheck.Checked := True;
    LForm.DarkCheckClick(nil);
    Check(LForm.Grid.Theme = Th5uGridTheme.Dark, 'Object-list theme option failed.');
    LForm.LiveCheck.Checked := False;
    LForm.LiveCheckClick(nil);
    Check(not LForm.UpdateTimer.Enabled, 'Object-list pause option failed.');
  finally
    LForm.Free;
  end;
  WriteLn('PASS: ObjectList resource, published RTTI, editing and live updates');
end;

procedure TestVirtual;
const
  CFields: array[0..5] of string = ('ID', 'TIMESTAMP', 'SOURCE', 'MESSAGE', 'SEVERITY', 'ACK');
var
  LForm: TLclVirtualDemoForm;
  LField: string;
begin
  Trace('Loading VirtualLive form resource...');
  LForm := TLclVirtualDemoForm.Create(nil);
  try
    LForm.LiveTimer.Enabled := False;
    Check(not LForm.Visible, 'Virtual form must remain hidden.');
    Check(LForm.Grid.DataController = LForm.VirtualController, 'Virtual controller reference was not streamed.');
    Check(LForm.Grid.Columns.Count = 6, 'Virtual columns were not streamed.');
    Check(LForm.VirtualController.GetTotalRowCount = 60, 'Virtual initialization or row-count event failed.');
    for LField in CFields do
      Check(not LForm.VirtualController.GetValue(0, LField).IsEmpty, 'Virtual value event failed for ' + LField);
    LForm.VirtualController.SetValue(0, 'ACK', TValue.specialize From<Boolean>(True));
    Check(LForm.VirtualController.GetValue(0, 'ACK').AsBoolean, 'Virtual Boolean editing failed.');
    LForm.VirtualController.SetValue(0, 'MESSAGE', TValue.specialize From<string>('Quittiert: äöü'));
    Check(LForm.VirtualController.GetDisplayText(0, 'MESSAGE') = 'Quittiert: äöü', 'Virtual string editing lost UTF-8 text.');
    LForm.VirtualController.PrepareRange(0, 10);
    Check(Pos('Viewport-Anfrage:', LForm.StatusLabel.Caption) = 1, 'Virtual prepare-range event failed.');
    LForm.AppendButtonClick(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 61, 'Virtual append button failed.');
    LForm.LiveTimerTimer(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 61, 'Virtual live update unexpectedly changed the row count.');
    LForm.PauseCheck.Checked := True;
    LForm.PagedCheck.Checked := True;
    LForm.CacheCheck.Checked := False;
    LForm.DarkCheck.Checked := True;
    LForm.OptionClick(nil);
    Check(not LForm.LiveTimer.Enabled, 'Virtual pause option failed.');
    Check(LForm.VirtualController.Cache.Mode = Th5uCacheMode.None, 'Virtual cache option failed.');
    Check(LForm.Grid.Theme = Th5uGridTheme.Dark, 'Virtual theme option failed.');
    Check(LForm.VirtualController.GetRowCount = 20, 'Virtual pagination failed.');
    LForm.NextPageButtonClick(nil);
    Check(LForm.VirtualController.Pagination.PageIndex = 1, 'Virtual next-page button failed.');
    LForm.ClearButtonClick(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 0, 'Virtual clear button failed.');
    LForm.LiveTimerTimer(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 1, 'Virtual live append after clearing failed.');
  finally
    LForm.Free;
  end;
  WriteLn('PASS: VirtualLive resource, data events, editing, paging and live updates');
end;

begin
  try
    RequireDerivedFormResource := True;
    Application.Initialize;
    // No Show, application message loop or focus-changing calls: forms stay hidden.
    TestDataset;
    TestObjects;
    TestVirtual;
    WriteLn('All LCL demo resource tests passed.');
  except
    on E: Exception do
    begin
      WriteLn(StdErr, E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
