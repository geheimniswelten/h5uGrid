unit h5u.Grid.Columns;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.Math,
  System.SysUtils,
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
    FColor: Th5uColor;
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
    procedure SetColor(const AValue: Th5uColor);
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
    property Color: Th5uColor read FColor write SetColor default h5uColorDefault;
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

implementation

function CompareVisibleColumns(const ALeft, ARight: Th5uGridColumn): Integer;
begin
  if ALeft.FixedKind <> ARight.FixedKind then
  begin
    if ALeft.FixedKind = Th5uFixedKind.Left then
      Exit(-1);
    if ARight.FixedKind = Th5uFixedKind.Left then
      Exit(1);
    if ALeft.FixedKind = Th5uFixedKind.Right then
      Exit(1);
    if ARight.FixedKind = Th5uFixedKind.Right then
      Exit(-1);
  end;

  Result := ALeft.VisibleIndex - ARight.VisibleIndex;
  if Result = 0 then
    Result := ALeft.Index - ARight.Index;
end;

{ Th5uGridColumn }

procedure Th5uGridColumn.Assign(Source: TPersistent);
var
  LSource: Th5uGridColumn;
begin
  if Source is Th5uGridColumn then
  begin
    LSource := Th5uGridColumn(Source);
    FId := LSource.FId;
    FCaption := LSource.FCaption;
    FFieldName := LSource.FFieldName;
    FWidth := LSource.FWidth;
    FMinWidth := LSource.FMinWidth;
    FMaxWidth := LSource.FMaxWidth;
    FVisible := LSource.FVisible;
    FVisibleIndex := LSource.FVisibleIndex;
    FFixedKind := LSource.FFixedKind;
    FReadOnly := LSource.FReadOnly;
    FDataType := LSource.FDataType;
    FEditorKind := LSource.FEditorKind;
    FWordWrap := LSource.FWordWrap;
    FAutoHeight := LSource.FAutoHeight;
    FMaxAutoHeight := LSource.FMaxAutoHeight;
    FMaxLines := LSource.FMaxLines;
    FScrollHintText := LSource.FScrollHintText;
    FDisplayFormat := LSource.FDisplayFormat;
    FStyleName := LSource.FStyleName;
    FHeaderStyleName := LSource.FHeaderStyleName;
    FHighlighted := LSource.FHighlighted;
    FRightSpacing := LSource.FRightSpacing;
    FColor := LSource.FColor;
    FClassId := LSource.FClassId;
    FCellClassId := LSource.FCellClassId;
    FHeaderCellClassId := LSource.FHeaderCellClassId;
    FCanMove := LSource.FCanMove;
    FCanHide := LSource.FCanHide;
    FCanResize := LSource.FCanResize;
    FCanSelect := LSource.FCanSelect;
    FShowInColumnChooser := LSource.FShowInColumnChooser;
    FImagePreserveAspectRatio := LSource.FImagePreserveAspectRatio;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure Th5uGridColumn.Changed;
begin
  inherited Changed(False);
end;

constructor Th5uGridColumn.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FId := '';
  FCaption := '';
  FFieldName := '';
  FWidth := 100;
  FMinWidth := 24;
  FMaxWidth := 1000;
  FVisible := True;
  FVisibleIndex := -1;
  FFixedKind := Th5uFixedKind.None;
  FReadOnly := False;
  FDataType := Th5uColumnDataType.Auto;
  FEditorKind := Th5uColumnEditorKind.Automatic;
  FWordWrap := False;
  FAutoHeight := False;
  FMaxAutoHeight := 160;
  FMaxLines := 0;
  FRightSpacing := -1;
  FColor := h5uColorDefault;
  FClassId := 'h5u.grid.column.default';
  FCellClassId := h5uClassIdGridDataCell;
  FHeaderCellClassId := h5uClassIdGridHeaderCell;
  FCanMove := True;
  FCanHide := True;
  FCanResize := True;
  FCanSelect := True;
  FShowInColumnChooser := True;
  FImagePreserveAspectRatio := True;
end;

function Th5uGridColumn.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else if FId <> '' then
    Result := FId
  else if FFieldName <> '' then
    Result := FFieldName
  else
    Result := inherited GetDisplayName;
end;

procedure Th5uGridColumn.SetColor(const AValue: Th5uColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetCaption(const AValue: string);
begin
  if FCaption = AValue then
    Exit;
  FCaption := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then
    Exit;
  FFieldName := AValue;
  if FId = '' then
    FId := AValue;
  if FCaption = '' then
    FCaption := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetFixedKind(const AValue: Th5uFixedKind);
begin
  if FFixedKind = AValue then
    Exit;
  FFixedKind := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetId(const AValue: string);
begin
  if FId = AValue then
    Exit;
  FId := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetRightSpacing(const AValue: Integer);
begin
  if FRightSpacing = AValue then
    Exit;
  if AValue < -1 then
    FRightSpacing := -1
  else
    FRightSpacing := EnsureRange(AValue, -1, 1000);
  Changed;
end;

procedure Th5uGridColumn.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetVisibleIndex(const AValue: Integer);
begin
  if FVisibleIndex = AValue then
    Exit;
  FVisibleIndex := AValue;
  Changed;
end;

procedure Th5uGridColumn.SetWidth(const AValue: Integer);
begin
  if FWidth = AValue then
    Exit;
  FWidth := EnsureRange(AValue, FMinWidth, FMaxWidth);
  Changed;
end;

{ Th5uGridColumns }

function Th5uGridColumns.Add: Th5uGridColumn;
begin
  Result := Th5uGridColumn(inherited Add);
  if Result.VisibleIndex < 0 then
    Result.VisibleIndex := Count - 1;
end;

constructor Th5uGridColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uGridColumn);
end;

