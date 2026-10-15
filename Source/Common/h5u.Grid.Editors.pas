unit h5u.Grid.Editors;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Math,
    SysUtils,
    Rtti,
    Types,
    Generics.Collections,
  {$ELSE}
    System.Classes,
    System.Math,
    System.SysUtils,
    System.Rtti,
    System.Types,
    System.UITypes,
    System.Generics.Collections,
  {$ENDIF}
  h5u.Grid.Types,
  h5u.Grid.Sizing,
  h5u.Grid.Columns,
  h5u.Grid.Values;

type
  ThiiEditorMode = (Text, Graphic);
  ThiiEditorPlatform = (VCL, FMX, LCL);

  {$IFDEF FPC}
    Th5uEditorPreparePaint = procedure(APart: ThiiElementPaintPart) of object;
  {$ELSE}
    Th5uEditorPreparePaint = TProc<ThiiElementPaintPart>;
  {$ENDIF}

  ThiiEditorContext = record
    Grid: TComponent;
    Column: ThiiGridColumn;
    RowIndex: Int64;
    RowKey: ThiiRowKey;
    Bounds: TRectF;
    Value: TValue;
    Text: string;
    // Native canvas and cached image: Common does not depend on either UI library.
    Canvas: TObject;
    Image: TObject;
    Foreground: TAlphaColor;
    Background: TAlphaColor;
    PreparePaint: Th5uEditorPreparePaint;
  end;

  ThiiEditorMeasureWidthEvent = procedure(Sender: TObject; const AContext: ThiiEditorContext; var AWidth: Single) of object;
  ThiiEditorTextEvent = procedure(Sender: TObject; var AText: string) of object;
  ThiiEditorValueEvent = procedure(Sender: TObject; var AValue: TValue) of object;
  ThiiEditorDrawEvent = procedure(Sender: TObject; const AContext: ThiiEditorContext; var AHandled: Boolean) of object;
  ThiiEditorKeyEvent = procedure(Sender: TObject; var AKey: Word; var AKeyChar: Char; AShift: TShiftState) of object;
  ThiiEditorPointerEvent = procedure(Sender: TObject; AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF) of object;

  ThiiGridEditorItem = class(TCollectionItem)
  private
    FEditorName: string;
    FEditorType: string;
    FEditorVersion: Integer;
    FDefaultWidth, FDefaultMaxWidth: ThiiWidth;
    FDefaultMinWidth: Single;
    FMode: ThiiEditorMode;
    FActivateOnClick: Boolean;
    FContext: ThiiEditorContext;
    FValue: TValue;
    FText: string;
    FOriginalState: string;
    FActive: Boolean;
    FChangedSinceBegin: Boolean;
    FOnShow, FOnHide, FOnCancel, FOnCommit, FOnChange, FOnEnter, FOnExit: TNotifyEvent;
    FOnGetText, FOnSetText: ThiiEditorTextEvent;
    FOnGetValue, FOnSetValue: ThiiEditorValueEvent;
    FOnDrawDisplay, FOnDrawEditor: ThiiEditorDrawEvent;
    FOnMeasureWidth: ThiiEditorMeasureWidthEvent;
    FOnKeyDown: ThiiEditorKeyEvent;
    FOnMouseDown, FOnMouseMove, FOnMouseUp: ThiiEditorPointerEvent;
    FRequestCommit, FRequestCancel, FChanged, FExited: TNotifyEvent;
    FKeyDown: ThiiEditorKeyEvent;
    procedure SetEditorName(const AValue: string);
    procedure SetDefaultWidth(const AValue: ThiiWidth);
    procedure SetDefaultMinWidth(const AValue: Single);
    procedure SetDefaultMaxWidth(const AValue: ThiiWidth);
  protected
    procedure SetEditorType(const AValue: string); virtual;
    function GetDisplayName: string; override;
    function ReadText: string; virtual;
    procedure WriteText(const AText: string); virtual;
    function ReadValue: TValue; virtual;
    procedure WriteValue(const AValue: TValue); virtual;
    function State: string; virtual;
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; virtual;
    procedure ReleaseEditor; virtual;
    procedure BeginEdit(const AContext: ThiiEditorContext); virtual;
    procedure UpdateBounds(const ABounds: TRectF); virtual;
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
    // Measurement does not activate an editor or change its current value.
    function MeasureWidth(const AContext: ThiiEditorContext): Single; virtual;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; virtual;
    function DrawEditor(const AContext: ThiiEditorContext): Boolean; virtual;
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
    property Context: ThiiEditorContext read FContext;
    property Active: Boolean read FActive;
    property OnRequestCommit: TNotifyEvent read FRequestCommit write FRequestCommit;
    property OnRequestCancel: TNotifyEvent read FRequestCancel write FRequestCancel;
    property OnChanged: TNotifyEvent read FChanged write FChanged;
    property OnExited: TNotifyEvent read FExited write FExited;
    property OnProcessKey: ThiiEditorKeyEvent read FKeyDown write FKeyDown;
  published
    property EditorType: string read FEditorType write SetEditorType;
    property EditorName: string read FEditorName write SetEditorName;
    property ActivateOnClick: Boolean read FActivateOnClick write FActivateOnClick default False;
    property EditorVersion: Integer read FEditorVersion write FEditorVersion default 0;
    property DefaultWidth: ThiiWidth read FDefaultWidth write SetDefaultWidth nodefault;
    property DefaultMinWidth: Single read FDefaultMinWidth write SetDefaultMinWidth nodefault;
    property DefaultMaxWidth: ThiiWidth read FDefaultMaxWidth write SetDefaultMaxWidth nodefault;
    property Mode: ThiiEditorMode read FMode write FMode default ThiiEditorMode.Text;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
    property OnCommit: TNotifyEvent read FOnCommit write FOnCommit;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnGetText: ThiiEditorTextEvent read FOnGetText write FOnGetText;
    property OnSetText: ThiiEditorTextEvent read FOnSetText write FOnSetText;
    property OnGetValue: ThiiEditorValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiEditorValueEvent read FOnSetValue write FOnSetValue;
    property OnMeasureWidth: ThiiEditorMeasureWidthEvent read FOnMeasureWidth write FOnMeasureWidth;
    property OnDrawDisplay: ThiiEditorDrawEvent read FOnDrawDisplay write FOnDrawDisplay;
    property OnDrawEditor: ThiiEditorDrawEvent read FOnDrawEditor write FOnDrawEditor;
    property OnKeyDown: ThiiEditorKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnMouseDown: ThiiEditorPointerEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: ThiiEditorPointerEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: ThiiEditorPointerEvent read FOnMouseUp write FOnMouseUp;
  end;
  ThiiGridEditorItemClass = class of ThiiGridEditorItem;

  ThiiGridEditors = class(TOwnedCollection)
  private
    FOnChanged: TNotifyEvent;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Find(const AName: string): ThiiGridEditorItem;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  Th5uGridEditorCache = class
  private type
    TEntry = record
      Editor: ThiiGridEditorItem;
      Template: ThiiGridEditorItem;
      Version: Integer;
    end;
  private
    FItems: TCollection;
    FEntries: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TEntry>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Get(APlatform: ThiiEditorPlatform; const AName, AColumnId: string; ATemplate: ThiiGridEditorItem): ThiiGridEditorItem;
  end;

  ThiiDefaultEditors = class(TPersistent)
  private
    FEdit, FInteger, FFloat, FCurrency, FDate, FTime, FDateTime, FCheckBox, FImage: string;
    FOnChanged: TNotifyEvent;
    function GetEditor(AIndex: Integer): string;
    procedure SetEditor(AIndex: Integer; const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function DataTypeEditor(AType: ThiiColumnDataType): string;
    function EditorFor(AColumn: ThiiGridColumn): string;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    {$IFnDEF FPC} [Default('TextEditor')] {$ENDIF}
    property Edit: string index 0 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('IntegerEditor')] {$ENDIF}
    property Integer: string index 1 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('FloatEditor')] {$ENDIF}
    property Float: string index 2 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('CurrencyEditor')] {$ENDIF}
    property Currency: string index 3 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('DateEditor')] {$ENDIF}
    property Date: string index 4 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('TimeEditor')] {$ENDIF}
    property Time: string index 5 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('DateTimeEditor')] {$ENDIF}
    property DateTime: string index 6 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('CheckBoxEditor')] {$ENDIF}
    property CheckBox: string index 7 read GetEditor write SetEditor;
    {$IFnDEF FPC} [Default('ImageEditor')] {$ENDIF}
    property Image: string index 8 read GetEditor write SetEditor;
  end;

