uses
  System.TypInfo, System.Classes, System.DateUtils, System.SysUtils, System.Types, System.Rtti, System.UITypes,
  Data.DB, Datasnap.DBClient, MidasLib,
  h5u.Grid.Editors,
  h5u.Grid.Selection, h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Options,
  h5u.Grid.Data.Core, h5u.Grid.Data.Dataset,
{$IFDEF TEST_FMX}
  System.UIConsts, FMX.Objects, FMX.Types, FMX.StdCtrls, FMX.Forms, FMX.Controls, FMX.Edit, FMX.DateTimeCtrls, FMX.Graphics,
  Fmx.h5u.Grid.Editors, Fmx.h5u.Grid, Fmx.h5u.Grid.Styles,
  FmxDatasetDemoMain in '..\Demos\FMX\ClientDataset\FmxDatasetDemoMain.pas',
  FmxObjectDemoMain in '..\Demos\FMX\ObjectList\FmxObjectDemoMain.pas',
  FmxVirtualDemoMain in '..\Demos\FMX\VirtualLive\FmxVirtualDemoMain.pas';
{$ELSE}
  Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Graphics, Vcl.h5u.Grid.Editors, Vcl.h5u.Grid,
    Vcl.h5u.Grid.Styles,
  VclDatasetDemoMain in '..\Demos\VCL\ClientDataset\VclDatasetDemoMain.pas',
  VclObjectDemoMain in '..\Demos\VCL\ObjectList\VclObjectDemoMain.pas',
  VclVirtualDemoMain in '..\Demos\VCL\VirtualLive\VclVirtualDemoMain.pas';
{$ENDIF}

type
{$IFDEF TEST_FMX}
  TNativeCustomEditor = Th5uFmxCustomEditor;
  TNativeTextEditor = Th5uFmxTextEditor;
  TNativeDateEditor = Th5uFmxDateEditor;
{$ELSE}
  TNativeCustomEditor = Th5uVclCustomEditor;
  TNativeTextEditor = Th5uVclTextEditor;
  TNativeDateEditor = Th5uVclDateEditor;
{$ENDIF}
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
    procedure Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
{$ELSE}
    Bounds: TRect;
    procedure Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
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
{$IFDEF TEST_FMX}
    procedure TouchDrag(const AFrom, ATo: TPointF);
    procedure PanGesture(const AFrom, ATo: TPointF);
    procedure PanPoint(const APoint: TPointF; AFlags: TInteractiveGestureFlags);
{$ENDIF}
    procedure HoverAt(const P: TPoint);
    procedure LeaveGrid;
    procedure RightClickAt(const P: TPoint; Shift: TShiftState = []);
    function HeaderBounds(AColumn: Integer): TRect;
    procedure LoseMoveCapture;
    procedure DesignModeForTest(AValue: Boolean);
    procedure Press(AKey: Word; AShift: TShiftState = []);
    procedure TypeText(const AText: string);
    procedure ClickAt(const APoint: TPoint; ADouble: Boolean = False);
    procedure ClickWithShift(const P: TPoint; Shift: TShiftState);
    procedure PointerDown(const P: TPoint; Shift: TShiftState = []);
    procedure PointerMove(const P: TPoint; Shift: TShiftState = []);
    procedure PointerUp(const P: TPoint; Shift: TShiftState = []);
  end;

  TMoveProbe = class
  public
    Count: Integer;
    Context: Th5uRowsMovedContext;
    RaiseError: Boolean;
    procedure RowsMoved(Sender: TObject; const AContext: Th5uRowsMovedContext);
  end;

  TFixture = class
  private
    procedure Changed(Sender: TObject; const AChange: Th5uDataChange);
  private
    FLastEditor: TEdit;
    function GetEditor: TEdit;
    procedure BeforePost(DataSet: TDataSet);
    procedure AfterPost(DataSet: TDataSet);
  public
    Form: TForm;
    Grid: TGridAccess;
    Data: TClientDataSet;
    Source: TDataSource;
    Controller: Th5uDatasetController;
    Link: Th5uDataControllerLink;
    property Editor: TEdit read GetEditor;
  public
    Posts: Integer;
    Changes: Integer;
    RejectPost: Boolean;
    HideOnReject: Boolean;
    constructor Create(AMode: Th5uCacheMode);
    destructor Destroy; override;
    procedure PaintGrid;
    function CellPoint(const AField: string; ARow: Integer = 0): TPoint;
    procedure EditorKey(AKey: Word);
  end;

