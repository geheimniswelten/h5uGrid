# h5u.Grid – öffentlicher API-Auszug

> Automatisch aus den vollständigen `interface`-Abschnitten des ausgelieferten Quellstands erzeugt. Maßgeblich bleiben die Pascal-Units.

**Erzeugt:** 2. September 2026  
**Version:** 0.1.4

## `Fmx.h5u.Grid`

Quelle: `Source/FMX/Fmx.h5u.Grid.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.StrUtils,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  FMX.Controls,
  FMX.Edit,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Selection,
  h5u.Grid.Types,
  Fmx.h5u.Grid.Styles;

type
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
    class function Empty: Th5uFmxHitTestInfo; static;
  end;

  Th5uFmxVisualCell = class(Th5uFactoryObject)
  private
    FContext: Th5uFactoryContext;
    FBounds: TRectF;
    FValue: TValue;
    FDisplayText: string;
    FAppearance: Th5uResolvedAppearance;
    FInUse: Boolean;
  protected
    procedure PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas); virtual;
  public
    procedure BindCell(const AContext: Th5uFactoryContext; const ABounds: TRectF; const AValue: TValue; const ADisplayText: string;
      const AAppearance: Th5uResolvedAppearance); virtual;
    procedure Paint(AGrid: Th5uFmxGrid; ACanvas: TCanvas); virtual;
    property Context: Th5uFactoryContext read FContext;
    property Bounds: TRectF read FBounds;
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
    FColumns: Th5uGridColumns;
    FHeaderLayout: Th5uHeaderLayout;
    FDataController: Th5uCustomDataController;
    FDataLink: Th5uDataControllerLink;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FSelection: Th5uGridSelection;
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
    FTextSize: Single;

    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditor: TEdit;
    FImageEditor: TObject;
    FEditRowIndex: Int64;
    FEditColumn: Th5uGridColumn;
    FCommittingEditor: Boolean;

    FHorizontalOffset: Single;
    FVerticalOffset: Single;
    FAllColumns: TArray<Th5uFmxVisibleColumnInfo>;
    FVisibleColumns: TArray<Th5uFmxVisibleColumnInfo>;
    FVisibleRows: TArray<Th5uFmxVisibleRowInfo>;
    FCellPool: TObjectList<Th5uFmxVisualCell>;
    FRowHeightCache: TDictionary<string, Single>;
    FUpdatingScrollBars: Boolean;
    FLastMousePoint: TPointF;

    FOnGetRowHeight: Th5uFmxGetRowHeightEvent;
    FOnGetRowSpacing: Th5uFmxGetRowSpacingEvent;
    FOnGetThumbHint: Th5uFmxGetThumbHintEvent;
    FOnCustomDraw: Th5uFmxCustomDrawEvent;
    FOnGetTreeLevel: Th5uGetTreeLevelEvent;
    FOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    FOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    FOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;

    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure ThumbHintTimer(Sender: TObject);
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
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCell;

    procedure DrawContentPadding;
    procedure DrawHeaders;
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

    procedure StartEdit(const AHit: Th5uFmxHitTestInfo);
    procedure CommitEditor;
    procedure CancelEditor;
    procedure ImageEditorCommit(Sender: TObject);
    procedure ImageEditorCancel(Sender: TObject);
    function ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;

    function GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uFmxVisualCellClass): Th5uFmxVisualCellClass; virtual;
    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uFmxDrawContext; AStage: Th5uFmxCustomDrawStage; var ADrawDefault: Boolean);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
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
    property OnCustomDraw: Th5uFmxCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnGetTreeLevel: Th5uGetTreeLevelEvent read FOnGetTreeLevel write FOnGetTreeLevel;
    property OnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent read FOnGetTreeBranchEnd write FOnGetTreeBranchEnd;
    property OnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent read FOnGetAdjacentGroupId write FOnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent read FOnAdjacentGroupStateChanged write FOnAdjacentGroupStateChanged;
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
```

## `Fmx.h5u.Grid.Design`

Quelle: `Source/Design/Fmx.h5u.Grid.Design.pas`

```pascal
procedure Register;
```

## `Fmx.h5u.Grid.Editors`

Quelle: `Source/FMX/Fmx.h5u.Grid.Editors.pas`

```pascal
uses
  System.Classes,
  System.SysUtils,
  System.Types,
  FMX.Controls,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types;

type
  Th5uFmxImageEditor = class(TLayout)
  private
    FImage: TImage;
    FToolBar: TLayout;
    FLoadButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    FOnCommit: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure LoadClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    property Bytes: TBytes read FBytes write SetBytes;
    property OnCommit: TNotifyEvent read FOnCommit write FOnCommit;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
  end;
```

## `Fmx.h5u.Grid.Styles`

Quelle: `Source/FMX/Fmx.h5u.Grid.Styles.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.UITypes,
  FMX.Graphics,
  h5u.Grid.Types;

type
  Th5uFmxPalette = record
    GridBackground: TAlphaColor;
    EmptyArea: TAlphaColor;
    CellBackground: TAlphaColor;
    CellText: TAlphaColor;
    CellBorder: TAlphaColor;
    HeaderBackground: TAlphaColor;
    HeaderText: TAlphaColor;
    FixedBackground: TAlphaColor;
    OddBackground: TAlphaColor;
    EvenBackground: TAlphaColor;
    StripeBackground: TAlphaColor;
    HighlightedColumnBackground: TAlphaColor;
    SelectedBackground: TAlphaColor;
    SelectedText: TAlphaColor;
    FocusBorder: TAlphaColor;
    ErrorBackground: TAlphaColor;
    WarningBackground: TAlphaColor;
    TreeBranchEndBackground: TAlphaColor;
    AdjacentGroupEndBackground: TAlphaColor;
    DisabledText: TAlphaColor;
    ThumbHintBackground: TAlphaColor;
    ThumbHintText: TAlphaColor;
  end;

function h5uGetFmxPalette(ATheme: Th5uGridTheme): Th5uFmxPalette;
function h5uColorToFmx(const AColor: TColor): TAlphaColor;
```

## `h5u.Grid.AdjacentGroups`

