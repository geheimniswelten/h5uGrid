unit Fmx.h5u.Grid;

interface

{$SCOPEDENUMS ON}

{$IF Defined(ANDROID) or Defined(IOS)}
  {$DEFINE MOBILE}
{$ELSE}
  {$UNDEF MOBILE}
{$ENDIF}

uses
  System.StrUtils,
  System.TypInfo,
  System.Classes,
  System.DateUtils,
  System.Diagnostics,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  FMX.Controls,
  FMX.DateTimeCtrls,
  FMX.Edit,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Forms,
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Values,
  h5u.Grid.Editors,
  h5u.Grid.Moving,
  h5u.Grid.Resizing,
  h5u.Grid.Navigation,
  h5u.Grid.View,
  h5u.Grid.Layout,
  h5u.Grid.RowMetrics,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Sizing,
  h5u.Grid.Selection,
  h5u.Grid.Types,
  Fmx.h5u.Grid.Styles,
  Fmx.h5u.Grid.Editors;

type
  // Types used by the grid API; these are aliases, not additional runtime classes.
  ThiiClassId = h5u.Grid.Types.ThiiClassId;
  EhiiGrid = h5u.Grid.Types.EhiiGrid;
  {$IFNDEF FPC}
  ThiiLegacyOptionAttribute = h5u.Grid.Types.ThiiLegacyOptionAttribute;
  {$ENDIF}
  EhiiFactory = h5u.Grid.Types.EhiiFactory;
  EhiiDataController = h5u.Grid.Types.EhiiDataController;
  ThiiGridPerformanceStage = h5u.Grid.Types.ThiiGridPerformanceStage;
  ThiiGridTiming = h5u.Grid.Types.ThiiGridTiming;
  ThiiGridPerformance = h5u.Grid.Types.ThiiGridPerformance;
  ThiiRowKey = h5u.Grid.Types.ThiiRowKey;
  ThiiRowsMovedContext = h5u.Grid.Types.ThiiRowsMovedContext;
  ThiiRowsMovedEvent = h5u.Grid.Types.ThiiRowsMovedEvent;
  ThiiElementKind = h5u.Grid.Types.ThiiElementKind;
  ThiiElementPaintPart = h5u.Grid.Types.ThiiElementPaintPart;
  ThiiElementFlag = h5u.Grid.Types.ThiiElementFlag;
  ThiiElementFlags = h5u.Grid.Types.ThiiElementFlags;
  ThiiCreationReason = h5u.Grid.Types.ThiiCreationReason;
  ThiiFactoryCacheScope = h5u.Grid.Types.ThiiFactoryCacheScope;
  ThiiFactoryContext = h5u.Grid.Types.ThiiFactoryContext;
  ThiiTreeLevelContext = h5u.Grid.Types.ThiiTreeLevelContext;
  ThiiGetTreeLevelEvent = h5u.Grid.Types.ThiiGetTreeLevelEvent;
  ThiiTreeBranchEndContext = h5u.Grid.Types.ThiiTreeBranchEndContext;
  ThiiGetTreeBranchEndEvent = h5u.Grid.Types.ThiiGetTreeBranchEndEvent;
  ThiiAdjacentGroupInitialState = h5u.Grid.Types.ThiiAdjacentGroupInitialState;
  ThiiAdjacentGroupEndBandVisibility = h5u.Grid.Types.ThiiAdjacentGroupEndBandVisibility;
  ThiiAdjacentGroupIdContext = h5u.Grid.Types.ThiiAdjacentGroupIdContext;
  ThiiGetAdjacentGroupIdEvent = h5u.Grid.Types.ThiiGetAdjacentGroupIdEvent;
  ThiiAdjacentGroupStateChangedContext = h5u.Grid.Types.ThiiAdjacentGroupStateChangedContext;
  ThiiAdjacentGroupStateChangedEvent = h5u.Grid.Types.ThiiAdjacentGroupStateChangedEvent;
  ThiiColumnRowMovingGesture = h5u.Grid.Types.ThiiColumnRowMovingGesture;
  ThiiColumnMovePermission = h5u.Grid.Types.ThiiColumnMovePermission;
  ThiiGridTheme = h5u.Grid.Types.ThiiGridTheme;
  ThiiColumnDataType = h5u.Grid.Types.ThiiColumnDataType;
  ThiiColumnEditorKind = h5u.Grid.Types.ThiiColumnEditorKind;
  ThiiFixedKind = h5u.Grid.Types.ThiiFixedKind;
  ThiiRowHeightMode = h5u.Grid.Types.ThiiRowHeightMode;
  ThiiAutoHeightMeasureScope = h5u.Grid.Types.ThiiAutoHeightMeasureScope;
  ThiiVerticalScrollMode = h5u.Grid.Types.ThiiVerticalScrollMode;
  ThiiHorizontalScrollMode = h5u.Grid.Types.ThiiHorizontalScrollMode;
  ThiiScrollAxis = h5u.Grid.Types.ThiiScrollAxis;
  ThiiScrollHintTrigger = h5u.Grid.Types.ThiiScrollHintTrigger;
  ThiiScrollHintTriggers = h5u.Grid.Types.ThiiScrollHintTriggers;
  ThiiCacheMode = h5u.Grid.Types.ThiiCacheMode;
  ThiiPaginationMode = h5u.Grid.Types.ThiiPaginationMode;
  ThiiSelectionKind = h5u.Grid.Types.ThiiSelectionKind;
  ThiiSelectionKinds = h5u.Grid.Types.ThiiSelectionKinds;
  ThiiSelectionCombinationMode = h5u.Grid.Types.ThiiSelectionCombinationMode;
  ThiiSelectionScope = h5u.Grid.Types.ThiiSelectionScope;
  ThiiDataChangeKind = h5u.Grid.Types.ThiiDataChangeKind;
  ThiiDataChange = h5u.Grid.Types.ThiiDataChange;
  ThiiCellRange = h5u.Grid.Types.ThiiCellRange;
  ThiiCellAddress = h5u.Grid.Types.ThiiCellAddress;
  ThiiResolvedAppearance = h5u.Grid.Types.ThiiResolvedAppearance;
  ThiiGridColumn = h5u.Grid.Columns.ThiiGridColumn;
  ThiiGridColumns = h5u.Grid.Columns.ThiiGridColumns;
  ThiiHeaderLayout = h5u.Grid.Columns.ThiiHeaderLayout;
  ThiiCellEvent = h5u.Grid.Columns.ThiiCellEvent;
  ThiiCellPermissionEvent = h5u.Grid.Columns.ThiiCellPermissionEvent;
  ThiiCellGetValueEvent = h5u.Grid.Columns.ThiiCellGetValueEvent;
  ThiiCellSetValueEvent = h5u.Grid.Columns.ThiiCellSetValueEvent;
  ThiiCellValidateEvent = h5u.Grid.Columns.ThiiCellValidateEvent;
  ThiiGetColumnModeEvent = h5u.Grid.Columns.ThiiGetColumnModeEvent;
  ThiiGetCellEditorEvent = h5u.Grid.Columns.ThiiGetCellEditorEvent;
  ThiiColumnChangedEvent = h5u.Grid.Columns.ThiiColumnChangedEvent;
  ThiiHeaderLayoutCell = h5u.Grid.Columns.ThiiHeaderLayoutCell;
  ThiiHeaderLayoutCells = h5u.Grid.Columns.ThiiHeaderLayoutCells;
  ThiiRowStyleMapping = h5u.Grid.Columns.ThiiRowStyleMapping;
  ThiiRowStyleMappings = h5u.Grid.Columns.ThiiRowStyleMappings;
  ThiiOptionsChangedEvent = h5u.Grid.Options.ThiiOptionsChangedEvent;
  ThiiGridHeaderOptions = h5u.Grid.Options.ThiiGridHeaderOptions;
  ThiiRowIndicatorOptions = h5u.Grid.Options.ThiiRowIndicatorOptions;
  ThiiEditingOptions = h5u.Grid.Options.ThiiEditingOptions;
  ThiiGridAppearanceOptions = h5u.Grid.Options.ThiiGridAppearanceOptions;
  ThiiGridSpacingOptions = h5u.Grid.Options.ThiiGridSpacingOptions;
  ThiiTreeBranchEndBandOptions = h5u.Grid.Options.ThiiTreeBranchEndBandOptions;
  ThiiTreeOptions = h5u.Grid.Options.ThiiTreeOptions;
  ThiiAdjacentGroupEndBandOptions = h5u.Grid.Options.ThiiAdjacentGroupEndBandOptions;
  ThiiAdjacentGroupFoldingOptions = h5u.Grid.Options.ThiiAdjacentGroupFoldingOptions;
  ThiiRowHeightOptions = h5u.Grid.Options.ThiiRowHeightOptions;
  ThiiScrollingOptions = h5u.Grid.Options.ThiiScrollingOptions;
  ThiiScrollHintOptions = h5u.Grid.Options.ThiiScrollHintOptions;
  ThiiPaginationOptions = h5u.Grid.Options.ThiiPaginationOptions;
  ThiiCacheOptions = h5u.Grid.Options.ThiiCacheOptions;
  ThiiRowStyleOptions = h5u.Grid.Options.ThiiRowStyleOptions;
  ThiiCustomizationOptions = h5u.Grid.Options.ThiiCustomizationOptions;
  ThiiWidth = h5u.Grid.Sizing.ThiiWidth;
  ThiiColumnFitMode = h5u.Grid.Sizing.ThiiColumnFitMode;
  ThiiMaxWidthSource = h5u.Grid.Sizing.ThiiMaxWidthSource;
  ThiiColumnSizingOptions = h5u.Grid.Sizing.ThiiColumnSizingOptions;
  ThiiSelectionChangedEvent = h5u.Grid.Selection.ThiiSelectionChangedEvent;
  ThiiGridSelection = h5u.Grid.Selection.ThiiGridSelection;
  ThiiEditorMode = h5u.Grid.Editors.ThiiEditorMode;
  ThiiEditorPlatform = h5u.Grid.Editors.ThiiEditorPlatform;
  ThiiEditorContext = h5u.Grid.Editors.ThiiEditorContext;
  ThiiEditorMeasureWidthEvent = h5u.Grid.Editors.ThiiEditorMeasureWidthEvent;
  ThiiEditorTextEvent = h5u.Grid.Editors.ThiiEditorTextEvent;
  ThiiEditorValueEvent = h5u.Grid.Editors.ThiiEditorValueEvent;
  ThiiEditorDrawEvent = h5u.Grid.Editors.ThiiEditorDrawEvent;
  ThiiEditorKeyEvent = h5u.Grid.Editors.ThiiEditorKeyEvent;
  ThiiEditorPointerEvent = h5u.Grid.Editors.ThiiEditorPointerEvent;
  ThiiGridEditorItem = h5u.Grid.Editors.ThiiGridEditorItem;
  ThiiGridEditorItemClass = h5u.Grid.Editors.ThiiGridEditorItemClass;
  ThiiGridEditors = h5u.Grid.Editors.ThiiGridEditors;
  ThiiDefaultEditors = h5u.Grid.Editors.ThiiDefaultEditors;
  ThiiCustomDataController = h5u.Grid.Data.Core.ThiiCustomDataController;
  ThiiDataControllerLink = h5u.Grid.Data.Core.ThiiDataControllerLink;
  ThiiDataControllerChangedEvent = h5u.Grid.Data.Core.ThiiDataControllerChangedEvent;
  ThiiFactoryObject = h5u.Grid.Factory.ThiiFactoryObject;
  ThiiGetClassEvent = h5u.Grid.Factory.ThiiGetClassEvent;
  ThiiCreateInstanceEvent = h5u.Grid.Factory.ThiiCreateInstanceEvent;
  ThiiConfigureInstanceEvent = h5u.Grid.Factory.ThiiConfigureInstanceEvent;
  ThiiFactoryScope = h5u.Grid.Factory.ThiiFactoryScope;
  ThiiClassFactory = h5u.Grid.Factory.ThiiClassFactory;

  // Keep source compatibility. implementations live in the editor unit.
  ThiiCellDateEdit = Fmx.h5u.Grid.Editors.ThiiCellDateEdit;
  ThiiCellTimeEdit = Fmx.h5u.Grid.Editors.ThiiCellTimeEdit;
  ThiiCellTextEdit = Fmx.h5u.Grid.Editors.ThiiCellTextEdit;

  ThiiCustomGrid = class;
  ThiiFmxVisualCell = class;
  ThiiFmxVisualCellClass = class of ThiiFmxVisualCell;

  ThiiCustomDrawStage = (BeforeDefault, AfterDefault);

  ThiiHitKind = (None, Header, RowIndicator, DataCell, AdjacentGroupGlyph);

  ThiiGetRowHeightContext = record
    Grid: ThiiCustomGrid;
    DataController: ThiiCustomDataController;
    RowKey: ThiiRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    IsEstimated: Boolean;
  end;

  ThiiGetRowHeightEvent = procedure(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Single; var ACacheResult: Boolean) of object;
  ThiiGetRowSpacingEvent = procedure(Sender: TObject; const AContext: ThiiGetRowHeightContext; var ASpacing: Single) of object;

  ThiiThumbHintContext = record
    Grid: ThiiCustomGrid;
    DataController: ThiiCustomDataController;
    Axis: ThiiScrollAxis;
    RowKey: ThiiRowKey;
    ViewRowIndex: Int64;
    Column: ThiiGridColumn;
    Value: TValue;
    DisplayText: string;
  end;

  ThiiGetThumbHintEvent = procedure(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean) of object;

  ThiiFmxDrawContext = record
    FactoryContext: ThiiFactoryContext;
    Bounds: TRectF;
    DisplayText: string;
    Appearance: ThiiResolvedAppearance;
  end;

  ThiiFmxAfterDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;
  ThiiFmxPrepareElementEvent = procedure(Sender: TObject; Control: TObject; ACanvas: TCanvas; const AContext: ThiiFmxDrawContext; APart: ThiiElementPaintPart) of object;
  ThiiFmxCustomDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas; const AContext: ThiiFmxDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean) of object;

  ThiiVisibleColumnInfo = record
    Column: ThiiGridColumn;
    VisibleIndex: Integer;
    Bounds: TRectF;
  end;

  ThiiVisibleRowInfo = record
    RowIndex: Int64;
    RowKey: ThiiRowKey;
    Bounds: TRectF;
    Height: Single;
  end;

  ThiiHitTestInfo = record
    Kind: ThiiHitKind;
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: ThiiRowKey;
    Column: ThiiGridColumn;
    Bounds: TRectF;
    HeaderCell: ThiiHeaderLayoutCell;
    class function Empty: ThiiHitTestInfo; static;
  end;

  ThiiFmxVisualCell = class(ThiiFactoryObject)
  private
    FContext: ThiiFactoryContext;
    FBounds: TRectF;
    FContentBounds: TRectF;
    FValue: TValue;
    FDisplayText: string;
    FAppearance: ThiiResolvedAppearance;
    FInUse: Boolean;
  protected
    procedure PrepareCanvas(AGrid: ThiiCustomGrid; ACanvas: TCanvas; APart: ThiiElementPaintPart);
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); virtual;
  public
    procedure BindCell(const AContext: ThiiFactoryContext; const ABounds: TRectF; const AValue: TValue; const ADisplayText: string;
      const AAppearance: ThiiResolvedAppearance); virtual;
    procedure Paint(AGrid: ThiiCustomGrid; ACanvas: TCanvas); virtual;
    property Context: ThiiFactoryContext read FContext;
    property Bounds: TRectF read FBounds;
    // Text/images keep their horizontal layout while Bounds is the visible hit area.
    property ContentBounds: TRectF read FContentBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: ThiiResolvedAppearance read FAppearance;
  end;

  // Lightweight pooled painter for row/column separators, content padding
  // and the tree branch-end band. Its ClassId is resolved per grid instance.
  Th5uFmxSpacingCell = class(ThiiFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiFmxDataCell = class(ThiiFmxVisualCell)
  private
    FBitmap: TBitmap;
    FBitmapSignature: Integer;
    procedure EnsureBitmap;
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  ThiiFmxHeaderCell = class(ThiiFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  Th5uFmxAdjacentGroupGlyphCell = class(ThiiFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiCustomGrid = class(TStyledControl)
  private
    FShowColumnModes: Boolean;
    FColumns: ThiiGridColumns;
    FColumnSizing: ThiiColumnSizingOptions;
    FHeader: ThiiGridHeaderOptions;
    FRowIndicator: ThiiRowIndicatorOptions;
    FEditing: ThiiEditingOptions;
    FSizingVersion: Integer;
    FAutoWidthConstraints: string;
    function GetMinWidth: Single;
    function GetMaxWidth: Single;
    function GetAutoWidthRowLimit: Integer;
    function GetTheme: ThiiGridTheme;
    function GetHeaderRowHeight: Single;
    procedure SetHeaderRowHeight(const AValue: Single);
    function GetRowIndicatorWidth: Single;
    procedure SetRowIndicatorWidth(const AValue: Single);
    function GetShowHeader: Boolean;
    procedure SetShowHeader(const AValue: Boolean);
    function GetShowRowIndicator: Boolean;
    procedure SetShowRowIndicator(const AValue: Boolean);
    function GetAllowEditing: Boolean;
    procedure SetAllowEditing(const AValue: Boolean);
    function GetImmediateEdit: Boolean;
    procedure SetImmediateEdit(const AValue: Boolean);
    procedure ReadSizingVersion(AReader: TReader);
    procedure WriteSizingVersion(AWriter: TWriter);
    procedure SetColumnSizing(const AValue: ThiiColumnSizingOptions);
    procedure SetHeader(const AValue: ThiiGridHeaderOptions);
    procedure SetRowIndicator(const AValue: ThiiRowIndicatorOptions);
    procedure SetEditing(const AValue: ThiiEditingOptions);
    procedure EditorTemplatesChanged(Sender: TObject);
    procedure AppearanceChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure EditingChanged(Sender: TObject);
    function MonitorWidth: Single;
    procedure PrepareColumnWidthDefaults(AReferenceWidth: Single);
  private
    FMeasuringAutoWidths: Boolean;
    FAutoWidthsDirty: Boolean;
    FAutoWidthFont: string;
    procedure SetMinWidth(const AValue: Single);
    procedure SetMaxWidth(const AValue: Single);
    procedure SetAutoWidthRowLimit(const AValue: Integer);
    procedure MeasureAutoWidths;
    procedure ResolveColumnWidths(AAvailableWidth: Single);
  private
    FHeaderLayout: ThiiHeaderLayout;
    FDataController: ThiiCustomDataController;
    FDataLink: ThiiDataControllerLink;
    FFactoryScope: ThiiFactoryScope;
    FSharedClassFactory: ThiiClassFactory;
    FSelection: ThiiGridSelection;
    FNavigation: Th5uGridNavigation;
    FRowHeight: ThiiRowHeightOptions;
    FScrolling: ThiiScrollingOptions;
    FScrollHints: ThiiScrollHintOptions;
    FRowStyles: ThiiRowStyleOptions;
    FCustomization: ThiiCustomizationOptions;
    FSpacing: ThiiGridSpacingOptions;
    FAppearance: ThiiGridAppearanceOptions;
    FTree: ThiiTreeOptions;
    FAdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions;
    FView: Th5uGridView;


    FOnCanFocus: ThiiCellPermissionEvent;
    FOnCanEdit: ThiiCellPermissionEvent;
    FOnValidate: ThiiCellValidateEvent;
    FOnGetValue: ThiiCellGetValueEvent;
    FOnSetValue: ThiiCellSetValueEvent;
    FOnCellClick: ThiiCellEvent;
    FOnColumnHeaderClick: ThiiCellEvent;
    FOnCellEnter: ThiiCellEvent;
    FOnCellExit: ThiiCellEvent;
    FOnRowIndicatorClick: ThiiCellEvent;
    FOnSelectionChange: TNotifyEvent;
    FClickDownHit: ThiiHitTestInfo;
    FSelectingRange, FSelectionDragging, FMouseEditPending: Boolean;
    FSelectionDragKind: ThiiSelectionKind;
    FSelectionDragShift: TShiftState;
    FSelectionDragOrigin: TPointF;
    FSelectionDragLast: ThiiCellAddress;
    FMovingColumns: TArray<ThiiGridColumn>;
    FMovingRowKeys: TArray<ThiiRowKey>;
    FMovingFirstRowIndex: Int64;
    FMoveDragging: Boolean;
    FMovePoint: TPointF;
    FMoveCaption: string;
    FMovingHeaderCell: ThiiHeaderLayoutCell;
    FMovePreviewWidth: Single;
    FHeaderTouch: Boolean;
    FMoveCursor: TCursor;
    FResizingColumn: ThiiGridColumn;
    FResizeStartX: Single;
    FResizeOriginalWidth: Single;
    FResizeCursorActive: Boolean;
    FResizeCursor: TCursor;
    FHeaderInteraction: Boolean;
    FOnRowsMoved: ThiiRowsMovedEvent;
    FLastNotifiedCell: ThiiCellAddress;
    function FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean = False): Boolean;
    function FocusedCellHit(out AHit: ThiiHitTestInfo): Boolean;
    function CellHit(const LCell: ThiiCellAddress; out AHit: ThiiHitTestInfo): Boolean;
    procedure EditFocusedCell(AAutomatic: Boolean);
    function NavigationRowExtent(ARow: Int64): Single;
    function HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
    procedure SearchCharacter(AChar: Char);
  private
    FTextSize: Single;

    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintBackground: TRectangle;
    FThumbHintTimer: TTimer;
    FTouchTracking, FTouchScrolling, FGesturePanning, FDispatchingTouch: Boolean;
    FTouchOrigin: TPointF;
    FTouchOffsetX: Single;
    FTouchOffsetY: Double;
    FTouchShift: TShiftState;
    FEditRowIndex: Int64;
    FEditRowKey: ThiiRowKey;
    FEditColumn: ThiiGridColumn;
    FCommittingEditor: Boolean;
    FEditors: ThiiFmxGridEditors;
    FEditorCache: Th5uGridEditorCache;
    FDefaultEditors: ThiiDefaultEditors;
    FActiveEditor: ThiiGridEditorItem;
    procedure SetEditors(AValue: ThiiFmxGridEditors);
    procedure SetDefaultEditors(AValue: ThiiDefaultEditors);
    procedure FinishEditor(ACommitted: Boolean);
    procedure EditorRequestCommit(Sender: TObject);
    procedure EditorRequestCancel(Sender: TObject);
    procedure ProcessEditorKey(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    function CachedEditor(const AName: string): ThiiGridEditorItem;
    function CellEditorContext(AColumn: ThiiGridColumn; ARow: Int64; const ABounds: TRectF): ThiiEditorContext;
    function CellEditorClick(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
    function CellEditorAutoEdit(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
    function CellEditorHit(AColumn: ThiiGridColumn; ARow: Int64; const ABounds: TRectF; const APoint: TPointF): Boolean;
  private
    FEditorExitBlocked: Boolean;

    FHorizontalOffset: Single;
    FVerticalOffset: Double;
    FAllColumns: TArray<ThiiVisibleColumnInfo>;
    FVisibleColumns: TArray<ThiiVisibleColumnInfo>;
    FVisibleRows: TArray<ThiiVisibleRowInfo>;
    FCellPool: TObjectList<ThiiFmxVisualCell>;
    FRowMetrics: Th5uGridRowMetrics;
    FPerformance: ThiiGridPerformance;
    FUpdatingScrollBars: Boolean;
    FInitialized: Boolean;
    FLastMousePoint: TPointF;

    FOnGetRowHeight: ThiiGetRowHeightEvent;
    FOnGetRowSpacing: ThiiGetRowSpacingEvent;
    FOnGetThumbHint: ThiiGetThumbHintEvent;
    FOnAfterDraw: ThiiFmxAfterDrawEvent;
    FOnPrepareElement: ThiiFmxPrepareElementEvent;
    FOnCustomDraw: ThiiFmxCustomDrawEvent;
    function GetOnGetTreeLevel: ThiiGetTreeLevelEvent;
    procedure SetOnGetTreeLevel(const AValue: ThiiGetTreeLevelEvent);
    function GetOnGetTreeBranchEnd: ThiiGetTreeBranchEndEvent;
    procedure SetOnGetTreeBranchEnd(const AValue: ThiiGetTreeBranchEndEvent);
    function GetOnGetAdjacentGroupId: ThiiGetAdjacentGroupIdEvent;
    procedure SetOnGetAdjacentGroupId(const AValue: ThiiGetAdjacentGroupIdEvent);
    function GetOnAdjacentGroupStateChanged: ThiiAdjacentGroupStateChangedEvent;
    procedure SetOnAdjacentGroupStateChanged(const AValue: ThiiAdjacentGroupStateChangedEvent);

    function ViewDataController: ThiiCustomDataController;
    function IndicatorExtent: Single;
    function MetricCellHeight(ARow: Int64; AColumn: ThiiGridColumn): Single;
    procedure MetricAdjustHeight(ARow: Int64; const AKey: ThiiRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean);
    function MetricRowExtent(ARow: Int64; AAllowMeasure: Boolean): Single;
    function MetricRowSpacing(ARow: Int64; const AKey: ThiiRowKey): Single;
    procedure ColumnsChanged(Sender: TObject; AColumn: ThiiGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: ThiiDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure BeginSelectionDrag(AKind: ThiiSelectionKind; X, Y: Single; AShift: TShiftState);
    procedure UpdateSelectionDrag(X, Y: Single);
    procedure EndSelectionDrag;
    function ColumnResizeAt(X, Y: Single; ATouch: Boolean): ThiiGridColumn;
    function IsResizeHeaderEdge(AX, AY: Single): Boolean;
    function BeginColumnResize(X, Y: Single; ATouch: Boolean): Boolean;
    procedure UpdateColumnResize(X: Single);
    procedure SetResizeCursor(AActive: Boolean);
    procedure SelectRightClickCell(const AHit: ThiiHitTestInfo);
    function IsRowMoveGesture(AShift: TShiftState): Boolean;
    function GetHeaderCellBounds(ACell: ThiiHeaderLayoutCell): TRectF;
    function GetHeaderCellViewport(ACell: ThiiHeaderLayoutCell): TRectF;
    function HeaderCellAtPoint(X, Y: Single): ThiiHeaderLayoutCell;
    function BeginColumnMove(AColumnIndex: Integer; X, Y: Single): Boolean;
    function BeginRowMove(ARowIndex: Int64; X, Y: Single): Boolean;
    procedure UpdateHeaderMove(X, Y: Single);
    function FinishHeaderMove(X, Y: Single): Boolean;
    function GetColumnMoveHeaderBounds(const AInfo: ThiiVisibleColumnInfo): TRectF;
    function ColumnMoveTarget(X, Y: Single; out ANewIndex: Integer; out AMarkerX, AMarkerTop: Single): Boolean;
    function CanMoveColumn(AColumn: ThiiGridColumn): Boolean;
    function IsColumnMoveGesture(AColumn: ThiiGridColumn; AShift: TShiftState): Boolean;
    procedure SelectHeaderRange(AKind: ThiiSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
    procedure SelectionChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    function GetColumnViewportRect(AColumn: ThiiGridColumn): TRectF;
    function GetVisibleCellBounds(AColumn: ThiiGridColumn; const AColumnBounds, ARowBounds: TRectF): TRectF;
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);

    procedure SetColumns(const AValue: ThiiGridColumns);
    procedure SetHeaderLayout(const AValue: ThiiHeaderLayout);
    procedure SetDataController(const AValue: ThiiCustomDataController);
    procedure SetSharedClassFactory(const AValue: ThiiClassFactory);
    procedure SetRowHeight(const AValue: ThiiRowHeightOptions);
    procedure SetScrolling(const AValue: ThiiScrollingOptions);
    procedure SetScrollHints(const AValue: ThiiScrollHintOptions);
    procedure SetRowStyles(const AValue: ThiiRowStyleOptions);
    procedure SetCustomization(const AValue: ThiiCustomizationOptions);
    procedure SetSpacing(const AValue: ThiiGridSpacingOptions);
    procedure SetAppearance(const AValue: ThiiGridAppearanceOptions);
    procedure SetTree(const AValue: ThiiTreeOptions);
    procedure SetAdjacentGroupFolding(const AValue: ThiiAdjacentGroupFoldingOptions);
    procedure SetSelection(const AValue: ThiiGridSelection);
    procedure SetTheme(const AValue: ThiiGridTheme);
    procedure SetGridLines(const AValue: Boolean);

    function GetOnGetClass: ThiiGetClassEvent;
    procedure SetOnGetClass(const AValue: ThiiGetClassEvent);
    function GetOnCreateInstance: ThiiCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
    function GetOnConfigureInstance: ThiiConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);

    function GetUnpaddedViewportRect: TRectF;
    function GetViewportRect: TRectF;
    function GetDataViewportRect: TRectF;
    function GetHeaderHeight: Single;
    function GetTotalColumnWidth: Single;
    function GetEffectiveColumnRightSpacing(AColumn: ThiiGridColumn): Single;
    procedure InvalidateAdjacentGroupMap(AClearStates: Boolean = False);
    function GetViewRowCount: Int64;
    function GetViewRowKey(AViewRowIndex: Int64): ThiiRowKey;
    function GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
    procedure PrepareViewRange(AFirstViewRow, ACount: Int64);
    function TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure PopulateAdjacentGroupContext(var AContext: ThiiFactoryContext; AViewRowIndex: Int64);
    procedure DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
    function GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): Single;
    function GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out AElementKind: ThiiElementKind; out AColor: TAlphaColor; out AStyleName: string;
      out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Single;
    function GetGridLines: Boolean;
    function ResolveColor(const AColor: TColor; AFallback: TAlphaColor): TAlphaColor;
    function ResolveDefaultCellColor: TAlphaColor;
    function ResolveRowSpacingColor: TAlphaColor;
    function ResolveColumnSpacingColor: TAlphaColor;
    function ResolveContentPaddingColor: TAlphaColor;
    function ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TAlphaColor;
    function ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TAlphaColor;
    function BeginPerformanceTiming: Int64;
    procedure EndPerformanceTiming(AStage: ThiiGridPerformanceStage; AStarted: Int64);
    procedure PrepareRowMetrics;
    function GetEstimatedTotalRowHeight(AAllowMeasure: Boolean = True): Double;
    function CanUpdateLayout: Boolean;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure UpdateActiveEditorBounds;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: ThiiFactoryContext; ADefaultClass: ThiiFmxVisualCellClass): ThiiFmxVisualCell;

    procedure DrawContentPadding;
    procedure DrawCustomHeaderLayout;
    procedure DrawHeaders;
    procedure DrawColumnMoveFeedback;
    procedure DrawRows;
    procedure DrawSpacingRect(const ABounds: TRectF; AElementKind: ThiiElementKind; AColumn: ThiiGridColumn; AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AColor: TAlphaColor;
      const AStyleName: string = ''; ATreeLevel: Integer = -1; AClosedTreeLevels: Integer = 0);
    function GetAdjacentGroupGlyphRect(const ARowInfo: ThiiVisibleRowInfo): TRectF;
    procedure DrawAdjacentGroupGlyph(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);
    function GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AAllowMeasure: Boolean = True): Single;
    function MeasureCellHeight(AViewRowIndex: Int64; AColumn: ThiiGridColumn): Single;
    function FindFirstVisibleRow(AOffset: Double; out ATop: Single): Int64;
    function ResolveRowBackground(AViewRowIndex: Int64): TAlphaColor;
    function ResolveCellAppearance(AViewRowIndex: Int64; AColumn: ThiiGridColumn; ASelected, AFocused: Boolean): ThiiResolvedAppearance;

    function BuildThumbHintText(AAxis: ThiiScrollAxis; out AContext: ThiiThumbHintContext): string;
    procedure ShowThumbHint(AAxis: ThiiScrollAxis);
    procedure HideThumbHint;

    procedure StartEdit(const AHit: ThiiHitTestInfo);
    function TryFocusCell(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean): Boolean;
    function AllowCellEdit(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
    function GetCellValue(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
    function GetCellText(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): string;
    procedure PutCellValue(AColumn: ThiiGridColumn; ARow: Int64; const AValue: TValue);
    procedure NotifyCellClick(AColumn: ThiiGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
    procedure SetShowColumnModes(AValue: Boolean);
    procedure GetColumnMode(AColumn: ThiiGridColumn; var AMode: string);
    function ColumnModeSymbols(AColumn: ThiiGridColumn): string;
    procedure PrepareGridCanvas(const ABounds: TRectF; AKind: ThiiElementKind);
    procedure BeginTouchScroll(const APoint: TPointF);
    procedure MoveTouchScroll(const APoint: TPointF);
    procedure CommitEditor;
    procedure CancelEditor;

    function GetVisualCellClass(const AContext: ThiiFactoryContext; ADefaultClass: ThiiFmxVisualCellClass): ThiiFmxVisualCellClass; virtual;
    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: ThiiFmxDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean);
  protected
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    procedure DoExit; override;
    procedure DoMouseLeave; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoGesture(const EventInfo: TGestureEventInfo; var Handled: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure DblClick; override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;
  public
    function GetCellEditor(AColumn: ThiiGridColumn; ARow: Int64): ThiiGridEditorItem;
    function MeasureColumnWidth(AColumn: ThiiGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1): Single;
    procedure AutoSizeColumn(AColumn: ThiiGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1);
    procedure InvalidateColumnWidths;
    procedure ClearEditorCache;
    property ActiveEditor: ThiiGridEditorItem read FActiveEditor;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GridHitTest(X, Y: Single): ThiiHitTestInfo;
    procedure InvalidateAllRowHeights;
    procedure MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
    procedure SetColumnVisible(AColumn: ThiiGridColumn; AVisible: Boolean);
    procedure ToggleAdjacentGroup(AViewRowIndex: Int64);
    procedure SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
    procedure ExpandAllAdjacentGroups;
    procedure CollapseAllAdjacentGroups;
    procedure ResetAdjacentGroupStates;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;

    property FactoryScope: ThiiFactoryScope read FFactoryScope;
    property Performance: ThiiGridPerformance read FPerformance;
  protected
    property ColumnSizing: ThiiColumnSizingOptions read FColumnSizing write SetColumnSizing;
    property Header: ThiiGridHeaderOptions read FHeader write SetHeader;
    property RowIndicator: ThiiRowIndicatorOptions read FRowIndicator write SetRowIndicator;
    property Editing: ThiiEditingOptions read FEditing write SetEditing;
    property DataController: ThiiCustomDataController read FDataController write SetDataController;
    property SharedClassFactory: ThiiClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Editors: ThiiFmxGridEditors read FEditors write SetEditors;
    property DefaultEditors: ThiiDefaultEditors read FDefaultEditors write SetDefaultEditors;
    // Limits for the combined column content, not the control itself. Zero disables a limit.
    property MinWidth: Single read GetMinWidth write SetMinWidth stored False;
    property MaxWidth: Single read GetMaxWidth write SetMaxWidth stored False;
    property AutoWidthRowLimit: Integer read GetAutoWidthRowLimit write SetAutoWidthRowLimit stored False;
    property Columns: ThiiGridColumns read FColumns write SetColumns;
    property HeaderLayout: ThiiHeaderLayout read FHeaderLayout write SetHeaderLayout stored False;
    property Selection: ThiiGridSelection read FSelection write SetSelection;
    property RowHeight: ThiiRowHeightOptions read FRowHeight write SetRowHeight;
    property Scrolling: ThiiScrollingOptions read FScrolling write SetScrolling;
    property ScrollHints: ThiiScrollHintOptions read FScrollHints write SetScrollHints;
    property RowStyles: ThiiRowStyleOptions read FRowStyles write SetRowStyles;
    property Customization: ThiiCustomizationOptions read FCustomization write SetCustomization;
    property Spacing: ThiiGridSpacingOptions read FSpacing write SetSpacing;
    property Appearance: ThiiGridAppearanceOptions read FAppearance write SetAppearance;
    property Tree: ThiiTreeOptions read FTree write SetTree;
    property AdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions read FAdjacentGroupFolding write SetAdjacentGroupFolding;
    property Theme: ThiiGridTheme read GetTheme write SetTheme stored False;
    property HeaderRowHeight: Single read GetHeaderRowHeight write SetHeaderRowHeight stored False;
    property RowIndicatorWidth: Single read GetRowIndicatorWidth write SetRowIndicatorWidth stored False;
    property ShowHeader: Boolean read GetShowHeader write SetShowHeader stored False;
    property ShowRowIndicator: Boolean read GetShowRowIndicator write SetShowRowIndicator stored False;
    property AllowEditing: Boolean read GetAllowEditing write SetAllowEditing stored False;
    property ImmediateEdit: Boolean read GetImmediateEdit write SetImmediateEdit stored False;
    property GridLines: Boolean read GetGridLines write SetGridLines default True;
    property TextSize: Single read FTextSize write FTextSize;

    property OnGetClass: ThiiGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: ThiiGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: ThiiGetRowSpacingEvent read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: ThiiGetThumbHintEvent read FOnGetThumbHint write FOnGetThumbHint;
    property OnAfterDraw: ThiiFmxAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;
    property OnPrepareElement: ThiiFmxPrepareElementEvent read FOnPrepareElement write FOnPrepareElement;
    property OnCustomDraw: ThiiFmxCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnGetTreeLevel: ThiiGetTreeLevelEvent read GetOnGetTreeLevel write SetOnGetTreeLevel;
    property OnGetTreeBranchEnd: ThiiGetTreeBranchEndEvent read GetOnGetTreeBranchEnd write SetOnGetTreeBranchEnd;
    property OnGetAdjacentGroupId: ThiiGetAdjacentGroupIdEvent read GetOnGetAdjacentGroupId write SetOnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged: ThiiAdjacentGroupStateChangedEvent read GetOnAdjacentGroupStateChanged write SetOnAdjacentGroupStateChanged;
    property OnCanFocus: ThiiCellPermissionEvent read FOnCanFocus write FOnCanFocus;
    property OnCanEdit: ThiiCellPermissionEvent read FOnCanEdit write FOnCanEdit;
    property OnValidate: ThiiCellValidateEvent read FOnValidate write FOnValidate;
    property OnGetValue: ThiiCellGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiCellSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCellClick: ThiiCellEvent read FOnCellClick write FOnCellClick;
    property OnColumnHeaderClick: ThiiCellEvent read FOnColumnHeaderClick write FOnColumnHeaderClick;
    property OnCellEnter: ThiiCellEvent read FOnCellEnter write FOnCellEnter;
    property OnCellExit: ThiiCellEvent read FOnCellExit write FOnCellExit;
    property OnRowIndicatorClick: ThiiCellEvent read FOnRowIndicatorClick write FOnRowIndicatorClick;
    property OnRowsMoved: ThiiRowsMovedEvent read FOnRowsMoved write FOnRowsMoved;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property ShowColumnModes: Boolean read FShowColumnModes write SetShowColumnModes default False;
  end;

  ThiiGrid = class(ThiiCustomGrid)
  published
    property Align;
    property Anchors;
    property CanFocus;
    property ClipChildren;
    property ClipParent;
    property Cursor;
    property DragMode;
    property Enabled;
    property Height;
    property HitTest;
    property Margins;
    property Opacity;
    property Padding;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    //property StyleLookup;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;

    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property DataController;
    property SharedClassFactory;
    property Editors;
    property DefaultEditors;
    // Limits for the combined column content, not the control itself. Zero disables a limit.
    [ThiiLegacyOption]
    property MinWidth;
    [ThiiLegacyOption]
    property MaxWidth;
    [ThiiLegacyOption]
    property AutoWidthRowLimit;
    property Columns;
    [ThiiLegacyOption]
    property HeaderLayout;
    property Selection;
    property RowHeight;
    property Scrolling;
    property ScrollHints;
    property RowStyles;
    property Customization;
    property Spacing;
    property Appearance;
    property Tree;
    property AdjacentGroupFolding;
    [ThiiLegacyOption]
    property Theme;
    [ThiiLegacyOption]
    property HeaderRowHeight;
    [ThiiLegacyOption]
    property RowIndicatorWidth;
    [ThiiLegacyOption]
    property ShowHeader;
    [ThiiLegacyOption]
    property ShowRowIndicator;
    [ThiiLegacyOption]
    property AllowEditing;
    [ThiiLegacyOption]
    property ImmediateEdit;
    // Convenience switch for all grid-wide one-pixel separators.
    // Explicit per-column RightSpacing values remain independently configurable.
    property GridLines;
    property TextSize;

    property OnGetClass;
    property OnCreateInstance;
    property OnConfigureInstance;
    property OnGetRowHeight;
    property OnGetRowSpacing;
    property OnGetThumbHint;
    property OnAfterDraw;
    property OnPrepareElement;
    property OnCustomDraw;
    property OnGetTreeLevel;
    property OnGetTreeBranchEnd;
    property OnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged;
    property OnCanFocus;
    property OnCanEdit;
    property OnValidate;
    property OnGetValue;
    property OnSetValue;
    property OnCellClick;
    property OnColumnHeaderClick;
    property OnCellEnter;
    property OnCellExit;
    property OnRowIndicatorClick;
    property OnRowsMoved;
    property OnSelectionChange;
    property ShowColumnModes;

    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
  end;

implementation

function h5uRectFIntersects(const A, B: TRectF): Boolean;
begin
  Result := (A.Right > B.Left) and (A.Left < B.Right) and (A.Bottom > B.Top) and (A.Top < B.Bottom);
end;

function ThiiCustomGrid.GetMinWidth: Single;
begin
  Result := FColumnSizing.MinContentWidth;
end;

procedure ThiiCustomGrid.SetMinWidth(const AValue: Single);
begin
  FColumnSizing.MinContentWidth := AValue;
end;

function ThiiCustomGrid.GetMaxWidth: Single;
begin
  Result := FColumnSizing.MaxContentWidth;
end;

procedure ThiiCustomGrid.SetMaxWidth(const AValue: Single);
begin
  FColumnSizing.MaxContentWidth := AValue;
end;

function ThiiCustomGrid.GetAutoWidthRowLimit: Integer;
begin
  Result := FColumnSizing.AutoWidthRowLimit;
end;

procedure ThiiCustomGrid.SetAutoWidthRowLimit(const AValue: Integer);
begin
  FColumnSizing.AutoWidthRowLimit := AValue;
end;

function ThiiCustomGrid.GetTheme: ThiiGridTheme;
begin
  Result := FAppearance.Theme;
end;

procedure ThiiCustomGrid.SetTheme(const AValue: ThiiGridTheme);
begin
  FAppearance.Theme := AValue;
end;

function ThiiCustomGrid.GetHeaderRowHeight: Single;
begin
  Result := FHeader.RowHeight;
end;

procedure ThiiCustomGrid.SetHeaderRowHeight(const AValue: Single);
begin
  FHeader.RowHeight := AValue;
end;

function ThiiCustomGrid.GetRowIndicatorWidth: Single;
begin
  Result := FRowIndicator.Width;
end;

procedure ThiiCustomGrid.SetRowIndicatorWidth(const AValue: Single);
begin
  FRowIndicator.Width := AValue;
end;

function ThiiCustomGrid.GetShowHeader: Boolean;
begin
  Result := FHeader.Visible;
end;

procedure ThiiCustomGrid.SetShowHeader(const AValue: Boolean);
begin
  FHeader.Visible := AValue;
end;

function ThiiCustomGrid.GetShowRowIndicator: Boolean;
begin
  Result := FRowIndicator.Visible;
end;

procedure ThiiCustomGrid.SetShowRowIndicator(const AValue: Boolean);
begin
  FRowIndicator.Visible := AValue;
end;

function ThiiCustomGrid.GetAllowEditing: Boolean;
begin
  Result := FEditing.AllowEditing;
end;

procedure ThiiCustomGrid.SetAllowEditing(const AValue: Boolean);
begin
  FEditing.AllowEditing := AValue;
end;

function ThiiCustomGrid.GetImmediateEdit: Boolean;
begin
  Result := FEditing.ImmediateEdit;
end;

procedure ThiiCustomGrid.SetImmediateEdit(const AValue: Boolean);
begin
  FEditing.ImmediateEdit := AValue;
end;

procedure ThiiCustomGrid.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('SizingVersion', ReadSizingVersion, WriteSizingVersion, True);
end;

procedure ThiiCustomGrid.ReadSizingVersion(AReader: TReader);
begin
  FSizingVersion := AReader.ReadInteger;
end;

procedure ThiiCustomGrid.WriteSizingVersion(AWriter: TWriter);
begin
  AWriter.WriteInteger(1);
end;

procedure ThiiCustomGrid.SetColumnSizing(const AValue: ThiiColumnSizingOptions);
begin
  FColumnSizing.Assign(AValue);
end;

procedure ThiiCustomGrid.SetHeader(const AValue: ThiiGridHeaderOptions);
begin
  FHeader.Assign(AValue);
end;

procedure ThiiCustomGrid.SetRowIndicator(const AValue: ThiiRowIndicatorOptions);
begin
  FRowIndicator.Assign(AValue);
end;

procedure ThiiCustomGrid.SetEditing(const AValue: ThiiEditingOptions);
begin
  FEditing.Assign(AValue);
end;

procedure ThiiCustomGrid.EditorTemplatesChanged(Sender: TObject);
begin
  FAutoWidthsDirty := True;
  if not FInitialized then
    Exit;
  InvalidateAllRowHeights;
  Repaint;
end;

procedure ThiiCustomGrid.AppearanceChanged(Sender: TObject);
begin
  Repaint;
end;

procedure ThiiCustomGrid.ThemeChanged(Sender: TObject);
begin
  if not FInitialized then
    Exit;
  OptionsChanged(Sender);
end;

procedure ThiiCustomGrid.EditingChanged(Sender: TObject);
begin
  if FInitialized and not FEditing.AllowEditing then
    CancelEditor;
end;

function ThiiCustomGrid.MonitorWidth: Single;
begin
  Result := Screen.WorkAreaRect.Width;
  if Root is TCommonCustomForm then
    Result := Screen.DisplayFromForm(TCommonCustomForm(Root)).Workarea.Width;
end;

procedure ThiiCustomGrid.PrepareColumnWidthDefaults(AReferenceWidth: Single);
var
  Column: ThiiGridColumn;
  AvailableMonitorWidth: Single;
begin
  AvailableMonitorWidth := MonitorWidth;
  for Column in FColumns.VisibleColumns do
    h5uResolveColumnWidthDefaults(Column, FColumnSizing, FEditors, FDefaultEditors, AReferenceWidth, AvailableMonitorWidth);
end;

{ ThiiHitTestInfo }

class function ThiiHitTestInfo.Empty: ThiiHitTestInfo;
begin
  Result := Default(ThiiHitTestInfo);
  Result.Kind := ThiiHitKind.None;
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  Result.RowKey := ThiiRowKey.Empty;
end;

{ ThiiFmxVisualCell }

procedure ThiiFmxVisualCell.BindCell(const AContext: ThiiFactoryContext; const ABounds: TRectF; const AValue: TValue; const ADisplayText: string;
  const AAppearance: ThiiResolvedAppearance);
begin
  FContext := AContext;
  FBounds := ABounds;
  FContentBounds := ABounds;
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

procedure ThiiFmxVisualCell.PrepareCanvas(AGrid: ThiiCustomGrid; ACanvas: TCanvas; APart: ThiiElementPaintPart);
var
  LContext: ThiiFmxDrawContext;
begin
  if not Assigned(AGrid.FOnPrepareElement) then
    Exit;
  LContext.FactoryContext := Context;
  LContext.Bounds := Bounds;
  LContext.DisplayText := DisplayText;
  LContext.Appearance := Appearance;
  AGrid.FOnPrepareElement(AGrid, Self, ACanvas, LContext, APart);
end;

procedure ThiiCustomGrid.PrepareGridCanvas(const ABounds: TRectF; AKind: ThiiElementKind);
var
  LContext: ThiiFmxDrawContext;
begin
  if not Assigned(FOnPrepareElement) then
    Exit;
  LContext := Default(ThiiFmxDrawContext);
  LContext.FactoryContext := ThiiFactoryContext.Create(Self, Self, FDataController, '', AKind);
  LContext.FactoryContext.ViewRowIndex := -1;
  LContext.Bounds := ABounds;
  FOnPrepareElement(Self, Self, Canvas, LContext, ThiiElementPaintPart.Background);
end;

procedure ThiiFmxVisualCell.Paint(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LContext: ThiiFmxDrawContext;
  LDrawDefault: Boolean;
  LState: TCanvasSaveState;
begin
  LState := nil;
  if Assigned(AGrid.FOnPrepareElement) or not FContentBounds.EqualsTo(FBounds) then
    LState := ACanvas.SaveState;
  try
    if not FContentBounds.EqualsTo(FBounds) then
      ACanvas.IntersectClipRect(FBounds);
    LContext.FactoryContext := FContext;
    LContext.Bounds := FBounds;
    LContext.DisplayText := FDisplayText;
    LContext.Appearance := FAppearance;

    LDrawDefault := True;
    AGrid.DoCustomDraw(ACanvas, LContext, ThiiCustomDrawStage.BeforeDefault, LDrawDefault);
    if LDrawDefault then
      PaintDefault(AGrid, ACanvas);
    AGrid.DoCustomDraw(ACanvas, LContext, ThiiCustomDrawStage.AfterDefault, LDrawDefault);
  finally
    if Assigned(LState) then
      ACanvas.RestoreState(LState);
  end;
end;

procedure ThiiFmxVisualCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LBackground: TAlphaColor;
begin
  if Appearance.HasBackground then
    LBackground := h5uColorToFmx(Appearance.Background)
  else
    LBackground := AGrid.ResolveDefaultCellColor;

  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := LBackground;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);
end;

{ Th5uFmxSpacingCell }

procedure Th5uFmxSpacingCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := h5uColorToFmx(Appearance.Background);
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);
end;

{ Th5uFmxAdjacentGroupGlyphCell }

procedure Th5uFmxAdjacentGroupGlyphCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LPalette: ThiiFmxPalette;
  LRect: TRectF;
  LMidX: Single;
  LMidY: Single;
begin
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  LRect := Bounds;

  if Appearance.HasBackground then
    ACanvas.Fill.Color := h5uColorToFmx(Appearance.Background)
  else
    ACanvas.Fill.Color := AGrid.ResolveDefaultCellColor;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);

  LRect.Inflate(-1, -1);
  if (LRect.Width < 7) or (LRect.Height < 7) then
    Exit;

  ACanvas.Fill.Color := LPalette.CellBackground;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := LPalette.CellText;
  ACanvas.Stroke.Thickness := 1;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Glyph);
  ACanvas.DrawRect(LRect, 0, 0, AllCorners, 1);

  LMidX := (LRect.Left + LRect.Right) / 2;
  LMidY := (LRect.Top + LRect.Bottom) / 2;
  ACanvas.DrawLine(PointF(LRect.Left + 2, LMidY), PointF(LRect.Right - 2, LMidY), 1);
  if Context.AdjacentGroupCollapsed then
    ACanvas.DrawLine(PointF(LMidX, LRect.Top + 2), PointF(LMidX, LRect.Bottom - 2), 1);
end;

{ ThiiFmxDataCell }

destructor ThiiFmxDataCell.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure ThiiFmxDataCell.EnsureBitmap;
var
  LBytes: TBytes;
  LStream: TBytesStream;
  LSignature: Integer;
begin
  if not Value.IsType<TBytes> then
  begin
    FreeAndNil(FBitmap);
    FBitmapSignature := 0;
    Exit;
  end;

  LBytes := Value.AsType<TBytes>;
  LSignature := Length(LBytes);
  if Length(LBytes) > 0 then
    LSignature := LSignature xor LBytes[0] xor (Integer(LBytes[High(LBytes)]) shl 8);

  if Assigned(FBitmap) and (FBitmapSignature = LSignature) then
    Exit;

  FreeAndNil(FBitmap);
  FBitmapSignature := LSignature;
  if Length(LBytes) = 0 then
    Exit;

  FBitmap := TBitmap.Create;
  LStream := TBytesStream.Create(LBytes);
  try
    try
      FBitmap.LoadFromStream(LStream);
    except
      FreeAndNil(FBitmap);
    end;
  finally
    LStream.Free;
  end;
end;

procedure ThiiFmxDataCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LEditor: ThiiGridEditorItem;
  LEditorContext: ThiiEditorContext;
  LHandled: Boolean;
  LRow: ThiiVisibleRowInfo;
  LGlyph: TRectF;
  LColumn: ThiiGridColumn;
  LPalette: ThiiFmxPalette;
  LTextRect: TRectF;
  LTextColor: TAlphaColor;
  LAlign: TTextAlign;
begin
  inherited;
  if Context.ElementKind = ThiiElementKind.RowHeaderCell then
  begin
    LRow.RowIndex := Context.ViewRowIndex;
    LRow.RowKey := Context.RowKey;
    LRow.Bounds := Bounds;
    LGlyph := AGrid.GetAdjacentGroupGlyphRect(LRow);
    LTextRect := Bounds;
    LTextRect.Inflate(-2, 0);
    LAlign := TTextAlign.Center;
    if not LGlyph.IsEmpty then
    begin
      LTextRect.Left := Max(LTextRect.Left, LGlyph.Right + 2);
      LAlign := TTextAlign.Trailing;
    end;
    ACanvas.Fill.Kind := TBrushKind.Solid;
    ACanvas.Fill.Color := h5uGetFmxPalette(AGrid.Theme).CellText;
    ACanvas.Font.Size := AGrid.TextSize;
    ACanvas.Font.Style := [];
    PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Text);
    if LTextRect.Width > 0 then
      ACanvas.FillText(LTextRect, DisplayText, False, 1, [], LAlign, TTextAlign.Center);
    Exit;
  end;
  if not (Context.Column is ThiiGridColumn) then
    Exit;

  // Mobile edit styles can be transparent. Do not draw the old cell content
  // behind an active text/date editor, even when its style is replaced.
  if (AGrid.FEditColumn = Context.Column) and (AGrid.FEditRowIndex = Context.ViewRowIndex)
    and (Assigned(AGrid.FActiveEditor) and AGrid.FActiveEditor.Active and (AGrid.FActiveEditor.Mode = ThiiEditorMode.Text)) then
    Exit;
  LColumn := ThiiGridColumn(Context.Column);
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  if Appearance.HasForeground then
    LTextColor := h5uColorToFmx(Appearance.Foreground)
  else
    LTextColor := LPalette.CellText;

  LEditor := AGrid.GetCellEditor(LColumn, Context.ViewRowIndex);
  if not Assigned(LEditor) then
    LEditor := AGrid.CachedEditor(AGrid.DefaultEditors.DataTypeEditor(LColumn.DataType));
  LEditorContext := Default(ThiiEditorContext);
  LEditorContext.Grid := AGrid;
  LEditorContext.Column := LColumn;
  LEditorContext.RowIndex := Context.ViewRowIndex;
  LEditorContext.RowKey := Context.RowKey;
  LEditorContext.Bounds := ContentBounds;
  LEditorContext.Value := Value;
  LEditorContext.Text := DisplayText;
  LEditorContext.Canvas := ACanvas;
  LEditorContext.Foreground := LTextColor;
  LEditorContext.Background := LPalette.CellBackground;
  ACanvas.Font.Size := AGrid.TextSize;
  if Appearance.HasBackground then
    LEditorContext.Background := h5uColorToFmx(Appearance.Background);
  if LEditor is ThiiFmxImageCellEditor then
    EnsureBitmap;
  LEditorContext.Image := FBitmap;
  LEditorContext.PreparePaint :=
    procedure(APart: ThiiElementPaintPart)
    begin
      PrepareCanvas(AGrid, ACanvas, APart);
    end;
  if (LEditor = AGrid.FActiveEditor) and (AGrid.FEditColumn = LColumn) and (AGrid.FEditRowIndex = Context.ViewRowIndex) then
  begin
    if LEditor.Mode = ThiiEditorMode.Graphic then
      LEditorContext.Value := LEditor.GetValue;
    LHandled := LEditor.DrawEditor(LEditorContext);
  end
  else
    LHandled := LEditor.DrawDisplay(LEditorContext);
  if not LHandled then
    AGrid.CachedEditor('TextEditor').DrawDisplay(LEditorContext);

  if ThiiElementFlag.Focused in Context.ElementFlags then
  begin
    ACanvas.Stroke.Color := LPalette.FocusBorder;
    ACanvas.Stroke.Thickness := 2;
    PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Border);
    ACanvas.DrawRect(Bounds, 0, 0, AllCorners, 1);
    ACanvas.Stroke.Thickness := 1;
  end;