procedure TGridAccess.DesignModeForTest(AValue: Boolean);
begin
  SetDesigning(AValue);
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
procedure TCellBoundsProbe.Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
{$ELSE}
procedure TCellBoundsProbe.Draw(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
{$ENDIF}
begin
  if (AContext.FactoryContext.ElementKind = Th5uElementKind.DataCell) and (AContext.FactoryContext.ViewRowIndex = 0)
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
  LText := TStringStream.Create('object TestForm: TForm' + sLineBreak + '  object Grid: TGridAccess' + sLineBreak + '  end' + sLineBreak + 'end');
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
    Check(not (Grid.Components[LIndex] is TEdit), 'Text editor created before first edit');
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

function TFixture.CellPoint(const AField: string; ARow: Integer): TPoint;
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
      if (LHit.RowIndex = ARow) and (LHit.Column.FieldName = AField) then
        Exit(Point(Round((LHit.Bounds.Left + LHit.Bounds.Right) / 2), Round((LHit.Bounds.Top + LHit.Bounds.Bottom) / 2)));
    end;
  raise Exception.Create('Cell not found: ' + AField);
end;

function TFixture.GetEditor: TEdit;
begin
  if Assigned(Grid.ActiveEditor) and (TNativeCustomEditor(Grid.ActiveEditor).Control is TEdit) then
    FLastEditor := TEdit(TNativeCustomEditor(Grid.ActiveEditor).Control);
  Result := FLastEditor;
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

type
  TCellEventProbe = class
    AllowFocus, AllowEdit, RejectValue, BooleanMap, GridOverride: Boolean;
    Log: string;
    ColumnValidations, GridValidations, Gets, Sets, DisplayGets, EditGets: Integer;
    Clicks, Headers, Indicators, Enters, Exits, Selections: Integer;
    procedure CanFocus(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Allow: Boolean);
    procedure CanEdit(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Allow: Boolean);
    procedure Validate(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue; var Valid: Boolean; var Error: string);
    procedure GetValue(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue; Display: Boolean);
    procedure SetValue(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue);
    procedure CellClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
    procedure HeaderClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
    procedure IndicatorClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
    procedure CellEnter(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
    procedure CellExit(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
    procedure SelectionChange(Sender: TObject);
  end;

procedure TCellEventProbe.CanFocus(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Allow: Boolean);
begin
  if Sender = AColumn then begin Log := Log+'c'; Allow := AllowFocus; end
  else begin Log := Log+'g'; if GridOverride then Allow := True; end;
end;
procedure TCellEventProbe.CanEdit(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Allow: Boolean);
begin
  if Sender = AColumn then begin Log := Log+'e'; Allow := AllowEdit; end
  else begin Log := Log+'G'; if GridOverride then Allow := True; end;
end;
procedure TCellEventProbe.Validate(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue; var Valid: Boolean; var Error: string);
begin
  if Sender = AColumn then Inc(ColumnValidations) else Inc(GridValidations);
  Valid := not RejectValue;
  Error := 'Rejected by cell event';
end;
procedure TCellEventProbe.GetValue(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue; Display: Boolean);
begin
  Inc(Gets);
  if Display then Inc(DisplayGets) else Inc(EditGets);
  if BooleanMap then Value := TValue.From<Boolean>(Value.ToString = 'yes')
  else if Display then Value := TValue.From<string>('Display: '+Value.ToString);
end;
procedure TCellEventProbe.SetValue(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var Value: TValue);
begin
  Inc(Sets);
  if BooleanMap then
  begin
    if Value.AsBoolean then Value := TValue.From<string>('yes') else Value := TValue.From<string>('no');
  end
  else Value := TValue.From<string>(UpperCase(Value.ToString));
end;
procedure TCellEventProbe.CellClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
begin Inc(Clicks); end;
procedure TCellEventProbe.HeaderClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
begin Check(ARow = -1, 'Header row index'); Inc(Headers); end;
procedure TCellEventProbe.IndicatorClick(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
begin Check(AColumn = nil, 'Indicator column'); Inc(Indicators); end;
procedure TCellEventProbe.CellEnter(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
begin Inc(Enters); end;
procedure TCellEventProbe.CellExit(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64);
begin Inc(Exits); end;
procedure TCellEventProbe.SelectionChange(Sender: TObject);
begin Inc(Selections); end;

procedure TestCellEvents;
var
  T: TFixture;
  P: TCellEventProbe;
  C: Th5uGridColumn;
  PointInCell: TPoint;
  BeforeValidate, BeforeSets: Integer;
  Rejected: Boolean;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  P := TCellEventProbe.Create;
  try
    C := T.Grid.Columns[1];
    T.Grid.Press(vkHome, [ssCtrl]);
    C.OnCanFocus := P.CanFocus;
    C.OnCanEdit := P.CanEdit;
    C.OnValidate := P.Validate;
    C.OnGetValue := P.GetValue;
    C.OnSetValue := P.SetValue;
    C.OnCellClick := P.CellClick;
    C.OnColumnHeaderClick := P.HeaderClick;
    T.Grid.OnCanFocus := P.CanFocus;
    T.Grid.OnCanEdit := P.CanEdit;
    T.Grid.OnValidate := P.Validate;
    T.Grid.OnCellClick := P.CellClick;
    T.Grid.OnColumnHeaderClick := P.HeaderClick;
    T.Grid.OnRowIndicatorClick := P.IndicatorClick;
    T.Grid.OnCellEnter := P.CellEnter;
    T.Grid.OnCellExit := P.CellExit;
    T.Grid.OnSelectionChange := P.SelectionChange;
    P.Log := '';
    T.Grid.Press(vkRight);
    Check((P.Log = 'cg') and (T.Grid.Selection.FocusedCell.ColumnIndex = 0), 'Column focus veto/order ignored');
    Check(P.Enters = 0, 'Denied cell received enter');
    P.GridOverride := True;
    T.Grid.Press(vkRight);
    Check((T.Grid.Selection.FocusedCell.ColumnIndex = 1) and (P.Enters = 1), 'Allowed cell did not receive focus');
    P.GridOverride := False;
    P.Log := '';
    T.Grid.Press(vkF2);
    Check((P.Log = 'eG') and not Assigned(T.Grid.ActiveEditor), 'Column edit veto/order ignored');
    P.AllowEdit := True;
    T.Grid.AllowEditing := False;
    C.ReadOnly := True;
    T.Grid.Press(vkF2);
    Check(T.Editor.Visible and (T.Editor.Text = 'Original memo'), 'Editor value differs from source');
    T.Editor.Text := 'changed';
    T.EditorKey(vkReturn);
    Check((P.ColumnValidations = 1) and (P.GridValidations = 0), 'Column validation did not override grid');
    Check(T.Controller.GetValue(0,'DESCRIPTION').ToString = 'CHANGED', 'SetValue conversion failed');
    T.PaintGrid;
    Check((P.DisplayGets > 0) and (P.EditGets > 0), 'Display/editor modes not reported');
    P.AllowEdit := False;
    P.GridOverride := True;
    BeforeValidate := P.ColumnValidations;
    BeforeSets := P.Sets;
    T.Grid.Press(vkF2);
    T.Editor.Text := 'discard';
    T.EditorKey(vkEscape);
    Check((P.ColumnValidations = BeforeValidate) and (P.Sets = BeforeSets), 'ESC called validate/set');
    Check(T.Controller.GetValue(0,'DESCRIPTION').ToString = 'CHANGED', 'ESC changed stored value');
    C.OnValidate := nil;
    T.Grid.Press(vkF2);
    T.Editor.Text := 'fallback';
    T.EditorKey(vkReturn);
    Check(P.GridValidations = 1, 'Grid validation fallback missing');
    P.RejectValue := True;
    T.Grid.Press(vkF2);
    T.Editor.Text := 'invalid';
    Rejected := False;
    try T.EditorKey(vkReturn); except on E: EConvertError do Rejected := E.Message = 'Rejected by cell event'; end;
    Check(Rejected and T.Editor.Visible, 'Rejected edit did not remain correctable');
    Check(T.Controller.GetValue(0,'DESCRIPTION').ToString = 'FALLBACK', 'Validation rejection wrote data');
    BeforeValidate := P.GridValidations;
    T.EditorKey(vkEscape);
    Check(P.GridValidations = BeforeValidate, 'ESC validated rejected value');
    P.RejectValue := False;
    PointInCell := T.CellPoint('DESCRIPTION');
    P.Clicks := 0;
    T.Grid.ClickAt(PointInCell);
    Check(P.Clicks = 2, 'Column/grid cell click missing');
    T.Grid.ClickAt(Point(PointInCell.X, 10));
    Check(P.Headers = 2, 'Column/grid header click missing');
    T.Grid.ClickAt(Point(10, PointInCell.Y));
    Check(P.Indicators = 1, 'Row indicator click missing');
    Check((P.Selections > 0) and (P.Exits > 0), 'Selection/exit events missing');
    T.Controller.SetValue(0,'DESCRIPTION',TValue.From<string>('yes'));
    P.BooleanMap := True;
    C.DataType := Th5uColumnDataType.Boolean;
    T.PaintGrid;
    T.Grid.ClickAt(T.CellPoint('DESCRIPTION'));
    Check(T.Controller.GetValue(0,'DESCRIPTION').ToString = 'no', 'Text-to-Boolean checkbox conversion failed');
    T.Grid.ClickAt(T.CellPoint('DESCRIPTION'));
    Check(T.Controller.GetValue(0,'DESCRIPTION').ToString = 'yes', 'Boolean-to-text checkbox conversion failed');
    Writeln('PASS: cell event permissions, validation precedence, ESC, conversion and notifications');
  finally
    T.Free;
    P.Free;
  end;
end;


type
  TElementStyleProbe = class
    Kinds: set of Th5uElementKind;
    Symbols: Integer;
{$IFDEF TEST_FMX}
    procedure Prepare(Sender, Control: TObject; Canvas: TCanvas; const Context: Th5uFmxDrawContext; Part: Th5uElementPaintPart);
{$ELSE}
    procedure Prepare(Sender, Control: TObject; Canvas: TCanvas; const Context: Th5uVclDrawContext; Part: Th5uElementPaintPart);
{$ENDIF}
  end;
{$IFDEF TEST_FMX}
procedure TElementStyleProbe.Prepare(Sender, Control: TObject; Canvas: TCanvas; const Context: Th5uFmxDrawContext; Part: Th5uElementPaintPart);
{$ELSE}
procedure TElementStyleProbe.Prepare(Sender, Control: TObject; Canvas: TCanvas; const Context: Th5uVclDrawContext; Part: Th5uElementPaintPart);
{$ENDIF}
var
  Color: TAlphaColor;
begin
  Check(Assigned(Control), 'PrepareElement has no element');
  Include(Kinds, Context.FactoryContext.ElementKind);
  if Context.FactoryContext.ElementKind = Th5uElementKind.RowHeaderCell then
    Check(Control <> Sender, 'Index cell has no element object');
  if Part = Th5uElementPaintPart.ColumnMode then Inc(Symbols);
  if Part = Th5uElementPaintPart.Background then
  begin
    case Context.FactoryContext.ElementKind of
      Th5uElementKind.DataCell: Color := TAlphaColorRec.Red;
      Th5uElementKind.ColumnHeaderCell: Color := TAlphaColorRec.Lime;
      Th5uElementKind.RowHeaderCell: Color := TAlphaColorRec.Blue;
      Th5uElementKind.Grid: Color := TAlphaColorRec.Yellow;
      else Color := TAlphaColorRec.Fuchsia;
    end;
{$IFDEF TEST_FMX}
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := Color;
{$ELSE}
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := RGB((Color shr 16) and $FF, (Color shr 8) and $FF, Color and $FF);
{$ENDIF}
  end;
  if Part = Th5uElementPaintPart.Text then
  begin
    Canvas.Font.Size := 17;
    Canvas.Font.Style := [TFontStyle.fsBold];
{$IFDEF TEST_FMX}
    Canvas.Fill.Color := TAlphaColorRec.White;
{$ELSE}
    Canvas.Font.Color := clWhite;
{$ENDIF}
  end;
end;

procedure TestElementStyleAndModes;
var
  T: TFixture;
  P: TElementStyleProbe;
  B: TBitmap;
  Pt: TPoint;
  Column: Th5uGridColumn;
  Info: PPropInfo;
{$IFDEF TEST_FMX}
  Map: TBitmapData;
  H: Th5uFmxHitTestInfo;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}
  procedure CheckPixel(X,Y: Integer; Expected: TAlphaColor; const Message: string);
{$IFNDEF TEST_FMX}
  var Actual: TColor;
{$ENDIF}
  begin
{$IFDEF TEST_FMX}
    Check(Map.GetPixel(X,Y) = Expected, Message);
{$ELSE}
    Actual := ColorToRGB(B.Canvas.Pixels[X,Y]);
    Check(Actual = RGB((Expected shr 16) and $FF, (Expected shr 8) and $FF, Expected and $FF), Message);
{$ENDIF}
  end;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  P := TElementStyleProbe.Create;
  try
    Column := T.Grid.Columns[0];
    T.Controller.KeyFieldName := 'FLAG';
    T.Grid.Tree.LevelColumnId := 'FLAG';
    T.Grid.AdjacentGroupFolding.IdColumnId := 'FLAG';
    T.Grid.RowStyles.StyleKeyColumnId := 'FLAG';
    T.Grid.ScrollHints.VerticalColumnId := 'FLAG';
    Check(Column.Mode = 'KeyField TreeLevel GroupId StyleKey ScrollHint', 'Combined column roles incorrect');
    Info := GetPropInfo(Column, 'Mode');
    Check(Assigned(Info) and (Info.SetProc = nil), 'Mode is not published read-only');
    T.Grid.OnPrepareElement := P.Prepare;
    T.PaintGrid;
    Check(P.Symbols = 0, 'Runtime modes should default to hidden');
    T.Grid.ShowColumnModes := True;
    T.PaintGrid;
    Check(P.Symbols > 0, 'Configured role symbols not painted');
    T.Grid.ShowColumnModes := False;
    T.Grid.DesignModeForTest(True);
    P.Symbols := 0;
    T.PaintGrid;
    Check(P.Symbols > 0, 'Designer must always show roles');
    T.Grid.DesignModeForTest(False);
    Check(Th5uElementKind.ContentPadding in P.Kinds, 'Padding style event missing');
    Check(Th5uElementKind.ColumnSpacing in P.Kinds, 'Column spacing style event missing');
    Check(Th5uElementKind.RowSpacing in P.Kinds, 'Row spacing style event missing');
    Pt := T.CellPoint('DESCRIPTION');
{$IFDEF TEST_FMX}
    H := T.Grid.GridHitTest(Pt.X,Pt.Y);
    B := T.Grid.MakeScreenshot;
    Check(B.Map(TMapAccess.Read, Map), 'Cannot map style image');
{$ELSE}
    H := T.Grid.HitTest(Pt.X,Pt.Y);
    B := TBitmap.Create;
    B.SetSize(T.Grid.Width,T.Grid.Height);
    T.Grid.PaintTo(B.Canvas.Handle,0,0);
{$ENDIF}
    try
      CheckPixel(Round(H.Bounds.Left)+2, Round(H.Bounds.Top)+2,TAlphaColorRec.Red,'Cell fill override lost');
      CheckPixel(Round(H.Bounds.Left)+2,3,TAlphaColorRec.Lime,'Header fill override lost');
      CheckPixel(3,Round(H.Bounds.Top)+2,TAlphaColorRec.Blue,'Index fill override lost');
      CheckPixel(550,180,TAlphaColorRec.Yellow,'Empty grid fill override lost');
    finally
{$IFDEF TEST_FMX}
      B.Unmap(Map);
{$ENDIF}
      B.Free;
    end;
    Writeln('PASS: element style pixels, spacing contexts, column modes and designer roles');
  finally
    T.Grid.OnPrepareElement := nil;
    T.Free;
    P.Free;
  end;
end;


{$IFDEF TEST_FMX}
type
  TMobileTextAccess = class(Th5uCellTextEdit)
    procedure ForceFixedHeight;
  end;
  TMobileDateAccess = class(Th5uCellDateEdit)
    procedure ForceFixedHeight;
  end;
  TMobileTimeAccess = class(Th5uCellTimeEdit)
    procedure ForceFixedHeight;
  end;

procedure TMobileTextAccess.ForceFixedHeight;
begin SetAdjustSizeValue(TSizeF.Create(100,22)); SetAdjustType(TAdjustType.FixedHeight); end;
procedure TMobileDateAccess.ForceFixedHeight;
begin SetAdjustSizeValue(TSizeF.Create(100,22)); SetAdjustType(TAdjustType.FixedHeight); end;
procedure TMobileTimeAccess.ForceFixedHeight;
begin SetAdjustSizeValue(TSizeF.Create(100,22)); SetAdjustType(TAdjustType.FixedHeight); end;

procedure TGridAccess.TouchDrag(const AFrom, ATo: TPointF);
begin
  MouseDown(TMouseButton.mbLeft,[ssTouch],AFrom.X,AFrom.Y);
  MouseMove([ssTouch,ssLeft],ATo.X,ATo.Y);
  MouseUp(TMouseButton.mbLeft,[ssTouch],ATo.X,ATo.Y);
end;

procedure TGridAccess.PanPoint(const APoint: TPointF; AFlags: TInteractiveGestureFlags);
var
  E: TGestureEventInfo;
  Handled: Boolean;
begin
  E := Default(TGestureEventInfo);
  E.GestureID := igiPan;
  E.Location := LocalToAbsolute(APoint);
  E.Flags := AFlags;
  Handled := False;
  DoGesture(E, Handled);
  Check(Handled, 'Pan not handled');
end;

procedure TGridAccess.PanGesture(const AFrom, ATo: TPointF);
begin
  PanPoint(AFrom, [TInteractiveGestureFlag.gfBegin]);
  PanPoint(ATo, []);
  PanPoint(ATo, [TInteractiveGestureFlag.gfEnd]);
end;

procedure TestMobileInputAndEditors;
var
  T: TFixture;
  P: TPoint;
  I: Integer;
  V,H: TScrollBar;
  D: TMobileDateAccess;
  C: TMobileTimeAccess;
  Back: TRectangle;
  BeforeValue: Boolean;
  Events: TCellEventProbe;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.Width := 300;
    T.Grid.Height := 180;
    T.Grid.RowHeight.FixedHeight := 80;
    T.PaintGrid;
    V := nil; H := nil;
    for I := 0 to T.Grid.ComponentCount-1 do
      if T.Grid.Components[I] is TScrollBar then
        if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Vertical then
          V := TScrollBar(T.Grid.Components[I])
        else H := TScrollBar(T.Grid.Components[I]);
    Check(Assigned(V) and Assigned(H),'Scrollbars missing');
    P := T.CellPoint('FLAG');
    BeforeValue := T.Controller.GetValue(0,'FLAG').AsBoolean;
    T.Grid.ImmediateEdit := True;
    T.Grid.TouchDrag(PointF(P.X,P.Y),PointF(P.X-40,P.Y-35));
    T.PaintGrid;
    Check((V.Value>0) and (H.Value>0),'Touch does not scroll both axes');
    Check((T.Posts=0) and (T.Controller.GetValue(0,'FLAG').AsBoolean=BeforeValue), 'Swipe edited a checkbox');
    Check(not Assigned(T.Grid.ActiveEditor),'Swipe opened an editor');
    V.Value := 0; H.Value := 0;
    T.PaintGrid;
    P := T.CellPoint('FLAG');
    T.Grid.TouchDrag(PointF(P.X,P.Y),PointF(P.X,P.Y));
    Check((T.Posts=1) and (T.Controller.GetValue(0,'FLAG').AsBoolean<>BeforeValue),'Tap did not toggle exactly once');
    T.Grid.PanGesture(PointF(170,120),PointF(110,70));
    Check((V.Value>0) and (H.Value>0),'Native pan gesture does not scroll');
    T.Grid.PanGesture(PointF(150,100),PointF(-2000,-2000));
    Check(Abs(V.Value-(V.Max-V.ViewportSize))<1,'Vertical pan exceeds range');
    Check(Abs(H.Value-(H.Max-H.ViewportSize))<1,'Horizontal pan exceeds range');
    V.Value := 0; H.Value := 0;
    T.Grid.Width := 600;
    T.PaintGrid;
    P := T.CellPoint('DESCRIPTION');
    Events := TCellEventProbe.Create;
    try
      T.Grid.OnCellClick := Events.CellClick;
      T.Grid.ClickAt(P);
      Check(Events.Clicks=1,'Native pan swallowed the next mouse click');
      T.EditorKey(vkEscape);
    finally
      T.Grid.OnCellClick := nil;
      Events.Free;
    end;
    T.Grid.TouchDrag(PointF(P.X,P.Y),PointF(P.X,P.Y));
    Check(T.Editor.Visible,'Immediate edit did not open after tap');
    Back := nil;
    for I := 0 to T.Grid.ComponentCount-1 do
      if (T.Grid.Components[I] is TRectangle) and TRectangle(T.Grid.Components[I]).Visible then
        if TRectangle(T.Grid.Components[I]).BoundsRect.EqualsTo(T.Editor.BoundsRect) then
          Back := TRectangle(T.Grid.Components[I]);
    Check(Assigned(Back),'Opaque editor background missing or wrong size');
    Check(((Back.Fill.Color shr 24)=$FF) and not Back.Stored and not Back.HitTest,'Editor background is transparent or persisted');
    TMobileTextAccess(T.Editor).ForceFixedHeight;
    T.Editor.ApplyStyleLookup;
    T.Editor.SetBounds(80,40,210,70);
    Check(Abs(T.Editor.Height-70)<1,'Text editor still fixed after style lookup');
    T.Editor.ApplyStyleLookup;
    Check(Abs(T.Editor.Height-70)<1,'Style reapplication resized text editor');
    T.EditorKey(vkEscape);
    Check(not Back.Visible,'Editor background remains after cancel');
    D := TMobileDateAccess.Create(T.Form);
    C := TMobileTimeAccess.Create(T.Form);
    try
      D.Parent := T.Form;
      C.Parent := T.Form;
      D.ApplyStyleLookup; C.ApplyStyleLookup;
      D.ForceFixedHeight; C.ForceFixedHeight;
      D.ApplyStyleLookup; C.ApplyStyleLookup;
      D.SetBounds(0,0,210,70); C.SetBounds(0,80,210,70);
      Check((Abs(D.Height-70)<1) and (Abs(C.Height-70)<1),'Date/time editor retains fixed style size');
    finally C.Free; D.Free; end;
    Writeln('PASS: touch drag/tap/pan, scroll limits, fixed editor styles and opaque backing');
  finally T.Free; end;
end;
{$ENDIF}


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
    Check((LTest.Posts = 1) and not Assigned(LTest.Grid.ActiveEditor), 'Commit did not close the editor exactly once');
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

procedure TGridAccess.ClickWithShift(const P: TPoint; Shift: TShiftState);
begin
  MouseDown(TMouseButton.mbLeft, Shift, P.X, P.Y);
  MouseUp(TMouseButton.mbLeft, Shift, P.X, P.Y);
end;

procedure TGridAccess.PointerDown(const P: TPoint; Shift: TShiftState);
begin
  MouseDown(TMouseButton.mbLeft, Shift, P.X, P.Y);
end;

procedure TGridAccess.PointerMove(const P: TPoint; Shift: TShiftState);
begin
  MouseMove(Shift + [ssLeft], P.X, P.Y);
end;

procedure TGridAccess.PointerUp(const P: TPoint; Shift: TShiftState);
begin
  MouseUp(TMouseButton.mbLeft, Shift, P.X, P.Y);
end;
procedure TestColumnMovingStreaming;
var
  Form: TForm;
  Grid: TGridAccess;
  Text: TStringStream;
  Binary: TMemoryStream;
  Columns: Th5uGridColumns;
  Options: Th5uCustomizationOptions;
  Selection: Th5uGridSelection;
begin
  Form := TForm.CreateNew(nil);
  Text := TStringStream.Create('object OptionsForm: TForm' + sLineBreak + 'object Grid: TGridAccess' + sLineBreak
    + 'Customization.ColumnResizeHitZoneLeft = 9' + sLineBreak + 'Customization.ColumnResizeHitZoneRight = 2' + sLineBreak
    + 'Customization.TouchColumnResizeHitZoneLeft = 20' + sLineBreak + 'Customization.TouchColumnResizeHitZoneRight = 3' + sLineBreak
    + 'Customization.LastColumnResizeHitZoneLeft = 17' + sLineBreak + 'Customization.TouchLastColumnResizeHitZoneLeft = 28' + sLineBreak
    + 'Selection.RightClickSelect = True' + sLineBreak + 'Customization.ColumnMovingGesture = Drag' + sLineBreak
    + 'Customization.AllowColumnMoving = False' + sLineBreak + 'Customization.AllowRowMoving = False' + sLineBreak
    + 'Customization.RowMovingGesture = Drag' + sLineBreak + 'Columns = <item Id = ''denied'' MovePermission = Deny end' + sLineBreak
    + 'item Id = ''allowed'' MovePermission = Allow end>' + sLineBreak + 'end' + sLineBreak + 'end');
  Binary := TMemoryStream.Create;
  try
    ObjectTextToBinary(Text, Binary);
    Binary.Position := 0;
    Binary.ReadComponent(Form);
    Grid := Form.FindComponent('Grid') as TGridAccess;
    Check(Grid.Columns[0].MovePermission=Th5uColumnMovePermission.Deny,'MovePermission=Deny not loaded');
    Check(Grid.Columns[1].MovePermission=Th5uColumnMovePermission.Allow,'Column Allow not loaded');
    Check(not Grid.Customization.AllowColumnMoving and (Grid.Customization.ColumnMovingGesture
      =Th5uColumnRowMovingGesture.Drag),'Customization options not loaded');
    Columns := Th5uGridColumns.Create(Form);
    Options := Th5uCustomizationOptions.Create;
    Selection := Th5uGridSelection.Create;
    try
      Selection.Assign(Grid.Selection);
      Check(Selection.RightClickSelect, 'RightClickSelect streaming/Assign failed');
      Columns.Assign(Grid.Columns);
      Options.Assign(Grid.Customization);
      Check((Options.LastColumnResizeHitZoneLeft = 17) and (Options.TouchLastColumnResizeHitZoneLeft
        = 28), 'Last column hit zones lost during streaming/Assign');
      Options.LastColumnResizeHitZoneLeft := -2;
      Options.TouchLastColumnResizeHitZoneLeft := -2;
      Check((Options.LastColumnResizeHitZoneLeft = -1) and (Options.TouchLastColumnResizeHitZoneLeft
        = -1), 'Last column hit zone sentinel must clamp at -1');
      Check((Options.ColumnResizeHitZoneLeft = 9) and (Options.ColumnResizeHitZoneRight = 2) and (Options.TouchColumnResizeHitZoneLeft = 20)
        and (Options.TouchColumnResizeHitZoneRight = 3), 'Resize hit zones lost during streaming/Assign');
      Options.ColumnResizeHitZoneLeft := -1;
      Options.ColumnResizeHitZoneRight := -1;
      Options.TouchColumnResizeHitZoneLeft := -1;
      Options.TouchColumnResizeHitZoneRight := -1;
      Check((Options.ColumnResizeHitZoneLeft = 0) and (Options.ColumnResizeHitZoneRight = 0) and (Options.TouchColumnResizeHitZoneLeft = 0)
        and (Options.TouchColumnResizeHitZoneRight = 0), 'Negative hit zone sizes must clamp to zero');
      Check(not Options.AllowRowMoving and (Options.RowMovingGesture=Th5uColumnRowMovingGesture.Drag),'Assign lost row moving options');
      Check((Columns[0].MovePermission=Th5uColumnMovePermission.Deny) and (Columns[1].MovePermission
        =Th5uColumnMovePermission.Allow),'Assign lost column permissions');
      Check(not Options.AllowColumnMoving and (Options.ColumnMovingGesture=Th5uColumnRowMovingGesture.Drag),'Assign lost moving gesture');
    finally
      Selection.Free;
      Options.Free;
      Columns.Free;
    end;
    Binary.Clear;
    Binary.WriteComponent(Form);
    Binary.Position := 0;
    Text.Size := 0;
    ObjectBinaryToText(Binary, Text);
    Check(Text.DataString.Contains('ColumnMovingGesture = Drag') and Text.DataString.Contains('MovePermission = Deny')
      and Text.DataString.Contains('MovePermission = Allow'),'New moving options not saved');
    Check(Text.DataString.Contains('RightClickSelect = True'), 'RightClickSelect not saved');
    Check(Text.DataString.Contains('LastColumnResizeHitZoneLeft = 17')
      and Text.DataString.Contains('TouchLastColumnResizeHitZoneLeft = 28'), 'Last column hit zones not saved');
    Check(Text.DataString.Contains('ColumnResizeHitZoneLeft = 9') and Text.DataString.Contains('ColumnResizeHitZoneRight = 2')
      and Text.DataString.Contains('TouchColumnResizeHitZoneLeft = 20')
      and Text.DataString.Contains('TouchColumnResizeHitZoneRight = 3'), 'Resize hit zones not saved');
    Check(not Text.DataString.Contains('CanMove ='),'Legacy alias should not be saved alongside MovePermission');
    Writeln('PASS: moving options DFM/FMX streaming and Assign');
  finally
    Binary.Free;
    Text.Free;
    Form.Free;
  end;
end;

procedure TMoveProbe.RowsMoved(Sender: TObject; const AContext: Th5uRowsMovedContext);
begin
  Inc(Count);
  Context := AContext;
  Check(TGridAccess(Sender).Cursor = crCross, 'Move event ran before cursor restoration');
{$IFDEF TEST_FMX}
  Check(TGridAccess(Sender).Root.Captured = nil, 'Row event ran with mouse capture');
{$ELSE}
  Check(not TGridAccess(Sender).MouseCapture, 'Row event ran with mouse capture');
{$ENDIF}
  if RaiseError then raise Exception.Create('Move handler test exception');
end;

procedure TGridAccess.LoseMoveCapture;
begin
{$IFDEF TEST_FMX}
  ReleaseCapture;
{$ELSE}
  MouseCapture := False;
{$ENDIF}
end;

procedure TGridAccess.HoverAt(const P: TPoint);
begin
  MouseMove([], P.X, P.Y);
end;

procedure TGridAccess.LeaveGrid;
begin
{$IFDEF TEST_FMX}
  DoMouseLeave;
{$ELSE}
  Perform(CM_MOUSELEAVE, 0, 0);
{$ENDIF}
end;

procedure TGridAccess.RightClickAt(const P: TPoint; Shift: TShiftState);
begin
  MouseDown(TMouseButton.mbRight, Shift, P.X, P.Y);
  MouseUp(TMouseButton.mbRight, Shift, P.X, P.Y);
end;

function TGridAccess.HeaderBounds(AColumn: Integer): TRect;
var
  X, Y, HeaderRow: Integer;
{$IFDEF TEST_FMX}
  H: Th5uFmxHitTestInfo;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}
begin
  for HeaderRow := 0 to HeaderLayout.RowCount - 1 do
  begin
    Y := Round(Spacing.Top + HeaderRow * (HeaderRowHeight + Spacing.RowSpacing) + HeaderRowHeight / 2);
    for X := 1 to Trunc(Width) - 1 do
    begin
{$IFDEF TEST_FMX}
      H := GridHitTest(X, Y);
      if (H.Kind <> Th5uFmxHitKind.Header) or (H.ColumnIndex <> AColumn) then Continue;
{$ELSE}
      H := HitTest(X, Y);
      if (H.Kind <> Th5uHitKind.Header) or (H.ColumnIndex <> AColumn) then Continue;
{$ENDIF}
      if Assigned(H.HeaderCell) and (H.HeaderCell.ColumnSpan > 1) then Continue;
      Exit(Rect(Round(H.Bounds.Left), Round(H.Bounds.Top), Round(H.Bounds.Right), Round(H.Bounds.Bottom)));
    end;
  end;
  raise Exception.Create('Header missing');
end;

{$IFNDEF TEST_FMX}
procedure TestVclMouseMessages;
var
  T: TFixture;
  P, Q: TPoint;
  Original, Scenario: Integer;
  Probe: TMoveProbe;

  procedure SendMouse(AMessage: Cardinal; const APoint: TPoint; AKeys: WPARAM = 0);
  begin
    T.Grid.Perform(AMessage, AKeys, MakeLParam(APoint.X, APoint.Y));
  end;

begin
  for Scenario := 0 to 8 do
  begin
    T := TFixture.Create(Th5uCacheMode.None);
    try
      T.Grid.AllowEditing := False;
      T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
      T.Grid.Cursor := crCross;
      case Scenario of
        0, 1, 2, 3:
          begin
            P := T.Grid.HeaderBounds(0).CenterPoint;
            Q := T.Grid.HeaderBounds(2).CenterPoint;
            SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
            Check(T.Grid.MouseCapture, 'Native header press did not capture');
            if Scenario <> 0 then
              SendMouse(WM_MOUSEMOVE, T.Grid.HeaderBounds(1).CenterPoint, MK_LBUTTON);
            Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'Native move reordered before release');
            if Scenario = 2 then Winapi.Windows.ReleaseCapture
            else if Scenario = 3 then T.Grid.Press(vkEscape);
            SendMouse(WM_LBUTTONUP, Q);
            Check((T.Grid.Columns.VisibleColumns[0] <> T.Grid.Columns[0]) = (Scenario
              < 2), 'Native column release lost its final coordinate or ignored cancellation');
          end;
        4:
          begin
            P := T.Grid.HeaderBounds(0).CenterPoint;
            SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
            SendMouse(WM_LBUTTONUP, P);
            Check(T.Grid.Selection.IsColumnSelected('FLAG'), 'Native header click did not select');
          end;
        5:
          begin
            P := Point(T.Grid.HeaderBounds(0).Right, T.Grid.HeaderBounds(0).CenterPoint.Y);
            Original := T.Grid.Columns[0].Width;
            SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
            SendMouse(WM_MOUSEMOVE, Point(P.X + 20, P.Y), MK_LBUTTON);
            SendMouse(WM_LBUTTONUP, Point(P.X + 37, P.Y));
            Check(T.Grid.Columns[0].Width = Original + 37, 'Native resize ignored final release position');
          end;
        6:
          begin
            T.Grid.AllowEditing := True;
            T.Grid.ImmediateEdit := True;
            P := T.CellPoint('DESCRIPTION');
            SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
            SendMouse(WM_LBUTTONUP, P);
            Check(T.Editor.Visible, 'Native mouse release lost pending immediate edit');
            T.EditorKey(vkEscape);
          end;
        7:
          begin
            T.Grid.AllowEditing := True;
            T.Grid.ImmediateEdit := True;
            P := T.CellPoint('DESCRIPTION');
            Q := T.CellPoint('NUMBER', 1);
            SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
            SendMouse(WM_LBUTTONUP, Q);
            Check(T.Grid.Selection.IsCellSelected(0, 1) and T.Grid.Selection.IsCellSelected(1, 2), 'Native range release lost its final cell');
            Check(not Assigned(T.Grid.ActiveEditor), 'Native range drag started editing');
          end;
        8:
          begin
            Probe := TMoveProbe.Create;
            try
              T.Grid.Customization.AllowRowMoving := True;
              T.Grid.OnRowsMoved := Probe.RowsMoved;
              P := Point(10, T.CellPoint('FLAG').Y);
              Q := Point(10, T.CellPoint('FLAG', 2).Y);
              // Alt is a keyboard state, not part of a Windows mouse message.
              T.Grid.PointerDown(P, [ssAlt]);
              SendMouse(WM_MOUSEMOVE, Q, MK_LBUTTON);
              SendMouse(WM_LBUTTONUP, Q);
              Check((Probe.Count = 1) and (Probe.Context.TargetRowIndex = 2), 'Native release lost row move');
            finally
              T.Grid.OnRowsMoved := nil;
              Probe.Free;
            end;
          end;
      end;
      Check(not T.Grid.MouseCapture, 'Mouse capture survived native release/cancel');
      Check(T.Grid.Cursor = crCross, 'Native release did not restore cursor');
      Check(T.Posts = 0, 'Native move/cancel posted data');
    finally
      T.Free;
    end;
  end;
  Writeln('PASS: VCL Windows mouse messages: column/row moves, final release position, clicks, resize, range/edit, capture and Escape');
end;
{$ENDIF}

{$IFNDEF TEST_FMX}
procedure TestVclMoveFeedback;
var
  T: TFixture;
  P, Q, Marker: TPoint;
  Scenario, Offset: Integer;
  Baseline, Active: TColor;
  ExpectedValid: Boolean;
  B: TBitmap;

  function PixelAt(const APoint: TPoint): TColor;
  begin
    B := TBitmap.Create;
    try
      B.SetSize(T.Grid.Width, T.Grid.Height);
      T.Grid.PaintTo(B.Canvas.Handle, 0, 0);
      Result := B.Canvas.Pixels[APoint.X, APoint.Y];
    finally
      B.Free;
    end;
  end;

  procedure SendMouse(AMessage: Cardinal; const APoint: TPoint; AKeys: WPARAM = 0);
  begin
    T.Grid.Perform(AMessage, AKeys, MakeLParam(APoint.X, APoint.Y));
  end;

begin
  for Scenario := 0 to 6 do
  begin
    T := TFixture.Create(Th5uCacheMode.None);
    try
      T.Grid.AllowEditing := False;
      T.Grid.Cursor := crCross;
      T.Grid.Theme := Th5uGridTheme(Scenario mod 4);
      T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
      if Scenario = 3 then T.Grid.Columns[2].FixedKind := Th5uFixedKind.Right;
      if Scenario = 4 then
      begin
        T.Grid.Selection.SelectColumn('FLAG');
        T.Grid.Selection.SelectColumn('DESCRIPTION', True);
      end;
      T.PaintGrid;
      P := T.Grid.HeaderBounds(0).CenterPoint;
      Q := T.Grid.HeaderBounds(2).CenterPoint;
      Marker := Point(T.Grid.HeaderBounds(2).Right - 1, 180);
      if Marker.X >= T.Grid.Width - 2 then Marker.X := T.Grid.Width - 3;
      Baseline := PixelAt(Marker);
      Winapi.Windows.SetCursor(Screen.Cursors[crArrow]);
      Offset := 16;
      if Scenario = 6 then
      begin
        T.Grid.PointerDown(P, [ssTouch]);
        Offset := 40;
      end
      else SendMouse(WM_LBUTTONDOWN, P, MK_LBUTTON);
      Check(PixelAt(Marker) = Baseline, 'VCL feedback appeared before drag threshold');
      SendMouse(WM_MOUSEMOVE, Q, MK_LBUTTON);
      Check(Winapi.Windows.GetCursor = Screen.Cursors[crDrag], 'Windows still shows the old cursor during VCL drag');
      Active := PixelAt(Marker);
      ExpectedValid := Scenario <> 3;
      Check((Active <> Baseline) = ExpectedValid, 'VCL insertion marker disagrees with drop permissions');
      if ExpectedValid then
        Check(PixelAt(Point(Q.X - 55, Q.Y + Offset + 10))
          = ColorToRGB(h5uGetVclPalette(T.Grid.Theme).SelectedBackground), 'VCL moving caption is missing');
      Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'VCL feedback reordered before release');
      SendMouse(WM_MOUSEMOVE, Point(Q.X, 100), MK_LBUTTON);
      Check(PixelAt(Marker) = Baseline, 'VCL data area shows a valid drop marker');
      SendMouse(WM_MOUSEMOVE, Q, MK_LBUTTON);
      Check(PixelAt(Marker) = Active, 'VCL feedback did not follow the pointer back');
      if Scenario = 1 then T.Grid.Press(vkEscape)
      else if Scenario = 2 then Winapi.Windows.ReleaseCapture
      else if Scenario = 5 then
      begin
        T.Grid.Columns[0].Free;
        Check(PixelAt(Marker) = Baseline, 'VCL deleted source still shows a valid drop marker');
      end;
      SendMouse(WM_LBUTTONUP, Q);
      if Scenario <> 5 then
        Check((T.Grid.Columns.VisibleColumns[0] <> T.Grid.Columns[0]) = (Scenario in [0, 4, 6]), 'VCL feedback target and completed move disagree');
      Check(PixelAt(Marker) = Baseline, 'VCL feedback survived release/cancel');
      Check((T.Grid.Cursor = crCross) and not T.Grid.MouseCapture, 'VCL feedback left cursor/capture active');
      if Scenario <> 2 then
        Check(Winapi.Windows.GetCursor = Screen.Cursors[crCross], 'VCL release failed to restore the visible cursor');
      if Scenario = 4 then
        Check(T.Grid.Selection.IsColumnSelected('FLAG') and T.Grid.Selection.IsColumnSelected('DESCRIPTION'), 'VCL block feedback changed selection');
      Check(T.Posts = 0, 'VCL column feedback edited data');
    finally
      T.Free;
    end;
  end;
  Writeln('PASS: VCL drag feedback pixels, themes, block/touch move, fixed targets, release/cancel/deletion and visible cursor');
end;

procedure TestVclGroupedMoveFeedback;
var
  T: TFixture;
  D: TVclDatasetDemoForm;
  Cell: Th5uHeaderLayoutCell;
  I: Integer;

  procedure CheckMove(G: TGridAccess; ASource, ATarget, ASourceRow, ATargetRow, ASourceSpan: Integer);
  var
    BeforeImage, DragImage: TBitmap;
    SourceBounds, TargetBounds: TRect;
    P, Q: TPoint;
    SourceColumn: Th5uGridColumn;
    SourceTop, TargetTop, X, Y: Integer;

    procedure Paint(B: TBitmap);
    begin
      B.SetSize(G.Width, G.Height);
      G.PaintTo(B.Canvas.Handle, 0, 0);
    end;

  begin
    G.AllowEditing := False;
    G.SetFocus;
    BeforeImage := TBitmap.Create;
    DragImage := TBitmap.Create;
    try
      Paint(BeforeImage);
      SourceBounds := G.HeaderBounds(ASource);
      TargetBounds := G.HeaderBounds(ATarget);
      SourceTop := SourceBounds.Top;
      TargetTop := TargetBounds.Top;
      P := Point(SourceBounds.CenterPoint.X, SourceTop + G.HeaderRowHeight div 2);
      Q := Point(TargetBounds.CenterPoint.X, TargetTop + G.HeaderRowHeight div 2);
      SourceColumn := G.Columns.VisibleColumns[ASource];
      G.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y));
      Paint(BeforeImage);
      G.Perform(WM_MOUSEMOVE, MK_LBUTTON, MakeLParam(Q.X, Q.Y));
      Paint(DragImage);
      for Y := G.Spacing.Top to SourceTop - 1 do
        for X := SourceBounds.Left to SourceBounds.Right - 1 do
          Check(BeforeImage.Canvas.Pixels[X, Y] = DragImage.Canvas.Pixels[X, Y], 'VCL source highlight extends into its parent group header');
      for Y := G.Spacing.Top to TargetTop - 1 do
        for X := TargetBounds.Right - 8 to TargetBounds.Right + 8 do
          Check(BeforeImage.Canvas.Pixels[X, Y] = DragImage.Canvas.Pixels[X, Y], 'VCL insertion marker extends into its parent group header');
      X := SourceBounds.Left + 8;
      Y := SourceTop + 5 + (ASourceSpan - 1) * (G.HeaderRowHeight + G.Spacing.RowSpacing);
      Check(BeforeImage.Canvas.Pixels[X, Y] <> DragImage.Canvas.Pixels[X, Y], 'VCL source highlight misses the actual header cell/row span');
      Check(DragImage.Canvas.Pixels[TargetBounds.Right - 1, TargetTop + 3]
        = ColorToRGB(h5uGetVclPalette(G.Theme).SelectedBackground), 'VCL marker does not start at the target header');
      Check(G.Columns.VisibleColumns[ASource] = SourceColumn, 'Grouped VCL move happened before release');
      G.Perform(WM_LBUTTONUP, 0, MakeLParam(Q.X, Q.Y));
      Check(G.Columns.VisibleColumns[ATarget] = SourceColumn, 'Grouped VCL move did not reach its indicated target');
      Check(not G.MouseCapture, 'Grouped VCL move retained mouse capture');
    finally
      DragImage.Free;
      BeforeImage.Free;
    end;
  end;

