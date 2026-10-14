# hiiGrid – öffentlicher API-Auszug

> Automatisch aus den vollständigen `interface`-Abschnitten des ausgelieferten Quellstands erzeugt. Maßgeblich bleiben die Pascal-Units.

**Erzeugt:** 12. Oktober 2026
**Version:** 0.1.4

## `Fmx.h5u.FormDesigner`

Quelle: `Source/FMX/Fmx.h5u.FormDesigner.pas`

```pascal
uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Fmx.Controls, Fmx.Types, Fmx.Layouts, Fmx.Edit, Fmx.ComboEdit,
  h5u.FormDesigner,
  h5u.Grid.Data.Objects,
  Fmx.h5u.Grid;

type
  ThiiFmxStructureModel = class(ThiiStructureModel)
  protected
    procedure CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList); override;
  end;

  ThiiStructureSelectEvent = procedure(Sender: TObject; AComponent: TComponent) of object;

  ThiiStructureView = class(TLayout)
  private
    FStructureView: ThiiFmxStructureModel;
    FObjectListController: ThiiObjectListController;
    FGrid: ThiiGrid;
    FFilterEdit: TEdit;
    FUpdating: Boolean;
    FFilterError: string;
    FLoadingRoot: TComponent;
    FLoadingRootAssigned: Boolean;
    FOnSelect: ThiiStructureSelectEvent;
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure GetNameValue(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
    function ItemAtRow(ARowIndex: Int64): ThiiStructureItem;
    function GetRootComponent: TComponent;
    procedure SetRootComponent(AValue: TComponent);
    function GetFilterText: string;
    procedure SetFilterText(const AValue: string);
    function GetResolveByOwner: Boolean;
    procedure SetResolveByOwner(AValue: Boolean);
    function GetResolveByParent: Boolean;
    procedure SetResolveByParent(AValue: Boolean);
    function GetOnLoaded: TNotifyEvent;
    procedure SetOnLoaded(AValue: TNotifyEvent);
    function GetSelectedComponent: TComponent;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    property StructureView: ThiiFmxStructureModel read FStructureView;
    property ObjectListController: ThiiObjectListController read FObjectListController;
    property Grid: ThiiGrid read FGrid;
    property FilterEdit: TEdit read FFilterEdit;
    property SelectedComponent: TComponent read GetSelectedComponent;
    property FilterError: string read FFilterError;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property RootComponent: TComponent read GetRootComponent write SetRootComponent;
    property ResolveByOwner: Boolean read GetResolveByOwner write SetResolveByOwner default True;
    property ResolveByParent: Boolean read GetResolveByParent write SetResolveByParent default True;
    property FilterText: string read GetFilterText write SetFilterText;
    property OnLoaded: TNotifyEvent read GetOnLoaded write SetOnLoaded;
    property OnSelect: ThiiStructureSelectEvent read FOnSelect write FOnSelect;
  end;

  ThiiFmxEventEditor = class(ThiiCustomGrid)
  private
  protected
  public
  published
  end;

  { Component Palette }

  Th5uFmxComponentPaletteOld = class(TComponent)
  private
    {TToolBar}
  protected
  public
  published
  end;

  ThiiFmxComponentPalette = class(TComponent)
  private
    {TListView}
  protected
  public
  published
  end;
```

## `Fmx.h5u.Grid`

Quelle: `Source/FMX/Fmx.h5u.Grid.pas`

```pascal
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

  ThiiCustomGrid = class(TStyledControl, IControl)
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
    FResizeHasMoved: Boolean;
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
    function AutoSizeColumnsAt(X, Y: Single): Boolean;
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
    function IControl.GetDesignInteractive = GetGridDesignInteractive;
    function IControl.GetCursor = GetGridCursor;
    function GetGridCursor: TCursor;
    function GetGridDesignInteractive: Boolean;
    function DesignerInteractiveAt(const APoint: TPointF): Boolean;
    function IsDesignerColumnHit(const AHit: ThiiHitTestInfo): Boolean;
    procedure SelectDesignerColumn(AColumn: ThiiGridColumn); virtual;
    procedure DesignerColumnsModified; virtual;
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
```

## `Fmx.h5u.Grid.Design`

Quelle: `Source/Design/Fmx.h5u.Grid.Design.pas`

```pascal
uses
  System.Classes, DesignIntf,
  Fmx.h5u.Grid, Fmx.h5u.PropertyEditor, Fmx.h5u.FormDesigner;

procedure Register;
```

## `Fmx.h5u.Grid.Editors`

Quelle: `Source/FMX/Fmx.h5u.Grid.Editors.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes, System.Rtti,
  System.TypInfo, System.Math, System.DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  FMX.Controls, FMX.Types, FMX.Edit, FMX.DateTimeCtrls, FMX.Pickers,
  FMX.StdCtrls, FMX.Graphics, FMX.Objects, FMX.Layouts, FMX.Dialogs;

type
  ThiiCellDateEdit = class(TDateEdit)
  protected
    function GetAdjustType: TAdjustType; override;
    procedure HandlerPickerDateTimeChanged(Sender: TObject; const ADate: TDateTime); override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiCellTimeEdit = class(TTimeEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiCellTextEdit = class(TEdit)
  protected
    function GetAdjustType: TAdjustType; override;
  public
    procedure ApplyStyleLookup; override;
  end;

  ThiiFmxEditorControlClass = class of TControl;
  ThiiFmxBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiFmxCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiFmxEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiFmxBuildEditorEvent;
    FBackground: TRectangle;
    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiFmxEditorControlClass);
    procedure ControlChanged(Sender: TObject);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  protected
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiFmxEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure UpdateBounds(const ABounds: TRectF); override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: ThiiFmxEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to DFM/FMX streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiFmxBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiFmxTextEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiFmxIntegerEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxFloatEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxCurrencyEditor = class(ThiiFmxTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiFmxDateEditor = class(ThiiFmxTextEditor)
  protected
    function DefaultControlClass: ThiiFmxEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiFmxTimeEditor = class(ThiiFmxDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiFmxDateTimeEditor = class(ThiiFmxDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiFmxCheckBoxEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiFmxImageCellEditor = class(ThiiFmxCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  private
    procedure ImageCommit(Sender: TObject);
    procedure ImageCancel(Sender: TObject);
  protected
    function DefaultControlClass: ThiiFmxEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiFmxGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiFmxCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiFmxCustomEditor;
    function AddVariant(const AName, AType: string): ThiiFmxCustomEditor;
    property Items[AIndex: Integer]: ThiiFmxCustomEditor read GetItem; default;
  end;

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
  System.UIConsts,
  System.UITypes,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  FMX.Graphics,
  h5u.Grid.Types;

type
  ThiiFmxPalette = record
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

function h5uGetFmxPalette(ATheme: ThiiGridTheme): ThiiFmxPalette;
function h5uColorToFmx(const AColor: TColor): TAlphaColor;
```

## `Fmx.h5u.PropertyEditor`

Quelle: `Source/FMX/Fmx.h5u.PropertyEditor.pas`

```pascal
uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Fmx.Controls, Fmx.Types, Fmx.Layouts, Fmx.Edit, Fmx.ComboEdit,
  h5u.PropertyEditor,
  Fmx.h5u.Grid, Fmx.h5u.Grid.Editors;

type
  // Property-editor API; canonical declarations live in the shared model unit.
  EhiiPropertyError = h5u.PropertyEditor.EhiiPropertyError;
  ThiiPropertyModel = h5u.PropertyEditor.ThiiPropertyModel;
  ThiiPropertyItem = h5u.PropertyEditor.ThiiPropertyItem;
  ThiiManualProperty = h5u.PropertyEditor.ThiiManualProperty;
  ThiiPropertySortOrder = h5u.PropertyEditor.ThiiPropertySortOrder;
  ThiiPropertyItemChangedEvent = h5u.PropertyEditor.ThiiPropertyItemChangedEvent;
  ThiiGetPropertyValueEvent = h5u.PropertyEditor.ThiiGetPropertyValueEvent;
  ThiiSetPropertyValueEvent = h5u.PropertyEditor.ThiiSetPropertyValueEvent;
  ThiiValueEditor = h5u.PropertyEditor.ThiiValueEditor;
  ThiiValueEditorClass = h5u.PropertyEditor.ThiiValueEditorClass;
  ThiiWidthValueEditor = h5u.PropertyEditor.ThiiWidthValueEditor;
  ThiiPropertyFilter = h5u.PropertyEditor.ThiiPropertyFilter;
  ThiiPropertyFilters = h5u.PropertyEditor.ThiiPropertyFilters;
  ThiiManualProperties = h5u.PropertyEditor.ThiiManualProperties;
  ThiiPropertyListController = h5u.PropertyEditor.ThiiPropertyListController;

  // The grid borrows the model's items. The model owns their lifetime and values.
  ThiiPropertyEditor = class(ThiiCustomGrid)
  private
    FPropertyEditor: ThiiPropertyModel;
    FObjectListController: ThiiPropertyListController;
    FNeedsRebind: Boolean;
    FShowGroups: Boolean;
    FGroupStates: TDictionary<Integer, Boolean>;
    procedure GroupStateChanged(Sender: TObject; const AContext: ThiiAdjacentGroupStateChangedContext);
    procedure RestoreGroupStates;
    procedure SetShowGroups(AValue: Boolean);
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure ModelItemChanged(Sender: TObject; AItem: ThiiPropertyItem);
    procedure CanEditProperty(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AAllow: Boolean);
    procedure ShowValueEditor(Sender: TObject);
    function ItemAtRow(ARowIndex: Int64): ThiiPropertyItem;
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    function GetGrid: ThiiPropertyEditor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure ResetAdjacentGroupStates; reintroduce;
    property DataObject: TObject read GetDataObject write SetDataObject;

    property ObjectListController: ThiiPropertyListController read FObjectListController;
    property Grid: ThiiPropertyEditor read GetGrid;
  published
    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property PropertyEditor: ThiiPropertyModel read FPropertyEditor;
    property ShowGroups: Boolean read FShowGroups write SetShowGroups default True;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property Columns;
    property Appearance;
    property RowHeight;
    [ThiiLegacyOption]
    property ShowHeader;
    property GridLines;
  end;
```

## `h5u.FormDesigner`

Quelle: `Source/Common/h5u.FormDesigner.pas`

```pascal
// FPC/LCL support awaits its extended RTTI implementation.
{$IFNDEF FPC}
uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Masks;

type
  TComponentEvent = procedure(Sender: TObject; Component: TComponent) of object;
  TComponentMoveEvent = procedure(Sender: TObject; Component, OldParent, NewParent: TComponent) of object;
  ThiiComponentList = TList<TComponent>;

  ThiiStructureItem = class(TPersistent)
  private
    FComponent: TComponent;
    FParent: ThiiStructureItem;
    FID: Integer;
    FImageIndex: Integer;
    FVisible: Boolean;
    function GetParentID: Integer;
    function GetLevel: Integer;
    function GetName: string;
    function GetComponentClassName: string;
  public
    property Component: TComponent read FComponent;
    property Parent: ThiiStructureItem read FParent;
    property Visible: Boolean read FVisible;
  published
    property ID: Integer read FID;
    property ParentID: Integer read GetParentID;
    property Level: Integer read GetLevel;
    property Name: string read GetName;
    property ComponentClassName: string read GetComponentClassName;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
  end;

  ThiiStructureItems = TObjectList<ThiiStructureItem>;
  Th5uStructureChangeListener = class
  public
    Changing: TNotifyEvent;
    Changed: TNotifyEvent;
  end;
  Th5uStructureChangeEvents = record
    Changing, Changed: TNotifyEvent;
  end;

  ThiiStructureModel = class(TComponent)
  public type
    TElement = ThiiStructureItem;
  private
    FAllItems: ThiiStructureItems;
    FComponentList: ThiiStructureItems;
    FListeners: TObjectList<Th5uStructureChangeListener>;
    FRootComponent: TComponent;
    FSelectedComponent: TComponent;
    FResolveByOwner: Boolean;
    FResolveByParent: Boolean;
    FFilterText: string;
    FUpdateCount: Integer;
    FNextID: Integer;
    FDestroying: Boolean;
    FReloading: Boolean;
    FOnChanging: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnLoaded: TNotifyEvent;
    FOnCleared: TNotifyEvent;
    FOnSelect: TComponentEvent;
    procedure SetRootComponent(AValue: TComponent);
    procedure SetResolveByOwner(AValue: Boolean);
    procedure SetResolveByParent(AValue: Boolean);
    procedure SetFilterText(const AValue: string);
    procedure ApplyFilter;
    procedure AppendVisibleChildren(AParent: ThiiStructureItem);
    procedure ClearItems;
    procedure AddChildren(AItem: ThiiStructureItem);
    procedure RemoveBranch(AComponent: TComponent);
    procedure NotifyListeners(AChanging: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    // Framework adapters append visual children first, then call inherited.
    procedure CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList); virtual;
    procedure DoLoaded; virtual;
    procedure DoChanging; virtual;
    procedure DoChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure Reload;
    function AddComponent(AComponent: TComponent; AParent: ThiiStructureItem = nil; AIncludeChildren: Boolean = False): ThiiStructureItem;
    function FindComponent(AComponent: TComponent): ThiiStructureItem; reintroduce;
    function FindItemByID(AID: Integer): ThiiStructureItem;
    procedure SelectComponent(AComponent: TComponent);
    procedure AddChangeListener(AChanging, AChanged: TNotifyEvent);
    procedure RemoveChangeListener(AChanging, AChanged: TNotifyEvent);
    // Treat these lists as read-only; use AddComponent to add rows in OnLoaded.
    // Rows never own the represented components.
    property ComponentList: ThiiStructureItems read FComponentList;
    property AllItems: ThiiStructureItems read FAllItems;
    property SelectedComponent: TComponent read FSelectedComponent write SelectComponent;
  published
    property RootComponent: TComponent read FRootComponent write SetRootComponent;
    property ResolveByOwner: Boolean read FResolveByOwner write SetResolveByOwner default True;
    property ResolveByParent: Boolean read FResolveByParent write SetResolveByParent default True;
    property FilterText: string read FFilterText write SetFilterText;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnCleared: TNotifyEvent read FOnCleared write FOnCleared;
    property OnSelect: TComponentEvent read FOnSelect write FOnSelect;
  end;

  // Reserved extension points from the original FormDesigner scaffolding.
  ThiiEventEditor = class(TComponent);
  ThiiComponentPalette = class(TComponent);
  ThiiFormDesigner = class(TComponent);

{$ENDIF}
```

## `h5u.Grid.AdjacentGroups`

