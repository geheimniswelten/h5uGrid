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
  h5u.Grid.Types;

type
  Th5uGridColumn = class;
  Th5uGridColumns = class;
  Th5uHeaderLayout = class;

  Th5uCellEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64) of object;
  Th5uCellPermissionEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AAllow: Boolean) of object;
  Th5uCellGetValueEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean) of object;
  Th5uCellSetValueEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AValue: TValue) of object;
  Th5uCellValidateEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AValue: TValue; var AValid: Boolean; var AErrorText: string) of object;
  Th5uGetColumnModeEvent = procedure(AColumn: Th5uGridColumn; var AMode: string) of object;
  Th5uGetCellEditorEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn; ARowIndex: Int64; var AEditorName: string) of object;
  Th5uColumnChangedEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn) of object;

  Th5uGridColumn = class(TCollectionItem)
  private
    FId: string;
    FCaption: string;
    FFieldName: string;
    FWidth: Integer;
    FAutoWidth: Boolean;
    FWidthInPercent: Double;
    FLayoutWidth: Integer;
    FMeasuredWidth: Integer;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FVisible: Boolean;
    FVisibleIndex: Integer;
    FFixedKind: Th5uFixedKind;
    FReadOnly: Boolean;
    FDataType: Th5uColumnDataType;
    FEditorKind: Th5uColumnEditorKind;
    FEditor, FCellEditorColumnId, FRowEditorColumnId: string;
    FOnGetCellEditor, FOnGetRowEditor: Th5uGetCellEditorEvent;
    FWordWrap: Boolean;
    FAutoHeight: Boolean;
    FMaxAutoHeight: Integer;
    FMaxLines: Integer;
    FScrollHintText: string;
    FDisplayFormat: string;
    FStyleName: string;
    FHeaderStyleName: string;
    FHighlighted: Boolean;
    FRightSpacing: Integer;
    FColor: TColor;
    FClassId: Th5uClassId;
    FCellClassId: Th5uClassId;
    FHeaderCellClassId: Th5uClassId;
    FMovePermission: Th5uColumnMovePermission;
    FCanHide: Boolean;
    FCanResize: Boolean;
    FCanSelect: Boolean;
    FShowInColumnChooser: Boolean;
    FImagePreserveAspectRatio: Boolean;
    FOnCanFocus: Th5uCellPermissionEvent;
    FOnCanEdit: Th5uCellPermissionEvent;
    FOnValidate: Th5uCellValidateEvent;
    FOnGetValue: Th5uCellGetValueEvent;
    FOnSetValue: Th5uCellSetValueEvent;
    FOnCellClick: Th5uCellEvent;
    FOnColumnHeaderClick: Th5uCellEvent;
    FOnCellEnter: Th5uCellEvent;
    FOnCellExit: Th5uCellEvent;
    procedure Changed;
    procedure SetCaption(const AValue: string);
    procedure SetFieldName(const AValue: string);
    procedure SetFixedKind(const AValue: Th5uFixedKind);
    procedure SetId(const AValue: string);
    procedure SetColor(const AValue: TColor);
    procedure SetRightSpacing(const AValue: Integer);
    procedure SetVisible(const AValue: Boolean);
    procedure SetVisibleIndex(const AValue: Integer);
    procedure SetWidth(const AValue: Integer);
    procedure SetAutoWidth(const AValue: Boolean);
    procedure SetWidthInPercent(const AValue: Double);
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    function GetLayoutWidth: Integer;
    procedure SetMovePermission(AValue: Th5uColumnMovePermission);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function GetMode: string;
    function ConstrainWidth(AValue: Integer): Integer;
    procedure SetLayoutWidth(AValue: Integer);
    procedure SetMeasuredWidth(AValue: Integer);
    property LayoutWidth: Integer read GetLayoutWidth;
    property MeasuredWidth: Integer read FMeasuredWidth;
    function GetColumns: Th5uGridColumns;
    property Columns: Th5uGridColumns read GetColumns;
  published
    property Id: string read FId write SetId;
    property Caption: string read FCaption write SetCaption;
    property FieldName: string read FFieldName write SetFieldName;
    property Width: Integer read FWidth write SetWidth default 100;
    property AutoWidth: Boolean read FAutoWidth write SetAutoWidth default False;
    property WidthInPercent: Double read FWidthInPercent write SetWidthInPercent;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 24;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 1000;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleIndex: Integer read FVisibleIndex write SetVisibleIndex default -1;
    property FixedKind: Th5uFixedKind read FFixedKind write SetFixedKind default Th5uFixedKind.None;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property DataType: Th5uColumnDataType read FDataType write FDataType default Th5uColumnDataType.Auto;
    property Editor: string read FEditor write FEditor;
    property CellEditorColumnId: string read FCellEditorColumnId write FCellEditorColumnId;
    property RowEditorColumnId: string read FRowEditorColumnId write FRowEditorColumnId;
    property OnGetCellEditor: Th5uGetCellEditorEvent read FOnGetCellEditor write FOnGetCellEditor;
    property OnGetRowEditor: Th5uGetCellEditorEvent read FOnGetRowEditor write FOnGetRowEditor;
    property EditorKind: Th5uColumnEditorKind read FEditorKind write FEditorKind default Th5uColumnEditorKind.Automatic;
    property WordWrap: Boolean read FWordWrap write FWordWrap default False;
    property AutoHeight: Boolean read FAutoHeight write FAutoHeight default False;
    property MaxAutoHeight: Integer read FMaxAutoHeight write FMaxAutoHeight default 160;
    property MaxLines: Integer read FMaxLines write FMaxLines default 0;
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat;
    property ScrollHintText: string read FScrollHintText write FScrollHintText;
    property StyleName: string read FStyleName write FStyleName;
    property HeaderStyleName: string read FHeaderStyleName write FHeaderStyleName;
    property Highlighted: Boolean read FHighlighted write FHighlighted default False;
    property RightSpacing: Integer read FRightSpacing write SetRightSpacing default -1;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    {$IFnDEF FPC} [Default(h5uClassIdGridColumn)] {$ENDIF}
    property ClassId: Th5uClassId read FClassId write FClassId;
    {$IFnDEF FPC} [Default(h5uClassIdGridDataCell)] {$ENDIF}
    property CellClassId: Th5uClassId read FCellClassId write FCellClassId;
    {$IFnDEF FPC} [Default(h5uClassIdGridHeaderCell)] {$ENDIF}
    property HeaderCellClassId: Th5uClassId read FHeaderCellClassId write FHeaderCellClassId;
    property MovePermission: Th5uColumnMovePermission read FMovePermission write SetMovePermission default Th5uColumnMovePermission.Default;
    property CanHide: Boolean read FCanHide write FCanHide default True;
    property CanResize: Boolean read FCanResize write FCanResize default True;
    property CanSelect: Boolean read FCanSelect write FCanSelect default True;
    property ShowInColumnChooser: Boolean read FShowInColumnChooser write FShowInColumnChooser default True;
    property Mode: string read GetMode stored False;
    property ImagePreserveAspectRatio: Boolean read FImagePreserveAspectRatio write FImagePreserveAspectRatio default True;
    property OnCanFocus: Th5uCellPermissionEvent read FOnCanFocus write FOnCanFocus;
    property OnCanEdit: Th5uCellPermissionEvent read FOnCanEdit write FOnCanEdit;
    property OnValidate: Th5uCellValidateEvent read FOnValidate write FOnValidate;
    property OnGetValue: Th5uCellGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uCellSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCellClick: Th5uCellEvent read FOnCellClick write FOnCellClick;
    property OnColumnHeaderClick: Th5uCellEvent read FOnColumnHeaderClick write FOnColumnHeaderClick;
    property OnCellEnter: Th5uCellEvent read FOnCellEnter write FOnCellEnter;
    property OnCellExit: Th5uCellEvent read FOnCellExit write FOnCellExit;
  end;

  Th5uGridColumns = class(TOwnedCollection)
  private
    FOnGetMode: Th5uGetColumnModeEvent;
    FOnChanged: Th5uColumnChangedEvent;
    function GetItem(AIndex: Integer): Th5uGridColumn;
    procedure SetItem(AIndex: Integer; const AValue: Th5uGridColumn);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: Th5uGridColumn;
    function FindById(const AId: string): Th5uGridColumn;
    function FindByFieldName(const AFieldName: string): Th5uGridColumn;
    function VisibleColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
    procedure NormalizeVisibleIndexes;
    procedure MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
    // ANewVisibleIndex is the block's first index after removal and insertion.
    procedure MoveColumns(const AColumns: array of Th5uGridColumn; ANewVisibleIndex: Integer; AHeaderLayout: Th5uHeaderLayout = nil);
    property Items[AIndex: Integer]: Th5uGridColumn read GetItem write SetItem; default;
    property OnGetMode: Th5uGetColumnModeEvent read FOnGetMode write FOnGetMode;
    property OnChanged: Th5uColumnChangedEvent read FOnChanged write FOnChanged;
  end;

  Th5uHeaderLayoutCell = class(TCollectionItem)
  private
    FId: string;
    FCaption: string;
    FColumnId: string;
    FLayoutRow: Integer;
    FLayoutColumn: Integer;
    FRowSpan: Integer;
    FColumnSpan: Integer;
    FWidth, FMinWidth, FMaxWidth: Integer;
    FWidthInPercent: Double;
    FStyleName: string;
    procedure SetWidth(const AValue: Integer);
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetWidthInPercent(const AValue: Double);
    procedure SetLayoutRow(const AValue: Integer);
    procedure SetLayoutColumn(const AValue: Integer);
    procedure SetColumnSpan(const AValue: Integer);
    procedure SetColumnId(const AValue: string);
  private
    FClassId: Th5uClassId;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Id: string read FId write FId;
    property Caption: string read FCaption write FCaption;
    property ColumnId: string read FColumnId write SetColumnId;
    property LayoutRow: Integer read FLayoutRow write SetLayoutRow default 0;
    property LayoutColumn: Integer read FLayoutColumn write SetLayoutColumn default 0;
    property RowSpan: Integer read FRowSpan write FRowSpan default 1;
    property ColumnSpan: Integer read FColumnSpan write SetColumnSpan default 1;
    property Width: Integer read FWidth write SetWidth default 0;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property WidthInPercent: Double read FWidthInPercent write SetWidthInPercent;
    property StyleName: string read FStyleName write FStyleName;
    {$IFnDEF FPC} [Default(h5uClassIdGridHeaderGroupCell)] {$ENDIF}
    property ClassId: Th5uClassId read FClassId write FClassId;
  end;

  Th5uHeaderLayoutCells = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): Th5uHeaderLayoutCell;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: Th5uHeaderLayoutCell;
    property Items[AIndex: Integer]: Th5uHeaderLayoutCell read GetItem; default;
  end;

  Th5uHeaderLayout = class(TPersistent)
  private
    FOwner: TPersistent;
    FRowCount: Integer;
    FCells: Th5uHeaderLayoutCells;
    FEnabled: Boolean;
    FOnChanged: TNotifyEvent;
    procedure SetEnabled(const AValue: Boolean);
    procedure Changed;
    procedure SetCells(const AValue: Th5uHeaderLayoutCells);
    procedure SetRowCount(const AValue: Integer);
    function UsesColumnBindings(ACell: Th5uHeaderLayoutCell): Boolean;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ContainsCell(ACell: Th5uHeaderLayoutCell): Boolean;
    function ColumnRange(ACell: Th5uHeaderLayoutCell; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; out AFirst, ALast: Integer): Boolean;
    function CanMoveColumns(const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AFirst, ACount, ANewIndex: Integer): Boolean;
    procedure ColumnsMoved(const ABefore, AAfter: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>);
    function MovesWithColumns(AColumn: Th5uGridColumn; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AFirst, ACount: Integer): Boolean;
    property Owner: TPersistent read FOwner;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property RowCount: Integer read FRowCount write SetRowCount default 1;
    property Cells: Th5uHeaderLayoutCells read FCells write SetCells;
  end;

  Th5uRowStyleMapping = class(TCollectionItem)
  private
    FValue: Integer;
    FStyleName: string;
  protected
    function GetDisplayName: string; override;
  published
    property Value: Integer read FValue write FValue default 0;
    property StyleName: string read FStyleName write FStyleName;
  end;

  Th5uRowStyleMappings = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): Th5uRowStyleMapping;
  public
    constructor Create(AOwner: TPersistent);
    function Add: Th5uRowStyleMapping;
    function FindStyle(AValue: Integer; out AStyleName: string): Boolean;
    property Items[AIndex: Integer]: Th5uRowStyleMapping read GetItem; default;
  end;

