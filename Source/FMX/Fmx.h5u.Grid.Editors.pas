unit Fmx.h5u.Grid.Editors;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes, System.Rtti,
  System.TypInfo, System.Math, System.DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  FMX.Controls, FMX.Types, FMX.Edit, FMX.DateTimeCtrls, FMX.Pickers,
  FMX.StdCtrls, FMX.Graphics, FMX.Objects, FMX.Layouts, FMX.Dialogs;

type
  ThiiCellDateEdit = class(TDateEdit)
  protected
    function GetAdjustType: TAdjustType; override;
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime); override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiCellTimeEdit = class(TTimeEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiCellTextEdit = class(TEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiFmxEditorControlClass = class of TControl;
  ThiiFmxBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiFmxCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiFmxEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiFmxBuildEditorEvent;
    FBackground: TRectangle;
    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiFmxEditorControlClass);
    procedure ControlChanged(Sender: TObject);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  protected
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiFmxEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure UpdateBounds(const ABounds: TRectF); override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: ThiiFmxEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to DFM/FMX streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiFmxBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiFmxTextEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiFmxIntegerEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxFloatEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxCurrencyEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxDateEditor = class(ThiiFmxTextEditor)
  protected
    function DefaultControlClass: ThiiFmxEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiFmxTimeEditor = class(ThiiFmxDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiFmxDateTimeEditor = class(ThiiFmxDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiFmxCheckBoxEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiFmxImageCellEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  private
    procedure ImageCommit(Sender: TObject);
    procedure ImageCancel(Sender: TObject);
  protected
    function DefaultControlClass: ThiiFmxEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiFmxGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiFmxCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiFmxCustomEditor;
    function AddVariant(const AName, AType: string): ThiiFmxCustomEditor;
    property Items[AIndex: Integer]: ThiiFmxCustomEditor read GetItem; default;
  end;

  Th5uFmxImageEditor = class(TLayout)
  private
    FImage: TImage;
    FToolBar: TLayout;
    FLoadButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    FOnCommit: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure LoadClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    property Bytes: TBytes read FBytes write SetBytes;
    property OnCommit: TNotifyEvent read FOnCommit write FOnCommit;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
  end;

implementation

type
  TControlAccess = class(TControl);
  TEditAccess = class(TEdit);

constructor ThiiFmxGridEditors.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiFmxCustomEditor);
end;

function ThiiFmxGridEditors.Add: ThiiFmxCustomEditor;
begin
  Result := ThiiFmxCustomEditor(inherited Add);
end;

function ThiiFmxGridEditors.AddVariant(const AName, AType: string): ThiiFmxCustomEditor;
begin
  Result := Add;
  try
    Result.EditorName := AName;
    Result.EditorType := AType;
  except
    Result.Free;
    raise;
  end;
end;

procedure ThiiFmxCustomEditor.SetEditorType(const AValue: string);
var
  E: ThiiGridEditorItem;
begin
  if EditorType = AValue then
    Exit;
  if AValue <> '' then
  begin
    E := h5uCreateEditor(ThiiEditorPlatform.FMX, AValue, nil);
    try
      Mode := E.Mode;
      ActivateOnClick := E.ActivateOnClick;
    finally
      E.Free;
    end;
  end;
  inherited;
end;

function ThiiFmxGridEditors.GetItem(AIndex: Integer): ThiiFmxCustomEditor;
begin
  Result := ThiiFmxCustomEditor(inherited Items[AIndex]);
end;

constructor ThiiFmxCustomEditor.Create(Collection: TCollection);
begin
  inherited;
  FControlVersion := -1;
end;

destructor ThiiFmxCustomEditor.Destroy;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
  inherited;
end;

procedure ThiiFmxCustomEditor.Assign(Source: TPersistent);
begin
  if Active then
    raise EhiiGrid.Create('Ein aktiver Editor kann nicht ersetzt werden.');
  inherited;
  if Source is ThiiFmxCustomEditor then
  begin
    ReleaseControl;
    FControlClass := ThiiFmxCustomEditor(Source).FControlClass;
    FOnBuildEditor := ThiiFmxCustomEditor(Source).FOnBuildEditor;
  end;
end;

procedure ThiiFmxCustomEditor.ReleaseControl;
begin
  // Detach callbacks before destroying a focused native control.
  if Assigned(FControl) then
  begin
    TControlAccess(FControl).OnExit := nil;
    FreeAndNil(FControl);
  end;
  FreeAndNil(FBackground);
  FControlVersion := -1;
end;

procedure ThiiFmxCustomEditor.ReleaseEditor;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
end;

function ThiiFmxCustomEditor.GetControlClassName: string;
begin
  Result := '';
  if Assigned(FControlClass) then
    Result := FControlClass.ClassName;
end;

procedure ThiiFmxCustomEditor.SetControlClassName(const AValue: string);
var
  C: TPersistentClass;
begin
  if AValue = '' then
  begin
    SetControlClass(nil);
    Exit;
  end;
  C := GetClass(AValue);
  if not Assigned(C) or not C.InheritsFrom(TControl) then
    raise EhiiGrid.CreateFmt('Control-Klasse "%s" ist nicht registriert.', [AValue]);
  SetControlClass(ThiiFmxEditorControlClass(C));
end;

procedure ThiiFmxCustomEditor.SetControlClass(AValue: ThiiFmxEditorControlClass);
begin
  if FControlClass = AValue then
    Exit;
  FControlClass := AValue;
  EditorVersion := EditorVersion + 1;
end;

function ThiiFmxCustomEditor.DefaultControlClass: ThiiFmxEditorControlClass;
begin
  if Mode = ThiiEditorMode.Text then
    Result := ThiiCellTextEdit
  else
    Result := nil;
end;

procedure ThiiFmxCustomEditor.BuildEditor;
var
  C: ThiiFmxEditorControlClass;
begin
  if not Assigned(Context.Grid) or (csDesigning in Context.Grid.ComponentState) then
    Exit;
  if FControlVersion = EditorVersion then
    Exit;
  if Active then
    Exit;
  ReleaseControl;
  C := FControlClass;
  if not Assigned(C) then
    C := DefaultControlClass;
  try
    if Assigned(FOnBuildEditor) then
      FOnBuildEditor(Self, FControl);
    if not Assigned(FControl) and Assigned(C) then
      FControl := C.Create(Context.Grid);
    if Assigned(FControl) then
    begin
      FControl.Visible := False;
      FControl.Stored := False;
      FControl.Parent := TControl(Context.Grid);
      ConfigureControl;
    end;
    FControlVersion := EditorVersion;
  except
    ReleaseControl;
    raise;
  end;
end;

procedure ThiiFmxCustomEditor.ConfigureControl;
var
  P: PPropInfo;
  M: TMethod;
  N: TNotifyEvent;
begin
  if Control is TEdit then
    TEdit(Control).StyledSettings := TEdit(Control).StyledSettings - [TStyledSetting.FontColor];
  if Control is TCustomEdit then
    TEditAccess(Control).OnChange := ControlChanged;
  // Use RTTI for published OnChange on arbitrary controls. Never assume TEdit layout.
  P := GetPropInfo(Control.ClassInfo, 'OnChange');
  if Assigned(P) and (P.PropType^.Kind = tkMethod) then
  begin
    N := ControlChanged;
    M := TMethod(N);
    if P.PropType^ = TypeInfo(TNotifyEvent) then
      SetMethodProp(Control, P, M);
  end;

  TControlAccess(Control).OnEnter := ControlEnter;
  TControlAccess(Control).OnExit := ControlExit;
  TControlAccess(Control).OnKeyDown := ControlKeyDown;
  TControlAccess(Control).OnMouseDown := ControlMouseDown;
  TControlAccess(Control).OnMouseMove := ControlMouseMove;
  TControlAccess(Control).OnMouseUp := ControlMouseUp;
end;

procedure ThiiFmxCustomEditor.ControlChanged(Sender: TObject);
begin
  Change;
end;

procedure ThiiFmxCustomEditor.ControlEnter(Sender: TObject);
begin
  Enter;
end;

procedure ThiiFmxCustomEditor.ControlExit(Sender: TObject);
begin
  if not DeferExit then
    ExitEditor;
end;

procedure ThiiFmxCustomEditor.ControlKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  KeyDown(Key, KeyChar, Shift);
end;

procedure ThiiFmxCustomEditor.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  MouseDown(Button, Shift, PointF(X, Y));
end;

procedure ThiiFmxCustomEditor.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  MouseMove(Shift, PointF(X, Y));
end;

procedure ThiiFmxCustomEditor.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  MouseUp(Button, Shift, PointF(X, Y));
end;

function ThiiFmxCustomEditor.ReadText: string;
begin
  if Assigned(Control) and IsPublishedProp(Control, 'Text') then
    Result := GetStrProp(Control, 'Text')
  else
    Result := inherited;
end;

procedure ThiiFmxCustomEditor.WriteText(const AText: string);
begin
  inherited;
  if Assigned(Control) and IsPublishedProp(Control, 'Text') then
    SetStrProp(Control, 'Text', AText);
end;

procedure ThiiFmxCustomEditor.UpdateBounds(const ABounds: TRectF);
begin
  inherited;
  // Graphic editors may use a separate popup instead of the cell rectangle.
  if Mode <> ThiiEditorMode.Text then
    Exit;
  if Assigned(Control) then
    Control.SetBounds(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  if Assigned(FBackground) then
    FBackground.SetBounds(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
end;

procedure ThiiFmxCustomEditor.Show;
begin
  if Assigned(Control) then
  begin
    Control.SetBounds(Context.Bounds.Left, Context.Bounds.Top, Context.Bounds.Width, Context.Bounds.Height);
    if not Assigned(FBackground) then
    begin
      FBackground := TRectangle.Create(Context.Grid);
      FBackground.Stored := False;
      FBackground.Parent := TControl(Context.Grid);
      FBackground.HitTest := False;
      FBackground.Stroke.Kind := TBrushKind.None;
    end;
    FBackground.SetBounds(Context.Bounds.Left, Context.Bounds.Top, Context.Bounds.Width, Context.Bounds.Height);
    FBackground.Fill.Color := Context.Background or $FF000000;
    FBackground.Visible := True;
    FBackground.BringToFront;
    if Control is TEdit then
      TEdit(Control).TextSettings.FontColor := Context.Foreground;
    if Control is TCustomDateTimeEdit then
    begin
      TCustomDateTimeEdit(Control).StyledSettings := TCustomDateTimeEdit(Control).StyledSettings - [TStyledSetting.FontColor];
      TCustomDateTimeEdit(Control).TextSettings.FontColor := Context.Foreground;
    end;
    Control.Visible := True;
    BringToFront;
  end;
  inherited;
  Focus;
  if Control is TEdit then
    TEdit(Control).SelectAll;
end;

procedure ThiiFmxCustomEditor.Hide;
begin
  inherited;
  if Assigned(Control) then
    Control.Visible := False;
  if Assigned(FBackground) then
    FBackground.Visible := False;
end;

procedure ThiiFmxCustomEditor.Focus;
begin
  if Assigned(Control) and Control.CanFocus then
    Control.SetFocus;
end;

procedure ThiiFmxCustomEditor.BringToFront;
begin
  if Assigned(Control) then
    Control.BringToFront;
end;

function ThiiFmxIntegerEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Integer, GetText);
end;

function ThiiFmxFloatEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Float, GetText);
end;

function ThiiFmxCurrencyEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Currency, GetText);
end;

function ThiiFmxDateEditor.DefaultControlClass: ThiiFmxEditorControlClass;
begin
  if DateKind = ThiiColumnEditorKind.Time then
    Result := ThiiCellTimeEdit
  else
    Result := ThiiCellDateEdit;
end;

function ThiiFmxDateEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Date;
end;

function ThiiFmxTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Time;
end;

function ThiiFmxDateTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.DateTime;
end;

procedure ThiiFmxDateEditor.ConfigureControl;
var
  E: TCustomDateTimeEdit;
begin
  if not (Control is TCustomDateTimeEdit) then
    raise EhiiGrid.Create('Der Datumseditor benötigt ein TCustomDateTimeEdit-Control.');
  inherited;
  E := TCustomDateTimeEdit(Control);
  E.ShowClearButton := True;
  if E is TTimeEdit then
    TTimeEdit(E).UseNowTime := False;
  if E is TDateEdit then
    TDateEdit(E).TodayDefault := False;
  case DateKind of
    ThiiColumnEditorKind.Time:
      E.Format := 'hh:nn:ss';
    ThiiColumnEditorKind.DateTime:
      E.Format := 'dd.mm.yyyy hh:nn:ss';
    else
      E.Format := 'dd.mm.yyyy';
  end;
end;

function ThiiFmxDateEditor.ReadValue: TValue;
var
  D: TDateTime;
  E: TCustomDateTimeEdit;
begin
  E := TCustomDateTimeEdit(Control);
  if E.IsEmpty then
    Exit(TValue.Empty);
  D := E.DateTime;
  case DateKind of
    ThiiColumnEditorKind.Date: D := DateOf(D);
    ThiiColumnEditorKind.Time: D := TimeOf(D);
  end;
  Result := TValue.From<TDateTime>(D);
end;

procedure ThiiFmxDateEditor.WriteValue(const AValue: TValue);
var
  E: TCustomDateTimeEdit;
begin
  E := TCustomDateTimeEdit(Control);
  if AValue.IsEmpty then
    E.DateTime := Now
  else
    E.DateTime := AValue.AsType<TDateTime>;
  E.IsEmpty := AValue.IsEmpty;
end;

function ThiiFmxDateEditor.State: string;
begin
  Result := BoolToStr(TCustomDateTimeEdit(Control).IsEmpty, True) + ':' + FloatToStr(TCustomDateTimeEdit(Control).DateTime,
    TFormatSettings.Invariant);
end;

function ThiiFmxDateEditor.UsesTextValue: Boolean;
begin
  Result := False;
end;

function ThiiFmxDateEditor.DeferExit: Boolean;
begin
  Result := Assigned(Control) and TCustomDateTimeEdit(Control).IsPickerOpened;
end;

constructor ThiiFmxCheckBoxEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := ThiiEditorMode.Graphic;
  ActivateOnClick := True;
end;

procedure ThiiFmxCheckBoxEditor.Activate;
var
  V: TValue;
begin
  inherited;
  V := GetValue;
  SetValue(TValue.From<Boolean>(V.IsEmpty or not SameText(V.ToString, 'True') and (V.ToString <> '1')));
  Change;
  RequestCommit;
end;

function ThiiFmxCheckBoxEditor.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  Result := h5uEditorCheckBounds(ABounds).Contains(APoint);
end;

constructor ThiiFmxImageCellEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := ThiiEditorMode.Graphic;
end;

function ThiiFmxImageCellEditor.DefaultControlClass: ThiiFmxEditorControlClass;
begin
  Result := Th5uFmxImageEditor;
end;

procedure ThiiFmxImageCellEditor.ConfigureControl;
begin
  if not (Control is Th5uFmxImageEditor) then
    raise EhiiGrid.Create('Der Bildeditor benötigt ein Th5uFmxImageEditor-Control.');
  inherited;
  Th5uFmxImageEditor(Control).OnCommit := ImageCommit;
  Th5uFmxImageEditor(Control).OnCancel := ImageCancel;
end;

function ThiiFmxImageCellEditor.ReadValue: TValue;
begin
  Result := TValue.From<TBytes>(Th5uFmxImageEditor(Control).Bytes);
end;

procedure ThiiFmxImageCellEditor.WriteValue(const AValue: TValue);
begin
  if AValue.IsType<TBytes> then
    Th5uFmxImageEditor(Control).Bytes := AValue.AsType<TBytes>
  else
    Th5uFmxImageEditor(Control).Bytes := nil;
end;

function ThiiFmxImageCellEditor.Modified: Boolean;
begin
  // An explicit OK accepts the image even when the TValue is a byte array.
  Result := True;
end;

procedure ThiiFmxImageCellEditor.Activate;

begin
  inherited;
  Control.SetBounds(Max(4, (TControl(Context.Grid).Width - 420) / 2), Max(4, (TControl(Context.Grid).Height - 300) / 2),
    Min(420, TControl(Context.Grid).Width - 8), Min(300, TControl(Context.Grid).Height - 8));
end;

procedure ThiiFmxImageCellEditor.ImageCommit(Sender: TObject);
begin
  RequestCommit;
end;

procedure ThiiFmxImageCellEditor.ImageCancel(Sender: TObject);
begin
  RequestCancel;
end;

function ThiiFmxTextEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
var
  LLine: string;
begin
  if not (AContext.Canvas is TCanvas) then
    Exit(-1);
  Result := 0;
  for LLine in AContext.Text.Replace(#13, '').Split([#10]) do
    Result := Max(Result, TCanvas(AContext.Canvas).TextWidth(LLine));
  Result := Result + 10;
end;

function ThiiFmxCheckBoxEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
begin
  Result := 25;
end;

function ThiiFmxImageCellEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
var
  B: TBitmap;
  S: TBytesStream;
begin
  Result := 8;
  if AContext.Image is TBitmap then
    Exit(TBitmap(AContext.Image).Width + 8);
  if not AContext.Value.IsType<TBytes> then
    Exit;
  if Length(AContext.Value.AsType<TBytes>) = 0 then
    Exit;
  B := TBitmap.Create;
  S := TBytesStream.Create(AContext.Value.AsType<TBytes>);
  try
    try
      B.LoadFromStream(S);
      Result := B.Width + 8;
    except
      Result := 8;
    end;
  finally
    S.Free;
    B.Free;
  end;
end;

function ThiiFmxTextEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: ThiiGridColumn;
  LTextRect: TRectF;
  LAlign: TTextAlign;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
  LTextRect := AContext.Bounds;
  LTextRect.Inflate(-5, -2);
  ACanvas.Fill.Color := AContext.Foreground;

  LAlign := TTextAlign.Leading;
  if LColumn.DataType in [ThiiColumnDataType.Integer, ThiiColumnDataType.Float, ThiiColumnDataType.Currency] then
    LAlign := TTextAlign.Trailing;

  AContext.PreparePaint(ThiiElementPaintPart.Text);

  ACanvas.FillText(LTextRect, AContext.Text, LColumn.WordWrap, 1, [], LAlign, TTextAlign.Center);
  Result := True;
end;

function ThiiFmxCheckBoxEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LCheckRect: TRectF;
  LChecked: Boolean;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LCheckRect := h5uEditorCheckBounds(AContext.Bounds);
  LChecked := False;
  if not AContext.Value.IsEmpty then
    if AContext.Value.Kind = tkEnumeration then
      LChecked := AContext.Value.AsBoolean
    else
      LChecked := SameText(AContext.Value.ToString, 'True') or (AContext.Value.ToString = '1');

  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Dash := TStrokeDash.Solid;
  ACanvas.Stroke.Thickness := 1;
  ACanvas.Stroke.Color := AContext.Foreground;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := AContext.Background;
  AContext.PreparePaint(ThiiElementPaintPart.Background);
  ACanvas.FillRect(LCheckRect, 2, 2, AllCorners, 1);
  AContext.PreparePaint(ThiiElementPaintPart.Glyph);
  ACanvas.DrawRect(LCheckRect, 2, 2, AllCorners, 1);
  if LChecked then
  begin
    ACanvas.Stroke.Color := AContext.Foreground;
    ACanvas.Stroke.Thickness := 2;
    AContext.PreparePaint(ThiiElementPaintPart.Glyph);
    ACanvas.DrawLine(PointF(LCheckRect.Left + 3, LCheckRect.Top + 8), PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), 1);
    AContext.PreparePaint(ThiiElementPaintPart.Glyph);
    ACanvas.DrawLine(PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), PointF(LCheckRect.Right - 2, LCheckRect.Top + 3), 1);
    ACanvas.Stroke.Thickness := 1;
  end;
  Result := True;
