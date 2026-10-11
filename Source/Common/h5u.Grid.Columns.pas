unit h5u.Grid.Columns;

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
    Rtti,
    Generics.Defaults,
    Generics.Collections,
    Math,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Rtti,
    System.Generics.Defaults,
    System.Generics.Collections,
    System.Math,
    System.SysUtils,
    System.UITypes,
  {$ENDIF}
  h5u.Grid.Sizing,
  h5u.Grid.Types;

type
  ThiiGridColumn = class;
  ThiiGridColumns = class;
  ThiiHeaderLayout = class;

  ThiiCellEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64) of object;
  ThiiCellPermissionEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AAllow: Boolean) of object;
  ThiiCellGetValueEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean) of object;
  ThiiCellSetValueEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue) of object;
  ThiiCellValidateEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; var AValid: Boolean; var AErrorText: string) of object;
  ThiiGetColumnModeEvent = procedure(AColumn: ThiiGridColumn; var AMode: string) of object;
  ThiiGetCellEditorEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AEditorName: string) of object;
  ThiiColumnChangedEvent = procedure(Sender: TObject; AColumn: ThiiGridColumn) of object;

  ThiiGridColumn = class(TCollectionItem)
  private
    FId: string;
    FCaption: string;
    FFieldName: string;
    FWidth: ThiiWidth;
    FAutoWidth: Boolean;
    FDefaultWidth, FDefaultMaxWidth, FReferenceWidth: Single;
    FDefaultMinWidth: Single;
    FWidthSpecified, FMinWidthSpecified, FMaxWidthSpecified: Boolean;
    FLegacyWidthInPercent: Single;
    FLayoutWidth: Single;
    FMeasuredWidth: Single;
    FMinWidth: Single;
    FMaxWidth: ThiiWidth;
    FVisible: Boolean;
    FVisibleIndex: Integer;
    FFixedKind: ThiiFixedKind;
    FReadOnly: Boolean;
    FDataType: ThiiColumnDataType;
    FEditorKind: ThiiColumnEditorKind;
    FEditor, FCellEditorColumnId, FRowEditorColumnId: string;
    FOnGetCellEditor, FOnGetRowEditor: ThiiGetCellEditorEvent;
    FWordWrap: Boolean;
    FAutoHeight: Boolean;
    FMaxAutoHeight: Single;
    FMaxLines: Integer;
    FScrollHintText: string;
    FDisplayFormat: string;
    FStyleName: string;
    FHeaderStyleName: string;
    FHighlighted: Boolean;
    FRightSpacing: Single;
    FColor: TColor;
    FClassId: ThiiClassId;
    FCellClassId: ThiiClassId;
    FHeaderCellClassId: ThiiClassId;
    FMovePermission: ThiiColumnMovePermission;
    FCanHide: Boolean;
    FCanResize: Boolean;
    FCanSelect: Boolean;
    FShowInColumnChooser: Boolean;
    FImagePreserveAspectRatio: Boolean;
    FOnCanFocus: ThiiCellPermissionEvent;
    FOnCanEdit: ThiiCellPermissionEvent;
    FOnValidate: ThiiCellValidateEvent;
    FOnGetValue: ThiiCellGetValueEvent;
    FOnSetValue: ThiiCellSetValueEvent;
    FOnCellClick: ThiiCellEvent;
    FOnColumnHeaderClick: ThiiCellEvent;
    FOnCellEnter: ThiiCellEvent;
    FOnCellExit: ThiiCellEvent;
    procedure Changed;
    procedure SetCaption(const AValue: string);
    procedure SetFieldName(const AValue: string);
    procedure SetFixedKind(const AValue: ThiiFixedKind);
    procedure SetId(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetRightSpacing(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
    procedure SetVisibleIndex(const AValue: Integer);
    procedure SetWidth(const AValue: ThiiWidth);
    procedure SetAutoWidth(const AValue: Boolean);
    procedure SetWidthInPercent(const AValue: Single);
    procedure SetMinWidth(const AValue: Single);
    procedure SetMaxWidth(const AValue: ThiiWidth);
    procedure SetMaxAutoHeight(const AValue: Single);
    function GetWidthInPercent: Single;
    function GetWidthSpecification: Single;
    function GetMaxWidthSpecification: Single;
    function GetResolvedWidth: Single;
    function GetResolvedMinWidth: Single;
    function GetResolvedMaxWidth: Single;
    function IsMinWidthStored: Boolean;
    procedure ReadLegacyWidthInPercent(AReader: TReader);
    function GetLayoutWidth: Single;
    procedure SetMovePermission(AValue: ThiiColumnMovePermission);
  protected
    procedure DefineProperties(AFiler: TFiler); override;
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function GetMode: string;
    function ConstrainWidth(AValue: Single): Single;
    procedure SetWidthDefaults(AWidth: Single; AMinWidth: Single; AMaxWidth, AReferenceWidth: Single);
    procedure SetWidthReference(AReferenceWidth: Single);
    procedure ApplyLegacySizing;
    property WidthSpecification: Single read GetWidthSpecification;
    property MaxWidthSpecification: Single read GetMaxWidthSpecification;
    property ResolvedWidth: Single read GetResolvedWidth;
    property ResolvedMinWidth: Single read GetResolvedMinWidth;
    property ResolvedMaxWidth: Single read GetResolvedMaxWidth;
    property WidthInPercent: Single read GetWidthInPercent write SetWidthInPercent;
    procedure SetLayoutWidth(AValue: Single);
    procedure SetMeasuredWidth(AValue: Single);
    property LayoutWidth: Single read GetLayoutWidth;
    property MeasuredWidth: Single read FMeasuredWidth;
    function GetColumns: ThiiGridColumns;
    property Columns: ThiiGridColumns read GetColumns;
  published
    property Id: string read FId write SetId;
    property Caption: string read FCaption write SetCaption;
    property FieldName: string read FFieldName write SetFieldName;
    property Width: ThiiWidth read FWidth write SetWidth;
    property AutoWidth: Boolean read FAutoWidth write SetAutoWidth default False;
    property MinWidth: Single read FMinWidth write SetMinWidth stored IsMinWidthStored nodefault;
    property MaxWidth: ThiiWidth read FMaxWidth write SetMaxWidth;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleIndex: Integer read FVisibleIndex write SetVisibleIndex default -1;
    property FixedKind: ThiiFixedKind read FFixedKind write SetFixedKind default ThiiFixedKind.None;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property DataType: ThiiColumnDataType read FDataType write FDataType default ThiiColumnDataType.Auto;
    property Editor: string read FEditor write FEditor;
    property CellEditorColumnId: string read FCellEditorColumnId write FCellEditorColumnId;
    property RowEditorColumnId: string read FRowEditorColumnId write FRowEditorColumnId;
    property OnGetCellEditor: ThiiGetCellEditorEvent read FOnGetCellEditor write FOnGetCellEditor;
    property OnGetRowEditor: ThiiGetCellEditorEvent read FOnGetRowEditor write FOnGetRowEditor;
    property EditorKind: ThiiColumnEditorKind read FEditorKind write FEditorKind default ThiiColumnEditorKind.Automatic;
    property WordWrap: Boolean read FWordWrap write FWordWrap default False;
    property AutoHeight: Boolean read FAutoHeight write FAutoHeight default False;
    property MaxAutoHeight: Single read FMaxAutoHeight write SetMaxAutoHeight nodefault;
    property MaxLines: Integer read FMaxLines write FMaxLines default 0;
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat;
    property ScrollHintText: string read FScrollHintText write FScrollHintText;
    property StyleName: string read FStyleName write FStyleName;
    property HeaderStyleName: string read FHeaderStyleName write FHeaderStyleName;
    property Highlighted: Boolean read FHighlighted write FHighlighted default False;
    property RightSpacing: Single read FRightSpacing write SetRightSpacing nodefault;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    {$IFnDEF FPC} [Default(h5uClassIdGridColumn)] {$ENDIF}
    property ClassId: ThiiClassId read FClassId write FClassId;
    {$IFnDEF FPC} [Default(h5uClassIdGridDataCell)] {$ENDIF}
    property CellClassId: ThiiClassId read FCellClassId write FCellClassId;
    {$IFnDEF FPC} [Default(h5uClassIdGridHeaderCell)] {$ENDIF}
    property HeaderCellClassId: ThiiClassId read FHeaderCellClassId write FHeaderCellClassId;
    property MovePermission: ThiiColumnMovePermission read FMovePermission write SetMovePermission default ThiiColumnMovePermission.Default;
    property CanHide: Boolean read FCanHide write FCanHide default True;
    property CanResize: Boolean read FCanResize write FCanResize default True;
    property CanSelect: Boolean read FCanSelect write FCanSelect default True;
    property ShowInColumnChooser: Boolean read FShowInColumnChooser write FShowInColumnChooser default True;
    property Mode: string read GetMode stored False;
    property ImagePreserveAspectRatio: Boolean read FImagePreserveAspectRatio write FImagePreserveAspectRatio default True;
    property OnCanFocus: ThiiCellPermissionEvent read FOnCanFocus write FOnCanFocus;
    property OnCanEdit: ThiiCellPermissionEvent read FOnCanEdit write FOnCanEdit;
    property OnValidate: ThiiCellValidateEvent read FOnValidate write FOnValidate;
    property OnGetValue: ThiiCellGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiCellSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCellClick: ThiiCellEvent read FOnCellClick write FOnCellClick;
    property OnColumnHeaderClick: ThiiCellEvent read FOnColumnHeaderClick write FOnColumnHeaderClick;
    property OnCellEnter: ThiiCellEvent read FOnCellEnter write FOnCellEnter;
    property OnCellExit: ThiiCellEvent read FOnCellExit write FOnCellExit;
  end;

  ThiiGridColumns = class(TOwnedCollection)
  private
    FOnGetMode: ThiiGetColumnModeEvent;
    FOnChanged: ThiiColumnChangedEvent;
    function GetItem(AIndex: Integer): ThiiGridColumn;
    procedure SetItem(AIndex: Integer; const AValue: ThiiGridColumn);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiGridColumn;
    function FindById(const AId: string): ThiiGridColumn;
    function FindByFieldName(const AFieldName: string): ThiiGridColumn;
    function VisibleColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
    procedure NormalizeVisibleIndexes;
    procedure MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
    // ANewVisibleIndex is the block's first index after removal and insertion.
    procedure MoveColumns(const AColumns: array of ThiiGridColumn; ANewVisibleIndex: Integer; AHeaderLayout: ThiiHeaderLayout = nil);
    property Items[AIndex: Integer]: ThiiGridColumn read GetItem write SetItem; default;
    property OnGetMode: ThiiGetColumnModeEvent read FOnGetMode write FOnGetMode;
    property OnChanged: ThiiColumnChangedEvent read FOnChanged write FOnChanged;
  end;

  ThiiHeaderLayoutCell = class(TCollectionItem)
  private
    FId: string;
    FCaption: string;
    FColumnId: string;
    FLayoutRow: Integer;
    FLayoutColumn: Integer;
    FRowSpan: Integer;
    FColumnSpan: Integer;
    FWidth, FMaxWidth: ThiiWidth;
    FMinWidth: Single;
    FLegacyWidthInPercent: Single;
    FStyleName: string;
    procedure SetWidth(const AValue: ThiiWidth);
    procedure SetMinWidth(const AValue: Single);
    procedure SetMaxWidth(const AValue: ThiiWidth);
    function GetWidthInPercent: Single;
    procedure ReadLegacyWidthInPercent(AReader: TReader);
    procedure SetWidthInPercent(const AValue: Single);
    procedure SetLayoutRow(const AValue: Integer);
    procedure SetLayoutColumn(const AValue: Integer);
    procedure SetColumnSpan(const AValue: Integer);
    procedure SetColumnId(const AValue: string);
  private
    FClassId: ThiiClassId;
  protected
    procedure DefineProperties(AFiler: TFiler); override;
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyLegacySizing;
    property WidthInPercent: Single read GetWidthInPercent write SetWidthInPercent;
  published
    property Id: string read FId write FId;
    property Caption: string read FCaption write FCaption;
    property ColumnId: string read FColumnId write SetColumnId;
    property LayoutRow: Integer read FLayoutRow write SetLayoutRow default 0;
    property LayoutColumn: Integer read FLayoutColumn write SetLayoutColumn default 0;
    property RowSpan: Integer read FRowSpan write FRowSpan default 1;
    property ColumnSpan: Integer read FColumnSpan write SetColumnSpan default 1;
    property Width: ThiiWidth read FWidth write SetWidth;
    property MinWidth: Single read FMinWidth write SetMinWidth;
    property MaxWidth: ThiiWidth read FMaxWidth write SetMaxWidth;
    property StyleName: string read FStyleName write FStyleName;
    {$IFnDEF FPC} [Default(h5uClassIdGridHeaderGroupCell)] {$ENDIF}
    property ClassId: ThiiClassId read FClassId write FClassId;
  end;

  ThiiHeaderLayoutCells = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): ThiiHeaderLayoutCell;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiHeaderLayoutCell;
    property Items[AIndex: Integer]: ThiiHeaderLayoutCell read GetItem; default;
  end;

  ThiiHeaderLayout = class(TPersistent)
  private
    FOwner: TPersistent;
    FRowCount: Integer;
    FCells: ThiiHeaderLayoutCells;
    FEnabled: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure Changed;
    procedure SetCells(const AValue: ThiiHeaderLayoutCells);
    procedure SetRowCount(const AValue: Integer);
    function UsesColumnBindings(ACell: ThiiHeaderLayoutCell): Boolean;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ContainsCell(ACell: ThiiHeaderLayoutCell): Boolean;
    function ColumnRange(ACell: ThiiHeaderLayoutCell; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
      out AFirst, ALast: Integer): Boolean;
    function CanMoveColumns(const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>; AFirst, ACount, ANewIndex: Integer): Boolean;
    procedure ColumnsMoved(const ABefore, AAfter: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>);
    function MovesWithColumns(AColumn: ThiiGridColumn; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
      AFirst, ACount: Integer): Boolean;
    property Owner: TPersistent read FOwner;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property RowCount: Integer read FRowCount write SetRowCount default 1;
    property Cells: ThiiHeaderLayoutCells read FCells write SetCells;
  end;

  ThiiRowStyleMapping = class(TCollectionItem)
  private
    FValue: Integer;
    FStyleName: string;
  protected
    function GetDisplayName: string; override;
  published
    property Value: Integer read FValue write FValue default 0;
    property StyleName: string read FStyleName write FStyleName;
  end;

  ThiiRowStyleMappings = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): ThiiRowStyleMapping;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiRowStyleMapping;
    function FindStyle(AValue: Integer; out AStyleName: string): Boolean;
    property Items[AIndex: Integer]: ThiiRowStyleMapping read GetItem; default;
  end;

