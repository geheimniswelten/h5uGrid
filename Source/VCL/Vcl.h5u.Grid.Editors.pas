unit Vcl.h5u.Grid.Editors;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes, System.Rtti,
  System.TypInfo, System.Math, System.DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  Winapi.Windows, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.Clipbrd, Vcl.Dialogs;

type
  ThiiVclEditorControlClass = class of TControl;
  ThiiVclBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiVclCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiVclEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiVclBuildEditorEvent;

    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiVclEditorControlClass);
    procedure ControlChanged(Sender: TObject);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiVclEditorControlClass; virtual;
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
    property ControlClass: ThiiVclEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to DFM/FMX streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiVclBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiVclTextEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiVclIntegerEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclFloatEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclCurrencyEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclDateEditor = class(ThiiVclTextEditor)
  protected
    function DefaultControlClass: ThiiVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiVclTimeEditor = class(ThiiVclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiVclDateTimeEditor = class(ThiiVclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiVclCheckBoxEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiVclImageCellEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  protected
    function DefaultControlClass: ThiiVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiVclGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiVclCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiVclCustomEditor;
    function AddVariant(const AName, AType: string): ThiiVclCustomEditor;
    property Items[AIndex: Integer]: ThiiVclCustomEditor read GetItem; default;
  end;

  Th5uVclImageEditForm = class(TForm)
  private
    FImage: TImage;
    FButtonPanel: TPanel;
    FLoadButton: TButton;
    FPasteButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    procedure LoadClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    class function Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
  end;

implementation

type
  TControlAccess = class(TControl);
  TWinControlAccess = class(TWinControl);
  TEditAccess = class(TEdit);

constructor ThiiVclGridEditors.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiVclCustomEditor);
end;

function ThiiVclGridEditors.Add: ThiiVclCustomEditor;
begin
  Result := ThiiVclCustomEditor(inherited Add);
end;

function ThiiVclGridEditors.AddVariant(const AName, AType: string): ThiiVclCustomEditor;
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

procedure ThiiVclCustomEditor.SetEditorType(const AValue: string);
var
  E: ThiiGridEditorItem;
begin
  if EditorType = AValue then
    Exit;
  if AValue <> '' then
  begin
    E := h5uCreateEditor(ThiiEditorPlatform.VCL, AValue, nil);
    try
      Mode := E.Mode;
      ActivateOnClick := E.ActivateOnClick;
    finally
      E.Free;
    end;
  end;
  inherited;
end;

function ThiiVclGridEditors.GetItem(AIndex: Integer): ThiiVclCustomEditor;
begin
  Result := ThiiVclCustomEditor(inherited Items[AIndex]);
end;

constructor ThiiVclCustomEditor.Create(Collection: TCollection);
begin
  inherited;
  FControlVersion := -1;
end;

destructor ThiiVclCustomEditor.Destroy;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
  inherited;
end;

procedure ThiiVclCustomEditor.Assign(Source: TPersistent);
begin
  if Active then
    raise EhiiGrid.Create('Ein aktiver Editor kann nicht ersetzt werden.');
  inherited;
  if Source is ThiiVclCustomEditor then
  begin
    ReleaseControl;
    FControlClass := ThiiVclCustomEditor(Source).FControlClass;
    FOnBuildEditor := ThiiVclCustomEditor(Source).FOnBuildEditor;
  end;
end;

procedure ThiiVclCustomEditor.ReleaseControl;
begin
  // Detach callbacks before destroying a focused native control.
  if Assigned(FControl) then
  begin
    if FControl is TWinControl then
      TWinControlAccess(FControl).OnExit := nil;
    FreeAndNil(FControl);
  end;

  FControlVersion := -1;
end;

procedure ThiiVclCustomEditor.ReleaseEditor;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
end;

function ThiiVclCustomEditor.GetControlClassName: string;
begin
  Result := '';
  if Assigned(FControlClass) then
    Result := FControlClass.ClassName;
end;

procedure ThiiVclCustomEditor.SetControlClassName(const AValue: string);
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
  SetControlClass(ThiiVclEditorControlClass(C));
end;

procedure ThiiVclCustomEditor.SetControlClass(AValue: ThiiVclEditorControlClass);
begin
  if FControlClass = AValue then
    Exit;
  FControlClass := AValue;
  EditorVersion := EditorVersion + 1;
end;

function ThiiVclCustomEditor.DefaultControlClass: ThiiVclEditorControlClass;
begin
  if Mode = ThiiEditorMode.Text then
    Result := TEdit
  else
    Result := nil;
end;

procedure ThiiVclCustomEditor.BuildEditor;
var
  C: ThiiVclEditorControlClass;
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

      FControl.Parent := TWinControl(Context.Grid);
      ConfigureControl;
    end;
    FControlVersion := EditorVersion;
  except
    ReleaseControl;
    raise;
  end;
end;

procedure ThiiVclCustomEditor.ConfigureControl;
var
  P: PPropInfo;
  M: TMethod;
  N: TNotifyEvent;
begin
  if Control is TEdit then
    TEdit(Control).AutoSize := False;
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
  if Control is TWinControl then
  begin
    TWinControlAccess(Control).OnEnter := ControlEnter;
    TWinControlAccess(Control).OnExit := ControlExit;
    TWinControlAccess(Control).OnKeyDown := ControlKeyDown;
  end;
  TControlAccess(Control).OnMouseDown := ControlMouseDown;
  TControlAccess(Control).OnMouseMove := ControlMouseMove;
  TControlAccess(Control).OnMouseUp := ControlMouseUp;
end;

procedure ThiiVclCustomEditor.ControlChanged(Sender: TObject);
begin
  Change;
end;

procedure ThiiVclCustomEditor.ControlEnter(Sender: TObject);
begin
  Enter;
end;

procedure ThiiVclCustomEditor.ControlExit(Sender: TObject);
begin
  if not DeferExit then
    ExitEditor;
end;

procedure ThiiVclCustomEditor.ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  C: Char;
begin
  C := #0;
  KeyDown(Key, C, Shift);
end;

procedure ThiiVclCustomEditor.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, PointF(X, Y));
end;