function Th5uGridColumns.FindByFieldName(const AFieldName: string): Th5uGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].FieldName, AFieldName) then
      Exit(Items[I]);
end;

function Th5uGridColumns.FindById(const AId: string): Th5uGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].Id, AId) then
      Exit(Items[I]);
end;

function Th5uGridColumns.GetItem(AIndex: Integer): Th5uGridColumn;
begin
  Result := Th5uGridColumn(inherited GetItem(AIndex));
end;

procedure Th5uGridColumns.MoveColumn(AColumn: Th5uGridColumn; ANewVisibleIndex: Integer);
var
  LColumns: TArray<Th5uGridColumn>;
  LList: TList<Th5uGridColumn>;
  LColumn: Th5uGridColumn;
  I: Integer;
begin
  if not Assigned(AColumn) or not AColumn.CanMove then
    Exit;

  LColumns := VisibleColumns;
  LList := TList<Th5uGridColumn>.Create;
  try
    for LColumn in LColumns do
      LList.Add(LColumn);

    LList.Remove(AColumn);
    ANewVisibleIndex := EnsureRange(
      ANewVisibleIndex,
      0,
      LList.Count
    );
    LList.Insert(ANewVisibleIndex, AColumn);

    for I := 0 to LList.Count - 1 do
      LList[I].FVisibleIndex := I;

    Changed;
  finally
    LList.Free;
  end;
end;

procedure Th5uGridColumns.NormalizeVisibleIndexes;
var
  LColumns: TArray<Th5uGridColumn>;
  I: Integer;
begin
  LColumns := VisibleColumns;
  for I := 0 to High(LColumns) do
    LColumns[I].FVisibleIndex := I;
  Changed;
end;

procedure Th5uGridColumns.SetItem(AIndex: Integer; const AValue: Th5uGridColumn);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure Th5uGridColumns.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChanged) then
    FOnChanged(Self, Th5uGridColumn(Item));
end;

function Th5uGridColumns.VisibleColumns: TArray<Th5uGridColumn>;
var
  LList: TList<Th5uGridColumn>;
  I: Integer;
begin
  LList := TList<Th5uGridColumn>.Create;
  try
    for I := 0 to Count - 1 do
      if Items[I].Visible then
        LList.Add(Items[I]);

    LList.Sort(TComparer<Th5uGridColumn>.Construct(CompareVisibleColumns));
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

{ Th5uHeaderLayoutCell }

constructor Th5uHeaderLayoutCell.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FRowSpan := 1;
  FColumnSpan := 1;
  FClassId := h5uClassIdGridHeaderGroupCell;
end;

function Th5uHeaderLayoutCell.GetDisplayName: string;
begin
  if FCaption <> '' then
    Result := FCaption
  else if FId <> '' then
    Result := FId
  else
    Result := inherited GetDisplayName;
end;

{ Th5uHeaderLayoutCells }

function Th5uHeaderLayoutCells.Add: Th5uHeaderLayoutCell;
begin
  Result := Th5uHeaderLayoutCell(inherited Add);
end;

constructor Th5uHeaderLayoutCells.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uHeaderLayoutCell);
end;

function Th5uHeaderLayoutCells.GetItem(AIndex: Integer): Th5uHeaderLayoutCell;
begin
  Result := Th5uHeaderLayoutCell(inherited GetItem(AIndex));
end;

{ Th5uHeaderLayout }

procedure Th5uHeaderLayout.Assign(Source: TPersistent);
begin
  if Source is Th5uHeaderLayout then
  begin
    FEnabled := Th5uHeaderLayout(Source).FEnabled;
    FRowCount := Th5uHeaderLayout(Source).FRowCount;
    FCells.Assign(Th5uHeaderLayout(Source).FCells);
  end
  else
    inherited Assign(Source);
end;

constructor Th5uHeaderLayout.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FEnabled := False;
  FRowCount := 1;
  FCells := Th5uHeaderLayoutCells.Create(Self);
end;

destructor Th5uHeaderLayout.Destroy;
begin
  FCells.Free;
  inherited Destroy;
end;

procedure Th5uHeaderLayout.SetCells(const AValue: Th5uHeaderLayoutCells);
begin
  FCells.Assign(AValue);
end;

procedure Th5uHeaderLayout.SetRowCount(const AValue: Integer);
begin
  FRowCount := EnsureRange(AValue, 1, 16);
end;

{ Th5uRowStyleMapping }

function Th5uRowStyleMapping.GetDisplayName: string;
begin
  if FStyleName <> '' then
    Result := Format('%d = %s', [FValue, FStyleName])
  else
    Result := IntToStr(FValue);
end;

{ Th5uRowStyleMappings }

function Th5uRowStyleMappings.Add: Th5uRowStyleMapping;
begin
  Result := Th5uRowStyleMapping(inherited Add);
end;

constructor Th5uRowStyleMappings.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, Th5uRowStyleMapping);
end;

function Th5uRowStyleMappings.FindStyle(AValue: Integer; out AStyleName: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Items[I].Value = AValue then
    begin
      AStyleName := Items[I].StyleName;
      Exit(True);
    end;

  AStyleName := '';
  Result := False;
end;

function Th5uRowStyleMappings.GetItem(AIndex: Integer): Th5uRowStyleMapping;
begin
  Result := Th5uRowStyleMapping(inherited GetItem(AIndex));
end;


function Th5uGridColumn.GetColumns: Th5uGridColumns;
begin
  Result := Th5uGridColumns(Collection);
end;

end.