Quelle: `Source/Common/h5u.Grid.AdjacentGroups.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Generics.Collections,
    Rtti,
    SysUtils,
    TypInfo,
    Variants,
  {$ELSE}
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
    System.TypInfo,
    System.Variants,
  {$ENDIF}
  h5u.Grid.Types;

type
  // A run represents one contiguous block of equal adjacent IDs. The same ID
  // may therefore occur in several independent runs when other rows lie in
  // between. State is keyed by the first row of the run, not by the ID alone.
  Th5uAdjacentGroupRun = record
    StateKey: string;
    ComparisonKey: string;
    GroupId: TValue;
    AnchorRowKey: ThiiRowKey;
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
    AnchorRowKey: ThiiRowKey;
    RowCount: Int64;
    Collapsed: Boolean;
    IsFirstRow: Boolean;
    IsLastSourceRow: Boolean;
    IsLastVisibleRow: Boolean;
    IsFoldable: Boolean;
    class function Empty: Th5uAdjacentGroupRowInfo; static;
  end;

  // Per-grid view map. It never changes the data controller or its order. It
  // only maps visible row indexes to the controller's current view indexes.
  Th5uAdjacentGroupMap = class
  private
    FRuns: {$IFDEF FPC}specialize {$ENDIF}TList<Th5uAdjacentGroupRun>;
    FVisibleControllerRows: {$IFDEF FPC}specialize {$ENDIF}TList<Int64>;
    FVisibleGroupIndexes: {$IFDEF FPC}specialize {$ENDIF}TList<Integer>;
    FCollapsedStates: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Boolean>;
    FActive: Boolean;
    FInitialCollapsed: Boolean;
    FCaseSensitive: Boolean;
    FGroupEmptyValues: Boolean;
    FHasPendingRun: Boolean;
    FPendingRun: Th5uAdjacentGroupRun;
    procedure FinalizePendingRun;
    procedure RebuildVisibleRows;
    function BuildComparisonKey(const AGroupId: TValue; AControllerRowIndex: Int64; AAvailable: Boolean; out AKey: string): Boolean;
    function BuildStateKey(const ARowKey: ThiiRowKey; AControllerRowIndex: Int64; const AComparisonKey: string): string;
    function GetRun(AIndex: Integer): Th5uAdjacentGroupRun;
    function GetRunCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear(AClearStates: Boolean = False);
    procedure ResetStates;
    procedure BeginBuild(AInitialState: ThiiAdjacentGroupInitialState; ACaseSensitive: Boolean; AGroupEmptyValues: Boolean);
    procedure AddRow(AControllerRowIndex: Int64; const ARowKey: ThiiRowKey; const AGroupId: TValue; AAvailable: Boolean);
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
  protected
    function GetOwner: TPersistent; override;
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
```

## `h5u.Grid.Compat`

Quelle: `Source/Common/h5u.Grid.Compat.pas`

```pascal
{$IFDEF FPC}

uses
  Rtti, SysUtils, TypInfo, Variants;

type
  // Framework-neutral storage types. The core has no LCL/widgetset dependency.
  TColor = LongInt;
  TAlphaColor = LongWord;
  TMouseButton = (mbLeft, mbRight, mbMiddle, mbExtra1, mbExtra2);
  TFontStyle = (fsBold, fsItalic, fsUnderline, fsStrikeOut);
  TFontStyles = set of TFontStyle;

  TColorRec = record
  const
    SysDefault = TColor($20000000);
    Lightgray = TColor($D3D3D3);
  end;

const
  vkPrior = $21;
  vkNext = $22;
  vkEnd = $23;
  vkHome = $24;
  vkLeft = $25;
  vkUp = $26;
  vkRight = $27;
  vkDown = $28;
  vkF2 = $71;

type
  // FPC 3.2.2 has TValue.From/IsType, but lacks Delphi's AsType/AsVariant.
  Th5uValueHelper = record helper for TValue
    generic function AsType<T>: T;
    function AsVariant: Variant;
  end;

// FPC 3.2.2 cannot construct a TValue with tkVariant. Normalize scalar variants.
function h5uValueFromVariant(const AValue: Variant): TValue;
function h5uValueAsText(const AValue: TValue): string;
function h5uGetPropertyValue(AObject: TObject; AProperty: TRttiProperty): TValue;
procedure h5uSetPropertyValue(AObject: TObject; AProperty: TRttiProperty; const AValue: TValue);

{$ELSE DELPHI}

// none

{$ENDIF}
```

## `h5u.Grid.Data.Core`

Quelle: `Source/Common/h5u.Grid.Data.Core.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    Rtti,
    SysUtils,
    TypInfo,
    Variants,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
    System.TypInfo,
    System.Variants,
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  ThiiCustomDataController = class;
  ThiiDataControllerLink = class;

  ThiiDataControllerChangedEvent = procedure(Sender: TObject; const AChange: ThiiDataChange) of object;

  ThiiDataControllerLink = class(TObject)
  private
    FController: ThiiCustomDataController;
    FOnChanged: ThiiDataControllerChangedEvent;
    procedure SetController(const AValue: ThiiCustomDataController);
  public
    destructor Destroy; override;
    procedure DataChanged(const AChange: ThiiDataChange);
    property Controller: ThiiCustomDataController read FController write SetController;
    property OnChanged: ThiiDataControllerChangedEvent read FOnChanged write FOnChanged;
  end;

  ThiiDataViewSession = class(ThiiFactoryObject)
  private
    FGrid: TObject;
    FView: TObject;
    FController: ThiiCustomDataController;
    FQueryGeneration: Int64;
  public
    constructor Create(const AContext: ThiiFactoryContext); override;
    procedure NextQueryGeneration;
    property Grid: TObject read FGrid;
    property View: TObject read FView;
    property Controller: ThiiCustomDataController read FController;
    property QueryGeneration: Int64 read FQueryGeneration;
  end;

  ThiiCustomDataController = class(TComponent)
  private
    FLinks: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiDataControllerLink>;
    FFactoryScope: ThiiFactoryScope;
    FSharedClassFactory: ThiiClassFactory;
    FCache: ThiiCacheOptions;
    FPagination: ThiiPaginationOptions;
    FEnabled: Boolean;
    FUpdateCount: Integer;
    FPendingReset: Boolean;
    procedure CacheOptionsChanged(Sender: TObject);
    procedure PaginationOptionsChanged(Sender: TObject);
    procedure SetSharedClassFactory(const AValue: ThiiClassFactory);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetSourceRowCount: Int64; virtual; abstract;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; virtual;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; virtual; abstract;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); virtual;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; virtual;
    function GetSourceDisplayText(ASourceRowIndex: Int64; const AFieldName, ADisplayFormat: string): string; virtual;
    function MapViewToSourceIndex(AViewRowIndex: Int64): Int64; virtual;

    procedure DoCacheOptionsChanged; virtual;
    procedure DoPaginationChanged; virtual;

    procedure RegisterLink(ALink: ThiiDataControllerLink);
    procedure UnregisterLink(ALink: ThiiDataControllerLink);
    procedure NotifyDataChanged(const AChange: ThiiDataChange);

    function GetDataSessionClass(const AContext: ThiiFactoryContext): TClass; virtual;

    property Links: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiDataControllerLink> read FLinks;
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
    function GetRowKey(AViewRowIndex: Int64): ThiiRowKey;
    function GetValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEdit(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetDisplayText(AViewRowIndex: Int64; const AFieldName: string; const ADisplayFormat: string = ''): string;

    function CreateSession(AGrid, AView: TObject): ThiiDataViewSession; virtual;

    property FactoryScope: ThiiFactoryScope read FFactoryScope;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property SharedClassFactory: ThiiClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Cache: ThiiCacheOptions read FCache write FCache;
    property Pagination: ThiiPaginationOptions read FPagination write FPagination;
  end;

function h5uValueToDisplayText(const AValue: TValue; const ADisplayFormat: string = ''): string;

function h5uTryValueAsInteger(const AValue: TValue; out AInteger: Integer): Boolean;
```

## `h5u.Grid.Data.Dataset`

Quelle: `Source/Common/h5u.Grid.Data.Dataset.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    Rtti,
    SysUtils,
    DB,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
    Data.DB,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  ThiiDatasetController = class;

  Th5uDatasetDataLink = class(TDataLink)
  private
    FOwner: ThiiDatasetController;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AOwner: ThiiDatasetController);
  end;

  Th5uDataRowSnapshot = class
  private
    FRowKey: ThiiRowKey;
    FValues: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
  public
    constructor Create;
    destructor Destroy; override;
    property RowKey: ThiiRowKey read FRowKey write FRowKey;
    property Values: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue> read FValues;
  end;

  ThiiDatasetController = class(ThiiCustomDataController)
  private
    FDataSource: TDataSource;
    FDataLink: Th5uDatasetDataLink;
    FKeyFieldName: string;
    FSnapshotCache: {$IFDEF FPC}specialize {$ENDIF}TObjectDictionary<Int64, Th5uDataRowSnapshot>;
    FCacheGeneration: Int64;
    FInternalReadCount: Integer;
    FInternalWriteCount: Integer;
    procedure SetDataSource(const AValue: TDataSource);
    function GetDataset: TDataset;
    function ReadFieldValue(AField: TField): TValue;
    procedure WriteFieldValue(AField: TField; const AValue: TValue);
    function CreateSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    function GetSnapshot(ASourceRowIndex: Int64): Th5uDataRowSnapshot;
    procedure ClearSnapshotCache;
    function GoToSourceRow(ASourceRowIndex: Int64; AReadOnly: Boolean = False): Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareRange(AFirstViewRow, ACount: Int64); override;
    procedure DatasetChanged(AKind: ThiiDataChangeKind; AField: TField = nil);
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
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    Rtti,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  ThiiMemoryRow = class
  private
    FKey: ThiiRowKey;
    FValues: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
  public
    constructor Create(const AKey: ThiiRowKey);
    destructor Destroy; override;
    function GetValue(const AFieldName: string): TValue;
    procedure SetValue(const AFieldName: string; const AValue: TValue);
    property Key: ThiiRowKey read FKey write FKey;
  end;

  ThiiMemoryController = class(ThiiCustomDataController)
  private
    FRows: {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiMemoryRow>;
    FNextKey: Int64;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AppendRow: ThiiMemoryRow;
    function AppendValues(const AFieldNames: array of string; const AValues: array of TValue): ThiiMemoryRow;
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    function Row(AIndex: Integer): ThiiMemoryRow;
  end;
```

## `h5u.Grid.Data.Objects`

Quelle: `Source/Common/h5u.Grid.Data.Objects.pas`

```pascal
{$SCOPEDENUMS ON}
{$IFnDEF FPC}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}
{$ENDIF}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    Math,
    Rtti,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Math,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  ThiiObjectListController = class(ThiiCustomDataController)
  private
    FItems: {$IFDEF FPC}specialize {$ENDIF}TList<TObject>;
    FOwnsObjects: Boolean;
    FKeyPropertyName: string;
    FRttiContext: TRttiContext;
    FPropertyCache: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TRttiProperty>;
    FValueCache: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
    function ResolveProperty(AObject: TObject; const APropertyName: string): TRttiProperty;
    function ReadPropertyPath(AObject: TObject; const APath: string): TValue;
    procedure WritePropertyPath(AObject: TObject; const APath: string; const AValue: TValue);
    function ValueCacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
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
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    Rtti,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

type
  ThiiVirtualGetRowCountEvent = procedure(Sender: TObject; var ARowCount: Int64) of object;
  ThiiVirtualGetRowKeyEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: ThiiRowKey) of object;
  ThiiVirtualGetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue) of object;
  ThiiVirtualSetValueEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean) of object;
  ThiiVirtualCanEditEvent = procedure(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var ACanEdit: Boolean) of object;
  ThiiVirtualPrepareRangeEvent = procedure(Sender: TObject; AFirstSourceRow, ACount: Int64; AQueryGeneration: Int64) of object;

  ThiiVirtualController = class(ThiiCustomDataController)
  private
    FOnGetRowCount: ThiiVirtualGetRowCountEvent;
    FOnGetRowKey: ThiiVirtualGetRowKeyEvent;
    FOnGetValue: ThiiVirtualGetValueEvent;
    FOnSetValue: ThiiVirtualSetValueEvent;
    FOnCanEdit: ThiiVirtualCanEditEvent;
    FOnPrepareRange: ThiiVirtualPrepareRangeEvent;
    FValueCache: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, TValue>;
    FQueryGeneration: Int64;
    function CacheKey(ASourceRowIndex: Int64; const AFieldName: string): string;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(ASourceRowIndex: Int64): ThiiRowKey; override;
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
    property OnGetRowCount: ThiiVirtualGetRowCountEvent read FOnGetRowCount write FOnGetRowCount;
    property OnGetRowKey: ThiiVirtualGetRowKeyEvent read FOnGetRowKey write FOnGetRowKey;
    property OnGetValue: ThiiVirtualGetValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiVirtualSetValueEvent read FOnSetValue write FOnSetValue;
    property OnCanEdit: ThiiVirtualCanEditEvent read FOnCanEdit write FOnCanEdit;
    property OnPrepareRange: ThiiVirtualPrepareRangeEvent read FOnPrepareRange write FOnPrepareRange;
  end;
```

## `h5u.Grid.Design`

Quelle: `Source/Design/h5u.Grid.Design.pas`

```pascal
uses
  {$IFDEF FPC}
    Classes,
    //Graphics,
    LResources,
    LazarusPackageIntf,
  {$ELSE}
    System.Classes,
    System.SysUtils,
    Imaging.pngimage,
    DesignIntf,
    DesignEditors,
    ToolsAPI,
    h5u.FormDesigner,
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Sizing,
  h5u.Grid.Data.Dataset,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData;

procedure Register;
```

## `h5u.Grid.Editors`

Quelle: `Source/Common/h5u.Grid.Editors.pas`

```pascal
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
procedure h5uUnregisterEditor(APlatform: ThiiEditorPlatform; const AEditorName: string);
function h5uCreateEditor(APlatform: ThiiEditorPlatform; const AEditorName: string; ACollection: TCollection): ThiiGridEditorItem;
function h5uResolveEditorName(AGrid: TObject; AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; ARow: Int64; ADefaults: ThiiDefaultEditors; AGetValue: Th5uGetCellValueMethod;
  out AColumnScoped: Boolean): string;
function h5uEditorCheckBounds(const ABounds: TRectF): TRectF;

procedure h5uResolveColumnWidthDefaults(AColumn: ThiiGridColumn; AOptions: ThiiColumnSizingOptions; AEditors: ThiiGridEditors; ADefaultEditors: ThiiDefaultEditors;
  AReferenceWidth, AMonitorWidth: Single);
```