// Registry updates belong on the UI thread. Each platform has its own namespace.
procedure h5uRegisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; AClass: ThiiGridEditorItemClass);
function h5uEditorClass(APlatform: ThiiEditorPlatform; const AEditorName: string): ThiiGridEditorItemClass;
procedure h5uUnregisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string); overload;
// Remove only the registering module's class; keep replacements from other modules.
procedure h5uUnregisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; AExpectedClass: ThiiGridEditorItemClass); overload;
function h5uCreateEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; ACollection: TCollection): ThiiGridEditorItem;
function h5uResolveEditorName(AGrid: TObject; AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; ARow: Int64; ADefaults: ThiiDefaultEditors; AGetValue: Th5uGetCellValueMethod;
  out AColumnScoped: Boolean): string;
function h5uEditorCheckBounds(const ABounds: TRectF): TRectF;

procedure h5uResolveColumnWidthDefaults(AColumn: ThiiGridColumn; AOptions: ThiiColumnSizingOptions; AEditors: ThiiGridEditors; ADefaultEditors: ThiiDefaultEditors;
  AReferenceWidth, AMonitorWidth: Single);

implementation

procedure h5uResolveColumnWidthDefaults(AColumn: ThiiGridColumn; AOptions: ThiiColumnSizingOptions; AEditors: ThiiGridEditors; ADefaultEditors: ThiiDefaultEditors;
  AReferenceWidth, AMonitorWidth: Single);
