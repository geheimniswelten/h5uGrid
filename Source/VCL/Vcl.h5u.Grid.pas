unit Vcl.h5u.Grid;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.TypInfo,
  System.DateUtils,
  System.Diagnostics,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Data.DB,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
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
  h5u.Grid.Selection,
  h5u.Grid.Sizing,
  h5u.Grid.Types,
  h5u.Grid.Data.Dataset,
  Vcl.h5u.Grid.Styles,
  Vcl.h5u.Grid.Editors;

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

  ThiiCustomGrid = class;
  ThiiVclVisualCell = class;
  ThiiVclVisualCellClass = class of ThiiVclVisualCell;

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

  ThiiGetRowHeightEvent = procedure(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean) of object;
  ThiiGetRowSpacingEvent = procedure(Sender: TObject; const AContext: ThiiGetRowHeightContext; var ASpacing: Integer) of object;

  ThiiThumbHintContext = record
    Grid: ThiiCustomGrid;
    DataController: ThiiCustomDataController;
    Axis: ThiiScrollAxis;
    Trigger: ThiiScrollHintTrigger;
    ScrollOffset: Int64;
    ScrollRange: Int64;
    RowKey: ThiiRowKey;
    ViewRowIndex: Int64;
    Column: ThiiGridColumn;
    Value: TValue;
    DisplayText: string;
    IsEstimated: Boolean;
    IsValueAvailable: Boolean;
  end;

  ThiiGetThumbHintEvent = procedure(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean) of object;
  ThiiRowAppearanceEvent = procedure(Sender: TObject; AViewRowIndex: Int64; const ARowKey: ThiiRowKey; var AAppearance: ThiiResolvedAppearance) of object;
  ThiiCellAppearanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; var AAppearance: ThiiResolvedAppearance) of object;

  ThiiVclDrawContext = record
    FactoryContext: ThiiFactoryContext;
    Bounds: TRect;
    DisplayText: string;
    Appearance: ThiiResolvedAppearance;
  end;

  ThiiVclAfterDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;
  ThiiVclPrepareElementEvent = procedure(Sender: TObject; Control: TObject; ACanvas: TCanvas; const AContext: ThiiVclDrawContext; APart: ThiiElementPaintPart) of object;
  ThiiVclCustomDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas; const AContext: ThiiVclDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean) of object;

  ThiiVisibleColumnInfo = record
    Column: ThiiGridColumn;
    VisibleIndex: Integer;
    Bounds: TRect;
    RightSpacing: Integer;
  end;

  ThiiVisibleRowInfo = record
    RowIndex: Int64;
    RowKey: ThiiRowKey;
    Bounds: TRect;
    Height: Integer;
  end;

  ThiiHitTestInfo = record
    Kind: ThiiHitKind;
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: ThiiRowKey;
    Column: ThiiGridColumn;
    Bounds: TRect;
    HeaderCell: ThiiHeaderLayoutCell;
    class function Empty: ThiiHitTestInfo; static;
  end;

  ThiiVclVisualCell = class(ThiiFactoryObject)
  private
    FContext: ThiiFactoryContext;
    FBounds: TRect;
    FValue: TValue;
    FDisplayText: string;
    FAppearance: ThiiResolvedAppearance;
    FInUse: Boolean;
  protected
    procedure PrepareCanvas(AGrid: ThiiCustomGrid; ACanvas: TCanvas; APart: ThiiElementPaintPart);
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); virtual;
    function EffectiveBackground(AGrid: ThiiCustomGrid): TColor;
    function EffectiveForeground(AGrid: ThiiCustomGrid): TColor;
  public
    procedure BindCell(const AContext: ThiiFactoryContext; const ABounds: TRect; const AValue: TValue; const ADisplayText: string;
      const AAppearance: ThiiResolvedAppearance); virtual;
    procedure Paint(AGrid: ThiiCustomGrid; ACanvas: TCanvas); virtual;

    property Context: ThiiFactoryContext read FContext;
    property Bounds: TRect read FBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: ThiiResolvedAppearance read FAppearance;
  end;

  // Lightweight pooled painter for row/column separators, content padding
  // and the tree branch-end band. Its ClassId is resolved per grid instance.
  Th5uVclSpacingCell = class(ThiiVclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiVclDataCell = class(ThiiVclVisualCell)
  private
    FPicture: TPicture;
    FPictureSignature: Integer;
    procedure EnsurePicture;
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  ThiiVclHeaderCell = class(ThiiVclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiVclFixedCell = class(ThiiVclDataCell);

  // Plus/minus glyph used for one contiguous run of equal adjacent IDs.
  // The class is resolved through the per-grid FactoryScope.
  Th5uVclAdjacentGroupGlyphCell = class(ThiiVclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiCustomGrid = class(TCustomControl)
  private
    FShowColumnModes: Boolean;
    FColumns: ThiiGridColumns;
    FColumnSizing: ThiiColumnSizingOptions;
    FHasSizingVersion: Boolean;
    FAutoWidthsDirty: Boolean;
    FAutoWidthFont: string;
    FAutoWidthConstraints: string;
    FMeasuringAutoWidths: Boolean;
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetAutoWidthRowLimit(const AValue: Integer);
    procedure MeasureAutoWidths;
    procedure ResolveColumnWidths(AAvailableWidth: Single);
  private
    FHeader: ThiiGridHeaderOptions;
    FHeaderLayout: ThiiHeaderLayout;
    FRowIndicator: ThiiRowIndicatorOptions;
    FEditing: ThiiEditingOptions;
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
    FAdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions;
    FTree: ThiiTreeOptions;
    FView: Th5uGridView;

    function GetTheme: ThiiGridTheme;
    function GetHeaderRowHeight: Integer;
    function GetRowIndicatorWidth: Integer;
    function GetShowHeader: Boolean;
    function GetShowRowIndicator: Boolean;
    function GetAllowEditing: Boolean;
    function GetImmediateEdit: Boolean;
    function GetMinWidth: Integer;
    function GetMaxWidth: Integer;
    function GetAutoWidthRowLimit: Integer;
    procedure SetShowHeader(AValue: Boolean);
    procedure SetShowRowIndicator(AValue: Boolean);
    procedure SetAllowEditing(AValue: Boolean);
    procedure SetImmediateEdit(AValue: Boolean);
    procedure SetColumnSizing(const AValue: ThiiColumnSizingOptions);
    procedure SetHeader(const AValue: ThiiGridHeaderOptions);
    procedure SetRowIndicator(const AValue: ThiiRowIndicatorOptions);
    procedure SetEditing(const AValue: ThiiEditingOptions);
    procedure EditorTemplatesChanged(Sender: TObject);
    procedure AppearanceChanged(Sender: TObject);
    procedure EditingChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure ReadSizingVersion(AReader: TReader);
    procedure WriteSizingVersion(AWriter: TWriter);
    procedure PrepareColumnWidthDefaults(AReferenceWidth: Single);
    function MonitorWorkAreaWidth: Single;
  private
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
    FLastNotifiedCell: ThiiCellAddress;

    function FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean = False): Boolean;
    function FocusedCellHit(out AHit: ThiiHitTestInfo): Boolean;
    function CellHit(const LCell: ThiiCellAddress; out AHit: ThiiHitTestInfo): Boolean;
    procedure EditFocusedCell(AAutomatic: Boolean);
    function NavigationRowExtent(ARow: Int64): Single;
    function HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
    procedure SearchCharacter(AChar: Char);
  private
    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditRowIndex: Int64;
    FEditRowKey: ThiiRowKey;
    FEditColumn: ThiiGridColumn;
    FCommittingEditor: Boolean;
    FEditors: ThiiVclGridEditors;
    FEditorCache: Th5uGridEditorCache;
    FDefaultEditors: ThiiDefaultEditors;
    FActiveEditor: ThiiGridEditorItem;
    procedure SetEditors(AValue: ThiiVclGridEditors);
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

    FHorizontalOffset: Integer;
    FVerticalOffset: Integer;
    FVisibleColumns: TArray<ThiiVisibleColumnInfo>;
    FAllColumns: TArray<ThiiVisibleColumnInfo>;
    FVisibleRows: TArray<ThiiVisibleRowInfo>;
    FCellPool: TObjectList<ThiiVclVisualCell>;
    FRowMetrics: Th5uGridRowMetrics;
    FPerformance: ThiiGridPerformance;
    FUpdatingScrollBars: Boolean;
    FInitialized: Boolean;

    FMouseDownHit: ThiiHitTestInfo;
    FSelectingRange, FSelectionDragging, FMouseEditPending: Boolean;
    FSelectionDragKind: ThiiSelectionKind;
    FSelectionDragShift: TShiftState;
    FSelectionDragOrigin: TPoint;
    FSelectionDragLast: ThiiCellAddress;
    FMovingColumns: TArray<ThiiGridColumn>;
    FMovingRowKeys: TArray<ThiiRowKey>;
    FMovingFirstRowIndex: Int64;
    FMoveDragging: Boolean;
    FMovePoint: TPoint;
    FMoveCaption: string;
    FMovingHeaderCell: ThiiHeaderLayoutCell;
    FMovePreviewWidth: Integer;
    FMoveTouch: Boolean;
    FMoveCursor: TCursor;
    FOnRowsMoved: ThiiRowsMovedEvent;
    FResizingColumn: ThiiGridColumn;
    FResizeStartX: Integer;
    FResizeOriginalWidth: Integer;
    FResizeHasMoved: Boolean;
    FResizeCursorActive: Boolean;
    FResizeCursor: TCursor;

    FOnGetRowHeight: ThiiGetRowHeightEvent;
    FOnGetRowSpacing: ThiiGetRowSpacingEvent;
    FOnGetThumbHint: ThiiGetThumbHintEvent;
    FOnGetRowAppearance: ThiiRowAppearanceEvent;
    FOnGetCellAppearance: ThiiCellAppearanceEvent;
    FOnAfterDraw: ThiiVclAfterDrawEvent;
    FOnPrepareElement: ThiiVclPrepareElementEvent;
    FOnCustomDraw: ThiiVclCustomDrawEvent;
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
    procedure BeginSelectionDrag(AKind: ThiiSelectionKind; X, Y: Integer; AShift: TShiftState);
    procedure UpdateSelectionDrag(X, Y: Integer);
    procedure EndSelectionDrag;
    function ColumnResizeAt(X, Y: Integer; ATouch: Boolean): ThiiGridColumn;
    function AutoSizeColumnsAt(X, Y: Integer): Boolean;
    function IsResizeHeaderEdge(AX, AY: Single): Boolean;
    function BeginColumnResize(X, Y: Integer; ATouch: Boolean): Boolean;
    procedure UpdateColumnResize(X: Integer);
    procedure SetResizeCursor(AActive: Boolean);
    procedure SelectRightClickCell(const AHit: ThiiHitTestInfo);
    function IsRowMoveGesture(AShift: TShiftState): Boolean;
    function GetHeaderCellBounds(ACell: ThiiHeaderLayoutCell): TRect;
    function GetHeaderCellViewport(ACell: ThiiHeaderLayoutCell): TRect;
    function HeaderCellAtPoint(X, Y: Integer): ThiiHeaderLayoutCell;
    function BeginColumnMove(AColumnIndex: Integer; X, Y: Integer): Boolean;
    function BeginRowMove(ARowIndex: Int64; X, Y: Integer): Boolean;
    procedure UpdateHeaderMove(X, Y: Integer);
    function FinishHeaderMove(X, Y: Integer): Boolean;
    function GetColumnMoveHeaderBounds(const AInfo: ThiiVisibleColumnInfo): TRect;
    function ColumnMoveTarget(X, Y: Integer; out ANewIndex, AMarkerX, AMarkerTop: Integer): Boolean;
    function CanMoveColumn(AColumn: ThiiGridColumn): Boolean;
    function IsColumnMoveGesture(AColumn: ThiiGridColumn; AShift: TShiftState): Boolean;
    procedure SelectHeaderRange(AKind: ThiiSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
    procedure SelectionChanged(Sender: TObject);
    procedure SetColumns(const AValue: ThiiGridColumns);
    procedure SetHeaderLayout(const AValue: ThiiHeaderLayout);
    procedure SetDataController(const AValue: ThiiCustomDataController);
    procedure SetSharedClassFactory(const AValue: ThiiClassFactory);
    procedure SetTheme(const AValue: ThiiGridTheme);
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
    procedure SetGridLines(const AValue: Boolean);
    procedure SetHeaderRowHeight(const AValue: Integer);
    procedure SetRowIndicatorWidth(const AValue: Integer);

    function GetOnGetClass: ThiiGetClassEvent;
    procedure SetOnGetClass(const AValue: ThiiGetClassEvent);
    function GetOnCreateInstance: ThiiCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
    function GetOnConfigureInstance: ThiiConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);

    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    function GetColumnViewportRect(AColumn: ThiiGridColumn): TRect;
    function GetVisibleCellBounds(AColumn: ThiiGridColumn; const AColumnBounds, ARowBounds: TRect): TRect;
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function GetUnpaddedViewportRect: TRect;
    function GetViewportRect: TRect;
    function GetHeaderHeight: Integer;
    function GetDataViewportRect: TRect;
    function GetTotalColumnWidth: Integer;
    function GetIndicatorRightSpacing: Integer;
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
    function GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): Integer;
    function GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out AElementKind: ThiiElementKind; out AColor: TColor; out AStyleName: string;
      out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Integer;
    function GetGridLines: Boolean;
    function ResolveColor(const AColor: TColor; AFallback: TColor): TColor;
    function ResolveDefaultCellColor: TColor;
    function ResolveRowSpacingColor: TColor;
    function ResolveColumnSpacingColor: TColor;
    function ResolveContentPaddingColor: TColor;
    function ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TColor;
    function ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TColor;
    function GetEstimatedTotalRowHeight(AAllowMeasure: Boolean = True): Int64;
    procedure PrepareRowMetrics;
    function BeginPerformanceTiming: Int64;
    procedure EndPerformanceTiming(AStage: ThiiGridPerformanceStage; AStarted: Int64);
    function CanUpdateLayout: Boolean;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure UpdateActiveEditorBounds;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: ThiiFactoryContext; ADefaultClass: ThiiVclVisualCellClass): ThiiVclVisualCell;

    procedure DrawContentPadding;
    procedure DrawHeaders;
    procedure DrawColumnMoveFeedback;
    procedure DrawRows;
    procedure DrawSpacingRect(const ABounds: TRect; AElementKind: ThiiElementKind; AColumn: ThiiGridColumn; AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AColor: TColor;
      const AStyleName: string = ''; ATreeLevel: Integer = -1; AClosedTreeLevels: Integer = 0);
    procedure DrawDefaultHeaders;
    procedure DrawCustomHeaderLayout;
    procedure DrawRowIndicator(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);
    function GetAdjacentGroupGlyphRect(const ARowInfo: ThiiVisibleRowInfo): TRect;
    procedure DrawAdjacentGroupGlyph(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);

    function GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AAllowMeasure: Boolean = True): Integer;
    function MeasureCellHeight(AViewRowIndex: Int64; AColumn: ThiiGridColumn): Integer;
    function FindFirstVisibleRow(AOffset: Int64; out ATop: Integer): Int64;
    function GetRowStyle(AViewRowIndex: Int64; out AStyleKey: TValue): string;
    function ResolveRowAppearance(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; const AStyleName: string): ThiiResolvedAppearance;
    function ResolveCellAppearance(const AContext: ThiiFactoryContext; AColumn: ThiiGridColumn; const ARowAppearance: ThiiResolvedAppearance;
      ASelected, AFocused: Boolean): ThiiResolvedAppearance;

    function ColumnInfoAtPoint(X, Y: Integer; out AInfo: ThiiVisibleColumnInfo): Boolean;
    function RowInfoAtPoint(X, Y: Integer; out AInfo: ThiiVisibleRowInfo): Boolean;

    procedure ShowThumbHint(AAxis: ThiiScrollAxis; ATrigger: ThiiScrollHintTrigger);
    procedure HideThumbHint;
    function BuildThumbHintText(AAxis: ThiiScrollAxis; ATrigger: ThiiScrollHintTrigger; out AContext: ThiiThumbHintContext): string;

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
    procedure PrepareGridCanvas(const ABounds: TRect; AKind: ThiiElementKind);
    procedure CommitEditor;
    procedure CancelEditor;

    procedure ShowColumnChooser;
    procedure ColumnChooserClick(Sender: TObject);
    procedure RebuildAfterLayoutChange;

    function GetVisualCellClass(const AContext: ThiiFactoryContext; ADefaultClass: ThiiVclVisualCellClass): ThiiVclVisualCellClass; virtual;

    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: ThiiVclDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean);
  protected
    function IsDesignerColumnHit(const AHit: ThiiHitTestInfo): Boolean;
    function DesignWndProc(var Message: TMessage): Boolean; override;
    procedure SelectDesignerColumn(AColumn: ThiiGridColumn); virtual;
    procedure DesignerColumnsModified; virtual;
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    procedure DoExit; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMCursorChanged(var Message: TMessage); message CM_CURSORCHANGED;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure DefineProperties(AFiler: TFiler); override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;

    function GetDataCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass; virtual;
    function GetHeaderCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass; virtual;
    function GetFixedCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass; virtual;
  public
    function GetCellEditor(AColumn: ThiiGridColumn; ARow: Int64): ThiiGridEditorItem;
    procedure ClearEditorCache;
    property ActiveEditor: ThiiGridEditorItem read FActiveEditor;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateRowHeight(const ARowKey: ThiiRowKey);
    procedure InvalidateVisibleRowHeights;
    procedure InvalidateAllRowHeights;

    function HitTest(X, Y: Integer): ThiiHitTestInfo;
    procedure MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
    procedure SetColumnVisible(AColumn: ThiiGridColumn; AVisible: Boolean);
    function MeasureColumnWidth(AColumn: ThiiGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1): Integer;
    procedure AutoSizeColumn(AColumn: ThiiGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1);
    procedure InvalidateColumnWidths;
    procedure AutoCreateColumnsFromDataset(AClearExisting: Boolean = True);
    procedure ToggleAdjacentGroup(AViewRowIndex: Int64);
    procedure SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
    procedure ExpandAllAdjacentGroups;
    procedure CollapseAllAdjacentGroups;
    procedure ResetAdjacentGroupStates;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;

    property FactoryScope: ThiiFactoryScope read FFactoryScope;
    property Performance: ThiiGridPerformance read FPerformance;
    property HorizontalOffset: Integer read FHorizontalOffset;
    property VerticalOffset: Integer read FVerticalOffset;
  protected
    property DataController: ThiiCustomDataController read FDataController write SetDataController;
    property SharedClassFactory: ThiiClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Editors: ThiiVclGridEditors read FEditors write SetEditors;
    property DefaultEditors: ThiiDefaultEditors read FDefaultEditors write SetDefaultEditors;
    // Limits for the combined column content, not the control itself. Zero disables a limit.
    property MinWidth: Integer read GetMinWidth write SetMinWidth stored False;
    property MaxWidth: Integer read GetMaxWidth write SetMaxWidth stored False;
    property AutoWidthRowLimit: Integer read GetAutoWidthRowLimit write SetAutoWidthRowLimit stored False;
    property Columns: ThiiGridColumns read FColumns write SetColumns;
    property HeaderLayout: ThiiHeaderLayout read FHeaderLayout write SetHeaderLayout stored False;
    property ColumnSizing: ThiiColumnSizingOptions read FColumnSizing write SetColumnSizing;
    property Header: ThiiGridHeaderOptions read FHeader write SetHeader;
    property RowIndicator: ThiiRowIndicatorOptions read FRowIndicator write SetRowIndicator;
    property Editing: ThiiEditingOptions read FEditing write SetEditing;
    property Selection: ThiiGridSelection read FSelection write SetSelection;
    property RowHeight: ThiiRowHeightOptions read FRowHeight write SetRowHeight;
    property Scrolling: ThiiScrollingOptions read FScrolling write SetScrolling;
    property ScrollHints: ThiiScrollHintOptions read FScrollHints write SetScrollHints;
    property RowStyles: ThiiRowStyleOptions read FRowStyles write SetRowStyles;
    property Customization: ThiiCustomizationOptions read FCustomization write SetCustomization;
    property Spacing: ThiiGridSpacingOptions read FSpacing write SetSpacing;
    property Appearance: ThiiGridAppearanceOptions read FAppearance write SetAppearance;
    property AdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions read FAdjacentGroupFolding write SetAdjacentGroupFolding;
    property Tree: ThiiTreeOptions read FTree write SetTree;

    property Theme: ThiiGridTheme read GetTheme write SetTheme stored False;
    property HeaderRowHeight: Integer read GetHeaderRowHeight write SetHeaderRowHeight stored False;
    property RowIndicatorWidth: Integer read GetRowIndicatorWidth write SetRowIndicatorWidth stored False;
    property ShowHeader: Boolean read GetShowHeader write SetShowHeader stored False;
    property ShowRowIndicator: Boolean read GetShowRowIndicator write SetShowRowIndicator stored False;
    property AllowEditing: Boolean read GetAllowEditing write SetAllowEditing stored False;
    property ImmediateEdit: Boolean read GetImmediateEdit write SetImmediateEdit stored False;
    property GridLines: Boolean read GetGridLines write SetGridLines default True;

    property OnGetClass: ThiiGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: ThiiGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: ThiiGetRowSpacingEvent read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: ThiiGetThumbHintEvent read FOnGetThumbHint write FOnGetThumbHint;
    property OnGetRowAppearance: ThiiRowAppearanceEvent read FOnGetRowAppearance write FOnGetRowAppearance;
    property OnGetCellAppearance: ThiiCellAppearanceEvent read FOnGetCellAppearance write FOnGetCellAppearance;
    property OnAfterDraw: ThiiVclAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;
    property OnPrepareElement: ThiiVclPrepareElementEvent read FOnPrepareElement write FOnPrepareElement;
    property OnCustomDraw: ThiiVclCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
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
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

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
    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property Selection;
    property RowHeight;
    property Scrolling;
    property ScrollHints;
    property RowStyles;
    property Customization;
    property Spacing;
    property Appearance;
    property AdjacentGroupFolding;
    property Tree;

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

    property OnGetClass;
    property OnCreateInstance;
    property OnConfigureInstance;
    property OnGetRowHeight;
    property OnGetRowSpacing;
    property OnGetThumbHint;
    property OnGetRowAppearance;
    property OnGetCellAppearance;
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
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

