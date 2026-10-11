unit Lcl.h5u.Grid.Editors;

{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$CODEPAGE UTF8}

interface

{$SCOPEDENUMS ON}

uses
  h5u.Grid.Compat,
  Classes, SysUtils, Types, Rtti,
  TypInfo, Math, DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  LCLIntf, LCLType, DateTimePicker, Controls, ComCtrls, ExtCtrls, Forms,
  Graphics, StdCtrls, Clipbrd, Dialogs, Lcl.h5u.Grid.Compat;

type
  ThiiLclEditorControlClass = class of TControl;
  ThiiLclBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiLclCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiLclEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiLclBuildEditorEvent;

    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiLclEditorControlClass);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure ControlChanged(Sender: TObject);
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiLclEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: ThiiLclEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to LFM streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiLclBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiLclTextEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiLclIntegerEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclFloatEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclCurrencyEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclDateEditor = class(ThiiLclTextEditor)
  protected
    function DefaultControlClass: ThiiLclEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiLclTimeEditor = class(ThiiLclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiLclDateTimeEditor = class(ThiiLclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiLclCheckBoxEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiLclImageCellEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  protected
    function DefaultControlClass: ThiiLclEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiLclGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiLclCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiLclCustomEditor;
    function AddVariant(const AName, AType: string): ThiiLclCustomEditor;
    property Items[AIndex: Integer]: ThiiLclCustomEditor read GetItem; default;
  end;

  Th5uLclImageEditForm = class(TForm)
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

constructor ThiiLclGridEditors.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiLclCustomEditor);
end;

function ThiiLclGridEditors.Add: ThiiLclCustomEditor;
begin
  Result := ThiiLclCustomEditor(inherited Add);
end;

function ThiiLclGridEditors.AddVariant(const AName, AType: string): ThiiLclCustomEditor;
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

procedure ThiiLclCustomEditor.SetEditorType(const AValue: string);
var
  E: ThiiGridEditorItem;
begin
  if EditorType = AValue then
    Exit;
  if AValue <> '' then
  begin
    E := h5uCreateEditor(ThiiEditorPlatform.LCL, AValue, nil);
    try
      Mode := E.Mode;
      ActivateOnClick := E.ActivateOnClick;
    finally
      E.Free;
    end;
  end;
  inherited;
end;

function ThiiLclGridEditors.GetItem(AIndex: Integer): ThiiLclCustomEditor;
begin
  Result := ThiiLclCustomEditor(inherited Items[AIndex]);
end;

constructor ThiiLclCustomEditor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FControlVersion := -1;
end;

destructor ThiiLclCustomEditor.Destroy;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
  inherited;
end;

procedure ThiiLclCustomEditor.Assign(Source: TPersistent);
begin
  if Active then
    raise EhiiGrid.Create('Ein aktiver Editor kann nicht ersetzt werden.');
  inherited;
  if Source is ThiiLclCustomEditor then
  begin
    ReleaseControl;
    FControlClass := ThiiLclCustomEditor(Source).FControlClass;
    FOnBuildEditor := ThiiLclCustomEditor(Source).FOnBuildEditor;
  end;
end;

procedure ThiiLclCustomEditor.ReleaseControl;
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

procedure ThiiLclCustomEditor.ReleaseEditor;
begin
  if Active then
    RequestCancel;
  ReleaseControl;
end;

function ThiiLclCustomEditor.GetControlClassName: string;
begin
  Result := '';
  if Assigned(FControlClass) then
    Result := FControlClass.ClassName;
end;

procedure ThiiLclCustomEditor.SetControlClassName(const AValue: string);
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
  SetControlClass(ThiiLclEditorControlClass(C));
end;

procedure ThiiLclCustomEditor.SetControlClass(AValue: ThiiLclEditorControlClass);
begin
  if FControlClass = AValue then
    Exit;
  FControlClass := AValue;
  EditorVersion := EditorVersion + 1;
end;

function ThiiLclCustomEditor.DefaultControlClass: ThiiLclEditorControlClass;
begin
  if Mode = ThiiEditorMode.Text then
    Result := TEdit
  else
    Result := nil;
end;

procedure ThiiLclCustomEditor.BuildEditor;
var
  C: ThiiLclEditorControlClass;
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

procedure ThiiLclCustomEditor.ConfigureControl;
var
  P: PPropInfo;
  M: TMethod;
  N: TNotifyEvent;
begin
  if Control is TEdit then
    TEdit(Control).AutoSize := False;
  if Control is TCustomEdit then
    TEditAccess(Control).OnChange := @ControlChanged;
  // Use RTTI for published OnChange on arbitrary controls. Never assume TEdit layout.
  P := GetPropInfo(Control.ClassInfo, 'OnChange');
  if Assigned(P) and (P^.PropType^.Kind = tkMethod) then
  begin
    N := @ControlChanged;
    M := TMethod(N);
    if P^.PropType = TypeInfo(TNotifyEvent) then
      SetMethodProp(Control, P, M);
  end;
  if Control is TWinControl then
  begin
    TWinControlAccess(Control).OnEnter := @ControlEnter;
    TWinControlAccess(Control).OnExit := @ControlExit;
    TWinControlAccess(Control).OnKeyDown := @ControlKeyDown;
  end;
  TControlAccess(Control).OnMouseDown := @ControlMouseDown;
  TControlAccess(Control).OnMouseMove := @ControlMouseMove;
  TControlAccess(Control).OnMouseUp := @ControlMouseUp;
end;

procedure ThiiLclCustomEditor.ControlChanged(Sender: TObject);
begin
  Change;
end;

procedure ThiiLclCustomEditor.ControlEnter(Sender: TObject);
begin
  Enter;
end;

procedure ThiiLclCustomEditor.ControlExit(Sender: TObject);
begin
  if not DeferExit then
    ExitEditor;
end;

procedure ThiiLclCustomEditor.ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  C: Char;
begin
  C := #0;
  KeyDown(Key, C, Shift);
end;

procedure ThiiLclCustomEditor.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(h5u.Grid.Compat.TMouseButton(Button), Shift, PointF(X, Y));
end;

procedure ThiiLclCustomEditor.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, PointF(X, Y));
end;

