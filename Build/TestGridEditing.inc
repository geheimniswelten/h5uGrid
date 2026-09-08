uses
  System.Classes, System.DateUtils, System.SysUtils, System.Types, System.Rtti, System.UITypes,
  Data.DB, Datasnap.DBClient, MidasLib,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Data.Core, h5u.Grid.Data.Dataset,
{$IFDEF TEST_FMX}
  System.UIConsts, FMX.Types, FMX.StdCtrls, FMX.Forms, FMX.Controls, FMX.Edit, FMX.DateTimeCtrls, FMX.Graphics, Fmx.h5u.Grid, Fmx.h5u.Grid.Styles,
  FmxDatasetDemoMain in '..\Demos\FMX\ClientDataset\FmxDatasetDemoMain.pas',
  FmxListDemoMain in '..\Demos\FMX\ObjectList\FmxListDemoMain.pas',
  FmxVirtualDemoMain in '..\Demos\FMX\VirtualLive\FmxVirtualDemoMain.pas';
{$ELSE}
  Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Graphics, Vcl.h5u.Grid, Vcl.h5u.Grid.Styles,
  VclDatasetDemoMain in '..\Demos\VCL\ClientDataset\VclDatasetDemoMain.pas',
  VclObjectDemoMain in '..\Demos\VCL\ObjectList\VclObjectDemoMain.pas',
  VclVirtualDemoMain in '..\Demos\VCL\VirtualLive\VclVirtualDemoMain.pas';
{$ENDIF}

type
{$IFDEF TEST_FMX}
  TDateEditAccess = class(Th5uCellDateEdit)
  public
    procedure PickDate(const ADate: TDateTime);
  end;
{$ENDIF}

  TCellBoundsProbe = class
  public
    Found: Boolean;
{$IFDEF TEST_FMX}
    Bounds: TRectF;
    procedure Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext;
      AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
{$ELSE}
    Bounds: TRect;
    procedure Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext;
      AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
{$ENDIF}
  end;
  TExceptionSink = class
  public
    Count: Integer;
    procedure HandleException(Sender: TObject; E: Exception);
  end;

{$IFDEF TEST_FMX}
  TGridAccess = class(Th5uFmxGrid)
{$ELSE}
  TGridAccess = class(Th5uVclGrid)
{$ENDIF}
  public
    procedure Press(AKey: Word; AShift: TShiftState = []);
    procedure TypeText(const AText: string);
    procedure ClickAt(const APoint: TPoint; ADouble: Boolean = False);
  end;

  TFixture = class
  private
    procedure Changed(Sender: TObject; const AChange: Th5uDataChange);
    procedure BeforePost(DataSet: TDataSet);
    procedure AfterPost(DataSet: TDataSet);
  public
    Form: TForm;
    Grid: TGridAccess;
    Data: TClientDataSet;
    Source: TDataSource;
    Controller: Th5uDatasetController;
    Link: Th5uDataControllerLink;
    Editor: TEdit;
    Posts: Integer;
    Changes: Integer;
    RejectPost: Boolean;
    HideOnReject: Boolean;
    constructor Create(AMode: Th5uCacheMode);
    destructor Destroy; override;
    procedure PaintGrid;
    function CellPoint(const AField: string): TPoint;
    procedure EditorKey(AKey: Word);
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

{$IFDEF TEST_FMX}
procedure TDateEditAccess.PickDate(const ADate: TDateTime);
begin
  HandlerPickerDateTimeChanged(Self, ADate);
end;
{$ENDIF}

{$IFDEF TEST_FMX}
procedure TCellBoundsProbe.Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext;
  AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
{$ELSE}
procedure TCellBoundsProbe.Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext;
  AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
{$ENDIF}
begin
  if (AContext.FactoryContext.ElementKind = Th5uElementKind.DataCell)
    and (AContext.FactoryContext.ViewRowIndex = 0)
    and (Th5uGridColumn(AContext.FactoryContext.Column).FieldName = 'FLAG') then
  begin
    Found := True;
    Bounds := AContext.Bounds;
  end;
end;
procedure TExceptionSink.HandleException(Sender: TObject; E: Exception);
begin
  Inc(Count);
  Writeln('EVENT EXCEPTION: ', E.ClassName, ': ', E.Message);
end;

procedure TGridAccess.ClickAt(const APoint: TPoint; ADouble: Boolean);
begin
  MouseDown(TMouseButton.mbLeft, [], APoint.X, APoint.Y);
  MouseUp(TMouseButton.mbLeft, [], APoint.X, APoint.Y);
  if not ADouble then
    Exit;
{$IFDEF TEST_FMX}
  MouseDown(TMouseButton.mbLeft, [ssDouble], APoint.X, APoint.Y);
  MouseUp(TMouseButton.mbLeft, [ssDouble], APoint.X, APoint.Y);
{$ELSE}
  // Exercise VCL's actual DblClick -> MouseDown(ssDouble) dispatch order.
  Perform(WM_LBUTTONDBLCLK, MK_LBUTTON, MakeLParam(APoint.X, APoint.Y));
  Perform(WM_LBUTTONUP, 0, MakeLParam(APoint.X, APoint.Y));
{$ENDIF}
end;

procedure TGridAccess.Press(AKey: Word; AShift: TShiftState);
{$IFDEF TEST_FMX}
var LChar: Char;
{$ENDIF}
begin
{$IFDEF TEST_FMX}
  LChar := #0;
  KeyDown(AKey, LChar, AShift);
{$ELSE}
  if AShift = [] then
  begin
    Check(Perform(CN_KEYDOWN, AKey, 0) = 0, 'VCL intercepted grid key');
    Perform(WM_KEYDOWN, AKey, 0);
  end
  else
    KeyDown(AKey, AShift);
{$ENDIF}
end;

procedure TGridAccess.TypeText(const AText: string);
var
  C: Char;
  K: Char;
{$IFDEF TEST_FMX}
  W: Word;
{$ENDIF}
begin
  for C in AText do
  begin
    K := C;
{$IFDEF TEST_FMX}
    W := 0;
    KeyDown(W, K, []);
{$ELSE}
    KeyPress(K);
{$ENDIF}
  end;
end;
constructor TFixture.Create(AMode: Th5uCacheMode);
var
  LColumn: Th5uGridColumn;
  LIndex: Integer;
  LText: TStringStream;
  LBinary: TMemoryStream;
