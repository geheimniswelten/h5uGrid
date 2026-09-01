unit h5u.Grid.Options;

interface

{$SCOPEDENUMS ON}

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  h5u.Grid.Columns,
  h5u.Grid.Types;

type
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
      read FOnChanged write FOnChanged;
  published
    property Mode: Th5uRowHeightMode
      read FMode write SetMode default Th5uRowHeightMode.Fixed;
    property FixedHeight: Integer
      read FFixedHeight write SetFixedHeight default 24;
    property MinHeight: Integer
      read FMinHeight write SetMinHeight default 20;
    property MaxHeight: Integer
      read FMaxHeight write SetMaxHeight default 180;
    property EstimatedHeight: Integer
      read FEstimatedHeight write SetEstimatedHeight default 24;
    property MeasureScope: Th5uAutoHeightMeasureScope
      read FMeasureScope write FMeasureScope
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
      read FOnChanged write FOnChanged;
  published
    property VerticalMode: Th5uVerticalScrollMode
      read FVerticalMode write FVerticalMode
      default Th5uVerticalScrollMode.Pixel;
    property HorizontalMode: Th5uHorizontalScrollMode
      read FHorizontalMode write FHorizontalMode
      default Th5uHorizontalScrollMode.Pixel;
    property OverscanRows: Integer
      read FOverscanRows write FOverscanRows default 2;
    property SnapDelay: Integer
      read FSnapDelay write FSnapDelay default 120;
    property WheelRows: Integer
      read FWheelRows write FWheelRows default 3;
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
      read FOnChanged write FOnChanged;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property Triggers: Th5uScrollHintTriggers
      read FTriggers write FTriggers;
    property VerticalColumnId: string
      read FVerticalColumnId write FVerticalColumnId;
    property ShowRowPosition: Boolean
      read FShowRowPosition write FShowRowPosition default True;
    property UseHeaderPath: Boolean
      read FUseHeaderPath write FUseHeaderPath default True;
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
      read FOnChanged write FOnChanged;
  published
    property Mode: Th5uPaginationMode
      read FMode write FMode
      default Th5uPaginationMode.Continuous;
    property PageSize: Integer
      read FPageSize write SetPageSize default 100;
    property PageIndex: Integer
      read FPageIndex write SetPageIndex default 0;
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
      read FOnChanged write FOnChanged;
  published
    property Mode: Th5uCacheMode
      read FMode write FMode default Th5uCacheMode.Viewport;
    property PageSize: Integer
      read FPageSize write FPageSize default 200;
    property MaxCachedPages: Integer
      read FMaxCachedPages write FMaxCachedPages default 8;
    property PrefetchPagesBefore: Integer
      read FPrefetchPagesBefore write FPrefetchPagesBefore default 1;
    property PrefetchPagesAfter: Integer
      read FPrefetchPagesAfter write FPrefetchPagesAfter default 2;
    property MaxMemoryBytes: Int64
      read FMaxMemoryBytes write FMaxMemoryBytes;
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
    ): string;
    property OnChanged: Th5uOptionsChangedEvent
      read FOnChanged write FOnChanged;
  published
    property StripePeriod: Integer
      read FStripePeriod write FStripePeriod default 2;
    property StripeOffset: Integer
      read FStripeOffset write FStripeOffset default 1;
    property StripeStyleName: string
      read FStripeStyleName write FStripeStyleName;
    property OddStyleName: string
      read FOddStyleName write FOddStyleName;
    property EvenStyleName: string
      read FEvenStyleName write FEvenStyleName;
    property StyleKeyColumnId: string
      read FStyleKeyColumnId write FStyleKeyColumnId;
    property Mappings: Th5uRowStyleMappings
      read FMappings write SetMappings;
    property RestartAtGroup: Boolean
      read FRestartAtGroup write FRestartAtGroup default False;
    property RestartAtPage: Boolean
      read FRestartAtPage write FRestartAtPage default False;
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
      read FAllowColumnMoving write FAllowColumnMoving default True;
    property AllowColumnHiding: Boolean
      read FAllowColumnHiding write FAllowColumnHiding default True;
    property AllowColumnResizing: Boolean
      read FAllowColumnResizing write FAllowColumnResizing default True;
    property ShowColumnChooser: Boolean
      read FShowColumnChooser write FShowColumnChooser default True;
  end;

implementation

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
    inherited Assign(Source);
end;

procedure Th5uRowHeightOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uRowHeightOptions.Create;
begin
  inherited Create;
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
    inherited Assign(Source);
end;

procedure Th5uScrollingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uScrollingOptions.Create;
begin
  inherited Create;
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
    inherited Assign(Source);
end;

constructor Th5uScrollHintOptions.Create;
begin
  inherited Create;
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
    inherited Assign(Source);
end;

procedure Th5uPaginationOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uPaginationOptions.Create;
begin
  inherited Create;
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
    inherited Assign(Source);
end;

procedure Th5uCacheOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor Th5uCacheOptions.Create;
begin
  inherited Create;
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
    inherited Assign(Source);
end;

constructor Th5uRowStyleOptions.Create;
begin
  inherited Create;
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
  inherited Destroy;
end;

function Th5uRowStyleOptions.ResolveStyle(
  AViewRowIndex: Int64;
  AStyleKey: Integer;
  AHasStyleKey: Boolean): string;
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

procedure Th5uRowStyleOptions.SetMappings(
  const AValue: Th5uRowStyleMappings);
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
    FAllowColumnHiding := LSource.FAllowColumnHiding;
    FAllowColumnResizing := LSource.FAllowColumnResizing;
    FShowColumnChooser := LSource.FShowColumnChooser;
  end
  else
    inherited Assign(Source);
end;

constructor Th5uCustomizationOptions.Create;
begin
  inherited Create;
  FAllowColumnMoving := True;
  FAllowColumnHiding := True;
  FAllowColumnResizing := True;
  FShowColumnChooser := True;
end;

end.
