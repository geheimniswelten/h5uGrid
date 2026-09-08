unit h5u.Grid.Options;

interface

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
    FColumnMovingGesture: Th5uColumnMovingGesture;
    FAllowRowMoving: Boolean;
    FRowMovingGesture: Th5uRowMovingGesture;
    FAllowColumnHiding: Boolean;
    FAllowColumnResizing: Boolean;
    FShowColumnChooser: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property AllowColumnMoving: Boolean read FAllowColumnMoving write FAllowColumnMoving default True;
    property AllowRowMoving: Boolean read FAllowRowMoving write FAllowRowMoving default True;
    property RowMovingGesture: Th5uRowMovingGesture read FRowMovingGesture write FRowMovingGesture default Th5uRowMovingGesture.AltDrag;
    property ColumnMovingGesture: Th5uColumnMovingGesture read FColumnMovingGesture write FColumnMovingGesture default Th5uColumnMovingGesture.AltDrag;
    property AllowColumnHiding: Boolean read FAllowColumnHiding write FAllowColumnHiding default True;
    property AllowColumnResizing: Boolean read FAllowColumnResizing write FAllowColumnResizing default True;
    property ShowColumnChooser: Boolean read FShowColumnChooser write FShowColumnChooser default True;
  end;

implementation

{ Th5uGridSpacingOptions }

procedure Th5uGridSpacingOptions.Assign(Source: TPersistent);
var
  LSource: Th5uGridSpacingOptions;
begin
  if Source is Th5uGridSpacingOptions then
  begin
    LSource := Th5uGridSpacingOptions(Source);
    FLeft := LSource.FLeft;
    FTop := LSource.FTop;
    FRight := LSource.FRight;
    FBottom := LSource.FBottom;
    FRowSpacing := LSource.FRowSpacing;
    FDefaultColumnRightSpacing := LSource.FDefaultColumnRightSpacing;
    FRowSpacingColor := LSource.FRowSpacingColor;
    FColumnSpacingColor := LSource.FColumnSpacingColor;
    FContentPaddingColor := LSource.FContentPaddingColor;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uGridSpacingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uGridSpacingOptions.Create;
begin
  inherited;
  FLeft := 1;
  FTop := 1;
  FRight := 1;
  FBottom := 1;
  FRowSpacing := 1;
  FDefaultColumnRightSpacing := 1;
  FRowSpacingColor := TColorRec.Lightgray;
  FColumnSpacingColor := TColorRec.Lightgray;
  FContentPaddingColor := TColorRec.Lightgray;
end;

procedure Th5uGridSpacingOptions.SetBottom(const AValue: Integer);
begin
  if FBottom = AValue then
    Exit;
  FBottom := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetColumnSpacingColor(const AValue: TColor);
begin
  if FColumnSpacingColor = AValue then
    Exit;
  FColumnSpacingColor := AValue;
  Changed;
end;

procedure Th5uGridSpacingOptions.SetContentPaddingColor(const AValue: TColor);
begin
  if FContentPaddingColor = AValue then
    Exit;
  FContentPaddingColor := AValue;
  Changed;
end;

procedure Th5uGridSpacingOptions.SetDefaultColumnRightSpacing(const AValue: Integer);
begin
  if FDefaultColumnRightSpacing = AValue then
    Exit;
  FDefaultColumnRightSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetLeft(const AValue: Integer);
begin
  if FLeft = AValue then
    Exit;
  FLeft := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetAllSeparators(const ASize: Integer);
var
  LSize: Integer;
begin
  LSize := EnsureRange(ASize, 0, 1000);
  if (FLeft = LSize) and (FTop = LSize) and (FRight = LSize) and (FBottom = LSize) and (FRowSpacing = LSize) and (FDefaultColumnRightSpacing
    = LSize) then
    Exit;

  FLeft := LSize;
  FTop := LSize;
  FRight := LSize;
  FBottom := LSize;
  FRowSpacing := LSize;
  FDefaultColumnRightSpacing := LSize;
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRight(const AValue: Integer);
begin
  if FRight = AValue then
    Exit;
  FRight := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRowSpacing(const AValue: Integer);
begin
  if FRowSpacing = AValue then
    Exit;
  FRowSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRowSpacingColor(const AValue: TColor);
