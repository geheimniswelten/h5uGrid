unit Vcl.h5u.Grid;

interface

{$SCOPEDENUMS ON}

uses
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Menus,
  Vcl.StdCtrls,
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
    DataCell
  );

  Th5uGetRowHeightContext = record
    Grid: Th5uVclGrid;
    DataController: Th5uCustomDataController;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    SourceRowIndex: Int64;
    IsEstimated: Boolean;
  end;

  Th5uGetRowHeightEvent = procedure(
    Sender: TObject;
    const AContext: Th5uGetRowHeightContext;
    var AHeight: Integer;
    var ACacheResult: Boolean
  ) of object;

  Th5uGetRowSpacingEvent = procedure(
    Sender: TObject;
    const AContext: Th5uGetRowHeightContext;
    var ASpacing: Integer
  ) of object;

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

  Th5uGetThumbHintEvent = procedure(
    Sender: TObject;
    const AContext: Th5uThumbHintContext;
    var AText: string;
    var AVisible: Boolean
  ) of object;

  Th5uRowAppearanceEvent = procedure(
    Sender: TObject;
    AViewRowIndex: Int64;
    const ARowKey: Th5uRowKey;
    var AAppearance: Th5uResolvedAppearance
  ) of object;

  Th5uCellAppearanceEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    var AAppearance: Th5uResolvedAppearance
  ) of object;

  Th5uVclDrawContext = record
    FactoryContext: Th5uFactoryContext;
    Bounds: TRect;
    DisplayText: string;
    Appearance: Th5uResolvedAppearance;
  end;

  Th5uVclCustomDrawEvent = procedure(
    Sender: TObject;
    ACanvas: TCanvas;
    const AContext: Th5uVclDrawContext;
    AStage: Th5uCustomDrawStage;
    var ADrawDefault: Boolean
  ) of object;

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
    procedure PaintDefault(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
    ); virtual;
    function EffectiveBackground(
      AGrid: Th5uVclGrid
    ): TColor;
    function EffectiveForeground(
      AGrid: Th5uVclGrid
    ): TColor;
  public
    procedure BindCell(
      const AContext: Th5uFactoryContext;
      const ABounds: TRect;
      const AValue: TValue;
      const ADisplayText: string;
      const AAppearance: Th5uResolvedAppearance
    ); virtual;
    procedure Paint(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
    ); virtual;

    property Context: Th5uFactoryContext read FContext;
    property Bounds: TRect read FBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: Th5uResolvedAppearance read FAppearance;
  end;

  Th5uVclDataCell = class(Th5uVclVisualCell)
  private
    FPicture: TPicture;
    FPictureSignature: Integer;
    procedure EnsurePicture;
  protected
    procedure PaintDefault(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
    ); override;
  public
    destructor Destroy; override;
  end;

  Th5uVclHeaderCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
    ); override;
  end;

  Th5uVclFixedCell = class(Th5uVclDataCell);

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
    procedure SetSelection(const AValue: Th5uGridSelection);
    procedure SetGridLines(const AValue: Boolean);
    procedure SetHeaderRowHeight(const AValue: Integer);
    procedure SetRowIndicatorWidth(const AValue: Integer);

    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(
      const AValue: Th5uConfigureInstanceEvent
    );

    procedure ScrollBarScroll(
      Sender: TObject;
      ScrollCode: TScrollCode;
      var ScrollPos: Integer
    );
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(
      Sender: TObject;
      var Key: Word;
      Shift: TShiftState
    );

    function GetUnpaddedViewportRect: TRect;
    function GetViewportRect: TRect;
    function GetHeaderHeight: Integer;
    function GetDataViewportRect: TRect;
    function GetTotalColumnWidth: Integer;
    function GetEffectiveColumnRightSpacing(
      AColumn: Th5uGridColumn
    ): Integer;
    function GetRowSpacingFor(
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey
    ): Integer;
    function GetGridLines: Boolean;
    function ResolveColor(
      const AColor: Th5uColor;
      AFallback: TColor
    ): TColor;
    function ResolveDefaultCellColor: TColor;
    function ResolveRowSpacingColor: TColor;
    function ResolveColumnSpacingColor: TColor;
    function ResolveContentPaddingColor: TColor;
    function GetEstimatedTotalRowHeight: Int64;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(
      const AContext: Th5uFactoryContext;
      ADefaultClass: Th5uVclVisualCellClass
    ): Th5uVclVisualCell;

    procedure DrawContentPadding;
    procedure DrawHeaders;
    procedure DrawRows;
    procedure DrawSpacingRect(
      const ABounds: TRect;
      AElementKind: Th5uElementKind;
      AColumn: Th5uGridColumn;
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey;
      AColor: TColor
    );
    procedure DrawDefaultHeaders;
    procedure DrawCustomHeaderLayout;
    procedure DrawRowIndicator(
      const ARowInfo: Th5uVisibleRowInfo;
      ASelected: Boolean
    );

    function GetRowHeightFor(
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey;
      AAllowMeasure: Boolean = True
    ): Integer;
    function MeasureCellHeight(
      AViewRowIndex: Int64;
      AColumn: Th5uGridColumn
    ): Integer;
    function FindFirstVisibleRow(
      AOffset: Int64;
      out ATop: Integer
    ): Int64;
    function GetRowStyle(
      AViewRowIndex: Int64;
      out AStyleKey: TValue
    ): string;
    function ResolveRowAppearance(
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey;
      const AStyleName: string
    ): Th5uResolvedAppearance;
    function ResolveCellAppearance(
      const AContext: Th5uFactoryContext;
      AColumn: Th5uGridColumn;
      const ARowAppearance: Th5uResolvedAppearance;
      ASelected, AFocused: Boolean
    ): Th5uResolvedAppearance;

    function ColumnInfoAtPoint(
      X, Y: Integer;
      out AInfo: Th5uVisibleColumnInfo
    ): Boolean;
    function RowInfoAtPoint(
      X, Y: Integer;
      out AInfo: Th5uVisibleRowInfo
    ): Boolean;

    procedure ShowThumbHint(
      AAxis: Th5uScrollAxis;
      ATrigger: Th5uScrollHintTrigger
    );
    procedure HideThumbHint;
    function BuildThumbHintText(
      AAxis: Th5uScrollAxis;
      ATrigger: Th5uScrollHintTrigger;
      out AContext: Th5uThumbHintContext
    ): string;

    procedure StartEdit(const AHit: Th5uHitTestInfo);
    procedure CommitEditor;
    procedure CancelEditor;
    function ParseEditorValue(
      AColumn: Th5uGridColumn;
      const AText: string
    ): TValue;

    procedure ShowColumnChooser;
    procedure ColumnChooserClick(Sender: TObject);
    procedure RebuildAfterLayoutChange;

    function GetVisualCellClass(
      const AContext: Th5uFactoryContext;
      ADefaultClass: Th5uVclVisualCellClass
    ): Th5uVclVisualCellClass; virtual;

    procedure DoCustomDraw(
      ACanvas: TCanvas;
      const AContext: Th5uVclDrawContext;
      AStage: Th5uCustomDrawStage;
      var ADrawDefault: Boolean
    );
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    ); override;
    procedure MouseDown(
      Button: TMouseButton;
      Shift: TShiftState;
      X, Y: Integer
    ); override;
    procedure MouseMove(
      Shift: TShiftState;
      X, Y: Integer
    ); override;
    procedure MouseUp(
      Button: TMouseButton;
      Shift: TShiftState;
      X, Y: Integer
    ); override;
    procedure DblClick; override;
    function DoMouseWheel(
      Shift: TShiftState;
      WheelDelta: Integer;
      MousePos: TPoint
    ): Boolean; override;

    function GetDataCellClass(
      const AContext: Th5uFactoryContext
    ): Th5uVclVisualCellClass; virtual;
    function GetHeaderCellClass(
      const AContext: Th5uFactoryContext
    ): Th5uVclVisualCellClass; virtual;
    function GetFixedCellClass(
      const AContext: Th5uFactoryContext
    ): Th5uVclVisualCellClass; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure InvalidateRowHeight(const ARowKey: Th5uRowKey);
    procedure InvalidateVisibleRowHeights;
    procedure InvalidateAllRowHeights;

    function HitTest(X, Y: Integer): Th5uHitTestInfo;
    procedure MoveColumn(
      AColumn: Th5uGridColumn;
      ANewVisibleIndex: Integer
    );
    procedure SetColumnVisible(
      AColumn: Th5uGridColumn;
      AVisible: Boolean
    );
    procedure AutoCreateColumnsFromDataSet(
      AClearExisting: Boolean = True
    );

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

    property DataController: Th5uCustomDataController
      read FDataController write SetDataController;
    property SharedClassFactory: Th5uClassFactory
      read FSharedClassFactory write SetSharedClassFactory;
    property Columns: Th5uGridColumns
      read FColumns write SetColumns;
    property HeaderLayout: Th5uHeaderLayout
      read FHeaderLayout write SetHeaderLayout;
    property Selection: Th5uGridSelection
      read FSelection write SetSelection;
    property RowHeight: Th5uRowHeightOptions
      read FRowHeight write SetRowHeight;
    property Scrolling: Th5uScrollingOptions
      read FScrolling write SetScrolling;
    property ScrollHints: Th5uScrollHintOptions
      read FScrollHints write SetScrollHints;
    property RowStyles: Th5uRowStyleOptions
      read FRowStyles write SetRowStyles;
    property Customization: Th5uCustomizationOptions
      read FCustomization write SetCustomization;
    property Spacing: Th5uGridSpacingOptions
      read FSpacing write SetSpacing;
    property Appearance: Th5uGridAppearanceOptions
      read FAppearance write SetAppearance;

    property Theme: Th5uGridTheme
      read FTheme write SetTheme
      default Th5uGridTheme.ApplicationStyle;
    property HeaderRowHeight: Integer
      read FHeaderRowHeight write SetHeaderRowHeight default 26;
    property RowIndicatorWidth: Integer
      read FRowIndicatorWidth write SetRowIndicatorWidth default 34;
    property ShowHeader: Boolean
      read FShowHeader write FShowHeader default True;
    property ShowRowIndicator: Boolean
      read FShowRowIndicator write FShowRowIndicator default True;
    property AllowEditing: Boolean
      read FAllowEditing write FAllowEditing default True;
    // Convenience switch for all grid-wide one-pixel separators.
    // Explicit per-column RightSpacing values remain independently configurable.
    property GridLines: Boolean
      read GetGridLines write SetGridLines default True;

    property OnGetClass: Th5uGetClassEvent
      read GetOnGetClass write SetOnGetClass;
    property OnCreateInstance: Th5uCreateInstanceEvent
      read GetOnCreateInstance write SetOnCreateInstance;
    property OnConfigureInstance: Th5uConfigureInstanceEvent
      read GetOnConfigureInstance write SetOnConfigureInstance;
    property OnGetRowHeight: Th5uGetRowHeightEvent
      read FOnGetRowHeight write FOnGetRowHeight;
    property OnGetRowSpacing: Th5uGetRowSpacingEvent
      read FOnGetRowSpacing write FOnGetRowSpacing;
    property OnGetThumbHint: Th5uGetThumbHintEvent
      read FOnGetThumbHint write FOnGetThumbHint;
    property OnGetRowAppearance: Th5uRowAppearanceEvent
      read FOnGetRowAppearance write FOnGetRowAppearance;
    property OnGetCellAppearance: Th5uCellAppearanceEvent
      read FOnGetCellAppearance write FOnGetCellAppearance;
    property OnCustomDraw: Th5uVclCustomDrawEvent
      read FOnCustomDraw write FOnCustomDraw;
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
  h5u.Grid.Data.DataSet,
  Vcl.h5u.Grid.Editors;

