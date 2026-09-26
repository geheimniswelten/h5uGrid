unit Vcl.h5u.Grid;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.TypInfo,
  System.DateUtils,
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
  h5u.Grid.Types,
  h5u.Grid.Data.Dataset,
  Vcl.h5u.Grid.Styles,
  Vcl.h5u.Grid.Editors;

type
  Th5uVclCustomGrid = class;
  Th5uVclVisualCell = class;
  Th5uVclVisualCellClass = class of Th5uVclVisualCell;

  Th5uCustomDrawStage = (BeforeDefault, AfterDefault);
  Th5uHitKind = (None, Header, RowIndicator, DataCell, AdjacentGroupGlyph);

  Th5uGetRowHeightContext = record
    Grid: Th5uVclCustomGrid;
    DataController: Th5uCustomDataController;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    IsEstimated: Boolean;
  end;

  Th5uGetRowHeightEvent = procedure(Sender: TObject; const AContext: Th5uGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean) of object;
  Th5uGetRowSpacingEvent = procedure(Sender: TObject; const AContext: Th5uGetRowHeightContext; var ASpacing: Integer) of object;

  Th5uThumbHintContext = record
    Grid: Th5uVclCustomGrid;
    DataController: Th5uCustomDataController;
    Axis: Th5uScrollAxis;
    Trigger: Th5uScrollHintTrigger;
    ScrollOffset: Int64;
    ScrollRange: Int64;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    Column: Th5uGridColumn;
    Value: TValue;
    DisplayText: string;
    IsEstimated: Boolean;
    IsValueAvailable: Boolean;
  end;

  Th5uGetThumbHintEvent = procedure(Sender: TObject; const AContext: Th5uThumbHintContext; var AText: string; var AVisible: Boolean) of object;
  Th5uRowAppearanceEvent = procedure(Sender: TObject; AViewRowIndex: Int64; const ARowKey: Th5uRowKey; var AAppearance: Th5uResolvedAppearance) of object;
  Th5uCellAppearanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; var AAppearance: Th5uResolvedAppearance) of object;

  Th5uVclDrawContext = record
    FactoryContext: Th5uFactoryContext;
    Bounds: TRect;
    DisplayText: string;
    Appearance: Th5uResolvedAppearance;
  end;

  Th5uVclAfterDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;
  Th5uVclPrepareElementEvent = procedure(Sender: TObject; Control: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext; APart: Th5uElementPaintPart) of object;
  Th5uVclCustomDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean) of object;

  Th5uVisibleColumnInfo = record
    Column: Th5uGridColumn;
    VisibleIndex: Integer;
    Bounds: TRect;
  end;

  Th5uVisibleRowInfo = record
    RowIndex: Int64;
    RowKey: Th5uRowKey;
    Bounds: TRect;
    Height: Integer;
  end;

  Th5uHitTestInfo = record
    Kind: Th5uHitKind;
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: Th5uRowKey;
    Column: Th5uGridColumn;
    Bounds: TRect;
    HeaderCell: Th5uHeaderLayoutCell;
    class function Empty: Th5uHitTestInfo; static;
  end;

  Th5uVclVisualCell = class(Th5uFactoryObject)
  private
    FContext: Th5uFactoryContext;
    FBounds: TRect;
    FValue: TValue;
    FDisplayText: string;
    FAppearance: Th5uResolvedAppearance;
    FInUse: Boolean;
  protected
    procedure PrepareCanvas(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
    procedure PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); virtual;
    function EffectiveBackground(AGrid: Th5uVclCustomGrid): TColor;
    function EffectiveForeground(AGrid: Th5uVclCustomGrid): TColor;
  public
    procedure BindCell(const AContext: Th5uFactoryContext; const ABounds: TRect; const AValue: TValue; const ADisplayText: string;
      const AAppearance: Th5uResolvedAppearance); virtual;
    procedure Paint(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); virtual;

    property Context: Th5uFactoryContext read FContext;
    property Bounds: TRect read FBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: Th5uResolvedAppearance read FAppearance;
  end;

  // Lightweight pooled painter for row/column separators, content padding
  // and the tree branch-end band. Its ClassId is resolved per grid instance.
  Th5uVclSpacingCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclDataCell = class(Th5uVclVisualCell)
  private
    FPicture: TPicture;
    FPictureSignature: Integer;
    procedure EnsurePicture;
  protected
    procedure PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  Th5uVclHeaderCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclFixedCell = class(Th5uVclDataCell);

  // Plus/minus glyph used for one contiguous run of equal adjacent IDs.
  // The class is resolved through the per-grid FactoryScope.
  Th5uVclAdjacentGroupGlyphCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclCustomGrid = class(TCustomControl)
  private
    FShowColumnModes: Boolean;
    FColumns: Th5uGridColumns;
    FMinWidth, FMaxWidth: Integer;
    FAutoWidthRowLimit: Integer;
    FAutoWidthsDirty: Boolean;
    FAutoWidthFont: string;
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
    procedure SetAutoWidthRowLimit(const AValue: Integer);
    procedure MeasureAutoWidths;
    procedure ResolveColumnWidths(AAvailableWidth: Double);
  private
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
    FAdjacentGroupFolding: Th5uAdjacentGroupFoldingOptions;
    FTree: Th5uTreeOptions;
    FView: Th5uGridView;

    FTheme: Th5uGridTheme;
    FHeaderRowHeight: Integer;
    FRowIndicatorWidth: Integer;
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
    FLastNotifiedCell: Th5uCellAddress;

    function FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean = False): Boolean;
    function FocusedCellHit(out AHit: Th5uHitTestInfo): Boolean;
    function CellHit(const LCell: Th5uCellAddress; out AHit: Th5uHitTestInfo): Boolean;
    procedure EditFocusedCell(AAutomatic: Boolean);
    function NavigationRowExtent(ARow: Int64): Double;
    function HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
    procedure SearchCharacter(AChar: Char);
  private
    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditRowIndex: Int64;
    FEditRowKey: Th5uRowKey;
    FEditColumn: Th5uGridColumn;
    FCommittingEditor: Boolean;
    FEditors: Th5uVclGridEditors;
    FEditorCache: Th5uGridEditorCache;
    FDefaultEditors: Th5uDefaultEditors;
    FActiveEditor: Th5uGridEditorItem;
    procedure SetEditors(AValue: Th5uVclGridEditors);
    procedure SetDefaultEditors(AValue: Th5uDefaultEditors);
    procedure FinishEditor(ACommitted: Boolean);
    procedure EditorRequestCommit(Sender: TObject);
    procedure EditorRequestCancel(Sender: TObject);
    procedure ProcessEditorKey(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    function CachedEditor(const AName: string): Th5uGridEditorItem;
    function CellEditorContext(AColumn: Th5uGridColumn; ARow: Int64; const ABounds: TRectF): Th5uEditorContext;
    function CellEditorClick(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
    function CellEditorAutoEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
    function CellEditorHit(AColumn: Th5uGridColumn; ARow: Int64; const ABounds: TRectF; const APoint: TPointF): Boolean;
  private
    FEditorExitBlocked: Boolean;

    FHorizontalOffset: Integer;
    FVerticalOffset: Integer;
    FVisibleColumns: TArray<Th5uVisibleColumnInfo>;
    FAllColumns: TArray<Th5uVisibleColumnInfo>;
    FVisibleRows: TArray<Th5uVisibleRowInfo>;
    FCellPool: TObjectList<Th5uVclVisualCell>;
    FRowMetrics: Th5uGridRowMetrics;
    FUpdatingScrollBars: Boolean;
    FInitialized: Boolean;

    FMouseDownHit: Th5uHitTestInfo;
    FSelectingRange, FSelectionDragging, FMouseEditPending: Boolean;
    FSelectionDragKind: Th5uSelectionKind;
    FSelectionDragShift: TShiftState;
    FSelectionDragOrigin: TPoint;
    FSelectionDragLast: Th5uCellAddress;
    FMovingColumns: TArray<Th5uGridColumn>;
    FMovingRowKeys: TArray<Th5uRowKey>;
    FMovingFirstRowIndex: Int64;
    FMoveDragging: Boolean;
    FMovePoint: TPoint;
    FMoveCaption: string;
    FMovingHeaderCell: Th5uHeaderLayoutCell;
    FMovePreviewWidth: Integer;
    FMoveTouch: Boolean;
    FMoveCursor: TCursor;
    FOnRowsMoved: Th5uRowsMovedEvent;
    FResizingColumn: Th5uGridColumn;
    FResizeStartX: Integer;
    FResizeOriginalWidth: Integer;
    FResizeCursorActive: Boolean;
    FResizeCursor: TCursor;

    FOnGetRowHeight: Th5uGetRowHeightEvent;
    FOnGetRowSpacing: Th5uGetRowSpacingEvent;
    FOnGetThumbHint: Th5uGetThumbHintEvent;
    FOnGetRowAppearance: Th5uRowAppearanceEvent;
    FOnGetCellAppearance: Th5uCellAppearanceEvent;
    FOnAfterDraw: Th5uVclAfterDrawEvent;
    FOnPrepareElement: Th5uVclPrepareElementEvent;
    FOnCustomDraw: Th5uVclCustomDrawEvent;
    function GetOnGetTreeLevel: Th5uGetTreeLevelEvent;
    procedure SetOnGetTreeLevel(const AValue: Th5uGetTreeLevelEvent);
    function GetOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    procedure SetOnGetTreeBranchEnd(const AValue: Th5uGetTreeBranchEndEvent);
    function GetOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    procedure SetOnGetAdjacentGroupId(const AValue: Th5uGetAdjacentGroupIdEvent);
    function GetOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;
    procedure SetOnAdjacentGroupStateChanged(const AValue: Th5uAdjacentGroupStateChangedEvent);

    function ViewDataController: Th5uCustomDataController;
    function IndicatorExtent: Double;
    function MetricCellHeight(ARow: Int64; AColumn: Th5uGridColumn): Double;
    procedure MetricAdjustHeight(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Double; var ACacheResult: Boolean);
    function MetricRowExtent(ARow: Int64; AAllowMeasure: Boolean): Double;
    function MetricRowSpacing(ARow: Int64; const AKey: Th5uRowKey): Double;
    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Integer; AShift: TShiftState);
    procedure UpdateSelectionDrag(X, Y: Integer);
    procedure EndSelectionDrag;
    function ColumnResizeAt(X, Y: Integer; ATouch: Boolean): Th5uGridColumn;
    function IsResizeHeaderEdge(AX, AY: Double): Boolean;
    function BeginColumnResize(X, Y: Integer; ATouch: Boolean): Boolean;
    procedure UpdateColumnResize(X: Integer);
    procedure SetResizeCursor(AActive: Boolean);
    procedure SelectRightClickCell(const AHit: Th5uHitTestInfo);
    function IsRowMoveGesture(AShift: TShiftState): Boolean;
    function GetHeaderCellBounds(ACell: Th5uHeaderLayoutCell): TRect;
    function GetHeaderCellViewport(ACell: Th5uHeaderLayoutCell): TRect;
    function HeaderCellAtPoint(X, Y: Integer): Th5uHeaderLayoutCell;
    function BeginColumnMove(AColumnIndex: Integer; X, Y: Integer): Boolean;
    function BeginRowMove(ARowIndex: Int64; X, Y: Integer): Boolean;
    procedure UpdateHeaderMove(X, Y: Integer);
    function FinishHeaderMove(X, Y: Integer): Boolean;
    function GetColumnMoveHeaderBounds(const AInfo: Th5uVisibleColumnInfo): TRect;
    function ColumnMoveTarget(X, Y: Integer; out ANewIndex, AMarkerX, AMarkerTop: Integer): Boolean;
    function CanMoveColumn(AColumn: Th5uGridColumn): Boolean;
    function IsColumnMoveGesture(AColumn: Th5uGridColumn; AShift: TShiftState): Boolean;
    procedure SelectHeaderRange(AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
    procedure SelectionChanged(Sender: TObject);
    procedure SetColumns(const AValue: Th5uGridColumns);
    procedure SetHeaderLayout(const AValue: Th5uHeaderLayout);
    procedure SetDataController(const AValue: Th5uCustomDataController);
    procedure SetSharedClassFactory(const AValue: Th5uClassFactory);
    procedure SetTheme(const AValue: Th5uGridTheme);
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
    procedure SetGridLines(const AValue: Boolean);
    procedure SetHeaderRowHeight(const AValue: Integer);
    procedure SetRowIndicatorWidth(const AValue: Integer);

    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);

    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorChanged(Sender: TObject);
    function GetColumnViewportRect(AColumn: Th5uGridColumn): TRect;
    function GetVisibleCellBounds(AColumn: Th5uGridColumn; const AColumnBounds, ARowBounds: TRect): TRect;
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function GetUnpaddedViewportRect: TRect;
    function GetViewportRect: TRect;
    function GetHeaderHeight: Integer;
    function GetDataViewportRect: TRect;
    function GetTotalColumnWidth: Integer;
    function GetEffectiveColumnRightSpacing(AColumn: Th5uGridColumn): Integer;
    procedure InvalidateAdjacentGroupMap(AClearStates: Boolean = False);
    function GetViewRowCount: Int64;
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    function GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
    procedure PrepareViewRange(AFirstViewRow, ACount: Int64);
    function TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
    procedure DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
    function GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Integer;
    function GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out AElementKind: Th5uElementKind; out AColor: TColor; out AStyleName: string;
      out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Integer;
    function GetGridLines: Boolean;
    function ResolveColor(const AColor: TColor; AFallback: TColor): TColor;
    function ResolveDefaultCellColor: TColor;
    function ResolveRowSpacingColor: TColor;
    function ResolveColumnSpacingColor: TColor;
    function ResolveContentPaddingColor: TColor;
    function ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
    function ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
    function GetEstimatedTotalRowHeight: Int64;
    function CanUpdateLayout: Boolean;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCell;

    procedure DrawContentPadding;
    procedure DrawHeaders;
    procedure DrawColumnMoveFeedback;
    procedure DrawRows;
    procedure DrawSpacingRect(const ABounds: TRect; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AColor: TColor;
      const AStyleName: string = ''; ATreeLevel: Integer = -1; AClosedTreeLevels: Integer = 0);
    procedure DrawDefaultHeaders;
    procedure DrawCustomHeaderLayout;
    procedure DrawRowIndicator(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
    function GetAdjacentGroupGlyphRect(const ARowInfo: Th5uVisibleRowInfo): TRect;
    procedure DrawAdjacentGroupGlyph(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);

    function GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AAllowMeasure: Boolean = True): Integer;
    function MeasureCellHeight(AViewRowIndex: Int64; AColumn: Th5uGridColumn): Integer;
    function FindFirstVisibleRow(AOffset: Int64; out ATop: Integer): Int64;
    function GetRowStyle(AViewRowIndex: Int64; out AStyleKey: TValue): string;
    function ResolveRowAppearance(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; const AStyleName: string): Th5uResolvedAppearance;
    function ResolveCellAppearance(const AContext: Th5uFactoryContext; AColumn: Th5uGridColumn; const ARowAppearance: Th5uResolvedAppearance;
      ASelected, AFocused: Boolean): Th5uResolvedAppearance;

    function ColumnInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleColumnInfo): Boolean;
    function RowInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleRowInfo): Boolean;

    procedure ShowThumbHint(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger);
    procedure HideThumbHint;
    function BuildThumbHintText(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger; out AContext: Th5uThumbHintContext): string;

    procedure StartEdit(const AHit: Th5uHitTestInfo);
    function TryFocusCell(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean;
    function AllowCellEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
    function GetCellValue(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
    function GetCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
    procedure PutCellValue(AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue);
    procedure NotifyCellClick(AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
    procedure SetShowColumnModes(AValue: Boolean);
    procedure GetColumnMode(AColumn: Th5uGridColumn; var AMode: string);
    function ColumnModeSymbols(AColumn: Th5uGridColumn): string;
    procedure PrepareGridCanvas(const ABounds: TRect; AKind: Th5uElementKind);
    procedure CommitEditor;
    procedure CancelEditor;

    procedure ShowColumnChooser;
    procedure ColumnChooserClick(Sender: TObject);
    procedure RebuildAfterLayoutChange;

    function GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCellClass; virtual;

    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
  protected
    procedure DoExit; override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMCursorChanged(var Message: TMessage); message CM_CURSORCHANGED;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;

    function GetDataCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass; virtual;
    function GetHeaderCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass; virtual;
    function GetFixedCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass; virtual;
  public
    function GetCellEditor(AColumn: Th5uGridColumn; ARow: Int64): Th5uGridEditorItem;
    procedure ClearEditorCache;
    property ActiveEditor: Th5uGridEditorItem read FActiveEditor;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateRowHeight(const ARowKey: Th5uRowKey);
    procedure InvalidateVisibleRowHeights;
    procedure InvalidateAllRowHeights;

    function HitTest(X, Y: Integer): Th5uHitTestInfo;
    procedure MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
    procedure SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
    function MeasureColumnWidth(AColumn: Th5uGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1): Integer;
    procedure AutoSizeColumn(AColumn: Th5uGridColumn; AFirstRow: Int64 = 0; ARowCount: Int64 = -1);
    procedure InvalidateColumnWidths;
    procedure AutoCreateColumnsFromDataset(AClearExisting: Boolean = True);
    procedure ToggleAdjacentGroup(AViewRowIndex: Int64);
    procedure SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
    procedure ExpandAllAdjacentGroups;
    procedure CollapseAllAdjacentGroups;
    procedure ResetAdjacentGroupStates;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;

    property FactoryScope: Th5uFactoryScope read FFactoryScope;
    property HorizontalOffset: Integer read FHorizontalOffset;
    property VerticalOffset: Integer read FVerticalOffset;
  protected
    property DataController: Th5uCustomDataController read FDataController write SetDataController;
    property SharedClassFactory: Th5uClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Editors: Th5uVclGridEditors read FEditors write SetEditors;
    property DefaultEditors: Th5uDefaultEditors read FDefaultEditors write SetDefaultEditors;
    // Limits for the combined column content, not the control itself. Zero disables a limit.
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property AutoWidthRowLimit: Integer read FAutoWidthRowLimit write SetAutoWidthRowLimit default 1000;
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
    property AdjacentGroupFolding: Th5uAdjacentGroupFoldingOptions read FAdjacentGroupFolding write SetAdjacentGroupFolding;
    property Tree: Th5uTreeOptions read FTree write SetTree;

    property Theme: Th5uGridTheme read FTheme write SetTheme default Th5uGridTheme.ApplicationStyle;
    property HeaderRowHeight: Integer read FHeaderRowHeight write SetHeaderRowHeight default 26;
    property RowIndicatorWidth: Integer read FRowIndicatorWidth write SetRowIndicatorWidth default 34;
    property ShowHeader: Boolean read FShowHeader write FShowHeader default True;
    property ShowRowIndicator: Boolean read FShowRowIndicator write FShowRowIndicator default True;
    property AllowEditing: Boolean read FAllowEditing write FAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write FImmediateEdit default False;
    property GridLines: Boolean read GetGridLines write SetGridLines default True;

    property OnGetClass: Th5uGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: Th5uGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: Th5uGetRowSpacingEvent read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: Th5uGetThumbHintEvent read FOnGetThumbHint write FOnGetThumbHint;
    property OnGetRowAppearance: Th5uRowAppearanceEvent read FOnGetRowAppearance write FOnGetRowAppearance;
    property OnGetCellAppearance: Th5uCellAppearanceEvent read FOnGetCellAppearance write FOnGetCellAppearance;
    property OnAfterDraw: Th5uVclAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;
    property OnPrepareElement: Th5uVclPrepareElementEvent read FOnPrepareElement write FOnPrepareElement;
    property OnCustomDraw: Th5uVclCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnGetTreeLevel: Th5uGetTreeLevelEvent read GetOnGetTreeLevel write SetOnGetTreeLevel;
    property OnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent read GetOnGetTreeBranchEnd write SetOnGetTreeBranchEnd;
    property OnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent read GetOnGetAdjacentGroupId write SetOnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent read GetOnAdjacentGroupStateChanged write SetOnAdjacentGroupStateChanged;
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
  end;

  Th5uVclGrid = class(Th5uVclCustomGrid)
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
    property MinWidth;
    property MaxWidth;
    property AutoWidthRowLimit;
    property Columns;
    property HeaderLayout;
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

    property Theme;
    property HeaderRowHeight;
    property RowIndicatorWidth;
    property ShowHeader;
    property ShowRowIndicator;
    property AllowEditing;
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

implementation

type
  Th5uAccessGridColumn = class(Th5uGridColumn);

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

{ Th5uHitTestInfo }

class function Th5uHitTestInfo.Empty: Th5uHitTestInfo;
begin
  Result := Default(Th5uHitTestInfo);
  Result.Kind := Th5uHitKind.None;
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  Result.RowKey := Th5uRowKey.Empty;
end;

{ Th5uVclVisualCell }

procedure Th5uVclVisualCell.BindCell(const AContext: Th5uFactoryContext; const ABounds: TRect; const AValue: TValue; const ADisplayText: string;
  const AAppearance: Th5uResolvedAppearance);
begin
  FContext := AContext;
  FBounds := ABounds;
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

function Th5uVclVisualCell.EffectiveBackground(AGrid: Th5uVclCustomGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasBackground then
    Result := FAppearance.Background
  else
    Result := AGrid.ResolveDefaultCellColor;
end;

function Th5uVclVisualCell.EffectiveForeground(AGrid: Th5uVclCustomGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasForeground then
    Result := FAppearance.Foreground
  else
    Result := LPalette.CellText;
end;

procedure Th5uVclVisualCell.PrepareCanvas(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
var
  LContext: Th5uVclDrawContext;
begin
  if not Assigned(AGrid.FOnPrepareElement) then
    Exit;
  LContext.FactoryContext := Context;
  LContext.Bounds := Bounds;
  LContext.DisplayText := DisplayText;
  LContext.Appearance := Appearance;
  AGrid.FOnPrepareElement(AGrid, Self, ACanvas, LContext, APart);
end;

procedure Th5uVclCustomGrid.PrepareGridCanvas(const ABounds: TRect; AKind: Th5uElementKind);
var
  LContext: Th5uVclDrawContext;
begin
  if not Assigned(FOnPrepareElement) then
    Exit;
  LContext := Default(Th5uVclDrawContext);
  LContext.FactoryContext := Th5uFactoryContext.Create(Self, Self, FDataController, '', AKind);
  LContext.FactoryContext.ViewRowIndex := -1;
  LContext.Bounds := ABounds;
  FOnPrepareElement(Self, Self, Canvas, LContext, Th5uElementPaintPart.Background);
end;

procedure Th5uVclVisualCell.Paint(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
var
  LDrawContext: Th5uVclDrawContext;
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
    AGrid.DoCustomDraw(ACanvas, LDrawContext, Th5uCustomDrawStage.BeforeDefault, LDrawDefault);

    if LDrawDefault then
      PaintDefault(AGrid, ACanvas);

    AGrid.DoCustomDraw(ACanvas, LDrawContext, Th5uCustomDrawStage.AfterDefault, LDrawDefault);
  finally
    if Assigned(LBrush) then ACanvas.Brush.Assign(LBrush);
    if Assigned(LPen)  then  ACanvas.Pen.Assign(LPen);
    if Assigned(LFont) then  ACanvas.Font.Assign(LFont);
    LFont.Free; LPen.Free; LBrush.Free;
  end;
end;

procedure Th5uVclVisualCell.PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
begin
  // Separators are independent layout elements. Painting them around every
  // cell would double their width and would make per-column spacing impossible.
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(FBounds);
end;

{ Th5uVclSpacingCell }

procedure Th5uVclSpacingCell.PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := Appearance.Background;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(Bounds);
end;

{ Th5uVclAdjacentGroupGlyphCell }

procedure Th5uVclAdjacentGroupGlyphCell.PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
var
  LPalette: Th5uVclPalette;
  LRect: TRect;
  LMidX: Integer;
  LMidY: Integer;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  LRect := Bounds;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(LRect);

  InflateRect(LRect, -1, -1);
  if (LRect.Width < 7) or (LRect.Height < 7) then
    Exit;

  ACanvas.Brush.Color := LPalette.CellBackground;
  ACanvas.Pen.Color := LPalette.CellText;
  ACanvas.Pen.Width := 1;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
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

destructor Th5uVclDataCell.Destroy;
begin
  FPicture.Free;
  inherited;
end;

procedure Th5uVclDataCell.EnsurePicture;
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

procedure Th5uVclDataCell.PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
var
  LEditor: Th5uGridEditorItem;
  LEditorContext: Th5uEditorContext;
  LHandled: Boolean;
  LColumn: Th5uGridColumn;
  LTextRect: TRect;
  LFlags: Cardinal;
  LRow: Th5uVisibleRowInfo;
  LGlyph: TRect;
  LPalette: Th5uVclPalette;
begin
  inherited;
  if Context.ElementKind = Th5uElementKind.RowHeaderCell then
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
    PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);
    if LTextRect.Width > 0 then
      DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect, LFlags);
    ACanvas.Brush.Style := bsSolid;
    Exit;
  end;
  if not (Context.Column is Th5uGridColumn) then
    Exit;

  LColumn := Th5uGridColumn(Context.Column);
  LPalette := h5uGetVclPalette(AGrid.Theme);
  ACanvas.Font.Assign(AGrid.Font);
  ACanvas.Font.Color := EffectiveForeground(AGrid);
  ACanvas.Font.Style := Appearance.FontStyle;
  ACanvas.Brush.Style := bsClear;

  LEditor := AGrid.GetCellEditor(LColumn, Context.ViewRowIndex);
  if not Assigned(LEditor) then
    LEditor := AGrid.CachedEditor(AGrid.DefaultEditors.DataTypeEditor(LColumn.DataType));
  LEditorContext := Default(Th5uEditorContext);
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

  if LEditor is Th5uVclImageCellEditor then
  begin
    EnsurePicture; LEditorContext.Image := FPicture;
  end;
  LEditorContext.PreparePaint :=
    procedure(APart: Th5uElementPaintPart)
    begin
      PrepareCanvas(AGrid, ACanvas, APart);
    end;
  if (LEditor = AGrid.FActiveEditor) and (AGrid.FEditColumn = LColumn) and (AGrid.FEditRowIndex = Context.ViewRowIndex) then
  begin
    if LEditor.Mode = Th5uEditorMode.Graphic then
      LEditorContext.Value := LEditor.GetValue;
    LHandled := LEditor.DrawEditor(LEditorContext);
  end
  else
    LHandled := LEditor.DrawDisplay(LEditorContext);
  if not LHandled then
    AGrid.CachedEditor('TextEditor').DrawDisplay(LEditorContext);

  if Th5uElementFlag.Focused in Context.ElementFlags then
  begin
    ACanvas.Pen.Color := LPalette.FocusBorder;
    ACanvas.Brush.Style := bsClear;
    PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Border);
    ACanvas.Rectangle(Bounds);
    ACanvas.Brush.Style := bsSolid;
  end;
end;

{ Th5uVclHeaderCell }

procedure Th5uVclHeaderCell.PaintDefault(AGrid: Th5uVclCustomGrid; ACanvas: TCanvas);
var
  LPalette: Th5uVclPalette;
  LTextRect, LSymbolRect: TRect;
  LSymbols: string;
  LSavedFont: TFont;
  LDetails: TThemedElementDetails;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);

  if (AGrid.Theme = Th5uGridTheme.ApplicationStyle) and StyleServices.Enabled and not Assigned(AGrid.FOnPrepareElement) then
  begin
    LDetails := StyleServices.GetElementDetails(thHeaderItemNormal);
    StyleServices.DrawElement(ACanvas.Handle, LDetails, Bounds);
  end
  else
  begin
    ACanvas.Brush.Color := LPalette.HeaderBackground;
    PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
    ACanvas.FillRect(Bounds);
  end;

  ACanvas.Font.Assign(AGrid.Font);
  ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  ACanvas.Font.Color := LPalette.HeaderText;
  ACanvas.Brush.Style := bsClear;
  LTextRect := Bounds;
  InflateRect(LTextRect, -5, -2);
  LSymbols := AGrid.ColumnModeSymbols(Th5uGridColumn(Context.Column));
  if LSymbols <> '' then
  begin
    LSavedFont := TFont.Create;
    try
      LSavedFont.Assign(ACanvas.Font);
      ACanvas.Font.Color := clMaroon;
      PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.ColumnMode);
      LSymbolRect := LTextRect;
      LSymbolRect.Right := Min(LSymbolRect.Right, LSymbolRect.Left + ACanvas.TextWidth(LSymbols) + 4);
      DrawText(ACanvas.Handle, PChar(LSymbols), Length(LSymbols), LSymbolRect, DT_NOPREFIX or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
      LTextRect.Left := LSymbolRect.Right + 3;
    finally
      ACanvas.Font.Assign(LSavedFont);
      LSavedFont.Free;
    end;
  end;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);
  DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect, DT_NOPREFIX or DT_CENTER or DT_VCENTER or DT_SINGLELINE
    or DT_END_ELLIPSIS);
  ACanvas.Brush.Style := bsSolid;
end;

function Th5uVclCustomGrid.AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCell;
var
  LClass: Th5uVclVisualCellClass;
  LCell: Th5uVclVisualCell;
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

  Result := Th5uVclVisualCell(FFactoryScope.CreateInstance(LCreateContext, Th5uVclVisualCell, LClass));
  Result.FInUse := True;
  FCellPool.Add(Result);
  FFactoryScope.BindInstance(AContext, Result);
end;

procedure Th5uVclCustomGrid.AutoCreateColumnsFromDataset(AClearExisting: Boolean);
var
  LController: Th5uDatasetController;
  LField: TField;
  LColumn: Th5uGridColumn;
begin
  if not (FDataController is Th5uDatasetController) then
    Exit;

  LController := Th5uDatasetController(FDataController);
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
          LColumn.DataType := Th5uColumnDataType.Integer;

        ftFloat, ftSingle, ftExtended:
          LColumn.DataType := Th5uColumnDataType.Float;

        ftCurrency, ftBCD, ftFMTBcd:
        begin
          LColumn.DataType := Th5uColumnDataType.Currency;
          LColumn.DisplayFormat := '#,##0.00';
        end;

        ftDate:
        begin
          LColumn.DataType := Th5uColumnDataType.Date;
          LColumn.DisplayFormat := 'dd.mm.yyyy';
        end;

        ftTime:
        begin
          LColumn.DataType := Th5uColumnDataType.Time;
          LColumn.DisplayFormat := 'hh:nn:ss';
        end;

        ftDateTime, ftTimeStamp:
        begin
          LColumn.DataType := Th5uColumnDataType.DateTime;
          LColumn.DisplayFormat := 'dd.mm.yyyy hh:nn';
        end;

        ftBoolean: LColumn.DataType := Th5uColumnDataType.Boolean;

        ftBlob, ftGraphic, ftOraBlob:
        begin
          LColumn.DataType := Th5uColumnDataType.Image;
          LColumn.EditorKind := Th5uColumnEditorKind.Image;
          LColumn.Width := 100;
          LColumn.AutoHeight := True;
          LColumn.MaxAutoHeight := 100;
        end;

        ftMemo, ftWideMemo:
        begin
          LColumn.DataType := Th5uColumnDataType.Text;
          LColumn.WordWrap := True;
          LColumn.AutoHeight := True;
          LColumn.Width := 240;
        end;

        else
          LColumn.DataType := Th5uColumnDataType.Text;
      end;
    end;
  finally
    FColumns.EndUpdate;
  end;
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.BeginVisualPass;
var
  LCell: Th5uVclVisualCell;
begin
  for LCell in FCellPool do
    if LCell.FInUse then
    begin
      FFactoryScope.UnbindInstance(LCell.Context, LCell);
      LCell.FInUse := False;
    end;
end;

function Th5uVclCustomGrid.BuildThumbHintText(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger; out AContext: Th5uThumbHintContext): string;
var
  LTop: Integer;
  LRowIndex: Int64;
  LColumn: Th5uGridColumn;
  LInfo: Th5uVisibleColumnInfo;
  LColumns: TArray<Th5uGridColumn>;
begin
  AContext := Default(Th5uThumbHintContext);
  AContext.Grid := Self;
  AContext.DataController := FDataController;
  AContext.Axis := AAxis;
  AContext.Trigger := ATrigger;
  AContext.IsEstimated := False;

  Result := '';
  if AAxis = Th5uScrollAxis.Vertical then
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
      if (LInfo.Column.FixedKind = Th5uFixedKind.None) and (LInfo.Bounds.Right > GetDataViewportRect.Left) then
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

procedure Th5uVclCustomGrid.SetMinWidth(const AValue: Integer);
begin
  if FMinWidth = Max(0, AValue) then
    Exit;
  FMinWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMaxWidth < FMinWidth) then
    FMaxWidth := FMinWidth;
  OptionsChanged(Self);
