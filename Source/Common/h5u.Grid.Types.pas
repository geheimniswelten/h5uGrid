unit h5u.Grid.Types;

interface

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
  h5uClassIdGridColumn = Th5uClassId('h5u.grid.column.default');
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
    Image,
    Time
  );

  Th5uColumnEditorKind = (
    Automatic,
    None,
    Text,
    Boolean,
    Image,
    Time,
    Date,
    DateTime
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


implementation

{ Th5uRowKey }

class operator Th5uRowKey.Equal(const ALeft, ARight: Th5uRowKey): Boolean;
begin
  Result := ALeft.FValue = ARight.FValue;
end;

class operator Th5uRowKey.NotEqual(const ALeft, ARight: Th5uRowKey): Boolean;
begin
  Result := not (ALeft = ARight);
end;

class function Th5uRowKey.Empty: Th5uRowKey;
begin
  Result.FValue := '';
end;

class function Th5uRowKey.FromInt64(const AValue: Int64): Th5uRowKey;
begin
  Result.FValue := IntToStr(AValue);
end;

class function Th5uRowKey.FromString(const AValue: string): Th5uRowKey;
begin
  Result.FValue := AValue;
end;

function Th5uRowKey.IsEmpty: Boolean;
begin
  Result := FValue = '';
end;

function Th5uRowKey.ToString: string;
begin
  Result := FValue;
end;

{ Th5uFactoryContext }

class function Th5uFactoryContext.Create(AGrid, AView, AController: TObject; const AClassId: Th5uClassId; AElementKind: Th5uElementKind): Th5uFactoryContext;
begin
  Result := Default(Th5uFactoryContext);
  Result.Grid := AGrid;
  Result.View := AView;
  Result.DataController := AController;
  Result.ClassId := AClassId;
  Result.ElementKind := AElementKind;
  Result.RowKey := Th5uRowKey.Empty;
  Result.SourceRowIndex := -1;
  Result.ViewRowIndex := -1;
  Result.LayoutRow := -1;
  Result.LayoutColumn := -1;
  Result.RowSpan := 1;
  Result.ColumnSpan := 1;
  Result.TreeLevel := -1;
  Result.ClosedTreeLevels := 0;
  Result.AdjacentGroupIndex := -1;
  Result.AdjacentGroupAnchorRowKey := Th5uRowKey.Empty;
  Result.AdjacentGroupRowCount := 0;
  Result.CreationReason := Th5uCreationReason.Runtime;
end;

{ Th5uDataChange }

class function Th5uDataChange.ResetAll: Th5uDataChange;
begin
  Result := Default(Th5uDataChange);
  Result.Kind := Th5uDataChangeKind.Reset;
  Result.FirstIndex := 0;
  Result.Count := -1;
  Result.RowKey := Th5uRowKey.Empty;
end;

{ Th5uCellRange }

function Th5uCellRange.Contains(ARowIndex: Int64; AColumnIndex: Integer): Boolean;
var
  LRange: Th5uCellRange;
begin
  LRange := Self;
  LRange.Normalize;
  Result := (ARowIndex >= LRange.StartRowIndex) and (ARowIndex <= LRange.EndRowIndex) and (AColumnIndex >= LRange.StartColumnIndex) and (AColumnIndex
    <= LRange.EndColumnIndex);
end;

class function Th5uCellRange.Create(AStartRow, AEndRow: Int64; AStartColumn, AEndColumn: Integer): Th5uCellRange;
begin
  Result.StartRowIndex := AStartRow;
  Result.EndRowIndex := AEndRow;
  Result.StartColumnIndex := AStartColumn;
  Result.EndColumnIndex := AEndColumn;
  Result.Normalize;
end;

procedure Th5uCellRange.Normalize;
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

{ Th5uCellAddress }

class function Th5uCellAddress.Empty: Th5uCellAddress;
begin
  Result := Default(Th5uCellAddress);
  Result.RowIndex := -1;
  Result.ColumnIndex := -1;
  Result.RowKey := Th5uRowKey.Empty;
end;

function Th5uCellAddress.IsValid: Boolean;
begin
  Result := (RowIndex >= 0) and (ColumnIndex >= 0);
end;

{ Th5uResolvedAppearance }

procedure Th5uResolvedAppearance.Clear;
begin
  Self := Default(Th5uResolvedAppearance);
end;

end.