type
  Th5uAccessGridColumn = class(Th5uGridColumn);

{ Utilities }

function h5uRectIntersects(const A, B: TRect): Boolean;
begin
  Result :=
    (A.Right > B.Left) and
    (A.Left < B.Right) and
    (A.Bottom > B.Top) and
    (A.Top < B.Bottom);
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

procedure Th5uVclVisualCell.BindCell(
  const AContext: Th5uFactoryContext;
  const ABounds: TRect;
  const AValue: TValue;
  const ADisplayText: string;
  const AAppearance: Th5uResolvedAppearance);
begin
  FContext := AContext;
  FBounds := ABounds;
  FValue := AValue;
  FDisplayText := ADisplayText;
  FAppearance := AAppearance;
end;

function Th5uVclVisualCell.EffectiveBackground(
  AGrid: Th5uVclGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasBackground then
    Result := h5uColorToVcl(FAppearance.Background)
  else
    Result := AGrid.ResolveDefaultCellColor;
end;

function Th5uVclVisualCell.EffectiveForeground(
  AGrid: Th5uVclGrid): TColor;
var
  LPalette: Th5uVclPalette;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);
  if FAppearance.HasForeground then
    Result := h5uColorToVcl(FAppearance.Foreground)
  else
    Result := LPalette.CellText;
end;

procedure Th5uVclVisualCell.Paint(
  AGrid: Th5uVclGrid; ACanvas: TCanvas);
var
  LDrawContext: Th5uVclDrawContext;
  LDrawDefault: Boolean;
begin
  LDrawContext.FactoryContext := FContext;
  LDrawContext.Bounds := FBounds;
  LDrawContext.DisplayText := FDisplayText;
  LDrawContext.Appearance := FAppearance;

  LDrawDefault := True;
  AGrid.DoCustomDraw(
    ACanvas,
    LDrawContext,
    Th5uCustomDrawStage.BeforeDefault,
    LDrawDefault
  );

  if LDrawDefault then
    PaintDefault(AGrid, ACanvas);

  AGrid.DoCustomDraw(
    ACanvas,
    LDrawContext,
    Th5uCustomDrawStage.AfterDefault,
    LDrawDefault
  );
end;

procedure Th5uVclVisualCell.PaintDefault(
  AGrid: Th5uVclGrid; ACanvas: TCanvas);
begin
  // Separators are independent layout elements. Painting them around every
  // cell would double their width and would make per-column spacing impossible.
  ACanvas.Brush.Color := EffectiveBackground(AGrid);
  ACanvas.FillRect(FBounds);
end;

destructor Th5uVclDataCell.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
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
    LSignature := LSignature xor LBytes[0] xor
      (Integer(LBytes[High(LBytes)]) shl 8);

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

procedure Th5uVclDataCell.PaintDefault(
  AGrid: Th5uVclGrid; ACanvas: TCanvas);
var
  LColumn: Th5uGridColumn;
  LTextRect: TRect;
  LFlags: Cardinal;
  LCheckRect: TRect;
  LChecked: Boolean;
  LImageRect: TRect;
  LScale: Double;
  LWidth: Integer;
  LHeight: Integer;
  LPalette: Th5uVclPalette;
begin
  inherited PaintDefault(AGrid, ACanvas);
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
        LCheckRect := Rect(
          Bounds.Left + (Bounds.Width - 14) div 2,
          Bounds.Top + (Bounds.Height - 14) div 2,
          Bounds.Left + (Bounds.Width - 14) div 2 + 14,
          Bounds.Top + (Bounds.Height - 14) div 2 + 14
        );
        LChecked := False;
        if not Value.IsEmpty then
        begin
          if Value.Kind = tkEnumeration then
            LChecked := Value.AsBoolean
          else
            LChecked := SameText(Value.ToString, 'True') or
              (Value.ToString = '1');
        end;

        ACanvas.Pen.Color := LPalette.CellText;
        ACanvas.Brush.Color := EffectiveBackground(AGrid);
        ACanvas.Rectangle(LCheckRect);
        if LChecked then
        begin
          ACanvas.Pen.Width := 2;
          ACanvas.Pen.Color := LPalette.SelectedBackground;
          ACanvas.MoveTo(LCheckRect.Left + 3, LCheckRect.Top + 7);
          ACanvas.LineTo(LCheckRect.Left + 6, LCheckRect.Bottom - 3);
          ACanvas.LineTo(LCheckRect.Right - 2, LCheckRect.Top + 3);
          ACanvas.Pen.Width := 1;
        end;
      end;

    Th5uColumnDataType.Image:
      begin
        EnsurePicture;
        if Assigned(FPicture) and Assigned(FPicture.Graphic) and
           not FPicture.Graphic.Empty then
        begin
          LImageRect := Bounds;
          InflateRect(LImageRect, -4, -4);
          if LColumn.ImagePreserveAspectRatio then
          begin
            LScale := Min(
              LImageRect.Width / FPicture.Graphic.Width,
              LImageRect.Height / FPicture.Graphic.Height
            );
            LWidth := Max(1, Round(FPicture.Graphic.Width * LScale));
            LHeight := Max(1, Round(FPicture.Graphic.Height * LScale));
            LImageRect := Rect(
              LImageRect.Left + (LImageRect.Width - LWidth) div 2,
              LImageRect.Top + (LImageRect.Height - LHeight) div 2,
              LImageRect.Left + (LImageRect.Width - LWidth) div 2 + LWidth,
              LImageRect.Top + (LImageRect.Height - LHeight) div 2 + LHeight
            );
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

      DrawText(
        ACanvas.Handle,
        PChar(DisplayText),
        Length(DisplayText),
        LTextRect,
        LFlags
      );
    end;
  end;

  if Th5uElementFlag.Focused in Context.ElementFlags then
  begin
    ACanvas.Pen.Color := LPalette.FocusBorder;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(Bounds);
    ACanvas.Brush.Style := bsSolid;
  end;
end;

{ Th5uVclHeaderCell }

procedure Th5uVclHeaderCell.PaintDefault(
  AGrid: Th5uVclGrid; ACanvas: TCanvas);
var
  LPalette: Th5uVclPalette;
  LTextRect: TRect;
  LDetails: TThemedElementDetails;
begin
  LPalette := h5uGetVclPalette(AGrid.Theme);

  if (AGrid.Theme = Th5uGridTheme.ApplicationStyle) and
     StyleServices.Enabled then
  begin
    LDetails := StyleServices.GetElementDetails(thHeaderItemNormal);
    StyleServices.DrawElement(ACanvas.Handle, LDetails, Bounds);
  end
  else
  begin
    ACanvas.Brush.Color := LPalette.HeaderBackground;
    ACanvas.FillRect(Bounds);
  end;

  ACanvas.Font.Assign(AGrid.Font);
  ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  ACanvas.Font.Color := LPalette.HeaderText;
  ACanvas.Brush.Style := bsClear;
  LTextRect := Bounds;
  InflateRect(LTextRect, -5, -2);
  DrawText(
    ACanvas.Handle,
    PChar(DisplayText),
    Length(DisplayText),
    LTextRect,
    DT_NOPREFIX or DT_CENTER or DT_VCENTER or
    DT_SINGLELINE or DT_END_ELLIPSIS
  );
  ACanvas.Brush.Style := bsSolid;
end;

