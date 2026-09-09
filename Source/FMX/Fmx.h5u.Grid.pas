unit Fmx.h5u.Grid;

interface

{$SCOPEDENUMS ON}

uses
  System.StrUtils,
  System.TypInfo,
  System.Classes,
  System.DateUtils,
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
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Values,
  h5u.Grid.Moving,
  h5u.Grid.Resizing,
  h5u.Grid.Navigation,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Selection,
  h5u.Grid.Types,
  Fmx.h5u.Grid.Styles;

type
  Th5uCellDateEdit = class(TDateEdit)
  protected
    function GetAdjustType: TAdjustType; override;
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime); override;
  public
    procedure ApplyStyleLookup; override;
  end;

  Th5uCellTimeEdit = class(TTimeEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  Th5uCellTextEdit = class(TEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  Th5uFmxGrid = class;
  Th5uFmxVisualCell = class;
  Th5uFmxVisualCellClass = class of Th5uFmxVisualCell;

  Th5uFmxCustomDrawStage = (
    BeforeDefault,
    AfterDefault
  );

  Th5uFmxHitKind = (
    None,
    Header,
    RowIndicator,
    DataCell,
    AdjacentGroupGlyph
  );

  Th5uFmxGetRowHeightContext = record
    Grid: Th5uFmxGrid;
    DataController: Th5uCustomDataController;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    IsEstimated: Boolean;
  end;

  Th5uFmxGetRowHeightEvent = procedure(Sender: TObject; const AContext: Th5uFmxGetRowHeightContext; var AHeight: Single; var ACacheResult: Boolean) of object;

  Th5uFmxGetRowSpacingEvent = procedure(Sender: TObject; const AContext: Th5uFmxGetRowHeightContext; var ASpacing: Single) of object;

  Th5uFmxThumbHintContext = record
    Grid: Th5uFmxGrid;
    DataController: Th5uCustomDataController;
    Axis: Th5uScrollAxis;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    Column: Th5uGridColumn;
    Value: TValue;
    DisplayText: string;
  end;

  Th5uFmxGetThumbHintEvent = procedure(Sender: TObject; const AContext: Th5uFmxThumbHintContext; var AText: string; var AVisible: Boolean) of object;

  Th5uFmxDrawContext = record
    FactoryContext: Th5uFactoryContext;
    Bounds: TRectF;
    DisplayText: string;
    Appearance: Th5uResolvedAppearance;
  end;

  Th5uFmxAfterDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;

  Th5uFmxPrepareElementEvent = procedure(Sender: TObject; Control: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; APart: Th5uElementPaintPart) of object;

  Th5uFmxCustomDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean) of object;

  Th5uFmxVisibleColumnInfo = record
    Column: Th5uGridColumn;
    VisibleIndex: Integer;
    Bounds: TRectF;
  end;

  Th5uFmxVisibleRowInfo = record
    RowIndex: Int64;
    RowKey: Th5uRowKey;
    Bounds: TRectF;
    Height: Single;
  end;

  Th5uFmxHitTestInfo = record
    Kind: Th5uFmxHitKind;
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: Th5uRowKey;
    Column: Th5uGridColumn;
    Bounds: TRectF;
    HeaderCell: Th5uHeaderLayoutCell;
    class function Empty: Th5uFmxHitTestInfo; static;
  end;

  Th5uFmxVisualCell = class(Th5uFactoryObject)
  private
    FContext: Th5uFactoryContext;
    FBounds: TRectF;
    FContentBounds: TRectF;
    FValue: TValue;
    FDisplayText: string;
    FAppearance: Th5uResolvedAppearance;
    FInUse: Boolean;
  protected
    procedure PrepareCanvas(AGrid: Th5uFmxGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); virtual;
  public
    procedure BindCell(const AContext: Th5uFactoryContext; const ABounds: TRectF; const AValue: TValue; const ADisplayText: string;
      const AAppearance: Th5uResolvedAppearance); virtual;
    procedure Paint(AGrid: Th5uFmxGrid; ACanvas: TCanvas); virtual;
    property Context: Th5uFactoryContext read FContext;
    property Bounds: TRectF read FBounds;
    // Text/images keep their horizontal layout while Bounds is the visible hit area.
    property ContentBounds: TRectF read FContentBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: Th5uResolvedAppearance read FAppearance;
  end;

  // Lightweight pooled painter for row/column separators, content padding
  // and the tree branch-end band. Its ClassId is resolved per grid instance.
  Th5uFmxSpacingCell = class(Th5uFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); override;
  end;

  Th5uFmxDataCell = class(Th5uFmxVisualCell)
  private
    FBitmap: TBitmap;
    FBitmapSignature: Integer;
    procedure EnsureBitmap;
  protected
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  Th5uFmxHeaderCell = class(Th5uFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); override;
  end;

  Th5uFmxAdjacentGroupGlyphCell = class(Th5uFmxVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); override;
  end;

  Th5uFmxGrid = class(TStyledControl)
  private
    FShowColumnModes: Boolean;
    FColumns: Th5uGridColumns;
    FHeaderLayout: Th5uHeaderLayout;
    FDataController: Th5uCustomDataController;
    FDataLink: Th5uDataControllerLink;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FSelection: Th5uGridSelection;
    FNavigation: Th5uGridNavigation;
    FRowHeight: Th5uRowHeightOptions;
    FScrolling: Th5uScrollingOptions;
    FScrollHints: Th5uScrollHintOptions;
    FRowStyles: Th5uRowStyleOptions;
    FCustomization: Th5uCustomizationOptions;
    FSpacing: Th5uGridSpacingOptions;
    FAppearance: Th5uGridAppearanceOptions;
    FTree: Th5uTreeOptions;
    FAdjacentGroupFolding: Th5uAdjacentGroupFoldingOptions;
    FAdjacentGroupMap: Th5uAdjacentGroupMap;
    FAdjacentGroupMapDirty: Boolean;

    FTheme: Th5uGridTheme;
    FHeaderRowHeight: Single;
    FRowIndicatorWidth: Single;
    FShowHeader: Boolean;
    FShowRowIndicator: Boolean;
    FAllowEditing: Boolean;
    FImmediateEdit: Boolean;

    FOnCanFocus: Th5uCellPermissionEvent;
    FOnCanEdit: Th5uCellPermissionEvent;
    FOnValidate: Th5uCellValidateEvent;
    FOnGetValue: Th5uCellGetValueEvent;
    FOnSetValue: Th5uCellSetValueEvent;
    FOnCellClick: Th5uCellEvent;
    FOnColumnHeaderClick: Th5uCellEvent;
    FOnCellEnter: Th5uCellEvent;
    FOnCellExit: Th5uCellEvent;
    FOnRowIndicatorClick: Th5uCellEvent;
    FOnSelectionChange: TNotifyEvent;
    FClickDownHit: Th5uFmxHitTestInfo;
    FSelectingRange, FSelectionDragging, FMouseEditPending: Boolean;
    FSelectionDragKind: Th5uSelectionKind;
    FSelectionDragShift: TShiftState;
    FSelectionDragOrigin: TPointF;
    FSelectionDragLast: Th5uCellAddress;
    FMovingColumns: TArray<Th5uGridColumn>;
    FMovingRowKeys: TArray<Th5uRowKey>;
    FMovingFirstRowIndex: Int64;
    FMoveDragging: Boolean;
    FMovePoint: TPointF;
    FMoveCaption: string;
    FMovingHeaderCell: Th5uHeaderLayoutCell;
    FMovePreviewWidth: Single;
    FHeaderTouch: Boolean;
    FMoveCursor: TCursor;
    FResizingColumn: Th5uGridColumn;
    FResizeStartX: Single;
    FResizeOriginalWidth: Integer;
    FResizeCursorActive: Boolean;
    FResizeCursor: TCursor;
    FHeaderInteraction: Boolean;
    FOnRowsMoved: Th5uRowsMovedEvent;
    FLastNotifiedCell: Th5uCellAddress;
    function FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean = False): Boolean;
    function FocusedCellHit(out AHit: Th5uFmxHitTestInfo): Boolean;
    function CellHit(const LCell: Th5uCellAddress; out AHit: Th5uFmxHitTestInfo): Boolean;
    procedure EditFocusedCell(AAutomatic: Boolean);
    function NavigationRowExtent(ARow: Int64): Double;
    function HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
    procedure SearchCharacter(AChar: Char);
  private
    FTextSize: Single;

    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintBackground: TRectangle;
    FThumbHintTimer: TTimer;
    FEditorBackground: TRectangle;
    FTouchTracking, FTouchScrolling, FGesturePanning, FDispatchingTouch: Boolean;
    FTouchOrigin, FTouchOffset: TPointF;
    FTouchShift: TShiftState;
    FEditor: TEdit;
    FDateEditor: TCustomDateTimeEdit;
    FCalendarEditor: TDateEdit;
    FClockEditor: TTimeEdit;
    FDateEditorKind: Th5uColumnEditorKind;
    FDateEditorOriginal: TDateTime;
    FDateEditorWasEmpty: Boolean;
    FImageEditor: TObject;
    FEditRowIndex: Int64;
    FEditRowKey: Th5uRowKey;
    FEditColumn: Th5uGridColumn;
    FCommittingEditor: Boolean;
    FEditorOriginalText: string;
    FEditorExitBlocked: Boolean;

    FHorizontalOffset: Single;
    FVerticalOffset: Single;
    FAllColumns: TArray<Th5uFmxVisibleColumnInfo>;
    FVisibleColumns: TArray<Th5uFmxVisibleColumnInfo>;
    FVisibleRows: TArray<Th5uFmxVisibleRowInfo>;
    FCellPool: TObjectList<Th5uFmxVisualCell>;
    FRowHeightCache: TDictionary<string, Single>;
    FUpdatingScrollBars: Boolean;
    FInitialized: Boolean;
    FLastMousePoint: TPointF;

    FOnGetRowHeight: Th5uFmxGetRowHeightEvent;
    FOnGetRowSpacing: Th5uFmxGetRowSpacingEvent;
    FOnGetThumbHint: Th5uFmxGetThumbHintEvent;
    FOnAfterDraw: Th5uFmxAfterDrawEvent;
    FOnPrepareElement: Th5uFmxPrepareElementEvent;
    FOnCustomDraw: Th5uFmxCustomDrawEvent;
    FOnGetTreeLevel: Th5uGetTreeLevelEvent;
    FOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    FOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    FOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;

    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Single; AShift: TShiftState);
    procedure UpdateSelectionDrag(X, Y: Single);
    procedure EndSelectionDrag;
    function ColumnResizeAt(X, Y: Single; ATouch: Boolean): Th5uGridColumn;
    function IsResizeHeaderEdge(AX, AY: Double): Boolean;
    function BeginColumnResize(X, Y: Single; ATouch: Boolean): Boolean;
    procedure UpdateColumnResize(X: Single);
    procedure SetResizeCursor(AActive: Boolean);
    procedure SelectRightClickCell(const AHit: Th5uFmxHitTestInfo);
    function IsRowMoveGesture(AShift: TShiftState): Boolean;
    function GetHeaderCellBounds(ACell: Th5uHeaderLayoutCell): TRectF;
    function GetHeaderCellViewport(ACell: Th5uHeaderLayoutCell): TRectF;
    function HeaderCellAtPoint(X, Y: Single): Th5uHeaderLayoutCell;
    function BeginColumnMove(AColumnIndex: Integer; X, Y: Single): Boolean;
    function BeginRowMove(ARowIndex: Int64; X, Y: Single): Boolean;
    procedure UpdateHeaderMove(X, Y: Single);
    function FinishHeaderMove(X, Y: Single): Boolean;
    function GetColumnMoveHeaderBounds(const AInfo: Th5uFmxVisibleColumnInfo): TRectF;
    function ColumnMoveTarget(X, Y: Single; out ANewIndex: Integer; out AMarkerX, AMarkerTop: Single): Boolean;
    function CanMoveColumn(AColumn: Th5uGridColumn): Boolean;
    function IsColumnMoveGesture(AColumn: Th5uGridColumn; AShift: TShiftState): Boolean;
    procedure SelectHeaderRange(AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
    procedure SelectionChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    function GetCheckBoxRect(const ABounds: TRectF): TRectF;
    function GetColumnViewportRect(AColumn: Th5uGridColumn): TRectF;
    function GetVisibleCellBounds(AColumn: Th5uGridColumn; const AColumnBounds, ARowBounds: TRectF): TRectF;
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);

    procedure SetColumns(const AValue: Th5uGridColumns);
    procedure SetHeaderLayout(const AValue: Th5uHeaderLayout);
    procedure SetDataController(const AValue: Th5uCustomDataController);
    procedure SetSharedClassFactory(const AValue: Th5uClassFactory);
    procedure SetRowHeight(const AValue: Th5uRowHeightOptions);
    procedure SetScrolling(const AValue: Th5uScrollingOptions);
    procedure SetScrollHints(const AValue: Th5uScrollHintOptions);
    procedure SetRowStyles(const AValue: Th5uRowStyleOptions);
    procedure SetCustomization(const AValue: Th5uCustomizationOptions);
    procedure SetSpacing(const AValue: Th5uGridSpacingOptions);
    procedure SetAppearance(const AValue: Th5uGridAppearanceOptions);
    procedure SetTree(const AValue: Th5uTreeOptions);
    procedure SetAdjacentGroupFolding(const AValue: Th5uAdjacentGroupFoldingOptions);
    procedure SetSelection(const AValue: Th5uGridSelection);
    procedure SetTheme(const AValue: Th5uGridTheme);
    procedure SetGridLines(const AValue: Boolean);

    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);

    function GetUnpaddedViewportRect: TRectF;
    function GetViewportRect: TRectF;
    function GetDataViewportRect: TRectF;
    function GetHeaderHeight: Single;
    function GetTotalColumnWidth: Single;
    function GetEffectiveColumnRightSpacing(AColumn: Th5uGridColumn): Single;
    procedure InvalidateAdjacentGroupMap(AClearStates: Boolean = False);
    procedure EnsureAdjacentGroupMap;
    function ResolveAdjacentGroupFieldName: string;
    function TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
    function GetViewRowCount: Int64;
    function MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean = False): Int64;
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    function GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
    function IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
    procedure PrepareViewRange(AFirstViewRow, ACount: Int64);
    function TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
    function GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
    function GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Single;
    function TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
    function GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
    function GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out AElementKind: Th5uElementKind; out AColor: TAlphaColor; out AStyleName: string;
      out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Single;
    function GetGridLines: Boolean;
    function ResolveColor(const AColor: TColor; AFallback: TAlphaColor): TAlphaColor;
    function ResolveDefaultCellColor: TAlphaColor;
    function ResolveRowSpacingColor: TAlphaColor;
    function ResolveColumnSpacingColor: TAlphaColor;
    function ResolveContentPaddingColor: TAlphaColor;
    function ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TAlphaColor;
    function ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TAlphaColor;
    function GetEstimatedTotalRowHeight: Double;
    function CanUpdateLayout: Boolean;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCell;

    procedure DrawContentPadding;
    procedure DrawCustomHeaderLayout;
    procedure DrawHeaders;
    procedure DrawColumnMoveFeedback;
    procedure DrawRows;
    procedure DrawSpacingRect(const ABounds: TRectF; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AColor: TAlphaColor;
      const AStyleName: string = ''; ATreeLevel: Integer = -1; AClosedTreeLevels: Integer = 0);
    function GetAdjacentGroupGlyphRect(const ARowInfo: Th5uFmxVisibleRowInfo): TRectF;
    procedure DrawAdjacentGroupGlyph(const ARowInfo: Th5uFmxVisibleRowInfo; ASelected: Boolean);
    function GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AAllowMeasure: Boolean = True): Single;
    function MeasureCellHeight(AViewRowIndex: Int64; AColumn: Th5uGridColumn): Single;
    function FindFirstVisibleRow(AOffset: Double; out ATop: Single): Int64;
    function ResolveRowBackground(AViewRowIndex: Int64): TAlphaColor;
    function ResolveCellAppearance(AViewRowIndex: Int64; AColumn: Th5uGridColumn; ASelected, AFocused: Boolean): Th5uResolvedAppearance;

    function BuildThumbHintText(AAxis: Th5uScrollAxis; out AContext: Th5uFmxThumbHintContext): string;
    procedure ShowThumbHint(AAxis: Th5uScrollAxis);
    procedure HideThumbHint;

    procedure StartDateEdit(const AHit: Th5uFmxHitTestInfo; AKind: Th5uColumnEditorKind);
    function DateEditorValue: TValue;
    function DateEditorVisible: Boolean;
    procedure StartEdit(const AHit: Th5uFmxHitTestInfo);
    function TryFocusCell(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean;
    function AllowCellEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
    function GetCellValue(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
    function GetCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
    procedure PutCellValue(AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue);
    procedure NotifyCellClick(AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
    procedure SetShowColumnModes(AValue: Boolean);
    procedure GetColumnMode(AColumn: Th5uGridColumn; var AMode: string);
    function ColumnModeSymbols(AColumn: Th5uGridColumn): string;
    procedure PrepareGridCanvas(const ABounds: TRectF; AKind: Th5uElementKind);
    procedure BeginTouchScroll(const APoint: TPointF);
    procedure MoveTouchScroll(const APoint: TPointF);
    procedure ShowEditorBackground(const ABounds: TRectF);
    procedure CommitEditor;
    procedure CancelEditor;
    procedure ImageEditorCommit(Sender: TObject);
    procedure ImageEditorCancel(Sender: TObject);
    function ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;

    function GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCellClass; virtual;
    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
  protected
    procedure DoExit; override;
    procedure DoMouseLeave; override;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GridHitTest(X, Y: Single): Th5uFmxHitTestInfo;
    procedure InvalidateAllRowHeights;
    procedure MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
    procedure SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
    procedure ToggleAdjacentGroup(AViewRowIndex: Int64);
    procedure SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
    procedure ExpandAllAdjacentGroups;
    procedure CollapseAllAdjacentGroups;
    procedure ResetAdjacentGroupStates;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;

    property FactoryScope: Th5uFactoryScope read FFactoryScope;
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
    property StyleLookup;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;

    property DataController: Th5uCustomDataController read FDataController write SetDataController;
    property SharedClassFactory: Th5uClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Columns: Th5uGridColumns read FColumns write SetColumns;
    property HeaderLayout: Th5uHeaderLayout read FHeaderLayout write SetHeaderLayout;
    property Selection: Th5uGridSelection read FSelection write SetSelection;
    property RowHeight: Th5uRowHeightOptions read FRowHeight write SetRowHeight;
    property Scrolling: Th5uScrollingOptions read FScrolling write SetScrolling;
    property ScrollHints: Th5uScrollHintOptions read FScrollHints write SetScrollHints;
    property RowStyles: Th5uRowStyleOptions read FRowStyles write SetRowStyles;
    property Customization: Th5uCustomizationOptions read FCustomization write SetCustomization;
    property Spacing: Th5uGridSpacingOptions read FSpacing write SetSpacing;
    property Appearance: Th5uGridAppearanceOptions read FAppearance write SetAppearance;
    property Tree: Th5uTreeOptions read FTree write SetTree;
    property AdjacentGroupFolding: Th5uAdjacentGroupFoldingOptions read FAdjacentGroupFolding write SetAdjacentGroupFolding;
    property Theme: Th5uGridTheme read FTheme write SetTheme default Th5uGridTheme.ApplicationStyle;
    property HeaderRowHeight: Single read FHeaderRowHeight write FHeaderRowHeight;
    property RowIndicatorWidth: Single read FRowIndicatorWidth write FRowIndicatorWidth;
    property ShowHeader: Boolean read FShowHeader write FShowHeader default True;
    property ShowRowIndicator: Boolean read FShowRowIndicator write FShowRowIndicator default True;
    property AllowEditing: Boolean read FAllowEditing write FAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write FImmediateEdit default False;
    // Convenience switch for all grid-wide one-pixel separators.
    // Explicit per-column RightSpacing values remain independently configurable.
    property GridLines: Boolean read GetGridLines write SetGridLines default True;
    property TextSize: Single read FTextSize write FTextSize;

    property OnGetClass: Th5uGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: Th5uFmxGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: Th5uFmxGetRowSpacingEvent read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: Th5uFmxGetThumbHintEvent read FOnGetThumbHint write FOnGetThumbHint;
    property OnAfterDraw: Th5uFmxAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;
    property OnPrepareElement: Th5uFmxPrepareElementEvent read FOnPrepareElement write FOnPrepareElement;
    property OnCustomDraw: Th5uFmxCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnGetTreeLevel: Th5uGetTreeLevelEvent read FOnGetTreeLevel write FOnGetTreeLevel;
    property OnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent read FOnGetTreeBranchEnd write FOnGetTreeBranchEnd;
    property OnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent read FOnGetAdjacentGroupId write FOnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent read FOnAdjacentGroupStateChanged write FOnAdjacentGroupStateChanged;
    property OnCanFocus: Th5uCellPermissionEvent read FOnCanFocus write FOnCanFocus;
    property OnCanEdit: Th5uCellPermissionEvent read FOnCanEdit write FOnCanEdit;
    property OnValidate: Th5uCellValidateEvent read FOnValidate write FOnValidate;
    property OnGetValue: Th5uCellGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uCellSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCellClick: Th5uCellEvent read FOnCellClick write FOnCellClick;
    property OnColumnHeaderClick: Th5uCellEvent read FOnColumnHeaderClick write FOnColumnHeaderClick;
    property OnCellEnter: Th5uCellEvent read FOnCellEnter write FOnCellEnter;
    property OnCellExit: Th5uCellEvent read FOnCellExit write FOnCellExit;
    property OnRowIndicatorClick: Th5uCellEvent read FOnRowIndicatorClick write FOnRowIndicatorClick;
    property OnRowsMoved: Th5uRowsMovedEvent read FOnRowsMoved write FOnRowsMoved;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property ShowColumnModes: Boolean read FShowColumnModes write SetShowColumnModes default False;
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

uses
  FMX.Forms,
  Fmx.h5u.Grid.Editors;

function h5uRectFIntersects(const A, B: TRectF): Boolean;
begin
  Result := (A.Right > B.Left) and (A.Left < B.Right) and (A.Bottom > B.Top) and (A.Top < B.Bottom);
end;

{ Th5uFmxHitTestInfo }

class function Th5uFmxHitTestInfo.Empty: Th5uFmxHitTestInfo;
begin
  Result := Default(Th5uFmxHitTestInfo);
  Result.Kind := Th5uFmxHitKind.None;
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  Result.RowKey := Th5uRowKey.Empty;
end;

{ Th5uFmxVisualCell }

procedure Th5uFmxVisualCell.BindCell(const AContext: Th5uFactoryContext; const ABounds: TRectF; const AValue: TValue; const ADisplayText: string;
  const AAppearance: Th5uResolvedAppearance);
begin
  FContext := AContext;
  FBounds := ABounds;
  FContentBounds := ABounds;
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

procedure Th5uFmxVisualCell.PrepareCanvas(AGrid: Th5uFmxGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
var
  LContext: Th5uFmxDrawContext;
begin
  if not Assigned(AGrid.FOnPrepareElement) then
    Exit;
  LContext.FactoryContext := Context;
  LContext.Bounds := Bounds;
  LContext.DisplayText := DisplayText;
  LContext.Appearance := Appearance;
  AGrid.FOnPrepareElement(AGrid, Self, ACanvas, LContext, APart);
end;

procedure Th5uFmxGrid.PrepareGridCanvas(const ABounds: TRectF; AKind: Th5uElementKind);
var
  LContext: Th5uFmxDrawContext;
begin
  if not Assigned(FOnPrepareElement) then
    Exit;
  LContext := Default(Th5uFmxDrawContext);
  LContext.FactoryContext := Th5uFactoryContext.Create(Self, Self, FDataController, '', AKind);
  LContext.FactoryContext.ViewRowIndex := -1;
  LContext.Bounds := ABounds;
  FOnPrepareElement(Self, Self, Canvas, LContext, Th5uElementPaintPart.Background);
end;

procedure Th5uFmxVisualCell.Paint(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LContext: Th5uFmxDrawContext;
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
    AGrid.DoCustomDraw(ACanvas, LContext, Th5uFmxCustomDrawStage.BeforeDefault, LDrawDefault);
    if LDrawDefault then
      PaintDefault(AGrid, ACanvas);
    AGrid.DoCustomDraw(ACanvas, LContext, Th5uFmxCustomDrawStage.AfterDefault, LDrawDefault);
  finally
    if Assigned(LState) then
      ACanvas.RestoreState(LState);
  end;
end;

procedure Th5uFmxVisualCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LBackground: TAlphaColor;
begin
  if Appearance.HasBackground then
    LBackground := h5uColorToFmx(Appearance.Background)
  else
    LBackground := AGrid.ResolveDefaultCellColor;

  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := LBackground;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);
end;

{ Th5uFmxSpacingCell }

procedure Th5uFmxSpacingCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := h5uColorToFmx(Appearance.Background);
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);
end;

{ Th5uFmxAdjacentGroupGlyphCell }

procedure Th5uFmxAdjacentGroupGlyphCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LPalette: Th5uFmxPalette;
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
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);

  LRect.Inflate(-1, -1);
  if (LRect.Width < 7) or (LRect.Height < 7) then
    Exit;

  ACanvas.Fill.Color := LPalette.CellBackground;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := LPalette.CellText;
  ACanvas.Stroke.Thickness := 1;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
  ACanvas.DrawRect(LRect, 0, 0, AllCorners, 1);

  LMidX := (LRect.Left + LRect.Right) / 2;
  LMidY := (LRect.Top + LRect.Bottom) / 2;
  ACanvas.DrawLine(PointF(LRect.Left + 2, LMidY), PointF(LRect.Right - 2, LMidY), 1);
  if Context.AdjacentGroupCollapsed then
    ACanvas.DrawLine(PointF(LMidX, LRect.Top + 2), PointF(LMidX, LRect.Bottom - 2), 1);
end;

{ Th5uFmxDataCell }

destructor Th5uFmxDataCell.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure Th5uFmxDataCell.EnsureBitmap;
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

procedure Th5uFmxDataCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LRow: Th5uFmxVisibleRowInfo;
  LGlyph: TRectF;
  LColumn: Th5uGridColumn;
  LPalette: Th5uFmxPalette;
  LTextRect: TRectF;
  LTextColor: TAlphaColor;
  LAlign: TTextAlign;
  LCheckRect: TRectF;
  LChecked: Boolean;
  LDest: TRectF;
  LScale: Single;
  LWidth: Single;
  LHeight: Single;
begin
  inherited;
  if Context.ElementKind = Th5uElementKind.RowHeaderCell then
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
    PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);
    if LTextRect.Width > 0 then
      ACanvas.FillText(LTextRect, DisplayText, False, 1, [], LAlign, TTextAlign.Center);
    Exit;
  end;
  if not (Context.Column is Th5uGridColumn) then
    Exit;

  // Mobile edit styles can be transparent. Do not draw the old cell content
  // behind an active text/date editor, even when its style is replaced.
  if (AGrid.FEditColumn = Context.Column) and (AGrid.FEditRowIndex = Context.ViewRowIndex) and (AGrid.FEditor.Visible
    or AGrid.DateEditorVisible) then Exit;
  LColumn := Th5uGridColumn(Context.Column);
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  if Appearance.HasForeground then
    LTextColor := h5uColorToFmx(Appearance.Foreground)
  else
    LTextColor := LPalette.CellText;

  case LColumn.DataType of
    Th5uColumnDataType.Boolean:
      begin
        LCheckRect := AGrid.GetCheckBoxRect(Bounds);
        LChecked := False;
        if not Value.IsEmpty then
          if Value.Kind = tkEnumeration then
            LChecked := Value.AsBoolean
          else
            LChecked := SameText(Value.ToString, 'True') or (Value.ToString = '1');

        ACanvas.Stroke.Kind := TBrushKind.Solid;
        ACanvas.Stroke.Dash := TStrokeDash.Solid;
        ACanvas.Stroke.Thickness := 1;
        ACanvas.Stroke.Color := LTextColor;
        ACanvas.Fill.Kind := TBrushKind.Solid;
        if Appearance.HasBackground then
          ACanvas.Fill.Color := h5uColorToFmx(Appearance.Background)
        else
          ACanvas.Fill.Color := LPalette.CellBackground;
        PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
        ACanvas.FillRect(LCheckRect, 2, 2, AllCorners, 1);
        PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
        ACanvas.DrawRect(LCheckRect, 2, 2, AllCorners, 1);
        if LChecked then
        begin
          ACanvas.Stroke.Color := LTextColor;
          ACanvas.Stroke.Thickness := 2;
          PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
          ACanvas.DrawLine(PointF(LCheckRect.Left + 3, LCheckRect.Top + 8), PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), 1);
          PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
          ACanvas.DrawLine(PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), PointF(LCheckRect.Right - 2, LCheckRect.Top + 3), 1);
          ACanvas.Stroke.Thickness := 1;
        end;
      end;

    Th5uColumnDataType.Image:
      begin
        EnsureBitmap;
        if Assigned(FBitmap) and not FBitmap.IsEmpty then
        begin
          LDest := ContentBounds;
          LDest.Inflate(-4, -4);
          if LColumn.ImagePreserveAspectRatio then
          begin
            LScale := Min(LDest.Width / FBitmap.Width, LDest.Height / FBitmap.Height);
            LWidth := FBitmap.Width * LScale;
            LHeight := FBitmap.Height * LScale;
            LDest := RectF(LDest.Left + (LDest.Width - LWidth) / 2, LDest.Top + (LDest.Height - LHeight) / 2, LDest.Left + (LDest.Width - LWidth) / 2
              + LWidth, LDest.Top + (LDest.Height - LHeight) / 2 + LHeight);
          end;
          ACanvas.DrawBitmap(FBitmap, RectF(0, 0, FBitmap.Width, FBitmap.Height), LDest, 1, True);
        end;
      end;

    else
      begin
        LTextRect := ContentBounds;
        LTextRect.Inflate(-5, -2);
        ACanvas.Fill.Color := LTextColor;
        ACanvas.Font.Size := AGrid.TextSize;
        LAlign := TTextAlign.Leading;
        if LColumn.DataType in [Th5uColumnDataType.Integer, Th5uColumnDataType.Float, Th5uColumnDataType.Currency] then
          LAlign := TTextAlign.Trailing;

        PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);

        ACanvas.FillText(LTextRect, DisplayText, LColumn.WordWrap, 1, [], LAlign, TTextAlign.Center);
      end;
  end;

  if Th5uElementFlag.Focused in Context.ElementFlags then
  begin
    ACanvas.Stroke.Color := LPalette.FocusBorder;
    ACanvas.Stroke.Thickness := 2;
    PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Border);
    ACanvas.DrawRect(Bounds, 0, 0, AllCorners, 1);
    ACanvas.Stroke.Thickness := 1;
  end;
