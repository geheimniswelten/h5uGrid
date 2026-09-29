unit h5u.Grid.RowMetrics;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

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
  h5u.Grid.Types;

const
  h5uExactRowHeightLimit = 5000;

type
  Th5uMeasureCellHeight = function(ARow: Int64; AColumn: Th5uGridColumn): Double of object;
  Th5uAdjustRowHeight = procedure(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Double; var ACacheResult: Boolean) of object;
  Th5uGetRowExtent = function(ARow: Int64; AAllowMeasure: Boolean): Double of object;
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
    FHeights: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Double>;
    FRowsByKey: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Int64>;
    FRoot: Th5uRowExtentNode;
    FRowCount, FEstimatedExtent: Int64;
    FExtentCount: Integer;
    FConfigured, FExact, FExactReady, FPreparing: Boolean;
    FHasUncachedHeights, FDynamicSpacing: Boolean;
    FPrepare: Th5uPrepareMetricRange;
    FExtent: Th5uGetRowExtent;
    FColumnWidths: string;
    procedure EnsureExact;
    function EstimatedTop(ARow: Int64; ADelta: Double): Th5uTotalRowHeight;
    function LocateOffset(const AOffset: Th5uTotalRowHeight;
      out ARowTop: Th5uTotalRowHeight): Int64;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Remove(const AKey: string);
    procedure Configure(AOptions: Th5uRowHeightOptions; ARowCount: Int64;
      ASpacing: Integer; AVariableSpacing: Boolean; APrepare: Th5uPrepareMetricRange;
      AExtent: Th5uGetRowExtent; ADynamicSpacing: Boolean = False);
    procedure RecordExtent(ARow: Int64; AExtent: Double);
    procedure InvalidateExtents;
    procedure InvalidateRow(ARow: Int64);
    function CheckColumnWidths(AColumns: Th5uGridColumns): Boolean;
    function RowTop(ARow: Int64): Th5uTotalRowHeight;
    function Total(AAllowMeasure: Boolean = True): Th5uTotalRowHeight;
    function FindFirstVisibleRow(AOffset: Int64; AViewportTop: Integer;
      out ATop: Integer): Int64; overload;
    function FindFirstVisibleRow(AOffset, AViewportTop: Double;
      out ATop: Double): Int64; overload;
    function GetHeight(AOptions: Th5uRowHeightOptions; AColumns: Th5uGridColumns; ARow: Int64; const AKey: Th5uRowKey;
      AAllowMeasure: Boolean; AMeasure: Th5uMeasureCellHeight; AAdjust: Th5uAdjustRowHeight): Double;
    property ExtentCount: Integer read FExtentCount;
  end;

function h5uFindFirstVisibleRow(ARowCount, AOffset: Int64; AViewportTop: Integer; AExtent: Th5uGetRowExtent; out ATop: Integer): Int64; overload;
function h5uFindFirstVisibleRow(ARowCount: Int64; AOffset, AViewportTop: Double; AExtent: Th5uGetRowExtent; out ATop: Double): Int64; overload;
function h5uTotalRowHeight(AOptions: Th5uRowHeightOptions; ARowCount: Int64; ASpacing: Integer; AVariableSpacing: Boolean;
  APrepare: Th5uPrepareMetricRange; AExtent: Th5uGetRowExtent): Th5uTotalRowHeight;
function h5uRowTop(ARow: Int64; AExtent: Th5uGetRowExtent): Double;

implementation

function NodeHeight(ANode: Th5uRowExtentNode): Integer;
begin
  Result := 0;
  if ANode <> nil then
    Result := ANode.Height;
end;

function NodeSum(ANode: Th5uRowExtentNode): Double;
begin
  Result := 0;
  if ANode <> nil then
    Result := ANode.Sum;
end;

procedure UpdateNode(ANode: Th5uRowExtentNode);
begin
  ANode.Height := Max(NodeHeight(ANode.Left), NodeHeight(ANode.Right)) + 1;
  ANode.Sum := NodeSum(ANode.Left) + ANode.Delta + NodeSum(ANode.Right);