Quelle: `Source/Common/h5u.Grid.AdjacentGroups.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  h5u.Grid.Types;

type
  // A run represents one contiguous block of equal adjacent IDs. The same ID
  // may therefore occur in several independent runs when other rows lie in
  // between. State is keyed by the first row of the run, not by the ID alone.
  Th5uAdjacentGroupRun = record
    StateKey: string;
    ComparisonKey: string;
    GroupId: TValue;
    AnchorRowKey: Th5uRowKey;
    FirstControllerRowIndex: Int64;
    LastControllerRowIndex: Int64;
    RowCount: Int64;
    Collapsed: Boolean;
    function IsFoldable: Boolean;
  end;

  Th5uAdjacentGroupRowInfo = record
    ViewRowIndex: Int64;
    ControllerRowIndex: Int64;
    GroupIndex: Integer;
    GroupOffset: Int64;
    GroupId: TValue;
    AnchorRowKey: Th5uRowKey;
    RowCount: Int64;
    Collapsed: Boolean;
    IsFirstRow: Boolean;
    IsLastSourceRow: Boolean;
    IsLastVisibleRow: Boolean;
    IsFoldable: Boolean;
    class function Empty: Th5uAdjacentGroupRowInfo; static;
  end;

  // Per-grid view map. It never changes the data controller or its order; it
  // only maps visible row indexes to the controller's current view indexes.
  Th5uAdjacentGroupMap = class
  private
    FRuns: TList<Th5uAdjacentGroupRun>;
    FVisibleControllerRows: TList<Int64>;
    FVisibleGroupIndexes: TList<Integer>;
    FCollapsedStates: TDictionary<string, Boolean>;
    FActive: Boolean;
    FInitialCollapsed: Boolean;
    FCaseSensitive: Boolean;
    FGroupEmptyValues: Boolean;
    FHasPendingRun: Boolean;
    FPendingRun: Th5uAdjacentGroupRun;
    procedure FinalizePendingRun;
    procedure RebuildVisibleRows;
    function BuildComparisonKey(const AGroupId: TValue; AControllerRowIndex: Int64; AAvailable: Boolean; out AKey: string): Boolean;
    function BuildStateKey(const ARowKey: Th5uRowKey; AControllerRowIndex: Int64; const AComparisonKey: string): string;
    function GetRun(AIndex: Integer): Th5uAdjacentGroupRun;
    function GetRunCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear(AClearStates: Boolean = False);
    procedure ResetStates;
    procedure BeginBuild(AInitialState: Th5uAdjacentGroupInitialState; ACaseSensitive: Boolean; AGroupEmptyValues: Boolean);
    procedure AddRow(AControllerRowIndex: Int64; const ARowKey: Th5uRowKey; const AGroupId: TValue; AAvailable: Boolean);
    procedure EndBuild;

    function GetVisibleRowCount: Int64;
    function MapViewToController(AViewRowIndex: Int64): Int64;
    function TryGetRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    function SetCollapsedAtViewRow(AViewRowIndex: Int64; ACollapsed: Boolean): Boolean;
    function ToggleAtViewRow(AViewRowIndex: Int64): Boolean;
    function ExpandAll: Boolean;
    function CollapseAll: Boolean;

    property Active: Boolean read FActive;
    property Runs[AIndex: Integer]: Th5uAdjacentGroupRun read GetRun;
    property RunCount: Integer read GetRunCount;
  end;
```

## `h5u.Grid.Columns`

Quelle: `Source/Common/h5u.Grid.Columns.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.Math,
  System.SysUtils,
  System.UITypes,
  h5u.Grid.Types;

type
  Th5uGridColumn = class;
  Th5uGridColumns = class;

  Th5uColumnChangedEvent = procedure(Sender: TObject; AColumn: Th5uGridColumn) of object;

  Th5uGridColumn = class(TCollectionItem)
  private
    FId: string;
    FCaption: string;
    FFieldName: string;
    FWidth: Integer;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FVisible: Boolean;
    FVisibleIndex: Integer;
    FFixedKind: Th5uFixedKind;
    FReadOnly: Boolean;
    FDataType: Th5uColumnDataType;
    FEditorKind: Th5uColumnEditorKind;
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
    FCanMove: Boolean;
    FCanHide: Boolean;
    FCanResize: Boolean;
    FCanSelect: Boolean;
    FShowInColumnChooser: Boolean;
    FImagePreserveAspectRatio: Boolean;
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
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function GetColumns: Th5uGridColumns;
    property Columns: Th5uGridColumns read GetColumns;
  published
    property Id: string read FId write SetId;
    property Caption: string read FCaption write SetCaption;
    property FieldName: string read FFieldName write SetFieldName;
    property Width: Integer read FWidth write SetWidth default 100;
    property MinWidth: Integer read FMinWidth write FMinWidth default 24;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth default 1000;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleIndex: Integer read FVisibleIndex write SetVisibleIndex default -1;
    property FixedKind: Th5uFixedKind read FFixedKind write SetFixedKind default Th5uFixedKind.None;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property DataType: Th5uColumnDataType read FDataType write FDataType default Th5uColumnDataType.Auto;
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
    property ClassId: Th5uClassId read FClassId write FClassId;
    property CellClassId: Th5uClassId read FCellClassId write FCellClassId;
    property HeaderCellClassId: Th5uClassId read FHeaderCellClassId write FHeaderCellClassId;
    property CanMove: Boolean read FCanMove write FCanMove default True;
    property CanHide: Boolean read FCanHide write FCanHide default True;
    property CanResize: Boolean read FCanResize write FCanResize default True;
    property CanSelect: Boolean read FCanSelect write FCanSelect default True;
    property ShowInColumnChooser: Boolean read FShowInColumnChooser write FShowInColumnChooser default True;
    property ImagePreserveAspectRatio: Boolean read FImagePreserveAspectRatio write FImagePreserveAspectRatio default True;
  end;

  Th5uGridColumns = class(TOwnedCollection)
  private
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
    function VisibleColumns: TArray<Th5uGridColumn>;
    procedure NormalizeVisibleIndexes;
    procedure MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
    property Items[AIndex: Integer]: Th5uGridColumn read GetItem write SetItem; default;
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
    FStyleName: string;
    FClassId: Th5uClassId;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
  published
    property Id: string read FId write FId;
    property Caption: string read FCaption write FCaption;
    property ColumnId: string read FColumnId write FColumnId;
    property LayoutRow: Integer read FLayoutRow write FLayoutRow default 0;
    property LayoutColumn: Integer read FLayoutColumn write FLayoutColumn default 0;
    property RowSpan: Integer read FRowSpan write FRowSpan default 1;
    property ColumnSpan: Integer read FColumnSpan write FColumnSpan default 1;
    property StyleName: string read FStyleName write FStyleName;
    property ClassId: Th5uClassId read FClassId write FClassId;
  end;

  Th5uHeaderLayoutCells = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): Th5uHeaderLayoutCell;
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
    procedure SetCells(const AValue: Th5uHeaderLayoutCells);
    procedure SetRowCount(const AValue: Integer);
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Owner: TPersistent read FOwner;
  published
    property Enabled: Boolean read FEnabled write FEnabled default False;
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
```

## `h5u.Grid.Data.Core`

