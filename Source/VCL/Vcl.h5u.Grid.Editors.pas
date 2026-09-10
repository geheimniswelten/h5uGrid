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
  Th5uVclEditorControlClass = class of TControl;
  Th5uVclBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  Th5uVclCustomEditor = class(Th5uGridEditorItem)
  private
    FControl: TControl;
    FControlClass: Th5uVclEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: Th5uVclBuildEditorEvent;

    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: Th5uVclEditorControlClass);
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
    function DefaultControlClass: Th5uVclEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: Th5uVclEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to DFM/FMX streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: Th5uVclBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  Th5uVclTextEditor = class(Th5uVclCustomEditor)
  public
    function DrawDisplay(const AContext: Th5uEditorContext): Boolean; override;
  end;

  Th5uVclIntegerEditor = class(Th5uVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  Th5uVclFloatEditor = class(Th5uVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  Th5uVclCurrencyEditor = class(Th5uVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  Th5uVclDateEditor = class(Th5uVclTextEditor)
  protected
    function DefaultControlClass: Th5uVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: Th5uColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  Th5uVclTimeEditor = class(Th5uVclDateEditor)
  protected
    function DateKind: Th5uColumnEditorKind; override;
  end;

  Th5uVclDateTimeEditor = class(Th5uVclDateEditor)
  protected
    function DateKind: Th5uColumnEditorKind; override;
  end;

  Th5uVclCheckBoxEditor = class(Th5uVclCustomEditor)
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: Th5uEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  Th5uVclImageCellEditor = class(Th5uVclCustomEditor)
  protected
    function DefaultControlClass: Th5uVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: Th5uEditorContext): Boolean; override;
  end;

  Th5uVclGridEditors = class(Th5uGridEditors)
  private
    function GetItem(AIndex: Integer): Th5uVclCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: Th5uVclCustomEditor;
    function AddVariant(const AName, AType: string): Th5uVclCustomEditor;
    property Items[AIndex: Integer]: Th5uVclCustomEditor read GetItem; default;
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

constructor Th5uVclGridEditors.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uVclCustomEditor);
end;

function Th5uVclGridEditors.Add: Th5uVclCustomEditor;
begin
  Result := Th5uVclCustomEditor(inherited Add);
end;

function Th5uVclGridEditors.AddVariant(const AName, AType: string): Th5uVclCustomEditor;
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

procedure Th5uVclCustomEditor.SetEditorType(const AValue: string);
var
  E: Th5uGridEditorItem;
begin
  if EditorType = AValue then Exit;
  if AValue <> '' then
  begin
    E := h5uCreateEditor(Th5uEditorPlatform.VCL, AValue, nil);
    try
      Mode := E.Mode;
      ActivateOnClick := E.ActivateOnClick;
    finally
      E.Free;
    end;
  end;
  inherited;
end;

function Th5uVclGridEditors.GetItem(AIndex: Integer): Th5uVclCustomEditor;
begin
  Result := Th5uVclCustomEditor(inherited Items[AIndex]);
end;

constructor Th5uVclCustomEditor.Create(Collection: TCollection);
begin
  inherited;
  FControlVersion := -1;
end;

destructor Th5uVclCustomEditor.Destroy;
begin
  if Active then RequestCancel;
  ReleaseControl;
  inherited;
end;

procedure Th5uVclCustomEditor.Assign(Source: TPersistent);
begin
  if Active then raise Eh5uGrid.Create('Ein aktiver Editor kann nicht ersetzt werden.');
  inherited;
  if Source is Th5uVclCustomEditor then
  begin
    ReleaseControl;
    FControlClass := Th5uVclCustomEditor(Source).FControlClass;
    FOnBuildEditor := Th5uVclCustomEditor(Source).FOnBuildEditor;
  end;
end;

procedure Th5uVclCustomEditor.ReleaseControl;
begin
  // Detach callbacks before destroying a focused native control.
  if Assigned(FControl) then
  begin
    if FControl is TWinControl then TWinControlAccess(FControl).OnExit := nil;
    FreeAndNil(FControl);
  end;

  FControlVersion := -1;
end;

procedure Th5uVclCustomEditor.ReleaseEditor;
begin
  if Active then RequestCancel;
  ReleaseControl;
end;

function Th5uVclCustomEditor.GetControlClassName: string;
begin
  Result := '';
  if Assigned(FControlClass) then Result := FControlClass.ClassName;
end;

procedure Th5uVclCustomEditor.SetControlClassName(const AValue: string);
var
  C: TPersistentClass;
begin
  if AValue = '' then begin SetControlClass(nil); Exit; end;
  C := GetClass(AValue);
  if not Assigned(C) or not C.InheritsFrom(TControl) then
    raise Eh5uGrid.CreateFmt('Control-Klasse "%s" ist nicht registriert.', [AValue]);
  SetControlClass(Th5uVclEditorControlClass(C));
end;

procedure Th5uVclCustomEditor.SetControlClass(AValue: Th5uVclEditorControlClass);
begin
  if FControlClass = AValue then Exit;
  FControlClass := AValue;
  EditorVersion := EditorVersion + 1;
end;

function Th5uVclCustomEditor.DefaultControlClass: Th5uVclEditorControlClass;
begin
  if Mode = Th5uEditorMode.Text then Result := TEdit else Result := nil;
end;

procedure Th5uVclCustomEditor.BuildEditor;
var
  C: Th5uVclEditorControlClass;
begin
  if not Assigned(Context.Grid) or (csDesigning in Context.Grid.ComponentState) then Exit;
  if FControlVersion = EditorVersion then Exit;
  if Active then Exit;
  ReleaseControl;
  C := FControlClass;
  if not Assigned(C) then C := DefaultControlClass;
  try
    if Assigned(FOnBuildEditor) then FOnBuildEditor(Self, FControl);
    if not Assigned(FControl) and Assigned(C) then FControl := C.Create(Context.Grid);
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

procedure Th5uVclCustomEditor.ConfigureControl;
var
  P: PPropInfo;
  M: TMethod;
  N: TNotifyEvent;
begin
  if Control is TEdit then TEdit(Control).AutoSize := False;
  if Control is TCustomEdit then TEditAccess(Control).OnChange := ControlChanged;
  // Use RTTI for published OnChange on arbitrary controls; never assume TEdit layout.
  P := GetPropInfo(Control.ClassInfo, 'OnChange');
  if Assigned(P) and (P.PropType^.Kind = tkMethod) then
  begin
    N := ControlChanged; M := TMethod(N);
    if P.PropType^ = TypeInfo(TNotifyEvent) then SetMethodProp(Control, P, M);
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

procedure Th5uVclCustomEditor.ControlChanged(Sender: TObject);
begin
  Change;
end;

procedure Th5uVclCustomEditor.ControlEnter(Sender: TObject);
begin
  Enter;
end;

procedure Th5uVclCustomEditor.ControlExit(Sender: TObject);
begin
  if not DeferExit then ExitEditor;
end;

procedure Th5uVclCustomEditor.ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var C: Char;
begin
  C := #0;
  KeyDown(Key, C, Shift);
end;

procedure Th5uVclCustomEditor.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, PointF(X, Y));
end;

