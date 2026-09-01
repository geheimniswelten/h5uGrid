# h5u.Grid – öffentlicher API-Auszug

> Automatisch aus den `interface`-Abschnitten des ausgelieferten Quellstands erzeugt. Maßgeblich bleiben die Pascal-Units.

Erzeugt: 2026-09-01

## `h5u.Grid.Columns`

Quelle: `Source/Common/h5u.Grid.Columns.pas`

```pascal
  Th5uGridColumn = class;
  Th5uGridColumns = class;
  Th5uColumnChangedEvent = procedure(
    Sender: TObject;
    AColumn: Th5uGridColumn
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
    property VisibleIndex: Integer
    property FixedKind: Th5uFixedKind
      read FFixedKind write SetFixedKind default Th5uFixedKind.None;
    property ReadOnly: Boolean
    property DataType: Th5uColumnDataType
      read FDataType write FDataType default Th5uColumnDataType.Auto;
    property EditorKind: Th5uColumnEditorKind
      default Th5uColumnEditorKind.Automatic;
    property WordWrap: Boolean
    property AutoHeight: Boolean
    property MaxAutoHeight: Integer
    property MaxLines: Integer
    property DisplayFormat: string
    property ScrollHintText: string
    property StyleName: string read FStyleName write FStyleName;
    property HeaderStyleName: string
    property Highlighted: Boolean
    property ClassId: Th5uClassId read FClassId write FClassId;
    property CellClassId: Th5uClassId
    property HeaderCellClassId: Th5uClassId
    property CanMove: Boolean
    property CanHide: Boolean
    property CanResize: Boolean
    property CanSelect: Boolean
    property ShowInColumnChooser: Boolean
    property ImagePreserveAspectRatio: Boolean
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
    property Items[AIndex: Integer]: Th5uGridColumn
    property OnChanged: Th5uColumnChangedEvent
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
    property LayoutRow: Integer
    property LayoutColumn: Integer
    property RowSpan: Integer read FRowSpan write FRowSpan default 1;
    property ColumnSpan: Integer
    property StyleName: string read FStyleName write FStyleName;
    property ClassId: Th5uClassId read FClassId write FClassId;
  end;
  Th5uHeaderLayoutCells = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): Th5uHeaderLayoutCell;
  public
    constructor Create(AOwner: TPersistent);
    function Add: Th5uHeaderLayoutCell;
    property Items[AIndex: Integer]: Th5uHeaderLayoutCell
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
    property Items[AIndex: Integer]: Th5uRowStyleMapping
  end;
```

## `h5u.Grid.Data.Core`

Quelle: `Source/Common/h5u.Grid.Data.Core.pas`

```pascal
  Th5uCustomDataController = class;
  Th5uDataControllerLink = class;
  Th5uDataControllerChangedEvent = procedure(
    Sender: TObject;
    const AChange: Th5uDataChange
  Th5uDataControllerLink = class(TObject)
  private
    FController: Th5uCustomDataController;
    FOnChanged: Th5uDataControllerChangedEvent;
    procedure SetController(const AValue: Th5uCustomDataController);
  public
    destructor Destroy; override;
    procedure DataChanged(const AChange: Th5uDataChange);
    property Controller: Th5uCustomDataController
    property OnChanged: Th5uDataControllerChangedEvent
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
    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    function GetSourceRowCount: Int64; virtual; abstract;
    function GetSourceRowKey(
      ASourceRowIndex: Int64
    ): Th5uRowKey; virtual;
    function GetSourceValue(
      ASourceRowIndex: Int64;
    procedure SetSourceValue(
      ASourceRowIndex: Int64;
    function GetSourceCanEdit(
      ASourceRowIndex: Int64;
    function GetSourceDisplayText(
      ASourceRowIndex: Int64;
    function MapViewToSourceIndex(
      AViewRowIndex: Int64
    procedure DoCacheOptionsChanged; virtual;
    procedure DoPaginationChanged; virtual;
    procedure RegisterLink(ALink: Th5uDataControllerLink);
    procedure UnregisterLink(ALink: Th5uDataControllerLink);
    procedure NotifyDataChanged(const AChange: Th5uDataChange);
    function GetDataSessionClass(
      const AContext: Th5uFactoryContext
    property Links: TList<Th5uDataControllerLink> read FLinks;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Invalidate;
    procedure PrepareRange(
    function GetRowCount: Int64;
    function GetTotalRowCount: Int64;
    function GetRowKey(AViewRowIndex: Int64): Th5uRowKey;
    function GetValue(
      AViewRowIndex: Int64;
    procedure SetValue(
      AViewRowIndex: Int64;
    );
    function CanEdit(
      AViewRowIndex: Int64;
    function GetDisplayText(
      AViewRowIndex: Int64;
    function CreateSession(
    ): Th5uDataViewSession; virtual;
    property FactoryScope: Th5uFactoryScope read FFactoryScope;
  published
    property Enabled: Boolean
    property SharedClassFactory: Th5uClassFactory
    property Cache: Th5uCacheOptions read FCache write FCache;
    property Pagination: Th5uPaginationOptions
  end;
function h5uValueToDisplayText(
function h5uTryValueAsInteger(
```