end;

procedure Th5uVclCustomGrid.SetMaxWidth(const AValue: Integer);
begin
  if FMaxWidth = Max(0, AValue) then
    Exit;
  FMaxWidth := Max(0, AValue);
  if (FMaxWidth > 0) and (FMinWidth > FMaxWidth) then
    FMinWidth := FMaxWidth;
  OptionsChanged(Self);
end;

procedure Th5uVclCustomGrid.SetAutoWidthRowLimit(const AValue: Integer);
begin
  if FAutoWidthRowLimit = Max(0, AValue) then
    Exit;
  FAutoWidthRowLimit := Max(0, AValue);
  InvalidateColumnWidths;
end;

procedure Th5uVclCustomGrid.InvalidateColumnWidths;
begin
  FAutoWidthsDirty := True;
  Invalidate;
end;

procedure Th5uVclCustomGrid.AutoSizeColumn(AColumn: Th5uGridColumn; AFirstRow, ARowCount: Int64);
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

procedure Th5uVclCustomGrid.MeasureAutoWidths;
var
  LColumn: Th5uGridColumn;
  LFont: string;
  LCount: Int64;
begin
  LFont := Font.Name + ':' + IntToStr(Font.Height) + ':' + IntToStr(Byte(Font.Style));
  if LFont <> FAutoWidthFont then
    FAutoWidthsDirty := True;
  if not FAutoWidthsDirty then
    Exit;
  // Clear before reading: asynchronous or reentrant data notifications must survive.
  FAutoWidthsDirty := False;
  FAutoWidthFont := LFont;
  LCount := FAutoWidthRowLimit;
  if LCount = 0 then
    LCount := -1;
  try
    for LColumn in FColumns.VisibleColumns do
      if LColumn.AutoWidth then
        LColumn.SetMeasuredWidth(MeasureColumnWidth(LColumn, 0, LCount));
  except
    FAutoWidthsDirty := True;
    raise;
  end;