procedure Th5uVclCustomEditor.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, PointF(X, Y));
end;

procedure Th5uVclCustomEditor.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, PointF(X, Y));
end;

function Th5uVclCustomEditor.ReadText: string;
begin
  if Assigned(Control) then Result := TControlAccess(Control).Text else Result := inherited;
end;

procedure Th5uVclCustomEditor.WriteText(const AText: string);
begin
  inherited;
  if Assigned(Control) then TControlAccess(Control).Text := AText;
end;

procedure Th5uVclCustomEditor.Show;
begin
  if Assigned(Control) then
  begin
    Control.SetBounds(Round(Context.Bounds.Left), Round(Context.Bounds.Top), Round(Context.Bounds.Width), Round(Context.Bounds.Height));


    Control.Visible := True;
    BringToFront;
  end;
  inherited;
  Focus;
  if Control is TEdit then TEdit(Control).SelectAll;
end;

procedure Th5uVclCustomEditor.Hide;
begin
  inherited;
  if Assigned(Control) then Control.Visible := False;

end;

procedure Th5uVclCustomEditor.Focus;
begin
  if (Control is TWinControl) and TWinControl(Control).CanFocus then TWinControl(Control).SetFocus;
end;

procedure Th5uVclCustomEditor.BringToFront;
begin
  if Assigned(Control) then Control.BringToFront;