## `h5u.Grid.Data.DataSet`

Quelle: `Source/Common/h5u.Grid.Data.DataSet.pas`

```pascal
  Th5uDataSetController = class;
  Th5uDataSetDataLink = class(TDataLink)
  private
    FOwner: Th5uDataSetController;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AOwner: Th5uDataSetController);
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
  Th5uDataSetController = class(Th5uCustomDataController)
  private
    FDataSource: TDataSource;
    FDataLink: Th5uDataSetDataLink;
    FKeyFieldName: string;
    FSnapshotCache: TObjectDictionary<Int64, Th5uDataRowSnapshot>;
    FCacheGeneration: Int64;
    procedure SetDataSource(const AValue: TDataSource);
    function GetDataSet: TDataSet;
    function ReadFieldValue(AField: TField): TValue;
    procedure WriteFieldValue(AField: TField; const AValue: TValue);
    function CreateSnapshot(
      ASourceRowIndex: Int64
    ): Th5uDataRowSnapshot;
    function GetSnapshot(
      ASourceRowIndex: Int64
    ): Th5uDataRowSnapshot;
    procedure ClearSnapshotCache;
    function GoToSourceRow(ASourceRowIndex: Int64): Boolean;
  protected
    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(
      ASourceRowIndex: Int64
    ): Th5uRowKey; override;
    function GetSourceValue(
      ASourceRowIndex: Int64;
    procedure SetSourceValue(
      ASourceRowIndex: Int64;
    function GetSourceCanEdit(
      ASourceRowIndex: Int64;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareRange(
    procedure DataSetChanged(
      AKind: Th5uDataChangeKind;
      AField: TField = nil
    );
    property DataSet: TDataSet read GetDataSet;
  published
    property DataSource: TDataSource
    property KeyFieldName: string
  end;
```

## `h5u.Grid.Data.Memory`

Quelle: `Source/Common/h5u.Grid.Data.Memory.pas`

```pascal
  Th5uMemoryRow = class
  private
    FKey: Th5uRowKey;
    FValues: TDictionary<string, TValue>;
  public
    constructor Create(const AKey: Th5uRowKey);
    destructor Destroy; override;
    function GetValue(const AFieldName: string): TValue;
    procedure SetValue(
    );
    property Key: Th5uRowKey read FKey write FKey;
  end;
  Th5uMemoryController = class(Th5uCustomDataController)
  private
    FRows: TObjectList<Th5uMemoryRow>;
    FNextKey: Int64;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(
      ASourceRowIndex: Int64
    ): Th5uRowKey; override;
    function GetSourceValue(
      ASourceRowIndex: Int64;
    procedure SetSourceValue(
      ASourceRowIndex: Int64;
    function GetSourceCanEdit(
      ASourceRowIndex: Int64;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AppendRow: Th5uMemoryRow;
    function AppendValues(
    ): Th5uMemoryRow;
    procedure DeleteRow(AIndex: Integer);
    procedure Clear;
    function Row(AIndex: Integer): Th5uMemoryRow;
  end;
```

## `h5u.Grid.Data.Objects`

Quelle: `Source/Common/h5u.Grid.Data.Objects.pas`

```pascal
  Th5uObjectListController = class(Th5uCustomDataController)
  private
    FItems: TList<TObject>;
    FOwnsObjects: Boolean;
    FKeyPropertyName: string;
    FRttiContext: TRttiContext;
    FPropertyCache: TDictionary<string, TRttiProperty>;
    FValueCache: TDictionary<string, TValue>;
    function ResolveProperty(
      AObject: TObject;
    function ReadPropertyPath(
      AObject: TObject;
    procedure WritePropertyPath(
      AObject: TObject;
    );
    function ValueCacheKey(
      ASourceRowIndex: Int64;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(
      ASourceRowIndex: Int64
    ): Th5uRowKey; override;
    function GetSourceValue(
      ASourceRowIndex: Int64;
    procedure SetSourceValue(
      ASourceRowIndex: Int64;
    function GetSourceCanEdit(
      ASourceRowIndex: Int64;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(AObject: TObject);
    procedure Insert(AIndex: Integer; AObject: TObject);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    procedure NotifyObjectChanged(
      AObject: TObject;
    );
    function Item(AIndex: Integer): TObject;
    function GetCount: Integer;
    property Count: Integer read GetCount;
  published
    property OwnsObjects: Boolean
    property KeyPropertyName: string
  end;
```