type
  Th5uVclDesignerColumnSelect = procedure(AGrid: ThiiCustomGrid; AColumn: ThiiGridColumn);

var
  h5uVclDesignerColumnSelect: Th5uVclDesignerColumnSelect;

implementation

type
  Th5uVclDesignScrollBar = class(TScrollBar)
  private
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
  end;

  Th5uAccessGridColumn = class(ThiiGridColumn);

procedure Th5uVclDesignScrollBar.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
  if Visible and Enabled and ClientRect.Contains(SmallPointToPoint(Message.Pos)) then
    Message.Result := 1
  else
    inherited;
end;

procedure ThiiCustomGrid.CMDesignHitTest(var Message: TCMDesignHitTest);
var
  Point: TPoint;
  Hit: ThiiHitTestInfo;
begin
  Point := SmallPointToPoint(Message.Pos);
  if (csDesigning in ComponentState) and CanUpdateLayout then
  begin
    Hit := HitTest(Point.X, Point.Y);
    if (Length(FMovingColumns) = 0) and not Assigned(FResizingColumn) then
      SetResizeCursor(FHeader.Visible and Assigned(ColumnResizeAt(Point.X, Point.Y, False)));
    if IsDesignerColumnHit(Hit) or (Length(FMovingColumns) > 0) or Assigned(FResizingColumn)
      or (FHeader.Visible and Assigned(ColumnResizeAt(Point.X, Point.Y, False))) then
    begin
      Message.Result := 1;
      Exit;
    end;
    if not FHeader.Visible and (Hit.Kind = ThiiHitKind.DataCell) and Assigned(h5uObserveDesignColumnClick) then
      h5uObserveDesignColumnClick(Self, Hit.Column, SelectDesignerColumn);
  end;
  // Only the internal scrollbars opt out of the designer's normal selection handling.
  if (Assigned(FHScrollBar) and FHScrollBar.Visible and FHScrollBar.Enabled and FHScrollBar.BoundsRect.Contains(Point))
    or (Assigned(FVScrollBar) and FVScrollBar.Visible and FVScrollBar.Enabled and FVScrollBar.BoundsRect.Contains(Point)) then
    Message.Result := 1
  else
    inherited;
end;

{ Utilities }

function h5uRectIntersects(const A, B: TRect): Boolean;
begin
  Result := (A.Right > B.Left) and (A.Left < B.Right) and (A.Bottom > B.Top) and (A.Top < B.Bottom);
end;

function h5uClampInt64ToInteger(const AValue: Int64): Integer;
begin
  if AValue > MaxInt - 1 then
    Result := MaxInt - 1
  else if AValue < 0 then
    Result := 0
  else
    Result := AValue;
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

{ ThiiVclVisualCell }

procedure ThiiVclVisualCell.BindCell(const AContext: ThiiFactoryContext; const ABounds: TRect; const AValue: TValue; const ADisplayText: string;
  const AAppearance: ThiiResolvedAppearance);
begin
  FContext := AContext;
  FBounds := ABounds;
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

function ThiiVclVisualCell.EffectiveBackground(AGrid: ThiiCustomGrid): TColor;
var
  LPalette: ThiiVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasBackground then
    Result := FAppearance.Background
  else
    Result := AGrid.ResolveDefaultCellColor;
end;

function ThiiVclVisualCell.EffectiveForeground(AGrid: ThiiCustomGrid): TColor;
var
  LPalette: ThiiVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasForeground then
    Result := FAppearance.Foreground
  else
    Result := LPalette.CellText;
end;

procedure ThiiVclVisualCell.PrepareCanvas(AGrid: ThiiCustomGrid; ACanvas: TCanvas; APart: ThiiElementPaintPart);
var
  LContext: ThiiVclDrawContext;
begin
  if not Assigned(AGrid.FOnPrepareElement) then
    Exit;
  LContext.FactoryContext := Context;
  LContext.Bounds := Bounds;
  LContext.DisplayText := DisplayText;
  LContext.Appearance := Appearance;
  AGrid.FOnPrepareElement(AGrid, Self, ACanvas, LContext, APart);
end;

procedure ThiiCustomGrid.PrepareGridCanvas(const ABounds: TRect; AKind: ThiiElementKind);
var
  LContext: ThiiVclDrawContext;
begin
  if not Assigned(FOnPrepareElement) then
    Exit;
  LContext := Default(ThiiVclDrawContext);
  LContext.FactoryContext := ThiiFactoryContext.Create(Self, Self, FDataController, '', AKind);
  LContext.FactoryContext.ViewRowIndex := -1;
  LContext.Bounds := ABounds;
  FOnPrepareElement(Self, Self, Canvas, LContext, ThiiElementPaintPart.Background);
end;

procedure ThiiVclVisualCell.Paint(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LDrawContext: ThiiVclDrawContext;
  LDrawDefault: Boolean;
  LBrush: TBrush;
  LPen: TPen;
  LFont: TFont;
begin
  LBrush := nil; LPen := nil; LFont := nil;
  try
    if Assigned(AGrid.FOnPrepareElement) then
    begin
      LBrush := TBrush.Create; LBrush.Assign(ACanvas.Brush);
      LPen   := TPen.Create;   LPen.Assign(ACanvas.Pen);
      LFont  := TFont.Create;  LFont.Assign(ACanvas.Font);
    end;
    LDrawContext.FactoryContext := FContext;
    LDrawContext.Bounds := FBounds;
    LDrawContext.DisplayText := FDisplayText;
    LDrawContext.Appearance := FAppearance;

    LDrawDefault := True;
    AGrid.DoCustomDraw(ACanvas, LDrawContext, ThiiCustomDrawStage.BeforeDefault, LDrawDefault);

    if LDrawDefault then
      PaintDefault(AGrid, ACanvas);

    AGrid.DoCustomDraw(ACanvas, LDrawContext, ThiiCustomDrawStage.AfterDefault, LDrawDefault);
  finally
    if Assigned(LBrush) then ACanvas.Brush.Assign(LBrush);
    if Assigned(LPen)  then  ACanvas.Pen.Assign(LPen);
    if Assigned(LFont) then  ACanvas.Font.Assign(LFont);
    LFont.Free; LPen.Free; LBrush.Free;
  end;
end;

procedure ThiiVclVisualCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
begin
  // Separators are independent layout elements. Painting them around every
  // cell would double their width and would make per-column spacing impossible.
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(FBounds);
end;

{ Th5uVclSpacingCell }

procedure Th5uVclSpacingCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := Appearance.Background;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(Bounds);
end;

{ Th5uVclAdjacentGroupGlyphCell }

procedure Th5uVclAdjacentGroupGlyphCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LPalette: ThiiVclPalette;
  LRect: TRect;
  LMidX: Integer;
  LMidY: Integer;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  LRect := Bounds;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
  ACanvas.FillRect(LRect);

  InflateRect(LRect, -1, -1);
  if (LRect.Width < 7) or (LRect.Height < 7) then
    Exit;

  ACanvas.Brush.Color := LPalette.CellBackground;
  ACanvas.Pen.Color := LPalette.CellText;
  ACanvas.Pen.Width := 1;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Glyph);
  ACanvas.Rectangle(LRect);

  LMidX := (LRect.Left + LRect.Right) div 2;
  LMidY := (LRect.Top + LRect.Bottom) div 2;
  ACanvas.MoveTo(LRect.Left + 2, LMidY);
  ACanvas.LineTo(LRect.Right - 2, LMidY);
  if Context.AdjacentGroupCollapsed then
  begin
    ACanvas.MoveTo(LMidX, LRect.Top + 2);
    ACanvas.LineTo(LMidX, LRect.Bottom - 2);
  end;
end;

destructor ThiiVclDataCell.Destroy;
begin
  FPicture.Free;
  inherited;
end;

procedure ThiiVclDataCell.EnsurePicture;
var
  LBytes: TBytes;
  LStream: TBytesStream;
  LSignature: Integer;
begin
  if not Value.IsType<TBytes> then
  begin
    FreeAndNil(FPicture);
    FPictureSignature := 0;
    Exit;
  end;

  LBytes := Value.AsType<TBytes>;
  LSignature := Length(LBytes);
  if Length(LBytes) > 0 then
    LSignature := LSignature xor LBytes[0] xor (Integer(LBytes[High(LBytes)]) shl 8);

  if Assigned(FPicture) and (FPictureSignature = LSignature) then
    Exit;

  FreeAndNil(FPicture);
  FPictureSignature := LSignature;
  if Length(LBytes) = 0 then
    Exit;

  FPicture := TPicture.Create;
  LStream := TBytesStream.Create(LBytes);
  try
    try
      FPicture.LoadFromStream(LStream);
    except
      FreeAndNil(FPicture);
    end;
  finally
    LStream.Free;
  end;
end;

procedure ThiiVclDataCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LEditor: ThiiGridEditorItem;
  LEditorContext: ThiiEditorContext;
  LHandled: Boolean;
  LColumn: ThiiGridColumn;
  LTextRect: TRect;
  LFlags: Cardinal;
  LRow: ThiiVisibleRowInfo;
  LGlyph: TRect;
  LPalette: ThiiVclPalette;
begin
  inherited;
  if Context.ElementKind = ThiiElementKind.RowHeaderCell then
  begin
    LRow.RowIndex := Context.ViewRowIndex;
    LRow.RowKey := Context.RowKey;
    LRow.Bounds := Bounds;
    LGlyph := AGrid.GetAdjacentGroupGlyphRect(LRow);
    LTextRect := Bounds;
    InflateRect(LTextRect, -2, 0);
    LFlags := DT_NOPREFIX or DT_VCENTER or DT_SINGLELINE;
    if not LGlyph.IsEmpty then
    begin
      LTextRect.Left := Max(LTextRect.Left, LGlyph.Right + 2);
      LFlags := LFlags or DT_RIGHT;
    end
    else
      LFlags := LFlags or DT_CENTER;
    ACanvas.Font.Assign(AGrid.Font);
    ACanvas.Font.Color := EffectiveForeground(AGrid);
    ACanvas.Brush.Style := bsClear;
    PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Text);
    if LTextRect.Width > 0 then
      DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect, LFlags);
    ACanvas.Brush.Style := bsSolid;
    Exit;
  end;
  if not (Context.Column is ThiiGridColumn) then
    Exit;

  LColumn := ThiiGridColumn(Context.Column);
  LPalette := h5uGetVclPalette(AGrid.Theme);
  ACanvas.Font.Assign(AGrid.Font);
  ACanvas.Font.Color := EffectiveForeground(AGrid);
  ACanvas.Font.Style := Appearance.FontStyle;
  ACanvas.Brush.Style := bsClear;

  LEditor := AGrid.GetCellEditor(LColumn, Context.ViewRowIndex);
  if not Assigned(LEditor) then
    LEditor := AGrid.CachedEditor(AGrid.DefaultEditors.DataTypeEditor(LColumn.DataType));
  LEditorContext := Default(ThiiEditorContext);
  LEditorContext.Grid := AGrid;
  LEditorContext.Column := LColumn;
  LEditorContext.RowIndex := Context.ViewRowIndex;
  LEditorContext.RowKey := Context.RowKey;
  LEditorContext.Bounds := TRectF.Create(Bounds);
  LEditorContext.Value := Value;
  LEditorContext.Text := DisplayText;
  LEditorContext.Canvas := ACanvas;
  LEditorContext.Foreground := TAlphaColor(EffectiveForeground(AGrid));
  LEditorContext.Background := TAlphaColor(EffectiveBackground(AGrid));

  if LEditor is ThiiVclImageCellEditor then
  begin
    EnsurePicture; LEditorContext.Image := FPicture;
  end;
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
    ACanvas.Pen.Color := LPalette.FocusBorder;
    ACanvas.Brush.Style := bsClear;
    PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Border);
    ACanvas.Rectangle(Bounds);
    ACanvas.Brush.Style := bsSolid;
  end;
end;

{ ThiiVclHeaderCell }