procedure ThiiVclCustomEditor.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, PointF(X, Y));
end;

procedure ThiiVclCustomEditor.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, PointF(X, Y));
end;

function ThiiVclCustomEditor.ReadText: string;
begin
  if Assigned(Control) then
    Result := TControlAccess(Control).Text
  else
    Result := inherited;
end;

procedure ThiiVclCustomEditor.WriteText(const AText: string);
begin
  inherited;
  if Assigned(Control) then
    TControlAccess(Control).Text := AText;
end;

procedure ThiiVclCustomEditor.UpdateBounds(const ABounds: TRectF);
begin
  inherited;
  // Graphic editors may use a separate popup instead of the cell rectangle.
  if Mode <> ThiiEditorMode.Text then
    Exit;
  if Assigned(Control) then
    Control.SetBounds(Round(ABounds.Left), Round(ABounds.Top), Round(ABounds.Width), Round(ABounds.Height));
end;

procedure ThiiVclCustomEditor.Show;
begin
  if Assigned(Control) then
  begin
    Control.SetBounds(Round(Context.Bounds.Left), Round(Context.Bounds.Top), Round(Context.Bounds.Width), Round(Context.Bounds.Height));


    Control.Visible := True;
    BringToFront;
  end;
  inherited;
  Focus;
  if Control is TEdit then
    TEdit(Control).SelectAll;
end;

procedure ThiiVclCustomEditor.Hide;
begin
  inherited;
  if Assigned(Control) then
    Control.Visible := False;
end;

procedure ThiiVclCustomEditor.Focus;
begin
  if (Control is TWinControl) and TWinControl(Control).CanFocus then
    TWinControl(Control).SetFocus;
end;

procedure ThiiVclCustomEditor.BringToFront;
begin
  if Assigned(Control) then
    Control.BringToFront;
end;

function ThiiVclIntegerEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Integer, GetText);
end;

function ThiiVclFloatEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Float, GetText);
end;

function ThiiVclCurrencyEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Currency, GetText);
end;

function ThiiVclDateEditor.DefaultControlClass: ThiiVclEditorControlClass;
begin
  Result := TDateTimePicker;
end;

function ThiiVclDateEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Date;
end;

function ThiiVclTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Time;
end;

function ThiiVclDateTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.DateTime;
end;

procedure ThiiVclDateEditor.ConfigureControl;
var
  E: TDateTimePicker;
begin
  if not (Control is TDateTimePicker) then
    raise EhiiGrid.Create('Der Datumseditor benötigt ein TDateTimePicker-Control.');
  inherited;
  E := TDateTimePicker(Control);
  E.ShowCheckbox := True;
  if DateKind = ThiiColumnEditorKind.Time then
    E.Kind := dtkTime
  else
    E.Kind := dtkDate;
  case DateKind of
    ThiiColumnEditorKind.Time:
      E.Format := 'HH:mm:ss';
    ThiiColumnEditorKind.DateTime:
      E.Format := 'dd.MM.yyyy HH:mm:ss';
    else
      E.Format := 'dd.MM.yyyy';
  end;
