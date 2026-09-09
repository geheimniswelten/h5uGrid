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
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.StdCtrls,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Selection,
  h5u.Grid.Types,
  Vcl.h5u.Grid.Styles;

type
  Th5uVclGrid = class;
  Th5uVclVisualCell = class;
  Th5uVclVisualCellClass = class of Th5uVclVisualCell;

  Th5uCustomDrawStage = (
    BeforeDefault,
    AfterDefault
  );

  Th5uHitKind = (
    None,
    Header,
    RowIndicator,
    DataCell,
    AdjacentGroupGlyph
  );

  Th5uGetRowHeightContext = record
    Grid: Th5uVclGrid;
    DataController: Th5uCustomDataController;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    IsEstimated: Boolean;
  end;

  Th5uGetRowHeightEvent = procedure(Sender: TObject; const AContext: Th5uGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean) of object;

  Th5uGetRowSpacingEvent = procedure(Sender: TObject; const AContext: Th5uGetRowHeightContext; var ASpacing: Integer) of object;

  Th5uThumbHintContext = record
    Grid: Th5uVclGrid;
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
    procedure PrepareCanvas(AGrid: Th5uVclGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
    procedure PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas); virtual;
    function EffectiveBackground(AGrid: Th5uVclGrid): TColor;
    function EffectiveForeground(AGrid: Th5uVclGrid): TColor;
  public
    procedure BindCell(const AContext: Th5uFactoryContext; const ABounds: TRect; const AValue: TValue; const ADisplayText: string;
      const AAppearance: Th5uResolvedAppearance); virtual;
    procedure Paint(AGrid: Th5uVclGrid; ACanvas: TCanvas); virtual;

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
    procedure PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclDataCell = class(Th5uVclVisualCell)
  private
    FPicture: TPicture;
    FPictureSignature: Integer;
    procedure EnsurePicture;
  protected
    procedure PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  Th5uVclHeaderCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclFixedCell = class(Th5uVclDataCell);

  // Plus/minus glyph used for one contiguous run of equal adjacent IDs.
  // The class is resolved through the per-grid FactoryScope.
  Th5uVclAdjacentGroupGlyphCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas); override;
  end;

  Th5uVclGrid = class(TCustomControl)
  private
    FShowColumnModes: Boolean;
    FColumns: Th5uGridColumns;
    FHeaderLayout: Th5uHeaderLayout;
    FDataController: Th5uCustomDataController;
    FDataLink: Th5uDataControllerLink;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FSelection: Th5uGridSelection;
    FHeaderSelectionActive: Boolean;
    FHeaderSelectionKind: Th5uSelectionKind;
    FHeaderAnchor, FHeaderFocus: Th5uCellAddress;

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
    FHeaderRowHeight: Integer;
    FRowIndicatorWidth: Integer;
    FShowHeader: Boolean;
    FShowRowIndicator: Boolean;
    FAllowEditing: Boolean;
    FImmediateEdit: Boolean;
    FSearchText: string;
    FSearchTime: TDateTime;

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
    function HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
    procedure SearchCharacter(AChar: Char);
  private

    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditor: TEdit;
    FDateEditor: TDateTimePicker;
    FDateEditorKind: Th5uColumnEditorKind;
    FDateEditorOriginal: TDateTime;
    FDateEditorWasEmpty: Boolean;
    FEditRowIndex: Int64;
    FEditRowKey: Th5uRowKey;
    FEditColumn: Th5uGridColumn;
    FCommittingEditor: Boolean;
    FEditorOriginalText: string;
    FEditorExitBlocked: Boolean;

    FHorizontalOffset: Integer;
    FVerticalOffset: Integer;
    FVisibleColumns: TArray<Th5uVisibleColumnInfo>;
    FAllColumns: TArray<Th5uVisibleColumnInfo>;
    FVisibleRows: TArray<Th5uVisibleRowInfo>;
    FCellPool: TObjectList<Th5uVclVisualCell>;
    FRowHeightCache: TDictionary<string, Integer>;
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
    FOnGetTreeLevel: Th5uGetTreeLevelEvent;
    FOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    FOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    FOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;

    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Integer; AShift: TShiftState);
    procedure UpdateSelectionDrag(X, Y: Integer);
    procedure EndSelectionDrag;
    function ColumnResizeAt(X, Y: Integer; ATouch: Boolean): Th5uGridColumn;
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
    function GetCheckBoxRect(const ABounds: TRect): TRect;
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
    function GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Integer;
    function TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
    function GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
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

    procedure StartDateEdit(const AHit: Th5uHitTestInfo; AKind: Th5uColumnEditorKind);
    function DateEditorValue: TValue;
    function DateEditorVisible: Boolean;
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
    function ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;

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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateRowHeight(const ARowKey: Th5uRowKey);
    procedure InvalidateVisibleRowHeights;
    procedure InvalidateAllRowHeights;

    function HitTest(X, Y: Integer): Th5uHitTestInfo;
    procedure MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
    procedure SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
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
    property HeaderRowHeight: Integer read FHeaderRowHeight write SetHeaderRowHeight default 26;
    property RowIndicatorWidth: Integer read FRowIndicatorWidth write SetRowIndicatorWidth default 34;
    property ShowHeader: Boolean read FShowHeader write FShowHeader default True;
    property ShowRowIndicator: Boolean read FShowRowIndicator write FShowRowIndicator default True;
    property AllowEditing: Boolean read FAllowEditing write FAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write FImmediateEdit default False;
    // Convenience switch for all grid-wide one-pixel separators.
    // Explicit per-column RightSpacing values remain independently configurable.
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

uses
  Data.DB,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Themes,
  h5u.Grid.Data.Dataset,
  Vcl.h5u.Grid.Editors;

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

function Th5uVclVisualCell.EffectiveBackground(AGrid: Th5uVclGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasBackground then
    Result := FAppearance.Background
  else
    Result := AGrid.ResolveDefaultCellColor;
end;

function Th5uVclVisualCell.EffectiveForeground(AGrid: Th5uVclGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasForeground then
    Result := FAppearance.Foreground
  else
    Result := LPalette.CellText;
end;

procedure Th5uVclVisualCell.PrepareCanvas(AGrid: Th5uVclGrid; ACanvas: TCanvas; APart: Th5uElementPaintPart);
var
  LContext: Th5uVclDrawContext;
begin
  if not Assigned(AGrid.FOnPrepareElement) then Exit;
  LContext.FactoryContext := Context;
  LContext.Bounds := Bounds;
  LContext.DisplayText := DisplayText;
  LContext.Appearance := Appearance;
  AGrid.FOnPrepareElement(AGrid, Self, ACanvas, LContext, APart);
end;

procedure Th5uVclGrid.PrepareGridCanvas(const ABounds: TRect; AKind: Th5uElementKind);
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

procedure Th5uVclVisualCell.Paint(AGrid: Th5uVclGrid; ACanvas: TCanvas);
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

procedure Th5uVclVisualCell.PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas);
begin
  // Separators are independent layout elements. Painting them around every
  // cell would double their width and would make per-column spacing impossible.
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(FBounds);
end;

{ Th5uVclSpacingCell }

procedure Th5uVclSpacingCell.PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := Appearance.Background;
  PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Background);
  ACanvas.FillRect(Bounds);
end;

{ Th5uVclAdjacentGroupGlyphCell }

procedure Th5uVclAdjacentGroupGlyphCell.PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas);
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

procedure Th5uVclDataCell.PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas);
var
  LColumn: Th5uGridColumn;
  LTextRect: TRect;
  LFlags: Cardinal;
  LCheckRect: TRect;
  LRow: Th5uVisibleRowInfo;
  LGlyph: TRect;
  LChecked: Boolean;
  LImageRect: TRect;
  LScale: Double;
  LWidth: Integer;
  LHeight: Integer;
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

  case LColumn.DataType of
    Th5uColumnDataType.Boolean:
      begin
        LCheckRect := AGrid.GetCheckBoxRect(Bounds);
        LChecked := False;
        if not Value.IsEmpty then
        begin
          if Value.Kind = tkEnumeration then
            LChecked := Value.AsBoolean
          else
            LChecked := SameText(Value.ToString, 'True') or (Value.ToString = '1');
        end;

        ACanvas.Pen.Style := psSolid;
        ACanvas.Pen.Color := EffectiveForeground(AGrid);
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Brush.Color := EffectiveBackground(AGrid);
        PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
        ACanvas.Rectangle(LCheckRect);
        if LChecked then
        begin
          ACanvas.Pen.Width := 2;
          ACanvas.Pen.Color := EffectiveForeground(AGrid);
          PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Glyph);
          ACanvas.MoveTo(LCheckRect.Left + 3, LCheckRect.Top + 7);
          ACanvas.LineTo(LCheckRect.Left + 6, LCheckRect.Bottom - 3);
          ACanvas.LineTo(LCheckRect.Right - 2, LCheckRect.Top + 3);
          ACanvas.Pen.Width := 1;
        end;
      end;

    Th5uColumnDataType.Image:
      begin
        EnsurePicture;
        if Assigned(FPicture) and Assigned(FPicture.Graphic) and not FPicture.Graphic.Empty then
        begin
          LImageRect := Bounds;
          InflateRect(LImageRect, -4, -4);
          if LColumn.ImagePreserveAspectRatio then
          begin
            LScale := Min(LImageRect.Width / FPicture.Graphic.Width, LImageRect.Height / FPicture.Graphic.Height);
            LWidth := Max(1, Round(FPicture.Graphic.Width * LScale));
            LHeight := Max(1, Round(FPicture.Graphic.Height * LScale));
            LImageRect := Rect(LImageRect.Left + (LImageRect.Width - LWidth) div 2, LImageRect.Top + (LImageRect.Height - LHeight) div 2,
              LImageRect.Left + (LImageRect.Width - LWidth) div 2 + LWidth, LImageRect.Top + (LImageRect.Height - LHeight) div 2 + LHeight);
          end;
          ACanvas.StretchDraw(LImageRect, FPicture.Graphic);
        end;
      end;

    else
      begin
        LTextRect := Bounds;
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

        PrepareCanvas(AGrid, ACanvas, Th5uElementPaintPart.Text);
        DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect, LFlags);
      end;
  end;

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