procedure ThiiVclHeaderCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LPalette: ThiiVclPalette;
  LTextRect, LSymbolRect: TRect;
  LEdge, LMiddle: Integer;
  LRightVisible: Boolean;
  LSymbols: string;
  LSavedFont: TFont;
  LDetails: TThemedElementDetails;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);

  if (AGrid.Theme = ThiiGridTheme.ApplicationStyle) and StyleServices.Enabled and not Assigned(AGrid.FOnPrepareElement) then
  begin
    LDetails := StyleServices.GetElementDetails(thHeaderItemNormal);
    StyleServices.DrawElement(ACanvas.Handle, LDetails, Bounds);
  end
  else
  begin
    ACanvas.Brush.Color := LPalette.HeaderBackground;
    PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Background);
    ACanvas.FillRect(Bounds);
  end;

  ACanvas.Font.Assign(AGrid.Font);
  ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  ACanvas.Font.Color := LPalette.HeaderText;
  ACanvas.Brush.Style := bsClear;
  LTextRect := Bounds;
  InflateRect(LTextRect, -5, -2);
  LSymbols := AGrid.ColumnModeSymbols(ThiiGridColumn(Context.Column));
  if LSymbols <> '' then
  begin
    LSavedFont := TFont.Create;
    try
      LSavedFont.Assign(ACanvas.Font);
      ACanvas.Font.Color := clMaroon;
      PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.ColumnMode);
      LSymbolRect := LTextRect;
      LSymbolRect.Right := Min(LSymbolRect.Right, LSymbolRect.Left + ACanvas.TextWidth(LSymbols) + 4);
      DrawText(ACanvas.Handle, PChar(LSymbols), Length(LSymbols), LSymbolRect, DT_NOPREFIX or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
      LTextRect.Left := LSymbolRect.Right + 3;
    finally
      ACanvas.Font.Assign(LSavedFont);
      LSavedFont.Free;
    end;
  end;
  PrepareCanvas(AGrid, ACanvas, ThiiElementPaintPart.Text);
  DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect,
    DT_NOPREFIX or DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  ACanvas.Brush.Style := bsSolid;
  if (Context.ElementKind = ThiiElementKind.ColumnHeaderCell) and Assigned(Context.Column)
    and (not (Context.HeaderCell is ThiiHeaderLayoutCell) or (ThiiHeaderLayoutCell(Context.HeaderCell).ColumnSpan = 1))
    and ((csDesigning in AGrid.ComponentState) or AGrid.Header.HighlightInteractive) then
  begin
    LEdge := Max(1, MulDiv(2, AGrid.CurrentPPI, 96));
    LMiddle := (Bounds.Top + Bounds.Bottom) div 2;
    ACanvas.Brush.Color := LPalette.SelectedBackground;
    ACanvas.FillRect(Rect(Bounds.Left + LEdge, Max(Bounds.Top, Bounds.Bottom - 2 * LEdge), Bounds.Right - LEdge, Bounds.Bottom - LEdge));
    if Context.HeaderCell is ThiiHeaderLayoutCell then
      LRightVisible := AGrid.GetHeaderCellBounds(ThiiHeaderLayoutCell(Context.HeaderCell)).Right = Bounds.Right
    else
      LRightVisible := (Context.LayoutColumn >= 0) and (Context.LayoutColumn < Length(AGrid.FAllColumns))
        and (AGrid.FAllColumns[Context.LayoutColumn].Bounds.Right = Bounds.Right);
    if LRightVisible and ThiiGridColumn(Context.Column).CanResize and AGrid.Customization.AllowColumnResizing then
      ACanvas.FillRect(Rect(Bounds.Right - 2 * LEdge, Max(Bounds.Top, LMiddle - 3 * LEdge), Bounds.Right - LEdge,
        Min(Bounds.Bottom, LMiddle + 3 * LEdge)));
  end;
end;

function ThiiCustomGrid.AcquireVisualCell(const AContext: ThiiFactoryContext; ADefaultClass: ThiiVclVisualCellClass): ThiiVclVisualCell;
var
  LClass: ThiiVclVisualCellClass;
  LCell: ThiiVclVisualCell;
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

  Result := ThiiVclVisualCell(FFactoryScope.CreateInstance(LCreateContext, ThiiVclVisualCell, LClass));
  Result.FInUse := True;
  FCellPool.Add(Result);
  FFactoryScope.BindInstance(AContext, Result);
end;

procedure ThiiCustomGrid.AutoCreateColumnsFromDataset(AClearExisting: Boolean);
var
  LController: ThiiDatasetController;
  LField: TField;
  LColumn: ThiiGridColumn;
begin
  if not (FDataController is ThiiDatasetController) then
    Exit;

  LController := ThiiDatasetController(FDataController);
  if not Assigned(LController.Dataset) then
    Exit;

  FColumns.BeginUpdate;
  try
    if AClearExisting then
      FColumns.Clear;

    for LField in LController.Dataset.Fields do
    begin
      LColumn := FColumns.Add;
      LColumn.Id := LField.FieldName.ToLowerInvariant;
      LColumn.FieldName := LField.FieldName;
      if LField.DisplayLabel <> '' then
        LColumn.Caption := LField.DisplayLabel
      else
        LColumn.Caption := LField.FieldName;
      LColumn.Width := EnsureRange(LField.DisplayWidth * 8, 60, 280);

      case LField.DataType of
        ftSmallint, ftInteger, ftWord, ftAutoInc, ftShortint, ftByte, ftLargeint:
          LColumn.DataType := ThiiColumnDataType.Integer;

        ftFloat, ftSingle, ftExtended:
          LColumn.DataType := ThiiColumnDataType.Float;

        ftCurrency, ftBCD, ftFMTBcd:
        begin
          LColumn.DataType := ThiiColumnDataType.Currency;
          LColumn.DisplayFormat := '#,##0.00';
        end;

        ftDate:
        begin
          LColumn.DataType := ThiiColumnDataType.Date;
          LColumn.DisplayFormat := 'dd.mm.yyyy';
        end;

        ftTime:
        begin
          LColumn.DataType := ThiiColumnDataType.Time;
          LColumn.DisplayFormat := 'hh:nn:ss';
        end;

        ftDateTime, ftTimeStamp:
        begin
          LColumn.DataType := ThiiColumnDataType.DateTime;
          LColumn.DisplayFormat := 'dd.mm.yyyy hh:nn';
        end;

        ftBoolean: LColumn.DataType := ThiiColumnDataType.Boolean;

        ftBlob, ftGraphic, ftOraBlob:
        begin
          LColumn.DataType := ThiiColumnDataType.Image;
          LColumn.EditorKind := ThiiColumnEditorKind.Image;
          LColumn.Width := 100;
          LColumn.AutoHeight := True;
          LColumn.MaxAutoHeight := 100;
        end;

        ftMemo, ftWideMemo:
        begin
          LColumn.DataType := ThiiColumnDataType.Text;
          LColumn.WordWrap := True;
          LColumn.AutoHeight := True;
          LColumn.Width := 240;
        end;

        else
          LColumn.DataType := ThiiColumnDataType.Text;
      end;
    end;
  finally
    FColumns.EndUpdate;
  end;
  RebuildAfterLayoutChange;
end;

procedure ThiiCustomGrid.BeginVisualPass;
var
  LCell: ThiiVclVisualCell;
begin
  for LCell in FCellPool do
    if LCell.FInUse then
    begin
      FFactoryScope.UnbindInstance(LCell.Context, LCell);
      LCell.FInUse := False;
    end;
end;

function ThiiCustomGrid.BuildThumbHintText(AAxis: ThiiScrollAxis; ATrigger: ThiiScrollHintTrigger; out AContext: ThiiThumbHintContext): string;
var
  LTop: Integer;
  LRowIndex: Int64;
  LColumn: ThiiGridColumn;
  LInfo: ThiiVisibleColumnInfo;
  LColumns: TArray<ThiiGridColumn>;
begin
  AContext := Default(ThiiThumbHintContext);
  AContext.Grid := Self;
  AContext.DataController := FDataController;
  AContext.Axis := AAxis;
  AContext.Trigger := ATrigger;
  AContext.IsEstimated := False;

  Result := '';
  if AAxis = ThiiScrollAxis.Vertical then
  begin
    if not Assigned(FDataController) or (GetViewRowCount = 0) then
      Exit;

    LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
    if LRowIndex < 0 then
      Exit;

    AContext.ScrollOffset := FVerticalOffset;
    AContext.ScrollRange := FVScrollBar.Max;
    AContext.ViewRowIndex := LRowIndex;
    AContext.RowKey := GetViewRowKey(LRowIndex);

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
      AContext.Value := GetViewValue(LRowIndex, LColumn.FieldName);
      AContext.DisplayText := GetViewDisplayText(LRowIndex, LColumn.FieldName, LColumn.DisplayFormat);
      AContext.IsValueAvailable := not AContext.Value.IsEmpty;
      Result := AContext.DisplayText;
    end;

    if FScrollHints.ShowRowPosition then
    begin
      if Result <> '' then
        Result := Result + ' — ';
      Result := Result + Format('Zeile %d von %d', [LRowIndex + 1, GetViewRowCount]);
    end;
  end
  else
  begin
    AContext.ScrollOffset := FHorizontalOffset;
    AContext.ScrollRange := FHScrollBar.Max;
    LColumn := nil;
    for LInfo in FAllColumns do
      if (LInfo.Column.FixedKind = ThiiFixedKind.None) and (LInfo.Bounds.Right > GetDataViewportRect.Left) then
      begin
        LColumn := LInfo.Column;
        Break;
      end;

    AContext.Column := LColumn;
    if Assigned(LColumn) then
    begin
      if LColumn.ScrollHintText <> '' then
        Result := LColumn.ScrollHintText
      else
        Result := LColumn.Caption;
      AContext.DisplayText := Result;
    end;
  end;
end;

function ThiiCustomGrid.GetTheme: ThiiGridTheme;
begin
  Result := FAppearance.Theme;
end;

function ThiiCustomGrid.GetHeaderRowHeight: Integer;
begin
  Result := Round(FHeader.RowHeight);
end;

function ThiiCustomGrid.GetRowIndicatorWidth: Integer;
begin
  Result := Round(FRowIndicator.Width);
end;

function ThiiCustomGrid.GetShowHeader: Boolean;
begin
  Result := FHeader.Visible;
end;

function ThiiCustomGrid.GetShowRowIndicator: Boolean;
begin
  Result := FRowIndicator.Visible;
end;

function ThiiCustomGrid.GetAllowEditing: Boolean;
begin
  Result := FEditing.AllowEditing;
end;

function ThiiCustomGrid.GetImmediateEdit: Boolean;
begin
  Result := FEditing.ImmediateEdit;
end;

function ThiiCustomGrid.GetMinWidth: Integer;
begin
  Result := Round(FColumnSizing.MinContentWidth);
end;

function ThiiCustomGrid.GetMaxWidth: Integer;
begin
  Result := Round(FColumnSizing.MaxContentWidth);
end;

function ThiiCustomGrid.GetAutoWidthRowLimit: Integer;
begin
  Result := FColumnSizing.AutoWidthRowLimit;
end;

procedure ThiiCustomGrid.SetShowHeader(AValue: Boolean);
begin
  FHeader.Visible := AValue;
end;

procedure ThiiCustomGrid.SetShowRowIndicator(AValue: Boolean);
begin
  FRowIndicator.Visible := AValue;
end;

procedure ThiiCustomGrid.SetAllowEditing(AValue: Boolean);
begin
  FEditing.AllowEditing := AValue;
end;

procedure ThiiCustomGrid.SetImmediateEdit(AValue: Boolean);
begin
  FEditing.ImmediateEdit := AValue;
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
  Invalidate;
end;

procedure ThiiCustomGrid.EditingChanged(Sender: TObject);
begin
  if FInitialized and not FEditing.AllowEditing then
    CancelEditor;
end;

procedure ThiiCustomGrid.AppearanceChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure ThiiCustomGrid.ThemeChanged(Sender: TObject);
begin
  if not FInitialized then
    Exit;
  Color := h5uGetVclPalette(FAppearance.Theme).GridBackground;
  FAutoWidthsDirty := True;
  InvalidateAllRowHeights;
  Invalidate;
end;

procedure ThiiCustomGrid.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('SizingVersion', ReadSizingVersion, WriteSizingVersion, True);
end;

procedure ThiiCustomGrid.ReadSizingVersion(AReader: TReader);
begin
  FHasSizingVersion := AReader.ReadInteger > 0;
end;

procedure ThiiCustomGrid.WriteSizingVersion(AWriter: TWriter);
begin
  AWriter.WriteInteger(1);
end;

function ThiiCustomGrid.MonitorWorkAreaWidth: Single;
var
  LMonitor: TMonitor;
begin
  if HandleAllocated then
    LMonitor := Screen.MonitorFromWindow(Handle, mdNearest)
  else
    LMonitor := Screen.PrimaryMonitor;
  if Assigned(LMonitor) then
    Result := LMonitor.WorkareaRect.Width
  else
    Result := 3000;
end;

procedure ThiiCustomGrid.PrepareColumnWidthDefaults(AReferenceWidth: Single);
var
  LColumn: ThiiGridColumn;
  LMonitorWidth: Single;
begin
  LMonitorWidth := MonitorWorkAreaWidth;
  for LColumn in FColumns.VisibleColumns do
    h5uResolveColumnWidthDefaults(LColumn, FColumnSizing, FEditors, FDefaultEditors, AReferenceWidth, LMonitorWidth);
end;

procedure ThiiCustomGrid.SetMinWidth(const AValue: Integer);
begin
  FColumnSizing.MinContentWidth := AValue;
end;

procedure ThiiCustomGrid.SetMaxWidth(const AValue: Integer);
begin
  FColumnSizing.MaxContentWidth := AValue;
end;

procedure ThiiCustomGrid.SetAutoWidthRowLimit(const AValue: Integer);
begin
  FColumnSizing.AutoWidthRowLimit := AValue;
end;

procedure ThiiCustomGrid.InvalidateColumnWidths;
begin
  FAutoWidthsDirty := True;
  Invalidate;
end;

procedure ThiiCustomGrid.AutoSizeColumn(AColumn: ThiiGridColumn; AFirstRow, ARowCount: Int64);
var
  LWidth: Integer;
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
    if LColumn.AutoWidth then
      LConstraints := LConstraints + LColumn.Id + ':' + FloatToStr(LColumn.ResolvedMinWidth) + ':' + FloatToStr(LColumn.ResolvedMaxWidth) + ';';
  if LConstraints <> FAutoWidthConstraints then
    FAutoWidthsDirty := True;
  LFont := Font.Name + ':' + IntToStr(Font.Height) + ':' + IntToStr(Byte(Font.Style));
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
  FAutoWidthConstraints := LConstraints;
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
  PrepareColumnWidthDefaults(Max(0, AAvailableWidth - IndicatorExtent));
  h5uResolveColumnWidths(FColumns, FHeaderLayout, FSpacing.DefaultColumnRightSpacing, AAvailableWidth - IndicatorExtent,
    FColumnSizing.MinContentWidth, FColumnSizing.MaxContentWidth, FColumnSizing.FitMode);
end;

function ThiiCustomGrid.MeasureColumnWidth(AColumn: ThiiGridColumn; AFirstRow, ARowCount: Int64): Integer;
var
  LBitmap: TBitmap;
  LContext: ThiiEditorContext;
  LEditor: ThiiGridEditorItem;
  LRow, LCount, LEnd: Int64;
  LWidth: Single;
  LFactoryContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LStyleKey: TValue;
begin
  if not Assigned(AColumn) or (AColumn.Collection <> FColumns) then
    raise EArgumentException.Create('Die Spalte gehört nicht zu diesem Grid.');
  if not FMeasuringAutoWidths then
  begin
    ResolveColumnWidths(GetViewportRect.Width);
    if not AColumn.Visible then
      h5uResolveColumnWidthDefaults(AColumn, FColumnSizing, FEditors, FDefaultEditors, Max(0.0, GetViewportRect.Width - IndicatorExtent),
        MonitorWorkAreaWidth);
  end;
  Result := Round(AColumn.ResolvedMinWidth);
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
    LBitmap.Canvas.Font.Assign(Font);
    LContext := Default(ThiiEditorContext);
    LContext.Grid := Self;
    LContext.Column := AColumn;
    LContext.Canvas := LBitmap.Canvas;
    LContext.Bounds := RectF(0, 0, AColumn.LayoutWidth, Round(FRowHeight.EstimatedHeight));
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
          LFactoryContext := ThiiFactoryContext.Create(Self, Self, FDataController, AColumn.CellClassId, ThiiElementKind.DataCell);
          LFactoryContext.Column := AColumn;
          LFactoryContext.ViewRowIndex := LRow;
          LFactoryContext.RowKey := LContext.RowKey;
          LFactoryContext.SourceRowIndex := GetViewSourceRowIndex(LRow);
          LAppearance := ResolveRowAppearance(LRow, LContext.RowKey, GetRowStyle(LRow, LStyleKey));
          LFactoryContext.RowStyleKey := LStyleKey;
          LAppearance := ResolveCellAppearance(LFactoryContext, AColumn, LAppearance, False, False);
          LBitmap.Canvas.Font.Assign(Font);
          LBitmap.Canvas.Font.Style := LAppearance.FontStyle;
          LContext.Value := GetCellValue(AColumn, LRow, True);
          LContext.Text := GetCellText(AColumn, LRow, True);
          LEditor := GetCellEditor(AColumn, LRow);
          if not Assigned(LEditor) then
            LEditor := CachedEditor(FDefaultEditors.DataTypeEditor(AColumn.DataType));
          LWidth := LEditor.MeasureWidth(LContext);
          if LWidth < 0 then
            LWidth := CachedEditor('TextEditor').MeasureWidth(LContext);
          if not IsNan(LWidth) and not IsInfinite(LWidth) then
            Result := Max(Result, Round(AColumn.ConstrainWidth(Ceil(EnsureRange(LWidth, 0.0, Single(MaxInt div 4))))));
          if Result >= AColumn.ResolvedMaxWidth then
            Exit;
        end;
        Inc(LRow);
        Dec(LCount);
      end;
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
          FActiveEditor.UpdateBounds(TRectF.Create(GetVisibleCellBounds(FEditColumn, LColumn.Bounds, LRow.Bounds)));
          Exit;
        end;
  FActiveEditor.UpdateBounds(TRectF.Empty);
end;

procedure ThiiCustomGrid.BuildColumnLayout;
var
  LLayout: TArray<Th5uColumnLayoutInfo>;
  LView: TRect;
  LSpacingRight: Single;
  I, LVisibleCount: Integer;
  LStarted: Int64;
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
      FAllColumns[I].Bounds := Rect(Round(LLayout[I].Left), LView.Top, Round(LLayout[I].Right), LView.Bottom);
      LSpacingRight := LLayout[I].Left + LLayout[I].Column.LayoutWidth + h5uColumnRightSpacing(LLayout[I].Column, FSpacing.DefaultColumnRightSpacing);
      FAllColumns[I].RightSpacing := Round(LSpacingRight) - FAllColumns[I].Bounds.Right;
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
    Result := RowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
end;

procedure ThiiCustomGrid.CancelEditor;
begin
  FinishEditor(False);
end;

procedure ThiiCustomGrid.ColumnChooserClick(Sender: TObject);
var
  LItem: TMenuItem;
  LColumn: ThiiGridColumn;
begin
  if not (Sender is TMenuItem) then
    Exit;
  LItem := TMenuItem(Sender);
  if (LItem.Tag < 0) or (LItem.Tag >= FColumns.Count) then
    Exit;
  LColumn := FColumns[LItem.Tag];
  SetColumnVisible(LColumn, not LColumn.Visible);
end;

function ThiiCustomGrid.ColumnInfoAtPoint(X, Y: Integer; out AInfo: ThiiVisibleColumnInfo): Boolean;
var
  LInfo: ThiiVisibleColumnInfo;
begin
  for LInfo in FVisibleColumns do
    if PtInRect(LInfo.Bounds, Point(X, Y)) and GetColumnViewportRect(LInfo.Column).Contains(Point(X, Y)) then
    begin
      AInfo := LInfo;
      Exit(True);
    end;
  Result := False;
end;

procedure ThiiCustomGrid.SetShowColumnModes(AValue: Boolean);
begin
  if FShowColumnModes = AValue then
    Exit;
  FShowColumnModes := AValue;
  Invalidate;
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
  RebuildAfterLayoutChange;
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
      Invalidate;
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
  // Our interaction handlers own capture. VCL's automatic release happens before
  // MouseUp and would cancel the pending action through WMCaptureChanged.
  ControlStyle := (ControlStyle + [csOpaque, csDoubleClicks]) - [csCaptureMouse];

  FFactoryScope := ThiiFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FFactoryScope.RegisterClass(h5uClassIdGridDataCell, ThiiVclVisualCell, ThiiVclDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridFixedCell, ThiiVclVisualCell, ThiiVclFixedCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderCell, ThiiVclVisualCell, ThiiVclHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderGroupCell, ThiiVclVisualCell, ThiiVclHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupFoldGlyph, ThiiVclVisualCell, Th5uVclAdjacentGroupGlyphCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupEndBand, ThiiVclVisualCell, Th5uVclSpacingCell);

  FEditors := ThiiVclGridEditors.Create(Self);
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
  FHeader.OnChanged := OptionsChanged;
  FHeaderLayout := FHeader.Layout;
  FRowIndicator := ThiiRowIndicatorOptions.Create;
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
  FCellPool := TObjectList<ThiiVclVisualCell>.Create(True);
  FRowMetrics := Th5uGridRowMetrics.Create;
  FRowMetrics.PixelAligned := True;
  FPerformance := ThiiGridPerformance.Create;

  FEditRowIndex := -1;

  FVScrollBar := Th5uVclDesignScrollBar.Create(Self);
  FVScrollBar.SetSubComponent(True);
  FVScrollBar.Parent := Self;
  FVScrollBar.Kind := sbVertical;
  FVScrollBar.OnScroll := ScrollBarScroll;

  FHScrollBar := Th5uVclDesignScrollBar.Create(Self);
  FHScrollBar.SetSubComponent(True);
  FHScrollBar.Parent := Self;
  FHScrollBar.Kind := sbHorizontal;
  FHScrollBar.OnScroll := ScrollBarScroll;

  FThumbHintTimer := TTimer.Create(Self);
  FThumbHintTimer.SetSubComponent(True);
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Interval := 900;
  FThumbHintTimer.OnTimer := ThumbHintTimer;

  FInitialized := True;
  TabStop := True;
  DoubleBuffered := True;
  SetBounds(Left, Top, 640, 320);
  LayoutScrollBars;
end;

procedure ThiiCustomGrid.DataChanged(Sender: TObject; const AChange: ThiiDataChange);
var
  LStarted: Int64;
begin
  LStarted := BeginPerformanceTiming;
  try
    FAutoWidthsDirty := True;
    // Unknown row changes may reorder positional keys; abandon the pending drop.
    if (Length(FMovingRowKeys) > 0) and (AChange.Kind <> ThiiDataChangeKind.CellChanged) then
      EndSelectionDrag;
    InvalidateAdjacentGroupMap(not FAdjacentGroupFolding.PreserveStateOnDataChange);
    // Live updates must not discard an in-progress draft. Cancel only when the
    // target is no longer the same row; never commit into a replacement row.
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
    Invalidate;
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
  FCellPool.Free;
  FDataLink.Free;
  FTree.Free;
  FSpacing.Free;
  FAppearance.Free;
  FCustomization.Free;
  FRowStyles.Free;
  FScrollHints.Free;
  FScrolling.Free;
  FRowHeight.Free;
  FSelection.Free;
  FEditing.Free;
  FRowIndicator.Free;
  FHeader.Free;
  FColumnSizing.Free;
  FColumns.Free;
  FFactoryScope.Free;
  FPerformance.Free;
  inherited;
end;

procedure ThiiCustomGrid.DoCustomDraw(ACanvas: TCanvas; const AContext: ThiiVclDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, ACanvas, AContext, AStage, ADrawDefault);
end;

function ThiiCustomGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  LDelta: Integer;
begin
  LDelta := FScrolling.WheelRows * (Round(FRowHeight.EstimatedHeight) + Round(FSpacing.RowSpacing));

  if ssShift in Shift then
  begin
    if WheelDelta > 0 then
      Dec(FHorizontalOffset, LDelta)
    else
      Inc(FHorizontalOffset, LDelta);
    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, FHScrollBar.Max);
    FHScrollBar.Position := FHorizontalOffset;
    Invalidate;
    if ThiiScrollHintTrigger.MouseWheel in FScrollHints.Triggers then
      ShowThumbHint(ThiiScrollAxis.Horizontal, ThiiScrollHintTrigger.MouseWheel);
    Exit(True);
  end;

  if WheelDelta > 0 then
    Dec(FVerticalOffset, LDelta)
  else
    Inc(FVerticalOffset, LDelta);

  FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);

  if FScrolling.VerticalMode = ThiiVerticalScrollMode.WholeRows then
  begin
    FindFirstVisibleRow(FVerticalOffset, LDelta);
    FVerticalOffset := EnsureRange(FVerticalOffset + (LDelta - GetDataViewportRect.Top), 0, FVScrollBar.Max);
  end;

  FVScrollBar.Position := FVerticalOffset;
  Invalidate;
  if ThiiScrollHintTrigger.MouseWheel in FScrollHints.Triggers then
    ShowThumbHint(ThiiScrollAxis.Vertical, ThiiScrollHintTrigger.MouseWheel);
  Result := True;