end;

function ThiiVclDateEditor.ReadValue: TValue;
var
  D: TDateTime;
  E: TDateTimePicker;
begin
  E := TDateTimePicker(Control);
  if not E.Checked then
    Exit(TValue.Empty);
  D := E.DateTime;
  case DateKind of
    ThiiColumnEditorKind.Date: D := DateOf(D);
    ThiiColumnEditorKind.Time: D := TimeOf(D);
  end;
  Result := TValue.From<TDateTime>(D);
end;

procedure ThiiVclDateEditor.WriteValue(const AValue: TValue);
var
  E: TDateTimePicker;
begin
  E := TDateTimePicker(Control);
  if AValue.IsEmpty then
    E.DateTime := Now
  else
    E.DateTime := AValue.AsType<TDateTime>;
  E.Checked := not AValue.IsEmpty;
end;

function ThiiVclDateEditor.State: string;
begin
  Result := BoolToStr(TDateTimePicker(Control).Checked, True) + ':' + FloatToStr(TDateTimePicker(Control).DateTime, TFormatSettings.Invariant);
end;

function ThiiVclDateEditor.UsesTextValue: Boolean;
begin
  Result := False;
end;

function ThiiVclDateEditor.DeferExit: Boolean;
begin
  Result := False;
end;

constructor ThiiVclCheckBoxEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := ThiiEditorMode.Graphic;
  ActivateOnClick := True;
end;

procedure ThiiVclCheckBoxEditor.Activate;
var
  V: TValue;
begin
  inherited;
  V := GetValue;
  SetValue(TValue.From<Boolean>(V.IsEmpty or not SameText(V.ToString, 'True') and (V.ToString <> '1')));
  Change;
  RequestCommit;
end;

function ThiiVclCheckBoxEditor.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  Result := h5uEditorCheckBounds(ABounds).Contains(APoint);
end;

constructor ThiiVclImageCellEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := ThiiEditorMode.Graphic;
end;

function ThiiVclImageCellEditor.DefaultControlClass: ThiiVclEditorControlClass;
begin
  Result := nil;
end;

procedure ThiiVclImageCellEditor.ConfigureControl;
begin
  inherited;

end;

function ThiiVclImageCellEditor.ReadValue: TValue;
begin
  Result := inherited;
end;

procedure ThiiVclImageCellEditor.WriteValue(const AValue: TValue);
begin
  inherited;
end;

function ThiiVclImageCellEditor.Modified: Boolean;
begin
  // An explicit OK accepts the image even when the TValue is a byte array.
  Result := True;
end;

procedure ThiiVclImageCellEditor.Activate;
var
  LBytes: TBytes;
  LValue: TValue;
begin
  inherited;
  LValue := GetValue;
  if LValue.IsType<TBytes> then
    LBytes := LValue.AsType<TBytes>
  else
    LBytes := nil;
  if Th5uVclImageEditForm.Execute(Context.Grid, LBytes) then
  begin
    SetValue(TValue.From<TBytes>(LBytes));
    RequestCommit;
  end
  else
    RequestCancel;
end;

function ThiiVclTextEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
var
  R: TRect;
  C: TCanvas;
begin
  if not (AContext.Canvas is TCanvas) then
    Exit(-1);
  C := TCanvas(AContext.Canvas);
  R := Rect(0, 0, 0, 0);
  DrawText(C.Handle, PChar(AContext.Text), Length(AContext.Text), R, DT_CALCRECT or DT_NOPREFIX or DT_EXPANDTABS);
  Result := R.Width + 10;
end;

function ThiiVclCheckBoxEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
begin
  Result := 25;
end;

function ThiiVclImageCellEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
var
  P: TPicture;
  S: TBytesStream;
begin
  Result := 8;
  if AContext.Image is TPicture then
    Exit(TPicture(AContext.Image).Width + 8);
  if not AContext.Value.IsType<TBytes> then
    Exit;
  if Length(AContext.Value.AsType<TBytes>) = 0 then
    Exit;
  P := TPicture.Create;
  S := TBytesStream.Create(AContext.Value.AsType<TBytes>);
  try
    try
      P.LoadFromStream(S);
      Result := P.Width + 8;
    except
      // Invalid images are also rendered as empty cells.
      Result := 8;
    end;
  finally
    S.Free;
    P.Free;
  end;