begin
  D := TVclDatasetDemoForm.Create(nil);
  try
    D.Show;
    Application.ProcessMessages;
    Check(D.Grid.HeaderLayout.Enabled and (D.Grid.HeaderLayout.RowCount = 2), 'Dataset demo lacks grouped headers');
    CheckMove(TGridAccess(D.Grid), 1, 2, 1, 1, 1);
  finally
    D.Free;
  end;
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
    T.Grid.HeaderLayout.RowCount := 3;
    T.Grid.Spacing.RowSpacing := 3;
    Cell := T.Grid.HeaderLayout.Cells.Add;
    Cell.Caption := 'Parent group';
    Cell.ColumnSpan := 3;
    for I := 0 to 2 do
    begin
      Cell := T.Grid.HeaderLayout.Cells.Add;
      Cell.ColumnId := T.Grid.Columns[I].Id;
      Cell.Caption := T.Grid.Columns[I].Caption;
      Cell.LayoutColumn := I;
      Cell.LayoutRow := 2;
      if I = 0 then
      begin
        Cell.LayoutRow := 1;
        Cell.RowSpan := 2;
      end;
    end;
    T.Grid.HeaderLayout.Enabled := True;
    T.PaintGrid;
    CheckMove(T.Grid, 0, 2, 1, 2, 2);
  finally
    T.Free;
  end;
  Writeln('PASS: VCL grouped demo and three-row headers: source/target clipping, row spans, spacing and completed move');
end;

procedure TestVclCapturedCursors;
var
  T: TFixture;
  P, Q: TPoint;
  SavedCursor: TCursor;
begin
  SavedCursor := Screen.Cursor;
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    T.Grid.Cursor := crCross;
    T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
    P := T.Grid.HeaderBounds(0).CenterPoint;
    Q := T.Grid.HeaderBounds(2).CenterPoint;
    Screen.Cursor := crHourGlass;
    T.Grid.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y));
    T.Grid.Perform(WM_MOUSEMOVE, MK_LBUTTON, MakeLParam(Q.X, Q.Y));
    Check(Winapi.Windows.GetCursor = Screen.Cursors[crHourGlass], 'VCL drag overrode global wait cursor');
    T.Grid.Press(vkEscape);
    Screen.Cursor := crDefault;
    P := Point(T.Grid.HeaderBounds(0).Right, P.Y);
    Winapi.Windows.SetCursor(Screen.Cursors[crArrow]);
    T.Grid.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y));
    Check(Winapi.Windows.GetCursor = Screen.Cursors[crHSplit], 'VCL resize press did not show actual split cursor');
    T.Grid.Perform(WM_LBUTTONUP, 0, MakeLParam(P.X + 20, P.Y));
    Check(Winapi.Windows.GetCursor = Screen.Cursors[crCross], 'VCL resize release did not restore actual cursor');
    Writeln('PASS: VCL actual resize/release cursor and global Screen.Cursor precedence');
  finally
    T.Free;
    Screen.Cursor := SavedCursor;
  end;
end;
{$ENDIF}

procedure TestGroupedHeaderMoving;
var
  T: TFixture;
  Alpha, Beta, Cell, SourceHeader, TargetHeader: Th5uHeaderLayoutCell;
  SourceColumns: array[0..2] of Th5uGridColumn;
  SourceBounds, TargetBounds, LeafBounds: TRect;
  P, Q, SourcePixel, ChildPixel, MarkerPixel: TPoint;
  BeforeImage, DragImage: TBitmap;
  Scenario, I, SourceIndex, TargetIndex, FirstAfter: Integer;
  ExpectedMove, ExpectedFeedback: Boolean;

  function BoundsFor(ACell: Th5uHeaderLayoutCell): TRect;
  var
    X, Y: Integer;
{$IFDEF TEST_FMX}
    H: Th5uFmxHitTestInfo;
{$ELSE}
    H: Th5uHitTestInfo;
{$ENDIF}
  begin
    Y := Round(T.Grid.Spacing.Top + ACell.LayoutRow * (T.Grid.HeaderRowHeight + T.Grid.Spacing.RowSpacing) + T.Grid.HeaderRowHeight / 2);
    for X := 1 to Trunc(T.Grid.Width) - 1 do
    begin
{$IFDEF TEST_FMX}
      H := T.Grid.GridHitTest(X, Y);
{$ELSE}
      H := T.Grid.HitTest(X, Y);
{$ENDIF}
      if H.HeaderCell = ACell then Exit(Rect(Round(H.Bounds.Left), Round(H.Bounds.Top), Round(H.Bounds.Right), Round(H.Bounds.Bottom)));
    end;
    raise Exception.Create('Grouped header is not hittable: ' + ACell.Caption);
  end;

  function Snapshot: TBitmap;
  begin
{$IFDEF TEST_FMX}
    Result := T.Grid.MakeScreenshot;
{$ELSE}
    Result := TBitmap.Create;
    Result.SetSize(T.Grid.Width, T.Grid.Height);
    T.Grid.PaintTo(Result.Canvas.Handle, 0, 0);
{$ENDIF}
  end;

  function Pixel(B: TBitmap; const At: TPoint): Cardinal;
{$IFDEF TEST_FMX}
  var
    Data: TBitmapData;
{$ENDIF}
  begin
{$IFDEF TEST_FMX}
    Check(B.Map(TMapAccess.Read, Data), 'Group feedback bitmap could not be mapped');
    try Result := Data.GetPixel(At.X, At.Y); finally B.Unmap(Data); end;
{$ELSE}
    Result := B.Canvas.Pixels[At.X, At.Y];
{$ENDIF}
  end;

  procedure Down;
  begin
{$IFDEF TEST_FMX}
    if Scenario in [2, 3] then T.Grid.PointerDown(P, [ssTouch]) else T.Grid.PointerDown(P);
{$ELSE}
    if Scenario = 2 then T.Grid.PointerDown(P, [ssTouch])
    else T.Grid.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y));
{$ENDIF}
  end;

  procedure Move;
  begin
{$IFDEF TEST_FMX}
    if Scenario = 3 then T.Grid.PanGesture(PointF(P.X, P.Y), PointF(Q.X, Q.Y)) else T.Grid.PointerMove(Q);
{$ELSE}
    T.Grid.Perform(WM_MOUSEMOVE, MK_LBUTTON, MakeLParam(Q.X, Q.Y));
{$ENDIF}
  end;

  procedure Up;
  begin
{$IFDEF TEST_FMX}
    T.Grid.PointerUp(Q);
{$ELSE}
    T.Grid.Perform(WM_LBUTTONUP, 0, MakeLParam(Q.X, Q.Y));
{$ENDIF}
  end;