end;

procedure ThiiCustomGrid.DrawCustomHeaderLayout;
var
  I, LFirst, LLast: Integer;
  LCellDef: ThiiHeaderLayoutCell;
  LRect, LDrawRect, LClip, LSeparatorRect: TRect;
  LContext: ThiiFactoryContext;
  LCell: ThiiVclVisualCell;
  LAppearance: ThiiResolvedAppearance;
  LClassId: ThiiClassId;
  LRightSpacing: Integer;
begin
  for I := 0 to FHeaderLayout.Cells.Count - 1 do
  begin
    LCellDef := FHeaderLayout.Cells[I];
    if not FHeaderLayout.ColumnRange(LCellDef, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
      Continue;
    LRect := GetHeaderCellBounds(LCellDef);
    LClip := GetHeaderCellViewport(LCellDef);
    IntersectRect(LDrawRect, LRect, LClip);
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
    LCell := AcquireVisualCell(LContext, ThiiVclHeaderCell);
    LCell.BindCell(LContext, LDrawRect, TValue.Empty, LCellDef.Caption, LAppearance);
    LCell.Paint(Self, Canvas);
    LRightSpacing := FAllColumns[LLast].RightSpacing;
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      IntersectRect(LSeparatorRect, LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, FAllColumns[LLast].Column, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
    if Round(FSpacing.RowSpacing) > 0 then
    begin
      LSeparatorRect := Rect(LRect.Left, LRect.Bottom, LRect.Right + LRightSpacing, LRect.Bottom + Round(FSpacing.RowSpacing));
      IntersectRect(LSeparatorRect, LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.RowSpacing, ThiiGridColumn(LContext.Column), -1, ThiiRowKey.Empty, ResolveRowSpacingColor);
    end;
  end;
end;

procedure ThiiCustomGrid.DrawDefaultHeaders;
var
  LInfo: ThiiVisibleColumnInfo;
  LRect: TRect;
  LDrawRect: TRect;
  LSeparatorRect: TRect;
  LContext: ThiiFactoryContext;
  LCell: ThiiVclVisualCell;
  LAppearance: ThiiResolvedAppearance;
  LClassId: ThiiClassId;
  LRightSpacing: Integer;
begin
  for LInfo in FVisibleColumns do
  begin
    LRect := LInfo.Bounds;
    LRect.Top := GetViewportRect.Top;
    LRect.Bottom := LRect.Top + HeaderRowHeight;

    LDrawRect := LRect;
    IntersectRect(LDrawRect, LDrawRect, GetColumnViewportRect(LInfo.Column));
    if not IsRectEmpty(LDrawRect) then
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
      LCell := AcquireVisualCell(LContext, ThiiVclHeaderCell);
      LCell.BindCell(LContext, LDrawRect, TValue.Empty, LInfo.Column.Caption, LAppearance);
      LCell.Paint(Self, Canvas);
    end;

    // The separator remains visible even if pixel scrolling starts inside it
    // and the corresponding cell itself is already outside the viewport.
    LRightSpacing := LInfo.RightSpacing;
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      IntersectRect(LSeparatorRect, LSeparatorRect, GetColumnViewportRect(LInfo.Column));
      if not IsRectEmpty(LSeparatorRect) then
        DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, LInfo.Column, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;
end;

procedure ThiiCustomGrid.DrawContentPadding;
var
  LOuterRect: TRect;
  LInnerRect: TRect;
  LPaddingRect: TRect;
  LColor: TColor;
begin
  LOuterRect := GetUnpaddedViewportRect;
  LInnerRect := GetViewportRect;
  LColor := ResolveContentPaddingColor;

  if LInnerRect.Top > LOuterRect.Top then
  begin
    LPaddingRect := Rect(LOuterRect.Left, LOuterRect.Top, LOuterRect.Right, LInnerRect.Top);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Bottom < LOuterRect.Bottom then
  begin
    LPaddingRect := Rect(LOuterRect.Left, LInnerRect.Bottom, LOuterRect.Right, LOuterRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Left > LOuterRect.Left then
  begin
    LPaddingRect := Rect(LOuterRect.Left, LInnerRect.Top, LInnerRect.Left, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;

  if LInnerRect.Right < LOuterRect.Right then
  begin
    LPaddingRect := Rect(LInnerRect.Right, LInnerRect.Top, LOuterRect.Right, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, ThiiElementKind.ContentPadding, nil, -1, ThiiRowKey.Empty, LColor);
  end;
end;

procedure ThiiCustomGrid.DrawHeaders;
var
  LRect: TRect;
  LSeparatorRect: TRect;
  LRightSpacing: Integer;
  LHeaderRect: TRect;
  LContext: ThiiFactoryContext;
  LCell: ThiiVclVisualCell;
  LAppearance: ThiiResolvedAppearance;
  LPalette: ThiiVclPalette;
  LContentBottom: Integer;
begin
  if not FHeader.Visible then
    Exit;

  LPalette := h5uGetVclPalette(FAppearance.Theme);
  LHeaderRect := GetViewportRect;
  LHeaderRect.Bottom := LHeaderRect.Top + GetHeaderHeight;
  Canvas.Brush.Color := LPalette.HeaderBackground;
  Canvas.FillRect(LHeaderRect);

  if FRowIndicator.Visible then
  begin
    LContentBottom := LHeaderRect.Bottom - Round(FSpacing.RowSpacing);
    LRect := Rect(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Left + RowIndicatorWidth, Max(GetViewportRect.Top, LContentBottom));
    LContext := ThiiFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridHeaderCell, ThiiElementKind.CornerCell);
    LContext.ElementFlags := [ThiiElementFlag.Header, ThiiElementFlag.Corner, ThiiElementFlag.FixedColumn];
    LAppearance.Clear;
    LCell := AcquireVisualCell(LContext, ThiiVclHeaderCell);
    LCell.BindCell(LContext, LRect, TValue.Empty, '', LAppearance);
    LCell.Paint(Self, Canvas);

    LRightSpacing := GetIndicatorRightSpacing;
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, nil, -1, ThiiRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    DrawCustomHeaderLayout
  else
    DrawDefaultHeaders;

  if Round(FSpacing.RowSpacing) > 0 then
  begin
    LSeparatorRect := Rect(LHeaderRect.Left, LHeaderRect.Bottom - Round(FSpacing.RowSpacing), LHeaderRect.Right, LHeaderRect.Bottom);
    DrawSpacingRect(LSeparatorRect, ThiiElementKind.RowSpacing, nil, -1, ThiiRowKey.Empty, ResolveRowSpacingColor);
  end;
end;

procedure ThiiCustomGrid.DrawRowIndicator(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);
var
  LRect: TRect;
  LSeparatorRect: TRect;
  LRightSpacing: Integer;
  LContext: ThiiFactoryContext;
  LCell: ThiiVclVisualCell;
  LAppearance: ThiiResolvedAppearance;
begin
  if not FRowIndicator.Visible then
    Exit;

  LRect := ARowInfo.Bounds;
  LRect.Left := GetViewportRect.Left;
  LRect.Right := LRect.Left + RowIndicatorWidth;

  LContext := ThiiFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridFixedCell, ThiiElementKind.RowHeaderCell);
  LContext.RowKey := ARowInfo.RowKey;
  LContext.ViewRowIndex := ARowInfo.RowIndex;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARowInfo.RowIndex);
  LContext.ElementFlags := [ThiiElementFlag.FixedColumn];
  PopulateAdjacentGroupContext(LContext, ARowInfo.RowIndex);
  if ASelected then
    Include(LContext.ElementFlags, ThiiElementFlag.Selected);

  LAppearance.Clear;
  if ASelected then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := h5uGetVclPalette(FAppearance.Theme).SelectedBackground;
    LAppearance.HasForeground := True;
    LAppearance.Foreground := h5uGetVclPalette(FAppearance.Theme).SelectedText;
  end;

  LCell := AcquireVisualCell(LContext, ThiiVclDataCell);
  LCell.BindCell(LContext, LRect, TValue.From<Int64>(ARowInfo.RowIndex + 1), IntToStr(ARowInfo.RowIndex + 1), LAppearance);
  LCell.Paint(Self, Canvas);

  LRightSpacing := GetIndicatorRightSpacing;
  if LRightSpacing > 0 then
  begin
    LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
    IntersectRect(LSeparatorRect, LSeparatorRect, GetDataViewportRect);
    if not IsRectEmpty(LSeparatorRect) then
      DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, nil, ARowInfo.RowIndex, ARowInfo.RowKey, ResolveColumnSpacingColor);
  end;
end;

function ThiiCustomGrid.GetAdjacentGroupGlyphRect(const ARowInfo: ThiiVisibleRowInfo): TRect;
var
  LInfo: Th5uAdjacentGroupRowInfo;
  LLeft: Integer;
  LTop: Integer;
  LSize: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not FAdjacentGroupFolding.Enabled or not FAdjacentGroupFolding.ShowFoldGlyph or not TryGetAdjacentGroupRowInfo(ARowInfo.RowIndex, LInfo)
    or not LInfo.IsFoldable or not LInfo.IsFirstRow then
    Exit;

  LSize := EnsureRange(ARowInfo.Bounds.Height - 8, 9, 13);
  LTop := ARowInfo.Bounds.Top + (ARowInfo.Bounds.Height - LSize) div 2;

  if FRowIndicator.Visible then
    LLeft := GetViewportRect.Left + 4
  else if Length(FVisibleColumns) > 0 then
    LLeft := Max(GetDataViewportRect.Left + 3, FVisibleColumns[0].Bounds.Left + 3)
  else
    Exit;

  Result := Rect(LLeft, LTop, LLeft + LSize, LTop + LSize);
  IntersectRect(Result, Result, GetDataViewportRect);
end;

procedure ThiiCustomGrid.DrawAdjacentGroupGlyph(const ARowInfo: ThiiVisibleRowInfo; ASelected: Boolean);
var
  LBounds: TRect;
  LContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiVclVisualCell;