begin
  if FRowSpacingColor = AValue then
    Exit;
  FRowSpacingColor := AValue;
  Changed;
end;

procedure Th5uGridSpacingOptions.SetTop(const AValue: Integer);
begin
  if FTop = AValue then
    Exit;
  FTop := EnsureRange(AValue, 0, 10000);
  Changed;
end;

{ Th5uGridAppearanceOptions }

procedure Th5uGridAppearanceOptions.Assign(Source: TPersistent);
begin
  if Source is Th5uGridAppearanceOptions then
  begin
    FDefaultCellColor := Th5uGridAppearanceOptions(Source).FDefaultCellColor;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uGridAppearanceOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uGridAppearanceOptions.Create;
begin
  inherited;
  FDefaultCellColor := TColorRec.SysDefault;
end;

procedure Th5uGridAppearanceOptions.SetDefaultCellColor(const AValue: TColor);
begin
  if FDefaultCellColor = AValue then
    Exit;
  FDefaultCellColor := AValue;
  Changed;
end;

{ Th5uTreeBranchEndBandOptions }

procedure Th5uTreeBranchEndBandOptions.Assign(Source: TPersistent);
var
  LSource: Th5uTreeBranchEndBandOptions;
begin
  if Source is Th5uTreeBranchEndBandOptions then
  begin
    LSource := Th5uTreeBranchEndBandOptions(Source);
    FEnabled := LSource.FEnabled;
    FHeight := LSource.FHeight;
    FColor := LSource.FColor;
    FStyleName := LSource.FStyleName;
    FIncludeEndOfData := LSource.FIncludeEndOfData;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uTreeBranchEndBandOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uTreeBranchEndBandOptions.Create;
begin
  inherited;
  FEnabled := False;
  FHeight := 6;
  FColor := TColorRec.SysDefault;
  FStyleName := '';
  FIncludeEndOfData := True;
end;

procedure Th5uTreeBranchEndBandOptions.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure Th5uTreeBranchEndBandOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure Th5uTreeBranchEndBandOptions.SetHeight(const AValue: Integer);
begin
  if FHeight = AValue then
    Exit;
  FHeight := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uTreeBranchEndBandOptions.SetIncludeEndOfData(const AValue: Boolean);
begin
  if FIncludeEndOfData = AValue then
    Exit;
  FIncludeEndOfData := AValue;
  Changed;
end;

procedure Th5uTreeBranchEndBandOptions.SetStyleName(const AValue: string);
begin
  if FStyleName = AValue then
    Exit;
  FStyleName := AValue;
  Changed;
end;

{ Th5uTreeOptions }

procedure Th5uTreeOptions.Assign(Source: TPersistent);
var
  LSource: Th5uTreeOptions;
begin
  if Source is Th5uTreeOptions then
  begin
    LSource := Th5uTreeOptions(Source);
    FEnabled := LSource.FEnabled;
    FLevelColumnId := LSource.FLevelColumnId;
    FBranchEndBand.Assign(LSource.FBranchEndBand);
    Changed;
  end
  else
    inherited;
end;

procedure Th5uTreeOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure Th5uTreeOptions.ChildChanged(Sender: TObject);
begin
  Changed;
end;

constructor Th5uTreeOptions.Create;
begin
  inherited;
  FEnabled := False;
  FBranchEndBand := Th5uTreeBranchEndBandOptions.Create;
  FBranchEndBand.OnChanged := ChildChanged;
end;

destructor Th5uTreeOptions.Destroy;
begin
  FBranchEndBand.Free;
  inherited;
end;

procedure Th5uTreeOptions.SetBranchEndBand(const AValue: Th5uTreeBranchEndBandOptions);
begin
  if Assigned(AValue) then
    FBranchEndBand.Assign(AValue);
end;

procedure Th5uTreeOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure Th5uTreeOptions.SetLevelColumnId(const AValue: string);
begin
  if FLevelColumnId = AValue then
    Exit;
  FLevelColumnId := AValue;
  Changed;
end;

{ Th5uAdjacentGroupEndBandOptions }

procedure Th5uAdjacentGroupEndBandOptions.Assign(Source: TPersistent);
var
  LSource: Th5uAdjacentGroupEndBandOptions;