implementation

function CompareVisibleColumns({$IFDEF FPC}constref{$ELSE}const{$ENDIF} ALeft, ARight: ThiiGridColumn): Integer;
begin
  if ALeft.FixedKind <> ARight.FixedKind then
  begin
    if ALeft.FixedKind = ThiiFixedKind.Left then
      Exit(-1);
    if ARight.FixedKind = ThiiFixedKind.Left then
      Exit(1);
    if ALeft.FixedKind = ThiiFixedKind.Right then
      Exit(1);
    if ARight.FixedKind = ThiiFixedKind.Right then
      Exit(-1);
  end;

  Result := ALeft.VisibleIndex - ARight.VisibleIndex;
  if Result = 0 then
    Result := ALeft.Index - ARight.Index;
end;

{ ThiiGridColumn }

function ThiiGridColumn.GetMode: string;
var
  LColumns: ThiiGridColumns;
begin
  Result := '';
  LColumns := GetColumns;
  if Assigned(LColumns) and Assigned(LColumns.OnGetMode) then
    LColumns.OnGetMode(Self, Result);
end;

procedure ThiiGridColumn.Assign(Source: TPersistent);
var
  LSource: ThiiGridColumn;
begin
  if Source is ThiiGridColumn then
  begin
    LSource := ThiiGridColumn(Source);
    FId := LSource.FId;
    FCaption := LSource.FCaption;
    FFieldName := LSource.FFieldName;
    FWidth := LSource.FWidth;
    FAutoWidth := LSource.FAutoWidth;
    FDefaultWidth := LSource.FDefaultWidth;
    FDefaultMinWidth := LSource.FDefaultMinWidth;
    FDefaultMaxWidth := LSource.FDefaultMaxWidth;
    FReferenceWidth := LSource.FReferenceWidth;
    FWidthSpecified := LSource.FWidthSpecified;
    FMinWidthSpecified := LSource.FMinWidthSpecified;
    FMaxWidthSpecified := LSource.FMaxWidthSpecified;
    FLegacyWidthInPercent := LSource.FLegacyWidthInPercent;
    FLayoutWidth := -1;
    FMeasuredWidth := 0;
    FMinWidth := LSource.FMinWidth;
    FMaxWidth := LSource.FMaxWidth;
    FVisible := LSource.FVisible;
    FVisibleIndex := LSource.FVisibleIndex;
    FFixedKind := LSource.FFixedKind;
    FReadOnly := LSource.FReadOnly;
    FDataType := LSource.FDataType;
    FEditorKind := LSource.FEditorKind;
    FEditor := LSource.FEditor;
    FCellEditorColumnId := LSource.FCellEditorColumnId;
    FRowEditorColumnId := LSource.FRowEditorColumnId;
    FOnGetCellEditor := LSource.FOnGetCellEditor;
    FOnGetRowEditor := LSource.FOnGetRowEditor;
    FWordWrap := LSource.FWordWrap;
    FAutoHeight := LSource.FAutoHeight;
    FMaxAutoHeight := LSource.FMaxAutoHeight;
    FMaxLines := LSource.FMaxLines;
    FScrollHintText := LSource.FScrollHintText;
    FDisplayFormat := LSource.FDisplayFormat;
    FStyleName := LSource.FStyleName;
    FHeaderStyleName := LSource.FHeaderStyleName;
    FHighlighted := LSource.FHighlighted;
    FRightSpacing := LSource.FRightSpacing;
    FColor := LSource.FColor;
    FClassId := LSource.FClassId;
    FCellClassId := LSource.FCellClassId;
    FHeaderCellClassId := LSource.FHeaderCellClassId;
    FMovePermission := LSource.FMovePermission;
    FCanHide := LSource.FCanHide;
    FCanResize := LSource.FCanResize;
    FCanSelect := LSource.FCanSelect;
    FShowInColumnChooser := LSource.FShowInColumnChooser;
    FImagePreserveAspectRatio := LSource.FImagePreserveAspectRatio;
    FOnCanFocus := LSource.FOnCanFocus;
    FOnCanEdit := LSource.FOnCanEdit;
    FOnValidate := LSource.FOnValidate;
    FOnGetValue := LSource.FOnGetValue;
    FOnSetValue := LSource.FOnSetValue;
    FOnCellClick := LSource.FOnCellClick;
    FOnColumnHeaderClick := LSource.FOnColumnHeaderClick;
    FOnCellEnter := LSource.FOnCellEnter;
    FOnCellExit := LSource.FOnCellExit;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiGridColumn.Changed;