end;

procedure Th5uVclCustomGrid.ResolveColumnWidths(AAvailableWidth: Double);
begin
  if h5uResolveColumnWidths(FColumns, FHeaderLayout, FSpacing.DefaultColumnRightSpacing,
     AAvailableWidth - IndicatorExtent, FMinWidth, FMaxWidth)
   then
     InvalidateAllRowHeights;
end;

function Th5uVclCustomGrid.MeasureColumnWidth(AColumn: Th5uGridColumn; AFirstRow, ARowCount: Int64): Integer;
var
  LBitmap: TBitmap;
  LContext: Th5uEditorContext;
  LEditor: Th5uGridEditorItem;
  LRow, LCount, LEnd: Int64;
  LWidth: Double;
  LFactoryContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LStyleKey: TValue;
begin
  if not Assigned(AColumn) or (AColumn.Collection <> FColumns) then
    raise EArgumentException.Create('Die Spalte gehört nicht zu diesem Grid.');
  Result := AColumn.MinWidth;
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
    LContext := Default(Th5uEditorContext);
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
          LFactoryContext := Th5uFactoryContext.Create(Self, Self, FDataController, AColumn.CellClassId, Th5uElementKind.DataCell);
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
            Result := Max(Result, AColumn.ConstrainWidth(Ceil(EnsureRange(LWidth, 0.0, Double(MaxInt div 4)))));
          if (AColumn.MaxWidth > 0) and (Result >= AColumn.MaxWidth) then
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

procedure Th5uVclCustomGrid.BuildColumnLayout;
var
  LLayout: TArray<Th5uColumnLayoutInfo>;
  LView: TRect;
  I, LVisibleCount: Integer;
begin
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
    if LLayout[I].Visible then
    begin
      FVisibleColumns[LVisibleCount] := FAllColumns[I];
      Inc(LVisibleCount);
    end;
  end;
  SetLength(FVisibleColumns, LVisibleCount);
end;

function Th5uVclCustomGrid.IndicatorExtent: Double;
begin
  Result := 0;
  if FShowRowIndicator then
    Result := FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
end;

procedure Th5uVclCustomGrid.CancelEditor;
begin
  FinishEditor(False);
end;

procedure Th5uVclCustomGrid.ColumnChooserClick(Sender: TObject);
var
  LItem: TMenuItem;
  LColumn: Th5uGridColumn;
begin
  if not (Sender is TMenuItem) then
    Exit;
  LItem := TMenuItem(Sender);
  if (LItem.Tag < 0) or (LItem.Tag >= FColumns.Count) then
    Exit;
  LColumn := FColumns[LItem.Tag];
  SetColumnVisible(LColumn, not LColumn.Visible);
end;

function Th5uVclCustomGrid.ColumnInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleColumnInfo): Boolean;
var
  LInfo: Th5uVisibleColumnInfo;
begin
  for LInfo in FVisibleColumns do
    if PtInRect(LInfo.Bounds, Point(X, Y)) and GetColumnViewportRect(LInfo.Column).Contains(Point(X, Y)) then
    begin
      AInfo := LInfo;
      Exit(True);
    end;
  Result := False;
end;

procedure Th5uVclCustomGrid.SetShowColumnModes(AValue: Boolean);
begin
  if FShowColumnModes = AValue then
    Exit;
  FShowColumnModes := AValue;
  Invalidate;
end;

procedure Th5uVclCustomGrid.GetColumnMode(AColumn: Th5uGridColumn; var AMode: string);
begin
  AMode := h5uColumnMode(AColumn, FDataController, FTree.LevelColumnId, FAdjacentGroupFolding.IdColumnId, FRowStyles.StyleKeyColumnId,
    FScrollHints.VerticalColumnId);
end;

function Th5uVclCustomGrid.ColumnModeSymbols(AColumn: Th5uGridColumn): string;
begin
  Result := '';
  if Assigned(AColumn) and (FShowColumnModes or (csDesigning in ComponentState)) then
    Result := h5uColumnModeSymbols(AColumn.Mode);
end;

procedure Th5uVclCustomGrid.ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
begin
  FAutoWidthsDirty := True;
  InvalidateAdjacentGroupMap(False);
  RebuildAfterLayoutChange;
end;

function Th5uVclCustomGrid.TryFocusCell(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean;
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

function Th5uVclCustomGrid.AllowCellEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
begin
  Result := False;
  if not CanUpdateLayout then
    Exit;
  Result := h5uCellPermission(Self, AColumn, ARow, FAllowEditing and not AColumn.ReadOnly
    and CanEditViewValue(ARow, AColumn.FieldName), AColumn.OnCanEdit, FOnCanEdit);
end;

function Th5uVclCustomGrid.GetCellValue(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
begin
  Result := GetViewValue(ARow, AColumn.FieldName);
  if CanUpdateLayout then
    h5uOverrideCellValue(Self, AColumn, ARow, ADisplay, FOnGetValue, Result);
end;

function Th5uVclCustomGrid.GetCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  Result := h5uCellText(AColumn, ARow, ADisplay, Assigned(AColumn.OnGetValue)
    or Assigned(FOnGetValue), GetCellValue, GetViewValue, GetViewDisplayText);
end;

procedure Th5uVclCustomGrid.PutCellValue(AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue);
var
  LValue: TValue;
begin
  if not CanUpdateLayout then
    Exit;
  LValue := h5uPrepareCellValue(Self, AColumn, ARow, AValue, FOnValidate, FOnSetValue);
  SetViewValue(ARow, AColumn.FieldName, LValue);
end;

procedure Th5uVclCustomGrid.NotifyCellClick(AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
begin
  if CanUpdateLayout then
    h5uNotifyCellClick(Self, AColumn, ARow, AHeader, AIndicator, FOnCellClick, FOnColumnHeaderClick, FOnRowIndicatorClick);
end;

procedure Th5uVclCustomGrid.CommitEditor;
var
  LValue: TValue;
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
      PutCellValue(FEditColumn, FEditRowIndex, LValue);
      FinishEditor(True);
      InvalidateAllRowHeights;
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

function Th5uVclCustomGrid.GetOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetAdjacentGroupId;
end;

procedure Th5uVclCustomGrid.SetOnGetAdjacentGroupId(const AValue: Th5uGetAdjacentGroupIdEvent);
begin
  FView.OnGetAdjacentGroupId := AValue;
end;

function Th5uVclCustomGrid.GetOnGetTreeLevel: Th5uGetTreeLevelEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetTreeLevel;
end;

procedure Th5uVclCustomGrid.SetOnGetTreeLevel(const AValue: Th5uGetTreeLevelEvent);
begin
  FView.OnGetTreeLevel := AValue;
end;

function Th5uVclCustomGrid.GetOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnGetTreeBranchEnd;
end;

procedure Th5uVclCustomGrid.SetOnGetTreeBranchEnd(const AValue: Th5uGetTreeBranchEndEvent);
begin
  FView.OnGetTreeBranchEnd := AValue;
end;

function Th5uVclCustomGrid.GetOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;
begin
  Result := nil;
  if Assigned(FView) then
    Result := FView.OnAdjacentGroupStateChanged;
end;

procedure Th5uVclCustomGrid.SetOnAdjacentGroupStateChanged(const AValue: Th5uAdjacentGroupStateChangedEvent);
begin
  FView.OnAdjacentGroupStateChanged := AValue;
end;

function Th5uVclCustomGrid.ViewDataController: Th5uCustomDataController;
begin
  Result := FDataController;
end;

constructor Th5uVclCustomGrid.Create(AOwner: TComponent);
begin
  inherited;
  // Our interaction handlers own capture. VCL's automatic release happens before
  // MouseUp and would cancel the pending action through WMCaptureChanged.
  ControlStyle := (ControlStyle + [csOpaque, csDoubleClicks]) - [csCaptureMouse];

  FFactoryScope := Th5uFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FFactoryScope.RegisterClass(h5uClassIdGridDataCell, Th5uVclVisualCell, Th5uVclDataCell);
  FFactoryScope.RegisterClass(h5uClassIdGridFixedCell, Th5uVclVisualCell, Th5uVclFixedCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderCell, Th5uVclVisualCell, Th5uVclHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridHeaderGroupCell, Th5uVclVisualCell, Th5uVclHeaderCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupFoldGlyph, Th5uVclVisualCell, Th5uVclAdjacentGroupGlyphCell);
  FFactoryScope.RegisterClass(h5uClassIdGridAdjacentGroupEndBand, Th5uVclVisualCell, Th5uVclSpacingCell);

  FEditors := Th5uVclGridEditors.Create(Self);
  FEditorCache := Th5uGridEditorCache.Create;
  FDefaultEditors := Th5uDefaultEditors.Create;

  FColumns := Th5uGridColumns.Create(Self);
  FColumns.OnChanged := ColumnsChanged;
  FColumns.OnGetMode := GetColumnMode;

  FHeaderLayout := Th5uHeaderLayout.Create(Self);
  FHeaderLayout.OnChanged := OptionsChanged;
  FAutoWidthRowLimit := 1000;
  FAutoWidthsDirty := True;

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

  FAdjacentGroupFolding := Th5uAdjacentGroupFoldingOptions.Create;
  FAdjacentGroupFolding.OnChanged := OptionsChanged;

  FTree := Th5uTreeOptions.Create;
  FTree.OnChanged := OptionsChanged;

  FView := Th5uGridView.Create(Self, FColumns, FTree, FAdjacentGroupFolding, ViewDataController);

  FDataLink := Th5uDataControllerLink.Create;
  FDataLink.OnChanged := DataChanged;
  FCellPool := TObjectList<Th5uVclVisualCell>.Create(True);
  FRowMetrics := Th5uGridRowMetrics.Create;

  FTheme := Th5uGridTheme.ApplicationStyle;
  FHeaderRowHeight := 26;
  FRowIndicatorWidth := 34;
  FShowHeader := True;
  FShowRowIndicator := True;
  FAllowEditing := True;
  FEditRowIndex := -1;

  FVScrollBar := TScrollBar.Create(Self);
  FVScrollBar.SetSubComponent(True);
  FVScrollBar.Parent := Self;
  FVScrollBar.Kind := sbVertical;
  FVScrollBar.OnScroll := ScrollBarScroll;

  FHScrollBar := TScrollBar.Create(Self);
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

procedure Th5uVclCustomGrid.DataChanged(Sender: TObject; const AChange: Th5uDataChange);
begin
  FAutoWidthsDirty := True;
  // Unknown row changes may reorder positional keys; abandon the pending drop.
  if (Length(FMovingRowKeys) > 0) and (AChange.Kind <> Th5uDataChangeKind.CellChanged) then
    EndSelectionDrag;
  InvalidateAdjacentGroupMap(not FAdjacentGroupFolding.PreserveStateOnDataChange);
  // Live updates must not discard an in-progress draft. Cancel only when the
  // target is no longer the same row; never commit into a replacement row.
  if not FCommittingEditor and Assigned(FEditColumn) then
    if not CanUpdateLayout or FEditRowKey.IsEmpty or (FEditRowIndex < 0) or (FEditRowIndex >= GetViewRowCount) or (GetViewRowKey(FEditRowIndex)
      <> FEditRowKey) then
      CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

destructor Th5uVclCustomGrid.Destroy;
begin
  CancelEditor;
  FEditorCache.Free;
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

procedure Th5uVclCustomGrid.DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, ACanvas, AContext, AStage, ADrawDefault);
end;

function Th5uVclCustomGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  LDelta: Integer;
begin
  LDelta := FScrolling.WheelRows * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);

  if WheelDelta > 0 then
    Dec(FVerticalOffset, LDelta)
  else
    Inc(FVerticalOffset, LDelta);

  FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);

  if FScrolling.VerticalMode = Th5uVerticalScrollMode.WholeRows then
  begin
    FindFirstVisibleRow(FVerticalOffset, LDelta);
    FVerticalOffset := EnsureRange(FVerticalOffset + (LDelta - GetDataViewportRect.Top), 0, FVScrollBar.Max);
  end;

  FVScrollBar.Position := FVerticalOffset;
  Invalidate;
  if Th5uScrollHintTrigger.MouseWheel in FScrollHints.Triggers then
    ShowThumbHint(Th5uScrollAxis.Vertical, Th5uScrollHintTrigger.MouseWheel);
  Result := True;