begin
  LBounds := GetAdjacentGroupGlyphRect(ARowInfo);
  if IsRectEmpty(LBounds) then
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
    LAppearance.Background := h5uGetVclPalette(FAppearance.Theme).SelectedBackground;
  end;

  LCell := AcquireVisualCell(LContext, Th5uVclAdjacentGroupGlyphCell);
  LCell.BindCell(LContext, LBounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

procedure ThiiCustomGrid.DrawRows;
var
  LDataRect: TRect;
  LTop: Integer;
  LRowIndex: Int64;
  LRowCount: Int64;
  LHeight: Integer;
  LRowSpacing: Integer;
  LRowRect: TRect;
  LRowKey: ThiiRowKey;
  LRows: TList<ThiiVisibleRowInfo>;
  LRowInfo: ThiiVisibleRowInfo;
  LColumnInfo: ThiiVisibleColumnInfo;
  LCellRect: TRect;
  LSeparatorRect: TRect;
  LContext: ThiiFactoryContext;
  LCell: ThiiVclVisualCell;
  LValue: TValue;
  LDisplayText: string;
  LStyleName: string;
  LStyleKey: TValue;
  LRowAppearance: ThiiResolvedAppearance;
  LCellAppearance: ThiiResolvedAppearance;
  LRowSelected: Boolean;
  LCellSelected: Boolean;
  LFocused: Boolean;
  LClassId: ThiiClassId;
  LOverscanBottom: Integer;
  LColumnSpacing: Integer;
  LRowSeparatorKind: ThiiElementKind;
  LRowSeparatorColor: TColor;
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

  PrepareViewRange(Max(0, LRowIndex - FScrolling.OverscanRows), 64);

  LRows := TList<ThiiVisibleRowInfo>.Create;
  try
    LOverscanBottom := LDataRect.Bottom + FScrolling.OverscanRows * (Round(FRowHeight.EstimatedHeight) + Round(FSpacing.RowSpacing));

    while (LRowIndex < LRowCount) and (LTop < LOverscanBottom) do
    begin
      LRowKey := GetViewRowKey(LRowIndex);
      LHeight := GetRowHeightFor(LRowIndex, LRowKey);
      LRowSpacing := GetEffectiveRowSeparatorFor(LRowIndex, LRowKey, LRowSeparatorKind, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
        LClosedTreeLevels);
      FRowMetrics.RecordExtent(LRowIndex, LHeight + LRowSpacing);
      LRowRect := Rect(LDataRect.Left, LTop, LDataRect.Right, LTop + LHeight);

      LRowInfo.RowIndex := LRowIndex;
      LRowInfo.RowKey := LRowKey;
      LRowInfo.Bounds := LRowRect;
      LRowInfo.Height := LHeight;
      LRows.Add(LRowInfo);

      if h5uRectIntersects(LRowRect, LDataRect) then
      begin
        LRowSelected := FSelection.IsRowSelected(LRowKey);
        LStyleName := GetRowStyle(LRowIndex, LStyleKey);
        LRowAppearance := ResolveRowAppearance(LRowIndex, LRowKey, LStyleName);

        DrawRowIndicator(LRowInfo, LRowSelected);
        if FRowIndicator.Visible then
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);

        for LColumnInfo in FVisibleColumns do
        begin
          LCellRect := GetVisibleCellBounds(LColumnInfo.Column, LColumnInfo.Bounds, LRowRect);

          if not IsRectEmpty(LCellRect) then
          begin
            LCellSelected := LRowSelected or FSelection.IsColumnSelected(LColumnInfo.Column.Id)
              or FSelection.IsCellSelected(LRowIndex, LColumnInfo.VisibleIndex);
            LFocused := FSelection.FocusedCell.IsValid and (FSelection.FocusedCell.RowIndex = LRowIndex)
              and (FSelection.FocusedCell.ColumnIndex = LColumnInfo.VisibleIndex);

            LClassId := LColumnInfo.Column.CellClassId;
            if string(LClassId) = '' then
              LClassId := h5uClassIdGridDataCell;
            if (LColumnInfo.Column.FixedKind <> ThiiFixedKind.None) and (LClassId = h5uClassIdGridDataCell) then
              LClassId := h5uClassIdGridFixedCell;

            LContext := ThiiFactoryContext.Create(Self, Self, FDataController, LClassId, ThiiElementKind.DataCell);
            LContext.Column := LColumnInfo.Column;
            LContext.RowKey := LRowKey;
            LContext.ViewRowIndex := LRowIndex;
            LContext.SourceRowIndex := GetViewSourceRowIndex(LRowIndex);
            LContext.RowStyleKey := LStyleKey;
            PopulateAdjacentGroupContext(LContext, LRowIndex);

            if LColumnInfo.Column.FixedKind <> ThiiFixedKind.None then
              Include(LContext.ElementFlags, ThiiElementFlag.FixedColumn);
            if LCellSelected then
              Include(LContext.ElementFlags, ThiiElementFlag.Selected);
            if LFocused then
              Include(LContext.ElementFlags, ThiiElementFlag.Focused);
            if Odd(LRowIndex) then
              Include(LContext.ElementFlags, ThiiElementFlag.OddRow)
            else
              Include(LContext.ElementFlags, ThiiElementFlag.EvenRow);
            if (FRowStyles.StripePeriod > 0) and (((LRowIndex + 1 - FRowStyles.StripeOffset) mod FRowStyles.StripePeriod) = 0) then
              Include(LContext.ElementFlags, ThiiElementFlag.PatternRow);
            if LColumnInfo.Column.ReadOnly then
              Include(LContext.ElementFlags, ThiiElementFlag.ReadOnly);

            LValue := GetCellValue(LColumnInfo.Column, LRowIndex, True);
            LContext.Value := LValue;
            LDisplayText := GetCellText(LColumnInfo.Column, LRowIndex, True);

            LCellAppearance := ResolveCellAppearance(LContext, LColumnInfo.Column, LRowAppearance, LCellSelected, LFocused);

            LCell := AcquireVisualCell(LContext, GetDataCellClass(LContext));
            LCell.BindCell(LContext, LCellRect, LValue, LDisplayText, LCellAppearance);
            LCell.Paint(Self, Canvas);
          end;

          LColumnSpacing := LColumnInfo.RightSpacing;
          if LColumnSpacing > 0 then
          begin
            LSeparatorRect := Rect(LColumnInfo.Bounds.Right, LRowRect.Top, LColumnInfo.Bounds.Right + LColumnSpacing, LRowRect.Bottom);
            LSeparatorRect := GetVisibleCellBounds(LColumnInfo.Column, LSeparatorRect, LRowRect);
            if not IsRectEmpty(LSeparatorRect) then
              DrawSpacingRect(LSeparatorRect, ThiiElementKind.ColumnSpacing, LColumnInfo.Column, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
        end;
        if not FRowIndicator.Visible then
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);
      end;

      if LRowSpacing > 0 then
      begin
        LSeparatorRect := Rect(LDataRect.Left, LRowRect.Bottom, LDataRect.Right, LRowRect.Bottom + LRowSpacing);
        IntersectRect(LSeparatorRect, LSeparatorRect, LDataRect);
        if not IsRectEmpty(LSeparatorRect) then
          DrawSpacingRect(LSeparatorRect, LRowSeparatorKind, nil, LRowIndex, LRowKey, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
            LClosedTreeLevels);
      end;

      Inc(LTop, LHeight + LRowSpacing);
      Inc(LRowIndex);
    end;

    FVisibleRows := LRows.ToArray;
  finally
    LRows.Free;
  end;
end;

procedure ThiiCustomGrid.DrawSpacingRect(const ABounds: TRect; AElementKind: ThiiElementKind; AColumn: ThiiGridColumn; AViewRowIndex: Int64; const ARowKey: ThiiRowKey;
  AColor: TColor; const AStyleName: string; ATreeLevel: Integer; AClosedTreeLevels: Integer);
var
  LClassId: ThiiClassId;
  LFactoryContext: ThiiFactoryContext;
  LAppearance: ThiiResolvedAppearance;
  LCell: ThiiVclVisualCell;
begin
  if IsRectEmpty(ABounds) then
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
  if AColor <> clNone then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := AColor;
  end;
  LCell := AcquireVisualCell(LFactoryContext, Th5uVclSpacingCell);
  LCell.BindCell(LFactoryContext, ABounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

function ThiiCustomGrid.GetColumnViewportRect(AColumn: ThiiGridColumn): TRect;
var
  LLeft, LRight: Single;
begin
  Result := GetViewportRect;
  LLeft := Result.Left;
  LRight := Result.Right;
  h5uColumnViewport(FColumns, AColumn, FSpacing.DefaultColumnRightSpacing, IndicatorExtent, LLeft, LRight);
  Result.Left := Round(LLeft);
  Result.Right := Round(LRight);
end;

function ThiiCustomGrid.GetVisibleCellBounds(AColumn: ThiiGridColumn; const AColumnBounds, ARowBounds: TRect): TRect;
begin
  // Painting, pointer hit testing and cell editors must use the same clipped
  // rectangle, including rows partially scrolled underneath the header.
  Result := GetColumnViewportRect(AColumn);
  Result.Top := ARowBounds.Top;
  Result.Bottom := ARowBounds.Bottom;
  IntersectRect(Result, Result, GetDataViewportRect);
  IntersectRect(Result, Result, AColumnBounds);
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

procedure ThiiCustomGrid.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
    begin
      CommitEditor;
      Key := 0;
    end;
    VK_ESCAPE:
    begin
      CancelEditor;
      SetFocus;
      Key := 0;
    end;
  end;
end;

function ThiiCustomGrid.FindFirstVisibleRow(AOffset: Int64; out ATop: Integer): Int64;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if Assigned(FDataController) then
  begin
    PrepareRowMetrics;
    Result := FRowMetrics.FindFirstVisibleRow(AOffset, GetDataViewportRect.Top, ATop);
  end;
end;

function ThiiCustomGrid.GetDataCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass;
begin
  if ThiiElementFlag.FixedColumn in AContext.ElementFlags then
    Result := GetFixedCellClass(AContext)
  else
    Result := ThiiVclDataCell;
end;

function ThiiCustomGrid.GetDataViewportRect: TRect;
begin
  Result := GetViewportRect;
  Inc(Result.Top, GetHeaderHeight);
end;

function ThiiCustomGrid.GetEstimatedTotalRowHeight(AAllowMeasure: Boolean): Int64;
var
  LTotal: Th5uTotalRowHeight;
begin
  Result := 0;
  if not Assigned(FDataController) then
    Exit;
  PrepareRowMetrics;
  LTotal := FRowMetrics.Total(AAllowMeasure);
  Result := LTotal.Whole;
end;

procedure ThiiCustomGrid.PrepareRowMetrics;
var
  LVariableSpacing: Boolean;
begin
  LVariableSpacing := Assigned(FOnGetRowHeight) or Assigned(FOnGetRowSpacing) or (FTree.Enabled and FTree.BranchEndBand.Enabled)
    or (FAdjacentGroupFolding.Enabled and (FAdjacentGroupFolding.EndBand.Visibility <> ThiiAdjacentGroupEndBandVisibility.Never));
  FRowMetrics.Configure(FRowHeight, GetViewRowCount, Round(FSpacing.RowSpacing), LVariableSpacing, PrepareViewRange, MetricRowExtent,
    Assigned(FOnGetRowSpacing));
end;

function ThiiCustomGrid.BeginPerformanceTiming: Int64;
begin
  Result := 0;
  if Assigned(FPerformance) and FPerformance.Enabled then
    Result := TStopwatch.GetTimeStamp;
end;

procedure ThiiCustomGrid.EndPerformanceTiming(AStage: ThiiGridPerformanceStage; AStarted: Int64);
begin
  if (AStarted <> 0) and Assigned(FPerformance) then
    FPerformance.RecordElapsed(AStage, (TStopwatch.GetTimeStamp - AStarted) * 1000.0 / TStopwatch.Frequency);
end;

function ThiiCustomGrid.GetFixedCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass;
begin
  Result := ThiiVclFixedCell;
end;

function ThiiCustomGrid.GetHeaderCellClass(const AContext: ThiiFactoryContext): ThiiVclVisualCellClass;
begin
  Result := ThiiVclHeaderCell;
end;

function ThiiCustomGrid.GetHeaderHeight: Integer;
begin
  Result := Round(h5uHeaderHeight(FHeaderLayout, FHeader.Visible, HeaderRowHeight, Round(FSpacing.RowSpacing)));
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

function ThiiCustomGrid.GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; AAllowMeasure: Boolean): Integer;
begin
  Result := Round(FRowMetrics.GetHeight(FRowHeight, FColumns, AViewRowIndex, ARowKey, AAllowMeasure, MetricCellHeight, MetricAdjustHeight));
end;

function ThiiCustomGrid.MetricCellHeight(ARow: Int64; AColumn: ThiiGridColumn): Single;
begin
  Result := MeasureCellHeight(ARow, AColumn);
end;

procedure ThiiCustomGrid.MetricAdjustHeight(ARow: Int64; const AKey: ThiiRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean);
var
  LContext: ThiiGetRowHeightContext;
  LHeight: Integer;
begin
  if not Assigned(FOnGetRowHeight) then
    Exit;
  LHeight := Round(AHeight);
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
  LColor: TColor;
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

function ThiiCustomGrid.GetRowStyle(AViewRowIndex: Int64; out AStyleKey: TValue): string;
var
  LColumn: ThiiGridColumn;
  LInteger: Integer;
  LHasKey: Boolean;
begin
  AStyleKey := TValue.Empty;
  LHasKey := False;
  LInteger := 0;

  if Assigned(FDataController) and (FRowStyles.StyleKeyColumnId <> '') then
  begin
    LColumn := FColumns.FindById(FRowStyles.StyleKeyColumnId);
    if not Assigned(LColumn) then
      LColumn := FColumns.FindByFieldName(FRowStyles.StyleKeyColumnId);

    if Assigned(LColumn) then
    begin
      AStyleKey := GetViewValue(AViewRowIndex, LColumn.FieldName);
      LHasKey := h5uTryValueAsInteger(AStyleKey, LInteger);
    end;
  end;

  Result := FRowStyles.ResolveStyle(AViewRowIndex, LInteger, LHasKey);
end;

function ThiiCustomGrid.GetIndicatorRightSpacing: Integer;
var
  LLeft: Integer;
begin
  LLeft := GetViewportRect.Left;
  Result := Round(LLeft + IndicatorExtent) - LLeft - RowIndicatorWidth;
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

function ThiiCustomGrid.GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): Integer;
var
  LContext: ThiiGetRowHeightContext;
begin
  Result := Round(FSpacing.RowSpacing);
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
  Result := EnsureRange(Result, 0, 1000);
end;

function ThiiCustomGrid.GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out AElementKind: ThiiElementKind; out AColor: TColor; out AStyleName: string;
  out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Integer;
var
  LSeparator: Th5uRowSeparatorInfo;
begin
  LSeparator := h5uRowSeparator(FView, FTree, FAdjacentGroupFolding, AViewRowIndex, ARowKey, MetricRowSpacing);
  AElementKind := LSeparator.Kind;
  AStyleName := LSeparator.StyleName;
  ATreeLevel := LSeparator.TreeLevel;
  AClosedTreeLevels := LSeparator.ClosedTreeLevels;
  Result := Round(LSeparator.Height);
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
  // from this compatibility property. Horizontal subpixel gaps can still
  // occupy native pixels after their positions are accumulated.
  Result := (Round(FSpacing.Left) > 0) or (Round(FSpacing.Top) > 0) or (Round(FSpacing.Right) > 0) or (Round(FSpacing.Bottom) > 0)
    or (Round(FSpacing.RowSpacing) > 0) or (FSpacing.DefaultColumnRightSpacing > 0);
end;

function ThiiCustomGrid.GetTotalColumnWidth: Integer;
var
  LColumn: ThiiGridColumn;
  LWidth: Single;
begin
  LWidth := 0;
  for LColumn in FColumns.VisibleColumns do
    LWidth := LWidth + LColumn.LayoutWidth + h5uColumnRightSpacing(LColumn, FSpacing.DefaultColumnRightSpacing);
  if FRowIndicator.Visible then
    LWidth := LWidth + RowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
  Result := Round(LWidth);
end;

function ThiiCustomGrid.GetUnpaddedViewportRect: TRect;
begin
  Result := ClientRect;
  if FVScrollBar.Visible then
    Dec(Result.Right, FVScrollBar.Width);
  if FHScrollBar.Visible then
    Dec(Result.Bottom, FHScrollBar.Height);
end;

function ThiiCustomGrid.GetViewportRect: TRect;
begin
  Result := GetUnpaddedViewportRect;

  Inc(Result.Left, Round(FSpacing.Left));
  Inc(Result.Top, Round(FSpacing.Top));
  Dec(Result.Right, Round(FSpacing.Right));
  Dec(Result.Bottom, Round(FSpacing.Bottom));

  if Result.Right < Result.Left then
    Result.Right := Result.Left;
  if Result.Bottom < Result.Top then
    Result.Bottom := Result.Top;
end;

function ThiiCustomGrid.ResolveColor(const AColor: TColor; AFallback: TColor): TColor;
begin
  if AColor = clDefault then
    Result := AFallback
  else
    Result := AColor;
end;

function ThiiCustomGrid.ResolveDefaultCellColor: TColor;
begin
  Result := ResolveColor(FAppearance.DefaultCellColor, h5uGetVclPalette(FAppearance.Theme).CellBackground);
end;