end;

function RotateLeft(ANode: Th5uRowExtentNode): Th5uRowExtentNode;
begin
  Result := ANode.Right;
  ANode.Right := Result.Left;
  Result.Left := ANode;
  UpdateNode(ANode);
  UpdateNode(Result);
end;

function RotateRight(ANode: Th5uRowExtentNode): Th5uRowExtentNode;
begin
  Result := ANode.Left;
  ANode.Left := Result.Right;
  Result.Right := ANode;
  UpdateNode(ANode);
  UpdateNode(Result);
end;

function BalanceNode(ANode: Th5uRowExtentNode): Th5uRowExtentNode;
begin
  Result := ANode;
  if ANode = nil then
    Exit;
  UpdateNode(ANode);
  if NodeHeight(ANode.Left) > NodeHeight(ANode.Right) + 1 then
  begin
    if NodeHeight(ANode.Left.Right) > NodeHeight(ANode.Left.Left) then
      ANode.Left := RotateLeft(ANode.Left);
    Result := RotateRight(ANode);
  end
  else if NodeHeight(ANode.Right) > NodeHeight(ANode.Left) + 1 then
  begin
    if NodeHeight(ANode.Right.Left) > NodeHeight(ANode.Right.Right) then
      ANode.Right := RotateRight(ANode.Right);
    Result := RotateLeft(ANode);
  end;
end;

function PutExtent(ANode: Th5uRowExtentNode; ARow: Int64; ADelta: Double;
  var AAdded: Boolean): Th5uRowExtentNode;
begin
  if ANode = nil then
  begin
    Result := Th5uRowExtentNode.Create;
    Result.Row := ARow;
    Result.Delta := ADelta;
    Result.Sum := ADelta;
    Result.Height := 1;
    AAdded := True;
    Exit;
  end;
  if ARow < ANode.Row then
    ANode.Left := PutExtent(ANode.Left, ARow, ADelta, AAdded)
  else if ARow > ANode.Row then
    ANode.Right := PutExtent(ANode.Right, ARow, ADelta, AAdded)
  else
    ANode.Delta := ADelta;
  Result := BalanceNode(ANode);
end;

function DeleteExtent(ANode: Th5uRowExtentNode; ARow: Int64;
  var ARemoved: Boolean): Th5uRowExtentNode;
var
  Successor: Th5uRowExtentNode;
begin
  if ANode = nil then
    Exit(nil);
  if ARow < ANode.Row then
    ANode.Left := DeleteExtent(ANode.Left, ARow, ARemoved)
  else if ARow > ANode.Row then
    ANode.Right := DeleteExtent(ANode.Right, ARow, ARemoved)
  else
  begin
    ARemoved := True;
    if (ANode.Left = nil) or (ANode.Right = nil) then
    begin
      Result := ANode.Left;
      if Result = nil then
        Result := ANode.Right;
      ANode.Free;
      Exit;
    end;
    Successor := ANode.Right;
    while Successor.Left <> nil do
      Successor := Successor.Left;
    ANode.Row := Successor.Row;
    ANode.Delta := Successor.Delta;
    ANode.Right := DeleteExtent(ANode.Right, Successor.Row, ARemoved);
  end;
  Result := BalanceNode(ANode);
end;

procedure FreeExtents(ANode: Th5uRowExtentNode);
begin
  if ANode = nil then
    Exit;
  FreeExtents(ANode.Left);
  FreeExtents(ANode.Right);
  ANode.Free;
end;

function SumBefore(ANode: Th5uRowExtentNode; ARow: Int64): Double;
begin
  Result := 0;
  while ANode <> nil do
    if ARow <= ANode.Row then
      ANode := ANode.Left
    else
    begin
      Result := Result + NodeSum(ANode.Left) + ANode.Delta;
      ANode := ANode.Right;
    end;
end;