end;

procedure Th5uVclCustomGrid.DrawCustomHeaderLayout;
var
  I, LFirst, LLast: Integer;
  LCellDef: Th5uHeaderLayoutCell;
  LRect, LDrawRect, LClip, LSeparatorRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LAppearance: Th5uResolvedAppearance;
  LClassId: Th5uClassId;
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
    LCell := AcquireVisualCell(LContext, Th5uVclHeaderCell);
    LCell.BindCell(LContext, LDrawRect, TValue.Empty, LCellDef.Caption, LAppearance);
    LCell.Paint(Self, Canvas);
    LRightSpacing := GetEffectiveColumnRightSpacing(FAllColumns[LLast].Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      IntersectRect(LSeparatorRect, LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, FAllColumns[LLast].Column, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
    if FSpacing.RowSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Left, LRect.Bottom, LRect.Right + LRightSpacing, LRect.Bottom + FSpacing.RowSpacing);
      IntersectRect(LSeparatorRect, LSeparatorRect, LClip);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.RowSpacing, Th5uGridColumn(LContext.Column), -1, Th5uRowKey.Empty, ResolveRowSpacingColor);
    end;
  end;
end;

procedure Th5uVclCustomGrid.DrawDefaultHeaders;
var
  LInfo: Th5uVisibleColumnInfo;
  LRect: TRect;
  LDrawRect: TRect;
  LSeparatorRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LAppearance: Th5uResolvedAppearance;
  LClassId: Th5uClassId;
  LRightSpacing: Integer;
begin
  for LInfo in FVisibleColumns do
  begin
    LRect := LInfo.Bounds;
    LRect.Top := GetViewportRect.Top;
    LRect.Bottom := LRect.Top + FHeaderRowHeight;

    LDrawRect := LRect;
    IntersectRect(LDrawRect, LDrawRect, GetColumnViewportRect(LInfo.Column));
    if not IsRectEmpty(LDrawRect) then
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
      LCell := AcquireVisualCell(LContext, Th5uVclHeaderCell);
      LCell.BindCell(LContext, LDrawRect, TValue.Empty, LInfo.Column.Caption, LAppearance);
      LCell.Paint(Self, Canvas);
    end;

    // The separator remains visible even if pixel scrolling starts inside it
    // and the corresponding cell itself is already outside the viewport.
    LRightSpacing := GetEffectiveColumnRightSpacing(LInfo.Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + LRightSpacing, LRect.Bottom);
      IntersectRect(LSeparatorRect, LSeparatorRect, GetColumnViewportRect(LInfo.Column));
      if not IsRectEmpty(LSeparatorRect) then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, LInfo.Column, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;
end;

procedure Th5uVclCustomGrid.DrawContentPadding;
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
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Bottom < LOuterRect.Bottom then
  begin
    LPaddingRect := Rect(LOuterRect.Left, LInnerRect.Bottom, LOuterRect.Right, LOuterRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Left > LOuterRect.Left then
  begin
    LPaddingRect := Rect(LOuterRect.Left, LInnerRect.Top, LInnerRect.Left, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;

  if LInnerRect.Right < LOuterRect.Right then
  begin
    LPaddingRect := Rect(LInnerRect.Right, LInnerRect.Top, LOuterRect.Right, LInnerRect.Bottom);
    DrawSpacingRect(LPaddingRect, Th5uElementKind.ContentPadding, nil, -1, Th5uRowKey.Empty, LColor);
  end;
end;

procedure Th5uVclCustomGrid.DrawHeaders;
var
  LRect: TRect;
  LSeparatorRect: TRect;
  LHeaderRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LAppearance: Th5uResolvedAppearance;
  LPalette: Th5uVclPalette;
  LContentBottom: Integer;
begin
  if not FShowHeader then
    Exit;

  LPalette := h5uGetVclPalette(FTheme);
  LHeaderRect := GetViewportRect;
  LHeaderRect.Bottom := LHeaderRect.Top + GetHeaderHeight;
  Canvas.Brush.Color := LPalette.HeaderBackground;
  Canvas.FillRect(LHeaderRect);

  if FShowRowIndicator then
  begin
    LContentBottom := LHeaderRect.Bottom - FSpacing.RowSpacing;
    LRect := Rect(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Left + FRowIndicatorWidth, Max(GetViewportRect.Top, LContentBottom));
    LContext := Th5uFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridHeaderCell, Th5uElementKind.CornerCell);
    LContext.ElementFlags := [Th5uElementFlag.Header, Th5uElementFlag.Corner, Th5uElementFlag.FixedColumn];
    LAppearance.Clear;
    LCell := AcquireVisualCell(LContext, Th5uVclHeaderCell);
    LCell.BindCell(LContext, LRect, TValue.Empty, '', LAppearance);
    LCell.Paint(Self, Canvas);

    if FSpacing.DefaultColumnRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + FSpacing.DefaultColumnRightSpacing, LRect.Bottom);
      DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, nil, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    DrawCustomHeaderLayout
  else
    DrawDefaultHeaders;

  if FSpacing.RowSpacing > 0 then
  begin
    LSeparatorRect := Rect(LHeaderRect.Left, LHeaderRect.Bottom - FSpacing.RowSpacing, LHeaderRect.Right, LHeaderRect.Bottom);
    DrawSpacingRect(LSeparatorRect, Th5uElementKind.RowSpacing, nil, -1, Th5uRowKey.Empty, ResolveRowSpacingColor);
  end;
end;

procedure Th5uVclCustomGrid.DrawRowIndicator(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
var
  LRect: TRect;
  LSeparatorRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LAppearance: Th5uResolvedAppearance;
begin
  if not FShowRowIndicator then
    Exit;

  LRect := ARowInfo.Bounds;
  LRect.Left := GetViewportRect.Left;
  LRect.Right := LRect.Left + FRowIndicatorWidth;

  LContext := Th5uFactoryContext.Create(Self, Self, FDataController, h5uClassIdGridFixedCell, Th5uElementKind.RowHeaderCell);
  LContext.RowKey := ARowInfo.RowKey;
  LContext.ViewRowIndex := ARowInfo.RowIndex;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARowInfo.RowIndex);
  LContext.ElementFlags := [Th5uElementFlag.FixedColumn];
  PopulateAdjacentGroupContext(LContext, ARowInfo.RowIndex);
  if ASelected then
    Include(LContext.ElementFlags, Th5uElementFlag.Selected);

  LAppearance.Clear;
  if ASelected then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := h5uGetVclPalette(FTheme).SelectedBackground;
    LAppearance.HasForeground := True;
    LAppearance.Foreground := h5uGetVclPalette(FTheme).SelectedText;
  end;

  LCell := AcquireVisualCell(LContext, Th5uVclDataCell);
  LCell.BindCell(LContext, LRect, TValue.From<Int64>(ARowInfo.RowIndex + 1), IntToStr(ARowInfo.RowIndex + 1), LAppearance);
  LCell.Paint(Self, Canvas);

  if FSpacing.DefaultColumnRightSpacing > 0 then
  begin
    LSeparatorRect := Rect(LRect.Right, LRect.Top, LRect.Right + FSpacing.DefaultColumnRightSpacing, LRect.Bottom);
    IntersectRect(LSeparatorRect, LSeparatorRect, GetDataViewportRect);
    if not IsRectEmpty(LSeparatorRect) then
      DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, nil, ARowInfo.RowIndex, ARowInfo.RowKey, ResolveColumnSpacingColor);
  end;
end;

function Th5uVclCustomGrid.GetAdjacentGroupGlyphRect(const ARowInfo: Th5uVisibleRowInfo): TRect;
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

  if FShowRowIndicator then
    LLeft := GetViewportRect.Left + 4
  else if Length(FVisibleColumns) > 0 then
    LLeft := Max(GetDataViewportRect.Left + 3, FVisibleColumns[0].Bounds.Left + 3)
  else
    Exit;

  Result := Rect(LLeft, LTop, LLeft + LSize, LTop + LSize);
  IntersectRect(Result, Result, GetDataViewportRect);
end;

procedure Th5uVclCustomGrid.DrawAdjacentGroupGlyph(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
var
  LBounds: TRect;
  LContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uVclVisualCell;
begin
  LBounds := GetAdjacentGroupGlyphRect(ARowInfo);
  if IsRectEmpty(LBounds) then
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
    LAppearance.Background := h5uGetVclPalette(FTheme).SelectedBackground;
  end;

  LCell := AcquireVisualCell(LContext, Th5uVclAdjacentGroupGlyphCell);
  LCell.BindCell(LContext, LBounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

procedure Th5uVclCustomGrid.DrawRows;
var
  LDataRect: TRect;
  LTop: Integer;
  LRowIndex: Int64;
  LRowCount: Int64;
  LHeight: Integer;
  LRowSpacing: Integer;
  LRowRect: TRect;
  LRowKey: Th5uRowKey;
  LRows: TList<Th5uVisibleRowInfo>;
  LRowInfo: Th5uVisibleRowInfo;
  LColumnInfo: Th5uVisibleColumnInfo;
  LCellRect: TRect;
  LSeparatorRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LValue: TValue;
  LDisplayText: string;
  LStyleName: string;
  LStyleKey: TValue;
  LRowAppearance: Th5uResolvedAppearance;
  LCellAppearance: Th5uResolvedAppearance;
  LRowSelected: Boolean;
  LCellSelected: Boolean;
  LFocused: Boolean;
  LClassId: Th5uClassId;
  LOverscanBottom: Integer;
  LColumnSpacing: Integer;
  LRowSeparatorKind: Th5uElementKind;
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

  LRows := TList<Th5uVisibleRowInfo>.Create;
  try
    LOverscanBottom := LDataRect.Bottom + FScrolling.OverscanRows * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);

    while (LRowIndex < LRowCount) and (LTop < LOverscanBottom) do
    begin
      LRowKey := GetViewRowKey(LRowIndex);
      LHeight := GetRowHeightFor(LRowIndex, LRowKey);
      LRowSpacing := GetEffectiveRowSeparatorFor(LRowIndex, LRowKey, LRowSeparatorKind, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
        LClosedTreeLevels);
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
        if FShowRowIndicator then
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);

        for LColumnInfo in FVisibleColumns do
        begin
          LCellRect := GetVisibleCellBounds(LColumnInfo.Column, LColumnInfo.Bounds, LRowRect);

          if not IsRectEmpty(LCellRect) then
          begin
            LCellSelected := LRowSelected or FSelection.IsColumnSelected(LColumnInfo.Column.Id)
              or FSelection.IsCellSelected(LRowIndex, LColumnInfo.VisibleIndex);
            LFocused := FSelection.FocusedCell.IsValid and (FSelection.FocusedCell.RowIndex = LRowIndex) and (FSelection.FocusedCell.ColumnIndex
              = LColumnInfo.VisibleIndex);

            LClassId := LColumnInfo.Column.CellClassId;
            if string(LClassId) = '' then
              LClassId := h5uClassIdGridDataCell;
            if (LColumnInfo.Column.FixedKind <> Th5uFixedKind.None) and (LClassId = h5uClassIdGridDataCell) then
              LClassId := h5uClassIdGridFixedCell;

            LContext := Th5uFactoryContext.Create(Self, Self, FDataController, LClassId, Th5uElementKind.DataCell);
            LContext.Column := LColumnInfo.Column;
            LContext.RowKey := LRowKey;
            LContext.ViewRowIndex := LRowIndex;
            LContext.SourceRowIndex := GetViewSourceRowIndex(LRowIndex);
            LContext.RowStyleKey := LStyleKey;
            PopulateAdjacentGroupContext(LContext, LRowIndex);

            if LColumnInfo.Column.FixedKind <> Th5uFixedKind.None then
              Include(LContext.ElementFlags, Th5uElementFlag.FixedColumn);
            if LCellSelected then
              Include(LContext.ElementFlags, Th5uElementFlag.Selected);
            if LFocused then
              Include(LContext.ElementFlags, Th5uElementFlag.Focused);
            if Odd(LRowIndex) then
              Include(LContext.ElementFlags, Th5uElementFlag.OddRow)
            else
              Include(LContext.ElementFlags, Th5uElementFlag.EvenRow);
            if (FRowStyles.StripePeriod > 0) and (((LRowIndex + 1 - FRowStyles.StripeOffset) mod FRowStyles.StripePeriod) = 0) then
              Include(LContext.ElementFlags, Th5uElementFlag.PatternRow);
            if LColumnInfo.Column.ReadOnly then
              Include(LContext.ElementFlags, Th5uElementFlag.ReadOnly);

            LValue := GetCellValue(LColumnInfo.Column, LRowIndex, True);
            LContext.Value := LValue;
            LDisplayText := GetCellText(LColumnInfo.Column, LRowIndex, True);

            LCellAppearance := ResolveCellAppearance(LContext, LColumnInfo.Column, LRowAppearance, LCellSelected, LFocused);

            LCell := AcquireVisualCell(LContext, GetDataCellClass(LContext));
            LCell.BindCell(LContext, LCellRect, LValue, LDisplayText, LCellAppearance);
            LCell.Paint(Self, Canvas);
          end;

          LColumnSpacing := GetEffectiveColumnRightSpacing(LColumnInfo.Column);
          if LColumnSpacing > 0 then
          begin
            LSeparatorRect := Rect(LColumnInfo.Bounds.Right, LRowRect.Top, LColumnInfo.Bounds.Right + LColumnSpacing, LRowRect.Bottom);
            LSeparatorRect := GetVisibleCellBounds(LColumnInfo.Column, LSeparatorRect, LRowRect);
            if not IsRectEmpty(LSeparatorRect) then
              DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, LColumnInfo.Column, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
        end;
        if not FShowRowIndicator then
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