var
  Editor: ThiiGridEditorItem;
  EditorName, EditorType: string;
  Width, MaxWidth: Single;
  MinWidth: Single;
  IsCheckBox: Boolean;
begin
  EditorName := AColumn.Editor;
  if EditorName = '' then
    EditorName := ADefaultEditors.EditorFor(AColumn);
  Editor := AEditors.Find(EditorName);
  EditorType := EditorName;
  if Assigned(Editor) and (Editor.EditorType <> '') then
    EditorType := Editor.EditorType;
  IsCheckBox := SameText(EditorType, 'CheckBoxEditor');
  Width := 100;
  MinWidth := 24;
  MaxWidth := 3000;
  if IsCheckBox then
  begin
    Width := 28;
    MinWidth := 28;
    MaxWidth := 28;
  end
  else if AOptions.MaxWidthSource = ThiiMaxWidthSource.Monitor then
    MaxWidth := Max(1.0, AMonitorWidth);
  if Assigned(Editor) then
  begin
    if Editor.DefaultWidth <> 0 then
      Width := Editor.DefaultWidth;
    if Editor.DefaultMinWidth <> 0 then
      MinWidth := Editor.DefaultMinWidth;
    if Editor.DefaultMaxWidth <> 0 then
      MaxWidth := Editor.DefaultMaxWidth;
  end;
  if AOptions.DefaultWidth <> 0 then
    Width := AOptions.DefaultWidth;
  if AOptions.DefaultMinWidth <> 0 then
    MinWidth := AOptions.DefaultMinWidth;
  if AOptions.DefaultMaxWidth <> 0 then
    MaxWidth := AOptions.DefaultMaxWidth;
  AColumn.SetWidthDefaults(Width, MinWidth, MaxWidth, AReferenceWidth);