begin
  for Scenario := 0 to 16 do
  begin
    T := TFixture.Create(Th5uCacheMode.None);
    try
      T.Grid.AllowEditing := False;
      T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
      for I := 3 to 6 do
      begin
        with T.Grid.Columns.Add do
        begin
          Id := 'C' + IntToStr(I);
          Caption := Id;
          VisibleIndex := I;
        end;
      end;
      for I := 0 to 6 do T.Grid.Columns[I].Width := 65;
      T.Grid.Columns[0].FixedKind := Th5uFixedKind.Left;
      T.Grid.HeaderLayout.RowCount := 2;
      T.Grid.Spacing.RowSpacing := 2;
      Alpha := T.Grid.HeaderLayout.Cells.Add;
      Alpha.Caption := 'Alpha';
      Alpha.LayoutColumn := 1;
      Alpha.ColumnSpan := 3;
      Beta := T.Grid.HeaderLayout.Cells.Add;
      Beta.Caption := 'Beta';
      Beta.LayoutColumn := 4;
      Beta.ColumnSpan := 3;
      for I := 0 to 6 do
      begin
        Cell := T.Grid.HeaderLayout.Cells.Add;
        Cell.ColumnId := T.Grid.Columns[I].Id;
        Cell.Caption := T.Grid.Columns[I].Caption;
        Cell.LayoutColumn := I;
        if I = 0 then Cell.RowSpan := 2 else Cell.LayoutRow := 1;
      end;
      if Scenario = 14 then
        for I := 2 to T.Grid.HeaderLayout.Cells.Count - 1 do T.Grid.HeaderLayout.Cells[I].ColumnId := '';
      if Scenario = 15 then
      begin
        T.Grid.HeaderLayout.RowCount := 3;
        Alpha.LayoutRow := 1;
        Beta.LayoutRow := 1;
        T.Grid.HeaderLayout.Cells[2].RowSpan := 3;
        for I := 3 to T.Grid.HeaderLayout.Cells.Count - 1 do T.Grid.HeaderLayout.Cells[I].LayoutRow := 2;
        Cell := T.Grid.HeaderLayout.Cells.Add;
        Cell.Caption := 'Parent of Alpha and Beta';
        Cell.LayoutColumn := 1;
        Cell.ColumnSpan := 6;
      end;
      T.Grid.HeaderLayout.Enabled := True;
      SourceIndex := 1;
      TargetIndex := 4;
      SourceHeader := Alpha;
      TargetHeader := Beta;
      if Scenario in [1, 16] then
      begin
        SourceIndex := 4;
        TargetIndex := 1;
        SourceHeader := Beta;
        TargetHeader := Alpha;
      end;
      for I := 0 to 2 do SourceColumns[I] := T.Grid.Columns[SourceIndex + I];
      if Scenario = 16 then T.Grid.Columns[1].Visible := False;
      if Scenario in [8, 12] then SourceColumns[2].Visible := False;
      if Scenario = 9 then SourceColumns[0].Visible := False;
      if Scenario in [7, 12] then SourceColumns[2].MovePermission := Th5uColumnMovePermission.Deny;
      T.PaintGrid;
      T.Grid.SetFocus;
      SourceBounds := BoundsFor(SourceHeader);
      TargetBounds := BoundsFor(TargetHeader);
      P := SourceBounds.CenterPoint;
      Q := TargetBounds.CenterPoint;
      // A child's boundary/spacer is inside the parent, not a resize edge there.
      if Scenario = 0 then P.X := T.Grid.HeaderBounds(1).Right;
      LeafBounds := T.Grid.HeaderBounds(SourceIndex);
      SourcePixel := Point(SourceBounds.Left + 8, SourceBounds.Top + 4);
      ChildPixel := Point(SourceBounds.Right - 8, LeafBounds.Top + 4);
      if Scenario = 4 then
      begin
        SourceBounds := T.Grid.HeaderBounds(1);
        TargetBounds := T.Grid.HeaderBounds(3);
        P := SourceBounds.CenterPoint;
        Q := TargetBounds.CenterPoint;
        SourcePixel := Point(SourceBounds.Left + 8, SourceBounds.Top + 4);
        ChildPixel := Point(SourceBounds.Left + 8, BoundsFor(Alpha).Top + 4);
      end;
      if Scenario = 6 then Q := T.Grid.HeaderBounds(TargetIndex).CenterPoint;
      if Scenario = 10 then Q := T.Grid.HeaderBounds(0).CenterPoint;
      MarkerPixel := Point(TargetBounds.Right - 1, TargetBounds.Top + 3);
      if Scenario in [1, 16] then MarkerPixel.X := TargetBounds.Left + 1;
      ExpectedMove := not (Scenario in [5, 6, 7, 10, 11, 12, 13]);
      ExpectedFeedback := not (Scenario in [6, 7, 10, 11, 12]);
      Down;
      BeforeImage := Snapshot;
      try
        if Scenario = 11 then SourceHeader.Free;
        Move;
        DragImage := Snapshot;
        try
          Check((Pixel(BeforeImage, MarkerPixel) <> Pixel(DragImage, MarkerPixel))
            = ExpectedFeedback, 'Group marker disagrees with valid drop/row/permissions, scenario ' + IntToStr(Scenario));
          if ExpectedFeedback then
          begin
            Check(Pixel(BeforeImage, SourcePixel) <> Pixel(DragImage, SourcePixel), 'Source feedback is on the wrong header row');
            Check(Pixel(BeforeImage, ChildPixel) = Pixel(DragImage, ChildPixel), 'Source feedback paints the other header row, scenario '
              + IntToStr(Scenario));
          end;
        finally
          DragImage.Free;
        end;
      finally
        BeforeImage.Free;
      end;
      Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'Group drag moved fixed ID');
      if Scenario = 5 then T.Grid.Press(vkEscape);
      if Scenario = 13 then T.Grid.LoseMoveCapture;
      Up;
      if Scenario in [8, 9] then
      begin
        SourceColumns[0].Visible := True;
        SourceColumns[2].Visible := True;
      end;
      if Scenario = 16 then T.Grid.Columns[1].Visible := True;
      FirstAfter := SourceIndex;
      if ExpectedMove then
      begin
        if Scenario in [1, 16] then FirstAfter := 1
        else if Scenario = 4 then FirstAfter := 3
        else FirstAfter := 4;
      end;
      if Scenario <> 12 then
        Check(T.Grid.Columns.VisibleColumns[FirstAfter] = SourceColumns[0], 'Wrong group/leaf moved, scenario ' + IntToStr(Scenario));
      if ExpectedMove and (Scenario <> 4) then
      begin
        for I := 0 to 2 do
          Check(T.Grid.Columns.VisibleColumns[FirstAfter + I] = SourceColumns[I], 'Group descendants lost order');
        T.PaintGrid;
        SourceBounds := BoundsFor(SourceHeader);
        Check(SourceBounds.Left = T.Grid.HeaderBounds(FirstAfter).Left, 'Moved parent caption did not follow its data');
        Check(SourceBounds.Right = T.Grid.HeaderBounds(FirstAfter + 2).Right, 'Moved parent lost its full span');
      end;
      Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'Completed group move changed fixed ID');
    finally
      T.Free;
    end;
  end;
  Writeln('PASS: grouped headers: mouse/touch/Pan, correct source row, child spacers, complete groups/leaves, '
    + 'hidden members, fixed ID, permissions and cancel');
end;

procedure TestRightClickSelection;
var
  T: TFixture;
  A, B, C, R: TPoint;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    A := T.CellPoint('FLAG');
    B := T.CellPoint('DESCRIPTION');
    C := T.CellPoint('NUMBER');
    R := T.CellPoint('FLAG', 1);
    Check(not T.Grid.Selection.RightClickSelect, 'RightClickSelect must default to False');
    T.Grid.ClickAt(B);
    T.Grid.Selection.SelectRow(T.Controller.GetRowKey(1), True);
    T.Grid.Selection.SelectColumn('NUMBER', True);
    T.Grid.RightClickAt(A);
    Check(T.Grid.Selection.IsCellSelected(0, 1) and T.Grid.Selection.IsColumnSelected('NUMBER')
      and T.Grid.Selection.IsRowSelected(T.Controller.GetRowKey(1)), 'Default right click changed mixed selection');
    Check(T.Grid.Selection.FocusedCell.ColumnId = 'DESCRIPTION', 'Default right click changed cell focus');
    T.Grid.Selection.RightClickSelect := True;
    T.Grid.RightClickAt(A, [ssCtrl, ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0, 0) and (T.Grid.Selection.CellRanges.Count = 1) and (T.Grid.Selection.SelectedColumnCount = 0)
      and (T.Grid.Selection.SelectedRowCount(3) = 0), 'Unselected right click must replace all selection kinds, regardless of modifiers');
    Check(T.Grid.Selection.FocusedCell.ColumnId = 'FLAG', 'Right click did not focus new cell');
    T.Grid.Selection.AddCellRange(Th5uCellRange.Create(0, 0, 1, 1), True);
    T.Grid.Selection.SelectRow(T.Controller.GetRowKey(1), True);
    T.Grid.Selection.SelectColumn('NUMBER', True);
    T.Grid.RightClickAt(B);
    Check(T.Grid.Selection.FocusedCell.ColumnId = 'DESCRIPTION', 'Selected cell right click did not change focus');
    T.Grid.RightClickAt(C);
    Check(T.Grid.Selection.FocusedCell.ColumnId = 'NUMBER', 'Selected column right click did not change focus');
    T.Grid.RightClickAt(R);
    Check((T.Grid.Selection.FocusedCell.RowIndex = 1) and (T.Grid.Selection.FocusedCell.ColumnId
      = 'FLAG'), 'Selected row right click did not change focus');
    Check((T.Grid.Selection.CellRanges.Count = 2) and T.Grid.Selection.IsColumnSelected('NUMBER')
      and T.Grid.Selection.IsRowSelected(T.Controller.GetRowKey(1)), 'Right click inside mixed selection changed it');
    T.Grid.RightClickAt(Point(590, 210));
    Check((T.Grid.Selection.FocusedCell.RowIndex = 1) and (T.Grid.Selection.CellRanges.Count = 2), 'Blank area changed focus/selection');
    Check(T.Posts = 0, 'Right click toggled a checkbox');
    T.Grid.Selection.Clear;
    T.Grid.Selection.SelectColumn('DESCRIPTION');
    T.Grid.Columns[0].CanSelect := False;
    T.Grid.RightClickAt(A);
    Check(T.Grid.Selection.IsColumnSelected('DESCRIPTION') and (T.Grid.Selection.FocusedCell.ColumnId
      = 'FLAG'), 'CanSelect=False must permit focus while preserving selection');
    T.Grid.Columns[0].CanSelect := True;
    T.Grid.Selection.AllowedKinds := [Th5uSelectionKind.Columns];
    T.Grid.RightClickAt(C);
    Check(T.Grid.Selection.IsColumnSelected('DESCRIPTION') and (T.Grid.Selection.FocusedCell.ColumnId
      = 'NUMBER'), 'Right click bypassed AllowedKinds or failed to focus');
    Writeln('PASS: right-click defaults, replacement, selected cells/rows/columns, modifiers, blank area, focus and permissions');
  finally
    T.Free;
  end;
end;

procedure TestLastColumnHitZone;
var
  T: TFixture;
  H: TRect;
  P: TPoint;

  procedure CheckHover(AColumn, ADelta: Integer; AExpected: Boolean);
  begin
    H := T.Grid.HeaderBounds(AColumn);
    T.Grid.HoverAt(Point(H.Right + ADelta, H.CenterPoint.Y));
    Check((T.Grid.Cursor = crHSplit) = AExpected, 'Last-column hit zone mismatch');
  end;

begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.Cursor := crCross;
    T.Grid.AllowEditing := False;
    Check((T.Grid.Customization.LastColumnResizeHitZoneLeft = -1) and (T.Grid.Customization.TouchLastColumnResizeHitZoneLeft
      = -1), 'Last-column hit zones must default to -1');
    T.Grid.Customization.ColumnResizeHitZoneLeft := 2;
    T.Grid.Customization.ColumnResizeHitZoneRight := 1;
    CheckHover(2, -2, True);
    CheckHover(2, -3, False);
    T.Grid.Customization.LastColumnResizeHitZoneLeft := 10;
    CheckHover(2, -10, True);
    CheckHover(2, -11, False);
    CheckHover(2, 1, True);
    CheckHover(2, 2, False);
    CheckHover(1, -3, False);
    H := T.Grid.HeaderBounds(2);
    P := Point(H.Right - 10, H.CenterPoint.Y);
    T.Grid.PointerDown(P);
    T.Grid.PointerUp(Point(P.X + 20, P.Y));
    Check(T.Grid.Columns[2].Width = 170, 'Last-column mouse press ignored its larger left zone');
    T.Grid.Customization.LastColumnResizeHitZoneLeft := 0;
    T.PaintGrid;
    CheckHover(2, -1, False);
    CheckHover(2, 0, True);
    T.Grid.Customization.LastColumnResizeHitZoneLeft := -1;
    T.Grid.Customization.ColumnResizeHitZoneLeft := 5;
    CheckHover(2, -5, True);
    CheckHover(2, -6, False);
    T.Grid.Customization.LastColumnResizeHitZoneLeft := 10;
    T.Grid.Columns[2].Visible := False;
    T.PaintGrid;
    CheckHover(1, -10, True);
    CheckHover(0, -6, False);
    T.Grid.Columns[0].FixedKind := Th5uFixedKind.Right;
    T.PaintGrid;
    CheckHover(1, -10, True);
    CheckHover(0, -6, False);
{$IFDEF TEST_FMX}
    T.Grid.Customization.TouchColumnResizeHitZoneLeft := 3;
    T.Grid.Customization.TouchLastColumnResizeHitZoneLeft := 18;
    H := T.Grid.HeaderBounds(1);
    P := Point(H.Right - 18, H.CenterPoint.Y);
    T.Grid.TouchDrag(PointF(P.X, P.Y), PointF(P.X + 25, P.Y));
    Check(T.Grid.Columns[0].Width = 175, 'Last-column touch press ignored its larger left zone');
    T.Grid.Customization.TouchLastColumnResizeHitZoneLeft := -1;
    T.Grid.Customization.TouchColumnResizeHitZoneLeft := 7;
    T.PaintGrid;
    H := T.Grid.HeaderBounds(1);
    P := Point(H.Right - 7, H.CenterPoint.Y);
    T.Grid.TouchDrag(PointF(P.X, P.Y), PointF(P.X - 10, P.Y));
    Check(T.Grid.Columns[0].Width = 165, 'Last-column touch zone did not inherit the current normal value');
{$ENDIF}
    Writeln('PASS: last-column left hit zone, -1 inheritance, zero, right side, hidden/fixed columns and mouse/touch');
  finally
    T.Free;
  end;
end;

procedure TestResizeHitZones;
var
  T: TFixture;
  H: TRect;
  P: TPoint;
  I, Offset: Integer;

  procedure CheckHover(ADelta: Integer; AExpected: Boolean);
  begin
    T.Grid.HoverAt(Point(H.Right + ADelta, H.CenterPoint.Y));
    Check((T.Grid.Cursor = crHSplit) = AExpected, 'Asymmetric mouse hit zone mismatch at ' + IntToStr(ADelta));
  end;

begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.Cursor := crCross;
    T.Grid.AllowEditing := False;
    T.Grid.Customization.AllowColumnMoving := False;
    Check((T.Grid.Customization.ColumnResizeHitZoneLeft = 4) and (T.Grid.Customization.ColumnResizeHitZoneRight = 4)
      and (T.Grid.Customization.TouchColumnResizeHitZoneLeft = 12) and (T.Grid.Customization.TouchColumnResizeHitZoneRight
      = 12), 'Resize hit zone defaults changed');
    T.Grid.Customization.ColumnResizeHitZoneLeft := 9;
    T.Grid.Customization.ColumnResizeHitZoneRight := 2;
    H := T.Grid.HeaderBounds(0);
    CheckHover(-10, False);
    CheckHover(-9, True);
    CheckHover(2, True);
    CheckHover(3, False);
    for I := 0 to 3 do
    begin
      case I of
        0: Offset := -10;
        1: Offset := -9;
        2: Offset := 2;
        else Offset := 3;
      end;
      T.Grid.Columns[0].Width := 150;
      T.PaintGrid;
      H := T.Grid.HeaderBounds(0);
      P := Point(H.Right + Offset, H.CenterPoint.Y);
      T.Grid.PointerDown(P);
      T.Grid.PointerMove(Point(P.X + 25, P.Y));
      T.Grid.PointerUp(Point(P.X + 25, P.Y));
      Check((T.Grid.Columns[0].Width = 175) = (I in [1, 2]), 'Mouse press did not use the same hit zone as hover');
    end;
    T.Grid.Columns[0].Width := 150;
    T.PaintGrid;
    H := T.Grid.HeaderBounds(0);
    T.Grid.Customization.ColumnResizeHitZoneLeft := 0;
    T.Grid.Customization.ColumnResizeHitZoneRight := 0;
    CheckHover(-1, False);
    CheckHover(0, True);
    CheckHover(1, False);
{$IFDEF TEST_FMX}
    T.Grid.Customization.TouchColumnResizeHitZoneLeft := 20;
    T.Grid.Customization.TouchColumnResizeHitZoneRight := 3;
    for I := 0 to 3 do
    begin
      case I of
        0: Offset := -21;
        1: Offset := -20;
        2: Offset := 3;
        else Offset := 4;
      end;
      T.Grid.Columns[0].Width := 150;
      T.PaintGrid;
      H := T.Grid.HeaderBounds(0);
      P := Point(H.Right + Offset, H.CenterPoint.Y);
      T.Grid.TouchDrag(PointF(P.X, P.Y), PointF(P.X + 25, P.Y));
      Check((T.Grid.Columns[0].Width = 175) = (I in [1, 2]), 'Asymmetric touch hit zone mismatch');
    end;
{$ENDIF}
    Writeln('PASS: configurable left/right mouse and touch hit zones, boundaries, zero size, hover and press agreement');
  finally
    T.Free;
  end;