end;

{ Th5uFmxHeaderCell }

procedure Th5uFmxHeaderCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LPalette: Th5uFmxPalette;
  LRect, LSymbolRect: TRectF;
  LSymbols: string;
  LState: TCanvasSaveState;
begin
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := LPalette.HeaderBackground;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  LRect := ContentBounds;
  LRect.Inflate(-5, -2);
  ACanvas.Font.Size := AGrid.TextSize;
  ACanvas.Font.Style := [TFontStyle.fsBold];
  ACanvas.Fill.Color := LPalette.HeaderText;
  LSymbols := AGrid.ColumnModeSymbols(Th5uGridColumn(Context.Column));
  if LSymbols <> '' then
  begin
    LState := ACanvas.SaveState;
    try
      ACanvas.Fill.Color := TAlphaColorRec.Maroon;
      PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.ColumnMode);
      LSymbolRect := LRect;
      LSymbolRect.Right := Min(LSymbolRect.Right, LSymbolRect.Left + ACanvas.TextWidth(LSymbols) + 4);
      ACanvas.FillText(LSymbolRect, LSymbols, False, 1, [], TTextAlign.Leading, TTextAlign.Center);
      LRect.Left := LSymbolRect.Right + 3;
    finally
      ACanvas.RestoreState(LState);
    end;
  end;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);
  ACanvas.FillText(LRect, DisplayText, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  ACanvas.Font.Style := [];
end;

{ Th5uFmxGrid }

function Th5uFmxGrid.AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCell;
var
  LClass: Th5uFmxVisualCellClass;
  LCell: Th5uFmxVisualCell;
  LCreateContext: Th5uFactoryContext;
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
  LCreateContext.CreationReason := Th5uCreationReason.ViewportMaterialization;

  Result := Th5uFmxVisualCell(FFactoryScope.CreateInstance(LCreateContext, Th5uFmxVisualCell, LClass));
  Result.FInUse := True;
  FCellPool.Add(Result);
  FFactoryScope.BindInstance(AContext, Result);
end;

procedure Th5uFmxGrid.BeginVisualPass;
var
  LCell: Th5uFmxVisualCell;
begin
  for LCell in FCellPool do
    if LCell.FInUse then
    begin
      FFactoryScope.UnbindInstance(LCell.Context, LCell);
      LCell.FInUse := False;
    end;
end;

function Th5uFmxGrid.BuildThumbHintText(AAxis: Th5uScrollAxis; out AContext: Th5uFmxThumbHintContext): string;
var
  LTop: Single;
  LIndex: Int64;
  LColumn: Th5uGridColumn;
  LColumns: TArray<Th5uGridColumn>;
  LInfo: Th5uFmxVisibleColumnInfo;
begin
  AContext := Default(Th5uFmxThumbHintContext);
  AContext.Grid := Self;
  AContext.DataController := FDataController;
  AContext.Axis := AAxis;
  Result := '';

  if AAxis = Th5uScrollAxis.Vertical then
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
      if (LInfo.Column.FixedKind = Th5uFixedKind.None) and (LInfo.Bounds.Right > GetDataViewportRect.Left) then
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

procedure Th5uFmxGrid.BuildColumnLayout;
var
  LColumns: TArray<Th5uGridColumn>;
  LAll: TList<Th5uFmxVisibleColumnInfo>;
  LVisible: TList<Th5uFmxVisibleColumnInfo>;
  LView: TRectF;
  LDataLeft: Single;
  LDataRight: Single;
  LLeftX: Single;
  LRightX: Single;
  LNormalX: Single;
  LInfo: Th5uFmxVisibleColumnInfo;
  LVisibilityRect: TRectF;
  LSpacing: Single;
  I: Integer;
begin
  LColumns := FColumns.VisibleColumns;
  LAll := TList<Th5uFmxVisibleColumnInfo>.Create;
  LVisible := TList<Th5uFmxVisibleColumnInfo>.Create;
  try
    LView := GetViewportRect;
    LDataLeft := LView.Left;
    if FShowRowIndicator then
      LDataLeft := LDataLeft + FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
    LDataRight := LView.Right;

    LLeftX := LDataLeft;
    for I := 0 to High(LColumns) do
      if LColumns[I].FixedKind = Th5uFixedKind.Left then
        LLeftX := LLeftX + LColumns[I].Width + GetEffectiveColumnRightSpacing(LColumns[I]);

    LRightX := LDataRight;
    for I := High(LColumns) downto 0 do
      if LColumns[I].FixedKind = Th5uFixedKind.Right then
        LRightX := LRightX - LColumns[I].Width - GetEffectiveColumnRightSpacing(LColumns[I]);

    LNormalX := LLeftX - FHorizontalOffset;
    LLeftX := LDataLeft;

    for I := 0 to High(LColumns) do
    begin
      LInfo.Column := LColumns[I];
      LInfo.VisibleIndex := I;
      LSpacing := GetEffectiveColumnRightSpacing(LColumns[I]);

      case LColumns[I].FixedKind of
        Th5uFixedKind.Left:
          begin
            LInfo.Bounds := RectF(LLeftX, LView.Top, LLeftX + LColumns[I].Width, LView.Bottom);
            LLeftX := LLeftX + LColumns[I].Width + LSpacing;
          end;

        Th5uFixedKind.Right:
          begin
            LInfo.Bounds := RectF(LRightX, LView.Top, LRightX + LColumns[I].Width, LView.Bottom);
            LRightX := LRightX + LColumns[I].Width + LSpacing;
          end;

        else
          begin
            LInfo.Bounds := RectF(LNormalX, LView.Top, LNormalX + LColumns[I].Width, LView.Bottom);
            LNormalX := LNormalX + LColumns[I].Width + LSpacing;
          end;
      end;

      LAll.Add(LInfo);
      LVisibilityRect := LInfo.Bounds;
      LVisibilityRect.Right := LVisibilityRect.Right + LSpacing;
      if h5uRectFIntersects(LVisibilityRect, LView) then
        LVisible.Add(LInfo);
    end;

    FAllColumns := LAll.ToArray;
    FVisibleColumns := LVisible.ToArray;
  finally
    LVisible.Free;
    LAll.Free;
  end;
end;

procedure Th5uFmxGrid.CancelEditor;
begin
  // Hiding a focused editor can synchronously invoke EditorExit.
  FEditRowIndex := -1;
  FEditColumn := nil;
  if Assigned(FDateEditor) then
    FDateEditor.Visible := False;
  FDateEditor := nil;
  if Assigned(FEditorBackground) then FEditorBackground.Visible := False;
  if Assigned(FEditor) then
    FEditor.Visible := False;
  if Assigned(FImageEditor) then
    Th5uFmxImageEditor(FImageEditor).Visible := False;
end;

procedure Th5uFmxGrid.SetShowColumnModes(AValue: Boolean);
begin
  if FShowColumnModes = AValue then
    Exit;
  FShowColumnModes := AValue;
  Repaint;
end;

procedure Th5uFmxGrid.GetColumnMode(AColumn: Th5uGridColumn; var AMode: string);
begin
  AMode := h5uColumnMode(AColumn, FDataController, FTree.LevelColumnId, FAdjacentGroupFolding.IdColumnId,
    FRowStyles.StyleKeyColumnId, FScrollHints.VerticalColumnId);
end;

function Th5uFmxGrid.ColumnModeSymbols(AColumn: Th5uGridColumn): string;
begin
  Result := '';
  if Assigned(AColumn) and (FShowColumnModes or (csDesigning in ComponentState)) then
    Result := h5uColumnModeSymbols(AColumn.Mode);
end;

procedure Th5uFmxGrid.ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
begin
  InvalidateAdjacentGroupMap(False);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

function Th5uFmxGrid.TryFocusCell(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean;
var
  LColumn: Th5uGridColumn;
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

function Th5uFmxGrid.AllowCellEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
begin
  Result := False;
  if not CanUpdateLayout then
    Exit;
  Result := h5uCellPermission(Self, AColumn, ARow,
    FAllowEditing and not AColumn.ReadOnly and CanEditViewValue(ARow, AColumn.FieldName),
    AColumn.OnCanEdit, FOnCanEdit);
end;

function Th5uFmxGrid.GetCellValue(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
begin
  Result := GetViewValue(ARow, AColumn.FieldName);
  if CanUpdateLayout then
    h5uOverrideCellValue(Self, AColumn, ARow, ADisplay, FOnGetValue, Result);
end;

function Th5uFmxGrid.GetCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  Result := h5uCellText(AColumn, ARow, ADisplay, Assigned(AColumn.OnGetValue) or Assigned(FOnGetValue),
    GetCellValue, GetViewValue, GetViewDisplayText);
end;

procedure Th5uFmxGrid.PutCellValue(AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue);
var
  LValue: TValue;
begin
  if not CanUpdateLayout then
    Exit;
  LValue := h5uPrepareCellValue(Self, AColumn, ARow, AValue, FOnValidate, FOnSetValue);
  SetViewValue(ARow, AColumn.FieldName, LValue);
end;

procedure Th5uFmxGrid.NotifyCellClick(AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
begin
  if CanUpdateLayout then
    h5uNotifyCellClick(Self, AColumn, ARow, AHeader, AIndicator, FOnCellClick, FOnColumnHeaderClick, FOnRowIndicatorClick);
end;

procedure Th5uFmxGrid.CommitEditor;
var
  LValue: TValue;
begin
  if FCommittingEditor or (not FEditor.Visible and not DateEditorVisible) or not Assigned(FEditColumn) or not Assigned(FDataController) then
    Exit;

  if (DateEditorVisible and (DateEditorValue.IsEmpty = FDateEditorWasEmpty) and (FDateEditor.DateTime = FDateEditorOriginal))
    or (not DateEditorVisible and (FEditor.Text = FEditorOriginalText))
  then
  begin
    CancelEditor;
    Exit;
  end;

  FCommittingEditor := True;
  try
    try
      if DateEditorVisible then
        LValue := DateEditorValue
      else
        if Assigned(FEditColumn.OnSetValue) or Assigned(FOnSetValue) then
          LValue := TValue.From<string>(FEditor.Text)
        else
          LValue := ParseEditorValue(FEditColumn, FEditor.Text);
      PutCellValue(FEditColumn, FEditRowIndex, LValue);
      CancelEditor;
      InvalidateAllRowHeights;
      Repaint;
    except
      FEditorExitBlocked := True;
      raise;
    end;
  finally
    FCommittingEditor := False;
  end;
end;

constructor Th5uFmxGrid.Create(AOwner: TComponent);
begin
  inherited;

  FFactoryScope := Th5uFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FFactoryScope.RegisterClass(h5uClassIdGridDataCell, Th5uFmxVisualCell, Th5uFmxDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridFixedCell, Th5uFmxVisualCell, Th5uFmxDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderCell, Th5uFmxVisualCell, Th5uFmxHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderGroupCell, Th5uFmxVisualCell, Th5uFmxHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupFoldGlyph, Th5uFmxVisualCell, Th5uFmxAdjacentGroupGlyphCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupEndBand, Th5uFmxVisualCell, Th5uFmxSpacingCell);

  FColumns := Th5uGridColumns.Create(Self);
  FColumns.OnChanged := ColumnsChanged;
  FColumns.OnGetMode := GetColumnMode;
  FHeaderLayout := Th5uHeaderLayout.Create(Self);
  FLastNotifiedCell := Th5uCellAddress.Empty;
  FSelection := Th5uGridSelection.Create;
  FSelection.OnChanged := SelectionChanged;
  FRowHeight := Th5uRowHeightOptions.Create;
  FRowHeight.OnChanged := OptionsChanged;
  FScrolling := Th5uScrollingOptions.Create;
  FScrolling.OnChanged := OptionsChanged;
  FScrollHints := Th5uScrollHintOptions.Create;
  FScrollHints.OnChanged := OptionsChanged;
  FRowStyles := Th5uRowStyleOptions.Create;
  FRowStyles.OnChanged := OptionsChanged;
  FCustomization := Th5uCustomizationOptions.Create;
  FSpacing := Th5uGridSpacingOptions.Create;
  FSpacing.OnChanged := OptionsChanged;
  FAppearance := Th5uGridAppearanceOptions.Create;
  FAppearance.OnChanged := OptionsChanged;
  FTree := Th5uTreeOptions.Create;
  FTree.OnChanged := OptionsChanged;
  FAdjacentGroupFolding := Th5uAdjacentGroupFoldingOptions.Create;
  FAdjacentGroupFolding.OnChanged := OptionsChanged;
  FAdjacentGroupMap := Th5uAdjacentGroupMap.Create;
  FAdjacentGroupMapDirty := True;
  FDataLink := Th5uDataControllerLink.Create;
  FDataLink.OnChanged := DataChanged;
  FCellPool := TObjectList<Th5uFmxVisualCell>.Create(True);
  FRowHeightCache := TDictionary<string, Single>.Create;

  FTheme := Th5uGridTheme.ApplicationStyle;
  FHeaderRowHeight := 28;
  FRowIndicatorWidth := 38;
  FShowHeader := True;
  FShowRowIndicator := True;
  FAllowEditing := True;
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

  FEditorBackground := TRectangle.Create(Self);
  FEditorBackground.Stored := False;
  FEditorBackground.Parent := Self;
  FEditorBackground.Visible := False;
  FEditorBackground.HitTest := False;
  FEditorBackground.Stroke.Kind := TBrushKind.None;
  FEditorBackground.Fill.Kind := TBrushKind.Solid;

  Touch.DefaultInteractiveGestures := Touch.DefaultInteractiveGestures + [TInteractiveGesture.Pan];
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.Pan];
  FEditor := Th5uCellTextEdit.Create(Self);
  FEditor.Stored := False;
  FEditor.Parent := Self;
  FEditor.Visible := False;
  FEditor.OnExit := EditorExit;
  FEditor.OnChange := EditorChanged;
  FEditor.OnKeyDown := EditorKeyDown;

  FInitialized := True;
  CanFocus := True;
  ClipChildren := True;
  SetSize(640, 320);
  LayoutScrollBars;
end;

procedure Th5uFmxGrid.DataChanged(Sender: TObject; const AChange: Th5uDataChange);
begin
  // Unknown row changes may reorder positional keys; abandon the pending drop.
  if (Length(FMovingRowKeys) > 0) and (AChange.Kind <> Th5uDataChangeKind.CellChanged) then
    EndSelectionDrag;
  InvalidateAdjacentGroupMap(not FAdjacentGroupFolding.PreserveStateOnDataChange);
  // Live updates must not discard an in-progress draft. Cancel only when the
  // target is no longer the same row; never commit into a replacement row.
  if not FCommittingEditor and Assigned(FEditColumn) then
    if not CanUpdateLayout or FEditRowKey.IsEmpty or (FEditRowIndex < 0) or (FEditRowIndex >= GetViewRowCount) or (GetViewRowKey(FEditRowIndex) <> FEditRowKey) then
      CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

destructor Th5uFmxGrid.Destroy;
begin
  EndSelectionDrag;
  FInitialized := False;
  FDataLink.Controller := nil;
  FAdjacentGroupMap.Free;
  FAdjacentGroupFolding.Free;
  FRowHeightCache.Free;
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
  FHeaderLayout.Free;
  FColumns.Free;
  FFactoryScope.Free;
  inherited;
end;

procedure Th5uFmxGrid.DblClick;
var
  LHit: Th5uFmxHitTestInfo;
begin
  inherited;
  LHit := GridHitTest(FLastMousePoint.X, FLastMousePoint.Y);
  if (LHit.Kind = Th5uFmxHitKind.DataCell) and (((LHit.Column.EditorKind <> Th5uColumnEditorKind.Boolean)
    and not ((LHit.Column.EditorKind = Th5uColumnEditorKind.Automatic) and (LHit.Column.DataType = Th5uColumnDataType.Boolean)))
      or GetCheckBoxRect(LHit.Bounds).Contains(FLastMousePoint))
  then
    StartEdit(LHit);
end;

procedure Th5uFmxGrid.DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, ACanvas, AContext, AStage, ADrawDefault);
end;

procedure Th5uFmxGrid.DrawContentPadding;
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
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Bottom < LOuterRect.Bottom then
  begin
    LPaddingRect := RectF(LOuterRect.Left, LInnerRect.Bottom, LOuterRect.Right, LOuterRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Left > LOuterRect.Left then
  begin
    LPaddingRect := RectF(LOuterRect.Left, LInnerRect.Top, LInnerRect.Left, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Right < LOuterRect.Right then
  begin
    LPaddingRect := RectF(LInnerRect.Right, LInnerRect.Top, LOuterRect.Right, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;
end;

procedure Th5uFmxGrid.DrawCustomHeaderLayout;
var
  I, LFirst, LLast: Integer;
  LCellDef: Th5uHeaderLayoutCell;
  LRect, LDrawRect, LClip, LSeparatorRect: TRectF;
  LContext: Th5uFactoryContext;
  LCell: Th5uFmxVisualCell;
  LAppearance: Th5uResolvedAppearance;
  LClassId: Th5uClassId;
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
    LContext := Th5uFactoryContext.Create(Self, Self, FDataController, LClassId, Th5uElementKind.ColumnHeaderGroupCell);
    LContext.HeaderCell := LCellDef;
    LContext.LayoutRow := LCellDef.LayoutRow;
    LContext.LayoutColumn := LFirst;
    LContext.RowSpan := LCellDef.RowSpan;
    LContext.ColumnSpan := LLast - LFirst + 1;
    LContext.ElementFlags := [Th5uElementFlag.Header];
    if FAllColumns[LFirst].Column.FixedKind <> Th5uFixedKind.None then
      Include(LContext.ElementFlags, Th5uElementFlag.FixedColumn);
    if LCellDef.ColumnId <> '' then
    begin
      LContext.Column := FColumns.FindById(LCellDef.ColumnId);
      LContext.ElementKind := Th5uElementKind.ColumnHeaderCell;
      if FSelection.IsColumnSelected(LCellDef.ColumnId) then
        Include(LContext.ElementFlags, Th5uElementFlag.Selected);
    end;
    LAppearance.Clear;
    LAppearance.StyleName := LCellDef.StyleName;
    LCell := AcquireVisualCell(LContext, Th5uFmxHeaderCell);
    LCell.BindCell(LContext, LDrawRect, TValue.Empty, LCellDef.Caption, LAppearance);
    LCell.FContentBounds := LRect;
    LCell.Paint(Self, Canvas);
    LRightSpacing := GetEffectiveColumnRightSpacing(FAllColumns[LLast].Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, FAllColumns[LLast].Column, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
    if FSpacing.RowSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Left, LRect.Bottom, LRect.Right + LRightSpacing, LRect.Bottom + FSpacing.RowSpacing);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.RowSpacing, Th5uGridColumn(LContext.Column), -1, Th5uRowKey.Empty, ResolveRowSpacingColor);
    end;
  end;
end;

procedure Th5uFmxGrid.DrawHeaders;
var
  LInfo: Th5uFmxVisibleColumnInfo;
  LRect: TRectF;
  LDrawRect: TRectF;
  LSeparatorRect: TRectF;
  LContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uFmxVisualCell;
  LPalette: Th5uFmxPalette;
  LClassId: Th5uClassId;
  LSpacing: Single;
begin
  if not FShowHeader then
    Exit;

  LPalette := h5uGetFmxPalette(FTheme);
  LRect := RectF(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Right, GetViewportRect.Top + GetHeaderHeight);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := LPalette.HeaderBackground;
  Canvas.FillRect(LRect, 0, 0, AllCorners, 1);

  if FShowRowIndicator then
  begin
    LRect := RectF(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Left + FRowIndicatorWidth, GetViewportRect.Top + GetHeaderHeight);
    LContext := Th5uFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridHeaderCell, Th5uElementKind.CornerCell);
    LContext.ElementFlags := [Th5uElementFlag.Header, Th5uElementFlag.Corner, Th5uElementFlag.FixedColumn];
    LAppearance.Clear;
    LCell := AcquireVisualCell(LContext, Th5uFmxHeaderCell);
    LCell.BindCell(LContext, LRect, TValue.Empty, '', LAppearance);
    LCell.Paint(Self, Canvas);

    if FSpacing.DefaultColumnRightSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + FSpacing.DefaultColumnRightSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, GetViewportRect);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, nil, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
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
    LRect.Bottom := LRect.Top + FHeaderRowHeight;

    LDrawRect := TRectF.Intersect(LRect, GetColumnViewportRect(LInfo.Column));
    if not LDrawRect.IsEmpty then
    begin
      LClassId := LInfo.Column.HeaderCellClassId;
      if string(LClassId) = '' then
        LClassId := h5uClassIdGridHeaderCell;

      LContext := Th5uFactoryContext.Create(Self, Self, FDataController, LClassId, Th5uElementKind.ColumnHeaderCell);
      LContext.Column := LInfo.Column;
      LContext.LayoutColumn := LInfo.VisibleIndex;
      LContext.ElementFlags := [Th5uElementFlag.Header];
      if LInfo.Column.FixedKind <> Th5uFixedKind.None then
        Include(LContext.ElementFlags, Th5uElementFlag.FixedColumn);
      if FSelection.IsColumnSelected(LInfo.Column.Id) then
        Include(LContext.ElementFlags, Th5uElementFlag.Selected);

      LAppearance.Clear;
      LAppearance.StyleName := LInfo.Column.HeaderStyleName;
      LCell := AcquireVisualCell(LContext, Th5uFmxHeaderCell);
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
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, LInfo.Column, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FSpacing.RowSpacing > 0 then
  begin
    LSeparatorRect := RectF(GetViewportRect.Left, GetViewportRect.Top + FHeaderRowHeight, GetViewportRect.Right, GetViewportRect.Top + FHeaderRowHeight + FSpacing.RowSpacing);
    DrawSpacingRect(LSeparatorRect, Th5uElementKind.RowSpacing, nil, -1, Th5uRowKey.Empty, ResolveRowSpacingColor);
  end;
end;

function Th5uFmxGrid.GetAdjacentGroupGlyphRect(const ARowInfo: Th5uFmxVisibleRowInfo): TRectF;
var
  LInfo: Th5uAdjacentGroupRowInfo;
  LLeft: Single;
  LTop: Single;
  LSize: Single;
begin
  Result := RectF(0, 0, 0, 0);
  if not FAdjacentGroupFolding.Enabled or not FAdjacentGroupFolding.ShowFoldGlyph 
    or not TryGetAdjacentGroupRowInfo(ARowInfo.RowIndex, LInfo) or not LInfo.IsFoldable or not LInfo.IsFirstRow
  then
    Exit;

  LSize := Min(13, Max(9, ARowInfo.Bounds.Height - 8));
  LTop := ARowInfo.Bounds.Top + (ARowInfo.Bounds.Height - LSize) / 2;
  if FShowRowIndicator then
    LLeft := GetViewportRect.Left + 4
  else if Length(FVisibleColumns) > 0 then
    LLeft := Max(GetDataViewportRect.Left + 3, FVisibleColumns[0].Bounds.Left + 3)
  else
    Exit;

  Result := RectF(LLeft, LTop, LLeft + LSize, LTop + LSize);
  Result := TRectF.Intersect(Result, GetDataViewportRect);
end;

procedure Th5uFmxGrid.DrawAdjacentGroupGlyph(const ARowInfo: Th5uFmxVisibleRowInfo; ASelected: Boolean);
var
  LBounds: TRectF;
  LContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uFmxVisualCell;
begin
  LBounds := GetAdjacentGroupGlyphRect(ARowInfo);
  if LBounds.IsEmpty then
    Exit;

  LContext := Th5uFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridAdjacentGroupFoldGlyph, Th5uElementKind.AdjacentGroupFoldGlyph);
  LContext.RowKey := ARowInfo.RowKey;
  LContext.ViewRowIndex := ARowInfo.RowIndex;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARowInfo.RowIndex);
  PopulateAdjacentGroupContext(LContext, ARowInfo.RowIndex);
  if ASelected then
    Include(LContext.ElementFlags, Th5uElementFlag.Selected);

  LAppearance.Clear;
  if ASelected then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := AlphaColorToColor(h5uGetFmxPalette(FTheme).SelectedBackground);
  end;

  LCell := AcquireVisualCell(LContext, Th5uFmxAdjacentGroupGlyphCell);
  LCell.BindCell(LContext, LBounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

procedure Th5uFmxGrid.DrawRows;
var
  LDataRect: TRectF;
  LTop: Single;
  LRowIndex: Int64;
  LRowCount: Int64;
  LHeight: Single;
  LRowSpacing: Single;
  LRowRect: TRectF;
  LSeparatorRect: TRectF;
  LRowKey: Th5uRowKey;
  LRows: TList<Th5uFmxVisibleRowInfo>;
  LRowInfo: Th5uFmxVisibleRowInfo;
  LColumnInfo: Th5uFmxVisibleColumnInfo;
  LCellRect: TRectF;
  LContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uFmxVisualCell;
  LValue: TValue;
  LSelected: Boolean;
  LRowSelected: Boolean;
  LFocused: Boolean;
  LIndicatorRect: TRectF;
  LPalette: Th5uFmxPalette;
  LColumnSpacing: Single;
  LRowSeparatorKind: Th5uElementKind;
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
  LRows := TList<Th5uFmxVisibleRowInfo>.Create;
  LPalette := h5uGetFmxPalette(FTheme);
  try
    while (LRowIndex < LRowCount) and (LTop < LDataRect.Bottom + FScrolling.OverscanRows * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing)) do
    begin
      LRowKey := GetViewRowKey(LRowIndex);
      LHeight := GetRowHeightFor(LRowIndex, LRowKey);
      LRowSpacing := GetEffectiveRowSeparatorFor(LRowIndex, LRowKey, LRowSeparatorKind, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel, LClosedTreeLevels);
      LRowRect := RectF(LDataRect.Left, LTop, LDataRect.Right, LTop + LHeight);

      LRowInfo.RowIndex := LRowIndex;
      LRowInfo.RowKey := LRowKey;
      LRowInfo.Bounds := LRowRect;
      LRowInfo.Height := LHeight;
      LRows.Add(LRowInfo);

      if h5uRectFIntersects(LRowRect, LDataRect) then
      begin
        LRowSelected := FSelection.IsRowSelected(LRowKey);
        if FShowRowIndicator then
        begin
          LIndicatorRect := RectF(LDataRect.Left, LRowRect.Top, LDataRect.Left + FRowIndicatorWidth, LRowRect.Bottom);
          LContext := Th5uFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridFixedCell, Th5uElementKind.RowHeaderCell);
          LContext.ViewRowIndex := LRowIndex;
          LContext.RowKey := LRowKey;
          LContext.ElementFlags := [Th5uElementFlag.FixedColumn];
          LAppearance.Clear;
          LAppearance.HasBackground := True;
          LAppearance.Background := AlphaColorToColor(LPalette.FixedBackground);
          LCell := AcquireVisualCell(LContext, Th5uFmxDataCell);
          LCell.BindCell(LContext, TRectF.Intersect(LIndicatorRect, LDataRect), TValue.Empty, IntToStr(LRowIndex + 1), LAppearance);
          LCell.Paint(Self, Canvas);
          if FSpacing.DefaultColumnRightSpacing > 0 then
          begin
            LSeparatorRect := RectF(LIndicatorRect.Right, LIndicatorRect.Top, LIndicatorRect.Right + FSpacing.DefaultColumnRightSpacing, LIndicatorRect.Bottom);
            LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
            if not LSeparatorRect.IsEmpty then
              DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, nil, LRowIndex, LRowKey, ResolveColumnSpacingColor);
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

            LContext := Th5uFactoryContext.Create(Self, Self, FDataController, LColumnInfo.Column.CellClassId, Th5uElementKind.DataCell);
            if string(LContext.ClassId) = '' then
              LContext.ClassId := h5uClassIdGridDataCell;
            LContext.Column := LColumnInfo.Column;
            LContext.RowKey := LRowKey;
            LContext.ViewRowIndex := LRowIndex;
            LContext.SourceRowIndex := GetViewSourceRowIndex(LRowIndex);
            PopulateAdjacentGroupContext(LContext, LRowIndex);
            if LSelected then
              Include(LContext.ElementFlags, Th5uElementFlag.Selected);
            if LFocused then
              Include(LContext.ElementFlags, Th5uElementFlag.Focused);
            if LColumnInfo.Column.FixedKind <> Th5uFixedKind.None then
              Include(LContext.ElementFlags, Th5uElementFlag.FixedColumn);

            LValue := GetCellValue(LColumnInfo.Column, LRowIndex, True);
            LContext.Value := LValue;
            LAppearance := ResolveCellAppearance(LRowIndex, LColumnInfo.Column, LSelected, LFocused);

            LCell := AcquireVisualCell(LContext, Th5uFmxDataCell);
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
              DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, LColumnInfo.Column, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
        end;
        if not FShowRowIndicator then
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);
      end;

      if LRowSpacing > 0 then
      begin
        LSeparatorRect := RectF(LDataRect.Left, LRowRect.Bottom, LDataRect.Right, LRowRect.Bottom + LRowSpacing);
        LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
        if not LSeparatorRect.IsEmpty then
          DrawSpacingRect(LSeparatorRect, LRowSeparatorKind, nil, LRowIndex, LRowKey, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel, LClosedTreeLevels);
      end;

      LTop := LTop + LHeight + LRowSpacing;
      Inc(LRowIndex);
    end;

    FVisibleRows := LRows.ToArray;
  finally
    LRows.Free;
  end;