end;

function Th5uVclIntegerEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(Th5uColumnDataType.Integer, GetText);
end;

function Th5uVclFloatEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(Th5uColumnDataType.Float, GetText);
end;

function Th5uVclCurrencyEditor.ReadValue: TValue;
begin
  Result := h5uParseEditorValue(Th5uColumnDataType.Currency, GetText);
end;

function Th5uVclDateEditor.DefaultControlClass: Th5uVclEditorControlClass;
begin
  Result := TDateTimePicker;
end;

function Th5uVclDateEditor.DateKind: Th5uColumnEditorKind;
begin
  Result := Th5uColumnEditorKind.Date;
end;

function Th5uVclTimeEditor.DateKind: Th5uColumnEditorKind;
begin
  Result := Th5uColumnEditorKind.Time;
end;

function Th5uVclDateTimeEditor.DateKind: Th5uColumnEditorKind;
begin
  Result := Th5uColumnEditorKind.DateTime;
end;

procedure Th5uVclDateEditor.ConfigureControl;
var
  E: TDateTimePicker;
begin
  if not (Control is TDateTimePicker) then
    raise Eh5uGrid.Create('Der Datumseditor benötigt ein TDateTimePicker-Control.');
  inherited;
  E := TDateTimePicker(Control);
  E.ShowCheckbox := True;
  if DateKind = Th5uColumnEditorKind.Time then E.Kind := dtkTime else E.Kind := dtkDate;
  case DateKind of
    Th5uColumnEditorKind.Time: E.Format := 'HH:mm:ss';
    Th5uColumnEditorKind.DateTime: E.Format := 'dd.MM.yyyy HH:mm:ss';
    else E.Format := 'dd.MM.yyyy';
  end;
end;

function Th5uVclDateEditor.ReadValue: TValue;
var
  D: TDateTime;
  E: TDateTimePicker;
begin
  E := TDateTimePicker(Control);
  if not E.Checked then Exit(TValue.Empty);
  D := E.DateTime;
  case DateKind of
    Th5uColumnEditorKind.Date: D := DateOf(D);
    Th5uColumnEditorKind.Time: D := TimeOf(D);
  end;
  Result := TValue.From<TDateTime>(D);
end;

procedure Th5uVclDateEditor.WriteValue(const AValue: TValue);
var
  E: TDateTimePicker;
begin
  E := TDateTimePicker(Control);
  if AValue.IsEmpty then E.DateTime := Now else E.DateTime := AValue.AsType<TDateTime>;
  E.Checked := not AValue.IsEmpty;
end;

function Th5uVclDateEditor.State: string;
begin
  Result := BoolToStr(TDateTimePicker(Control).Checked, True) + ':' + FloatToStr(TDateTimePicker(Control).DateTime, TFormatSettings.Invariant);
end;

function Th5uVclDateEditor.UsesTextValue: Boolean;
begin
  Result := False;
end;

function Th5uVclDateEditor.DeferExit: Boolean;
begin
  Result := False;
end;

constructor Th5uVclCheckBoxEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := Th5uEditorMode.Graphic;
  ActivateOnClick := True;
end;

procedure Th5uVclCheckBoxEditor.Activate;
var
  V: TValue;
begin
  inherited;
  V := GetValue;
  SetValue(TValue.From<Boolean>(V.IsEmpty or not SameText(V.ToString, 'True') and (V.ToString <> '1')));
  Change;
  RequestCommit;
end;

function Th5uVclCheckBoxEditor.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  Result := h5uEditorCheckBounds(ABounds).Contains(APoint);
end;

constructor Th5uVclImageCellEditor.Create(Collection: TCollection);
begin
  inherited;
  Mode := Th5uEditorMode.Graphic;
end;

function Th5uVclImageCellEditor.DefaultControlClass: Th5uVclEditorControlClass;
begin
  Result := nil;
end;

procedure Th5uVclImageCellEditor.ConfigureControl;
begin
  inherited;

end;

function Th5uVclImageCellEditor.ReadValue: TValue;
begin
  Result := inherited;
end;

procedure Th5uVclImageCellEditor.WriteValue(const AValue: TValue);
begin
  inherited;