procedure Th5uVclHeaderCell.PaintDefault(AGrid: Th5uVclGrid; ACanvas: TCanvas);
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
  DrawText(ACanvas.Handle, PChar(DisplayText), Length(DisplayText), LTextRect, DT_NOPREFIX or DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  ACanvas.Brush.Style := bsSolid;
end;

function Th5uVclGrid.AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCell;
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

procedure Th5uVclGrid.AutoCreateColumnsFromDataset(AClearExisting: Boolean);
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

        ftBoolean:
          LColumn.DataType := Th5uColumnDataType.Boolean;

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

procedure Th5uVclGrid.BeginVisualPass;
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

function Th5uVclGrid.BuildThumbHintText(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger; out AContext: Th5uThumbHintContext): string;
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

procedure Th5uVclGrid.BuildColumnLayout;
var
  LColumns: TArray<Th5uGridColumn>;
  LInfos: TList<Th5uVisibleColumnInfo>;
  LAll: TList<Th5uVisibleColumnInfo>;
  LViewRect: TRect;
  LDataLeft: Integer;
  LDataRight: Integer;
  LLeftX: Integer;
  LNormalX: Integer;
  LRightX: Integer;
  LColumn: Th5uGridColumn;
  LInfo: Th5uVisibleColumnInfo;
  LVisibilityRect: TRect;
  LSpacing: Integer;
  I: Integer;
begin
  LColumns := FColumns.VisibleColumns;
  LInfos := TList<Th5uVisibleColumnInfo>.Create;
  LAll := TList<Th5uVisibleColumnInfo>.Create;
  try
    LViewRect := GetViewportRect;
    LDataLeft := LViewRect.Left;
    if FShowRowIndicator then
      Inc(LDataLeft, FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing);
    LDataRight := LViewRect.Right;

    LLeftX := LDataLeft;
    for I := 0 to High(LColumns) do
      if LColumns[I].FixedKind = Th5uFixedKind.Left then
        Inc(LLeftX, LColumns[I].Width + GetEffectiveColumnRightSpacing(LColumns[I]));

    LRightX := LDataRight;
    for I := High(LColumns) downto 0 do
      if LColumns[I].FixedKind = Th5uFixedKind.Right then
        Dec(LRightX, LColumns[I].Width + GetEffectiveColumnRightSpacing(LColumns[I]));

    LNormalX := LLeftX - FHorizontalOffset;
    LLeftX := LDataLeft;

    for I := 0 to High(LColumns) do
    begin
      LColumn := LColumns[I];
      LSpacing := GetEffectiveColumnRightSpacing(LColumn);
      LInfo.Column := LColumn;
      LInfo.VisibleIndex := I;

      case LColumn.FixedKind of
        Th5uFixedKind.Left:
          begin
            LInfo.Bounds := Rect(LLeftX, LViewRect.Top, LLeftX + LColumn.Width, LViewRect.Bottom);
            Inc(LLeftX, LColumn.Width + LSpacing);
          end;

        Th5uFixedKind.Right:
          begin
            LInfo.Bounds := Rect(LRightX, LViewRect.Top, LRightX + LColumn.Width, LViewRect.Bottom);
            Inc(LRightX, LColumn.Width + LSpacing);
          end;

        else
          begin
            LInfo.Bounds := Rect(LNormalX, LViewRect.Top, LNormalX + LColumn.Width, LViewRect.Bottom);
            Inc(LNormalX, LColumn.Width + LSpacing);
          end;
      end;

      LAll.Add(LInfo);
      LVisibilityRect := LInfo.Bounds;
      Inc(LVisibilityRect.Right, LSpacing);
      if h5uRectIntersects(LVisibilityRect, LViewRect) then
        LInfos.Add(LInfo);
    end;

    FAllColumns := LAll.ToArray;
    FVisibleColumns := LInfos.ToArray;
  finally
    LAll.Free;
    LInfos.Free;
  end;
end;

procedure Th5uVclGrid.CancelEditor;
begin
  // Hiding a focused editor can synchronously invoke EditorExit.
  FEditColumn := nil;
  FEditRowIndex := -1;
  if Assigned(FDateEditor) then
    FDateEditor.Visible := False;
  if Assigned(FEditor) then
    FEditor.Visible := False;
end;

procedure Th5uVclGrid.ColumnChooserClick(Sender: TObject);
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

function Th5uVclGrid.ColumnInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleColumnInfo): Boolean;
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

procedure Th5uVclGrid.SetShowColumnModes(AValue: Boolean);
begin
  if FShowColumnModes = AValue then Exit;
  FShowColumnModes := AValue;
  Invalidate;
end;

procedure Th5uVclGrid.GetColumnMode(AColumn: Th5uGridColumn; var AMode: string);
var
  LKey: string;
  procedure Add(const AToken: string);
  begin
    if AMode <> '' then AMode := AMode + ' ';
    AMode := AMode + AToken;
  end;
begin
  AMode := '';
  if not Assigned(AColumn) then Exit;
  LKey := '';
  if Assigned(FDataController) then
    if IsPublishedProp(FDataController, 'KeyFieldName') then
      LKey := GetStrProp(FDataController, 'KeyFieldName')
    else if IsPublishedProp(FDataController, 'KeyPropertyName') then
      LKey := GetStrProp(FDataController, 'KeyPropertyName');
  if (LKey <> '') and SameText(AColumn.FieldName, LKey) then
    Add('KeyField');
  if (FTree.LevelColumnId <> '') and SameText(AColumn.Id, FTree.LevelColumnId) then
    Add('TreeLevel');
  if (FAdjacentGroupFolding.IdColumnId <> '') and SameText(AColumn.Id, FAdjacentGroupFolding.IdColumnId) then
    Add('GroupId');
  if (FRowStyles.StyleKeyColumnId <> '') and SameText(AColumn.Id, FRowStyles.StyleKeyColumnId) then
    Add('StyleKey');
  if (FScrollHints.VerticalColumnId <> '') and SameText(AColumn.Id, FScrollHints.VerticalColumnId) then
    Add('ScrollHint');
end;

function Th5uVclGrid.ColumnModeSymbols(AColumn: Th5uGridColumn): string;
var
  LMode: string;
begin
  Result := '';
  if not Assigned(AColumn) or not (FShowColumnModes or (csDesigning in ComponentState)) then
    Exit;
  LMode := ' ' + AColumn.Mode + ' ';
  if Pos(' KeyField ',   LMode) > 0 then Result := Result + #$26BF;
  if Pos(' TreeLevel ',  LMode) > 0 then Result := Result + #$21B3;
  if Pos(' GroupId ',    LMode) > 0 then Result := Result + #$2261;
  if Pos(' StyleKey ',   LMode) > 0 then Result := Result + #$25C6;
  if Pos(' ScrollHint ', LMode) > 0 then Result := Result + #$2195;
end;

procedure Th5uVclGrid.ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
begin
  InvalidateAdjacentGroupMap(False);
  RebuildAfterLayoutChange;
end;

function Th5uVclGrid.TryFocusCell(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean): Boolean;
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
    LAllow := True;
    if Assigned(LColumn.OnCanFocus) then
      LColumn.OnCanFocus(LColumn, LColumn, ACell.RowIndex, LAllow);
    if Assigned(FOnCanFocus) then
      FOnCanFocus(Self, LColumn, ACell.RowIndex, LAllow);
    Result := LAllow;
    if not Result then
      Exit;
    if Assigned(FEditColumn) then
      CommitEditor;
  end;
  FHeaderSelectionActive := False;
  FSelection.SetFocus(ACell, AUpdateAnchor);
  Result := True;
end;

function Th5uVclGrid.AllowCellEdit(AColumn: Th5uGridColumn; ARow: Int64): Boolean;
var
  LAllow: Boolean;
begin
  Result := False;
  if not CanUpdateLayout then
    Exit;
  LAllow := FAllowEditing and not AColumn.ReadOnly and CanEditViewValue(ARow, AColumn.FieldName);
  if Assigned(AColumn.OnCanEdit) then
    AColumn.OnCanEdit(AColumn, AColumn, ARow, LAllow);
  if Assigned(FOnCanEdit) then
    FOnCanEdit(Self, AColumn, ARow, LAllow);
  Result := LAllow;
end;

function Th5uVclGrid.GetCellValue(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): TValue;
begin
  Result := GetViewValue(ARow, AColumn.FieldName);
  if not CanUpdateLayout then
    Exit;
  if Assigned(AColumn.OnGetValue) then
    AColumn.OnGetValue(AColumn, AColumn, ARow, Result, ADisplay)
  else if Assigned(FOnGetValue) then
    FOnGetValue(Self, AColumn, ARow, Result, ADisplay);
end;

function Th5uVclGrid.GetCellText(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  if Assigned(AColumn.OnGetValue) or Assigned(FOnGetValue) then
  begin
    if ADisplay then
      Result := h5uValueToDisplayText(GetCellValue(AColumn, ARow, True), AColumn.DisplayFormat)
    else
      Result := h5uValueToDisplayText(GetCellValue(AColumn, ARow, False));
  end
  else if ADisplay then
    Result := GetViewDisplayText(ARow, AColumn.FieldName, AColumn.DisplayFormat)
  else
    Result := h5uValueToDisplayText(GetViewValue(ARow, AColumn.FieldName));
end;

procedure Th5uVclGrid.PutCellValue(AColumn: Th5uGridColumn; ARow: Int64; const AValue: TValue);
var
  LValue: TValue;
  LValid: Boolean;
  LError: string;
begin
  if not CanUpdateLayout then Exit;
  LValue := AValue;
  LValid := True;
  LError := '';
  if Assigned(AColumn.OnValidate) then
    AColumn.OnValidate(AColumn, AColumn, ARow, LValue, LValid, LError)
  else if Assigned(FOnValidate) then
    FOnValidate(Self, AColumn, ARow, LValue, LValid, LError);
  if not LValid then
  begin
    if LError = '' then
      LError := 'Invalid cell value';
    raise EConvertError.Create(LError);
  end;
  if Assigned(AColumn.OnSetValue) then
    AColumn.OnSetValue(AColumn, AColumn, ARow, LValue)
  else if Assigned(FOnSetValue) then
    FOnSetValue(Self, AColumn, ARow, LValue);
  SetViewValue(ARow, AColumn.FieldName, LValue);
end;

procedure Th5uVclGrid.NotifyCellClick(AColumn: Th5uGridColumn; ARow: Int64; AHeader, AIndicator: Boolean);
begin
  if not CanUpdateLayout then Exit;
  if AIndicator then
  begin
    if Assigned(FOnRowIndicatorClick) then FOnRowIndicatorClick(Self, nil, ARow);
  end
  else if Assigned(AColumn) then
    if AHeader then
    begin
      if Assigned(AColumn.OnColumnHeaderClick) then
        AColumn.OnColumnHeaderClick(AColumn, AColumn, -1);
      if Assigned(FOnColumnHeaderClick) then
        FOnColumnHeaderClick(Self, AColumn, -1);
    end
    else
    begin
      if Assigned(AColumn.OnCellClick) then
        AColumn.OnCellClick(AColumn, AColumn, ARow);
      if Assigned(FOnCellClick) then
        FOnCellClick(Self, AColumn, ARow);
    end;
end;


procedure Th5uVclGrid.CommitEditor;
var
  LValue: TValue;
begin
  if FCommittingEditor or not Assigned(FEditor) or (not FEditor.Visible and not DateEditorVisible) or not Assigned(FEditColumn)
    or not Assigned(FDataController) then
    Exit;

  if (DateEditorVisible and (DateEditorValue.IsEmpty = FDateEditorWasEmpty) and (FDateEditor.DateTime = FDateEditorOriginal)) or (
    not DateEditorVisible and (FEditor.Text = FEditorOriginalText)) then
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
      Invalidate;
    except
      on E: Exception do
      begin
        FEditorExitBlocked := True;
        if DateEditorVisible and FDateEditor.CanFocus then
          FDateEditor.SetFocus
        else if FEditor.CanFocus then
          FEditor.SetFocus;
        raise;
      end;
    end;
  finally
    FCommittingEditor := False;
  end;
end;

constructor Th5uVclGrid.Create(AOwner: TComponent);
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
  FCellPool := TObjectList<Th5uVclVisualCell>.Create(True);
  FRowHeightCache := TDictionary<string, Integer>.Create;

  FTheme := Th5uGridTheme.ApplicationStyle;
  FHeaderRowHeight := 26;
  FRowIndicatorWidth := 34;
  FShowHeader := True;
  FShowRowIndicator := True;
  FAllowEditing := True;
  FEditRowIndex := -1;

  FVScrollBar := TScrollBar.Create(Self);
  FVScrollBar.Parent := Self;
  FVScrollBar.Kind := sbVertical;
  FVScrollBar.OnScroll := ScrollBarScroll;

  FHScrollBar := TScrollBar.Create(Self);
  FHScrollBar.Parent := Self;
  FHScrollBar.Kind := sbHorizontal;
  FHScrollBar.OnScroll := ScrollBarScroll;

  FThumbHint := TLabel.Create(Self);
  FThumbHint.Parent := Self;
  FThumbHint.Visible := False;
  FThumbHint.Transparent := False;
  FThumbHint.AutoSize := False;
  FThumbHint.WordWrap := False;
  FThumbHint.Alignment := taCenter;
  FThumbHint.Layout := tlCenter;

  FThumbHintTimer := TTimer.Create(Self);
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Interval := 900;
  FThumbHintTimer.OnTimer := ThumbHintTimer;

  FEditor := TEdit.Create(Self);
  FEditor.AutoSize := False;
  FEditor.Parent := Self;
  FEditor.Visible := False;
  FEditor.OnExit := EditorExit;
  FEditor.OnChange := EditorChanged;
  FEditor.OnKeyDown := EditorKeyDown;

  FInitialized := True;
  TabStop := True;
  DoubleBuffered := True;
  SetBounds(Left, Top, 640, 320);
  LayoutScrollBars;
end;

procedure Th5uVclGrid.DataChanged(Sender: TObject; const AChange: Th5uDataChange);
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
  Invalidate;
end;

destructor Th5uVclGrid.Destroy;
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

procedure Th5uVclGrid.DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, ACanvas, AContext, AStage, ADrawDefault);
end;