procedure Th5uVclCustomGrid.DrawSpacingRect(const ABounds: TRect; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AColor: TColor;
  const AStyleName: string; ATreeLevel: Integer; AClosedTreeLevels: Integer);
var
  LClassId: Th5uClassId;
  LFactoryContext: Th5uFactoryContext;
  LAppearance: Th5uResolvedAppearance;
  LCell: Th5uVclVisualCell;
begin
  if IsRectEmpty(ABounds) then
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
  if AColor <> clNone then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := AColor;
  end;
  LCell := AcquireVisualCell(LFactoryContext, Th5uVclSpacingCell);
  LCell.BindCell(LFactoryContext, ABounds, TValue.Empty, '', LAppearance);
  LCell.Paint(Self, Canvas);
end;

function Th5uVclCustomGrid.GetColumnViewportRect(AColumn: Th5uGridColumn): TRect;
var
  LLeft, LRight: Double;
begin
  Result := GetViewportRect;
  LLeft := Result.Left;
  LRight := Result.Right;
  h5uColumnViewport(FColumns, AColumn, FSpacing.DefaultColumnRightSpacing, IndicatorExtent, LLeft, LRight);
  Result.Left := Round(LLeft);
  Result.Right := Round(LRight);
end;

function Th5uVclCustomGrid.GetVisibleCellBounds(AColumn: Th5uGridColumn; const AColumnBounds, ARowBounds: TRect): TRect;
begin
  // Painting, pointer hit testing and cell editors must use the same clipped
  // rectangle, including rows partially scrolled underneath the header.
  Result := GetColumnViewportRect(AColumn);
  Result.Top := ARowBounds.Top;
  Result.Bottom := ARowBounds.Bottom;
  IntersectRect(Result, Result, GetDataViewportRect);
  IntersectRect(Result, Result, AColumnBounds);
end;

procedure Th5uVclCustomGrid.EditorChanged(Sender: TObject);
begin
  // A changed value permits another automatic commit. Showing a validation
  // dialog, and the focus changes it causes, must not retry the failed value.
  FEditorExitBlocked := False;
end;

procedure Th5uVclCustomGrid.EditorExit(Sender: TObject);
begin
  if Assigned(FActiveEditor) and FActiveEditor.DeferExit then
    Exit;
  if not FCommittingEditor and not FEditorExitBlocked then
    CommitEditor;
end;

procedure Th5uVclCustomGrid.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

function Th5uVclCustomGrid.FindFirstVisibleRow(AOffset: Int64; out ATop: Integer): Int64;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if Assigned(FDataController) then
    Result := h5uFindFirstVisibleRow(GetViewRowCount, AOffset, GetDataViewportRect.Top, MetricRowExtent, ATop);
end;

function Th5uVclCustomGrid.GetDataCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  if Th5uElementFlag.FixedColumn in AContext.ElementFlags then
    Result := GetFixedCellClass(AContext)
  else
    Result := Th5uVclDataCell;
end;

function Th5uVclCustomGrid.GetDataViewportRect: TRect;
begin
  Result := GetViewportRect;
  Inc(Result.Top, GetHeaderHeight);
end;

function Th5uVclCustomGrid.GetEstimatedTotalRowHeight: Int64;
var
  LTotal: Th5uTotalRowHeight;
  LVariableSpacing: Boolean;
begin
  Result := 0;
  if not Assigned(FDataController) then
    Exit;
  LVariableSpacing := Assigned(FOnGetRowSpacing) or (FTree.Enabled and FTree.BranchEndBand.Enabled) or (FAdjacentGroupFolding.Enabled
    and (FAdjacentGroupFolding.EndBand.Visibility <> Th5uAdjacentGroupEndBandVisibility.Never));
  LTotal := h5uTotalRowHeight(FRowHeight, GetViewRowCount, FSpacing.RowSpacing, LVariableSpacing, PrepareViewRange, MetricRowExtent);
  Result := LTotal.Whole;
end;

function Th5uVclCustomGrid.GetFixedCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclFixedCell;
end;

function Th5uVclCustomGrid.GetHeaderCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclHeaderCell;
end;

function Th5uVclCustomGrid.GetHeaderHeight: Integer;
begin
  Result := Round(h5uHeaderHeight(FHeaderLayout, FShowHeader, FHeaderRowHeight, FSpacing.RowSpacing));
end;

function Th5uVclCustomGrid.GetOnConfigureInstance: Th5uConfigureInstanceEvent;
begin
  Result := FFactoryScope.OnConfigureInstance;
end;

function Th5uVclCustomGrid.GetOnCreateInstance: Th5uCreateInstanceEvent;
begin
  Result := FFactoryScope.OnCreateInstance;
end;

function Th5uVclCustomGrid.GetOnGetClass: Th5uGetClassEvent;
begin
  Result := FFactoryScope.OnGetClass;
end;

function Th5uVclCustomGrid.GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AAllowMeasure: Boolean): Integer;
begin
  Result := Round(FRowMetrics.GetHeight(FRowHeight, FColumns, AViewRowIndex, ARowKey, AAllowMeasure, MetricCellHeight, MetricAdjustHeight));
end;

function Th5uVclCustomGrid.MetricCellHeight(ARow: Int64; AColumn: Th5uGridColumn): Double;
begin
  Result := MeasureCellHeight(ARow, AColumn);
end;

procedure Th5uVclCustomGrid.MetricAdjustHeight(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Double; var ACacheResult: Boolean);
var
  LContext: Th5uGetRowHeightContext;
  LHeight: Integer;
begin
  if not Assigned(FOnGetRowHeight) then
    Exit;
  LHeight := Round(AHeight);
  LContext := Default(Th5uGetRowHeightContext);
  LContext.Grid := Self;
  LContext.DataController := FDataController;
  LContext.RowKey := AKey;
  LContext.ViewRowIndex := ARow;
  LContext.SourceRowIndex := GetViewSourceRowIndex(ARow);
  LContext.IsEstimated := AEstimated;
  FOnGetRowHeight(Self, LContext, LHeight, ACacheResult);
  AHeight := LHeight;
end;

function Th5uVclCustomGrid.MetricRowExtent(ARow: Int64; AAllowMeasure: Boolean): Double;
var
  LKey: Th5uRowKey;
  LKind: Th5uElementKind;
  LColor: TColor;
  LStyle: string;
  LLevel, LClosed: Integer;
begin
  LKey := GetViewRowKey(ARow);
  Result := GetRowHeightFor(ARow, LKey, AAllowMeasure) + GetEffectiveRowSeparatorFor(ARow, LKey, LKind, LColor, LStyle, LLevel, LClosed);
end;

function Th5uVclCustomGrid.MetricRowSpacing(ARow: Int64; const AKey: Th5uRowKey): Double;
begin
  Result := GetRowSpacingFor(ARow, AKey);
end;

function Th5uVclCustomGrid.GetRowStyle(AViewRowIndex: Int64; out AStyleKey: TValue): string;
var
  LColumn: Th5uGridColumn;
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

function Th5uVclCustomGrid.GetEffectiveColumnRightSpacing(AColumn: Th5uGridColumn): Integer;
begin
  Result := h5uColumnRightSpacing(AColumn, FSpacing.DefaultColumnRightSpacing);
end;

procedure Th5uVclCustomGrid.InvalidateAdjacentGroupMap(AClearStates: Boolean);
begin
  FView.InvalidateAdjacentGroupMap(AClearStates);
end;

function Th5uVclCustomGrid.GetViewRowCount: Int64;
begin
  Result := FView.GetViewRowCount;
end;

function Th5uVclCustomGrid.GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
begin
  Result := FView.GetViewSourceRowIndex(AViewRowIndex);
end;

function Th5uVclCustomGrid.GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
begin
  Result := FView.GetViewRowKey(AViewRowIndex);
end;

function Th5uVclCustomGrid.GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
begin
  Result := FView.GetViewValue(AViewRowIndex, AFieldName);
end;

procedure Th5uVclCustomGrid.SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
begin
  FView.SetViewValue(AViewRowIndex, AFieldName, AValue);
end;

function Th5uVclCustomGrid.CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
begin
  Result := FView.CanEditViewValue(AViewRowIndex, AFieldName);
end;

function Th5uVclCustomGrid.GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
begin
  Result := FView.GetViewDisplayText(AViewRowIndex, AFieldName, ADisplayFormat);
end;

procedure Th5uVclCustomGrid.PrepareViewRange(AFirstViewRow, ACount: Int64);
begin
  FView.PrepareViewRange(AFirstViewRow, ACount);
end;

function Th5uVclCustomGrid.TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  Result := FView.TryGetAdjacentGroupRowInfo(AViewRowIndex, AInfo);
end;

procedure Th5uVclCustomGrid.PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
begin
  FView.PopulateAdjacentGroupContext(AContext, AViewRowIndex);
end;

procedure Th5uVclCustomGrid.DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
begin
  FView.DoAdjacentGroupStateChanged(AInfo);
end;

function Th5uVclCustomGrid.GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Integer;
var
  LContext: Th5uGetRowHeightContext;
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
  Result := EnsureRange(Result, 0, 1000);
end;

function Th5uVclCustomGrid.GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out AElementKind: Th5uElementKind; out AColor: TColor; out AStyleName: string;
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
    Th5uElementKind.AdjacentGroupEndBand:
      AColor := ResolveAdjacentGroupEndColor(AViewRowIndex, ARowKey);
    Th5uElementKind.TreeBranchEndBand:
      AColor := ResolveTreeBranchEndColor(AViewRowIndex, ARowKey);
    else
      AColor := ResolveRowSpacingColor;
  end;
end;

function Th5uVclCustomGrid.GetGridLines: Boolean;
begin
  // Explicit per-column RightSpacing values are intentionally independent
  // from this compatibility property.
  Result := (FSpacing.Left > 0) or (FSpacing.Top > 0) or (FSpacing.Right > 0) or (FSpacing.Bottom > 0) or (FSpacing.RowSpacing > 0)
    or (FSpacing.DefaultColumnRightSpacing > 0);
end;

function Th5uVclCustomGrid.GetTotalColumnWidth: Integer;
var
  LColumn: Th5uGridColumn;
begin
  Result := 0;
  for LColumn in FColumns.VisibleColumns do
    Inc(Result, LColumn.LayoutWidth + GetEffectiveColumnRightSpacing(LColumn));
  if FShowRowIndicator then
    Inc(Result, FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing);
end;

function Th5uVclCustomGrid.GetUnpaddedViewportRect: TRect;
begin
  Result := ClientRect;
  if FVScrollBar.Visible then
    Dec(Result.Right, FVScrollBar.Width);
  if FHScrollBar.Visible then
    Dec(Result.Bottom, FHScrollBar.Height);
end;

function Th5uVclCustomGrid.GetViewportRect: TRect;
begin
  Result := GetUnpaddedViewportRect;

  Inc(Result.Left, FSpacing.Left);
  Inc(Result.Top, FSpacing.Top);
  Dec(Result.Right, FSpacing.Right);
  Dec(Result.Bottom, FSpacing.Bottom);

  if Result.Right < Result.Left then
    Result.Right := Result.Left;
  if Result.Bottom < Result.Top then
    Result.Bottom := Result.Top;
end;

function Th5uVclCustomGrid.ResolveColor(const AColor: TColor; AFallback: TColor): TColor;
begin
  if AColor = clDefault then
    Result := AFallback
  else
    Result := AColor;
end;

function Th5uVclCustomGrid.ResolveDefaultCellColor: TColor;
begin
  Result := ResolveColor(FAppearance.DefaultCellColor, h5uGetVclPalette(FTheme).CellBackground);
end;