begin
  inherited Create;
  Form := TForm.CreateNew(nil);
  Form.Left := 30;
  Form.Top := 30;
  Form.ClientWidth := 620;
  Form.ClientHeight := 240;
  Data := TClientDataSet.Create(Form);
  Data.FieldDefs.Add('FLAG', ftBoolean);
  Data.FieldDefs.Add('DESCRIPTION', ftWideMemo);
  Data.FieldDefs.Add('NUMBER', ftInteger);
  Data.FieldDefs.Add('DATEVALUE', ftDateTime);
  Data.CreateDataSet;
  for LIndex := 1 to 3 do
    Data.AppendRecord([True, 'Original memo', LIndex]);
  Data.First;
  Data.BeforePost := BeforePost;
  Data.AfterPost := AfterPost;
  Source := TDataSource.Create(Form);
  Source.DataSet := Data;
  Controller := Th5uDatasetController.Create(Form);
  Controller.Cache.Mode := AMode;
  Controller.DataSource := Source;
  // Create the control through streaming, as in the actual demo forms.
  LText := TStringStream.Create('object TestForm: TForm' + sLineBreak
    + '  object Grid: TGridAccess' + sLineBreak + '  end' + sLineBreak + 'end');
  try
    LBinary := TMemoryStream.Create;
    try
      ObjectTextToBinary(LText, LBinary);
      LBinary.Position := 0;
      LBinary.ReadComponent(Form);
    finally
      LBinary.Free;
    end;
  finally
    LText.Free;
  end;
  Grid := Form.FindComponent('Grid') as TGridAccess;
  Grid.SetBounds(0, 0, 600, 220);
  for LIndex := 0 to 2 do
  begin
    LColumn := Grid.Columns.Add;
    LColumn.Id := Data.Fields[LIndex].FieldName;
    LColumn.FieldName := LColumn.Id;
    LColumn.Caption := LColumn.Id;
    LColumn.VisibleIndex := LIndex;
    LColumn.Width := 150;
    case LIndex of
      0: LColumn.DataType := Th5uColumnDataType.Boolean;
      1: LColumn.DataType := Th5uColumnDataType.Text;
      2: LColumn.DataType := Th5uColumnDataType.Integer;
    end;
  end;
  Grid.DataController := Controller;
  for LIndex := 0 to Grid.ComponentCount - 1 do
    if Grid.Components[LIndex] is TEdit then
      Editor := TEdit(Grid.Components[LIndex]);
  Check(Assigned(Editor), 'Cell editor missing');
  Link := Th5uDataControllerLink.Create;
  Link.Controller := Controller;
  Link.OnChanged := Changed;
  Form.Show;
  PaintGrid;
  Posts := 0;
  Changes := 0;
end;

destructor TFixture.Destroy;
begin
  Link.Free;
  if Assigned(Grid) then
    Grid.DataController := nil;
  Form.Free;
  inherited Destroy;
end;

procedure TFixture.Changed(Sender: TObject; const AChange: Th5uDataChange);
var
  LIndex: Integer;
begin
  Inc(Changes);
  Check(Changes < 100, 'Recursive data changes');
  Controller.PrepareRange(0, 3);
  for LIndex := 0 to 2 do
    Controller.GetValue(LIndex, 'DESCRIPTION');
end;

procedure TFixture.BeforePost(DataSet: TDataSet);
begin
  if RejectPost then
  begin
    if HideOnReject then
      Grid.Visible := False;
    raise EDatabaseError.Create('Rejected by test validation');
  end;
end;

procedure TFixture.AfterPost(DataSet: TDataSet);
begin
  Inc(Posts);
end;

procedure TFixture.PaintGrid;
var
  LBitmap: TBitmap;
begin
{$IFDEF TEST_FMX}
  LBitmap := Grid.MakeScreenshot;
{$ELSE}
  LBitmap := TBitmap.Create;
  LBitmap.SetSize(Grid.Width, Grid.Height);
  Grid.PaintTo(LBitmap.Canvas.Handle, 0, 0);
{$ENDIF}
  LBitmap.Free;
end;

function TFixture.CellPoint(const AField: string): TPoint;
var
  LX, LY: Integer;
{$IFDEF TEST_FMX}
  LHit: Th5uFmxHitTestInfo;
{$ELSE}
  LHit: Th5uHitTestInfo;
{$ENDIF}
begin
  PaintGrid;
  for LY := 0 to Trunc(Grid.Height) div 4 do
    for LX := 0 to Trunc(Grid.Width) div 4 do
    begin
{$IFDEF TEST_FMX}
      LHit := Grid.GridHitTest(LX * 4, LY * 4);
      if LHit.Kind <> Th5uFmxHitKind.DataCell then
{$ELSE}
      LHit := Grid.HitTest(LX * 4, LY * 4);
      if LHit.Kind <> Th5uHitKind.DataCell then
{$ENDIF}
        Continue;
      if (LHit.RowIndex = 0) and (LHit.Column.FieldName = AField) then
        Exit(Point(Round((LHit.Bounds.Left + LHit.Bounds.Right) / 2), Round((LHit.Bounds.Top + LHit.Bounds.Bottom) / 2)));
    end;
  raise Exception.Create('Cell not found: ' + AField);
end;

procedure TFixture.EditorKey(AKey: Word);
{$IFDEF TEST_FMX}
var
  LChar: Char;
{$ENDIF}
begin
{$IFDEF TEST_FMX}
  LChar := #0;
  Editor.OnKeyDown(Editor, AKey, LChar, []);
{$ELSE}
  Editor.OnKeyDown(Editor, AKey, []);
{$ENDIF}
end;

procedure TestCheckbox(AMode: Th5uCacheMode);
var
  LTest: TFixture;
  LPoint: TPoint;
begin
  LTest := TFixture.Create(AMode);
  try
    LPoint := LTest.CellPoint('FLAG');
    LTest.Grid.ClickAt(LPoint);
    Check(not LTest.Controller.GetValue(0, 'FLAG').AsBoolean, 'Single click did not toggle True to False');
    Check(LTest.Posts = 1, 'Checkbox was not posted exactly once');
    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'));
    Check(not LTest.Controller.GetValue(0, 'FLAG').AsBoolean, 'Checkbox reverted on focus change');
    LTest.Grid.ClickAt(LPoint, True);
    Check(not LTest.Controller.GetValue(0, 'FLAG').AsBoolean, 'Two rapid clicks did not toggle twice');
    Check(LTest.Posts = 3, 'Each rapid click must perform one write');
    LTest.Grid.Columns[0].ReadOnly := True;
    LTest.Grid.ClickAt(LPoint);
    Check(not LTest.Controller.GetValue(0, 'FLAG').AsBoolean, 'Read-only checkbox changed');
  finally
    LTest.Free;
  end;
end;

procedure TestEditor(AMode: Th5uCacheMode);
var
  LTest: TFixture;
  LRejected: Boolean;