function Th5uVclGrid.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
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

procedure Th5uVclGrid.DrawCustomHeaderLayout;
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
    if not FHeaderLayout.ColumnRange(LCellDef, FColumns.VisibleColumns, LFirst, LLast) or (LLast >= Length(FAllColumns)) then Continue;
    LRect := GetHeaderCellBounds(LCellDef);
    LClip := GetHeaderCellViewport(LCellDef);
    IntersectRect(LDrawRect, LRect, LClip);
    if LDrawRect.IsEmpty then Continue;
    LClassId := LCellDef.ClassId;
    if string(LClassId) = '' then LClassId := h5uClassIdGridHeaderGroupCell;
    LContext := Th5uFactoryContext.Create(Self, Self, FDataController, LClassId, Th5uElementKind.ColumnHeaderGroupCell);
    LContext.HeaderCell := LCellDef;
    LContext.LayoutRow := LCellDef.LayoutRow;
    LContext.LayoutColumn := LFirst;
    LContext.RowSpan := LCellDef.RowSpan;
    LContext.ColumnSpan := LLast - LFirst + 1;
    LContext.ElementFlags := [Th5uElementFlag.Header];
    if FAllColumns[LFirst].Column.FixedKind <> Th5uFixedKind.None then Include(LContext.ElementFlags, Th5uElementFlag.FixedColumn);
    if LCellDef.ColumnId <> '' then
    begin
      LContext.Column := FColumns.FindById(LCellDef.ColumnId);
      LContext.ElementKind := Th5uElementKind.ColumnHeaderCell;
      if FSelection.IsColumnSelected(LCellDef.ColumnId) then Include(LContext.ElementFlags, Th5uElementFlag.Selected);
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

procedure Th5uVclGrid.DrawDefaultHeaders;
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

procedure Th5uVclGrid.DrawContentPadding;
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

procedure Th5uVclGrid.DrawHeaders;
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

procedure Th5uVclGrid.DrawRowIndicator(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
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

function Th5uVclGrid.GetAdjacentGroupGlyphRect(const ARowInfo: Th5uVisibleRowInfo): TRect;
var
  LInfo: Th5uAdjacentGroupRowInfo;
  LLeft: Integer;
  LTop: Integer;
  LSize: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if not FAdjacentGroupFolding.Enabled or not FAdjacentGroupFolding.ShowFoldGlyph
    or not TryGetAdjacentGroupRowInfo(ARowInfo.RowIndex, LInfo) or not LInfo.IsFoldable or not LInfo.IsFirstRow
  then
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

procedure Th5uVclGrid.DrawAdjacentGroupGlyph(const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
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

procedure Th5uVclGrid.DrawRows;
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
            LFocused := FSelection.FocusedCell.IsValid and (FSelection.FocusedCell.RowIndex = LRowIndex)
              and (FSelection.FocusedCell.ColumnIndex = LColumnInfo.VisibleIndex);

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

procedure Th5uVclGrid.DrawSpacingRect(const ABounds: TRect; AElementKind: Th5uElementKind; AColumn: Th5uGridColumn; AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AColor: TColor;
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

function Th5uVclGrid.GetColumnViewportRect(AColumn: Th5uGridColumn): TRect;
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

function Th5uVclGrid.GetVisibleCellBounds(AColumn: Th5uGridColumn; const AColumnBounds, ARowBounds: TRect): TRect;
begin
  // Painting, pointer hit testing and cell editors must use the same clipped
  // rectangle, including rows partially scrolled underneath the header.
  Result := GetColumnViewportRect(AColumn);
  Result.Top := ARowBounds.Top;
  Result.Bottom := ARowBounds.Bottom;
  IntersectRect(Result, Result, GetDataViewportRect);
  IntersectRect(Result, Result, AColumnBounds);
end;

function Th5uVclGrid.GetCheckBoxRect(const ABounds: TRect): TRect;
begin
  Result := Rect(ABounds.Left + (ABounds.Width - 14) div 2, ABounds.Top + (ABounds.Height - 14) div 2, 0, 0);
  Result.Right := Result.Left + 14;
  Result.Bottom := Result.Top + 14;
end;

procedure Th5uVclGrid.EditorChanged(Sender: TObject);
begin
  // A changed value permits another automatic commit. Showing a validation
  // dialog, and the focus changes it causes, must not retry the failed value.
  FEditorExitBlocked := False;
end;

procedure Th5uVclGrid.EditorExit(Sender: TObject);
begin
  if not FCommittingEditor and not FEditorExitBlocked then
    CommitEditor;
end;

procedure Th5uVclGrid.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin CommitEditor;
        Key := 0;
      end;
    VK_ESCAPE: begin CancelEditor;
        SetFocus;
        Key := 0;
      end;
  end;
end;

function Th5uVclGrid.FindFirstVisibleRow(AOffset: Int64; out ATop: Integer): Int64;
var
  LIndex: Int64;
  LCount: Int64;
  LHeight: Integer;
  LSpacing: Integer;
  LExtent: Integer;
  LRemaining: Int64;
  LKey: Th5uRowKey;
  LElementKind: Th5uElementKind;
  LColor: TColor;
  LStyleName: string;
  LTreeLevel: Integer;
  LClosedTreeLevels: Integer;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if not Assigned(FDataController) then
    Exit;

  LCount := GetViewRowCount;
  LRemaining := Max(0, AOffset);
  LIndex := 0;

  while LIndex < LCount do
  begin
    LKey := GetViewRowKey(LIndex);
    LHeight := GetRowHeightFor(LIndex, LKey, LCount <= 5000);
    LSpacing := GetEffectiveRowSeparatorFor(LIndex, LKey, LElementKind, LColor, LStyleName, LTreeLevel, LClosedTreeLevels);
    LExtent := LHeight + LSpacing;
    if LRemaining < LExtent then
    begin
      ATop := GetDataViewportRect.Top - Integer(LRemaining);
      Exit(LIndex);
    end;
    Dec(LRemaining, LExtent);
    Inc(LIndex);
  end;
end;

function Th5uVclGrid.GetDataCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  if Th5uElementFlag.FixedColumn in AContext.ElementFlags then
    Result := GetFixedCellClass(AContext)
  else
    Result := Th5uVclDataCell;
end;

function Th5uVclGrid.GetDataViewportRect: TRect;
begin
  Result := GetViewportRect;
  Inc(Result.Top, GetHeaderHeight);
end;

function Th5uVclGrid.GetEstimatedTotalRowHeight: Int64;
var
  LCount: Int64;
  LIndex: Int64;
  LKey: Th5uRowKey;
  LHeight: Integer;
  LSpacing: Integer;
  LElementKind: Th5uElementKind;
  LColor: TColor;
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

  if LCount <= 5000 then
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
      Inc(Result, LHeight + LSpacing);
    end;
  end
  else
    Result := LCount * (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);
end;

function Th5uVclGrid.GetFixedCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclFixedCell;
end;

function Th5uVclGrid.GetHeaderCellClass(const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclHeaderCell;
end;

function Th5uVclGrid.GetHeaderHeight: Integer;
var
  LRowCount: Integer;
begin
  if not FShowHeader then
    Exit(0);

  if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    LRowCount := Max(1, FHeaderLayout.RowCount)
  else
    LRowCount := 1;

  Result := LRowCount * (FHeaderRowHeight + FSpacing.RowSpacing);
end;

function Th5uVclGrid.GetOnConfigureInstance: Th5uConfigureInstanceEvent;
begin
  Result := FFactoryScope.OnConfigureInstance;
end;

function Th5uVclGrid.GetOnCreateInstance: Th5uCreateInstanceEvent;
begin
  Result := FFactoryScope.OnCreateInstance;
end;

function Th5uVclGrid.GetOnGetClass: Th5uGetClassEvent;
begin
  Result := FFactoryScope.OnGetClass;
end;

function Th5uVclGrid.GetRowHeightFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; AAllowMeasure: Boolean): Integer;
var
  LCacheKey: string;
  LColumn: Th5uGridColumn;
  LColumns: TArray<Th5uGridColumn>;
  LProposed: Integer;
  LCellHeight: Integer;
  LCacheResult: Boolean;
  LContext: Th5uGetRowHeightContext;
begin
  if FRowHeight.Mode = Th5uRowHeightMode.Fixed then
    Exit(FRowHeight.FixedHeight);

  LCacheKey := ARowKey.ToString;
  if LCacheKey = '' then
    LCacheKey := '#' + IntToStr(AViewRowIndex);

  if FRowHeightCache.TryGetValue(LCacheKey, Result) then
    Exit;

  if not AAllowMeasure then
    LProposed := FRowHeight.EstimatedHeight
  else
  begin
    LProposed := FRowHeight.MinHeight;
    LColumns := FColumns.VisibleColumns;
    for LColumn in LColumns do
    begin
      if (FRowHeight.MeasureScope = Th5uAutoHeightMeasureScope.ExplicitContributorColumns) and not LColumn.AutoHeight then
        Continue;

      LCellHeight := MeasureCellHeight(AViewRowIndex, LColumn);
      LProposed := Max(LProposed, LCellHeight);
    end;
  end;

  LProposed := EnsureRange(LProposed, FRowHeight.MinHeight, FRowHeight.MaxHeight);

  LCacheResult := True;
  if Assigned(FOnGetRowHeight) then
  begin
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := GetViewSourceRowIndex(AViewRowIndex);
    LContext.IsEstimated := not AAllowMeasure;
    FOnGetRowHeight(Self, LContext, LProposed, LCacheResult);
  end;

  Result := Max(1, LProposed);
  if LCacheResult then
    FRowHeightCache.AddOrSetValue(LCacheKey, Result);
end;

function Th5uVclGrid.GetRowStyle(AViewRowIndex: Int64; out AStyleKey: TValue): string;
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

function Th5uVclGrid.GetEffectiveColumnRightSpacing(AColumn: Th5uGridColumn): Integer;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := FSpacing.DefaultColumnRightSpacing;
end;

procedure Th5uVclGrid.InvalidateAdjacentGroupMap(AClearStates: Boolean);
begin
  if AClearStates then
    FAdjacentGroupMap.ResetStates;
  FAdjacentGroupMapDirty := True;
end;

procedure Th5uVclGrid.EnsureAdjacentGroupMap;
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

function Th5uVclGrid.ResolveAdjacentGroupFieldName: string;
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

function Th5uVclGrid.TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
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

function Th5uVclGrid.GetViewRowCount: Int64;
begin
  if not Assigned(FDataController) then
    Exit(0);
  EnsureAdjacentGroupMap;
  if FAdjacentGroupMap.Active then
    Result := FAdjacentGroupMap.GetVisibleRowCount
  else
    Result := FDataController.GetRowCount;
end;

function Th5uVclGrid.MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean): Int64;
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

function Th5uVclGrid.GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
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

function Th5uVclGrid.GetViewRowKey(AViewRowIndex: Int64): Th5uRowKey;
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

function Th5uVclGrid.GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
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

procedure Th5uVclGrid.SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
var
  LControllerRowIndex: Int64;
begin
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex);
  if LControllerRowIndex >= 0 then
    FDataController.SetValue(LControllerRowIndex, AFieldName, AValue);
end;

function Th5uVclGrid.CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
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

function Th5uVclGrid.GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
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

function Th5uVclGrid.IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
var
  LControllerRowIndex: Int64;
begin
  Result := False;
  if not Assigned(FDataController) then
    Exit;
  LControllerRowIndex := MapViewToControllerRowIndex(AViewRowIndex, True);
  Result := (LControllerRowIndex >= 0) and FDataController.IsRowAvailable(LControllerRowIndex);
end;

procedure Th5uVclGrid.PrepareViewRange(AFirstViewRow, ACount: Int64);
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

function Th5uVclGrid.TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
begin
  EnsureAdjacentGroupMap;
  Result := FAdjacentGroupMap.Active and FAdjacentGroupMap.TryGetRowInfo(AViewRowIndex, AInfo);
end;

procedure Th5uVclGrid.PopulateAdjacentGroupContext(var AContext: Th5uFactoryContext; AViewRowIndex: Int64);
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

function Th5uVclGrid.GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
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

procedure Th5uVclGrid.DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
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

function Th5uVclGrid.GetRowSpacingFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): Integer;
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