## `h5u.Grid.Data.Virtual`

Quelle: `Source/Common/h5u.Grid.Data.Virtual.pas`

```pascal
  Th5uVirtualGetRowCountEvent = procedure(
    Sender: TObject;
  Th5uVirtualGetRowKeyEvent = procedure(
    Sender: TObject;
    ASourceRowIndex: Int64;
    var ARowKey: Th5uRowKey
  Th5uVirtualGetValueEvent = procedure(
    Sender: TObject;
    ASourceRowIndex: Int64;
  Th5uVirtualSetValueEvent = procedure(
    Sender: TObject;
    ASourceRowIndex: Int64;
  Th5uVirtualCanEditEvent = procedure(
    Sender: TObject;
    ASourceRowIndex: Int64;
  Th5uVirtualPrepareRangeEvent = procedure(
    Sender: TObject;
    AQueryGeneration: Int64
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
    function CacheKey(
      ASourceRowIndex: Int64;
    procedure ClearValueCache;
  protected
    function GetSourceRowCount: Int64; override;
    function GetSourceRowKey(
      ASourceRowIndex: Int64
    ): Th5uRowKey; override;
    function GetSourceValue(
      ASourceRowIndex: Int64;
    procedure SetSourceValue(
      ASourceRowIndex: Int64;
    function GetSourceCanEdit(
      ASourceRowIndex: Int64;
    procedure DoCacheOptionsChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareRange(
    procedure NotifyReset;
    procedure NotifyRowsInserted(
    );
    procedure NotifyRowsDeleted(
    );
    procedure NotifyRowChanged(
      ASourceRowIndex: Int64;
    );
    procedure BeginNewQuery;
    property QueryGeneration: Int64 read FQueryGeneration;
  published
    property OnGetRowCount: Th5uVirtualGetRowCountEvent
    property OnGetRowKey: Th5uVirtualGetRowKeyEvent
    property OnGetValue: Th5uVirtualGetValueEvent
    property OnSetValue: Th5uVirtualSetValueEvent
    property OnCanEdit: Th5uVirtualCanEditEvent
    property OnPrepareRange: Th5uVirtualPrepareRangeEvent
  end;
```

## `h5u.Grid.Factory`

Quelle: `Source/Common/h5u.Grid.Factory.pas`

```pascal
  Th5uFactoryObject = class;
  Th5uFactoryObjectClass = class of Th5uFactoryObject;
  Th5uCollectionItemClass = class of TCollectionItem;
  Th5uAnyObjectClass = class of TObject;
  Th5uClassRulePredicate = reference to function(
    const AContext: Th5uFactoryContext): Boolean;
  Th5uGetClassEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    var ACacheScope: Th5uFactoryCacheScope
  Th5uCreateInstanceEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    AInstanceClass: TClass;
  Th5uConfigureInstanceEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    AInstance: TObject
  Th5uInstanceEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    AInstance: TObject
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
    function FindLocalClass(
      const AContext: Th5uFactoryContext;
      AExpectedBaseClass: TClass
    procedure ValidateClass(
      const AClassId: Th5uClassId;
    );
    procedure SetParent(const AValue: Th5uFactoryScope);
  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;
    function RegisterClass(
      const AClassId: Th5uClassId;
      APriority: Integer = 0;
      const APredicate: Th5uClassRulePredicate = nil
    ): Th5uClassRegistration;
    procedure Unregister(ARegistration: Th5uClassRegistration);
    procedure Clear;
    function ResolveClass(
      const AContext: Th5uFactoryContext;
      out ACacheScope: Th5uFactoryCacheScope
    function CreateInstance(
      const AContext: Th5uFactoryContext;
    procedure ConfigureInstance(
      const AContext: Th5uFactoryContext;
      AInstance: TObject
    );
    procedure BindInstance(
      const AContext: Th5uFactoryContext;
      AInstance: TObject
    );
    procedure UnbindInstance(
      const AContext: Th5uFactoryContext;
      AInstance: TObject
    );
    property Owner: TObject read FOwner;
    property Parent: Th5uFactoryScope read FParent write SetParent;
    property OnGetClass: Th5uGetClassEvent
    property OnCreateInstance: Th5uCreateInstanceEvent
    property OnConfigureInstance: Th5uConfigureInstanceEvent
    property OnInstanceCreated: Th5uInstanceEvent
    property OnBindInstance: Th5uInstanceEvent
    property OnUnbindInstance: Th5uInstanceEvent
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
    property OnGetClass: Th5uGetClassEvent
    property OnCreateInstance: Th5uCreateInstanceEvent
    property OnConfigureInstance: Th5uConfigureInstanceEvent
  end;
function h5uGlobalFactoryScope: Th5uFactoryScope;
```