## `h5u.Grid.Factory`

Quelle: `Source/Common/h5u.Grid.Factory.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    SyncObjs,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.SyncObjs,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Types;

type
  ThiiFactoryObject = class;
  ThiiFactoryObjectClass = class of ThiiFactoryObject;
  ThiiCollectionItemClass = class of TCollectionItem;
  ThiiAnyObjectClass = class of TObject;

  ThiiClassRulePredicate = {$IFnDEF FPC}reference to {$ENDIF}function(const AContext: ThiiFactoryContext): Boolean;
  ThiiGetClassEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; var AClass: TClass; var ACacheScope: ThiiFactoryCacheScope) of object;
  ThiiCreateInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstanceClass: TClass; var AInstance: TObject; var AHandled: Boolean) of object;
  ThiiConfigureInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstance: TObject) of object;
  ThiiInstanceEvent = procedure(Sender: TObject; const AContext: ThiiFactoryContext; AInstance: TObject) of object;

  ThiiFactoryObject = class(TObject)
  public
    constructor Create(const AContext: ThiiFactoryContext); virtual;
    procedure Configure(const AContext: ThiiFactoryContext); virtual;
    procedure Bind(const AContext: ThiiFactoryContext); virtual;
    procedure Unbind; virtual;
  end;

  ThiiClassRegistration = class
  private
    FClassId: ThiiClassId;
    FExpectedBaseClass: TClass;
    FImplementationClass: TClass;
    FPredicate: ThiiClassRulePredicate;
    FPriority: Integer;
    FSequence: Int64;
  public
    property ClassId: ThiiClassId read FClassId;
    property ExpectedBaseClass: TClass read FExpectedBaseClass;
    property ImplementationClass: TClass read FImplementationClass;
    property Predicate: ThiiClassRulePredicate read FPredicate;
    property Priority: Integer read FPriority;
    property Sequence: Int64 read FSequence;
  end;

  ThiiFactoryScope = class(TPersistent)
  private
    FOwner: TObject;
    FParent: ThiiFactoryScope;
    FRegistrations: {$IFDEF FPC}specialize {$ENDIF}TObjectList<ThiiClassRegistration>;
    FLock: TMultiReadExclusiveWriteSynchronizer;
    FSequence: Int64;
    FOnGetClass: ThiiGetClassEvent;
    FOnCreateInstance: ThiiCreateInstanceEvent;
    FOnConfigureInstance: ThiiConfigureInstanceEvent;
    FOnInstanceCreated: ThiiInstanceEvent;
    FOnBindInstance: ThiiInstanceEvent;
    FOnUnbindInstance: ThiiInstanceEvent;
    function FindLocalClass(const AContext: ThiiFactoryContext; AExpectedBaseClass: TClass): TClass;
    procedure ValidateClass(const AClassId: ThiiClassId; AClass, AExpectedBaseClass: TClass);
    procedure SetParent(const AValue: ThiiFactoryScope);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function RegisterClass(const AClassId: ThiiClassId; AExpectedBaseClass, AImplementationClass: TClass; APriority: Integer = 0;
      const APredicate: ThiiClassRulePredicate = nil): ThiiClassRegistration;

    procedure Unregister(ARegistration: ThiiClassRegistration);
    procedure Clear;

    function ResolveClass(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass; out ACacheScope: ThiiFactoryCacheScope): TClass;

    function CreateInstance(const AContext: ThiiFactoryContext; AExpectedBaseClass, ADefaultClass: TClass): TObject;

    procedure ConfigureInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    procedure BindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    procedure UnbindInstance(const AContext: ThiiFactoryContext; AInstance: TObject);

    property Owner: TObject read FOwner;
    property Parent: ThiiFactoryScope read FParent write SetParent;

    property OnGetClass: ThiiGetClassEvent read FOnGetClass write FOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read FOnCreateInstance write FOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read FOnConfigureInstance write FOnConfigureInstance;
    property OnInstanceCreated: ThiiInstanceEvent read FOnInstanceCreated write FOnInstanceCreated;
    property OnBindInstance: ThiiInstanceEvent read FOnBindInstance write FOnBindInstance;
    property OnUnbindInstance: ThiiInstanceEvent read FOnUnbindInstance write FOnUnbindInstance;
  end;

  ThiiClassFactory = class(TComponent)
  private
    FScope: ThiiFactoryScope;
    function GetOnGetClass: ThiiGetClassEvent;
    procedure SetOnGetClass(const AValue: ThiiGetClassEvent);
    function GetOnCreateInstance: ThiiCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: ThiiCreateInstanceEvent);
    function GetOnConfigureInstance: ThiiConfigureInstanceEvent;
    procedure SetOnConfigureInstance(const AValue: ThiiConfigureInstanceEvent);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Scope: ThiiFactoryScope read FScope;
  published
    property OnGetClass: ThiiGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
  end;

function h5uGlobalFactoryScope: ThiiFactoryScope;
```

## `h5u.Grid.Layout`

Quelle: `Source/Common/h5u.Grid.Layout.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Math,
    Generics.Collections,
  {$ELSE}
    System.Classes,
    System.Math,
    System.Generics.Collections,
  {$ENDIF}
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Sizing,
  h5u.Grid.Types,
  h5u.Grid.View;

type
  Th5uColumnLayoutInfo = record
    Column: ThiiGridColumn;
    VisibleIndex: Integer;
    Left, Right: Single;
    Visible: Boolean;
  end;

  Th5uRowSeparatorInfo = record
    Kind: ThiiElementKind;
    Height: Single;
    StyleName: string;
    TreeLevel, ClosedTreeLevels: Integer;
  end;

  Th5uRowSpacingMethod = function(ARow: Int64; const AKey: ThiiRowKey): Single of object;

// The content budget excludes the row indicator and includes column spacing.
// The fitting mode controls whether percentages or all desired widths are relative weights.
function h5uResolveColumnWidths(AColumns: ThiiGridColumns; AHeader: ThiiHeaderLayout; ADefaultSpacing: Single; AAvailableWidth: Single; AMinWidth: Single = 0;
  AMaxWidth: Single = 0; AFitMode: ThiiColumnFitMode = ThiiColumnFitMode.PercentColumns): Boolean;
function h5uColumnRightSpacing(AColumn: ThiiGridColumn; ADefault: Single): Single;
function h5uBuildColumnLayout(AColumns: ThiiGridColumns; ADefaultSpacing: Single; AViewLeft, AViewRight, AIndicatorExtent, AHorizontalOffset: Single;
  AViewHasHeight: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
procedure h5uColumnViewport(AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; ADefaultSpacing: Single; AIndicatorExtent: Single; var ALeft, ARight: Single);
function h5uHeaderHeight(ALayout: ThiiHeaderLayout; AShowHeader: Boolean; ARowHeight, ASpacing: Single): Single;
function h5uRevealOffset(AOffset, AStart, ASize, AViewportSize: Double): Double;
function h5uRowSeparator(AView: Th5uGridView; ATree: ThiiTreeOptions; AGroups: ThiiAdjacentGroupFoldingOptions; ARow: Int64; const AKey: ThiiRowKey;
  AGetSpacing: Th5uRowSpacingMethod): Th5uRowSeparatorInfo;
```

## `h5u.Grid.Moving`

Quelle: `Source/Common/h5u.Grid.Moving.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Math,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Math,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Selection,
  h5u.Grid.Types;

// Plans contain model identities only. Capture, hit testing and painting stay in the control.
type
  Th5uMoveGetRowKey = function(ARow: Int64): ThiiRowKey of object;
  Th5uMoveGetSourceRow = function(ARow: Int64): Int64 of object;
  Th5uDesignColumnSelect = procedure(AColumn: ThiiGridColumn) of object;
  Th5uDesignColumnClickObserver = procedure(AGrid: TComponent; AColumn: ThiiGridColumn; ASelect: Th5uDesignColumnSelect);

  Th5uColumnMovePlan = record
    Columns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
    HeaderCell: ThiiHeaderLayoutCell;
    Caption: string;
  end;

  Th5uRowMovePlan = record
    RowKeys: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiRowKey>;
    FirstRowIndex: Int64;
  end;

function h5uCanMoveColumn(AColumns: ThiiGridColumns; AAllowByDefault: Boolean; AColumn: ThiiGridColumn): Boolean;
function h5uDesignColumnMoveTarget(AColumns: ThiiGridColumns; ALayout: ThiiHeaderLayout; AColumn, ATarget: ThiiGridColumn; out ANewIndex: Integer): Boolean;
function h5uMoveDesignColumn(AColumns: ThiiGridColumns; ALayout: ThiiHeaderLayout; AColumn: ThiiGridColumn; ANewIndex: Integer): Boolean;
function h5uMoveGestureAllowed(AEnabled, AAltDrag: Boolean; AShift: TShiftState; ATouchWithoutAlt: Boolean = False): Boolean;
function h5uPlanColumnMove(AColumns: ThiiGridColumns; AHeaderLayout: ThiiHeaderLayout; ASelection: ThiiGridSelection; ACustomization: ThiiCustomizationOptions;
  AColumnIndex: Integer; AHeaderCell: ThiiHeaderLayoutCell; out APlan: Th5uColumnMovePlan): Boolean;
function h5uColumnMoveTarget(AColumns: ThiiGridColumns; AHeaderLayout: ThiiHeaderLayout; ACustomization: ThiiCustomizationOptions;
  const AMovingColumns: {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>; AMovingHeader: ThiiHeaderLayoutCell; ATargetColumn: ThiiGridColumn;
  ATargetIndex: Integer; ATargetHeader: ThiiHeaderLayoutCell; out ANewIndex: Integer; out AInsertAfter: Boolean): Boolean;
function h5uPlanRowMove(ASelection: ThiiGridSelection; ARowIndex, ARowCount: Int64; AGetRowKey: Th5uMoveGetRowKey; out APlan: Th5uRowMovePlan): Boolean;
function h5uRowMoveTarget(ARowCount, ATargetRowIndex: Int64; const ATargetRowKey: ThiiRowKey; AGetRowKey: Th5uMoveGetRowKey; AGetSourceRow: Th5uMoveGetSourceRow;
  var AContext: ThiiRowsMovedContext): Boolean;

var
  // Installed only by the Delphi design-time package. Native designer drags remain unhandled.
  h5uObserveDesignColumnClick: Th5uDesignColumnClickObserver;
```

## `h5u.Grid.Navigation`

Quelle: `Source/Common/h5u.Grid.Navigation.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Character,
    Classes,
    DateUtils,
    Generics.Collections,
    Math,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.DateUtils,
    System.Generics.Collections,
    System.Math,
    System.SysUtils,
    System.UITypes,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Selection,
  h5u.Grid.Types;

type
  Th5uNavigationGetRowKey = function(ARow: Int64): ThiiRowKey of object;
  Th5uNavigationRowExtent = function(ARow: Int64): Single of object;
  Th5uNavigationPrepareRange = procedure(AFirst, ACount: Int64) of object;
  Th5uNavigationGetText = function(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): string of object;
  Th5uNavigationTryFocus = function(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean): Boolean of object;

  Th5uNavigationActionKind = (None, Focus, Edit, Header);
  Th5uNavigationAction = record
    Kind: Th5uNavigationActionKind;
    Cell: ThiiCellAddress;
    Extend, Add, AutomaticEdit, EditAfterFocus: Boolean;
  end;

  // This state belongs to one grid view, independently of its shared data controller.
  Th5uGridNavigation = record
    HeaderSelectionActive: Boolean;
    HeaderSelectionKind: ThiiSelectionKind;
    HeaderAnchor, HeaderFocus: ThiiCellAddress;
    SearchText: string;
    SearchTime: TDateTime;
    procedure Cancel(ASelection: ThiiGridSelection);
    procedure SelectHeaderRange(AColumns: ThiiGridColumns; ASelection: ThiiGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; AKind: ThiiSelectionKind;
      ARow: Int64; AColumn: Integer; AShift: TShiftState);
    function Navigate(AColumns: ThiiGridColumns; ASelection: ThiiGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; ARowExtent: Th5uNavigationRowExtent;
      APageHeight: Single; AKey: Word; AShift: TShiftState; out AAction: Th5uNavigationAction): Boolean;
    function SearchCharacter(AColumns: ThiiGridColumns; ASelection: ThiiGridSelection; ARowCount: Int64; APrepareRange: Th5uNavigationPrepareRange; AGetText: Th5uNavigationGetText;
      const AText: string; ANow: TDateTime; out ARow: Int64; out AColumn: Integer): Boolean;
  end;

function h5uPlanCellFocus(AColumns: ThiiGridColumns; ASelection: ThiiGridSelection; ARowCount: Int64; AGetRowKey: Th5uNavigationGetRowKey; ARow: Int64; AColumn: Integer;
  AExtend: Boolean; out ACell: ThiiCellAddress; out ARange: ThiiCellRange): Boolean;
procedure h5uSelectRightClick(ASelection: ThiiGridSelection; const ACell: ThiiCellAddress; ACanSelect: Boolean; ATryFocus: Th5uNavigationTryFocus);
procedure h5uNotifyFocusChange(AGrid: TObject; AColumns: ThiiGridColumns; const AOld, ANew: ThiiCellAddress; AExit, AEnter: ThiiCellEvent; AChanged: TNotifyEvent);
```

## `h5u.Grid.Options`

Quelle: `Source/Common/h5u.Grid.Options.pas`