end;

procedure TestColumnResizing;
var
  T: TFixture;
  H: TRect;
  P, Q: TPoint;
  I, Original: Integer;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    T.Grid.Cursor := crCross;
    T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
    T.Grid.Columns[0].RightSpacing := 8;
    T.PaintGrid;
    H := T.Grid.HeaderBounds(0);
    for I := -1 to 1 do
    begin
      T.Grid.HoverAt(Point(H.Right + I * 2, H.CenterPoint.Y));
      Check(T.Grid.Cursor = crHSplit, 'Resize hover missing inside/outside header edge');
      T.Grid.HoverAt(H.CenterPoint);
      Check(T.Grid.Cursor = crCross, 'Hover did not restore custom cursor');
    end;
    P := Point(H.Right + 2, H.CenterPoint.Y);
    T.Grid.HoverAt(P);
    T.Grid.LeaveGrid;
    Check(T.Grid.Cursor = crCross, 'Mouse leave did not restore cursor');
    T.Grid.Columns[0].CanResize := False;
    T.Grid.HoverAt(P);
    Check(T.Grid.Cursor = crCross, 'CanResize=False showed resize cursor');
    T.Grid.Columns[0].CanResize := True;
    T.Grid.Customization.AllowColumnResizing := False;
    T.Grid.HoverAt(P);
    Check(T.Grid.Cursor = crCross, 'Resizing disabled but cursor visible');
    T.Grid.Customization.AllowColumnResizing := True;
    T.Grid.Selection.SelectColumn('DESCRIPTION');
    Original := T.Grid.Columns[0].Width;
    T.Grid.PointerDown(P);
    Check(T.Grid.Cursor = crHSplit, 'Resize press did not set cursor');
    Q := Point(P.X + 30, P.Y);
    T.Grid.PointerMove(Q);
    Check(T.Grid.Columns[0].Width = Original + 30, 'Column width did not follow pointer');
    Q.X := P.X + 45;
    T.Grid.PointerUp(Q);
    Check(T.Grid.Columns[0].Width = Original + 45, 'Resize ignored final MouseUp coordinate');
    Check(T.Grid.Cursor = crCross, 'Resize release did not restore custom cursor');
    Check(T.Grid.Selection.IsColumnSelected('DESCRIPTION'), 'Resize changed selection');
    Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'Resize moved the column');
    T.PaintGrid;
    H := T.Grid.HeaderBounds(0);
    P := Point(H.Right, H.CenterPoint.Y);
    Original := T.Grid.Columns[0].Width;
    T.Grid.PointerDown(P);
    T.Grid.LoseMoveCapture;
    T.Grid.PointerMove(Point(P.X + 25, P.Y));
    T.Grid.PointerUp(Point(P.X + 25, P.Y));
    Check((T.Grid.Columns[0].Width = Original) and (T.Grid.Cursor = crCross), 'Resize survived capture loss');
    T.Grid.PointerDown(P);
    T.Grid.Press(vkEscape);
    T.Grid.PointerMove(Point(P.X + 25, P.Y));
    T.Grid.PointerUp(Point(P.X + 25, P.Y));
    Check((T.Grid.Columns[0].Width = Original) and (T.Grid.Cursor = crCross), 'Resize survived Escape');
    T.Grid.Columns[0].MinWidth := 80;
    T.Grid.Columns[0].MaxWidth := 210;
    T.Grid.PointerDown(P);
    T.Grid.PointerMove(Point(P.X + 80, P.Y));
    T.Grid.PointerUp(Point(P.X + 80, P.Y));
    Check(T.Grid.Columns[0].Width = 210, 'Resize bypassed MaxWidth');
    T.PaintGrid;
    H := T.Grid.HeaderBounds(0);
    P := Point(H.Right, H.CenterPoint.Y);
    T.Grid.PointerDown(P);
    T.Grid.PointerUp(Point(P.X - 200, P.Y));
    Check(T.Grid.Columns[0].Width = 80, 'Resize bypassed MinWidth');
    T.Grid.Columns[1].Width := 900;
    T.PaintGrid;
    H := T.Grid.HeaderBounds(1);
    T.Grid.HoverAt(Point(H.Right - 2, H.CenterPoint.Y));
    Check(T.Grid.Cursor = crCross, 'Clipped viewport edge became a resize boundary');
    H := T.Grid.HeaderBounds(0);
    P := Point(H.Right, H.CenterPoint.Y);
    T.Grid.PointerDown(P);
    T.Grid.Columns[0].Free;
    T.Grid.PointerMove(Point(P.X + 10, P.Y));
    T.Grid.PointerUp(Point(P.X + 10, P.Y));
    Check(T.Grid.Cursor = crCross, 'Deleted resize column left cursor active');
    Writeln('PASS: resizing, both edge sides, hover/leave, release coordinates, selection, capture/Escape, bounds and deleted columns');
  finally
    T.Free;
  end;
end;

{$IFDEF TEST_FMX}
procedure TestHeaderPanFeedback;
var
  T: TFixture;
  P, Q, R: TPoint;
  B: TBitmap;
  TouchMode, CancelMode, I: Integer;
  Shift: TShiftState;
  Baseline, Active: TAlphaColor;
  H: TScrollBar;

  function PixelAt(X, Y: Integer): TAlphaColor;
  var
    Data: TBitmapData;
  begin
    B := T.Grid.MakeScreenshot;
    try
      Check(B.Map(TMapAccess.Read, Data), 'Cannot map drag feedback');
      try
        Result := Data.GetPixel(X, Y);
      finally
        B.Unmap(Data);
      end;
    finally
      B.Free;
    end;
  end;

begin
  for TouchMode := 0 to 1 do
    for CancelMode := 0 to 2 do
    begin
      T := TFixture.Create(Th5uCacheMode.None);
      try
        T.Grid.AllowEditing := False;
        T.Grid.Cursor := crCross;
        T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
        if TouchMode = 1 then Shift := [ssTouch] else Shift := [];
        P := T.Grid.HeaderBounds(0).CenterPoint;
        Q := T.Grid.HeaderBounds(2).CenterPoint;
        R := Point(T.Grid.HeaderBounds(2).Right, 180);
        Baseline := PixelAt(R.X, R.Y);
        T.Grid.PointerDown(P, Shift);
        T.Grid.PanPoint(PointF(P.X, P.Y), [TInteractiveGestureFlag.gfBegin]);
        Check(PixelAt(R.X, R.Y) = Baseline, 'Click showed a drag marker before threshold');
        // Native Pan can supply the movement without a corresponding MouseMove.
        T.Grid.PanPoint(PointF(Q.X, Q.Y), []);
        Active := PixelAt(R.X, R.Y);
        Check(Active <> Baseline, 'No insertion marker during native Pan');
        Check(T.Grid.Columns.VisibleColumns[0] = T.Grid.Columns[0], 'Column reordered before release');
        Check(T.Grid.Selection.SelectedColumnCount = 0, 'Move changed selection');
        // An invalid drop in the data area must remove the insertion marker.
        T.Grid.PanPoint(PointF(Q.X, 100), []);
        Check(PixelAt(R.X, R.Y) = Baseline, 'Data area still shows an insertion marker');
        T.Grid.PanPoint(PointF(Q.X, Q.Y), []);
        Check(PixelAt(R.X, R.Y) = Active, 'Returning to header did not restore feedback');
        for I := 0 to T.Grid.ComponentCount - 1 do
          if T.Grid.Components[I] is TScrollBar then
          begin
            H := TScrollBar(T.Grid.Components[I]);
            Check(H.Value = 0, 'Header move also scrolled');
          end;
        if CancelMode = 1 then T.Grid.Press(vkEscape)
        else if CancelMode = 2 then T.Grid.LoseMoveCapture;
        T.Grid.PanPoint(PointF(Q.X, Q.Y), [TInteractiveGestureFlag.gfEnd]);
        T.Grid.PointerUp(Q, Shift);
        Check((T.Grid.Columns.VisibleColumns[0] <> T.Grid.Columns[0]) = (CancelMode = 0), 'Native Pan cancelled a move or ignored cancellation');
        Check(T.Grid.Cursor = crCross, 'Drag left the cursor active');
        Check(T.Grid.Root.Captured = nil, 'Drag left capture active');
        Check(PixelAt(R.X, R.Y) = Baseline, 'Drag feedback survived release/cancel');
        Check(T.Posts = 0, 'Header Pan edited data');
      finally
        T.Free;
      end;
    end;
  Writeln('PASS: FMX mouse/touch Pan column move, live feedback, invalid targets, release, Escape and capture loss');
end;

procedure TestScrolledTextLayout;
var
  T: TFixture;
  BeforeImage, AfterImage: TBitmap;
  BeforeData, AfterData: TBitmapData;
  I, X, Y, Difference, FixedDifference: Integer;
  Header: TRect;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    T.Grid.Columns[0].FixedKind := Th5uFixedKind.Left;
    T.Grid.Columns[1].WordWrap := True;
    T.Grid.Width := 370;
    T.Grid.RowHeight.FixedHeight := 80;
    T.PaintGrid;
    Header := T.Grid.HeaderBounds(1);
    BeforeImage := T.Grid.MakeScreenshot;
    try
      for I := 0 to T.Grid.ComponentCount - 1 do
        if T.Grid.Components[I] is TScrollBar then
          if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Horizontal then
            TScrollBar(T.Grid.Components[I]).Value := 40;
      AfterImage := T.Grid.MakeScreenshot;
      try
        Check(BeforeImage.Map(TMapAccess.Read, BeforeData), 'Cannot map original text');
        try
          Check(AfterImage.Map(TMapAccess.Read, AfterData), 'Cannot map scrolled text');
          try
            Difference := 0;
            FixedDifference := 0;
            for Y := Header.Top + 2 to Header.Bottom + 77 do
            begin
              for X := Header.Left + 2 to Header.Right - 43 do
                if BeforeData.GetPixel(X + 40, Y) <> AfterData.GetPixel(X, Y) then Inc(Difference);
              for X := 2 to Header.Left - 2 do
                if BeforeData.GetPixel(X, Y) <> AfterData.GetPixel(X, Y) then Inc(FixedDifference);
            end;
            Check(Difference < 25, Format('Horizontal scroll reflowed/recentered text (%d pixels)', [Difference]));
            Check(FixedDifference = 0, 'Scrolling text painted over the fixed column');
          finally
            AfterImage.Unmap(AfterData);
          end;
        finally
          BeforeImage.Unmap(BeforeData);
        end;
      finally
        AfterImage.Free;
      end;
    finally
      BeforeImage.Free;
    end;
    Check(T.Grid.Columns[1].Width = 150, 'Horizontal scrolling changed column width');
    Writeln('PASS: FMX horizontal scrolling clips full-width text/header without reflow or painting over fixed columns');
  finally
    T.Free;
  end;
end;

procedure TestTouchBodyAfterResize;
var
  T: TFixture;
  P, Q: TPoint;
  Widths: array[0..2] of Integer;
  I, Attempt: Integer;
  V, H: TScrollBar;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    T.Grid.Columns[0].FixedKind := Th5uFixedKind.Left;
    T.Grid.Width := 370;
    T.Grid.Height := 180;
    T.Grid.RowHeight.FixedHeight := 80;
    T.PaintGrid;
    V := nil;
    H := nil;
    for I := 0 to T.Grid.ComponentCount - 1 do
      if T.Grid.Components[I] is TScrollBar then
        if TScrollBar(T.Grid.Components[I]).Orientation = TOrientation.Vertical then
          V := TScrollBar(T.Grid.Components[I])
        else H := TScrollBar(T.Grid.Components[I]);
    Check(Assigned(V) and Assigned(H), 'Missing scrollbars');
    P := Point(T.Grid.HeaderBounds(1).Right - 5, 12);
    T.Grid.PointerDown(P, [ssTouch]);
    Q := Point(P.X + 20, P.Y + 8);
    T.Grid.PanPoint(PointF(P.X, P.Y), [TInteractiveGestureFlag.gfBegin]);
    T.Grid.PanPoint(PointF(Q.X, Q.Y), []);
    Check(T.Grid.Columns[1].Width = 170, 'Native header Pan did not resize');
    Check((V.Value = 0) and (H.Value = 0), 'Header resizing also scrolled');
    T.Grid.PointerUp(Q, [ssTouch]);
    // Android can deliver gesture-end after MouseUp.
    T.Grid.PanPoint(PointF(Q.X, Q.Y), [TInteractiveGestureFlag.gfEnd]);
    for I := 0 to 2 do Widths[I] := T.Grid.Columns[I].Width;
    for Attempt := 0 to 3 do
    begin
      V.Value := 0;
      H.Value := 0;
      T.PaintGrid;
      P := Point(315, 120);
      case Attempt of
        1: P.X := T.Grid.HeaderBounds(1).Right;
        2: P.X := T.Grid.HeaderBounds(0).Right;
        3: P.Y := T.Grid.HeaderBounds(0).Bottom + T.Grid.Spacing.RowSpacing;
      end;
      Q := Point(P.X - 35, P.Y - 30);
      T.Grid.PointerDown(P, [ssTouch]);
      T.Grid.PanPoint(PointF(P.X, P.Y), [TInteractiveGestureFlag.gfBegin]);
      T.Grid.PointerMove(Q, [ssTouch]);
      T.Grid.PanPoint(PointF(Q.X, Q.Y), []);
      T.Grid.PointerUp(Q, [ssTouch]);
      T.Grid.PanPoint(PointF(Q.X, Q.Y), [TInteractiveGestureFlag.gfEnd]);
      Check((V.Value > 0) and (H.Value > 0), 'Data swipe did not scroll both axes');
      for I := 0 to 2 do
        Check(T.Grid.Columns[I].Width = Widths[I], 'Data swipe resized a column');
      V.Value := 0;
      H.Value := 0;
      T.PaintGrid;
      for I := 0 to 2 do
        Check(T.Grid.Columns[I].Width = Widths[I], 'Width changed after returning to scroll origin');
    end;
    Check(T.Posts = 0, 'Data swipe edited data');
    Writeln('PASS: FMX touch data swipes after header resize, both axes, fixed first column and unchanged widths');
  finally
    T.Free;
  end;
end;

procedure TestTouchHeaders;
var
  T: TFixture;
  H: TRect;
  P, Q: TPointF;
  Original: Integer;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  try
    T.Grid.AllowEditing := False;
    T.Grid.Cursor := crCross;
    T.Grid.Selection.SelectColumn('DESCRIPTION');
    H := T.Grid.HeaderBounds(0);
    P := PointF(H.Right - 10, H.CenterPoint.Y);
    Original := T.Grid.Columns[0].Width;
    T.Grid.TouchDrag(P, PointF(P.X + 35, P.Y));
    Check(T.Grid.Columns[0].Width = Original + 35, 'Touch resize needs a larger edge target');
    Check(T.Grid.Cursor = crCross, 'Touch resize changed mouse cursor');
    Check(T.Grid.Selection.IsColumnSelected('DESCRIPTION'), 'Touch resize changed selection');
    T.Grid.Selection.Clear;
    T.PaintGrid;
    H := T.Grid.HeaderBounds(0);
    P := PointF(H.CenterPoint.X, H.CenterPoint.Y);
    H := T.Grid.HeaderBounds(2);
    Q := PointF(H.CenterPoint.X, H.CenterPoint.Y);
    // Touch header dragging must work without Alt, including alongside native Pan events.
    T.Grid.PointerDown(Point(Round(P.X), Round(P.Y)), [ssTouch]);
    T.Grid.PanGesture(P, Q);
    T.Grid.PointerMove(Point(Round(Q.X), Round(Q.Y)), [ssTouch]);
    T.Grid.PointerUp(Point(Round(Q.X), Round(Q.Y)), [ssTouch]);
    Check(T.Grid.Columns.VisibleColumns[0] <> T.Grid.Columns[0], 'Touch header did not move column without Alt');
    Check(T.Grid.Cursor = crCross, 'Touch move left cursor active');
    Check(T.Posts = 0, 'Touch header gesture edited data');
    Writeln('PASS: touch header resizing and column moving without Alt, native Pan arbitration and selection');
  finally
    T.Free;
  end;
end;
{$ENDIF}

procedure TestBlockMoving;
var
  T: TFixture;
  Probe: TMoveProbe;
  Rows, Cols: array[0..2] of TPoint;
  Keys: array[0..2] of Th5uRowKey;
  I, X, Y, Before: Integer;
  Found: Boolean;
{$IFDEF TEST_FMX}
  H: Th5uFmxHitTestInfo;
{$ELSE}
  H: Th5uHitTestInfo;
{$ENDIF}

  procedure Drag(const AFrom, ATo: TPoint; Shift: TShiftState = [ssAlt]);
  begin
    T.Grid.PointerDown(AFrom, Shift);
    T.Grid.PointerMove(ATo, Shift);
    T.Grid.PointerUp(ATo, Shift);
  end;

  procedure CheckOrder(A, B, C: Integer; const Msg: string);
  var
    V: TArray<Th5uGridColumn>;
  begin
    V := T.Grid.Columns.VisibleColumns;
    Check((V[0]=T.Grid.Columns[A]) and (V[1]=T.Grid.Columns[B]) and (V[2]=T.Grid.Columns[C]), Msg);
  end;

