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
  Th5uOptionsChangedEvent = procedure(Sender: TObject) of object;

  Th5uGridHeaderOptions = class(TPersistent)
  private
    FOwner: TPersistent;
    FVisible: Boolean;
    FRowHeight: Single;
    FLayout: Th5uHeaderLayout;
    FAssigning: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure LayoutChanged(Sender: TObject);
    procedure SetLayout(const AValue: Th5uHeaderLayout);
    procedure SetRowHeight(const AValue: Single);
    procedure SetVisible(const AValue: Boolean);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visible: Boolean read FVisible write SetVisible default True;
    property RowHeight: Single read FRowHeight write SetRowHeight nodefault;
    property Layout: Th5uHeaderLayout read FLayout write SetLayout;
  end;

  Th5uRowIndicatorOptions = class(TPersistent)
  private
    FVisible: Boolean;
    FWidth: Single;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetVisible(const AValue: Boolean);
    procedure SetWidth(const AValue: Single);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Single read FWidth write SetWidth nodefault;
  end;

  Th5uEditingOptions = class(TPersistent)
  private
    FAllowEditing: Boolean;
    FImmediateEdit: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetAllowEditing(const AValue: Boolean);
    procedure SetImmediateEdit(const AValue: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property AllowEditing: Boolean read FAllowEditing write SetAllowEditing default True;
    property ImmediateEdit: Boolean read FImmediateEdit write SetImmediateEdit default False;
  end;

  Th5uGridAppearanceOptions = class(TPersistent)
  private
    FTheme: Th5uGridTheme;
    FDefaultCellColor: TColor;
    FRowSpacingColor: TColor;
    FColumnSpacingColor: TColor;
    FContentPaddingColor: TColor;
    FOnChanged: Th5uOptionsChangedEvent;
    FOnThemeChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetColumnSpacingColor(const AValue: TColor);
    procedure SetContentPaddingColor(const AValue: TColor);
    procedure SetDefaultCellColor(const AValue: TColor);
    procedure SetRowSpacingColor(const AValue: TColor);
    procedure SetTheme(const AValue: Th5uGridTheme);
    procedure ThemeChanged;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
    property OnThemeChanged: Th5uOptionsChangedEvent read FOnThemeChanged write FOnThemeChanged;
  published
    property Theme: Th5uGridTheme read FTheme write SetTheme default Th5uGridTheme.ApplicationStyle;
    property DefaultCellColor: TColor read FDefaultCellColor write SetDefaultCellColor default TColorRec.SysDefault;
    property RowSpacingColor: TColor read FRowSpacingColor write SetRowSpacingColor default TColorRec.Lightgray;
    property ColumnSpacingColor: TColor read FColumnSpacingColor write SetColumnSpacingColor default TColorRec.Lightgray;
    property ContentPaddingColor: TColor read FContentPaddingColor write SetContentPaddingColor default TColorRec.Lightgray;
  end;

  // Spacing is layout geometry. A value of 1 produces the default one-pixel separator.
  // 0 disables the corresponding separator completely.
  Th5uGridSpacingOptions = class(TPersistent)
  private
    FLeft: Single;
    FTop: Single;
    FRight: Single;
    FBottom: Single;
    FRowSpacing: Single;
    FDefaultColumnRightSpacing: Single;
    FAppearance: Th5uGridAppearanceOptions;
    FRowSpacingColor: TColor;
    FColumnSpacingColor: TColor;
    FContentPaddingColor: TColor;
    FOnChanged: Th5uOptionsChangedEvent;
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
    procedure BindAppearance(AValue: Th5uGridAppearanceOptions);
    procedure SetAllSeparators(const ASize: Single);
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
    // Source and streaming compatibility; bound grids store colors in Appearance.
    {$IFNDEF FPC}
    [Th5uLegacyOption]
    {$ENDIF}
    property RowSpacingColor: TColor read GetRowSpacingColor write SetRowSpacingColor;
    {$IFNDEF FPC}
    [Th5uLegacyOption]
    {$ENDIF}
    property ColumnSpacingColor: TColor read GetColumnSpacingColor write SetColumnSpacingColor;
    {$IFNDEF FPC}
    [Th5uLegacyOption]
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
  Th5uTreeBranchEndBandOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FHeight: Single;
    FColor: TColor;
    FStyleName: string;
    FIncludeEndOfData: Boolean;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetHeight(const AValue: Single);
    procedure SetIncludeEndOfData(const AValue: Boolean);
    procedure SetStyleName(const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property Height: Single read FHeight write SetHeight nodefault;
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
  // the normal RowSpacing at that boundary. it is never added to it.
  Th5uAdjacentGroupEndBandOptions = class(TPersistent)
  private
    FVisibility: Th5uAdjacentGroupEndBandVisibility;
    FHeight: Single;
    FColor: TColor;
    FStyleName: string;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetColor(const AValue: TColor);
    procedure SetHeight(const AValue: Single);
    procedure SetStyleName(const AValue: string);
    procedure SetVisibility(const AValue: Th5uAdjacentGroupEndBandVisibility);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Visibility: Th5uAdjacentGroupEndBandVisibility read FVisibility write SetVisibility default Th5uAdjacentGroupEndBandVisibility.Never;
    property Height: Single read FHeight write SetHeight nodefault;
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
    FFixedHeight: Single;
    FMinHeight: Single;
    FMaxHeight: Single;
    FEstimatedHeight: Single;
    FMeasureScope: Th5uAutoHeightMeasureScope;
    FOnChanged: Th5uOptionsChangedEvent;
    procedure Changed;
    procedure SetEstimatedHeight(const AValue: Single);
    procedure SetFixedHeight(const AValue: Single);
    procedure SetMaxHeight(const AValue: Single);
    procedure SetMinHeight(const AValue: Single);
    procedure SetMode(const AValue: Th5uRowHeightMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: Th5uOptionsChangedEvent read FOnChanged write FOnChanged;
  published
    property Mode: Th5uRowHeightMode read FMode write SetMode default Th5uRowHeightMode.Fixed;
    property FixedHeight: Single read FFixedHeight write SetFixedHeight nodefault;
    property MinHeight: Single read FMinHeight write SetMinHeight nodefault;
    property MaxHeight: Single read FMaxHeight write SetMaxHeight nodefault;
    property EstimatedHeight: Single read FEstimatedHeight write SetEstimatedHeight nodefault;
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
  private const
    cDefaultTriggers = [Th5uScrollHintTrigger.ThumbTracking {.$IFnDEF MOBILE}, Th5uScrollHintTrigger.MouseWheel{.$ENDIF}];
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
    property Triggers: Th5uScrollHintTriggers read FTriggers write FTriggers default cDefaultTriggers;
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
    {$IFnDEF FPC} [Default('Stripe')] {$ENDIF}
    property StripeStyleName: string read FStripeStyleName write FStripeStyleName;
    {$IFnDEF FPC} [Default('Odd')] {$ENDIF}
    property OddStyleName: string read FOddStyleName write FOddStyleName;
    {$IFnDEF FPC} [Default('Even')] {$ENDIF}
    property EvenStyleName: string read FEvenStyleName write FEvenStyleName;
    property StyleKeyColumnId: string read FStyleKeyColumnId write FStyleKeyColumnId;
    property Mappings: Th5uRowStyleMappings read FMappings write SetMappings;
    property RestartAtGroup: Boolean read FRestartAtGroup write FRestartAtGroup default False;
    property RestartAtPage: Boolean read FRestartAtPage write FRestartAtPage default False;
  end;

  Th5uCustomizationOptions = class(TPersistent)
  private
    FAllowColumnMoving: Boolean;
    FColumnMovingGesture: Th5uColumnRowMovingGesture;
    FAllowRowMoving: Boolean;
    FRowMovingGesture: Th5uColumnRowMovingGesture;
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
    property RowMovingGesture: Th5uColumnRowMovingGesture read FRowMovingGesture write FRowMovingGesture default Th5uColumnRowMovingGesture.Drag;
    property ColumnMovingGesture: Th5uColumnRowMovingGesture read FColumnMovingGesture write FColumnMovingGesture default Th5uColumnRowMovingGesture.Drag;
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

{ Th5uGridHeaderOptions }

procedure Th5uGridHeaderOptions.Assign(Source: TPersistent);
var
  LSource: Th5uGridHeaderOptions;
begin
  if Source = Self then
    Exit;
  if Source is Th5uGridHeaderOptions then
  begin
    LSource := Th5uGridHeaderOptions(Source);
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

procedure Th5uGridHeaderOptions.Changed;
begin
  if not FAssigning and Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uGridHeaderOptions.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FVisible := True;
  FRowHeight := 26;
  FLayout := Th5uHeaderLayout.Create(Self);
  FLayout.OnChanged := {$IFDEF FPC}@{$ENDIF}LayoutChanged;
end;

destructor Th5uGridHeaderOptions.Destroy;
begin
  FLayout.Free;
  inherited;
end;

function Th5uGridHeaderOptions.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure Th5uGridHeaderOptions.LayoutChanged(Sender: TObject);
begin
  Changed;
end;

procedure Th5uGridHeaderOptions.SetLayout(const AValue: Th5uHeaderLayout);
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

procedure Th5uGridHeaderOptions.SetRowHeight(const AValue: Single);
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

procedure Th5uGridHeaderOptions.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

{ Th5uRowIndicatorOptions }

procedure Th5uRowIndicatorOptions.Assign(Source: TPersistent);
var
  LSource: Th5uRowIndicatorOptions;
begin
  if Source is Th5uRowIndicatorOptions then
  begin
    LSource := Th5uRowIndicatorOptions(Source);
    FVisible := LSource.FVisible;
    FWidth := LSource.FWidth;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uRowIndicatorOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uRowIndicatorOptions.Create;
begin
  inherited Create;
  FVisible := True;
  FWidth := 34;
end;

procedure Th5uRowIndicatorOptions.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure Th5uRowIndicatorOptions.SetWidth(const AValue: Single);
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

{ Th5uEditingOptions }

procedure Th5uEditingOptions.Assign(Source: TPersistent);
var
  LSource: Th5uEditingOptions;
begin
  if Source is Th5uEditingOptions then
  begin
    LSource := Th5uEditingOptions(Source);
    FAllowEditing := LSource.FAllowEditing;
    FImmediateEdit := LSource.FImmediateEdit;
    Changed;
  end
  else
    inherited;
end;

procedure Th5uEditingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uEditingOptions.Create;
begin
  inherited Create;
  FAllowEditing := True;
  FImmediateEdit := False;
end;

procedure Th5uEditingOptions.SetAllowEditing(const AValue: Boolean);
begin
  if FAllowEditing = AValue then
    Exit;
  FAllowEditing := AValue;
  Changed;
end;

procedure Th5uEditingOptions.SetImmediateEdit(const AValue: Boolean);
begin
  if FImmediateEdit = AValue then
    Exit;
  FImmediateEdit := AValue;
  Changed;
end;

{ Th5uGridAppearanceOptions }

procedure Th5uGridAppearanceOptions.Assign(Source: TPersistent);
var
  LSource: Th5uGridAppearanceOptions;
  LThemeChanged: Boolean;
begin
  if Source is Th5uGridAppearanceOptions then
  begin
    LSource := Th5uGridAppearanceOptions(Source);
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

procedure Th5uGridAppearanceOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uGridAppearanceOptions.Create;
begin
  inherited Create;
  FTheme := Th5uGridTheme.ApplicationStyle;
  FDefaultCellColor := TColorRec.SysDefault;
  FRowSpacingColor := TColorRec.Lightgray;
  FColumnSpacingColor := TColorRec.Lightgray;
  FContentPaddingColor := TColorRec.Lightgray;
end;

procedure Th5uGridAppearanceOptions.SetColumnSpacingColor(const AValue: TColor);
begin
  if FColumnSpacingColor = AValue then
    Exit;
  FColumnSpacingColor := AValue;
  Changed;
end;

procedure Th5uGridAppearanceOptions.SetContentPaddingColor(const AValue: TColor);
begin
  if FContentPaddingColor = AValue then
    Exit;
  FContentPaddingColor := AValue;
  Changed;
end;

procedure Th5uGridAppearanceOptions.SetDefaultCellColor(const AValue: TColor);
begin
  if FDefaultCellColor = AValue then
    Exit;
  FDefaultCellColor := AValue;
  Changed;
end;

procedure Th5uGridAppearanceOptions.SetRowSpacingColor(const AValue: TColor);
begin
  if FRowSpacingColor = AValue then
    Exit;
  FRowSpacingColor := AValue;
  Changed;
end;

procedure Th5uGridAppearanceOptions.SetTheme(const AValue: Th5uGridTheme);
begin
  if FTheme = AValue then
    Exit;
  FTheme := AValue;
  ThemeChanged;
  Changed;
end;

procedure Th5uGridAppearanceOptions.ThemeChanged;
begin
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self);
end;

{ Th5uGridSpacingOptions }

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

procedure Th5uGridSpacingOptions.BindAppearance(AValue: Th5uGridAppearanceOptions);
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

procedure Th5uGridSpacingOptions.DefineProperties(AFiler: TFiler);
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

function Th5uGridSpacingOptions.GetColumnSpacingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.ColumnSpacingColor
  else
    Result := FColumnSpacingColor;
end;

function Th5uGridSpacingOptions.GetContentPaddingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.ContentPaddingColor
  else
    Result := FContentPaddingColor;
end;

function Th5uGridSpacingOptions.GetRowSpacingColor: TColor;
begin
  if Assigned(FAppearance) then
    Result := FAppearance.RowSpacingColor
  else
    Result := FRowSpacingColor;
end;

procedure Th5uGridSpacingOptions.ReadColumnSpacingColor(AReader: TReader);
begin
  SetColumnSpacingColor(h5uReadSpacingColor(AReader));
end;

procedure Th5uGridSpacingOptions.ReadContentPaddingColor(AReader: TReader);
begin
  SetContentPaddingColor(h5uReadSpacingColor(AReader));
end;

procedure Th5uGridSpacingOptions.ReadRowSpacingColor(AReader: TReader);
begin
  SetRowSpacingColor(h5uReadSpacingColor(AReader));
end;

procedure Th5uGridSpacingOptions.SetBottom(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FBottom = AValue then
    Exit;
  FBottom := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetColumnSpacingColor(const AValue: TColor);
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

procedure Th5uGridSpacingOptions.SetContentPaddingColor(const AValue: TColor);
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

procedure Th5uGridSpacingOptions.SetDefaultColumnRightSpacing(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FDefaultColumnRightSpacing = AValue then
    Exit;
  FDefaultColumnRightSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FLeft = AValue then
    Exit;
  FLeft := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetAllSeparators(const ASize: Single);
var
  LSize: Single;
begin
  if IsNan(ASize) or IsInfinite(ASize) then
    Exit;
  LSize := EnsureRange(ASize, 0, 1000);
  if (FLeft = LSize) and (FTop = LSize) and (FRight = LSize) and (FBottom = LSize) and (FRowSpacing = LSize) and (FDefaultColumnRightSpacing = LSize) then
    Exit;

  FLeft := LSize;
  FTop := LSize;
  FRight := LSize;
  FBottom := LSize;
  FRowSpacing := LSize;
  FDefaultColumnRightSpacing := LSize;
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FRight = AValue then
    Exit;
  FRight := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRowSpacing(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FRowSpacing = AValue then
    Exit;
  FRowSpacing := EnsureRange(AValue, 0, 1000);
  Changed;
end;

procedure Th5uGridSpacingOptions.SetRowSpacingColor(const AValue: TColor);
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

procedure Th5uGridSpacingOptions.SetTop(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  if FTop = AValue then
    Exit;
  FTop := EnsureRange(AValue, 0, 10000);
  Changed;
end;

procedure Th5uGridSpacingOptions.WriteColumnSpacingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FColumnSpacingColor);
end;

procedure Th5uGridSpacingOptions.WriteContentPaddingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FContentPaddingColor);
end;

procedure Th5uGridSpacingOptions.WriteRowSpacingColor(AWriter: TWriter);
begin
  AWriter.WriteInteger(FRowSpacingColor);
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

procedure Th5uTreeBranchEndBandOptions.SetHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
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
  FBranchEndBand.OnChanged := {$IFDEF FPC}@{$ENDIF}ChildChanged;
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

procedure Th5uAdjacentGroupEndBandOptions.SetHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
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
  FEndBand.OnChanged := {$IFDEF FPC}@{$ENDIF}ChildChanged;
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

procedure Th5uRowHeightOptions.SetEstimatedHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FEstimatedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetFixedHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FFixedHeight := EnsureRange(AValue, 8, 1000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetMaxHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FMaxHeight := EnsureRange(AValue, FMinHeight, 4000);
  Changed;
end;

procedure Th5uRowHeightOptions.SetMinHeight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
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
  FTriggers := cDefaultTriggers;
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

constructor Th5uCustomizationOptions.Create;
begin
  inherited;
  FAllowColumnMoving := True;
  FColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;
  FAllowRowMoving := True;
  FRowMovingGesture := Th5uColumnRowMovingGesture.Drag;
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

procedure Th5uCustomizationOptions.SetColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FColumnResizeHitZoneLeft := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure Th5uCustomizationOptions.SetColumnResizeHitZoneRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FColumnResizeHitZoneRight := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure Th5uCustomizationOptions.SetTouchColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchColumnResizeHitZoneLeft := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure Th5uCustomizationOptions.SetTouchColumnResizeHitZoneRight(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchColumnResizeHitZoneRight := EnsureRange(AValue, 0, h5uUnlimitedWidth);
end;

procedure Th5uCustomizationOptions.SetLastColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FLastColumnResizeHitZoneLeft := EnsureRange(AValue, -1, h5uUnlimitedWidth);
end;

procedure Th5uCustomizationOptions.SetTouchLastColumnResizeHitZoneLeft(const AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) then
    Exit;
  FTouchLastColumnResizeHitZoneLeft := EnsureRange(AValue, -1, h5uUnlimitedWidth);
end;

end.