begin
  FLayoutWidth := -1;
  inherited Changed(False);
end;

constructor ThiiGridColumn.Create(ACollection: TCollection);
begin
  inherited;
  FId := '';
  FCaption := '';
  FFieldName := '';
  FWidth := 0;
  FDefaultWidth := 100;
  FDefaultMinWidth := 24;
  FDefaultMaxWidth := 3000;
  FLayoutWidth := -1;
  FMinWidth := 24;
  FMaxWidth := 0;
  FVisible := True;
  FVisibleIndex := -1;
  FFixedKind := ThiiFixedKind.None;
  FReadOnly := False;
  FDataType := ThiiColumnDataType.Auto;
  FEditorKind := ThiiColumnEditorKind.Automatic;
  FWordWrap := False;
  FAutoHeight := False;
  FMaxAutoHeight := 160;
  FMaxLines := 0;
  FRightSpacing := -1;
  FColor := TColorRec.SysDefault;
  FClassId := h5uClassIdGridColumn;
  FCellClassId := h5uClassIdGridDataCell;
  FHeaderCellClassId := h5uClassIdGridHeaderCell;
  FMovePermission := ThiiColumnMovePermission.Default;
  FCanHide := True;
  FCanResize := True;
  FCanSelect := True;
  FShowInColumnChooser := True;
  FImagePreserveAspectRatio := True;
