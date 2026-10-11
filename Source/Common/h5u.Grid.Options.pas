unit h5u.Grid.Options;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

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
    FRowHeight: Single;
    FLayout: ThiiHeaderLayout;
    FAssigning: Boolean;
    FOnChanged: ThiiOptionsChangedEvent;
    procedure Changed;
    procedure LayoutChanged(Sender: TObject);
    procedure SetLayout(const AValue: ThiiHeaderLayout);
    procedure SetRowHeight(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: ThiiOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visible: Boolean read FVisible write SetVisible default True;
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

implementation

{ ThiiGridHeaderOptions }

procedure ThiiGridHeaderOptions.Assign(Source: TPersistent);
var
  LSource: ThiiGridHeaderOptions;
begin
  if Source = Self then
    Exit;
  if Source is ThiiGridHeaderOptions then
  begin
    LSource := ThiiGridHeaderOptions(Source);
    FAssigning := True;
    try
      FVisible := LSource.FVisible;
      FRowHeight := LSource.FRowHeight;
      FLayout.Assign(LSource.FLayout);
    finally
      FAssigning := False;
    end;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiGridHeaderOptions.Changed;
begin
  if not FAssigning and Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiGridHeaderOptions.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FVisible := True;
  FRowHeight := 26;
  FLayout := ThiiHeaderLayout.Create(Self);
  FLayout.OnChanged := {$IFDEF FPC}@{$ENDIF}LayoutChanged;
end;

destructor ThiiGridHeaderOptions.Destroy;
begin
  FLayout.Free;
  inherited;
end;

function ThiiGridHeaderOptions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure ThiiGridHeaderOptions.LayoutChanged(Sender: TObject);
begin
  Changed;
end;

procedure ThiiGridHeaderOptions.SetLayout(const AValue: ThiiHeaderLayout);
begin
  if Assigned(AValue) and (AValue <> FLayout) then
  begin
    FAssigning := True;
    try
      FLayout.Assign(AValue);
    finally
      FAssigning := False;
    end;
    Changed;
  end;
end;

procedure ThiiGridHeaderOptions.SetRowHeight(const AValue: Single);
var
  LValue: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  LValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FRowHeight = LValue then
    Exit;
  FRowHeight := LValue;
  Changed;
end;

procedure ThiiGridHeaderOptions.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

{ ThiiRowIndicatorOptions }

procedure ThiiRowIndicatorOptions.Assign(Source: TPersistent);
var
  LSource: ThiiRowIndicatorOptions;
begin
  if Source is ThiiRowIndicatorOptions then
  begin
    LSource := ThiiRowIndicatorOptions(Source);
    FVisible := LSource.FVisible;
    FWidth := LSource.FWidth;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiRowIndicatorOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiRowIndicatorOptions.Create;
begin
  inherited Create;
  FVisible := True;
  FWidth := 34;
end;

procedure ThiiRowIndicatorOptions.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure ThiiRowIndicatorOptions.SetWidth(const AValue: Single);
var
  LValue: Single;
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  LValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FWidth = LValue then
    Exit;
  FWidth := LValue;
  Changed;
end;

{ ThiiEditingOptions }

procedure ThiiEditingOptions.Assign(Source: TPersistent);
var
  LSource: ThiiEditingOptions;
begin
  if Source is ThiiEditingOptions then
  begin
    LSource := ThiiEditingOptions(Source);
    FAllowEditing := LSource.FAllowEditing;
    FImmediateEdit := LSource.FImmediateEdit;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiEditingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiEditingOptions.Create;
begin
  inherited Create;
  FAllowEditing := True;
  FImmediateEdit := False;
end;

procedure ThiiEditingOptions.SetAllowEditing(const AValue: Boolean);
begin
  if FAllowEditing = AValue then
    Exit;
  FAllowEditing := AValue;
  Changed;
end;

procedure ThiiEditingOptions.SetImmediateEdit(const AValue: Boolean);
begin
  if FImmediateEdit = AValue then
    Exit;
  FImmediateEdit := AValue;
  Changed;
end;

{ ThiiGridAppearanceOptions }

procedure ThiiGridAppearanceOptions.Assign(Source: TPersistent);
var
  LSource: ThiiGridAppearanceOptions;
  LThemeChanged: Boolean;
begin
  if Source is ThiiGridAppearanceOptions then
  begin
    LSource := ThiiGridAppearanceOptions(Source);
    LThemeChanged := FTheme <> LSource.FTheme;
    FTheme := LSource.FTheme;
    FDefaultCellColor := LSource.FDefaultCellColor;
    FRowSpacingColor := LSource.FRowSpacingColor;
    FColumnSpacingColor := LSource.FColumnSpacingColor;
    FContentPaddingColor := LSource.FContentPaddingColor;
    if LThemeChanged then
      ThemeChanged;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiGridAppearanceOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiGridAppearanceOptions.Create;
begin
  inherited Create;
  FTheme := ThiiGridTheme.ApplicationStyle;
  FDefaultCellColor := TColorRec.SysDefault;
  FRowSpacingColor := TColorRec.Lightgray;
  FColumnSpacingColor := TColorRec.Lightgray;
  FContentPaddingColor := TColorRec.Lightgray;
end;

procedure ThiiGridAppearanceOptions.SetColumnSpacingColor(const AValue: TColor);
begin
  if FColumnSpacingColor = AValue then
    Exit;
  FColumnSpacingColor := AValue;
  Changed;
end;

procedure ThiiGridAppearanceOptions.SetContentPaddingColor(const AValue: TColor);
begin
  if FContentPaddingColor = AValue then
    Exit;
  FContentPaddingColor := AValue;
  Changed;
end;

procedure ThiiGridAppearanceOptions.SetDefaultCellColor(const AValue: TColor);
begin
  if FDefaultCellColor = AValue then
    Exit;
  FDefaultCellColor := AValue;
  Changed;
end;

procedure ThiiGridAppearanceOptions.SetRowSpacingColor(const AValue: TColor);
begin
  if FRowSpacingColor = AValue then
    Exit;
  FRowSpacingColor := AValue;
  Changed;
end;

procedure ThiiGridAppearanceOptions.SetTheme(const AValue: ThiiGridTheme);
begin
  if FTheme = AValue then
    Exit;
  FTheme := AValue;
  ThemeChanged;
  Changed;
end;

procedure ThiiGridAppearanceOptions.ThemeChanged;
begin
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self);
end;