## `h5u.Grid.Options`

Quelle: `Source/Common/h5u.Grid.Options.pas`

```pascal
  Th5uOptionsChangedEvent = procedure(Sender: TObject) of object;
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
    property OnChanged: Th5uOptionsChangedEvent
  published
    property Mode: Th5uRowHeightMode
      read FMode write SetMode default Th5uRowHeightMode.Fixed;
    property FixedHeight: Integer
    property MinHeight: Integer
    property MaxHeight: Integer
    property EstimatedHeight: Integer
    property MeasureScope: Th5uAutoHeightMeasureScope
      default Th5uAutoHeightMeasureScope.ExplicitContributorColumns;
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
    property OnChanged: Th5uOptionsChangedEvent
  published
    property VerticalMode: Th5uVerticalScrollMode
      default Th5uVerticalScrollMode.Pixel;
    property HorizontalMode: Th5uHorizontalScrollMode
      default Th5uHorizontalScrollMode.Pixel;
    property OverscanRows: Integer
    property SnapDelay: Integer
    property WheelRows: Integer
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
    property OnChanged: Th5uOptionsChangedEvent
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Triggers: Th5uScrollHintTriggers
    property VerticalColumnId: string
    property ShowRowPosition: Boolean
    property UseHeaderPath: Boolean
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
    property OnChanged: Th5uOptionsChangedEvent
  published
    property Mode: Th5uPaginationMode
      default Th5uPaginationMode.Continuous;
    property PageSize: Integer
    property PageIndex: Integer
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
    property OnChanged: Th5uOptionsChangedEvent
  published
    property Mode: Th5uCacheMode
      read FMode write FMode default Th5uCacheMode.Viewport;
    property PageSize: Integer
    property MaxCachedPages: Integer
    property PrefetchPagesBefore: Integer
    property PrefetchPagesAfter: Integer
    property MaxMemoryBytes: Int64
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
    function ResolveStyle(
      AViewRowIndex: Int64;
      AStyleKey: Integer;
      AHasStyleKey: Boolean
    property OnChanged: Th5uOptionsChangedEvent
  published
    property StripePeriod: Integer
    property StripeOffset: Integer
    property StripeStyleName: string
    property OddStyleName: string
    property EvenStyleName: string
    property StyleKeyColumnId: string
    property Mappings: Th5uRowStyleMappings
    property RestartAtGroup: Boolean
    property RestartAtPage: Boolean
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
    property AllowColumnMoving: Boolean
    property AllowColumnHiding: Boolean
    property AllowColumnResizing: Boolean
    property ShowColumnChooser: Boolean
  end;
```

## `h5u.Grid.SampleData`

Quelle: `Source/Common/h5u.Grid.SampleData.pas`

```pascal
  Th5uSampleClientDataSet = class(TClientDataSet)
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
    property AutoCreateSampleData: Boolean
    property IncludeImages: Boolean
    property SampleRowCount: Integer
  end;
```

## `h5u.Grid.Selection`

Quelle: `Source/Common/h5u.Grid.Selection.pas`

```pascal
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
    procedure SelectRow(
      const ARowKey: Th5uRowKey;
      AAdd: Boolean = False
    );
    procedure ToggleRow(const ARowKey: Th5uRowKey);
    procedure SelectAllRows;
    procedure ExcludeRow(const ARowKey: Th5uRowKey);
    function IsRowSelected(const ARowKey: Th5uRowKey): Boolean;
    procedure SelectColumn(
      AAdd: Boolean = False
    );
    procedure ToggleColumn(const AColumnId: string);
    function IsColumnSelected(const AColumnId: string): Boolean;
    procedure AddCellRange(
      const ARange: Th5uCellRange;
      AAdd: Boolean = False
    );
    function IsCellSelected(
      ARowIndex: Int64;
      AColumnIndex: Integer
    procedure SetFocus(
      const ACell: Th5uCellAddress;
      AUpdateAnchor: Boolean
    );
    property CellRanges: TList<Th5uCellRange> read FCellRanges;
    property FocusedCell: Th5uCellAddress read FFocusedCell;
    property AnchorCell: Th5uCellAddress read FAnchorCell;
    property AllRowsSelected: Boolean read FAllRowsSelected;
    property OnChanged: Th5uSelectionChangedEvent
  published
    property AllowedKinds: Th5uSelectionKinds
    property CombinationMode: Th5uSelectionCombinationMode
      default Th5uSelectionCombinationMode.Mixed;
    property Scope: Th5uSelectionScope
      default Th5uSelectionScope.CurrentQuery;
    property MultiRange: Boolean
    property KeepAcrossPages: Boolean
  end;
```