end;

function ThiiGridColumn.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else if FId <> '' then
    Result := FId
  else if FFieldName <> '' then
    Result := FFieldName
  else
    Result := inherited;
end;

procedure ThiiGridColumn.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetCaption(const AValue: string);
begin
  if FCaption = AValue then
    Exit;
  FCaption := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then
    Exit;
  FFieldName := AValue;
  if FId = '' then
    FId := AValue;
  if FCaption = '' then
    FCaption := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetFixedKind(const AValue: ThiiFixedKind);
begin
  if FFixedKind = AValue then
    Exit;
  FFixedKind := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetId(const AValue: string);
begin
  if FId = AValue then
    Exit;
  FId := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetRightSpacing(const AValue: Single);
begin
  h5uValidateWidth(AValue);
  if FRightSpacing = AValue then
    Exit;
  if AValue < -1 then
    FRightSpacing := -1
  else
    FRightSpacing := EnsureRange(AValue, -1, 1000);
  Changed;
end;

procedure ThiiGridColumn.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetVisibleIndex(const AValue: Integer);
begin
  if FVisibleIndex = AValue then
    Exit;
  FVisibleIndex := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetMovePermission(AValue: ThiiColumnMovePermission);
begin
  if FMovePermission = AValue then
    Exit;
  FMovePermission := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  FWidthSpecified := True;
  if FWidth = AValue then
    Exit;
  FWidth := AValue;
  Changed;
end;

function ThiiGridColumn.GetWidthSpecification: Single;
begin
  Result := FWidth;
  if Result = 0 then
    Result := FDefaultWidth;
  if Result = 0 then
    Result := 100;
end;

function ThiiGridColumn.GetResolvedWidth: Single;
begin
  Result := EnsureRange(h5uResolveWidth(WidthSpecification, FReferenceWidth), Single(ResolvedMinWidth), Single(ResolvedMaxWidth));
end;

function ThiiGridColumn.GetResolvedMinWidth: Single;
begin
  if FMinWidthSpecified then
    Result := FMinWidth
  else
    Result := FDefaultMinWidth;
end;

function ThiiGridColumn.GetMaxWidthSpecification: Single;
begin
  Result := FMaxWidth;
  if Result = 0 then
    Result := FDefaultMaxWidth;
  if Result = 0 then
    Result := 3000;
end;

