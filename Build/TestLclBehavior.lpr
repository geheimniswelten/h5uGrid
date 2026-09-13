program TestLclBehavior;

{$MODE OBJFPC}{$H+}
{$CODEPAGE UTF8}
{$SCOPEDENUMS ON}

uses
  Interfaces, Classes, SysUtils, Types, Rtti, DateUtils, Forms, Controls,
  StdCtrls, Graphics, DateTimePicker, LCLType, LazUTF8,
  h5u.Grid.Compat, h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Editors,
  h5u.Grid.Data.Memory, Lcl.h5u.Grid, Lcl.h5u.Grid.Editors, Lcl.h5u.Grid.Styles;

type
  TNativeMouseButton = Controls.TMouseButton;
  TGridProbe = class(Th5uLclGrid)
  public
    procedure Press(AKey: Word);
    procedure TypeUTF8(const AText: string);
    procedure ClickCell(AColumn: Th5uGridColumn; ARow: Integer);
    procedure Render(ABitmap: Graphics.TBitmap);
  end;
  TPickerProbe = class(TDateTimePicker)
  public
    procedure OpenCalendar;
  end;
  TEvents = class
    Changes: Integer;
    Errors: Integer;
    procedure Changed(Sender: TObject);
    procedure Failed(Sender: TObject; E: Exception);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure TEvents.Changed(Sender: TObject);
begin
  Inc(Changes);
end;

procedure TEvents.Failed(Sender: TObject; E: Exception);
begin
  Inc(Errors);
  WriteLn(StdErr, E.ClassName, ': ', E.Message);
end;

procedure TGridProbe.Press(AKey: Word);
begin
  KeyDown(AKey, []);
end;

procedure TGridProbe.TypeUTF8(const AText: string);
var
  K: TUTF8Char;
begin
  K := AText;
  UTF8KeyPress(K);
end;

procedure TPickerProbe.OpenCalendar;
begin
  DropDownCalendarForm;
end;

procedure TGridProbe.Render(ABitmap: Graphics.TBitmap);
begin
  ABitmap.Canvas.Brush.Color := clFuchsia;
  ABitmap.Canvas.FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
  PaintWindow(ABitmap.Canvas.Handle);
  Check(ABitmap.Canvas.Pixels[2, 2] <> clFuchsia, 'Grid painted into the target canvas');
end;

procedure TGridProbe.ClickCell(AColumn: Th5uGridColumn; ARow: Integer);
var
  X, Y: Integer;
  H: Th5uHitTestInfo;
begin
  Repaint;
  for Y := HeaderRowHeight + 2 to ClientHeight - 1 do
    for X := 1 to ClientWidth - 1 do
    begin
      H := HitTest(X, Y);
      if (H.Kind = Th5uHitKind.DataCell) and (H.Column = AColumn) and (H.RowIndex = ARow) then
      begin
        MouseDown(TNativeMouseButton(0), [], (H.Bounds.Left + H.Bounds.Right) div 2, (H.Bounds.Top + H.Bounds.Bottom) div 2);
        MouseUp(TNativeMouseButton(0), [], (H.Bounds.Left + H.Bounds.Right) div 2, (H.Bounds.Top + H.Bounds.Bottom) div 2);
        Exit;
      end;
    end;
  raise Exception.Create('Visible cell not found: ' + AColumn.FieldName);
end;

procedure SendEditorKey(AGrid: TGridProbe; AKey: Word);
var
  C: Char;
begin
  Check(Assigned(AGrid.ActiveEditor), 'Expected active editor');
  C := #0;
  AGrid.ActiveEditor.KeyDown(AKey, C, []);
end;

procedure TestGrid;
var
  F: TForm;
  G: TGridProbe;
  Data: Th5uMemoryController;
  NameCol, NumberCol, DateCol: Th5uGridColumn;
  I: Integer;
  Editor: Th5uLclCustomEditor;
  Picker: TDateTimePicker;
  V: TValue;
  T: Th5uGridTheme;
  B: Graphics.TBitmap;
  PNG: TPortableNetworkGraphic;
  Events: TEvents;