end;

{ ThiiFmxHeaderCell }

procedure ThiiFmxHeaderCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LPalette: ThiiFmxPalette;
  LRect, LSymbolRect: TRectF;
  LSymbols: string;
  LState: TCanvasSaveState;
begin
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := LPalette.HeaderBackground;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  LRect := ContentBounds;
  LRect.Inflate(-5, -2);
  ACanvas.Font.Size := AGrid.TextSize;
  ACanvas.Font.Style := [TFontStyle.fsBold];
  ACanvas.Fill.Color := LPalette.HeaderText;
  LSymbols := AGrid.ColumnModeSymbols(ThiiGridColumn(Context.Column));
  if LSymbols <> '' then
  begin
    LState := ACanvas.SaveState;
    try
      ACanvas.Fill.Color := TAlphaColorRec.Maroon;
      PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.ColumnMode);
      LSymbolRect := LRect;
      LSymbolRect.Right := Min(LSymbolRect.Right, LSymbolRect.Left + ACanvas.TextWidth(LSymbols) + 4);
      ACanvas.FillText(LSymbolRect, LSymbols, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
      LRect.Left := LSymbolRect.Right + 3;
    finally
      ACanvas.RestoreState(LState);
    end;
  end;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Text);
  ACanvas.FillText(LRect, DisplayText, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  ACanvas.Font.Style := [];
end;

{ ThiiCustomGrid }

function ThiiCustomGrid.AcquireVisualCell(const AContext: ThiiFactoryContext; ADefaultClass: ThiiFmxVisualCellClass): ThiiFmxVisualCell;
var
  LClass: ThiiFmxVisualCellClass;
  LCell: ThiiFmxVisualCell;
  LCreateContext: ThiiFactoryContext;
begin
  LClass := GetVisualCellClass(AContext, ADefaultClass);
  for LCell in FCellPool do
    if not LCell.FInUse and (LCell.ClassType = LClass) then
    begin
      LCell.FInUse := True;
      FFactoryScope.BindInstance(AContext, LCell);
      Exit(LCell);
    end;

  LCreateContext := AContext;
  LCreateContext.Owner := Self;
  LCreateContext.CreationReason := ThiiCreationReason.ViewportMaterialization;

  Result := ThiiFmxVisualCell(FFactoryScope.CreateInstance(LCreateContext, ThiiFmxVisualCell, LClass));
  Result.FInUse := True;
  FCellPool.Add(Result);
  FFactoryScope.BindInstance(AContext, Result);
end;

procedure ThiiCustomGrid.BeginVisualPass;
var
  LCell: ThiiFmxVisualCell;
begin
  for LCell in FCellPool do
    if LCell.FInUse then
    begin
      FFactoryScope.UnbindInstance(LCell.Context, LCell);
      LCell.FInUse := False;
    end;
end;

function ThiiCustomGrid.BuildThumbHintText(AAxis: ThiiScrollAxis; out AContext: ThiiThumbHintContext): string;
var
  LTop: Single;
  LIndex: Int64;
  LColumn: ThiiGridColumn;
  LColumns: TArray<ThiiGridColumn>;
  LInfo: ThiiVisibleColumnInfo;
begin
  AContext := Default(ThiiThumbHintContext);
  AContext.Grid := Self;
  AContext.DataController := FDataController;
  AContext.Axis := AAxis;
  Result := '';

  if AAxis = ThiiScrollAxis.Vertical then
  begin
    if not Assigned(FDataController) or (GetViewRowCount = 0) then
      Exit;
    LIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
    if LIndex < 0 then
      Exit;

    AContext.ViewRowIndex := LIndex;
    AContext.RowKey := GetViewRowKey(LIndex);
    LColumn := FColumns.FindById(FScrollHints.VerticalColumnId);
    if not Assigned(LColumn) then
    begin
      LColumns := FColumns.VisibleColumns;
      if Length(LColumns) > 0 then
        LColumn := LColumns[0];
    end;

    AContext.Column := LColumn;
    if Assigned(LColumn) then
    begin
      AContext.Value := GetViewValue(LIndex, LColumn.FieldName);
      Result := GetViewDisplayText(LIndex, LColumn.FieldName, LColumn.DisplayFormat);
      AContext.DisplayText := Result;
    end;

    if FScrollHints.ShowRowPosition then
    begin
      if Result <> '' then
        Result := Result + ' — ';
      Result := Result + Format('Zeile %d von %d', [LIndex + 1, GetViewRowCount]);
    end;
  end
  else
  begin
    LColumn := nil;
    for LInfo in FAllColumns do
      if (LInfo.Column.FixedKind = ThiiFixedKind.None) and (LInfo.Bounds.Right > GetDataViewportRect.Left) then
      begin
        LColumn := LInfo.Column;
        Break;
      end;
    AContext.Column := LColumn;
    if Assigned(LColumn) then
      if LColumn.ScrollHintText <> '' then
        Result := LColumn.ScrollHintText
      else
        Result := LColumn.Caption;
  end;
end;




procedure ThiiCustomGrid.InvalidateColumnWidths;
begin
  FAutoWidthsDirty := True;
  Repaint;
end;

procedure ThiiCustomGrid.AutoSizeColumn(AColumn: ThiiGridColumn; AFirstRow, ARowCount: Int64);
var
  LWidth: Single;
begin
  LWidth := MeasureColumnWidth(AColumn, AFirstRow, ARowCount);
  FColumns.BeginUpdate;
  try
    AColumn.AutoWidth := False;
    AColumn.WidthInPercent := 0;
    AColumn.Width := LWidth;
  finally
    FColumns.EndUpdate;
  end;
end;

procedure ThiiCustomGrid.MeasureAutoWidths;
var
  LColumn: ThiiGridColumn;
  LFont, LConstraints: string;
  LCount: Int64;
begin
  ResolveColumnWidths(GetViewportRect.Width);
  LConstraints := '';
  for LColumn in FColumns.VisibleColumns do
    LConstraints := LConstraints + FloatToStr(LColumn.ResolvedMinWidth) + ':' + FloatToStr(LColumn.ResolvedMaxWidth) + ';';
  if LConstraints <> FAutoWidthConstraints then
  begin
    FAutoWidthsDirty := True;
    FAutoWidthConstraints := LConstraints;
  end;
  LFont := FloatToStr(FTextSize);
  if LFont <> FAutoWidthFont then
  begin
    FAutoWidthsDirty := True;
    InvalidateAllRowHeights;
  end;
  if not FAutoWidthsDirty then
    Exit;
  // Clear before reading: asynchronous or reentrant data notifications must survive.
  FAutoWidthsDirty := False;
  FAutoWidthFont := LFont;
  LCount := FColumnSizing.AutoWidthRowLimit;
  if LCount = 0 then
    LCount := -1;
  FMeasuringAutoWidths := True;
  try
    try
      for LColumn in FColumns.VisibleColumns do
        if LColumn.AutoWidth then
          LColumn.SetMeasuredWidth(MeasureColumnWidth(LColumn, 0, LCount));
    except
      FAutoWidthsDirty := True;
      raise;
    end;
  finally
    FMeasuringAutoWidths := False;
  end;
end;

procedure ThiiCustomGrid.ResolveColumnWidths(AAvailableWidth: Single);
begin
  PrepareColumnWidthDefaults(AAvailableWidth - IndicatorExtent);
  h5uResolveColumnWidths(FColumns, FHeaderLayout, FSpacing.DefaultColumnRightSpacing, AAvailableWidth - IndicatorExtent,
    FColumnSizing.MinContentWidth, FColumnSizing.MaxContentWidth, FColumnSizing.FitMode);
end;

function ThiiCustomGrid.MeasureColumnWidth(AColumn: ThiiGridColumn; AFirstRow, ARowCount: Int64): Single;
var
  LBitmap: TBitmap;
  LContext: ThiiEditorContext;
  LEditor: ThiiGridEditorItem;
  LRow, LCount, LEnd: Int64;
  LWidth: Single;
begin
  if not Assigned(AColumn) or (AColumn.Collection <> FColumns) then
    raise EArgumentException.Create('Die Spalte gehört nicht zu diesem Grid.');
  if not FMeasuringAutoWidths then
  begin
    ResolveColumnWidths(GetViewportRect.Width);
    if not AColumn.Visible then
      h5uResolveColumnWidthDefaults(AColumn, FColumnSizing, FEditors, FDefaultEditors, Max(0.0, GetViewportRect.Width - IndicatorExtent),
        MonitorWidth);
  end;
  Result := AColumn.ResolvedMinWidth;
  if Result >= AColumn.ResolvedMaxWidth then
    Exit;
  if not Assigned(FDataController) then
    Exit;
  LCount := GetViewRowCount;
  AFirstRow := EnsureRange(AFirstRow, Int64(0), LCount);
  if ARowCount < 0 then
    ARowCount := LCount - AFirstRow;
  LEnd := AFirstRow + Min(ARowCount, LCount - AFirstRow);
  if AFirstRow >= LEnd then
    Exit;
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(1, 1);
    if not LBitmap.Canvas.BeginScene then
      Exit;
    try
      LBitmap.Canvas.Font.Size := FTextSize;
      LBitmap.Canvas.Font.Style := [];
      LContext := Default(ThiiEditorContext);
      LContext.Grid := Self;
      LContext.Column := AColumn;
      LContext.Canvas := LBitmap.Canvas;
      LContext.Bounds := RectF(0, 0, AColumn.LayoutWidth, FRowHeight.EstimatedHeight);
      LRow := AFirstRow;
      while LRow < LEnd do
      begin
        // Bounded preparation keeps explicit full scans compatible with paged sources.
        PrepareViewRange(LRow, Min(Int64(128), LEnd - LRow));
        LCount := Min(Int64(128), LEnd - LRow);
        while LCount > 0 do
        begin
          if FView.IsViewRowAvailable(LRow) then
          begin
            LContext.RowIndex := LRow;
            LContext.RowKey := GetViewRowKey(LRow);
            LContext.Value := GetCellValue(AColumn, LRow, True);
            LContext.Text := GetCellText(AColumn, LRow, True);
            LEditor := GetCellEditor(AColumn, LRow);
            if not Assigned(LEditor) then
              LEditor := CachedEditor(FDefaultEditors.DataTypeEditor(AColumn.DataType));
            LWidth := LEditor.MeasureWidth(LContext);
            if LWidth < 0 then
              LWidth := CachedEditor('TextEditor').MeasureWidth(LContext);
            if not IsNan(LWidth) and not IsInfinite(LWidth) then
              Result := Max(Result, AColumn.ConstrainWidth(EnsureRange(LWidth, 0.0, Single(h5uUnlimitedWidth))));
            if Result >= AColumn.ResolvedMaxWidth then
              Exit;
          end;
          Inc(LRow);
          Dec(LCount);
        end;
      end;
    finally
      LBitmap.Canvas.EndScene;
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure ThiiCustomGrid.UpdateActiveEditorBounds;
var
  LColumn: ThiiVisibleColumnInfo;
  LRow: ThiiVisibleRowInfo;
begin
  if not Assigned(FActiveEditor) or not FActiveEditor.Active or not Assigned(FEditColumn) then
    Exit;
  for LRow in FVisibleRows do
    if LRow.RowIndex = FEditRowIndex then
      for LColumn in FVisibleColumns do
        if LColumn.Column = FEditColumn then
        begin
          FActiveEditor.UpdateBounds(GetVisibleCellBounds(FEditColumn, LColumn.Bounds, LRow.Bounds));
          Exit;
        end;
  FActiveEditor.UpdateBounds(TRectF.Empty);
end;

procedure ThiiCustomGrid.BuildColumnLayout;
var
  LStarted: Int64;
  LLayout: TArray<Th5uColumnLayoutInfo>;
  LView: TRectF;
  I, LVisibleCount: Integer;
begin
  LStarted := BeginPerformanceTiming;
  try
    LView := GetViewportRect;
    LLayout := h5uBuildColumnLayout(FColumns, FSpacing.DefaultColumnRightSpacing, LView.Left, LView.Right, IndicatorExtent, FHorizontalOffset,
      LView.Bottom > LView.Top);
    SetLength(FAllColumns, Length(LLayout));
    SetLength(FVisibleColumns, Length(LLayout));
    LVisibleCount := 0;
    for I := 0 to High(LLayout) do
    begin
      FAllColumns[I].Column := LLayout[I].Column;
      FAllColumns[I].VisibleIndex := LLayout[I].VisibleIndex;
      FAllColumns[I].Bounds := RectF(LLayout[I].Left, LView.Top, LLayout[I].Right, LView.Bottom);
      if LLayout[I].Visible then
      begin
        FVisibleColumns[LVisibleCount] := FAllColumns[I];
        Inc(LVisibleCount);
      end;
    end;
    SetLength(FVisibleColumns, LVisibleCount);
  finally
    EndPerformanceTiming(ThiiGridPerformanceStage.ColumnLayout, LStarted);
  end;
end;

function ThiiCustomGrid.IndicatorExtent: Single;
begin
  Result := 0;
  if FRowIndicator.Visible then
    Result := FRowIndicator.Width + FSpacing.DefaultColumnRightSpacing;
end;

procedure ThiiCustomGrid.CancelEditor;
begin
  FinishEditor(False);
end;

procedure ThiiCustomGrid.SetShowColumnModes(AValue: Boolean);
begin
  if FShowColumnModes = AValue then
    Exit;
  FShowColumnModes := AValue;
  Repaint;
end;

procedure ThiiCustomGrid.GetColumnMode(AColumn: ThiiGridColumn; var AMode: string);
begin
  AMode := h5uColumnMode(AColumn, FDataController, FTree.LevelColumnId, FAdjacentGroupFolding.IdColumnId, FRowStyles.StyleKeyColumnId,
    FScrollHints.VerticalColumnId);
end;

function ThiiCustomGrid.ColumnModeSymbols(AColumn: ThiiGridColumn): string;
begin
  Result := '';
  if Assigned(AColumn) and (FShowColumnModes or (csDesigning in ComponentState)) then
    Result := h5uColumnModeSymbols(AColumn.Mode);
end;

procedure ThiiCustomGrid.ColumnsChanged(Sender: TObject; AColumn: ThiiGridColumn);
begin
  FAutoWidthsDirty := True;
  InvalidateAdjacentGroupMap(False);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

function ThiiCustomGrid.TryFocusCell(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean): Boolean;
var
  LColumn: ThiiGridColumn;
  LAllow: Boolean;
begin
  Result := False;
  if not CanUpdateLayout then
    Exit;
  LColumn := FColumns.FindById(ACell.ColumnId);
  if not Assigned(LColumn) then
    Exit;
  if (FSelection.FocusedCell.RowIndex <> ACell.RowIndex) or (FSelection.FocusedCell.ColumnId <> ACell.ColumnId) then
  begin
    LAllow := h5uCellPermission(Self, LColumn, ACell.RowIndex, True, LColumn.OnCanFocus, FOnCanFocus);
    Result := LAllow;
    if not Result then
      Exit;
    if Assigned(FEditColumn) then
      CommitEditor;
  end;
  FNavigation.HeaderSelectionActive := False;
  FSelection.SetFocus(ACell, AUpdateAnchor);
  Result := True;
end;

function ThiiCustomGrid.AllowCellEdit(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
begin
  Result := False;
  if not CanUpdateLayout then
    Exit;
  Result := h5uCellPermission(Self, AColumn, ARow, FEditing.AllowEditing and not AColumn.ReadOnly and CanEditViewValue(ARow, AColumn.FieldName),
    AColumn.OnCanEdit, FOnCanEdit);
end;

function ThiiCustomGrid.GetCellValue(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
begin
  Result := GetViewValue(ARow, AColumn.FieldName);
  if CanUpdateLayout then
    h5uOverrideCellValue(Self, AColumn, ARow, ADisplay, FOnGetValue, Result);
end;

function ThiiCustomGrid.GetCellText(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  Result := h5uCellText(AColumn, ARow, ADisplay, Assigned(AColumn.OnGetValue) or Assigned(FOnGetValue), GetCellValue, GetViewValue,
    GetViewDisplayText);
end;

procedure ThiiCustomGrid.PutCellValue(AColumn: ThiiGridColumn; ARow: Int64; const AValue: TValue);
var
  LValue: TValue;
begin
  if not CanUpdateLayout then
    Exit;
  LValue := h5uPrepareCellValue(Self, AColumn, ARow, AValue, FOnValidate, FOnSetValue);
  SetViewValue(ARow, AColumn.FieldName, LValue);
end;

procedure ThiiCustomGrid.NotifyCellClick(AColumn: ThiiGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
begin
  if CanUpdateLayout then
    h5uNotifyCellClick(Self, AColumn, ARow, AHeader, AIndicator, FOnCellClick, FOnColumnHeaderClick, FOnRowIndicatorClick);
end;

procedure ThiiCustomGrid.CommitEditor;
var
  LValue: TValue;
  LEditedKey: ThiiRowKey;
begin
  if FCommittingEditor or not Assigned(FActiveEditor) or not FActiveEditor.Active or not Assigned(FEditColumn) or not Assigned(FDataController) then
    Exit;
  if not FActiveEditor.Modified then
  begin
    FinishEditor(True);
    Exit;
  end;
  FCommittingEditor := True;
  try
    try
      if FActiveEditor.UsesTextValue and (Assigned(FEditColumn.OnSetValue) or Assigned(FOnSetValue)) then
        LValue := TValue.From<string>(FActiveEditor.GetText)
      else
        LValue := FActiveEditor.GetValue;
      LEditedKey := FEditRowKey;
      PutCellValue(FEditColumn, FEditRowIndex, LValue);
      FinishEditor(True);
      FRowMetrics.Remove(LEditedKey.ToString);
      Repaint;
    except
      FEditorExitBlocked := True;
      if Assigned(FActiveEditor) then
        FActiveEditor.Focus;
      raise;
    end;
  finally
    FCommittingEditor := False;
  end;
end;

function ThiiCustomGrid.GetOnGetAdjacentGroupId: ThiiGetAdjacentGroupIdEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetAdjacentGroupId;
end;

procedure ThiiCustomGrid.SetOnGetAdjacentGroupId(const AValue: ThiiGetAdjacentGroupIdEvent);
begin
  FView.OnGetAdjacentGroupId := AValue;
end;

function ThiiCustomGrid.GetOnGetTreeLevel: ThiiGetTreeLevelEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetTreeLevel;
end;

procedure ThiiCustomGrid.SetOnGetTreeLevel(const AValue: ThiiGetTreeLevelEvent);
begin
  FView.OnGetTreeLevel := AValue;
end;

function ThiiCustomGrid.GetOnGetTreeBranchEnd: ThiiGetTreeBranchEndEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetTreeBranchEnd;
end;

procedure ThiiCustomGrid.SetOnGetTreeBranchEnd(const AValue: ThiiGetTreeBranchEndEvent);
begin
  FView.OnGetTreeBranchEnd := AValue;
end;

function ThiiCustomGrid.GetOnAdjacentGroupStateChanged: ThiiAdjacentGroupStateChangedEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnAdjacentGroupStateChanged;
end;

procedure ThiiCustomGrid.SetOnAdjacentGroupStateChanged(const AValue: ThiiAdjacentGroupStateChangedEvent);
begin
  FView.OnAdjacentGroupStateChanged := AValue;
end;

function ThiiCustomGrid.ViewDataController: ThiiCustomDataController;
begin
  Result := FDataController;
end;

constructor ThiiCustomGrid.Create(AOwner: TComponent);
begin
  inherited;

  FFactoryScope := ThiiFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FFactoryScope.RegisterClass(h5uClassIdGridDataCell, ThiiFmxVisualCell, ThiiFmxDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridFixedCell, ThiiFmxVisualCell, ThiiFmxDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderCell, ThiiFmxVisualCell, ThiiFmxHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderGroupCell, ThiiFmxVisualCell, ThiiFmxHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupFoldGlyph, ThiiFmxVisualCell, Th5uFmxAdjacentGroupGlyphCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupEndBand, ThiiFmxVisualCell, Th5uFmxSpacingCell);

  FEditors := ThiiFmxGridEditors.Create(Self);
  FEditors.OnChanged := EditorTemplatesChanged;
  FEditorCache := Th5uGridEditorCache.Create;
  FDefaultEditors := ThiiDefaultEditors.Create;
  FDefaultEditors.OnChanged := EditorTemplatesChanged;

  FColumns := ThiiGridColumns.Create(Self);
  FColumns.OnChanged := ColumnsChanged;
  FColumns.OnGetMode := GetColumnMode;

  FColumnSizing := ThiiColumnSizingOptions.Create;
  FColumnSizing.OnChanged := OptionsChanged;
  FHeader := ThiiGridHeaderOptions.Create(Self);
  FHeader.RowHeight := 28;
  FHeader.OnChanged := OptionsChanged;
  FHeaderLayout := FHeader.Layout;
  FRowIndicator := ThiiRowIndicatorOptions.Create;
  FRowIndicator.Width := 38;
  FRowIndicator.OnChanged := OptionsChanged;
  FEditing := ThiiEditingOptions.Create;
  FEditing.OnChanged := EditingChanged;
  FAutoWidthsDirty := True;

  FLastNotifiedCell := ThiiCellAddress.Empty;

  FSelection := ThiiGridSelection.Create;
  FSelection.OnChanged := SelectionChanged;

  FRowHeight := ThiiRowHeightOptions.Create;
  FRowHeight.OnChanged := OptionsChanged;

  FScrolling := ThiiScrollingOptions.Create;
  FScrolling.OnChanged := OptionsChanged;

  FScrollHints := ThiiScrollHintOptions.Create;
  FScrollHints.OnChanged := OptionsChanged;

  FRowStyles := ThiiRowStyleOptions.Create;
  FRowStyles.OnChanged := OptionsChanged;

  FCustomization := ThiiCustomizationOptions.Create;

  FSpacing := ThiiGridSpacingOptions.Create;
  FSpacing.OnChanged := OptionsChanged;

  FAppearance := ThiiGridAppearanceOptions.Create;
  FAppearance.OnChanged := AppearanceChanged;
  FAppearance.OnThemeChanged := ThemeChanged;
  FSpacing.BindAppearance(FAppearance);

  FAdjacentGroupFolding := ThiiAdjacentGroupFoldingOptions.Create;
  FAdjacentGroupFolding.OnChanged := OptionsChanged;

  FTree := ThiiTreeOptions.Create;
  FTree.OnChanged := OptionsChanged;

  FView := Th5uGridView.Create(Self, FColumns, FTree, FAdjacentGroupFolding, ViewDataController);

  FDataLink := ThiiDataControllerLink.Create;
  FDataLink.OnChanged := DataChanged;

  FCellPool := TObjectList<ThiiFmxVisualCell>.Create(True);

  FRowMetrics := Th5uGridRowMetrics.Create;
  FPerformance := ThiiGridPerformance.Create;

  FTextSize := 12;
  FEditRowIndex := -1;

  FVScrollBar := TScrollBar.Create(Self);
  FVScrollBar.Stored := False;
  FVScrollBar.Parent := Self;
  FVScrollBar.Orientation := TOrientation.Vertical;
  FVScrollBar.OnChange := ScrollChanged;

  FHScrollBar := TScrollBar.Create(Self);
  FHScrollBar.Stored := False;
  FHScrollBar.Parent := Self;
  FHScrollBar.Orientation := TOrientation.Horizontal;
  FHScrollBar.OnChange := ScrollChanged;

  FThumbHintBackground := TRectangle.Create(Self);
  FThumbHintBackground.Stored := False;
  FThumbHintBackground.Parent := Self;
  FThumbHintBackground.Visible := False;
  FThumbHintBackground.HitTest := False;
  FThumbHintBackground.Stroke.Kind := TBrushKind.None;
  FThumbHintBackground.Fill.Kind := TBrushKind.Solid;

  FThumbHint := TLabel.Create(Self);
  FThumbHint.Stored := False;
  FThumbHint.Parent := FThumbHintBackground;
  FThumbHint.Align := TAlignLayout.Client;
  FThumbHint.HitTest := False;
  FThumbHint.StyledSettings := [];
  FThumbHint.TextSettings.HorzAlign := TTextAlign.Center;
  FThumbHint.TextSettings.VertAlign := TTextAlign.Center;

  FThumbHintTimer := TTimer.Create(Self);
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Interval := 900;
  FThumbHintTimer.OnTimer := ThumbHintTimer;

  Touch.DefaultInteractiveGestures := Touch.DefaultInteractiveGestures + [TInteractiveGesture.Pan];
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.Pan];

  FInitialized := True;
  CanFocus := True;
  ClipChildren := True;
  SetSize(640, 320);
  LayoutScrollBars;
end;

procedure ThiiCustomGrid.DataChanged(Sender: TObject; const AChange: ThiiDataChange);
var
  LStarted: Int64;
begin
  LStarted := BeginPerformanceTiming;
  try
    FAutoWidthsDirty := True;
    // Unknown row changes may reorder positional keys. Abandon the pending drop.
    if (Length(FMovingRowKeys) > 0) and (AChange.Kind <> ThiiDataChangeKind.CellChanged) then
      EndSelectionDrag;
    InvalidateAdjacentGroupMap(not FAdjacentGroupFolding.PreserveStateOnDataChange);
    // Live updates must not discard an in-progress draft. Cancel only when the
    // target is no longer the same row. Never commit into a replacement row.
    if not FCommittingEditor and Assigned(FEditColumn) then
      if not CanUpdateLayout or FEditRowKey.IsEmpty or (FEditRowIndex < 0) or (FEditRowIndex >= GetViewRowCount)
        or (GetViewRowKey(FEditRowIndex) <> FEditRowKey) then
        CancelEditor;
    if (AChange.Kind in [ThiiDataChangeKind.CellChanged, ThiiDataChangeKind.RowsChanged]) and (AChange.Count = 1) and not AChange.RowKey.IsEmpty
      and not FTree.Enabled and not FAdjacentGroupFolding.Enabled then
      FRowMetrics.Remove(AChange.RowKey.ToString)
    else
      InvalidateAllRowHeights;
    UpdateScrollBars;
    Repaint;
  finally
    EndPerformanceTiming(ThiiGridPerformanceStage.DataUpdate, LStarted);
  end;
end;

destructor ThiiCustomGrid.Destroy;
begin
  CancelEditor;
  FEditorCache.Free;
  FEditors.OnChanged := nil;
  FEditors.Free;
  FDefaultEditors.Free;
  EndSelectionDrag;
  FInitialized := False;
  FDataLink.Controller := nil;
  FView.Free;
  FAdjacentGroupFolding.Free;
  FRowMetrics.Free;
  FreeAndNil(FPerformance);
  FCellPool.Free;
  FDataLink.Free;
  FTree.Free;
  FAppearance.Free;
  FSpacing.Free;
  FCustomization.Free;
  FRowStyles.Free;
  FScrollHints.Free;
  FScrolling.Free;
  FRowHeight.Free;
  FSelection.Free;
  FHeader.Free;
  FRowIndicator.Free;
  FEditing.Free;
  FColumnSizing.Free;
  FColumns.Free;
  FFactoryScope.Free;
  inherited;
end;

procedure ThiiCustomGrid.DblClick;
var
  LHit: ThiiHitTestInfo;
begin
  inherited;
  LHit := GridHitTest(FLastMousePoint.X, FLastMousePoint.Y);
  if (LHit.Kind = ThiiHitKind.DataCell) and CellEditorHit(LHit.Column, LHit.RowIndex, LHit.Bounds, FLastMousePoint) then
    StartEdit(LHit);
end;

procedure ThiiCustomGrid.DoCustomDraw(ACanvas: TCanvas; const AContext: ThiiFmxDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, ACanvas, AContext, AStage, ADrawDefault);
end;

procedure ThiiCustomGrid.DrawContentPadding;
var
  LOuterRect: TRectF;
  LInnerRect: TRectF;
  LPaddingRect: TRectF;
  LColor: TAlphaColor;
begin
  LOuterRect := GetUnpaddedViewportRect;
  LInnerRect := GetViewportRect;
  LColor := ResolveContentPaddingColor;

  if LInnerRect.Top > LOuterRect.Top then
  begin
    LPaddingRect := RectF(LOuterRect.Left, LOuterRect.Top, LOuterRect.Right, LInnerRect.Top);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Bottom < LOuterRect.Bottom then
  begin
    LPaddingRect := RectF(LOuterRect.Left, LInnerRect.Bottom, LOuterRect.Right, LOuterRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Left > LOuterRect.Left then
  begin
    LPaddingRect := RectF(LOuterRect.Left, LInnerRect.Top, LInnerRect.Left, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Right < LOuterRect.Right then
  begin
    LPaddingRect := RectF(LInnerRect.Right, LInnerRect.Top, LOuterRect.Right, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;
end;

procedure ThiiCustomGrid.DrawCustomHeaderLayout;
var
  I, LFirst, LLast: Integer;
  LCellDef: ThiiHeaderLayoutCell;
  LRect, LDrawRect, LClip, LSeparatorRect: TRectF;
  LContext: ThiiFactoryContext;
  LCell: ThiiFmxVisualCell;
  LAppearance: ThiiResolvedAppearance;
  LClassId: ThiiClassId;
  LRightSpacing: Single;
begin
  for I := 0 to FHeaderLayout.Cells.Count - 1 do
  begin
    LCellDef := FHeaderLayout.Cells[I];
    if not FHeaderLayout.ColumnRange(LCellDef, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
      Continue;
    LRect := GetHeaderCellBounds(LCellDef);
    LClip := GetHeaderCellViewport(LCellDef);
    LDrawRect := TRectF.Intersect(LRect, LClip);
    if LDrawRect.IsEmpty then
      Continue;
    LClassId := LCellDef.ClassId;
    if string(LClassId) = '' then
      LClassId := h5uClassIdGridHeaderGroupCell;
    LContext := ThiiFactoryContext.Create(Self, Self, FDataController, LClassId, ThiiElementKind.ColumnHeaderGroupCell);
    LContext.HeaderCell := LCellDef;
    LContext.LayoutRow := LCellDef.LayoutRow;
    LContext.LayoutColumn := LFirst;
    LContext.RowSpan := LCellDef.RowSpan;
    LContext.ColumnSpan := LLast - LFirst + 1;
    LContext.ElementFlags := [ThiiElementFlag.Header];
    if FAllColumns[LFirst].Column.FixedKind <> ThiiFixedKind.None then
      Include(LContext.ElementFlags, ThiiElementFlag.FixedColumn);
    if LCellDef.ColumnId <> '' then
    begin
      LContext.Column := FColumns.FindById(LCellDef.ColumnId);
      LContext.ElementKind := ThiiElementKind.ColumnHeaderCell;
      if FSelection.IsColumnSelected(LCellDef.ColumnId) then
        Include(LContext.ElementFlags, ThiiElementFlag.Selected);
    end;
    LAppearance.Clear;
    LAppearance.StyleName := LCellDef.StyleName;
    LCell := AcquireVisualCell(LContext, ThiiFmxHeaderCell);
    LCell.BindCell(LContext, LDrawRect, TValue.Empty, LCellDef.Caption, LAppearance);
    LCell.FContentBounds := LRect;
    LCell.Paint(Self, Canvas);
    LRightSpacing := GetEffectiveColumnRightSpacing(FAllColumns[LLast].Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, FAllColumns[LLast].Column, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
    if FSpacing.RowSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Left, LRect.Bottom, LRect.Right + LRightSpacing, LRect.Bottom + FSpacing.RowSpacing);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.RowSpacing, ThiiGridColumn(LContext.Column), -1, ThiiRowKey.Empty, ResolveRowSpacingColor);
    end;
  end;
end;

procedure ThiiCustomGrid.DrawHeaders;
var
  LInfo: ThiiVisibleColumnInfo;
  LRect: TRectF;
  LDrawRect: TRectF;
  LSeparatorRect: TRectF;
  LContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiFmxVisualCell;
  LPalette: ThiiFmxPalette;
  LClassId: ThiiClassId;
  LSpacing: Single;
begin
  if not FHeader.Visible then
    Exit;

  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  LRect := RectF(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Right, GetViewportRect.Top + GetHeaderHeight);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := LPalette.HeaderBackground;
  Canvas.FillRect(LRect, 0, 0, AllCorners, 1);

  if FRowIndicator.Visible then
  begin
    LRect := RectF(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Left + FRowIndicator.Width, GetViewportRect.Top + GetHeaderHeight);
    LContext := ThiiFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridHeaderCell, ThiiElementKind.CornerCell);
    LContext.ElementFlags := [ThiiElementFlag.Header, ThiiElementFlag.Corner, ThiiElementFlag.FixedColumn];
    LAppearance.Clear;
    LCell := AcquireVisualCell(LContext, ThiiFmxHeaderCell);
    LCell.BindCell(LContext, LRect, TValue.Empty, '', LAppearance);
    LCell.Paint(Self, Canvas);

    if FSpacing.DefaultColumnRightSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + FSpacing.DefaultColumnRightSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, GetViewportRect);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, nil, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
  begin
    DrawCustomHeaderLayout;
    Exit;
  end;
  for LInfo in FVisibleColumns do
  begin
    LRect := LInfo.Bounds;
    LRect.Top := GetViewportRect.Top;
    LRect.Bottom := LRect.Top + FHeader.RowHeight;

    LDrawRect := TRectF.Intersect(LRect, GetColumnViewportRect(LInfo.Column));
    if not LDrawRect.IsEmpty then
    begin
      LClassId := LInfo.Column.HeaderCellClassId;
      if string(LClassId) = '' then
        LClassId := h5uClassIdGridHeaderCell;

      LContext := ThiiFactoryContext.Create(Self, Self, FDataController, LClassId, ThiiElementKind.ColumnHeaderCell);
      LContext.Column := LInfo.Column;
      LContext.LayoutColumn := LInfo.VisibleIndex;
      LContext.ElementFlags := [ThiiElementFlag.Header];
      if LInfo.Column.FixedKind <> ThiiFixedKind.None then
        Include(LContext.ElementFlags, ThiiElementFlag.FixedColumn);
      if FSelection.IsColumnSelected(LInfo.Column.Id) then
        Include(LContext.ElementFlags, ThiiElementFlag.Selected);

      LAppearance.Clear;
      LAppearance.StyleName := LInfo.Column.HeaderStyleName;
      LCell := AcquireVisualCell(LContext, ThiiFmxHeaderCell);
      LCell.BindCell(LContext, LDrawRect, TValue.Empty, LInfo.Column.Caption, LAppearance);
      LCell.FContentBounds := LRect;
      LCell.Paint(Self, Canvas);
    end;

    LSpacing := GetEffectiveColumnRightSpacing(LInfo.Column);
    if LSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + LSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, GetColumnViewportRect(LInfo.Column));
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, LInfo.Column, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FSpacing.RowSpacing > 0 then
  begin
    LSeparatorRect := RectF(GetViewportRect.Left, GetViewportRect.Top + FHeader.RowHeight, GetViewportRect.Right,
      GetViewportRect.Top + FHeader.RowHeight + FSpacing.RowSpacing);
    DrawSpacingRect(LSeparatorRect, ThiiElementKind.RowSpacing, nil, -1, ThiiRowKey.Empty, ResolveRowSpacingColor);
  end;
end;

function ThiiCustomGrid.GetAdjacentGroupGlyphRect(const ARowInfo: ThiiVisibleRowInfo): TRectF;
var
  LInfo: Th5uAdjacentGroupRowInfo;
  LLeft: Single;
  LTop: Single;
  LSize: Single;
begin
  Result := RectF(0, 0, 0, 0);
  if not FAdjacentGroupFolding.Enabled or not FAdjacentGroupFolding.ShowFoldGlyph or not TryGetAdjacentGroupRowInfo(ARowInfo.RowIndex, LInfo)
    or not LInfo.IsFoldable or not LInfo.IsFirstRow then
    Exit;

  LSize := Min(13, Max(9, ARowInfo.Bounds.Height - 8));
  LTop := ARowInfo.Bounds.Top + (ARowInfo.Bounds.Height - LSize) / 2;
  if FRowIndicator.Visible then
    LLeft := GetViewportRect.Left + 4
  else if Length(FVisibleColumns) > 0 then
    LLeft := Max(GetDataViewportRect.Left + 3, FVisibleColumns[0].Bounds.Left + 3)
  else
    Exit;

  Result := RectF(LLeft, LTop, LLeft + LSize, LTop + LSize);
  Result := TRectF.Intersect(Result, GetDataViewportRect);
end;

procedure ThiiCustomGrid.DrawAdjacentGroupGlyph(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);
var
  LBounds: TRectF;
  LContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiFmxVisualCell;
begin
  LBounds := GetAdjacentGroupGlyphRect(ARowInfo);
  if LBounds.IsEmpty then
    Exit;

  LContext := ThiiFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridAdjacentGroupFoldGlyph, ThiiElementKind.AdjacentGroupFoldGlyph);
  LContext.RowKey := ARowInfo.RowKey;
  LContext.ViewRowIndex := ARowInfo.RowIndex;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARowInfo.RowIndex);
  PopulateAdjacentGroupContext(LContext, ARowInfo.RowIndex);
  if ASelected then
    Include(LContext.ElementFlags, ThiiElementFlag.Selected);

  LAppearance.Clear;
  if ASelected then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := AlphaColorToColor(h5uGetFmxPalette(FAppearance.Theme).SelectedBackground);
  end;

  LCell := AcquireVisualCell(LContext, Th5uFmxAdjacentGroupGlyphCell);
  LCell.BindCell(LContext, LBounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

procedure ThiiCustomGrid.DrawRows;
var
  LDataRect: TRectF;
  LTop: Single;
  LRowIndex: Int64;
  LRowCount: Int64;
  LHeight: Single;
  LRowSpacing: Single;
  LRowRect: TRectF;
  LSeparatorRect: TRectF;
  LRowKey: ThiiRowKey;
  LRows: TList<ThiiVisibleRowInfo>;
  LRowInfo: ThiiVisibleRowInfo;
  LColumnInfo: ThiiVisibleColumnInfo;
  LCellRect: TRectF;
  LContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiFmxVisualCell;
  LValue: TValue;
  LSelected: Boolean;
  LRowSelected: Boolean;
  LFocused: Boolean;
  LIndicatorRect: TRectF;
  LPalette: ThiiFmxPalette;
  LColumnSpacing: Single;
  LRowSeparatorKind: ThiiElementKind;
  LRowSeparatorColor: TAlphaColor;
  LRowSeparatorStyleName: string;
  LTreeLevel: Integer;
  LClosedTreeLevels: Integer;
begin
  if not Assigned(FDataController) then
  begin
    FVisibleRows := nil;
    Exit;
  end;

  LDataRect := GetDataViewportRect;
  LRowCount := GetViewRowCount;
  if LRowCount <= 0 then
  begin
    FVisibleRows := nil;
    Exit;
  end;

  LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
  if LRowIndex < 0 then
    Exit;

  PrepareViewRange(LRowIndex, 64);
  LRows := TList<ThiiVisibleRowInfo>.Create;
  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  try
    while (LRowIndex < LRowCount) and (LTop < LDataRect.Bottom + FScrolling.OverscanRows * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing)) do
    begin
      LRowKey := GetViewRowKey(LRowIndex);
      LHeight := GetRowHeightFor(LRowIndex, LRowKey);
      LRowSpacing := GetEffectiveRowSeparatorFor(LRowIndex, LRowKey, LRowSeparatorKind, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
        LClosedTreeLevels);
      FRowMetrics.RecordExtent(LRowIndex, LHeight + LRowSpacing);
      LRowRect := RectF(LDataRect.Left, LTop, LDataRect.Right, LTop + LHeight);

      LRowInfo.RowIndex := LRowIndex;
      LRowInfo.RowKey := LRowKey;
      LRowInfo.Bounds := LRowRect;
      LRowInfo.Height := LHeight;
      LRows.Add(LRowInfo);

      if h5uRectFIntersects(LRowRect, LDataRect) then
      begin
        LRowSelected := FSelection.IsRowSelected(LRowKey);
        if FRowIndicator.Visible then
        begin
          LIndicatorRect := RectF(LDataRect.Left, LRowRect.Top, LDataRect.Left + FRowIndicator.Width, LRowRect.Bottom);
          LContext := ThiiFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridFixedCell, ThiiElementKind.RowHeaderCell);
          LContext.ViewRowIndex := LRowIndex;
          LContext.RowKey := LRowKey;
          LContext.ElementFlags := [ThiiElementFlag.FixedColumn];
          LAppearance.Clear;
          LAppearance.HasBackground := True;
          LAppearance.Background := AlphaColorToColor(LPalette.FixedBackground);
          LCell := AcquireVisualCell(LContext, ThiiFmxDataCell);
          LCell.BindCell(LContext, TRectF.Intersect(LIndicatorRect, LDataRect), TValue.Empty, IntToStr(LRowIndex + 1), LAppearance);
          LCell.Paint(Self, Canvas);
          if FSpacing.DefaultColumnRightSpacing > 0 then
          begin
            LSeparatorRect := RectF(LIndicatorRect.Right, LIndicatorRect.Top, LIndicatorRect.Right + FSpacing.DefaultColumnRightSpacing,
              LIndicatorRect.Bottom);
            LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
            if not LSeparatorRect.IsEmpty then
              DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, nil, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);
        end;

        for LColumnInfo in FVisibleColumns do
        begin
          LCellRect := GetVisibleCellBounds(LColumnInfo.Column, LColumnInfo.Bounds, LRowRect);

          if not LCellRect.IsEmpty then
          begin
            LSelected := FSelection.IsRowSelected(LRowKey) or FSelection.IsColumnSelected(LColumnInfo.Column.Id)
              or FSelection.IsCellSelected(LRowIndex, LColumnInfo.VisibleIndex);
            LFocused := FSelection.FocusedCell.IsValid and (FSelection.FocusedCell.RowIndex = LRowIndex)
              and (FSelection.FocusedCell.ColumnIndex = LColumnInfo.VisibleIndex);

            LContext := ThiiFactoryContext.Create(Self, Self, FDataController, LColumnInfo.Column.CellClassId, ThiiElementKind.DataCell);
            if string(LContext.ClassId) = '' then
              LContext.ClassId := h5uClassIdGridDataCell;
            LContext.Column := LColumnInfo.Column;
            LContext.RowKey := LRowKey;
            LContext.ViewRowIndex := LRowIndex;
            LContext.SourceRowIndex := GetViewSourceRowIndex(LRowIndex);
            PopulateAdjacentGroupContext(LContext, LRowIndex);
            if LSelected then
              Include(LContext.ElementFlags, ThiiElementFlag.Selected);
            if LFocused then
              Include(LContext.ElementFlags, ThiiElementFlag.Focused);
            if LColumnInfo.Column.FixedKind <> ThiiFixedKind.None then
              Include(LContext.ElementFlags, ThiiElementFlag.FixedColumn);

            LValue := GetCellValue(LColumnInfo.Column, LRowIndex, True);
            LContext.Value := LValue;
            LAppearance := ResolveCellAppearance(LRowIndex, LColumnInfo.Column, LSelected, LFocused);

            LCell := AcquireVisualCell(LContext, ThiiFmxDataCell);
            LCell.BindCell(LContext, LCellRect, LValue, GetCellText(LColumnInfo.Column, LRowIndex, True), LAppearance);
            LCell.FContentBounds := RectF(LColumnInfo.Bounds.Left, LCellRect.Top, LColumnInfo.Bounds.Right, LCellRect.Bottom);
            LCell.Paint(Self, Canvas);
          end;

          LColumnSpacing := GetEffectiveColumnRightSpacing(LColumnInfo.Column);
          if LColumnSpacing > 0 then
          begin
            LSeparatorRect := RectF(LColumnInfo.Bounds.Right, LRowRect.Top, LColumnInfo.Bounds.Right + LColumnSpacing, LRowRect.Bottom);
            LSeparatorRect := GetVisibleCellBounds(LColumnInfo.Column, LSeparatorRect, LRowRect);
            if not LSeparatorRect.IsEmpty then
              DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, LColumnInfo.Column, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
        end;
        if not FRowIndicator.Visible then
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);
      end;

      if LRowSpacing > 0 then
      begin
        LSeparatorRect := RectF(LDataRect.Left, LRowRect.Bottom, LDataRect.Right, LRowRect.Bottom + LRowSpacing);
        LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
        if not LSeparatorRect.IsEmpty then
          DrawSpacingRect(LSeparatorRect, LRowSeparatorKind, nil, LRowIndex, LRowKey, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
            LClosedTreeLevels);
      end;

      LTop := LTop + LHeight + LRowSpacing;
      Inc(LRowIndex);
    end;

    FVisibleRows := LRows.ToArray;
  finally
    LRows.Free;
  end;