end;

procedure Th5uFmxGrid.DrawSpacingRect(const ABounds: TRectF; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey;
  AColor: TAlphaColor; const AStyleName: string; ATreeLevel: Integer; AClosedTreeLevels: Integer);
var
  LClassId: Th5uClassId;
  LFactoryContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uFmxVisualCell;
begin
  if ABounds.IsEmpty then
    Exit;

  case AElementKind of
    Th5uElementKind.RowSpacing:
      LClassId := h5uClassIdGridRowSpacing;
    Th5uElementKind.ColumnSpacing:
      LClassId := h5uClassIdGridColumnSpacing;
    Th5uElementKind.TreeBranchEndBand:
      LClassId := h5uClassIdGridTreeBranchEndBand;
    Th5uElementKind.AdjacentGroupEndBand:
      LClassId := h5uClassIdGridAdjacentGroupEndBand;
    else
      LClassId := h5uClassIdGridContentPadding;
  end;

  LFactoryContext := Th5uFactoryContext.Create(Self, Self, FDataController, LClassId, AElementKind);
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
  if AElementKind = Th5uElementKind.TreeBranchEndBand then
    Include(LFactoryContext.ElementFlags, Th5uElementFlag.TreeBranchEnd);
  if AElementKind = Th5uElementKind.AdjacentGroupEndBand then
    Include(LFactoryContext.ElementFlags, Th5uElementFlag.AdjacentGroupEnd);

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