## `h5u.Grid.Types`

Quelle: `Source/Common/h5u.Grid.Types.pas`

```pascal
  Th5uClassId = type string;
  Th5uColor = type Cardinal;
const
  h5uColorNone = Th5uColor($00000000);
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
    DetailView,
    DataSession,
    DataCache,
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
  );
  Th5uFactoryCacheScope = (
    None,
    ClassId,
    Grid,
    View,
    ElementKind,
    Column,
    HeaderCell,
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
    ClassId: Th5uClassId;
    CreationReason: Th5uCreationReason;
    class function Create(
      const AClassId: Th5uClassId;
      AElementKind: Th5uElementKind
    ): Th5uFactoryContext; static;
  end;
  Th5uGridTheme = (
    ApplicationStyle,
    Classic2000,
    Modern,
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
  );
  Th5uColumnEditorKind = (
    Automatic,
    None,
    Text,
    Boolean,
  );
  Th5uFixedKind = (
    None,
    Left,
  );
  Th5uRowHeightMode = (
    Fixed,
  );
  Th5uAutoHeightMeasureScope = (
    VisibleViewportColumns,
    AllVisibleColumns,
  );
  Th5uVerticalScrollMode = (
    Pixel,
    WholeRows,
  );
  Th5uHorizontalScrollMode = (
    Pixel,
    WholeColumns,
  );
  Th5uScrollAxis = (
    Horizontal,
  );
  Th5uScrollHintTrigger = (
    ThumbTracking,
    MouseWheel,
    Keyboard,
    Touch,
  );
  Th5uScrollHintTriggers = set of Th5uScrollHintTrigger;
  Th5uCacheMode = (
    None,
    Viewport,
    Paged,
    All,
  );
  Th5uPaginationMode = (
    Continuous,
    NumberedPages,
  );
  Th5uSelectionKind = (
    Rows,
    Columns,
  );
  Th5uSelectionKinds = set of Th5uSelectionKind;
  Th5uSelectionCombinationMode = (
    Exclusive,
  );
  Th5uSelectionScope = (
    CurrentPage,
    VisibleRows,
    CurrentQuery,
  );
  Th5uDataChangeKind = (
    Reset,
    LayoutChanged,
    RowsInserted,
    RowsDeleted,
    RowsChanged,
    CellChanged,
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
    class function Create(
    ): Th5uCellRange; static;
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
    Background: Th5uColor;
    Foreground: Th5uColor;
    Border: Th5uColor;
    Accent: Th5uColor;
    FontStyle: TFontStyles;
    HasBackground: Boolean;
    HasForeground: Boolean;
    HasBorder: Boolean;
    HasAccent: Boolean;
    StyleName: string;
    procedure Clear;
  end;
```

## `FMX.h5u.Grid.Editors`

Quelle: `Source/FMX/FMX.h5u.Grid.Editors.pas`