end;

procedure ThiiGridEditorItem.SetDefaultWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultWidth = AValue then
    Exit;
  FDefaultWidth := AValue;
  Inc(FEditorVersion);
  Changed(False);
end;

procedure ThiiGridEditors.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiGridEditorItem.SetDefaultMinWidth(const AValue: Single);
begin
  h5uValidateWidth(AValue);
  if FDefaultMinWidth = Max(0, AValue) then
    Exit;
  FDefaultMinWidth := Max(0, AValue);
  Inc(FEditorVersion);
  Changed(False);
end;

procedure ThiiGridEditorItem.SetDefaultMaxWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultMaxWidth = AValue then
    Exit;
  FDefaultMaxWidth := AValue;
  Inc(FEditorVersion);
  Changed(False);
end;

var
  GEditors: array[ThiiEditorPlatform] of {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, ThiiGridEditorItemClass>;

procedure h5uRegisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; AClass: ThiiGridEditorItemClass);
begin
  if (Trim(AEditorName) = '') or not Assigned(AClass) then
    raise EArgumentException.Create('EditorName und Editor-Klasse sind erforderlich.');
  if not Assigned(GEditors[APlatform]) then
    GEditors[APlatform] := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, ThiiGridEditorItemClass>.Create;
  GEditors[APlatform].AddOrSetValue(LowerCase(AEditorName), AClass);
end;

function h5uEditorClass(APlatform: ThiiEditorPlatform; const AEditorName: string): ThiiGridEditorItemClass;
begin
  if not Assigned(GEditors[APlatform]) or not GEditors[APlatform].TryGetValue(LowerCase(AEditorName), Result) then
    raise EhiiGrid.CreateFmt('Editor "%s" ist nicht registriert.', [AEditorName]);
end;

procedure h5uUnregisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string);
begin
  h5uUnregisterEditor(APlatform, AEditorName, nil);
end;

procedure h5uUnregisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; AExpectedClass: ThiiGridEditorItemClass);
var
  LClass: ThiiGridEditorItemClass;
begin
  if not Assigned(GEditors[APlatform]) then
    Exit;
  if Assigned(AExpectedClass) then
    if not GEditors[APlatform].TryGetValue(LowerCase(AEditorName), LClass) or (LClass <> AExpectedClass) then
      Exit;
  GEditors[APlatform].Remove(LowerCase(AEditorName));
end;

function h5uCreateEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; ACollection: TCollection): ThiiGridEditorItem;
var
  LClass: ThiiGridEditorItemClass;
begin
  if not Assigned(GEditors[APlatform]) or not GEditors[APlatform].TryGetValue(LowerCase(AEditorName), LClass) then
    raise EhiiGrid.CreateFmt('Editor "%s" ist nicht registriert.', [AEditorName]);
  Result := LClass.Create(ACollection);
  Result.EditorName := AEditorName;
end;

function h5uResolveEditorName(AGrid: TObject; AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; ARow: Int64; ADefaults: ThiiDefaultEditors; AGetValue: Th5uGetCellValueMethod;
  out AColumnScoped: Boolean): string;
  function FromColumn(const AId: string): string;
  var
    LColumn: ThiiGridColumn;
    LValue: TValue;
  begin
    Result := '';
    if AId = '' then
      Exit;
    LColumn := AColumns.FindById(AId);
    if not Assigned(LColumn) then
      raise EhiiGrid.CreateFmt('Editor-Spalte "%s" wurde nicht gefunden.', [AId]);
    LValue := AGetValue(LColumn, ARow, False);
    if not LValue.IsEmpty then
      Result := Trim({$IFDEF FPC}h5uValueAsText(LValue){$ELSE}LValue.ToString{$ENDIF});
  end;