end;

function ThiiFmxImageCellEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: ThiiGridColumn;
  LDest: TRectF;
  LScale, LWidth, LHeight: Single;
  FBitmap: TBitmap;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
  FBitmap := TBitmap(AContext.Image);
  if Assigned(FBitmap) and not FBitmap.IsEmpty then
  begin
    LDest := AContext.Bounds;
    LDest.Inflate(-4, -4);
    if LColumn.ImagePreserveAspectRatio then
    begin
      LScale := Min(LDest.Width / FBitmap.Width, LDest.Height / FBitmap.Height);
      LWidth := FBitmap.Width * LScale;
      LHeight := FBitmap.Height * LScale;
      LDest := RectF(LDest.Left + (LDest.Width - LWidth) / 2, LDest.Top + (LDest.Height - LHeight) / 2,
        LDest.Left + (LDest.Width - LWidth) / 2 + LWidth, LDest.Top + (LDest.Height - LHeight) / 2 + LHeight);
    end;
    ACanvas.DrawBitmap(FBitmap, RectF(0, 0, FBitmap.Width, FBitmap.Height), LDest, 1, True);
  end;
  Result := True;
end;

procedure ThiiCellDateEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;

function ThiiCellDateEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

procedure ThiiCellDateEdit.HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime);
begin
  // The calendar picks a date, not a new time. Keep the time component when
  // this control is used for a combined date/time cell.
  inherited HandlerPickerDateTimeChanged(Sender, DateOf(ADate) + TimeOf(DateTime));