end;

function Th5uVclImageCellEditor.Modified: Boolean;
begin
  // An explicit OK accepts the image even when the TValue is a byte array.
  Result := True;
end;

procedure Th5uVclImageCellEditor.Activate;
var
  LBytes: TBytes;
  LValue: TValue;
begin
  inherited;
  LValue := GetValue;
  if LValue.IsType<TBytes> then LBytes := LValue.AsType<TBytes> else LBytes := nil;
  if Th5uVclImageEditForm.Execute(Context.Grid, LBytes) then
  begin
    SetValue(TValue.From<TBytes>(LBytes));
    RequestCommit;
  end
  else RequestCancel;
end;

function Th5uVclTextEditor.DrawDisplay(const AContext: Th5uEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: Th5uGridColumn;
  LTextRect: TRect; LFlags: Cardinal;
begin
  Result := inherited;
  if Result then Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
      begin
        LTextRect := AContext.Bounds.Round;
        InflateRect(LTextRect, -5, -2);

        LFlags := DT_NOPREFIX or DT_VCENTER or DT_END_ELLIPSIS;
        if LColumn.WordWrap then
          LFlags := (LFlags and not DT_VCENTER) or DT_WORDBREAK;

        case LColumn.DataType of
          Th5uColumnDataType.Integer,
          Th5uColumnDataType.Float,
          Th5uColumnDataType.Currency:
            LFlags := LFlags or DT_RIGHT;
          else
            LFlags := LFlags or DT_LEFT;
        end;

        AContext.PreparePaint(Th5uElementPaintPart.Text);
        DrawText(ACanvas.Handle, PChar(AContext.Text), Length(AContext.Text), LTextRect, LFlags);
      end;
  Result := True;
end;

function Th5uVclCheckBoxEditor.DrawDisplay(const AContext: Th5uEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: Th5uGridColumn;
  LCheckRect: TRect; LChecked: Boolean;
begin
  Result := inherited;
  if Result then Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
      begin
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
        AContext.PreparePaint(Th5uElementPaintPart.Glyph);
        ACanvas.Rectangle(LCheckRect);
        if LChecked then
        begin
          ACanvas.Pen.Width := 2;
          ACanvas.Pen.Color := TColor(AContext.Foreground);
          AContext.PreparePaint(Th5uElementPaintPart.Glyph);
          ACanvas.MoveTo(LCheckRect.Left + 3, LCheckRect.Top + 7);
          ACanvas.LineTo(LCheckRect.Left + 6, LCheckRect.Bottom - 3);
          ACanvas.LineTo(LCheckRect.Right - 2, LCheckRect.Top + 3);
          ACanvas.Pen.Width := 1;
        end;
      end;
  Result := True;
end;

function Th5uVclImageCellEditor.DrawDisplay(const AContext: Th5uEditorContext): Boolean;
var
  ACanvas: TCanvas;
  LColumn: Th5uGridColumn;
  LImageRect: TRect; LScale: Double; LWidth, LHeight: Integer; FPicture: TPicture;
begin
  Result := inherited;
  if Result then Exit;
  ACanvas := TCanvas(AContext.Canvas);
  LColumn := AContext.Column;
      begin
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
            LImageRect := Rect(LImageRect.Left + (LImageRect.Width - LWidth) div 2, LImageRect.Top + (LImageRect.Height - LHeight)
              div 2, LImageRect.Left + (LImageRect.Width - LWidth) div 2 + LWidth, LImageRect.Top + (LImageRect.Height - LHeight) div 2 + LHeight);
          end;
          ACanvas.StretchDraw(LImageRect, FPicture.Graphic);
        end;
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
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'TextEditor', Th5uVclTextEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'IntegerEditor', Th5uVclIntegerEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'FloatEditor', Th5uVclFloatEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'CurrencyEditor', Th5uVclCurrencyEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'DateEditor', Th5uVclDateEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'TimeEditor', Th5uVclTimeEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'DateTimeEditor', Th5uVclDateTimeEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'CheckBoxEditor', Th5uVclCheckBoxEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'ImageEditor', Th5uVclImageCellEditor);
  h5uRegisterEditor(Th5uEditorPlatform.VCL, 'CustomEditor', Th5uVclCustomEditor);

end.