begin
  if Source is Th5uAdjacentGroupEndBandOptions then
  begin
    LSource := Th5uAdjacentGroupEndBandOptions(Source);
    FVisibility := LSource.FVisibility;
    FHeight := LSource.FHeight;
    FColor := LSource.FColor;
    FStyleName := LSource.FStyleName;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uAdjacentGroupEndBandOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uAdjacentGroupEndBandOptions.Create;
begin
  inherited;
  FVisibility := Th5uAdjacentGroupEndBandVisibility.Never;
  FHeight := 6;
  FColor := TColorRec.SysDefault;
  FStyleName := '';
end;

procedure Th5uAdjacentGroupEndBandOptions.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupEndBandOptions.SetHeight(const AValue: Integer);
begin
  if FHeight = AValue then
    Exit;
  FHeight := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uAdjacentGroupEndBandOptions.SetStyleName(const AValue: string);
begin
  if FStyleName = AValue then
    Exit;
  FStyleName := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupEndBandOptions.SetVisibility(const AValue: Th5uAdjacentGroupEndBandVisibility);
begin
  if FVisibility = AValue then
    Exit;
  FVisibility := AValue;
  Changed;
end;

{ Th5uAdjacentGroupFoldingOptions }

procedure Th5uAdjacentGroupFoldingOptions.Assign(Source: TPersistent);
var
  LSource: Th5uAdjacentGroupFoldingOptions;
begin
  if Source is Th5uAdjacentGroupFoldingOptions then
  begin
    LSource := Th5uAdjacentGroupFoldingOptions(Source);
    FEnabled := LSource.FEnabled;
    FIdColumnId := LSource.FIdColumnId;
    FInitialState := LSource.FInitialState;
    FShowFoldGlyph := LSource.FShowFoldGlyph;
    FCaseSensitive := LSource.FCaseSensitive;
    FGroupEmptyValues := LSource.FGroupEmptyValues;
    FPreserveStateOnDataChange := LSource.FPreserveStateOnDataChange;
    FEndBand.Assign(LSource.FEndBand);
    Changed;
  end
  else
    inherited;
end;

procedure Th5uAdjacentGroupFoldingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure Th5uAdjacentGroupFoldingOptions.ChildChanged(Sender: TObject);
begin
  Changed;
end;

constructor Th5uAdjacentGroupFoldingOptions.Create;
begin
  inherited;
  FEnabled := False;
  FInitialState := Th5uAdjacentGroupInitialState.Expanded;
  FShowFoldGlyph := True;
  FCaseSensitive := True;
  FGroupEmptyValues := True;
  FPreserveStateOnDataChange := True;
  FEndBand := Th5uAdjacentGroupEndBandOptions.Create;
  FEndBand.OnChanged := ChildChanged;
end;

destructor Th5uAdjacentGroupFoldingOptions.Destroy;
begin
  FEndBand.Free;
  inherited;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetCaseSensitive(const AValue: Boolean);
begin
  if FCaseSensitive = AValue then
    Exit;
  FCaseSensitive := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetEndBand(const AValue: Th5uAdjacentGroupEndBandOptions);
begin
  if Assigned(AValue) then
    FEndBand.Assign(AValue);
end;

procedure Th5uAdjacentGroupFoldingOptions.SetGroupEmptyValues(const AValue: Boolean);
begin
  if FGroupEmptyValues = AValue then
    Exit;
  FGroupEmptyValues := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetIdColumnId(const AValue: string);
begin
  if FIdColumnId = AValue then
    Exit;
  FIdColumnId := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetInitialState(const AValue: Th5uAdjacentGroupInitialState);
begin
  if FInitialState = AValue then
    Exit;
  FInitialState := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetPreserveStateOnDataChange(const AValue: Boolean);
begin
  if FPreserveStateOnDataChange = AValue then
    Exit;
  FPreserveStateOnDataChange := AValue;
  Changed;
end;

procedure Th5uAdjacentGroupFoldingOptions.SetShowFoldGlyph(const AValue: Boolean);
begin
  if FShowFoldGlyph = AValue then
    Exit;
  FShowFoldGlyph := AValue;
  Changed;
end;

{ Th5uRowHeightOptions }

procedure Th5uRowHeightOptions.Assign(Source: TPersistent);
var
  LSource: Th5uRowHeightOptions;