Quelle: `Source/Common/h5u.Grid.Data.Core.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  Th5uCustomDataController = class;
  Th5uDataControllerLink = class;

  Th5uDataControllerChangedEvent = procedure(Sender: TObject; const AChange: Th5uDataChange) of object;

  Th5uDataControllerLink = class(TObject)
  private
    FController: Th5uCustomDataController;
    FOnChanged: Th5uDataControllerChangedEvent;
    procedure SetController(const AValue: Th5uCustomDataController);
  public
    destructor Destroy; override;
    procedure DataChanged(const AChange: Th5uDataChange);
    property Controller: Th5uCustomDataController read FController write SetController;
    property OnChanged: Th5uDataControllerChangedEvent read FOnChanged write FOnChanged;
  end;

  Th5uDataViewSession = class(Th5uFactoryObject)
  private
    FGrid: TObject;
    FView: TObject;
    FController: Th5uCustomDataController;
    FQueryGeneration: Int64;
  public
    constructor Create(const AContext: Th5uFactoryContext); override;
    procedure NextQueryGeneration;
    property Grid: TObject read FGrid;
    property View: TObject read FView;
    property Controller: Th5uCustomDataController read FController;
    property QueryGeneration: Int64 read FQueryGeneration;
  end;

  Th5uCustomDataController = class(TComponent)
  private
    FLinks: TList<Th5uDataControllerLink>;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FCache: Th5uCacheOptions;
    FPagination: Th5uPaginationOptions;
    FEnabled: Boolean;
    FUpdateCount: Integer;
    FPendingReset: Boolean;
    procedure CacheOptionsChanged(Sender: TObject);
    procedure PaginationOptionsChanged(Sender: TObject);
    procedure SetSharedClassFactory(const AValue: Th5uClassFactory);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetSourceRowCount: Int64; virtual; abstract;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; virtual;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; virtual; abstract;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); virtual;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; virtual;
    function GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string; virtual;
    function MapViewToSourceIndex(AViewRowIndex: Int64): Int64; virtual;

    procedure DoCacheOptionsChanged; virtual;
    procedure DoPaginationChanged; virtual;

    procedure RegisterLink(ALink: Th5uDataControllerLink);
    procedure UnregisterLink(ALink: Th5uDataControllerLink);
    procedure NotifyDataChanged(const AChange: Th5uDataChange);

    function GetDataSessionClass(const AContext: Th5uFactoryContext): TClass; virtual;

    property Links: TList<Th5uDataControllerLink> read FLinks;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Invalidate;
    procedure PrepareRange(AFirstViewRow, ACount: Int64); virtual;

    function GetRowCount: Int64;
    function GetTotalRowCount: Int64;
    function GetSourceRowIndex(AViewRowIndex: Int64): Int64;
    // Unlike GetRowCount (the current numbered page), this also accepts the
    // immediately following logical view index so layout helpers can inspect
    // a page boundary without treating it as the end of the source.
    function IsRowAvailable(AViewRowIndex: Int64): Boolean;
    function GetRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetDisplayText(AViewRowIndex: Int64; const AFieldName: string; const ADisplayFormat: string = ''): string;

    function CreateSession(AGrid, AView: TObject): Th5uDataViewSession; virtual;

    property FactoryScope: Th5uFactoryScope read FFactoryScope;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property SharedClassFactory: Th5uClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Cache: Th5uCacheOptions read FCache write FCache;
    property Pagination: Th5uPaginationOptions read FPagination write FPagination;
  end;

function h5uValueToDisplayText(const AValue: TValue; const ADisplayFormat: string = ''): string;

function h5uTryValueAsInteger(const AValue: TValue; out AInteger: Integer): Boolean;
```

## `h5u.Grid.Data.Dataset`

Quelle: `Source/Common/h5u.Grid.Data.Dataset.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  Data.DB,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uDatasetController = class;

  Th5uDatasetDataLink = class(TDataLink)
  private
    FOwner: Th5uDatasetController;
  protected
    procedure ActiveChanged; override;
    procedure DatasetChanged; override;
    procedure DatasetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AOwner: Th5uDatasetController);
  end;

  Th5uDataRowSnapshot = class
  private
    FRowKey: Th5uRowKey;
    FValues: TDictionary<string, TValue>;
  public
    constructor Create;
    destructor Destroy; override;
    property RowKey: Th5uRowKey read FRowKey write FRowKey;
    property Values: TDictionary<string, TValue> read FValues;
  end;

  Th5uDatasetController = class(Th5uCustomDataController)
  private
    FDataSource: TDataSource;
    FDataLink: Th5uDatasetDataLink;
    FKeyFieldName: string;
    FSnapshotCache: TObjectDictionary<Int64, Th5uDataRowSnapshot>;
    FCacheGeneration: Int64;
    procedure SetDataSource(const AValue: TDataSource);
    function GetDataset: TDataset;
    function ReadFieldValue(AField: TField): TValue;
    procedure WriteFieldValue(AField: TField; const AValue: TValue);
    function CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    function GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    procedure ClearSnapshotCache;
    function GoToSourceRow(ASourceRowIndex: Int64): Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareRange(AFirstViewRow, ACount: Int64); override;
    procedure DatasetChanged(AKind: Th5uDataChangeKind; AField: TField = nil);
    property Dataset: TDataset read GetDataset;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property KeyFieldName: string read FKeyFieldName write FKeyFieldName;
  end;
```

## `h5u.Grid.Data.Memory`

Quelle: `Source/Common/h5u.Grid.Data.Memory.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uMemoryRow = class
  private
    FKey: Th5uRowKey;
    FValues: TDictionary<string, TValue>;
  public
    constructor Create(const AKey: Th5uRowKey);
    destructor Destroy; override;
    function GetValue(const AFieldName: string): TValue;
    procedure SetValue(const AFieldName: string; const AValue: TValue);
    property Key: Th5uRowKey read FKey write FKey;
  end;

  Th5uMemoryController = class(Th5uCustomDataController)
  private
    FRows: TObjectList<Th5uMemoryRow>;
    FNextKey: Int64;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AppendRow: Th5uMemoryRow;
    function AppendValues(const AFieldNames: array of string; const AValues: array of TValue): Th5uMemoryRow;
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    function Row(AIndex: Integer): Th5uMemoryRow;
  end;
```

## `h5u.Grid.Data.Objects`

Quelle: `Source/Common/h5u.Grid.Data.Objects.pas`

```pascal
{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uObjectListController = class(Th5uCustomDataController)
  private
    FItems: TList<TObject>;
    FOwnsObjects: Boolean;
    FKeyPropertyName: string;
    FRttiContext: TRttiContext;
    FPropertyCache: TDictionary<string, TRttiProperty>;
    FValueCache: TDictionary<string, TValue>;
    function ResolveProperty(AObject: TObject; const APropertyName: string): TRttiProperty;
    function ReadPropertyPath(AObject: TObject; const APath: string): TValue;
    procedure WritePropertyPath(AObject: TObject; const APath: string; const AValue: TValue);
    function ValueCacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Add(AObject: TObject);
    procedure Insert(AIndex: Integer; AObject: TObject);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    procedure NotifyObjectChanged(AObject: TObject; const APropertyName: string = '');
    function Item(AIndex: Integer): TObject;

    function GetCount: Integer;
    property Count: Integer read GetCount;
  published
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects default False;
    property KeyPropertyName: string read FKeyPropertyName write FKeyPropertyName;
  end;
```

## `h5u.Grid.Data.Virtual`

Quelle: `Source/Common/h5u.Grid.Data.Virtual.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  Th5uVirtualGetRowCountEvent = procedure(Sender: TObject; var ARowCount: Int64) of object;

  Th5uVirtualGetRowKeyEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey) of object;

  Th5uVirtualGetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue) of object;

  Th5uVirtualSetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean) of object;

  Th5uVirtualCanEditEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var ACanEdit: Boolean) of object;

  Th5uVirtualPrepareRangeEvent = procedure(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64) of object;

  Th5uVirtualController = class(Th5uCustomDataController)
  private
    FOnGetRowCount: Th5uVirtualGetRowCountEvent;
    FOnGetRowKey: Th5uVirtualGetRowKeyEvent;
    FOnGetValue: Th5uVirtualGetValueEvent;
    FOnSetValue: Th5uVirtualSetValueEvent;
    FOnCanEdit: Th5uVirtualCanEditEvent;
    FOnPrepareRange: Th5uVirtualPrepareRangeEvent;
    FValueCache: TDictionary<string, TValue>;
    FQueryGeneration: Int64;
    function CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): Th5uRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareRange(AFirstViewRow, ACount: Int64); override;

    procedure NotifyReset;
    procedure NotifyRowsInserted(AFirstSourceRow, ACount: Int64);
    procedure NotifyRowsDeleted(AFirstSourceRow, ACount: Int64);
    procedure NotifyRowChanged(ASourceRowIndex: Int64; const AColumnId: string = '');

    procedure BeginNewQuery;
    property QueryGeneration: Int64 read FQueryGeneration;
  published
    property OnGetRowCount: Th5uVirtualGetRowCountEvent read FOnGetRowCount write FOnGetRowCount;
    property OnGetRowKey: Th5uVirtualGetRowKeyEvent read FOnGetRowKey write FOnGetRowKey;
    property OnGetValue: Th5uVirtualGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: Th5uVirtualSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCanEdit: Th5uVirtualCanEditEvent read FOnCanEdit write FOnCanEdit;
    property OnPrepareRange: Th5uVirtualPrepareRangeEvent read FOnPrepareRange write FOnPrepareRange;
  end;
```