function Th5uFmxGrid.GetColumnViewportRect(AColumn: Th5uGridColumn): TRectF;
var
  LColumn: Th5uGridColumn;
begin
  Result := GetViewportRect;
  if FShowRowIndicator then
    Result.Left := Result.Left + FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
  // Scrollable columns occupy only the space between the fixed columns.
  if AColumn.FixedKind = Th5uFixedKind.None then
    for LColumn in FColumns.VisibleColumns do
      case LColumn.FixedKind of
        Th5uFixedKind.Left:
          Result.Left := Result.Left + LColumn.Width + GetEffectiveColumnRightSpacing(LColumn);
        Th5uFixedKind.Right:
          Result.Right := Result.Right - LColumn.Width - GetEffectiveColumnRightSpacing(LColumn);
      end;
  Result.Left := Min(Result.Left, Result.Right);
end;

function Th5uFmxGrid.GetVisibleCellBounds(AColumn: Th5uGridColumn; const AColumnBounds, ARowBounds: TRectF): TRectF;
begin
  // Painting, pointer hit testing and cell editors must use the same clipped
  // rectangle, including rows partially scrolled underneath the header.
  Result := GetColumnViewportRect(AColumn);
  Result.Top := ARowBounds.Top;
  Result.Bottom := ARowBounds.Bottom;
  Result := TRectF.Intersect(Result, GetDataViewportRect);
  Result := TRectF.Intersect(Result, AColumnBounds);
end;

function Th5uFmxGrid.GetCheckBoxRect(const ABounds: TRectF): TRectF;
begin
  Result := RectF(ABounds.Left + (ABounds.Width - 15) / 2, ABounds.Top + (ABounds.Height - 15) / 2, 0, 0);
  Result.Right := Result.Left + 15;
  Result.Bottom := Result.Top + 15;
end;

procedure Th5uFmxGrid.EditorChanged(Sender: TObject);
begin
  // A changed value permits another automatic commit. Showing a validation
  // dialog, and the focus changes it causes, must not retry the failed value.
  FEditorExitBlocked := False;
end;

procedure Th5uFmxGrid.EditorExit(Sender: TObject);
begin
  if DateEditorVisible and FDateEditor.IsPickerOpened then
    Exit;
  if not FCommittingEditor and not FEditorExitBlocked then
    CommitEditor;
end;

procedure Th5uFmxGrid.EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    CommitEditor;
    Key := 0;
    KeyChar := #0;
  end
  else if Key = vkEscape then
  begin
    CancelEditor;
    SetFocus;
    Key := 0;
    KeyChar := #0;
  end;
end;

function Th5uFmxGrid.FindFirstVisibleRow(AOffset: Double; out ATop: Single): Int64;
var
  LRemaining: Double;
  LIndex: Int64;
  LCount: Int64;
  LHeight: Single;
  LSpacing: Single;
  LExtent: Single;
  LKey: Th5uRowKey;
  LElementKind: Th5uElementKind;
  LColor: TAlphaColor;
  LStyleName: string;
  LTreeLevel: Integer;
  LClosedTreeLevels: Integer;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if not Assigned(FDataController) then
    Exit;

  LRemaining := Max(0.0, AOffset);
  LCount := GetViewRowCount;
  LIndex := 0;
  while LIndex < LCount do
  begin
    LKey := GetViewRowKey(LIndex);
    LHeight := GetRowHeightFor(LIndex, LKey, LCount <= 3000);
    LSpacing := GetEffectiveRowSeparatorFor(LIndex, LKey, LElementKind, LColor, LStyleName, LTreeLevel, LClosedTreeLevels);
    LExtent := LHeight + LSpacing;
    if LRemaining < LExtent then
    begin
      ATop := GetDataViewportRect.Top - LRemaining;
      Exit(LIndex);
    end;
    LRemaining := LRemaining - LExtent;
    Inc(LIndex);
  end;
end;

function Th5uFmxGrid.GetDataViewportRect: TRectF;
begin
  Result := GetViewportRect;
  Result.Top := Result.Top + GetHeaderHeight;
end;

function Th5uFmxGrid.GetEstimatedTotalRowHeight: Double;
var
  LCount: Int64;
  LIndex: Int64;
  LKey: Th5uRowKey;
  LHeight: Single;
  LSpacing: Single;
  LElementKind: Th5uElementKind;
  LColor: TAlphaColor;
  LStyleName: string;
  LTreeLevel: Integer;
  LClosedTreeLevels: Integer;
begin
  Result := 0;
  if not Assigned(FDataController) then
    Exit;

  LCount := GetViewRowCount;
  if (FRowHeight.Mode = Th5uRowHeightMode.Fixed) and not Assigned(FOnGetRowSpacing) and not (FTree.Enabled and FTree.BranchEndBand.Enabled)
    and not (FAdjacentGroupFolding.Enabled and (FAdjacentGroupFolding.EndBand.Visibility <> Th5uAdjacentGroupEndBandVisibility.Never))
  then
    Exit(LCount * (FRowHeight.FixedHeight + FSpacing.RowSpacing));

  if LCount <= 3000 then
  begin
    PrepareViewRange(0, LCount);
    for LIndex := 0 to LCount - 1 do
    begin
      LKey := GetViewRowKey(LIndex);
      if FRowHeight.Mode = Th5uRowHeightMode.Fixed then
        LHeight := FRowHeight.FixedHeight
      else
        LHeight := GetRowHeightFor(LIndex, LKey, True);
      LSpacing := GetEffectiveRowSeparatorFor(LIndex, LKey, LElementKind, LColor, LStyleName, LTreeLevel, LClosedTreeLevels);
      Result := Result + LHeight + LSpacing;
    end;
  end
  else
    Result := LCount * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);
end;

function Th5uFmxGrid.GetHeaderHeight: Single;
var
  LRows: Integer;
begin
  if not FShowHeader then Exit(0);
  LRows := 1;
  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    LRows := Max(1, FHeaderLayout.RowCount);
  Result := LRows * (FHeaderRowHeight + FSpacing.RowSpacing);
end;

function Th5uFmxGrid.GetOnConfigureInstance: Th5uConfigureInstanceEvent;
begin
  Result := FFactoryScope.OnConfigureInstance;
end;

function Th5uFmxGrid.GetOnCreateInstance: Th5uCreateInstanceEvent;
begin
  Result := FFactoryScope.OnCreateInstance;
end;

function Th5uFmxGrid.GetOnGetClass: Th5uGetClassEvent;
begin
  Result := FFactoryScope.OnGetClass;
end;

function Th5uFmxGrid.GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AAllowMeasure: Boolean): Single;
var
  LKey: string;
  LProposed: Single;
  LColumn: Th5uGridColumn;
  LCacheResult: Boolean;
  LContext: Th5uFmxGetRowHeightContext;
begin
  if FRowHeight.Mode = Th5uRowHeightMode.Fixed then
    Exit(FRowHeight.FixedHeight);

  LKey := ARowKey.ToString;
  if LKey = '' then
    LKey := '#' + IntToStr(AViewRowIndex);
  if FRowHeightCache.TryGetValue(LKey, Result) then
    Exit;

  if AAllowMeasure then
  begin
    LProposed := FRowHeight.MinHeight;
    for LColumn in FColumns.VisibleColumns do
      if LColumn.AutoHeight then
        LProposed := Max(LProposed, MeasureCellHeight(AViewRowIndex, LColumn));
  end
  else
    LProposed := FRowHeight.EstimatedHeight;

  LProposed := EnsureRange(LProposed, FRowHeight.MinHeight, FRowHeight.MaxHeight);

  LCacheResult := True;
  if Assigned(FOnGetRowHeight) then
  begin
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.IsEstimated := not AAllowMeasure;
    FOnGetRowHeight(Self, LContext, LProposed, LCacheResult);
  end;

  Result := LProposed;
  if LCacheResult then
    FRowHeightCache.AddOrSetValue(LKey, Result);
end;

function Th5uFmxGrid.GetEffectiveColumnRightSpacing(AColumn: Th5uGridColumn): Single;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := FSpacing.DefaultColumnRightSpacing;
end;

procedure Th5uFmxGrid.InvalidateAdjacentGroupMap(AClearStates: Boolean);
begin
  if AClearStates then
    FAdjacentGroupMap.ResetStates;
  FAdjacentGroupMapDirty := True;
end;

procedure Th5uFmxGrid.EnsureAdjacentGroupMap;
var
  LControllerRowIndex: Int64;
  LControllerRowCount: Int64;
  LGroupId: TValue;
  LAvailable: Boolean;
begin
  if not Assigned(FDataController) or not FAdjacentGroupFolding.Enabled then
  begin
    FAdjacentGroupMap.Clear(False);
    FAdjacentGroupMapDirty := False;
    Exit;
  end;

  if not FAdjacentGroupMapDirty then
    Exit;

  FAdjacentGroupMap.BeginBuild(FAdjacentGroupFolding.InitialState, FAdjacentGroupFolding.CaseSensitive, FAdjacentGroupFolding.GroupEmptyValues);
  LControllerRowCount := FDataController.GetRowCount;
  if LControllerRowCount > 0 then
    FDataController.PrepareRange(0, LControllerRowCount);

  for LControllerRowIndex := 0 to LControllerRowCount - 1 do
  begin
    LAvailable := TryGetAdjacentGroupIdForControllerRow(LControllerRowIndex, LGroupId);
    FAdjacentGroupMap.AddRow(LControllerRowIndex, FDataController.GetRowKey(LControllerRowIndex), LGroupId, LAvailable);
  end;
  FAdjacentGroupMap.EndBuild;
  FAdjacentGroupMapDirty := False;