implementation

function CompareVisibleColumns({$IFDEF FPC}constref{$ELSE}const{$ENDIF} ALeft, ARight: Th5uGridColumn): Integer;
begin
  if ALeft.FixedKind <> ARight.FixedKind then
  begin
    if ALeft.FixedKind = Th5uFixedKind.Left then
      Exit(-1);
    if ARight.FixedKind = Th5uFixedKind.Left then
      Exit(1);
    if ALeft.FixedKind = Th5uFixedKind.Right then
      Exit(1);
    if ARight.FixedKind = Th5uFixedKind.Right then
      Exit(-1);
  end;

  Result := ALeft.VisibleIndex - ARight.VisibleIndex;
  if Result = 0 then
    Result := ALeft.Index - ARight.Index;
end;

{ Th5uGridColumn }

function Th5uGridColumn.GetMode: string;
var
  LColumns: Th5uGridColumns;
begin
  Result := '';
  LColumns := GetColumns;
  if Assigned(LColumns) and Assigned(LColumns.OnGetMode) then
    LColumns.OnGetMode(Self, Result);
end;

procedure Th5uGridColumn.Assign(Source: TPersistent);
var
  LSource: Th5uGridColumn;
begin
  if Source is Th5uGridColumn then
  begin
    LSource := Th5uGridColumn(Source);
    FId := LSource.FId;
    FCaption := LSource.FCaption;
    FFieldName := LSource.FFieldName;
    FWidth := LSource.FWidth;
    FAutoWidth := LSource.FAutoWidth;
    FWidthInPercent := LSource.FWidthInPercent;
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