end;

function ThiiVclTextEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: ThiiGridColumn;
  LTextRect: TRect; LFlags: Cardinal;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
  LTextRect := AContext.Bounds.Round;
  InflateRect(LTextRect, -5, -2);

  LFlags := DT_NOPREFIX or DT_VCENTER or DT_END_ELLIPSIS;
  if LColumn.WordWrap then
    LFlags := (LFlags and not DT_VCENTER) or DT_WORDBREAK;

  case LColumn.DataType of
    ThiiColumnDataType.Integer,
    ThiiColumnDataType.Float,
    ThiiColumnDataType.Currency:
      LFlags := LFlags or DT_RIGHT;
    else
      LFlags := LFlags or DT_LEFT;
  end;

  AContext.PreparePaint(ThiiElementPaintPart.Text);
  DrawText(ACanvas.Handle, PChar(AContext.Text), Length(AContext.Text), LTextRect, LFlags);
  Result := True;
end;

function ThiiVclCheckBoxEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LCheckRect: TRect; LChecked: Boolean;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LCheckRect := h5uEditorCheckBounds(AContext.Bounds).Round;
  LChecked := False;
  if not AContext.Value.IsEmpty then
  begin
    if AContext.Value.Kind = tkEnumeration then
      LChecked := AContext.Value.AsBoolean
    else
      LChecked := SameText(AContext.Value.ToString, 'True') or (AContext.Value.ToString = '1');
  end;

  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := TColor(AContext.Foreground);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := TColor(AContext.Background);
  AContext.PreparePaint(ThiiElementPaintPart.Glyph);
  ACanvas.Rectangle(LCheckRect);
  if LChecked then
  begin
    ACanvas.Pen.Width := 2;
    ACanvas.Pen.Color := TColor(AContext.Foreground);
    AContext.PreparePaint(ThiiElementPaintPart.Glyph);
    ACanvas.MoveTo(LCheckRect.Left + 3, LCheckRect.Top + 7);
    ACanvas.LineTo(LCheckRect.Left + 6, LCheckRect.Bottom - 3);
    ACanvas.LineTo(LCheckRect.Right - 2, LCheckRect.Top + 3);
    ACanvas.Pen.Width := 1;
  end;
  Result := True;
end;

function ThiiVclImageCellEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: ThiiGridColumn;
  LImageRect: TRect;
  LScale: Single;
  LWidth, LHeight: Integer;
  FPicture: TPicture;
begin
  Result := inherited;
  if Result then
    Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
  FPicture := TPicture(AContext.Image);
  if Assigned(FPicture) and Assigned(FPicture.Graphic) and not FPicture.Graphic.Empty then
  begin
    LImageRect := AContext.Bounds.Round;
    InflateRect(LImageRect, -4, -4);
    if LColumn.ImagePreserveAspectRatio then
    begin
      LScale := Min(LImageRect.Width / FPicture.Graphic.Width, LImageRect.Height / FPicture.Graphic.Height);
      LWidth := Max(1, Round(FPicture.Graphic.Width * LScale));
      LHeight := Max(1, Round(FPicture.Graphic.Height * LScale));
      LImageRect := Rect(LImageRect.Left + (LImageRect.Width - LWidth) div 2, LImageRect.Top + (LImageRect.Height - LHeight) div 2,
        LImageRect.Left + (LImageRect.Width - LWidth) div 2 + LWidth, LImageRect.Top + (LImageRect.Height - LHeight) div 2 + LHeight);
    end;
    ACanvas.StretchDraw(LImageRect, FPicture.Graphic);
  end;
  Result := True;
end;

{ Th5uVclImageEditForm }

procedure Th5uVclImageEditForm.ClearClick(Sender: TObject);
begin
  FBytes := nil;
  FImage.Picture.Assign(nil);
end;

