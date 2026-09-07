unit Fmx.h5u.Grid;

interface

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
    FInitialized: Boolean;
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
    function CanUpdateLayout: Boolean;
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
    procedure Loaded; override;
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
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

procedure Th5uFmxVisualCell.Paint(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LContext: Th5uFmxDrawContext;
  LDrawDefault: Boolean;
begin
  LContext.FactoryContext := FContext;
  LContext.Bounds := FBounds;
  LContext.DisplayText := FDisplayText;
  LContext.Appearance := FAppearance;

  LDrawDefault := True;
  AGrid.DoCustomDraw(ACanvas, LContext, Th5uFmxCustomDrawStage.BeforeDefault, LDrawDefault);
  if LDrawDefault then
    PaintDefault(AGrid, ACanvas);
  AGrid.DoCustomDraw(ACanvas, LContext, Th5uFmxCustomDrawStage.AfterDefault, LDrawDefault);
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
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);
end;

{ Th5uFmxSpacingCell }

procedure Th5uFmxSpacingCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
begin
  if not Appearance.HasBackground then
    Exit;
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := h5uColorToFmx(Appearance.Background);
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
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);

  LRect.Inflate(-1, -1);
  if (LRect.Width < 7) or (LRect.Height < 7) then
    Exit;

  ACanvas.Fill.Color := LPalette.CellBackground;
  ACanvas.FillRect(LRect, 0, 0, AllCorners, 1);
  ACanvas.Stroke.Kind := TBrushKind.Solid;
  ACanvas.Stroke.Color := LPalette.CellText;
  ACanvas.Stroke.Thickness := 1;
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
  if not (Context.Column is Th5uGridColumn) then
    Exit;

  LColumn := Th5uGridColumn(Context.Column);
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  if Appearance.HasForeground then
    LTextColor := h5uColorToFmx(Appearance.Foreground)
  else
    LTextColor := LPalette.CellText;

  case LColumn.DataType of
    Th5uColumnDataType.Boolean:
      begin
        LCheckRect := RectF(Bounds.Left + (Bounds.Width - 15) / 2, Bounds.Top + (Bounds.Height - 15) / 2, Bounds.Left + (Bounds.Width - 15) / 2
          + 15, Bounds.Top + (Bounds.Height - 15) / 2 + 15);
        LChecked := False;
        if not Value.IsEmpty then
          if Value.Kind = tkEnumeration then
            LChecked := Value.AsBoolean
          else
            LChecked := SameText(Value.ToString, 'True') or (Value.ToString = '1');

        ACanvas.Stroke.Color := LTextColor;
        ACanvas.Fill.Color := LPalette.CellBackground;
        ACanvas.FillRect(LCheckRect, 2, 2, AllCorners, 1);
        ACanvas.DrawRect(LCheckRect, 2, 2, AllCorners, 1);
        if LChecked then
        begin
          ACanvas.Stroke.Color := LPalette.SelectedBackground;
          ACanvas.Stroke.Thickness := 2;
          ACanvas.DrawLine(PointF(LCheckRect.Left + 3, LCheckRect.Top + 8), PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), 1);
          ACanvas.DrawLine(PointF(LCheckRect.Left + 6, LCheckRect.Bottom - 3), PointF(LCheckRect.Right - 2, LCheckRect.Top + 3), 1);
          ACanvas.Stroke.Thickness := 1;
        end;
      end;

    Th5uColumnDataType.Image:
      begin
        EnsureBitmap;
        if Assigned(FBitmap) and not FBitmap.IsEmpty then
        begin
          LDest := Bounds;
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
        LTextRect := Bounds;
        LTextRect.Inflate(-5, -2);
        ACanvas.Fill.Color := LTextColor;
        ACanvas.Font.Size := AGrid.TextSize;
        LAlign := TTextAlign.Leading;
        if LColumn.DataType in [Th5uColumnDataType.Integer, Th5uColumnDataType.Float, Th5uColumnDataType.Currency] then
          LAlign := TTextAlign.Trailing;

        ACanvas.FillText(LTextRect, DisplayText, LColumn.WordWrap, 1, [], LAlign, TTextAlign.Center);
      end;
  end;

  if Th5uElementFlag.Focused in Context.ElementFlags then
  begin
    ACanvas.Stroke.Color := LPalette.FocusBorder;
    ACanvas.Stroke.Thickness := 2;
    ACanvas.DrawRect(Bounds, 0, 0, AllCorners, 1);
    ACanvas.Stroke.Thickness := 1;
  end;