procedure ThiiLclCustomEditor.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(h5u.Grid.Compat.TMouseButton(Button), Shift, PointF(X, Y));
end;

function ThiiLclCustomEditor.ReadText: string;
begin
  if Assigned(Control) then
    Result := TControlAccess(Control).Text
  else
    Result := inherited;
end;

procedure ThiiLclCustomEditor.WriteText(const AText: string);
begin
  inherited;
  if Assigned(Control) then
    TControlAccess(Control).Text := AText;
end;

procedure ThiiLclCustomEditor.Show;
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

procedure ThiiLclCustomEditor.Hide;
begin
  inherited;
  if Assigned(Control) then
    Control.Visible := False;
end;

procedure ThiiLclCustomEditor.Focus;
begin
  if (Control is TWinControl) and TWinControl(Control).CanFocus then
    TWinControl(Control).SetFocus;
end;

procedure ThiiLclCustomEditor.BringToFront;
begin
  if Assigned(Control) then
    Control.BringToFront;
end;

function ThiiLclIntegerEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Integer, GetText);
end;

function ThiiLclFloatEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Float, GetText);
end;

function ThiiLclCurrencyEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(ThiiColumnDataType.Currency, GetText);
end;

function ThiiLclDateEditor.DefaultControlClass: ThiiLclEditorControlClass;
begin
  Result := TDateTimePicker;
end;

function ThiiLclDateEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Date;
end;

function ThiiLclTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.Time;
end;

function ThiiLclDateTimeEditor.DateKind: ThiiColumnEditorKind;
begin
  Result := ThiiColumnEditorKind.DateTime;
end;

procedure ThiiLclDateEditor.ConfigureControl;
var
  E: TDateTimePicker;
begin
  if not (Control is TDateTimePicker) then
    raise EhiiGrid.Create('Der Datumseditor benötigt ein TDateTimePicker-Control.');
  inherited;
  E := TDateTimePicker(Control);
  E.ShowCheckbox := True;
  E.OnCheckBoxChange := @ControlChanged;
  E.DateDisplayOrder := ddoDMY;
  E.TimeFormat := tf24;
  E.TimeDisplay := tdHMS;
  case DateKind of
    ThiiColumnEditorKind.Time: E.Kind := dtkTime;
    ThiiColumnEditorKind.DateTime: E.Kind := dtkDateTime;
    else E.Kind := dtkDate;
  end;
end;

function ThiiLclDateEditor.ReadValue: TValue;
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
  Result := TValue.specialize From<TDateTime>(D);
end;

procedure ThiiLclDateEditor.WriteValue(const AValue: TValue);
var
  E: TDateTimePicker;
begin
  E := TDateTimePicker(Control);
  if AValue.IsEmpty then
    E.DateTime := Now
  else
    E.DateTime := AValue.specialize AsType<TDateTime>;
  E.Checked := not AValue.IsEmpty;
end;

function ThiiLclDateEditor.State: string;
begin
  Result := BoolToStr(TDateTimePicker(Control).Checked, True) + ':' + FloatToStr(TDateTimePicker(Control).DateTime, DefaultFormatSettings);
end;

function ThiiLclDateEditor.UsesTextValue: Boolean;
begin
  Result := False;
end;

function ThiiLclDateEditor.DeferExit: Boolean;
begin
  Result := (Control is TDateTimePicker) and TDateTimePicker(Control).DroppedDown;
end;

constructor ThiiLclCheckBoxEditor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  Mode := ThiiEditorMode.Graphic;
  ActivateOnClick := True;
end;

