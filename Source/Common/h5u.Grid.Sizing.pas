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
  Th5uWidth = type Single;
  Th5uColumnFitMode = (None, PercentColumns, AllColumns);
  Th5uMaxWidthSource = (Default, Monitor);

  Th5uColumnSizingOptions = class(TPersistent)
  private
    FDefaultWidth: Th5uWidth;
    FDefaultMinWidth: Single;
    FDefaultMaxWidth: Th5uWidth;
    FMaxWidthSource: Th5uMaxWidthSource;
    FAutoWidthRowLimit: Integer;
    FMinContentWidth: Single;
    FMaxContentWidth: Single;
    FFitMode: Th5uColumnFitMode;
    FOnChanged: TNotifyEvent;
    procedure Changed;
    procedure SetDefaultWidth(AValue: Th5uWidth);
    procedure SetDefaultMinWidth(AValue: Single);
    procedure SetDefaultMaxWidth(AValue: Th5uWidth);
    procedure SetMaxWidthSource(AValue: Th5uMaxWidthSource);
    procedure SetAutoWidthRowLimit(AValue: Integer);
    procedure SetMinContentWidth(AValue: Single);
    procedure SetMaxContentWidth(AValue: Single);
    procedure SetFitMode(AValue: Th5uColumnFitMode);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property DefaultWidth: Th5uWidth read FDefaultWidth write SetDefaultWidth;
    property DefaultMinWidth: Single read FDefaultMinWidth write SetDefaultMinWidth;
    property DefaultMaxWidth: Th5uWidth read FDefaultMaxWidth write SetDefaultMaxWidth;
    property MaxWidthSource: Th5uMaxWidthSource read FMaxWidthSource write SetMaxWidthSource default Th5uMaxWidthSource.Default;
    property AutoWidthRowLimit: Integer read FAutoWidthRowLimit write SetAutoWidthRowLimit default 1000;
    property MinContentWidth: Single read FMinContentWidth write SetMinContentWidth;
    property MaxContentWidth: Single read FMaxContentWidth write SetMaxContentWidth;
    property FitMode: Th5uColumnFitMode read FFitMode write SetFitMode default Th5uColumnFitMode.PercentColumns;
  end;

const
  h5uUnlimitedWidth: Single = 536870912;

procedure h5uValidateWidth(AValue: Single);
function h5uResolveWidth(AValue, AReferenceWidth: Single): Single;
function h5uWidthToText(AValue: Th5uWidth): string;
function h5uTryTextToWidth(const AText: string; out AValue: Th5uWidth): Boolean;

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

function h5uWidthToText(AValue: Th5uWidth): string;
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

function h5uTryTextToWidth(const AText: string; out AValue: Th5uWidth): Boolean;
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
  Result := not IsNan(LValue) and not IsInfinite(LValue)
    and (Abs(LValue) <= h5uUnlimitedWidth);
  if Result then
  begin
    if LPercent then
      LValue := -Abs(LValue);
    AValue := LValue;
  end;
end;

constructor Th5uColumnSizingOptions.Create;
begin
  inherited;
  FAutoWidthRowLimit := 1000;
  FFitMode := Th5uColumnFitMode.PercentColumns;
end;

procedure Th5uColumnSizingOptions.Assign(Source: TPersistent);
var
  LSource: Th5uColumnSizingOptions;
begin
  if not (Source is Th5uColumnSizingOptions) then
  begin
    inherited;
    Exit;
  end;
  LSource := Th5uColumnSizingOptions(Source);
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

procedure Th5uColumnSizingOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure Th5uColumnSizingOptions.SetDefaultWidth(AValue: Th5uWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultWidth = AValue then
    Exit;
  FDefaultWidth := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetDefaultMinWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FDefaultMinWidth = AValue then
    Exit;
  FDefaultMinWidth := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetDefaultMaxWidth(AValue: Th5uWidth);
begin
  h5uValidateWidth(AValue);
  if FDefaultMaxWidth = AValue then
    Exit;
  FDefaultMaxWidth := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetMaxWidthSource(AValue: Th5uMaxWidthSource);
begin
  if FMaxWidthSource = AValue then
    Exit;
  FMaxWidthSource := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetAutoWidthRowLimit(AValue: Integer);
begin
  AValue := Max(0, AValue);
  if FAutoWidthRowLimit = AValue then
    Exit;
  FAutoWidthRowLimit := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetMinContentWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMinContentWidth = AValue then
    Exit;
  FMinContentWidth := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetMaxContentWidth(AValue: Single);
begin
  h5uValidateWidth(AValue);
  AValue := EnsureRange(AValue, 0, h5uUnlimitedWidth);
  if FMaxContentWidth = AValue then
    Exit;
  FMaxContentWidth := AValue;
  Changed;
end;

procedure Th5uColumnSizingOptions.SetFitMode(AValue: Th5uColumnFitMode);
begin
  if FFitMode = AValue then
    Exit;
  FFitMode := AValue;
  Changed;
end;

end.