procedure NormalizeHeight(var AValue: Th5uTotalRowHeight);
var
  WholeDelta: Int64;
begin
  WholeDelta := Trunc(AValue.Fraction);
  if (WholeDelta > 0) and (AValue.Whole > High(Int64) - WholeDelta) then
  begin
    AValue.Whole := High(Int64);
    AValue.Fraction := 0;
    Exit;
  end;
  AValue.Whole := AValue.Whole + WholeDelta;
  AValue.Fraction := AValue.Fraction - WholeDelta;
  if AValue.Fraction < 0 then
  begin
    Dec(AValue.Whole);
    AValue.Fraction := AValue.Fraction + 1;
  end;
end;

function CompareHeight(const A, B: Th5uTotalRowHeight): Integer;
begin
  if A.Whole < B.Whole then
    Exit(-1);
  if A.Whole > B.Whole then
    Exit(1);
  if A.Fraction < B.Fraction then
    Exit(-1);
  if A.Fraction > B.Fraction then
    Exit(1);
  Result := 0;
end;

constructor Th5uGridRowMetrics.Create;
begin
  inherited;
  FHeights := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Double>.Create;
  FRowsByKey := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Int64>.Create;
end;

destructor Th5uGridRowMetrics.Destroy;
begin
  FreeExtents(FRoot);
  FRowsByKey.Free;
  FHeights.Free;
  inherited;
end;

procedure Th5uGridRowMetrics.Clear;
begin
  FHeights.Clear;
  InvalidateExtents;
end;

procedure Th5uGridRowMetrics.Remove(const AKey: string);
var
  Row: Int64;
begin
  FHeights.Remove(AKey);
  if FRowsByKey.TryGetValue(AKey, Row) then
  begin
    InvalidateRow(Row);
    FRowsByKey.Remove(AKey);
  end;
end;

procedure Th5uGridRowMetrics.InvalidateExtents;
begin
  FreeExtents(FRoot);
  FRoot := nil;
  FExtentCount := 0;
  FExactReady := False;
  FHasUncachedHeights := False;
  FRowsByKey.Clear;
end;

procedure Th5uGridRowMetrics.InvalidateRow(ARow: Int64);
var
  Removed: Boolean;
begin
  Removed := False;
  FRoot := DeleteExtent(FRoot, ARow, Removed);
  if Removed then
    Dec(FExtentCount);
  FExactReady := False;
end;

procedure Th5uGridRowMetrics.Configure(AOptions: Th5uRowHeightOptions; ARowCount: Int64;
  ASpacing: Integer; AVariableSpacing: Boolean; APrepare: Th5uPrepareMetricRange;
  AExtent: Th5uGetRowExtent; ADynamicSpacing: Boolean);
var
  EstimatedExtent: Int64;
  Exact: Boolean;
begin
  ARowCount := Max(Int64(0), ARowCount);
  if AOptions.Mode = Th5uRowHeightMode.Fixed then
    EstimatedExtent := Int64(AOptions.FixedHeight) + ASpacing
  else
    EstimatedExtent := Int64(AOptions.EstimatedHeight) + ASpacing;
  EstimatedExtent := Max(Int64(1), EstimatedExtent);
  Exact := (ARowCount <= h5uExactRowHeightLimit)
    and ((AOptions.Mode <> Th5uRowHeightMode.Fixed) or AVariableSpacing);
  if not FConfigured or (FRowCount <> ARowCount) or (FEstimatedExtent <> EstimatedExtent)
    or (FExact <> Exact) or (TMethod(FExtent).Code <> TMethod(AExtent).Code)
    or (TMethod(FExtent).Data <> TMethod(AExtent).Data) then
    InvalidateExtents;
  FConfigured := True;
  FRowCount := ARowCount;
  FEstimatedExtent := EstimatedExtent;
  FExact := Exact;
  FPrepare := APrepare;
  FExtent := AExtent;
  FDynamicSpacing := ADynamicSpacing;
end;