end;

procedure ThiiCellTimeEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;

function ThiiCellTimeEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

procedure ThiiCellTextEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;

function ThiiCellTextEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

{ Th5uFmxImageEditor }

procedure Th5uFmxImageEditor.CancelClick(Sender: TObject);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;

procedure Th5uFmxImageEditor.ClearClick(Sender: TObject);
begin
  FBytes := nil;
  FImage.Bitmap.SetSize(0, 0);
end;

constructor Th5uFmxImageEditor.Create(AOwner: TComponent);
begin
  inherited;
  Width := 420;
  Height := 300;
  ClipChildren := True;

  FToolBar := TLayout.Create(Self);
  FToolBar.Parent := Self;
  FToolBar.Align := TAlignLayout.Bottom;
  FToolBar.Height := 42;

  FLoadButton := TButton.Create(Self);
  FLoadButton.Parent := FToolBar;
  FLoadButton.Position.Point := PointF(6, 6);
  FLoadButton.Size.Size := TSizeF.Create(82, 30);
  FLoadButton.Text := 'Laden ...';
  FLoadButton.OnClick := LoadClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FToolBar;
  FClearButton.Position.Point := PointF(94, 6);
  FClearButton.Size.Size := TSizeF.Create(82, 30);
  FClearButton.Text := 'Löschen';
  FClearButton.OnClick := ClearClick;

  FOkButton := TButton.Create(Self);
  FOkButton.Parent := FToolBar;
  FOkButton.Align := TAlignLayout.Right;
  FOkButton.Width := 82;
  FOkButton.Margins.Rect := RectF(4, 6, 6, 6);
  FOkButton.Text := 'OK';
  FOkButton.OnClick := OkClick;

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := FToolBar;
  FCancelButton.Align := TAlignLayout.Right;
  FCancelButton.Width := 92;
  FCancelButton.Margins.Rect := RectF(4, 6, 0, 6);
  FCancelButton.Text := 'Abbrechen';
  FCancelButton.OnClick := CancelClick;

  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FImage.Align := TAlignLayout.Client;
  FImage.WrapMode := TImageWrapMode.Fit;