end;

{ Th5uFmxHeaderCell }

procedure Th5uFmxHeaderCell.PaintDefault(AGrid: Th5uFmxGrid; ACanvas: TCanvas);
var
  LPalette: Th5uFmxPalette;
  LRect: TRectF;
begin
  LPalette := h5uGetFmxPalette(AGrid.Theme);
  ACanvas.Fill.Kind := TBrushKind.Solid;
  ACanvas.Fill.Color := LPalette.HeaderBackground;
  ACanvas.FillRect(Bounds, 0, 0, AllCorners, 1);

  LRect := Bounds;
  LRect.Inflate(-5, -2);
  ACanvas.Font.Size := AGrid.TextSize;
  ACanvas.Font.Style := [TFontStyle.fsBold];
  ACanvas.Fill.Color := LPalette.HeaderText;
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
  FEditor.Visible := False;
  if Assigned(FImageEditor) then
    Th5uFmxImageEditor(FImageEditor).Visible := False;
  FEditRowIndex := -1;
  FEditColumn := nil;
end;

procedure Th5uFmxGrid.ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
begin
  InvalidateAdjacentGroupMap(False);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

procedure Th5uFmxGrid.CommitEditor;
var
  LValue: TValue;
begin
  if FCommittingEditor or not FEditor.Visible or not Assigned(FEditColumn) or not Assigned(FDataController) then
    Exit;

  FCommittingEditor := True;
  try
    LValue := ParseEditorValue(FEditColumn, FEditor.Text);
    SetViewValue(FEditRowIndex, FEditColumn.FieldName, LValue);
    CancelEditor;
    InvalidateAllRowHeights;
    Repaint;
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
  FHeaderLayout := Th5uHeaderLayout.Create(Self);
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
  FVScrollBar.Parent := Self;
  FVScrollBar.Orientation := TOrientation.Vertical;
  FVScrollBar.OnChange := ScrollChanged;

  FHScrollBar := TScrollBar.Create(Self);
  FHScrollBar.Parent := Self;
  FHScrollBar.Orientation := TOrientation.Horizontal;
  FHScrollBar.OnChange := ScrollChanged;

  FThumbHint := TLabel.Create(Self);
  FThumbHint.Parent := Self;
  FThumbHint.Visible := False;
  FThumbHint.TextSettings.HorzAlign := TTextAlign.Center;
  FThumbHint.TextSettings.VertAlign := TTextAlign.Center;

  FThumbHintTimer := TTimer.Create(Self);
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Interval := 900;
  FThumbHintTimer.OnTimer := ThumbHintTimer;

  FEditor := TEdit.Create(Self);
  FEditor.Parent := Self;
  FEditor.Visible := False;
  FEditor.OnExit := EditorExit;
  FEditor.OnKeyDown := EditorKeyDown;


  FInitialized := True;
  CanFocus := True;
  ClipChildren := True;
  SetSize(640, 320);
  LayoutScrollBars;
end;

procedure Th5uFmxGrid.DataChanged(Sender: TObject; const AChange: Th5uDataChange);
begin
  CancelEditor;
  InvalidateAdjacentGroupMap(not FAdjacentGroupFolding.PreserveStateOnDataChange);
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Repaint;
end;