function ThiiGridColumn.GetResolvedMaxWidth: Single;
begin
  Result := Max(ResolvedMinWidth, h5uResolveWidth(MaxWidthSpecification, FReferenceWidth));
end;

procedure ThiiGridColumn.SetWidthDefaults(AWidth: Single; AMinWidth: Single; AMaxWidth, AReferenceWidth: Single);
begin
  h5uValidateWidth(AWidth);
  h5uValidateWidth(AMinWidth);
  h5uValidateWidth(AMaxWidth);
  FDefaultWidth := AWidth;
  FDefaultMinWidth := EnsureRange(AMinWidth, 0, h5uUnlimitedWidth);
  FDefaultMaxWidth := AMaxWidth;
  SetWidthReference(AReferenceWidth);
end;

procedure ThiiGridColumn.SetWidthReference(AReferenceWidth: Single);
begin
  h5uValidateWidth(AReferenceWidth);
  FReferenceWidth := EnsureRange(AReferenceWidth, 0.0, Single(h5uUnlimitedWidth));
end;

function ThiiGridColumn.ConstrainWidth(AValue: Single): Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    raise EArgumentOutOfRangeException.Create('Width must be finite.');
  Result := EnsureRange(AValue, ResolvedMinWidth, ResolvedMaxWidth);
end;

function ThiiGridColumn.GetLayoutWidth: Single;
begin
  if FLayoutWidth >= 0 then
    Result := FLayoutWidth
  else
    Result := ResolvedWidth;
end;

procedure ThiiGridColumn.SetLayoutWidth(AValue: Single);
begin
  // Layout results are transient and must not trigger collection notifications.
  FLayoutWidth := ConstrainWidth(AValue);
end;

procedure ThiiGridColumn.SetMeasuredWidth(AValue: Single);
begin
  FMeasuredWidth := ConstrainWidth(AValue);
end;

procedure ThiiGridColumn.SetAutoWidth(const AValue: Boolean);
begin
  if FAutoWidth = AValue then
    Exit;
  FAutoWidth := AValue;
  Changed;
end;

function ThiiGridColumn.GetWidthInPercent: Single;
begin
  Result := Max(0.0, -FWidth);
end;

procedure ThiiGridColumn.SetWidthInPercent(const AValue: Single);
begin
  h5uValidateWidth(AValue);
  if AValue < 0 then
    raise EArgumentOutOfRangeException.Create('WidthInPercent must not be negative.');
  if (AValue > 0) or (FWidth < 0) then
    SetWidth(-AValue);
end;

procedure ThiiGridColumn.SetMinWidth(const AValue: Single);
var
  LValue: Single;
begin
  h5uValidateWidth(AValue);
  LValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMinWidthSpecified and (FMinWidth = LValue) then
    Exit;
  FMinWidthSpecified := True;
  FMinWidth := LValue;
  Changed;
end;

procedure ThiiGridColumn.SetMaxWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  FMaxWidthSpecified := True;
  if FMaxWidth = AValue then
    Exit;
  FMaxWidth := AValue;
  Changed;
end;

procedure ThiiGridColumn.SetMaxAutoHeight(const AValue: Single);
var
  LValue: Single;
begin
  h5uValidateWidth(AValue);
  LValue := Max(0.0, AValue);
  if FMaxAutoHeight = LValue then
    Exit;
  FMaxAutoHeight := LValue;
  Changed;
end;

function ThiiGridColumn.IsMinWidthStored: Boolean;
begin
  Result := FMinWidthSpecified;
end;

procedure ThiiGridColumn.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('WidthInPercent', {$IFDEF FPC}@{$ENDIF}ReadLegacyWidthInPercent, nil, False);
end;

procedure ThiiGridColumn.ReadLegacyWidthInPercent(AReader: TReader);
begin
  FLegacyWidthInPercent := AReader.ReadFloat;
  h5uValidateWidth(FLegacyWidthInPercent);
  if (FLegacyWidthInPercent > 0) and (FWidth >= 0) then
    FWidth := -FLegacyWidthInPercent;
end;

procedure ThiiGridColumn.ApplyLegacySizing;
begin
  if not FWidthSpecified and (FWidth = 0) then
    FWidth := 100;
  if (FLegacyWidthInPercent > 0) and (FWidth >= 0) then
    FWidth := -FLegacyWidthInPercent;
  if not FMaxWidthSpecified then
    FMaxWidth := 1000
  else if FMaxWidth = 0 then
    FMaxWidth := h5uUnlimitedWidth;
  FMinWidthSpecified := True;
  FWidthSpecified := True;
  FMaxWidthSpecified := True;
  FLegacyWidthInPercent := 0;
  Changed;
end;

{ ThiiGridColumns }

function ThiiGridColumns.Add: ThiiGridColumn;
begin
  Result := ThiiGridColumn(inherited Add);
  if Result.VisibleIndex < 0 then
    Result.VisibleIndex := Count - 1;
end;

constructor ThiiGridColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiGridColumn);
end;

function ThiiGridColumns.FindByFieldName(const AFieldName: string): ThiiGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].FieldName, AFieldName) then
      Exit(Items[I]);
end;

function ThiiGridColumns.FindById(const AId: string): ThiiGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].Id, AId) then
      Exit(Items[I]);
end;

function ThiiGridColumns.GetItem(AIndex: Integer): ThiiGridColumn;
begin
  Result := ThiiGridColumn(inherited GetItem(AIndex));
end;

procedure ThiiGridColumns.MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
begin
  MoveColumns([AColumn], ANewVisibleIndex);
end;

procedure ThiiGridColumns.MoveColumns(const AColumns: array of ThiiGridColumn; ANewVisibleIndex: Integer; AHeaderLayout: ThiiHeaderLayout);
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
  LList, LAll, LMoving: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>;
  I, J, LFirst, LInsert: Integer;
  LMove: Boolean;
  LAnchor: ThiiGridColumn;