end;

function Th5uFmxGrid.ResolveAdjacentGroupFieldName: string;
var
  LColumn: Th5uGridColumn;
begin
  Result := Trim(FAdjacentGroupFolding.IdColumnId);
  if Result = '' then
    Exit;

  LColumn := FColumns.FindById(Result);
  if not Assigned(LColumn) then
    LColumn := FColumns.FindByFieldName(Result);
  if Assigned(LColumn) then
    Result := LColumn.FieldName;
end;

function Th5uFmxGrid.TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
var
  LContext: Th5uAdjacentGroupIdContext;
  LFieldName: string;
begin
  AGroupId := TValue.Empty;
  Result := False;
  if not Assigned(FDataController) or not FDataController.IsRowAvailable(AControllerRowIndex) then
    Exit;

  LFieldName := ResolveAdjacentGroupFieldName;
  if LFieldName <> '' then
  begin
    AGroupId := FDataController.GetValue(AControllerRowIndex, LFieldName);
    Result := True;
  end;

  if Assigned(FOnGetAdjacentGroupId) then
  begin
    LContext := Default(Th5uAdjacentGroupIdContext);
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := FDataController.GetRowKey(AControllerRowIndex);
    LContext.ControllerRowIndex := AControllerRowIndex;
    LContext.SourceRowIndex := FDataController.GetSourceRowIndex(AControllerRowIndex);
    FOnGetAdjacentGroupId(Self, LContext, AGroupId, Result);
  end;
end;

function Th5uFmxGrid.GetViewRowCount: Int64;
begin
  if not Assigned(FDataController) then
    Exit(0);
  EnsureAdjacentGroupMap;
  if FAdjacentGroupMap.Active then
    Result := FAdjacentGroupMap.GetVisibleRowCount
  else
    Result := FDataController.GetRowCount;
end;

function Th5uFmxGrid.MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean): Int64;
begin
  Result := -1;
  if not Assigned(FDataController) or (AViewRowIndex < 0) then
    Exit;
  EnsureAdjacentGroupMap;
  if not FAdjacentGroupMap.Active then
    Exit(AViewRowIndex);

  Result := FAdjacentGroupMap.MapViewToController(AViewRowIndex);
  if (Result < 0) and AAllowLookAhead and (AViewRowIndex = FAdjacentGroupMap.GetVisibleRowCount) then
    Result := FDataController.GetRowCount;
end;

function Th5uFmxGrid.GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
var
  LControllerRowIndex: Int64;
begin
  Result := -1;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  if LControllerRowIndex >= 0 then
    Result := FDataController.GetSourceRowIndex(LControllerRowIndex);
end;

function Th5uFmxGrid.GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
var
  LControllerRowIndex: Int64;
begin
  Result := Th5uRowKey.Empty;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  if LControllerRowIndex >= 0 then
    Result := FDataController.GetRowKey(LControllerRowIndex);
end;

function Th5uFmxGrid.GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
var
  LControllerRowIndex: Int64;
begin
  Result := TValue.Empty;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := FDataController.GetValue(LControllerRowIndex, AFieldName);
end;

procedure Th5uFmxGrid.SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LControllerRowIndex: Int64;
begin
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    FDataController.SetValue(LControllerRowIndex, AFieldName, AValue);
end;

function Th5uFmxGrid.CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
var
  LControllerRowIndex: Int64;
begin
  Result := False;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := FDataController.CanEdit(LControllerRowIndex, AFieldName);
end;

function Th5uFmxGrid.GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
var
  LControllerRowIndex: Int64;
begin
  Result := '';
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    Result := FDataController.GetDisplayText(LControllerRowIndex, AFieldName, ADisplayFormat);
end;

function Th5uFmxGrid.IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
var
  LControllerRowIndex: Int64;
begin
  Result := False;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  Result := (LControllerRowIndex >= 0) and FDataController.IsRowAvailable(LControllerRowIndex);
end;

procedure Th5uFmxGrid.PrepareViewRange(AFirstViewRow, ACount: Int64);
var
  LFirstControllerRow: Int64;
  LLastControllerRow: Int64;
  LLastViewRow: Int64;
begin
  if not Assigned(FDataController) or (ACount <= 0) then
    Exit;

  LFirstControllerRow := MapViewToControllerRowIndex(AFirstViewRow);
  LLastViewRow := Min(GetViewRowCount - 1, AFirstViewRow + ACount - 1);
  LLastControllerRow := MapViewToControllerRowIndex(LLastViewRow);
  if (LFirstControllerRow < 0) or (LLastControllerRow < 0) then
    Exit;
  FDataController.PrepareRange(LFirstControllerRow, LLastControllerRow - LFirstControllerRow + 1);
end;

function Th5uFmxGrid.TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  EnsureAdjacentGroupMap;
  Result := FAdjacentGroupMap.Active and FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, AInfo);
end;

procedure Th5uFmxGrid.PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  if not TryGetAdjacentGroupRowInfo(AViewRowIndex, LInfo) then
    Exit;

  AContext.AdjacentGroupIndex := LInfo.GroupIndex;
  AContext.AdjacentGroupId := LInfo.GroupId;
  AContext.AdjacentGroupAnchorRowKey := LInfo.AnchorRowKey;
  AContext.AdjacentGroupRowCount := LInfo.RowCount;
  AContext.AdjacentGroupCollapsed := LInfo.Collapsed;
  AContext.AdjacentGroupFirstRow := LInfo.IsFirstRow;
  AContext.AdjacentGroupLastVisibleRow := LInfo.IsLastVisibleRow;
  if LInfo.IsFirstRow then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupFirst);
  if LInfo.IsLastVisibleRow then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupLast);
  if LInfo.Collapsed then
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupCollapsed)
  else
    Include(AContext.ElementFlags, Th5uElementFlag.AdjacentGroupExpanded);
end;

function Th5uFmxGrid.GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  Result := TryGetAdjacentGroupRowInfo(AViewRowIndex, AInfo) and AInfo.IsFoldable and AInfo.IsLastVisibleRow;
  if not Result then
    Exit;

  case FAdjacentGroupFolding.EndBand.Visibility of
    Th5uAdjacentGroupEndBandVisibility.Never:
      Result := False;
    Th5uAdjacentGroupEndBandVisibility.CollapsedOnly:
      Result := AInfo.Collapsed;
    Th5uAdjacentGroupEndBandVisibility.ExpandedOnly:
      Result := not AInfo.Collapsed;
    Th5uAdjacentGroupEndBandVisibility.Always:
      Result := True;
  end;
end;

procedure Th5uFmxGrid.DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
var
  LContext: Th5uAdjacentGroupStateChangedContext;
begin
  if not Assigned(FOnAdjacentGroupStateChanged) then
    Exit;
  LContext := Default(Th5uAdjacentGroupStateChangedContext);
  LContext.Grid := Self;
  LContext.DataController := FDataController;
  LContext.GroupId := AInfo.GroupId;
  LContext.AnchorRowKey := AInfo.AnchorRowKey;
  LContext.FirstControllerRowIndex := AInfo.ControllerRowIndex - AInfo.GroupOffset;
  LContext.RowCount := AInfo.RowCount;
  LContext.Collapsed := AInfo.Collapsed;
  FOnAdjacentGroupStateChanged(Self, LContext);
end;

function Th5uFmxGrid.GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Single;
var
  LContext: Th5uFmxGetRowHeightContext;
begin
  Result := FSpacing.RowSpacing;
  if Assigned(FOnGetRowSpacing) then
  begin
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.IsEstimated := False;
    FOnGetRowSpacing(Self, LContext, Result);
  end;
  Result := EnsureRange(Result, 0.0, 1000.0);
end;

function Th5uFmxGrid.TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
var
  LColumn: Th5uGridColumn;
  LContext: Th5uTreeLevelContext;
  LFieldName: string;
  LValue: TValue;
begin
  ALevel := 0;
  Result := False;
  if not FTree.Enabled or not Assigned(FDataController) then
    Exit;

  LFieldName := Trim(FTree.LevelColumnId);
  if LFieldName <> '' then
  begin
    LColumn := FColumns.FindById(LFieldName);
    if not Assigned(LColumn) then
      LColumn := FColumns.FindByFieldName(LFieldName);
    if Assigned(LColumn) then
      LFieldName := LColumn.FieldName;

    LValue := GetViewValue(AViewRowIndex, LFieldName);
    Result := h5uTryValueAsInteger(LValue, ALevel);
  end;

  if Assigned(FOnGetTreeLevel) then
  begin
    LContext := Default(Th5uTreeLevelContext);
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    FOnGetTreeLevel(Self, LContext, ALevel, Result);
  end;

  if Result then
    ALevel := Max(0, ALevel);
end;

function Th5uFmxGrid.GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
var
  LContext: Th5uTreeBranchEndContext;
  LCurrentAvailable: Boolean;
  LNextAvailable: Boolean;
  LNextIndex: Int64;
  LNextKey: Th5uRowKey;
  LNextLevel: Integer;
  LHasNextRow: Boolean;
begin
  Result := False;
  ATreeLevel := 0;
  AClosedTreeLevels := 0;
  if not FTree.Enabled or not Assigned(FDataController) then
    Exit;

  LCurrentAvailable := TryGetTreeLevelFor(AViewRowIndex, ARowKey, ATreeLevel);

  LNextIndex := AViewRowIndex + 1;
  LNextKey := Th5uRowKey.Empty;
  LNextLevel := ATreeLevel;
  LNextAvailable := False;
  LHasNextRow := IsViewRowAvailable(LNextIndex);

  if LHasNextRow then
  begin
    LNextKey := GetViewRowKey(LNextIndex);
    LNextAvailable := TryGetTreeLevelFor(LNextIndex, LNextKey, LNextLevel);
  end;

  if LCurrentAvailable and (ATreeLevel > 0) then
  begin
    if not LHasNextRow then
    begin
      Result := FTree.BranchEndBand.IncludeEndOfData;
      if Result then
        AClosedTreeLevels := ATreeLevel;
    end
    else if LNextAvailable and (LNextLevel < ATreeLevel) then
    begin
      Result := True;
      AClosedTreeLevels := ATreeLevel - LNextLevel;
    end;
  end;

  if Assigned(FOnGetTreeBranchEnd) then
  begin
    LContext := Default(Th5uTreeBranchEndContext);
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.NextRowKey := LNextKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    LContext.CurrentLevel := ATreeLevel;
    LContext.NextLevel := LNextLevel;
    LContext.IsEndOfData := not LHasNextRow;
    FOnGetTreeBranchEnd(Self, LContext, Result, AClosedTreeLevels);
  end;

  if Result and (AClosedTreeLevels <= 0) then
    AClosedTreeLevels := 1;
end;

function Th5uFmxGrid.GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out AElementKind: Th5uElementKind; out AColor: TAlphaColor;
  out AStyleName: string; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Single;
var
  LAdjacentInfo: Th5uAdjacentGroupRowInfo;
begin
  AElementKind := Th5uElementKind.RowSpacing;
  AColor := ResolveRowSpacingColor;
  AStyleName := '';
  ATreeLevel := -1;
  AClosedTreeLevels := 0;

  if FAdjacentGroupFolding.Enabled and GetAdjacentGroupEndBandInfo(AViewRowIndex, LAdjacentInfo) then
  begin
    Result := FAdjacentGroupFolding.EndBand.Height;
    AElementKind := Th5uElementKind.AdjacentGroupEndBand;
    AColor := ResolveAdjacentGroupEndColor(AViewRowIndex, ARowKey);
    AStyleName := FAdjacentGroupFolding.EndBand.StyleName;
    Exit;
  end;

  if FTree.Enabled and FTree.BranchEndBand.Enabled and GetTreeBranchEndInfo(AViewRowIndex, ARowKey, ATreeLevel, AClosedTreeLevels) then
  begin
    // The branch-end band replaces regular RowSpacing.
    Result := FTree.BranchEndBand.Height;
    AElementKind := Th5uElementKind.TreeBranchEndBand;
    AColor := ResolveTreeBranchEndColor(AViewRowIndex, ARowKey);
    AStyleName := FTree.BranchEndBand.StyleName;
    Exit;
  end;

  Result := GetRowSpacingFor(AViewRowIndex, ARowKey);
end;

function Th5uFmxGrid.GetGridLines: Boolean;
begin
  // Explicit per-column RightSpacing values are intentionally independent
  // from this compatibility property.
  Result := (FSpacing.Left > 0) or (FSpacing.Top > 0) or (FSpacing.Right > 0) or (FSpacing.Bottom > 0) or (FSpacing.RowSpacing > 0)
    or (FSpacing.DefaultColumnRightSpacing > 0);
end;

function Th5uFmxGrid.ResolveColor(const AColor: TColor; AFallback: TAlphaColor): TAlphaColor;
begin
  if AColor = TColorRec.SysDefault then
    Result := AFallback
  else if AColor = TColorRec.SysNone then
    Result := 0
  else
    Result := h5uColorToFmx(AColor);
end;

function Th5uFmxGrid.ResolveDefaultCellColor: TAlphaColor;
begin
  Result := ResolveColor(FAppearance.DefaultCellColor, h5uGetFmxPalette(FTheme).CellBackground);
end;

function Th5uFmxGrid.ResolveRowSpacingColor: TAlphaColor;
begin
  Result := ResolveColor(FSpacing.RowSpacingColor, h5uGetFmxPalette(FTheme).CellBorder);
end;

function Th5uFmxGrid.ResolveColumnSpacingColor: TAlphaColor;
begin
  Result := ResolveColor(FSpacing.ColumnSpacingColor, h5uGetFmxPalette(FTheme).CellBorder);
end;

function Th5uFmxGrid.ResolveContentPaddingColor: TAlphaColor;
begin
  Result := ResolveColor(FSpacing.ContentPaddingColor, h5uGetFmxPalette(FTheme).CellBorder);
end;

function Th5uFmxGrid.ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TAlphaColor;
var
  LPalette: Th5uFmxPalette;
  LStyleName: string;
begin
  if FTree.BranchEndBand.Color <> TColorRec.SysDefault then
    Exit(ResolveColor(FTree.BranchEndBand.Color, ResolveRowSpacingColor));

  LPalette := h5uGetFmxPalette(FTheme);
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

function Th5uFmxGrid.ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TAlphaColor;
var
  LPalette: Th5uFmxPalette;
  LStyleName: string;
begin
  if FAdjacentGroupFolding.EndBand.Color <> TColorRec.SysDefault then
    Exit(ResolveColor(FAdjacentGroupFolding.EndBand.Color, ResolveRowSpacingColor));

  LPalette := h5uGetFmxPalette(FTheme);
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

function Th5uFmxGrid.GetTotalColumnWidth: Single;
var
  LColumn: Th5uGridColumn;
begin
  Result := 0;
  for LColumn in FColumns.VisibleColumns do
    Result := Result + LColumn.Width + GetEffectiveColumnRightSpacing(LColumn);
  if FShowRowIndicator then
    Result := Result + FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
end;

function Th5uFmxGrid.GetUnpaddedViewportRect: TRectF;
begin
  Result := LocalRect;
  if FVScrollBar.Visible then
    Result.Right := Result.Right - FVScrollBar.Width;
  if FHScrollBar.Visible then
    Result.Bottom := Result.Bottom - FHScrollBar.Height;
end;

function Th5uFmxGrid.GetViewportRect: TRectF;
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

function Th5uFmxGrid.GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCellClass;
var
  LCacheScope: Th5uFactoryCacheScope;
begin
  Result := Th5uFmxVisualCellClass(FFactoryScope.ResolveClass(AContext, Th5uFmxVisualCell, ADefaultClass, LCacheScope));
end;

function Th5uFmxGrid.GridHitTest(X, Y: Single): Th5uFmxHitTestInfo;
var
  LFirst, LLast: Integer;
  LColumn: Th5uFmxVisibleColumnInfo;
  LRow: Th5uFmxVisibleRowInfo;
  LGlyphRect: TRectF;
begin
  Result := Th5uFmxHitTestInfo.Empty;
  if not GetViewportRect.Contains(PointF(X, Y)) then
    Exit;

  if FShowHeader and (Y < GetDataViewportRect.Top) then
  begin
    if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    begin
      Result.HeaderCell := HeaderCellAtPoint(X, Y);
      if not Assigned(Result.HeaderCell)
        or not FHeaderLayout.ColumnRange(Result.HeaderCell, FColumns.VisibleColumns, LFirst, LLast) then Exit(Th5uFmxHitTestInfo.Empty);
      Result.Kind := Th5uFmxHitKind.Header;
      Result.ColumnIndex := LFirst;
      Result.Column := FAllColumns[LFirst].Column;
      Result.Bounds := GetHeaderCellBounds(Result.HeaderCell);
      Result.Bounds := TRectF.Intersect(Result.Bounds, GetHeaderCellViewport(Result.HeaderCell));
      Exit;
    end;
    for LColumn in FVisibleColumns do
      if LColumn.Bounds.Contains(PointF(X, Y)) and GetColumnViewportRect(LColumn.Column).Contains(PointF(X, Y)) then
      begin
        Result.Kind := Th5uFmxHitKind.Header;
        Result.Column := LColumn.Column;
        Result.ColumnIndex := LColumn.VisibleIndex;
        Result.Bounds := TRectF.Intersect(LColumn.Bounds, GetColumnViewportRect(LColumn.Column));
        Result.Bounds.Top := GetViewportRect.Top;
        Result.Bounds.Bottom := Result.Bounds.Top + FHeaderRowHeight;
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
        Result.Kind := Th5uFmxHitKind.AdjacentGroupGlyph;
        Result.Bounds := LGlyphRect;
        Exit;
      end;
      if FShowRowIndicator and (X < GetDataViewportRect.Left + FRowIndicatorWidth) then
      begin
        Result.Kind := Th5uFmxHitKind.RowIndicator;
        Exit;
      end;

      for LColumn in FVisibleColumns do
        if (X >= LColumn.Bounds.Left) and (X < LColumn.Bounds.Right) and GetColumnViewportRect(LColumn.Column).Contains(PointF(X, Y)) then
        begin
          Result.Kind := Th5uFmxHitKind.DataCell;
          Result.Column := LColumn.Column;
          Result.ColumnIndex := LColumn.VisibleIndex;
          Result.Bounds := GetVisibleCellBounds(LColumn.Column, LColumn.Bounds, LRow.Bounds);
          Exit;
        end;
    end;