function ThiiCustomGrid.ResolveRowSpacingColor: TColor;
begin
  Result := ResolveColor(FAppearance.RowSpacingColor, h5uGetVclPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveColumnSpacingColor: TColor;
begin
  Result := ResolveColor(FAppearance.ColumnSpacingColor, h5uGetVclPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveContentPaddingColor: TColor;
begin
  Result := ResolveColor(FAppearance.ContentPaddingColor, h5uGetVclPalette(FAppearance.Theme).CellBorder);
end;

function ThiiCustomGrid.ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TColor;
var
  LAppearance: ThiiResolvedAppearance;
begin
  if FTree.BranchEndBand.Color <> clDefault then
    Exit(ResolveColor(FTree.BranchEndBand.Color, ResolveRowSpacingColor));

  if SameText(FTree.BranchEndBand.StyleName, 'TreeBranchEnd') then
    Exit(h5uGetVclPalette(FAppearance.Theme).TreeBranchEndBackground);

  if FTree.BranchEndBand.StyleName <> '' then
  begin
    LAppearance := ResolveRowAppearance(AViewRowIndex, ARowKey, FTree.BranchEndBand.StyleName);
    if LAppearance.HasBackground then
      Exit(LAppearance.Background);
  end;

  Result := ResolveRowSpacingColor;
end;

function ThiiCustomGrid.ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey): TColor;
var
  LAppearance: ThiiResolvedAppearance;
begin
  if FAdjacentGroupFolding.EndBand.Color <> clDefault then
    Exit(ResolveColor(FAdjacentGroupFolding.EndBand.Color, ResolveRowSpacingColor));

  if SameText(FAdjacentGroupFolding.EndBand.StyleName, 'AdjacentGroupEnd') then
    Exit(h5uGetVclPalette(FAppearance.Theme).AdjacentGroupEndBackground);

  if FAdjacentGroupFolding.EndBand.StyleName <> '' then
  begin
    LAppearance := ResolveRowAppearance(AViewRowIndex, ARowKey, FAdjacentGroupFolding.EndBand.StyleName);
    if LAppearance.HasBackground then
      Exit(LAppearance.Background);
  end;

  Result := ResolveRowSpacingColor;
end;

function ThiiCustomGrid.GetVisualCellClass(const AContext: ThiiFactoryContext; ADefaultClass: ThiiVclVisualCellClass): ThiiVclVisualCellClass;
var
  LCacheScope: ThiiFactoryCacheScope;
begin
  Result := ThiiVclVisualCellClass(FFactoryScope.ResolveClass(AContext, ThiiVclVisualCell, ADefaultClass, LCacheScope));
end;

function ThiiCustomGrid.HitTest(X, Y: Integer): ThiiHitTestInfo;
var
  LFirst, LLast: Integer;
  LColumnInfo: ThiiVisibleColumnInfo;
  LRowInfo: ThiiVisibleRowInfo;
  LGlyphRect: TRect;
begin
  Result := ThiiHitTestInfo.Empty;
  if not GetViewportRect.Contains(Point(X, Y)) then
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
      IntersectRect(Result.Bounds, Result.Bounds, GetHeaderCellViewport(Result.HeaderCell));
      Exit;
    end;
    if ColumnInfoAtPoint(X, Y, LColumnInfo) then
    begin
      Result.Kind := ThiiHitKind.Header;
      Result.Column := LColumnInfo.Column;
      Result.ColumnIndex := LColumnInfo.VisibleIndex;
      Result.Bounds := LColumnInfo.Bounds;
      IntersectRect(Result.Bounds, Result.Bounds, GetColumnViewportRect(LColumnInfo.Column));
      Result.Bounds.Top := GetViewportRect.Top;
      Result.Bounds.Bottom := Result.Bounds.Top + HeaderRowHeight;
    end;
    Exit;
  end;

  if not RowInfoAtPoint(X, Y, LRowInfo) then
    Exit;

  Result.RowIndex := LRowInfo.RowIndex;
  Result.RowKey := LRowInfo.RowKey;
  Result.Bounds := LRowInfo.Bounds;

  LGlyphRect := GetAdjacentGroupGlyphRect(LRowInfo);
  if not IsRectEmpty(LGlyphRect) and PtInRect(LGlyphRect, Point(X, Y)) then
  begin
    Result.Kind := ThiiHitKind.AdjacentGroupGlyph;
    Result.Bounds := LGlyphRect;
    Exit;
  end;

  if FRowIndicator.Visible and (X < GetViewportRect.Left + RowIndicatorWidth) then
  begin
    Result.Kind := ThiiHitKind.RowIndicator;
    Exit;
  end;

  if ColumnInfoAtPoint(X, Y, LColumnInfo) then
  begin
    Result.Kind := ThiiHitKind.DataCell;
    Result.Column := LColumnInfo.Column;
    Result.ColumnIndex := LColumnInfo.VisibleIndex;
    Result.Bounds := GetVisibleCellBounds(LColumnInfo.Column, LColumnInfo.Bounds, LRowInfo.Bounds);
  end;
end;

procedure ThiiCustomGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  if Assigned(FThumbHint) then
    FThumbHint.Visible := False;
end;

procedure ThiiCustomGrid.InvalidateAllRowHeights;
begin
  FRowMetrics.Clear;
end;

procedure ThiiCustomGrid.InvalidateRowHeight(const ARowKey: ThiiRowKey);
begin
  FRowMetrics.Remove(ARowKey.ToString);
  Invalidate;
end;

procedure ThiiCustomGrid.InvalidateVisibleRowHeights;
var
  LRow: ThiiVisibleRowInfo;
begin
  for LRow in FVisibleRows do
    FRowMetrics.Remove(LRow.RowKey.ToString);
  Invalidate;
end;

function ThiiCustomGrid.CanUpdateLayout: Boolean;
var
  LComponent: TComponent;
begin
  Result := False;
  if not FInitialized or not Assigned(Parent) then
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

procedure ThiiCustomGrid.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  // Internal scrollbars, hints and cached editors are runtime implementation details.
  for I := 0 to ControlCount - 1 do
    if (Controls[I].Owner = Root) and (Controls[I].Owner <> Self) then
      Proc(Controls[I]);
end;

procedure ThiiCustomGrid.Loaded;
var
  I: Integer;
begin
  if not FHasSizingVersion then
  begin
    FColumns.BeginUpdate;
    try
      for I := 0 to FColumns.Count - 1 do
        FColumns[I].ApplyLegacySizing;
      for I := 0 to FHeaderLayout.Cells.Count - 1 do
        FHeaderLayout.Cells[I].ApplyLegacySizing;
    finally
      FColumns.EndUpdate;
    end;
  end;
  inherited;
  LayoutScrollBars;
  // Paint refreshes data-dependent layout; FormCreate may not have run yet.
  Invalidate;
end;

procedure ThiiCustomGrid.LayoutScrollBars;
var
  LVWidth: Integer;
  LHHeight: Integer;
begin
  if not CanUpdateLayout then
    Exit;
  LVWidth := GetSystemMetrics(SM_CXVSCROLL);
  LHHeight := GetSystemMetrics(SM_CYHSCROLL);
  if LVWidth <= 0 then
    LVWidth := 17;
  if LHHeight <= 0 then
    LHHeight := 17;

  FVScrollBar.SetBounds(ClientWidth - LVWidth, 0, LVWidth, ClientHeight - IfThen(FHScrollBar.Visible, LHHeight, 0));
  FHScrollBar.SetBounds(0, ClientHeight - LHHeight, ClientWidth - IfThen(FVScrollBar.Visible, LVWidth, 0), LHHeight);
  if Assigned(FThumbHint) then
    FThumbHint.BringToFront;
  if Assigned(FActiveEditor) then
    FActiveEditor.BringToFront;
end;

function ThiiCustomGrid.MeasureCellHeight(AViewRowIndex: Int64; AColumn: ThiiGridColumn): Integer;
var
  LText: string;
  LRect: TRect;
  LFlags: Cardinal;
  LMaxByLines: Integer;
  LValue: TValue;
  LStarted: Int64;
begin
  Result := Round(FRowHeight.MinHeight);
  if not Assigned(FDataController) then
    Exit;
  LStarted := BeginPerformanceTiming;
  try
    if AColumn.DataType = ThiiColumnDataType.Image then
    begin
      LValue := GetCellValue(AColumn, AViewRowIndex, True);
      if LValue.IsType<TBytes> and (Length(LValue.AsType<TBytes>) > 0) then
        Result := Min(Round(AColumn.MaxAutoHeight), Max(Round(FRowHeight.MinHeight), 80));
      Exit;
    end;

    if not AColumn.AutoHeight then
      Exit;

    LText := GetCellText(AColumn, AViewRowIndex, True);

    Canvas.Font.Assign(Font);
    LRect := Rect(0, 0, Max(8, Round(AColumn.LayoutWidth) - 10), 0);
    LFlags := DT_CALCRECT or DT_NOPREFIX;
    if AColumn.WordWrap then
      LFlags := LFlags or DT_WORDBREAK
    else
      LFlags := LFlags or DT_SINGLELINE;

    DrawText(Canvas.Handle, PChar(LText), Length(LText), LRect, LFlags);
    Result := LRect.Height + 6;

    if AColumn.MaxLines > 0 then
    begin
      LMaxByLines := Canvas.TextHeight('Wg') * AColumn.MaxLines + 6;
      Result := Min(Result, LMaxByLines);
    end;

    if AColumn.MaxAutoHeight > 0 then
      Result := Min(Result, Round(AColumn.MaxAutoHeight));
  finally
    EndPerformanceTiming(ThiiGridPerformanceStage.HeightMeasurement, LStarted);
  end;
end;

procedure ThiiCustomGrid.CMCursorChanged(var Message: TMessage);
var
  LCursor: TCursor;
begin
  inherited;
  if not MouseCapture then
    Exit;
  // VCL skips visible cursor changes during capture; our drags need them now.
  LCursor := Screen.Cursor;
  if LCursor = crDefault then LCursor := Cursor;
  if LCursor = crDefault then LCursor := crArrow;
  Winapi.Windows.SetCursor(Screen.Cursors[LCursor]);
end;

procedure ThiiCustomGrid.CMMouseLeave(var Message: TMessage);
begin
  if not Assigned(FResizingColumn) then
    SetResizeCursor(False);
  inherited;
end;

function ThiiCustomGrid.ColumnResizeAt(X, Y: Integer; ATouch: Boolean): ThiiGridColumn;
var
  LCandidates: TArray<Th5uResizeCandidate>;
  LView: TRect;
  I: Integer;
begin
  Result := nil;
  if not CanUpdateLayout or not FCustomization.AllowColumnResizing then
    Exit;
  if not GetViewportRect.Contains(Point(X, Y)) or (FHeader.Visible and (Y >= GetDataViewportRect.Top)) then
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
  // Without a header the vertical edge must belong to an actual data cell.
  if not FHeader.Visible then
    Exit(HitTest(Round(AX - 1), Round(AY)).Kind = ThiiHitKind.DataCell);
  Result := True;
  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
  begin
    LHeader := HeaderCellAtPoint(Round(AX - 1), Round(AY));
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

function ThiiCustomGrid.AutoSizeColumnsAt(X, Y: Integer): Boolean;
var
  LTargets: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
  LColumn: ThiiGridColumn;
begin
  LTargets := h5uAutoSizeColumnTargets(FColumns, FSelection, ColumnResizeAt(X, Y, False));
  Result := Length(LTargets) > 0;
  if not Result then
    Exit;
  EndSelectionDrag;
  // Batch layout changes so later selected columns use the same header geometry.
  FColumns.BeginUpdate;
  try
    for LColumn in LTargets do
      AutoSizeColumn(LColumn);
  finally
    FColumns.EndUpdate;
  end;
end;

function ThiiCustomGrid.BeginColumnResize(X, Y: Integer; ATouch: Boolean): Boolean;
begin
  FResizingColumn := ColumnResizeAt(X, Y, ATouch);
  Result := Assigned(FResizingColumn);
  if not Result then
     Exit;
  FResizeStartX := X;
  FResizeHasMoved := False;
  FResizeOriginalWidth := Round(FResizingColumn.LayoutWidth);
  MouseCapture := True;
  if not ATouch then
    SetResizeCursor(True);
end;

procedure ThiiCustomGrid.UpdateColumnResize(X: Integer);
var
  Changed: Boolean;
begin
  if not Assigned(FResizingColumn) then
    Exit;
  if (csDesigning in ComponentState) and not FResizeHasMoved and (X = FResizeStartX) then Exit;
  if CanUpdateLayout and FCustomization.AllowColumnResizing and MouseCapture then
    if h5uTryResizeColumn(FColumns, FResizingColumn, FResizeOriginalWidth, X - FResizeStartX, Changed) then
    begin
      FResizeHasMoved := True;
      if (csDesigning in ComponentState) and Changed then DesignerColumnsModified;
      Exit;
    end;
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

function ThiiCustomGrid.IsDesignerColumnHit(const AHit: ThiiHitTestInfo): Boolean;
begin
  Result := (AHit.Kind = ThiiHitKind.Header) and Assigned(AHit.Column)
    and (not Assigned(AHit.HeaderCell) or ((AHit.HeaderCell.ColumnId <> '') and (AHit.HeaderCell.ColumnSpan = 1)));
end;

function ThiiCustomGrid.DesignWndProc(var Message: TMessage): Boolean;
var
  Point: TPoint;
  WasResizeCursor: Boolean;
begin
  Result := inherited;
  if not (csDesigning in ComponentState) or not CanUpdateLayout or (Message.Msg <> WM_SETCURSOR) or (LoWord(Message.LParam) <> HTCLIENT)
    or (Length(FMovingColumns) > 0) then Exit;
  if Assigned(FResizingColumn) then
  begin
    Result := True;
    Exit;
  end;
  WasResizeCursor := FResizeCursorActive;
  if not GetCursorPos(Point) then Exit;
  Point := ScreenToClient(Point);
  SetResizeCursor(FHeader.Visible and Assigned(ColumnResizeAt(Point.X, Point.Y, False)));
  // Let VCL apply the control cursor before the designer can replace it with its own.
  if FResizeCursorActive or WasResizeCursor then Result := True;
end;

procedure ThiiCustomGrid.WMSetCursor(var Message: TWMSetCursor);
var
  ActiveCursor: TCursor;
begin
  if (csDesigning in ComponentState) and FResizeCursorActive and (Message.HitTest = HTCLIENT) and (Message.CursorWnd = Handle) then
  begin
    ActiveCursor := Screen.Cursor;
    if ActiveCursor = crDefault then ActiveCursor := Cursor;
    Winapi.Windows.SetCursor(Screen.Cursors[ActiveCursor]);
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

procedure ThiiCustomGrid.SelectDesignerColumn(AColumn: ThiiGridColumn);
begin
  if (csDesigning in ComponentState) and Assigned(h5uVclDesignerColumnSelect) then
    h5uVclDesignerColumnSelect(Self, AColumn);
end;

procedure ThiiCustomGrid.DesignerColumnsModified;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if (csDesigning in ComponentState) and Assigned(Form) and Assigned(Form.Designer) then
    Form.Designer.Modified;
end;

function ThiiCustomGrid.CanMoveColumn(AColumn: ThiiGridColumn): Boolean;
begin
  Result := h5uCanMoveColumn(FColumns, FCustomization.AllowColumnMoving, AColumn);
end;

function ThiiCustomGrid.IsColumnMoveGesture(AColumn: ThiiGridColumn; AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(CanMoveColumn(AColumn), FCustomization.ColumnMovingGesture = ThiiColumnRowMovingGesture.AltDrag, AShift);
end;

function ThiiCustomGrid.IsRowMoveGesture(AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(Assigned(FOnRowsMoved) and FCustomization.AllowRowMoving,
    FCustomization.RowMovingGesture = ThiiColumnRowMovingGesture.AltDrag, AShift);
end;

function ThiiCustomGrid.GetHeaderCellBounds(ACell: ThiiHeaderLayoutCell): TRect;
var
  LFirst, LLast, LSpan: Integer;
begin
  Result := TRect.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
    Exit;
  Result.Left := FAllColumns[LFirst].Bounds.Left;
  Result.Right := FAllColumns[LLast].Bounds.Right;
  Result.Top := GetViewportRect.Top + ACell.LayoutRow * (HeaderRowHeight + Round(FSpacing.RowSpacing));
  LSpan := Max(1, ACell.RowSpan);
  Result.Bottom := Result.Top + LSpan * HeaderRowHeight + (LSpan - 1) * Round(FSpacing.RowSpacing);
end;

function ThiiCustomGrid.GetHeaderCellViewport(ACell: ThiiHeaderLayoutCell): TRect;
var
  LFirst, LLast: Integer;
begin
  Result := TRect.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LFirst >= Length(FAllColumns)) then
    Exit;
  Result := GetColumnViewportRect(FAllColumns[LFirst].Column);
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function ThiiCustomGrid.HeaderCellAtPoint(X, Y: Integer): ThiiHeaderLayoutCell;
var
  I: Integer;
  LRect: TRect;
begin
  Result := nil;
  if not FHeaderLayout.Enabled or not FHeader.Visible then
    Exit;
  // Reverse paint order also resolves overlapping cells consistently with drawing.
  for I := FHeaderLayout.Cells.Count - 1 downto 0 do
  begin
    LRect := GetHeaderCellBounds(FHeaderLayout.Cells[I]);
    IntersectRect(LRect, LRect, GetHeaderCellViewport(FHeaderLayout.Cells[I]));
    if LRect.Contains(Point(X, Y)) then
      Exit(FHeaderLayout.Cells[I]);
  end;
end;

function ThiiCustomGrid.BeginColumnMove(AColumnIndex: Integer; X, Y: Integer): Boolean;
var
  LPlan: Th5uColumnMovePlan;
  LHit: ThiiHitTestInfo;
begin
  Result := False;
  LHit := HitTest(X, Y);
  if csDesigning in ComponentState then
  begin
    if not IsDesignerColumnHit(LHit) then Exit;
    LPlan := Default(Th5uColumnMovePlan);
    LPlan.Columns := [LHit.Column];
    LPlan.HeaderCell := LHit.HeaderCell;
    LPlan.Caption := LHit.Column.Caption;
  end
  else
  if not h5uPlanColumnMove(FColumns, FHeaderLayout, FSelection, FCustomization, AColumnIndex, LHit.HeaderCell, LPlan) then
    Exit;
  FMovingColumns := LPlan.Columns;
  FMovingHeaderCell := LPlan.HeaderCell;
  FMoveCaption := LPlan.Caption;
  FMovePoint := Point(X, Y);
  FMovePreviewWidth := EnsureRange(Round(LPlan.Columns[0].LayoutWidth), MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  if Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
    FMovePreviewWidth := EnsureRange(LHit.Bounds.Width, MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  FSelectionDragOrigin := Point(X, Y);
  MouseCapture := True;
  Result := True;
end;

function ThiiCustomGrid.BeginRowMove(ARowIndex: Int64; X, Y: Integer): Boolean;
var
  LPlan: Th5uRowMovePlan;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving then
    Exit;
  if not h5uPlanRowMove(FSelection, ARowIndex, GetViewRowCount, GetViewRowKey, LPlan) then
    Exit;
  FMovingRowKeys := LPlan.RowKeys;
  FMovingFirstRowIndex := LPlan.FirstRowIndex;
  FSelectionDragOrigin := Point(X, Y);
  MouseCapture := True;
  Result := True;
end;

procedure ThiiCustomGrid.UpdateHeaderMove(X, Y: Integer);
begin
  if (Length(FMovingColumns) = 0) and (Length(FMovingRowKeys) = 0) then
    Exit;
  if not MouseCapture then
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
  FMovePoint := Point(X, Y);
  Invalidate;
end;

function ThiiCustomGrid.GetColumnMoveHeaderBounds(const AInfo: ThiiVisibleColumnInfo): TRect;
var
  LCell: ThiiHeaderLayoutCell;
  LFirst, LLast, I: Integer;
begin
  Result := AInfo.Bounds;
  Result.Top := GetViewportRect.Top;
  Result.Bottom := Result.Top + HeaderRowHeight;
  if Assigned(FMovingHeaderCell) then
  begin
    if not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
      Exit(TRect.Empty);
    if FMovingHeaderCell.ColumnSpan > 1 then
    begin
      Result := GetHeaderCellBounds(FMovingHeaderCell);
      IntersectRect(Result, Result, GetHeaderCellViewport(FMovingHeaderCell));
      Exit;
    end;
    Result := TRect.Empty;
    for I := 0 to FHeaderLayout.Cells.Count - 1 do
    begin
      LCell := FHeaderLayout.Cells[I];
      if (LCell.LayoutRow <> FMovingHeaderCell.LayoutRow) or not FHeaderLayout.ColumnRange(LCell, FColumns.VisibleColumns, LFirst, LLast) then
        Continue;
      if (AInfo.VisibleIndex >= LFirst) and (AInfo.VisibleIndex <= LLast) then
        Result := GetHeaderCellBounds(LCell);
    end;
  end;
  IntersectRect(Result, Result, GetColumnViewportRect(AInfo.Column));
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function ThiiCustomGrid.ColumnMoveTarget(X, Y: Integer; out ANewIndex, AMarkerX, AMarkerTop: Integer): Boolean;
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
  LHit := HitTest(X, Y);
  if (LHit.Kind <> ThiiHitKind.Header) or not Assigned(LHit.Column) then
    Exit;
  if csDesigning in ComponentState then
  begin
    if not IsDesignerColumnHit(LHit) then Exit;
    Result := h5uDesignColumnMoveTarget(FColumns, FHeaderLayout, FMovingColumns[0], LHit.Column, ANewIndex);
    LAfter := LHit.ColumnIndex > FMouseDownHit.ColumnIndex;
  end
  else
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
  LPalette: ThiiVclPalette;
  LCanvas: TCanvas;
  LFill: TBitmap;
  LBlend: TBlendFunction;
  LSavedDC: Integer;
  LView, LRect, LTextRect: TRect;
  LInfo: ThiiVisibleColumnInfo;
  LColumn: ThiiGridColumn;
  LMarkerX, LMarkerTop, LWidth, LHeight, LLeft, LTop, LOffset, LNewIndex, LEdge, LMargin: Integer;
  LValid, LSourcePainted: Boolean;

  function Scaled(AValue: Integer): Integer;
  begin
    Result := MulDiv(AValue, CurrentPPI, 96);
  end;

begin
  if not FMoveDragging or (Length(FMovingColumns) = 0) or not FHeader.Visible or not MouseCapture then
    Exit;
  if Assigned(FMovingHeaderCell) and not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
    Exit;
  LView := GetViewportRect;
  if LView.IsEmpty then
    Exit;
  LPalette := h5uGetVclPalette(FAppearance.Theme);
  LValid := ColumnMoveTarget(FMovePoint.X, FMovePoint.Y, LNewIndex, LMarkerX, LMarkerTop);
  LEdge := Max(1, Scaled(2));
  LMargin := Scaled(4);
  LSavedDC := SaveDC(Canvas.Handle);
  if LSavedDC = 0 then
    Exit;
  LCanvas := nil;
  LFill := nil;
  try
    // A separate canvas preserves the grid canvas's cached pen/brush/font state.
    LCanvas := TCanvas.Create;
    LCanvas.Handle := Canvas.Handle;
    IntersectClipRect(LCanvas.Handle, LView.Left, LView.Top, LView.Right, LView.Bottom);
    LCanvas.Pen.Style := psSolid;
    LCanvas.Pen.Mode := pmCopy;
    LCanvas.Pen.Width := LEdge;
    LCanvas.Pen.Color := LPalette.SelectedBackground;
    LFill := TBitmap.Create;
    LFill.PixelFormat := pf32bit;
    LFill.SetSize(1, 1);
    LFill.Canvas.Brush.Color := LPalette.SelectedBackground;
    LFill.Canvas.FillRect(Rect(0, 0, 1, 1));
    LBlend := Default(TBlendFunction);
    LBlend.BlendOp := AC_SRC_OVER;
    LBlend.SourceConstantAlpha := 76;
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
          Winapi.Windows.AlphaBlend(LCanvas.Handle, LRect.Left, LRect.Top, LRect.Width, LRect.Height, LFill.Canvas.Handle, 0, 0, 1, 1, LBlend);
          // Fill the outline inside the cell; a centered pen would overlap its parent header.
          LCanvas.Brush.Style := bsSolid;
          LCanvas.Brush.Color := LPalette.SelectedBackground;
          LCanvas.FillRect(Rect(LRect.Left, LRect.Top, LRect.Right, Min(LRect.Bottom, LRect.Top + LEdge)));
          LCanvas.FillRect(Rect(LRect.Left, Max(LRect.Top, LRect.Bottom - LEdge), LRect.Right, LRect.Bottom));
          LCanvas.FillRect(Rect(LRect.Left, LRect.Top, Min(LRect.Right, LRect.Left + LEdge), LRect.Bottom));
          LCanvas.FillRect(Rect(Max(LRect.Left, LRect.Right - LEdge), LRect.Top, LRect.Right, LRect.Bottom));
        end;
    LCanvas.Brush.Style := bsSolid;
    if LValid then
    begin
      LMarkerX := EnsureRange(LMarkerX, LView.Left + LEdge, Max(LView.Left + LEdge, LView.Right - LEdge));
      LCanvas.Brush.Color := LPalette.SelectedBackground;
      LCanvas.Pen.Style := psClear;
      LCanvas.FillRect(Rect(LMarkerX - LEdge, LMarkerTop, LMarkerX + LEdge, LView.Bottom));
      LCanvas.RoundRect(LMarkerX - Scaled(6), LMarkerTop, LMarkerX + Scaled(6), LMarkerTop + Scaled(7), LMargin, LMargin);
      LCanvas.Pen.Style := psSolid;
    end;
    LWidth := Min(FMovePreviewWidth, Max(1, LView.Width - 2 * LMargin));
    LHeight := Max(Scaled(30), HeaderRowHeight);
    LOffset := Scaled(16);
    if FMoveTouch then
      LOffset := Scaled(40);
    LLeft := EnsureRange(FMovePoint.X - LWidth div 2, LView.Left + LMargin, Max(LView.Left + LMargin, LView.Right - LWidth - LMargin));
    LTop := EnsureRange(FMovePoint.Y + LOffset, LView.Top + LMargin, Max(LView.Top + LMargin, LView.Bottom - LHeight - LMargin));
    LRect := Rect(LLeft, LTop, LLeft + LWidth, LTop + LHeight);
    LFill.Canvas.Brush.Color := clBlack;
    LFill.Canvas.FillRect(Rect(0, 0, 1, 1));
    LBlend.SourceConstantAlpha := 64;
    Winapi.Windows.AlphaBlend(LCanvas.Handle, LRect.Left + Scaled(3), LRect.Top + Scaled(3), LRect.Width, LRect.Height, LFill.Canvas.Handle, 0, 0, 1,
      1, LBlend);
    if LValid then
      LCanvas.Brush.Color := LPalette.SelectedBackground
    else
      LCanvas.Brush.Color := LPalette.ErrorBackground;
    LCanvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom, Scaled(8), Scaled(8));
    LCanvas.Font.Assign(Font);
    LCanvas.Font.Style := [fsBold];
    if LValid then
      LCanvas.Font.Color := LPalette.SelectedText
    else
      LCanvas.Font.Color := LPalette.CellText;
    LCanvas.Brush.Style := bsClear;
    LTextRect := LRect;
    InflateRect(LTextRect, -Scaled(8), -Scaled(3));
    LCanvas.TextRect(LTextRect, FMoveCaption, [tfCenter, tfVerticalCenter, tfSingleLine, tfEndEllipsis, tfNoPrefix]);
  finally
    LFill.Free;
    LCanvas.Free;
    RestoreDC(Canvas.Handle, LSavedDC);
  end;
end;

function ThiiCustomGrid.FinishHeaderMove(X, Y: Integer): Boolean;
var
  LHit: ThiiHitTestInfo;
  LMovingColumns: TArray<ThiiGridColumn>;
  LContext: ThiiRowsMovedContext;
  LNewIndex, LMarkerX, LMarkerTop: Integer;
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
  LHit := HitTest(X, Y);
  if csDesigning in ComponentState then
  begin
    if Length(LMovingColumns) <> 1 then Exit;
    if LDragging then
    begin
      if LColumnTargetValid and h5uMoveDesignColumn(FColumns, FHeaderLayout, LMovingColumns[0], LNewIndex) then
      begin
        DesignerColumnsModified;
        RebuildAfterLayoutChange;
        SelectDesignerColumn(LMovingColumns[0]);
      end;
    end
    else if IsDesignerColumnHit(LHit) and (LHit.Column = LMovingColumns[0]) then
      SelectDesignerColumn(LMovingColumns[0]);
    Exit;
  end;
  if not LDragging then
  begin
    if (Length(LMovingColumns) > 0) and (LHit.Kind = ThiiHitKind.Header) and (LHit.Column = FMouseDownHit.Column) then
      SelectHeaderRange(ThiiSelectionKind.Columns, -1, LHit.ColumnIndex, [])
    else if (Length(LContext.RowKeys) > 0) and (LHit.Kind = ThiiHitKind.RowIndicator) and (LHit.RowKey = FMouseDownHit.RowKey) then
      SelectHeaderRange(ThiiSelectionKind.Rows, LHit.RowIndex, -1, []);
    Result := False; // A click still dispatches the ordinary header click event.
    Exit;
  end;
  if Length(LMovingColumns) > 0 then
  begin
    if not LColumnTargetValid then
      Exit;
    FColumns.MoveColumns(LMovingColumns, LNewIndex, FHeaderLayout);
    RebuildAfterLayoutChange;
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

procedure ThiiCustomGrid.BeginSelectionDrag(AKind: ThiiSelectionKind; X, Y: Integer; AShift: TShiftState);
begin
  FSelectingRange := True;
  FSelectionDragging := False;
  FSelectionDragKind := AKind;
  FSelectionDragShift := AShift;
  FSelectionDragOrigin := Point(X, Y);
  FSelectionDragLast := ThiiCellAddress.Empty;
  MouseCapture := True;
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
    Invalidate;
  end;
  FMoveCaption := '';
  FMovingHeaderCell := nil;
  FSelectingRange := False;
  FSelectionDragging := False;
  FMouseEditPending := False;
  if LCaptured then
     MouseCapture := False;
end;

procedure ThiiCustomGrid.UpdateSelectionDrag(X, Y: Integer);
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
  LHit := HitTest(X, Y);
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

procedure ThiiCustomGrid.WMCancelMode(var Message: TWMCancelMode);
begin
  EndSelectionDrag;
  inherited;
end;

procedure ThiiCustomGrid.WMCaptureChanged(var Message: TMessage);
begin
  if Message.LParam <> LPARAM(Handle) then
    EndSelectionDrag;
  inherited;
end;

procedure ThiiCustomGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LCell: ThiiCellAddress;
  LRange: ThiiCellRange;
begin
  if csDesigning in ComponentState then
  begin
    EndSelectionDrag;
    FMouseDownHit := HitTest(X, Y);
    if (Button = TMouseButton.mbLeft) and FHeader.Visible and BeginColumnResize(X, Y, False) then Exit;
    if (Button = TMouseButton.mbLeft) and IsDesignerColumnHit(FMouseDownHit) then
      BeginColumnMove(FMouseDownHit.ColumnIndex, X, Y);
    Exit;
  end;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseDown(Button, Shift, PointF(X, Y));
  EndSelectionDrag;
  FMoveTouch := ssTouch in Shift;
  inherited;
  // VCL dispatches DblClick before this second MouseDown. Open the editor here
  // using the event coordinates, without taking focus back from it afterwards.
  if ssDouble in Shift then
  begin
    if (Button = mbLeft) and AutoSizeColumnsAt(X, Y) then
    begin
      FMouseDownHit := ThiiHitTestInfo.Empty;
      Exit;
    end;
    FMouseDownHit := HitTest(X, Y);
    if (Button = mbLeft) and (FMouseDownHit.Kind = ThiiHitKind.DataCell)
      and CellEditorHit(FMouseDownHit.Column, FMouseDownHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), PointF(X, Y)) then
      StartEdit(FMouseDownHit);
    Exit;
  end;
  SetFocus;
  FMouseDownHit := HitTest(X, Y);

  if (Button = mbRight) and (FMouseDownHit.Kind = ThiiHitKind.Header) and FCustomization.ShowColumnChooser then
  begin
    ShowColumnChooser;
    Exit;
  end;

  if Button = mbRight then
  begin
    SelectRightClickCell(FMouseDownHit);
    Exit;
  end;
  if Button <> mbLeft then
    Exit;
  if BeginColumnResize(X, Y, ssTouch in Shift) then
    Exit;

  if FMouseDownHit.Kind = ThiiHitKind.AdjacentGroupGlyph then
  begin
    ToggleAdjacentGroup(FMouseDownHit.RowIndex);
    Exit;
  end;

  if FMouseDownHit.Kind = ThiiHitKind.Header then
  begin
    if IsColumnMoveGesture(FMouseDownHit.Column, Shift) then
    begin
      BeginColumnMove(FMouseDownHit.ColumnIndex, X, Y);
      Exit;
    end;
    if FMouseDownHit.Column.CanSelect and (ThiiSelectionKind.Columns in FSelection.AllowedKinds) then
    begin
      SelectHeaderRange(ThiiSelectionKind.Columns, -1, FMouseDownHit.ColumnIndex, Shift);
      BeginSelectionDrag(ThiiSelectionKind.Columns, X, Y, Shift);
    end;
    Exit;
  end;

  if FMouseDownHit.Kind = ThiiHitKind.RowIndicator then
  begin
    if IsRowMoveGesture(Shift) then
    begin
      BeginRowMove(FMouseDownHit.RowIndex, X, Y);
      Exit;
    end;
    if ThiiSelectionKind.Rows in FSelection.AllowedKinds then
    begin
      SelectHeaderRange(ThiiSelectionKind.Rows, FMouseDownHit.RowIndex, -1, Shift);
      BeginSelectionDrag(ThiiSelectionKind.Rows, X, Y, Shift);
    end;
    Exit;
  end;

  if FMouseDownHit.Kind = ThiiHitKind.DataCell then
  begin
    LCell.RowIndex := FMouseDownHit.RowIndex;
    LCell.ColumnIndex := FMouseDownHit.ColumnIndex;
    LCell.RowKey := FMouseDownHit.RowKey;
    LCell.ColumnId := FMouseDownHit.Column.Id;

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

procedure ThiiCustomGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if csDesigning in ComponentState then
  begin
    if Assigned(FResizingColumn) then
      UpdateColumnResize(X)
    else if Length(FMovingColumns) > 0 then
      UpdateHeaderMove(X, Y)
    else
      SetResizeCursor(FHeader.Visible and Assigned(ColumnResizeAt(X, Y, False)));
    Exit;
  end;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseMove(Shift, PointF(X, Y));
  inherited;

  if Assigned(FResizingColumn) then
  begin
    if ssLeft in Shift then
      UpdateColumnResize(X)
    else
      EndSelectionDrag;
    Exit;
  end;
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

procedure ThiiCustomGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LHit: ThiiHitTestInfo;
  LColumn: ThiiGridColumn;
  I: Integer;
  LDragged, LEdit: Boolean;
begin
  if csDesigning in ComponentState then
  begin
    if (Button = TMouseButton.mbLeft) and Assigned(FResizingColumn) then
    begin
      LColumn := FResizingColumn;
      try
        UpdateColumnResize(X);
      finally
        EndSelectionDrag;
      end;
      for I := 0 to FColumns.Count - 1 do
        if FColumns[I] = LColumn then
        begin
          SelectDesignerColumn(LColumn);
          Break;
        end;
      FMouseDownHit := ThiiHitTestInfo.Empty;
      Exit;
    end;
    if Button = TMouseButton.mbLeft then FinishHeaderMove(X, Y);
    FMouseDownHit := ThiiHitTestInfo.Empty;
    Exit;
  end;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
    FActiveEditor.MouseUp(Button, Shift, PointF(X, Y));
  if (Button = TMouseButton.mbLeft) and Assigned(FResizingColumn) then
  begin
    try
      UpdateColumnResize(X);
    finally
      EndSelectionDrag;
    end;
    FMouseDownHit := ThiiHitTestInfo.Empty;
    inherited;
    Exit;
  end;
  if (Button = TMouseButton.mbLeft) and FinishHeaderMove(X, Y) then
  begin
    FMouseDownHit := ThiiHitTestInfo.Empty;
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
    FMouseDownHit := ThiiHitTestInfo.Empty;
    Exit;
  end;

  if Button = mbLeft then
  begin
    LHit := HitTest(X, Y);
    if (LHit.Kind = FMouseDownHit.Kind) and (LHit.Column = FMouseDownHit.Column) and (LHit.RowIndex = FMouseDownHit.RowIndex)
      and (LHit.Kind in [ThiiHitKind.DataCell, ThiiHitKind.Header, ThiiHitKind.RowIndicator]) then
    begin
      if LEdit and (LHit.Kind = ThiiHitKind.DataCell) then
      begin
        if CellEditorClick(LHit.Column, LHit.RowIndex) then
        begin
          if CellEditorHit(LHit.Column, LHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), TPointF.Create(FSelectionDragOrigin))
            and CellEditorHit(LHit.Column, LHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), PointF(X, Y)) then
            StartEdit(LHit);
        end
        else
          if FEditing.ImmediateEdit then
            EditFocusedCell(True);
      end;
      NotifyCellClick(LHit.Column, LHit.RowIndex, LHit.Kind = ThiiHitKind.Header, LHit.Kind = ThiiHitKind.RowIndicator);
    end;
  end;
  FSelectingRange := False;