{ ThiiGridSpacingOptions }

function h5uReadSpacingColor(AReader: TReader): TColor;
var
  LIdent: string;
  LValue: Integer;
  LIdentToInt: TIdentToInt;
begin
  if AReader.NextValue <> vaIdent then
    Exit(TColor(AReader.ReadInteger));

  LIdent := AReader.ReadIdent;
  LIdentToInt := FindIdentToInt(TypeInfo(TColor));
  if not Assigned(LIdentToInt) then
    raise EReadError.CreateFmt('Unknown color: %s', [LIdent]);
  if not LIdentToInt(LIdent, LValue) then
    raise EReadError.CreateFmt('Unknown color: %s', [LIdent]);
  Result := TColor(LValue);
end;

procedure ThiiGridSpacingOptions.Assign(Source: TPersistent);
var
  LSource: ThiiGridSpacingOptions;
begin
  if Source is ThiiGridSpacingOptions then
  begin
    LSource := ThiiGridSpacingOptions(Source);
    FLeft := LSource.FLeft;
    FTop := LSource.FTop;
    FRight := LSource.FRight;
    FBottom := LSource.FBottom;
    FRowSpacing := LSource.FRowSpacing;
    FDefaultColumnRightSpacing := LSource.FDefaultColumnRightSpacing;
    if Assigned(FAppearance) then
    begin
      FAppearance.RowSpacingColor := LSource.RowSpacingColor;
      FAppearance.ColumnSpacingColor := LSource.ColumnSpacingColor;
      FAppearance.ContentPaddingColor := LSource.ContentPaddingColor;
    end
    else
    begin
      FRowSpacingColor := LSource.RowSpacingColor;
      FColumnSpacingColor := LSource.ColumnSpacingColor;
      FContentPaddingColor := LSource.ContentPaddingColor;
    end;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiGridSpacingOptions.BindAppearance(AValue: ThiiGridAppearanceOptions);