begin
  LTest := TFixture.Create(AMode);
  try
    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'), True);
    Check(LTest.Editor.Visible, 'Double click immediately closed the editor');
    Check(LTest.Posts = 0, 'Opening the editor posted data');
    LTest.Editor.Text := 'New memo';
    LTest.EditorKey(vkReturn);
    Check(LTest.Controller.GetValue(0, 'DESCRIPTION').AsString = 'New memo', 'Memo was not committed');
    Check((LTest.Posts = 1) and not LTest.Editor.Visible, 'Commit did not close the editor exactly once');
    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'), True);
    LTest.Editor.Text := 'Discard this';
    LTest.EditorKey(vkEscape);
    Check(LTest.Posts = 1, 'Escape posted the cancelled text');
    Check(LTest.Controller.GetValue(0, 'DESCRIPTION').AsString = 'New memo', 'Escape changed the dataset');

    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'), True);
    LTest.Editor.Text := 'Correctable memo';
    LTest.RejectPost := True;
    LRejected := False;
    try
      LTest.EditorKey(vkReturn);
    except
      on E: EDatabaseError do
      begin
        Check(E.Message = 'Rejected by test validation', 'Validation exception was replaced');
        LRejected := True;
      end;
    end;
    Check(LRejected, 'Expected validation error');
    // A modal error dialog causes another OnExit; it must not retry the failed write.
    LTest.Editor.OnExit(LTest.Editor);
    LTest.Editor.OnExit(LTest.Editor);
    Check(LTest.Editor.Visible and (LTest.Editor.Text = 'Correctable memo'), 'Validation failure lost the editor text');
    Check(LTest.Data.State = dsBrowse, 'Failed grid-owned edit was not cancelled');
    Check(not LTest.Data.ControlsDisabled, 'Failed write left controls disabled');
    LTest.RejectPost := False;
    LTest.EditorKey(vkReturn);
    Check(LTest.Controller.GetValue(0, 'DESCRIPTION').AsString = 'Correctable memo', 'Retry did not commit');

    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'), True);
    LTest.Editor.Text := 'Focus-loss memo';
    LTest.Grid.SetFocus;
    Check(LTest.Controller.GetValue(0, 'DESCRIPTION').AsString = 'Focus-loss memo', 'Focus loss did not commit');

    LTest.Grid.ClickAt(LTest.CellPoint('NUMBER'), True);
    LTest.Editor.Text := 'not a number';
    LRejected := False;
    try
      LTest.EditorKey(vkReturn);
    except
      on E: EConvertError do
        LRejected := True;
    end;
    Check(LRejected and LTest.Editor.Visible, 'Invalid numeric input did not remain correctable');
    LTest.Editor.OnExit(LTest.Editor);
    LTest.Editor.Text := '42';
    LTest.EditorKey(vkReturn);
    Check(LTest.Controller.GetValue(0, 'NUMBER').AsInteger = 42, 'Corrected number did not commit');

    LTest.Grid.ClickAt(LTest.CellPoint('DESCRIPTION'), True);
    LTest.RejectPost := True;
    LTest.HideOnReject := True;
    LTest.Editor.Text := 'A changed value to reject';
    try
      LTest.EditorKey(vkReturn);
      raise Exception.Create('Expected rejection when hiding the grid');
    except
      on E: EDatabaseError do
        Check(E.Message = 'Rejected by test validation', 'Hidden editor masked the original exception');
    end;
  finally
    LTest.Free;
  end;
end;

procedure TestExternalEdit(AMode: Th5uCacheMode);
var
  LTest: TFixture;
begin
  LTest := TFixture.Create(AMode);
  try
    LTest.Data.First;
    LTest.Data.Edit;
    LTest.Data.FieldByName('DESCRIPTION').AsString := 'External memo';
    Check(LTest.Data.State = dsEdit, 'Observer reads prematurely posted external edit');
    LTest.Data.Post;
    Check(LTest.Posts = 1, 'External edit posted more than once');
    Check(LTest.Controller.GetValue(0, 'DESCRIPTION').AsString = 'External memo', 'External edit left stale data');
  finally
    LTest.Free;
  end;
end;

procedure TestKeyboard(AMode: Th5uCacheMode);
var
  T: TFixture;
  I: Integer;
  P: TPoint;
{$IFDEF TEST_FMX}
  H: Th5uFmxHitTestInfo;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}