function Th5uVclGrid.TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ALevel: Integer): Boolean;
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

function Th5uVclGrid.GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
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

function Th5uVclGrid.GetEffectiveRowSeparatorFor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; out AElementKind: Th5uElementKind;
   out AColor: TColor; out AStyleName: string; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Integer;
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
    // The adjacent-run end band has precedence over the ordinary row
    // separator and over a tree branch-end band at the same boundary. It is
    // an alternative separator, never an additional one.
    Result := FAdjacentGroupFolding.EndBand.Height;
    AElementKind := Th5uElementKind.AdjacentGroupEndBand;
    AColor := ResolveAdjacentGroupEndColor(AViewRowIndex, ARowKey);
    AStyleName := FAdjacentGroupFolding.EndBand.StyleName;
    Exit;
  end;

  if FTree.Enabled and FTree.BranchEndBand.Enabled and GetTreeBranchEndInfo(AViewRowIndex, ARowKey, ATreeLevel, AClosedTreeLevels) then
  begin
    // The branch-end band replaces regular RowSpacing. It is deliberately
    // not added to it, so a height of 0 also removes the separator entirely.
    Result := FTree.BranchEndBand.Height;
    AElementKind := Th5uElementKind.TreeBranchEndBand;
    AColor := ResolveTreeBranchEndColor(AViewRowIndex, ARowKey);
    AStyleName := FTree.BranchEndBand.StyleName;
    Exit;
  end;

  Result := GetRowSpacingFor(AViewRowIndex, ARowKey);
end;

function Th5uVclGrid.GetGridLines: Boolean;
begin
  // Explicit per-column RightSpacing values are intentionally independent
  // from this compatibility property.
  Result := (FSpacing.Left > 0) or (FSpacing.Top > 0) or (FSpacing.Right > 0) or (FSpacing.Bottom > 0)
    or (FSpacing.RowSpacing > 0) or (FSpacing.DefaultColumnRightSpacing > 0);
end;

function Th5uVclGrid.GetTotalColumnWidth: Integer;
var
  LColumn: Th5uGridColumn;
begin
  Result := 0;
  for LColumn in FColumns.VisibleColumns do
    Inc(Result, LColumn.Width + GetEffectiveColumnRightSpacing(LColumn));
  if FShowRowIndicator then
    Inc(Result, FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing);
end;

function Th5uVclGrid.GetUnpaddedViewportRect: TRect;
begin
  Result := ClientRect;
  if FVScrollBar.Visible then
    Dec(Result.Right, FVScrollBar.Width);
  if FHScrollBar.Visible then
    Dec(Result.Bottom, FHScrollBar.Height);
end;

function Th5uVclGrid.GetViewportRect: TRect;
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

function Th5uVclGrid.ResolveColor(const AColor: TColor; AFallback: TColor): TColor;
begin
  if AColor = clDefault then
    Result := AFallback
  else
    Result := AColor;
end;

function Th5uVclGrid.ResolveDefaultCellColor: TColor;
begin
  Result := ResolveColor(FAppearance.DefaultCellColor, h5uGetVclPalette(FTheme).CellBackground);
end;