function Th5uVclCustomGrid.ResolveRowSpacingColor: TColor;
begin
  Result := ResolveColor(FSpacing.RowSpacingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclCustomGrid.ResolveColumnSpacingColor: TColor;
begin
  Result := ResolveColor(FSpacing.ColumnSpacingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclCustomGrid.ResolveContentPaddingColor: TColor;
begin
  Result := ResolveColor(FSpacing.ContentPaddingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclCustomGrid.ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
var
  LAppearance: Th5uResolvedAppearance;
begin
  if FTree.BranchEndBand.Color <> clDefault then
    Exit(ResolveColor(FTree.BranchEndBand.Color, ResolveRowSpacingColor));

  if SameText(FTree.BranchEndBand.StyleName, 'TreeBranchEnd') then
    Exit(h5uGetVclPalette(FTheme).TreeBranchEndBackground);

  if FTree.BranchEndBand.StyleName <> '' then
  begin
    LAppearance := ResolveRowAppearance(AViewRowIndex, ARowKey, FTree.BranchEndBand.StyleName);
    if LAppearance.HasBackground then
      Exit(LAppearance.Background);
  end;

  Result := ResolveRowSpacingColor;
end;

function Th5uVclCustomGrid.ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
var
  LAppearance: Th5uResolvedAppearance;
begin
  if FAdjacentGroupFolding.EndBand.Color <> clDefault then
    Exit(ResolveColor(FAdjacentGroupFolding.EndBand.Color, ResolveRowSpacingColor));

  if SameText(FAdjacentGroupFolding.EndBand.StyleName, 'AdjacentGroupEnd') then
    Exit(h5uGetVclPalette(FTheme).AdjacentGroupEndBackground);

  if FAdjacentGroupFolding.EndBand.StyleName <> '' then
  begin
    LAppearance := ResolveRowAppearance(AViewRowIndex, ARowKey, FAdjacentGroupFolding.EndBand.StyleName);
    if LAppearance.HasBackground then
      Exit(LAppearance.Background);
  end;

  Result := ResolveRowSpacingColor;
end;

function Th5uVclCustomGrid.GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCellClass;
var
  LCacheScope: Th5uFactoryCacheScope;
begin
  Result := Th5uVclVisualCellClass(FFactoryScope.ResolveClass(AContext, Th5uVclVisualCell, ADefaultClass, LCacheScope));
end;

function Th5uVclCustomGrid.HitTest(X, Y: Integer): Th5uHitTestInfo;
var
  LFirst, LLast: Integer;
  LColumnInfo: Th5uVisibleColumnInfo;
  LRowInfo: Th5uVisibleRowInfo;
  LGlyphRect: TRect;
begin
  Result := Th5uHitTestInfo.Empty;
  if not GetViewportRect.Contains(Point(X, Y)) then
    Exit;

  if FShowHeader and (Y < GetDataViewportRect.Top) then
  begin
    if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    begin
      Result.HeaderCell := HeaderCellAtPoint(X, Y);
      if not Assigned(Result.HeaderCell) or not FHeaderLayout.ColumnRange(Result.HeaderCell, FColumns.VisibleColumns, LFirst, LLast) then
        Exit(Th5uHitTestInfo.Empty);
      Result.Kind := Th5uHitKind.Header;
      Result.ColumnIndex := LFirst;
      Result.Column := FAllColumns[LFirst].Column;
      Result.Bounds := GetHeaderCellBounds(Result.HeaderCell);
      IntersectRect(Result.Bounds, Result.Bounds, GetHeaderCellViewport(Result.HeaderCell));
      Exit;
    end;
    if ColumnInfoAtPoint(X, Y, LColumnInfo) then
    begin
      Result.Kind := Th5uHitKind.Header;
      Result.Column := LColumnInfo.Column;
      Result.ColumnIndex := LColumnInfo.VisibleIndex;
      Result.Bounds := LColumnInfo.Bounds;
      IntersectRect(Result.Bounds, Result.Bounds, GetColumnViewportRect(LColumnInfo.Column));
      Result.Bounds.Top := GetViewportRect.Top;
      Result.Bounds.Bottom := Result.Bounds.Top + FHeaderRowHeight;
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
    Result.Kind := Th5uHitKind.AdjacentGroupGlyph;
    Result.Bounds := LGlyphRect;
    Exit;
  end;

  if FShowRowIndicator and (X < GetViewportRect.Left + FRowIndicatorWidth) then
  begin
    Result.Kind := Th5uHitKind.RowIndicator;
    Exit;
  end;

  if ColumnInfoAtPoint(X, Y, LColumnInfo) then
  begin
    Result.Kind := Th5uHitKind.DataCell;
    Result.Column := LColumnInfo.Column;
    Result.ColumnIndex := LColumnInfo.VisibleIndex;
    Result.Bounds := GetVisibleCellBounds(LColumnInfo.Column, LColumnInfo.Bounds, LRowInfo.Bounds);
  end;
end;

procedure Th5uVclCustomGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  if Assigned(FThumbHint) then
    FThumbHint.Visible := False;
end;

procedure Th5uVclCustomGrid.InvalidateAllRowHeights;
begin
  FRowMetrics.Clear;
end;

procedure Th5uVclCustomGrid.InvalidateRowHeight(const ARowKey: Th5uRowKey);
begin
  FRowMetrics.Remove(ARowKey.ToString);
  Invalidate;
end;

procedure Th5uVclCustomGrid.InvalidateVisibleRowHeights;
var
  LRow: Th5uVisibleRowInfo;
begin
  for LRow in FVisibleRows do
    FRowMetrics.Remove(LRow.RowKey.ToString);
  Invalidate;
end;

function Th5uVclCustomGrid.CanUpdateLayout: Boolean;
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

procedure Th5uVclCustomGrid.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  // Internal scrollbars, hints and cached editors are runtime implementation details.
  for I := 0 to ControlCount - 1 do
    if (Controls[I].Owner = Root) and (Controls[I].Owner <> Self) then
      Proc(Controls[I]);
end;

procedure Th5uVclCustomGrid.Loaded;
begin
  inherited;
  LayoutScrollBars;
  // Paint refreshes data-dependent layout; FormCreate may not have run yet.
  Invalidate;
end;

procedure Th5uVclCustomGrid.LayoutScrollBars;
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

function Th5uVclCustomGrid.MeasureCellHeight(AViewRowIndex: Int64; AColumn: Th5uGridColumn): Integer;
var
  LText: string;
  LRect: TRect;
  LFlags: Cardinal;
  LMaxByLines: Integer;
  LValue: TValue;
begin
  Result := FRowHeight.MinHeight;
  if not Assigned(FDataController) then
    Exit;

  if AColumn.DataType = Th5uColumnDataType.Image then
  begin
    LValue := GetCellValue(AColumn, AViewRowIndex, True);
    if LValue.IsType<TBytes> and (Length(LValue.AsType<TBytes>) > 0) then
      Result := Min(AColumn.MaxAutoHeight, Max(FRowHeight.MinHeight, 80));
    Exit;
  end;

  if not AColumn.AutoHeight then
    Exit;

  LText := GetCellText(AColumn, AViewRowIndex, True);

  Canvas.Font.Assign(Font);
  LRect := Rect(0, 0, Max(8, AColumn.LayoutWidth - 10), 0);
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
    Result := Min(Result, AColumn.MaxAutoHeight);
end;

procedure Th5uVclCustomGrid.CMCursorChanged(var Message: TMessage);
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

procedure Th5uVclCustomGrid.CMMouseLeave(var Message: TMessage);
begin
  if not Assigned(FResizingColumn) then
    SetResizeCursor(False);
  inherited;
end;

function Th5uVclCustomGrid.ColumnResizeAt(X, Y: Integer; ATouch: Boolean): Th5uGridColumn;
var
  LCandidates: TArray<Th5uResizeCandidate>;
  LView: TRect;
  I: Integer;
begin
  Result := nil;
  if not CanUpdateLayout or not FShowHeader or not FCustomization.AllowColumnResizing then
    Exit;
  if not GetViewportRect.Contains(Point(X, Y)) or (Y >= GetDataViewportRect.Top) then
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

function Th5uVclCustomGrid.IsResizeHeaderEdge(AX, AY: Double): Boolean;
var
  LHeader: Th5uHeaderLayoutCell;
begin
  Result := True;
  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
  begin
    LHeader := HeaderCellAtPoint(Round(AX - 1), Round(AY));
    Result := Assigned(LHeader) and (Abs(GetHeaderCellBounds(LHeader).Right - AX) <= 0.1);
  end;
end;

procedure Th5uVclCustomGrid.SetResizeCursor(AActive: Boolean);
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

function Th5uVclCustomGrid.BeginColumnResize(X, Y: Integer; ATouch: Boolean): Boolean;
begin
  FResizingColumn := ColumnResizeAt(X, Y, ATouch);
  Result := Assigned(FResizingColumn);
  if not Result then
     Exit;
  FResizeStartX := X;
  FResizeOriginalWidth := FResizingColumn.LayoutWidth;
  MouseCapture := True;
  if not ATouch then
    SetResizeCursor(True);
end;

procedure Th5uVclCustomGrid.UpdateColumnResize(X: Integer);
begin
  if not Assigned(FResizingColumn) then
    Exit;
  if CanUpdateLayout and FCustomization.AllowColumnResizing and MouseCapture then
    if h5uTryResizeColumn(FColumns, FResizingColumn, FResizeOriginalWidth, X - FResizeStartX) then
      Exit;
  EndSelectionDrag;
end;

procedure Th5uVclCustomGrid.SelectRightClickCell(const AHit: Th5uHitTestInfo);
var
  LCell: Th5uCellAddress;
begin
  if not FSelection.RightClickSelect or (AHit.Kind <> Th5uHitKind.DataCell) then
    Exit;
  LCell.RowIndex := AHit.RowIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.ColumnId := AHit.Column.Id;
  h5uSelectRightClick(FSelection, LCell, AHit.Column.CanSelect, TryFocusCell);
end;

function Th5uVclCustomGrid.CanMoveColumn(AColumn: Th5uGridColumn): Boolean;
begin
  Result := h5uCanMoveColumn(FColumns, FCustomization.AllowColumnMoving, AColumn);
end;

function Th5uVclCustomGrid.IsColumnMoveGesture(AColumn: Th5uGridColumn; AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(CanMoveColumn(AColumn),
    FCustomization.ColumnMovingGesture = Th5uColumnRowMovingGesture.AltDrag, AShift);
end;

function Th5uVclCustomGrid.IsRowMoveGesture(AShift: TShiftState): Boolean;
begin
  Result := h5uMoveGestureAllowed(Assigned(FOnRowsMoved) and FCustomization.AllowRowMoving,
    FCustomization.RowMovingGesture = Th5uColumnRowMovingGesture.AltDrag, AShift);
end;

function Th5uVclCustomGrid.GetHeaderCellBounds(ACell: Th5uHeaderLayoutCell): TRect;
var
  LFirst, LLast, LSpan: Integer;
begin
  Result := TRect.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then
    Exit;
  Result.Left := FAllColumns[LFirst].Bounds.Left;
  Result.Right := FAllColumns[LLast].Bounds.Right;
  Result.Top := GetViewportRect.Top + ACell.LayoutRow * (FHeaderRowHeight + FSpacing.RowSpacing);
  LSpan := Max(1, ACell.RowSpan);
  Result.Bottom := Result.Top + LSpan * FHeaderRowHeight + (LSpan - 1) * FSpacing.RowSpacing;
end;

function Th5uVclCustomGrid.GetHeaderCellViewport(ACell: Th5uHeaderLayoutCell): TRect;
var
  LFirst, LLast: Integer;
begin
  Result := TRect.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LFirst >= Length(FAllColumns)) then
    Exit;
  Result := GetColumnViewportRect(FAllColumns[LFirst].Column);
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function Th5uVclCustomGrid.HeaderCellAtPoint(X, Y: Integer): Th5uHeaderLayoutCell;
var
  I: Integer;
  LRect: TRect;
begin
  Result := nil;
  if not FHeaderLayout.Enabled or not FShowHeader then
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

function Th5uVclCustomGrid.BeginColumnMove(AColumnIndex: Integer; X, Y: Integer): Boolean;
var
  LPlan: Th5uColumnMovePlan;
  LHit: Th5uHitTestInfo;
begin
  Result := False;
  LHit := HitTest(X, Y);
  if not h5uPlanColumnMove(FColumns, FHeaderLayout, FSelection, FCustomization, AColumnIndex, LHit.HeaderCell, LPlan) then
    Exit;
  FMovingColumns := LPlan.Columns;
  FMovingHeaderCell := LPlan.HeaderCell;
  FMoveCaption := LPlan.Caption;
  FMovePoint := Point(X, Y);
  FMovePreviewWidth := EnsureRange(LPlan.Columns[0].LayoutWidth, MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  if Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
    FMovePreviewWidth := EnsureRange(LHit.Bounds.Width, MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  FSelectionDragOrigin := Point(X, Y);
  MouseCapture := True;
  Result := True;
end;

function Th5uVclCustomGrid.BeginRowMove(ARowIndex: Int64; X, Y: Integer): Boolean;
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

procedure Th5uVclCustomGrid.UpdateHeaderMove(X, Y: Integer);
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

function Th5uVclCustomGrid.GetColumnMoveHeaderBounds(const AInfo: Th5uVisibleColumnInfo): TRect;
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

function Th5uVclCustomGrid.ColumnMoveTarget(X, Y: Integer; out ANewIndex, AMarkerX, AMarkerTop: Integer): Boolean;
var
  LHit: Th5uHitTestInfo;
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
  if (LHit.Kind <> Th5uHitKind.Header) or not Assigned(LHit.Column) then
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

procedure Th5uVclCustomGrid.DrawColumnMoveFeedback;
var
  LPalette: Th5uVclPalette;
  LCanvas: TCanvas;
  LFill: TBitmap;
  LBlend: TBlendFunction;
  LSavedDC: Integer;
  LView, LRect, LTextRect: TRect;
  LInfo: Th5uVisibleColumnInfo;
  LColumn: Th5uGridColumn;
  LMarkerX, LMarkerTop, LWidth, LHeight, LLeft, LTop, LOffset, LNewIndex, LEdge, LMargin: Integer;
  LValid, LSourcePainted: Boolean;

  function Scaled(AValue: Integer): Integer;
  begin
    Result := MulDiv(AValue, CurrentPPI, 96);
  end;

begin
  if not FMoveDragging or (Length(FMovingColumns) = 0) or not FShowHeader or not MouseCapture then
    Exit;
  if Assigned(FMovingHeaderCell) and not FHeaderLayout.ContainsCell(FMovingHeaderCell) then
    Exit;
  LView := GetViewportRect;
  if LView.IsEmpty then
    Exit;
  LPalette := h5uGetVclPalette(FTheme);
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
    LHeight := Max(Scaled(30), FHeaderRowHeight);
    LOffset := Scaled(16);
    if FMoveTouch then
      LOffset := Scaled(40);
    LLeft := EnsureRange(FMovePoint.X - LWidth div 2, LView.Left + LMargin, Max(LView.Left + LMargin, LView.Right - LWidth - LMargin));
    LTop := EnsureRange(FMovePoint.Y + LOffset, LView.Top + LMargin, Max(LView.Top + LMargin, LView.Bottom - LHeight - LMargin));
    LRect := Rect(LLeft, LTop, LLeft + LWidth, LTop + LHeight);
    LFill.Canvas.Brush.Color := clBlack;
    LFill.Canvas.FillRect(Rect(0, 0, 1, 1));
    LBlend.SourceConstantAlpha := 64;
    Winapi.Windows.AlphaBlend(LCanvas.Handle, LRect.Left + Scaled(3), LRect.Top + Scaled(3),
      LRect.Width, LRect.Height, LFill.Canvas.Handle, 0, 0, 1, 1, LBlend);
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

function Th5uVclCustomGrid.FinishHeaderMove(X, Y: Integer): Boolean;
var
  LHit: Th5uHitTestInfo;
  LMovingColumns: TArray<Th5uGridColumn>;
  LContext: Th5uRowsMovedContext;
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
  if not LDragging then
  begin
    if (Length(LMovingColumns) > 0) and (LHit.Kind = Th5uHitKind.Header) and (LHit.Column = FMouseDownHit.Column) then
      SelectHeaderRange(Th5uSelectionKind.Columns, -1, LHit.ColumnIndex, [])
    else if (Length(LContext.RowKeys) > 0) and (LHit.Kind = Th5uHitKind.RowIndicator) and (LHit.RowKey = FMouseDownHit.RowKey) then
      SelectHeaderRange(Th5uSelectionKind.Rows, LHit.RowIndex, -1, []);
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
    if not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving or not (LHit.Kind in [Th5uHitKind.RowIndicator, Th5uHitKind.DataCell]) then
     Exit;
    if not h5uRowMoveTarget(GetViewRowCount, LHit.RowIndex, LHit.RowKey, GetViewRowKey, GetViewSourceRowIndex, LContext) then
      Exit;
    FOnRowsMoved(Self, LContext);
  end;
end;

procedure Th5uVclCustomGrid.BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Integer; AShift: TShiftState);
begin
  FSelectingRange := True;
  FSelectionDragging := False;
  FSelectionDragKind := AKind;
  FSelectionDragShift := AShift;
  FSelectionDragOrigin := Point(X, Y);
  FSelectionDragLast := Th5uCellAddress.Empty;
  MouseCapture := True;
end;

procedure Th5uVclCustomGrid.EndSelectionDrag;
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

procedure Th5uVclCustomGrid.UpdateSelectionDrag(X, Y: Integer);
var
  LHit: Th5uHitTestInfo;
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
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
  LCell := Th5uCellAddress.Empty;
  case FSelectionDragKind of
    Th5uSelectionKind.CellRanges:
      begin
        if (LHit.Kind <> Th5uHitKind.DataCell) or not FSelection.AnchorCell.IsValid then
          Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
    Th5uSelectionKind.Rows:
      begin
        if not (LHit.Kind in [Th5uHitKind.RowIndicator, Th5uHitKind.DataCell]) then
          Exit;
        LCell.RowIndex := LHit.RowIndex;
        LCell.RowKey := LHit.RowKey;
      end;
    Th5uSelectionKind.Columns:
      begin
        if not (LHit.Kind in [Th5uHitKind.Header, Th5uHitKind.DataCell]) then
          Exit;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.ColumnId := LHit.Column.Id;
      end;
  end;
  if (LCell.RowIndex = FSelectionDragLast.RowIndex) and (LCell.RowKey = FSelectionDragLast.RowKey) and (LCell.ColumnIndex
    = FSelectionDragLast.ColumnIndex) and (LCell.ColumnId = FSelectionDragLast.ColumnId) then
    Exit;
  if FSelectionDragKind = Th5uSelectionKind.CellRanges then
  begin
    if not TryFocusCell(LCell, False) then
      Exit;
    LRange := Th5uCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex);
    FSelection.AddCellRange(LRange, ssCtrl in FSelectionDragShift, True);
  end
  else
    SelectHeaderRange(FSelectionDragKind, LCell.RowIndex, LCell.ColumnIndex, FSelectionDragShift + [ssShift]);
  FSelectionDragLast := LCell;
end;

procedure Th5uVclCustomGrid.SelectHeaderRange(AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
begin
  if CanUpdateLayout then
    FNavigation.SelectHeaderRange(FColumns, FSelection, GetViewRowCount, GetViewRowKey, AKind, ARow, AColumn, AShift);
end;

procedure Th5uVclCustomGrid.DoExit;
begin
  EndSelectionDrag;
  inherited;
end;

procedure Th5uVclCustomGrid.WMCancelMode(var Message: TWMCancelMode);
begin
  EndSelectionDrag;
  inherited;
end;

procedure Th5uVclCustomGrid.WMCaptureChanged(var Message: TMessage);
begin
  if Message.LParam <> LPARAM(Handle) then
    EndSelectionDrag;
  inherited;
end;

procedure Th5uVclCustomGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = Th5uEditorMode.Graphic) then
    FActiveEditor.MouseDown(Button, Shift, PointF(X, Y));
  EndSelectionDrag;
  FMoveTouch := ssTouch in Shift;
  inherited;
  // VCL dispatches DblClick before this second MouseDown. Open the editor here
  // using the event coordinates, without taking focus back from it afterwards.
  if ssDouble in Shift then
  begin
    FMouseDownHit := HitTest(X, Y);
    if (Button = mbLeft) and (FMouseDownHit.Kind = Th5uHitKind.DataCell)
      and CellEditorHit(FMouseDownHit.Column, FMouseDownHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), PointF(X, Y)) then
      StartEdit(FMouseDownHit);
    Exit;
  end;
  SetFocus;
  FMouseDownHit := HitTest(X, Y);

  if (Button = mbRight) and (FMouseDownHit.Kind = Th5uHitKind.Header) and FCustomization.ShowColumnChooser then
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

  if FMouseDownHit.Kind = Th5uHitKind.AdjacentGroupGlyph then
  begin
    ToggleAdjacentGroup(FMouseDownHit.RowIndex);
    Exit;
  end;

  if FMouseDownHit.Kind = Th5uHitKind.Header then
  begin
    if IsColumnMoveGesture(FMouseDownHit.Column, Shift) then
    begin
      BeginColumnMove(FMouseDownHit.ColumnIndex, X, Y);
      Exit;
    end;
    if FMouseDownHit.Column.CanSelect and (Th5uSelectionKind.Columns in FSelection.AllowedKinds) then
    begin
      SelectHeaderRange(Th5uSelectionKind.Columns, -1, FMouseDownHit.ColumnIndex, Shift);
      BeginSelectionDrag(Th5uSelectionKind.Columns, X, Y, Shift);
    end;
    Exit;
  end;

  if FMouseDownHit.Kind = Th5uHitKind.RowIndicator then
  begin
    if IsRowMoveGesture(Shift) then
    begin
      BeginRowMove(FMouseDownHit.RowIndex, X, Y);
      Exit;
    end;
    if Th5uSelectionKind.Rows in FSelection.AllowedKinds then
    begin
      SelectHeaderRange(Th5uSelectionKind.Rows, FMouseDownHit.RowIndex, -1, Shift);
      BeginSelectionDrag(Th5uSelectionKind.Rows, X, Y, Shift);
    end;
    Exit;
  end;

  if FMouseDownHit.Kind = Th5uHitKind.DataCell then
  begin
    LCell.RowIndex := FMouseDownHit.RowIndex;
    LCell.ColumnIndex := FMouseDownHit.ColumnIndex;
    LCell.RowKey := FMouseDownHit.RowKey;
    LCell.ColumnId := FMouseDownHit.Column.Id;

    if (ssShift in Shift) and FSelection.AnchorCell.IsValid then
      LRange := Th5uCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex)
    else
      LRange := Th5uCellRange.Create(LCell.RowIndex, LCell.RowIndex, LCell.ColumnIndex, LCell.ColumnIndex);

    if not TryFocusCell(LCell, not (ssShift in Shift)) then
      Exit;
    FSelection.AddCellRange(LRange, ssCtrl in Shift, ssShift in Shift);
    BeginSelectionDrag(Th5uSelectionKind.CellRanges, X, Y, Shift);
    // Wait for release: the same MouseDown can still become a range drag.
    FMouseEditPending := not (ssCtrl in Shift) and not (ssShift in Shift);
  end;
end;

procedure Th5uVclCustomGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = Th5uEditorMode.Graphic) then
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
procedure Th5uVclCustomGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LHit: Th5uHitTestInfo;
  LDragged, LEdit: Boolean;