procedure Th5uGridRowMetrics.RecordExtent(ARow: Int64; AExtent: Double);
var
  Changed: Boolean;
  Delta: Double;
begin
  if not FConfigured or (ARow < 0) or (ARow >= FRowCount) then
    Exit;
  if IsNan(AExtent) or IsInfinite(AExtent) then
    Exit;
  Delta := Max(1.0, AExtent) - FEstimatedExtent;
  Changed := False;
  if Delta = 0 then
  begin
    FRoot := DeleteExtent(FRoot, ARow, Changed);
    if Changed then
      Dec(FExtentCount);
  end
  else
  begin
    FRoot := PutExtent(FRoot, ARow, Delta, Changed);
    if Changed then
      Inc(FExtentCount);
  end;
end;

function Th5uGridRowMetrics.CheckColumnWidths(AColumns: Th5uGridColumns): Boolean;
var
  Column: Th5uGridColumn;
  Signature: string;
begin
  Signature := '';
  for Column in AColumns.VisibleColumns do
    Signature := Signature + IntToStr(Length(Column.Id)) + ':' + Column.Id
      + ':' + IntToStr(Column.LayoutWidth) + ':' + IntToStr(Ord(Column.AutoHeight)) + ';';
  Result := Signature <> FColumnWidths;
  if Result then
  begin
    FColumnWidths := Signature;
    Clear;
  end;
end;

procedure Th5uGridRowMetrics.EnsureExact;
var
  Row: Int64;
begin
  if not FExact or FPreparing then
    Exit;
  if FExactReady and not FHasUncachedHeights and not FDynamicSpacing then
    Exit;
  if not Assigned(FExtent) then
    Exit;
  FPreparing := True;
  try
    FHasUncachedHeights := False;
    if Assigned(FPrepare) then
      FPrepare(0, FRowCount);
    Row := 0;
    while Row < FRowCount do
    begin
      RecordExtent(Row, FExtent(Row, True));
      Inc(Row);
    end;
    FExactReady := True;
  finally
    FPreparing := False;
  end;
end;

function Th5uGridRowMetrics.EstimatedTop(ARow: Int64; ADelta: Double): Th5uTotalRowHeight;
begin
  Result := Default(Th5uTotalRowHeight);
  if (FEstimatedExtent > 0) and (ARow > High(Int64) div FEstimatedExtent) then
  begin
    Result.Whole := High(Int64);
    Exit;
  end;
  Result.Whole := ARow * FEstimatedExtent;
  Result.Fraction := ADelta;
  NormalizeHeight(Result);
end;

function Th5uGridRowMetrics.RowTop(ARow: Int64): Th5uTotalRowHeight;
begin
  EnsureExact;
  ARow := Max(Int64(0), Min(ARow, FRowCount));
  Result := EstimatedTop(ARow, SumBefore(FRoot, ARow));
end;

function Th5uGridRowMetrics.Total(AAllowMeasure: Boolean): Th5uTotalRowHeight;
begin
  if AAllowMeasure then
    EnsureExact;
  Result := EstimatedTop(FRowCount, NodeSum(FRoot));
end;

function Th5uGridRowMetrics.LocateOffset(const AOffset: Th5uTotalRowHeight;
  out ARowTop: Th5uTotalRowHeight): Int64;
var
  Node: Th5uRowExtentNode;
  DeltaBefore: Double;
  LowerRow, UpperRow: Int64;
  Start, Finish, Remaining: Th5uTotalRowHeight;