begin
  T := TFixture.Create(AMode);
  try
    T.Grid.ClickAt(T.CellPoint('DESCRIPTION'));
    Check(not T.Editor.Visible, 'Single click unexpectedly opens editor');
    T.Grid.Press(vkDown);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 1, 'Down did not move');
    T.Grid.Press(vkUp);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 0, 'Up did not move');
    T.Grid.Press(vkRight);
    Check(T.Grid.Selection.FocusedCell.ColumnIndex = 2, 'Right did not move');
    T.Grid.Press(vkLeft);
    Check(T.Grid.Selection.FocusedCell.ColumnIndex = 1, 'Left did not move');
    T.Grid.Press(vkEnd);
    Check(T.Grid.Selection.FocusedCell.ColumnIndex = 2, 'End did not move');
    T.Grid.Press(vkHome);
    Check(T.Grid.Selection.FocusedCell.ColumnIndex = 0, 'Home did not move');
    T.Grid.Press(vkEnd, [ssCtrl]);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 2, 'Ctrl+End did not move');
    T.Grid.Press(vkHome, [ssCtrl]);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 0, 'Ctrl+Home did not move');
    T.Grid.Press(vkDown, [ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and T.Grid.Selection.IsCellSelected(1,0), 'Shift navigation lost anchor');
    T.Grid.Selection.SelectAllRows;
    T.Grid.Selection.SelectColumn('DESCRIPTION');
{$IFNDEF TEST_FMX}
    Check(T.Grid.Perform(CM_WANTSPECIALKEY, vkEscape, 0) <> 0, 'Escape can be consumed by a form cancel button');
{$ENDIF}
    T.Grid.Press(vkEscape);
    Check(not T.Grid.Selection.AllRowsSelected, 'Escape retained all rows');
    Check(not T.Grid.Selection.IsColumnSelected('DESCRIPTION'), 'Escape retained column');
    Check(T.Grid.Selection.CellRanges.Count = 0, 'Escape retained range');
    Check(T.Grid.Selection.FocusedCell.RowIndex = 1, 'Escape cleared focus');
    T.Grid.Press(vkRight);
    T.Grid.Press(vkEscape);
    Check(T.Grid.Selection.IsCellSelected(1,1), 'Escape cleared single cell');
    T.Grid.Selection.SelectRow(T.Grid.Selection.FocusedCell.RowKey);
    T.Grid.Press(vkEscape);
    Check(not T.Grid.Selection.IsRowSelected(T.Grid.Selection.FocusedCell.RowKey), 'Escape retained row');

    T.Data.First;
    T.Data.Edit; T.Data.FieldByName('DESCRIPTION').AsString := 'Alpha'; T.Data.Post;
    T.Data.Next;
    T.Data.Edit; T.Data.FieldByName('DESCRIPTION').AsString := 'Beta'; T.Data.Post;
    T.Data.Next;
    T.Data.Edit; T.Data.FieldByName('DESCRIPTION').AsString := 'Bravo'; T.Data.Post;
    T.Grid.Press(vkHome, [ssCtrl]);
    T.Grid.Press(vkRight);
    T.Grid.TypeText('b');
    Check(T.Grid.Selection.FocusedCell.RowIndex = 1, 'Prefix letter failed');
    T.Grid.TypeText('ra');
    Check(T.Grid.Selection.FocusedCell.RowIndex = 2, 'Prefix word failed');
    T.Grid.Press(vkEscape);
    T.Grid.TypeText('a');
    Check(T.Grid.Selection.FocusedCell.RowIndex = 0, 'Search did not wrap');
    Check(not T.Editor.Visible, 'Search opened an editor');

    T.Grid.RowHeight.FixedHeight := 47;
    T.PaintGrid;
    P := T.CellPoint('DESCRIPTION');
{$IFDEF TEST_FMX}
    H := T.Grid.GridHitTest(P.X, P.Y);
{$ELSE}
    H := T.Grid.HitTest(P.X, P.Y);
{$ENDIF}
    T.Grid.Press(vkF2);
    Check(T.Editor.Visible, 'F2 did not open editor');
    Check(Abs(T.Editor.Height - H.Bounds.Height) < 1, 'Editor height does not fit cell');
    Check(Abs(T.Editor.Width - H.Bounds.Width) < 1, 'Editor width does not fit cell');
    T.EditorKey(vkEscape);
    T.Grid.ImmediateEdit := True;
    T.Grid.ClickAt(P);
    Check(T.Editor.Visible, 'ImmediateEdit click did not open editor');
    T.EditorKey(vkEscape);
    T.Grid.Press(vkDown);
    Check(T.Editor.Visible, 'ImmediateEdit keyboard focus did not open editor');
    T.EditorKey(vkEscape);
    T.Grid.Press(vkHome);
    Check(not T.Editor.Visible, 'Boolean focus opened editor');
    Check(T.Controller.GetValue(1,'FLAG').AsBoolean, 'Boolean focus changed value');
    T.Grid.Columns[1].ReadOnly := True;
    T.Grid.Press(vkRight);
    Check(not T.Editor.Visible, 'ImmediateEdit ignored ReadOnly');
    T.Grid.Columns[1].ReadOnly := False;
    T.Grid.ImmediateEdit := False;
    T.Grid.RowHeight.FixedHeight := 24;
    for I := 4 to 50 do
    begin
      T.Changes := 0;
      T.Data.AppendRecord([True, 'Row ' + I.ToString, I]);
    end;
    T.Grid.Press(vkHome, [ssCtrl]);
    T.Grid.Press(vkNext);
    Check(T.Grid.Selection.FocusedCell.RowIndex > 1, 'PageDown did not move one page');
    T.Grid.Press(vkPrior);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 0, 'PageUp did not return');
    T.Grid.Press(vkEnd, [ssCtrl]);
    Check(T.Grid.Selection.FocusedCell.RowIndex = 49, 'Ctrl+End did not reach last row');
    T.Grid.Press(vkF2);
{$IFDEF TEST_FMX}
    Check(T.Editor.Visible and (T.Editor.Position.Y >= 0),
{$ELSE}
    Check(T.Editor.Visible and (T.Editor.Top >= 0),
{$ENDIF} 'Last row editor not visible');
    T.EditorKey(vkEscape);
  finally
    T.Free;
  end;
end;
{$IFDEF TEST_FMX}
procedure CheckInternalControls(G: TGridAccess);
var
  I, Count: Integer;
  Binary: TMemoryStream;
  TextStream: TStringStream;
begin
  Count := 0;
  for I := 0 to G.ChildrenCount - 1 do
    if G.Children[I] is TScrollBar then Inc(Count);
  Check(Count = 2, Format('Expected two internal scrollbars, found %d', [Count]));
  Binary := TMemoryStream.Create;
  TextStream := TStringStream.Create;
  try
    Binary.WriteComponent(G);
    Binary.Position := 0;
    ObjectBinaryToText(Binary, TextStream);
    Check(Pos('object TScrollBar', TextStream.DataString) = 0,
      'Internal scrollbars are persisted in the FMX resource');
    Check(Pos('object TLabel', TextStream.DataString) = 0,
      'Internal hint label is persisted in the FMX resource');
    Check(Pos('object Th5uCell', TextStream.DataString) = 0,
      'Internal cell editor is persisted in the FMX resource');
  finally
    TextStream.Free;
    Binary.Free;
  end;
  Writeln('PASS: exactly two scrollbars and no persisted internal controls: ', G.Owner.ClassName);
end;
{$ENDIF}

procedure CheckDemoCheckbox(G: TGridAccess);
var
  Columns: TArray<Th5uGridColumn>;
  Index, I, X, Y: Integer;
  Original: Boolean;
  P: TPoint;
  Found: Boolean;
{$IFDEF TEST_FMX}
  H: Th5uFmxHitTestInfo;
  B: TBitmap;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}
begin
{$IFDEF TEST_FMX}
  CheckInternalControls(G);
{$ENDIF}
  Columns := G.Columns.VisibleColumns;
  Index := -1;
  for I := 0 to High(Columns) do
    if Columns[I].DataType = Th5uColumnDataType.Boolean then
    begin Index := I; Break; end;
  Check(Index >= 0, 'Demo Boolean column missing');
  G.SetFocus;
  G.Press(vkHome, [ssCtrl]);
  for I := 1 to Index do G.Press(vkRight);
{$IFDEF TEST_FMX}
  B := G.MakeScreenshot;
  B.Free;
{$ELSE}
  G.Repaint;
{$ENDIF}
  Found := False;
  P := Point(0,0);
  for Y := 0 to Trunc(G.Height) div 4 do
  begin
    for X := 0 to Trunc(G.Width) div 4 do
    begin
{$IFDEF TEST_FMX}
      H := G.GridHitTest(X*4,Y*4);
      if (H.Kind = Th5uFmxHitKind.DataCell) and (H.RowIndex = 0) and (H.Column = Columns[Index]) then
{$ELSE}
      H := G.HitTest(X*4,Y*4);
      if (H.Kind = Th5uHitKind.DataCell) and (H.RowIndex = 0) and (H.Column = Columns[Index]) then
{$ENDIF}
      begin
        P := Point(Round((H.Bounds.Left+H.Bounds.Right)/2), Round((H.Bounds.Top+H.Bounds.Bottom)/2));
        Found := True;
        Break;
      end;
    end;
    if Found then Break;
  end;
  Check(Found, 'Visible demo checkbox missing');
  Original := G.DataController.GetValue(0, Columns[Index].FieldName).AsBoolean;
  G.ClickAt(Point(P.X-20,P.Y));
  Check(G.DataController.GetValue(0, Columns[Index].FieldName).AsBoolean = Original, 'Focus-only click changed demo Boolean');
  G.ClickAt(P);
  Check(G.DataController.GetValue(0, Columns[Index].FieldName).AsBoolean <> Original, 'First checkbox click failed in demo');
  G.ClickAt(P, True);
  Check(G.DataController.GetValue(0, Columns[Index].FieldName).AsBoolean <> Original, 'Rapid checkbox clicks failed in demo');
  G.Press(vkHome);
  Check(G.DataController.GetValue(0, Columns[Index].FieldName).AsBoolean <> Original, 'Demo checkbox reverted on focus loss');
  Writeln('PASS: demo checkbox ', G.Owner.ClassName);