function Th5uVclGrid.AcquireVisualCell(
  const AContext: Th5uFactoryContext;
  ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCell;
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
  LCreateContext.CreationReason :=
    Th5uCreationReason.ViewportMaterialization;

  Result := Th5uVclVisualCell(
    FFactoryScope.CreateInstance(
      LCreateContext,
      Th5uVclVisualCell,
      LClass
    )
  );
  Result.FInUse := True;
  FCellPool.Add(Result);
  FFactoryScope.BindInstance(AContext, Result);
end;

procedure Th5uVclGrid.AutoCreateColumnsFromDataSet(
  AClearExisting: Boolean);
var
  LController: Th5uDataSetController;
  LField: TField;
  LColumn: Th5uGridColumn;
begin
  if not (FDataController is Th5uDataSetController) then
    Exit;

  LController := Th5uDataSetController(FDataController);
  if not Assigned(LController.DataSet) then
    Exit;

  FColumns.BeginUpdate;
  try
    if AClearExisting then
      FColumns.Clear;

    for LField in LController.DataSet.Fields do
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
        ftSmallint, ftInteger, ftWord, ftAutoInc,
        ftShortint, ftByte, ftLargeint:
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

        ftTime, ftDateTime, ftTimeStamp:
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

function Th5uVclGrid.BuildThumbHintText(
  AAxis: Th5uScrollAxis;
  ATrigger: Th5uScrollHintTrigger;
  out AContext: Th5uThumbHintContext): string;
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
    if not Assigned(FDataController) or
       (FDataController.GetRowCount = 0) then
      Exit;

    LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
    if LRowIndex < 0 then
      Exit;

    AContext.ScrollOffset := FVerticalOffset;
    AContext.ScrollRange := FVScrollBar.Max;
    AContext.ViewRowIndex := LRowIndex;
    AContext.RowKey := FDataController.GetRowKey(LRowIndex);

    LColumn := FColumns.FindById(
      FScrollHints.VerticalColumnId
    );
    if not Assigned(LColumn) then
    begin
      LColumns := FColumns.VisibleColumns;
      if Length(LColumns) > 0 then
        LColumn := LColumns[0];
    end;

    AContext.Column := LColumn;
    if Assigned(LColumn) then
    begin
      AContext.Value := FDataController.GetValue(
        LRowIndex,
        LColumn.FieldName
      );
      AContext.DisplayText := FDataController.GetDisplayText(
        LRowIndex,
        LColumn.FieldName,
        LColumn.DisplayFormat
      );
      AContext.IsValueAvailable := not AContext.Value.IsEmpty;
      Result := AContext.DisplayText;
    end;

    if FScrollHints.ShowRowPosition then
    begin
      if Result <> '' then
        Result := Result + ' — ';
      Result := Result + Format(
        'Zeile %d von %d',
        [LRowIndex + 1, FDataController.GetRowCount]
      );
    end;
  end
  else
  begin
    AContext.ScrollOffset := FHorizontalOffset;
    AContext.ScrollRange := FHScrollBar.Max;
    LColumn := nil;
    for LInfo in FAllColumns do
      if (LInfo.Column.FixedKind = Th5uFixedKind.None) and
         (LInfo.Bounds.Right > GetDataViewportRect.Left) then
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
      Inc(
        LDataLeft,
        FRowIndicatorWidth + FSpacing.DefaultColumnRightSpacing
      );
    LDataRight := LViewRect.Right;

    LLeftX := LDataLeft;
    for I := 0 to High(LColumns) do
      if LColumns[I].FixedKind = Th5uFixedKind.Left then
        Inc(
          LLeftX,
          LColumns[I].Width +
          GetEffectiveColumnRightSpacing(LColumns[I])
        );

    LRightX := LDataRight;
    for I := High(LColumns) downto 0 do
      if LColumns[I].FixedKind = Th5uFixedKind.Right then
        Dec(
          LRightX,
          LColumns[I].Width +
          GetEffectiveColumnRightSpacing(LColumns[I])
        );

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
            LInfo.Bounds := Rect(
              LLeftX,
              LViewRect.Top,
              LLeftX + LColumn.Width,
              LViewRect.Bottom
            );
            Inc(LLeftX, LColumn.Width + LSpacing);
          end;

        Th5uFixedKind.Right:
          begin
            LInfo.Bounds := Rect(
              LRightX,
              LViewRect.Top,
              LRightX + LColumn.Width,
              LViewRect.Bottom
            );
            Inc(LRightX, LColumn.Width + LSpacing);
          end;

      else
        begin
          LInfo.Bounds := Rect(
            LNormalX,
            LViewRect.Top,
            LNormalX + LColumn.Width,
            LViewRect.Bottom
          );
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
  if Assigned(FEditor) then
    FEditor.Visible := False;
  FEditColumn := nil;
  FEditRowIndex := -1;
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

function Th5uVclGrid.ColumnInfoAtPoint(
  X, Y: Integer; out AInfo: Th5uVisibleColumnInfo): Boolean;
var
  LInfo: Th5uVisibleColumnInfo;
begin
  for LInfo in FVisibleColumns do
    if PtInRect(LInfo.Bounds, Point(X, Y)) then
    begin
      AInfo := LInfo;
      Exit(True);
    end;
  Result := False;
end;

procedure Th5uVclGrid.ColumnsChanged(
  Sender: TObject; AColumn: Th5uGridColumn);
begin
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.CommitEditor;
var
  LValue: TValue;
begin
  if FCommittingEditor or not Assigned(FEditor) or
     not FEditor.Visible or not Assigned(FEditColumn) or
     not Assigned(FDataController) then
    Exit;

  FCommittingEditor := True;
  try
    try
      LValue := ParseEditorValue(FEditColumn, FEditor.Text);
      FDataController.SetValue(
        FEditRowIndex,
        FEditColumn.FieldName,
        LValue
      );
      FEditor.Visible := False;
      FEditColumn := nil;
      FEditRowIndex := -1;
      InvalidateAllRowHeights;
      Invalidate;
    except
      on E: Exception do
      begin
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
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];
  Width := 640;
  Height := 320;
  TabStop := True;
  DoubleBuffered := True;

  FFactoryScope := Th5uFactoryScope.Create(Self);
  FFactoryScope.Parent := h5uGlobalFactoryScope;
  FFactoryScope.RegisterClass(
    h5uClassIdGridDataCell,
    Th5uVclVisualCell,
    Th5uVclDataCell
  );
  FFactoryScope.RegisterClass(
    h5uClassIdGridFixedCell,
    Th5uVclVisualCell,
    Th5uVclFixedCell
  );
  FFactoryScope.RegisterClass(
    h5uClassIdGridHeaderCell,
    Th5uVclVisualCell,
    Th5uVclHeaderCell
  );
  FFactoryScope.RegisterClass(
    h5uClassIdGridHeaderGroupCell,
    Th5uVclVisualCell,
    Th5uVclHeaderCell
  );

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
  FEditor.Parent := Self;
  FEditor.Visible := False;
  FEditor.OnExit := EditorExit;
  FEditor.OnKeyDown := EditorKeyDown;

  LayoutScrollBars;
end;

procedure Th5uVclGrid.DataChanged(
  Sender: TObject; const AChange: Th5uDataChange);
begin
  CancelEditor;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

destructor Th5uVclGrid.Destroy;
begin
  FDataLink.Controller := nil;
  FRowHeightCache.Free;
  FCellPool.Free;
  FDataLink.Free;
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
  inherited Destroy;
end;

procedure Th5uVclGrid.DblClick;
var
  LPoint: TPoint;
  LHit: Th5uHitTestInfo;
begin
  inherited DblClick;
  LPoint := ScreenToClient(Mouse.CursorPos);
  LHit := HitTest(LPoint.X, LPoint.Y);
  if LHit.Kind = Th5uHitKind.DataCell then
    StartEdit(LHit);
end;

procedure Th5uVclGrid.DoCustomDraw(
  ACanvas: TCanvas;
  const AContext: Th5uVclDrawContext;
  AStage: Th5uCustomDrawStage;
  var ADrawDefault: Boolean);
begin
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(
      Self,
      ACanvas,
      AContext,
      AStage,
      ADrawDefault
    );
end;