begin
  Result := '';
  AColumnScoped := False;
  if not Assigned(AColumn) then
    Exit;
  if Assigned(AColumn.OnGetCellEditor) then
    AColumn.OnGetCellEditor(AGrid, AColumn, ARow, Result);
  AColumnScoped := Result <> '';
  if Result = '' then
    Result := FromColumn(AColumn.CellEditorColumnId);
  if (Result = '') and Assigned(AColumn.OnGetRowEditor) then
  begin
    AColumn.OnGetRowEditor(AGrid, AColumn, ARow, Result);
    AColumnScoped := Result <> '';
  end;
  if Result = '' then
    Result := FromColumn(AColumn.RowEditorColumnId);
  if Result = '' then
    Result := AColumn.Editor;
  if Result = '' then
    Result := ADefaults.EditorFor(AColumn);
end;

function h5uEditorCheckBounds(const ABounds: TRectF): TRectF;
begin
  {$IFDEF FPC}
    Result.Left := (ABounds.Left + ABounds.Right) / 2 - 7.5;
    Result.Top := (ABounds.Top + ABounds.Bottom) / 2 - 7.5;
    Result.Right := Result.Left + 15;
    Result.Bottom := Result.Top + 15;
  {$ELSE}
    Result := RectF(ABounds.CenterPoint.X - 7.5, ABounds.CenterPoint.Y - 7.5, ABounds.CenterPoint.X + 7.5, ABounds.CenterPoint.Y + 7.5);
  {$ENDIF}
end;

function ThiiGridEditors.Find(const AName: string): ThiiGridEditorItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if SameText(ThiiGridEditorItem(Items[I]).EditorName, AName) then
      Exit(ThiiGridEditorItem(Items[I]));
  Result := nil;
end;

procedure ThiiGridEditorItem.SetEditorName(const AValue: string);
var
  LItem: ThiiGridEditorItem;
begin
  if Collection is ThiiGridEditors then
  begin
    LItem := ThiiGridEditors(Collection).Find(AValue);
    if (AValue <> '') and Assigned(LItem) and (LItem <> Self) then
      raise EhiiGrid.CreateFmt('EditorName "%s" ist bereits vorhanden.', [AValue]);
  end;
  FEditorName := AValue;
  Changed(False);
end;

procedure ThiiGridEditorItem.SetEditorType(const AValue: string);
begin
  if FEditorType = AValue then
    Exit;
  FEditorType := AValue;
  Inc(FEditorVersion);
  Changed(False);
end;

function ThiiGridEditorItem.GetDisplayName: string;
begin
  Result := EditorName;
  if Result = '' then
    Result := inherited;
end;

procedure ThiiGridEditorItem.Assign(Source: TPersistent);
var
  S: ThiiGridEditorItem;
begin
  if not (Source is ThiiGridEditorItem) then
  begin
    inherited;
    Exit;
  end;
  S := ThiiGridEditorItem(Source);
  EditorName := S.EditorName;
  FEditorType := S.FEditorType;
  FDefaultWidth := S.FDefaultWidth;
  FDefaultMinWidth := S.FDefaultMinWidth;
  FDefaultMaxWidth := S.FDefaultMaxWidth;
  Mode := S.Mode;
  ActivateOnClick := S.ActivateOnClick;
  EditorVersion := S.EditorVersion;
  FOnShow := S.FOnShow;
  FOnHide := S.FOnHide;
  FOnCancel := S.FOnCancel;
  FOnCommit := S.FOnCommit;
  FOnChange := S.FOnChange;
  FOnEnter := S.FOnEnter;
  FOnExit := S.FOnExit;
  FOnGetText := S.FOnGetText;
  FOnSetText := S.FOnSetText;
  FOnGetValue := S.FOnGetValue;
  FOnSetValue := S.FOnSetValue;
  FOnMeasureWidth := S.FOnMeasureWidth;
  FOnDrawDisplay := S.FOnDrawDisplay;
  FOnDrawEditor := S.FOnDrawEditor;
  FOnKeyDown := S.FOnKeyDown;
  FOnMouseDown := S.FOnMouseDown;
  FOnMouseMove := S.FOnMouseMove;
  FOnMouseUp := S.FOnMouseUp;