end;

procedure ThiiCustomGrid.DrawSpacingRect(const ABounds: TRectF; AElementKind: ThiiElementKind; AColumn: ThiiGridColumn; AViewRowIndex: Int64; const ARowKey: ThiiRowKey;
  AColor: TAlphaColor; const AStyleName: string; ATreeLevel: Integer; AClosedTreeLevels: Integer);
var
  LClassId: ThiiClassId;
  LFactoryContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiFmxVisualCell;
begin
  if ABounds.IsEmpty then
    Exit;

  case AElementKind of
    ThiiElementKind.RowSpacing:
      LClassId := h5uClassIdGridRowSpacing;
    ThiiElementKind.ColumnSpacing:
      LClassId := h5uClassIdGridColumnSpacing;
    ThiiElementKind.TreeBranchEndBand:
      LClassId := h5uClassIdGridTreeBranchEndBand;
    ThiiElementKind.AdjacentGroupEndBand:
      LClassId := h5uClassIdGridAdjacentGroupEndBand;
    else
      LClassId := h5uClassIdGridContentPadding;
  end;

  LFactoryContext := ThiiFactoryContext.Create(Self, Self, FDataController, LClassId, AElementKind);
  LFactoryContext.Column := AColumn;
  LFactoryContext.ViewRowIndex := AViewRowIndex;
  if Assigned(FDataController) and (AViewRowIndex >= 0) then
    LFactoryContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex)
  else
    LFactoryContext.SourceRowIndex := AViewRowIndex;
  LFactoryContext.RowKey := ARowKey;
  PopulateAdjacentGroupContext(LFactoryContext, AViewRowIndex);
  LFactoryContext.TreeLevel := ATreeLevel;
  LFactoryContext.ClosedTreeLevels := AClosedTreeLevels;
  if AElementKind = ThiiElementKind.TreeBranchEndBand then
    Include(LFactoryContext.ElementFlags, ThiiElementFlag.TreeBranchEnd);
  if AElementKind = ThiiElementKind.AdjacentGroupEndBand then
    Include(LFactoryContext.ElementFlags, ThiiElementFlag.AdjacentGroupEnd);

  LAppearance.Clear;
  LAppearance.StyleName := AStyleName;
  if AColor <> TAlphaColorRec.Null then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := AlphaColorToColor(AColor);
  end;
  LCell := AcquireVisualCell(LFactoryContext, Th5uFmxSpacingCell);
  LCell.BindCell(LFactoryContext, ABounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

function ThiiCustomGrid.GetColumnViewportRect(AColumn: ThiiGridColumn): TRectF;
var
  LLeft, LRight: Single;
begin
  Result := GetViewportRect;
  LLeft := Result.Left;
  LRight := Result.Right;
  h5uColumnViewport(FColumns, AColumn, FSpacing.DefaultColumnRightSpacing, IndicatorExtent, LLeft, LRight);
  Result.Left := LLeft;
  Result.Right := LRight;
end;

function ThiiCustomGrid.GetVisibleCellBounds(AColumn: ThiiGridColumn; const AColumnBounds, ARowBounds: TRectF): TRectF;
begin
  // Painting, pointer hit testing and cell editors must use the same clipped
  // rectangle, including rows partially scrolled underneath the header.
  Result := GetColumnViewportRect(AColumn);
  Result.Top := ARowBounds.Top;
  Result.Bottom := ARowBounds.Bottom;
  Result := TRectF.Intersect(Result, GetDataViewportRect);
  Result := TRectF.Intersect(Result, AColumnBounds);
end;

procedure ThiiCustomGrid.EditorChanged(Sender: TObject);
begin
  // A changed value permits another automatic commit. Showing a validation
  // dialog, and the focus changes it causes, must not retry the failed value.
  FEditorExitBlocked := False;
end;

procedure ThiiCustomGrid.EditorExit(Sender: TObject);
begin
  if Assigned(FActiveEditor) and FActiveEditor.DeferExit then
    Exit;
  if not FCommittingEditor and not FEditorExitBlocked then
    CommitEditor;
end;

procedure ThiiCustomGrid.EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    CommitEditor;
    Key := 0;
    KeyChar := #0;
  end
  else
  if Key = vkEscape then
  begin
    CancelEditor;
    SetFocus;
    Key := 0;
    KeyChar := #0;
  end;
end;

function ThiiCustomGrid.FindFirstVisibleRow(AOffset: Double; out ATop: Single): Int64;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if not Assigned(FDataController) then
    Exit;
  PrepareRowMetrics;
  Result := FRowMetrics.FindFirstVisibleRow(AOffset, GetDataViewportRect.Top, ATop);
end;

function ThiiCustomGrid.GetDataViewportRect: TRectF;
begin
  Result := GetViewportRect;
  Result.Top := Result.Top + GetHeaderHeight;
end;

function ThiiCustomGrid.BeginPerformanceTiming: Int64;
begin
  Result := 0;
  if Assigned(FPerformance) and FPerformance.Enabled then
    Result := TStopwatch.GetTimeStamp;
end;

procedure ThiiCustomGrid.EndPerformanceTiming(AStage: ThiiGridPerformanceStage; AStarted: Int64);
begin
  if AStarted <> 0 then
    FPerformance.RecordElapsed(AStage, (TStopwatch.GetTimeStamp - AStarted) * 1000.0 / TStopwatch.Frequency);
end;

procedure ThiiCustomGrid.PrepareRowMetrics;
var
  LVariableSpacing: Boolean;
begin
  LVariableSpacing := Assigned(FOnGetRowSpacing) or (FTree.Enabled and FTree.BranchEndBand.Enabled)
    or (FAdjacentGroupFolding.Enabled and (FAdjacentGroupFolding.EndBand.Visibility <> ThiiAdjacentGroupEndBandVisibility.Never));
  FRowMetrics.Configure(FRowHeight, GetViewRowCount, FSpacing.RowSpacing, LVariableSpacing, PrepareViewRange, MetricRowExtent,
    Assigned(FOnGetRowSpacing));
end;

function ThiiCustomGrid.GetEstimatedTotalRowHeight(AAllowMeasure: Boolean): Double;
begin
  Result := 0;
  if not Assigned(FDataController) then
    Exit;
  PrepareRowMetrics;
  Result := FRowMetrics.Total(AAllowMeasure).AsFloat;
end;

function ThiiCustomGrid.GetHeaderHeight: Single;
begin
  Result := h5uHeaderHeight(FHeaderLayout, FHeader.Visible, FHeader.RowHeight, FSpacing.RowSpacing);
end;

function ThiiCustomGrid.GetOnConfigureInstance: ThiiConfigureInstanceEvent;
begin
  Result := FFactoryScope.OnConfigureInstance;
end;

function ThiiCustomGrid.GetOnCreateInstance: ThiiCreateInstanceEvent;
begin
  Result := FFactoryScope.OnCreateInstance;
end;

function ThiiCustomGrid.GetOnGetClass: ThiiGetClassEvent;
begin
  Result := FFactoryScope.OnGetClass;
end;

function ThiiCustomGrid.GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AAllowMeasure: Boolean): Single;
begin
  Result := FRowMetrics.GetHeight(FRowHeight, FColumns, AViewRowIndex, ARowKey, AAllowMeasure, MetricCellHeight, MetricAdjustHeight);