```pascal
{$SCOPEDENUMS ON}

{$IF Defined(ANDROID) or Defined(IOS)}
  {$DEFINE MOBILE}
{$ELSE}
  {$UNDEF MOBILE}
{$ENDIF}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Math,
    Classes,
    SysUtils,
  {$ELSE}
    System.Math,
    System.Classes,
    System.SysUtils,
    System.UITypes,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Sizing,
  h5u.Grid.Types;

type
  ThiiOptionsChangedEvent = procedure(Sender: TObject) of object;

  ThiiGridHeaderOptions = class(TPersistent)
  private
    FOwner: TPersistent;
    FVisible: Boolean;
    FHighlightInteractive: Boolean;
    FRowHeight: Single;
    FLayout: ThiiHeaderLayout;
    FAssigning: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure LayoutChanged(Sender: TObject);
    procedure SetLayout(const AValue: ThiiHeaderLayout);
    procedure SetRowHeight(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
    procedure SetHighlightInteractive(const AValue: Boolean);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visible: Boolean read FVisible write SetVisible default True;
    property HighlightInteractive: Boolean read FHighlightInteractive write SetHighlightInteractive default False;
    property RowHeight: Single read FRowHeight write SetRowHeight nodefault;
    property Layout: ThiiHeaderLayout read FLayout write SetLayout;
  end;

  ThiiRowIndicatorOptions = class(TPersistent)
  private
    FVisible: Boolean;
    FWidth: Single;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetVisible(const AValue: Boolean);
    procedure SetWidth(const AValue: Single);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Single read FWidth write SetWidth nodefault;
  end;

  ThiiEditingOptions = class(TPersistent)
  private
    FAllowEditing: Boolean;
    FImmediateEdit: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetAllowEditing(const AValue: Boolean);
    procedure SetImmediateEdit(const AValue: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowEditing: Boolean read FAllowEditing write SetAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write SetImmediateEdit default False;
  end;

  ThiiGridAppearanceOptions = class(TPersistent)
  private
    FTheme: ThiiGridTheme;
    FDefaultCellColor: TColor;
    FRowSpacingColor: TColor;
    FColumnSpacingColor: TColor;
    FContentPaddingColor: TColor;
    FOnChanged: ThiiOptionsChangedEvent;
    FOnThemeChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetColumnSpacingColor(const AValue: TColor);
    procedure SetContentPaddingColor(const AValue: TColor);
    procedure SetDefaultCellColor(const AValue: TColor);
    procedure SetRowSpacingColor(const AValue: TColor);
    procedure SetTheme(const AValue: ThiiGridTheme);
    procedure ThemeChanged;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
    property OnThemeChanged: ThiiOptionsChangedEvent read FOnThemeChanged write FOnThemeChanged;
  published
    property Theme: ThiiGridTheme read FTheme write SetTheme default ThiiGridTheme.ApplicationStyle;
    property DefaultCellColor: TColor read FDefaultCellColor write SetDefaultCellColor default TColorRec.SysDefault;
    property RowSpacingColor: TColor read FRowSpacingColor write SetRowSpacingColor default TColorRec.Lightgray;
    property ColumnSpacingColor: TColor read FColumnSpacingColor write SetColumnSpacingColor default TColorRec.Lightgray;
    property ContentPaddingColor: TColor read FContentPaddingColor write SetContentPaddingColor default TColorRec.Lightgray;
  end;

  // Spacing is layout geometry. A value of 1 produces the default one-pixel separator.
  // 0 disables the corresponding separator completely.
  ThiiGridSpacingOptions = class(TPersistent)
  private
    FLeft: Single;
    FTop: Single;
    FRight: Single;
    FBottom: Single;
    FRowSpacing: Single;
    FDefaultColumnRightSpacing: Single;
    FAppearance: ThiiGridAppearanceOptions;
    FRowSpacingColor: TColor;
    FColumnSpacingColor: TColor;
    FContentPaddingColor: TColor;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    function GetColumnSpacingColor: TColor;
    function GetContentPaddingColor: TColor;
    function GetRowSpacingColor: TColor;
    procedure ReadColumnSpacingColor(AReader: TReader);
    procedure ReadContentPaddingColor(AReader: TReader);
    procedure ReadRowSpacingColor(AReader: TReader);
    procedure SetBottom(const AValue: Single);
    procedure SetColumnSpacingColor(const AValue: TColor);
    procedure SetContentPaddingColor(const AValue: TColor);
    procedure SetDefaultColumnRightSpacing(const AValue: Single);
    procedure SetLeft(const AValue: Single);
    procedure SetRight(const AValue: Single);
    procedure SetRowSpacing(const AValue: Single);
    procedure SetRowSpacingColor(const AValue: TColor);
    procedure SetTop(const AValue: Single);
    procedure WriteColumnSpacingColor(AWriter: TWriter);
    procedure WriteContentPaddingColor(AWriter: TWriter);
    procedure WriteRowSpacingColor(AWriter: TWriter);
  protected
    procedure DefineProperties(AFiler: TFiler); override;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure BindAppearance(AValue: ThiiGridAppearanceOptions);
    procedure SetAllSeparators(const ASize: Single);
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
    // Source and streaming compatibility; bound grids store colors in Appearance.
    {$IFNDEF FPC}
    [ThiiLegacyOption]
    {$ENDIF}
    property RowSpacingColor: TColor read GetRowSpacingColor write SetRowSpacingColor;
    {$IFNDEF FPC}
    [ThiiLegacyOption]
    {$ENDIF}
    property ColumnSpacingColor: TColor read GetColumnSpacingColor write SetColumnSpacingColor;
    {$IFNDEF FPC}
    [ThiiLegacyOption]
    {$ENDIF}
    property ContentPaddingColor: TColor read GetContentPaddingColor write SetContentPaddingColor;
  published
    property Left: Single read FLeft write SetLeft nodefault;
    property Top: Single read FTop write SetTop nodefault;
    property Right: Single read FRight write SetRight nodefault;
    property Bottom: Single read FBottom write SetBottom nodefault;
    property RowSpacing: Single read FRowSpacing write SetRowSpacing nodefault;
    property DefaultColumnRightSpacing: Single read FDefaultColumnRightSpacing write SetDefaultColumnRightSpacing nodefault;
  end;

  // When a flattened tree leaves one or more child levels, this band replaces
  // the normal row spacing after the last visible descendant. It is never
  // added on top of RowSpacing.
  ThiiTreeBranchEndBandOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FHeight: Single;
    FColor: TColor;
    FStyleName: string;
    FIncludeEndOfData: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetHeight(const AValue: Single);
    procedure SetIncludeEndOfData(const AValue: Boolean);
    procedure SetStyleName(const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Height: Single read FHeight write SetHeight nodefault;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    property StyleName: string read FStyleName write SetStyleName;
    property IncludeEndOfData: Boolean read FIncludeEndOfData write SetIncludeEndOfData default True;
  end;

  ThiiTreeOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FLevelColumnId: string;
    FBranchEndBand: ThiiTreeBranchEndBandOptions;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure ChildChanged(Sender: TObject);
    procedure SetBranchEndBand(const AValue: ThiiTreeBranchEndBandOptions);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetLevelColumnId(const AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    // May name a Column.Id, Column.FieldName or a controller field directly.
    property LevelColumnId: string read FLevelColumnId write SetLevelColumnId;
    property BranchEndBand: ThiiTreeBranchEndBandOptions read FBranchEndBand write SetBranchEndBand;
  end;

  // Optional separator after one contiguous run of equal IDs. It replaces
  // the normal RowSpacing at that boundary. it is never added to it.
  ThiiAdjacentGroupEndBandOptions = class(TPersistent)
  private
    FVisibility: ThiiAdjacentGroupEndBandVisibility;
    FHeight: Single;
    FColor: TColor;
    FStyleName: string;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetHeight(const AValue: Single);
    procedure SetStyleName(const AValue: string);
    procedure SetVisibility(const AValue: ThiiAdjacentGroupEndBandVisibility);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visibility: ThiiAdjacentGroupEndBandVisibility read FVisibility write SetVisibility default ThiiAdjacentGroupEndBandVisibility.Never;
    property Height: Single read FHeight write SetHeight nodefault;
    property Color: TColor read FColor write SetColor default TColorRec.SysDefault;
    property StyleName: string read FStyleName write SetStyleName;
  end;

  // Adjacent-group folding keeps the controller's current order intact. Only
  // directly consecutive rows with equal IDs form a foldable run. A later run
  // with the same ID is deliberately independent.
  ThiiAdjacentGroupFoldingOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FIdColumnId: string;
    FInitialState: ThiiAdjacentGroupInitialState;
    FShowFoldGlyph: Boolean;
    FCaseSensitive: Boolean;
    FGroupEmptyValues: Boolean;
    FPreserveStateOnDataChange: Boolean;
    FEndBand: ThiiAdjacentGroupEndBandOptions;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure ChildChanged(Sender: TObject);
    procedure SetCaseSensitive(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetEndBand(const AValue: ThiiAdjacentGroupEndBandOptions);
    procedure SetGroupEmptyValues(const AValue: Boolean);
    procedure SetIdColumnId(const AValue: string);
    procedure SetInitialState(const AValue: ThiiAdjacentGroupInitialState);
    procedure SetPreserveStateOnDataChange(const AValue: Boolean);
    procedure SetShowFoldGlyph(const AValue: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    // May name a Column.Id, Column.FieldName or controller field directly.
    property IdColumnId: string read FIdColumnId write SetIdColumnId;
    property InitialState: ThiiAdjacentGroupInitialState read FInitialState write SetInitialState default ThiiAdjacentGroupInitialState.Expanded;
    property ShowFoldGlyph: Boolean read FShowFoldGlyph write SetShowFoldGlyph default True;
    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive default True;
    property GroupEmptyValues: Boolean read FGroupEmptyValues write SetGroupEmptyValues default True;
    property PreserveStateOnDataChange: Boolean read FPreserveStateOnDataChange write SetPreserveStateOnDataChange default True;
    property EndBand: ThiiAdjacentGroupEndBandOptions read FEndBand write SetEndBand;
  end;

  ThiiRowHeightOptions = class(TPersistent)
  private
    FMode: ThiiRowHeightMode;
    FFixedHeight: Single;
    FMinHeight: Single;
    FMaxHeight: Single;
    FEstimatedHeight: Single;
    FMeasureScope: ThiiAutoHeightMeasureScope;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetEstimatedHeight(const AValue: Single);
    procedure SetFixedHeight(const AValue: Single);
    procedure SetMaxHeight(const AValue: Single);
    procedure SetMinHeight(const AValue: Single);
    procedure SetMode(const AValue: ThiiRowHeightMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: ThiiRowHeightMode read FMode write SetMode default ThiiRowHeightMode.Fixed;
    property FixedHeight: Single read FFixedHeight write SetFixedHeight nodefault;
    property MinHeight: Single read FMinHeight write SetMinHeight nodefault;
    property MaxHeight: Single read FMaxHeight write SetMaxHeight nodefault;
    property EstimatedHeight: Single read FEstimatedHeight write SetEstimatedHeight nodefault;
    property MeasureScope: ThiiAutoHeightMeasureScope read FMeasureScope write FMeasureScope default ThiiAutoHeightMeasureScope.ExplicitContributorColumns;
  end;

  ThiiScrollingOptions = class(TPersistent)
  private
    FVerticalMode: ThiiVerticalScrollMode;
    FHorizontalMode: ThiiHorizontalScrollMode;
    FOverscanRows: Integer;
    FSnapDelay: Integer;
    FWheelRows: Integer;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property VerticalMode: ThiiVerticalScrollMode read FVerticalMode write FVerticalMode default ThiiVerticalScrollMode.Pixel;
    property HorizontalMode: ThiiHorizontalScrollMode read FHorizontalMode write FHorizontalMode default ThiiHorizontalScrollMode.Pixel;
    property OverscanRows: Integer read FOverscanRows write FOverscanRows default 2;
    property SnapDelay: Integer read FSnapDelay write FSnapDelay default 120;
    property WheelRows: Integer read FWheelRows write FWheelRows default 3;
  end;

  ThiiScrollHintOptions = class(TPersistent)
  private const
    cDefaultTriggers = [ThiiScrollHintTrigger.ThumbTracking {.$IFnDEF MOBILE}, ThiiScrollHintTrigger.MouseWheel{.$ENDIF}];
  private
    FEnabled: Boolean;
    FTriggers: ThiiScrollHintTriggers;
    FVerticalColumnId: string;
    FShowRowPosition: Boolean;
    FUseHeaderPath: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Triggers: ThiiScrollHintTriggers read FTriggers write FTriggers default cDefaultTriggers;
    property VerticalColumnId: string read FVerticalColumnId write FVerticalColumnId;
    property ShowRowPosition: Boolean read FShowRowPosition write FShowRowPosition default True;
    property UseHeaderPath: Boolean read FUseHeaderPath write FUseHeaderPath default True;
  end;

  ThiiPaginationOptions = class(TPersistent)
  private
    FMode: ThiiPaginationMode;
    FPageSize: Integer;
    FPageIndex: Integer;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure SetPageIndex(const AValue: Integer);
    procedure SetPageSize(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: ThiiPaginationMode read FMode write FMode default ThiiPaginationMode.Continuous;
    property PageSize: Integer read FPageSize write SetPageSize default 100;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 0;
  end;

  ThiiCacheOptions = class(TPersistent)
  private
    FMode: ThiiCacheMode;
    FPageSize: Integer;
    FMaxCachedPages: Integer;
    FPrefetchPagesBefore: Integer;
    FPrefetchPagesAfter: Integer;
    FMaxMemoryBytes: Int64;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: ThiiCacheMode read FMode write FMode default ThiiCacheMode.Viewport;
    property PageSize: Integer read FPageSize write FPageSize default 200;
    property MaxCachedPages: Integer read FMaxCachedPages write FMaxCachedPages default 8;
    property PrefetchPagesBefore: Integer read FPrefetchPagesBefore write FPrefetchPagesBefore default 1;
    property PrefetchPagesAfter: Integer read FPrefetchPagesAfter write FPrefetchPagesAfter default 2;
    property MaxMemoryBytes: Int64 read FMaxMemoryBytes write FMaxMemoryBytes;
  end;

  ThiiRowStyleOptions = class(TPersistent)
  private
    FStripePeriod: Integer;
    FStripeOffset: Integer;
    FStripeStyleName: string;
    FOddStyleName: string;
    FEvenStyleName: string;
    FStyleKeyColumnId: string;
    FMappings: ThiiRowStyleMappings;
    FRestartAtGroup: Boolean;
    FRestartAtPage: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure SetMappings(const AValue: ThiiRowStyleMappings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function ResolveStyle(AViewRowIndex: Int64; AStyleKey: Integer; AHasStyleKey: Boolean): string;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property StripePeriod: Integer read FStripePeriod write FStripePeriod default 2;
    property StripeOffset: Integer read FStripeOffset write FStripeOffset default 1;
    {$IFnDEF FPC} [Default('Stripe')] {$ENDIF}
    property StripeStyleName: string read FStripeStyleName write FStripeStyleName;
    {$IFnDEF FPC} [Default('Odd')] {$ENDIF}
    property OddStyleName: string read FOddStyleName write FOddStyleName;
    {$IFnDEF FPC} [Default('Even')] {$ENDIF}
    property EvenStyleName: string read FEvenStyleName write FEvenStyleName;
    property StyleKeyColumnId: string read FStyleKeyColumnId write FStyleKeyColumnId;
    property Mappings: ThiiRowStyleMappings read FMappings write SetMappings;
    property RestartAtGroup: Boolean read FRestartAtGroup write FRestartAtGroup default False;
    property RestartAtPage: Boolean read FRestartAtPage write FRestartAtPage default False;
  end;

  ThiiCustomizationOptions = class(TPersistent)
  private
    FAllowColumnMoving: Boolean;
    FColumnMovingGesture: ThiiColumnRowMovingGesture;
    FAllowRowMoving: Boolean;
    FRowMovingGesture: ThiiColumnRowMovingGesture;
    FAllowColumnHiding: Boolean;
    FAllowColumnResizing: Boolean;
    FShowColumnChooser: Boolean;
    FLastColumnResizeHitZoneLeft: Single;
    FTouchLastColumnResizeHitZoneLeft: Single;
    FColumnResizeHitZoneLeft: Single;
    FColumnResizeHitZoneRight: Single;
    FTouchColumnResizeHitZoneLeft: Single;
    FTouchColumnResizeHitZoneRight: Single;
    procedure SetLastColumnResizeHitZoneLeft(const AValue: Single);
    procedure SetTouchLastColumnResizeHitZoneLeft(const AValue: Single);
    procedure SetColumnResizeHitZoneLeft(const AValue: Single);
    procedure SetColumnResizeHitZoneRight(const AValue: Single);
    procedure SetTouchColumnResizeHitZoneLeft(const AValue: Single);
    procedure SetTouchColumnResizeHitZoneRight(const AValue: Single);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property AllowColumnMoving: Boolean read FAllowColumnMoving write FAllowColumnMoving default True;
    property AllowRowMoving: Boolean read FAllowRowMoving write FAllowRowMoving default True;
    property RowMovingGesture: ThiiColumnRowMovingGesture read FRowMovingGesture write FRowMovingGesture default ThiiColumnRowMovingGesture.Drag;
    property ColumnMovingGesture: ThiiColumnRowMovingGesture read FColumnMovingGesture write FColumnMovingGesture default ThiiColumnRowMovingGesture.Drag;
    property AllowColumnHiding: Boolean read FAllowColumnHiding write FAllowColumnHiding default True;
    property AllowColumnResizing: Boolean read FAllowColumnResizing write FAllowColumnResizing default True;
    property ColumnResizeHitZoneLeft: Single read FColumnResizeHitZoneLeft write SetColumnResizeHitZoneLeft nodefault;
    property ColumnResizeHitZoneRight: Single read FColumnResizeHitZoneRight write SetColumnResizeHitZoneRight nodefault;
    property TouchColumnResizeHitZoneLeft: Single read FTouchColumnResizeHitZoneLeft write SetTouchColumnResizeHitZoneLeft nodefault;
    property TouchColumnResizeHitZoneRight: Single read FTouchColumnResizeHitZoneRight write SetTouchColumnResizeHitZoneRight nodefault;
    property LastColumnResizeHitZoneLeft: Single read FLastColumnResizeHitZoneLeft write SetLastColumnResizeHitZoneLeft nodefault;
    property TouchLastColumnResizeHitZoneLeft: Single read FTouchLastColumnResizeHitZoneLeft write SetTouchLastColumnResizeHitZoneLeft nodefault;
    property ShowColumnChooser: Boolean read FShowColumnChooser write FShowColumnChooser default True;
  end;
```