begin
  T := TFixture.Create(Th5uCacheMode.None);
  Probe := TMoveProbe.Create;
  try
    T.Grid.AllowEditing := False;
    T.Grid.Cursor := crCross;
    T.Grid.Selection.AllowedKinds := [Th5uSelectionKind.Rows,Th5uSelectionKind.Columns,Th5uSelectionKind.CellRanges];
    Check(GetPropInfo(T.Grid.Columns[0], 'CanMove') = nil, 'CanMove compatibility remains published');
    for I := 0 to 2 do
    begin
      Keys[I] := T.Controller.GetRowKey(I);
      Found := False;
      for Y := 0 to Trunc(T.Grid.Height) div 4 do
      begin
        for X := 0 to Trunc(T.Grid.Width) div 4 do
        begin
{$IFDEF TEST_FMX}
          H := T.Grid.GridHitTest(X*4,Y*4);
          if (H.Kind=Th5uFmxHitKind.RowIndicator) and (H.RowIndex=I) then
{$ELSE}
          H := T.Grid.HitTest(X*4,Y*4);
          if (H.Kind=Th5uHitKind.RowIndicator) and (H.RowIndex=I) then
{$ENDIF}
          begin
            Rows[I] := Point(X*4, Round((H.Bounds.Top+H.Bounds.Bottom)/2));
            Found := True;
            Break;
          end;
        end;
        if Found then Break;
      end;
      Check(Found, 'Row header missing for block move');
      Found := False;
      for Y := 0 to Trunc(T.Grid.Height) div 4 do
      begin
        for X := 0 to Trunc(T.Grid.Width) div 4 do
        begin
{$IFDEF TEST_FMX}
          H := T.Grid.GridHitTest(X*4,Y*4);
          if (H.Kind=Th5uFmxHitKind.Header) and (H.ColumnIndex=I) then
{$ELSE}
          H := T.Grid.HitTest(X*4,Y*4);
          if (H.Kind=Th5uHitKind.Header) and (H.ColumnIndex=I) then
{$ENDIF}
          begin
            Cols[I] := Point(Round((H.Bounds.Left+H.Bounds.Right)/2), Y*4);
            Found := True;
            Break;
          end;
        end;
        if Found then Break;
      end;
      Check(Found, 'Column header missing for block move');
    end;

    T.Grid.Selection.SelectColumns([T.Grid.Columns[0].Id,T.Grid.Columns[1].Id]);
    T.Grid.PointerDown(Cols[1],[ssAlt]);
    Check(T.Grid.Cursor=crCross, 'Move cursor activated on mere MouseDown');
    T.Grid.PointerMove(Cols[2],[ssAlt]);
    Check(T.Grid.Cursor=crDrag, 'Column block drag cursor missing');
    T.Grid.PointerUp(Cols[2],[ssAlt]);
    CheckOrder(2,0,1,'Column block did not retain order moving right');
    Check(T.Grid.Cursor=crCross,'Column cursor not restored');
    Check(T.Grid.Selection.IsColumnSelected(T.Grid.Columns[0].Id)
      and T.Grid.Selection.IsColumnSelected(T.Grid.Columns[1].Id),'Column move lost selection');
    T.PaintGrid;
    Drag(Cols[2],Cols[0]);
    CheckOrder(0,1,2,'Column block did not retain order moving left');
    T.PaintGrid;
    Drag(Cols[0],Cols[1]);
    CheckOrder(0,1,2,'Drop inside selected column block moved it');
    T.Grid.Selection.SelectColumns([T.Grid.Columns[0].Id,T.Grid.Columns[2].Id]);
    T.Grid.PointerDown(Cols[0],[ssAlt]);
    T.Grid.PointerMove(Cols[1],[ssAlt]);
    Check(T.Grid.Cursor=crCross,'Non-contiguous column move started');
    T.Grid.PointerUp(Cols[1],[ssAlt]);
    CheckOrder(0,1,2,'Non-contiguous column selection moved');
    T.Grid.Selection.SelectColumns([T.Grid.Columns[0].Id,T.Grid.Columns[1].Id]);
    T.Grid.Columns[1].MovePermission := Th5uColumnMovePermission.Deny;
    Drag(Cols[0],Cols[2]);
    CheckOrder(0,1,2,'Partially denied column block moved');
    T.Grid.Columns[1].MovePermission := Th5uColumnMovePermission.Default;
    T.Grid.Selection.Clear;
    T.Grid.Columns[0].FixedKind := Th5uFixedKind.Left;
    T.PaintGrid;
    Drag(Cols[1],Cols[0]);
    CheckOrder(0,1,2,'Column crossed the fixed region');
    T.Grid.Columns[0].FixedKind := Th5uFixedKind.None;
    T.PaintGrid;
    T.Grid.PointerDown(Cols[0],[ssAlt]);
    T.Grid.PointerMove(Cols[2],[ssAlt]);
    T.Grid.Press(vkEscape);
    Check(T.Grid.Cursor=crCross,'Escape did not restore column cursor');
    T.Grid.PointerUp(Cols[2],[ssAlt]);
    CheckOrder(0,1,2,'Escape did not cancel column move');
    T.Grid.PointerDown(Cols[0],[ssAlt]);
    T.Grid.PointerMove(Cols[2],[ssAlt]);
    T.Grid.Columns[0].MovePermission := Th5uColumnMovePermission.Deny;
    T.Grid.PointerUp(Cols[2],[ssAlt]);
    CheckOrder(0,1,2,'Column permission changed during drag was ignored');
    T.Grid.Columns[0].MovePermission := Th5uColumnMovePermission.Default;
    Drag(Cols[0],Point(-20,-20));
    CheckOrder(0,1,2,'Outside column drop changed order');
    Check(T.Grid.Cursor=crCross,'Outside column drop left drag cursor');

    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    Check(T.Grid.Cursor=crCross,'Row move started without an event');
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    T.Grid.Selection.Clear;
    T.Grid.OnRowsMoved := Probe.RowsMoved;
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerUp(Rows[0],[ssAlt]);
    Check(Probe.Count=0,'Click emitted a move event');
    T.Grid.Selection.SelectRows([Keys[0],Keys[1]]);
    T.Grid.PointerDown(Rows[1],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    Check(T.Grid.Cursor=crDrag,'Row block drag cursor missing');
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    Check((Probe.Count=1) and (Probe.Context.FirstRowIndex=0) and (Probe.Context.NewFirstRowIndex=1) and (Length(Probe.Context.RowKeys)=2)
      and (Probe.Context.RowKeys[0]=Keys[0]) and (Probe.Context.RowKeys[1]=Keys[1]) and (Probe.Context.SourceRowIndexes[0]=0)
      and (Probe.Context.SourceRowIndexes[1]=1) and (Probe.Context.TargetRowIndex=2) and (Probe.Context.TargetSourceRowIndex=2)
      and (Probe.Context.TargetRowKey=Keys[2]) and Probe.Context.InsertAfter,'Incorrect downward row move context');
    Check((T.Posts=0) and (T.Controller.GetRowKey(0)=Keys[0]),'Grid reordered data without the developer handler');
    T.Grid.Selection.SelectRows([Keys[1],Keys[2]]);
    Drag(Rows[2],Rows[0]);
    Check((Probe.Count=2) and (Probe.Context.FirstRowIndex=1) and (Probe.Context.NewFirstRowIndex=0) and not Probe.Context.InsertAfter
      and (Probe.Context.TargetRowKey=Keys[0]),'Incorrect upward row move context');
    Before := Probe.Count;
    Drag(Rows[1],Rows[2]);
    Check(Probe.Count=Before,'Drop inside row block emitted event');
    T.Grid.Selection.SelectRows([Keys[0],Keys[2]]);
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[1],[ssAlt]);
    Check(T.Grid.Cursor=crCross,'Non-contiguous row move started');
    T.Grid.PointerUp(Rows[1],[ssAlt]);
    Check(Probe.Count=Before,'Non-contiguous rows emitted move event');
    T.Grid.Selection.SelectAllRows;
    Drag(Rows[0],Rows[2]);
    Check(Probe.Count=Before,'Moving the entire query should be a no-op');
    T.Grid.Selection.ExcludeRow(Keys[0]);
    Drag(Rows[2],Rows[0]);
    Check((Probe.Count=Before+1) and (Length(Probe.Context.RowKeys)=2),'Contiguous select-all minus exclusions could not move');
    T.Grid.Selection.Clear;
    T.Grid.Customization.RowMovingGesture := Th5uColumnRowMovingGesture.Drag;
    Drag(Rows[0],Rows[2],[]);
    Check((Probe.Count=Before+2) and (Length(Probe.Context.RowKeys)=1),'Plain row moving gesture failed');
    Before := Probe.Count;
    Drag(Rows[0],Rows[2],[ssCtrl]);
    Check(Probe.Count=Before,'Ctrl selection moved rows');
    T.Grid.Customization.AllowRowMoving := False;
    Drag(Rows[0],Rows[2],[]);
    Check(Probe.Count=Before,'Row moving ignored grid prohibition');
    T.Grid.Customization.AllowRowMoving := True;
    T.Grid.Customization.RowMovingGesture := Th5uColumnRowMovingGesture.AltDrag;
    T.Grid.Selection.Clear;
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    T.Grid.Press(vkEscape);
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    Check((Probe.Count=Before) and (T.Grid.Cursor=crCross),'Escape did not cancel row move');
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    T.Grid.LoseMoveCapture;
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    Check((Probe.Count=Before) and (T.Grid.Cursor=crCross),'Lost capture did not cancel row move');
    Drag(Rows[0],Point(-20,-20));
    Check((Probe.Count=Before) and (T.Grid.Cursor=crCross),'Outside drop emitted row move');
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    T.Grid.OnRowsMoved := nil;
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    Check(Probe.Count=Before,'Unassigned row handler called');
    T.Grid.OnRowsMoved := Probe.RowsMoved;
    Probe.RaiseError := True;
    try
      Drag(Rows[0],Rows[2]);
      Check(False,'Move handler exception was swallowed');
    except
      on E: Exception do Check(E.Message='Move handler test exception','Unexpected move exception: '+E.Message);
    end;
    Check(T.Grid.Cursor=crCross,'Move handler exception left drag cursor');
    Probe.RaiseError := False;
    Before := Probe.Count;
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    T.Grid.DataController := nil;
    T.Grid.DataController := T.Controller;
    T.PaintGrid;
    T.Grid.PointerUp(Rows[2],[ssAlt]);
    Check((Probe.Count=Before) and (T.Grid.Cursor=crCross),'Controller change did not cancel row move');
    T.Grid.PointerDown(Rows[0],[ssAlt]);
    T.Grid.PointerMove(Rows[2],[ssAlt]);
    T.Data.First;
    T.Data.Delete;
    T.PaintGrid;
    T.Grid.PointerUp(Rows[1],[ssAlt]);
    Check(Probe.Count=Before,'Deleted source row emitted stale move event');
    Writeln('PASS: contiguous row/column block moving, event context, permissions, fixed regions, cursor, cancel and live changes');
  finally
    T.Grid.OnRowsMoved := nil;
    Probe.Free;
    T.Free;
  end;
end;


procedure TestMixedSelection;
var
  T: TFixture;
  Events: TCellEventProbe;
  Cells: array[0..2, 0..2] of TPoint;
  Rows, Cols: array[0..2] of TPoint;
  Keys: array[0..2] of Th5uRowKey;
  I, J, Before: Integer;

  function HitPoint(Kind: Th5uSelectionKind; Row, Col: Integer): TPoint;
  var
    X, Y: Integer;
{$IFDEF TEST_FMX}
    H: Th5uFmxHitTestInfo;
{$ELSE}
    H: Th5uHitTestInfo;
{$ENDIF}
    Match: Boolean;
  begin
    T.PaintGrid;
    for Y := 0 to Trunc(T.Grid.Height) div 4 do
      for X := 0 to Trunc(T.Grid.Width) div 4 do
      begin
{$IFDEF TEST_FMX}
        H := T.Grid.GridHitTest(X*4,Y*4);
        Match := ((Kind=Th5uSelectionKind.Rows) and (H.Kind=Th5uFmxHitKind.RowIndicator) and (H.RowIndex=Row)) or ((Kind=Th5uSelectionKind.Columns)
          and (H.Kind=Th5uFmxHitKind.Header) and (H.ColumnIndex=Col)) or ((Kind=Th5uSelectionKind.CellRanges) and (H.Kind=Th5uFmxHitKind.DataCell)
          and (H.RowIndex=Row) and (H.ColumnIndex=Col));
{$ELSE}
        H := T.Grid.HitTest(X*4,Y*4);
        Match := ((Kind=Th5uSelectionKind.Rows) and (H.Kind=Th5uHitKind.RowIndicator) and (H.RowIndex=Row)) or ((Kind=Th5uSelectionKind.Columns)
          and (H.Kind=Th5uHitKind.Header) and (H.ColumnIndex=Col)) or ((Kind=Th5uSelectionKind.CellRanges) and (H.Kind=Th5uHitKind.DataCell)
          and (H.RowIndex=Row) and (H.ColumnIndex=Col));
{$ENDIF}
        if Match then
          if Kind=Th5uSelectionKind.Rows then Exit(Point(X*4,Round((H.Bounds.Top+H.Bounds.Bottom)/2)))
          else if Kind=Th5uSelectionKind.Columns then Exit(Point(Round((H.Bounds.Left+H.Bounds.Right)/2),Y*4))
          else Exit(Point(Round((H.Bounds.Left+H.Bounds.Right)/2),Round((H.Bounds.Top+H.Bounds.Bottom)/2)));
      end;
    raise Exception.CreateFmt('Selection target not found: %d/%d/%d',[Ord(Kind),Row,Col]);
  end;

  procedure CheckRows(A, B, C: Boolean; const Msg: string);
  begin
    Check((T.Grid.Selection.IsRowSelected(Keys[0])=A) and (T.Grid.Selection.IsRowSelected(Keys[1])=B) and (T.Grid.Selection.IsRowSelected(Keys[2])
      =C),Msg);
  end;

  procedure CheckCols(A, B, C: Boolean; const Msg: string);
  begin
    Check((T.Grid.Selection.IsColumnSelected(T.Grid.Columns[0].Id)=A) and (T.Grid.Selection.IsColumnSelected(T.Grid.Columns[1].Id)=B)
      and (T.Grid.Selection.IsColumnSelected(T.Grid.Columns[2].Id)=C),Msg);
  end;