end;

{$IFNDEF TEST_FMX}
procedure TestVclLiveCheckboxes;
var
  L: TVclObjectDemoForm;
  V: TVclVirtualDemoForm;
begin
  L := TVclObjectDemoForm.Create(nil);
  try
    L.Show;
    Application.ProcessMessages;
    CheckDemoCheckbox(TGridAccess(L.Grid));
  finally L.Free; end;
  V := TVclVirtualDemoForm.Create(nil);
  try
    V.Show;
    Application.ProcessMessages;
    CheckDemoCheckbox(TGridAccess(V.Grid));
  finally V.Free; end;
end;
{$ENDIF}
{$IFDEF TEST_FMX}
procedure TestLiveDemos;
var
  L: TFmxListDemoForm;
  V: TFmxVirtualDemoForm;
  G: TGridAccess;
  E: TEdit;
  I, J: Integer;
begin
  L := TFmxListDemoForm.Create(nil);
  try
    V := TFmxVirtualDemoForm.Create(nil);
    try
      for J := 0 to 1 do
      begin
        if J = 0 then begin L.Show; G := TGridAccess(L.Grid); end
        else begin L.Hide; V.Show; G := TGridAccess(V.Grid); end;
        Application.ProcessMessages;
        CheckDemoCheckbox(G);
        E := nil;
        for I := 0 to G.ComponentCount - 1 do
          if G.Components[I] is TEdit then E := TEdit(G.Components[I]);
        G.SetFocus;
        G.Press(vkHome, [ssCtrl]);
        if J = 0 then G.Press(vkRight)
        else for I := 1 to 3 do G.Press(vkRight);
        G.Press(vkF2);
        Check(E.Visible, 'Live editor missing');
        E.Text := 'Live draft';
        // Deterministic notifications plus actual timer delivery.
        if J = 0 then L.UpdateTimerTimer(L.UpdateTimer)
        else V.LiveTimerTimer(V.LiveTimer);
        for I := 1 to 150 do
        begin
          Application.ProcessMessages;
          TThread.Sleep(10);
        end;
        Check(E.Visible and (E.Text = 'Live draft'), 'Live data update discarded draft');
        if J = 0 then L.ObjectController.Clear
        else begin V.VirtualController.OnGetRowCount := nil; V.VirtualController.NotifyReset; end;
        Check(not E.Visible, 'Removed row retained an editor');
        Writeln('PASS: live demo ', J, ' retains draft and cancels removed row');
      end;
    finally
      V.Free;
    end;
  finally
    L.Free;
  end;
end;
{$ENDIF}
procedure TestTemporalEditors(AMode: Th5uCacheMode);
var
  T: TFixture;
  Kind: Th5uColumnDataType;
  I, BeforePosts: Integer;
  Expected, Original: TDateTime;
  Key: Word;
{$IFDEF TEST_FMX}
  D: TCustomDateTimeEdit;
  C: Char;
{$ELSE}
  D: TDateTimePicker;
{$ENDIF}

  procedure FindEditor;
  var J: Integer;
  begin
    D := nil;
    for J := 0 to T.Grid.ComponentCount - 1 do
{$IFDEF TEST_FMX}
      if (T.Grid.Components[J] is TCustomDateTimeEdit) and TCustomDateTimeEdit(T.Grid.Components[J]).Visible then
        D := TCustomDateTimeEdit(T.Grid.Components[J]);
{$ELSE}
      if (T.Grid.Components[J] is TDateTimePicker) and TDateTimePicker(T.Grid.Components[J]).Visible then
        D := TDateTimePicker(T.Grid.Components[J]);
{$ENDIF}
    Check(Assigned(D), 'Native date/time editor missing');
    Check(not T.Editor.Visible, 'Text editor used for a date/time cell');
    Check(Abs(D.Height-47) < 1, 'Date/time editor height does not fit the cell');
  end;

  procedure PressEditor(AKey: Word);
  begin
    Key := AKey;
{$IFDEF TEST_FMX}
    C := #0;
    D.OnKeyDown(D, Key, C, []);
{$ELSE}
    D.OnKeyDown(D, Key, []);
{$ENDIF}
  end;

begin
  T := TFixture.Create(AMode);
  try
    Original := EncodeDate(2024, 3, 12) + EncodeTime(10, 20, 30, 0);
    T.Grid.Columns[2].FieldName := 'DATEVALUE';
    T.Grid.RowHeight.FixedHeight := 47;
    for I := 0 to 2 do
    begin
      case I of
        0: Kind := Th5uColumnDataType.Date;
        1: Kind := Th5uColumnDataType.Time;
        else Kind := Th5uColumnDataType.DateTime;
      end;
      T.Changes := 0;
      T.Grid.Columns[2].DataType := Kind;
      T.Controller.SetValue(0, 'DATEVALUE', TValue.From<TDateTime>(Original));
      T.Grid.Press(vkHome, [ssCtrl]);
      T.Grid.Press(vkEnd);
      BeforePosts := T.Posts;
      T.Grid.Press(vkF2);
      FindEditor;
{$IFDEF TEST_FMX}
      if Kind = Th5uColumnDataType.Time then Check(D is TTimeEdit, 'Time cell must use TTimeEdit')
      else Check(D is TDateEdit, 'Date cell must use TDateEdit');
{$ENDIF}
      T.Grid.SetFocus;
      Check(T.Posts = BeforePosts, 'Unchanged temporal editor posted');
      T.Grid.Press(vkF2);
      FindEditor;
      Expected := EncodeDate(2025, 7, 18) + EncodeTime(15, 16, 17, 0);
      D.DateTime := Expected;
{$IFDEF TEST_FMX}
      if Kind = Th5uColumnDataType.DateTime then
      begin
        TDateEditAccess(D).PickDate(DateOf(Expected) + 1);
        Check(SameTime(D.DateTime, Expected), 'Calendar selection lost the time component');
        D.DateTime := Expected;
      end;
{$ENDIF}
      PressEditor(vkEscape);
      Check(SameDateTime(T.Controller.GetValue(0, 'DATEVALUE').AsType<TDateTime>, Original), 'Escape changed date/time');
      T.Grid.Press(vkF2);
      FindEditor;
      D.DateTime := Expected;
{$IFDEF TEST_FMX}
      if Kind = Th5uColumnDataType.DateTime then
      begin
        TDateEditAccess(D).PickDate(DateOf(Expected) + 1);
        Check(SameTime(D.DateTime, Expected), 'Calendar selection lost the time component');
        D.DateTime := Expected;
      end;
{$ENDIF}
      PressEditor(vkReturn);
      if Kind = Th5uColumnDataType.Date then Expected := DateOf(Expected)
      else if Kind = Th5uColumnDataType.Time then Expected := TimeOf(Expected);
      Check(SameDateTime(T.Controller.GetValue(0, 'DATEVALUE').AsType<TDateTime>, Expected), 'Date/time commit lost a component');
      T.Controller.SetValue(0, 'DATEVALUE', TValue.Empty);
      BeforePosts := T.Posts;
      T.Grid.SetFocus;
      T.Grid.Press(vkF2);
      FindEditor;
      T.Grid.SetFocus;
      Check(T.Controller.GetValue(0, 'DATEVALUE').IsEmpty and (T.Posts = BeforePosts), 'Unchanged null date/time became a value');
    end;
  finally T.Free; end;