end;

procedure ThiiGridEditorItem.BuildEditor;
begin
end;

procedure ThiiGridEditorItem.ReleaseEditor;
begin
end;

procedure ThiiGridEditorItem.BeginEdit(const AContext: ThiiEditorContext);
begin
  if Assigned(AContext.Grid) and (csDesigning in AContext.Grid.ComponentState) then
    Exit;
  FContext := AContext;
  BuildEditor;
  SetValue(AContext.Value);
  if UsesTextValue then
    SetText(AContext.Text);
  FOriginalState := State;
  FChangedSinceBegin := False;
end;

procedure ThiiGridEditorItem.UpdateBounds(const ABounds: TRectF);
begin
  FContext.Bounds := ABounds;
end;

procedure ThiiGridEditorItem.Activate;
begin
  Show;
end;

procedure ThiiGridEditorItem.Show;
begin
  FActive := True;
  if Assigned(FOnShow) then
    FOnShow(Self);
end;

procedure ThiiGridEditorItem.Hide;
begin
  FActive := False;
  if Assigned(FOnHide) then
    FOnHide(Self);
end;

procedure ThiiGridEditorItem.Cancel;
begin
  Hide;
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;

procedure ThiiGridEditorItem.Committed;
begin
  Hide;
  if Assigned(FOnCommit) then
    FOnCommit(Self);
end;

procedure ThiiGridEditorItem.Focus;
begin
end;

procedure ThiiGridEditorItem.BringToFront;
begin
end;

function ThiiGridEditorItem.UsesTextValue: Boolean;
begin
  Result := Mode = ThiiEditorMode.Text;
end;

function ThiiGridEditorItem.CanAutoEdit: Boolean;
begin
  Result := Mode = ThiiEditorMode.Text;
end;

function ThiiGridEditorItem.DeferExit: Boolean;
begin
  Result := False;
end;

function ThiiGridEditorItem.ReadText: string;
begin
  Result := FText;
end;

procedure ThiiGridEditorItem.WriteText(const AText: string);
begin
  FText := AText;
end;

function ThiiGridEditorItem.ReadValue: TValue;
begin
  if UsesTextValue and Assigned(Context.Column) then
    Result := h5uParseEditorValue(Context.Column.DataType, GetText)
  else
    Result := FValue;
end;

procedure ThiiGridEditorItem.WriteValue(const AValue: TValue);
begin
  FValue := AValue;
  WriteText({$IFDEF FPC}h5uValueAsText(AValue){$ELSE}AValue.ToString{$ENDIF});
end;

function ThiiGridEditorItem.GetText: string;
begin
  Result := ReadText;
  if Assigned(FOnGetText) then
    FOnGetText(Self, Result);
end;

procedure ThiiGridEditorItem.SetText(const AText: string);
var
  LText: string;
begin
  LText := AText;
  if Assigned(FOnSetText) then
    FOnSetText(Self, LText);
  WriteText(LText);
end;

function ThiiGridEditorItem.GetValue: TValue;
begin
  // A custom value provider can handle values that the standard parser cannot.
  if Assigned(FOnGetValue) then
  begin
    Result := FValue;
    FOnGetValue(Self, Result);
  end
  else
    Result := ReadValue;
end;

procedure ThiiGridEditorItem.SetValue(const AValue: TValue);
var
  LValue: TValue;
begin
  LValue := AValue;
  if Assigned(FOnSetValue) then
    FOnSetValue(Self, LValue);
  WriteValue(LValue);
end;

function ThiiGridEditorItem.State: string;
begin
  if UsesTextValue and not Assigned(FOnGetValue) then
    Result := GetText
  else
    Result := {$IFDEF FPC}h5uValueAsText(GetValue){$ELSE}GetValue.ToString{$ENDIF};