begin
  if FAppearance = AValue then
    Exit;
  if Assigned(FAppearance) then
  begin
    FRowSpacingColor := FAppearance.RowSpacingColor;
    FColumnSpacingColor := FAppearance.ColumnSpacingColor;
    FContentPaddingColor := FAppearance.ContentPaddingColor;
  end;
  FAppearance := AValue;
  if not Assigned(FAppearance) then
    Exit;

  if FAppearance.RowSpacingColor = TColorRec.Lightgray then
    FAppearance.RowSpacingColor := FRowSpacingColor;
  if FAppearance.ColumnSpacingColor = TColorRec.Lightgray then
    FAppearance.ColumnSpacingColor := FColumnSpacingColor;
  if FAppearance.ContentPaddingColor = TColorRec.Lightgray then
    FAppearance.ContentPaddingColor := FContentPaddingColor;
end;

procedure ThiiGridSpacingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiGridSpacingOptions.Create;
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

procedure ThiiGridSpacingOptions.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('RowSpacingColor', {$IFDEF FPC}@{$ENDIF}ReadRowSpacingColor,
    {$IFDEF FPC}@{$ENDIF}WriteRowSpacingColor,
    not Assigned(FAppearance) and (FRowSpacingColor <> TColorRec.Lightgray));
  AFiler.DefineProperty('ColumnSpacingColor', {$IFDEF FPC}@{$ENDIF}ReadColumnSpacingColor,
    {$IFDEF FPC}@{$ENDIF}WriteColumnSpacingColor,
    not Assigned(FAppearance) and (FColumnSpacingColor <> TColorRec.Lightgray));
  AFiler.DefineProperty('ContentPaddingColor', {$IFDEF FPC}@{$ENDIF}ReadContentPaddingColor,
    {$IFDEF FPC}@{$ENDIF}WriteContentPaddingColor,
    not Assigned(FAppearance) and (FContentPaddingColor <> TColorRec.Lightgray));
end;

function ThiiGridSpacingOptions.GetColumnSpacingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.ColumnSpacingColor
  else
    Result := FColumnSpacingColor;
end;

function ThiiGridSpacingOptions.GetContentPaddingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.ContentPaddingColor
  else
    Result := FContentPaddingColor;
end;

function ThiiGridSpacingOptions.GetRowSpacingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.RowSpacingColor
  else
    Result := FRowSpacingColor;
end;

procedure ThiiGridSpacingOptions.ReadColumnSpacingColor(AReader: TReader);
begin
  SetColumnSpacingColor(h5uReadSpacingColor(AReader));
end;

procedure ThiiGridSpacingOptions.ReadContentPaddingColor(AReader: TReader);
begin
  SetContentPaddingColor(h5uReadSpacingColor(AReader));
end;

procedure ThiiGridSpacingOptions.ReadRowSpacingColor(AReader: TReader);
begin
  SetRowSpacingColor(h5uReadSpacingColor(AReader));
end;