begin
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = Th5uEditorMode.Graphic) then
    FActiveEditor.MouseUp(Button, Shift, PointF(X, Y));
  if (Button = TMouseButton.mbLeft) and Assigned(FResizingColumn) then
  begin
    try
      UpdateColumnResize(X);
    finally
      EndSelectionDrag;
    end;
    FMouseDownHit := Th5uHitTestInfo.Empty;
    inherited;
    Exit;
  end;
  if (Button = TMouseButton.mbLeft) and FinishHeaderMove(X, Y) then
  begin
    FMouseDownHit := Th5uHitTestInfo.Empty;
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
    FMouseDownHit := Th5uHitTestInfo.Empty;
    Exit;
  end;

  if Button = mbLeft then
  begin
    LHit := HitTest(X, Y);
    if (LHit.Kind = FMouseDownHit.Kind) and (LHit.Column = FMouseDownHit.Column) and (LHit.RowIndex = FMouseDownHit.RowIndex) and (LHit.Kind
      in [Th5uHitKind.DataCell, Th5uHitKind.Header, Th5uHitKind.RowIndicator]) then
    begin
      if LEdit and (LHit.Kind = Th5uHitKind.DataCell) then
      begin
        if CellEditorClick(LHit.Column, LHit.RowIndex) then
        begin
          if CellEditorHit(LHit.Column, LHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), TPointF.Create(FSelectionDragOrigin))
            and CellEditorHit(LHit.Column, LHit.RowIndex, TRectF.Create(FMouseDownHit.Bounds), PointF(X, Y))
          then
            StartEdit(LHit);
        end
        else
          if FImmediateEdit then
            EditFocusedCell(True);
      end;
      NotifyCellClick(LHit.Column, LHit.RowIndex, LHit.Kind = Th5uHitKind.Header, LHit.Kind = Th5uHitKind.RowIndicator);
    end;
  end;
  FSelectingRange := False;
end;

procedure Th5uVclCustomGrid.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  if not CanMoveColumn(AColumn) then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.ToggleAdjacentGroup(AViewRowIndex: Int64);
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

procedure Th5uVclCustomGrid.SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
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

procedure Th5uVclCustomGrid.ExpandAllAdjacentGroups;
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

procedure Th5uVclCustomGrid.CollapseAllAdjacentGroups;
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

procedure Th5uVclCustomGrid.ResetAdjacentGroupStates;
begin
  FAutoWidthsDirty := True;
  FView.ResetAdjacentGroupStates;
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

function Th5uVclCustomGrid.IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
begin
  Result := FView.IsAdjacentGroupCollapsed(AViewRowIndex);
end;

procedure Th5uVclCustomGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;

  if AComponent = FDataController then
    DataController := nil;
  if AComponent = FSharedClassFactory then
    SharedClassFactory := nil;
end;

procedure Th5uVclCustomGrid.OptionsChanged(Sender: TObject);
begin
  FAutoWidthsDirty := True;
  if Sender = FAdjacentGroupFolding then
    InvalidateAdjacentGroupMap(False);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.Paint;
var
  LPalette: Th5uVclPalette;
  LViewRect: TRect;
  LDataRect: TRect;
begin
  if not CanUpdateLayout then
    Exit;
  LPalette := h5uGetVclPalette(FTheme);
  Canvas.Brush.Color := LPalette.EmptyArea;
  Canvas.Brush.Style := bsSolid;
  PrepareGridCanvas(ClientRect, Th5uElementKind.Grid);
  Canvas.FillRect(ClientRect);
  Canvas.Font.Assign(Font);

  UpdateScrollBars;
  BuildColumnLayout;
  BeginVisualPass;

  DrawContentPadding;

  LViewRect := GetViewportRect;
  Canvas.Brush.Color := LPalette.GridBackground;
  Canvas.Brush.Style := bsSolid;
  PrepareGridCanvas(LViewRect, Th5uElementKind.View);
  Canvas.FillRect(LViewRect);

  LDataRect := GetDataViewportRect;
  Canvas.Brush.Color := ResolveDefaultCellColor;
  Canvas.Brush.Style := bsSolid;
  PrepareGridCanvas(LDataRect, Th5uElementKind.Grid);
  Canvas.FillRect(LDataRect);

  DrawHeaders;
  DrawRows;
  DrawColumnMoveFeedback;
  if Assigned(FOnAfterDraw) then
    FOnAfterDraw(Self, Canvas);
end;

procedure Th5uVclCustomGrid.RebuildAfterLayoutChange;
begin
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

procedure Th5uVclCustomGrid.Resize;
begin
  inherited;
  if not CanUpdateLayout then
    Exit;
  LayoutScrollBars;
  RebuildAfterLayoutChange;
end;

function Th5uVclCustomGrid.ResolveCellAppearance(const AContext: Th5uFactoryContext; AColumn: Th5uGridColumn; const ARowAppearance: Th5uResolvedAppearance;
  ASelected, AFocused: Boolean): Th5uResolvedAppearance;
var
  LPalette: Th5uVclPalette;
begin
  Result := ARowAppearance;
  LPalette := h5uGetVclPalette(FTheme);

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

function Th5uVclCustomGrid.ResolveRowAppearance(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; const AStyleName: string): Th5uResolvedAppearance;
var
  LPalette: Th5uVclPalette;
begin
  Result.Clear;
  Result.StyleName := AStyleName;
  Result.HasBackground := True;
  LPalette := h5uGetVclPalette(FTheme);

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

function Th5uVclCustomGrid.RowInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleRowInfo): Boolean;
var
  LInfo: Th5uVisibleRowInfo;
begin
  for LInfo in FVisibleRows do
    if PtInRect(LInfo.Bounds, Point(X, Y)) then
    begin
      AInfo := LInfo;
      Exit(True);
    end;
  Result := False;
end;