function Th5uVclGrid.DoMouseWheel(
  Shift: TShiftState;
  WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  LDelta: Integer;
begin
  LDelta := FScrolling.WheelRows *
    (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);

  if WheelDelta > 0 then
    Dec(FVerticalOffset, LDelta)
  else
    Inc(FVerticalOffset, LDelta);

  FVerticalOffset := EnsureRange(
    FVerticalOffset,
    0,
    FVScrollBar.Max
  );

  if FScrolling.VerticalMode =
     Th5uVerticalScrollMode.WholeRows then
  begin
    FindFirstVisibleRow(FVerticalOffset, LDelta);
    FVerticalOffset := EnsureRange(
      FVerticalOffset +
        (LDelta - GetDataViewportRect.Top),
      0,
      FVScrollBar.Max
    );
  end;

  FVScrollBar.Position := FVerticalOffset;
  Invalidate;
  if Th5uScrollHintTrigger.MouseWheel in
     FScrollHints.Triggers then
    ShowThumbHint(
      Th5uScrollAxis.Vertical,
      Th5uScrollHintTrigger.MouseWheel
    );
  Result := True;
end;

procedure Th5uVclGrid.DrawCustomHeaderLayout;
var
  LCellDef: Th5uHeaderLayoutCell;
  LStartInfo: Th5uVisibleColumnInfo;
  LEndInfo: Th5uVisibleColumnInfo;
  LRect: TRect;
  LSeparatorRect: TRect;
  LContext: Th5uFactoryContext;
  LCell: Th5uVclVisualCell;
  LAppearance: Th5uResolvedAppearance;
  LViewRect: TRect;
  LClassId: Th5uClassId;
  LRightSpacing: Integer;
  LRowSpacing: Integer;
begin
  LViewRect := GetViewportRect;
  LRowSpacing := FSpacing.RowSpacing;
  for LCellDef in FHeaderLayout.Cells do
  begin
    if (LCellDef.LayoutColumn < 0) or
       (LCellDef.LayoutColumn >= Length(FAllColumns)) then
      Continue;

    LStartInfo := FAllColumns[LCellDef.LayoutColumn];
    LEndInfo := FAllColumns[
      Min(
        High(FAllColumns),
        LCellDef.LayoutColumn + Max(1, LCellDef.ColumnSpan) - 1
      )
    ];

    LRect := Rect(
      LStartInfo.Bounds.Left,
      LViewRect.Top +
        LCellDef.LayoutRow * (FHeaderRowHeight + LRowSpacing),
      LEndInfo.Bounds.Right,
      LViewRect.Top +
        LCellDef.LayoutRow * (FHeaderRowHeight + LRowSpacing) +
        Max(1, LCellDef.RowSpan) * FHeaderRowHeight +
        (Max(1, LCellDef.RowSpan) - 1) * LRowSpacing
    );

    if not h5uRectIntersects(LRect, LViewRect) then
      Continue;

    IntersectRect(LRect, LRect, LViewRect);
    LClassId := LCellDef.ClassId;
    if string(LClassId) = '' then
      LClassId := h5uClassIdGridHeaderGroupCell;

    LContext := Th5uFactoryContext.Create(
      Self,
      Self,
      FDataController,
      LClassId,
      Th5uElementKind.ColumnHeaderGroupCell
    );
    LContext.HeaderCell := LCellDef;
    LContext.LayoutRow := LCellDef.LayoutRow;
    LContext.LayoutColumn := LCellDef.LayoutColumn;
    LContext.RowSpan := LCellDef.RowSpan;
    LContext.ColumnSpan := LCellDef.ColumnSpan;
    LContext.ElementFlags := [Th5uElementFlag.Header];

    if LCellDef.ColumnId <> '' then
    begin
      LContext.Column := FColumns.FindById(LCellDef.ColumnId);
      LContext.ElementKind := Th5uElementKind.ColumnHeaderCell;
    end;

    LAppearance.Clear;
    LAppearance.StyleName := LCellDef.StyleName;

    LCell := AcquireVisualCell(LContext, Th5uVclHeaderCell);
    LCell.BindCell(
      LContext,
      LRect,
      TValue.Empty,
      LCellDef.Caption,
      LAppearance
    );
    LCell.Paint(Self, Canvas);

    LRightSpacing := GetEffectiveColumnRightSpacing(LEndInfo.Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(
        LRect.Right,
        LRect.Top,
        Min(LRect.Right + LRightSpacing, LViewRect.Right),
        LRect.Bottom
      );
      if not IsRectEmpty(LSeparatorRect) then
        DrawSpacingRect(
          LSeparatorRect,
          Th5uElementKind.ColumnSpacing,
          LEndInfo.Column,
          -1,
          Th5uRowKey.Empty,
          ResolveColumnSpacingColor
        );
    end;

    if LRowSpacing > 0 then
    begin
      LSeparatorRect := Rect(
        LRect.Left,
        LRect.Bottom,
        LRect.Right + LRightSpacing,
        Min(LRect.Bottom + LRowSpacing, LViewRect.Bottom)
      );
      IntersectRect(LSeparatorRect, LSeparatorRect, LViewRect);
      if not IsRectEmpty(LSeparatorRect) then
        DrawSpacingRect(
          LSeparatorRect,
          Th5uElementKind.RowSpacing,
          LContext.Column,
          -1,
          Th5uRowKey.Empty,
          ResolveRowSpacingColor
        );
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
    IntersectRect(LDrawRect, LDrawRect, GetViewportRect);
    if not IsRectEmpty(LDrawRect) then
    begin
      LClassId := LInfo.Column.HeaderCellClassId;
      if string(LClassId) = '' then
        LClassId := h5uClassIdGridHeaderCell;

      LContext := Th5uFactoryContext.Create(
        Self,
        Self,
        FDataController,
        LClassId,
        Th5uElementKind.ColumnHeaderCell
      );
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
      LCell.BindCell(
        LContext,
        LDrawRect,
        TValue.Empty,
        LInfo.Column.Caption,
        LAppearance
      );
      LCell.Paint(Self, Canvas);
    end;

    // The separator remains visible even if pixel scrolling starts inside it
    // and the corresponding cell itself is already outside the viewport.
    LRightSpacing := GetEffectiveColumnRightSpacing(LInfo.Column);
    if LRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(
        LRect.Right,
        LRect.Top,
        LRect.Right + LRightSpacing,
        LRect.Bottom
      );
      IntersectRect(LSeparatorRect, LSeparatorRect, GetViewportRect);
      if not IsRectEmpty(LSeparatorRect) then
        DrawSpacingRect(
          LSeparatorRect,
          Th5uElementKind.ColumnSpacing,
          LInfo.Column,
          -1,
          Th5uRowKey.Empty,
          ResolveColumnSpacingColor
        );
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
    LPaddingRect := Rect(
      LOuterRect.Left,
      LOuterRect.Top,
      LOuterRect.Right,
      LInnerRect.Top
    );
    DrawSpacingRect(
      LPaddingRect,
      Th5uElementKind.ContentPadding,
      nil,
      -1,
      Th5uRowKey.Empty,
      LColor
    );
  end;

  if LInnerRect.Bottom < LOuterRect.Bottom then
  begin
    LPaddingRect := Rect(
      LOuterRect.Left,
      LInnerRect.Bottom,
      LOuterRect.Right,
      LOuterRect.Bottom
    );
    DrawSpacingRect(
      LPaddingRect,
      Th5uElementKind.ContentPadding,
      nil,
      -1,
      Th5uRowKey.Empty,
      LColor
    );
  end;

  if LInnerRect.Left > LOuterRect.Left then
  begin
    LPaddingRect := Rect(
      LOuterRect.Left,
      LInnerRect.Top,
      LInnerRect.Left,
      LInnerRect.Bottom
    );
    DrawSpacingRect(
      LPaddingRect,
      Th5uElementKind.ContentPadding,
      nil,
      -1,
      Th5uRowKey.Empty,
      LColor
    );
  end;

  if LInnerRect.Right < LOuterRect.Right then
  begin
    LPaddingRect := Rect(
      LInnerRect.Right,
      LInnerRect.Top,
      LOuterRect.Right,
      LInnerRect.Bottom
    );
    DrawSpacingRect(
      LPaddingRect,
      Th5uElementKind.ContentPadding,
      nil,
      -1,
      Th5uRowKey.Empty,
      LColor
    );
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
    LRect := Rect(
      GetViewportRect.Left,
      GetViewportRect.Top,
      GetViewportRect.Left + FRowIndicatorWidth,
      Max(GetViewportRect.Top, LContentBottom)
    );
    LContext := Th5uFactoryContext.Create(
      Self,
      Self,
      FDataController,
      h5uClassIdGridHeaderCell,
      Th5uElementKind.CornerCell
    );
    LContext.ElementFlags := [
      Th5uElementFlag.Header,
      Th5uElementFlag.Corner,
      Th5uElementFlag.FixedColumn
    ];
    LAppearance.Clear;
    LCell := AcquireVisualCell(LContext, Th5uVclHeaderCell);
    LCell.BindCell(
      LContext,
      LRect,
      TValue.Empty,
      '',
      LAppearance
    );
    LCell.Paint(Self, Canvas);

    if FSpacing.DefaultColumnRightSpacing > 0 then
    begin
      LSeparatorRect := Rect(
        LRect.Right,
        LRect.Top,
        LRect.Right + FSpacing.DefaultColumnRightSpacing,
        LRect.Bottom
      );
      DrawSpacingRect(
        LSeparatorRect,
        Th5uElementKind.ColumnSpacing,
        nil,
        -1,
        Th5uRowKey.Empty,
        ResolveColumnSpacingColor
      );
    end;
  end;

  if FHeaderLayout.Enabled and
     (FHeaderLayout.Cells.Count > 0) then
    DrawCustomHeaderLayout
  else
    DrawDefaultHeaders;

  if FSpacing.RowSpacing > 0 then
  begin
    LSeparatorRect := Rect(
      LHeaderRect.Left,
      LHeaderRect.Bottom - FSpacing.RowSpacing,
      LHeaderRect.Right,
      LHeaderRect.Bottom
    );
    DrawSpacingRect(
      LSeparatorRect,
      Th5uElementKind.RowSpacing,
      nil,
      -1,
      Th5uRowKey.Empty,
      ResolveRowSpacingColor
    );
  end;
end;

procedure Th5uVclGrid.DrawRowIndicator(
  const ARowInfo: Th5uVisibleRowInfo; ASelected: Boolean);
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

  LContext := Th5uFactoryContext.Create(
    Self,
    Self,
    FDataController,
    h5uClassIdGridFixedCell,
    Th5uElementKind.RowHeaderCell
  );
  LContext.RowKey := ARowInfo.RowKey;
  LContext.ViewRowIndex := ARowInfo.RowIndex;
  LContext.ElementFlags := [Th5uElementFlag.FixedColumn];
  if ASelected then
    Include(LContext.ElementFlags, Th5uElementFlag.Selected);

  LAppearance.Clear;
  if ASelected then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := h5uVclToColor(
      h5uGetVclPalette(FTheme).SelectedBackground
    );
    LAppearance.HasForeground := True;
    LAppearance.Foreground := h5uVclToColor(
      h5uGetVclPalette(FTheme).SelectedText
    );
  end;

  LCell := AcquireVisualCell(LContext, Th5uVclDataCell);
  LCell.BindCell(
    LContext,
    LRect,
    TValue.From<Int64>(ARowInfo.RowIndex + 1),
    IntToStr(ARowInfo.RowIndex + 1),
    LAppearance
  );
  LCell.Paint(Self, Canvas);

  if FSpacing.DefaultColumnRightSpacing > 0 then
  begin
    LSeparatorRect := Rect(
      LRect.Right,
      LRect.Top,
      LRect.Right + FSpacing.DefaultColumnRightSpacing,
      LRect.Bottom
    );
    IntersectRect(
      LSeparatorRect,
      LSeparatorRect,
      GetDataViewportRect
    );
    if not IsRectEmpty(LSeparatorRect) then
      DrawSpacingRect(
        LSeparatorRect,
        Th5uElementKind.ColumnSpacing,
        nil,
        ARowInfo.RowIndex,
        ARowInfo.RowKey,
        ResolveColumnSpacingColor
      );
  end;
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
begin
  if not Assigned(FDataController) then
  begin
    FVisibleRows := nil;
    Exit;
  end;

  LDataRect := GetDataViewportRect;
  LRowCount := FDataController.GetRowCount;
  if LRowCount <= 0 then
  begin
    FVisibleRows := nil;
    Exit;
  end;

  LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
  if LRowIndex < 0 then
    Exit;

  FDataController.PrepareRange(
    Max(0, LRowIndex - FScrolling.OverscanRows),
    64
  );

  LRows := TList<Th5uVisibleRowInfo>.Create;
  try
    LOverscanBottom := LDataRect.Bottom +
      FScrolling.OverscanRows *
      (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);

    while (LRowIndex < LRowCount) and
          (LTop < LOverscanBottom) do
    begin
      LRowKey := FDataController.GetRowKey(LRowIndex);
      LHeight := GetRowHeightFor(LRowIndex, LRowKey);
      LRowSpacing := GetRowSpacingFor(LRowIndex, LRowKey);
      LRowRect := Rect(
        LDataRect.Left,
        LTop,
        LDataRect.Right,
        LTop + LHeight
      );

      LRowInfo.RowIndex := LRowIndex;
      LRowInfo.RowKey := LRowKey;
      LRowInfo.Bounds := LRowRect;
      LRowInfo.Height := LHeight;
      LRows.Add(LRowInfo);

      if h5uRectIntersects(LRowRect, LDataRect) then
      begin
        LRowSelected := FSelection.IsRowSelected(LRowKey);
        LStyleName := GetRowStyle(LRowIndex, LStyleKey);
        LRowAppearance := ResolveRowAppearance(
          LRowIndex,
          LRowKey,
          LStyleName
        );

        DrawRowIndicator(LRowInfo, LRowSelected);

        for LColumnInfo in FVisibleColumns do
        begin
          LCellRect := LColumnInfo.Bounds;
          LCellRect.Top := LRowRect.Top;
          LCellRect.Bottom := LRowRect.Bottom;
          IntersectRect(LCellRect, LCellRect, LDataRect);

          if not IsRectEmpty(LCellRect) then
          begin
            LCellSelected :=
              LRowSelected or
              FSelection.IsColumnSelected(LColumnInfo.Column.Id) or
              FSelection.IsCellSelected(
                LRowIndex,
                LColumnInfo.VisibleIndex
              );
            LFocused :=
              FSelection.FocusedCell.IsValid and
              (FSelection.FocusedCell.RowIndex = LRowIndex) and
              (FSelection.FocusedCell.ColumnIndex =
                LColumnInfo.VisibleIndex);

            LClassId := LColumnInfo.Column.CellClassId;
            if string(LClassId) = '' then
              LClassId := h5uClassIdGridDataCell;
            if (LColumnInfo.Column.FixedKind <>
                Th5uFixedKind.None) and
               (LClassId = h5uClassIdGridDataCell) then
              LClassId := h5uClassIdGridFixedCell;

            LContext := Th5uFactoryContext.Create(
              Self,
              Self,
              FDataController,
              LClassId,
              Th5uElementKind.DataCell
            );
            LContext.Column := LColumnInfo.Column;
            LContext.RowKey := LRowKey;
            LContext.ViewRowIndex := LRowIndex;
            LContext.SourceRowIndex := LRowIndex;
            LContext.RowStyleKey := LStyleKey;

            if LColumnInfo.Column.FixedKind <>
               Th5uFixedKind.None then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.FixedColumn
              );
            if LCellSelected then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.Selected
              );
            if LFocused then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.Focused
              );
            if Odd(LRowIndex) then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.OddRow
              )
            else
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.EvenRow
              );
            if (FRowStyles.StripePeriod > 0) and
               (((LRowIndex + 1 - FRowStyles.StripeOffset) mod
                 FRowStyles.StripePeriod) = 0) then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.PatternRow
              );
            if LColumnInfo.Column.ReadOnly then
              Include(
                LContext.ElementFlags,
                Th5uElementFlag.ReadOnly
              );

            LValue := FDataController.GetValue(
              LRowIndex,
              LColumnInfo.Column.FieldName
            );
            LContext.Value := LValue;
            LDisplayText := FDataController.GetDisplayText(
              LRowIndex,
              LColumnInfo.Column.FieldName,
              LColumnInfo.Column.DisplayFormat
            );

            LCellAppearance := ResolveCellAppearance(
              LContext,
              LColumnInfo.Column,
              LRowAppearance,
              LCellSelected,
              LFocused
            );

            LCell := AcquireVisualCell(
              LContext,
              GetDataCellClass(LContext)
            );
            LCell.BindCell(
              LContext,
              LCellRect,
              LValue,
              LDisplayText,
              LCellAppearance
            );
            LCell.Paint(Self, Canvas);
          end;

          LColumnSpacing := GetEffectiveColumnRightSpacing(
            LColumnInfo.Column
          );
          if LColumnSpacing > 0 then
          begin
            LSeparatorRect := Rect(
              LColumnInfo.Bounds.Right,
              LRowRect.Top,
              LColumnInfo.Bounds.Right + LColumnSpacing,
              LRowRect.Bottom
            );
            IntersectRect(LSeparatorRect, LSeparatorRect, LDataRect);
            if not IsRectEmpty(LSeparatorRect) then
              DrawSpacingRect(
                LSeparatorRect,
                Th5uElementKind.ColumnSpacing,
                LColumnInfo.Column,
                LRowIndex,
                LRowKey,
                ResolveColumnSpacingColor
              );
          end;
        end;
      end;

      if LRowSpacing > 0 then
      begin
        LSeparatorRect := Rect(
          LDataRect.Left,
          LRowRect.Bottom,
          LDataRect.Right,
          LRowRect.Bottom + LRowSpacing
        );
        IntersectRect(LSeparatorRect, LSeparatorRect, LDataRect);
        if not IsRectEmpty(LSeparatorRect) then
          DrawSpacingRect(
            LSeparatorRect,
            Th5uElementKind.RowSpacing,
            nil,
            LRowIndex,
            LRowKey,
            ResolveRowSpacingColor
          );
      end;

      Inc(LTop, LHeight + LRowSpacing);
      Inc(LRowIndex);
    end;

    FVisibleRows := LRows.ToArray;
  finally
    LRows.Free;
  end;