function Th5uVclGrid.ResolveRowSpacingColor: TColor;
begin
  Result := ResolveColor(FSpacing.RowSpacingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclGrid.ResolveColumnSpacingColor: TColor;
begin
  Result := ResolveColor(FSpacing.ColumnSpacingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclGrid.ResolveContentPaddingColor: TColor;
begin
  Result := ResolveColor(FSpacing.ContentPaddingColor, h5uGetVclPalette(FTheme).CellBorder);
end;

function Th5uVclGrid.ResolveTreeBranchEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
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

function Th5uVclGrid.ResolveAdjacentGroupEndColor(AViewRowIndex: Int64; const ARowKey: Th5uRowKey): TColor;
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

function Th5uVclGrid.GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCellClass;
var
  LCacheScope: Th5uFactoryCacheScope;
begin
  Result := Th5uVclVisualCellClass(FFactoryScope.ResolveClass(AContext, Th5uVclVisualCell, ADefaultClass, LCacheScope));
end;

function Th5uVclGrid.HitTest(X, Y: Integer): Th5uHitTestInfo;
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
      if not Assigned(Result.HeaderCell)
        or not FHeaderLayout.ColumnRange(Result.HeaderCell, FColumns.VisibleColumns, LFirst, LLast) then Exit(Th5uHitTestInfo.Empty);
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

procedure Th5uVclGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  FThumbHint.Visible := False;
end;

procedure Th5uVclGrid.InvalidateAllRowHeights;
begin
  FRowHeightCache.Clear;
end;

procedure Th5uVclGrid.InvalidateRowHeight(const ARowKey: Th5uRowKey);
begin
  FRowHeightCache.Remove(ARowKey.ToString);
  Invalidate;
end;

procedure Th5uVclGrid.InvalidateVisibleRowHeights;
var
  LRow: Th5uVisibleRowInfo;
begin
  for LRow in FVisibleRows do
    FRowHeightCache.Remove(LRow.RowKey.ToString);
  Invalidate;
end;

function Th5uVclGrid.CanUpdateLayout: Boolean;
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

procedure Th5uVclGrid.Loaded;
begin
  inherited;
  LayoutScrollBars;
  // Paint refreshes data-dependent layout; FormCreate may not have run yet.
  Invalidate;
end;

procedure Th5uVclGrid.LayoutScrollBars;
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
  FThumbHint.BringToFront;
  FEditor.BringToFront;
end;

function Th5uVclGrid.MeasureCellHeight(AViewRowIndex: Int64; AColumn: Th5uGridColumn): Integer;
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
  LRect := Rect(0, 0, Max(8, AColumn.Width - 10), 0);
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

procedure Th5uVclGrid.CMCursorChanged(var Message: TMessage);
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

procedure Th5uVclGrid.CMMouseLeave(var Message: TMessage);
begin
  if not Assigned(FResizingColumn) then
    SetResizeCursor(False);
  inherited;
end;

function Th5uVclGrid.ColumnResizeAt(X, Y: Integer; ATouch: Boolean): Th5uGridColumn;
var
  LInfo: Th5uVisibleColumnInfo;
  LView: TRect;
  LHeader: Th5uHeaderLayoutCell;
  LLeftTolerance, LRightTolerance, LLastLeftTolerance, LEffectiveLeft, LDelta, LDistance, LBest: Integer;
begin
  Result := nil;
  if not CanUpdateLayout or not FShowHeader or not FCustomization.AllowColumnResizing then
    Exit;
  if not GetViewportRect.Contains(Point(X, Y)) or (Y >= GetDataViewportRect.Top) then
    Exit;
  if ATouch then
  begin
    LLastLeftTolerance := FCustomization.TouchLastColumnResizeHitZoneLeft;
    LLeftTolerance := FCustomization.TouchColumnResizeHitZoneLeft;
    LRightTolerance := FCustomization.TouchColumnResizeHitZoneRight;
  end
  else
  begin
    LLastLeftTolerance := FCustomization.LastColumnResizeHitZoneLeft;
    LLeftTolerance := FCustomization.ColumnResizeHitZoneLeft;
    LRightTolerance := FCustomization.ColumnResizeHitZoneRight;
  end;
  LBest := Max(LLeftTolerance, LRightTolerance);
  BuildColumnLayout;
  for LInfo in FVisibleColumns do
  begin
    if not LInfo.Column.CanResize then
      Continue;
    LEffectiveLeft := LLeftTolerance;
    // Use the last non-hidden column, not the last one inside the scrolled viewport.
    if (LInfo.VisibleIndex = High(FAllColumns)) and (LLastLeftTolerance >= 0) then
      LEffectiveLeft := LLastLeftTolerance;
    LDelta := X - LInfo.Bounds.Right;
    if (LDelta < -LEffectiveLeft) or (LDelta > LRightTolerance) then
      Continue;
    if FHeaderLayout.Enabled and (FHeaderLayout.Cells.Count > 0) then
    begin
      LHeader := HeaderCellAtPoint(LInfo.Bounds.Right - 1, Y);
      if not Assigned(LHeader) or (Abs(GetHeaderCellBounds(LHeader).Right - LInfo.Bounds.Right) > 0.1) then
        Continue;
    end;
    LDistance := Abs(LDelta);
    if Assigned(Result) and (LDistance >= LBest) then
      Continue;
    LView := GetColumnViewportRect(LInfo.Column);
    // A clipped column's viewport edge is not its resize boundary.
    if (LInfo.Bounds.Right <= LView.Left) or (LInfo.Bounds.Right > LView.Right) then
      Continue;
    Result := LInfo.Column;
    LBest := LDistance;
  end;
end;

procedure Th5uVclGrid.SetResizeCursor(AActive: Boolean);
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

function Th5uVclGrid.BeginColumnResize(X, Y: Integer; ATouch: Boolean): Boolean;
begin
  FResizingColumn := ColumnResizeAt(X, Y, ATouch);
  Result := Assigned(FResizingColumn);
  if not Result then
     Exit;
  FResizeStartX := X;
  FResizeOriginalWidth := FResizingColumn.Width;
  MouseCapture := True;
  if not ATouch then
    SetResizeCursor(True);
end;

procedure Th5uVclGrid.UpdateColumnResize(X: Integer);
var
  I: Integer;
begin
  if not Assigned(FResizingColumn) then Exit;
  if CanUpdateLayout and FCustomization.AllowColumnResizing and MouseCapture then
    for I := 0 to FColumns.Count - 1 do
      if FColumns[I] = FResizingColumn then
      begin
        if FColumns[I].Visible and FColumns[I].CanResize then
        begin
          FColumns[I].Width := FResizeOriginalWidth + (X - FResizeStartX);
          Exit;
        end;
        Break;
      end;
  // Capture, permissions or the source column may disappear during a drag.
  EndSelectionDrag;
end;

procedure Th5uVclGrid.SelectRightClickCell(const AHit: Th5uHitTestInfo);
var
  LCell: Th5uCellAddress;
  LSelected: Boolean;
begin
  if not FSelection.RightClickSelect or (AHit.Kind <> Th5uHitKind.DataCell) then
    Exit;
  LCell.RowIndex := AHit.RowIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.ColumnId := AHit.Column.Id;
  LSelected := FSelection.IsCellSelected(LCell.RowIndex, LCell.ColumnIndex)
    or FSelection.IsRowSelected(LCell.RowKey) or FSelection.IsColumnSelected(LCell.ColumnId);
  if not TryFocusCell(LCell, not LSelected) then
    Exit;
  if not LSelected and AHit.Column.CanSelect then
    FSelection.AddCellRange(Th5uCellRange.Create(LCell.RowIndex, LCell.RowIndex, LCell.ColumnIndex, LCell.ColumnIndex));
end;

function Th5uVclGrid.CanMoveColumn(AColumn: Th5uGridColumn): Boolean;
var
  I: Integer;
begin
  Result := False;
  // The source column may have been removed while the mouse was captured.
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I] = AColumn then
    begin
      case AColumn.MovePermission of
        Th5uColumnMovePermission.Default: Result := FCustomization.AllowColumnMoving;
        Th5uColumnMovePermission.Allow: Result := True;
        Th5uColumnMovePermission.Deny: Result := False;
      end;
      Exit;
    end;
end;

function Th5uVclGrid.IsColumnMoveGesture(AColumn: Th5uGridColumn; AShift: TShiftState): Boolean;
begin
  Result := False;
  if (AShift * [ssCtrl, ssShift] <> []) or not CanMoveColumn(AColumn) then
    Exit;
  if FCustomization.ColumnMovingGesture = Th5uColumnMovingGesture.AltDrag then
    Result := ssAlt in AShift
  else
    Result := not (ssAlt in AShift);
end;

function Th5uVclGrid.IsRowMoveGesture(AShift: TShiftState): Boolean;
begin
  Result := False;
  if not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving or (AShift * [ssCtrl, ssShift] <> []) then
    Exit;
  if FCustomization.RowMovingGesture = Th5uRowMovingGesture.AltDrag then
    Result := ssAlt in AShift
  else
   Result := not (ssAlt in AShift);
end;

function Th5uVclGrid.GetHeaderCellBounds(ACell: Th5uHeaderLayoutCell): TRect;
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

function Th5uVclGrid.GetHeaderCellViewport(ACell: Th5uHeaderLayoutCell): TRect;
var
  LFirst, LLast: Integer;
begin
  Result := TRect.Empty;
  if not FHeaderLayout.ColumnRange(ACell, FColumns.VisibleColumns, LFirst, LLast) or (LFirst >= Length(FAllColumns)) then
    Exit;
  Result := GetColumnViewportRect(FAllColumns[LFirst].Column);
  Result.Bottom := Min(Result.Bottom, GetDataViewportRect.Top);
end;

function Th5uVclGrid.HeaderCellAtPoint(X, Y: Integer): Th5uHeaderLayoutCell;
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

function Th5uVclGrid.BeginColumnMove(AColumnIndex: Integer; X, Y: Integer): Boolean;
var
  LColumns: TArray<Th5uGridColumn>;
  LFirst, LLast, I: Integer;
  LHit: Th5uHitTestInfo;
begin
  Result := False;
  LColumns := FColumns.VisibleColumns;
  if (AColumnIndex < 0) or (AColumnIndex >= Length(LColumns)) then Exit;
  LHit := HitTest(X, Y);
  FMovingHeaderCell := nil;
  LFirst := AColumnIndex;
  LLast := LFirst;
  if Assigned(LHit.HeaderCell) and (LHit.HeaderCell.ColumnSpan > 1) then
  begin
    if not FHeaderLayout.ColumnRange(LHit.HeaderCell, LColumns, LFirst, LLast) then
      Exit;
  end
  else if FSelection.IsColumnSelected(LColumns[LFirst].Id) then
  begin
    while (LFirst > 0) and FSelection.IsColumnSelected(LColumns[LFirst - 1].Id) do
      Dec(LFirst);
    while (LLast < High(LColumns)) and FSelection.IsColumnSelected(LColumns[LLast + 1].Id) do
      Inc(LLast);
    // Include the entire selected block or do not start at all (also for hidden selections).
    if LLast - LFirst + 1 <> FSelection.SelectedColumnCount then
      Exit;
  end;
  for I := LFirst to LLast do
    if not CanMoveColumn(LColumns[I]) or (LColumns[I].FixedKind <> LColumns[LFirst].FixedKind) then
      Exit;
  if Assigned(LHit.HeaderCell) then
    for I := 0 to FColumns.Count - 1 do
      if FHeaderLayout.MovesWithColumns(FColumns[I], LColumns, LFirst, LLast - LFirst + 1)
        and (not CanMoveColumn(FColumns[I]) or (FColumns[I].FixedKind <> LColumns[LFirst].FixedKind))
      then
        Exit;
  FMovingHeaderCell := LHit.HeaderCell;
  FMovingColumns := Copy(LColumns, LFirst, LLast - LFirst + 1);
  FMovePoint := Point(X, Y);
  FMoveCaption := LColumns[LFirst].Caption;
  if LLast > LFirst then
    FMoveCaption := FMoveCaption + Format(' (+%d)', [LLast - LFirst]);
  FMovePreviewWidth := EnsureRange(LColumns[LFirst].Width, MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  if Assigned(FMovingHeaderCell) and (FMovingHeaderCell.ColumnSpan > 1) then
  begin
    FMoveCaption := FMovingHeaderCell.Caption;
    FMovePreviewWidth := EnsureRange(LHit.Bounds.Width, MulDiv(80, CurrentPPI, 96), MulDiv(260, CurrentPPI, 96));
  end;
  FSelectionDragOrigin := Point(X, Y);
  MouseCapture := True;
  Result := True;
end;

function Th5uVclGrid.BeginRowMove(ARowIndex: Int64; X, Y: Integer): Boolean;
var
  LFirst, LLast, LCount, LSelectedCount: Int64;
  I: Integer;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving then
    Exit;
  LCount := GetViewRowCount;
  if (ARowIndex < 0) or (ARowIndex >= LCount) then
    Exit;
  LFirst := ARowIndex;
  LLast := LFirst;
  if FSelection.IsRowSelected(GetViewRowKey(LFirst)) then
  begin
    LSelectedCount := FSelection.SelectedRowCount(LCount);
    if (LSelectedCount >= LCount) or (LSelectedCount <= 0) then
      Exit;
    // Visit only the selected neighbours; virtual grids must not scan every row.
    while (LFirst > 0) and FSelection.IsRowSelected(GetViewRowKey(LFirst - 1)) do
      Dec(LFirst);
    while (LLast < LCount - 1) and FSelection.IsRowSelected(GetViewRowKey(LLast + 1)) do
      Inc(LLast);
    if LLast - LFirst + 1 <> LSelectedCount then Exit;
  end;
  if LLast - LFirst >= MaxInt then
    Exit;
  SetLength(FMovingRowKeys, LLast - LFirst + 1);
  for I := 0 to High(FMovingRowKeys) do
  begin
    FMovingRowKeys[I] := GetViewRowKey(LFirst + I);
    if FMovingRowKeys[I].IsEmpty then
    begin
      FMovingRowKeys := nil;
      Exit;
    end;
  end;
  FMovingFirstRowIndex := LFirst;
  FSelectionDragOrigin := Point(X, Y);
  MouseCapture := True;
  Result := True;
end;

procedure Th5uVclGrid.UpdateHeaderMove(X, Y: Integer);
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

function Th5uVclGrid.GetColumnMoveHeaderBounds(const AInfo: Th5uVisibleColumnInfo): TRect;
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

function Th5uVclGrid.ColumnMoveTarget(X, Y: Integer; out ANewIndex, AMarkerX, AMarkerTop: Integer): Boolean;
var
  LHit: Th5uHitTestInfo;
  LColumns: TArray<Th5uGridColumn>;
  LFirst, LTargetFirst, LTargetLast, I: Integer;
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
  LColumns := FColumns.VisibleColumns;
  LFirst := -1;
  for I := 0 to High(LColumns) do
    if LColumns[I] = FMovingColumns[0] then
      LFirst := I;
  if (LFirst < 0) or (LFirst + Length(FMovingColumns) > Length(LColumns)) then
    Exit;
  for I := 0 to High(FMovingColumns) do
  begin
    if LColumns[LFirst + I] <> FMovingColumns[I] then
      Exit;
    if not CanMoveColumn(FMovingColumns[I]) then
      Exit;
    if FMovingColumns[I].FixedKind <> LHit.Column.FixedKind then
      Exit;
  end;
  if Assigned(FMovingHeaderCell) then
    for I := 0 to FColumns.Count - 1 do
      if FHeaderLayout.MovesWithColumns(FColumns[I], LColumns, LFirst, Length(FMovingColumns))
        and (not CanMoveColumn(FColumns[I]) or (FColumns[I].FixedKind <> LColumns[LFirst].FixedKind))
      then
        Exit;
  LTargetFirst := LHit.ColumnIndex;
  LTargetLast := LTargetFirst;
  if Assigned(FMovingHeaderCell) then
  begin
    if not Assigned(LHit.HeaderCell) then
      Exit;
    if FMovingHeaderCell.ColumnSpan > 1 then
    begin
      if LHit.HeaderCell.LayoutRow <> FMovingHeaderCell.LayoutRow then
        Exit;
    end
    else if (LHit.HeaderCell.ColumnSpan > 1) or (LHit.HeaderCell.LayoutRow >= FMovingHeaderCell.LayoutRow + Max(1, FMovingHeaderCell.RowSpan))
      or (FMovingHeaderCell.LayoutRow >= LHit.HeaderCell.LayoutRow + Max(1, LHit.HeaderCell.RowSpan))
    then
      Exit;
    if not FHeaderLayout.ColumnRange(LHit.HeaderCell, LColumns, LTargetFirst, LTargetLast) then
      Exit;
  end;
  if (LTargetFirst < LFirst + Length(FMovingColumns)) and (LTargetLast >= LFirst) then
    Exit;
  ANewIndex := LTargetFirst;
  AMarkerX := LHit.Bounds.Left;
  AMarkerTop := LHit.Bounds.Top;
  if LTargetFirst > LFirst then
  begin
    ANewIndex := LTargetLast + 1 - Length(FMovingColumns);
    AMarkerX := LHit.Bounds.Right;
  end;
  if FHeaderLayout.Enabled and not FHeaderLayout.CanMoveColumns(LColumns, LFirst, Length(FMovingColumns), ANewIndex) then
    Exit;
  Result := True;
end;

procedure Th5uVclGrid.DrawColumnMoveFeedback;
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
  if LSavedDC = 0 then Exit;
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
    Winapi.Windows.AlphaBlend(LCanvas.Handle, LRect.Left + Scaled(3),
      LRect.Top + Scaled(3), LRect.Width, LRect.Height, LFill.Canvas.Handle, 0, 0, 1, 1, LBlend);
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

function Th5uVclGrid.FinishHeaderMove(X, Y: Integer): Boolean;
var
  LHit: Th5uHitTestInfo;
  LMovingColumns: TArray<Th5uGridColumn>;
  LContext: Th5uRowsMovedContext;
  LNewIndex, LMarkerX, LMarkerTop, I: Integer;
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
  else if Length(LContext.RowKeys) > 0 then
  begin
    if not Assigned(FOnRowsMoved) or not FCustomization.AllowRowMoving
      or not (LHit.Kind in [Th5uHitKind.RowIndicator, Th5uHitKind.DataCell])
    then
     Exit;
    if (LContext.FirstRowIndex < 0) or (LContext.FirstRowIndex + Length(LContext.RowKeys) > GetViewRowCount) then
      Exit;
    if (LHit.RowIndex >= LContext.FirstRowIndex) and (LHit.RowIndex < LContext.FirstRowIndex + Length(LContext.RowKeys)) then
      Exit;
    SetLength(LContext.SourceRowIndexes, Length(LContext.RowKeys));
    for I := 0 to High(LContext.RowKeys) do
    begin
      // A live sort/filter or removed row invalidates the original drag range.
      if GetViewRowKey(LContext.FirstRowIndex + I) <> LContext.RowKeys[I] then
        Exit;
      LContext.SourceRowIndexes[I] := GetViewSourceRowIndex(LContext.FirstRowIndex + I);
    end;
    LContext.TargetRowIndex := LHit.RowIndex;
    LContext.TargetRowKey := LHit.RowKey;
    LContext.TargetSourceRowIndex := GetViewSourceRowIndex(LHit.RowIndex);
    LContext.InsertAfter := LHit.RowIndex > LContext.FirstRowIndex;
    LContext.NewFirstRowIndex := LHit.RowIndex;
    if LContext.InsertAfter then
      Dec(LContext.NewFirstRowIndex, Length(LContext.RowKeys) - 1);
    FOnRowsMoved(Self, LContext);
  end;
end;


procedure Th5uVclGrid.BeginSelectionDrag(AKind: Th5uSelectionKind; X, Y: Integer; AShift: TShiftState);
begin
  FSelectingRange := True;
  FSelectionDragging := False;
  FSelectionDragKind := AKind;
  FSelectionDragShift := AShift;
  FSelectionDragOrigin := Point(X, Y);
  FSelectionDragLast := Th5uCellAddress.Empty;
  MouseCapture := True;
end;

procedure Th5uVclGrid.EndSelectionDrag;
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

procedure Th5uVclGrid.UpdateSelectionDrag(X, Y: Integer);
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
  if (LCell.RowIndex = FSelectionDragLast.RowIndex) and (LCell.RowKey = FSelectionDragLast.RowKey)
    and (LCell.ColumnIndex = FSelectionDragLast.ColumnIndex) and (LCell.ColumnId = FSelectionDragLast.ColumnId)
  then
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


procedure Th5uVclGrid.SelectHeaderRange(AKind: Th5uSelectionKind; ARow: Int64; AColumn: Integer; AShift: TShiftState);
var
  LColumns: TArray<Th5uGridColumn>;
  LKeys: TArray<Th5uRowKey>;
  LIds: TList<string>;
  LRow, LFirstRow, LLastRow: Int64;
  I, LAnchorColumn: Integer;
  LExtend: Boolean;
begin
  if not CanUpdateLayout or not (AKind in FSelection.AllowedKinds) then
    Exit;
  LColumns := FColumns.VisibleColumns;
  if AKind = Th5uSelectionKind.Rows then
  begin
    if (ARow < 0) or (ARow >= GetViewRowCount) then
      Exit;
  end
  else if (AColumn < 0) or (AColumn >= Length(LColumns)) then
    Exit
  else if not LColumns[AColumn].CanSelect then
    Exit;

  LExtend := (ssShift in AShift) and FHeaderSelectionActive and (FHeaderSelectionKind = AKind);
  if not LExtend then
    FHeaderAnchor := Th5uCellAddress.Empty;
  FHeaderSelectionActive := True;
  FHeaderSelectionKind := AKind;
  FHeaderFocus := Th5uCellAddress.Empty;
  if AKind = Th5uSelectionKind.Rows then
  begin
    FHeaderFocus.RowIndex := ARow;
    FHeaderFocus.RowKey := GetViewRowKey(ARow);
    // A removed/replaced row must not leave an anchor pointing at another row.
    if (FHeaderAnchor.RowIndex < 0) or (FHeaderAnchor.RowIndex >= GetViewRowCount) then
      FHeaderAnchor := FHeaderFocus
    else if GetViewRowKey(FHeaderAnchor.RowIndex) <> FHeaderAnchor.RowKey then
      FHeaderAnchor := FHeaderFocus;
    if (ssCtrl in AShift) and not (ssShift in AShift) then
      FSelection.ToggleRow(FHeaderFocus.RowKey)
    else
    begin
      LFirstRow := Min(FHeaderAnchor.RowIndex, ARow);
      LLastRow := Max(FHeaderAnchor.RowIndex, ARow);
      SetLength(LKeys, LLastRow - LFirstRow + 1);
      for LRow := LFirstRow to LLastRow do
        LKeys[LRow - LFirstRow] := GetViewRowKey(LRow);
      FSelection.SelectRows(LKeys, ssCtrl in AShift, LExtend);
    end;
  end
  else
  begin
    FHeaderFocus.ColumnIndex := AColumn;
    FHeaderFocus.ColumnId := LColumns[AColumn].Id;
    LAnchorColumn := -1;
    for I := 0 to High(LColumns) do
      if LColumns[I].Id = FHeaderAnchor.ColumnId then
        LAnchorColumn := I;
    if LAnchorColumn < 0 then
    begin
      FHeaderAnchor := FHeaderFocus;
      LAnchorColumn := AColumn;
    end;
    if (ssCtrl in AShift) and not (ssShift in AShift) then
      FSelection.ToggleColumn(FHeaderFocus.ColumnId)
    else
    begin
      LIds := TList<string>.Create;
      try
        for I := Min(LAnchorColumn, AColumn) to Max(LAnchorColumn, AColumn) do
          if LColumns[I].CanSelect then
            LIds.Add(LColumns[I].Id);
        FSelection.SelectColumns(LIds.ToArray, ssCtrl in AShift, LExtend);
      finally
        LIds.Free;
      end;
    end;
  end;
end;


procedure Th5uVclGrid.DoExit;
begin
  EndSelectionDrag;
  inherited;
end;

procedure Th5uVclGrid.WMCancelMode(var Message: TWMCancelMode);
begin
  EndSelectionDrag;
  inherited;
end;

procedure Th5uVclGrid.WMCaptureChanged(var Message: TMessage);
begin
  if Message.LParam <> LPARAM(Handle) then
    EndSelectionDrag;
  inherited;
end;

procedure Th5uVclGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
begin
  EndSelectionDrag;
  FMoveTouch := ssTouch in Shift;
  inherited;
  // VCL dispatches DblClick before this second MouseDown. Open the editor here
  // using the event coordinates, without taking focus back from it afterwards.
  if ssDouble in Shift then
  begin
    FMouseDownHit := HitTest(X, Y);
    if (Button = mbLeft) and (FMouseDownHit.Kind = Th5uHitKind.DataCell) and (((FMouseDownHit.Column.EditorKind <> Th5uColumnEditorKind.Boolean)
      and not ((FMouseDownHit.Column.EditorKind = Th5uColumnEditorKind.Automatic) and (FMouseDownHit.Column.DataType = Th5uColumnDataType.Boolean)))
      or GetCheckBoxRect(FMouseDownHit.Bounds).Contains(Point(X, Y))) then
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

procedure Th5uVclGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
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
procedure Th5uVclGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LHit: Th5uHitTestInfo;
  LDragged, LEdit: Boolean;
begin
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
    if (LHit.Kind = FMouseDownHit.Kind) and (LHit.Column = FMouseDownHit.Column) and (LHit.RowIndex = FMouseDownHit.RowIndex)
      and (LHit.Kind in [Th5uHitKind.DataCell, Th5uHitKind.Header, Th5uHitKind.RowIndicator])
    then
    begin
      if LEdit and (LHit.Kind = Th5uHitKind.DataCell) then
      begin
        if (LHit.Column.EditorKind = Th5uColumnEditorKind.Boolean) or ((LHit.Column.EditorKind = Th5uColumnEditorKind.Automatic)
          and (LHit.Column.DataType = Th5uColumnDataType.Boolean))
        then
        begin
          if GetCheckBoxRect(FMouseDownHit.Bounds).Contains(FSelectionDragOrigin) and GetCheckBoxRect(FMouseDownHit.Bounds).Contains(Point(X, Y)) then
            StartEdit(LHit);
        end
        else if FImmediateEdit then EditFocusedCell(True);
      end;
      NotifyCellClick(LHit.Column, LHit.RowIndex, LHit.Kind = Th5uHitKind.Header, LHit.Kind = Th5uHitKind.RowIndicator);
    end;
  end;
  FSelectingRange := False;
end;

procedure Th5uVclGrid.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  if not CanMoveColumn(AColumn) then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.ToggleAdjacentGroup(AViewRowIndex: Int64);
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
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, h5uClampInt64ToInteger(GetEstimatedTotalRowHeight));
    UpdateScrollBars;
    Invalidate;
  end;
end;

procedure Th5uVclGrid.SetAdjacentGroupCollapsed(AViewRowIndex: Int64; ACollapsed: Boolean);
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
    Invalidate;
  end;
end;

procedure Th5uVclGrid.ExpandAllAdjacentGroups;
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
  Invalidate;
end;

procedure Th5uVclGrid.CollapseAllAdjacentGroups;
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
  Invalidate;
end;

procedure Th5uVclGrid.ResetAdjacentGroupStates;
begin
  FAdjacentGroupMap.ResetStates;
  InvalidateAdjacentGroupMap(False);
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

function Th5uVclGrid.IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
var
  LInfo: Th5uAdjacentGroupRowInfo;
begin
  Result := TryGetAdjacentGroupRowInfo(AViewRowIndex, LInfo) and LInfo.IsFoldable and LInfo.Collapsed;
end;

procedure Th5uVclGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;

  if AComponent = FDataController then
    DataController := nil;
  if AComponent = FSharedClassFactory then
    SharedClassFactory := nil;
end;

procedure Th5uVclGrid.OptionsChanged(Sender: TObject);
begin
  if Sender = FAdjacentGroupFolding then
    InvalidateAdjacentGroupMap(False);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.Paint;
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

function Th5uVclGrid.ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;
var
  LInteger: Int64;
  LFloat: Double;
  LCurrency: Currency;
  LDateTime: TDateTime;
begin
  case AColumn.DataType of
    Th5uColumnDataType.Integer:
      begin
        if not TryStrToInt64(AText, LInteger) then
          raise EConvertError.CreateFmt('"%s" ist keine ganze Zahl.', [AText]);
        Result := TValue.From<Int64>(LInteger);
      end;

    Th5uColumnDataType.Float:
      begin
        if not TryStrToFloat(AText, LFloat) then
          raise EConvertError.CreateFmt('"%s" ist keine Zahl.', [AText]);
        Result := TValue.From<Double>(LFloat);
      end;

    Th5uColumnDataType.Currency:
      begin
        if not TryStrToCurr(AText, LCurrency) then
          raise EConvertError.CreateFmt('"%s" ist kein gültiger Betrag.', [AText]);
        Result := TValue.From<Currency>(LCurrency);
      end;

    Th5uColumnDataType.Time:
      begin
        if not TryStrToTime(AText, LDateTime) then
          raise EConvertError.CreateFmt('"%s" ist keine gültige Uhrzeit.', [AText]);
        Result := TValue.From<TDateTime>(LDateTime);
      end;

    Th5uColumnDataType.Date,
    Th5uColumnDataType.DateTime:
      begin
        if not TryStrToDateTime(AText, LDateTime) then
          raise EConvertError.CreateFmt('"%s" ist kein gültiges Datum.', [AText]);
        Result := TValue.From<TDateTime>(LDateTime);
      end;

    else
      Result := TValue.From<string>(AText);
  end;
end;

procedure Th5uVclGrid.RebuildAfterLayoutChange;
begin
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

procedure Th5uVclGrid.Resize;
begin
  inherited;
  if not CanUpdateLayout then
    Exit;
  LayoutScrollBars;
  RebuildAfterLayoutChange;
end;

function Th5uVclGrid.ResolveCellAppearance(const AContext: Th5uFactoryContext; AColumn: Th5uGridColumn; const ARowAppearance: Th5uResolvedAppearance;
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

function Th5uVclGrid.ResolveRowAppearance(AViewRowIndex: Int64; const ARowKey: Th5uRowKey; const AStyleName: string): Th5uResolvedAppearance;
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

function Th5uVclGrid.RowInfoAtPoint(X, Y: Integer; out AInfo: Th5uVisibleRowInfo): Boolean;
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

procedure Th5uVclGrid.ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
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

procedure Th5uVclGrid.SelectionChanged(Sender: TObject);
var
  LOld, LNew: Th5uCellAddress;
  LColumn: Th5uGridColumn;
begin
  Invalidate;
  if not CanUpdateLayout then Exit;
  LOld := FLastNotifiedCell;
  LNew := FSelection.FocusedCell;
  FLastNotifiedCell := LNew;
  if (LOld.RowIndex <> LNew.RowIndex) or (LOld.ColumnId <> LNew.ColumnId) or (LOld.RowKey <> LNew.RowKey) then
  begin
    if LOld.IsValid then
    begin
      LColumn := FColumns.FindById(LOld.ColumnId);
      if Assigned(LColumn) and Assigned(LColumn.OnCellExit) then
        LColumn.OnCellExit(LColumn, LColumn, LOld.RowIndex);
      if Assigned(FOnCellExit) then
        FOnCellExit(Self, LColumn, LOld.RowIndex);
    end;
    if LNew.IsValid then
    begin
      LColumn := FColumns.FindById(LNew.ColumnId);
      if Assigned(LColumn) and Assigned(LColumn.OnCellEnter) then
        LColumn.OnCellEnter(LColumn, LColumn, LNew.RowIndex);
      if Assigned(FOnCellEnter) then
        FOnCellEnter(Self, LColumn, LNew.RowIndex);
    end;
  end;
  if Assigned(FOnSelectionChange) then FOnSelectionChange(Self);
end;

procedure Th5uVclGrid.SetColumns(const AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure Th5uVclGrid.SetCustomization(const AValue: Th5uCustomizationOptions);
begin
  FCustomization.Assign(AValue);
end;

procedure Th5uVclGrid.SetAppearance(const AValue: Th5uGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure Th5uVclGrid.SetTree(const AValue: Th5uTreeOptions);
begin
  if Assigned(AValue) then
    FTree.Assign(AValue);
end;

procedure Th5uVclGrid.SetAdjacentGroupFolding(const AValue: Th5uAdjacentGroupFoldingOptions);
begin
  if Assigned(AValue) then
    FAdjacentGroupFolding.Assign(AValue);
end;

procedure Th5uVclGrid.SetGridLines(const AValue: Boolean);
begin
  if AValue then
    FSpacing.SetAllSeparators(1)
  else
    FSpacing.SetAllSeparators(0);
end;

procedure Th5uVclGrid.SetSpacing(const AValue: Th5uGridSpacingOptions);
begin
  FSpacing.Assign(AValue);
end;

procedure Th5uVclGrid.SetDataController(const AValue: Th5uCustomDataController);
begin
  if FDataController = AValue then
    Exit;
  EndSelectionDrag;

  CancelEditor;
  if Assigned(FDataController) then
    FDataController.RemoveFreeNotification(Self);

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

procedure Th5uVclGrid.SetHeaderLayout(const AValue: Th5uHeaderLayout);
begin
  FHeaderLayout.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetHeaderRowHeight(const AValue: Integer);
begin
  FHeaderRowHeight := EnsureRange(AValue, 16, 200);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
begin
  FFactoryScope.OnConfigureInstance := AValue;
end;

procedure Th5uVclGrid.SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
begin
  FFactoryScope.OnCreateInstance := AValue;
end;

procedure Th5uVclGrid.SetOnGetClass(const AValue: Th5uGetClassEvent);
begin
  FFactoryScope.OnGetClass := AValue;
end;

procedure Th5uVclGrid.SetRowHeight(const AValue: Th5uRowHeightOptions);
begin
  FRowHeight.Assign(AValue);
end;

procedure Th5uVclGrid.SetRowIndicatorWidth(const AValue: Integer);
begin
  FRowIndicatorWidth := EnsureRange(AValue, 0, 300);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetRowStyles(const AValue: Th5uRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclGrid.SetScrolling(const AValue: Th5uScrollingOptions);
begin
  FScrolling.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetScrollHints(const AValue: Th5uScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure Th5uVclGrid.SetSelection(const AValue: Th5uGridSelection);
begin
  FSelection.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclGrid.SetSharedClassFactory(const AValue: Th5uClassFactory);
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

procedure Th5uVclGrid.SetTheme(const AValue: Th5uGridTheme);
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

procedure Th5uVclGrid.SetColumnVisible(AColumn: Th5uGridColumn; AVisible: Boolean);
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

procedure Th5uVclGrid.ShowColumnChooser;
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

procedure Th5uVclGrid.ShowThumbHint(AAxis: Th5uScrollAxis; ATrigger: Th5uScrollHintTrigger);
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
  FThumbHint.BringToFront;

  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Enabled := True;
end;

function Th5uVclGrid.FocusedCellHit(out AHit: Th5uHitTestInfo): Boolean;
begin
  Result := CellHit(FSelection.FocusedCell, AHit);
end;

function Th5uVclGrid.CellHit(const LCell: Th5uCellAddress; out AHit: Th5uHitTestInfo): Boolean;
var
  LColumns: TArray<Th5uGridColumn>;
  LView: TRect;
  LTop, LHeight, LLeft, LRight: Integer;
  LRow: Int64;
  LKey: Th5uRowKey;
  LElement: Th5uElementKind;
  LColor: TColor;
  LStyle: string;
  LLevel, LClosed, I: Integer;
begin
  Result := False;
  AHit := Th5uHitTestInfo.Empty;
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
      Th5uFixedKind.Left:
        LLeft := LLeft + LColumns[I].Width + GetEffectiveColumnRightSpacing(LColumns[I]);
      Th5uFixedKind.Right:
        LRight := LRight - LColumns[I].Width - GetEffectiveColumnRightSpacing(LColumns[I]);
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

function Th5uVclGrid.FocusCell(ARow: Int64; AColumn: Integer; AExtend, AEdit: Boolean; AAdd: Boolean): Boolean;
var
  LCell: Th5uCellAddress;
  LColumns: TArray<Th5uGridColumn>;
  LRange: Th5uCellRange;
  LHit: Th5uHitTestInfo;
begin
  Result := False;
  if not CanUpdateLayout or not Assigned(FDataController) or (GetViewRowCount = 0) then
    Exit;
  LColumns := FColumns.VisibleColumns;
  if Length(LColumns) = 0 then
    Exit;
  LCell.RowIndex := EnsureRange(ARow, Int64(0), GetViewRowCount - 1);
  LCell.ColumnIndex := EnsureRange(AColumn, 0, High(LColumns));
  LCell.RowKey := GetViewRowKey(LCell.RowIndex);
  LCell.ColumnId := LColumns[LCell.ColumnIndex].Id;
  if AExtend and FSelection.AnchorCell.IsValid then
    LRange := Th5uCellRange.Create(FSelection.AnchorCell.RowIndex, LCell.RowIndex, FSelection.AnchorCell.ColumnIndex, LCell.ColumnIndex)
  else
    LRange := Th5uCellRange.Create(LCell.RowIndex, LCell.RowIndex, LCell.ColumnIndex, LCell.ColumnIndex);
  if not TryFocusCell(LCell, not AExtend) then Exit;
  FSelection.AddCellRange(LRange, AAdd, AExtend);
  Result := FocusedCellHit(LHit);
  if Result and AEdit and FImmediateEdit and not AExtend then
    EditFocusedCell(True);
end;

procedure Th5uVclGrid.EditFocusedCell(AAutomatic: Boolean);
var
  LHit: Th5uHitTestInfo;
begin
  if not FocusedCellHit(LHit) then
    Exit;
  // Focus alone must neither toggle Boolean values nor open an image dialog.
  if AAutomatic and not ((LHit.Column.EditorKind in [Th5uColumnEditorKind.Text, Th5uColumnEditorKind.Date, Th5uColumnEditorKind.Time, Th5uColumnEditorKind.DateTime])
    or ((LHit.Column.EditorKind = Th5uColumnEditorKind.Automatic) and not (LHit.Column.DataType in [Th5uColumnDataType.Boolean, Th5uColumnDataType.Image])))
  then
    Exit;
  StartEdit(LHit);
end;

function Th5uVclGrid.HandleNavigationKey(AKey: Word; AShift: TShiftState): Boolean;
var
  LCell: Th5uCellAddress;
  LHit: Th5uHitTestInfo;
  LColumns: TArray<Th5uGridColumn>;
  LRow, LCount: Int64;
  LColumn: Integer;
  LDistance: Integer;
begin
  Result := False;
  if not CanUpdateLayout or (ssAlt in AShift) then
    Exit;
  if AKey = vkEscape then
  begin
    EndSelectionDrag;
    FSearchText := '';
    FHeaderSelectionActive := False;
    FSelection.ClearExtendedSelection;
    Exit(True);
  end;
  if not (AKey in [vkLeft, vkRight, vkUp, vkDown, vkPrior, vkNext, vkHome, vkEnd, vkF2]) then
    Exit;
  Result := True;
  FSearchText := '';
  LCount := GetViewRowCount;
  LColumns := FColumns.VisibleColumns;
  if (LCount = 0) or (Length(LColumns) = 0) then
    Exit;
  LCell := FSelection.FocusedCell;
  if FHeaderSelectionActive and (ssShift in AShift) and (AKey <> vkF2) then
  begin
    if not LCell.IsValid then
    begin
      LCell.RowIndex := 0;
      LCell.ColumnIndex := 0;
    end;
    if FHeaderSelectionKind = Th5uSelectionKind.Rows then
      LCell.RowIndex := FHeaderFocus.RowIndex
    else
      LCell.ColumnIndex := FHeaderFocus.ColumnIndex;
    LCell.RowIndex := EnsureRange(LCell.RowIndex, Int64(0), LCount - 1);
    LCell.ColumnIndex := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
    LCell.RowKey := GetViewRowKey(LCell.RowIndex);
    LCell.ColumnId := LColumns[LCell.ColumnIndex].Id;
  end;
  if not LCell.IsValid then
  begin
    FocusCell(0, 0, False, AKey <> vkF2);
    if AKey = vkF2 then
      EditFocusedCell(False);
    Exit;
  end;
  LRow := EnsureRange(LCell.RowIndex, Int64(0), LCount - 1);
  LColumn := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
  case AKey of
    vkLeft:  Dec(LColumn);
    vkRight: Inc(LColumn);
    vkUp:    Dec(LRow);
    vkDown:  Inc(LRow);
    vkHome:
    begin
      LColumn := 0;
      if ssCtrl in AShift then
        LRow := 0;
    end;
    vkEnd:
    begin
      LColumn := High(LColumns);
      if ssCtrl in AShift then
        LRow := LCount - 1; 
    end;
    vkPrior, vkNext:
    begin
      LDistance := 0;
      repeat
        LDistance := LDistance + GetRowHeightFor(LRow, GetViewRowKey(LRow)) + FSpacing.RowSpacing;
        if AKey = vkPrior then
          Dec(LRow)
        else
          Inc(LRow);
      until (LRow <= 0) or (LRow >= LCount - 1) or (LDistance >= GetDataViewportRect.Height);
    end;
    vkF2:
    begin
      EditFocusedCell(False);
      Exit;
    end;
  end;
  if FHeaderSelectionActive and (ssShift in AShift) then
  begin
    LCell.RowIndex := EnsureRange(LRow, Int64(0), LCount - 1);
    LCell.ColumnIndex := EnsureRange(LColumn, 0, High(LColumns));
    LCell.RowKey := GetViewRowKey(LCell.RowIndex);
    LCell.ColumnId := LColumns[LCell.ColumnIndex].Id;
    SelectHeaderRange(FHeaderSelectionKind, LCell.RowIndex, LCell.ColumnIndex, AShift);
    CellHit(LCell, LHit);
  end
  else
    FocusCell(LRow, LColumn, ssShift in AShift, True, (ssCtrl in AShift) and (ssShift in AShift));
end;

procedure Th5uVclGrid.SearchCharacter(AChar: Char);
var
  LColumns: TArray<Th5uGridColumn>;
  LCell: Th5uCellAddress;
  LCount, LRow, LStart, I: Int64;
  LColumn: Integer;
  LText: string;
  LContinue: Boolean;
begin
  if (AChar < #32) or Assigned(FEditColumn) or not CanUpdateLayout then
    Exit;
  LCount := GetViewRowCount;
  LColumns := FColumns.VisibleColumns;
  if (LCount = 0) or (Length(LColumns) = 0) then
    Exit;
  LCell := FSelection.FocusedCell;
  LColumn := EnsureRange(LCell.ColumnIndex, 0, High(LColumns));
  LContinue := (FSearchText <> '') and ((Now - FSearchTime) * MSecsPerDay < 1000);
  if not LContinue then
    FSearchText := '';
  FSearchText := FSearchText + AChar;
  FSearchTime := Now;
  LStart := Max(Int64(0), LCell.RowIndex);
  if LCell.IsValid and not LContinue then
    LStart := (LStart + 1) mod LCount;
  for I := 0 to LCount - 1 do
  begin
    LRow := (LStart + I) mod LCount;
    PrepareViewRange(LRow, 1);
    LText := GetCellText(LColumns[LColumn], LRow, True);
    if SameText(Copy(LText, 1, Length(FSearchText)), FSearchText) then
    begin
      FocusCell(LRow, LColumn, False, False);
      Exit;
    end;
  end;
end;

procedure Th5uVclGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure Th5uVclGrid.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  if Message.CharCode = vkEscape then
    Message.Result := 1;
end;

procedure Th5uVclGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if HandleNavigationKey(Key, Shift) then
    Key := 0;
end;

procedure Th5uVclGrid.KeyPress(var Key: Char);
begin
  inherited;
  if Key >= #32 then
  begin
    SearchCharacter(Key);
    Key := #0;
  end;
end;

function Th5uVclGrid.DateEditorVisible: Boolean;
begin
  Result := Assigned(FDateEditor) and FDateEditor.Visible;
end;

function Th5uVclGrid.DateEditorValue: TValue;
var
  LDateTime: TDateTime;
begin
  if not FDateEditor.Checked then
    Exit(TValue.Empty);
  LDateTime := FDateEditor.DateTime;
  case FDateEditorKind of
    Th5uColumnEditorKind.Date: LDateTime := DateOf(LDateTime);
    Th5uColumnEditorKind.Time: LDateTime := TimeOf(LDateTime);
  end;
  Result := TValue.From<TDateTime>(LDateTime);
end;

procedure Th5uVclGrid.StartDateEdit(const AHit: Th5uHitTestInfo; AKind: Th5uColumnEditorKind);
var
  LValue: TValue;
begin
  if not Assigned(FDateEditor) then
  begin
    FDateEditor := TDateTimePicker.Create(Self);
    FDateEditor.Visible := False;
    FDateEditor.Parent := Self;
    FDateEditor.ShowCheckbox := True;
    FDateEditor.OnChange := EditorChanged;
    FDateEditor.OnKeyDown := EditorKeyDown;
    FDateEditor.OnExit := EditorExit;
  end;
  if AKind = Th5uColumnEditorKind.Time then
  begin
    FDateEditor.Kind := dtkTime;
    FDateEditor.Format := 'HH:mm:ss';
  end
  else
  begin
    FDateEditor.Kind := dtkDate;
    if AKind = Th5uColumnEditorKind.DateTime then
      FDateEditor.Format := 'dd.MM.yyyy HH:mm:ss'
    else
      FDateEditor.Format := 'dd.MM.yyyy';
  end;
  FEditRowIndex := AHit.RowIndex;
  FEditRowKey := AHit.RowKey;
  FEditColumn := AHit.Column;
  FDateEditorKind := AKind;
  LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
  if LValue.IsEmpty then
    FDateEditor.DateTime := Now
  else
    FDateEditor.DateTime := LValue.AsType<TDateTime>;
  FDateEditor.Checked := not LValue.IsEmpty;
  FDateEditorOriginal := FDateEditor.DateTime;
  FDateEditorWasEmpty := LValue.IsEmpty;
  FEditorExitBlocked := False;
  FDateEditor.BoundsRect := AHit.Bounds;
  FDateEditor.Visible := True;
  FDateEditor.BringToFront;
  FDateEditor.SetFocus;
end;
procedure Th5uVclGrid.StartEdit(const AHit: Th5uHitTestInfo);
var
  LEditorKind: Th5uColumnEditorKind;
  LValue: TValue;
  LBytes: TBytes;
  LCell: Th5uCellAddress;
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

  LEditorKind := AHit.Column.EditorKind;
  if LEditorKind = Th5uColumnEditorKind.Automatic then
    case AHit.Column.DataType of
      Th5uColumnDataType.Boolean:
        LEditorKind := Th5uColumnEditorKind.Boolean;
      Th5uColumnDataType.Image:
        LEditorKind := Th5uColumnEditorKind.Image;
      Th5uColumnDataType.Date:
        LEditorKind := Th5uColumnEditorKind.Date;
      Th5uColumnDataType.Time:
        LEditorKind := Th5uColumnEditorKind.Time;
      Th5uColumnDataType.DateTime:
        LEditorKind := Th5uColumnEditorKind.DateTime;
      else
        LEditorKind := Th5uColumnEditorKind.Text;
    end;

  if LEditorKind = Th5uColumnEditorKind.None then
    Exit;

  LCell.RowIndex := AHit.RowIndex;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnId := AHit.Column.Id;
  if not TryFocusCell(LCell, True) then Exit;

  case LEditorKind of
    Th5uColumnEditorKind.Date, Th5uColumnEditorKind.Time, Th5uColumnEditorKind.DateTime:
      StartDateEdit(AHit, LEditorKind);

    Th5uColumnEditorKind.Boolean:
      begin
        LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
        if LValue.IsEmpty then
          PutCellValue(AHit.Column, AHit.RowIndex, TValue.From<Boolean>(True))
        else
          PutCellValue(AHit.Column, AHit.RowIndex, TValue.From<Boolean>(not LValue.AsBoolean));
      end;

    Th5uColumnEditorKind.Image:
      begin
        LValue := GetCellValue(AHit.Column, AHit.RowIndex, False);
        if LValue.IsType<TBytes> then
          LBytes := LValue.AsType<TBytes>
        else
          LBytes := nil;

        if Th5uVclImageEditForm.Execute(GetParentForm(Self), LBytes) then
          PutCellValue(AHit.Column, AHit.RowIndex, TValue.From<TBytes>(LBytes));
      end;

    else
      begin
        FEditRowIndex := AHit.RowIndex;
        FEditRowKey := AHit.RowKey;
        FEditColumn := AHit.Column;
        FEditor.Text := GetCellText(AHit.Column, AHit.RowIndex, False);
        FEditorOriginalText := FEditor.Text;
        FEditorExitBlocked := False;
        FEditor.BoundsRect := AHit.Bounds;
        FEditor.Visible := True;
        FEditor.BringToFront;
        FEditor.SetFocus;
        FEditor.SelectAll;
      end;
  end;

  Invalidate;
end;

procedure Th5uVclGrid.ThumbHintTimer(Sender: TObject);
begin
  HideThumbHint;
end;

procedure Th5uVclGrid.UpdateScrollBars;
var
  LClient: TRect;
  LTotalWidth: Integer;
  LTotalHeight: Int64;
  LAvailableWidth: Integer;
  LAvailableHeight: Integer;
  LNeedHorizontal: Boolean;
  LNeedVertical: Boolean;
  LMaxHorizontal: Integer;
  LMaxVertical: Integer;
begin
  if FUpdatingScrollBars or not CanUpdateLayout then
    Exit;

  FUpdatingScrollBars := True;
  try
    LClient := ClientRect;
    LTotalWidth := GetTotalColumnWidth;
    LTotalHeight := GetEstimatedTotalRowHeight;

    LAvailableWidth := Max(0, LClient.Width - FSpacing.Left - FSpacing.Right);
    LAvailableHeight := Max(0, LClient.Height - FSpacing.Top - FSpacing.Bottom - GetHeaderHeight);

    LNeedHorizontal := LTotalWidth > LAvailableWidth;
    LNeedVertical := LTotalHeight > LAvailableHeight;

    FHScrollBar.Visible := LNeedHorizontal;
    FVScrollBar.Visible := LNeedVertical;
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

end.