end;

procedure ThiiCustomGrid.MoveColumn(AColumn: ThiiGridColumn; ANewVisibleIndex: Integer);
begin
  if not CanMoveColumn(AColumn) then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  RebuildAfterLayoutChange;
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
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, h5uClampInt64ToInteger(GetEstimatedTotalRowHeight));
    UpdateScrollBars;
    Invalidate;
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
    Invalidate;
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
  Invalidate;
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
  Invalidate;
end;

procedure ThiiCustomGrid.ResetAdjacentGroupStates;
begin
  FAutoWidthsDirty := True;
  FView.ResetAdjacentGroupStates;
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
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
  RebuildAfterLayoutChange;
end;

procedure ThiiCustomGrid.Paint;
var
  LPalette: ThiiVclPalette;
  LViewRect: TRect;
  LDataRect: TRect;
  LStarted: Int64;
begin
  if not CanUpdateLayout then
    Exit;
  LStarted := BeginPerformanceTiming;
  try
    LPalette := h5uGetVclPalette(FAppearance.Theme);
    Canvas.Brush.Color := LPalette.EmptyArea;
    Canvas.Brush.Style := bsSolid;
    PrepareGridCanvas(ClientRect, ThiiElementKind.Grid);
    Canvas.FillRect(ClientRect);
    Canvas.Font.Assign(Font);

    UpdateScrollBars;
    BuildColumnLayout;
    BeginVisualPass;

    DrawContentPadding;

    LViewRect := GetViewportRect;
    Canvas.Brush.Color := LPalette.GridBackground;
    Canvas.Brush.Style := bsSolid;
    PrepareGridCanvas(LViewRect, ThiiElementKind.View);
    Canvas.FillRect(LViewRect);

    LDataRect := GetDataViewportRect;
    Canvas.Brush.Color := ResolveDefaultCellColor;
    Canvas.Brush.Style := bsSolid;
    PrepareGridCanvas(LDataRect, ThiiElementKind.Grid);
    Canvas.FillRect(LDataRect);

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