begin
  if Source is Th5uRowHeightOptions then
  begin
    LSource := Th5uRowHeightOptions(Source);
    FMode := LSource.FMode;
    FFixedHeight := LSource.FFixedHeight;
    FMinHeight := LSource.FMinHeight;
    FMaxHeight := LSource.FMaxHeight;
    FEstimatedHeight := LSource.FEstimatedHeight;
    FMeasureScope := LSource.FMeasureScope;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uRowHeightOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uRowHeightOptions.Create;
begin
  inherited;
  FMode := Th5uRowHeightMode.Fixed;
  FFixedHeight := 24;
  FMinHeight := 20;
  FMaxHeight := 180;
  FEstimatedHeight := 24;
  FMeasureScope := Th5uAutoHeightMeasureScope.ExplicitContributorColumns;
end;

procedure Th5uRowHeightOptions.SetEstimatedHeight(const AValue: Integer);
begin
  FEstimatedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetFixedHeight(const AValue: Integer);
begin
  FFixedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetMaxHeight(const AValue: Integer);
begin
  FMaxHeight := EnsureRange(AValue, FMinHeight, 4000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetMinHeight(const AValue: Integer);
begin
  FMinHeight := EnsureRange(AValue, 8, FMaxHeight);
  Changed;
end;

procedure Th5uRowHeightOptions.SetMode(const AValue: Th5uRowHeightMode);
begin
  if FMode = AValue then
    Exit;
  FMode := AValue;
  Changed;
end;

{ Th5uScrollingOptions }

procedure Th5uScrollingOptions.Assign(Source: TPersistent);
var
  LSource: Th5uScrollingOptions;
begin
  if Source is Th5uScrollingOptions then
  begin
    LSource := Th5uScrollingOptions(Source);
    FVerticalMode := LSource.FVerticalMode;
    FHorizontalMode := LSource.FHorizontalMode;
    FOverscanRows := LSource.FOverscanRows;
    FSnapDelay := LSource.FSnapDelay;
    FWheelRows := LSource.FWheelRows;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uScrollingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uScrollingOptions.Create;
begin
  inherited;
  FVerticalMode := Th5uVerticalScrollMode.Pixel;
  FHorizontalMode := Th5uHorizontalScrollMode.Pixel;
  FOverscanRows := 2;
  FSnapDelay := 120;
  FWheelRows := 3;
end;

{ Th5uScrollHintOptions }

procedure Th5uScrollHintOptions.Assign(Source: TPersistent);
var
  LSource: Th5uScrollHintOptions;
begin
  if Source is Th5uScrollHintOptions then
  begin
    LSource := Th5uScrollHintOptions(Source);
    FEnabled := LSource.FEnabled;
    FTriggers := LSource.FTriggers;
    FVerticalColumnId := LSource.FVerticalColumnId;
    FShowRowPosition := LSource.FShowRowPosition;
    FUseHeaderPath := LSource.FUseHeaderPath;
  end
  else
    inherited;
end;

constructor Th5uScrollHintOptions.Create;
begin
  inherited;
  FEnabled := True;
  FTriggers := [Th5uScrollHintTrigger.ThumbTracking];
  FShowRowPosition := True;
  FUseHeaderPath := True;
end;

{ Th5uPaginationOptions }

procedure Th5uPaginationOptions.Assign(Source: TPersistent);
var
  LSource: Th5uPaginationOptions;
begin
  if Source is Th5uPaginationOptions then
  begin
    LSource := Th5uPaginationOptions(Source);
    FMode := LSource.FMode;
    FPageSize := LSource.FPageSize;
    FPageIndex := LSource.FPageIndex;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uPaginationOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uPaginationOptions.Create;
begin
  inherited;
  FMode := Th5uPaginationMode.Continuous;
  FPageSize := 100;
  FPageIndex := 0;
end;

procedure Th5uPaginationOptions.SetPageIndex(const AValue: Integer);
begin
  FPageIndex := Max(0, AValue);
  Changed;
end;

procedure Th5uPaginationOptions.SetPageSize(const AValue: Integer);
begin
  FPageSize := EnsureRange(AValue, 1, 1000000);
  Changed;
end;

{ Th5uCacheOptions }

procedure Th5uCacheOptions.Assign(Source: TPersistent);
var
  LSource: Th5uCacheOptions;
begin
  if Source is Th5uCacheOptions then
  begin
    LSource := Th5uCacheOptions(Source);
    FMode := LSource.FMode;
    FPageSize := LSource.FPageSize;
    FMaxCachedPages := LSource.FMaxCachedPages;
    FPrefetchPagesBefore := LSource.FPrefetchPagesBefore;
    FPrefetchPagesAfter := LSource.FPrefetchPagesAfter;
    FMaxMemoryBytes := LSource.FMaxMemoryBytes;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uCacheOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uCacheOptions.Create;
begin
  inherited;
  FMode := Th5uCacheMode.Viewport;
  FPageSize := 200;
  FMaxCachedPages := 8;
  FPrefetchPagesBefore := 1;
  FPrefetchPagesAfter := 2;
  FMaxMemoryBytes := 64 * 1024 * 1024;
end;

{ Th5uRowStyleOptions }

procedure Th5uRowStyleOptions.Assign(Source: TPersistent);
var
  LSource: Th5uRowStyleOptions;
begin
  if Source is Th5uRowStyleOptions then
  begin
    LSource := Th5uRowStyleOptions(Source);
    FStripePeriod := LSource.FStripePeriod;
    FStripeOffset := LSource.FStripeOffset;
    FStripeStyleName := LSource.FStripeStyleName;
    FOddStyleName := LSource.FOddStyleName;
    FEvenStyleName := LSource.FEvenStyleName;
    FStyleKeyColumnId := LSource.FStyleKeyColumnId;
    FMappings.Assign(LSource.FMappings);
    FRestartAtGroup := LSource.FRestartAtGroup;
    FRestartAtPage := LSource.FRestartAtPage;
  end
  else
    inherited;
end;

constructor Th5uRowStyleOptions.Create;
begin
  inherited;
  FStripePeriod := 2;
  FStripeOffset := 1;
  FStripeStyleName := 'Stripe';
  FOddStyleName := 'Odd';
  FEvenStyleName := 'Even';
  FRestartAtGroup := False;
  FRestartAtPage := False;
  FMappings := Th5uRowStyleMappings.Create(Self);
end;

destructor Th5uRowStyleOptions.Destroy;
begin
  FMappings.Free;
  inherited;
end;

function Th5uRowStyleOptions.ResolveStyle(AViewRowIndex: Int64; AStyleKey: Integer; AHasStyleKey: Boolean): string;
var
  LIndex: Int64;
begin
  if AHasStyleKey and FMappings.FindStyle(AStyleKey, Result) then
    Exit;

  if FStripePeriod > 0 then
  begin
    LIndex := AViewRowIndex + 1 - FStripeOffset;
    if (LIndex >= 0) and ((LIndex mod FStripePeriod) = 0) then
      Exit(FStripeStyleName);
  end;

  if Odd(AViewRowIndex) then
    Result := FOddStyleName
  else
    Result := FEvenStyleName;
end;

procedure Th5uRowStyleOptions.SetMappings(const AValue: Th5uRowStyleMappings);
begin
  FMappings.Assign(AValue);
end;

{ Th5uCustomizationOptions }

procedure Th5uCustomizationOptions.Assign(Source: TPersistent);
var
  LSource: Th5uCustomizationOptions;
begin
  if Source is Th5uCustomizationOptions then
  begin
    LSource := Th5uCustomizationOptions(Source);
    FAllowColumnMoving := LSource.FAllowColumnMoving;
    FColumnMovingGesture := LSource.FColumnMovingGesture;
    FAllowRowMoving := LSource.FAllowRowMoving;
    FRowMovingGesture := LSource.FRowMovingGesture;
    FAllowColumnHiding := LSource.FAllowColumnHiding;
    FAllowColumnResizing := LSource.FAllowColumnResizing;
    FShowColumnChooser := LSource.FShowColumnChooser;
  end
  else
    inherited;
end;

constructor Th5uCustomizationOptions.Create;
begin
  inherited;
  FAllowColumnMoving := True;
  FColumnMovingGesture := Th5uColumnMovingGesture.AltDrag;
  FAllowRowMoving := True;
  FRowMovingGesture := Th5uRowMovingGesture.AltDrag;
  FAllowColumnHiding := True;
  FAllowColumnResizing := True;
  FShowColumnChooser := True;
end;

end.