procedure Th5uGridColumn.Changed;
begin
  FLayoutWidth := -1;
  inherited Changed(False);
end;

constructor Th5uGridColumn.Create(ACollection: TCollection);
begin
  inherited;
  FId := '';
  FCaption := '';
  FFieldName := '';
  FWidth := 100;
  FLayoutWidth := -1;
  FMinWidth := 24;
  FMaxWidth := 1000;
  FVisible := True;
  FVisibleIndex := -1;
  FFixedKind := Th5uFixedKind.None;
  FReadOnly := False;
  FDataType := Th5uColumnDataType.Auto;
  FEditorKind := Th5uColumnEditorKind.Automatic;
  FWordWrap := False;
  FAutoHeight := False;
  FMaxAutoHeight := 160;
  FMaxLines := 0;
  FRightSpacing := -1;
  FColor := TColorRec.SysDefault;
  FClassId := h5uClassIdGridColumn;
  FCellClassId := h5uClassIdGridDataCell;
  FHeaderCellClassId := h5uClassIdGridHeaderCell;
  FMovePermission := Th5uColumnMovePermission.Default;
  FCanHide := True;
  FCanResize := True;
  FCanSelect := True;
  FShowInColumnChooser := True;
  FImagePreserveAspectRatio := True;
end;

function Th5uGridColumn.GetDisplayName: string;
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