end;

function ThiiGridEditorItem.Modified: Boolean;
begin
  Result := (State <> FOriginalState) or (FChangedSinceBegin and (not UsesTextValue or Assigned(FOnGetValue)));
end;

function ThiiGridEditorItem.MeasureContentWidth(const AContext: ThiiEditorContext): Single;
begin
  Result := -1;
end;

function ThiiGridEditorItem.MeasureWidth(const AContext: ThiiEditorContext): Single;
begin
  Result := MeasureContentWidth(AContext);
  if Assigned(FOnMeasureWidth) then
    FOnMeasureWidth(Self, AContext, Result);
end;

function ThiiGridEditorItem.DrawDisplay(const AContext: ThiiEditorContext): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawDisplay) then
    FOnDrawDisplay(Self, AContext, Result);
end;

function ThiiGridEditorItem.DrawEditor(const AContext: ThiiEditorContext): Boolean;
begin
  Result := False;
  if Assigned(FOnDrawEditor) then
    FOnDrawEditor(Self, AContext, Result);
  if not Result then
    Result := DrawDisplay(AContext);
end;

function ThiiGridEditorItem.HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean;
begin
  {$IFDEF FPC}
    Result := (APoint.X >= ABounds.Left) and (APoint.X < ABounds.Right) and (APoint.Y >= ABounds.Top) and (APoint.Y < ABounds.Bottom);
  {$ELSE}
    Result := ABounds.Contains(APoint);
  {$ENDIF};
end;

procedure ThiiGridEditorItem.Change;
begin
  FChangedSinceBegin := True;
  if Assigned(FOnChange) then
    FOnChange(Self);
  if Assigned(FChanged) then
    FChanged(Self);
end;

procedure ThiiGridEditorItem.Enter;
begin
  if Assigned(FOnEnter) then
    FOnEnter(Self);
end;

procedure ThiiGridEditorItem.ExitEditor;
begin
  if Assigned(FOnExit) then
    FOnExit(Self);
  if Assigned(FExited) then
    FExited(Self);
end;

procedure ThiiGridEditorItem.KeyDown(var AKey: Word; var AKeyChar: Char; AShift: TShiftState);
begin
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, AKey, AKeyChar, AShift);
  if Assigned(FKeyDown) then
    FKeyDown(Self, AKey, AKeyChar, AShift);
end;

procedure ThiiGridEditorItem.MouseDown(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, AButton, AShift, APoint);
end;

procedure ThiiGridEditorItem.MouseMove(AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, TMouseButton.mbLeft, AShift, APoint);
end;

procedure ThiiGridEditorItem.MouseUp(AButton: TMouseButton; AShift: TShiftState; const APoint: TPointF);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, AButton, AShift, APoint);
end;

procedure ThiiGridEditorItem.RequestCommit;
begin
  if Assigned(FRequestCommit) then
    FRequestCommit(Self);
end;

procedure ThiiGridEditorItem.RequestCancel;
begin
  if Assigned(FRequestCancel) then
    FRequestCancel(Self);
end;