procedure ThiiCustomGrid.RebuildAfterLayoutChange;
begin
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

procedure ThiiCustomGrid.Resize;
begin
  inherited;
  if not CanUpdateLayout then
    Exit;
  LayoutScrollBars;
  RebuildAfterLayoutChange;
end;

function ThiiCustomGrid.ResolveCellAppearance(const AContext: ThiiFactoryContext; AColumn: ThiiGridColumn; const ARowAppearance: ThiiResolvedAppearance;
  ASelected, AFocused: Boolean): ThiiResolvedAppearance;
var
  LPalette: ThiiVclPalette;
begin
  Result := ARowAppearance;
  LPalette := h5uGetVclPalette(FAppearance.Theme);

  if AColumn.Color <> clDefault then
  begin
    Result.HasBackground := True;
    Result.Background := AColumn.Color;
  end;

  if AColumn.Highlighted and (AColumn.Color = clDefault) and not ASelected then
  begin
    Result.HasBackground := True;
    Result.Background := LPalette.HighlightedColumnBackground;
  end;

  if ASelected then
  begin
    Result.HasBackground := True;
    Result.Background := LPalette.SelectedBackground;
    Result.HasForeground := True;
    Result.Foreground := LPalette.SelectedText;
  end;

  if AFocused then
  begin
    Result.HasBorder := True;
    Result.Border := LPalette.FocusBorder;
  end;

  if Assigned(FOnGetCellAppearance) then
    FOnGetCellAppearance(Self, AContext, Result);
end;

function ThiiCustomGrid.ResolveRowAppearance(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; const AStyleName: string): ThiiResolvedAppearance;
var
  LPalette: ThiiVclPalette;
begin
  Result.Clear;
  Result.StyleName := AStyleName;
  Result.HasBackground := True;
  LPalette := h5uGetVclPalette(FAppearance.Theme);

  if SameText(AStyleName, 'Error') then
    Result.Background := LPalette.ErrorBackground
  else if SameText(AStyleName, 'Warning') then
    Result.Background := LPalette.WarningBackground
  else if SameText(AStyleName, 'TreeBranchEnd') then
    Result.Background := LPalette.TreeBranchEndBackground
  else if SameText(AStyleName, 'Stripe') then
    Result.Background := LPalette.StripeBackground
  else if FAppearance.DefaultCellColor <> clDefault then
    Result.Background := ResolveDefaultCellColor
  else if SameText(AStyleName, 'Odd') then
    Result.Background := LPalette.OddBackground
  else if SameText(AStyleName, 'Even') then
    Result.Background := LPalette.EvenBackground
  else
    Result.Background := ResolveDefaultCellColor;

  if Assigned(FOnGetRowAppearance) then
    FOnGetRowAppearance(Self, AViewRowIndex, ARowKey, Result);
end;

function ThiiCustomGrid.RowInfoAtPoint(X, Y: Integer; out AInfo: ThiiVisibleRowInfo): Boolean;
var
  LInfo: ThiiVisibleRowInfo;
begin
  for LInfo in FVisibleRows do
    if PtInRect(LInfo.Bounds, Point(X, Y)) then
    begin
      AInfo := LInfo;
      Exit(True);
    end;
  Result := False;
end;

procedure ThiiCustomGrid.ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  LTop: Integer;
  LRowIndex: Int64;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;
  CancelEditor;

  if Sender = FVScrollBar then
  begin
    FVerticalOffset := EnsureRange(ScrollPos, 0, FVScrollBar.Max);

    if (FScrolling.VerticalMode = ThiiVerticalScrollMode.WholeRows) and (ScrollCode = scEndScroll) then
    begin
      LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
      if LRowIndex >= 0 then
      begin
        FVerticalOffset := FVerticalOffset + (LTop - GetDataViewportRect.Top);
        FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);
        ScrollPos := FVerticalOffset;
      end;
    end;

    if ThiiScrollHintTrigger.ThumbTracking in FScrollHints.Triggers then
      ShowThumbHint(ThiiScrollAxis.Vertical, ThiiScrollHintTrigger.ThumbTracking);
  end
  else
  begin
    FHorizontalOffset := EnsureRange(ScrollPos, 0, FHScrollBar.Max);
    if ThiiScrollHintTrigger.ThumbTracking in FScrollHints.Triggers then
      ShowThumbHint(ThiiScrollAxis.Horizontal, ThiiScrollHintTrigger.ThumbTracking);
  end;

  Invalidate;
  if ScrollCode = scEndScroll then
  begin
    FThumbHintTimer.Enabled := False;
    FThumbHintTimer.Enabled := True;
  end;
end;

procedure ThiiCustomGrid.SelectionChanged(Sender: TObject);
var
  LOld, LNew: ThiiCellAddress;
begin
  Invalidate;
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

procedure ThiiCustomGrid.SetCustomization(const AValue: ThiiCustomizationOptions);
begin
  FCustomization.Assign(AValue);
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

procedure ThiiCustomGrid.SetDataController(const AValue: ThiiCustomDataController);
begin
  if FDataController = AValue then
    Exit;
  EndSelectionDrag;

  CancelEditor;
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
  UpdateScrollBars;
  Invalidate;
end;

procedure ThiiCustomGrid.SetHeaderLayout(const AValue: ThiiHeaderLayout);
begin
  FHeader.Layout.Assign(AValue);
end;

procedure ThiiCustomGrid.SetHeaderRowHeight(const AValue: Integer);
begin
  FHeader.RowHeight := AValue;
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

procedure ThiiCustomGrid.SetRowIndicatorWidth(const AValue: Integer);
begin
  FRowIndicator.Width := AValue;
end;

procedure ThiiCustomGrid.SetRowStyles(const AValue: ThiiRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Invalidate;
end;

procedure ThiiCustomGrid.SetScrolling(const AValue: ThiiScrollingOptions);
begin
  FScrolling.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure ThiiCustomGrid.SetScrollHints(const AValue: ThiiScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure ThiiCustomGrid.SetSelection(const AValue: ThiiGridSelection);
begin
  FSelection.Assign(AValue);
  Invalidate;
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
  Invalidate;
end;

procedure ThiiCustomGrid.SetTheme(const AValue: ThiiGridTheme);
begin
  FAppearance.Theme := AValue;
end;

procedure ThiiCustomGrid.SetColumnVisible(AColumn: ThiiGridColumn; AVisible: Boolean);
begin
  if not Assigned(AColumn) then
    Exit;
  if not FCustomization.AllowColumnHiding and not AVisible then
    Exit;
  if not AColumn.CanHide and not AVisible then
    Exit;

  AColumn.Visible := AVisible;
  FColumns.NormalizeVisibleIndexes;
  RebuildAfterLayoutChange;
end;

procedure ThiiCustomGrid.ShowColumnChooser;
var
  LMenu: TPopupMenu;
  LItem: TMenuItem;
  I: Integer;
  LPoint: TPoint;
begin
  LMenu := TPopupMenu.Create(Self);
  try
    for I := 0 to FColumns.Count - 1 do
      if FColumns[I].ShowInColumnChooser then
      begin
        LItem := TMenuItem.Create(LMenu);
        LItem.Caption := FColumns[I].Caption;
        LItem.AutoCheck := False;
        LItem.Checked := FColumns[I].Visible;
        LItem.Tag := I;
        LItem.OnClick := ColumnChooserClick;
        LMenu.Items.Add(LItem);
      end;

    LPoint := Mouse.CursorPos;
    LMenu.Popup(LPoint.X, LPoint.Y);
  finally
    LMenu.Free;
  end;
end;

procedure ThiiCustomGrid.ShowThumbHint(AAxis: ThiiScrollAxis; ATrigger: ThiiScrollHintTrigger);
var
  LContext: ThiiThumbHintContext;
  LText: string;
  LVisible: Boolean;
  LPalette: ThiiVclPalette;
  LWidth: Integer;
  LHeight: Integer;
  LX: Integer;
  LY: Integer;
  LRatio: Single;
  LViewport: TRect;
begin
  if csDesigning in ComponentState then
    Exit;
  if not Assigned(FThumbHint) then
  begin
    FThumbHint := TLabel.Create(Self);
    FThumbHint.Parent := Self;
    if Assigned(FThumbHint) then
      FThumbHint.Visible := False;
    FThumbHint.Transparent := False;
    FThumbHint.AutoSize := False;
    FThumbHint.WordWrap := False;
    FThumbHint.Alignment := taCenter;
    FThumbHint.Layout := tlCenter;
  end;
  if not FScrollHints.Enabled then
    Exit;

  LText := BuildThumbHintText(AAxis, ATrigger, LContext);
  LVisible := LText <> '';
  if Assigned(FOnGetThumbHint) then
    FOnGetThumbHint(Self, LContext, LText, LVisible);

  if not LVisible then
  begin
    HideThumbHint;
    Exit;
  end;

  LPalette := h5uGetVclPalette(FAppearance.Theme);
  FThumbHint.Caption := LText;
  FThumbHint.Color := LPalette.ThumbHintBackground;
  FThumbHint.Font.Assign(Font);
  FThumbHint.Font.Color := LPalette.ThumbHintText;

  Canvas.Font.Assign(FThumbHint.Font);
  LWidth := Min(Max(80, Canvas.TextWidth(LText) + 18), Max(80, ClientWidth - 20));
  LHeight := Canvas.TextHeight('Wg') + 10;
  LViewport := GetViewportRect;

  if AAxis = ThiiScrollAxis.Vertical then
  begin
    if FVScrollBar.Max > 0 then
      LRatio := FVerticalOffset / FVScrollBar.Max
    else
      LRatio := 0;
    LX := Max(LViewport.Left + 4, LViewport.Right - LWidth - 8);
    LY := LViewport.Top + Round((LViewport.Height - LHeight) * LRatio);
  end
  else
  begin
    if FHScrollBar.Max > 0 then
      LRatio := FHorizontalOffset / FHScrollBar.Max
    else
      LRatio := 0;
    LX := LViewport.Left + Round((LViewport.Width - LWidth) * LRatio);
    LY := Max(LViewport.Top + 4, LViewport.Bottom - LHeight - 8);
  end;

  FThumbHint.SetBounds(LX, LY, LWidth, LHeight);
  FThumbHint.Visible := True;
  if Assigned(FThumbHint) then
    FThumbHint.BringToFront;

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
  LView: TRect;
  LTop, LHeight: Integer;
  LLeft, LRight: Single;
  LKey: ThiiRowKey;
  LRowTop: Th5uTotalRowHeight;
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
  LRowTop := FRowMetrics.RowTop(LCell.RowIndex);
  LTop := h5uClampInt64ToInteger(LRowTop.Whole);
  PrepareViewRange(LCell.RowIndex, 1);
  LKey := GetViewRowKey(LCell.RowIndex);
  LHeight := GetRowHeightFor(LCell.RowIndex, LKey);
  FVerticalOffset := Round(h5uRevealOffset(FVerticalOffset, LTop, LHeight, LView.Height));
  BuildColumnLayout;
  LLeft := LView.Left;
  if FRowIndicator.Visible then
    LLeft := LLeft + RowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
  LRight := LView.Right;
  for I := 0 to High(LColumns) do
    case LColumns[I].FixedKind of
      ThiiFixedKind.Left:
        LLeft := LLeft + LColumns[I].LayoutWidth + h5uColumnRightSpacing(LColumns[I], FSpacing.DefaultColumnRightSpacing);
      ThiiFixedKind.Right:
        LRight := LRight - LColumns[I].LayoutWidth - h5uColumnRightSpacing(LColumns[I], FSpacing.DefaultColumnRightSpacing);
    end;
  if LColumns[LCell.ColumnIndex].FixedKind = ThiiFixedKind.None then
  begin
    if FAllColumns[LCell.ColumnIndex].Bounds.Left < LLeft then
      FHorizontalOffset := Max(0, Round(FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Left - LLeft))
    else if FAllColumns[LCell.ColumnIndex].Bounds.Right > LRight then
      FHorizontalOffset := Max(0, Round(FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Right - LRight));
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
  Invalidate;
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
  Result := GetRowHeightFor(ARow, GetViewRowKey(ARow)) + Round(FSpacing.RowSpacing);
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

procedure ThiiCustomGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure ThiiCustomGrid.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  if Message.CharCode = vkEscape then
    Message.Result := 1;
end;

procedure ThiiCustomGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  C: Char;
begin
  inherited;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = ThiiEditorMode.Graphic) then
  begin
    C := #0;
    FActiveEditor.KeyDown(Key, C, Shift);
    Exit;
  end;
  if HandleNavigationKey(Key, Shift) then
    Key := 0;
end;

procedure ThiiCustomGrid.KeyPress(var Key: Char);
begin
  inherited;
  if Key >= #32 then
  begin
    SearchCharacter(Key);
    Key := #0;
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
  LContext := CellEditorContext(AHit.Column, AHit.RowIndex, TRectF.Create(AHit.Bounds));
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
  Invalidate;
end;

procedure ThiiCustomGrid.ThumbHintTimer(Sender: TObject);
begin
  HideThumbHint;
end;

procedure ThiiCustomGrid.UpdateScrollBars;
var
  LPass, LSettlePass: Integer;
  LNeedH, LNeedV: Boolean;
  LTotalWidth: Integer;
  LTotalHeight: Int64;
  LAvailableWidth: Integer;
  LAvailableHeight: Integer;
  LMaxHorizontal: Integer;
  LMaxVertical: Integer;
  LStarted: Int64;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;

  LStarted := BeginPerformanceTiming;
  FUpdatingScrollBars := True;
  try
    MeasureAutoWidths;
    for LSettlePass := 1 to 3 do
    begin
      LNeedH := False;
      LNeedV := False;
      // Provisional widths must not measure rows or evict their final-width cache.
      for LPass := 1 to 3 do
      begin
        LAvailableWidth := Max(0, ClientWidth - Round(FSpacing.Left) - Round(FSpacing.Right));
        LAvailableHeight := Max(0, ClientHeight - Round(FSpacing.Top) - Round(FSpacing.Bottom) - GetHeaderHeight);
        if LNeedV then
          LAvailableWidth := Max(0, LAvailableWidth - FVScrollBar.Width);
        if LNeedH then
          LAvailableHeight := Max(0, LAvailableHeight - FHScrollBar.Height);
        ResolveColumnWidths(LAvailableWidth);
        LTotalWidth := GetTotalColumnWidth;
        LTotalHeight := GetEstimatedTotalRowHeight(False);
        if (LNeedH or (LTotalWidth <= LAvailableWidth)) and (LNeedV or (LTotalHeight <= LAvailableHeight)) then
          Break;
        LNeedH := LNeedH or (LTotalWidth > LAvailableWidth);
        LNeedV := LNeedV or (LTotalHeight > LAvailableHeight);
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
      LTotalWidth := GetTotalColumnWidth;
      LTotalHeight := GetEstimatedTotalRowHeight;
      if LNeedV = (LTotalHeight > LAvailableHeight) then
        Break;
    end;

    LMaxHorizontal := Max(0, LTotalWidth - LAvailableWidth);
    LMaxVertical := h5uClampInt64ToInteger(Max(0, LTotalHeight - LAvailableHeight));

    FHScrollBar.Min := 0;
    FHScrollBar.Max := LMaxHorizontal;
    FHScrollBar.LargeChange := Max(1, LAvailableWidth);
    FHScrollBar.SmallChange := 24;

    FVScrollBar.Min := 0;
    FVScrollBar.Max := LMaxVertical;
    FVScrollBar.LargeChange := Max(1, LAvailableHeight);
    FVScrollBar.SmallChange := Max(1, Round(FRowHeight.EstimatedHeight) + Round(FSpacing.RowSpacing));

    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, LMaxHorizontal);
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, LMaxVertical);
    FHScrollBar.Position := FHorizontalOffset;
    FVScrollBar.Position := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
    EndPerformanceTiming(ThiiGridPerformanceStage.Layout, LStarted);
  end;
end;

procedure ThiiCustomGrid.SetEditors(AValue: ThiiVclGridEditors);
begin
  CancelEditor;
  FEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Invalidate;
end;

procedure ThiiCustomGrid.SetDefaultEditors(AValue: ThiiDefaultEditors);
begin
  CancelEditor;
  FDefaultEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Invalidate;
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
  Result := FEditorCache.Get(ThiiEditorPlatform.VCL, AName, '', FEditors.Find(AName));
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
  Result := FEditorCache.Get(ThiiEditorPlatform.VCL, LName, LScope, FEditors.Find(LName));
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
  Result.Foreground := TAlphaColor(h5uGetVclPalette(FAppearance.Theme).CellText);
  Result.Background := TAlphaColor(h5uGetVclPalette(FAppearance.Theme).CellBackground);
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
  Invalidate;
end;

procedure ThiiCustomGrid.ProcessEditorKey(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  EditorKeyDown(Sender, Key, Shift);
end;

function ThiiCustomGrid.CellEditorClick(AColumn: ThiiGridColumn; ARow: Int64): Boolean;
var
  E: ThiiGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.ActivateOnClick;
end;

end.