destructor Th5uFmxGrid.Destroy;
begin
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
  if LHit.Kind = Th5uFmxHitKind.DataCell then
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
    LRect := RectF(GetViewportRect.Left, GetViewportRect.Top, GetViewportRect.Left + FRowIndicatorWidth, GetViewportRect.Top + FHeaderRowHeight);
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

  for LInfo in FVisibleColumns do
  begin
    LRect := LInfo.Bounds;
    LRect.Top := GetViewportRect.Top;
    LRect.Bottom := LRect.Top + FHeaderRowHeight;

    LDrawRect := TRectF.Intersect(LRect, GetViewportRect);
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
      LCell.Paint(Self, Canvas);
    end;

    LSpacing := GetEffectiveColumnRightSpacing(LInfo.Column);
    if LSpacing > 0 then
    begin
      LSeparatorRect := RectF(LRect.Right, LRect.Top, LRect.Right + LSpacing, LRect.Bottom);
      LSeparatorRect := TRectF.Intersect(LSeparatorRect, GetViewportRect);
      if not LSeparatorRect.IsEmpty then
        DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, LInfo.Column, -1, Th5uRowKey.Empty, ResolveColumnSpacingColor);
    end;
  end;

  if FSpacing.RowSpacing > 0 then
  begin
    LSeparatorRect := RectF(GetViewportRect.Left, GetViewportRect.Top + FHeaderRowHeight, GetViewportRect.Right, GetViewportRect.Top
      + FHeaderRowHeight + FSpacing.RowSpacing);
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
  if not FAdjacentGroupFolding.Enabled or not FAdjacentGroupFolding.ShowFoldGlyph or not TryGetAdjacentGroupRowInfo(ARowInfo.RowIndex, LInfo)
    or not LInfo.IsFoldable or not LInfo.IsFirstRow then
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
      LRowSpacing := GetEffectiveRowSeparatorFor(LRowIndex, LRowKey, LRowSeparatorKind, LRowSeparatorColor, LRowSeparatorStyleName, LTreeLevel,
        LClosedTreeLevels);
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
          Canvas.Fill.Kind := TBrushKind.Solid;
          Canvas.Fill.Color := LPalette.FixedBackground;
          Canvas.FillRect(LIndicatorRect, 0, 0, AllCorners, 1);
          Canvas.Fill.Color := LPalette.CellText;
          Canvas.Font.Size := FTextSize;
          Canvas.FillText(LIndicatorRect, IntToStr(LRowIndex + 1), False, 1, [], TTextAlign.Center, TTextAlign.Center);

          if FSpacing.DefaultColumnRightSpacing > 0 then
          begin
            LSeparatorRect := RectF(LIndicatorRect.Right, LIndicatorRect.Top, LIndicatorRect.Right
              + FSpacing.DefaultColumnRightSpacing, LIndicatorRect.Bottom);
            LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
            if not LSeparatorRect.IsEmpty then
              DrawSpacingRect(LSeparatorRect, Th5uElementKind.ColumnSpacing, nil, LRowIndex, LRowKey, ResolveColumnSpacingColor);
          end;
          DrawAdjacentGroupGlyph(LRowInfo, LRowSelected);
        end;

        for LColumnInfo in FVisibleColumns do
        begin
          LCellRect := LColumnInfo.Bounds;
          LCellRect.Top := LRowRect.Top;
          LCellRect.Bottom := LRowRect.Bottom;
          LCellRect := TRectF.Intersect(LCellRect, LDataRect);

          if not LCellRect.IsEmpty then
          begin
            LSelected := FSelection.IsRowSelected(LRowKey) or FSelection.IsColumnSelected(LColumnInfo.Column.Id)
              or FSelection.IsCellSelected(LRowIndex, LColumnInfo.VisibleIndex);
            LFocused := FSelection.FocusedCell.IsValid and (FSelection.FocusedCell.RowIndex = LRowIndex) and (FSelection.FocusedCell.ColumnIndex
              = LColumnInfo.VisibleIndex);

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

            LValue := GetViewValue(LRowIndex, LColumnInfo.Column.FieldName);
            LContext.Value := LValue;
            LAppearance := ResolveCellAppearance(LRowIndex, LColumnInfo.Column, LSelected, LFocused);

            LCell := AcquireVisualCell(LContext, Th5uFmxDataCell);
            LCell.BindCell(LContext, LCellRect, LValue, GetViewDisplayText(LRowIndex, LColumnInfo.Column.FieldName,
              LColumnInfo.Column.DisplayFormat), LAppearance);
            LCell.Paint(Self, Canvas);
          end;

          LColumnSpacing := GetEffectiveColumnRightSpacing(LColumnInfo.Column);
          if LColumnSpacing > 0 then
          begin
            LSeparatorRect := RectF(LColumnInfo.Bounds.Right, LRowRect.Top, LColumnInfo.Bounds.Right + LColumnSpacing, LRowRect.Bottom);
            LSeparatorRect := TRectF.Intersect(LSeparatorRect, LDataRect);
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