end;

function ThiiCustomGrid.MetricCellHeight(ARow: Int64; AColumn: ThiiGridColumn): Single;
begin
  Result := MeasureCellHeight(ARow, AColumn);
end;

procedure ThiiCustomGrid.MetricAdjustHeight(ARow: Int64; const AKey: ThiiRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean);
var
  LContext: ThiiGetRowHeightContext;
  LHeight: Single;
begin
  if not Assigned(FOnGetRowHeight) then
    Exit;
  LHeight := AHeight;
  LContext := Default(ThiiGetRowHeightContext);
  LContext.Grid := Self;
  LContext.DataController := FDataController;
  LContext.RowKey := AKey;
  LContext.ViewRowIndex := ARow;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARow);
  LContext.IsEstimated := AEstimated;
  FOnGetRowHeight(Self, LContext, LHeight, ACacheResult);
  AHeight := LHeight;
end;

function ThiiCustomGrid.MetricRowExtent(ARow: Int64; AAllowMeasure: Boolean): Single;
var
  LKey: ThiiRowKey;
  LKind: ThiiElementKind;
  LColor: TAlphaColor;
  LStyle: string;
  LLevel, LClosed: Integer;
begin
  LKey := GetViewRowKey(ARow);
  Result := GetRowHeightFor(ARow, LKey, AAllowMeasure) + GetEffectiveRowSeparatorFor(ARow, LKey, LKind, LColor, LStyle, LLevel, LClosed);
  if AAllowMeasure then
    FRowMetrics.RecordExtent(ARow, Result);