## `h5u.Grid.Design`

Quelle: `Source/Design/h5u.Grid.Design.pas`

```pascal
procedure Register;
```

## `h5u.Grid.Factory`

Quelle: `Source/Common/h5u.Grid.Factory.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.SysUtils,
  h5u.Grid.Types;

type
  Th5uFactoryObject = class;
  Th5uFactoryObjectClass = class of Th5uFactoryObject;
  Th5uCollectionItemClass = class of TCollectionItem;
  Th5uAnyObjectClass = class of TObject;

  Th5uClassRulePredicate = reference to function(const AContext: Th5uFactoryContext): Boolean;

  Th5uGetClassEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; var AClass: TClass; var ACacheScope: Th5uFactoryCacheScope) of object;

  Th5uCreateInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstanceClass: TClass; var AInstance: TObject; var AHandled: Boolean) of object;

  Th5uConfigureInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstance: TObject) of object;

  Th5uInstanceEvent = procedure(Sender: TObject; const AContext: Th5uFactoryContext; AInstance: TObject) of object;

  Th5uFactoryObject = class(TObject)
  public
    constructor Create(const AContext: Th5uFactoryContext); virtual;
    procedure Configure(const AContext: Th5uFactoryContext); virtual;
    procedure Bind(const AContext: Th5uFactoryContext); virtual;
    procedure Unbind; virtual;
  end;

  Th5uClassRegistration = class
  private
    FClassId: Th5uClassId;
    FExpectedBaseClass: TClass;
    FImplementationClass: TClass;
    FPredicate: Th5uClassRulePredicate;
    FPriority: Integer;
    FSequence: Int64;
  public
    property ClassId: Th5uClassId read FClassId;
    property ExpectedBaseClass: TClass read FExpectedBaseClass;
    property ImplementationClass: TClass read FImplementationClass;
    property Predicate: Th5uClassRulePredicate read FPredicate;
    property Priority: Integer read FPriority;
    property Sequence: Int64 read FSequence;
  end;

  Th5uFactoryScope = class(TPersistent)
  private
    FOwner: TObject;
    FParent: Th5uFactoryScope;
    FRegistrations: TObjectList<Th5uClassRegistration>;
    FLock: TMultiReadExclusiveWriteSynchronizer;
    FSequence: Int64;
    FOnGetClass: Th5uGetClassEvent;
    FOnCreateInstance: Th5uCreateInstanceEvent;
    FOnConfigureInstance: Th5uConfigureInstanceEvent;
    FOnInstanceCreated: Th5uInstanceEvent;
    FOnBindInstance: Th5uInstanceEvent;
    FOnUnbindInstance: Th5uInstanceEvent;
    function FindLocalClass(const AContext: Th5uFactoryContext; AExpectedBaseClass: TClass): TClass;
    procedure ValidateClass(const AClassId: Th5uClassId; AClass, AExpectedBaseClass: TClass);
    procedure SetParent(const AValue: Th5uFactoryScope);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function RegisterClass(const AClassId: Th5uClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer = 0;
      const APredicate: Th5uClassRulePredicate = nil): Th5uClassRegistration;

    procedure Unregister(ARegistration: Th5uClassRegistration);
    procedure Clear;

    function ResolveClass(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: Th5uFactoryCacheScope): TClass;

    function CreateInstance(const AContext: Th5uFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;

    procedure ConfigureInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    procedure BindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    procedure UnbindInstance(const AContext: Th5uFactoryContext; AInstance: TObject);

    property Owner: TObject read FOwner;
    property Parent: Th5uFactoryScope read FParent write SetParent;

    property OnGetClass: Th5uGetClassEvent read FOnGetClass write FOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read FOnCreateInstance write FOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read FOnConfigureInstance write FOnConfigureInstance;
    property OnInstanceCreated: Th5uInstanceEvent read FOnInstanceCreated write FOnInstanceCreated;
    property OnBindInstance: Th5uInstanceEvent read FOnBindInstance write FOnBindInstance;
    property OnUnbindInstance: Th5uInstanceEvent read FOnUnbindInstance write FOnUnbindInstance;
  end;

  Th5uClassFactory = class(TComponent)
  private
    FScope: Th5uFactoryScope;
    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: Th5uConfigureInstanceEvent);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Scope: Th5uFactoryScope read FScope;
  published
    property OnGetClass: Th5uGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
  end;

function h5uGlobalFactoryScope: Th5uFactoryScope;
```

## `h5u.Grid.Options`