## `h5u.Grid.Resizing`

Quelle: `Source/Common/h5u.Grid.Resizing.pas`

```pascal
uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Math,
  {$ELSE}
    System.Classes,
    System.Math,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Selection;

type
  Th5uResizeCandidate = record
    Column: ThiiGridColumn;
    VisibleIndex: Integer;
    Right, ViewLeft, ViewRight: Single;
  end;

  Th5uResizeHeaderEdgeTest = function(AX, AY: Single): Boolean of object;

function h5uColumnResizeAt(AOptions: ThiiCustomizationOptions; const ACandidates: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uResizeCandidate>;
  ALastVisibleIndex: Integer; X, Y: Single; ATouch: Boolean; AHeaderEdge: Th5uResizeHeaderEdgeTest): ThiiGridColumn;
function h5uTryResizeColumn(AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; AOriginalWidth, ADelta: Single): Boolean; overload;
function h5uTryResizeColumn(AColumns: ThiiGridColumns; AColumn: ThiiGridColumn; AOriginalWidth, ADelta: Single; out AChanged: Boolean): Boolean; overload;
function h5uAutoSizeColumnTargets(AColumns: ThiiGridColumns; ASelection: ThiiGridSelection;
  AColumn: ThiiGridColumn): {$IFDEF FPC}specialize {$ENDIF}TArray<ThiiGridColumn>;
```

## `h5u.Grid.RowMetrics`

Quelle: `Source/Common/h5u.Grid.RowMetrics.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Generics.Collections,
    Math,
    SysUtils,
  {$ELSE}
    System.Generics.Collections,
    System.Math,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Sizing,
  h5u.Grid.Types;

const
  h5uExactRowHeightLimit = 5000;

type
  Th5uMeasureCellHeight = function(ARow: Int64; AColumn: ThiiGridColumn): Single of object;
  Th5uAdjustRowHeight = procedure(ARow: Int64; const AKey: ThiiRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean) of object;
  Th5uGetRowExtent = function(ARow: Int64; AAllowMeasure: Boolean): Single of object;
  Th5uPrepareMetricRange = procedure(AFirst, ACount: Int64) of object;

  // Large integer estimates retain Int64 precision; fractional measured heights remain available to FMX.
  Th5uTotalRowHeight = record
    Whole: Int64;
    Fraction: Double;
    function AsFloat: Double;
  end;

  Th5uRowExtentNode = class
    Row: Int64;
    Delta, Sum: Double;
    Height: Integer;
    Left, Right: Th5uRowExtentNode;
  end;

  Th5uGridRowMetrics = class
  private
    FHeights: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Single>;
    FRowsByKey: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Int64>;
    FRoot: Th5uRowExtentNode;
    FRowCount: Int64;
    FEstimatedExtent: Single;
    FPixelAligned: Boolean;
    FExtentCount: Integer;
    FConfigured, FExact, FExactReady, FPreparing: Boolean;
    FHasUncachedHeights, FDynamicSpacing: Boolean;
    FPrepare: Th5uPrepareMetricRange;
    FExtent: Th5uGetRowExtent;
    FColumnWidths: string;
    procedure EnsureExact;
    procedure SetPixelAligned(AValue: Boolean);
    function EstimatedTop(ARow: Int64; ADelta: Double): Th5uTotalRowHeight;
    function LocateOffset(const AOffset: Th5uTotalRowHeight; out ARowTop: Th5uTotalRowHeight): Int64;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Remove(const AKey: string);
    procedure Configure(AOptions: ThiiRowHeightOptions; ARowCount: Int64; ASpacing: Single; AVariableSpacing: Boolean; APrepare: Th5uPrepareMetricRange; AExtent: Th5uGetRowExtent;
      ADynamicSpacing: Boolean = False);
    procedure RecordExtent(ARow: Int64; AExtent: Single);
    procedure InvalidateExtents;
    procedure InvalidateRow(ARow: Int64);
    function CheckColumnWidths(AColumns: ThiiGridColumns): Boolean;
    function RowTop(ARow: Int64): Th5uTotalRowHeight;
    function Total(AAllowMeasure: Boolean = True): Th5uTotalRowHeight;
    function FindFirstVisibleRow(AOffset: Int64; AViewportTop: Integer; out ATop: Integer): Int64; overload;
    function FindFirstVisibleRow(AOffset: Double; AViewportTop: Single; out ATop: Single): Int64; overload;
    function GetHeight(AOptions: ThiiRowHeightOptions; AColumns: ThiiGridColumns; ARow: Int64; const AKey: ThiiRowKey; AAllowMeasure: Boolean; AMeasure: Th5uMeasureCellHeight;
      AAdjust: Th5uAdjustRowHeight): Single;
    property ExtentCount: Integer read FExtentCount;
    property PixelAligned: Boolean read FPixelAligned write SetPixelAligned;
  end;

function h5uFindFirstVisibleRow(ARowCount, AOffset: Int64; AViewportTop: Integer; AExtent: Th5uGetRowExtent; out ATop: Integer): Int64; overload;
function h5uFindFirstVisibleRow(ARowCount: Int64; AOffset: Double; AViewportTop: Single; AExtent: Th5uGetRowExtent; out ATop: Single): Int64; overload;
function h5uTotalRowHeight(AOptions: ThiiRowHeightOptions; ARowCount: Int64; ASpacing: Single; AVariableSpacing: Boolean; APrepare: Th5uPrepareMetricRange;
  AExtent: Th5uGetRowExtent; AWholePixels: Boolean = False): Th5uTotalRowHeight;
function h5uRowTop(ARow: Int64; AExtent: Th5uGetRowExtent): Double;
```

## `h5u.Grid.SampleData`

Quelle: `Source/Design/h5u.Grid.SampleData.pas`

```pascal
uses
  {$IFDEF FPC}
    //h5u.Grid.Compat,
    Classes,
    SysUtils,
    base64,
    DB,
    BufDataset;
  {$ELSE}
    System.Classes,
    System.SysUtils,
    System.NetEncoding,
    Data.DB,
    Datasnap.DBClient;
  {$ENDIF}

type
  ThiiSampleClientDataset = class({$IFDEF FPC}TBufDataset{$ELSE}TClientDataset{$ENDIF})
  private
    FAutoCreateSampleData: Boolean;
    FIncludeImages: Boolean;
    FSampleRowCount: Integer;
    FUpdatingSampleData: Boolean;
    FRecreateAfterLoading: Boolean;
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
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Classes,
    Generics.Collections,
    SysUtils,
  {$ELSE}
    System.Classes,
    System.Generics.Collections,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.Types;

type
  ThiiSelectionChangedEvent = procedure(Sender: TObject) of object;

  ThiiGridSelection = class(TPersistent)
  private
    FAllowedKinds: ThiiSelectionKinds;
    FCombinationMode: ThiiSelectionCombinationMode;
    FScope: ThiiSelectionScope;
    FMultiRange: Boolean;
    FRightClickSelect: Boolean;
    FKeepAcrossPages: Boolean;
    FSelectedRows: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FSelectedColumns: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FCellRanges: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiCellRange>;
    FAllRowsSelected: Boolean;
    FExcludedRows: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Byte>;
    FFocusedCell: ThiiCellAddress;
    FAnchorCell: ThiiCellAddress;
    FExtensionBase: ThiiGridSelection;
    FExtensionKind: ThiiSelectionKind;
    FExtensionAdd: Boolean;
    FOnChanged: ThiiSelectionChangedEvent;
    function GetSelectedColumnCount: Integer;
    procedure ResetExtension;
    procedure CopySelection(ASource: ThiiGridSelection);
    procedure PrepareSelection(AKind: ThiiSelectionKind; AAdd, AExtend: Boolean);
    procedure Changed;
    procedure SetAllowedKinds(const AValue: ThiiSelectionKinds);
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create;
    destructor Destroy; override;

    function SelectedRowCount(ATotalRowCount: Int64): Int64;
    property SelectedColumnCount: Integer read GetSelectedColumnCount;
    procedure Clear;
    procedure ClearExtendedSelection;
    procedure ClearRows;
    procedure ClearColumns;
    procedure ClearCellRanges;

    procedure SelectRow(const ARowKey: ThiiRowKey; AAdd: Boolean = False);
    procedure SelectRows(const ARowKeys: array of ThiiRowKey; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleRow(const ARowKey: ThiiRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: ThiiRowKey);
    function IsRowSelected(const ARowKey: ThiiRowKey): Boolean;

    procedure SelectColumn(const AColumnId: string; AAdd: Boolean = False);
    procedure SelectColumns(const AColumnIds: array of string; AAdd: Boolean = False; AExtend: Boolean = False);
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;

    procedure AddCellRange(const ARange: ThiiCellRange; AAdd: Boolean = False; AExtend: Boolean = False);
    function IsCellSelected(ARowIndex: Int64; AColumnIndex: Integer): Boolean;

    procedure SetFocus(const ACell: ThiiCellAddress; AUpdateAnchor: Boolean);

    property CellRanges: {$IFDEF FPC}specialize {$ENDIF}TList<ThiiCellRange> read FCellRanges;
    property FocusedCell: ThiiCellAddress read FFocusedCell;
    property AnchorCell: ThiiCellAddress read FAnchorCell;
    property AllRowsSelected: Boolean read FAllRowsSelected;
    property OnChanged: ThiiSelectionChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowedKinds: ThiiSelectionKinds read FAllowedKinds write SetAllowedKinds;
    property CombinationMode: ThiiSelectionCombinationMode read FCombinationMode write FCombinationMode default ThiiSelectionCombinationMode.Mixed;
    property Scope: ThiiSelectionScope read FScope write FScope default ThiiSelectionScope.CurrentQuery;
    property RightClickSelect: Boolean read FRightClickSelect write FRightClickSelect default False;
    property MultiRange: Boolean read FMultiRange write FMultiRange default True;
    property KeepAcrossPages: Boolean read FKeepAcrossPages write FKeepAcrossPages default True;
  end;
```

## `h5u.Grid.Sizing`

Quelle: `Source/Common/h5u.Grid.Sizing.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    Classes,
    Math,
    SysUtils;
  {$ELSE}
    System.Classes,
    System.Math,
    System.SysUtils;
  {$ENDIF}

type
  ThiiWidth = type Single;
  ThiiColumnFitMode = (None, PercentColumns, AllColumns);
  ThiiMaxWidthSource = (Default, Monitor);

  ThiiColumnSizingOptions = class(TPersistent)
  private
    FDefaultWidth: ThiiWidth;
    FDefaultMinWidth: Single;
    FDefaultMaxWidth: ThiiWidth;
    FMaxWidthSource: ThiiMaxWidthSource;
    FAutoWidthRowLimit: Integer;
    FMinContentWidth: Single;
    FMaxContentWidth: Single;
    FFitMode: ThiiColumnFitMode;
    FOnChanged: TNotifyEvent;
    procedure Changed;
    procedure SetDefaultWidth(AValue: ThiiWidth);
    procedure SetDefaultMinWidth(AValue: Single);
    procedure SetDefaultMaxWidth(AValue: ThiiWidth);
    procedure SetMaxWidthSource(AValue: ThiiMaxWidthSource);
    procedure SetAutoWidthRowLimit(AValue: Integer);
    procedure SetMinContentWidth(AValue: Single);
    procedure SetMaxContentWidth(AValue: Single);
    procedure SetFitMode(AValue: ThiiColumnFitMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property DefaultWidth: ThiiWidth read FDefaultWidth write SetDefaultWidth;
    property DefaultMinWidth: Single read FDefaultMinWidth write SetDefaultMinWidth;
    property DefaultMaxWidth: ThiiWidth read FDefaultMaxWidth write SetDefaultMaxWidth;
    property MaxWidthSource: ThiiMaxWidthSource read FMaxWidthSource write SetMaxWidthSource default ThiiMaxWidthSource.Default;
    property AutoWidthRowLimit: Integer read FAutoWidthRowLimit write SetAutoWidthRowLimit default 1000;
    property MinContentWidth: Single read FMinContentWidth write SetMinContentWidth;
    property MaxContentWidth: Single read FMaxContentWidth write SetMaxContentWidth;
    property FitMode: ThiiColumnFitMode read FFitMode write SetFitMode default ThiiColumnFitMode.PercentColumns;
  end;

const
  h5uUnlimitedWidth: Single = 536870912;

procedure h5uValidateWidth(AValue: Single);
function h5uResolveWidth(AValue, AReferenceWidth: Single): Single;
function h5uWidthToText(AValue: ThiiWidth): string;
function h5uTryTextToWidth(const AText: string; out AValue: ThiiWidth): Boolean;
```