end;

procedure TestOpaqueCellBackground;
var
  T: TFixture;
  B: TBitmap;
  Context: Th5uFactoryContext;
  Appearance: Th5uResolvedAppearance;
{$IFDEF TEST_FMX}
  Cell: Th5uFmxDataCell;
  Data: TBitmapData;
{$ELSE}
  Cell: Th5uVclDataCell;
{$ENDIF}
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    Context := Default(Th5uFactoryContext);
    Context.Column := T.Grid.Columns[1];
    Context.ElementKind := Th5uElementKind.DataCell;
    Appearance.Clear;
    Appearance.HasBackground := True;
    Appearance.Background := TColorRec.Red;
    B := TBitmap.Create;
{$IFDEF TEST_FMX}
    Cell := Th5uFmxDataCell.Create(Context);
{$ELSE}
    Cell := Th5uVclDataCell.Create(Context);
{$ENDIF}
    try
      B.SetSize(60, 30);
{$IFDEF TEST_FMX}
      Check(B.Canvas.BeginScene, 'Background scene failed');
      try
        B.Canvas.Clear(TAlphaColorRec.Blue);
        B.Canvas.Fill.Kind := TBrushKind.None;
        Cell.BindCell(Context, RectF(0,0,60,30), TValue.Empty, '', Appearance);
        Cell.Paint(T.Grid, B.Canvas);
      finally B.Canvas.EndScene; end;
      Check(B.Map(TMapAccess.Read, Data), 'Background map failed');
      try Check(Data.GetPixel(2,2) = TAlphaColorRec.Red, 'Previous cell color leaked');
      finally B.Unmap(Data); end;
{$ELSE}
      B.Canvas.Brush.Color := clBlue;
      B.Canvas.FillRect(Rect(0,0,60,30));
      B.Canvas.Brush.Style := bsClear;
      Cell.BindCell(Context, Rect(0,0,60,30), TValue.Empty, '', Appearance);
      Cell.Paint(T.Grid, B.Canvas);
      Check(ColorToRGB(B.Canvas.Pixels[2,2]) = clRed, 'Previous cell color leaked through transparent brush');
{$ENDIF}
      Writeln('PASS: cell background replaces previous painter state');
    finally Cell.Free; B.Free; end;
  finally T.Free; end;
end;
{$IFDEF TEST_FMX}
procedure TestHorizontalScrollBar;
var
  T: TFixture;
  I: Integer;
  Bar: TScrollBar;
  OldWidth: Single;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.Width := 400;
    T.PaintGrid;
    Bar := nil;
    for I := 0 to T.Grid.ComponentCount - 1 do
      if T.Grid.Components[I] is TScrollBar then
        if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Horizontal then
          Bar := TScrollBar(T.Grid.Components[I]);
    Check(Assigned(Bar), 'Horizontal scrollbar missing');
    Application.ProcessMessages;
    T.PaintGrid;
    Check(Bar.Visible, 'Horizontal scrollbar hidden despite overflow');
    Check(Abs(Bar.Width-T.Grid.Width)<20, 'Horizontal scrollbar retains default width');
    Check(Bar.Max > Bar.ViewportSize, 'Horizontal scrollbar thumb fills entire track');
    OldWidth := Bar.Width;
    T.Grid.Width := 300;
    Application.ProcessMessages;
    T.PaintGrid;
    Check(Bar.Width < OldWidth-80, 'Horizontal scrollbar does not resize with grid');
    Bar.Value := Bar.Max;
    Check(Abs(Bar.Value-(Bar.Max-Bar.ViewportSize))<1, 'Horizontal end position incorrect');
    T.PaintGrid;
    Check(Bar.Value > 100, 'Horizontal scrolling was reset on repaint');
    Writeln('PASS: FMX horizontal scrollbar range, end position and resize');
  finally T.Free; end;
end;

{$ENDIF}
procedure TestClippedCheckboxBounds;
var
  T: TFixture;
  Probe: TCellBoundsProbe;
  Scenario, I, Position: Integer;
  Center, OldCenter: TPoint;
  Original: Boolean;
{$IFDEF TEST_FMX}
  H: Th5uFmxHitTestInfo;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}