procedure Th5uGridColumn.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetCaption(const AValue: string);
begin
  if FCaption = AValue then
    Exit;
  FCaption := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetFieldName(const AValue: string);
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

procedure Th5uGridColumn.SetFixedKind(const AValue: Th5uFixedKind);
begin
  if FFixedKind = AValue then
    Exit;
  FFixedKind := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetId(const AValue: string);
begin
  if FId = AValue then
    Exit;
  FId := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetRightSpacing(const AValue: Integer);
begin
  if FRightSpacing = AValue then
    Exit;
  if AValue < -1 then
    FRightSpacing := -1
  else
    FRightSpacing := EnsureRange(AValue, -1, 1000);
  Changed;
end;

procedure Th5uGridColumn.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetVisibleIndex(const AValue: Integer);
begin
  if FVisibleIndex = AValue then
    Exit;
  FVisibleIndex := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetMovePermission(AValue: Th5uColumnMovePermission);
begin
  if FMovePermission = AValue then
    Exit;
  FMovePermission := AValue;
  Changed;
end;
procedure Th5uGridColumn.SetWidth(const AValue: Integer);
begin
  if FWidth = AValue then
    Exit;
  FWidth := ConstrainWidth(AValue);
  Changed;
end;

function Th5uGridColumn.ConstrainWidth(AValue: Integer): Integer;
begin
  Result := Max(FMinWidth, AValue);
  if FMaxWidth > 0 then
    Result := Min(Result, Max(FMinWidth, FMaxWidth));