end;

procedure Th5uVclGrid.DrawSpacingRect(
  const ABounds: TRect;
  AElementKind: Th5uElementKind;
  AColumn: Th5uGridColumn;
  AViewRowIndex: Int64;
  const ARowKey: Th5uRowKey;
  AColor: TColor);
var
  LClassId: Th5uClassId;
  LFactoryContext: Th5uFactoryContext;
  LDrawContext: Th5uVclDrawContext;
  LAppearance: Th5uResolvedAppearance;
  LDrawDefault: Boolean;
begin
  if IsRectEmpty(ABounds) then
    Exit;

  case AElementKind of
    Th5uElementKind.RowSpacing:
      LClassId := h5uClassIdGridRowSpacing;
    Th5uElementKind.ColumnSpacing:
      LClassId := h5uClassIdGridColumnSpacing;
  else
    LClassId := h5uClassIdGridContentPadding;
  end;

  LFactoryContext := Th5uFactoryContext.Create(
    Self,
    Self,
    FDataController,
    LClassId,
    AElementKind
  );
  LFactoryContext.Column := AColumn;
  LFactoryContext.ViewRowIndex := AViewRowIndex;
  LFactoryContext.SourceRowIndex := AViewRowIndex;
  LFactoryContext.RowKey := ARowKey;

  LAppearance.Clear;
  if AColor <> clNone then
  begin
    LAppearance.HasBackground := True;
    LAppearance.Background := h5uVclToColor(AColor);
  end;
  LDrawContext.FactoryContext := LFactoryContext;
  LDrawContext.Bounds := ABounds;
  LDrawContext.DisplayText := '';
  LDrawContext.Appearance := LAppearance;

  LDrawDefault := True;
  DoCustomDraw(
    Canvas,
    LDrawContext,
    Th5uCustomDrawStage.BeforeDefault,
    LDrawDefault
  );
  if LDrawDefault and (AColor <> clNone) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := AColor;
    Canvas.FillRect(ABounds);
  end;
  DoCustomDraw(
    Canvas,
    LDrawContext,
    Th5uCustomDrawStage.AfterDefault,
    LDrawDefault
  );
end;

procedure Th5uVclGrid.EditorExit(Sender: TObject);
begin
  if not FCommittingEditor then
    CommitEditor;
end;

procedure Th5uVclGrid.EditorKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
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

function Th5uVclGrid.FindFirstVisibleRow(
  AOffset: Int64; out ATop: Integer): Int64;
var
  LIndex: Int64;
  LCount: Int64;
  LHeight: Integer;
  LSpacing: Integer;
  LExtent: Integer;
  LRemaining: Int64;
  LKey: Th5uRowKey;
begin
  Result := -1;
  ATop := GetDataViewportRect.Top;
  if not Assigned(FDataController) then
    Exit;

  LCount := FDataController.GetRowCount;
  LRemaining := Max(0, AOffset);
  LIndex := 0;

  while LIndex < LCount do
  begin
    LKey := FDataController.GetRowKey(LIndex);
    LHeight := GetRowHeightFor(LIndex, LKey, LCount <= 5000);
    LSpacing := GetRowSpacingFor(LIndex, LKey);
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