begin
  if Length(AColumns) = 0 then
    Exit;
  LColumns := VisibleColumns;
  LFirst := -1;
  for I := 0 to High(LColumns) do
    if LColumns[I] = AColumns[0] then
      LFirst := I;
  if (LFirst < 0) or (LFirst + Length(AColumns) > Length(LColumns)) then
    Exit;
  for I := 0 to High(AColumns) do
  begin
    // Validate ownership/contiguity before dereferencing supplied columns.
    if LColumns[LFirst + I] <> AColumns[I] then
      Exit;
    if (AColumns[I].MovePermission = ThiiColumnMovePermission.Deny) or (AColumns[I].FixedKind <> AColumns[0].FixedKind) then
      Exit;
  end;
  ANewVisibleIndex := EnsureRange(ANewVisibleIndex, 0, Length(LColumns) - Length(AColumns));
  if ANewVisibleIndex = LFirst then
    Exit;
  LList := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>.Create;
  try
    LList.AddRange(LColumns);
    LList.DeleteRange(LFirst, Length(AColumns));
    LList.InsertRange(ANewVisibleIndex, AColumns);
    // Moving never changes which columns are fixed or crosses a fixed region.
    for I := 0 to LList.Count - 1 do
      if LList[I].FixedKind <> LColumns[I].FixedKind then
        Exit;
    if Assigned(AHeaderLayout) and AHeaderLayout.Enabled then
    begin
      if not AHeaderLayout.CanMoveColumns(LColumns, LFirst, Length(AColumns), ANewVisibleIndex) then
        Exit;
      LAll := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>.Create;
      LMoving := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>.Create;
      try
        for I := 0 to Count - 1 do
          LAll.Add(Items[I]);
        LAll.Sort({$IFDEF FPC}specialize {$ENDIF}TComparer<ThiiGridColumn>.Construct({$IFDEF FPC}@{$ENDIF}CompareVisibleColumns));
        for I := LAll.Count - 1 downto 0 do
        begin
          LMove := AHeaderLayout.MovesWithColumns(LAll[I], LColumns, LFirst, Length(AColumns));
          for J := 0 to High(AColumns) do
            LMove := LMove or (LAll[I] = AColumns[J]);
          if not LMove then
            Continue;
          if (LAll[I].MovePermission = ThiiColumnMovePermission.Deny) or (LAll[I].FixedKind <> AColumns[0].FixedKind) then
            Exit;
          LMoving.Insert(0, LAll[I]);
          LAll.Delete(I);
        end;
        LInsert := LAll.Count;
        if ANewVisibleIndex + Length(AColumns) < LList.Count then
        begin
          LAnchor := LList[ANewVisibleIndex + Length(AColumns)];
          LInsert := LAll.IndexOf(LAnchor);
          while (LInsert > 0)
            and AHeaderLayout.MovesWithColumns(LAll[LInsert - 1], LList.ToArray, ANewVisibleIndex + Length(AColumns),
            LList.Count - ANewVisibleIndex - Length(AColumns)) do
            Dec(LInsert);
        end;
        LAll.InsertRange(LInsert, LMoving.ToArray);
        AHeaderLayout.ColumnsMoved(LColumns, LList.ToArray);
        // Include hidden descendants so showing them again restores the moved group.
        for I := 0 to LAll.Count - 1 do
          LAll[I].FVisibleIndex := I;
      finally
        LMoving.Free;
        LAll.Free;
      end;
    end
    else
      for I := 0 to LList.Count - 1 do
        LList[I].FVisibleIndex := I;
    Changed;
  finally
    LList.Free;
  end;
end;

procedure ThiiGridColumns.NormalizeVisibleIndexes;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
  I: Integer;
begin
  LColumns := VisibleColumns;
  for I := 0 to High(LColumns) do
    LColumns[I].FVisibleIndex := I;
  Changed;
end;

procedure ThiiGridColumns.SetItem(AIndex: Integer; const AValue: ThiiGridColumn);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure ThiiGridColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self, ThiiGridColumn(Item));
end;

function ThiiGridColumns.VisibleColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
var
  LList: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>;
  I: Integer;
begin
  LList := {$IFDEF FPC}specialize {$ENDIF}TList<ThiiGridColumn>.Create;
  try
    for I := 0 to Count - 1 do
      if Items[I].Visible then
        LList.Add(Items[I]);

    LList.Sort({$IFDEF FPC}specialize {$ENDIF}TComparer<ThiiGridColumn>.Construct({$IFDEF FPC}@{$ENDIF}CompareVisibleColumns));
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

{ ThiiHeaderLayoutCell }

constructor ThiiHeaderLayoutCell.Create(ACollection: TCollection);
begin
  inherited;
  FRowSpan := 1;
  FColumnSpan := 1;
  FClassId := h5uClassIdGridHeaderGroupCell;
end;

function ThiiHeaderLayoutCell.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else if FId <> '' then
    Result := FId
  else
    Result := inherited;
end;

procedure ThiiHeaderLayoutCell.Assign(Source: TPersistent);
var
  S: ThiiHeaderLayoutCell;
begin
  if not (Source is ThiiHeaderLayoutCell) then
  begin
    inherited;
    Exit;
  end;
  S := ThiiHeaderLayoutCell(Source);
  FId := S.FId;
  FCaption := S.FCaption;
  FColumnId := S.FColumnId;
  FLayoutRow := S.FLayoutRow;
  FLayoutColumn := S.FLayoutColumn;
  FRowSpan := S.FRowSpan;
  FColumnSpan := S.FColumnSpan;
  FWidth := S.FWidth;
  FMinWidth := S.FMinWidth;
  FMaxWidth := S.FMaxWidth;
  FLegacyWidthInPercent := S.FLegacyWidthInPercent;
  FStyleName := S.FStyleName;
  FClassId := S.FClassId;
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FWidth = AValue then
    Exit;
  FWidth := AValue;
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetMinWidth(const AValue: Single);
var
  LValue: Single;