```pascal
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

## `FMX.h5u.Grid`

Quelle: `Source/FMX/FMX.h5u.Grid.pas`

```pascal
  Th5uFmxGrid = class;
  Th5uFmxVisualCell = class;
  Th5uFmxVisualCellClass = class of Th5uFmxVisualCell;
  Th5uFmxCustomDrawStage = (
    BeforeDefault,
  );
  Th5uFmxHitKind = (
    None,
    Header,
    RowIndicator,
  );
  Th5uFmxGetRowHeightContext = record
    Grid: Th5uFmxGrid;
    DataController: Th5uCustomDataController;
    RowKey: Th5uRowKey;
    ViewRowIndex: Int64;
    IsEstimated: Boolean;
  end;
  Th5uFmxGetRowHeightEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFmxGetRowHeightContext;
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
  Th5uFmxGetThumbHintEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFmxThumbHintContext;
  Th5uFmxDrawContext = record
    FactoryContext: Th5uFactoryContext;
    Bounds: TRectF;
    DisplayText: string;
    Appearance: Th5uResolvedAppearance;
  end;
  Th5uFmxCustomDrawEvent = procedure(
    Sender: TObject;
    ACanvas: TCanvas;
    const AContext: Th5uFmxDrawContext;
    AStage: Th5uFmxCustomDrawStage;
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
    procedure PaintDefault(
      AGrid: Th5uFmxGrid;
      ACanvas: TCanvas
  public
    procedure BindCell(
      const AContext: Th5uFactoryContext;
      const AAppearance: Th5uResolvedAppearance
    procedure Paint(
      AGrid: Th5uFmxGrid;
      ACanvas: TCanvas
    property Context: Th5uFactoryContext read FContext;
    property Bounds: TRectF read FBounds;
    property Value: TValue read FValue;
    property DisplayText: string read FDisplayText;
    property Appearance: Th5uResolvedAppearance read FAppearance;
  end;
  Th5uFmxDataCell = class(Th5uFmxVisualCell)
  private
    FBitmap: TBitmap;
    FBitmapSignature: Integer;
    procedure EnsureBitmap;
  protected
    procedure PaintDefault(
      AGrid: Th5uFmxGrid;
      ACanvas: TCanvas
  public
    destructor Destroy; override;
  end;
  Th5uFmxHeaderCell = class(Th5uFmxVisualCell)
  protected
    procedure PaintDefault(
      AGrid: Th5uFmxGrid;
      ACanvas: TCanvas
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
    FTheme: Th5uGridTheme;
    FHeaderRowHeight: Single;
    FRowIndicatorWidth: Single;
    FShowHeader: Boolean;
    FShowRowIndicator: Boolean;
    FAllowEditing: Boolean;
    FGridLines: Boolean;
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
    FOnGetThumbHint: Th5uFmxGetThumbHintEvent;
    FOnCustomDraw: Th5uFmxCustomDrawEvent;
    procedure ColumnsChanged(Sender: TObject; AColumn: Th5uGridColumn);
    procedure DataChanged(Sender: TObject; const AChange: Th5uDataChange);
    procedure OptionsChanged(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure ScrollChanged(Sender: TObject);
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(
      Sender: TObject;
      Shift: TShiftState
    );
    procedure SetColumns(const AValue: Th5uGridColumns);
    procedure SetHeaderLayout(const AValue: Th5uHeaderLayout);
    procedure SetDataController(const AValue: Th5uCustomDataController);
    procedure SetSharedClassFactory(const AValue: Th5uClassFactory);
    procedure SetRowHeight(const AValue: Th5uRowHeightOptions);
    procedure SetScrolling(const AValue: Th5uScrollingOptions);
    procedure SetScrollHints(const AValue: Th5uScrollHintOptions);
    procedure SetRowStyles(const AValue: Th5uRowStyleOptions);
    procedure SetCustomization(const AValue: Th5uCustomizationOptions);
    procedure SetSelection(const AValue: Th5uGridSelection);
    procedure SetTheme(const AValue: Th5uGridTheme);
    function GetOnGetClass: Th5uGetClassEvent;
    procedure SetOnGetClass(const AValue: Th5uGetClassEvent);
    function GetOnCreateInstance: Th5uCreateInstanceEvent;
    procedure SetOnCreateInstance(const AValue: Th5uCreateInstanceEvent);
    function GetOnConfigureInstance: Th5uConfigureInstanceEvent;
    procedure SetOnConfigureInstance(
      const AValue: Th5uConfigureInstanceEvent
    );
    function GetViewportRect: TRectF;
    function GetDataViewportRect: TRectF;
    function GetHeaderHeight: Single;
    function GetTotalColumnWidth: Single;
    function GetEstimatedTotalRowHeight: Double;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(
      const AContext: Th5uFactoryContext;
      ADefaultClass: Th5uFmxVisualCellClass
    ): Th5uFmxVisualCell;
    procedure DrawHeaders;
    procedure DrawRows;
    function GetRowHeightFor(
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey;
      AAllowMeasure: Boolean = True
    function MeasureCellHeight(
      AViewRowIndex: Int64;
      AColumn: Th5uGridColumn
    function FindFirstVisibleRow(
      AOffset: Double;
    function ResolveRowBackground(
      AViewRowIndex: Int64
    function ResolveCellAppearance(
      AViewRowIndex: Int64;
      AColumn: Th5uGridColumn;
    ): Th5uResolvedAppearance;
    function BuildThumbHintText(
      AAxis: Th5uScrollAxis;
      out AContext: Th5uFmxThumbHintContext
    procedure ShowThumbHint(AAxis: Th5uScrollAxis);
    procedure HideThumbHint;
    procedure StartEdit(const AHit: Th5uFmxHitTestInfo);
    procedure CommitEditor;
    procedure CancelEditor;
    procedure ImageEditorCommit(Sender: TObject);
    procedure ImageEditorCancel(Sender: TObject);
    function ParseEditorValue(
      AColumn: Th5uGridColumn;
    function GetVisualCellClass(
      const AContext: Th5uFactoryContext;
      ADefaultClass: Th5uFmxVisualCellClass
    ): Th5uFmxVisualCellClass; virtual;
    procedure DoCustomDraw(
      ACanvas: TCanvas;
      const AContext: Th5uFmxDrawContext;
      AStage: Th5uFmxCustomDrawStage;
    );
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    procedure MouseDown(
      Button: TMouseButton;
      Shift: TShiftState;
    procedure MouseMove(
      Shift: TShiftState;
    procedure DblClick; override;
    procedure MouseWheel(
      Shift: TShiftState;
      WheelDelta: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GridHitTest(X, Y: Single): Th5uFmxHitTestInfo;
    procedure InvalidateAllRowHeights;
    procedure MoveColumn(
      AColumn: Th5uGridColumn;
      ANewVisibleIndex: Integer
    );
    procedure SetColumnVisible(
      AColumn: Th5uGridColumn;
      AVisible: Boolean
    );
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
    property DataController: Th5uCustomDataController
    property SharedClassFactory: Th5uClassFactory
    property Columns: Th5uGridColumns
    property HeaderLayout: Th5uHeaderLayout
    property Selection: Th5uGridSelection
    property RowHeight: Th5uRowHeightOptions
    property Scrolling: Th5uScrollingOptions
    property ScrollHints: Th5uScrollHintOptions
    property RowStyles: Th5uRowStyleOptions
    property Customization: Th5uCustomizationOptions
    property Theme: Th5uGridTheme
      default Th5uGridTheme.ApplicationStyle;
    property HeaderRowHeight: Single
    property RowIndicatorWidth: Single
    property ShowHeader: Boolean
    property ShowRowIndicator: Boolean
    property AllowEditing: Boolean
    property GridLines: Boolean
    property TextSize: Single read FTextSize write FTextSize;
    property OnGetClass: Th5uGetClassEvent
    property OnCreateInstance: Th5uCreateInstanceEvent
    property OnConfigureInstance: Th5uConfigureInstanceEvent
    property OnGetRowHeight: Th5uFmxGetRowHeightEvent
    property OnGetThumbHint: Th5uFmxGetThumbHintEvent
    property OnCustomDraw: Th5uFmxCustomDrawEvent
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

## `FMX.h5u.Grid.Styles`

Quelle: `Source/FMX/FMX.h5u.Grid.Styles.pas`

```pascal
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
    DisabledText: TAlphaColor;
    ThumbHintBackground: TAlphaColor;
    ThumbHintText: TAlphaColor;
  end;
function h5uGetFmxPalette(ATheme: Th5uGridTheme): Th5uFmxPalette;
function h5uColorToFmx(const AColor: Th5uColor): TAlphaColor;
function h5uFmxToColor(const AColor: TAlphaColor): Th5uColor;
```

## `Vcl.h5u.Grid.Editors`

Quelle: `Source/Vcl/Vcl.h5u.Grid.Editors.pas`

```pascal
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
    class function Execute(
      AOwner: TComponent;
  end;
```

## `Vcl.h5u.Grid`

Quelle: `Source/Vcl/Vcl.h5u.Grid.pas`

```pascal
  Th5uVclGrid = class;
  Th5uVclVisualCell = class;
  Th5uVclVisualCellClass = class of Th5uVclVisualCell;
  Th5uCustomDrawStage = (
    BeforeDefault,
  );
  Th5uHitKind = (
    None,
    Header,
    RowIndicator,
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
  Th5uRowAppearanceEvent = procedure(
    Sender: TObject;
    AViewRowIndex: Int64;
    const ARowKey: Th5uRowKey;
    var AAppearance: Th5uResolvedAppearance
  Th5uCellAppearanceEvent = procedure(
    Sender: TObject;
    const AContext: Th5uFactoryContext;
    var AAppearance: Th5uResolvedAppearance
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
    function EffectiveBackground(
      AGrid: Th5uVclGrid
    function EffectiveForeground(
      AGrid: Th5uVclGrid
  public
    procedure BindCell(
      const AContext: Th5uFactoryContext;
      const AAppearance: Th5uResolvedAppearance
    procedure Paint(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
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
  public
    destructor Destroy; override;
  end;
  Th5uVclHeaderCell = class(Th5uVclVisualCell)
  protected
    procedure PaintDefault(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
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
    FTheme: Th5uGridTheme;
    FHeaderRowHeight: Integer;
    FRowIndicatorWidth: Integer;
    FShowHeader: Boolean;
    FShowRowIndicator: Boolean;
    FAllowEditing: Boolean;
    FGridLines: Boolean;
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
    procedure SetSelection(const AValue: Th5uGridSelection);
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
    );
    procedure ThumbHintTimer(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyDown(
      Sender: TObject;
      Shift: TShiftState
    );
    function GetViewportRect: TRect;
    function GetHeaderHeight: Integer;
    function GetDataViewportRect: TRect;
    function GetTotalColumnWidth: Integer;
    function GetEstimatedTotalRowHeight: Int64;
    procedure LayoutScrollBars;
    procedure UpdateScrollBars;
    procedure BuildColumnLayout;
    procedure BeginVisualPass;
    function AcquireVisualCell(
      const AContext: Th5uFactoryContext;
      ADefaultClass: Th5uVclVisualCellClass
    ): Th5uVclVisualCell;
    procedure DrawHeaders;
    procedure DrawRows;
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
    function MeasureCellHeight(
      AViewRowIndex: Int64;
      AColumn: Th5uGridColumn
    function FindFirstVisibleRow(
      AOffset: Int64;
    function GetRowStyle(
      AViewRowIndex: Int64;
    function ResolveRowAppearance(
      AViewRowIndex: Int64;
      const ARowKey: Th5uRowKey;
    ): Th5uResolvedAppearance;
    function ResolveCellAppearance(
      const AContext: Th5uFactoryContext;
      AColumn: Th5uGridColumn;
      const ARowAppearance: Th5uResolvedAppearance;
    ): Th5uResolvedAppearance;
    function ColumnInfoAtPoint(
      out AInfo: Th5uVisibleColumnInfo
    function RowInfoAtPoint(
      out AInfo: Th5uVisibleRowInfo
    procedure ShowThumbHint(
      AAxis: Th5uScrollAxis;
      ATrigger: Th5uScrollHintTrigger
    );
    procedure HideThumbHint;
    function BuildThumbHintText(
      AAxis: Th5uScrollAxis;
      ATrigger: Th5uScrollHintTrigger;
      out AContext: Th5uThumbHintContext
    procedure StartEdit(const AHit: Th5uHitTestInfo);
    procedure CommitEditor;
    procedure CancelEditor;
    function ParseEditorValue(
      AColumn: Th5uGridColumn;
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
    );
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    procedure MouseDown(
      Button: TMouseButton;
      Shift: TShiftState;
    procedure MouseMove(
      Shift: TShiftState;
    procedure MouseUp(
      Button: TMouseButton;
      Shift: TShiftState;
    procedure DblClick; override;
    function DoMouseWheel(
      Shift: TShiftState;
      WheelDelta: Integer;
      MousePos: TPoint
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
    property SharedClassFactory: Th5uClassFactory
    property Columns: Th5uGridColumns
    property HeaderLayout: Th5uHeaderLayout
    property Selection: Th5uGridSelection
    property RowHeight: Th5uRowHeightOptions
    property Scrolling: Th5uScrollingOptions
    property ScrollHints: Th5uScrollHintOptions
    property RowStyles: Th5uRowStyleOptions
    property Customization: Th5uCustomizationOptions
    property Theme: Th5uGridTheme
      default Th5uGridTheme.ApplicationStyle;
    property HeaderRowHeight: Integer
    property RowIndicatorWidth: Integer
    property ShowHeader: Boolean
    property ShowRowIndicator: Boolean
    property AllowEditing: Boolean
    property GridLines: Boolean
    property OnGetClass: Th5uGetClassEvent
    property OnCreateInstance: Th5uCreateInstanceEvent
    property OnConfigureInstance: Th5uConfigureInstanceEvent
    property OnGetRowHeight: Th5uGetRowHeightEvent
    property OnGetThumbHint: Th5uGetThumbHintEvent
    property OnGetRowAppearance: Th5uRowAppearanceEvent
    property OnGetCellAppearance: Th5uCellAppearanceEvent
    property OnCustomDraw: Th5uVclCustomDrawEvent
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

## `Vcl.h5u.Grid.Styles`

Quelle: `Source/Vcl/Vcl.h5u.Grid.Styles.pas`

```pascal
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
    DisabledText: TColor;
    ThumbHintBackground: TColor;
    ThumbHintText: TColor;
  end;
function h5uGetVclPalette(ATheme: Th5uGridTheme): Th5uVclPalette;
function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
function h5uColorToVcl(const AColor: Th5uColor): TColor;
function h5uVclToColor(const AColor: TColor): Th5uColor;
```