function Th5uVclGrid.GetDataCellClass(
  const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
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
begin
  Result := 0;
  if not Assigned(FDataController) then
    Exit;

  LCount := FDataController.GetRowCount;
  if (FRowHeight.Mode = Th5uRowHeightMode.Fixed) and
     not Assigned(FOnGetRowSpacing) then
    Exit(
      LCount *
      (FRowHeight.FixedHeight + FSpacing.RowSpacing)
    );

  if LCount <= 5000 then
  begin
    FDataController.PrepareRange(0, LCount);
    for LIndex := 0 to LCount - 1 do
    begin
      LKey := FDataController.GetRowKey(LIndex);
      if FRowHeight.Mode = Th5uRowHeightMode.Fixed then
        LHeight := FRowHeight.FixedHeight
      else
        LHeight := GetRowHeightFor(LIndex, LKey, True);
      Inc(Result, LHeight + GetRowSpacingFor(LIndex, LKey));
    end;
  end
  else
    Result := LCount *
      (FRowHeight.EstimatedHeight + FSpacing.RowSpacing);
end;

function Th5uVclGrid.GetFixedCellClass(
  const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclFixedCell;
end;

function Th5uVclGrid.GetHeaderCellClass(
  const AContext: Th5uFactoryContext): Th5uVclVisualCellClass;
begin
  Result := Th5uVclHeaderCell;
end;

function Th5uVclGrid.GetHeaderHeight: Integer;
var
  LRowCount: Integer;
begin
  if not FShowHeader then
    Exit(0);

  if FHeaderLayout.Enabled and
     (FHeaderLayout.Cells.Count > 0) then
    LRowCount := Max(1, FHeaderLayout.RowCount)
  else
    LRowCount := 1;

  Result := LRowCount *
    (FHeaderRowHeight + FSpacing.RowSpacing);
end;

function Th5uVclGrid.GetOnConfigureInstance:
  Th5uConfigureInstanceEvent;
begin
  Result := FFactoryScope.OnConfigureInstance;
end;

function Th5uVclGrid.GetOnCreateInstance:
  Th5uCreateInstanceEvent;
begin
  Result := FFactoryScope.OnCreateInstance;
end;

function Th5uVclGrid.GetOnGetClass: Th5uGetClassEvent;
begin
  Result := FFactoryScope.OnGetClass;
end;

function Th5uVclGrid.GetRowHeightFor(
  AViewRowIndex: Int64;
  const ARowKey: Th5uRowKey;
  AAllowMeasure: Boolean): Integer;
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
      if (FRowHeight.MeasureScope =
          Th5uAutoHeightMeasureScope.ExplicitContributorColumns) and
         not LColumn.AutoHeight then
        Continue;

      LCellHeight := MeasureCellHeight(AViewRowIndex, LColumn);
      LProposed := Max(LProposed, LCellHeight);
    end;
  end;

  LProposed := EnsureRange(
    LProposed,
    FRowHeight.MinHeight,
    FRowHeight.MaxHeight
  );

  LCacheResult := True;
  if Assigned(FOnGetRowHeight) then
  begin
    LContext.Grid := Self;
    LContext.DataController := FDataController;
    LContext.RowKey := ARowKey;
    LContext.ViewRowIndex := AViewRowIndex;
    LContext.SourceRowIndex := AViewRowIndex;
    LContext.IsEstimated := not AAllowMeasure;
    FOnGetRowHeight(
      Self,
      LContext,
      LProposed,
      LCacheResult
    );
  end;

  Result := Max(1, LProposed);
  if LCacheResult then
    FRowHeightCache.AddOrSetValue(LCacheKey, Result);
end;

function Th5uVclGrid.GetRowStyle(
  AViewRowIndex: Int64; out AStyleKey: TValue): string;
var
  LColumn: Th5uGridColumn;
  LInteger: Integer;
  LHasKey: Boolean;
begin
  AStyleKey := TValue.Empty;
  LHasKey := False;
  LInteger := 0;

  if Assigned(FDataController) and
     (FRowStyles.StyleKeyColumnId <> '') then
  begin
    LColumn := FColumns.FindById(
      FRowStyles.StyleKeyColumnId
    );
    if not Assigned(LColumn) then
      LColumn := FColumns.FindByFieldName(
        FRowStyles.StyleKeyColumnId
      );

    if Assigned(LColumn) then
    begin
      AStyleKey := FDataController.GetValue(
        AViewRowIndex,
        LColumn.FieldName
      );
      LHasKey := h5uTryValueAsInteger(AStyleKey, LInteger);
    end;
  end;

  Result := FRowStyles.ResolveStyle(
    AViewRowIndex,
    LInteger,
    LHasKey
  );
end;

function Th5uVclGrid.GetEffectiveColumnRightSpacing(
  AColumn: Th5uGridColumn): Integer;
begin
  if Assigned(AColumn) and (AColumn.RightSpacing >= 0) then
    Result := AColumn.RightSpacing
  else
    Result := FSpacing.DefaultColumnRightSpacing;
end;

function Th5uVclGrid.GetRowSpacingFor(
  AViewRowIndex: Int64;
  const ARowKey: Th5uRowKey): Integer;
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
    LContext.SourceRowIndex := AViewRowIndex;
    LContext.IsEstimated := False;
    FOnGetRowSpacing(Self, LContext, Result);
  end;
  Result := EnsureRange(Result, 0, 1000);
end;

function Th5uVclGrid.GetGridLines: Boolean;
begin
  // Explicit per-column RightSpacing values are intentionally independent
  // from this compatibility property.
  Result :=
    (FSpacing.Left > 0) or
    (FSpacing.Top > 0) or
    (FSpacing.Right > 0) or
    (FSpacing.Bottom > 0) or
    (FSpacing.RowSpacing > 0) or
    (FSpacing.DefaultColumnRightSpacing > 0);
end;

function Th5uVclGrid.GetTotalColumnWidth: Integer;
var
  LColumn: Th5uGridColumn;
begin
  Result := 0;
  for LColumn in FColumns.VisibleColumns do
    Inc(
      Result,
      LColumn.Width +
      GetEffectiveColumnRightSpacing(LColumn)
    );
  if FShowRowIndicator then
    Inc(
      Result,
      FRowIndicatorWidth +
      FSpacing.DefaultColumnRightSpacing
    );
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

function Th5uVclGrid.ResolveColor(
  const AColor: Th5uColor;
  AFallback: TColor): TColor;
begin
  if AColor = h5uColorDefault then
    Result := AFallback
  else if AColor = h5uColorNone then
    Result := clNone
  else
    Result := h5uColorToVcl(AColor);
end;

function Th5uVclGrid.ResolveDefaultCellColor: TColor;
begin
  Result := ResolveColor(
    FAppearance.DefaultCellColor,
    h5uGetVclPalette(FTheme).CellBackground
  );
end;

function Th5uVclGrid.ResolveRowSpacingColor: TColor;
begin
  Result := ResolveColor(
    FSpacing.RowSpacingColor,
    h5uGetVclPalette(FTheme).CellBorder
  );
end;

function Th5uVclGrid.ResolveColumnSpacingColor: TColor;
begin
  Result := ResolveColor(
    FSpacing.ColumnSpacingColor,
    h5uGetVclPalette(FTheme).CellBorder
  );
end;

function Th5uVclGrid.ResolveContentPaddingColor: TColor;
begin
  Result := ResolveColor(
    FSpacing.ContentPaddingColor,
    h5uGetVclPalette(FTheme).CellBorder
  );
end;

function Th5uVclGrid.GetVisualCellClass(
  const AContext: Th5uFactoryContext;
  ADefaultClass: Th5uVclVisualCellClass): Th5uVclVisualCellClass;
var
  LCacheScope: Th5uFactoryCacheScope;
begin
  Result := Th5uVclVisualCellClass(
    FFactoryScope.ResolveClass(
      AContext,
      Th5uVclVisualCell,
      ADefaultClass,
      LCacheScope
    )
  );
end;

function Th5uVclGrid.HitTest(X, Y: Integer): Th5uHitTestInfo;
var
  LColumnInfo: Th5uVisibleColumnInfo;
  LRowInfo: Th5uVisibleRowInfo;
begin
  Result := Th5uHitTestInfo.Empty;

  if FShowHeader and (Y < GetDataViewportRect.Top) then
  begin
    if ColumnInfoAtPoint(X, Y, LColumnInfo) then
    begin
      Result.Kind := Th5uHitKind.Header;
      Result.Column := LColumnInfo.Column;
      Result.ColumnIndex := LColumnInfo.VisibleIndex;
      Result.Bounds := LColumnInfo.Bounds;
      Result.Bounds.Top := GetViewportRect.Top;
      Result.Bounds.Bottom := GetDataViewportRect.Top;
    end;
    Exit;
  end;

  if not RowInfoAtPoint(X, Y, LRowInfo) then
    Exit;

  Result.RowIndex := LRowInfo.RowIndex;
  Result.RowKey := LRowInfo.RowKey;
  Result.Bounds := LRowInfo.Bounds;

  if FShowRowIndicator and
     (X < GetViewportRect.Left + FRowIndicatorWidth) then
  begin
    Result.Kind := Th5uHitKind.RowIndicator;
    Exit;
  end;

  if ColumnInfoAtPoint(X, Y, LColumnInfo) then
  begin
    Result.Kind := Th5uHitKind.DataCell;
    Result.Column := LColumnInfo.Column;
    Result.ColumnIndex := LColumnInfo.VisibleIndex;
    Result.Bounds := LColumnInfo.Bounds;
    Result.Bounds.Top := LRowInfo.Bounds.Top;
    Result.Bounds.Bottom := LRowInfo.Bounds.Bottom;
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

procedure Th5uVclGrid.InvalidateRowHeight(
  const ARowKey: Th5uRowKey);
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

procedure Th5uVclGrid.LayoutScrollBars;
var
  LVWidth: Integer;
  LHHeight: Integer;
begin
  LVWidth := GetSystemMetrics(SM_CXVSCROLL);
  LHHeight := GetSystemMetrics(SM_CYHSCROLL);
  if LVWidth <= 0 then
    LVWidth := 17;
  if LHHeight <= 0 then
    LHHeight := 17;

  FVScrollBar.SetBounds(
    ClientWidth - LVWidth,
    0,
    LVWidth,
    ClientHeight - IfThen(FHScrollBar.Visible, LHHeight, 0)
  );
  FHScrollBar.SetBounds(
    0,
    ClientHeight - LHHeight,
    ClientWidth - IfThen(FVScrollBar.Visible, LVWidth, 0),
    LHHeight
  );
  FThumbHint.BringToFront;
  FEditor.BringToFront;
end;

function Th5uVclGrid.MeasureCellHeight(
  AViewRowIndex: Int64; AColumn: Th5uGridColumn): Integer;
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
    LValue := FDataController.GetValue(
      AViewRowIndex,
      AColumn.FieldName
    );
    if LValue.IsType<TBytes> and
       (Length(LValue.AsType<TBytes>) > 0) then
      Result := Min(
        AColumn.MaxAutoHeight,
        Max(FRowHeight.MinHeight, 80)
      );
    Exit;
  end;

  if not AColumn.AutoHeight then
    Exit;

  LText := FDataController.GetDisplayText(
    AViewRowIndex,
    AColumn.FieldName,
    AColumn.DisplayFormat
  );

  Canvas.Font.Assign(Font);
  LRect := Rect(0, 0, Max(8, AColumn.Width - 10), 0);
  LFlags := DT_CALCRECT or DT_NOPREFIX;
  if AColumn.WordWrap then
    LFlags := LFlags or DT_WORDBREAK
  else
    LFlags := LFlags or DT_SINGLELINE;

  DrawText(
    Canvas.Handle,
    PChar(LText),
    Length(LText),
    LRect,
    LFlags
  );
  Result := LRect.Height + 6;

  if AColumn.MaxLines > 0 then
  begin
    LMaxByLines := Canvas.TextHeight('Wg') *
      AColumn.MaxLines + 6;
    Result := Min(Result, LMaxByLines);
  end;

  if AColumn.MaxAutoHeight > 0 then
    Result := Min(Result, AColumn.MaxAutoHeight);
end;

procedure Th5uVclGrid.MouseDown(
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer);
var
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LNearRightEdge: Boolean;
begin
  inherited MouseDown(Button, Shift, X, Y);
  SetFocus;
  FMouseDownHit := HitTest(X, Y);

  if (Button = mbRight) and
     (FMouseDownHit.Kind = Th5uHitKind.Header) and
     FCustomization.ShowColumnChooser then
  begin
    ShowColumnChooser;
    Exit;
  end;

  if Button <> mbLeft then
    Exit;

  if FMouseDownHit.Kind = Th5uHitKind.Header then
  begin
    LNearRightEdge :=
      Abs(X - FMouseDownHit.Bounds.Right) <= 4;
    if LNearRightEdge and
       FCustomization.AllowColumnResizing and
       FMouseDownHit.Column.CanResize then
    begin
      FResizingColumn := FMouseDownHit.Column;
      FResizeStartX := X;
      FResizeOriginalWidth := FResizingColumn.Width;
      Exit;
    end;

    if FMouseDownHit.Column.CanSelect then
      if ssCtrl in Shift then
        FSelection.ToggleColumn(FMouseDownHit.Column.Id)
      else
        FSelection.SelectColumn(FMouseDownHit.Column.Id, False);
    Exit;
  end;

  if FMouseDownHit.Kind = Th5uHitKind.RowIndicator then
  begin
    if ssCtrl in Shift then
      FSelection.ToggleRow(FMouseDownHit.RowKey)
    else
      FSelection.SelectRow(FMouseDownHit.RowKey, False);
    Exit;
  end;

  if FMouseDownHit.Kind = Th5uHitKind.DataCell then
  begin
    LCell.RowIndex := FMouseDownHit.RowIndex;
    LCell.ColumnIndex := FMouseDownHit.ColumnIndex;
    LCell.RowKey := FMouseDownHit.RowKey;
    LCell.ColumnId := FMouseDownHit.Column.Id;

    if (ssShift in Shift) and FSelection.AnchorCell.IsValid then
      LRange := Th5uCellRange.Create(
        FSelection.AnchorCell.RowIndex,
        LCell.RowIndex,
        FSelection.AnchorCell.ColumnIndex,
        LCell.ColumnIndex
      )
    else
      LRange := Th5uCellRange.Create(
        LCell.RowIndex,
        LCell.RowIndex,
        LCell.ColumnIndex,
        LCell.ColumnIndex
      );

    FSelection.SetFocus(LCell, not (ssShift in Shift));
    FSelection.AddCellRange(LRange, ssCtrl in Shift);
    FSelectingRange := True;
  end;
end;

procedure Th5uVclGrid.MouseMove(
  Shift: TShiftState; X, Y: Integer);
var
  LHit: Th5uHitTestInfo;
  LRange: Th5uCellRange;
begin
  inherited MouseMove(Shift, X, Y);

  if Assigned(FResizingColumn) then
  begin
    FResizingColumn.Width :=
      FResizeOriginalWidth + (X - FResizeStartX);
    Exit;
  end;

  if FSelectingRange and (ssLeft in Shift) then
  begin
    LHit := HitTest(X, Y);
    if (LHit.Kind = Th5uHitKind.DataCell) and
       FSelection.AnchorCell.IsValid then
    begin
      LRange := Th5uCellRange.Create(
        FSelection.AnchorCell.RowIndex,
        LHit.RowIndex,
        FSelection.AnchorCell.ColumnIndex,
        LHit.ColumnIndex
      );
      FSelection.ClearCellRanges;
      FSelection.AddCellRange(LRange, False);
    end;
  end;
end;

procedure Th5uVclGrid.MouseUp(
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer);
var
  LHit: Th5uHitTestInfo;
begin
  inherited MouseUp(Button, Shift, X, Y);

  if Assigned(FResizingColumn) then
  begin
    FResizingColumn := nil;
    RebuildAfterLayoutChange;
    Exit;
  end;

  if (Button = mbLeft) and
     (FMouseDownHit.Kind = Th5uHitKind.Header) and
     FCustomization.AllowColumnMoving and
     FMouseDownHit.Column.CanMove then
  begin
    LHit := HitTest(X, Y);
    if (LHit.Kind = Th5uHitKind.Header) and
       Assigned(LHit.Column) and
       (LHit.Column <> FMouseDownHit.Column) then
      MoveColumn(
        FMouseDownHit.Column,
        LHit.ColumnIndex
      );
  end;

  FSelectingRange := False;
end;

procedure Th5uVclGrid.MoveColumn(
  AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
begin
  if not FCustomization.AllowColumnMoving then
    Exit;
  FColumns.MoveColumn(AColumn, ANewVisibleIndex);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.Notification(
  AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation <> opRemove then
    Exit;

  if AComponent = FDataController then
    DataController := nil;
  if AComponent = FSharedClassFactory then
    SharedClassFactory := nil;
end;

procedure Th5uVclGrid.OptionsChanged(Sender: TObject);
begin
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.Paint;
var
  LPalette: Th5uVclPalette;
  LViewRect: TRect;
  LDataRect: TRect;
begin
  LPalette := h5uGetVclPalette(FTheme);
  Canvas.Brush.Color := LPalette.EmptyArea;
  Canvas.FillRect(ClientRect);
  Canvas.Font.Assign(Font);

  UpdateScrollBars;
  BuildColumnLayout;
  BeginVisualPass;

  DrawContentPadding;

  LViewRect := GetViewportRect;
  Canvas.Brush.Color := LPalette.GridBackground;
  Canvas.FillRect(LViewRect);

  LDataRect := GetDataViewportRect;
  Canvas.Brush.Color := ResolveDefaultCellColor;
  Canvas.FillRect(LDataRect);

  DrawHeaders;
  DrawRows;
end;

function Th5uVclGrid.ParseEditorValue(
  AColumn: Th5uGridColumn; const AText: string): TValue;
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
          raise EConvertError.CreateFmt(
            '"%s" ist keine ganze Zahl.',
            [AText]
          );
        Result := TValue.From<Int64>(LInteger);
      end;

    Th5uColumnDataType.Float:
      begin
        if not TryStrToFloat(AText, LFloat) then
          raise EConvertError.CreateFmt(
            '"%s" ist keine Zahl.',
            [AText]
          );
        Result := TValue.From<Double>(LFloat);
      end;

    Th5uColumnDataType.Currency:
      begin
        if not TryStrToCurr(AText, LCurrency) then
          raise EConvertError.CreateFmt(
            '"%s" ist kein gültiger Betrag.',
            [AText]
          );
        Result := TValue.From<Currency>(LCurrency);
      end;

    Th5uColumnDataType.Date,
    Th5uColumnDataType.DateTime:
      begin
        if not TryStrToDateTime(AText, LDateTime) then
          raise EConvertError.CreateFmt(
            '"%s" ist kein gültiges Datum.',
            [AText]
          );
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
  inherited Resize;
  LayoutScrollBars;
  RebuildAfterLayoutChange;
end;

function Th5uVclGrid.ResolveCellAppearance(
  const AContext: Th5uFactoryContext;
  AColumn: Th5uGridColumn;
  const ARowAppearance: Th5uResolvedAppearance;
  ASelected, AFocused: Boolean): Th5uResolvedAppearance;
var
  LPalette: Th5uVclPalette;
begin
  Result := ARowAppearance;
  LPalette := h5uGetVclPalette(FTheme);

  if AColumn.Color <> h5uColorDefault then
  begin
    Result.HasBackground := True;
    Result.Background := AColumn.Color;
  end;

  if AColumn.Highlighted and
     (AColumn.Color = h5uColorDefault) and
     not ASelected then
  begin
    Result.HasBackground := True;
    Result.Background := h5uVclToColor(
      LPalette.HighlightedColumnBackground
    );
  end;

  if ASelected then
  begin
    Result.HasBackground := True;
    Result.Background := h5uVclToColor(
      LPalette.SelectedBackground
    );
    Result.HasForeground := True;
    Result.Foreground := h5uVclToColor(
      LPalette.SelectedText
    );
  end;

  if AFocused then
  begin
    Result.HasBorder := True;
    Result.Border := h5uVclToColor(LPalette.FocusBorder);
  end;

  if Assigned(FOnGetCellAppearance) then
    FOnGetCellAppearance(Self, AContext, Result);
end;

function Th5uVclGrid.ResolveRowAppearance(
  AViewRowIndex: Int64;
  const ARowKey: Th5uRowKey;
  const AStyleName: string): Th5uResolvedAppearance;
var
  LPalette: Th5uVclPalette;
begin
  Result.Clear;
  Result.StyleName := AStyleName;
  Result.HasBackground := True;
  LPalette := h5uGetVclPalette(FTheme);

  if SameText(AStyleName, 'Error') then
    Result.Background := h5uVclToColor(LPalette.ErrorBackground)
  else if SameText(AStyleName, 'Warning') then
    Result.Background := h5uVclToColor(LPalette.WarningBackground)
  else if SameText(AStyleName, 'Stripe') then
    Result.Background := h5uVclToColor(LPalette.StripeBackground)
  else if FAppearance.DefaultCellColor <> h5uColorDefault then
    Result.Background := h5uVclToColor(ResolveDefaultCellColor)
  else if SameText(AStyleName, 'Odd') then
    Result.Background := h5uVclToColor(LPalette.OddBackground)
  else if SameText(AStyleName, 'Even') then
    Result.Background := h5uVclToColor(LPalette.EvenBackground)
  else
    Result.Background := h5uVclToColor(ResolveDefaultCellColor);

  if Assigned(FOnGetRowAppearance) then
    FOnGetRowAppearance(
      Self,
      AViewRowIndex,
      ARowKey,
      Result
    );
end;

function Th5uVclGrid.RowInfoAtPoint(
  X, Y: Integer; out AInfo: Th5uVisibleRowInfo): Boolean;
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

procedure Th5uVclGrid.ScrollBarScroll(
  Sender: TObject;
  ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
  LTop: Integer;
  LRowIndex: Int64;
begin
  CancelEditor;

  if Sender = FVScrollBar then
  begin
    FVerticalOffset := EnsureRange(
      ScrollPos,
      0,
      FVScrollBar.Max
    );

    if (FScrolling.VerticalMode =
        Th5uVerticalScrollMode.WholeRows) and
       (ScrollCode = scEndScroll) then
    begin
      LRowIndex := FindFirstVisibleRow(FVerticalOffset, LTop);
      if LRowIndex >= 0 then
      begin
        FVerticalOffset := FVerticalOffset +
          (LTop - GetDataViewportRect.Top);
        FVerticalOffset := EnsureRange(
          FVerticalOffset,
          0,
          FVScrollBar.Max
        );
        ScrollPos := FVerticalOffset;
      end;
    end;

    if Th5uScrollHintTrigger.ThumbTracking in
       FScrollHints.Triggers then
      ShowThumbHint(
        Th5uScrollAxis.Vertical,
        Th5uScrollHintTrigger.ThumbTracking
      );
  end
  else
  begin
    FHorizontalOffset := EnsureRange(
      ScrollPos,
      0,
      FHScrollBar.Max
    );
    if Th5uScrollHintTrigger.ThumbTracking in
       FScrollHints.Triggers then
      ShowThumbHint(
        Th5uScrollAxis.Horizontal,
        Th5uScrollHintTrigger.ThumbTracking
      );
  end;

  Invalidate;
  if ScrollCode = scEndScroll then
  begin
    FThumbHintTimer.Enabled := False;
    FThumbHintTimer.Enabled := True;
  end;
end;

procedure Th5uVclGrid.SelectionChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure Th5uVclGrid.SetColumns(
  const AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure Th5uVclGrid.SetCustomization(
  const AValue: Th5uCustomizationOptions);
begin
  FCustomization.Assign(AValue);
end;

procedure Th5uVclGrid.SetAppearance(
  const AValue: Th5uGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure Th5uVclGrid.SetGridLines(const AValue: Boolean);
begin
  if AValue then
    FSpacing.SetAllSeparators(1)
  else
    FSpacing.SetAllSeparators(0);
end;

procedure Th5uVclGrid.SetSpacing(
  const AValue: Th5uGridSpacingOptions);
begin
  FSpacing.Assign(AValue);
end;

procedure Th5uVclGrid.SetDataController(
  const AValue: Th5uCustomDataController);
begin
  if FDataController = AValue then
    Exit;

  CancelEditor;
  if Assigned(FDataController) then
    FDataController.RemoveFreeNotification(Self);

  FDataController := AValue;
  FDataLink.Controller := FDataController;

  if Assigned(FDataController) then
    FDataController.FreeNotification(Self);

  FVerticalOffset := 0;
  InvalidateAllRowHeights;
  UpdateScrollBars;
  Invalidate;
end;

procedure Th5uVclGrid.SetHeaderLayout(
  const AValue: Th5uHeaderLayout);
begin
  FHeaderLayout.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetHeaderRowHeight(const AValue: Integer);
begin
  FHeaderRowHeight := EnsureRange(AValue, 16, 200);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetOnConfigureInstance(
  const AValue: Th5uConfigureInstanceEvent);
begin
  FFactoryScope.OnConfigureInstance := AValue;
end;

procedure Th5uVclGrid.SetOnCreateInstance(
  const AValue: Th5uCreateInstanceEvent);
begin
  FFactoryScope.OnCreateInstance := AValue;
end;

procedure Th5uVclGrid.SetOnGetClass(
  const AValue: Th5uGetClassEvent);
begin
  FFactoryScope.OnGetClass := AValue;
end;

procedure Th5uVclGrid.SetRowHeight(
  const AValue: Th5uRowHeightOptions);
begin
  FRowHeight.Assign(AValue);
end;

procedure Th5uVclGrid.SetRowIndicatorWidth(
  const AValue: Integer);
begin
  FRowIndicatorWidth := EnsureRange(AValue, 0, 300);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetRowStyles(
  const AValue: Th5uRowStyleOptions);
begin
  FRowStyles.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclGrid.SetScrolling(
  const AValue: Th5uScrollingOptions);
begin
  FScrolling.Assign(AValue);
  RebuildAfterLayoutChange;
end;

procedure Th5uVclGrid.SetScrollHints(
  const AValue: Th5uScrollHintOptions);
begin
  FScrollHints.Assign(AValue);
end;

procedure Th5uVclGrid.SetSelection(
  const AValue: Th5uGridSelection);
begin
  FSelection.Assign(AValue);
  Invalidate;
end;

procedure Th5uVclGrid.SetSharedClassFactory(
  const AValue: Th5uClassFactory);
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

procedure Th5uVclGrid.SetColumnVisible(
  AColumn: Th5uGridColumn; AVisible: Boolean);
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

procedure Th5uVclGrid.ShowThumbHint(
  AAxis: Th5uScrollAxis;
  ATrigger: Th5uScrollHintTrigger);
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
  LWidth := Min(
    Max(80, Canvas.TextWidth(LText) + 18),
    Max(80, ClientWidth - 20)
  );
  LHeight := Canvas.TextHeight('Wg') + 10;
  LViewport := GetViewportRect;

  if AAxis = Th5uScrollAxis.Vertical then
  begin
    if FVScrollBar.Max > 0 then
      LRatio := FVerticalOffset / FVScrollBar.Max
    else
      LRatio := 0;
    LX := Max(LViewport.Left + 4, LViewport.Right - LWidth - 8);
    LY := LViewport.Top +
      Round((LViewport.Height - LHeight) * LRatio);
  end
  else
  begin
    if FHScrollBar.Max > 0 then
      LRatio := FHorizontalOffset / FHScrollBar.Max
    else
      LRatio := 0;
    LX := LViewport.Left +
      Round((LViewport.Width - LWidth) * LRatio);
    LY := Max(LViewport.Top + 4, LViewport.Bottom - LHeight - 8);
  end;

  FThumbHint.SetBounds(LX, LY, LWidth, LHeight);
  FThumbHint.Visible := True;
  FThumbHint.BringToFront;

  FThumbHintTimer.Enabled := False;
  FThumbHintTimer.Enabled := True;
end;

procedure Th5uVclGrid.StartEdit(const AHit: Th5uHitTestInfo);
var
  LEditorKind: Th5uColumnEditorKind;
  LValue: TValue;
  LBytes: TBytes;
  LCell: Th5uCellAddress;
begin
  if not FAllowEditing or not Assigned(FDataController) or
     not Assigned(AHit.Column) or AHit.Column.ReadOnly or
     not FDataController.CanEdit(
       AHit.RowIndex,
       AHit.Column.FieldName
     ) then
    Exit;

  LEditorKind := AHit.Column.EditorKind;
  if LEditorKind = Th5uColumnEditorKind.Automatic then
    case AHit.Column.DataType of
      Th5uColumnDataType.Boolean:
        LEditorKind := Th5uColumnEditorKind.Boolean;
      Th5uColumnDataType.Image:
        LEditorKind := Th5uColumnEditorKind.Image;
    else
      LEditorKind := Th5uColumnEditorKind.Text;
    end;

  if LEditorKind = Th5uColumnEditorKind.None then
    Exit;

  LCell.RowIndex := AHit.RowIndex;
  LCell.ColumnIndex := AHit.ColumnIndex;
  LCell.RowKey := AHit.RowKey;
  LCell.ColumnId := AHit.Column.Id;
  FSelection.SetFocus(LCell, True);

  case LEditorKind of
    Th5uColumnEditorKind.Boolean:
      begin
        LValue := FDataController.GetValue(
          AHit.RowIndex,
          AHit.Column.FieldName
        );
        if LValue.IsEmpty then
          FDataController.SetValue(
            AHit.RowIndex,
            AHit.Column.FieldName,
            TValue.From<Boolean>(True)
          )
        else
          FDataController.SetValue(
            AHit.RowIndex,
            AHit.Column.FieldName,
            TValue.From<Boolean>(not LValue.AsBoolean)
          );
      end;

    Th5uColumnEditorKind.Image:
      begin
        LValue := FDataController.GetValue(
          AHit.RowIndex,
          AHit.Column.FieldName
        );
        if LValue.IsType<TBytes> then
          LBytes := LValue.AsType<TBytes>
        else
          LBytes := nil;

        if Th5uVclImageEditForm.Execute(GetParentForm(Self), LBytes) then
          FDataController.SetValue(
            AHit.RowIndex,
            AHit.Column.FieldName,
            TValue.From<TBytes>(LBytes)
          );
      end;

  else
    begin
      FEditRowIndex := AHit.RowIndex;
      FEditColumn := AHit.Column;
      FEditor.Text := FDataController.GetDisplayText(
        AHit.RowIndex,
        AHit.Column.FieldName,
        AHit.Column.DisplayFormat
      );
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
  if FUpdatingScrollBars or (csDestroying in ComponentState) then
    Exit;

  FUpdatingScrollBars := True;
  try
    LClient := ClientRect;
    LTotalWidth := GetTotalColumnWidth;
    LTotalHeight := GetEstimatedTotalRowHeight;

    LAvailableWidth := Max(
      0,
      LClient.Width - FSpacing.Left - FSpacing.Right
    );
    LAvailableHeight := Max(
      0,
      LClient.Height - FSpacing.Top - FSpacing.Bottom -
      GetHeaderHeight
    );

    LNeedHorizontal := LTotalWidth > LAvailableWidth;
    LNeedVertical := LTotalHeight > LAvailableHeight;

    FHScrollBar.Visible := LNeedHorizontal;
    FVScrollBar.Visible := LNeedVertical;
    LayoutScrollBars;

    LAvailableWidth := GetViewportRect.Width;
    LAvailableHeight := GetDataViewportRect.Height;

    LMaxHorizontal := Max(0, LTotalWidth - LAvailableWidth);
    LMaxVertical := h5uClampInt64ToInteger(
      Max(0, LTotalHeight - LAvailableHeight)
    );

    FHScrollBar.Min := 0;
    FHScrollBar.Max := LMaxHorizontal;
    FHScrollBar.LargeChange := Max(1, LAvailableWidth);
    FHScrollBar.SmallChange := 24;

    FVScrollBar.Min := 0;
    FVScrollBar.Max := LMaxVertical;
    FVScrollBar.LargeChange := Max(1, LAvailableHeight);
    FVScrollBar.SmallChange := Max(
      1,
      FRowHeight.EstimatedHeight + FSpacing.RowSpacing
    );

    FHorizontalOffset := EnsureRange(
      FHorizontalOffset,
      0,
      LMaxHorizontal
    );
    FVerticalOffset := EnsureRange(
      FVerticalOffset,
      0,
      LMaxVertical
    );
    FHScrollBar.Position := FHorizontalOffset;
    FVScrollBar.Position := FVerticalOffset;
  finally
    FUpdatingScrollBars := False;
  end;
end;

end.