end;

function Th5uGridColumn.GetLayoutWidth: Integer;
begin
  if FLayoutWidth >= 0 then
    Result := FLayoutWidth
  else
    Result := ConstrainWidth(FWidth);
end;

procedure Th5uGridColumn.SetLayoutWidth(AValue: Integer);
begin
  // Layout results are transient and must not trigger collection notifications.
  FLayoutWidth := ConstrainWidth(AValue);
end;

procedure Th5uGridColumn.SetMeasuredWidth(AValue: Integer);
begin
  FMeasuredWidth := ConstrainWidth(AValue);
end;

procedure Th5uGridColumn.SetAutoWidth(const AValue: Boolean);
begin
  if FAutoWidth = AValue then
    Exit;
  FAutoWidth := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetWidthInPercent(const AValue: Double);
begin
  if IsNan(AValue) or IsInfinite(AValue) or (AValue < 0) or (AValue > 100) then
    raise EArgumentOutOfRangeException.Create('WidthInPercent muss zwischen 0 und 100 liegen.');
  if FWidthInPercent = AValue then
    Exit;
  FWidthInPercent := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetMinWidth(const AValue: Integer);
begin
  if FMinWidth = Max(0, AValue) then
    Exit;
  FMinWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMaxWidth < FMinWidth) then
    FMaxWidth := FMinWidth;
  Changed;
end;

procedure Th5uGridColumn.SetMaxWidth(const AValue: Integer);
begin
  if FMaxWidth = Max(0, AValue) then
    Exit;
  FMaxWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMinWidth > FMaxWidth) then
    FMinWidth := FMaxWidth;
  Changed;
end;

{ Th5uGridColumns }

function Th5uGridColumns.Add: Th5uGridColumn;
begin
  Result := Th5uGridColumn(inherited Add);
  if Result.VisibleIndex < 0 then
    Result.VisibleIndex := Count - 1;
end;

constructor Th5uGridColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uGridColumn);
end;

function Th5uGridColumns.FindByFieldName(const AFieldName: string): Th5uGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].FieldName, AFieldName) then
      Exit(Items[I]);
end;

function Th5uGridColumns.FindById(const AId: string): Th5uGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].Id, AId) then
      Exit(Items[I]);
end;

function Th5uGridColumns.GetItem(AIndex: Integer): Th5uGridColumn;
begin
  Result := Th5uGridColumn(inherited GetItem(AIndex));
end;

procedure Th5uGridColumns.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  MoveColumns([AColumn], ANewVisibleIndex);
end;

