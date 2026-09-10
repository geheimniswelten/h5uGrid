unit h5u.Grid.Editors;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Rtti, System.Types, System.UITypes,
  System.Generics.Collections, h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values;

type
  Th5uEditorMode = (Text, Graphic);
  Th5uEditorPlatform = (VCL, FMX);

  Th5uEditorContext = record
    Grid: TComponent;
    Column: Th5uGridColumn;
    RowIndex: Int64;
    RowKey: Th5uRowKey;
    Bounds: TRectF;
    Value: TValue;
    Text: string;
    // Native canvas and cached image; Common does not depend on either UI library.
    Canvas: TObject;
    Image: TObject;
    Foreground: TAlphaColor;
    Background: TAlphaColor;
    PreparePaint: TProc<Th5uElementPaintPart>;
  end;

  Th5uEditorTextEvent = procedure(Sender: TObject; var AText: string) of object;
  Th5uEditorValueEvent = procedure(Sender: TObject; var AValue: TValue) of object;
  Th5uEditorDrawEvent = procedure(Sender: TObject; const AContext: Th5uEditorContext; var AHandled: Boolean) of object;
  Th5uEditorKeyEvent = procedure(Sender: TObject; var AKey: Word; var AKeyChar: Char; AShift: TShiftState) of object;
  Th5uEditorPointerEvent = procedure(Sender: TObject; AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF) of object;

  Th5uGridEditorItem = class(TCollectionItem)
  private
    FEditorName: string;
    FEditorType: string;
    FEditorVersion: Integer;
    FMode: Th5uEditorMode;
    FActivateOnClick: Boolean;
    FContext: Th5uEditorContext;
    FValue: TValue;
    FText: string;
    FOriginalState: string;
    FActive: Boolean;
    FChangedSinceBegin: Boolean;
    FOnShow, FOnHide, FOnCancel, FOnCommit, FOnChange, FOnEnter, FOnExit: TNotifyEvent;
    FOnGetText, FOnSetText: Th5uEditorTextEvent;
    FOnGetValue, FOnSetValue: Th5uEditorValueEvent;
    FOnDrawDisplay, FOnDrawEditor: Th5uEditorDrawEvent;
    FOnKeyDown: Th5uEditorKeyEvent;
    FOnMouseDown, FOnMouseMove, FOnMouseUp: Th5uEditorPointerEvent;
    FRequestCommit, FRequestCancel, FChanged, FExited: TNotifyEvent;
    FKeyDown: Th5uEditorKeyEvent;
    procedure SetEditorName(const AValue: string);
  protected
    procedure SetEditorType(const AValue: string); virtual;
    function GetDisplayName: string; override;
    function ReadText: string; virtual;
    procedure WriteText(const AText: string); virtual;
    function ReadValue: TValue; virtual;
    procedure WriteValue(const AValue: TValue); virtual;
    function State: string; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; virtual;
    procedure ReleaseEditor; virtual;
    procedure BeginEdit(const AContext: Th5uEditorContext); virtual;
    procedure Activate; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure Cancel; virtual;
    procedure Committed; virtual;
    procedure Focus; virtual;
    procedure BringToFront; virtual;
    function UsesTextValue: Boolean; virtual;
    function CanAutoEdit: Boolean; virtual;
    function DeferExit: Boolean; virtual;
    function GetText: string; virtual;
    procedure SetText(const AText: string); virtual;
    function GetValue: TValue; virtual;
    procedure SetValue(const AValue: TValue); virtual;
    function Modified: Boolean; virtual;
    function DrawDisplay(const AContext: Th5uEditorContext): Boolean; virtual;
    function DrawEditor(const AContext: Th5uEditorContext): Boolean; virtual;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; virtual;
    procedure Change; virtual;
    procedure Enter; virtual;
    procedure ExitEditor; virtual;
    procedure KeyDown(var AKey: Word; var AKeyChar: Char; AShift: TShiftState); virtual;
    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF); virtual;
    procedure MouseMove(AShift: TShiftState; const APoint: TPointF); virtual;
    procedure MouseUp(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF); virtual;
    procedure RequestCommit;
    procedure RequestCancel;
    property Context: Th5uEditorContext read FContext;
    property Active: Boolean read FActive;
    property OnRequestCommit: TNotifyEvent read FRequestCommit write FRequestCommit;
    property OnRequestCancel: TNotifyEvent read FRequestCancel write FRequestCancel;
    property OnChanged: TNotifyEvent read FChanged write FChanged;
    property OnExited: TNotifyEvent read FExited write FExited;
    property OnProcessKey: Th5uEditorKeyEvent read FKeyDown write FKeyDown;
  published
    property EditorType: string read FEditorType write SetEditorType;
    property EditorName: string read FEditorName write SetEditorName;
    property ActivateOnClick: Boolean read FActivateOnClick write FActivateOnClick default False;
    property EditorVersion: Integer read FEditorVersion write FEditorVersion default 0;
    property Mode: Th5uEditorMode read FMode write FMode default Th5uEditorMode.Text;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
    property OnCommit: TNotifyEvent read FOnCommit write FOnCommit;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnGetText: Th5uEditorTextEvent read FOnGetText write FOnGetText;
    property OnSetText: Th5uEditorTextEvent read FOnSetText write FOnSetText;
    property OnGetValue: Th5uEditorValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uEditorValueEvent read FOnSetValue write FOnSetValue;
    property OnDrawDisplay: Th5uEditorDrawEvent read FOnDrawDisplay write FOnDrawDisplay;
    property OnDrawEditor: Th5uEditorDrawEvent read FOnDrawEditor write FOnDrawEditor;
    property OnKeyDown: Th5uEditorKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnMouseDown: Th5uEditorPointerEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: Th5uEditorPointerEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: Th5uEditorPointerEvent read FOnMouseUp write FOnMouseUp;
  end;
  Th5uGridEditorItemClass = class of Th5uGridEditorItem;

  Th5uGridEditors = class(TOwnedCollection)
  public
    function Find(const AName: string): Th5uGridEditorItem;
  end;

  Th5uGridEditorCache = class
  private type
    TEntry = record
      Editor: Th5uGridEditorItem;
      Template: Th5uGridEditorItem;
      Version: Integer;
    end;
  private
    FItems: TCollection;
    FEntries: TDictionary<string, TEntry>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Get(APlatform: Th5uEditorPlatform; const AName, AColumnId: string; ATemplate: Th5uGridEditorItem): Th5uGridEditorItem;
  end;

  Th5uDefaultEditors = class(TPersistent)
  private
    FEdit, FInteger, FFloat, FCurrency, FDate, FTime, FDateTime, FCheckBox, FImage: string;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function DataTypeEditor(AType: Th5uColumnDataType): string;
    function EditorFor(AColumn: Th5uGridColumn): string;
  published
    property Edit: string read FEdit write FEdit;
    property Integer: string read FInteger write FInteger;
    property Float: string read FFloat write FFloat;
    property Currency: string read FCurrency write FCurrency;
    property Date: string read FDate write FDate;
    property Time: string read FTime write FTime;
    property DateTime: string read FDateTime write FDateTime;
    property CheckBox: string read FCheckBox write FCheckBox;
    property Image: string read FImage write FImage;
  end;