end;

procedure Th5uFmxGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  FThumbHintBackground.Visible := False;
end;

procedure Th5uFmxGrid.ImageEditorCancel(Sender: TObject);
begin
  CancelEditor;
  SetFocus;
end;

procedure Th5uFmxGrid.ImageEditorCommit(Sender: TObject);
var
  LImageEditor: Th5uFmxImageEditor;
begin
  if not Assigned(FDataController) or not Assigned(FEditColumn) then
    Exit;
  LImageEditor := Th5uFmxImageEditor(Sender);
  PutCellValue(FEditColumn, FEditRowIndex, TValue.From<TBytes>(LImageEditor.Bytes));
  CancelEditor;
  InvalidateAllRowHeights;
  Repaint;
end;

procedure Th5uFmxGrid.InvalidateAllRowHeights;
begin
  FRowHeightCache.Clear;
end;

function Th5uFmxGrid.CanUpdateLayout: Boolean;
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

procedure Th5uFmxGrid.Loaded;
begin
  inherited;
  LayoutScrollBars;
  // Paint refreshes data-dependent layout; FormCreate may not have run yet.
  Repaint;
end;

procedure Th5uFmxGrid.LayoutScrollBars;
const
  CScrollSize = 16;
begin
  if not CanUpdateLayout then
    Exit;
  FVScrollBar.SetBounds(Width - CScrollSize, 0, CScrollSize, Height - IfThen(FHScrollBar.Visible, CScrollSize, 0));
  FHScrollBar.SetBounds(0, Height - CScrollSize, Width - IfThen(FVScrollBar.Visible, CScrollSize, 0), CScrollSize);
  FThumbHintBackground.BringToFront;
  FEditor.BringToFront;
  if Assigned(FImageEditor) then
    Th5uFmxImageEditor(FImageEditor).BringToFront;
end;

function Th5uFmxGrid.MeasureCellHeight(AViewRowIndex: Int64; AColumn: Th5uGridColumn): Single;
var
  LRect: TRectF;
  LText: string;
  LValue: TValue;
begin
  Result := FRowHeight.MinHeight;
  if not Assigned(FDataController) then
    Exit;

  if AColumn.DataType = Th5uColumnDataType.Image then
  begin
    LValue := GetCellValue(AColumn, AViewRowIndex, True);
    if LValue.IsType<TBytes> and (Length(LValue.AsType<TBytes>) > 0) then
      Result := Min(AColumn.MaxAutoHeight, 80);
    Exit;
  end;

  LText := GetCellText(AColumn, AViewRowIndex, True);
  Canvas.Font.Size := FTextSize;
  LRect := RectF(0, 0, Max(8, AColumn.Width - 10), 10000);
  Canvas.MeasureText(LRect, LText, AColumn.WordWrap, [], TTextAlign.Leading, TTextAlign.Leading);
  Result := LRect.Height + 6;
  if AColumn.MaxAutoHeight > 0 then
    Result := Min(Result, AColumn.MaxAutoHeight);
end;

procedure Th5uFmxGrid.ShowEditorBackground(const ABounds: TRectF);
begin
  FEditorBackground.SetBounds(ABounds.Left, ABounds.Top, ABounds.Width, ABounds.Height);
  FEditorBackground.Fill.Color := h5uGetFmxPalette(FTheme).CellBackground or $FF000000;
  FEditorBackground.Visible := True;
  FEditorBackground.BringToFront;
end;

procedure Th5uFmxGrid.BeginTouchScroll(const APoint: TPointF);
begin
  FTouchTracking := True;
  FTouchScrolling := False;
  FTouchOrigin := APoint;
  FTouchOffset := PointF(FHorizontalOffset, FVerticalOffset);
end;

procedure Th5uFmxGrid.MoveTouchScroll(const APoint: TPointF);
var
  LDelta: TPointF;
begin
  if not FTouchTracking or not CanUpdateLayout then Exit;
  LDelta := FTouchOrigin - APoint;
  if not FTouchScrolling then
  begin
    if (Abs(LDelta.X) < 6) and (Abs(LDelta.Y) < 6) then Exit;
    FTouchScrolling := True;
    FClickDownHit := Th5uFmxHitTestInfo.Empty;
    CancelEditor;
  end;
  FHorizontalOffset := EnsureRange(FTouchOffset.X + LDelta.X, 0, Max(0.0, FHScrollBar.Max - FHScrollBar.ViewportSize));
  FVerticalOffset := EnsureRange(FTouchOffset.Y + LDelta.Y, 0, Max(0.0, FVScrollBar.Max - FVScrollBar.ViewportSize));
  FUpdatingScrollBars := True;
  try
    FHScrollBar.Value := FHorizontalOffset;
    FVScrollBar.Value := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
  end;
  Repaint;
end;

procedure Th5uFmxGrid.DoGesture(const EventInfo: TGestureEventInfo; var Handled: Boolean);
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
    if Assigned(FResizingColumn) then UpdateColumnResize(LPoint.X)
    else UpdateHeaderMove(LPoint.X, LPoint.Y);
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

procedure Th5uFmxGrid.DoMouseLeave;
begin
  if not Assigned(FResizingColumn) then SetResizeCursor(False);
  inherited;
end;

function Th5uFmxGrid.ColumnResizeAt(X, Y: Single; ATouch: Boolean): Th5uGridColumn;
var
  LCandidates: TArray<Th5uResizeCandidate>;
  LView: TRectF;
  I: Integer;
begin
  Result := nil;
  if not CanUpdateLayout or not FShowHeader or not FCustomization.AllowColumnResizing then
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

function Th5uFmxGrid.IsResizeHeaderEdge(AX, AY: Double): Boolean;
var
  LHeader: Th5uHeaderLayoutCell;
begin
  Result := True;
  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
  begin
    LHeader := HeaderCellAtPoint(AX - 1, AY);
    Result := Assigned(LHeader) and (Abs(GetHeaderCellBounds(LHeader).Right - AX) <= 0.1);
  end;
end;

procedure Th5uFmxGrid.SetResizeCursor(AActive: Boolean);
begin
  if AActive = FResizeCursorActive then
    Exit;
  FResizeCursorActive := AActive;
  if AActive then
  begin
    FResizeCursor := Cursor;
    Cursor := crHSplit;
  end
  else if Cursor = crHSplit then Cursor := FResizeCursor;
end;

function Th5uFmxGrid.BeginColumnResize(X, Y: Single; ATouch: Boolean): Boolean;
begin
  FResizingColumn := ColumnResizeAt(X, Y, ATouch);
  Result := Assigned(FResizingColumn);
  if not Result then
    Exit;
  FHeaderInteraction := True;
  FResizeStartX := X;
  FResizeOriginalWidth := FResizingColumn.Width;
  if not ATouch then
    SetResizeCursor(True);
  Capture;
end;

procedure Th5uFmxGrid.UpdateColumnResize(X: Single);
begin
  if not Assigned(FResizingColumn) then
    Exit;
  if CanUpdateLayout and FCustomization.AllowColumnResizing and ((Root <> nil) and (Root.Captured <> nil) and (Root.Captured.GetObject = Self)) then
    if h5uTryResizeColumn(FColumns, FResizingColumn, FResizeOriginalWidth, Round(X - FResizeStartX)) then
      Exit;
  EndSelectionDrag;
end;

procedure Th5uFmxGrid.SelectRightClickCell(const AHit: Th5uFmxHitTestInfo);
var
  LCell: Th5uCellAddress;
begin
  if not FSelection.RightClickSelect or (AHit.Kind <> Th5uFmxHitKind.DataCell) then
    Exit;
  LCell.RowIndex := AHit.RowIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.ColumnId := AHit.Column.Id;
  h5uSelectRightClick(FSelection, LCell, AHit.Column.CanSelect, TryFocusCell);
end;

function Th5uFmxGrid.CanMoveColumn(AColumn: Th5uGridColumn): Boolean;
begin
  Result := h5uCanMoveColumn(FColumns, FCustomization.AllowColumnMoving, AColumn);
end;

function Th5uFmxGrid.IsColumnMoveGesture(AColumn: Th5uGridColumn; AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(CanMoveColumn(AColumn),
    FCustomization.ColumnMovingGesture = Th5uColumnMovingGesture.AltDrag, AShift, ssTouch in AShift);
end;

function Th5uFmxGrid.IsRowMoveGesture(AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(Assigned(FOnRowsMoved) and FCustomization.AllowRowMoving,
    FCustomization.RowMovingGesture = Th5uRowMovingGesture.AltDrag, AShift);
end;

function Th5uFmxGrid.GetHeaderCellBounds(ACell: Th5uHeaderLayoutCell): TRectF;
var
  LFirst, LLast, LSpan: Integer;
begin
  Result := TRectF.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
    Exit;
  Result.Left := FAllColumns[LFirst].Bounds.Left;
  Result.Right := FAllColumns[LLast].Bounds.Right;
  Result.Top := GetViewportRect.Top + ACell.LayoutRow * (FHeaderRowHeight + FSpacing.RowSpacing);
  LSpan := Max(1, ACell.RowSpan);
  Result.Bottom := Result.Top + LSpan * FHeaderRowHeight + (LSpan - 1) * FSpacing.RowSpacing;
end;

function Th5uFmxGrid.GetHeaderCellViewport(ACell: Th5uHeaderLayoutCell): TRectF;
var
  LFirst, LLast: Integer;
begin
  Result := TRectF.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LFirst >= Length(FAllColumns)) then
    Exit;
  Result := GetColumnViewportRect(FAllColumns[LFirst].Column);
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function Th5uFmxGrid.HeaderCellAtPoint(X, Y: Single): Th5uHeaderLayoutCell;
var
  I: Integer;
  LRect: TRectF;
begin
  Result := nil;
  if not FHeaderLayout.Enabled or not FShowHeader then
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

function Th5uFmxGrid.BeginColumnMove(AColumnIndex: Integer; X, Y: Single): Boolean;
var
  LPlan: Th5uColumnMovePlan;
  LHit: Th5uFmxHitTestInfo;
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
  FMovePreviewWidth := EnsureRange(Single(LPlan.Columns[0].Width), 80, 260);
  if Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
  begin
    FMovePreviewWidth := EnsureRange(Single(LHit.Bounds.Width), 80, 260);
  end;
  FSelectionDragOrigin := PointF(X, Y);
  Capture;
  Result := True;
end;

function Th5uFmxGrid.BeginRowMove(ARowIndex: Int64; X, Y: Single): Boolean;
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

procedure Th5uFmxGrid.UpdateHeaderMove(X, Y: Single);
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

function Th5uFmxGrid.GetColumnMoveHeaderBounds(const AInfo: Th5uFmxVisibleColumnInfo): TRectF;
var
  LCell: Th5uHeaderLayoutCell;
  LFirst, LLast, I: Integer;
begin
  Result := AInfo.Bounds;
  Result.Top := GetViewportRect.Top;
  Result.Bottom := Result.Top + FHeaderRowHeight;
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
      if (AInfo.VisibleIndex >= LFirst) and (AInfo.VisibleIndex <= LLast) then Result := GetHeaderCellBounds(LCell);
    end;
  end;
  Result := TRectF.Intersect(Result, GetColumnViewportRect(AInfo.Column));
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function Th5uFmxGrid.ColumnMoveTarget(X, Y: Single; out ANewIndex: Integer; out AMarkerX, AMarkerTop: Single): Boolean;
var
  LHit: Th5uFmxHitTestInfo;
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
  if (LHit.Kind <> Th5uFmxHitKind.Header) or not Assigned(LHit.Column) then
    Exit;
  Result := h5uColumnMoveTarget(FColumns, FHeaderLayout, FCustomization, FMovingColumns, FMovingHeaderCell,
    LHit.Column, LHit.ColumnIndex, LHit.HeaderCell, ANewIndex, LAfter);
  if Result then
  begin
    AMarkerTop := LHit.Bounds.Top;
    if LAfter then
      AMarkerX := LHit.Bounds.Right
    else
      AMarkerX := LHit.Bounds.Left;
  end;
end;

procedure Th5uFmxGrid.DrawColumnMoveFeedback;
var
  LPalette: Th5uFmxPalette;
  LState: TCanvasSaveState;
  LView, LRect, LTextRect: TRectF;
  LInfo: Th5uFmxVisibleColumnInfo;
  LColumn: Th5uGridColumn;
  LMarkerX, LMarkerTop, LWidth, LHeight, LLeft, LTop, LOffset: Single;
  LNewIndex: Integer;
  LValid, LSourcePainted: Boolean;
begin
  if not FMoveDragging or (Length(FMovingColumns) = 0) or not FShowHeader then
    Exit;
  if (Root = nil) or (Root.Captured = nil) or (Root.Captured.GetObject <> Self) then
    Exit;
  if Assigned(FMovingHeaderCell) and not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
    Exit;
  LView := GetViewportRect;
  if LView.IsEmpty then Exit;
  LPalette := h5uGetFmxPalette(FTheme);
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
          if LSourcePainted and Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then Continue;
          LSourcePainted := True;
          LRect := GetColumnMoveHeaderBounds(LInfo);
          if LRect.IsEmpty then Continue;
          Canvas.Fill.Color := LPalette.SelectedBackground;
          Canvas.FillRect(LRect, 0, 0, AllCorners, 0.3);
          Canvas.Stroke.Color := LPalette.SelectedBackground;
          LRect.Inflate(-1, -1);
          if not LRect.IsEmpty then Canvas.DrawRect(LRect, 0, 0, AllCorners, 1);
        end;
    if LValid then
    begin
      LMarkerX := EnsureRange(LMarkerX, LView.Left + 2, Max(LView.Left + 2, LView.Right - 2));
      Canvas.Fill.Color := LPalette.SelectedBackground;
      Canvas.FillRect(RectF(LMarkerX - 2, LMarkerTop, LMarkerX + 2, LView.Bottom), 0, 0, AllCorners, 1);
      Canvas.FillRect(RectF(LMarkerX - 6, LMarkerTop, LMarkerX + 6, LMarkerTop + 7), 2, 2, AllCorners, 1);
    end;
    LWidth := Min(FMovePreviewWidth, Max(1, LView.Width - 8));
    LHeight := Max(30, FHeaderRowHeight);
    LOffset := 16;
    if FHeaderTouch then LOffset := 40;
    LLeft := EnsureRange(FMovePoint.X - LWidth / 2, LView.Left + 4, Max(LView.Left + 4, LView.Right - LWidth - 4));
    LTop := EnsureRange(FMovePoint.Y + LOffset, LView.Top + 4, Max(LView.Top + 4, LView.Bottom - LHeight - 4));
    LRect := RectF(LLeft, LTop, LLeft + LWidth, LTop + LHeight);
    Canvas.Fill.Color := TAlphaColorRec.Black;
    Canvas.FillRect(RectF(LRect.Left + 3, LRect.Top + 3, LRect.Right + 3, LRect.Bottom + 3), 4, 4, AllCorners, 0.25);
    if LValid then Canvas.Fill.Color := LPalette.SelectedBackground
    else Canvas.Fill.Color := LPalette.ErrorBackground;
    Canvas.FillRect(LRect, 4, 4, AllCorners, 0.95);
    Canvas.Stroke.Color := LPalette.SelectedBackground;
    Canvas.DrawRect(LRect, 4, 4, AllCorners, 1);
    if LValid then Canvas.Fill.Color := LPalette.SelectedText
    else Canvas.Fill.Color := LPalette.CellText;
    Canvas.Font.Size := FTextSize;
    Canvas.Font.Style := [TFontStyle.fsBold];
    LTextRect := LRect;
    LTextRect.Inflate(-8, -3);
    Canvas.FillText(LTextRect, FMoveCaption, False, 1, [], TTextAlign.Center, TTextAlign.Center);
  finally
    Canvas.RestoreState(LState);
  end;
end;

function Th5uFmxGrid.FinishHeaderMove(X, Y: Single): Boolean;
var
  LHit: Th5uFmxHitTestInfo;
  LMovingColumns: TArray<Th5uGridColumn>;
  LContext: Th5uRowsMovedContext;
  LNewIndex: Integer;
  LMarkerX, LMarkerTop: Single;
  LDragging, LColumnTargetValid: Boolean;
begin
  Result := (Length(FMovingColumns) > 0) or (Length(FMovingRowKeys) > 0);
  if not Result then Exit;
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
    if (Length(LMovingColumns) > 0) and (LHit.Kind = Th5uFmxHitKind.Header) and (LHit.Column = FClickDownHit.Column) then
      SelectHeaderRange(Th5uSelectionKind.Columns, -1, LHit.ColumnIndex, [])
    else if (Length(LContext.RowKeys) > 0) and (LHit.Kind = Th5uFmxHitKind.RowIndicator) and (LHit.RowKey = FClickDownHit.RowKey) then
      SelectHeaderRange(Th5uSelectionKind.Rows, LHit.RowIndex, -1, []);
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
  else if Length(LContext.RowKeys) > 0 then
  begin
    if not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving or not (LHit.Kind in [Th5uFmxHitKind.RowIndicator, Th5uFmxHitKind.DataCell]) then
    Exit;
    if not h5uRowMoveTarget(GetViewRowCount, LHit.RowIndex, LHit.RowKey, GetViewRowKey, GetViewSourceRowIndex, LContext) then
      Exit;
    FOnRowsMoved(Self, LContext);
  end;
end;

procedure Th5uFmxGrid.BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Single; AShift: TShiftState);
begin
  FSelectingRange := True;
  FSelectionDragging := False;
  FSelectionDragKind := AKind;
  FSelectionDragShift := AShift;
  FSelectionDragOrigin := PointF(X, Y);
  FSelectionDragLast := Th5uCellAddress.Empty;
  Capture;