end;

procedure Th5uFmxImageEditor.LoadClick(Sender: TObject);
var
  LDialog: TOpenDialog;
  LStream: TFileStream;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    LDialog.Filter := 'Bilder|*.png;*.jpg;*.jpeg;*.bmp;*.gif|' + 'Alle Dateien|*.*';
    if not LDialog.Execute then
      Exit;

    LStream := TFileStream.Create(LDialog.FileName, fmOpenRead or fmShareDenyWrite);
    try
      SetLength(FBytes, LStream.Size);
      if LStream.Size > 0 then
        LStream.ReadBuffer(FBytes[0], LStream.Size);
    finally
      LStream.Free;
    end;
    UpdatePreview;
  finally
    LDialog.Free;
  end;
end;

procedure Th5uFmxImageEditor.OkClick(Sender: TObject);
begin
  if Assigned(FOnCommit) then
    FOnCommit(Self);
end;

procedure Th5uFmxImageEditor.SetBytes(const AValue: TBytes);
begin
  FBytes := Copy(AValue);
  UpdatePreview;
end;

procedure Th5uFmxImageEditor.UpdatePreview;
var
  LStream: TBytesStream;
begin
  FImage.Bitmap.SetSize(0, 0);
  if Length(FBytes) = 0 then
    Exit;

  LStream := TBytesStream.Create(FBytes);
  try
    try
      FImage.Bitmap.LoadFromStream(LStream);
    except
      FImage.Bitmap.SetSize(0, 0);
    end;
  finally
    LStream.Free;
  end;
end;

initialization
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'TextEditor', ThiiFmxTextEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'IntegerEditor', ThiiFmxIntegerEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'FloatEditor', ThiiFmxFloatEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'CurrencyEditor', ThiiFmxCurrencyEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'DateEditor', ThiiFmxDateEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'TimeEditor', ThiiFmxTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'DateTimeEditor', ThiiFmxDateTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'CheckBoxEditor', ThiiFmxCheckBoxEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'ImageEditor', ThiiFmxImageCellEditor);
  h5uRegisterEditor(ThiiEditorPlatform.FMX, 'CustomEditor', ThiiFmxCustomEditor);

finalization
  // The shared core can remain loaded after this framework package is unloaded.
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'TextEditor', ThiiFmxTextEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'IntegerEditor', ThiiFmxIntegerEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'FloatEditor', ThiiFmxFloatEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'CurrencyEditor', ThiiFmxCurrencyEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'DateEditor', ThiiFmxDateEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'TimeEditor', ThiiFmxTimeEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'DateTimeEditor', ThiiFmxDateTimeEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'CheckBoxEditor', ThiiFmxCheckBoxEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'ImageEditor', ThiiFmxImageCellEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.FMX, 'CustomEditor', ThiiFmxCustomEditor);

end.