begin
  Result := -1;
  ARowTop := Default(Th5uTotalRowHeight);
  EnsureExact;
  if (FRowCount = 0) or (CompareHeight(AOffset, Total(False)) >= 0) then
    Exit;
  Node := FRoot;
  DeltaBefore := 0;
  LowerRow := 0;
  UpperRow := FRowCount;
  while Node <> nil do
  begin
    Start := EstimatedTop(Node.Row, DeltaBefore + NodeSum(Node.Left));
    if CompareHeight(AOffset, Start) < 0 then
    begin
      UpperRow := Node.Row;
      Node := Node.Left;
    end
    else
    begin
      Finish := Start;
      Finish.Fraction := Finish.Fraction + FEstimatedExtent + Node.Delta;
      NormalizeHeight(Finish);
      if CompareHeight(AOffset, Finish) < 0 then
      begin
        ARowTop := Start;
        Exit(Node.Row);
      end;
      DeltaBefore := DeltaBefore + NodeSum(Node.Left) + Node.Delta;
      LowerRow := Node.Row + 1;
      Node := Node.Right;
    end;
  end;
  Start := EstimatedTop(LowerRow, DeltaBefore);
  Remaining.Whole := AOffset.Whole - Start.Whole;
  Remaining.Fraction := AOffset.Fraction - Start.Fraction;
  NormalizeHeight(Remaining);
  Result := LowerRow + Remaining.Whole div FEstimatedExtent;
  Result := Max(LowerRow, Min(Result, UpperRow - 1));
  ARowTop := EstimatedTop(Result, DeltaBefore);
end;

function Th5uGridRowMetrics.FindFirstVisibleRow(AOffset: Int64; AViewportTop: Integer;
  out ATop: Integer): Int64;
var
  Offset, Top: Th5uTotalRowHeight;
begin
  Offset := Default(Th5uTotalRowHeight);
  Offset.Whole := Max(Int64(0), AOffset);
  Result := LocateOffset(Offset, Top);
  ATop := AViewportTop;
  if Result >= 0 then
    ATop := AViewportTop - Round((Offset.Whole - Top.Whole) - Top.Fraction);
end;

function Th5uGridRowMetrics.FindFirstVisibleRow(AOffset, AViewportTop: Double;
  out ATop: Double): Int64;
var
  Offset, Top: Th5uTotalRowHeight;
begin
  Offset := Default(Th5uTotalRowHeight);
  AOffset := Max(0.0, AOffset);
  if IsNan(AOffset) then
    AOffset := 0;
  if AOffset >= High(Int64) then
    Offset.Whole := High(Int64)
  else
  begin
    Offset.Whole := Trunc(AOffset);
    Offset.Fraction := AOffset - Offset.Whole;
  end;
  Result := LocateOffset(Offset, Top);
  ATop := AViewportTop;
  if Result >= 0 then
    ATop := AViewportTop - ((Offset.Whole - Top.Whole) + Offset.Fraction - Top.Fraction);
end;

function Th5uGridRowMetrics.GetHeight(AOptions: Th5uRowHeightOptions; AColumns: Th5uGridColumns; ARow: Int64; const AKey: Th5uRowKey;
  AAllowMeasure: Boolean; AMeasure: Th5uMeasureCellHeight; AAdjust: Th5uAdjustRowHeight): Double;
var
  LKey: string;
  LColumn: Th5uGridColumn;
  LCache: Boolean;
begin
  LKey := AKey.ToString;
  if LKey = '' then
    LKey := '#' + IntToStr(ARow);
  if AAllowMeasure then
    FRowsByKey.AddOrSetValue(LKey, ARow);
  if AOptions.Mode = Th5uRowHeightMode.Fixed then
    Exit(AOptions.FixedHeight);
  if FHeights.TryGetValue(LKey, Result) then
    Exit;
  if not AAllowMeasure then
    Result := AOptions.EstimatedHeight
  else
  begin
    Result := AOptions.MinHeight;
    for LColumn in AColumns.VisibleColumns do
      if (AOptions.MeasureScope <> Th5uAutoHeightMeasureScope.ExplicitContributorColumns) or LColumn.AutoHeight then
        Result := Max(Result, AMeasure(ARow, LColumn));
  end;
  Result := EnsureRange(Result, Double(AOptions.MinHeight), Double(AOptions.MaxHeight));
  LCache := True;
  if Assigned(AAdjust) then
    AAdjust(ARow, AKey, not AAllowMeasure, Result, LCache);
  Result := Max(1.0, Result);
  if LCache and AAllowMeasure then
    FHeights.AddOrSetValue(LKey, Result)
  else if AAllowMeasure then
    FHasUncachedHeights := True;
