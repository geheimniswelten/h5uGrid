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

  Th5uGridRowMetrics = class
  private
    FHeights: {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Double>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Remove(const AKey: string);
    function GetHeight(AOptions: Th5uRowHeightOptions; AColumns: Th5uGridColumns; ARow: Int64; const AKey: Th5uRowKey;
      AAllowMeasure: Boolean; AMeasure: Th5uMeasureCellHeight; AAdjust: Th5uAdjustRowHeight): Double;
  end;

function h5uFindFirstVisibleRow(ARowCount, AOffset: Int64; AViewportTop: Integer; AExtent: Th5uGetRowExtent; out ATop: Integer): Int64; overload;
function h5uFindFirstVisibleRow(ARowCount: Int64; AOffset, AViewportTop: Double; AExtent: Th5uGetRowExtent; out ATop: Double): Int64; overload;
function h5uTotalRowHeight(AOptions: Th5uRowHeightOptions; ARowCount: Int64; ASpacing: Integer; AVariableSpacing: Boolean;
  APrepare: Th5uPrepareMetricRange; AExtent: Th5uGetRowExtent): Th5uTotalRowHeight;
function h5uRowTop(ARow: Int64; AExtent: Th5uGetRowExtent): Double;

implementation

constructor Th5uGridRowMetrics.Create;
begin
  inherited;
  FHeights := {$IFDEF FPC}specialize {$ENDIF}TDictionary<string, Double>.Create;
end;

destructor Th5uGridRowMetrics.Destroy;
begin
  FHeights.Free;
  inherited;
end;

procedure Th5uGridRowMetrics.Clear;
begin
  FHeights.Clear;
end;

procedure Th5uGridRowMetrics.Remove(const AKey: string);
begin
  FHeights.Remove(AKey);
end;

function Th5uGridRowMetrics.GetHeight(AOptions: Th5uRowHeightOptions; AColumns: Th5uGridColumns; ARow: Int64; const AKey: Th5uRowKey;
  AAllowMeasure: Boolean; AMeasure: Th5uMeasureCellHeight; AAdjust: Th5uAdjustRowHeight): Double;
var
  LKey: string;
  LColumn: Th5uGridColumn;
  LCache: Boolean;
begin
  if AOptions.Mode = Th5uRowHeightMode.Fixed then
    Exit(AOptions.FixedHeight);
  LKey := AKey.ToString;
  if LKey = '' then
    LKey := '#' + IntToStr(ARow);
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
  if LCache then
    FHeights.AddOrSetValue(LKey, Result);
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