function ThiiDefaultEditors.GetEditor(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := FEdit;
    1: Result := FInteger;
    2: Result := FFloat;
    3: Result := FCurrency;
    4: Result := FDate;
    5: Result := FTime;
    6: Result := FDateTime;
    7: Result := FCheckBox;
    8: Result := FImage;
  end;
end;

procedure ThiiDefaultEditors.SetEditor(AIndex: Integer; const AValue: string);
begin
  if GetEditor(AIndex) = AValue then
    Exit;
  case AIndex of
    0: FEdit := AValue;
    1: FInteger := AValue;
    2: FFloat := AValue;
    3: FCurrency := AValue;
    4: FDate := AValue;
    5: FTime := AValue;
    6: FDateTime := AValue;
    7: FCheckBox := AValue;
    8: FImage := AValue;
  end;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiDefaultEditors.Create;
begin
  inherited;
  FEdit := 'TextEditor';
  FInteger := 'IntegerEditor';
  FFloat := 'FloatEditor';
  FCurrency := 'CurrencyEditor';
  FDate := 'DateEditor';
  FTime := 'TimeEditor';
  FDateTime := 'DateTimeEditor';
  FCheckBox := 'CheckBoxEditor';
  FImage := 'ImageEditor';
end;

procedure ThiiDefaultEditors.Assign(Source: TPersistent);
var
  S: ThiiDefaultEditors;
begin
  if not (Source is ThiiDefaultEditors) then
  begin
    inherited;
    Exit;
  end;
  S := ThiiDefaultEditors(Source);
  FEdit := S.FEdit;
  FInteger := S.FInteger;
  FFloat := S.FFloat;
  FCurrency := S.FCurrency;
  FDate := S.FDate;
  FTime := S.FTime;
  FDateTime := S.FDateTime;
  FCheckBox := S.FCheckBox;
  FImage := S.FImage;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

function ThiiDefaultEditors.EditorFor(AColumn: ThiiGridColumn): string;
begin
  case AColumn.EditorKind of
    ThiiColumnEditorKind.None: Exit('None');
    ThiiColumnEditorKind.Text: Exit(FEdit);
    ThiiColumnEditorKind.Date: Exit(FDate);
    ThiiColumnEditorKind.Time: Exit(FTime);
    ThiiColumnEditorKind.DateTime: Exit(FDateTime);
    ThiiColumnEditorKind.Boolean: Exit(FCheckBox);
    ThiiColumnEditorKind.Image: Exit(FImage);
  end;
  Result := DataTypeEditor(AColumn.DataType);
end;

function ThiiDefaultEditors.DataTypeEditor(AType: ThiiColumnDataType): string;
begin
  case AType of
    ThiiColumnDataType.Integer: Result := FInteger;
    ThiiColumnDataType.Float: Result := FFloat;
    ThiiColumnDataType.Currency: Result := FCurrency;
    ThiiColumnDataType.Date: Result := FDate;
    ThiiColumnDataType.Time: Result := FTime;
    ThiiColumnDataType.DateTime: Result := FDateTime;
    ThiiColumnDataType.Boolean: Result := FCheckBox;
    ThiiColumnDataType.Image: Result := FImage;
    else Result := FEdit;
  end;
end;

constructor Th5uGridEditorCache.Create;
begin
  inherited;
  FItems := TCollection.Create(ThiiGridEditorItem);
  FEntries := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TEntry>.Create;
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

function Th5uGridEditorCache.Get(APlatform: ThiiEditorPlatform; const AName, AColumnId: string; ATemplate: ThiiGridEditorItem): ThiiGridEditorItem;
var
  K: string;
  E: TEntry;
  C: ThiiGridEditorItemClass;
begin
  if (AColumnId = '') and Assigned(ATemplate) and (ATemplate.EditorType = '') then
    Exit(ATemplate);
  if Assigned(ATemplate) then
    if ATemplate.EditorType <> '' then
      C := h5uEditorClass(APlatform, ATemplate.EditorType)
    else
      C := ThiiGridEditorItemClass(ATemplate.ClassType)
  else
    C := h5uEditorClass(APlatform, AName);
  // Length prefix prevents collisions between editor and column IDs.
  K := IntToStr(Length(AName)) + ':' + LowerCase(AName) + LowerCase(AColumnId);
  if FEntries.TryGetValue(K, E) then
  begin
    if E.Editor.Active then
      Exit(E.Editor);
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
  else
    E.Editor := h5uCreateEditor(APlatform, AName, FItems);
  FEntries.Add(K, E);
  Result := E.Editor;
end;

initialization

finalization
  GEditors[ThiiEditorPlatform.VCL].Free;
  GEditors[ThiiEditorPlatform.FMX].Free;

end.