procedure ThiiGridSpacingOptions.SetBottom(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FBottom = AValue then
    Exit;
  FBottom := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure ThiiGridSpacingOptions.SetColumnSpacingColor(const AValue: TColor);
begin
  if Assigned(FAppearance) then
  begin
    FAppearance.ColumnSpacingColor := AValue;
    Exit;
  end;
  if FColumnSpacingColor = AValue then
    Exit;
  FColumnSpacingColor := AValue;
  Changed;
end;

procedure ThiiGridSpacingOptions.SetContentPaddingColor(const AValue: TColor);
begin
  if Assigned(FAppearance) then
  begin
    FAppearance.ContentPaddingColor := AValue;
    Exit;
  end;
  if FContentPaddingColor = AValue then
    Exit;
  FContentPaddingColor := AValue;
  Changed;
end;

procedure ThiiGridSpacingOptions.SetDefaultColumnRightSpacing(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FDefaultColumnRightSpacing = AValue then
    Exit;
  FDefaultColumnRightSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure ThiiGridSpacingOptions.SetLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FLeft = AValue then
    Exit;
  FLeft := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure ThiiGridSpacingOptions.SetAllSeparators(const ASize: Single);
var
  LSize: Single;
begin
  if IsNan(ASize) or IsInfinite(ASize) then
    Exit;
  LSize := EnsureRange(ASize, 0, 1000);
  if (FLeft = LSize) and (FTop = LSize) and (FRight = LSize) and (FBottom = LSize) and (FRowSpacing = LSize)
    and (FDefaultColumnRightSpacing = LSize) then
    Exit;

  FLeft := LSize;
  FTop := LSize;
  FRight := LSize;
  FBottom := LSize;
  FRowSpacing := LSize;
  FDefaultColumnRightSpacing := LSize;
  Changed;
end;

procedure ThiiGridSpacingOptions.SetRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FRight = AValue then
    Exit;
  FRight := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure ThiiGridSpacingOptions.SetRowSpacing(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FRowSpacing = AValue then
    Exit;
  FRowSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure ThiiGridSpacingOptions.SetRowSpacingColor(const AValue: TColor);
begin
  if Assigned(FAppearance) then
  begin
    FAppearance.RowSpacingColor := AValue;
    Exit;
  end;
  if FRowSpacingColor = AValue then
    Exit;
  FRowSpacingColor := AValue;
  Changed;
end;

procedure ThiiGridSpacingOptions.SetTop(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FTop = AValue then
    Exit;
  FTop := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure ThiiGridSpacingOptions.WriteColumnSpacingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FColumnSpacingColor);
end;

procedure ThiiGridSpacingOptions.WriteContentPaddingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FContentPaddingColor);
end;

procedure ThiiGridSpacingOptions.WriteRowSpacingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FRowSpacingColor);
end;

{ ThiiTreeBranchEndBandOptions }

procedure ThiiTreeBranchEndBandOptions.Assign(Source: TPersistent);
var
  LSource: ThiiTreeBranchEndBandOptions;
begin
  if Source is ThiiTreeBranchEndBandOptions then
  begin
    LSource := ThiiTreeBranchEndBandOptions(Source);
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

procedure ThiiTreeBranchEndBandOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiTreeBranchEndBandOptions.Create;
begin
  inherited;
  FEnabled := False;
  FHeight := 6;
  FColor := TColorRec.SysDefault;
  FStyleName := '';
  FIncludeEndOfData := True;
end;

procedure ThiiTreeBranchEndBandOptions.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure ThiiTreeBranchEndBandOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure ThiiTreeBranchEndBandOptions.SetHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FHeight = AValue then
    Exit;
  FHeight := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure ThiiTreeBranchEndBandOptions.SetIncludeEndOfData(const AValue: Boolean);
begin
  if FIncludeEndOfData = AValue then
    Exit;
  FIncludeEndOfData := AValue;
  Changed;
end;

procedure ThiiTreeBranchEndBandOptions.SetStyleName(const AValue: string);
begin
  if FStyleName = AValue then
    Exit;
  FStyleName := AValue;
  Changed;
end;

{ ThiiTreeOptions }

procedure ThiiTreeOptions.Assign(Source: TPersistent);
var
  LSource: ThiiTreeOptions;
begin
  if Source is ThiiTreeOptions then
  begin
    LSource := ThiiTreeOptions(Source);
    FEnabled := LSource.FEnabled;
    FLevelColumnId := LSource.FLevelColumnId;
    FBranchEndBand.Assign(LSource.FBranchEndBand);
    Changed;
  end
  else
    inherited;
end;

procedure ThiiTreeOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiTreeOptions.ChildChanged(Sender: TObject);
begin
  Changed;
end;

constructor ThiiTreeOptions.Create;
begin
  inherited;
  FEnabled := False;
  FBranchEndBand := ThiiTreeBranchEndBandOptions.Create;
  FBranchEndBand.OnChanged := {$IFDEF FPC}@{$ENDIF}ChildChanged;
end;

destructor ThiiTreeOptions.Destroy;
begin
  FBranchEndBand.Free;
  inherited;
end;

procedure ThiiTreeOptions.SetBranchEndBand(const AValue: ThiiTreeBranchEndBandOptions);
begin
  if Assigned(AValue) then
    FBranchEndBand.Assign(AValue);
end;

procedure ThiiTreeOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure ThiiTreeOptions.SetLevelColumnId(const AValue: string);
begin
  if FLevelColumnId = AValue then
    Exit;
  FLevelColumnId := AValue;
  Changed;
end;

{ ThiiAdjacentGroupEndBandOptions }

procedure ThiiAdjacentGroupEndBandOptions.Assign(Source: TPersistent);
var
  LSource: ThiiAdjacentGroupEndBandOptions;
begin
  if Source is ThiiAdjacentGroupEndBandOptions then
  begin
    LSource := ThiiAdjacentGroupEndBandOptions(Source);
    FVisibility := LSource.FVisibility;
    FHeight := LSource.FHeight;
    FColor := LSource.FColor;
    FStyleName := LSource.FStyleName;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiAdjacentGroupEndBandOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiAdjacentGroupEndBandOptions.Create;
begin
  inherited;
  FVisibility := ThiiAdjacentGroupEndBandVisibility.Never;
  FHeight := 6;
  FColor := TColorRec.SysDefault;
  FStyleName := '';
end;

procedure ThiiAdjacentGroupEndBandOptions.SetColor(const AValue: TColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupEndBandOptions.SetHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FHeight = AValue then
    Exit;
  FHeight := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure ThiiAdjacentGroupEndBandOptions.SetStyleName(const AValue: string);
begin
  if FStyleName = AValue then
    Exit;
  FStyleName := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupEndBandOptions.SetVisibility(const AValue: ThiiAdjacentGroupEndBandVisibility);
begin
  if FVisibility = AValue then
    Exit;
  FVisibility := AValue;
  Changed;
end;

{ ThiiAdjacentGroupFoldingOptions }

procedure ThiiAdjacentGroupFoldingOptions.Assign(Source: TPersistent);
var
  LSource: ThiiAdjacentGroupFoldingOptions;
begin
  if Source is ThiiAdjacentGroupFoldingOptions then
  begin
    LSource := ThiiAdjacentGroupFoldingOptions(Source);
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

procedure ThiiAdjacentGroupFoldingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiAdjacentGroupFoldingOptions.ChildChanged(Sender: TObject);
begin
  Changed;
end;

constructor ThiiAdjacentGroupFoldingOptions.Create;
begin
  inherited;
  FEnabled := False;
  FInitialState := ThiiAdjacentGroupInitialState.Expanded;
  FShowFoldGlyph := True;
  FCaseSensitive := True;
  FGroupEmptyValues := True;
  FPreserveStateOnDataChange := True;
  FEndBand := ThiiAdjacentGroupEndBandOptions.Create;
  FEndBand.OnChanged := {$IFDEF FPC}@{$ENDIF}ChildChanged;
end;

destructor ThiiAdjacentGroupFoldingOptions.Destroy;
begin
  FEndBand.Free;
  inherited;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetCaseSensitive(const AValue: Boolean);
begin
  if FCaseSensitive = AValue then
    Exit;
  FCaseSensitive := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetEndBand(const AValue: ThiiAdjacentGroupEndBandOptions);
begin
  if Assigned(AValue) then
    FEndBand.Assign(AValue);
end;

procedure ThiiAdjacentGroupFoldingOptions.SetGroupEmptyValues(const AValue: Boolean);
begin
  if FGroupEmptyValues = AValue then
    Exit;
  FGroupEmptyValues := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetIdColumnId(const AValue: string);
begin
  if FIdColumnId = AValue then
    Exit;
  FIdColumnId := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetInitialState(const AValue: ThiiAdjacentGroupInitialState);
begin
  if FInitialState = AValue then
    Exit;
  FInitialState := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetPreserveStateOnDataChange(const AValue: Boolean);
begin
  if FPreserveStateOnDataChange = AValue then
    Exit;
  FPreserveStateOnDataChange := AValue;
  Changed;
end;

procedure ThiiAdjacentGroupFoldingOptions.SetShowFoldGlyph(const AValue: Boolean);
begin
  if FShowFoldGlyph = AValue then
    Exit;
  FShowFoldGlyph := AValue;
  Changed;
end;

{ ThiiRowHeightOptions }

procedure ThiiRowHeightOptions.Assign(Source: TPersistent);
var
  LSource: ThiiRowHeightOptions;
begin
  if Source is ThiiRowHeightOptions then
  begin
    LSource := ThiiRowHeightOptions(Source);
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

procedure ThiiRowHeightOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiRowHeightOptions.Create;
begin
  inherited;
  FMode := ThiiRowHeightMode.Fixed;
  FFixedHeight := 24;
  FMinHeight := 20;
  FMaxHeight := 180;
  FEstimatedHeight := 24;
  FMeasureScope := ThiiAutoHeightMeasureScope.ExplicitContributorColumns;
end;

procedure ThiiRowHeightOptions.SetEstimatedHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FEstimatedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure ThiiRowHeightOptions.SetFixedHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FFixedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure ThiiRowHeightOptions.SetMaxHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FMaxHeight := EnsureRange(AValue, FMinHeight, 4000);
  Changed;
end;

procedure ThiiRowHeightOptions.SetMinHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FMinHeight := EnsureRange(AValue, 8, FMaxHeight);
  Changed;
end;

procedure ThiiRowHeightOptions.SetMode(const AValue: ThiiRowHeightMode);
begin
  if FMode = AValue then
    Exit;
  FMode := AValue;
  Changed;
end;

{ ThiiScrollingOptions }

procedure ThiiScrollingOptions.Assign(Source: TPersistent);
var
  LSource: ThiiScrollingOptions;
begin
  if Source is ThiiScrollingOptions then
  begin
    LSource := ThiiScrollingOptions(Source);
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

procedure ThiiScrollingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiScrollingOptions.Create;
begin
  inherited;
  FVerticalMode := ThiiVerticalScrollMode.Pixel;
  FHorizontalMode := ThiiHorizontalScrollMode.Pixel;
  FOverscanRows := 2;
  FSnapDelay := 120;
  FWheelRows := 3;
end;

{ ThiiScrollHintOptions }

procedure ThiiScrollHintOptions.Assign(Source: TPersistent);
var
  LSource: ThiiScrollHintOptions;
begin
  if Source is ThiiScrollHintOptions then
  begin
    LSource := ThiiScrollHintOptions(Source);
    FEnabled := LSource.FEnabled;
    FTriggers := LSource.FTriggers;
    FVerticalColumnId := LSource.FVerticalColumnId;
    FShowRowPosition := LSource.FShowRowPosition;
    FUseHeaderPath := LSource.FUseHeaderPath;
  end
  else
    inherited;
end;

constructor ThiiScrollHintOptions.Create;
begin
  inherited;
  FEnabled := True;
  FTriggers := cDefaultTriggers;
  FShowRowPosition := True;
  FUseHeaderPath := True;
end;

{ ThiiPaginationOptions }

procedure ThiiPaginationOptions.Assign(Source: TPersistent);
var
  LSource: ThiiPaginationOptions;
begin
  if Source is ThiiPaginationOptions then
  begin
    LSource := ThiiPaginationOptions(Source);
    FMode := LSource.FMode;
    FPageSize := LSource.FPageSize;
    FPageIndex := LSource.FPageIndex;
    Changed;
  end
  else
    inherited;
end;

procedure ThiiPaginationOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiPaginationOptions.Create;
begin
  inherited;
  FMode := ThiiPaginationMode.Continuous;
  FPageSize := 100;
  FPageIndex := 0;
end;

procedure ThiiPaginationOptions.SetPageIndex(const AValue: Integer);
begin
  FPageIndex := Max(0, AValue);
  Changed;
end;

procedure ThiiPaginationOptions.SetPageSize(const AValue: Integer);
begin
  FPageSize := EnsureRange(AValue, 1, 1000000);
  Changed;
end;

{ ThiiCacheOptions }

procedure ThiiCacheOptions.Assign(Source: TPersistent);
var
  LSource: ThiiCacheOptions;
begin
  if Source is ThiiCacheOptions then
  begin
    LSource := ThiiCacheOptions(Source);
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

procedure ThiiCacheOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor ThiiCacheOptions.Create;
begin
  inherited;
  FMode := ThiiCacheMode.Viewport;
  FPageSize := 200;
  FMaxCachedPages := 8;
  FPrefetchPagesBefore := 1;
  FPrefetchPagesAfter := 2;
  FMaxMemoryBytes := 64 * 1024 * 1024;
end;

{ ThiiRowStyleOptions }

procedure ThiiRowStyleOptions.Assign(Source: TPersistent);
var
  LSource: ThiiRowStyleOptions;
begin
  if Source is ThiiRowStyleOptions then
  begin
    LSource := ThiiRowStyleOptions(Source);
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

constructor ThiiRowStyleOptions.Create;
begin
  inherited;
  FStripePeriod := 2;
  FStripeOffset := 1;
  FStripeStyleName := 'Stripe';
  FOddStyleName := 'Odd';
  FEvenStyleName := 'Even';
  FRestartAtGroup := False;
  FRestartAtPage := False;
  FMappings := ThiiRowStyleMappings.Create(Self);
end;

destructor ThiiRowStyleOptions.Destroy;
begin
  FMappings.Free;
  inherited;
end;

function ThiiRowStyleOptions.ResolveStyle(AViewRowIndex: Int64; AStyleKey: Integer; AHasStyleKey: Boolean): string;
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

procedure ThiiRowStyleOptions.SetMappings(const AValue: ThiiRowStyleMappings);
begin
  FMappings.Assign(AValue);
end;

{ ThiiCustomizationOptions }

procedure ThiiCustomizationOptions.Assign(Source: TPersistent);
var
  LSource: ThiiCustomizationOptions;
begin
  if Source is ThiiCustomizationOptions then
  begin
    LSource := ThiiCustomizationOptions(Source);
    FAllowColumnMoving := LSource.FAllowColumnMoving;
    FColumnMovingGesture := LSource.FColumnMovingGesture;
    FAllowRowMoving := LSource.FAllowRowMoving;
    FRowMovingGesture := LSource.FRowMovingGesture;
    FAllowColumnHiding := LSource.FAllowColumnHiding;
    FAllowColumnResizing := LSource.FAllowColumnResizing;
    FShowColumnChooser := LSource.FShowColumnChooser;
    FLastColumnResizeHitZoneLeft := LSource.FLastColumnResizeHitZoneLeft;
    FTouchLastColumnResizeHitZoneLeft := LSource.FTouchLastColumnResizeHitZoneLeft;
    FColumnResizeHitZoneLeft := LSource.FColumnResizeHitZoneLeft;
    FColumnResizeHitZoneRight := LSource.FColumnResizeHitZoneRight;
    FTouchColumnResizeHitZoneLeft := LSource.FTouchColumnResizeHitZoneLeft;
    FTouchColumnResizeHitZoneRight := LSource.FTouchColumnResizeHitZoneRight;
  end
  else
    inherited;
end;

constructor ThiiCustomizationOptions.Create;
begin
  inherited;
  FAllowColumnMoving := True;
  FColumnMovingGesture := ThiiColumnRowMovingGesture.Drag;
  FAllowRowMoving := True;
  FRowMovingGesture := ThiiColumnRowMovingGesture.Drag;
  FAllowColumnHiding := True;
  FAllowColumnResizing := True;
  FShowColumnChooser := True;
  FLastColumnResizeHitZoneLeft := -1;
  FTouchLastColumnResizeHitZoneLeft := -1;
  FColumnResizeHitZoneLeft := 4;
  FColumnResizeHitZoneRight := 4;
  FTouchColumnResizeHitZoneLeft := 12;
  FTouchColumnResizeHitZoneRight := 12;
end;

procedure ThiiCustomizationOptions.SetColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FColumnResizeHitZoneLeft := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure ThiiCustomizationOptions.SetColumnResizeHitZoneRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FColumnResizeHitZoneRight := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure ThiiCustomizationOptions.SetTouchColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchColumnResizeHitZoneLeft := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure ThiiCustomizationOptions.SetTouchColumnResizeHitZoneRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchColumnResizeHitZoneRight := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure ThiiCustomizationOptions.SetLastColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FLastColumnResizeHitZoneLeft := EnsureRange(AValue, -1, h5uUnlimitedWidth);
end;

procedure ThiiCustomizationOptions.SetTouchLastColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchLastColumnResizeHitZoneLeft := EnsureRange(AValue, -1, h5uUnlimitedWidth);
end;

end.