Quelle: `Source/Common/h5u.Grid.Options.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  System.UITypes,
  h5u.Grid.Columns,
  h5u.Grid.Types;

type
  Th5uOptionsChangedEvent = procedure(Sender: TObject) of object;

  // Spacing is layout geometry. A value of 1 produces the default one-pixel
  // separator; 0 disables the corresponding separator completely.
  Th5uGridSpacingOptions = class(TPersistent)
  private
    FLeft: Integer;
    FTop: Integer;
    FRight: Integer;
    FBottom: Integer;
    FRowSpacing: Integer;
    FDefaultColumnRightSpacing: Integer;
    FRowSpacingColor: TColor;
    FColumnSpacingColor: TColor;
    FContentPaddingColor: TColor;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetBottom(const AValue: Integer);
    procedure SetColumnSpacingColor(const AValue: TColor);
    procedure SetContentPaddingColor(const AValue: TColor);
    procedure SetDefaultColumnRightSpacing(const AValue: Integer);
    procedure SetLeft(const AValue: Integer);
    procedure SetRight(const AValue: Integer);
    procedure SetRowSpacing(const AValue: Integer);
    procedure SetRowSpacingColor(const AValue: TColor);
    procedure SetTop(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure SetAllSeparators(const ASize: Integer);
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Left: Integer read FLeft write SetLeft default 1;
    property Top: Integer read FTop write SetTop default 1;
    property Right: Integer read FRight write SetRight default 1;
    property Bottom: Integer read FBottom write SetBottom default 1;
    property RowSpacing: Integer read FRowSpacing write SetRowSpacing default 1;
    property DefaultColumnRightSpacing: Integer read FDefaultColumnRightSpacing write SetDefaultColumnRightSpacing default 1;
    property RowSpacingColor: TColor read FRowSpacingColor write SetRowSpacingColor default TColorRec.Lightgray;
    property ColumnSpacingColor: TColor read FColumnSpacingColor write SetColumnSpacingColor default TColorRec.Lightgray;
    property ContentPaddingColor: TColor read FContentPaddingColor write SetContentPaddingColor default TColorRec.Lightgray;
  end;

  Th5uGridAppearanceOptions = class(TPersistent)
  private
    FDefaultCellColor: TColor;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetDefaultCellColor(const AValue: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property DefaultCellColor: TColor read FDefaultCellColor write SetDefaultCellColor default TColorRec.SysDefault;
  end;

  // When a flattened tree leaves one or more child levels, this band replaces
  // the normal row spacing after the last visible descendant. It is never
  // added on top of RowSpacing.
  Th5uTreeBranchEndBandOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FHeight: Integer;
    FColor: TColor;
    FStyleName: string;
    FIncludeEndOfData: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetHeight(const AValue: Integer);
    procedure SetIncludeEndOfData(const AValue: Boolean);
    procedure SetStyleName(const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Height: Integer read FHeight write SetHeight default 6;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    property StyleName: string read FStyleName write SetStyleName;
    property IncludeEndOfData: Boolean read FIncludeEndOfData write SetIncludeEndOfData default True;
  end;

  Th5uTreeOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FLevelColumnId: string;
    FBranchEndBand: Th5uTreeBranchEndBandOptions;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure ChildChanged(Sender: TObject);
    procedure SetBranchEndBand(const AValue: Th5uTreeBranchEndBandOptions);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetLevelColumnId(const AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    // May name a Column.Id, Column.FieldName or a controller field directly.
    property LevelColumnId: string read FLevelColumnId write SetLevelColumnId;
    property BranchEndBand: Th5uTreeBranchEndBandOptions read FBranchEndBand write SetBranchEndBand;
  end;

  // Optional separator after one contiguous run of equal IDs. It replaces
  // the normal RowSpacing at that boundary; it is never added to it.
  Th5uAdjacentGroupEndBandOptions = class(TPersistent)
  private
    FVisibility: Th5uAdjacentGroupEndBandVisibility;
    FHeight: Integer;
    FColor: TColor;
    FStyleName: string;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetHeight(const AValue: Integer);
    procedure SetStyleName(const AValue: string);
    procedure SetVisibility(const AValue: Th5uAdjacentGroupEndBandVisibility);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visibility: Th5uAdjacentGroupEndBandVisibility read FVisibility write SetVisibility default Th5uAdjacentGroupEndBandVisibility.Never;
    property Height: Integer read FHeight write SetHeight default 6;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    property StyleName: string read FStyleName write SetStyleName;
  end;

  // Adjacent-group folding keeps the controller's current order intact. Only
  // directly consecutive rows with equal IDs form a foldable run. A later run
  // with the same ID is deliberately independent.
  Th5uAdjacentGroupFoldingOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FIdColumnId: string;
    FInitialState: Th5uAdjacentGroupInitialState;
    FShowFoldGlyph: Boolean;
    FCaseSensitive: Boolean;
    FGroupEmptyValues: Boolean;
    FPreserveStateOnDataChange: Boolean;
    FEndBand: Th5uAdjacentGroupEndBandOptions;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure ChildChanged(Sender: TObject);
    procedure SetCaseSensitive(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetEndBand(const AValue: Th5uAdjacentGroupEndBandOptions);
    procedure SetGroupEmptyValues(const AValue: Boolean);
    procedure SetIdColumnId(const AValue: string);
    procedure SetInitialState(const AValue: Th5uAdjacentGroupInitialState);
    procedure SetPreserveStateOnDataChange(const AValue: Boolean);
    procedure SetShowFoldGlyph(const AValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    // May name a Column.Id, Column.FieldName or controller field directly.
    property IdColumnId: string read FIdColumnId write SetIdColumnId;
    property InitialState: Th5uAdjacentGroupInitialState read FInitialState write SetInitialState default Th5uAdjacentGroupInitialState.Expanded;
    property ShowFoldGlyph: Boolean read FShowFoldGlyph write SetShowFoldGlyph default True;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive default True;
    property GroupEmptyValues: Boolean read FGroupEmptyValues write SetGroupEmptyValues default True;
    property PreserveStateOnDataChange: Boolean read FPreserveStateOnDataChange write SetPreserveStateOnDataChange default True;
    property EndBand: Th5uAdjacentGroupEndBandOptions read FEndBand write SetEndBand;
  end;

  Th5uRowHeightOptions = class(TPersistent)
  private
    FMode: Th5uRowHeightMode;
    FFixedHeight: Integer;
    FMinHeight: Integer;
    FMaxHeight: Integer;
    FEstimatedHeight: Integer;
    FMeasureScope: Th5uAutoHeightMeasureScope;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetEstimatedHeight(const AValue: Integer);
    procedure SetFixedHeight(const AValue: Integer);
    procedure SetMaxHeight(const AValue: Integer);
    procedure SetMinHeight(const AValue: Integer);
    procedure SetMode(const AValue: Th5uRowHeightMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: Th5uRowHeightMode read FMode write SetMode default Th5uRowHeightMode.Fixed;
    property FixedHeight: Integer read FFixedHeight write SetFixedHeight default 24;
    property MinHeight: Integer read FMinHeight write SetMinHeight default 20;
    property MaxHeight: Integer read FMaxHeight write SetMaxHeight default 180;
    property EstimatedHeight: Integer read FEstimatedHeight write SetEstimatedHeight default 24;
    property MeasureScope: Th5uAutoHeightMeasureScope read FMeasureScope write FMeasureScope default Th5uAutoHeightMeasureScope.ExplicitContributorColumns;
  end;

  Th5uScrollingOptions = class(TPersistent)
  private
    FVerticalMode: Th5uVerticalScrollMode;
    FHorizontalMode: Th5uHorizontalScrollMode;
    FOverscanRows: Integer;
    FSnapDelay: Integer;
    FWheelRows: Integer;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property VerticalMode: Th5uVerticalScrollMode read FVerticalMode write FVerticalMode default Th5uVerticalScrollMode.Pixel;
    property HorizontalMode: Th5uHorizontalScrollMode read FHorizontalMode write FHorizontalMode default Th5uHorizontalScrollMode.Pixel;
    property OverscanRows: Integer read FOverscanRows write FOverscanRows default 2;
    property SnapDelay: Integer read FSnapDelay write FSnapDelay default 120;
    property WheelRows: Integer read FWheelRows write FWheelRows default 3;
  end;

  Th5uScrollHintOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FTriggers: Th5uScrollHintTriggers;
    FVerticalColumnId: string;
    FShowRowPosition: Boolean;
    FUseHeaderPath: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Triggers: Th5uScrollHintTriggers read FTriggers write FTriggers;
    property VerticalColumnId: string read FVerticalColumnId write FVerticalColumnId;
    property ShowRowPosition: Boolean read FShowRowPosition write FShowRowPosition default True;
    property UseHeaderPath: Boolean read FUseHeaderPath write FUseHeaderPath default True;
  end;

  Th5uPaginationOptions = class(TPersistent)
  private
    FMode: Th5uPaginationMode;
    FPageSize: Integer;
    FPageIndex: Integer;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetPageIndex(const AValue: Integer);
    procedure SetPageSize(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: Th5uPaginationMode read FMode write FMode default Th5uPaginationMode.Continuous;
    property PageSize: Integer read FPageSize write SetPageSize default 100;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 0;
  end;

  Th5uCacheOptions = class(TPersistent)
  private
    FMode: Th5uCacheMode;
    FPageSize: Integer;
    FMaxCachedPages: Integer;
    FPrefetchPagesBefore: Integer;
    FPrefetchPagesAfter: Integer;
    FMaxMemoryBytes: Int64;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: Th5uCacheMode read FMode write FMode default Th5uCacheMode.Viewport;
    property PageSize: Integer read FPageSize write FPageSize default 200;
    property MaxCachedPages: Integer read FMaxCachedPages write FMaxCachedPages default 8;
    property PrefetchPagesBefore: Integer read FPrefetchPagesBefore write FPrefetchPagesBefore default 1;
    property PrefetchPagesAfter: Integer read FPrefetchPagesAfter write FPrefetchPagesAfter default 2;
    property MaxMemoryBytes: Int64 read FMaxMemoryBytes write FMaxMemoryBytes;
  end;

  Th5uRowStyleOptions = class(TPersistent)
  private
    FStripePeriod: Integer;
    FStripeOffset: Integer;
    FStripeStyleName: string;
    FOddStyleName: string;
    FEvenStyleName: string;
    FStyleKeyColumnId: string;
    FMappings: Th5uRowStyleMappings;
    FRestartAtGroup: Boolean;
    FRestartAtPage: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure SetMappings(const AValue: Th5uRowStyleMappings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ResolveStyle(AViewRowIndex: Int64; AStyleKey: Integer; AHasStyleKey: Boolean): string;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property StripePeriod: Integer read FStripePeriod write FStripePeriod default 2;
    property StripeOffset: Integer read FStripeOffset write FStripeOffset default 1;
    property StripeStyleName: string read FStripeStyleName write FStripeStyleName;
    property OddStyleName: string read FOddStyleName write FOddStyleName;
    property EvenStyleName: string read FEvenStyleName write FEvenStyleName;
    property StyleKeyColumnId: string read FStyleKeyColumnId write FStyleKeyColumnId;
    property Mappings: Th5uRowStyleMappings read FMappings write SetMappings;
    property RestartAtGroup: Boolean read FRestartAtGroup write FRestartAtGroup default False;
    property RestartAtPage: Boolean read FRestartAtPage write FRestartAtPage default False;
  end;

  Th5uCustomizationOptions = class(TPersistent)
  private
    FAllowColumnMoving: Boolean;
    FAllowColumnHiding: Boolean;
    FAllowColumnResizing: Boolean;
    FShowColumnChooser: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property AllowColumnMoving: Boolean read FAllowColumnMoving write FAllowColumnMoving default True;
    property AllowColumnHiding: Boolean read FAllowColumnHiding write FAllowColumnHiding default True;
    property AllowColumnResizing: Boolean read FAllowColumnResizing write FAllowColumnResizing default True;
    property ShowColumnChooser: Boolean read FShowColumnChooser write FShowColumnChooser default True;
  end;
```