end;

function Th5uTotalRowHeight.AsFloat: Double;
begin
  Result := Whole + Fraction;
end;

function h5uFindFirstVisibleRow(ARowCount, AOffset: Int64; AViewportTop: Integer; AExtent: Th5uGetRowExtent; out ATop: Integer): Int64;
var
  LRow, LRemaining, LExtent: Int64;
begin
  Result := -1;
  ATop := AViewportTop;
  LRemaining := Max(Int64(0), AOffset);
  {$IFDEF FPC_old}
  LRow := 0;
  while LRow < ARowCount do
  {$ELSE}
  for LRow := 0 to ARowCount - 1 do
  {$ENDIF}
  begin
    LExtent := Round(AExtent(LRow, ARowCount <= h5uExactRowHeightLimit));
    if LRemaining < LExtent then
    begin
      ATop := AViewportTop - Integer(LRemaining);
      Exit(LRow);
    end;
    Dec(LRemaining, LExtent);
    {$IFDEF FPC_old}
    Inc(LRow);
    {$ENDIF}
  end;
end;

function h5uFindFirstVisibleRow(ARowCount: Int64; AOffset, AViewportTop: Double; AExtent: Th5uGetRowExtent; out ATop: Double): Int64;
var
  LRow: Int64;
  LRemaining, LExtent: Double;
begin
  Result := -1;
  ATop := AViewportTop;
  LRemaining := Max(0.0, AOffset);
  {$IFDEF FPC_old}
  LRow := 0;
  while LRow < ARowCount do
  {$ELSE}
  for LRow := 0 to ARowCount - 1 do
  {$ENDIF}
  begin
    LExtent := AExtent(LRow, ARowCount <= h5uExactRowHeightLimit);
    if LRemaining < LExtent then
    begin
      ATop := AViewportTop - LRemaining;
      Exit(LRow);
    end;
    LRemaining := LRemaining - LExtent;
    {$IFDEF FPC_old}
    Inc(LRow);
    {$ENDIF}
  end;
end;

function h5uTotalRowHeight(AOptions: Th5uRowHeightOptions; ARowCount: Int64; ASpacing: Integer; AVariableSpacing: Boolean;
  APrepare: Th5uPrepareMetricRange; AExtent: Th5uGetRowExtent): Th5uTotalRowHeight;
var
  LRow: Int64;
  LTotal: Double;
begin
  Result := Default(Th5uTotalRowHeight);
  if (AOptions.Mode = Th5uRowHeightMode.Fixed) and not AVariableSpacing then
    Result.Whole := ARowCount * (AOptions.FixedHeight + ASpacing)
  else
  if ARowCount <= h5uExactRowHeightLimit then
  begin
    APrepare(0, ARowCount);
    LTotal := 0;
    {$IFDEF FPC_old}
      LRow := 0;
      while LRow < ARowCount do
      begin
        Inc(LTotal, AExtent(LRow, True));
        Inc(LRow);
      end;
    {$ELSE}
      for LRow := 0 to ARowCount - 1 do
        LTotal := LTotal + AExtent(LRow, True);
    {$ENDIF}
    Result.Whole := Trunc(LTotal);
    Result.Fraction := LTotal - Result.Whole;
  end
  else
    Result.Whole := ARowCount * (AOptions.EstimatedHeight + ASpacing);
end;

function h5uRowTop(ARow: Int64; AExtent: Th5uGetRowExtent): Double;
var
  I: Int64;
begin
  Result := 0;
  {$IFDEF FPC_old}
    I := 0;
    while I < ARow do
    begin
      Result := Result + AExtent(I, True);
      Inc(I);
    end;
  {$ELSE}
    for I := 0 to ARow - 1 do
      Result := Result + AExtent(I, True);
  {$ENDIF}
end;

end.