## `h5u.Grid.Types`

Quelle: `Source/Common/h5u.Grid.Types.pas`

```pascal
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
  {$IFNDEF FPC}
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
```

## `h5u.Grid.Values`

Quelle: `Source/Common/h5u.Grid.Values.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Rtti,
    SysUtils,
    TypInfo,
  {$ELSE}
    System.Rtti,
    System.SysUtils,
    System.TypInfo,
  {$ENDIF}
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Types;

// Value conversion and cell-event precedence shared by all control adapters.
type
  Th5uGetCellValueMethod = function(AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean): TValue of object;
  Th5uGetViewValueMethod = function(ARow: Int64; const AFieldName: string): TValue of object;
  Th5uGetViewTextMethod = function(ARow: Int64; const AFieldName, ADisplayFormat: string): string of object;

function h5uParseEditorValue(ADataType: ThiiColumnDataType; const AText: string): TValue;
function h5uColumnMode(AColumn: ThiiGridColumn; AController: TObject; const ATreeColumnId, AGroupColumnId, AStyleColumnId, AHintColumnId: string): string;
function h5uColumnModeSymbols(const AMode: string): string;
function h5uCellPermission(AGrid: TObject; AColumn: ThiiGridColumn; ARow: Int64; AAllow: Boolean; AColumnEvent, AGridEvent: ThiiCellPermissionEvent): Boolean;
procedure h5uOverrideCellValue(AGrid: TObject; AColumn: ThiiGridColumn; ARow: Int64; ADisplay: Boolean; AGridEvent: ThiiCellGetValueEvent; var AValue: TValue);
function h5uCellText(AColumn: ThiiGridColumn; ARow: Int64; ADisplay, AHasValueEvent: Boolean; AGetCellValue: Th5uGetCellValueMethod; AGetViewValue: Th5uGetViewValueMethod;
  AGetViewText: Th5uGetViewTextMethod): string;
function h5uPrepareCellValue(AGrid: TObject; AColumn: ThiiGridColumn; ARow: Int64; const AValue: TValue; AValidate: ThiiCellValidateEvent;
  ASetValue: ThiiCellSetValueEvent): TValue;
procedure h5uNotifyCellClick(AGrid: TObject; AColumn: ThiiGridColumn; ARow: Int64; AHeader, AIndicator: Boolean; ACellClick, AHeaderClick, AIndicatorClick: ThiiCellEvent);
```

## `h5u.Grid.View`

Quelle: `Source/Common/h5u.Grid.View.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    h5u.Grid.Compat,
    Generics.Collections,
    Math,
    Rtti,
    SysUtils,
  {$ELSE}
    System.Generics.Collections,
    System.Math,
    System.Rtti,
    System.SysUtils,
  {$ENDIF}
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Factory,
  h5u.Grid.Options,
  h5u.Grid.Types;

type
  Th5uViewGetController = function: ThiiCustomDataController of object;

  // Nonvisual, per-grid row mapping. The data controller can be shared by other views.
  // Columns and options remain owned by the native component for streaming and factories.
  Th5uGridView = class
  private
    FGrid: TObject;
    FGetController: Th5uViewGetController;
    FColumns: ThiiGridColumns;
    FTree: ThiiTreeOptions;
    FAdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions;
    FAdjacentGroupMap: Th5uAdjacentGroupMap;
    FAdjacentGroupMapDirty: Boolean;
    FOnGetAdjacentGroupId: ThiiGetAdjacentGroupIdEvent;
    FOnGetTreeLevel: ThiiGetTreeLevelEvent;
    FOnGetTreeBranchEnd: ThiiGetTreeBranchEndEvent;
    FOnAdjacentGroupStateChanged: ThiiAdjacentGroupStateChangedEvent;
    function GetDataController: ThiiCustomDataController;
  public
    constructor Create(AGrid: TObject; AColumns: ThiiGridColumns; ATree: ThiiTreeOptions; AAdjacentGroups: ThiiAdjacentGroupFoldingOptions; AGetController: Th5uViewGetController);
    destructor Destroy; override;
    property DataController: ThiiCustomDataController read GetDataController;
    procedure InvalidateAdjacentGroupMap(AClearStates: Boolean);
    procedure EnsureAdjacentGroupMap;
    function ResolveAdjacentGroupFieldName: string;
    function TryGetAdjacentGroupIdForControllerRow(AControllerRowIndex: Int64; out AGroupId: TValue): Boolean;
    function GetViewRowCount: Int64;
    function MapViewToControllerRowIndex(AViewRowIndex: Int64; AAllowLookAhead: Boolean = False): Int64;
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
    function GetViewRowKey(AViewRowIndex: Int64): ThiiRowKey;
    function GetViewValue(AViewRowIndex: Int64; const AFieldName: string): TValue;
    procedure SetViewValue(AViewRowIndex: Int64; const AFieldName: string; const AValue: TValue);
    function CanEditViewValue(AViewRowIndex: Int64; const AFieldName: string): Boolean;
    function GetViewDisplayText(AViewRowIndex: Int64; const AFieldName, ADisplayFormat: string): string;
    function IsViewRowAvailable(AViewRowIndex: Int64): Boolean;
    procedure PrepareViewRange(AFirstViewRow, ACount: Int64);
    function TryGetAdjacentGroupRowInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure PopulateAdjacentGroupContext(var AContext: ThiiFactoryContext; AViewRowIndex: Int64);
    function GetAdjacentGroupEndBandInfo(AViewRowIndex: Int64; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    procedure DoAdjacentGroupStateChanged(const AInfo: Th5uAdjacentGroupRowInfo);
    function TryGetTreeLevelFor(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out ALevel: Integer): Boolean;
    function GetTreeBranchEndInfo(AViewRowIndex: Int64; const ARowKey: ThiiRowKey; out ATreeLevel: Integer; out AClosedTreeLevels: Integer): Boolean;
    function IsAdjacentGroupCollapsed(AViewRowIndex: Int64): Boolean;
    function ChangeAdjacentGroup(AViewRowIndex: Int64; AToggle, ACollapsed: Boolean; out AInfo: Th5uAdjacentGroupRowInfo): Boolean;
    function ChangeAllAdjacentGroups(ACollapsed: Boolean): {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uAdjacentGroupRowInfo>;
    procedure ResetAdjacentGroupStates;
    property OnGetAdjacentGroupId: ThiiGetAdjacentGroupIdEvent read FOnGetAdjacentGroupId write FOnGetAdjacentGroupId;
    property OnGetTreeLevel: ThiiGetTreeLevelEvent read FOnGetTreeLevel write FOnGetTreeLevel;
    property OnGetTreeBranchEnd: ThiiGetTreeBranchEndEvent read FOnGetTreeBranchEnd write FOnGetTreeBranchEnd;
    property OnAdjacentGroupStateChanged: ThiiAdjacentGroupStateChangedEvent read FOnAdjacentGroupStateChanged write FOnAdjacentGroupStateChanged;
  end;
```

## `h5u.PropertyEditor`

Quelle: `Source/Common/h5u.PropertyEditor.pas`