procedure Th5uGridColumns.MoveColumns(const AColumns: array of Th5uGridColumn; ANewVisibleIndex: Integer; AHeaderLayout: Th5uHeaderLayout);
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  LList, LAll, LMoving: {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>;
  I, J, LFirst, LInsert: Integer;
  LMove: Boolean;
  LAnchor: Th5uGridColumn;
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
    if (AColumns[I].MovePermission = Th5uColumnMovePermission.Deny) or (AColumns[I].FixedKind <> AColumns[0].FixedKind) then
      Exit;
  end;
  ANewVisibleIndex := EnsureRange(ANewVisibleIndex, 0, Length(LColumns) - Length(AColumns));
  if ANewVisibleIndex = LFirst then
    Exit;
  LList := {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>.Create;
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
      LAll := {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>.Create;
      LMoving := {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>.Create;
      try
        for I := 0 to Count - 1 do
          LAll.Add(Items[I]);
        LAll.Sort({$IFDEF FPC}specialize {$ENDIF}TComparer<Th5uGridColumn>.Construct({$IFDEF FPC}@{$ENDIF}CompareVisibleColumns));
        for I := LAll.Count - 1 downto 0 do
        begin
          LMove := AHeaderLayout.MovesWithColumns(LAll[I], LColumns, LFirst, Length(AColumns));
          for J := 0 to High(AColumns) do
            LMove := LMove or (LAll[I] = AColumns[J]);
          if not LMove then
            Continue;
          if (LAll[I].MovePermission = Th5uColumnMovePermission.Deny) or (LAll[I].FixedKind <> AColumns[0].FixedKind) then
            Exit;
          LMoving.Insert(0, LAll[I]);
          LAll.Delete(I);
        end;
        LInsert := LAll.Count;
        if ANewVisibleIndex + Length(AColumns) < LList.Count then
        begin
          LAnchor := LList[ANewVisibleIndex + Length(AColumns)];
          LInsert := LAll.IndexOf(LAnchor);
          while (LInsert > 0) and AHeaderLayout.MovesWithColumns(LAll[LInsert - 1], LList.ToArray, ANewVisibleIndex + Length(AColumns), LList.Count
            - ANewVisibleIndex - Length(AColumns)) do
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

procedure Th5uGridColumns.NormalizeVisibleIndexes;
var
  LColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
  I: Integer;
begin
  LColumns := VisibleColumns;
  for I := 0 to High(LColumns) do
    LColumns[I].FVisibleIndex := I;
  Changed;
end;

procedure Th5uGridColumns.SetItem(AIndex: Integer; const AValue: Th5uGridColumn);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure Th5uGridColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self, Th5uGridColumn(Item));
end;

function Th5uGridColumns.VisibleColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>;
var
  LList: {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>;
  I: Integer;
begin
  LList := {$IFDEF FPC}specialize {$ENDIF}TList<Th5uGridColumn>.Create;
  try
    for I := 0 to Count - 1 do
      if Items[I].Visible then
        LList.Add(Items[I]);

    LList.Sort({$IFDEF FPC}specialize {$ENDIF}TComparer<Th5uGridColumn>.Construct({$IFDEF FPC}@{$ENDIF}CompareVisibleColumns));
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

{ Th5uHeaderLayoutCell }

constructor Th5uHeaderLayoutCell.Create(ACollection: TCollection);
begin
  inherited;
  FRowSpan := 1;
  FColumnSpan := 1;
  FClassId := h5uClassIdGridHeaderGroupCell;
end;

function Th5uHeaderLayoutCell.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else if FId <> '' then
    Result := FId
  else
    Result := inherited;
end;

procedure Th5uHeaderLayoutCell.Assign(Source: TPersistent);
var
  S: Th5uHeaderLayoutCell;
begin
  if not (Source is Th5uHeaderLayoutCell) then
  begin
    inherited;
    Exit;
  end;
  S := Th5uHeaderLayoutCell(Source);
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
  FWidthInPercent := S.FWidthInPercent;
  FStyleName := S.FStyleName;
  FClassId := S.FClassId;
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetWidth(const AValue: Integer);
begin
  if FWidth = Max(0, AValue) then
    Exit;
  FWidth := Max(0, AValue);
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetMinWidth(const AValue: Integer);
begin
  if FMinWidth = Max(0, AValue) then
    Exit;
  FMinWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMaxWidth < FMinWidth) then
    FMaxWidth := FMinWidth;
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetMaxWidth(const AValue: Integer);
begin
  if FMaxWidth = Max(0, AValue) then
    Exit;
  FMaxWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMinWidth > FMaxWidth) then
    FMinWidth := FMaxWidth;
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetLayoutRow(const AValue: Integer);
begin
  if FLayoutRow = Max(0, AValue) then
    Exit;
  FLayoutRow := Max(0, AValue);
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetLayoutColumn(const AValue: Integer);
begin
  if FLayoutColumn = Max(0, AValue) then
    Exit;
  FLayoutColumn := Max(0, AValue);
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetColumnSpan(const AValue: Integer);
begin
  if FColumnSpan = Max(1, AValue) then
    Exit;
  FColumnSpan := Max(1, AValue);
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetColumnId(const AValue: string);
begin
  if FColumnId = AValue then
    Exit;
  FColumnId := AValue;
  Changed(False);
end;

procedure Th5uHeaderLayoutCell.SetWidthInPercent(const AValue: Double);
begin
  if IsNan(AValue) or IsInfinite(AValue) or (AValue < 0) or (AValue > 100) then
    raise EArgumentOutOfRangeException.Create('WidthInPercent muss zwischen 0 und 100 liegen.');
  if FWidthInPercent = AValue then
    Exit;
  FWidthInPercent := AValue;
  Changed(False);
end;

procedure Th5uHeaderLayoutCells.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is Th5uHeaderLayout then
    Th5uHeaderLayout(GetOwner).Changed;
end;

procedure Th5uHeaderLayout.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure Th5uHeaderLayout.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

{ Th5uHeaderLayoutCells }

function Th5uHeaderLayoutCells.Add: Th5uHeaderLayoutCell;
begin
  Result := Th5uHeaderLayoutCell(inherited Add);
end;

constructor Th5uHeaderLayoutCells.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uHeaderLayoutCell);
end;

function Th5uHeaderLayoutCells.GetItem(AIndex: Integer): Th5uHeaderLayoutCell;
begin
  Result := Th5uHeaderLayoutCell(inherited GetItem(AIndex));
end;

{ Th5uHeaderLayout }

function Th5uHeaderLayout.ContainsCell(ACell: Th5uHeaderLayoutCell): Boolean;
var
  I: Integer;
begin
  for I := 0 to FCells.Count - 1 do
    if FCells[I] = ACell then
      Exit(True);
  Result := False;
end;

function Th5uHeaderLayout.UsesColumnBindings(ACell: Th5uHeaderLayoutCell): Boolean;
var
  LCell: Th5uHeaderLayoutCell;
  I: Integer;
begin
  if ACell.ColumnId <> '' then
    Exit(True);
  for I := 0 to FCells.Count - 1 do
  begin
    LCell := FCells[I];
    if (LCell.ColumnId <> '') and (LCell.LayoutRow >= ACell.LayoutRow) and (LCell.LayoutColumn >= ACell.LayoutColumn) and (LCell.LayoutColumn
      < ACell.LayoutColumn + Max(1, ACell.ColumnSpan)) then
      Exit(True);
  end;
  Result := False;
end;

function Th5uHeaderLayout.ColumnRange(ACell: Th5uHeaderLayoutCell; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; out AFirst, ALast: Integer): Boolean;
var
  LCell: Th5uHeaderLayoutCell;
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
        if (LCell.LayoutRow < ACell.LayoutRow) or (LCell.LayoutColumn < ACell.LayoutColumn) or (LCell.LayoutColumn >= ACell.LayoutColumn
          + Max(1, ACell.ColumnSpan)) then
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

function Th5uHeaderLayout.CanMoveColumns(const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AFirst, ACount, ANewIndex: Integer): Boolean;
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

function Th5uHeaderLayout.MovesWithColumns(AColumn: Th5uGridColumn; const AColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>; AFirst, ACount: Integer): Boolean;
var
  LGroup, LLeaf: Th5uHeaderLayoutCell;
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

procedure Th5uHeaderLayout.ColumnsMoved(const ABefore, AAfter: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uGridColumn>);
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

procedure Th5uHeaderLayout.Assign(Source: TPersistent);
begin
  if Source is Th5uHeaderLayout then
  begin
    FEnabled := Th5uHeaderLayout(Source).FEnabled;
    FRowCount := Th5uHeaderLayout(Source).FRowCount;
    FCells.Assign(Th5uHeaderLayout(Source).FCells);
  end
  else
    inherited;
end;

constructor Th5uHeaderLayout.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FEnabled := False;
  FRowCount := 1;
  FCells := Th5uHeaderLayoutCells.Create(Self);
end;

destructor Th5uHeaderLayout.Destroy;
begin
  FCells.Free;
  inherited;
end;

procedure Th5uHeaderLayout.SetCells(const AValue: Th5uHeaderLayoutCells);
begin
  FCells.Assign(AValue);
end;

procedure Th5uHeaderLayout.SetRowCount(const AValue: Integer);
begin
  FRowCount := EnsureRange(AValue, 1, 16);
  Changed;
end;

{ Th5uRowStyleMapping }

function Th5uRowStyleMapping.GetDisplayName: string;
begin
  if FStyleName <> '' then
    Result := Format('%d = %s', [FValue, FStyleName])
  else
    Result := IntToStr(FValue);
end;

{ Th5uRowStyleMappings }

function Th5uRowStyleMappings.Add: Th5uRowStyleMapping;
begin
  Result := Th5uRowStyleMapping(inherited Add);
end;

constructor Th5uRowStyleMappings.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uRowStyleMapping);
end;

function Th5uRowStyleMappings.FindStyle(AValue: Integer; out AStyleName: string): Boolean;
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

function Th5uRowStyleMappings.GetItem(AIndex: Integer): Th5uRowStyleMapping;
begin
  Result := Th5uRowStyleMapping(inherited GetItem(AIndex));
end;


function Th5uGridColumn.GetColumns: Th5uGridColumns;
begin
  Result := Th5uGridColumns(Collection);
end;

end.