constructor Th5uVclImageEditForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Bild bearbeiten';
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  ClientWidth := 680;
  ClientHeight := 480;

  FButtonPanel := TPanel.Create(Self);
  FButtonPanel.Parent := Self;
  FButtonPanel.Align := alBottom;
  FButtonPanel.Height := 44;
  FButtonPanel.BevelOuter := bvNone;

  FLoadButton := TButton.Create(Self);
  FLoadButton.Parent := FButtonPanel;
  FLoadButton.SetBounds(8, 9, 90, 27);
  FLoadButton.Caption := 'Laden ...';
  FLoadButton.OnClick := LoadClick;

  FPasteButton := TButton.Create(Self);
  FPasteButton.Parent := FButtonPanel;
  FPasteButton.SetBounds(104, 9, 100, 27);
  FPasteButton.Caption := 'Einfügen';
  FPasteButton.OnClick := PasteClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FButtonPanel;
  FClearButton.SetBounds(210, 9, 90, 27);
  FClearButton.Caption := 'Löschen';
  FClearButton.OnClick := ClearClick;

  FCancelButton := TButton.Create(Self);
  FCancelButton.Parent := FButtonPanel;
  FCancelButton.SetBounds(574, 9, 90, 27);
  FCancelButton.Anchors := [akTop, akRight];
  FCancelButton.Caption := 'Abbrechen';
  FCancelButton.ModalResult := mrCancel;

  FOkButton := TButton.Create(Self);
  FOkButton.Parent := FButtonPanel;
  FOkButton.SetBounds(478, 9, 90, 27);
  FOkButton.Anchors := [akTop, akRight];
  FOkButton.Caption := 'OK';
  FOkButton.Default := True;
  FOkButton.ModalResult := mrOk;

  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FImage.Align := alClient;
  FImage.Center := True;
  FImage.Proportional := True;
  FImage.Stretch := True;
end;

class function Th5uVclImageEditForm.Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
var
  LForm: Th5uVclImageEditForm;
begin
  LForm := Th5uVclImageEditForm.Create(AOwner);
  try
    LForm.SetBytes(ABytes);
    Result := LForm.ShowModal = mrOk;
    if Result then
      ABytes := Copy(LForm.FBytes);
  finally
    LForm.Free;
  end;
end;

procedure Th5uVclImageEditForm.LoadClick(Sender: TObject);
var
  LDialog: TOpenDialog;
  LStream: TFileStream;
begin
  LDialog := TOpenDialog.Create(Self);
  try
    LDialog.Filter := 'Bilder|*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.ico|' + 'Alle Dateien|*.*';
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

procedure Th5uVclImageEditForm.PasteClick(Sender: TObject);
var
  LBitmap: Vcl.Graphics.TBitmap;
  LStream: TMemoryStream;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  LBitmap := Vcl.Graphics.TBitmap.Create;
  LStream := TMemoryStream.Create;
  try
    LBitmap.Assign(Clipboard);
    LBitmap.SaveToStream(LStream);
    SetLength(FBytes, LStream.Size);
    if LStream.Size > 0 then
    begin
      LStream.Position := 0;
      LStream.ReadBuffer(FBytes[0], LStream.Size);
    end;
  finally
    LStream.Free;
    LBitmap.Free;
  end;
  UpdatePreview;
end;

procedure Th5uVclImageEditForm.SetBytes(const AValue: TBytes);
begin
  FBytes := Copy(AValue);
  UpdatePreview;
end;

procedure Th5uVclImageEditForm.UpdatePreview;
var
  LStream: TBytesStream;
begin
  FImage.Picture.Assign(nil);
  if Length(FBytes) = 0 then
    Exit;

  LStream := TBytesStream.Create(FBytes);
  try
    try
      FImage.Picture.LoadFromStream(LStream);
    except
      FImage.Picture.Assign(nil);
    end;
  finally
    LStream.Free;
  end;
end;


initialization
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'TextEditor', ThiiVclTextEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'IntegerEditor', ThiiVclIntegerEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'FloatEditor', ThiiVclFloatEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'CurrencyEditor', ThiiVclCurrencyEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'DateEditor', ThiiVclDateEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'TimeEditor', ThiiVclTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'DateTimeEditor', ThiiVclDateTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'CheckBoxEditor', ThiiVclCheckBoxEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'ImageEditor', ThiiVclImageCellEditor);
  h5uRegisterEditor(ThiiEditorPlatform.VCL, 'CustomEditor', ThiiVclCustomEditor);

finalization
  // The shared core can remain loaded after this framework package is unloaded.
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'TextEditor', ThiiVclTextEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'IntegerEditor', ThiiVclIntegerEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'FloatEditor', ThiiVclFloatEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'CurrencyEditor', ThiiVclCurrencyEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'DateEditor', ThiiVclDateEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'TimeEditor', ThiiVclTimeEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'DateTimeEditor', ThiiVclDateTimeEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'CheckBoxEditor', ThiiVclCheckBoxEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'ImageEditor', ThiiVclImageCellEditor);
  h5uUnregisterEditor(ThiiEditorPlatform.VCL, 'CustomEditor', ThiiVclCustomEditor);

end.