begin
  h5uValidateWidth(AValue);
  LValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMinWidth = LValue then
    Exit;
  FMinWidth := LValue;
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetMaxWidth(const AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FMaxWidth = AValue then
    Exit;
  FMaxWidth := AValue;
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('WidthInPercent', {$IFDEF FPC}@{$ENDIF}ReadLegacyWidthInPercent, nil, False);
end;

procedure ThiiHeaderLayoutCell.ReadLegacyWidthInPercent(AReader: TReader);
begin
  FLegacyWidthInPercent := AReader.ReadFloat;
  h5uValidateWidth(FLegacyWidthInPercent);
  if (FLegacyWidthInPercent > 0) and (FWidth >= 0) then
    FWidth := -FLegacyWidthInPercent;
end;

procedure ThiiHeaderLayoutCell.ApplyLegacySizing;
begin
  if (FLegacyWidthInPercent > 0) and (FWidth >= 0) then
    FWidth := -FLegacyWidthInPercent;
  FLegacyWidthInPercent := 0;
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetLayoutRow(const AValue: Integer);
begin
  if FLayoutRow = Max(0, AValue) then
    Exit;
  FLayoutRow := Max(0, AValue);
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetLayoutColumn(const AValue: Integer);
begin
  if FLayoutColumn = Max(0, AValue) then
    Exit;
  FLayoutColumn := Max(0, AValue);
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetColumnSpan(const AValue: Integer);
begin
  if FColumnSpan = Max(1, AValue) then
    Exit;
  FColumnSpan := Max(1, AValue);
  Changed(False);
end;

procedure ThiiHeaderLayoutCell.SetColumnId(const AValue: string);
begin
  if FColumnId = AValue then
    Exit;
  FColumnId := AValue;
  Changed(False);
end;

function ThiiHeaderLayoutCell.GetWidthInPercent: Single;
begin
  Result := Max(0.0, -FWidth);
end;

procedure ThiiHeaderLayoutCell.SetWidthInPercent(const AValue: Single);
begin
  h5uValidateWidth(AValue);
  if AValue < 0 then
    raise EArgumentOutOfRangeException.Create('WidthInPercent must not be negative.');
  if (AValue > 0) or (FWidth < 0) then
    SetWidth(-AValue);
end;

procedure ThiiHeaderLayoutCells.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is ThiiHeaderLayout then
    ThiiHeaderLayout(GetOwner).Changed;
end;

procedure ThiiHeaderLayout.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiHeaderLayout.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

{ ThiiHeaderLayoutCells }

function ThiiHeaderLayoutCells.Add: ThiiHeaderLayoutCell;
begin
  Result := ThiiHeaderLayoutCell(inherited Add);
end;

constructor ThiiHeaderLayoutCells.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiHeaderLayoutCell);
end;

function ThiiHeaderLayoutCells.GetItem(AIndex: Integer): ThiiHeaderLayoutCell;
begin
  Result := ThiiHeaderLayoutCell(inherited GetItem(AIndex));
end;

{ ThiiHeaderLayout }

function ThiiHeaderLayout.ContainsCell(ACell: ThiiHeaderLayoutCell): Boolean;
var
  I: Integer;
begin
  for I := 0 to FCells.Count - 1 do
    if FCells[I] = ACell then
      Exit(True);
  Result := False;
end;

function ThiiHeaderLayout.UsesColumnBindings(ACell: ThiiHeaderLayoutCell): Boolean;
var
  LCell: ThiiHeaderLayoutCell;
  I: Integer;
begin
  if ACell.ColumnId <> '' then
    Exit(True);
  for I := 0 to FCells.Count - 1 do
  begin
    LCell := FCells[I];
    if (LCell.ColumnId <> '') and (LCell.LayoutRow >= ACell.LayoutRow) and (LCell.LayoutColumn >= ACell.LayoutColumn)
      and (LCell.LayoutColumn < ACell.LayoutColumn + Max(1, ACell.ColumnSpan)) then
      Exit(True);
  end;
  Result := False;
end;

function ThiiHeaderLayout.ColumnRange(ACell: ThiiHeaderLayoutCell; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
    out AFirst, ALast: Integer): Boolean;
var
  LCell: ThiiHeaderLayoutCell;
  I, J: Integer;
begin
  AFirst := Length(AColumns);
  ALast := -1;
  if not Assigned(ACell) then
    Exit(False);
  // ColumnId binds a leaf to its data column. A group inherits the bindings of
  // its descendants. LayoutColumn remains their logical position in the definition.
  // Consequently reordering and hiding a column cannot detach its caption/group.
  if UsesColumnBindings(ACell) then
  begin
    for I := 0 to FCells.Count - 1 do
    begin
      LCell := FCells[I];
      if ACell.ColumnId <> '' then
      begin
        if LCell <> ACell then
          Continue;
      end
      else
        if (LCell.LayoutRow < ACell.LayoutRow) or (LCell.LayoutColumn < ACell.LayoutColumn)
          or (LCell.LayoutColumn >= ACell.LayoutColumn + Max(1, ACell.ColumnSpan)) then
          Continue;
      if LCell.ColumnId = '' then
        Continue;
      for J := 0 to High(AColumns) do
        if SameText(AColumns[J].Id, LCell.ColumnId) then
        begin
          AFirst := Min(AFirst, J);
          ALast := Max(ALast, J);
        end;
    end;
  end
  else
  begin
    AFirst := ACell.LayoutColumn;
    ALast := Min(High(AColumns), AFirst + Max(1, ACell.ColumnSpan) - 1);
  end;
  if (ACell.ColumnId <> '') and (AFirst <= ALast) then
    ALast := Min(High(AColumns), AFirst + Max(1, ACell.ColumnSpan) - 1);
  Result := (AFirst >= 0) and (AFirst <= ALast);