procedure Th5uFmxGrid.EditorExit(Sender: TObject);
begin
  if not FCommittingEditor then
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
    and not (FAdjacentGroupFolding.Enabled and (FAdjacentGroupFolding.EndBand.Visibility <> Th5uAdjacentGroupEndBandVisibility.Never)) then
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
begin
  if FShowHeader then
    Result := FHeaderRowHeight + FSpacing.RowSpacing
  else
    Result := 0;
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
  LColumn: Th5uFmxVisibleColumnInfo;
  LRow: Th5uFmxVisibleRowInfo;
  LGlyphRect: TRectF;
begin
  Result := Th5uFmxHitTestInfo.Empty;

  if FShowHeader and (Y < GetDataViewportRect.Top) then
  begin
    for LColumn in FVisibleColumns do
      if LColumn.Bounds.Contains(PointF(X, Y)) then
      begin
        Result.Kind := Th5uFmxHitKind.Header;
        Result.Column := LColumn.Column;
        Result.ColumnIndex := LColumn.VisibleIndex;
        Result.Bounds := LColumn.Bounds;
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
        if (X >= LColumn.Bounds.Left) and (X < LColumn.Bounds.Right) then
        begin
          Result.Kind := Th5uFmxHitKind.DataCell;
          Result.Column := LColumn.Column;
          Result.ColumnIndex := LColumn.VisibleIndex;
          Result.Bounds := RectF(LColumn.Bounds.Left, LRow.Bounds.Top, LColumn.Bounds.Right, LRow.Bounds.Bottom);
          Exit;
        end;
    end;
end;

procedure Th5uFmxGrid.HideThumbHint;
begin
  FThumbHintTimer.Enabled := False;
  FThumbHint.Visible := False;
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
  SetViewValue(FEditRowIndex, FEditColumn.FieldName, TValue.From<TBytes>(LImageEditor.Bytes));
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
  FThumbHint.BringToFront;
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
    LValue := GetViewValue(AViewRowIndex, AColumn.FieldName);
    if LValue.IsType<TBytes> and (Length(LValue.AsType<TBytes>) > 0) then
      Result := Min(AColumn.MaxAutoHeight, 80);
    Exit;
  end;

  LText := GetViewDisplayText(AViewRowIndex, AColumn.FieldName, AColumn.DisplayFormat);
  Canvas.Font.Size := FTextSize;
  LRect := RectF(0, 0, Max(8, AColumn.Width - 10), 10000);
  Canvas.MeasureText(LRect, LText, AColumn.WordWrap, [], TTextAlign.Leading, TTextAlign.Leading);
  Result := LRect.Height + 6;
  if AColumn.MaxAutoHeight > 0 then
    Result := Min(Result, AColumn.MaxAutoHeight);
end;

procedure Th5uFmxGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  LHit: Th5uFmxHitTestInfo;
  LCell: Th5uCellAddress;