```pascal
{$IFNDEF FPC}

uses
  System.Classes, System.SysUtils, System.TypInfo, System.Rtti,
  System.Generics.Collections, System.Variants, System.Masks,
  h5u.Grid.Types, h5u.Grid.Sizing, h5u.Grid.Data.Objects;

type
  EhiiPropertyError = class(Exception);
  ThiiPropertyModel = class;
  ThiiPropertyItem = class;
  ThiiManualProperty = class;
  ThiiPropertySortOrder = (psoName, psoDeclaration);
  ThiiPropertyItemChangedEvent = procedure(Sender: TObject; Item: ThiiPropertyItem) of object;
  ThiiGetPropertyValueEvent = procedure(Sender: TObject; Item: ThiiPropertyItem; var Value: TValue; var Handled: Boolean) of object;
  ThiiSetPropertyValueEvent = procedure(Sender: TObject; Item: ThiiPropertyItem; const Value: TValue; var Handled: Boolean) of object;

  { Editors convert the model value to/from its editable presentation. Override
    these three methods to supply e.g. component references or method names. }
  ThiiValueEditor = class
  private
    FItem: ThiiPropertyItem;
  protected
    property Item: ThiiPropertyItem read FItem;
  public
    constructor Create(AItem: ThiiPropertyItem); virtual;
    function GetValue: string; virtual;
    procedure SetValue(const AText: string); virtual;
    procedure GetComboList(AList: TStrings); virtual;
  end;
  ThiiValueEditorClass = class of ThiiValueEditor;

  ThiiWidthValueEditor = class(ThiiValueEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const AText: string); override;
    procedure GetComboList(AList: TStrings); override;
  end;

  ThiiPropertyItem = class(TPersistent)
  private
    FOwner: ThiiPropertyModel;
    FInstance: Pointer;
    FName, FCaption, FGroupName, FDeclaringClassName, FTypeName, FReadError: string;
    FDeclaringClass: TClass;
    FValueTypeInfo: PTypeInfo;
    FProperty: TRttiProperty;
    FField: TRttiField;
    FManual: ThiiManualProperty;
    FCachedValue: TValue;
    FCacheValid, FReadOnly, FHidden, FIsManual: Boolean;
    FID, FParentID, FClassOrder, FMemberOrder: Integer;
    function GetValue: TValue;
    procedure SetValue(const AValue: TValue);
    function GetDisplayValue: string;
    procedure SetDisplayValue(const AValue: string);
    function GetCanEdit: Boolean;
    function GetIsManual: Boolean;
  public
    property Owner: ThiiPropertyModel read FOwner;
    property Instance: Pointer read FInstance;
    property Value: TValue read GetValue write SetValue;
    property ValueTypeInfo: PTypeInfo read FValueTypeInfo;
    property DeclaringClass: TClass read FDeclaringClass;
    property RttiProperty: TRttiProperty read FProperty;
    property RttiField: TRttiField read FField;
    procedure GetComboList(AList: TStrings);
  published
    property ID: Integer read FID;
    property ParentID: Integer read FParentID;
    property Name: string read FName;
    property Caption: string read FCaption write FCaption;
    property GroupName: string read FGroupName write FGroupName;
    property DisplayValue: string read GetDisplayValue write SetDisplayValue;
    property ReadError: string read FReadError;
    property DeclaringClassName: string read FDeclaringClassName;
    property TypeName: string read FTypeName;
    property ReadOnly: Boolean read FReadOnly;
    property CanEdit: Boolean read GetCanEdit;
    property Hidden: Boolean read FHidden;
    property IsManual: Boolean read GetIsManual;
  end;

  ThiiPropertyFilter = class(TCollectionItem)
  private
    FClassMask, FNameMask, FTypeMask: string;
    FReadOnly, FHidden: Boolean;
    procedure SetMask(AIndex: Integer; const AValue: string);
    procedure SetFlag(AIndex: Integer; AValue: Boolean);
  published
    property ClassMask: string index 0 read FClassMask write SetMask;
    property NameMask: string index 1 read FNameMask write SetMask;
    property TypeMask: string index 2 read FTypeMask write SetMask;
    property ReadOnly: Boolean index 0 read FReadOnly write SetFlag default False;
    property Hidden: Boolean index 1 read FHidden write SetFlag default False;
  end;

  ThiiPropertyFilters = class(TOwnedCollection)
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: ThiiPropertyFilter;
  end;

  ThiiManualProperty = class(TCollectionItem)
  private
    FTargetClass: TClass;
    FPropertyName: string;
    FValueTypeInfo: PTypeInfo;
    FDefaultValue: TValue;
    procedure SetTargetClass(AValue: TClass);
    procedure SetPropertyName(const AValue: string);
    procedure SetValueTypeInfo(AValue: PTypeInfo);
    procedure SetDefaultValue(const AValue: TValue);
    procedure ClearCachedValues;
  public
    destructor Destroy; override;
    property TargetClass: TClass read FTargetClass write SetTargetClass;
    property ValueTypeInfo: PTypeInfo read FValueTypeInfo write SetValueTypeInfo;
    property DefaultValue: TValue read FDefaultValue write SetDefaultValue;
  published
    property PropertyName: string read FPropertyName write SetPropertyName;
  end;

  ThiiManualProperties = class(TOwnedCollection)
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: ThiiManualProperty;
  end;

  ThiiPropertyModel = class(TComponent)
  private type
    TManualCacheEntry = class
      Instance: Pointer;
      Definition: ThiiManualProperty;
      Value: TValue;
      ExplicitValue: Boolean;
    end;
    TChangeListener = class
      Changing, Changed: TNotifyEvent;
      ItemChanged: ThiiPropertyItemChangedEvent;
    end;
  private
    FDataObject: TObject;
    FItems: TObjectList<ThiiPropertyItem>;
    FManualCache: TObjectList<TManualCacheEntry>;
    FListeners: TObjectList<TChangeListener>;
    FObservedComponents: TList<TComponent>;
    FNextItemID: Integer;
    FValueUpdateItem: ThiiPropertyItem;
    FValueBeforeUpdate: TValue;
    FReadErrorBeforeUpdate: string;
    FContext: TRttiContext;
    FPublishedProperties, FPublicProperties, FPublicFields, FPrivateFields: Boolean;
    FLimitClass: TClass;
    FSortOrder: ThiiPropertySortOrder;
    FClassMask, FNameMask, FTypeMask: string;
    FFilters: ThiiPropertyFilters;
    FManualProperties: ThiiManualProperties;
    FOnLoaded, FOnChanging, FOnChange: TNotifyEvent;
    FOnItemChanged: ThiiPropertyItemChangedEvent;
    FOnGetValue: ThiiGetPropertyValueEvent;
    FOnSetValue: ThiiSetPropertyValueEvent;
    FReloading, FDestroying: Boolean;
    procedure SetDataObject(AValue: TObject);
    procedure SetSelection(AIndex: Integer; AValue: Boolean);
    procedure SetLimitClass(AValue: TClass);
    procedure SetSortOrder(AValue: ThiiPropertySortOrder);
    procedure SetMask(AIndex: Integer; const AValue: string);
    procedure CheckItem(AItem: ThiiPropertyItem);
    procedure NotifyChanging;
    procedure NotifyChanged;
    procedure NotifyItemChanged(AItem: ThiiPropertyItem);
    procedure ObserveInstance(AInstance: Pointer);
    procedure PrepareItems;
    procedure CompleteNewItem(AItem: ThiiPropertyItem);
    function UpdateCachedValue(AItem: ThiiPropertyItem; const APreviousValue: TValue; const APreviousError: string): Boolean;
    function ValuesEqual(const A, B: TValue): Boolean;
    function SnapshotValue(const AValue: TValue): TValue;
    procedure ApplyFilters(AItem: ThiiPropertyItem);
    procedure SortItems;
    function NewItem(AInstance: Pointer; const AName: string; AClass: TClass; ATypeInfo: PTypeInfo): ThiiPropertyItem;
    function ReadMember(AItem: ThiiPropertyItem): TValue;
    procedure WriteMember(AItem: ThiiPropertyItem; const AValue: TValue);
    function ManualCache(AItem: ThiiPropertyItem; ACreate: Boolean): TManualCacheEntry;
    procedure ForgetDefinition(ADefinition: ThiiManualProperty);
    procedure UpdateDefinitionDefault(ADefinition: ThiiManualProperty);
    function CreateValueEditor(AItem: ThiiPropertyItem): ThiiValueEditor;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoLoaded; virtual;
    procedure DoGetValue(AItem: ThiiPropertyItem; var AValue: TValue; var AHandled: Boolean); virtual;
    procedure DoSetValue(AItem: ThiiPropertyItem; const AValue: TValue; var AHandled: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure Refresh; virtual;
    procedure Invalidate;
    procedure ForgetObject(AObject: TObject);
    procedure AddChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent = nil);
    procedure RemoveChangeListener(AChanging, AChanged: TNotifyEvent; AItemChanged: ThiiPropertyItemChangedEvent = nil);
    procedure NotifyItemsChanged;
    function AddProperty(AInstance: Pointer; AProperty: TRttiProperty): ThiiPropertyItem;
    function AddField(AInstance: Pointer; AField: TRttiField): ThiiPropertyItem;
    function AddManualProperty(AInstance: Pointer; const AName: string; const AValue: TValue): ThiiPropertyItem;
    function FindProperty(const AName: string): ThiiPropertyItem; overload;
    function FindProperty(AInstance: Pointer; const AName: string): ThiiPropertyItem; overload;
    function FindProperty(const AName: string; ADeclaringClass: TClass): ThiiPropertyItem; overload;
    function GetValue(AItem: ThiiPropertyItem): TValue;
    procedure SetValue(AItem: ThiiPropertyItem; const AValue: TValue);
    function GetText(AItem: ThiiPropertyItem): string;
    procedure SetText(AItem: ThiiPropertyItem; const AText: string);
    procedure GetComboList(AItem: ThiiPropertyItem; AList: TStrings);
    property DataObject: TObject read FDataObject write SetDataObject;
    property LimitClass: TClass read FLimitClass write SetLimitClass;
    property Items: TObjectList<ThiiPropertyItem> read FItems;
    property PropertyList: TObjectList<ThiiPropertyItem> read FItems;
    property Filters: ThiiPropertyFilters read FFilters;
    property ManualProperties: ThiiManualProperties read FManualProperties;
  published
    property PublishedProperties: Boolean index 0 read FPublishedProperties write SetSelection default True;
    property PublicProperties: Boolean index 1 read FPublicProperties write SetSelection default False;
    property PublicFields: Boolean index 2 read FPublicFields write SetSelection default False;
    property PrivateFields: Boolean index 3 read FPrivateFields write SetSelection default False;
    property SortOrder: ThiiPropertySortOrder read FSortOrder write SetSortOrder default psoName;
    property ClassMask: string index 0 read FClassMask write SetMask;
    property NameMask: string index 1 read FNameMask write SetMask;
    property TypeMask: string index 2 read FTypeMask write SetMask;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnItemChanged: ThiiPropertyItemChangedEvent read FOnItemChanged write FOnItemChanged;
    property OnGetValue: ThiiGetPropertyValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiSetPropertyValueEvent read FOnSetValue write FOnSetValue;
  end;

  Th5uPropertyGroupRow = class(TPersistent)
  private
    FID: Integer;
    FGroupName: string;
    function GetCaption: string;
    function GetDisplayValue: string;
  published
    property ID: Integer read FID;
    property Caption: string read GetCaption;
    property GroupName: string read FGroupName;
    property DisplayValue: string read GetDisplayValue;
  end;

  ThiiPropertyListController = class(ThiiObjectListController)
  private
    FPropertyEditor: ThiiPropertyModel;
    FGroupRows: TObjectList<TObject>;
    FGroupIDs: TDictionary<string, Integer>;
    FNextGroupID: Integer;
    FOnGetValue: ThiiGetPropertyValueEvent;
    FOnSetValue: ThiiSetPropertyValueEvent;
    function PropertyItem(ASourceRowIndex: Int64): ThiiPropertyItem;
    function GetHasGroups: Boolean;
  protected
    function GetSourceValue(ASourceRowIndex: Int64; const AFieldName: string): TValue; override;
    procedure SetSourceValue(ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue); override;
    function GetSourceCanEdit(ASourceRowIndex: Int64; const AFieldName: string): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Refresh;
    procedure RebuildItems(AShowGroups: Boolean = True);
    property HasGroups: Boolean read GetHasGroups;
    property PropertyEditor: ThiiPropertyModel read FPropertyEditor;
  published
    property OnGetValue: ThiiGetPropertyValueEvent read FOnGetValue write FOnGetValue;
    property OnSetValue: ThiiSetPropertyValueEvent read FOnSetValue write FOnSetValue;
  end;

{ Delphi RTL masks: case insensitive *, ?, [a-z]; dots remain literal.
  An empty mask selects everything. }
function h5uMatchesMask(const AText, AMask: string): Boolean;
function h5uRegisterPropertyEditor(ATypeInfo: PTypeInfo; AObjectClass: TClass; const APropertyName: string; AEditorClass: ThiiValueEditorClass): Integer;
procedure h5uUnregisterPropertyEditor(ARegistration: Integer);

{$ENDIF}
```

## `Lcl.h5u.Grid`

Quelle: `Source/LCL/Lcl.h5u.Grid.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  h5u.Grid.Compat,
  Classes,
  TypInfo,
  DateUtils,
  Generics.Collections,
  Math,
  Rtti,
  SysUtils,
  Types,
  DB,
  Dialogs,
  Forms,
  Themes,
  Lcl.h5u.Grid.Compat,
  LMessages,
  LCLIntf,
  Controls,
  ComCtrls,
  ExtCtrls,
  Graphics,
  Menus,
  StdCtrls,
  LCLType,
  LazUTF8,
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
  Lcl.h5u.Grid.Editors,
  Lcl.h5u.Grid.Styles;

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
  ThiiLclVisualCell = class;
  ThiiLclVisualCellClass = class of ThiiLclVisualCell;

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

  ThiiLclDrawContext = record
    FactoryContext: ThiiFactoryContext;
    Bounds: TRect;
    DisplayText: string;
    Appearance: ThiiResolvedAppearance;
  end;

  ThiiLclAfterDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas) of object;
  ThiiLclPrepareElementEvent = procedure(Sender: TObject; Control: TObject; ACanvas: TCanvas; const AContext: ThiiLclDrawContext; APart: ThiiElementPaintPart) of object;
  ThiiLclCustomDrawEvent = procedure(Sender: TObject; ACanvas: TCanvas; const AContext: ThiiLclDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean) of object;

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

  ThiiLclVisualCell = class(ThiiFactoryObject)
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
  Th5uLclSpacingCell = class(ThiiLclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiLclDataCell = class(ThiiLclVisualCell)
  private
    FPicture: TPicture;
    FPictureSignature: Integer;
    FPaintGrid: ThiiCustomGrid;
    FPaintCanvas: TCanvas;
    procedure EditorPreparePaint(APart: ThiiElementPaintPart);
    procedure EnsurePicture;
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  public
    destructor Destroy; override;
  end;

  ThiiLclHeaderCell = class(ThiiLclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiLclFixedCell = class(ThiiLclDataCell);

  // Plus/minus glyph used for one contiguous run of equal adjacent IDs.
  // The class is resolved through the per-grid FactoryScope.
  Th5uLclAdjacentGroupGlyphCell = class(ThiiLclVisualCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  ThiiCustomGrid = class(TCustomControl)
  private
    FShowColumnModes: Boolean;
    FColumns: ThiiGridColumns;
    FMinWidth, FMaxWidth: Integer;
    FAutoWidthRowLimit: Integer;
    FAutoWidthsDirty: Boolean;
    FAutoWidthFont: string;
    procedure SetMinWidth(const AValue: Integer);
    procedure SetMaxWidth(const AValue: Integer);
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
    FAdjacentGroupFolding: ThiiAdjacentGroupFoldingOptions;
    FTree: ThiiTreeOptions;
    FView: Th5uGridView;

    FTheme: ThiiGridTheme;
    FHeaderRowHeight: Integer;
    FRowIndicatorWidth: Integer;
    FShowHeader: Boolean;
    FShowRowIndicator: Boolean;
    FAllowEditing: Boolean;
    FImmediateEdit: Boolean;

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
    procedure SearchCharacter(const AText: string);
  private
    FVScrollBar: TScrollBar;
    FHScrollBar: TScrollBar;
    FThumbHint: TLabel;
    FThumbHintTimer: TTimer;
    FEditRowIndex: Int64;
    FEditRowKey: ThiiRowKey;
    FEditColumn: ThiiGridColumn;
    FCommittingEditor: Boolean;
    FEditors: ThiiLclGridEditors;
    FEditorCache: Th5uGridEditorCache;
    FDefaultEditors: ThiiDefaultEditors;
    FActiveEditor: ThiiGridEditorItem;
    procedure SetEditors(AValue: ThiiLclGridEditors);
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
    FVisibleColumns: specialize TArray<ThiiVisibleColumnInfo>;
    FAllColumns: specialize TArray<ThiiVisibleColumnInfo>;
    FVisibleRows: specialize TArray<ThiiVisibleRowInfo>;
    FCellPool: specialize TObjectList<ThiiLclVisualCell>;
    FRowMetrics: Th5uGridRowMetrics;
    FUpdatingScrollBars: Boolean;
    FLayoutClientWidth: Integer;
    FLayoutClientHeight: Integer;
    FInitialized: Boolean;

    FMouseDownHit: ThiiHitTestInfo;
    FSelectingRange, FSelectionDragging, FMouseEditPending: Boolean;
    FSelectionDragKind: ThiiSelectionKind;
    FSelectionDragShift: TShiftState;
    FSelectionDragOrigin: TPoint;
    FSelectionDragLast: ThiiCellAddress;
    FMovingColumns: specialize TArray<ThiiGridColumn>;
    FMovingRowKeys: specialize TArray<ThiiRowKey>;
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
    FResizeCursorActive: Boolean;
    FResizeCursor: TCursor;

    FOnGetRowHeight: ThiiGetRowHeightEvent;
    FOnGetRowSpacing: ThiiGetRowSpacingEvent;
    FOnGetThumbHint: ThiiGetThumbHintEvent;
    FOnGetRowAppearance: ThiiRowAppearanceEvent;
    FOnGetCellAppearance: ThiiCellAppearanceEvent;
    FOnAfterDraw: ThiiLclAfterDrawEvent;
    FOnPrepareElement: ThiiLclPrepareElementEvent;
    FOnCustomDraw: ThiiLclCustomDrawEvent;
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
    function GetViewSourceRowIndex(AViewRowIndex: Int64): Int64;
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
    function GetEstimatedTotalRowHeight: Int64;
    function CanUpdateLayout: Boolean;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(const AContext: ThiiFactoryContext; ADefaultClass: ThiiLclVisualCellClass): ThiiLclVisualCell;

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

    function GetVisualCellClass(const AContext: ThiiFactoryContext; ADefaultClass: ThiiLclVisualCellClass): ThiiLclVisualCellClass; virtual;

    procedure DoCustomDraw(ACanvas: TCanvas; const AContext: ThiiLclDrawContext; AStage: ThiiCustomDrawStage; var ADrawDefault: Boolean);
  protected
    procedure DoExit; override;
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    procedure CMCursorChanged(var Message: TLMessage); message CM_CURSORCHANGED;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure WMGetDlgCode(var Message: TLMGetDlgCode); message LM_GETDLGCODE;
    procedure WMCancelMode(var Message: TLMNoParams); message LM_CANCELMODE;
    procedure WMCaptureChanged(var Message: TLMessage); message LM_CAPTURECHANGED;
    procedure CMWantSpecialKey(var Message: TLMKey); message CM_WANTSPECIALKEY;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;

    function GetDataCellClass(const AContext: ThiiFactoryContext): ThiiLclVisualCellClass; virtual;
    function GetHeaderCellClass(const AContext: ThiiFactoryContext): ThiiLclVisualCellClass; virtual;
    function GetFixedCellClass(const AContext: ThiiFactoryContext): ThiiLclVisualCellClass; virtual;
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
    property HorizontalOffset: Integer read FHorizontalOffset;
    property VerticalOffset: Integer read FVerticalOffset;
  protected
    property DataController: ThiiCustomDataController read FDataController write SetDataController;
    property SharedClassFactory: ThiiClassFactory read FSharedClassFactory write SetSharedClassFactory;
    property Editors: ThiiLclGridEditors read FEditors write SetEditors;
    property DefaultEditors: ThiiDefaultEditors read FDefaultEditors write SetDefaultEditors;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 0;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 0;
    property AutoWidthRowLimit: Integer read FAutoWidthRowLimit write SetAutoWidthRowLimit default 1000;
    property Columns: ThiiGridColumns read FColumns write SetColumns;
    property HeaderLayout: ThiiHeaderLayout read FHeaderLayout write SetHeaderLayout;
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

    property Theme: ThiiGridTheme read FTheme write SetTheme default ThiiGridTheme.ApplicationStyle;
    property HeaderRowHeight: Integer read FHeaderRowHeight write SetHeaderRowHeight default 26;
    property RowIndicatorWidth: Integer read FRowIndicatorWidth write SetRowIndicatorWidth default 34;
    property ShowHeader: Boolean read FShowHeader write FShowHeader default True;
    property ShowRowIndicator: Boolean read FShowRowIndicator write FShowRowIndicator default True;
    property AllowEditing: Boolean read FAllowEditing write FAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write FImmediateEdit default False;
    property GridLines: Boolean read GetGridLines write SetGridLines default True;

    property OnGetClass: ThiiGetClassEvent read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: ThiiCreateInstanceEvent read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: ThiiConfigureInstanceEvent read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: ThiiGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: ThiiGetRowSpacingEvent read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: ThiiGetThumbHintEvent read FOnGetThumbHint write FOnGetThumbHint;
    property OnGetRowAppearance: ThiiRowAppearanceEvent read FOnGetRowAppearance write FOnGetRowAppearance;
    property OnGetCellAppearance: ThiiCellAppearanceEvent read FOnGetCellAppearance write FOnGetCellAppearance;
    property OnAfterDraw: ThiiLclAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;
    property OnPrepareElement: ThiiLclPrepareElementEvent read FOnPrepareElement write FOnPrepareElement;
    property OnCustomDraw: ThiiLclCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
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
    property OnUTF8KeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;
```