begin
  for Scenario := 0 to 6 do
  begin
    T := TFixture.Create(Th5uCacheMode.None);
    Probe := TCellBoundsProbe.Create;
    try
      T.Grid.Columns[0].Width := 240;
      T.Grid.RowHeight.FixedHeight := 80;
      if Scenario in [0, 3, 4] then T.Grid.Width := 190;
      if Scenario in [1, 4] then T.Grid.Height := 100;
      if Scenario in [5, 6] then
      begin
        T.Grid.Width := 400;
        T.Grid.Columns[1].FixedKind := Th5uFixedKind.Left;
        T.Grid.Columns[1].Width := 90;
        if Scenario = 6 then
        begin
          T.Grid.Columns[2].FixedKind := Th5uFixedKind.Right;
          T.Grid.Columns[2].Width := 180;
        end;
      end;
      T.Grid.OnCustomDraw := Probe.Draw;
      T.PaintGrid;
      if Scenario in [2, 3] then
      begin
        for I := 0 to T.Grid.ComponentCount - 1 do
          if T.Grid.Components[I] is TScrollBar then
{$IFDEF TEST_FMX}
            if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Vertical then
              TScrollBar(T.Grid.Components[I]).Value := 30;
{$ELSE}
            if TScrollBar(T.Grid.Components[I]).Kind = sbVertical then
            begin
              Position := 30;
              TScrollBar(T.Grid.Components[I]).OnScroll(T.Grid.Components[I], scPosition, Position);
            end;
{$ENDIF}
        Probe.Found := False;
        T.PaintGrid;
      end;
      if Scenario in [5, 6] then
      begin
        for I := 0 to T.Grid.ComponentCount - 1 do
          if T.Grid.Components[I] is TScrollBar then
{$IFDEF TEST_FMX}
            if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Horizontal then
            begin
              Check(TScrollBar(T.Grid.Components[I]).Max > TScrollBar(T.Grid.Components[I]).ViewportSize,
                'FMX horizontal scrollbar has no scrollable range');
              TScrollBar(T.Grid.Components[I]).Value := 70;
              Check(TScrollBar(T.Grid.Components[I]).Value > 0, 'Horizontal scroll value remains zero');
            end;
{$ELSE}
            if TScrollBar(T.Grid.Components[I]).Kind = sbHorizontal then
            begin
              Position := 70;
              TScrollBar(T.Grid.Components[I]).OnScroll(T.Grid.Components[I], scPosition, Position);
            end;
{$ENDIF}
        Probe.Found := False;
        T.PaintGrid;
        Check(Probe.Bounds.Left >= T.Grid.RowIndicatorWidth + 90,
          'Scrolling cell paints over fixed left column');
        if Scenario = 6 then
          Check(Probe.Bounds.Right <= T.Grid.Width - 180, 'Scrolling cell paints over fixed right column');
      end;
      Check(Probe.Found, 'Clipped first row not painted');
      if Scenario in [2, 3] then
        Check(Probe.Bounds.Height < 80, 'Top row was not actually scrolled beneath the header');
      Center := Point(Round((Probe.Bounds.Left + Probe.Bounds.Right)/2),
        Round((Probe.Bounds.Top + Probe.Bounds.Bottom)/2));
{$IFDEF TEST_FMX}
      H := T.Grid.GridHitTest(Center.X, Center.Y);
{$ELSE}
      H := T.Grid.HitTest(Center.X, Center.Y);
{$ENDIF}
      Check((Abs(H.Bounds.Left-Probe.Bounds.Left)<1) and (Abs(H.Bounds.Top-Probe.Bounds.Top)<1)
        and (Abs(H.Bounds.Right-Probe.Bounds.Right)<1) and (Abs(H.Bounds.Bottom-Probe.Bounds.Bottom)<1),
        Format('Paint/hit bounds disagree in clipping scenario %d', [Scenario]));
      Original := T.Controller.GetValue(0,'FLAG').AsBoolean;
      T.Grid.ClickAt(Center);
      Check(T.Controller.GetValue(0,'FLAG').AsBoolean <> Original,
        Format('Click on visible checkbox failed in clipping scenario %d', [Scenario]));
      T.Grid.ClickAt(Center, True);
      Check(T.Controller.GetValue(0,'FLAG').AsBoolean <> Original, 'Clipped rapid clicks were not counted');
      // The old full-column center is still inside the visible cell here, but
      // no longer inside the painted checkbox. It must not remain clickable.
      if Scenario = 0 then
      begin
        OldCenter := Point(Round(Probe.Bounds.Left+120), Center.Y);
        Check(OldCenter.X < Probe.Bounds.Right, 'Old center must be visible for regression');
        T.Grid.ClickAt(OldCenter);
        Check(T.Controller.GetValue(0,'FLAG').AsBoolean <> Original, 'Invisible checkbox hotspot remained');
      end;
      Writeln('PASS: clipped checkbox scenario ', Scenario);
    finally
      T.Grid.OnCustomDraw := nil;
      Probe.Free;
      T.Free;
    end;
  end;
end;
procedure TestCheckboxPixels;
var
  T: TFixture;
  Theme: Th5uGridTheme;
  Selected, Checked: Boolean;
  Context: Th5uFactoryContext;
  Appearance: Th5uResolvedAppearance;
  OffImage, OnImage, B: TBitmap;
  X, Y, Difference: Integer;
{$IFDEF TEST_FMX}
  Cell: Th5uFmxDataCell;
  Palette: Th5uFmxPalette;
  OffData, OnData: TBitmapData;
{$ELSE}
  Cell: Th5uVclDataCell;
  Palette: Th5uVclPalette;
{$ENDIF}
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    Context := Default(Th5uFactoryContext);
    Context.Column := T.Grid.Columns[0];
    Context.ElementKind := Th5uElementKind.DataCell;
{$IFDEF TEST_FMX}
    Cell := Th5uFmxDataCell.Create(Context);
{$ELSE}
    Cell := Th5uVclDataCell.Create(Context);
{$ENDIF}
    OffImage := TBitmap.Create;
    OnImage := TBitmap.Create;
    try
      OffImage.SetSize(60, 30);
      OnImage.SetSize(60, 30);
      for Theme := Low(Th5uGridTheme) to High(Th5uGridTheme) do
        for Selected := False to True do
        begin
          T.Grid.Theme := Theme;
{$IFDEF TEST_FMX}
          Palette := h5uGetFmxPalette(Theme);
{$ELSE}
          Palette := h5uGetVclPalette(Theme);
{$ENDIF}
          Appearance.Clear;
          Appearance.HasBackground := True;
          Appearance.HasForeground := True;
{$IFDEF TEST_FMX}
          if Selected then
          begin
            Appearance.Background := AlphaColorToColor(Palette.SelectedBackground);
            Appearance.Foreground := AlphaColorToColor(Palette.SelectedText);
          end
          else
          begin
            Appearance.Background := AlphaColorToColor(Palette.CellBackground);
            Appearance.Foreground := AlphaColorToColor(Palette.CellText);
          end;
{$ELSE}
          if Selected then
          begin
            Appearance.Background := Palette.SelectedBackground;
            Appearance.Foreground := Palette.SelectedText;
          end
          else
          begin
            Appearance.Background := Palette.CellBackground;
            Appearance.Foreground := Palette.CellText;
          end;
{$ENDIF}
          for Checked := False to True do
          begin
            if Checked then B := OnImage else B := OffImage;
{$IFDEF TEST_FMX}
            Check(B.Canvas.BeginScene, 'Bitmap BeginScene failed');
            try
              // Checkbox must not depend on another painter enabling strokes.
              B.Canvas.Stroke.Kind := TBrushKind.None;
              Cell.BindCell(Context, RectF(0,0,60,30), TValue.From<Boolean>(Checked), '', Appearance);
              Cell.Paint(T.Grid, B.Canvas);
            finally
              B.Canvas.EndScene;
            end;
{$ELSE}
            Cell.BindCell(Context, Rect(0,0,60,30), TValue.From<Boolean>(Checked), '', Appearance);
            Cell.Paint(T.Grid, B.Canvas);
{$ENDIF}
          end;
          Difference := 0;
{$IFDEF TEST_FMX}
          Check(OffImage.Map(TMapAccess.Read, OffData), 'OffImage map failed');
          try
            Check(OnImage.Map(TMapAccess.Read, OnData), 'OnImage map failed');
            try
{$ENDIF}
              for Y := 10 to 20 do
                for X := 25 to 35 do
{$IFDEF TEST_FMX}
                  if OffData.GetPixel(X,Y) <> OnData.GetPixel(X,Y) then Inc(Difference);
{$ELSE}
                  if OffImage.Canvas.Pixels[X,Y] <> OnImage.Canvas.Pixels[X,Y] then Inc(Difference);
{$ENDIF}
{$IFDEF TEST_FMX}
            finally OnImage.Unmap(OnData); end;
          finally OffImage.Unmap(OffData); end;
{$ENDIF}
          Check(Difference >= 8, Format('Checkbox checkmark invisible: theme %d, selected %s, pixels %d',
            [Ord(Theme), BoolToStr(Selected, True), Difference]));
        end;
      Writeln('PASS: checkbox pixels for all 4 themes, selected and unselected');
    finally
      OnImage.Free;
      OffImage.Free;
      Cell.Free;
    end;
  finally T.Free; end;