## `h5u.Grid.SampleData`

Quelle: `Source/Common/h5u.Grid.SampleData.pas`

```pascal
uses
  System.Classes,
  System.SysUtils,
  System.NetEncoding,
  Data.DB,
  Datasnap.DBClient;

type
  Th5uSampleClientDataset = class(TClientDataset)
  private
    FAutoCreateSampleData: Boolean;
    FIncludeImages: Boolean;
    FSampleRowCount: Integer;
    FUpdatingSampleData: Boolean;
    procedure SetAutoCreateSampleData(const AValue: Boolean);
    procedure SetIncludeImages(const AValue: Boolean);
    procedure SetSampleRowCount(const AValue: Integer);
    procedure BuildFieldDefs;
    procedure AppendSampleRows;
    procedure WriteSampleImage(AField: TField; AIndex: Integer);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RecreateSampleData;
    procedure EnsureSampleData;
  published
    property AutoCreateSampleData: Boolean read FAutoCreateSampleData write SetAutoCreateSampleData default True;
    property IncludeImages: Boolean read FIncludeImages write SetIncludeImages default True;
    property SampleRowCount: Integer read FSampleRowCount write SetSampleRowCount default 25;
  end;
```

## `h5u.Grid.Selection`

Quelle: `Source/Common/h5u.Grid.Selection.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  h5u.Grid.Types;

type
  Th5uSelectionChangedEvent = procedure(Sender: TObject) of object;

  Th5uGridSelection = class(TPersistent)
  private
    FAllowedKinds: Th5uSelectionKinds;
    FCombinationMode: Th5uSelectionCombinationMode;
    FScope: Th5uSelectionScope;
    FMultiRange: Boolean;
    FKeepAcrossPages: Boolean;
    FSelectedRows: TDictionary<string, Byte>;
    FSelectedColumns: TDictionary<string, Byte>;
    FCellRanges: TList<Th5uCellRange>;
    FAllRowsSelected: Boolean;
    FExcludedRows: TDictionary<string, Byte>;
    FFocusedCell: Th5uCellAddress;
    FAnchorCell: Th5uCellAddress;
    FOnChanged: Th5uSelectionChangedEvent;
    procedure Changed;
    procedure SetAllowedKinds(const AValue: Th5uSelectionKinds);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure ClearRows;
    procedure ClearColumns;
    procedure ClearCellRanges;

    procedure SelectRow(const ARowKey: Th5uRowKey; AAdd: Boolean = False);
    procedure ToggleRow(const ARowKey: Th5uRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: Th5uRowKey);
    function IsRowSelected(const ARowKey: Th5uRowKey): Boolean;

    procedure SelectColumn(const AColumnId: string; AAdd: Boolean = False);
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;

    procedure AddCellRange(const ARange: Th5uCellRange; AAdd: Boolean = False);
    function IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;

    procedure SetFocus(const ACell: Th5uCellAddress; AUpdateAnchor: Boolean);

    property CellRanges: TList<Th5uCellRange> read FCellRanges;
    property FocusedCell: Th5uCellAddress read FFocusedCell;
    property AnchorCell: Th5uCellAddress read FAnchorCell;
    property AllRowsSelected: Boolean read FAllRowsSelected;
    property OnChanged: Th5uSelectionChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowedKinds: Th5uSelectionKinds read FAllowedKinds write SetAllowedKinds;
    property CombinationMode: Th5uSelectionCombinationMode read FCombinationMode write FCombinationMode default Th5uSelectionCombinationMode.Mixed;
    property Scope: Th5uSelectionScope read FScope write FScope default Th5uSelectionScope.CurrentQuery;
    property MultiRange: Boolean read FMultiRange write FMultiRange default True;
    property KeepAcrossPages: Boolean read FKeepAcrossPages write FKeepAcrossPages default True;
  end;
```

## `h5u.Grid.Types`