end;

procedure Th5uFmxGrid.EndSelectionDrag;
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

procedure Th5uFmxGrid.UpdateSelectionDrag(X, Y: Single);
var
  LHit: Th5uFmxHitTestInfo;
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
begin
  if not FSelectingRange or not CanUpdateLayout then
    Exit;
  if not FSelectionDragging then
  begin
    if (Abs(X - FSelectionDragOrigin.X) < 4) and (Abs(Y - FSelectionDragOrigin.Y) < 4) then Exit;
    FSelectionDragging := True;
    FMouseEditPending := False;
  end;
  LHit := GridHitTest(X, Y);
  LCell := Th5uCellAddress.Empty;
  case FSelectionDragKind of
    Th5uSelectionKind.CellRanges:
      begin
        if (LHit.Kind <> Th5uFmxHitKind.DataCell) or not FSelection.AnchorCell.IsValid then Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
    Th5uSelectionKind.Rows:
      begin
        if not (LHit.Kind in [Th5uFmxHitKind.RowIndicator, Th5uFmxHitKind.DataCell]) then Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
      end;
    Th5uSelectionKind.Columns:
      begin
        if not (LHit.Kind in [Th5uFmxHitKind.Header, Th5uFmxHitKind.DataCell]) then Exit;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
  end;
  if (LCell.RowIndex = FSelectionDragLast.RowIndex) and (LCell.RowKey = FSelectionDragLast.RowKey) and (LCell.ColumnIndex
    = FSelectionDragLast.ColumnIndex) and (LCell.ColumnId = FSelectionDragLast.ColumnId) then Exit;
  if FSelectionDragKind = Th5uSelectionKind.CellRanges then
  begin
    if not TryFocusCell(LCell, False) then Exit;
    LRange := Th5uCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex);
    FSelection.AddCellRange(LRange, ssCtrl in FSelectionDragShift, True);
  end
  else
    SelectHeaderRange(FSelectionDragKind, LCell.RowIndex, LCell.ColumnIndex, FSelectionDragShift + [ssShift]);
  FSelectionDragLast := LCell;
end;


procedure Th5uFmxGrid.SelectHeaderRange(AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
begin
  if CanUpdateLayout then
    FNavigation.SelectHeaderRange(FColumns, FSelection, GetViewRowCount, GetViewRowKey, AKind, ARow, AColumn, AShift);
end;


procedure Th5uFmxGrid.DoExit;
begin
  EndSelectionDrag;
  inherited;
end;

procedure Th5uFmxGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LHit: Th5uFmxHitTestInfo;
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LTouch: Boolean;
begin
  EndSelectionDrag;
  LTouch := not FDispatchingTouch and (Button = TMouseButton.mbLeft) and ((ssTouch in Shift) {$IF Defined(ANDROID) or Defined(IOS)}or True{$ENDIF});
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
    FHeaderInteraction := Assigned(ColumnResizeAt(X, Y, True)) or ((LHit.Kind = Th5uFmxHitKind.Header) and IsColumnMoveGesture(LHit.Column, Shift));
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
    if FSelection.RightClickSelect then SetFocus;
    SelectRightClickCell(FClickDownHit);
    Exit;
  end;
  if Button <> TMouseButton.mbLeft then Exit;

  SetFocus;
  if BeginColumnResize(X, Y, LTouch) then Exit;
  LHit := GridHitTest(X, Y);
  case LHit.Kind of
    Th5uFmxHitKind.AdjacentGroupGlyph:
      ToggleAdjacentGroup(LHit.RowIndex);

    Th5uFmxHitKind.Header:
      begin
    if IsColumnMoveGesture(LHit.Column, Shift) then
    begin
      BeginColumnMove(LHit.ColumnIndex, X, Y);
      Exit;
    end;
    if LHit.Column.CanSelect and (Th5uSelectionKind.Columns in FSelection.AllowedKinds) then
    begin
      SelectHeaderRange(Th5uSelectionKind.Columns, -1, LHit.ColumnIndex, Shift);
      BeginSelectionDrag(Th5uSelectionKind.Columns, X, Y, Shift);
    end;
      end;

    Th5uFmxHitKind.RowIndicator:
      begin
    if IsRowMoveGesture(Shift) then
    begin
      BeginRowMove(LHit.RowIndex, X, Y);
      Exit;
    end;
    if Th5uSelectionKind.Rows in FSelection.AllowedKinds then
    begin
      SelectHeaderRange(Th5uSelectionKind.Rows, LHit.RowIndex, -1, Shift);
      BeginSelectionDrag(Th5uSelectionKind.Rows, X, Y, Shift);
    end;
      end;

    Th5uFmxHitKind.DataCell:
      begin
        LCell.RowIndex := LHit.RowIndex;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnId := LHit.Column.Id;
        if (ssShift in Shift) and FSelection.AnchorCell.IsValid then
          LRange := Th5uCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex)
        else LRange := Th5uCellRange.Create(LCell.RowIndex, LCell.RowIndex, LCell.ColumnIndex, LCell.ColumnIndex);
        if not TryFocusCell(LCell, not (ssShift in Shift)) then Exit;
          FSelection.AddCellRange(LRange, ssCtrl in Shift, ssShift in Shift);
        BeginSelectionDrag(Th5uSelectionKind.CellRanges, X, Y, Shift);
        // Wait for release: the same MouseDown can still become a range drag.
        FMouseEditPending := not (ssCtrl in Shift) and not (ssShift in Shift);
      end;
  end;
end;

procedure Th5uFmxGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LHit: Th5uFmxHitTestInfo;
  LDragged, LEdit: Boolean;
begin
  if (Button = TMouseButton.mbLeft) and Assigned(FResizingColumn) then
  begin
    try
      UpdateColumnResize(X);
    finally
      EndSelectionDrag;
    end;
    FClickDownHit := Th5uFmxHitTestInfo.Empty;
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
      FClickDownHit := Th5uFmxHitTestInfo.Empty;
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
    FClickDownHit := Th5uFmxHitTestInfo.Empty;
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
    FClickDownHit := Th5uFmxHitTestInfo.Empty;
    Exit;
  end;

  if Button <> TMouseButton.mbLeft then Exit;
  LHit := GridHitTest(X, Y);
  if (LHit.Kind = FClickDownHit.Kind) and (LHit.Column = FClickDownHit.Column) and (LHit.RowIndex = FClickDownHit.RowIndex) and (LHit.Kind
    in [Th5uFmxHitKind.DataCell, Th5uFmxHitKind.Header, Th5uFmxHitKind.RowIndicator]) then
    begin
      if LEdit and (LHit.Kind = Th5uFmxHitKind.DataCell) then
      begin
        if (LHit.Column.EditorKind = Th5uColumnEditorKind.Boolean) or ((LHit.Column.EditorKind = Th5uColumnEditorKind.Automatic)
          and (LHit.Column.DataType = Th5uColumnDataType.Boolean)) then
        begin
          if GetCheckBoxRect(FClickDownHit.Bounds).Contains(FSelectionDragOrigin)
            and GetCheckBoxRect(FClickDownHit.Bounds).Contains(PointF(X, Y)) then StartEdit(LHit);
        end
        else if FImmediateEdit then EditFocusedCell(True);
      end;
      NotifyCellClick(LHit.Column, LHit.RowIndex, LHit.Kind = Th5uFmxHitKind.Header, LHit.Kind = Th5uFmxHitKind.RowIndicator);
    end;
  FClickDownHit := Th5uFmxHitTestInfo.Empty;
end;
procedure Th5uFmxGrid.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FLastMousePoint := PointF(X, Y);
  if Assigned(FResizingColumn) then
  begin
    if ssLeft in Shift then UpdateColumnResize(X)
    else EndSelectionDrag;
    Exit;
  end;
  if FTouchTracking and not FGesturePanning then MoveTouchScroll(PointF(X, Y))
  else if not (ssLeft in Shift) then
  begin
    EndSelectionDrag;
    if not (ssTouch in Shift) then SetResizeCursor(Assigned(ColumnResizeAt(X, Y, False)));
  end
  else
  begin
    UpdateHeaderMove(X, Y);
    UpdateSelectionDrag(X, Y);
  end;
end;

procedure Th5uFmxGrid.MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
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

procedure Th5uFmxGrid.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  if not CanMoveColumn(AColumn) then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  Repaint;
end;

procedure Th5uFmxGrid.ToggleAdjacentGroup(AViewRowIndex: Int64);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  EnsureAdjacentGroupMap;
  if not FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, LInfo) or not LInfo.IsFoldable then
    Exit;

  if FAdjacentGroupMap.ToggleAtViewRow(AViewRowIndex) then
  begin
    LInfo.Collapsed := not LInfo.Collapsed;
    DoAdjacentGroupStateChanged(LInfo);
    CancelEditor;
    InvalidateAllRowHeights;
    UpdateScrollBars;
    Repaint;
  end;
end;

procedure Th5uFmxGrid.SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  EnsureAdjacentGroupMap;
  if not FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, LInfo) or not LInfo.IsFoldable then
    Exit;

  if FAdjacentGroupMap.SetCollapsedAtViewRow(AViewRowIndex, ACollapsed) then
  begin
    LInfo.Collapsed := ACollapsed;
    DoAdjacentGroupStateChanged(LInfo);
    CancelEditor;
    InvalidateAllRowHeights;
    UpdateScrollBars;
    Repaint;
  end;
end;

procedure Th5uFmxGrid.ExpandAllAdjacentGroups;
var
  I: Integer;
  LRun: Th5uAdjacentGroupRun;
  LChangedRuns: TList<Th5uAdjacentGroupRun>;
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  EnsureAdjacentGroupMap;
  LChangedRuns := TList<Th5uAdjacentGroupRun>.Create;
  try
    for I := 0 to FAdjacentGroupMap.RunCount - 1 do
    begin
      LRun := FAdjacentGroupMap.Runs[I];
      if LRun.IsFoldable and LRun.Collapsed then
        LChangedRuns.Add(LRun);
    end;

    if not FAdjacentGroupMap.ExpandAll then
      Exit;

    for LRun in LChangedRuns do
    begin
      LInfo := Th5uAdjacentGroupRowInfo.Empty;
      LInfo.ControllerRowIndex := LRun.FirstControllerRowIndex;
      LInfo.GroupOffset := 0;
      LInfo.GroupId := LRun.GroupId;
      LInfo.AnchorRowKey := LRun.AnchorRowKey;
      LInfo.RowCount := LRun.RowCount;
      LInfo.Collapsed := False;
      DoAdjacentGroupStateChanged(LInfo);
    end;
  finally
    LChangedRuns.Free;
  end;

  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure Th5uFmxGrid.CollapseAllAdjacentGroups;
var
  I: Integer;
  LRun: Th5uAdjacentGroupRun;
  LChangedRuns: TList<Th5uAdjacentGroupRun>;
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  EnsureAdjacentGroupMap;
  LChangedRuns := TList<Th5uAdjacentGroupRun>.Create;
  try
    for I := 0 to FAdjacentGroupMap.RunCount - 1 do
    begin
      LRun := FAdjacentGroupMap.Runs[I];
      if LRun.IsFoldable and not LRun.Collapsed then
        LChangedRuns.Add(LRun);
    end;

    if not FAdjacentGroupMap.CollapseAll then
      Exit;

    for LRun in LChangedRuns do
    begin
      LInfo := Th5uAdjacentGroupRowInfo.Empty;
      LInfo.ControllerRowIndex := LRun.FirstControllerRowIndex;
      LInfo.GroupOffset := 0;
      LInfo.GroupId := LRun.GroupId;
      LInfo.AnchorRowKey := LRun.AnchorRowKey;
      LInfo.RowCount := LRun.RowCount;
      LInfo.Collapsed := True;
      DoAdjacentGroupStateChanged(LInfo);
    end;
  finally
    LChangedRuns.Free;
  end;

  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure Th5uFmxGrid.ResetAdjacentGroupStates;
begin
  FAdjacentGroupMap.ResetStates;
  InvalidateAdjacentGroupMap(False);
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

function Th5uFmxGrid.IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  Result := TryGetAdjacentGroupRowInfo(AViewRowIndex, LInfo) and LInfo.IsFoldable and LInfo.Collapsed;
end;

procedure Th5uFmxGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;
  if AComponent = FDataController then
    DataController := nil;
  if AComponent = FSharedClassFactory then
    SharedClassFactory := nil;
end;

procedure Th5uFmxGrid.OptionsChanged(Sender: TObject);
begin
  if Sender = FAdjacentGroupFolding then
    InvalidateAdjacentGroupMap(False);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure Th5uFmxGrid.Paint;
var
  LPalette: Th5uFmxPalette;
  LViewport: TRectF;
begin
  if not CanUpdateLayout then
    Exit;
  inherited;
  LPalette := h5uGetFmxPalette(FTheme);
  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := LPalette.EmptyArea;
  PrepareGridCanvas(LocalRect, Th5uElementKind.Grid);
  Canvas.FillRect(LocalRect, 0, 0, AllCorners, 1);

  UpdateScrollBars;
  BuildColumnLayout;
  BeginVisualPass;

  DrawContentPadding;

  LViewport := GetViewportRect;
  Canvas.Fill.Color := ResolveDefaultCellColor;
  Canvas.Fill.Kind := TBrushKind.Solid;
  PrepareGridCanvas(LViewport, Th5uElementKind.Grid);
  Canvas.FillRect(LViewport, 0, 0, AllCorners, 1);

  DrawHeaders;
  DrawRows;
  DrawColumnMoveFeedback;
  if Assigned(FOnAfterDraw) then
    FOnAfterDraw(Self, Canvas);
end;

function Th5uFmxGrid.ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;
begin
  Result := h5uParseEditorValue(AColumn.DataType, AText, False);
end;

procedure Th5uFmxGrid.Resize;
begin
  inherited;
  if not CanUpdateLayout then
    Exit;
  LayoutScrollBars;
  UpdateScrollBars;
  Repaint;
end;

function Th5uFmxGrid.ResolveCellAppearance(AViewRowIndex: Int64; AColumn: Th5uGridColumn; ASelected, AFocused: Boolean): Th5uResolvedAppearance;
var
  LPalette: Th5uFmxPalette;
begin
  Result.Clear;
  Result.HasBackground := True;
  LPalette := h5uGetFmxPalette(FTheme);
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

function Th5uFmxGrid.ResolveRowBackground(AViewRowIndex: Int64): TAlphaColor;
var
  LPalette: Th5uFmxPalette;
  LStyle: string;
  LKeyValue: TValue;
  LKey: Integer;
  LHasKey: Boolean;
  LColumn: Th5uGridColumn;
begin
  LPalette := h5uGetFmxPalette(FTheme);
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

procedure Th5uFmxGrid.ScrollChanged(Sender: TObject);
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;

  CancelEditor;
  FVerticalOffset := FVScrollBar.Value;
  FHorizontalOffset := FHScrollBar.Value;
  if Sender = FVScrollBar then
    ShowThumbHint(Th5uScrollAxis.Vertical)
  else
    ShowThumbHint(Th5uScrollAxis.Horizontal);
  Repaint;
end;

procedure Th5uFmxGrid.SelectionChanged(Sender: TObject);
var
  LOld, LNew: Th5uCellAddress;
begin
  Repaint;
  if not CanUpdateLayout then Exit;
  LOld := FLastNotifiedCell;
  LNew := FSelection.FocusedCell;
  FLastNotifiedCell := LNew;
  h5uNotifyFocusChange(Self, FColumns, LOld, LNew, FOnCellExit, FOnCellEnter, FOnSelectionChange);
end;

