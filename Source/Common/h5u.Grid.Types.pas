unit h5u.Grid.Types;

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
    SysUtils,
    Types;
  {$ELSE}
    System.Classes,
    System.Rtti,
    System.SysUtils,
    System.UITypes,
    System.Types;
  {$ENDIF}

type
  ThiiClassId = type string;

const
  h5uClassIdGridVisibleRow = ThiiClassId('h5u.grid.visual.row');
  h5uClassIdGridColumn = ThiiClassId('h5u.grid.column.default');
  h5uClassIdGridDataCell = ThiiClassId('h5u.grid.visual.cell.data');
  h5uClassIdGridHeaderCell = ThiiClassId('h5u.grid.visual.cell.header');
  h5uClassIdGridHeaderGroupCell = ThiiClassId('h5u.grid.visual.cell.header-group');
  h5uClassIdGridFixedCell = ThiiClassId('h5u.grid.visual.cell.fixed');
  h5uClassIdGridFooterCell = ThiiClassId('h5u.grid.visual.cell.footer');
  h5uClassIdGridCornerCell = ThiiClassId('h5u.grid.visual.cell.corner');
  h5uClassIdGridTextEditor = ThiiClassId('h5u.grid.editor.text');
  h5uClassIdGridBooleanEditor = ThiiClassId('h5u.grid.editor.boolean');
  h5uClassIdGridImageEditor = ThiiClassId('h5u.grid.editor.image');
  h5uClassIdGridRowMetrics = ThiiClassId('h5u.grid.row-metrics');
  h5uClassIdGridThumbHint = ThiiClassId('h5u.grid.thumb-hint');
  h5uClassIdGridRowSpacing = ThiiClassId('h5u.grid.spacing.row');
  h5uClassIdGridColumnSpacing = ThiiClassId('h5u.grid.spacing.column');
  h5uClassIdGridContentPadding = ThiiClassId('h5u.grid.spacing.content-padding');
  h5uClassIdGridTreeBranchEndBand = ThiiClassId('h5u.grid.spacing.tree-branch-end');
  h5uClassIdGridAdjacentGroupFoldGlyph = ThiiClassId('h5u.grid.visual.adjacent-group-fold-glyph');
  h5uClassIdGridAdjacentGroupEndBand = ThiiClassId('h5u.grid.spacing.adjacent-group-end');
  h5uClassIdDataSession = ThiiClassId('h5u.grid.data.session');
  h5uClassIdDataCache = ThiiClassId('h5u.grid.data.cache');
  h5uClassIdDataPage = ThiiClassId('h5u.grid.data.page');