Quelle: `Source/Common/h5u.Grid.Types.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Rtti,
  System.SysUtils,
  System.UITypes,
  System.Types;

type
  Th5uClassId = type string;

const
  h5uClassIdGridVisibleRow = Th5uClassId('h5u.grid.visual.row');
  h5uClassIdGridDataCell = Th5uClassId('h5u.grid.visual.cell.data');
  h5uClassIdGridHeaderCell = Th5uClassId('h5u.grid.visual.cell.header');
  h5uClassIdGridHeaderGroupCell = Th5uClassId('h5u.grid.visual.cell.header-group');
  h5uClassIdGridFixedCell = Th5uClassId('h5u.grid.visual.cell.fixed');
  h5uClassIdGridFooterCell = Th5uClassId('h5u.grid.visual.cell.footer');
  h5uClassIdGridCornerCell = Th5uClassId('h5u.grid.visual.cell.corner');
  h5uClassIdGridTextEditor = Th5uClassId('h5u.grid.editor.text');
  h5uClassIdGridBooleanEditor = Th5uClassId('h5u.grid.editor.boolean');
  h5uClassIdGridImageEditor = Th5uClassId('h5u.grid.editor.image');
  h5uClassIdGridRowMetrics = Th5uClassId('h5u.grid.row-metrics');
  h5uClassIdGridThumbHint = Th5uClassId('h5u.grid.thumb-hint');
  h5uClassIdGridRowSpacing = Th5uClassId('h5u.grid.spacing.row');
  h5uClassIdGridColumnSpacing = Th5uClassId('h5u.grid.spacing.column');
  h5uClassIdGridContentPadding = Th5uClassId('h5u.grid.spacing.content-padding');
  h5uClassIdGridTreeBranchEndBand = Th5uClassId('h5u.grid.spacing.tree-branch-end');
  h5uClassIdGridAdjacentGroupFoldGlyph = Th5uClassId('h5u.grid.visual.adjacent-group-fold-glyph');
  h5uClassIdGridAdjacentGroupEndBand = Th5uClassId('h5u.grid.spacing.adjacent-group-end');
  h5uClassIdDataSession = Th5uClassId('h5u.grid.data.session');
  h5uClassIdDataCache = Th5uClassId('h5u.grid.data.cache');
  h5uClassIdDataPage = Th5uClassId('h5u.grid.data.page');

type
  Eh5uGrid = class(Exception);
  Eh5uFactory = class(Eh5uGrid);
  Eh5uDataController = class(Eh5uGrid);

  Th5uRowKey = record
  private
    FValue: string;
  public
    class function Empty: Th5uRowKey; static;
    class function FromString(const AValue: string): Th5uRowKey; static;
    class function FromInt64(const AValue: Int64): Th5uRowKey; static;
    function IsEmpty: Boolean;
    function ToString: string;
    class operator Equal(const ALeft, ARight: Th5uRowKey): Boolean;
    class operator NotEqual(const ALeft, ARight: Th5uRowKey): Boolean;
  end;

  Th5uElementKind = (
    Grid,
    View,
    VisibleRow,
    VisibleColumn,
    DataCell,
    ColumnHeaderCell,
    ColumnHeaderGroupCell,
    RowHeaderCell,
    DataGroupHeaderCell,
    FixedCell,
    CornerCell,
    FilterCell,
    FooterCell,
    Editor,
    ThumbHint,
    RowSpacing,
    ColumnSpacing,
    ContentPadding,
    TreeBranchEndBand,
    AdjacentGroupFoldGlyph,
    AdjacentGroupEndBand,
    DetailView,
    DataSession,
    DataCache,
    DataPage
  );

  Th5uElementFlag = (
    FixedRow,
    FixedColumn,
    Frozen,
    Header,
    Footer,
    Corner,
    Selected,
    Focused,
    Hot,
    Editing,
    Disabled,
    ReadOnly,
    OddRow,
    EvenRow,
    PatternRow,
    TreeBranchEnd,
    AdjacentGroupFirst,
    AdjacentGroupLast,
    AdjacentGroupCollapsed,
    AdjacentGroupExpanded,
    AdjacentGroupEnd
  );
  Th5uElementFlags = set of Th5uElementFlag;

  Th5uCreationReason = (
    Runtime,
    Designer,
    Streaming,
    AutoGenerate,
    Clone,
    LayoutRestore,
    DetailView,
    ControllerInternal,
    ViewportMaterialization
  );

  Th5uFactoryCacheScope = (
    None,
    ClassId,
    Grid,
    View,
    ElementKind,
    Column,
    HeaderCell,
    RowStyleKey
  );

  Th5uFactoryContext = record
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

    RowKey: Th5uRowKey;
    SourceRowIndex: Int64;
    ViewRowIndex: Int64;
    RowStyleKey: TValue;
    Value: TValue;

    ElementKind: Th5uElementKind;
    ElementFlags: Th5uElementFlags;
    LayoutRow: Integer;
    LayoutColumn: Integer;
    RowSpan: Integer;
    ColumnSpan: Integer;
    TreeLevel: Integer;
    ClosedTreeLevels: Integer;

    AdjacentGroupIndex: Integer;
    AdjacentGroupId: TValue;
    AdjacentGroupAnchorRowKey: Th5uRowKey;
    AdjacentGroupRowCount: Int64;
    AdjacentGroupCollapsed: Boolean;
    AdjacentGroupFirstRow: Boolean;
    AdjacentGroupLastVisibleRow: Boolean;

    ClassId: Th5uClassId;
    CreationReason: Th5uCreationReason;

    class function Create(AGrid, AView, AController: TObject; const AClassId: Th5uClassId; AElementKind: Th5uElementKind): Th5uFactoryContext; static;
  end;

  Th5uTreeLevelContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
  end;

  Th5uGetTreeLevelEvent = procedure(Sender: TObject; const AContext: Th5uTreeLevelContext; var ALevel: Integer; var AAvailable: Boolean) of object;

  Th5uTreeBranchEndContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: Th5uRowKey;
    NextRowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    CurrentLevel: Integer;
    NextLevel: Integer;
    IsEndOfData: Boolean;
  end;

  Th5uGetTreeBranchEndEvent = procedure(Sender: TObject; const AContext: Th5uTreeBranchEndContext; var AIsBranchEnd: Boolean; var AClosedLevels: Integer) of object;

  Th5uAdjacentGroupInitialState = (
    Expanded,
    Collapsed
  );

  Th5uAdjacentGroupEndBandVisibility = (
    Never,
    CollapsedOnly,
    ExpandedOnly,
    Always
  );

  Th5uAdjacentGroupIdContext = record
    Grid: TObject;
    DataController: TObject;
    RowKey: Th5uRowKey;
    ControllerRowIndex: Int64;
    SourceRowIndex: Int64;
  end;

  Th5uGetAdjacentGroupIdEvent = procedure(Sender: TObject; const AContext: Th5uAdjacentGroupIdContext; var AGroupId: TValue; var AAvailable: Boolean) of object;

  Th5uAdjacentGroupStateChangedContext = record
    Grid: TObject;
    DataController: TObject;
    GroupId: TValue;
    AnchorRowKey: Th5uRowKey;
    FirstControllerRowIndex: Int64;
    RowCount: Int64;
    Collapsed: Boolean;
  end;

  Th5uAdjacentGroupStateChangedEvent = procedure(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext) of object;

  Th5uGridTheme = (
    ApplicationStyle,
    Classic2000,
    Modern,
    Dark
  );

  Th5uColumnDataType = (
    Auto,
    Text,
    Integer,
    Float,
    Currency,
    Date,
    DateTime,
    Boolean,
    Image
  );

  Th5uColumnEditorKind = (
    Automatic,
    None,
    Text,
    Boolean,
    Image
  );

  Th5uFixedKind = (
    None,
    Left,
    Right
  );

  Th5uRowHeightMode = (
    Fixed,
    Automatic
  );

  Th5uAutoHeightMeasureScope = (
    VisibleViewportColumns,
    AllVisibleColumns,
    ExplicitContributorColumns
  );

  Th5uVerticalScrollMode = (
    Pixel,
    WholeRows,
    PixelSnap
  );

  Th5uHorizontalScrollMode = (
    Pixel,
    WholeColumns,
    PixelSnap
  );

  Th5uScrollAxis = (
    Horizontal,
    Vertical
  );

  Th5uScrollHintTrigger = (
    ThumbTracking,
    MouseWheel,
    Keyboard,
    Touch,
    Kinetic
  );
  Th5uScrollHintTriggers = set of Th5uScrollHintTrigger;

  Th5uCacheMode = (
    None,
    Viewport,
    Paged,
    All,
    Adaptive
  );

  Th5uPaginationMode = (
    Continuous,
    NumberedPages,
    Cursor
  );

  Th5uSelectionKind = (
    Rows,
    Columns,
    CellRanges
  );
  Th5uSelectionKinds = set of Th5uSelectionKind;

  Th5uSelectionCombinationMode = (
    Exclusive,
    Mixed
  );

  Th5uSelectionScope = (
    CurrentPage,
    VisibleRows,
    CurrentQuery,
    EntireSource
  );

  Th5uDataChangeKind = (
    Reset,
    LayoutChanged,
    RowsInserted,
    RowsDeleted,
    RowsChanged,
    CellChanged,
    PageChanged
  );

  Th5uDataChange = record
    Kind: Th5uDataChangeKind;
    FirstIndex: Int64;
    Count: Int64;
    RowKey: Th5uRowKey;
    ColumnId: string;
    class function ResetAll: Th5uDataChange; static;
  end;

  Th5uCellRange = record
    StartRowIndex: Int64;
    EndRowIndex: Int64;
    StartColumnIndex: Integer;
    EndColumnIndex: Integer;
    class function Create(AStartRow, AEndRow: Int64; AStartColumn, AEndColumn: Integer): Th5uCellRange; static;
    procedure Normalize;
    function Contains(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
  end;

  Th5uCellAddress = record
    RowIndex: Int64;
    ColumnIndex: Integer;
    RowKey: Th5uRowKey;
    ColumnId: string;
    class function Empty: Th5uCellAddress; static;
    function IsValid: Boolean;
  end;

  Th5uResolvedAppearance = record
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
```