procedure Th5uVclCustomGrid.ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
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

    if (FScrolling.VerticalMode = Th5uVerticalScrollMode.WholeRows) and (ScrollCode = scEndScroll) then
    begin
      LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
      if LRowIndex >= 0 then
      begin
        FVerticalOffset := FVerticalOffset + (LTop - GetDataViewportRect.Top);
        FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);
        ScrollPos := FVerticalOffset;
      end;
    end;

    if Th5uScrollHintTrigger.ThumbTracking in FScrollHints.Triggers then
      ShowThumbHint(Th5uScrollAxis.Vertical, Th5uScrollHintTrigger.ThumbTracking);
  end
  else
  begin
    FHorizontalOffset := EnsureRange(ScrollPos, 0, FHScrollBar.Max);
    if Th5uScrollHintTrigger.ThumbTracking in FScrollHints.Triggers then
      ShowThumbHint(Th5uScrollAxis.Horizontal, Th5uScrollHintTrigger.ThumbTracking);
  end;

  Invalidate;
  if ScrollCode = scEndScroll then
  begin
    FThumbHintTimer.Enabled := False;
    FThumbHintTimer.Enabled := True;
  end;
end;

procedure Th5uVclCustomGrid.SelectionChanged(Sender: TObject);
var
  LOld, LNew: Th5uCellAddress;
begin
  Invalidate;
  if not CanUpdateLayout then
     Exit;
  LOld := FLastNotifiedCell;
  LNew := FSelection.FocusedCell;
  FLastNotifiedCell := LNew;
  h5uNotifyFocusChange(Self, FColumns, LOld, LNew, FOnCellExit, FOnCellEnter, FOnSelectionChange);
end;

procedure Th5uVclCustomGrid.SetColumns(const AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetCustomization(const AValue: Th5uCustomizationOptions);
begin
  FCustomization.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetAppearance(const AValue: Th5uGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetTree(const AValue: Th5uTreeOptions);
begin
  if Assigned(AValue) then
    FTree.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetAdjacentGroupFolding(const AValue: Th5uAdjacentGroupFoldingOptions);
begin
  if Assigned(AValue) then
    FAdjacentGroupFolding.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetGridLines(const AValue: Boolean);
begin
  if AValue then
    FSpacing.SetAllSeparators(1)
  else
    FSpacing.SetAllSeparators(0);
end;

procedure Th5uVclCustomGrid.SetSpacing(const AValue: Th5uGridSpacingOptions);
begin
  FSpacing.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetDataController(const AValue: Th5uCustomDataController);
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

procedure Th5uVclCustomGrid.SetHeaderLayout(const AValue: Th5uHeaderLayout);
begin
  FHeaderLayout.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.SetHeaderRowHeight(const AValue: Integer);
begin
  FHeaderRowHeight := EnsureRange(AValue, 16, 200);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
begin
  FFactoryScope.OnConfigureInstance := AValue;
end;

procedure Th5uVclCustomGrid.SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
begin
  FFactoryScope.OnCreateInstance := AValue;
end;

procedure Th5uVclCustomGrid.SetOnGetClass(const AValue: Th5uGetClassEvent);
begin
  FFactoryScope.OnGetClass := AValue;
end;

procedure Th5uVclCustomGrid.SetRowHeight(const AValue: Th5uRowHeightOptions);
begin
  FRowHeight.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetRowIndicatorWidth(const AValue: Integer);
begin
  FRowIndicatorWidth := EnsureRange(AValue, 0, 300);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.SetRowStyles(const AValue: Th5uRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclCustomGrid.SetScrolling(const AValue: Th5uScrollingOptions);
begin
  FScrolling.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclCustomGrid.SetScrollHints(const AValue: Th5uScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure Th5uVclCustomGrid.SetSelection(const AValue: Th5uGridSelection);
begin
  FSelection.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclCustomGrid.SetSharedClassFactory(const AValue: Th5uClassFactory);
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

procedure Th5uVclCustomGrid.SetTheme(const AValue: Th5uGridTheme);
var
  LPalette: Th5uVclPalette;
begin
  if FTheme = AValue then
    Exit;
  FTheme := AValue;
  LPalette := h5uGetVclPalette(FTheme);
  Color := LPalette.GridBackground;
  InvalidateAllRowHeights;
  Invalidate;
end;

procedure Th5uVclCustomGrid.SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
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

procedure Th5uVclCustomGrid.ShowColumnChooser;
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

procedure Th5uVclCustomGrid.ShowThumbHint(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger);
var
  LContext: Th5uThumbHintContext;
  LText: string;
  LVisible: Boolean;
  LPalette: Th5uVclPalette;
  LWidth: Integer;
  LHeight: Integer;
  LX: Integer;
  LY: Integer;
  LRatio: Double;
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

  LPalette := h5uGetVclPalette(FTheme);
  FThumbHint.Caption := LText;
  FThumbHint.Color := LPalette.ThumbHintBackground;
  FThumbHint.Font.Assign(Font);
  FThumbHint.Font.Color := LPalette.ThumbHintText;

  Canvas.Font.Assign(FThumbHint.Font);
  LWidth := Min(Max(80, Canvas.TextWidth(LText) + 18), Max(80, ClientWidth - 20));
  LHeight := Canvas.TextHeight('Wg') + 10;
  LViewport := GetViewportRect;

  if AAxis = Th5uScrollAxis.Vertical then
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

function Th5uVclCustomGrid.FocusedCellHit(out AHit: Th5uHitTestInfo): Boolean;
begin
  Result := CellHit(FSelection.FocusedCell, AHit);
end;

function Th5uVclCustomGrid.CellHit(const LCell: Th5uCellAddress; out AHit: Th5uHitTestInfo): Boolean;
var
  LColumns: TArray<Th5uGridColumn>;
  LView: TRect;
  LTop, LHeight, LLeft, LRight: Integer;
  LKey: Th5uRowKey;
  I: Integer;
begin
  Result := False;
  AHit := Th5uHitTestInfo.Empty;
  if not CanUpdateLayout or not Assigned(FDataController) then
    Exit;
  LColumns := FColumns.VisibleColumns;
  if not LCell.IsValid or (LCell.RowIndex >= GetViewRowCount) or (LCell.ColumnIndex >= Length(LColumns)) then
    Exit;
  LView := GetDataViewportRect;
  LTop := Round(h5uRowTop(LCell.RowIndex, MetricRowExtent));
  PrepareViewRange(LCell.RowIndex, 1);
  LKey := GetViewRowKey(LCell.RowIndex);
  LHeight := GetRowHeightFor(LCell.RowIndex, LKey);
  FVerticalOffset := Round(h5uRevealOffset(FVerticalOffset, LTop, LHeight, LView.Height));
  BuildColumnLayout;
  LLeft := LView.Left;
  if FShowRowIndicator then
    LLeft := LLeft + FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing;
  LRight := LView.Right;
  for I := 0 to High(LColumns) do
    case LColumns[I].FixedKind of
      Th5uFixedKind.Left:
        LLeft := LLeft + LColumns[I].LayoutWidth + GetEffectiveColumnRightSpacing(LColumns[I]);
      Th5uFixedKind.Right:
        LRight := LRight - LColumns[I].LayoutWidth - GetEffectiveColumnRightSpacing(LColumns[I]);
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
  AHit.Kind := Th5uHitKind.DataCell;
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

function Th5uVclCustomGrid.FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean): Boolean;
var
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LHit: Th5uHitTestInfo;
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
  if Result and AEdit and FImmediateEdit and not AExtend then
    EditFocusedCell(True);
end;

procedure Th5uVclCustomGrid.EditFocusedCell(AAutomatic: Boolean);
var
  LHit: Th5uHitTestInfo;
begin
  if not FocusedCellHit(LHit) then
    Exit;
  if AAutomatic and not CellEditorAutoEdit(LHit.Column, LHit.RowIndex) then
    Exit;
  StartEdit(LHit);
end;

function Th5uVclCustomGrid.NavigationRowExtent(ARow: Int64): Double;
begin
  Result := GetRowHeightFor(ARow, GetViewRowKey(ARow)) + FSpacing.RowSpacing;
end;

function Th5uVclCustomGrid.HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
var
  LAction: Th5uNavigationAction;
  LHit: Th5uHitTestInfo;
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

procedure Th5uVclCustomGrid.SearchCharacter(AChar: Char);
var
  LRow: Int64;
  LColumn: Integer;
begin
  if (AChar < #32) or Assigned(FEditColumn) or not CanUpdateLayout then
    Exit;
  if FNavigation.SearchCharacter(FColumns, FSelection, GetViewRowCount, PrepareViewRange, GetCellText, AChar, Now, LRow, LColumn) then
    FocusCell(LRow, LColumn, False, False);
end;

procedure Th5uVclCustomGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure Th5uVclCustomGrid.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  if Message.CharCode = vkEscape then
    Message.Result := 1;
end;

procedure Th5uVclCustomGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  C: Char;
begin
  inherited;
  if Assigned(FActiveEditor) and (FActiveEditor.Mode = Th5uEditorMode.Graphic) then
  begin
    C := #0;
    FActiveEditor.KeyDown(Key, C, Shift);
    Exit;
  end;
  if HandleNavigationKey(Key, Shift) then
    Key := 0;
end;

procedure Th5uVclCustomGrid.KeyPress(var Key: Char);
begin
  inherited;
  if Key >= #32 then
  begin
    SearchCharacter(Key);
    Key := #0;
  end;
end;

procedure Th5uVclCustomGrid.StartEdit(const AHit: Th5uHitTestInfo);
var
  LEditor: Th5uGridEditorItem;
  LCell: Th5uCellAddress;
  LContext: Th5uEditorContext;
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

procedure Th5uVclCustomGrid.ThumbHintTimer(Sender: TObject);
begin
  HideThumbHint;
end;

procedure Th5uVclCustomGrid.UpdateScrollBars;
var
  LPass: Integer;
  LNeedH, LNeedV: Boolean;
  LTotalWidth: Integer;
  LTotalHeight: Int64;
  LAvailableWidth: Integer;
  LAvailableHeight: Integer;
  LMaxHorizontal: Integer;
  LMaxVertical: Integer;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;

  FUpdatingScrollBars := True;
  try
    MeasureAutoWidths;
    LNeedH := False;
    LNeedV := False;
    // Compute scrollbar visibility locally. Toggling native controls during Paint
    // would schedule another paint forever on FMX.
    for LPass := 1 to 3 do
    begin
      LAvailableWidth := Max(0, ClientWidth - FSpacing.Left - FSpacing.Right);
      LAvailableHeight := Max(0, ClientHeight - FSpacing.Top - FSpacing.Bottom - GetHeaderHeight);
      if LNeedV then LAvailableWidth := Max(0, LAvailableWidth - FVScrollBar.Width);
      if LNeedH then LAvailableHeight := Max(0, LAvailableHeight - FHScrollBar.Height);
      ResolveColumnWidths(LAvailableWidth);
      LTotalWidth := GetTotalColumnWidth;
      LTotalHeight := GetEstimatedTotalRowHeight;
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

    LMaxHorizontal := Max(0, LTotalWidth - LAvailableWidth);
    LMaxVertical := h5uClampInt64ToInteger(Max(0, LTotalHeight - LAvailableHeight));

    FHScrollBar.Min := 0;
    FHScrollBar.Max := LMaxHorizontal;
    FHScrollBar.LargeChange := Max(1, LAvailableWidth);
    FHScrollBar.SmallChange := 24;

    FVScrollBar.Min := 0;
    FVScrollBar.Max := LMaxVertical;
    FVScrollBar.LargeChange := Max(1, LAvailableHeight);
    FVScrollBar.SmallChange := Max(1, FRowHeight.EstimatedHeight + FSpacing.RowSpacing);

    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, LMaxHorizontal);
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, LMaxVertical);
    FHScrollBar.Position := FHorizontalOffset;
    FVScrollBar.Position := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
  end;
end;

procedure Th5uVclCustomGrid.SetEditors(AValue: Th5uVclGridEditors);
begin
  CancelEditor;
  FEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Invalidate;
end;

procedure Th5uVclCustomGrid.SetDefaultEditors(AValue: Th5uDefaultEditors);
begin
  CancelEditor;
  FDefaultEditors.Assign(AValue);
  FAutoWidthsDirty := True;
  Invalidate;
end;

procedure Th5uVclCustomGrid.ClearEditorCache;
var
  I: Integer;
begin
  CancelEditor;
  FEditorCache.Clear;
  FAutoWidthsDirty := True;
  for I := 0 to FEditors.Count - 1 do
    FEditors[I].ReleaseEditor;
end;

function Th5uVclCustomGrid.CachedEditor(const AName: string): Th5uGridEditorItem;
begin
  Result := FEditorCache.Get(Th5uEditorPlatform.VCL, AName, '', FEditors.Find(AName));
end;

function Th5uVclCustomGrid.GetCellEditor(AColumn: Th5uGridColumn; ARow: Int64): Th5uGridEditorItem;
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
      raise Eh5uGrid.Create('Dynamische Editoren benötigen eine ColumnID.');
  end;
  Result := FEditorCache.Get(Th5uEditorPlatform.VCL, LName, LScope, FEditors.Find(LName));
end;

function Th5uVclCustomGrid.CellEditorAutoEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
var
  E: Th5uGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.CanAutoEdit;
end;

function Th5uVclCustomGrid.CellEditorHit(AColumn: Th5uGridColumn; ARow: Int64; const ABounds: TRectF; const APoint: TPointF): Boolean;
var
  E: Th5uGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.HitTest(ABounds, APoint);
end;

function Th5uVclCustomGrid.CellEditorContext(AColumn: Th5uGridColumn; ARow: Int64; const ABounds: TRectF): Th5uEditorContext;
begin
  Result := Default(Th5uEditorContext);
  Result.Grid := Self;
  Result.Column := AColumn;
  Result.RowIndex := ARow;
  Result.RowKey := GetViewRowKey(ARow);
  Result.Bounds := ABounds;
  Result.Value := GetCellValue(AColumn, ARow, False);
  Result.Text := GetCellText(AColumn, ARow, False);
  Result.Foreground := TAlphaColor(h5uGetVclPalette(FTheme).CellText);
  Result.Background := TAlphaColor(h5uGetVclPalette(FTheme).CellBackground);
end;

procedure Th5uVclCustomGrid.FinishEditor(ACommitted: Boolean);
var
  E: Th5uGridEditorItem;
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

procedure Th5uVclCustomGrid.EditorRequestCommit(Sender: TObject);
begin
  CommitEditor;
end;

procedure Th5uVclCustomGrid.EditorRequestCancel(Sender: TObject);
begin
  CancelEditor;
  Invalidate;
end;

procedure Th5uVclCustomGrid.ProcessEditorKey(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  EditorKeyDown(Sender, Key, Shift);
end;

function Th5uVclCustomGrid.CellEditorClick(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
var
  E: Th5uGridEditorItem;
begin
  E := GetCellEditor(AColumn, ARow);
  Result := Assigned(E) and E.ActivateOnClick;
end;

end.