end;

function ThiiCustomGrid.MetricRowSpacing(ARow: Int64; const AKey: ThiiRowKey): Single;
begin
  Result := GetRowSpacingFor(ARow, AKey);
end;

function ThiiCustomGrid.GetEffectiveColumnRightSpacing(AColumn: ThiiGridColumn): Single;
begin
  Result := h5uColumnRightSpacing(AColumn, FSpacing.DefaultColumnRightSpacing);
end;

procedure ThiiCustomGrid.InvalidateAdjacentGroupMap(AClearStates: Boolean);
begin
  FView.InvalidateAdjacentGroupMap(AClearStates);
end;

function ThiiCustomGrid.GetViewRowCount: Int64;
begin
  Result := FView.GetViewRowCount;
end;

function ThiiCustomGrid.GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
begin
  Result := FView.GetViewSourceRowIndex(AViewRowIndex);
end;

function ThiiCustomGrid.GetViewRowKey(AViewRowIndex: Int64): ThiiRowKey;
begin
  Result := FView.GetViewRowKey(AViewRowIndex);
end;

function ThiiCustomGrid.GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
begin
  Result := FView.GetViewValue(AViewRowIndex, AFieldName);
end;

procedure ThiiCustomGrid.SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
begin
  FView.SetViewValue(AViewRowIndex, AFieldName, AValue);
end;

function ThiiCustomGrid.CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := FView.CanEditViewValue(AViewRowIndex, AFieldName);
end;

function ThiiCustomGrid.GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
begin
  Result := FView.GetViewDisplayText(AViewRowIndex, AFieldName, ADisplayFormat);
end;

procedure ThiiCustomGrid.PrepareViewRange(AFirstViewRow, ACount: Int64);
begin
  FView.PrepareViewRange(AFirstViewRow, ACount);
end;

function ThiiCustomGrid.TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  Result := FView.TryGetAdjacentGroupRowInfo(AViewRowIndex, AInfo);
end;

procedure ThiiCustomGrid.PopulateAdjacentGroupContext(var AContext: ThiiFactoryContext; AViewRowIndex: Int64);
begin
  FView.PopulateAdjacentGroupContext(AContext, AViewRowIndex);
end;

procedure ThiiCustomGrid.DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
begin
  FView.DoAdjacentGroupStateChanged(AInfo);
end;

function ThiiCustomGrid.GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): Single;
var
  LContext: ThiiGetRowHeightContext;
begin
  Result := FSpacing.RowSpacing;
  if Assigned(FOnGetRowSpacing) then
  begin
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    LContext.IsEstimated := False;
    FOnGetRowSpacing(Self, LContext, Result);
  end;
  if IsNan(Result) or IsInfinite(Result) then
    Result := FSpacing.RowSpacing;
  Result := EnsureRange(Result, 0.0, 1000.0);
end;

function ThiiCustomGrid.GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out AElementKind: ThiiElementKind; out AColor: TAlphaColor;
  out AStyleName: string; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Single;
var
  LSeparator: Th5uRowSeparatorInfo;
begin
  LSeparator := h5uRowSeparator(FView, FTree, FAdjacentGroupFolding, AViewRowIndex, ARowKey, MetricRowSpacing);
  AElementKind := LSeparator.Kind;
  AStyleName := LSeparator.StyleName;
  ATreeLevel := LSeparator.TreeLevel;
  AClosedTreeLevels := LSeparator.ClosedTreeLevels;
  Result := LSeparator.Height;
  case AElementKind of
    ThiiElementKind.AdjacentGroupEndBand:
      AColor := ResolveAdjacentGroupEndColor(AViewRowIndex, ARowKey);
    ThiiElementKind.TreeBranchEndBand:
      AColor := ResolveTreeBranchEndColor(AViewRowIndex, ARowKey);
    else
      AColor := ResolveRowSpacingColor;
  end;
end;

function ThiiCustomGrid.GetGridLines: Boolean;
begin
  // Explicit per-column RightSpacing values are intentionally independent
  // from this compatibility property.
  Result := (FSpacing.Left > 0) or (FSpacing.Top > 0) or (FSpacing.Right > 0) or (FSpacing.Bottom > 0) or (FSpacing.RowSpacing > 0)
    or (FSpacing.DefaultColumnRightSpacing > 0);
end;

function ThiiCustomGrid.ResolveColor(const AColor: TColor; AFallback: TAlphaColor): TAlphaColor;
begin
  if AColor = TColorRec.SysDefault then
    Result := AFallback
  else if AColor = TColorRec.SysNone then
    Result := 0
  else
    Result := h5uColorToFmx(AColor);
end;

function ThiiCustomGrid.ResolveDefaultCellColor: TAlphaColor;
begin
  Result := ResolveColor(FAppearance.DefaultCellColor, h5uGetFmxPalette(FAppearance.Theme).CellBackground);
end;