end;
procedure TestActualDemo;
var
{$IFDEF TEST_FMX}
  D: TFmxDatasetDemoForm;
{$ELSE}
  D: TVclDatasetDemoForm;
{$ENDIF}
  G: TGridAccess;
  E: TEdit;
  I: Integer;
  Key: Word;
{$IFDEF TEST_FMX}
  C: Char;
{$ENDIF}
begin
{$IFDEF TEST_FMX}
  D := TFmxDatasetDemoForm.Create(nil);
{$ELSE}
  D := TVclDatasetDemoForm.Create(nil);
{$ENDIF}
  try
    D.Show;
    Application.ProcessMessages;
    G := TGridAccess(D.Grid);
    CheckDemoCheckbox(G);
    E := nil;
    for I := 0 to G.ComponentCount - 1 do
      if G.Components[I] is TEdit then
        E := TEdit(G.Components[I]);
    Check(Assigned(E), 'Demo text editor missing');
    G.SetFocus;
    G.Press(vkHome, [ssCtrl]);
    G.Press(vkRight);
    G.Press(vkF2);
    Check(E.Visible, 'Demo editor did not open');
    E.Text := 'Draft must survive';
    for I := 1 to 150 do
    begin
      Application.ProcessMessages;
      TThread.Sleep(10);
    end;
    Check(E.Visible and (E.Text = 'Draft must survive'), 'Demo editor closed itself');
    Key := vkEscape;
{$IFDEF TEST_FMX}
    C := #0;
    E.OnKeyDown(E, Key, C, []);
{$ELSE}
    E.OnKeyDown(E, Key, []);
{$ENDIF}
    G.Press(vkHome, [ssCtrl]);
    for I := 1 to 4 do G.Press(vkRight);
    Check(G.Selection.FocusedCell.ColumnId = 'quantity', 'Quantity column not focused');
    Check(G.Columns[4].DataType = Th5uColumnDataType.Integer, 'Quantity type disagrees with dataset');
    G.Press(vkF2);
    G.SetFocus;
    Check(not E.Visible, 'Unchanged quantity editor did not close');
    G.Press(vkF2);
    E.Text := '42';
    Key := vkReturn;
{$IFDEF TEST_FMX}
    C := #0;
    E.OnKeyDown(E, Key, C, []);
{$ELSE}
    E.OnKeyDown(E, Key, []);
{$ENDIF}
    Check(D.DataController.GetValue(0,'QUANTITY').AsInteger = 42, 'Quantity edit failed');
    Writeln('PASS: actual ClientDataset demo delayed editor and quantity');
  finally
    D.Free;
  end;
end;
procedure TestEditorDetails(AMode: Th5uCacheMode);
var
  T: TFixture;
  P: TPoint;
  I, BeforePosts: Integer;
begin
  T := TFixture.Create(AMode);
  try
    P := T.CellPoint('FLAG');
    T.Grid.ClickAt(Point(P.X - 20, P.Y));
    Check(T.Controller.GetValue(0,'FLAG').AsBoolean, 'Click outside checkbox changed value');
    Check(T.Posts = 0, 'Click outside checkbox posted');
    T.Grid.ClickAt(Point(P.X + 20, P.Y));
    Check(T.Controller.GetValue(0,'FLAG').AsBoolean, 'Click right of checkbox changed value');
    T.Grid.ClickAt(P);
    Check(not T.Controller.GetValue(0,'FLAG').AsBoolean, 'Checkbox image click did not toggle');

    BeforePosts := T.Posts;
    T.Grid.ClickAt(T.CellPoint('NUMBER'), True);
    T.Grid.SetFocus;
    Check(T.Posts = BeforePosts, 'Unchanged numeric editor posted');
    T.Grid.ClickAt(T.CellPoint('DESCRIPTION'), True);
    T.Editor.Text := 'Keep this draft';
    for I := 1 to 150 do
    begin
      Application.ProcessMessages;
      TThread.Sleep(10);
    end;
    Check(T.Editor.Visible and (T.Editor.Text = 'Keep this draft'), 'Editor disappeared after message processing');
    T.EditorKey(vkEscape);
    Check(T.Posts = BeforePosts, 'Idle editor unexpectedly posted');
  finally
    T.Free;
  end;
end;
var
  LMode: Th5uCacheMode;
  LCase: Integer;
  LFailures: Integer;
  LExceptionSink: TExceptionSink;
begin
  Application.Initialize;
  System.Classes.RegisterClass(TGridAccess);
  LExceptionSink := TExceptionSink.Create;
  Application.OnException := LExceptionSink.HandleException;
  LFailures := 0;
  for LMode := Low(Th5uCacheMode) to High(Th5uCacheMode) do
    for LCase := 0 to 5 do
      try
        case LCase of
          0: TestCheckbox(LMode);
          1: TestEditor(LMode);
          2: TestExternalEdit(LMode);
          3: TestKeyboard(LMode);
          4: TestEditorDetails(LMode);
          5: TestTemporalEditors(LMode);
        end;
        Writeln('PASS: cache ', Ord(LMode), ', editing case ', LCase);
      except
        on E: Exception do
        begin
          Inc(LFailures);
          Writeln('FAIL: cache ', Ord(LMode), ', editing case ', LCase, ': ', E.ClassName, ': ', E.Message);
        end;
      end;
  try
{$IFDEF TEST_FMX}
    TestHorizontalScrollBar;
{$ENDIF}
    TestClippedCheckboxBounds;
    TestOpaqueCellBackground;
    TestCheckboxPixels;
    TestActualDemo;
{$IFDEF TEST_FMX}
    TestLiveDemos;
{$ELSE}
    TestVclLiveCheckboxes;
{$ENDIF}
  except
    on E: Exception do
    begin
      Inc(LFailures);
      Writeln('FAIL: actual demo: ', E.ClassName, ': ', E.Message);
    end;
  end;
  if (LFailures > 0) or (LExceptionSink.Count > 0) then
    ExitCode := 1;
  Application.OnException := nil;
  LExceptionSink.Free;
end.