// Registry updates belong on the UI thread. Each platform has its own namespace.
procedure h5uRegisterEditor(APlatform: Th5uEditorPlatform; const AEditorName: string; AClass: Th5uGridEditorItemClass);
function h5uEditorClass(APlatform: Th5uEditorPlatform; const AEditorName: string): Th5uGridEditorItemClass;
procedure h5uUnregisterEditor(APlatform: Th5uEditorPlatform; const AEditorName: string);
function h5uCreateEditor(APlatform: Th5uEditorPlatform; const AEditorName: string; ACollection: TCollection): Th5uGridEditorItem;
function h5uResolveEditorName(AGrid: TObject; AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ARow: Int64; ADefaults: Th5uDefaultEditors; AGetValue: Th5uGetCellValueMethod;
  out AColumnScoped: Boolean): string;
function h5uEditorCheckBounds(const ABounds: TRectF): TRectF;

implementation

var
  GEditors: array[Th5uEditorPlatform] of TDictionary<string, Th5uGridEditorItemClass>;

procedure h5uRegisterEditor(APlatform: Th5uEditorPlatform; const AEditorName: string; AClass: Th5uGridEditorItemClass);
begin
  if (Trim(AEditorName) = '') or not Assigned(AClass) then
    raise EArgumentException.Create('EditorName und Editor-Klasse sind erforderlich.');
  if not Assigned(GEditors[APlatform]) then GEditors[APlatform] := TDictionary<string, Th5uGridEditorItemClass>.Create;
  GEditors[APlatform].AddOrSetValue(LowerCase(AEditorName), AClass);