type
  EhiiGrid = class(Exception);
  {$IFnDEF FPC}
  ThiiLegacyOptionAttribute = class(TCustomAttribute);
  {$ENDIF}
  EhiiFactory = class(EhiiGrid);
  EhiiDataController = class(EhiiGrid);

  ThiiGridPerformanceStage = (Paint, Layout, ColumnLayout, HeightMeasurement, DataUpdate);

  ThiiGridTiming = record
    Count: Int64;
    LastMilliseconds: Double;
    TotalMilliseconds: Double;
    MaxMilliseconds: Double;
  end;

  // Durations measure completed CPU-side work. Nested stages overlap and must
  // not be added together; Paint does not include GPU/display presentation.
  ThiiGridPerformance = class
  private
    FEnabled: Boolean;
    FTimings: array[ThiiGridPerformanceStage] of ThiiGridTiming;
    function GetStage(AIndex: Integer): ThiiGridTiming; inline;
  public
    constructor Create;
    procedure Reset;
    procedure RecordElapsed(AStage: ThiiGridPerformanceStage; AElapsedMilliseconds: Double);
    property Enabled: Boolean read FEnabled write FEnabled;
    property Paint: ThiiGridTiming index 0 read GetStage;
    property Layout: ThiiGridTiming index 1 read GetStage;
    property ColumnLayout: ThiiGridTiming index 2 read GetStage;
    property HeightMeasurement: ThiiGridTiming index 3 read GetStage;
    property DataUpdate: ThiiGridTiming index 4 read GetStage;
  end;

  ThiiRowKey = record
  private
    FValue: string;
  public
    class function Empty: ThiiRowKey; static;
    class function FromString(const AValue: string): ThiiRowKey; static;
    class function FromInt64(const AValue: Int64): ThiiRowKey; static;
    function IsEmpty: Boolean;
    function ToString: string;
    class operator {$IFDEF FPC}={$ELSE}Equal{$ENDIF}(const ALeft, ARight: ThiiRowKey): Boolean;
    class operator {$IFDEF FPC}<>{$ELSE}NotEqual{$ENDIF}(const ALeft, ARight: ThiiRowKey): Boolean;
  end;

  ThiiRowsMovedContext = record
    // All indexes are zero-based. Source indexes address the controller data.
    FirstRowIndex: Int64;
    RowKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiRowKey>;
    SourceRowIndexes: {$IFDEF FPC}specialize {$ENDIF}TArray<Int64>;
    // Target indexes/key refer to the view BEFORE the requested move.
    TargetRowIndex: Int64;
    TargetRowKey: ThiiRowKey;
    TargetSourceRowIndex: Int64;
    InsertAfter: Boolean;
    // First view index of the block after removal and insertion.
    NewFirstRowIndex: Int64;
  end;

  // Notification of a requested drop: the handler must update the data/order.
  ThiiRowsMovedEvent = procedure(Sender: TObject; const AContext: ThiiRowsMovedContext) of object;

  ThiiElementKind = (Grid, View, VisibleRow, VisibleColumn, DataCell, ColumnHeaderCell, ColumnHeaderGroupCell, RowHeaderCell, DataGroupHeaderCell,
    FixedCell, CornerCell, FilterCell, FooterCell, Editor, ThumbHint, RowSpacing, ColumnSpacing, ContentPadding, TreeBranchEndBand,
    AdjacentGroupFoldGlyph, AdjacentGroupEndBand, DetailView, DataSession, DataCache, DataPage);

  ThiiElementPaintPart = (Background, Text, Glyph, Border, ColumnMode);

  ThiiElementFlag = (FixedRow, FixedColumn, Frozen, Header, Footer, Corner, Selected, Focused, Hot, Editing, Disabled, ReadOnly, OddRow, EvenRow,
    PatternRow, TreeBranchEnd, AdjacentGroupFirst, AdjacentGroupLast, AdjacentGroupCollapsed, AdjacentGroupExpanded, AdjacentGroupEnd);
  ThiiElementFlags = set of ThiiElementFlag;

  ThiiCreationReason = (Runtime, Designer, Streaming, AutoGenerate, Clone, LayoutRestore, DetailView, ControllerInternal, ViewportMaterialization);

  ThiiFactoryCacheScope = (None, ClassId, Grid, View, ElementKind, Column, HeaderCell, RowStyleKey);

  ThiiFactoryContext = record
    Grid: TObject;
    View: TObject;
    Level: TObject;
    DataController: TObject;
    DataSession: TObject;
    Column: TObject;
    HeaderCell: TObject;
    RecordLayoutCell: TObject;
    Owner: TComponent;
    Collection: TCollection;

    RowKey: ThiiRowKey;
    SourceRowIndex: Int64;
    ViewRowIndex: Int64;
    RowStyleKey: TValue;
    Value: TValue;

    ElementKind: ThiiElementKind;
    ElementFlags: ThiiElementFlags;
    LayoutRow: Integer;
    LayoutColumn: Integer;
    RowSpan: Integer;
    ColumnSpan: Integer;
    TreeLevel: Integer;
    ClosedTreeLevels: Integer;

    AdjacentGroupIndex: Integer;
    AdjacentGroupId: TValue;
    AdjacentGroupAnchorRowKey: ThiiRowKey;
    AdjacentGroupRowCount: Int64;
    AdjacentGroupCollapsed: Boolean;
    AdjacentGroupFirstRow: Boolean;
    AdjacentGroupLastVisibleRow: Boolean;

    ClassId: ThiiClassId;
    CreationReason: ThiiCreationReason;

    class function Create(AGrid, AView, AController: TObject; const AClassId: ThiiClassId; AElementKind: ThiiElementKind): ThiiFactoryContext; static;
  end;

  ThiiTreeLevelContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: ThiiRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
  end;

  ThiiGetTreeLevelEvent = procedure(Sender: TObject; const AContext: ThiiTreeLevelContext; var ALevel: Integer; var AAvailable: Boolean) of object;

  ThiiTreeBranchEndContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: ThiiRowKey;
    NextRowKey: ThiiRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    CurrentLevel: Integer;
    NextLevel: Integer;
    IsEndOfData: Boolean;
  end;

  ThiiGetTreeBranchEndEvent = procedure(Sender: TObject; const AContext: ThiiTreeBranchEndContext; var AIsBranchEnd: Boolean; var AClosedLevels: Integer) of object;

  ThiiAdjacentGroupInitialState = (Expanded, Collapsed);
  ThiiAdjacentGroupEndBandVisibility = (Never, CollapsedOnly, ExpandedOnly, Always);

  ThiiAdjacentGroupIdContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: ThiiRowKey;
    ControllerRowIndex: Int64;
    SourceRowIndex: Int64;
  end;

  ThiiGetAdjacentGroupIdEvent = procedure(Sender: TObject; const AContext: ThiiAdjacentGroupIdContext; var AGroupId: TValue; var AAvailable: Boolean) of object;

  ThiiAdjacentGroupStateChangedContext = record
    Grid: TObject;
    DataController: TObject;
    GroupId: TValue;
    AnchorRowKey: ThiiRowKey;
    FirstControllerRowIndex: Int64;
    RowCount: Int64;
    Collapsed: Boolean;
  end;

  ThiiAdjacentGroupStateChangedEvent = procedure(Sender: TObject; const AContext: ThiiAdjacentGroupStateChangedContext) of object;

  ThiiColumnRowMovingGesture = (AltDrag, Drag);
  ThiiColumnMovePermission = (Default, Allow, Deny);

  ThiiGridTheme = (ApplicationStyle, Classic2000, Modern, Dark);

  ThiiColumnDataType = (Auto, Text, Integer, Float, Currency, Date, DateTime, Boolean, Image, Time);

  ThiiColumnEditorKind = (Automatic, None, Text, Boolean, Image, Time, Date, DateTime);

  ThiiFixedKind = (None, Left, Right);

  ThiiRowHeightMode = (Fixed, Automatic);

  ThiiAutoHeightMeasureScope = (VisibleViewportColumns, AllVisibleColumns, ExplicitContributorColumns);

  ThiiVerticalScrollMode = (Pixel, WholeRows, PixelSnap);

  ThiiHorizontalScrollMode = (Pixel, WholeColumns, PixelSnap);

  ThiiScrollAxis = (Horizontal, Vertical);

  ThiiScrollHintTrigger = (ThumbTracking, MouseWheel, Keyboard, Touch, Kinetic);
  ThiiScrollHintTriggers = set of ThiiScrollHintTrigger;

  ThiiCacheMode = (None, Viewport, Paged, All, Adaptive);

  ThiiPaginationMode = (Continuous, NumberedPages, Cursor);

  ThiiSelectionKind = (Rows, Columns, CellRanges);
  ThiiSelectionKinds = set of ThiiSelectionKind;

  ThiiSelectionCombinationMode = (Exclusive, Mixed);

  ThiiSelectionScope = (CurrentPage, VisibleRows, CurrentQuery, EntireSource);

  ThiiDataChangeKind = (Reset, LayoutChanged, RowsInserted, RowsDeleted, RowsChanged, CellChanged, PageChanged);

  ThiiDataChange = record
    Kind: ThiiDataChangeKind;
    FirstIndex: Int64;
    Count: Int64;
    RowKey: ThiiRowKey;
    ColumnId: string;
    class function ResetAll: ThiiDataChange; static;
  end;

  ThiiCellRange = record
    StartRowIndex: Int64;
    EndRowIndex: Int64;
    StartColumnIndex: Integer;
    EndColumnIndex: Integer;
    class function Create(AStartRow, AEndRow: Int64; AStartColumn, AEndColumn: Integer): ThiiCellRange; static;
    procedure Normalize;
    function Contains(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
  end;

  ThiiCellAddress = record
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: ThiiRowKey;
    ColumnId: string;
    class function Empty: ThiiCellAddress; static;
    function IsValid: Boolean;
  end;

  ThiiResolvedAppearance = record
    Background: TColor;
    Foreground: TColor;
    Border: TColor;
    Accent: TColor;
    FontStyle: TFontStyles;
    HasBackground: Boolean;
    HasForeground: Boolean;
    HasBorder: Boolean;
    HasAccent: Boolean;
    StyleName: string;
    procedure Clear;
  end;

implementation

{ ThiiGridPerformance }

constructor ThiiGridPerformance.Create;
begin
  inherited Create;
  FEnabled := True;
end;

function ThiiGridPerformance.GetStage(AIndex: Integer): ThiiGridTiming;
begin
  Result := FTimings[ThiiGridPerformanceStage(AIndex)];
end;

procedure ThiiGridPerformance.Reset;
var
  LStage: ThiiGridPerformanceStage;
begin
  for LStage := Low(ThiiGridPerformanceStage) to High(ThiiGridPerformanceStage) do
    FTimings[LStage] := Default(ThiiGridTiming);
end;

procedure ThiiGridPerformance.RecordElapsed(AStage: ThiiGridPerformanceStage; AElapsedMilliseconds: Double);
begin
  if not FEnabled or not (AElapsedMilliseconds >= 0) then
    Exit;
  Inc(FTimings[AStage].Count);
  FTimings[AStage].LastMilliseconds := AElapsedMilliseconds;
  FTimings[AStage].TotalMilliseconds := FTimings[AStage].TotalMilliseconds + AElapsedMilliseconds;
  if AElapsedMilliseconds > FTimings[AStage].MaxMilliseconds then
    FTimings[AStage].MaxMilliseconds := AElapsedMilliseconds;
end;

{ ThiiRowKey }

class operator ThiiRowKey.{$IFDEF FPC}={$ELSE}Equal{$ENDIF}(const ALeft, ARight: ThiiRowKey): Boolean;
begin
  Result := ALeft.FValue = ARight.FValue;
end;

class operator ThiiRowKey.{$IFDEF FPC}<>{$ELSE}NotEqual{$ENDIF}(const ALeft, ARight: ThiiRowKey): Boolean;
begin
  Result := not (ALeft = ARight);
end;

class function ThiiRowKey.Empty: ThiiRowKey;
begin
  Result.FValue := '';
end;

class function ThiiRowKey.FromInt64(const AValue: Int64): ThiiRowKey;
begin
  Result.FValue := IntToStr(AValue);
end;

class function ThiiRowKey.FromString(const AValue: string): ThiiRowKey;
begin
  Result.FValue := AValue;
end;

function ThiiRowKey.IsEmpty: Boolean;
begin
  Result := FValue = '';
end;

function ThiiRowKey.ToString: string;
begin
  Result := FValue;
end;

{ ThiiFactoryContext }

class function ThiiFactoryContext.Create(AGrid, AView, AController: TObject; const AClassId: ThiiClassId; AElementKind: ThiiElementKind): ThiiFactoryContext;
begin
  Result := Default(ThiiFactoryContext);
  Result.Grid := AGrid;
  Result.View := AView;
  Result.DataController := AController;
  Result.ClassId := AClassId;
  Result.ElementKind := AElementKind;
  Result.RowKey := ThiiRowKey.Empty;
  Result.SourceRowIndex := -1;
  Result.ViewRowIndex := -1;
  Result.LayoutRow := -1;
  Result.LayoutColumn := -1;
  Result.RowSpan := 1;
  Result.ColumnSpan := 1;
  Result.TreeLevel := -1;
  Result.ClosedTreeLevels := 0;
  Result.AdjacentGroupIndex := -1;
  Result.AdjacentGroupAnchorRowKey := ThiiRowKey.Empty;
  Result.AdjacentGroupRowCount := 0;
  Result.CreationReason := ThiiCreationReason.Runtime;
end;

{ ThiiDataChange }

class function ThiiDataChange.ResetAll: ThiiDataChange;
begin
  Result := Default(ThiiDataChange);
  Result.Kind := ThiiDataChangeKind.Reset;
  Result.FirstIndex := 0;
  Result.Count := -1;
  Result.RowKey := ThiiRowKey.Empty;
end;

{ ThiiCellRange }

function ThiiCellRange.Contains(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
var
  LRange: ThiiCellRange;
begin
  LRange := Self;
  LRange.Normalize;
  Result := (ARowIndex >= LRange.StartRowIndex) and (ARowIndex <= LRange.EndRowIndex) and (AColumnIndex >= LRange.StartColumnIndex)
    and (AColumnIndex <= LRange.EndColumnIndex);
end;

class function ThiiCellRange.Create(AStartRow, AEndRow: Int64; AStartColumn, AEndColumn: Integer): ThiiCellRange;
begin
  Result.StartRowIndex := AStartRow;
  Result.EndRowIndex := AEndRow;
  Result.StartColumnIndex := AStartColumn;
  Result.EndColumnIndex := AEndColumn;
  Result.Normalize;
end;

procedure ThiiCellRange.Normalize;
var
  LInt64: Int64;
  LInteger: Integer;
begin
  if StartRowIndex > EndRowIndex then
  begin
    LInt64 := StartRowIndex;
    StartRowIndex := EndRowIndex;
    EndRowIndex := LInt64;
  end;

  if StartColumnIndex > EndColumnIndex then
  begin
    LInteger := StartColumnIndex;
    StartColumnIndex := EndColumnIndex;
    EndColumnIndex := LInteger;
  end;
end;

{ ThiiCellAddress }

class function ThiiCellAddress.Empty: ThiiCellAddress;
begin
  Result := Default(ThiiCellAddress);
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  Result.RowKey := ThiiRowKey.Empty;
end;

function ThiiCellAddress.IsValid: Boolean;
begin
  Result := (RowIndex >= 0) and (ColumnIndex >= 0);
end;

{ ThiiResolvedAppearance }

procedure ThiiResolvedAppearance.Clear;
begin
  Self := Default(ThiiResolvedAppearance);
end;

end.

