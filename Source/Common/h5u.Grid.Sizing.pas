unit h5u.Grid.Sizing;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

{$SCOPEDENUMS ON}

uses
  {$IFDEF FPC}
    Classes,
    Math,
    SysUtils;
  {$ELSE}
    System.Classes,
    System.Math,
    System.SysUtils;
  {$ENDIF}

type
  ThiiWidth = type Single;
  ThiiColumnFitMode = (None, PercentColumns, AllColumns);
  ThiiMaxWidthSource = (Default, Monitor);

  ThiiColumnSizingOptions = class(TPersistent)
  private
    FDefaultWidth: ThiiWidth;
    FDefaultMinWidth: Single;
    FDefaultMaxWidth: ThiiWidth;
    FMaxWidthSource: ThiiMaxWidthSource;
    FAutoWidthRowLimit: Integer;
    FMinContentWidth: Single;
    FMaxContentWidth: Single;
    FFitMode: ThiiColumnFitMode;
    FOnChanged: TNotifyEvent;
    procedure Changed;
    procedure SetDefaultWidth(AValue: ThiiWidth);
    procedure SetDefaultMinWidth(AValue: Single);
    procedure SetDefaultMaxWidth(AValue: ThiiWidth);
    procedure SetMaxWidthSource(AValue: ThiiMaxWidthSource);
    procedure SetAutoWidthRowLimit(AValue: Integer);
    procedure SetMinContentWidth(AValue: Single);
    procedure SetMaxContentWidth(AValue: Single);
    procedure SetFitMode(AValue: ThiiColumnFitMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property DefaultWidth: ThiiWidth read FDefaultWidth write SetDefaultWidth;
    property DefaultMinWidth: Single read FDefaultMinWidth write SetDefaultMinWidth;
    property DefaultMaxWidth: ThiiWidth read FDefaultMaxWidth write SetDefaultMaxWidth;
    property MaxWidthSource: ThiiMaxWidthSource read FMaxWidthSource write SetMaxWidthSource default ThiiMaxWidthSource.Default;
    property AutoWidthRowLimit: Integer read FAutoWidthRowLimit write SetAutoWidthRowLimit default 1000;
    property MinContentWidth: Single read FMinContentWidth write SetMinContentWidth;
    property MaxContentWidth: Single read FMaxContentWidth write SetMaxContentWidth;
    property FitMode: ThiiColumnFitMode read FFitMode write SetFitMode default ThiiColumnFitMode.PercentColumns;
  end;

const
  h5uUnlimitedWidth: Single = 536870912;

procedure h5uValidateWidth(AValue: Single);
function h5uResolveWidth(AValue, AReferenceWidth: Single): Single;
function h5uWidthToText(AValue: ThiiWidth): string;
function h5uTryTextToWidth(const AText: string; out AValue: ThiiWidth): Boolean;

implementation

procedure h5uValidateWidth(AValue: Single);
begin
  if IsNan(AValue) or IsInfinite(AValue) or (Abs(AValue) > h5uUnlimitedWidth) then
    raise EArgumentOutOfRangeException.Create('Width must be finite and within the supported range.');
end;

function h5uResolveWidth(AValue, AReferenceWidth: Single): Single;
begin
  if AValue < 0 then
    Result := Min(h5uUnlimitedWidth, (-AValue / 100) * Max(0.0, AReferenceWidth))
  else
    Result := Min(h5uUnlimitedWidth, AValue);
end;

function h5uWidthToText(AValue: ThiiWidth): string;
begin
  if AValue = 0 then
    Result := 'Default'
  else if AValue = h5uUnlimitedWidth then
    Result := 'Unlimited'
  else if AValue < 0 then
    Result := FloatToStr(-AValue) + ' %'
  else
    Result := FloatToStr(AValue);
end;

function h5uTryTextToWidth(const AText: string; out AValue: ThiiWidth): Boolean;
var
  LText: string;
  LValue: Double;
  LPercent: Boolean;
begin
  AValue := 0;
  LText := Trim(AText);
  if SameText(LText, 'Default') then
    Exit(True);
  if SameText(LText, 'Unlimited') then
  begin
    AValue := h5uUnlimitedWidth;
    Exit(True);
  end;
  LPercent := (LText <> '') and (LText[Length(LText)] = '%');
  if LPercent then
    LText := Trim(Copy(LText, 1, Length(LText) - 1))
  else if SameText(Copy(LText, Length(LText) - 1, 2), 'px') then
    LText := Trim(Copy(LText, 1, Length(LText) - 2));
  Result := TryStrToFloat(LText, LValue);
  if not Result then
    Exit;
  Result := not IsNan(LValue) and not IsInfinite(LValue) and (Abs(LValue) <= h5uUnlimitedWidth);
  if Result then
  begin
    if LPercent then
      LValue := -Abs(LValue);
    AValue := LValue;
  end;
end;

constructor ThiiColumnSizingOptions.Create;
begin
  inherited;
  FAutoWidthRowLimit := 1000;
  FFitMode := ThiiColumnFitMode.PercentColumns;
end;

procedure ThiiColumnSizingOptions.Assign(Source: TPersistent);
var
  LSource: ThiiColumnSizingOptions;
begin
  if not (Source is ThiiColumnSizingOptions) then
  begin
    inherited;
    Exit;
  end;
  LSource := ThiiColumnSizingOptions(Source);
  FDefaultWidth := LSource.FDefaultWidth;
  FDefaultMinWidth := LSource.FDefaultMinWidth;
  FDefaultMaxWidth := LSource.FDefaultMaxWidth;
  FMaxWidthSource := LSource.FMaxWidthSource;
  FAutoWidthRowLimit := LSource.FAutoWidthRowLimit;
  FMinContentWidth := LSource.FMinContentWidth;
  FMaxContentWidth := LSource.FMaxContentWidth;
  FFitMode := LSource.FFitMode;
  Changed;
end;

procedure ThiiColumnSizingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure ThiiColumnSizingOptions.SetDefaultWidth(AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultWidth = AValue then
    Exit;
  FDefaultWidth := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetDefaultMinWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FDefaultMinWidth = AValue then
    Exit;
  FDefaultMinWidth := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetDefaultMaxWidth(AValue: ThiiWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultMaxWidth = AValue then
    Exit;
  FDefaultMaxWidth := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetMaxWidthSource(AValue: ThiiMaxWidthSource);
begin
  if FMaxWidthSource = AValue then
    Exit;
  FMaxWidthSource := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetAutoWidthRowLimit(AValue: Integer);
begin
  AValue := Max(0, AValue);
  if FAutoWidthRowLimit = AValue then
    Exit;
  FAutoWidthRowLimit := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetMinContentWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMinContentWidth = AValue then
    Exit;
  FMinContentWidth := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetMaxContentWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMaxContentWidth = AValue then
    Exit;
  FMaxContentWidth := AValue;
  Changed;
end;

procedure ThiiColumnSizingOptions.SetFitMode(AValue: ThiiColumnFitMode);
begin
  if FFitMode = AValue then
    Exit;
  FFitMode := AValue;
  Changed;
end;

end.