end;

function h5uEditorClass(APlatform: Th5uEditorPlatform; const AEditorName: string): Th5uGridEditorItemClass;
begin
  if not Assigned(GEditors[APlatform]) or not GEditors[APlatform].TryGetValue(LowerCase(AEditorName), Result) then
    raise Eh5uGrid.CreateFmt('Editor "%s" ist nicht registriert.', [AEditorName]);
end;

procedure h5uUnregisterEditor(APlatform: Th5uEditorPlatform; const AEditorName: string);
begin
  if Assigned(GEditors[APlatform]) then GEditors[APlatform].Remove(LowerCase(AEditorName));
end;

function h5uCreateEditor(APlatform: Th5uEditorPlatform; const AEditorName: string; ACollection: TCollection): Th5uGridEditorItem;
var
  LClass: Th5uGridEditorItemClass;
begin
  if not Assigned(GEditors[APlatform]) or not GEditors[APlatform].TryGetValue(LowerCase(AEditorName), LClass) then
    raise Eh5uGrid.CreateFmt('Editor "%s" ist nicht registriert.', [AEditorName]);
  Result := LClass.Create(ACollection);
  Result.EditorName := AEditorName;
end;

function h5uResolveEditorName(AGrid: TObject; AColumns: Th5uGridColumns; AColumn: Th5uGridColumn; ARow: Int64; ADefaults: Th5uDefaultEditors; AGetValue: Th5uGetCellValueMethod;
  out AColumnScoped: Boolean): string;
  function FromColumn(const AId: string): string;
  var
    LColumn: Th5uGridColumn;
    LValue: TValue;
  begin
    Result := '';
    if AId = '' then Exit;
    LColumn := AColumns.FindById(AId);
    if not Assigned(LColumn) then
      raise Eh5uGrid.CreateFmt('Editor-Spalte "%s" wurde nicht gefunden.', [AId]);
    LValue := AGetValue(LColumn, ARow, False);
    if not LValue.IsEmpty then Result := Trim(LValue.ToString);
  end;
begin
  Result := '';
  AColumnScoped := False;
  if not Assigned(AColumn) then Exit;
  if Assigned(AColumn.OnGetCellEditor) then AColumn.OnGetCellEditor(AGrid, AColumn, ARow, Result);
  AColumnScoped := Result <> '';
  if Result = '' then Result := FromColumn(AColumn.CellEditorColumnId);
  if (Result = '') and Assigned(AColumn.OnGetRowEditor) then
  begin
    AColumn.OnGetRowEditor(AGrid, AColumn, ARow, Result);
    AColumnScoped := Result <> '';
  end;
  if Result = '' then Result := FromColumn(AColumn.RowEditorColumnId);
  if Result = '' then Result := AColumn.Editor;
  if Result = '' then Result := ADefaults.EditorFor(AColumn);
end;

function h5uEditorCheckBounds(const ABounds: TRectF): TRectF;
begin
  Result := RectF(ABounds.CenterPoint.X - 7.5, ABounds.CenterPoint.Y - 7.5, ABounds.CenterPoint.X + 7.5, ABounds.CenterPoint.Y + 7.5);
end;

function Th5uGridEditors.Find(const AName: string): Th5uGridEditorItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if SameText(Th5uGridEditorItem(Items[I]).EditorName, AName) then Exit(Th5uGridEditorItem(Items[I]));
  Result := nil;
end;

procedure Th5uGridEditorItem.SetEditorName(const AValue: string);
var
  LItem: Th5uGridEditorItem;