begin
  T := TFixture.Create(Th5uCacheMode.None);
  Events := TCellEventProbe.Create;
  try
    T.Grid.AllowEditing := False;
    T.Grid.OnSelectionChange := Events.SelectionChange;
    for I := 0 to 2 do
    begin
      Keys[I] := T.Controller.GetRowKey(I);
      Rows[I] := HitPoint(Th5uSelectionKind.Rows,I,-1);
      Cols[I] := HitPoint(Th5uSelectionKind.Columns,-1,I);
      for J := 0 to 2 do Cells[I,J] := HitPoint(Th5uSelectionKind.CellRanges,I,J);
    end;
    T.Grid.ClickAt(Rows[0]);
    T.Grid.ClickWithShift(Cols[0],[ssCtrl]);
    T.Grid.ClickWithShift(Cells[1,1],[ssCtrl]);
    CheckRows(True,False,False,'Ctrl cell/column click lost row');
    CheckCols(True,False,False,'Ctrl cell click lost column');
    T.Grid.ClickAt(Cells[2,2]);
    CheckRows(False,False,False,'Plain cell click retained row');
    CheckCols(False,False,False,'Plain cell click retained column');
    Check(T.Grid.Selection.IsCellSelected(2,2) and not T.Grid.Selection.IsCellSelected(1,1),'Plain cell did not replace selection');
    T.Grid.ClickWithShift(Cols[0],[ssCtrl]);
    T.Grid.ClickAt(Cols[1]);
    CheckCols(False,True,False,'Plain column retained old column');
    Check(T.Grid.Selection.CellRanges.Count=0,'Plain column retained cells');
    T.Grid.ClickWithShift(Rows[0],[ssCtrl]);
    T.Grid.ClickAt(Rows[1]);
    CheckCols(False,False,False,'Plain row retained column');
    CheckRows(False,True,False,'Plain row retained old row');

    T.Grid.ClickAt(Rows[0]);
    Before := Events.Selections;
    T.Grid.ClickWithShift(Rows[2],[ssShift]);
    CheckRows(True,True,True,'Shift row range missing');
    Check(Events.Selections=Before+1,'Row range emitted intermediate selection notifications');
    T.Grid.ClickWithShift(Rows[1],[ssShift]);
    CheckRows(True,True,False,'Shift row range did not contract');
    T.Grid.ClickAt(Rows[0]);
    T.Grid.ClickWithShift(Rows[2],[ssCtrl]);
    T.Grid.ClickWithShift(Rows[1],[ssCtrl,ssShift]);
    CheckRows(True,True,True,'Ctrl+Shift row range lost previous selection');
    T.Grid.ClickWithShift(Rows[2],[ssCtrl,ssShift]);
    CheckRows(True,False,True,'Ctrl+Shift row range did not contract');
    T.Grid.Press(vkUp,[ssCtrl,ssShift]);
    CheckRows(True,True,True,'Ctrl+Shift Up did not extend rows');
    T.Grid.Press(vkDown,[ssCtrl,ssShift]);
    CheckRows(True,False,True,'Ctrl+Shift Down did not contract rows');
    T.Grid.ClickAt(Rows[0]);
    T.Grid.Press(vkDown,[ssShift]);
    CheckRows(True,True,False,'Shift Down did not extend rows');
    T.Grid.Press(vkUp,[ssShift]);
    CheckRows(True,False,False,'Shift Up did not contract rows');

    T.Grid.ClickAt(Cols[0]);
    T.Grid.ClickWithShift(Cols[2],[ssShift]);
    CheckCols(True,True,True,'Shift column range missing');
    T.Grid.ClickWithShift(Cols[1],[ssShift]);
    CheckCols(True,True,False,'Shift column range did not contract');
    T.Grid.ClickAt(Cols[0]);
    T.Grid.ClickWithShift(Cols[2],[ssCtrl]);
    T.Grid.ClickWithShift(Cols[1],[ssCtrl,ssShift]);
    CheckCols(True,True,True,'Ctrl+Shift column range lost previous selection');
    T.Grid.ClickWithShift(Cols[2],[ssCtrl,ssShift]);
    CheckCols(True,False,True,'Ctrl+Shift column range did not contract');
    T.Grid.Press(vkLeft,[ssCtrl,ssShift]);
    CheckCols(True,True,True,'Ctrl+Shift Left did not extend columns');
    T.Grid.Press(vkRight,[ssCtrl,ssShift]);
    CheckCols(True,False,True,'Ctrl+Shift Right did not contract columns');
    T.Grid.ClickAt(Cols[0]);
    T.Grid.Press(vkRight,[ssShift]);
    CheckCols(True,True,False,'Shift Right did not extend columns');
    T.Grid.Press(vkLeft,[ssShift]);
    CheckCols(True,False,False,'Shift Left did not contract columns');

    T.Grid.ClickAt(Cells[0,0]);
    T.Grid.ClickWithShift(Cells[2,2],[ssCtrl]);
    T.Grid.ClickWithShift(Cells[1,1],[ssCtrl,ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and T.Grid.Selection.IsCellSelected(1,1) and T.Grid.Selection.IsCellSelected(2,1)
      and not T.Grid.Selection.IsCellSelected(0,2),'Ctrl+Shift cell range incorrect');
    T.Grid.ClickWithShift(Cells[2,2],[ssCtrl,ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0,0)
      and not T.Grid.Selection.IsCellSelected(1,1),'Ctrl+Shift cell contraction lost base or retained old extent');
    T.Grid.Press(vkUp,[ssCtrl,ssShift]);
    T.Grid.Press(vkLeft,[ssCtrl,ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and T.Grid.Selection.IsCellSelected(1,1),'Ctrl+Shift arrows replaced base selection');
    T.Grid.Press(vkRight,[ssCtrl,ssShift]);
    T.Grid.Press(vkDown,[ssCtrl,ssShift]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and T.Grid.Selection.IsCellSelected(2,2) and not T.Grid.Selection.IsCellSelected(1,2)
      and not T.Grid.Selection.IsCellSelected(2,1),'Ctrl+Shift arrows did not contract');
    Check(T.Grid.Selection.CellRanges.Count=3,'Ctrl+Shift accumulated a range on every key press');
    T.Grid.ClickAt(Cells[0,0]);
    T.Grid.ClickWithShift(Cells[2,2],[ssShift]);
    Check(T.Grid.Selection.IsCellSelected(1,1),'Shift cell click did not extend');
    T.Grid.Press(vkUp,[ssShift]);
    Check(T.Grid.Selection.IsCellSelected(1,2) and not T.Grid.Selection.IsCellSelected(2,2),'Shift Up did not contract cell range');
    Check(T.Posts=0,'Selection modifiers edited a checkbox');

    // Selection must change during MouseMove, before the button is released.
    T.Grid.ClickAt(Cells[2,2]);
    T.Grid.OnCellClick := Events.CellClick;
    Before := Events.Clicks;
    T.Grid.PointerDown(Cells[0,1]);
    Check(T.Grid.Selection.IsCellSelected(0,1) and not T.Grid.Selection.IsCellSelected(2,2),'MouseDown did not replace selection');
    T.Grid.PointerMove(Cells[2,2]);
    Check(T.Grid.Selection.IsCellSelected(1,1) and T.Grid.Selection.IsCellSelected(2,2),'MouseMove did not select cell rectangle');
    T.Grid.PointerMove(Cells[1,1]);
    Check(T.Grid.Selection.IsCellSelected(1,1) and not T.Grid.Selection.IsCellSelected(2,2),'Mouse drag did not contract');
    T.Grid.PointerUp(Cells[1,1]);
    Check(Events.Clicks=Before,'Range drag fired OnCellClick');
    T.Grid.ClickAt(Cells[0,0]);
    T.Grid.PointerDown(Cells[2,2],[ssCtrl]);
    T.Grid.PointerMove(Cells[1,1],[ssCtrl]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and T.Grid.Selection.IsCellSelected(1,1),'Ctrl drag lost previous selection');
    T.Grid.PointerMove(Cells[2,2],[ssCtrl]);
    Check(T.Grid.Selection.IsCellSelected(0,0) and not T.Grid.Selection.IsCellSelected(1,1),'Ctrl drag contraction lost base');
    T.Grid.PointerUp(Cells[2,2],[ssCtrl]);
    T.Grid.PointerMove(Cells[0,1],[ssCtrl]);
    Check(not T.Grid.Selection.IsCellSelected(0,1),'MouseMove changed selection after MouseUp');
    T.Grid.PointerDown(Cells[0,1]);
    T.Grid.PointerUp(Cells[2,2]);
    Check(T.Grid.Selection.IsCellSelected(1,1) and T.Grid.Selection.IsCellSelected(2,2),'MouseUp final coordinates were ignored');
    T.Grid.PointerDown(Cells[0,1]);
    T.Grid.PointerMove(Cells[2,2]);
    T.Grid.PointerUp(Point(-20,-20));
    T.Grid.PointerMove(Cells[0,1]);
    Check(T.Grid.Selection.IsCellSelected(2,2),'Release outside the grid left a drag active');

    T.Grid.PointerDown(Rows[0]);
    T.Grid.PointerMove(Rows[2]);
    CheckRows(True,True,True,'Row header drag missing');
    T.Grid.PointerMove(Rows[1]);
    CheckRows(True,True,False,'Row drag did not contract');
    T.Grid.PointerUp(Rows[1]);
    T.Grid.ClickAt(Rows[0]);
    T.Grid.PointerDown(Rows[2],[ssCtrl]);
    T.Grid.PointerMove(Rows[1],[ssCtrl]);
    CheckRows(True,True,True,'Ctrl row drag lost base');
    T.Grid.PointerMove(Rows[2],[ssCtrl]);
    T.Grid.PointerUp(Rows[2],[ssCtrl]);
    CheckRows(True,False,True,'Ctrl row drag contraction incorrect');

    Check(T.Grid.Customization.ColumnMovingGesture=Th5uColumnRowMovingGesture.AltDrag,'Default moving gesture is not Alt+drag');
    T.Grid.PointerDown(Cols[0]);
    T.Grid.PointerMove(Cols[2]);
    CheckCols(True,True,True,'Column header drag missing');
    T.Grid.PointerMove(Cols[1]);
    CheckCols(True,True,False,'Column drag did not contract');
    T.Grid.PointerUp(Cols[1]);
    Check(T.Grid.Columns[0].VisibleIndex=0,'Selection drag moved a column');
    T.Grid.ClickAt(Cols[0]);
    T.Grid.PointerDown(Cols[2],[ssCtrl]);
    T.Grid.PointerMove(Cols[1],[ssCtrl]);
    CheckCols(True,True,True,'Ctrl column drag lost base');
    T.Grid.PointerMove(Cols[2],[ssCtrl]);
    T.Grid.PointerUp(Cols[2],[ssCtrl]);
    CheckCols(True,False,True,'Ctrl column drag contraction incorrect');

    T.Grid.AllowEditing := True;
    T.Grid.ImmediateEdit := True;
    Before := T.Posts;
    T.Grid.PointerDown(Cells[0,1]);
    Check(not Assigned(T.Grid.ActiveEditor),'Immediate editor opened before a drag could start');
    T.Grid.PointerMove(Cells[2,2]);
    T.Grid.PointerUp(Cells[2,2]);
    Check(not Assigned(T.Grid.ActiveEditor) and (T.Posts=Before),'Range drag opened or committed an editor');
    T.Grid.PointerDown(Cells[0,0]);
    Check(T.Posts=Before,'Checkbox changed on MouseDown');
    T.Grid.PointerMove(Cells[2,1]);
    T.Grid.PointerUp(Cells[2,1]);
    Check((T.Posts=Before) and not Assigned(T.Grid.ActiveEditor),'Drag from checkbox edited the cell');
    T.Grid.ClickAt(Cells[0,0]);
    Check(T.Posts=Before+1,'Checkbox click stopped toggling');
    T.Grid.ClickAt(Cells[0,1]);
    Check(T.Editor.Visible,'Immediate editor did not open on click release');
    T.EditorKey(vkEscape);
    T.Grid.AllowEditing := False;
    T.Grid.ImmediateEdit := False;
    T.Grid.OnCellClick := nil;

    T.Grid.PointerDown(Cols[0],[ssAlt]);
    T.Grid.PointerMove(Cols[2],[ssAlt]);
    T.Grid.PointerUp(Cols[2],[ssAlt]);
    Check(T.Grid.Columns[0].VisibleIndex=2,'Alt+drag did not move column');
    T.Grid.MoveColumn(T.Grid.Columns[0],0);
    T.PaintGrid;
    T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
    T.Grid.PointerDown(Cols[0]);
    T.Grid.PointerMove(Cols[2]);
    T.Grid.PointerUp(Cols[2]);
    Check(T.Grid.Columns[0].VisibleIndex=2,'Plain drag mode did not move column');
    T.Grid.MoveColumn(T.Grid.Columns[0],0);
    T.PaintGrid;
    T.Grid.PointerDown(Cols[0],[ssCtrl]);
    T.Grid.PointerMove(Cols[2],[ssCtrl]);
    T.Grid.PointerUp(Cols[2],[ssCtrl]);
    CheckCols(True,True,True,'Ctrl drag in moving mode did not select');
    Check(T.Grid.Columns[0].VisibleIndex=0,'Ctrl selection moved a column');
    T.Grid.Customization.AllowColumnMoving := False;
    T.Grid.PointerDown(Cols[0]);
    T.Grid.PointerMove(Cols[2]);
    T.Grid.PointerUp(Cols[2]);
    CheckCols(True,True,True,'Disabled moving did not permit column selection');
    Check(T.Grid.Columns[0].VisibleIndex=0,'Grid move prohibition ignored');
    T.Grid.Selection.Clear;
    T.Grid.Columns[0].MovePermission := Th5uColumnMovePermission.Allow;
    T.Grid.PointerDown(Cols[0]);
    T.Grid.PointerMove(Cols[2]);
    T.Grid.PointerUp(Cols[2]);
    Check(T.Grid.Columns[0].VisibleIndex=2,'Column Allow did not override grid default');
    T.Grid.MoveColumn(T.Grid.Columns[0],0);
    T.PaintGrid;
    T.Grid.Customization.AllowColumnMoving := True;
    T.Grid.Columns[0].MovePermission := Th5uColumnMovePermission.Deny;
    T.Grid.PointerDown(Cols[0]);
    T.Grid.PointerMove(Cols[2]);
    T.Grid.PointerUp(Cols[2]);
    Check(T.Grid.Columns[0].VisibleIndex=0,'Column Deny was ignored');
    CheckCols(True,True,True,'Denied column moving blocked range selection');
    T.Grid.Columns[0].MovePermission := Th5uColumnMovePermission.Default;
    T.Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.AltDrag;
    Writeln(
      'PASS: live mouse range selection, Ctrl addition, release/capture, immediate and checkbox editing, configurable column moving and permissions');

    T.Grid.Selection.CombinationMode := Th5uSelectionCombinationMode.Exclusive;
    T.Grid.ClickAt(Rows[0]);
    T.Grid.ClickWithShift(Cols[0],[ssCtrl]);
    CheckRows(False,False,False,'Exclusive column toggle retained rows');
    T.Grid.ClickWithShift(Rows[0],[ssCtrl]);
    CheckCols(False,False,False,'Exclusive row toggle retained columns');
    T.Grid.Selection.AllowedKinds := [Th5uSelectionKind.CellRanges];
    T.Grid.ClickWithShift(Rows[0],[ssCtrl]);
    T.Grid.ClickWithShift(Cols[0],[ssCtrl]);
    CheckRows(False,False,False,'Ctrl bypassed AllowedKinds for rows');
    CheckCols(False,False,False,'Ctrl bypassed AllowedKinds for columns');
    T.Grid.Selection.AllowedKinds := [Th5uSelectionKind.Rows,Th5uSelectionKind.Columns,Th5uSelectionKind.CellRanges];
    T.Grid.Columns[1].CanSelect := False;
    T.Grid.ClickAt(Cols[0]);
    T.Grid.ClickWithShift(Cols[2],[ssShift]);
    CheckCols(True,False,True,'Shift selected a column with CanSelect=False');
    T.Grid.ClickWithShift(Cols[1],[ssCtrl]);
    CheckCols(True,False,True,'Ctrl bypassed column CanSelect');
    Writeln('PASS: mixed/exclusive selection, row/column/cell Shift and Ctrl+Shift clicks/arrows, range contraction and permissions');
  finally
    T.Grid.OnSelectionChange := nil;
    Events.Free;
    T.Free;
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
    Check(not Assigned(T.Grid.ActiveEditor), 'Single click unexpectedly opens editor');
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
    Check(T.Grid.Selection.IsCellSelected(1,1), Format('Escape cleared single cell; focus=%d/%d, ranges=%d', [T.Grid.Selection.FocusedCell.RowIndex,
      T.Grid.Selection.FocusedCell.ColumnIndex, T.Grid.Selection.CellRanges.Count]));
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
    Check(not Assigned(T.Grid.ActiveEditor), 'Search opened an editor');

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
    Check(not Assigned(T.Grid.ActiveEditor), 'Boolean focus opened editor');
    Check(T.Controller.GetValue(1,'FLAG').AsBoolean, 'Boolean focus changed value');
    T.Grid.Columns[1].ReadOnly := True;
    T.Grid.Press(vkRight);
    Check(not Assigned(T.Grid.ActiveEditor), 'ImmediateEdit ignored ReadOnly');
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
    Check(Pos('object TScrollBar', TextStream.DataString) = 0, 'Internal scrollbars are persisted in the FMX resource');
    Check(Pos('object TLabel', TextStream.DataString) = 0, 'Internal hint label is persisted in the FMX resource');
    Check(Pos('object Th5uCell', TextStream.DataString) = 0, 'Internal cell editor is persisted in the FMX resource');
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
  Check(G.Customization.ColumnMovingGesture = Th5uColumnRowMovingGesture.Drag, 'Demo header must use normal drag');
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
        E := TEdit(TNativeCustomEditor(G.ActiveEditor).Control);
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
    Check(not (T.Grid.ActiveEditor is TNativeTextEditor) or (T.Grid.ActiveEditor is TNativeDateEditor), 'Text editor used for a date/time cell');
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
              Check(TScrollBar(T.Grid.Components[I]).Max
                > TScrollBar(T.Grid.Components[I]).ViewportSize, 'FMX horizontal scrollbar has no scrollable range');
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
        Check(Probe.Bounds.Left >= T.Grid.RowIndicatorWidth + 90, 'Scrolling cell paints over fixed left column');
        if Scenario = 6 then
          Check(Probe.Bounds.Right <= T.Grid.Width - 180, 'Scrolling cell paints over fixed right column');
      end;
      Check(Probe.Found, 'Clipped first row not painted');
      if Scenario in [2, 3] then
        Check(Probe.Bounds.Height < 80, 'Top row was not actually scrolled beneath the header');
      Center := Point(Round((Probe.Bounds.Left + Probe.Bounds.Right)/2), Round((Probe.Bounds.Top + Probe.Bounds.Bottom)/2));
{$IFDEF TEST_FMX}
      H := T.Grid.GridHitTest(Center.X, Center.Y);
{$ELSE}
      H := T.Grid.HitTest(Center.X, Center.Y);
{$ENDIF}
      Check((Abs(H.Bounds.Left-Probe.Bounds.Left)<1) and (Abs(H.Bounds.Top-Probe.Bounds.Top)<1) and (Abs(H.Bounds.Right-Probe.Bounds.Right)<1)
        and (Abs(H.Bounds.Bottom-Probe.Bounds.Bottom)<1), Format('Paint/hit bounds disagree in clipping scenario %d', [Scenario]));
      Original := T.Controller.GetValue(0,'FLAG').AsBoolean;
      T.Grid.ClickAt(Center);
      Check(T.Controller.GetValue(0,'FLAG').AsBoolean <> Original, Format('Click on visible checkbox failed in clipping scenario %d', [Scenario]));
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
          Check(Difference
            >= 8, Format('Checkbox checkmark invisible: theme %d, selected %s, pixels %d', [Ord(Theme), BoolToStr(Selected, True), Difference]));
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
    Check(G.Customization.ColumnMovingGesture = Th5uColumnRowMovingGesture.Drag, 'Dataset demo requires normal header drag');
    Check(G.HeaderLayout.Enabled and (G.HeaderLayout.RowCount = 2) and (G.HeaderLayout.Cells.Count
      = 13), 'Dataset demo must expose matching grouped headers');
    Check((G.HeaderLayout.Cells[3].ColumnId = 'id') and (G.HeaderLayout.Cells[3].RowSpan = 2), 'Dataset demo ID must span both header rows');
{$IFDEF TEST_FMX}
    D.SeparatorsCheck.IsChecked := False;
{$ELSE}
    D.SeparatorsCheck.Checked := False;
{$ENDIF}
    D.OptionClick(nil);
    Check((G.Spacing.RowSpacing = 0) and (G.Spacing.DefaultColumnRightSpacing = 0), 'Thin separators did not turn off');
    Check(G.Columns.FindById('description').RightSpacing = 8, 'Wide description separator disappeared');
{$IFDEF TEST_FMX}
    D.SeparatorsCheck.IsChecked := True;
{$ELSE}
    D.SeparatorsCheck.Checked := True;
{$ENDIF}
    D.OptionClick(nil);
    Check((G.Spacing.RowSpacing = 1) and (G.Columns.FindById('description').RightSpacing = 8), 'Separator restore failed');
    CheckDemoCheckbox(G);
    E := nil;
    for I := 0 to G.ComponentCount - 1 do
      if G.Components[I] is TEdit then
        E := TEdit(G.Components[I]);

    G.SetFocus;
    G.Press(vkHome, [ssCtrl]);
    G.Press(vkRight);
    G.Press(vkF2);
    E := TEdit(TNativeCustomEditor(G.ActiveEditor).Control);
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
    E := TEdit(TNativeCustomEditor(G.ActiveEditor).Control);
    G.SetFocus;
    Check(not E.Visible, 'Unchanged quantity editor did not close');
    G.Press(vkF2);
    E := TEdit(TNativeCustomEditor(G.ActiveEditor).Control);
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
type
  TNamedEditorProbe = class
  public
    CellName, RowName: string;
    Builds, Shows, Hides, Cancels, Commits, Draws: Integer;
    procedure CellEditor(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var AName: string);
    procedure RowEditor(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var AName: string);
    procedure Build(Sender: TObject; var AControl: TControl);
    procedure Show(Sender: TObject);
    procedure Hide(Sender: TObject);
    procedure Cancel(Sender: TObject);
    procedure Commit(Sender: TObject);
    procedure Draw(Sender: TObject; const AContext: Th5uEditorContext; var AHandled: Boolean);
  end;

procedure TNamedEditorProbe.CellEditor(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var AName: string);
begin
  AName := CellName;
end;

procedure TNamedEditorProbe.RowEditor(Sender: TObject; AColumn: Th5uGridColumn; ARow: Int64; var AName: string);
begin
  AName := RowName;
end;

procedure TNamedEditorProbe.Build(Sender: TObject; var AControl: TControl);
begin
  Inc(Builds);
  AControl := TEdit.Create(Th5uGridEditorItem(Sender).Context.Grid);
end;

procedure TNamedEditorProbe.Show(Sender: TObject);
begin
  Inc(Shows);
end;

procedure TNamedEditorProbe.Hide(Sender: TObject);
begin
  Inc(Hides);
end;

procedure TNamedEditorProbe.Cancel(Sender: TObject);
begin
  Inc(Cancels);
end;

procedure TNamedEditorProbe.Commit(Sender: TObject);
begin
  Inc(Commits);
end;

procedure TNamedEditorProbe.Draw(Sender: TObject; const AContext: Th5uEditorContext; var AHandled: Boolean);
begin
  Inc(Draws);
  Check(Assigned(AContext.Grid) and Assigned(AContext.Column) and Assigned(AContext.Canvas), 'Incomplete editor paint context');
  AHandled := True;
end;

procedure TestNamedEditors;
var
  T: TFixture;
  P: TNamedEditorProbe;
  C, Other, Selector: Th5uGridColumn;
  E, Same, Different: Th5uGridEditorItem;
  Custom, Variant: TNativeCustomEditor;
  G, H: TGridAccess;
  Stream: TMemoryStream;
  EC: Th5uEditorContext;
  B, V: Integer;
  Failed: Boolean;
begin
  P := TNamedEditorProbe.Create;
  T := TFixture.Create(Th5uCacheMode.None);
  try
    C := T.Grid.Columns.FindById('DESCRIPTION');
    Other := T.Grid.Columns.Add;
    Other.Id := 'other'; Other.FieldName := 'DESCRIPTION'; Other.DataType := Th5uColumnDataType.Text;
    Other.Visible := False;
    E := T.Grid.GetCellEditor(C, 0);
    Check(not Assigned(TNativeCustomEditor(E).Control), 'Paint/lookup eagerly built an editor');
    Check(E = T.Grid.GetCellEditor(Other, 0), 'Static default editor not shared across columns');
    Check(E = T.Grid.GetCellEditor(C, 1), 'Default editor not shared across rows');

    C.OnGetCellEditor := P.CellEditor;
    Other.OnGetCellEditor := P.CellEditor;
    P.CellName := 'TextEditor';
    Same := T.Grid.GetCellEditor(C, 0);
    Different := T.Grid.GetCellEditor(Other, 0);
    Check((Same <> E) and (Different <> Same), 'Event editor cache does not include ColumnID');
    Check(Same = T.Grid.GetCellEditor(C, 1), 'Event editor not reused across rows of same column');
    P.CellName := '';
    P.RowName := 'IntegerEditor';
    C.OnGetRowEditor := P.RowEditor;
    Check(T.Grid.GetCellEditor(C, 0).EditorName = 'IntegerEditor', 'Row editor fallback failed');
    P.CellName := 'TextEditor';
    Check(T.Grid.GetCellEditor(C, 0) = Same, 'Cell editor did not override row editor');
    P.CellName := '';
    P.RowName := '';

    Custom := T.Grid.Editors.Add;
    Custom.EditorName := 'SharedCustom';
    Custom.OnBuildEditor := P.Build;
    Custom.OnShow := P.Show; Custom.OnHide := P.Hide;
    Custom.OnCancel := P.Cancel; Custom.OnCommit := P.Commit;
    Custom.OnDrawDisplay := P.Draw;
    C.Editor := Custom.EditorName;
    Other.Editor := C.Editor;
    Check(T.Grid.GetCellEditor(C, 0) = Custom, 'Column editor did not select custom item');
    Check(T.Grid.GetCellEditor(Other, 0) = Custom, 'Static custom editor not shared');
    T.PaintGrid;
    Check((P.Draws > 0) and (P.Builds = 0), 'DrawDisplay did not run without a native editor');
    T.Grid.SetFocus;
    T.Grid.Press(vkHome, [ssCtrl]);
    T.Grid.Press(vkRight);
    T.Grid.Press(vkF2);
    Check((T.Grid.ActiveEditor = Custom) and (P.Builds = 1), 'Custom BuildEditor did not run lazily');
    T.Editor.Text := 'custom commit';
    T.EditorKey(vkReturn);
    Check((P.Commits = 1) and (P.Hides = 1) and (T.Data.FieldByName('DESCRIPTION').AsString = 'custom commit'), 'Custom commit lifecycle failed');
    T.Grid.Press(vkF2);
    T.Editor.Text := 'discard me';
    T.EditorKey(vkEscape);
    Check((P.Builds = 1) and (P.Cancels = 1), 'Cached control was rebuilt or cancel was not forwarded');
    T.Grid.Press(vkF2);
    V := Custom.EditorVersion;
    Custom.EditorVersion := V + 1;
    Check(T.Grid.GetCellEditor(C, 0) = Custom, 'Version change replaced an active editor');
    Check(P.Builds = 1, 'Version rebuilt a live draft');
    T.EditorKey(vkEscape);
    T.Grid.Press(vkF2);
    Check(P.Builds = 2, 'New EditorVersion did not rebuild on next edit');
    T.EditorKey(vkEscape);

    P.CellName := 'SharedCustom';
    Same := T.Grid.GetCellEditor(C, 0);
    Different := T.Grid.GetCellEditor(Other, 0);
    Check((Same <> Custom) and (Different <> Same), 'Custom event editor variants were not separated by ColumnID');
    T.Grid.Press(vkF2);
    B := P.Builds;
    Check(T.Grid.ActiveEditor = Same, 'Scoped editor was not activated');
    T.EditorKey(vkEscape);
    T.Grid.Press(vkF2);
    Check(P.Builds = B, 'Scoped custom control was not cached');
    T.EditorKey(vkEscape);
    Custom.EditorVersion := Custom.EditorVersion + 1;
    T.Grid.Press(vkF2);
    Check(P.Builds = B + 1, 'Template version did not invalidate scoped control');
    T.EditorKey(vkEscape);

    // Native default variants retain their implementation after DFM/FMX streaming.
    G := TGridAccess.Create(nil);
    Stream := TMemoryStream.Create;
    try
      G.Parent := T.Form;
      G.Name := 'VariantGrid';
      Variant := G.Editors.AddVariant('DeliveryDate', 'DateEditor');
      Variant.EditorVersion := 7;
      G.DefaultEditors.Date := Variant.EditorName;
      G.Columns.Add.Id := 'delivery';
      G.Columns[0].DataType := Th5uColumnDataType.Date;
      Stream.WriteComponent(G);
      Stream.Position := 0;
      H := TGridAccess.Create(nil);
      H.Parent := T.Form;
      try
        Stream.ReadComponent(H);
        Check((H.Editors.Count = 1) and (H.Editors[0].EditorType = 'DateEditor') and (H.Editors[0].EditorVersion
          = 7), 'Editor collection did not round-trip');
        Check(H.GetCellEditor(H.Columns[0], 0) is TNativeDateEditor, 'Streamed variant lost its registered editor class');
        Check(not Assigned(TNativeCustomEditor(H.GetCellEditor(H.Columns[0], 0)).Control), 'Streaming constructed native editor controls');
      finally H.Free; end;
    finally
      Stream.Free;
      G.Free;
    end;

    // A row-selected numeric editor converts independently of the common column type.
    EC := Default(Th5uEditorContext);
    EC.Grid := T.Grid; EC.Column := C;
    EC.Value := TValue.From<string>('23'); EC.Text := '23';
    EC.Bounds := RectF(0, 0, 120, 25);
    C.Editor := 'IntegerEditor';
    P.CellName := '';
    E := T.Grid.GetCellEditor(C, 0);
    E.BeginEdit(EC);
    Check(E.GetValue.IsType<Int64> and (E.GetValue.AsInt64 = 23), 'IntegerEditor follows the column text type instead of its own value type');

    // TLabel is a non-windowed VCL TControl; it must support text without unsafe event casts.
    Variant := T.Grid.Editors.Add;
    Variant.EditorName := 'LabelEditor';
    Variant.ControlClass := TLabel;
    EC := Default(Th5uEditorContext);
    EC.Grid := T.Grid; EC.Column := C;
    EC.Value := TValue.From<string>('label'); EC.Text := 'label';
    EC.Bounds := RectF(0, 0, 120, 25);
    Variant.BeginEdit(EC);
    Check(Variant.GetText = 'label', 'Custom TControl text access failed');
    Variant.SetText('second label');
    Check(Variant.GetText = 'second label', 'Custom SetText failed');

    P.CellName := '';
    Variant := T.Grid.Editors.Add;
    Variant.EditorName := 'GraphicEditor';
    Variant.Mode := Th5uEditorMode.Graphic;
    Variant.OnDrawEditor := P.Draw;
    C.Editor := Variant.EditorName;
    T.Grid.Press(vkF2);
    Check((T.Grid.ActiveEditor = Variant) and not Assigned(Variant.Control), 'Graphic editor created a text control');
    B := P.Draws;
    T.PaintGrid;
    Check(P.Draws > B, 'Active graphic editor did not receive DrawEditor');
    T.Grid.SetFocus;
    T.Grid.Press(vkEscape);
    Check(not Assigned(T.Grid.ActiveEditor), 'Graphic editor cancel request ignored');

    // A column containing the editor name is read as data, never recursively resolved.
    P.CellName := ''; P.RowName := 'IntegerEditor';
    Selector := T.Grid.Columns.Add;
    Selector.Id := 'selector'; Selector.FieldName := 'DESCRIPTION'; Selector.Visible := False;
    T.Data.Edit; T.Data.FieldByName('DESCRIPTION').AsString := 'TextEditor'; T.Data.Post;
    C.CellEditorColumnId := Selector.Id;
    Check(T.Grid.GetCellEditor(C, 0).EditorName = 'TextEditor', 'Cell editor column did not precede row event');
    C.CellEditorColumnId := '';
    C.RowEditorColumnId := Selector.Id;
    Check(T.Grid.GetCellEditor(C, 0).EditorName = 'IntegerEditor', 'Row event did not precede row editor column');
    P.RowName := '';
    Check(T.Grid.GetCellEditor(C, 0).EditorName = 'TextEditor', 'Row editor column fallback failed');
    C.RowEditorColumnId := '';
    C.Editor := '';
    T.Grid.DefaultEditors.Edit := 'SharedCustom';
    Check(T.Grid.GetCellEditor(C, 0) = Custom, 'Grid default editor mapping ignored');
    C.Editor := 'None';
    Check(not Assigned(T.Grid.GetCellEditor(C, 0)), 'None editor did not disable editing');
    C.Editor := 'missing editor';
    Failed := False;
    try T.Grid.GetCellEditor(C, 0); except on Eh5uGrid do Failed := True; end;
    Check(Failed, 'Unknown editor silently fell back');
    C.Editor := '';
    T.Grid.ClearEditorCache;
    Check(not Assigned(Custom.Control), 'ClearEditorCache kept a custom control');
    T.Grid.DesignModeForTest(True);
    T.Grid.Press(vkF2);
    Check(not Assigned(T.Grid.ActiveEditor), 'Design mode activated editor');
    T.Grid.DesignModeForTest(False);
    Writeln('PASS: named editors, lazy controls, cache scopes/version, lifecycle, draw and resolution precedence');
  finally
    T.Free;
    P.Free;
  end;
end;


type
  TWidthProbe = class
    Calls: Integer;
    procedure Measure(Sender: TObject; const AContext: Th5uEditorContext; var AWidth: Double);
  end;

procedure TWidthProbe.Measure(Sender: TObject; const AContext: Th5uEditorContext; var AWidth: Double);
begin
  Inc(Calls);
  Check(Assigned(AContext.Canvas) and Assigned(AContext.Grid), 'measurement context lacks canvas or grid');
  Check(AContext.Text <> '', 'measurement context lacks formatted display text');
  AWidth := 170 + AContext.RowIndex * 10;
end;

procedure TestColumnSizing;
var
  T: TFixture;
  C: Th5uGridColumn;
  P: TWidthProbe;
  E, Active: Th5uGridEditorItem;
  Original, Measured, Total, I: Integer;
  G, H: TGridAccess;
  Stream: TMemoryStream;
begin
  T := TFixture.Create(Th5uCacheMode.None);
  P := TWidthProbe.Create;
  try
    C := T.Grid.Columns[1];
    Original := C.Width;
    Measured := T.Grid.MeasureColumnWidth(C);
    Check((Measured > C.MinWidth) and (Measured < Original), 'native text measurement');
    Check(T.Grid.MeasureColumnWidth(T.Grid.Columns[0]) = 25, 'checkbox measurement uses glyph size');
    T.Grid.ClickAt(T.CellPoint('DESCRIPTION'), True);
    Active := T.Grid.ActiveEditor;
    T.Editor.Text := 'Uncommitted measurement draft';
    T.Grid.MeasureColumnWidth(C);
    Check((T.Grid.ActiveEditor = Active) and (T.Editor.Text = 'Uncommitted measurement draft'), 'measurement changed active editor');
    T.EditorKey(vkEscape);
    E := T.Grid.Editors.AddVariant('MeasuredText', 'TextEditor');
    E.OnMeasureWidth := P.Measure;
    C.Editor := E.EditorName;
    C.AutoWidth := True;
    T.Grid.AutoWidthRowLimit := 1;
    T.PaintGrid;
    Check((C.LayoutWidth = 170) and (C.Width = Original), 'automatic measurement limit or stored pixel width');
    T.Grid.AutoWidthRowLimit := 0;
    T.PaintGrid;
    Check(C.LayoutWidth = 190, 'automatic measurement of all rows');
    T.PaintGrid;
    P.Calls := 0;
    T.PaintGrid;
    Check(P.Calls = 0, 'unchanged paint remeasured all content');
    T.Controller.SetValue(0, 'DESCRIPTION', TValue.From<string>('A changed display value'));
    T.PaintGrid;
    Check(P.Calls > 0, 'data changes did not invalidate measured width');
    C.MaxWidth := 180;
    T.PaintGrid;
    Check(C.LayoutWidth = 180, 'auto width ignored column maximum');
    T.Grid.AutoSizeColumn(C, 0, 1);
    Check((C.Width = 170) and not C.AutoWidth and (C.WidthInPercent = 0), 'one-shot auto sizing');
    T.Grid.Columns[0].Width := 80;
    C.Width := 170;
    T.Grid.Columns[2].WidthInPercent := 100;
    T.Grid.MaxWidth := 450;
    T.PaintGrid;
    Total := 0;
    for I := 0 to 2 do Inc(Total, T.Grid.Columns[I].LayoutWidth + T.Grid.Spacing.DefaultColumnRightSpacing);
    Check(Total = 450, 'native grid maximum content width');
    T.Grid.MaxWidth := 0;
    T.Grid.MinWidth := 650;
    T.PaintGrid;
    Total := 0;
    for I := 0 to 2 do Inc(Total, T.Grid.Columns[I].LayoutWidth + T.Grid.Spacing.DefaultColumnRightSpacing);
    Check(Total = 650, 'native grid minimum content width');
    Check(Round(T.Grid.Width) = 600, 'content limits changed control width');
    T.Grid.MinWidth := 0;
    T.Grid.Height := 80;
    T.PaintGrid;
    Check(T.Grid.HeaderBounds(2).Right < Round(T.Grid.Width) - 5, 'percentage layout did not reserve vertical scrollbar');
    T.Grid.Height := 220;
    T.PaintGrid;
    Check(T.Grid.HeaderBounds(2).Right >= Round(T.Grid.Width) - 4, 'percentage layout retained obsolete scrollbar space');
    G := TGridAccess.Create(nil);
    Stream := TMemoryStream.Create;
    try
      G.Parent := T.Form;
      G.Name := 'SizingGrid';
      G.MinWidth := 320; G.MaxWidth := 650; G.AutoWidthRowLimit := 2;
      G.Columns.Add.AutoWidth := True;
      G.Columns.Add.WidthInPercent := 65;
      with G.HeaderLayout.Cells.Add do
      begin
        Width := 300; MinWidth := 200; MaxWidth := 400; WidthInPercent := 80; ColumnSpan := 2;
      end;
      G.HeaderLayout.Enabled := True;
      Stream.WriteComponent(G);
      Stream.Position := 0;
      H := TGridAccess.Create(nil);
      try
        H.Parent := T.Form;
        Stream.ReadComponent(H);
        Check((H.MinWidth = 320) and (H.MaxWidth = 650) and (H.AutoWidthRowLimit = 2), 'grid width properties did not stream');
        Check(H.Columns[0].AutoWidth and (H.Columns[1].WidthInPercent = 65), 'column width modes did not stream');
        Check((H.HeaderLayout.Cells[0].Width = 300) and (H.HeaderLayout.Cells[0].WidthInPercent = 80), 'group budget did not stream');
        Check((H.HeaderLayout.Cells[0].MinWidth = 200) and (H.HeaderLayout.Cells[0].MaxWidth = 400), 'group limits did not stream');
      finally H.Free; end;
    finally
      Stream.Free;
      G.Free;
    end;
    Writeln('PASS: native AutoWidth, editor measurement, limits, invalidation, active draft, scrollbars and sizing streaming');
  finally
    T.Free;
    P.Free;
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
  if ParamStr(1) = '--column-widths' then
  begin
    try
      TestColumnSizing;
    except
      on E: Exception do begin Writeln('FAIL: column sizing: ', E.ClassName, ': ', E.Message); ExitCode := 1; end;
    end;
    if LExceptionSink.Count > 0 then ExitCode := 1;
    Application.OnException := nil;
    LExceptionSink.Free;
    Halt(ExitCode);
  end;
  if ParamStr(1) = '--named-editors' then
  begin
    try
      TestNamedEditors;
    except
      on E: Exception do begin Writeln('FAIL: named editors: ', E.ClassName, ': ', E.Message); ExitCode := 1; end;
    end;
    if LExceptionSink.Count > 0 then ExitCode := 1;
    Application.OnException := nil;
    LExceptionSink.Free;
    Halt(ExitCode);
  end;
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
    TestNamedEditors;
{$IFDEF TEST_FMX}
    TestHorizontalScrollBar;
{$ENDIF}
{$IFDEF TEST_FMX}
    TestMobileInputAndEditors;
{$ENDIF}
    TestColumnSizing;
    TestColumnMovingStreaming;
    TestRightClickSelection;
    TestGroupedHeaderMoving;
{$IFNDEF TEST_FMX}
    TestVclMouseMessages;
    TestVclMoveFeedback;
    TestVclGroupedMoveFeedback;
    TestVclCapturedCursors;
{$ENDIF}
    TestColumnResizing;
    TestResizeHitZones;
    TestLastColumnHitZone;
{$IFDEF TEST_FMX}
    TestTouchHeaders;
    TestHeaderPanFeedback;
    TestTouchBodyAfterResize;
    TestScrolledTextLayout;
{$ENDIF}
    TestMixedSelection;
    TestBlockMoving;
    TestElementStyleAndModes;
    TestCellEvents;
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