## `Vcl.h5u.Grid`

Quelle: `Source/VCL/Vcl.h5u.Grid.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
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
    FColumns: Th5uGridColumns;
    FHeaderLayout: Th5uHeaderLayout;
    FDataController: Th5uCustomDataController;
    FDataLink: Th5uDataControllerLink;
    FFactoryScope: Th5uFactoryScope;
    FSharedClassFactory: Th5uClassFactory;
    FSelection: Th5uGridSelection;

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

    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditor: TEdit;
    FEditRowIndex: Int64;
    FEditColumn: Th5uGridColumn;
    FCommittingEditor: Boolean;

    FHorizontalOffset: Integer;
    FVerticalOffset: Integer;
    FVisibleColumns: TArray<Th5uVisibleColumnInfo>;
    FAllColumns: TArray<Th5uVisibleColumnInfo>;
    FVisibleRows: TArray<Th5uVisibleRowInfo>;
    FCellPool: TObjectList<Th5uVclVisualCell>;
    FRowHeightCache: TDictionary<string, Integer>;
    FUpdatingScrollBars: Boolean;

    FMouseDownHit: Th5uHitTestInfo;
    FSelectingRange: Boolean;
    FResizingColumn: Th5uGridColumn;
    FResizeStartX: Integer;
    FResizeOriginalWidth: Integer;

    FOnGetRowHeight: Th5uGetRowHeightEvent;
    FOnGetRowSpacing: Th5uGetRowSpacingEvent;
    FOnGetThumbHint: Th5uGetThumbHintEvent;
    FOnGetRowAppearance: Th5uRowAppearanceEvent;
    FOnGetCellAppearance: Th5uCellAppearanceEvent;
    FOnCustomDraw: Th5uVclCustomDrawEvent;
    FOnGetTreeLevel: Th5uGetTreeLevelEvent;
    FOnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent;
    FOnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent;
    FOnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent;

    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
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
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCell;

    procedure DrawContentPadding;
    procedure DrawHeaders;
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
    procedure CommitEditor;
    procedure CancelEditor;
    function ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;

    procedure ShowColumnChooser;
    procedure ColumnChooserClick(Sender: TObject);
    procedure RebuildAfterLayoutChange;

    function GetVisualCellClass(const AContext: Th5uFactoryContext; ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCellClass; virtual;

    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: Th5uVclDrawContext; AStage: Th5uCustomDrawStage; var ADrawDefault: Boolean);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
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
    property OnCustomDraw: Th5uVclCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
    property OnGetTreeLevel: Th5uGetTreeLevelEvent read FOnGetTreeLevel write FOnGetTreeLevel;
    property OnGetTreeBranchEnd: Th5uGetTreeBranchEndEvent read FOnGetTreeBranchEnd write FOnGetTreeBranchEnd;
    property OnGetAdjacentGroupId: Th5uGetAdjacentGroupIdEvent read FOnGetAdjacentGroupId write FOnGetAdjacentGroupId;
    property OnAdjacentGroupStateChanged: Th5uAdjacentGroupStateChangedEvent read FOnAdjacentGroupStateChanged write FOnAdjacentGroupStateChanged;
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
```

## `Vcl.h5u.Grid.Design`

Quelle: `Source/Design/Vcl.h5u.Grid.Design.pas`

```pascal
procedure Register;
```

## `Vcl.h5u.Grid.Editors`

Quelle: `Source/VCL/Vcl.h5u.Grid.Editors.pas`

```pascal
uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls;

type
  Th5uVclImageEditForm = class(TForm)
  private
    FImage: TImage;
    FButtonPanel: TPanel;
    FLoadButton: TButton;
    FPasteButton: TButton;
    FClearButton: TButton;
    FOkButton: TButton;
    FCancelButton: TButton;
    FBytes: TBytes;
    procedure LoadClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SetBytes(const AValue: TBytes);
  public
    constructor Create(AOwner: TComponent); override;
    class function Execute(AOwner: TComponent; var ABytes: TBytes): Boolean;
  end;
```

## `Vcl.h5u.Grid.Styles`

Quelle: `Source/VCL/Vcl.h5u.Grid.Styles.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Themes,
  h5u.Grid.Types;

type
  Th5uVclPalette = record
    GridBackground: TColor;
    EmptyArea: TColor;
    CellBackground: TColor;
    CellText: TColor;
    CellBorder: TColor;
    HeaderBackground: TColor;
    HeaderText: TColor;
    FixedBackground: TColor;
    OddBackground: TColor;
    EvenBackground: TColor;
    StripeBackground: TColor;
    HighlightedColumnBackground: TColor;
    SelectedBackground: TColor;
    SelectedText: TColor;
    FocusBorder: TColor;
    ErrorBackground: TColor;
    WarningBackground: TColor;
    TreeBranchEndBackground: TColor;
    AdjacentGroupEndBackground: TColor;
    DisabledText: TColor;
    ThumbHintBackground: TColor;
    ThumbHintText: TColor;
  end;

function h5uGetVclPalette(ATheme: Th5uGridTheme): Th5uVclPalette;
function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
```