begin
  if Collection is Th5uGridEditors then
  begin
    LItem := Th5uGridEditors(Collection).Find(AValue);
    if (AValue <> '') and Assigned(LItem) and (LItem <> Self) then
      raise Eh5uGrid.CreateFmt('EditorName "%s" ist bereits vorhanden.', [AValue]);
  end;
  FEditorName := AValue;
  Changed(False);
end;

procedure Th5uGridEditorItem.SetEditorType(const AValue: string);
begin
  if FEditorType = AValue then Exit;
  FEditorType := AValue;
  Inc(FEditorVersion);
  Changed(False);
end;

function Th5uGridEditorItem.GetDisplayName: string;
begin
  Result := EditorName;
  if Result = '' then Result := inherited;
end;

procedure Th5uGridEditorItem.Assign(Source: TPersistent);
var
  S: Th5uGridEditorItem;
begin
  if not (Source is Th5uGridEditorItem) then begin inherited; Exit; end;
  S := Th5uGridEditorItem(Source);
  EditorName := S.EditorName;
  FEditorType := S.FEditorType;
  Mode := S.Mode;
  ActivateOnClick := S.ActivateOnClick;
  EditorVersion := S.EditorVersion;
  FOnShow := S.FOnShow; FOnHide := S.FOnHide; FOnCancel := S.FOnCancel; FOnCommit := S.FOnCommit;
  FOnChange := S.FOnChange; FOnEnter := S.FOnEnter; FOnExit := S.FOnExit;
  FOnGetText := S.FOnGetText; FOnSetText := S.FOnSetText;
  FOnGetValue := S.FOnGetValue; FOnSetValue := S.FOnSetValue;
  FOnDrawDisplay := S.FOnDrawDisplay; FOnDrawEditor := S.FOnDrawEditor;
  FOnKeyDown := S.FOnKeyDown;
  FOnMouseDown := S.FOnMouseDown; FOnMouseMove := S.FOnMouseMove; FOnMouseUp := S.FOnMouseUp;
end;

procedure Th5uGridEditorItem.BuildEditor;
begin
end;

procedure Th5uGridEditorItem.ReleaseEditor;
begin
end;

procedure Th5uGridEditorItem.BeginEdit(const AContext: Th5uEditorContext);
begin
  if Assigned(AContext.Grid) and (csDesigning in AContext.Grid.ComponentState) then Exit;
  FContext := AContext;
  BuildEditor;
  SetValue(AContext.Value);
  if UsesTextValue then SetText(AContext.Text);
  FOriginalState := State;
  FChangedSinceBegin := False;
end;

procedure Th5uGridEditorItem.Activate;
begin
  Show;
end;

procedure Th5uGridEditorItem.Show;
begin
  FActive := True;
  if Assigned(FOnShow) then FOnShow(Self);
end;

procedure Th5uGridEditorItem.Hide;
begin
  FActive := False;
  if Assigned(FOnHide) then FOnHide(Self);
end;

procedure Th5uGridEditorItem.Cancel;
begin
  Hide;
  if Assigned(FOnCancel) then FOnCancel(Self);
end;

procedure Th5uGridEditorItem.Committed;
begin
  Hide;
  if Assigned(FOnCommit) then FOnCommit(Self);
end;

procedure Th5uGridEditorItem.Focus;
begin
end;

procedure Th5uGridEditorItem.BringToFront;
begin
end;

function Th5uGridEditorItem.UsesTextValue: Boolean;
begin
  Result := Mode = Th5uEditorMode.Text;
end;

function Th5uGridEditorItem.CanAutoEdit: Boolean;
begin
  Result := Mode = Th5uEditorMode.Text;
end;

function Th5uGridEditorItem.DeferExit: Boolean;
begin
  Result := False;
end;

function Th5uGridEditorItem.ReadText: string;
begin
  Result := FText;
end;

procedure Th5uGridEditorItem.WriteText(const AText: string);
begin
  FText := AText;
end;

function Th5uGridEditorItem.ReadValue: TValue;
begin
  if UsesTextValue and Assigned(Context.Column) then Result := h5uParseEditorValue(Context.Column.DataType, GetText)
  else Result := FValue;
end;