procedure Th5uFmxGrid.SetColumns(const AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure Th5uFmxGrid.SetAppearance(const AValue: Th5uGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure Th5uFmxGrid.SetTree(const AValue: Th5uTreeOptions);
begin
  if Assigned(AValue) then
    FTree.Assign(AValue);
end;

procedure Th5uFmxGrid.SetAdjacentGroupFolding(const AValue: Th5uAdjacentGroupFoldingOptions);
begin
  if Assigned(AValue) then
    FAdjacentGroupFolding.Assign(AValue);
end;

procedure Th5uFmxGrid.SetGridLines(const AValue: Boolean);
begin
  if AValue then
    FSpacing.SetAllSeparators(1)
  else
    FSpacing.SetAllSeparators(0);
end;

procedure Th5uFmxGrid.SetSpacing(const AValue: Th5uGridSpacingOptions);
begin
  FSpacing.Assign(AValue);
end;

procedure Th5uFmxGrid.SetCustomization(const AValue: Th5uCustomizationOptions);
begin
  FCustomization.Assign(AValue);
end;

procedure Th5uFmxGrid.SetDataController(const AValue: Th5uCustomDataController);
begin
  if FDataController = AValue then
    Exit;
  EndSelectionDrag;
  if Assigned(FDataController) then
    FDataController.RemoveFreeNotification(Self);
  FDataController := AValue;
  FDataLink.Controller := FDataController;
  if Assigned(FDataController) then
    FDataController.FreeNotification(Self);
  FVerticalOffset := 0;
  InvalidateAdjacentGroupMap(True);
  InvalidateAllRowHeights;
  Repaint;
end;

procedure Th5uFmxGrid.SetHeaderLayout(const AValue: Th5uHeaderLayout);
begin
  FHeaderLayout.Assign(AValue);
  Repaint;
end;

procedure Th5uFmxGrid.SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
begin
  FFactoryScope.OnConfigureInstance := AValue;
end;

procedure Th5uFmxGrid.SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
begin
  FFactoryScope.OnCreateInstance := AValue;
end;

procedure Th5uFmxGrid.SetOnGetClass(const AValue: Th5uGetClassEvent);
begin
  FFactoryScope.OnGetClass := AValue;
end;

procedure Th5uFmxGrid.SetRowHeight(const AValue: Th5uRowHeightOptions);
begin
  FRowHeight.Assign(AValue);
end;

procedure Th5uFmxGrid.SetRowStyles(const AValue: Th5uRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Repaint;
end;

procedure Th5uFmxGrid.SetScrolling(const AValue: Th5uScrollingOptions);
begin
  FScrolling.Assign(AValue);
end;

procedure Th5uFmxGrid.SetScrollHints(const AValue: Th5uScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure Th5uFmxGrid.SetSelection(const AValue: Th5uGridSelection);
begin
  FSelection.Assign(AValue);
end;

procedure Th5uFmxGrid.SetSharedClassFactory(const AValue: Th5uClassFactory);
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

procedure Th5uFmxGrid.SetTheme(const AValue: Th5uGridTheme);
begin
  if FTheme = AValue then
    Exit;
  FTheme := AValue;
  InvalidateAllRowHeights;
  Repaint;
end;

procedure Th5uFmxGrid.SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
begin
  if not Assigned(AColumn) then
    Exit;
  if not AVisible and (not FCustomization.AllowColumnHiding or not AColumn.CanHide) then
    Exit;
  AColumn.Visible := AVisible;
  FColumns.NormalizeVisibleIndexes;
  Repaint;
end;

procedure Th5uFmxGrid.ShowThumbHint(AAxis: Th5uScrollAxis);
var
  LContext: Th5uFmxThumbHintContext;
  LText: string;
  LVisible: Boolean;
  LPalette: Th5uFmxPalette;
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

  LPalette := h5uGetFmxPalette(FTheme);
  // Alpha 204/255 gives the background 80% opacity without fading the text.
  FThumbHintBackground.Fill.Color := (LPalette.ThumbHintBackground and $00FFFFFF) or $CC000000;
  FThumbHint.Text := LText;
  FThumbHint.TextSettings.FontColor := LPalette.ThumbHintText;
  FThumbHint.TextSettings.Font.Size := FTextSize;
  FThumbHintBackground.Width := Min(Max(120, Length(LText) * FTextSize * 0.55 + 20), Width - 20);
  FThumbHintBackground.Height := 32;

  if AAxis = Th5uScrollAxis.Vertical then
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

function Th5uFmxGrid.FocusedCellHit(out AHit: Th5uFmxHitTestInfo): Boolean;
begin
  Result := CellHit(FSelection.FocusedCell, AHit);
end;

function Th5uFmxGrid.CellHit(const LCell: Th5uCellAddress; out AHit: Th5uFmxHitTestInfo): Boolean;
var
  LColumns: TArray<Th5uGridColumn>;
  LView: TRectF;
  LTop, LHeight, LLeft, LRight: Single;
  LRow: Int64;
  LKey: Th5uRowKey;
  LElement: Th5uElementKind;
  LColor: TAlphaColor;
  LStyle: string;
  LLevel, LClosed, I: Integer;
begin
  Result := False;
  AHit := Th5uFmxHitTestInfo.Empty;
  if not CanUpdateLayout or not Assigned(FDataController) then
    Exit;
  LColumns := FColumns.VisibleColumns;
  if not LCell.IsValid or (LCell.RowIndex >= GetViewRowCount) or (LCell.ColumnIndex >= Length(LColumns)) then
    Exit;
  LView := GetDataViewportRect;
  LTop := 0;
  for LRow := 0 to LCell.RowIndex - 1 do
  begin
    LKey := GetViewRowKey(LRow);
    LTop := LTop + GetRowHeightFor(LRow, LKey) + GetEffectiveRowSeparatorFor(LRow, LKey, LElement, LColor, LStyle, LLevel, LClosed);
  end;
  PrepareViewRange(LCell.RowIndex, 1);
  LKey := GetViewRowKey(LCell.RowIndex);
  LHeight := GetRowHeightFor(LCell.RowIndex, LKey);
  if LTop < FVerticalOffset then
    FVerticalOffset := LTop
  else if LTop + LHeight > FVerticalOffset + LView.Height then
    FVerticalOffset := Max(0, LTop + LHeight - LView.Height);
  BuildColumnLayout;
  LLeft := LView.Left;
  if FShowRowIndicator then
    LLeft := LLeft + FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
  LRight := LView.Right;
  for I := 0 to High(LColumns) do
    case LColumns[I].FixedKind of
      Th5uFixedKind.Left: LLeft := LLeft + LColumns[I].Width + GetEffectiveColumnRightSpacing(LColumns[I]);
      Th5uFixedKind.Right: LRight := LRight - LColumns[I].Width - GetEffectiveColumnRightSpacing(LColumns[I]);
    end;
  if LColumns[LCell.ColumnIndex].FixedKind = Th5uFixedKind.None then
  begin
    if FAllColumns[LCell.ColumnIndex].Bounds.Left < LLeft then
      FHorizontalOffset := Max(0, FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Left - LLeft)
    else if FAllColumns[LCell.ColumnIndex].Bounds.Right > LRight then
      FHorizontalOffset := Max(0, FHorizontalOffset + FAllColumns[LCell.ColumnIndex].Bounds.Right - LRight);
  end;
  UpdateScrollBars;
  BuildColumnLayout;
  AHit.Kind := Th5uFmxHitKind.DataCell;
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

function Th5uFmxGrid.FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean): Boolean;
var
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LHit: Th5uFmxHitTestInfo;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FDataController) then
    Exit;
  if not h5uPlanCellFocus(FColumns, FSelection, GetViewRowCount, GetViewRowKey, ARow, AColumn, AExtend, LCell, LRange) then
    Exit;
  if not TryFocusCell(LCell, not AExtend) then Exit;
  FSelection.AddCellRange(LRange, AAdd, AExtend);
  Result := FocusedCellHit(LHit);
  if Result and AEdit and FImmediateEdit and not AExtend then
    EditFocusedCell(True);
end;

procedure Th5uFmxGrid.EditFocusedCell(AAutomatic: Boolean);
var
  LHit: Th5uFmxHitTestInfo;
begin
  if not FocusedCellHit(LHit) then
    Exit;
  // Focus alone must neither toggle Boolean values nor open an image dialog.
  if AAutomatic and not ((LHit.Column.EditorKind
    in [Th5uColumnEditorKind.Text, Th5uColumnEditorKind.Date, Th5uColumnEditorKind.Time, Th5uColumnEditorKind.DateTime]) or ((LHit.Column.EditorKind
    = Th5uColumnEditorKind.Automatic) and not (LHit.Column.DataType in [Th5uColumnDataType.Boolean, Th5uColumnDataType.Image]))) then
    Exit;
  StartEdit(LHit);
end;

function Th5uFmxGrid.NavigationRowExtent(ARow: Int64): Double;
begin
  Result := GetRowHeightFor(ARow, GetViewRowKey(ARow)) + FSpacing.RowSpacing;
end;

function Th5uFmxGrid.HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
var
  LAction: Th5uNavigationAction;
  LHit: Th5uFmxHitTestInfo;
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
  Result := FNavigation.Navigate(FColumns, FSelection, GetViewRowCount, GetViewRowKey, NavigationRowExtent,
    GetDataViewportRect.Height, AKey, AShift, LAction);
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

procedure Th5uFmxGrid.SearchCharacter(AChar: Char);
var
  LRow: Int64;
  LColumn: Integer;
begin
  if (AChar < #32) or Assigned(FEditColumn) or not CanUpdateLayout then
    Exit;
  if FNavigation.SearchCharacter(FColumns, FSelection, GetViewRowCount, PrepareViewRange, GetCellText, AChar, Now, LRow, LColumn) then
    FocusCell(LRow, LColumn, False, False);
end;
procedure Th5uFmxGrid.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  // FMX also routes keys from children here; preserve the editor's caret keys.
  if Assigned(FEditColumn) then
    Exit;
  if HandleNavigationKey(Key, Shift) then
  begin
    Key := 0;
    KeyChar := #0;
  end
  else if (KeyChar >= #32) and not (ssCtrl in Shift) and not (ssAlt in Shift) then
  begin
    SearchCharacter(KeyChar);
    KeyChar := #0;
  end;
end;
procedure Th5uCellDateEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;
function Th5uCellDateEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

procedure Th5uCellDateEdit.HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime);
begin
  // The calendar picks a date, not a new time. Keep the time component when
  // this control is used for a combined date/time cell.
  inherited HandlerPickerDateTimeChanged(Sender, DateOf(ADate) + TimeOf(DateTime));
end;

procedure Th5uCellTimeEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;
function Th5uCellTimeEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

procedure Th5uCellTextEdit.ApplyStyleLookup;
var
  LBounds: TRectF;
begin
  LBounds := BoundsRect;
  inherited;
  // Also clears the style presentation's internal adjustment mode.
  SetAdjustType(TAdjustType.None);
  BoundsRect := LBounds;
end;
function Th5uCellTextEdit.GetAdjustType: TAdjustType;
begin
  Result := TAdjustType.None;
end;

function Th5uFmxGrid.DateEditorVisible: Boolean;
begin
  Result := Assigned(FDateEditor) and FDateEditor.Visible;
end;

function Th5uFmxGrid.DateEditorValue: TValue;
var
  LDateTime: TDateTime;
begin
  if FDateEditor.IsEmpty then
    Exit(TValue.Empty);
  LDateTime := FDateEditor.DateTime;
  case FDateEditorKind of
    Th5uColumnEditorKind.Date: LDateTime := DateOf(LDateTime);
    Th5uColumnEditorKind.Time: LDateTime := TimeOf(LDateTime);
  end;
  Result := TValue.From<TDateTime>(LDateTime);
end;

procedure Th5uFmxGrid.StartDateEdit(const AHit: Th5uFmxHitTestInfo; AKind: Th5uColumnEditorKind);
var
  LValue: TValue;
begin
  if AKind = Th5uColumnEditorKind.Time then
  begin
    if not Assigned(FClockEditor) then
    begin
      FClockEditor := Th5uCellTimeEdit.Create(Self);
      FClockEditor.Visible := False;
      FClockEditor.Stored := False;
      FClockEditor.Parent := Self;
      FClockEditor.UseNowTime := False;
    end;
    FDateEditor := FClockEditor;
    FDateEditor.Format := 'hh:nn:ss';
  end
  else
  begin
    if not Assigned(FCalendarEditor) then
    begin
      FCalendarEditor := Th5uCellDateEdit.Create(Self);
      FCalendarEditor.Visible := False;
      FCalendarEditor.Stored := False;
      FCalendarEditor.Parent := Self;
      FCalendarEditor.TodayDefault := False;
    end;
    FDateEditor := FCalendarEditor;
    if AKind = Th5uColumnEditorKind.DateTime then
      FDateEditor.Format := 'dd.mm.yyyy hh:nn:ss'
    else
      FDateEditor.Format := 'dd.mm.yyyy';
  end;
  FDateEditor.ShowClearButton := True;
  FDateEditor.OnChange := EditorChanged;
  FDateEditor.OnKeyDown := EditorKeyDown;
  FDateEditor.OnExit := EditorExit;
  FEditRowIndex := AHit.RowIndex;
  FEditRowKey := AHit.RowKey;
  FEditColumn := AHit.Column;
  FDateEditorKind := AKind;
  LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
  if LValue.IsEmpty then
    FDateEditor.DateTime := Now
  else
    FDateEditor.DateTime := LValue.AsType<TDateTime>;
  FDateEditor.IsEmpty := LValue.IsEmpty;
  FDateEditorOriginal := FDateEditor.DateTime;
  FDateEditorWasEmpty := LValue.IsEmpty;
  FEditorExitBlocked := False;
  FDateEditor.SetBounds(AHit.Bounds.Left, AHit.Bounds.Top, AHit.Bounds.Width, AHit.Bounds.Height);
  ShowEditorBackground(AHit.Bounds);
  FDateEditor.StyledSettings := FDateEditor.StyledSettings - [TStyledSetting.FontColor];
  FDateEditor.TextSettings.FontColor := h5uGetFmxPalette(FTheme).CellText;
  FDateEditor.Visible := True;
  FDateEditor.BringToFront;
  FDateEditor.SetFocus;
end;
procedure Th5uFmxGrid.StartEdit(const AHit: Th5uFmxHitTestInfo);
var
  LKind: Th5uColumnEditorKind;
  LValue: TValue;
  LCell: Th5uCellAddress;
  LImageEditor: Th5uFmxImageEditor;
begin
  if Assigned(FEditColumn) and (FEditor.Visible or DateEditorVisible) then
  begin
    if (FEditColumn = AHit.Column) and (FEditRowIndex = AHit.RowIndex) then
    begin
      if DateEditorVisible then FDateEditor.SetFocus else FEditor.SetFocus;
      Exit;
    end;
    CommitEditor;
  end;
  if not Assigned(FDataController) or not Assigned(AHit.Column) or not AllowCellEdit(AHit.Column, AHit.RowIndex) then
    Exit;

  LCell.RowIndex := AHit.RowIndex;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnId := AHit.Column.Id;
  if not TryFocusCell(LCell, True) then Exit;

  LKind := AHit.Column.EditorKind;
  if LKind = Th5uColumnEditorKind.Automatic then
    case AHit.Column.DataType of
      Th5uColumnDataType.Boolean:
        LKind := Th5uColumnEditorKind.Boolean;
      Th5uColumnDataType.Image:
        LKind := Th5uColumnEditorKind.Image;
      Th5uColumnDataType.Date:
        LKind := Th5uColumnEditorKind.Date;
      Th5uColumnDataType.Time:
        LKind := Th5uColumnEditorKind.Time;
      Th5uColumnDataType.DateTime:
        LKind := Th5uColumnEditorKind.DateTime;
      else
        LKind := Th5uColumnEditorKind.Text;
    end;

  case LKind of
    Th5uColumnEditorKind.Date, Th5uColumnEditorKind.Time, Th5uColumnEditorKind.DateTime:
      StartDateEdit(AHit, LKind);

    Th5uColumnEditorKind.Boolean:
      begin
        LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
        PutCellValue(AHit.Column, AHit.RowIndex, TValue.From<Boolean>(LValue.IsEmpty or not LValue.AsBoolean));
      end;

    Th5uColumnEditorKind.Image:
      begin
        if not Assigned(FImageEditor) then
        begin
          LImageEditor := Th5uFmxImageEditor.Create(Self);
          LImageEditor.Stored := False;
          LImageEditor.Parent := Self;
          LImageEditor.OnCommit := ImageEditorCommit;
          LImageEditor.OnCancel := ImageEditorCancel;
          FImageEditor := LImageEditor;
        end
        else
          LImageEditor := Th5uFmxImageEditor(FImageEditor);

        FEditRowIndex := AHit.RowIndex;
        FEditRowKey := AHit.RowKey;
        FEditColumn := AHit.Column;
        LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
        if LValue.IsType<TBytes> then
          LImageEditor.Bytes := LValue.AsType<TBytes>
        else
          LImageEditor.Bytes := nil;
        LImageEditor.SetBounds(Max(4, (Width - 420) / 2), Max(4, (Height - 300) / 2), Min(420, Width - 8), Min(300, Height - 8));
        LImageEditor.Visible := True;
        LImageEditor.BringToFront;
      end;

    Th5uColumnEditorKind.Text:
      begin
        FEditRowIndex := AHit.RowIndex;
        FEditRowKey := AHit.RowKey;
        FEditColumn := AHit.Column;
        FEditor.Text := GetCellText(AHit.Column, AHit.RowIndex, False);
        FEditorOriginalText := FEditor.Text;
        FEditorExitBlocked := False;
        FEditor.SetBounds(AHit.Bounds.Left, AHit.Bounds.Top, AHit.Bounds.Width, AHit.Bounds.Height);
        ShowEditorBackground(AHit.Bounds);
        FEditor.StyledSettings := FEditor.StyledSettings - [TStyledSetting.FontColor];
        FEditor.TextSettings.FontColor := h5uGetFmxPalette(FTheme).CellText;
        FEditor.Visible := True;
        FEditor.BringToFront;
        FEditor.SetFocus;
        FEditor.SelectAll;
      end;
  end;
end;

procedure Th5uFmxGrid.ThumbHintTimer(Sender: TObject);
begin
  HideThumbHint;
end;

procedure Th5uFmxGrid.UpdateScrollBars;
var
  LNeedH: Boolean;
  LNeedV: Boolean;
  LAvailableWidth: Single;
  LAvailableHeight: Single;
  LContentWidth: Single;
  LContentHeight: Double;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;
  FUpdatingScrollBars := True;
  try
    LContentWidth := GetTotalColumnWidth;
    LContentHeight := GetEstimatedTotalRowHeight;

    LNeedH := LContentWidth > Max(0.0, Width - FSpacing.Left - FSpacing.Right);
    LNeedV := LContentHeight > Max(0.0, Height - FSpacing.Top - FSpacing.Bottom - GetHeaderHeight);
    FHScrollBar.Visible := LNeedH;
    FVScrollBar.Visible := LNeedV;
    LayoutScrollBars;

    LAvailableWidth := GetViewportRect.Width;
    LAvailableHeight := GetDataViewportRect.Height;
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
  end;
end;

end.