begin
  inherited;
  FLastMousePoint := PointF(X, Y);
  if Button <> TMouseButton.mbLeft then
    Exit;

  SetFocus;
  LHit := GridHitTest(X, Y);
  case LHit.Kind of
    Th5uFmxHitKind.AdjacentGroupGlyph:
      ToggleAdjacentGroup(LHit.RowIndex);

    Th5uFmxHitKind.Header:
      if ssCtrl in Shift then
        FSelection.ToggleColumn(LHit.Column.Id)
      else
        FSelection.SelectColumn(LHit.Column.Id, False);

    Th5uFmxHitKind.RowIndicator:
      if ssCtrl in Shift then
        FSelection.ToggleRow(LHit.RowKey)
      else
        FSelection.SelectRow(LHit.RowKey, False);

    Th5uFmxHitKind.DataCell:
      begin
        LCell.RowIndex := LHit.RowIndex;
        LCell.ColumnIndex := LHit.ColumnIndex;
        LCell.RowKey := LHit.RowKey;
        LCell.ColumnId := LHit.Column.Id;
        FSelection.SetFocus(LCell, True);
        FSelection.AddCellRange(Th5uCellRange.Create(LHit.RowIndex, LHit.RowIndex, LHit.ColumnIndex, LHit.ColumnIndex), ssCtrl in Shift);
      end;
  end;
end;

procedure Th5uFmxGrid.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FLastMousePoint := PointF(X, Y);
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
  FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);
  FVScrollBar.Value := FVerticalOffset;
  Repaint;
  Handled := True;
end;

procedure Th5uFmxGrid.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  if not FCustomization.AllowColumnMoving then
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
  Canvas.FillRect(LocalRect, 0, 0, AllCorners, 1);

  UpdateScrollBars;
  BuildColumnLayout;
  BeginVisualPass;

  DrawContentPadding;

  LViewport := GetViewportRect;
  Canvas.Fill.Color := ResolveDefaultCellColor;
  Canvas.FillRect(LViewport, 0, 0, AllCorners, 1);

  DrawHeaders;
  DrawRows;
end;

function Th5uFmxGrid.ParseEditorValue(AColumn: Th5uGridColumn; const AText: string): TValue;
var
  LInt: Int64;
  LFloat: Double;
  LCurrency: Currency;
  LDateTime: TDateTime;
begin
  case AColumn.DataType of
    Th5uColumnDataType.Integer:
      begin
        if not TryStrToInt64(AText, LInt) then
          raise EConvertError.Create('Ungültige ganze Zahl.');
        Result := TValue.From<Int64>(LInt);
      end;
    Th5uColumnDataType.Float:
      begin
        if not TryStrToFloat(AText, LFloat) then
          raise EConvertError.Create('Ungültige Zahl.');
        Result := TValue.From<Double>(LFloat);
      end;
    Th5uColumnDataType.Currency:
      begin
        if not TryStrToCurr(AText, LCurrency) then
          raise EConvertError.Create('Ungültiger Betrag.');
        Result := TValue.From<Currency>(LCurrency);
      end;
    Th5uColumnDataType.Date,
    Th5uColumnDataType.DateTime:
      begin
        if not TryStrToDateTime(AText, LDateTime) then
          raise EConvertError.Create('Ungültiges Datum.');
        Result := TValue.From<TDateTime>(LDateTime);
      end;
    else
      Result := TValue.From<string>(AText);
  end;
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
begin
  Repaint;
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
  FThumbHint.Text := LText;
  FThumbHint.TextSettings.FontColor := LPalette.ThumbHintText;
  FThumbHint.TextSettings.Font.Size := FTextSize;
  FThumbHint.Width := Min(Max(120, Length(LText) * FTextSize * 0.55 + 20), Width - 20);
  FThumbHint.Height := 32;

  if AAxis = Th5uScrollAxis.Vertical then
  begin
    if FVScrollBar.Max > 0 then
      LRatio := FVerticalOffset / FVScrollBar.Max
    else
      LRatio := 0;
    LX := GetViewportRect.Right - FThumbHint.Width - 8;
    LY := GetViewportRect.Top + (GetViewportRect.Height - FThumbHint.Height) * LRatio;
  end
  else
  begin
    if FHScrollBar.Max > 0 then
      LRatio := FHorizontalOffset / FHScrollBar.Max
    else
      LRatio := 0;
    LX := GetViewportRect.Left + (GetViewportRect.Width - FThumbHint.Width) * LRatio;
    LY := GetViewportRect.Bottom - FThumbHint.Height - 8;
  end;

  FThumbHint.Position.Point := PointF(LX, LY);
  FThumbHint.Visible := True;
  FThumbHint.BringToFront;
  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Enabled := True;