procedure Th5uGridEditorItem.WriteValue(const AValue: TValue);
begin
  FValue := AValue;
  WriteText(AValue.ToString);
end;

function Th5uGridEditorItem.GetText: string;
begin
  Result := ReadText;
  if Assigned(FOnGetText) then FOnGetText(Self, Result);
end;

procedure Th5uGridEditorItem.SetText(const AText: string);
var
  LText: string;
begin
  LText := AText;
  if Assigned(FOnSetText) then FOnSetText(Self, LText);
  WriteText(LText);
end;

function Th5uGridEditorItem.GetValue: TValue;
begin
  // A custom value provider can handle values that the standard parser cannot.
  if Assigned(FOnGetValue) then begin Result := FValue; FOnGetValue(Self, Result); end
  else Result := ReadValue;
end;

procedure Th5uGridEditorItem.SetValue(const AValue: TValue);
var
  LValue: TValue;
begin
  LValue := AValue;
  if Assigned(FOnSetValue) then FOnSetValue(Self, LValue);
  WriteValue(LValue);
end;

function Th5uGridEditorItem.State: string;
begin
  if UsesTextValue and not Assigned(FOnGetValue) then Result := GetText else Result := GetValue.ToString;
end;

function Th5uGridEditorItem.Modified: Boolean;
begin
  Result := (State <> FOriginalState) or (FChangedSinceBegin and (not UsesTextValue or Assigned(FOnGetValue)));
end;

function Th5uGridEditorItem.DrawDisplay(const AContext: Th5uEditorContext): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawDisplay) then FOnDrawDisplay(Self, AContext, Result);
end;

function Th5uGridEditorItem.DrawEditor(const AContext: Th5uEditorContext): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawEditor) then FOnDrawEditor(Self, AContext, Result);
  if not Result then Result := DrawDisplay(AContext);
end;

function Th5uGridEditorItem.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  Result := ABounds.Contains(APoint);
end;

procedure Th5uGridEditorItem.Change;
begin
  FChangedSinceBegin := True;
  if Assigned(FOnChange) then FOnChange(Self);
  if Assigned(FChanged) then FChanged(Self);
end;

procedure Th5uGridEditorItem.Enter;
begin
  if Assigned(FOnEnter) then FOnEnter(Self);
end;

procedure Th5uGridEditorItem.ExitEditor;
begin
  if Assigned(FOnExit) then FOnExit(Self);
  if Assigned(FExited) then FExited(Self);
end;

procedure Th5uGridEditorItem.KeyDown(var AKey: Word; var AKeyChar: Char; AShift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, AKey, AKeyChar, AShift);
  if Assigned(FKeyDown) then FKeyDown(Self, AKey, AKeyChar, AShift);
end;

procedure Th5uGridEditorItem.MouseDown(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, AButton, AShift, APoint);
end;

procedure Th5uGridEditorItem.MouseMove(AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, TMouseButton.mbLeft, AShift, APoint);
end;

procedure Th5uGridEditorItem.MouseUp(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, AButton, AShift, APoint);
end;

procedure Th5uGridEditorItem.RequestCommit;
begin
  if Assigned(FRequestCommit) then FRequestCommit(Self);
end;

procedure Th5uGridEditorItem.RequestCancel;
begin
  if Assigned(FRequestCancel) then FRequestCancel(Self);
end;

constructor Th5uDefaultEditors.Create;
begin
  inherited;
  FEdit := 'TextEditor'; FInteger := 'IntegerEditor'; FFloat := 'FloatEditor'; FCurrency := 'CurrencyEditor';
  FDate := 'DateEditor'; FTime := 'TimeEditor'; FDateTime := 'DateTimeEditor';
  FCheckBox := 'CheckBoxEditor'; FImage := 'ImageEditor';
end;

procedure Th5uDefaultEditors.Assign(Source: TPersistent);
var
  S: Th5uDefaultEditors;
begin
  if not (Source is Th5uDefaultEditors) then begin inherited; Exit; end;
  S := Th5uDefaultEditors(Source);
  FEdit := S.FEdit; FInteger := S.FInteger; FFloat := S.FFloat; FCurrency := S.FCurrency;
  FDate := S.FDate; FTime := S.FTime; FDateTime := S.FDateTime; FCheckBox := S.FCheckBox; FImage := S.FImage;