function ThiiCustomGrid.ResolveRowSpacingColor: TAlphaColor;
begin
  Result := ResolveColor(FAppearance.RowSpacingColor, h5uGetFmxPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveColumnSpacingColor: TAlphaColor;
begin
  Result := ResolveColor(FAppearance.ColumnSpacingColor, h5uGetFmxPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveContentPaddingColor: TAlphaColor;
begin
  Result := ResolveColor(FAppearance.ContentPaddingColor, h5uGetFmxPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TAlphaColor;
var
  LPalette: ThiiFmxPalette;
  LStyleName: string;
begin
  if FTree.BranchEndBand.Color <> TColorRec.SysDefault then
    Exit(ResolveColor(FTree.BranchEndBand.Color, ResolveRowSpacingColor));

  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  LStyleName := FTree.BranchEndBand.StyleName;
  if SameText(LStyleName, 'TreeBranchEnd') then
    Result := LPalette.TreeBranchEndBackground
  else if SameText(LStyleName, 'Error') then
    Result := LPalette.ErrorBackground
  else if SameText(LStyleName, 'Warning') then
    Result := LPalette.WarningBackground
  else if SameText(LStyleName, 'Stripe') then
    Result := LPalette.StripeBackground
  else if SameText(LStyleName, 'Odd') then
    Result := LPalette.OddBackground
  else if SameText(LStyleName, 'Even') then
    Result := LPalette.EvenBackground
  else
    Result := ResolveRowSpacingColor;
end;

function ThiiCustomGrid.ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TAlphaColor;
var
  LPalette: ThiiFmxPalette;
  LStyleName: string;
begin
  if FAdjacentGroupFolding.EndBand.Color <> TColorRec.SysDefault then
    Exit(ResolveColor(FAdjacentGroupFolding.EndBand.Color, ResolveRowSpacingColor));

  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  LStyleName := FAdjacentGroupFolding.EndBand.StyleName;
  if SameText(LStyleName, 'AdjacentGroupEnd') then
    Result := LPalette.AdjacentGroupEndBackground
  else if SameText(LStyleName, 'Error') then
    Result := LPalette.ErrorBackground
  else if SameText(LStyleName, 'Warning') then
    Result := LPalette.WarningBackground
  else if SameText(LStyleName, 'Stripe') then
    Result := LPalette.StripeBackground
  else if SameText(LStyleName, 'Odd') then
    Result := LPalette.OddBackground
  else if SameText(LStyleName, 'Even') then
    Result := LPalette.EvenBackground
  else
    Result := ResolveRowSpacingColor;
end;

function ThiiCustomGrid.GetTotalColumnWidth: Single;
var
  LColumn: ThiiGridColumn;
begin
  Result := 0;
  for LColumn in FColumns.VisibleColumns do
    Result := Result + LColumn.LayoutWidth + GetEffectiveColumnRightSpacing(LColumn);
  if FRowIndicator.Visible then
    Result := Result + FRowIndicator.Width + FSpacing.DefaultColumnRightSpacing;
end;

function ThiiCustomGrid.GetUnpaddedViewportRect: TRectF;
begin
  Result := LocalRect;
  if FVScrollBar.Visible then
    Result.Right := Result.Right - FVScrollBar.Width;
  if FHScrollBar.Visible then
    Result.Bottom := Result.Bottom - FHScrollBar.Height;
end;

function ThiiCustomGrid.GetViewportRect: TRectF;
begin
  Result := GetUnpaddedViewportRect;
  Result.Left := Result.Left + FSpacing.Left;
  Result.Top := Result.Top + FSpacing.Top;
  Result.Right := Result.Right - FSpacing.Right;
  Result.Bottom := Result.Bottom - FSpacing.Bottom;

  if Result.Right < Result.Left then
    Result.Right := Result.Left;
  if Result.Bottom < Result.Top then
    Result.Bottom := Result.Top;
end;

function ThiiCustomGrid.GetVisualCellClass(const AContext: ThiiFactoryContext; ADefaultClass: ThiiFmxVisualCellClass): ThiiFmxVisualCellClass;
var
  LCacheScope: ThiiFactoryCacheScope;
begin
  Result := ThiiFmxVisualCellClass(FFactoryScope.ResolveClass(AContext, ThiiFmxVisualCell, ADefaultClass, LCacheScope));
end;

function ThiiCustomGrid.GridHitTest(X, Y: Single): ThiiHitTestInfo;
var
  LFirst, LLast: Integer;
  LColumn: ThiiVisibleColumnInfo;
  LRow: ThiiVisibleRowInfo;
  LGlyphRect: TRectF;
begin
  Result := ThiiHitTestInfo.Empty;
  if not GetViewportRect.Contains(PointF(X, Y)) then
    Exit;

  if FHeader.Visible and (Y < GetDataViewportRect.Top) then
  begin
    if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    begin
      Result.HeaderCell := HeaderCellAtPoint(X, Y);
      if not Assigned(Result.HeaderCell) or not FHeaderLayout.ColumnRange(Result.HeaderCell, FColumns.VisibleColumns, LFirst, LLast) then
        Exit(ThiiHitTestInfo.Empty);
      Result.Kind := ThiiHitKind.Header;
      Result.ColumnIndex := LFirst;
      Result.Column := FAllColumns[LFirst].Column;
      Result.Bounds := GetHeaderCellBounds(Result.HeaderCell);
      Result.Bounds := TRectF.Intersect(Result.Bounds, GetHeaderCellViewport(Result.HeaderCell));
      Exit;
    end;
    for LColumn in FVisibleColumns do
      if LColumn.Bounds.Contains(PointF(X, Y)) and GetColumnViewportRect(LColumn.Column).Contains(PointF(X, Y)) then
      begin
        Result.Kind := ThiiHitKind.Header;
        Result.Column := LColumn.Column;
        Result.ColumnIndex := LColumn.VisibleIndex;
        Result.Bounds := TRectF.Intersect(LColumn.Bounds, GetColumnViewportRect(LColumn.Column));
        Result.Bounds.Top := GetViewportRect.Top;
        Result.Bounds.Bottom := Result.Bounds.Top + FHeader.RowHeight;
        Exit;
      end;
  end;

  for LRow in FVisibleRows do
    if LRow.Bounds.Contains(PointF(X, Y)) then
    begin
      Result.RowIndex := LRow.RowIndex;
      Result.RowKey := LRow.RowKey;
      Result.Bounds := LRow.Bounds;

      LGlyphRect := GetAdjacentGroupGlyphRect(LRow);
      if not LGlyphRect.IsEmpty and LGlyphRect.Contains(PointF(X, Y)) then
      begin
        Result.Kind := ThiiHitKind.AdjacentGroupGlyph;
        Result.Bounds := LGlyphRect;
        Exit;
      end;
      if FRowIndicator.Visible and (X < GetDataViewportRect.Left + FRowIndicator.Width) then
      begin
        Result.Kind := ThiiHitKind.RowIndicator;
        Exit;
      end;

      for LColumn in FVisibleColumns do
        if (X >= LColumn.Bounds.Left) and (X < LColumn.Bounds.Right) and GetColumnViewportRect(LColumn.Column).Contains(PointF(X, Y)) then
        begin
          Result.Kind := ThiiHitKind.DataCell;
          Result.Column := LColumn.Column;
          Result.ColumnIndex := LColumn.VisibleIndex;
          Result.Bounds := GetVisibleCellBounds(LColumn.Column, LColumn.Bounds, LRow.Bounds);
          Exit;
        end;
    end;
end;

procedure ThiiCustomGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  FThumbHintBackground.Visible := False;
end;

procedure ThiiCustomGrid.InvalidateAllRowHeights;
begin
  FRowMetrics.Clear;
end;

function ThiiCustomGrid.CanUpdateLayout: Boolean;
var
  LComponent: TComponent;
begin
  Result := False;
  if not FInitialized then
    Exit;
  // A child's Loaded can run while its owning form is still loading.
  LComponent := Self;
  while Assigned(LComponent) do
  begin
    if LComponent.ComponentState * [csLoading, csReading, csDestroying] <> [] then
      Exit;
    LComponent := LComponent.Owner;
  end;
  Result := True;
end;

procedure ThiiCustomGrid.Loaded;
var
  I: Integer;
begin
  inherited;
  if FSizingVersion < 1 then
  begin
    for I := 0 to FColumns.Count - 1 do
      FColumns[I].ApplyLegacySizing;
    for I := 0 to FHeaderLayout.Cells.Count - 1 do
      FHeaderLayout.Cells[I].ApplyLegacySizing;
  end;
  LayoutScrollBars;
  // Paint refreshes data-dependent layout. FormCreate may not have run yet.
  Repaint;
end;

procedure ThiiCustomGrid.LayoutScrollBars;
const
  CScrollSize = 16;
begin
  if not CanUpdateLayout then
    Exit;
  FVScrollBar.SetBounds(Width - CScrollSize, 0, CScrollSize, Height - IfThen(FHScrollBar.Visible, CScrollSize, 0));
  FHScrollBar.SetBounds(0, Height - CScrollSize, Width - IfThen(FVScrollBar.Visible, CScrollSize, 0), CScrollSize);
  FThumbHintBackground.BringToFront;
  if Assigned(FActiveEditor) then
    FActiveEditor.BringToFront;
end;

function ThiiCustomGrid.MeasureCellHeight(AViewRowIndex: Int64; AColumn: ThiiGridColumn): Single;
var
  LStarted: Int64;
  LRect: TRectF;
  LText: string;
  LValue: TValue;
begin
  LStarted := BeginPerformanceTiming;
  try
    Result := FRowHeight.MinHeight;
    if not Assigned(FDataController) then
      Exit;

    if AColumn.DataType = ThiiColumnDataType.Image then
    begin
      LValue := GetCellValue(AColumn, AViewRowIndex, True);
      if LValue.IsType<TBytes> and (Length(LValue.AsType<TBytes>) > 0) then
        Result := Min(AColumn.MaxAutoHeight, 80);
      Exit;
    end;

    LText := GetCellText(AColumn, AViewRowIndex, True);
    Canvas.Font.Size := FTextSize;
    LRect := RectF(0, 0, Max(8, AColumn.LayoutWidth - 10), 10000);
    Canvas.MeasureText(LRect, LText, AColumn.WordWrap, [], TTextAlign.Leading, TTextAlign.Leading);
    Result := LRect.Height + 6;
    if AColumn.MaxAutoHeight > 0 then
      Result := Min(Result, AColumn.MaxAutoHeight);
  finally
    EndPerformanceTiming(ThiiGridPerformanceStage.HeightMeasurement, LStarted);
  end;
end;

procedure ThiiCustomGrid.BeginTouchScroll(const APoint: TPointF);
begin
  FTouchTracking := True;
  FTouchScrolling := False;
  FTouchOrigin := APoint;
  FTouchOffsetX := FHorizontalOffset;
  FTouchOffsetY := FVerticalOffset;
end;

procedure ThiiCustomGrid.MoveTouchScroll(const APoint: TPointF);
var
  LDelta: TPointF;
begin
  if not FTouchTracking or not CanUpdateLayout then
    Exit;
  LDelta := FTouchOrigin - APoint;
  if not FTouchScrolling then
  begin
    if (Abs(LDelta.X) < 6) and (Abs(LDelta.Y) < 6) then
      Exit;
    FTouchScrolling := True;
    FClickDownHit := ThiiHitTestInfo.Empty;
    CancelEditor;
  end;
  FHorizontalOffset := EnsureRange(FTouchOffsetX + LDelta.X, 0, Max(0.0, FHScrollBar.Max - FHScrollBar.ViewportSize));
  FVerticalOffset := EnsureRange(FTouchOffsetY + LDelta.Y, 0, Max(0.0, FVScrollBar.Max - FVScrollBar.ViewportSize));
  FUpdatingScrollBars := True;
  try
    FHScrollBar.Value := FHorizontalOffset;
    FVScrollBar.Value := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
  end;
  Repaint;
end;

procedure ThiiCustomGrid.DoGesture(const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  LPoint: TPointF;
begin
  if (EventInfo.GestureID <> igiPan) or not CanUpdateLayout then
  begin
    inherited;
    Exit;
  end;
  Handled := True;
  LPoint := AbsoluteToLocal(EventInfo.Location);
  if FHeaderInteraction then
  begin
    // FMX emits Pan for desktop mouse drags as well as touch. Keep the action
    // chosen at pointer-down, and update feedback even on gesture-only moves.
    if Assigned(FResizingColumn) then
      UpdateColumnResize(LPoint.X)
    else
      UpdateHeaderMove(LPoint.X, LPoint.Y);
    Exit;
  end;
  if TInteractiveGestureFlag.gfBegin in EventInfo.Flags then
  begin
    BeginTouchScroll(LPoint);
    FGesturePanning := True;
  end;
  MoveTouchScroll(LPoint);
  if TInteractiveGestureFlag.gfEnd in EventInfo.Flags then
  begin
    FTouchTracking := False;
    FGesturePanning := False;
    // A recognized pan must never become a checkbox click on release.
    FTouchScrolling := True;
  end;
end;

procedure ThiiCustomGrid.DoMouseLeave;
begin
  if not Assigned(FResizingColumn) then
    SetResizeCursor(False);
  inherited;
end;

function ThiiCustomGrid.ColumnResizeAt(X, Y: Single; ATouch: Boolean): ThiiGridColumn;
var
  LCandidates: TArray<Th5uResizeCandidate>;
  LView: TRectF;
  I: Integer;
begin
  Result := nil;
  if not CanUpdateLayout or not FHeader.Visible or not FCustomization.AllowColumnResizing then
    Exit;
  if not GetViewportRect.Contains(PointF(X, Y)) or (Y >= GetDataViewportRect.Top) then
    Exit;
  BuildColumnLayout;
  SetLength(LCandidates, Length(FVisibleColumns));
  for I := 0 to High(FVisibleColumns) do
  begin
    LCandidates[I].Column := FVisibleColumns[I].Column;
    LCandidates[I].VisibleIndex := FVisibleColumns[I].VisibleIndex;
    LCandidates[I].Right := FVisibleColumns[I].Bounds.Right;
    LView := GetColumnViewportRect(FVisibleColumns[I].Column);
    LCandidates[I].ViewLeft := LView.Left;
    LCandidates[I].ViewRight := LView.Right;
  end;
  Result := h5uColumnResizeAt(FCustomization, LCandidates, High(FAllColumns), X, Y, ATouch, IsResizeHeaderEdge);
end;

function ThiiCustomGrid.IsResizeHeaderEdge(AX, AY: Single): Boolean;
var
  LHeader: ThiiHeaderLayoutCell;
begin
  Result := True;
  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
  begin
    LHeader := HeaderCellAtPoint(AX - 1, AY);
    Result := Assigned(LHeader) and (Abs(GetHeaderCellBounds(LHeader).Right - AX) <= 0.1);
  end;
end;

procedure ThiiCustomGrid.SetResizeCursor(AActive: Boolean);
begin
  if AActive = FResizeCursorActive then
    Exit;
  FResizeCursorActive := AActive;
  if AActive then
  begin
    FResizeCursor := Cursor;
    Cursor := crHSplit;
  end
  else
    if Cursor = crHSplit then
      Cursor := FResizeCursor;
end;

function ThiiCustomGrid.BeginColumnResize(X, Y: Single; ATouch: Boolean): Boolean;
begin
  FResizingColumn := ColumnResizeAt(X, Y, ATouch);
  Result := Assigned(FResizingColumn);
  if not Result then
    Exit;
  FHeaderInteraction := True;
  FResizeStartX := X;
  FResizeOriginalWidth := FResizingColumn.LayoutWidth;
  if not ATouch then
    SetResizeCursor(True);
  Capture;
end;

procedure ThiiCustomGrid.UpdateColumnResize(X: Single);
begin
  if not Assigned(FResizingColumn) then
    Exit;
  if CanUpdateLayout and FCustomization.AllowColumnResizing and ((Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self)) then
    if h5uTryResizeColumn(FColumns, FResizingColumn, FResizeOriginalWidth, X - FResizeStartX) then
      Exit;
  EndSelectionDrag;
end;

procedure ThiiCustomGrid.SelectRightClickCell(const AHit: ThiiHitTestInfo);
var
  LCell: ThiiCellAddress;
begin
  if not FSelection.RightClickSelect or (AHit.Kind <> ThiiHitKind.DataCell) then
    Exit;
  LCell.RowIndex := AHit.RowIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.ColumnId := AHit.Column.Id;
  h5uSelectRightClick(FSelection, LCell, AHit.Column.CanSelect, TryFocusCell);
end;

function ThiiCustomGrid.CanMoveColumn(AColumn: ThiiGridColumn): Boolean;
begin
  Result := h5uCanMoveColumn(FColumns, FCustomization.AllowColumnMoving, AColumn);
end;

function ThiiCustomGrid.IsColumnMoveGesture(AColumn: ThiiGridColumn; AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(CanMoveColumn(AColumn), FCustomization.ColumnMovingGesture = ThiiColumnRowMovingGesture.AltDrag, AShift,
    ssTouch in AShift);
end;

function ThiiCustomGrid.IsRowMoveGesture(AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(Assigned(FOnRowsMoved) and FCustomization.AllowRowMoving,
    FCustomization.RowMovingGesture = ThiiColumnRowMovingGesture.AltDrag, AShift);
end;

function ThiiCustomGrid.GetHeaderCellBounds(ACell: ThiiHeaderLayoutCell): TRectF;
var
  LFirst, LLast, LSpan: Integer;
begin
  Result := TRectF.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
    Exit;
  Result.Left := FAllColumns[LFirst].Bounds.Left;
  Result.Right := FAllColumns[LLast].Bounds.Right;
  Result.Top := GetViewportRect.Top + ACell.LayoutRow * (FHeader.RowHeight + FSpacing.RowSpacing);
  LSpan := Max(1, ACell.RowSpan);
  Result.Bottom := Result.Top + LSpan * FHeader.RowHeight + (LSpan - 1) * FSpacing.RowSpacing;
end;

function ThiiCustomGrid.GetHeaderCellViewport(ACell: ThiiHeaderLayoutCell): TRectF;
var
  LFirst, LLast: Integer;
begin
  Result := TRectF.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LFirst >= Length(FAllColumns)) then
    Exit;
  Result := GetColumnViewportRect(FAllColumns[LFirst].Column);
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function ThiiCustomGrid.HeaderCellAtPoint(X, Y: Single): ThiiHeaderLayoutCell;
var
  I: Integer;
  LRect: TRectF;
begin
  Result := nil;
  if not FHeaderLayout.Enabled or not FHeader.Visible then
    Exit;
  // Reverse paint order also resolves overlapping cells consistently with drawing.
  for I := FHeaderLayout.Cells.Count - 1 downto 0 do
  begin
    LRect := GetHeaderCellBounds(FHeaderLayout.Cells[I]);
    LRect := TRectF.Intersect(LRect, GetHeaderCellViewport(FHeaderLayout.Cells[I]));
    if LRect.Contains(PointF(X, Y)) then
      Exit(FHeaderLayout.Cells[I]);
  end;
end;

function ThiiCustomGrid.BeginColumnMove(AColumnIndex: Integer; X, Y: Single): Boolean;
var
  LPlan: Th5uColumnMovePlan;
  LHit: ThiiHitTestInfo;
begin
  Result := False;
  LHit := GridHitTest(X, Y);
  if not h5uPlanColumnMove(FColumns, FHeaderLayout, FSelection, FCustomization, AColumnIndex, LHit.HeaderCell, LPlan) then
    Exit;
  FMovingColumns := LPlan.Columns;
  FMovingHeaderCell := LPlan.HeaderCell;
  FMoveCaption := LPlan.Caption;
  FHeaderInteraction := True;
  FMovePoint := PointF(X, Y);
  FMovePreviewWidth := EnsureRange(Single(LPlan.Columns[0].LayoutWidth), 80, 260);
  if Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
  begin
    FMovePreviewWidth := EnsureRange(Single(LHit.Bounds.Width), 80, 260);
  end;
  FSelectionDragOrigin := PointF(X, Y);
  Capture;
  Result := True;
end;

function ThiiCustomGrid.BeginRowMove(ARowIndex: Int64; X, Y: Single): Boolean;
var
  LPlan: Th5uRowMovePlan;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving then
    Exit;
  if not h5uPlanRowMove(FSelection, ARowIndex, GetViewRowCount, GetViewRowKey, LPlan) then
    Exit;
  FMovingRowKeys := LPlan.RowKeys;
  FHeaderInteraction := True;
  FMovingFirstRowIndex := LPlan.FirstRowIndex;
  FSelectionDragOrigin := PointF(X, Y);
  Capture;
  Result := True;
end;

procedure ThiiCustomGrid.UpdateHeaderMove(X, Y: Single);
begin
  if (Length(FMovingColumns) = 0) and (Length(FMovingRowKeys) = 0) then
    Exit;
  if not ((Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self)) then
  begin
    EndSelectionDrag;
    Exit;
  end;
  if Assigned(FMovingHeaderCell) and (not FHeaderLayout.Enabled or not FHeaderLayout.ContainsCell(FMovingHeaderCell)) then
  begin
    EndSelectionDrag;
    Exit;
  end;
  if not FMoveDragging then
  begin
    if (Abs(X - FSelectionDragOrigin.X) < 4) and (Abs(Y - FSelectionDragOrigin.Y) < 4) then
      Exit;
    FMoveCursor := Cursor;
    FMoveDragging := True;
    Cursor := crDrag;
  end;
  FMovePoint := PointF(X, Y);
  Repaint;
end;

function ThiiCustomGrid.GetColumnMoveHeaderBounds(const AInfo: ThiiVisibleColumnInfo): TRectF;
var
  LCell: ThiiHeaderLayoutCell;
  LFirst, LLast, I: Integer;
begin
  Result := AInfo.Bounds;
  Result.Top := GetViewportRect.Top;
  Result.Bottom := Result.Top + FHeader.RowHeight;
  if Assigned(FMovingHeaderCell) then
  begin
    if not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
      Exit(TRectF.Empty);
    if FMovingHeaderCell.ColumnSpan > 1 then
    begin
      Result := GetHeaderCellBounds(FMovingHeaderCell);
      Result := TRectF.Intersect(Result, GetHeaderCellViewport(FMovingHeaderCell));
      Exit;
    end;
    Result := TRectF.Empty;
    for I := 0 to FHeaderLayout.Cells.Count - 1 do
    begin
      LCell := FHeaderLayout.Cells[I];
      if (LCell.LayoutRow <> FMovingHeaderCell.LayoutRow) or not FHeaderLayout.ColumnRange(LCell, FColumns.VisibleColumns, LFirst, LLast) then
        Continue;
      if (AInfo.VisibleIndex >= LFirst) and (AInfo.VisibleIndex <= LLast) then
        Result := GetHeaderCellBounds(LCell);
    end;
  end;
  Result := TRectF.Intersect(Result, GetColumnViewportRect(AInfo.Column));
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function ThiiCustomGrid.ColumnMoveTarget(X, Y: Single; out ANewIndex: Integer; out AMarkerX, AMarkerTop: Single): Boolean;
var
  LHit: ThiiHitTestInfo;
  LAfter: Boolean;
begin
  Result := False;
  ANewIndex := -1;
  AMarkerX := 0;
  AMarkerTop := 0;
  if not CanUpdateLayout or (Length(FMovingColumns) = 0) then
    Exit;
  if Assigned(FMovingHeaderCell) and (not FHeaderLayout.Enabled or not FHeaderLayout.ContainsCell(FMovingHeaderCell)) then
    Exit;
  LHit := GridHitTest(X, Y);
  if (LHit.Kind <> ThiiHitKind.Header) or not Assigned(LHit.Column) then
    Exit;
  Result := h5uColumnMoveTarget(FColumns, FHeaderLayout, FCustomization, FMovingColumns, FMovingHeaderCell, LHit.Column, LHit.ColumnIndex,
    LHit.HeaderCell, ANewIndex, LAfter);
  if Result then
  begin
    AMarkerTop := LHit.Bounds.Top;
    if LAfter then
      AMarkerX := LHit.Bounds.Right
    else
      AMarkerX := LHit.Bounds.Left;
  end;
end;

procedure ThiiCustomGrid.DrawColumnMoveFeedback;
var
  LPalette: ThiiFmxPalette;
  LState: TCanvasSaveState;
  LView, LRect, LTextRect: TRectF;
  LInfo: ThiiVisibleColumnInfo;
  LColumn: ThiiGridColumn;
  LMarkerX, LMarkerTop, LWidth, LHeight, LLeft, LTop, LOffset: Single;
  LNewIndex: Integer;
  LValid, LSourcePainted: Boolean;
begin
  if not FMoveDragging or (Length(FMovingColumns) = 0) or not FHeader.Visible then
    Exit;
  if (Root = nil) or (Root.Captured = nil) or (Root.Captured.GetObject <> Self) then
    Exit;
  if Assigned(FMovingHeaderCell) and not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
    Exit;
  LView := GetViewportRect;
  if LView.IsEmpty then
    Exit;
  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  LValid := ColumnMoveTarget(FMovePoint.X, FMovePoint.Y, LNewIndex, LMarkerX, LMarkerTop);
  LState := Canvas.SaveState;
  try
    Canvas.IntersectClipRect(LView);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Dash := TStrokeDash.Solid;
    Canvas.Stroke.Thickness := 2;
    // Highlight the source without changing its selection or collection order.
    LSourcePainted := False;
    for LInfo in FVisibleColumns do
      for LColumn in FMovingColumns do
        if LInfo.Column = LColumn then
        begin
          if LSourcePainted and Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
            Continue;
          LSourcePainted := True;
          LRect := GetColumnMoveHeaderBounds(LInfo);
          if LRect.IsEmpty then
            Continue;
          Canvas.Fill.Color := LPalette.SelectedBackground;
          Canvas.FillRect(LRect, 0, 0, AllCorners, 0.3);
          Canvas.Stroke.Color := LPalette.SelectedBackground;
          LRect.Inflate(-1, -1);
          if not LRect.IsEmpty then
            Canvas.DrawRect(LRect, 0, 0, AllCorners, 1);
        end;
    if LValid then
    begin
      LMarkerX := EnsureRange(LMarkerX, LView.Left + 2, Max(LView.Left + 2, LView.Right - 2));
      Canvas.Fill.Color := LPalette.SelectedBackground;
      Canvas.FillRect(RectF(LMarkerX - 2, LMarkerTop, LMarkerX + 2, LView.Bottom), 0, 0, AllCorners, 1);
      Canvas.FillRect(RectF(LMarkerX - 6, LMarkerTop, LMarkerX + 6, LMarkerTop + 7), 2, 2, AllCorners, 1);
    end;
    LWidth := Min(FMovePreviewWidth, Max(1, LView.Width - 8));
    LHeight := Max(30, FHeader.RowHeight);
    LOffset := 16;
    if FHeaderTouch then
       LOffset := 40;
    LLeft := EnsureRange(FMovePoint.X - LWidth / 2, LView.Left + 4, Max(LView.Left + 4, LView.Right - LWidth - 4));
    LTop := EnsureRange(FMovePoint.Y + LOffset, LView.Top + 4, Max(LView.Top + 4, LView.Bottom - LHeight - 4));
    LRect := RectF(LLeft, LTop, LLeft + LWidth, LTop + LHeight);
    Canvas.Fill.Color := TAlphaColorRec.Black;
    Canvas.FillRect(RectF(LRect.Left + 3, LRect.Top + 3, LRect.Right + 3, LRect.Bottom + 3), 4, 4, AllCorners, 0.25);
    if LValid then
      Canvas.Fill.Color := LPalette.SelectedBackground
    else
      Canvas.Fill.Color := LPalette.ErrorBackground;
    Canvas.FillRect(LRect, 4, 4, AllCorners, 0.95);
    Canvas.Stroke.Color := LPalette.SelectedBackground;
    Canvas.DrawRect(LRect, 4, 4, AllCorners, 1);
    if LValid then
      Canvas.Fill.Color := LPalette.SelectedText
    else
      Canvas.Fill.Color := LPalette.CellText;
    Canvas.Font.Size := FTextSize;
    Canvas.Font.Style := [TFontStyle.fsBold];
    LTextRect := LRect;
    LTextRect.Inflate(-8, -3);
    Canvas.FillText(LTextRect, FMoveCaption, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  finally
    Canvas.RestoreState(LState);
  end;
end;

function ThiiCustomGrid.FinishHeaderMove(X, Y: Single): Boolean;
var
  LHit: ThiiHitTestInfo;
  LMovingColumns: TArray<ThiiGridColumn>;
  LContext: ThiiRowsMovedContext;
  LNewIndex: Integer;
  LMarkerX, LMarkerTop: Single;
  LDragging, LColumnTargetValid: Boolean;
begin
  Result := (Length(FMovingColumns) > 0) or (Length(FMovingRowKeys) > 0);
  if not Result then
    Exit;
  try
    UpdateHeaderMove(X, Y);
    LDragging := FMoveDragging;
    LColumnTargetValid := ColumnMoveTarget(X, Y, LNewIndex, LMarkerX, LMarkerTop);
    LMovingColumns := FMovingColumns;
    LContext.RowKeys := FMovingRowKeys;
    LContext.FirstRowIndex := FMovingFirstRowIndex;
  finally
    // Release capture/restore the cursor before layout notifications or user code.
    EndSelectionDrag;
  end;
  if not CanUpdateLayout then
     Exit;
  LHit := GridHitTest(X, Y);
  if not LDragging then
  begin
    if (Length(LMovingColumns) > 0) and (LHit.Kind = ThiiHitKind.Header) and (LHit.Column = FClickDownHit.Column) then
      SelectHeaderRange(ThiiSelectionKind.Columns, -1, LHit.ColumnIndex, [])
    else
    if (Length(LContext.RowKeys) > 0) and (LHit.Kind = ThiiHitKind.RowIndicator) and (LHit.RowKey = FClickDownHit.RowKey) then
      SelectHeaderRange(ThiiSelectionKind.Rows, LHit.RowIndex, -1, []);
    Result := False; // A click still dispatches the ordinary header click event.
    Exit;
  end;
  if Length(LMovingColumns) > 0 then
  begin
    if not LColumnTargetValid then
      Exit;
    FColumns.MoveColumns(LMovingColumns, LNewIndex, FHeaderLayout);
    Repaint;
  end
  else
  if Length(LContext.RowKeys) > 0 then
  begin
    if not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving or not (LHit.Kind in [ThiiHitKind.RowIndicator, ThiiHitKind.DataCell]) then
      Exit;
    if not h5uRowMoveTarget(GetViewRowCount, LHit.RowIndex, LHit.RowKey, GetViewRowKey, GetViewSourceRowIndex, LContext) then
      Exit;
    FOnRowsMoved(Self, LContext);
  end;
end;

procedure ThiiCustomGrid.BeginSelectionDrag(AKind: ThiiSelectionKind; X, Y: Single; AShift: TShiftState);
begin
  FSelectingRange := True;
  FSelectionDragging := False;
  FSelectionDragKind := AKind;
  FSelectionDragShift := AShift;
  FSelectionDragOrigin := PointF(X, Y);
  FSelectionDragLast := ThiiCellAddress.Empty;
  Capture;
end;

procedure ThiiCustomGrid.EndSelectionDrag;
var
  LCaptured: Boolean;
begin
  LCaptured := FSelectingRange or Assigned(FResizingColumn) or (Length(FMovingColumns) > 0) or (Length(FMovingRowKeys) > 0);
  FResizingColumn := nil;
  SetResizeCursor(False);
  FMovingColumns := nil;
  FMovingRowKeys := nil;
  if FMoveDragging then
  begin
    FMoveDragging := False;
    Cursor := FMoveCursor;
    Repaint;
  end;
  FMoveCaption := '';
  FMovingHeaderCell := nil;
  FSelectingRange := False;
  FSelectionDragging := False;
  FMouseEditPending := False;
  if LCaptured then
    ReleaseCapture;
end;

procedure ThiiCustomGrid.UpdateSelectionDrag(X, Y: Single);
var
  LHit: ThiiHitTestInfo;
  LCell: ThiiCellAddress;
  LRange: ThiiCellRange;
begin
  if not FSelectingRange or not CanUpdateLayout then
    Exit;
  if not FSelectionDragging then
  begin
    if (Abs(X - FSelectionDragOrigin.X) < 4) and (Abs(Y - FSelectionDragOrigin.Y) < 4) then
      Exit;
    FSelectionDragging := True;
    FMouseEditPending := False;
  end;
  LHit := GridHitTest(X, Y);
  LCell := ThiiCellAddress.Empty;
  case FSelectionDragKind of
    ThiiSelectionKind.CellRanges:
      begin
        if (LHit.Kind <> ThiiHitKind.DataCell) or not FSelection.AnchorCell.IsValid then
          Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
    ThiiSelectionKind.Rows:
      begin
        if not (LHit.Kind in [ThiiHitKind.RowIndicator, ThiiHitKind.DataCell]) then
          Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
      end;
    ThiiSelectionKind.Columns:
      begin
        if not (LHit.Kind in [ThiiHitKind.Header, ThiiHitKind.DataCell]) then
          Exit;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
  end;
  if (LCell.RowIndex = FSelectionDragLast.RowIndex) and (LCell.RowKey = FSelectionDragLast.RowKey)
    and (LCell.ColumnIndex = FSelectionDragLast.ColumnIndex) and (LCell.ColumnId = FSelectionDragLast.ColumnId) then
    Exit;
  if FSelectionDragKind = ThiiSelectionKind.CellRanges then
  begin
    if not TryFocusCell(LCell, False) then
      Exit;
    LRange := ThiiCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex);
    FSelection.AddCellRange(LRange, ssCtrl in FSelectionDragShift, True);
  end
  else
    SelectHeaderRange(FSelectionDragKind, LCell.RowIndex, LCell.ColumnIndex, FSelectionDragShift + [ssShift]);
  FSelectionDragLast := LCell;
end;

procedure ThiiCustomGrid.SelectHeaderRange(AKind: ThiiSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
begin
  if CanUpdateLayout then
    FNavigation.SelectHeaderRange(FColumns, FSelection, GetViewRowCount, GetViewRowKey, AKind, ARow, AColumn, AShift);
end;

procedure ThiiCustomGrid.DoExit;
begin
  EndSelectionDrag;
  inherited;
end;

procedure ThiiCustomGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LHit: ThiiHitTestInfo;
  LCell: ThiiCellAddress;
  LRange: ThiiCellRange;
  LTouch: Boolean;
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseDown(Button, Shift, PointF(X, Y));
  EndSelectionDrag;
  LTouch := not FDispatchingTouch and (Button = TMouseButton.mbLeft) and ((ssTouch in Shift) {$IFDEF MOBILE}or True{$ENDIF});
  if not FDispatchingTouch then
  begin
    FHeaderInteraction := False;
    FHeaderTouch := LTouch;
  end;
  if LTouch then
  begin
    if not CanUpdateLayout then
      Exit;
    Include(Shift, ssTouch);
    FGesturePanning := False;
    FTouchShift := Shift;
    LHit := GridHitTest(X, Y);
    FHeaderInteraction := Assigned(ColumnResizeAt(X, Y, True)) or ((LHit.Kind = ThiiHitKind.Header) and IsColumnMoveGesture(LHit.Column, Shift));
    if not FHeaderInteraction then
    begin
      BeginTouchScroll(PointF(X, Y));
      Capture;
      Exit;
    end;
  end;
  if not FDispatchingTouch then
  begin
    // Some platforms finish a native gesture without a synthetic MouseUp.
    FTouchTracking := False;
    FTouchScrolling := False;
    FGesturePanning := False;
  end;
  FClickDownHit := GridHitTest(X, Y);
  FLastMousePoint := PointF(X, Y);
  inherited;
  // Inherited MouseDown dispatches DblClick. Do not take focus back afterwards.
  if ssDouble in Shift then
    Exit;
  if Button = TMouseButton.mbRight then
  begin
    if FSelection.RightClickSelect then
      SetFocus;
    SelectRightClickCell(FClickDownHit);
    Exit;
  end;
  if Button <> TMouseButton.mbLeft then
    Exit;

  SetFocus;
  if BeginColumnResize(X, Y, LTouch) then
    Exit;
  LHit := GridHitTest(X, Y);
  case LHit.Kind of
    ThiiHitKind.AdjacentGroupGlyph:
      ToggleAdjacentGroup(LHit.RowIndex);

    ThiiHitKind.Header:
      begin
    if IsColumnMoveGesture(LHit.Column, Shift) then
    begin
      BeginColumnMove(LHit.ColumnIndex, X, Y);
      Exit;
    end;
    if LHit.Column.CanSelect and (ThiiSelectionKind.Columns in FSelection.AllowedKinds) then
    begin
      SelectHeaderRange(ThiiSelectionKind.Columns, -1, LHit.ColumnIndex, Shift);
      BeginSelectionDrag(ThiiSelectionKind.Columns, X, Y, Shift);
    end;
      end;

    ThiiHitKind.RowIndicator:
      begin
    if IsRowMoveGesture(Shift) then
    begin
      BeginRowMove(LHit.RowIndex, X, Y);
      Exit;
    end;
    if ThiiSelectionKind.Rows in FSelection.AllowedKinds then
    begin
      SelectHeaderRange(ThiiSelectionKind.Rows, LHit.RowIndex, -1, Shift);
      BeginSelectionDrag(ThiiSelectionKind.Rows, X, Y, Shift);
    end;
      end;

    ThiiHitKind.DataCell:
      begin
        LCell.RowIndex := LHit.RowIndex;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnId := LHit.Column.Id;
        if (ssShift in Shift) and FSelection.AnchorCell.IsValid then
          LRange := ThiiCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex)
        else
          LRange := ThiiCellRange.Create(LCell.RowIndex, LCell.RowIndex, LCell.ColumnIndex, LCell.ColumnIndex);
        if not TryFocusCell(LCell, not (ssShift in Shift)) then
          Exit;
        FSelection.AddCellRange(LRange, ssCtrl in Shift, ssShift in Shift);
        BeginSelectionDrag(ThiiSelectionKind.CellRanges, X, Y, Shift);
        // Wait for release: the same MouseDown can still become a range drag.
        FMouseEditPending := not (ssCtrl in Shift) and not (ssShift in Shift);
      end;
  end;
end;

procedure ThiiCustomGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LHit: ThiiHitTestInfo;
  LDragged, LEdit: Boolean;
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseUp(Button, Shift, PointF(X, Y));
  if (Button = TMouseButton.mbLeft) and Assigned(FResizingColumn) then
  begin
    try
      UpdateColumnResize(X);
    finally
      EndSelectionDrag;
    end;
    FClickDownHit := ThiiHitTestInfo.Empty;
    inherited;
    Exit;
  end;
  if (Button = TMouseButton.mbLeft) and (FTouchTracking or FTouchScrolling) then
  begin
    if FTouchTracking and not FGesturePanning then
      MoveTouchScroll(PointF(X, Y));
    FTouchTracking := False;
    if FTouchScrolling then
    begin
      FTouchScrolling := False;
      FGesturePanning := False;
      FClickDownHit := ThiiHitTestInfo.Empty;
      ReleaseCapture;
      Exit;
    end;
    FDispatchingTouch := True;
    try
      MouseDown(Button, FTouchShift - [ssTouch], X, Y);
    finally
      FDispatchingTouch := False;
    end;
  end;
  if (Button = TMouseButton.mbLeft) and FinishHeaderMove(X, Y) then
  begin
    FClickDownHit := ThiiHitTestInfo.Empty;
    inherited;
    Exit;
  end;
  LDragged := False;
  LEdit := False;
  if Button = TMouseButton.mbLeft then
    try
      UpdateSelectionDrag(X, Y);
      LDragged := FSelectionDragging;
      LEdit := FMouseEditPending;
    finally
      EndSelectionDrag;
    end;
  inherited;
  if LDragged then
  begin
    FClickDownHit := ThiiHitTestInfo.Empty;
    Exit;
  end;

  if Button <> TMouseButton.mbLeft then
    Exit;
  LHit := GridHitTest(X, Y);
  if (LHit.Kind = FClickDownHit.Kind) and (LHit.Column = FClickDownHit.Column) and (LHit.RowIndex = FClickDownHit.RowIndex)
    and (LHit.Kind in [ThiiHitKind.DataCell, ThiiHitKind.Header, ThiiHitKind.RowIndicator]) then
    begin
      if LEdit and (LHit.Kind = ThiiHitKind.DataCell) then
      begin
        if CellEditorClick(LHit.Column, LHit.RowIndex) then
        begin
          if CellEditorHit(LHit.Column, LHit.RowIndex, FClickDownHit.Bounds, FSelectionDragOrigin)
            and CellEditorHit(LHit.Column, LHit.RowIndex, FClickDownHit.Bounds, PointF(X, Y)) then
            StartEdit(LHit);
        end
        else
          if FEditing.ImmediateEdit then
            EditFocusedCell(True);
      end;
      NotifyCellClick(LHit.Column, LHit.RowIndex, LHit.Kind = ThiiHitKind.Header, LHit.Kind = ThiiHitKind.RowIndicator);
    end;
  FClickDownHit := ThiiHitTestInfo.Empty;
end;

procedure ThiiCustomGrid.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseMove(Shift, PointF(X, Y));
  inherited;
  FLastMousePoint := PointF(X, Y);
  if Assigned(FResizingColumn) then
  begin
    if ssLeft in Shift then
      UpdateColumnResize(X)
    else
      EndSelectionDrag;
    Exit;
  end;
  if FTouchTracking and not FGesturePanning then
    MoveTouchScroll(PointF(X, Y))
  else
  if not (ssLeft in Shift) then
  begin
    EndSelectionDrag;
    if not (ssTouch in Shift) then
      SetResizeCursor(Assigned(ColumnResizeAt(X, Y, False)));
  end
  else
  begin
    UpdateHeaderMove(X, Y);
    UpdateSelectionDrag(X, Y);
  end;
end;

procedure ThiiCustomGrid.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  LDelta: Single;
begin
  inherited;
  LDelta := FScrolling.WheelRows * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);
  if WheelDelta > 0 then
    FVerticalOffset := FVerticalOffset - LDelta
  else
    FVerticalOffset := FVerticalOffset + LDelta;
  FVerticalOffset := EnsureRange(FVerticalOffset, 0, Max(0.0, FVScrollBar.Max - FVScrollBar.ViewportSize));
  FVScrollBar.Value := FVerticalOffset;
  Repaint;
  Handled := True;
end;

procedure ThiiCustomGrid.MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
begin
  if not CanMoveColumn(AColumn) then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  Repaint;
end;

procedure ThiiCustomGrid.ToggleAdjacentGroup(AViewRowIndex: Int64);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  FAutoWidthsDirty := True;
  if FView.ChangeAdjacentGroup(AViewRowIndex, True, False, LInfo) then
  begin
    DoAdjacentGroupStateChanged(LInfo);
    CancelEditor;
    InvalidateAllRowHeights;
    UpdateScrollBars;
    Repaint;
  end;
end;

procedure ThiiCustomGrid.SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  FAutoWidthsDirty := True;
  if FView.ChangeAdjacentGroup(AViewRowIndex, False, ACollapsed, LInfo) then
  begin
    DoAdjacentGroupStateChanged(LInfo);
    CancelEditor;
    InvalidateAllRowHeights;
    UpdateScrollBars;
    Repaint;
  end;
end;

procedure ThiiCustomGrid.ExpandAllAdjacentGroups;
var
  LChanged: TArray<Th5uAdjacentGroupRowInfo>;
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  FAutoWidthsDirty := True;
  LChanged := FView.ChangeAllAdjacentGroups(False);
  if Length(LChanged) = 0 then
    Exit;
  for LInfo in LChanged do
    DoAdjacentGroupStateChanged(LInfo);
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure ThiiCustomGrid.CollapseAllAdjacentGroups;
var
  LChanged: TArray<Th5uAdjacentGroupRowInfo>;
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  FAutoWidthsDirty := True;
  LChanged := FView.ChangeAllAdjacentGroups(True);
  if Length(LChanged) = 0 then
    Exit;
  for LInfo in LChanged do
    DoAdjacentGroupStateChanged(LInfo);
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure ThiiCustomGrid.ResetAdjacentGroupStates;
begin
  FAutoWidthsDirty := True;
  FView.ResetAdjacentGroupStates;
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

function ThiiCustomGrid.IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
begin
  Result := FView.IsAdjacentGroupCollapsed(AViewRowIndex);
end;

procedure ThiiCustomGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;
  if AComponent = FDataController then
    DataController := nil;
  if AComponent = FSharedClassFactory then
    SharedClassFactory := nil;
end;

procedure ThiiCustomGrid.OptionsChanged(Sender: TObject);
begin
  FAutoWidthsDirty := True;
  if Sender = FAdjacentGroupFolding then
    InvalidateAdjacentGroupMap(False);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure ThiiCustomGrid.Paint;
var
  LStarted: Int64;
  LPalette: ThiiFmxPalette;
  LViewport: TRectF;
begin
  if not CanUpdateLayout then
    Exit;
  LStarted := BeginPerformanceTiming;
  try
    inherited;
    LPalette := h5uGetFmxPalette(FAppearance.Theme);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := LPalette.EmptyArea;
    PrepareGridCanvas(LocalRect, ThiiElementKind.Grid);
    Canvas.FillRect(LocalRect, 0, 0, AllCorners, 1);

    UpdateScrollBars;
    BuildColumnLayout;
    BeginVisualPass;

    DrawContentPadding;

    LViewport := GetViewportRect;
    Canvas.Fill.Color := ResolveDefaultCellColor;
    Canvas.Fill.Kind := TBrushKind.Solid;
    PrepareGridCanvas(LViewport, ThiiElementKind.Grid);
    Canvas.FillRect(LViewport, 0, 0, AllCorners, 1);

    DrawHeaders;
    DrawRows;
    UpdateActiveEditorBounds;
    DrawColumnMoveFeedback;
    if Assigned(FOnAfterDraw) then
      FOnAfterDraw(Self, Canvas);
  finally
    EndPerformanceTiming(ThiiGridPerformanceStage.Paint, LStarted);
  end;
end;

procedure ThiiCustomGrid.Resize;
begin
  inherited;
  if not CanUpdateLayout then
    Exit;
  LayoutScrollBars;
  UpdateScrollBars;
  Repaint;
end;

function ThiiCustomGrid.ResolveCellAppearance(AViewRowIndex: Int64; AColumn: ThiiGridColumn; ASelected, AFocused: Boolean): ThiiResolvedAppearance;
var
  LPalette: ThiiFmxPalette;
begin
  Result.Clear;
  Result.HasBackground := True;
  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  Result.Background := AlphaColorToColor(ResolveRowBackground(AViewRowIndex));

  if (AColumn.Color <> TColorRec.SysDefault) and not ASelected then
    Result.Background := AColumn.Color;

  if AColumn.Highlighted and (AColumn.Color = TColorRec.SysDefault) and not ASelected then
    Result.Background := AlphaColorToColor(LPalette.HighlightedColumnBackground);

  if ASelected then
  begin
    Result.Background := AlphaColorToColor(LPalette.SelectedBackground);
    Result.HasForeground := True;
    Result.Foreground := AlphaColorToColor(LPalette.SelectedText);
  end;

  if AFocused then
  begin
    Result.HasBorder := True;
    Result.Border := AlphaColorToColor(LPalette.FocusBorder);
  end;
end;

function ThiiCustomGrid.ResolveRowBackground(AViewRowIndex: Int64): TAlphaColor;
var
  LPalette: ThiiFmxPalette;
  LStyle: string;
  LKeyValue: TValue;
  LKey: Integer;
  LHasKey: Boolean;
  LColumn: ThiiGridColumn;
begin
  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  LKey := 0;
  LHasKey := False;

  LColumn := FColumns.FindById(FRowStyles.StyleKeyColumnId);
  if Assigned(LColumn) and Assigned(FDataController) then
  begin
    LKeyValue := GetViewValue(AViewRowIndex, LColumn.FieldName);
    LHasKey := h5uTryValueAsInteger(LKeyValue, LKey);
  end;

  LStyle := FRowStyles.ResolveStyle(AViewRowIndex, LKey, LHasKey);
  if SameText(LStyle, 'Error') then
    Result := LPalette.ErrorBackground
  else if SameText(LStyle, 'Warning') then
    Result := LPalette.WarningBackground
  else if SameText(LStyle, 'Stripe') then
    Result := LPalette.StripeBackground
  else if FAppearance.DefaultCellColor <> TColorRec.SysDefault then
    Result := ResolveDefaultCellColor
  else if SameText(LStyle, 'Odd') then
    Result := LPalette.OddBackground
  else if SameText(LStyle, 'Even') then
    Result := LPalette.EvenBackground
  else
    Result := ResolveDefaultCellColor;
end;

procedure ThiiCustomGrid.ScrollChanged(Sender: TObject);
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;

  CancelEditor;
  FVerticalOffset := FVScrollBar.Value;
  FHorizontalOffset := FHScrollBar.Value;
  if Sender = FVScrollBar then
    ShowThumbHint(ThiiScrollAxis.Vertical)
  else
    ShowThumbHint(ThiiScrollAxis.Horizontal);
  Repaint;
end;

procedure ThiiCustomGrid.SelectionChanged(Sender: TObject);
var
  LOld, LNew: ThiiCellAddress;
begin
  Repaint;
  if not CanUpdateLayout then
    Exit;
  LOld := FLastNotifiedCell;
  LNew := FSelection.FocusedCell;
  FLastNotifiedCell := LNew;
  h5uNotifyFocusChange(Self, FColumns, LOld, LNew, FOnCellExit, FOnCellEnter, FOnSelectionChange);
end;

procedure ThiiCustomGrid.SetColumns(const AValue: ThiiGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure ThiiCustomGrid.SetAppearance(const AValue: ThiiGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure ThiiCustomGrid.SetTree(const AValue: ThiiTreeOptions);
begin
  if Assigned(AValue) then
    FTree.Assign(AValue);
end;

procedure ThiiCustomGrid.SetAdjacentGroupFolding(const AValue: ThiiAdjacentGroupFoldingOptions);
begin
  if Assigned(AValue) then
    FAdjacentGroupFolding.Assign(AValue);
end;

procedure ThiiCustomGrid.SetGridLines(const AValue: Boolean);
begin
  if AValue then
    FSpacing.SetAllSeparators(1)
  else
    FSpacing.SetAllSeparators(0);
end;

procedure ThiiCustomGrid.SetSpacing(const AValue: ThiiGridSpacingOptions);
begin
  FSpacing.Assign(AValue);
end;

procedure ThiiCustomGrid.SetCustomization(const AValue: ThiiCustomizationOptions);
begin
  FCustomization.Assign(AValue);
end;

procedure ThiiCustomGrid.SetDataController(const AValue: ThiiCustomDataController);
begin
  if FDataController = AValue then
    Exit;
  EndSelectionDrag;
  if Assigned(FDataController) then
    FDataController.RemoveFreeNotification(Self);
  FAutoWidthsDirty := True;
  FDataController := AValue;
  FDataLink.Controller := FDataController;
  if Assigned(FDataController) then
    FDataController.FreeNotification(Self);
  FVerticalOffset := 0;
  InvalidateAdjacentGroupMap(True);
  InvalidateAllRowHeights;
  Repaint;
end;

procedure ThiiCustomGrid.SetHeaderLayout(const AValue: ThiiHeaderLayout);
begin
  FHeaderLayout.Assign(AValue);
  Repaint;
end;

procedure ThiiCustomGrid.SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);
begin
  FFactoryScope.OnConfigureInstance := AValue;
end;

procedure ThiiCustomGrid.SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
begin
  FFactoryScope.OnCreateInstance := AValue;
end;

procedure ThiiCustomGrid.SetOnGetClass(const AValue: ThiiGetClassEvent);
begin
  FFactoryScope.OnGetClass := AValue;
end;

procedure ThiiCustomGrid.SetRowHeight(const AValue: ThiiRowHeightOptions);
begin
  FRowHeight.Assign(AValue);
end;

procedure ThiiCustomGrid.SetRowStyles(const AValue: ThiiRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Repaint;
end;

procedure ThiiCustomGrid.SetScrolling(const AValue: ThiiScrollingOptions);
begin
  FScrolling.Assign(AValue);
end;

procedure ThiiCustomGrid.SetScrollHints(const AValue: ThiiScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure ThiiCustomGrid.SetSelection(const AValue: ThiiGridSelection);
begin
  FSelection.Assign(AValue);
end;

procedure ThiiCustomGrid.SetSharedClassFactory(const AValue: ThiiClassFactory);
begin
  if FSharedClassFactory = AValue then
    Exit;
  if Assigned(FSharedClassFactory) then
    FSharedClassFactory.RemoveFreeNotification(Self);
  FSharedClassFactory := AValue;
  if Assigned(FSharedClassFactory) then
  begin
    FSharedClassFactory.FreeNotification(Self);
    FFactoryScope.Parent := FSharedClassFactory.Scope;
  end
  else
    FFactoryScope.Parent := h5uGlobalFactoryScope;
  FCellPool.Clear;
  Repaint;
end;


procedure ThiiCustomGrid.SetColumnVisible(AColumn: ThiiGridColumn; AVisible: Boolean);
begin
  if not Assigned(AColumn) then
    Exit;
  if not AVisible and (not FCustomization.AllowColumnHiding or not AColumn.CanHide) then
    Exit;
  AColumn.Visible := AVisible;
  FColumns.NormalizeVisibleIndexes;
  Repaint;
end;

procedure ThiiCustomGrid.ShowThumbHint(AAxis: ThiiScrollAxis);
var
  LContext: ThiiThumbHintContext;
  LText: string;
  LVisible: Boolean;
  LPalette: ThiiFmxPalette;
  LRatio: Single;
  LX: Single;
  LY: Single;
begin
  if not FScrollHints.Enabled then
    Exit;

  LText := BuildThumbHintText(AAxis, LContext);
  LVisible := LText <> '';
  if Assigned(FOnGetThumbHint) then
    FOnGetThumbHint(Self, LContext, LText, LVisible);
  if not LVisible then
  begin
    HideThumbHint;
    Exit;
  end;

  LPalette := h5uGetFmxPalette(FAppearance.Theme);
  // Alpha 204/255 gives the background 80% opacity without fading the text.
  FThumbHintBackground.Fill.Color := (LPalette.ThumbHintBackground and $00FFFFFF) or $CC000000;
  FThumbHint.Text := LText;
  FThumbHint.TextSettings.FontColor := LPalette.ThumbHintText;
  FThumbHint.TextSettings.Font.Size := FTextSize;
  FThumbHintBackground.Width := Min(Max(120, Length(LText) * FTextSize * 0.55 + 20), Width - 20);
  FThumbHintBackground.Height := 32;

  if AAxis = ThiiScrollAxis.Vertical then
  begin
    if FVScrollBar.Max > FVScrollBar.ViewportSize then
      LRatio := FVerticalOffset / (FVScrollBar.Max - FVScrollBar.ViewportSize)
    else
      LRatio := 0;
    LX := GetViewportRect.Right - FThumbHintBackground.Width - 8;
    LY := GetViewportRect.Top + (GetViewportRect.Height - FThumbHintBackground.Height) * LRatio;
  end
  else
  begin
    if FHScrollBar.Max > FHScrollBar.ViewportSize then
      LRatio := FHorizontalOffset / (FHScrollBar.Max - FHScrollBar.ViewportSize)
    else
      LRatio := 0;
    LX := GetViewportRect.Left + (GetViewportRect.Width - FThumbHintBackground.Width) * LRatio;
    LY := GetViewportRect.Bottom - FThumbHintBackground.Height - 8;
  end;

  FThumbHintBackground.Position.Point := PointF(LX, LY);
  FThumbHintBackground.Visible := True;
  FThumbHintBackground.BringToFront;
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Enabled := True;
end;

function ThiiCustomGrid.FocusedCellHit(out AHit: ThiiHitTestInfo): Boolean;
begin
  Result := CellHit(FSelection.FocusedCell, AHit);
end;

function ThiiCustomGrid.CellHit(const LCell: ThiiCellAddress; out AHit: ThiiHitTestInfo): Boolean;
var
  LColumns: TArray<ThiiGridColumn>;
  LView: TRectF;
  LTop: Double;
  LHeight, LLeft, LRight: Single;
  LKey: ThiiRowKey;
  I: Integer;
begin
  Result := False;
  AHit := ThiiHitTestInfo.Empty;
  if not CanUpdateLayout or not Assigned(FDataController) then
    Exit;
  LColumns := FColumns.VisibleColumns;
  if not LCell.IsValid or (LCell.RowIndex >= GetViewRowCount) or (LCell.ColumnIndex >= Length(LColumns)) then
    Exit;
  LView := GetDataViewportRect;
  PrepareRowMetrics;
  LTop := FRowMetrics.RowTop(LCell.RowIndex).AsFloat;
  PrepareViewRange(LCell.RowIndex, 1);
  LKey := GetViewRowKey(LCell.RowIndex);
  LHeight := GetRowHeightFor(LCell.RowIndex, LKey);
  FVerticalOffset := h5uRevealOffset(FVerticalOffset, LTop, LHeight, LView.Height);
  BuildColumnLayout;
  LLeft := LView.Left;
  if FRowIndicator.Visible then
    LLeft := LLeft + FRowIndicator.Width + FSpacing.DefaultColumnRightSpacing;
  LRight := LView.Right;
  for I := 0 to High(LColumns) do
    case LColumns[I].FixedKind of
      ThiiFixedKind.Left: LLeft := LLeft + LColumns[I].LayoutWidth + GetEffectiveColumnRightSpacing(LColumns[I]);
      ThiiFixedKind.Right: LRight := LRight - LColumns[I].LayoutWidth - GetEffectiveColumnRightSpacing(LColumns[I]);
    end;
  if LColumns[LCell.ColumnIndex].FixedKind = ThiiFixedKind.None then
  begin
    if FAllColumns[LCell.ColumnIndex].Bounds.Left < LLeft then
      FHorizontalOffset := Max(0, FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Left - LLeft)
    else if FAllColumns[LCell.ColumnIndex].Bounds.Right > LRight then
      FHorizontalOffset := Max(0, FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Right - LRight);
  end;
  UpdateScrollBars;
  BuildColumnLayout;
  AHit.Kind := ThiiHitKind.DataCell;
  AHit.RowIndex := LCell.RowIndex;
  AHit.RowKey := LKey;
  AHit.ColumnIndex := LCell.ColumnIndex;
  AHit.Column := LColumns[LCell.ColumnIndex];
  AHit.Bounds := FAllColumns[LCell.ColumnIndex].Bounds;
  AHit.Bounds.Top := LView.Top + LTop - FVerticalOffset;
  AHit.Bounds.Bottom := AHit.Bounds.Top + LHeight;
  AHit.Bounds := GetVisibleCellBounds(AHit.Column, AHit.Bounds, AHit.Bounds);
  Repaint;
  Result := True;
end;

function ThiiCustomGrid.FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean): Boolean;
var
  LCell: ThiiCellAddress;
  LRange: ThiiCellRange;
  LHit: ThiiHitTestInfo;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FDataController) then
    Exit;
  if not h5uPlanCellFocus(FColumns, FSelection, GetViewRowCount, GetViewRowKey, ARow, AColumn, AExtend, LCell, LRange) then
    Exit;
  if not TryFocusCell(LCell, not AExtend) then
    Exit;
  FSelection.AddCellRange(LRange, AAdd, AExtend);
  Result := FocusedCellHit(LHit);
  if Result and AEdit and FEditing.ImmediateEdit and not AExtend then
    EditFocusedCell(True);
end;

procedure ThiiCustomGrid.EditFocusedCell(AAutomatic: Boolean);
var
  LHit: ThiiHitTestInfo;
begin
  if not FocusedCellHit(LHit) then
    Exit;
  if AAutomatic and not CellEditorAutoEdit(LHit.Column, LHit.RowIndex) then
    Exit;
  StartEdit(LHit);
end;

function ThiiCustomGrid.NavigationRowExtent(ARow: Int64): Single;
begin
  Result := GetRowHeightFor(ARow, GetViewRowKey(ARow)) + FSpacing.RowSpacing;
end;

function ThiiCustomGrid.HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
var
  LAction: Th5uNavigationAction;
  LHit: ThiiHitTestInfo;
begin
  Result := False;
  if not CanUpdateLayout or (ssAlt in AShift) then
    Exit;
  if AKey = vkEscape then
  begin
    EndSelectionDrag;
    FNavigation.Cancel(FSelection);
    Exit(True);
  end;
  Result := FNavigation.Navigate(FColumns, FSelection, GetViewRowCount, GetViewRowKey, NavigationRowExtent, GetDataViewportRect.Height, AKey, AShift,
    LAction);
  if not Result then
    Exit;
  case LAction.Kind of
    Th5uNavigationActionKind.Focus:
      begin
        FocusCell(LAction.Cell.RowIndex, LAction.Cell.ColumnIndex, LAction.Extend, LAction.AutomaticEdit, LAction.Add);
        if LAction.EditAfterFocus then
          EditFocusedCell(False);
      end;
    Th5uNavigationActionKind.Edit:
      EditFocusedCell(False);
    Th5uNavigationActionKind.Header:
      begin
        SelectHeaderRange(FNavigation.HeaderSelectionKind, LAction.Cell.RowIndex, LAction.Cell.ColumnIndex, AShift);
        CellHit(LAction.Cell, LHit);
      end;
  end;
end;

procedure ThiiCustomGrid.SearchCharacter(AChar: Char);
var
  LRow: Int64;
  LColumn: Integer;
begin
  if (AChar < #32) or Assigned(FEditColumn) or not CanUpdateLayout then
    Exit;
  if FNavigation.SearchCharacter(FColumns, FSelection, GetViewRowCount, PrepareViewRange, GetCellText, AChar, Now, LRow, LColumn) then
    FocusCell(LRow, LColumn, False, False);
end;

procedure ThiiCustomGrid.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) and IsFocused then
  begin
    FActiveEditor.KeyDown(Key, KeyChar, Shift);
    Exit;
  end;
  // FMX also routes keys from children here; preserve the editor's caret keys.
  if Assigned(FEditColumn) then
    Exit;
  if HandleNavigationKey(Key, Shift) then
  begin
    Key := 0;
    KeyChar := #0;
  end
  else
  if (KeyChar >= #32) and not (ssCtrl in Shift) and not (ssAlt in Shift) then
  begin
    SearchCharacter(KeyChar);
    KeyChar := #0;
  end;
end;

procedure ThiiCustomGrid.StartEdit(const AHit: ThiiHitTestInfo);
var
  LEditor: ThiiGridEditorItem;
  LCell: ThiiCellAddress;
  LContext: ThiiEditorContext;
begin
  if csDesigning in ComponentState then
    Exit;
  if Assigned(FActiveEditor) then
  begin
    if (FEditColumn = AHit.Column) and (FEditRowIndex = AHit.RowIndex) then
    begin
      FActiveEditor.Focus;
      Exit;
    end;
    CommitEditor;
    if Assigned(FActiveEditor) then
      Exit;
  end;
  if not Assigned(FDataController) or not Assigned(AHit.Column) or not AllowCellEdit(AHit.Column, AHit.RowIndex) then
    Exit;
  LEditor := GetCellEditor(AHit.Column, AHit.RowIndex);
  if not Assigned(LEditor) then
    Exit;
  LCell.RowIndex := AHit.RowIndex;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnId := AHit.Column.Id;
  if not TryFocusCell(LCell, True) then
    Exit;
  LContext := CellEditorContext(AHit.Column, AHit.RowIndex, AHit.Bounds);
  FEditColumn := AHit.Column;
  FEditRowIndex := AHit.RowIndex;
  FEditRowKey := AHit.RowKey;
  FActiveEditor := LEditor;
  FEditorExitBlocked := False;
  LEditor.OnRequestCommit := EditorRequestCommit;
  LEditor.OnRequestCancel := EditorRequestCancel;
  LEditor.OnChanged := EditorChanged;
  LEditor.OnExited := EditorExit;
  LEditor.OnProcessKey := ProcessEditorKey;
  try
    LEditor.BeginEdit(LContext);
    LEditor.Activate;
  except
    // Validation errors leave the draft open; construction errors abandon it.
    if not LEditor.Active then
      FinishEditor(False);
    raise;
  end;
  Repaint;
end;

procedure ThiiCustomGrid.ThumbHintTimer(Sender: TObject);
begin
  HideThumbHint;
end;

procedure ThiiCustomGrid.UpdateScrollBars;
var
  LStarted: Int64;
  LPass, LSettle: Integer;
  LNeedH, LNeedV: Boolean;
  LAvailableWidth, LAvailableHeight, LContentWidth: Single;
  LContentHeight: Double;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;
  LStarted := BeginPerformanceTiming;
  FUpdatingScrollBars := True;
  try
    MeasureAutoWidths;
    for LSettle := 1 to 3 do
    begin
      LNeedH := False;
      LNeedV := False;
      // Provisional widths must not measure rows or clear their height cache.
      for LPass := 1 to 3 do
      begin
        LAvailableWidth := Max(0, Width - FSpacing.Left - FSpacing.Right);
        LAvailableHeight := Max(0, Height - FSpacing.Top - FSpacing.Bottom - GetHeaderHeight);
        if LNeedV then
          LAvailableWidth := Max(0, LAvailableWidth - FVScrollBar.Width);
        if LNeedH then
          LAvailableHeight := Max(0, LAvailableHeight - FHScrollBar.Height);
        ResolveColumnWidths(LAvailableWidth);
        LContentWidth := GetTotalColumnWidth;
        LContentHeight := GetEstimatedTotalRowHeight(False);
        if (LNeedH or (LContentWidth <= LAvailableWidth)) and (LNeedV or (LContentHeight <= LAvailableHeight)) then
          Break;
        LNeedH := LNeedH or (LContentWidth > LAvailableWidth);
        LNeedV := LNeedV or (LContentHeight > LAvailableHeight);
      end;
      FHScrollBar.Visible := LNeedH;
      FVScrollBar.Visible := LNeedV;
      LayoutScrollBars;
      LAvailableWidth := GetViewportRect.Width;
      LAvailableHeight := GetDataViewportRect.Height;
      ResolveColumnWidths(LAvailableWidth);
      MeasureAutoWidths;
      ResolveColumnWidths(LAvailableWidth);
      FRowMetrics.CheckColumnWidths(FColumns);
      LContentWidth := GetTotalColumnWidth;
      LContentHeight := GetEstimatedTotalRowHeight;
      if LNeedV = (LContentHeight > LAvailableHeight) then
        Break;
    end;
    FHScrollBar.Min := 0;
    FHScrollBar.Max := Max(0.0, LContentWidth);
    FHScrollBar.ViewportSize := LAvailableWidth;
    FVScrollBar.Min := 0;
    FVScrollBar.Max := Max(0.0, LContentHeight);
    FVScrollBar.ViewportSize := LAvailableHeight;
    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, Max(0.0, FHScrollBar.Max - FHScrollBar.ViewportSize));
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, Max(0.0, FVScrollBar.Max - FVScrollBar.ViewportSize));
    FHScrollBar.Value := FHorizontalOffset;
    FVScrollBar.Value := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
    EndPerformanceTiming(ThiiGridPerformanceStage.Layout, LStarted);
  end;
end;

procedure ThiiCustomGrid.SetEditors(AValue: ThiiFmxGridEditors);
begin
  CancelEditor;
  FEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Repaint;
end;

procedure ThiiCustomGrid.SetDefaultEditors(AValue: ThiiDefaultEditors);
begin
  CancelEditor;
  FDefaultEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Repaint;
end;

procedure ThiiCustomGrid.ClearEditorCache;
var
  I: Integer;
begin
  CancelEditor;
  FEditorCache.Clear;
  FAutoWidthsDirty := True;
  for I := 0 to FEditors.Count - 1 do
    FEditors[I].ReleaseEditor;
end;

function ThiiCustomGrid.CachedEditor(const AName: string): ThiiGridEditorItem;
begin
  Result := FEditorCache.Get(ThiiEditorPlatform.FMX, AName, '', FEditors.Find(AName));
end;

function ThiiCustomGrid.GetCellEditor(AColumn: ThiiGridColumn; ARow: Int64): ThiiGridEditorItem;
var
  LName, LScope: string;
  LColumnScoped: Boolean;
begin
  LName := h5uResolveEditorName(Self, FColumns, AColumn, ARow, FDefaultEditors, GetCellValue, LColumnScoped);
  if (LName = '') or SameText(LName, 'None') then
    Exit(nil);
  LScope := '';
  if LColumnScoped then
  begin
    LScope := AColumn.Id;
    if LScope = '' then
      raise EhiiGrid.Create('Dynamische Editoren benötigen eine ColumnID.');
  end;
  Result := FEditorCache.Get(ThiiEditorPlatform.FMX, LName, LScope, FEditors.Find(LName));
end;

function ThiiCustomGrid.CellEditorAutoEdit(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
var
  E: ThiiGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.CanAutoEdit;
end;

function ThiiCustomGrid.CellEditorHit(AColumn: ThiiGridColumn; ARow: Int64; const ABounds: TRectF; const APoint: TPointF): Boolean;
var
  E: ThiiGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.HitTest(ABounds, APoint);
end;

function ThiiCustomGrid.CellEditorContext(AColumn: ThiiGridColumn; ARow: Int64; const ABounds: TRectF): ThiiEditorContext;
begin
  Result := Default(ThiiEditorContext);
  Result.Grid := Self;
  Result.Column := AColumn;
  Result.RowIndex := ARow;
  Result.RowKey := GetViewRowKey(ARow);
  Result.Bounds := ABounds;
  Result.Value := GetCellValue(AColumn, ARow, False);
  Result.Text := GetCellText(AColumn, ARow, False);
  Result.Foreground := h5uGetFmxPalette(FAppearance.Theme).CellText;
  Result.Background := h5uGetFmxPalette(FAppearance.Theme).CellBackground;
end;

procedure ThiiCustomGrid.FinishEditor(ACommitted: Boolean);
var
  E: ThiiGridEditorItem;
begin
  E := FActiveEditor;
  // Hiding a focused control can synchronously send OnExit.
  FActiveEditor := nil;
  FEditColumn := nil;
  FEditRowIndex := -1;
  if Assigned(E) then
    if ACommitted then
      E.Committed
    else
      E.Cancel;
end;

procedure ThiiCustomGrid.EditorRequestCommit(Sender: TObject);
begin
  CommitEditor;
end;

procedure ThiiCustomGrid.EditorRequestCancel(Sender: TObject);
begin
  CancelEditor;
  Repaint;
end;

procedure ThiiCustomGrid.ProcessEditorKey(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  EditorKeyDown(Sender, Key, KeyChar, Shift);
end;

function ThiiCustomGrid.CellEditorClick(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
var
  E: ThiiGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.ActivateOnClick;
end;

end.