end;

procedure Th5uFmxGrid.StartEdit(const AHit: Th5uFmxHitTestInfo);
var
  LKind: Th5uColumnEditorKind;
  LValue: TValue;
  LCell: Th5uCellAddress;
  LImageEditor: Th5uFmxImageEditor;
begin
  if not FAllowEditing or not Assigned(FDataController) or not Assigned(AHit.Column) or AHit.Column.ReadOnly
    or not CanEditViewValue(AHit.RowIndex, AHit.Column.FieldName) then
    Exit;

  LCell.RowIndex := AHit.RowIndex;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnId := AHit.Column.Id;
  FSelection.SetFocus(LCell, True);

  LKind := AHit.Column.EditorKind;
  if LKind = Th5uColumnEditorKind.Automatic then
    case AHit.Column.DataType of
      Th5uColumnDataType.Boolean:
        LKind := Th5uColumnEditorKind.Boolean;
      Th5uColumnDataType.Image:
        LKind := Th5uColumnEditorKind.Image;
      else
        LKind := Th5uColumnEditorKind.Text;
    end;

  case LKind of
    Th5uColumnEditorKind.Boolean:
      begin
        LValue := GetViewValue(AHit.RowIndex, AHit.Column.FieldName);
        SetViewValue(AHit.RowIndex, AHit.Column.FieldName, TValue.From<Boolean>(LValue.IsEmpty or not LValue.AsBoolean));
      end;

    Th5uColumnEditorKind.Image:
      begin
        if not Assigned(FImageEditor) then
        begin
          LImageEditor := Th5uFmxImageEditor.Create(Self);
          LImageEditor.Parent := Self;
          LImageEditor.OnCommit := ImageEditorCommit;
          LImageEditor.OnCancel := ImageEditorCancel;
          FImageEditor := LImageEditor;
        end
        else
          LImageEditor := Th5uFmxImageEditor(FImageEditor);

        FEditRowIndex := AHit.RowIndex;
        FEditColumn := AHit.Column;
        LValue := GetViewValue(AHit.RowIndex, AHit.Column.FieldName);
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
        FEditColumn := AHit.Column;
        FEditor.Text := GetViewDisplayText(AHit.RowIndex, AHit.Column.FieldName, AHit.Column.DisplayFormat);
        FEditor.SetBounds(AHit.Bounds.Left, AHit.Bounds.Top, AHit.Bounds.Width, AHit.Bounds.Height);
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
    FHScrollBar.Max := Max(0.0, LContentWidth - LAvailableWidth);
    FHScrollBar.ViewportSize := LAvailableWidth;
    FVScrollBar.Min := 0;
    FVScrollBar.Max := Max(0.0, LContentHeight - LAvailableHeight);
    FVScrollBar.ViewportSize := LAvailableHeight;

    FHorizontalOffset := EnsureRange(FHorizontalOffset, 0, FHScrollBar.Max);
    FVerticalOffset := EnsureRange(FVerticalOffset, 0, FVScrollBar.Max);
    FHScrollBar.Value := FHorizontalOffset;
    FVScrollBar.Value := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
  end;
end;

end.