end;

function Th5uDefaultEditors.EditorFor(AColumn: Th5uGridColumn): string;
begin
  case AColumn.EditorKind of
    Th5uColumnEditorKind.None: Exit('None');
    Th5uColumnEditorKind.Text: Exit(FEdit);
    Th5uColumnEditorKind.Date: Exit(FDate);
    Th5uColumnEditorKind.Time: Exit(FTime);
    Th5uColumnEditorKind.DateTime: Exit(FDateTime);
    Th5uColumnEditorKind.Boolean: Exit(FCheckBox);
    Th5uColumnEditorKind.Image: Exit(FImage);
  end;
  Result := DataTypeEditor(AColumn.DataType);
end;

function Th5uDefaultEditors.DataTypeEditor(AType: Th5uColumnDataType): string;
begin
  case AType of
    Th5uColumnDataType.Integer: Result := FInteger;
    Th5uColumnDataType.Float: Result := FFloat;
    Th5uColumnDataType.Currency: Result := FCurrency;
    Th5uColumnDataType.Date: Result := FDate;
    Th5uColumnDataType.Time: Result := FTime;
    Th5uColumnDataType.DateTime: Result := FDateTime;
    Th5uColumnDataType.Boolean: Result := FCheckBox;
    Th5uColumnDataType.Image: Result := FImage;
    else Result := FEdit;
  end;
end;

constructor Th5uGridEditorCache.Create;
begin
  inherited;
  FItems := TCollection.Create(Th5uGridEditorItem);
  FEntries := TDictionary<string, TEntry>.Create;
end;

destructor Th5uGridEditorCache.Destroy;
begin
  FEntries.Free;
  FItems.Free;
  inherited;
end;

procedure Th5uGridEditorCache.Clear;
begin
  FEntries.Clear;
  FItems.Clear;
end;

function Th5uGridEditorCache.Get(APlatform: Th5uEditorPlatform; const AName, AColumnId: string; ATemplate: Th5uGridEditorItem): Th5uGridEditorItem;
var
  K: string;
  E: TEntry;
  C: Th5uGridEditorItemClass;
begin
  if (AColumnId = '') and Assigned(ATemplate) and (ATemplate.EditorType = '') then Exit(ATemplate);
  if Assigned(ATemplate) then
    if ATemplate.EditorType <> '' then C := h5uEditorClass(APlatform, ATemplate.EditorType)
    else C := Th5uGridEditorItemClass(ATemplate.ClassType)
  else C := h5uEditorClass(APlatform, AName);
  // Length prefix prevents collisions between editor and column IDs.
  K := IntToStr(Length(AName)) + ':' + LowerCase(AName) + LowerCase(AColumnId);
  if FEntries.TryGetValue(K, E) then
  begin
    if E.Editor.Active then Exit(E.Editor);
    if (Assigned(E.Template) <> Assigned(ATemplate)) or (E.Editor.ClassType <> C) then
    begin
      FEntries.Remove(K);
      E.Editor.Free;
      Exit(Get(APlatform, AName, AColumnId, ATemplate));
    end;
    if Assigned(ATemplate) and ((E.Template <> ATemplate) or (E.Version <> ATemplate.EditorVersion)) and not E.Editor.Active then
    begin
      E.Editor.Assign(ATemplate);
      E.Template := ATemplate;
      E.Version := ATemplate.EditorVersion;
      FEntries[K] := E;
    end;
    Exit(E.Editor);
  end;
  E := Default(TEntry);
  if Assigned(ATemplate) then
  begin
    E.Editor := C.Create(FItems);
    try
      E.Editor.Assign(ATemplate);
    except
      E.Editor.Free;
      raise;
    end;
    E.Template := ATemplate;
    E.Version := ATemplate.EditorVersion;
  end
  else E.Editor := h5uCreateEditor(APlatform, AName, FItems);
  FEntries.Add(K, E);
  Result := E.Editor;
end;

initialization
finalization
  GEditors[Th5uEditorPlatform.VCL].Free;
  GEditors[Th5uEditorPlatform.FMX].Free;

end.