begin
  Events := TEvents.Create;
  F := TForm.CreateNew(nil);
  try
    Application.OnException := @Events.Failed;
    F.Caption := 'h5u.Grid LCL regression';
    F.SetBounds(160, 140, 760, 440);
    Data := Th5uMemoryController.Create(F);
    for I := 0 to 99 do
      Data.AppendValues(['Name', 'Count', 'Date'], [TValue.specialize From<string>('Row ' + IntToStr(I)), TValue.specialize From<Integer
        >(I), TValue.specialize From<TDateTime>(EncodeDate(2026, 9, 13))]);
    Data.SetValue(1, 'Name', TValue.specialize From<string>('Äpfel 東京'));
    G := TGridProbe.Create(F);
    G.Parent := F;
    G.Align := alClient;
    G.AllowEditing := True;
    G.ImmediateEdit := False;
    G.DataController := Data;
    NameCol := G.Columns.Add;
    NameCol.Id := 'name';
    NameCol.FieldName := 'Name';
    NameCol.Caption := 'Name / UTF-8';
    NameCol.Width := 250;
    NameCol.DataType := Th5uColumnDataType.Text;
    NumberCol := G.Columns.Add;
    NumberCol.Id := 'count';
    NumberCol.FieldName := 'Count';
    NumberCol.DataType := Th5uColumnDataType.Integer;
    DateCol := G.Columns.Add;
    DateCol.Id := 'date';
    DateCol.FieldName := 'Date';
    DateCol.Width := 200;
    DateCol.DataType := Th5uColumnDataType.DateTime;
    F.Show;
    Application.ProcessMessages;
    G.Repaint;
    G.ClickCell(NameCol, 0);
    Check(G.Selection.FocusedCell.IsValid, 'Mouse selection establishes focused cell');
    G.Press(VK_F2);
    Check(Assigned(G.ActiveEditor), 'F2 starts editor');
    Check(G.ActiveEditor is Th5uLclTextEditor, 'Text editor registration and F2');
    G.ActiveEditor.SetText('Grüße 東京');
    SendEditorKey(G, VK_RETURN);
    Check(h5uValueAsText(Data.GetValue(0, 'Name')) = string('Grüße 東京'), 'UTF-8 commit');
    G.ClickCell(NameCol, 0);
    G.Press(VK_F2);
    G.ActiveEditor.SetText('discard me');
    SendEditorKey(G, VK_ESCAPE);
    Check(h5uValueAsText(Data.GetValue(0, 'Name')) = string('Grüße 東京'), 'Escape cancels draft');
    G.ClickCell(NameCol, 0);
    G.TypeUTF8('ä');
    Check(G.Selection.FocusedCell.RowIndex = 1, 'UTF-8 case-insensitive typeahead');
    G.ClickCell(NumberCol, 0);
    G.Press(VK_F2);
    Check(G.ActiveEditor is Th5uLclIntegerEditor, 'Integer editor registration');
    G.ActiveEditor.SetText('42');
    SendEditorKey(G, VK_RETURN);
    Check(Data.GetValue(0, 'Count').AsInt64 = 42, 'Integer commit');
    G.ClickCell(DateCol, 0);
    G.Press(VK_F2);
    Check(G.ActiveEditor is Th5uLclDateTimeEditor, 'DateTime editor registration');
    Editor := Th5uLclCustomEditor(G.ActiveEditor);
    Picker := TDateTimePicker(Editor.Control);
    Check(Picker.Kind = dtkDateTime, 'Combined date and time picker');
    Editor.OnChange := @Events.Changed;
    Events.Changes := 0;
    Picker.Checked := False;
    Check(Events.Changes > 0, 'NULL checkbox change notifies editor');
    Check(Editor.GetValue.IsEmpty, 'Unchecked date returns NULL');
    Picker.Checked := True;
    Picker.DateTime := EncodeDateTime(2027, 2, 3, 12, 34, 56, 0);
    V := Editor.GetValue;
    Check(Abs(V.AsExtended - Picker.DateTime) < 1E-8, 'Date and time preserved');
    TPickerProbe(Picker).OpenCalendar;
    Application.ProcessMessages;
    Check(Picker.DroppedDown and Editor.DeferExit and Assigned(G.ActiveEditor), 'Calendar popup keeps editor alive');
    // Cancel destroys/hides the native editor safely even while the calendar is open.
    SendEditorKey(G, VK_ESCAPE);
    Application.ProcessMessages;
    Check(not Assigned(G.ActiveEditor), 'Date editor cancellation');
    G.ClickCell(NameCol, 0);
    G.Press(VK_NEXT);
    Check(G.Selection.FocusedCell.RowIndex > 0, 'PageDown navigation');
    G.Press(VK_HOME);
    G.MoveColumn(NumberCol, 0);
    Check(NumberCol.VisibleIndex = 0, 'Column move');
    G.SetColumnVisible(DateCol, False);
    Check(not DateCol.Visible, 'Column visibility');
    G.SetColumnVisible(DateCol, True);
    B := Graphics.TBitmap.Create;
    PNG := TPortableNetworkGraphic.Create;
    try
      B.SetSize(G.Width, G.Height);
      for T := Low(Th5uGridTheme) to High(Th5uGridTheme) do
      begin
        G.Theme := T;
        G.Repaint;
        G.Render(B);
      end;
      if ParamCount > 1 then
      begin
        G.Theme := Th5uGridTheme.Modern;
        G.Render(B);
        PNG.Assign(B);
        PNG.SaveToFile(ParamStr(2));
      end;
    finally
      PNG.Free;
      B.Free;
    end;
    Check(Events.Errors = 0, 'No asynchronous LCL errors');
    WriteLn('PASS: LCL painting, UTF-8 input, editing, dates, navigation, column layout');
  finally
    Application.OnException := nil;
    F.Free;
    Events.Free;
  end;
end;

begin
  if (ParamCount = 0) or (ParamStr(1) <> '--visual') then
  begin
    WriteLn(StdErr, 'Run through Build/test-lcl.ps1 so the desktop countdown is shown.');
    Halt(2);
  end;
  try
    Application.Initialize;
    TestGrid;
  except
    on E: Exception do
    begin
      WriteLn(StdErr, E.ClassName, ': ', E.Message);
      DumpExceptionBackTrace(StdErr);
      Halt(1);
    end;
  end;
end.