end;

function ThiiHeaderLayout.CanMoveColumns(const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
    AFirst, ACount, ANewIndex: Integer): Boolean;
var
  I, J, LFirst, LLast, LMin, LMax, LIndex: Integer;

  function MovedIndex(AIndex: Integer): Integer;
  begin
    if (AIndex >= AFirst) and (AIndex < AFirst + ACount) then
      Exit(ANewIndex + AIndex - AFirst);
    Result := AIndex;
    if Result >= AFirst + ACount then
      Dec(Result, ACount);
    if Result >= ANewIndex then
      Inc(Result, ACount);
  end;

begin
  Result := False;
  if (AFirst < 0) or (ACount < 1) or (AFirst + ACount > Length(AColumns)) or (ANewIndex < 0) or (ANewIndex + ACount > Length(AColumns)) then
    Exit;
  // A header must still cover a contiguous range after the move. This preserves
  // parent groups while allowing both sibling groups and their leaves to move.
  for I := 0 to FCells.Count - 1 do
    if ColumnRange(FCells[I], AColumns, LFirst, LLast) then
    begin
      LMin := Length(AColumns);
      LMax := -1;
      for J := LFirst to LLast do
      begin
        LIndex := MovedIndex(J);
        LMin := Min(LMin, LIndex);
        LMax := Max(LMax, LIndex);
      end;
      if LMax - LMin <> LLast - LFirst then
        Exit;
    end;
  Result := True;
end;

function ThiiHeaderLayout.MovesWithColumns(AColumn: ThiiGridColumn; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
    AFirst, ACount: Integer): Boolean;
var
  LGroup, LLeaf: ThiiHeaderLayoutCell;
  I, J, LFirst, LLast: Integer;
begin
  Result := False;
  if AColumn.Visible then
    Exit;
  for I := 0 to FCells.Count - 1 do
  begin
    LGroup := FCells[I];
    if (LGroup.ColumnSpan <= 1) or not ColumnRange(LGroup, AColumns, LFirst, LLast) or (LFirst < AFirst) or (LLast >= AFirst + ACount) then
      Continue;
    for J := 0 to FCells.Count - 1 do
    begin
      LLeaf := FCells[J];
      if SameText(LLeaf.ColumnId, AColumn.Id) and (LLeaf.LayoutRow >= LGroup.LayoutRow) and (LLeaf.LayoutColumn >= LGroup.LayoutColumn)
        and (LLeaf.LayoutColumn < LGroup.LayoutColumn + Max(1, LGroup.ColumnSpan)) then
        Exit(True);
    end;
  end;
end;

procedure ThiiHeaderLayout.ColumnsMoved(const ABefore, AAfter: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>);
var
  I, J, K, LFirst, LLast, LNewFirst: Integer;
  LPositions: {$IFDEF FPC}specialize {$ENDIF}TArray<Integer>;
begin
  SetLength(LPositions, FCells.Count);
  for I := 0 to FCells.Count - 1 do
  begin
    LPositions[I] := FCells[I].LayoutColumn;
    if UsesColumnBindings(FCells[I]) or not ColumnRange(FCells[I], ABefore, LFirst, LLast) then
      Continue;
    LNewFirst := Length(AAfter);
    for J := LFirst to LLast do
      for K := 0 to High(AAfter) do
        if ABefore[J] = AAfter[K] then
          LNewFirst := Min(LNewFirst, K);
    if LNewFirst < Length(AAfter) then
      LPositions[I] := LNewFirst;
  end;
  for I := 0 to FCells.Count - 1 do
    FCells[I].LayoutColumn := LPositions[I];
end;

procedure ThiiHeaderLayout.Assign(Source: TPersistent);
begin
  if Source is ThiiHeaderLayout then
  begin
    FEnabled := ThiiHeaderLayout(Source).FEnabled;
    FRowCount := ThiiHeaderLayout(Source).FRowCount;
    FCells.Assign(ThiiHeaderLayout(Source).FCells);
  end
  else
    inherited;
end;

constructor ThiiHeaderLayout.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FEnabled := False;
  FRowCount := 1;
  FCells := ThiiHeaderLayoutCells.Create(Self);
end;

destructor ThiiHeaderLayout.Destroy;
begin
  FCells.Free;
  inherited;
end;

procedure ThiiHeaderLayout.SetCells(const AValue: ThiiHeaderLayoutCells);
begin
  FCells.Assign(AValue);
end;

procedure ThiiHeaderLayout.SetRowCount(const AValue: Integer);
begin
  FRowCount := EnsureRange(AValue, 1, 16);
  Changed;
end;

{ ThiiRowStyleMapping }

function ThiiRowStyleMapping.GetDisplayName: string;
begin
  if FStyleName <> '' then
    Result := Format('%d = %s', [FValue, FStyleName])
  else
    Result := IntToStr(FValue);
end;

{ ThiiRowStyleMappings }

function ThiiRowStyleMappings.Add: ThiiRowStyleMapping;
begin
  Result := ThiiRowStyleMapping(inherited Add);
end;

constructor ThiiRowStyleMappings.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, ThiiRowStyleMapping);
end;

function ThiiRowStyleMappings.FindStyle(AValue: Integer; out AStyleName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Value = AValue then
    begin
      AStyleName := Items[I].StyleName;
      Exit(True);
    end;
  AStyleName := '';
  Result := False;
end;

function ThiiRowStyleMappings.GetItem(AIndex: Integer): ThiiRowStyleMapping;
begin
  Result := ThiiRowStyleMapping(inherited GetItem(AIndex));
end;


function ThiiGridColumn.GetColumns: ThiiGridColumns;
begin
  Result := ThiiGridColumns(Collection);
end;

end.