procedure ThiiLclCheckBoxEditor.Activate;
var
  V: TValue;
begin
  inherited;
  V := GetValue;
  SetValue(TValue.specialize From<Boolean>(V.IsEmpty or not SameText(V.ToString, 'True') and (V.ToString <> '1')));
  Change;
  RequestCommit;
end;

function ThiiLclCheckBoxEditor.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  Result := h5uEditorCheckBounds(ABounds).Contains(APoint);
end;

constructor ThiiLclImageCellEditor.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  Mode := ThiiEditorMode.Graphic;
end;

function ThiiLclImageCellEditor.DefaultControlClass: ThiiLclEditorControlClass;
begin
  Result := nil;
end;

procedure ThiiLclImageCellEditor.ConfigureControl;
begin
  inherited;

end;

function ThiiLclImageCellEditor.ReadValue: TValue;
begin
  Result := inherited;
end;

procedure ThiiLclImageCellEditor.WriteValue(const AValue: TValue);
begin
  inherited;
end;

function ThiiLclImageCellEditor.Modified: Boolean;
begin
  // An explicit OK accepts the image even when the TValue is a byte array.
  Result := True;
end;

procedure ThiiLclImageCellEditor.Activate;
var
  LBytes: TBytes;
  LValue: TValue;
begin
  inherited;
  LValue := GetValue;
  if LValue.specialize IsType<TBytes> then
    LBytes := LValue.specialize AsType<TBytes>
  else
    LBytes := nil;
  if Th5uLclImageEditForm.Execute(Context.Grid, LBytes) then
  begin
    SetValue(TValue.specialize From<TBytes>(LBytes));
    RequestCommit;
  end
  else
    RequestCancel;
end;

function ThiiLclTextEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
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

function ThiiLclCheckBoxEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
begin
  Result := 25;
end;

function ThiiLclImageCellEditor.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
var
  P: TPicture;
  S: TBytesStream;
begin
  Result := 8;
  if AContext.Image is TPicture then
    Exit(TPicture(AContext.Image).Width + 8);
  if not AContext.Value.specialize IsType<TBytes> then
    Exit;
  if Length(AContext.Value.specialize AsType<TBytes>) = 0 then
    Exit;
  P := TPicture.Create;
  S := TBytesStream.Create(AContext.Value.specialize AsType<TBytes>);
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

function ThiiLclTextEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
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

function ThiiLclCheckBoxEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
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
    if AContext.Value.Kind = tkBool then
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

function ThiiLclImageCellEditor.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
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

{ Th5uLclImageEditForm }

procedure Th5uLclImageEditForm.ClearClick(Sender: TObject);
begin
  FBytes := nil;
  FImage.Picture.Assign(nil);
end;

constructor Th5uLclImageEditForm.Create(AOwner: TComponent);
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
  FLoadButton.OnClick := @LoadClick;

  FPasteButton := TButton.Create(Self);
  FPasteButton.Parent := FButtonPanel;
  FPasteButton.SetBounds(104, 9, 100, 27);
  FPasteButton.Caption := 'Einfügen';
  FPasteButton.OnClick := @PasteClick;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := FButtonPanel;
  FClearButton.SetBounds(210, 9, 90, 27);
  FClearButton.Caption := 'Löschen';
  FClearButton.OnClick := @ClearClick;

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

class function Th5uLclImageEditForm.Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
var
  LForm: Th5uLclImageEditForm;
begin
  LForm := Th5uLclImageEditForm.Create(AOwner);
  try
    LForm.SetBytes(ABytes);
    Result := LForm.ShowModal = mrOk;
    if Result then
      ABytes := Copy(LForm.FBytes);
  finally
    LForm.Free;
  end;
end;

procedure Th5uLclImageEditForm.LoadClick(Sender: TObject);
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

procedure Th5uLclImageEditForm.PasteClick(Sender: TObject);
var
  LBitmap: Graphics.TBitmap;
  LStream: TMemoryStream;
begin
  if not Clipboard.HasFormat(CF_BITMAP) then
    Exit;

  LBitmap := Graphics.TBitmap.Create;
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

procedure Th5uLclImageEditForm.SetBytes(const AValue: TBytes);
begin
  FBytes := Copy(AValue);
  UpdatePreview;
end;

procedure Th5uLclImageEditForm.UpdatePreview;
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
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'TextEditor', ThiiLclTextEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'IntegerEditor', ThiiLclIntegerEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'FloatEditor', ThiiLclFloatEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'CurrencyEditor', ThiiLclCurrencyEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'DateEditor', ThiiLclDateEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'TimeEditor', ThiiLclTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'DateTimeEditor', ThiiLclDateTimeEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'CheckBoxEditor', ThiiLclCheckBoxEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'ImageEditor', ThiiLclImageCellEditor);
  h5uRegisterEditor(ThiiEditorPlatform.LCL, 'CustomEditor', ThiiLclCustomEditor);

end.