## `Lcl.h5u.Grid.Compat`

Quelle: `Source/LCL/Lcl.h5u.Grid.Compat.pas`

```pascal
uses
  Types;

type
  Th5uLclRectFHelper = record helper for TRectF
    class function Create(ALeft, ATop, ARight, ABottom: Single): TRectF; overload; static;
    class function Create(const ARect: TRect): TRectF; overload; static;
    function Round: TRect;
    function Contains(const APoint: TPointF): Boolean;
  end;

function PointF(AX, AY: Single): TPointF;
function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;
```

## `Lcl.h5u.Grid.Design`

Quelle: `Source/Design/Lcl.h5u.Grid.Design.pas`

```pascal
procedure Register;
```

## `Lcl.h5u.Grid.Editors`

Quelle: `Source/LCL/Lcl.h5u.Grid.Editors.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  h5u.Grid.Compat,
  Classes, SysUtils, Types, Rtti,
  TypInfo, Math, DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  LCLIntf, LCLType, DateTimePicker, Controls, ComCtrls, ExtCtrls, Forms,
  Graphics, StdCtrls, Clipbrd, Dialogs, Lcl.h5u.Grid.Compat;

type
  ThiiLclEditorControlClass = class of TControl;
  ThiiLclBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiLclCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiLclEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiLclBuildEditorEvent;

    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiLclEditorControlClass);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure ControlChanged(Sender: TObject);
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiLclEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: ThiiLclEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to LFM streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiLclBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiLclTextEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiLclIntegerEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclFloatEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclCurrencyEditor = class(ThiiLclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiLclDateEditor = class(ThiiLclTextEditor)
  protected
    function DefaultControlClass: ThiiLclEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiLclTimeEditor = class(ThiiLclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiLclDateTimeEditor = class(ThiiLclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiLclCheckBoxEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiLclImageCellEditor = class(ThiiLclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  protected
    function DefaultControlClass: ThiiLclEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiLclGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiLclCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiLclCustomEditor;
    function AddVariant(const AName, AType: string): ThiiLclCustomEditor;
    property Items[AIndex: Integer]: ThiiLclCustomEditor read GetItem; default;
  end;

  Th5uLclImageEditForm = class(TForm)
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

## `Lcl.h5u.Grid.Styles`

Quelle: `Source/LCL/Lcl.h5u.Grid.Styles.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  SysUtils,
  Graphics,
  Themes,
  h5u.Grid.Types;

type
  ThiiLclPalette = record
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

function h5uGetLclPalette(ATheme: ThiiGridTheme): ThiiLclPalette;
function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
```

## `Vcl.h5u.FormDesigner`

Quelle: `Source/VCL/Vcl.h5u.FormDesigner.pas`

```pascal
uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Vcl.Controls, Vcl.StdCtrls,
  h5u.FormDesigner,
  h5u.Grid.Data.Objects,
  Vcl.h5u.Grid;

type
  ThiiVclStructureModel = class(ThiiStructureModel)
  protected
    procedure CollectChildren(AComponent: TComponent; AChildren: ThiiComponentList); override;
  end;

  ThiiStructureSelectEvent = procedure(Sender: TObject; AComponent: TComponent) of object;

  ThiiStructureView = class(TCustomControl)
  private
    FStructureView: ThiiVclStructureModel;
    FObjectListController: ThiiObjectListController;
    FGrid: ThiiGrid;
    FFilterEdit: TEdit;
    FUpdating: Boolean;
    FFilterError: string;
    FLoadingRoot: TComponent;
    FLoadingRootAssigned: Boolean;
    FOnSelect: ThiiStructureSelectEvent;
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure FilterChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure GetNameValue(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AValue: TValue; ADisplayValue: Boolean);
    function ItemAtRow(ARowIndex: Int64): ThiiStructureItem;
    function GetRootComponent: TComponent;
    procedure SetRootComponent(AValue: TComponent);
    function GetFilterText: string;
    procedure SetFilterText(const AValue: string);
    function GetResolveByOwner: Boolean;
    procedure SetResolveByOwner(AValue: Boolean);
    function GetResolveByParent: Boolean;
    procedure SetResolveByParent(AValue: Boolean);
    function GetOnLoaded: TNotifyEvent;
    procedure SetOnLoaded(AValue: TNotifyEvent);
    function GetSelectedComponent: TComponent;
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    property StructureView: ThiiVclStructureModel read FStructureView;
    property ObjectListController: ThiiObjectListController read FObjectListController;
    property Grid: ThiiGrid read FGrid;
    property FilterEdit: TEdit read FFilterEdit;
    property SelectedComponent: TComponent read GetSelectedComponent;
    property FilterError: string read FFilterError;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property RootComponent: TComponent read GetRootComponent write SetRootComponent;
    property ResolveByOwner: Boolean read GetResolveByOwner write SetResolveByOwner default True;
    property ResolveByParent: Boolean read GetResolveByParent write SetResolveByParent default True;
    property FilterText: string read GetFilterText write SetFilterText;
    property OnLoaded: TNotifyEvent read GetOnLoaded write SetOnLoaded;
    property OnSelect: ThiiStructureSelectEvent read FOnSelect write FOnSelect;
  end;
```

## `Vcl.h5u.Grid`

Quelle: `Source/VCL/Vcl.h5u.Grid.pas`

```pascal
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
```

## `Vcl.h5u.Grid.Design`

Quelle: `Source/Design/Vcl.h5u.Grid.Design.pas`

```pascal
uses
  System.Classes, DesignIntf,
  Vcl.h5u.Grid, Vcl.h5u.PropertyEditor, Vcl.h5u.FormDesigner;

procedure Register;
```

## `Vcl.h5u.Grid.Editors`

Quelle: `Source/VCL/Vcl.h5u.Grid.Editors.pas`

```pascal
{$SCOPEDENUMS ON}

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes, System.Rtti,
  System.TypInfo, System.Math, System.DateUtils,
  h5u.Grid.Types, h5u.Grid.Columns, h5u.Grid.Values, h5u.Grid.Editors,
  Winapi.Windows, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Forms,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.Clipbrd, Vcl.Dialogs;

type
  ThiiVclEditorControlClass = class of TControl;
  ThiiVclBuildEditorEvent = procedure(Sender: TObject; var AControl: TControl) of object;

  ThiiVclCustomEditor = class(ThiiGridEditorItem)
  private
    FControl: TControl;
    FControlClass: ThiiVclEditorControlClass;
    FControlVersion: Integer;
    FOnBuildEditor: ThiiVclBuildEditorEvent;

    function GetControlClassName: string;
    procedure SetControlClassName(const AValue: string);
    procedure SetControlClass(AValue: ThiiVclEditorControlClass);
    procedure ControlChanged(Sender: TObject);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure SetEditorType(const AValue: string); override;
    function ReadText: string; override;
    procedure WriteText(const AText: string); override;
    function DefaultControlClass: ThiiVclEditorControlClass; virtual;
    procedure ConfigureControl; virtual;
    procedure ReleaseControl; virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BuildEditor; override;
    procedure ReleaseEditor; override;
    procedure UpdateBounds(const ABounds: TRectF); override;
    procedure Show; override;
    procedure Hide; override;
    procedure Focus; override;
    procedure BringToFront; override;
    property Control: TControl read FControl;
    property ControlClass: ThiiVclEditorControlClass read FControlClass write SetControlClass;
  published
    // RegisterClass makes a custom control class available to DFM/FMX streaming.
    property ControlClassName: string read GetControlClassName write SetControlClassName;
    property OnBuildEditor: ThiiVclBuildEditorEvent read FOnBuildEditor write FOnBuildEditor;
  end;

  ThiiVclTextEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiVclIntegerEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclFloatEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclCurrencyEditor = class(ThiiVclTextEditor)
  protected
    function ReadValue: TValue; override;
  end;

  ThiiVclDateEditor = class(ThiiVclTextEditor)
  protected
    function DefaultControlClass: ThiiVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function DateKind: ThiiColumnEditorKind; virtual;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
    function State: string; override;
  public
    function UsesTextValue: Boolean; override;
    function DeferExit: Boolean; override;
  end;

  ThiiVclTimeEditor = class(ThiiVclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiVclDateTimeEditor = class(ThiiVclDateEditor)
  protected
    function DateKind: ThiiColumnEditorKind; override;
  end;

  ThiiVclCheckBoxEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
    function HitTest(const ABounds: TRectF; const APoint: TPointF): Boolean; override;
  end;

  ThiiVclImageCellEditor = class(ThiiVclCustomEditor)
  protected
    function MeasureContentWidth(const AContext: ThiiEditorContext): Single; override;
  protected
    function DefaultControlClass: ThiiVclEditorControlClass; override;
    procedure ConfigureControl; override;
    function ReadValue: TValue; override;
    procedure WriteValue(const AValue: TValue); override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Activate; override;
    function Modified: Boolean; override;
    function DrawDisplay(const AContext: ThiiEditorContext): Boolean; override;
  end;

  ThiiVclGridEditors = class(ThiiGridEditors)
  private
    function GetItem(AIndex: Integer): ThiiVclCustomEditor;
  public
    constructor Create(AOwner: TPersistent);
    function Add: ThiiVclCustomEditor;
    function AddVariant(const AName, AType: string): ThiiVclCustomEditor;
    property Items[AIndex: Integer]: ThiiVclCustomEditor read GetItem; default;
  end;

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
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Themes,
  h5u.Grid.Types;

type
  ThiiVclPalette = record
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

function h5uGetVclPalette(ATheme: ThiiGridTheme): ThiiVclPalette;
function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
```

## `Vcl.h5u.PropertyEditor`

Quelle: `Source/VCL/Vcl.h5u.PropertyEditor.pas`

```pascal
uses
  System.SysUtils, System.Classes, System.Rtti, System.Masks, System.Generics.Collections,
  Vcl.Controls, Vcl.StdCtrls,
  h5u.PropertyEditor,
  Vcl.h5u.Grid, Vcl.h5u.Grid.Editors;

type
  // Property-editor API; canonical declarations live in the shared model unit.
  EhiiPropertyError = h5u.PropertyEditor.EhiiPropertyError;
  ThiiPropertyModel = h5u.PropertyEditor.ThiiPropertyModel;
  ThiiPropertyItem = h5u.PropertyEditor.ThiiPropertyItem;
  ThiiManualProperty = h5u.PropertyEditor.ThiiManualProperty;
  ThiiPropertySortOrder = h5u.PropertyEditor.ThiiPropertySortOrder;
  ThiiPropertyItemChangedEvent = h5u.PropertyEditor.ThiiPropertyItemChangedEvent;
  ThiiGetPropertyValueEvent = h5u.PropertyEditor.ThiiGetPropertyValueEvent;
  ThiiSetPropertyValueEvent = h5u.PropertyEditor.ThiiSetPropertyValueEvent;
  ThiiValueEditor = h5u.PropertyEditor.ThiiValueEditor;
  ThiiValueEditorClass = h5u.PropertyEditor.ThiiValueEditorClass;
  ThiiWidthValueEditor = h5u.PropertyEditor.ThiiWidthValueEditor;
  ThiiPropertyFilter = h5u.PropertyEditor.ThiiPropertyFilter;
  ThiiPropertyFilters = h5u.PropertyEditor.ThiiPropertyFilters;
  ThiiManualProperties = h5u.PropertyEditor.ThiiManualProperties;
  ThiiPropertyListController = h5u.PropertyEditor.ThiiPropertyListController;

  // The grid borrows the model's items. The model owns their lifetime and values.
  ThiiPropertyEditor = class(ThiiCustomGrid)
  private
    FPropertyEditor: ThiiPropertyModel;
    FObjectListController: ThiiPropertyListController;
    FNeedsRebind: Boolean;
    FShowGroups: Boolean;
    FGroupStates: TDictionary<Integer, Boolean>;
    procedure GroupStateChanged(Sender: TObject; const AContext: ThiiAdjacentGroupStateChangedContext);
    procedure RestoreGroupStates;
    procedure SetShowGroups(AValue: Boolean);
    procedure ModelChanging(Sender: TObject);
    procedure ModelChanged(Sender: TObject);
    procedure ModelItemChanged(Sender: TObject; AItem: ThiiPropertyItem);
    procedure CanEditProperty(Sender: TObject; AColumn: ThiiGridColumn; ARowIndex: Int64; var AAllow: Boolean);
    procedure ShowValueEditor(Sender: TObject);
    function ItemAtRow(ARowIndex: Int64): ThiiPropertyItem;
    function GetDataObject: TObject;
    procedure SetDataObject(AValue: TObject);
    function GetGrid: ThiiPropertyEditor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reload;
    procedure ResetAdjacentGroupStates; reintroduce;
    property DataObject: TObject read GetDataObject write SetDataObject;

    property ObjectListController: ThiiPropertyListController read FObjectListController;
    property Grid: ThiiPropertyEditor read GetGrid;
  published
    property ColumnSizing;
    property Header;
    property RowIndicator;
    property Editing;
    property PropertyEditor: ThiiPropertyModel read FPropertyEditor;
    property ShowGroups: Boolean read FShowGroups write SetShowGroups default True;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop;
    property Columns;
    property Appearance;
    property RowHeight;
    [ThiiLegacyOption]
    property ShowHeader;
    property GridLines;
  end;
```
