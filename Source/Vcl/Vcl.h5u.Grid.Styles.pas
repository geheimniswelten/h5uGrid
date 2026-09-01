unit Vcl.h5u.Grid.Styles;

interface

{$SCOPEDENUMS ON}

uses
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Themes,
  h5u.Grid.Types;

type
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
    TreeBranchEndBackground: TColor;
    AdjacentGroupEndBackground: TColor;
    DisabledText: TColor;
    ThumbHintBackground: TColor;
    ThumbHintText: TColor;
  end;

function h5uGetVclPalette(ATheme: Th5uGridTheme): Th5uVclPalette;
function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
function h5uColorToVcl(const AColor: Th5uColor): TColor;
function h5uVclToColor(const AColor: TColor): Th5uColor;

implementation

uses
  Winapi.Windows;

function h5uBlendColor(AColor1, AColor2: TColor; AWeight: Byte): TColor;
var
  LColor1: Cardinal;
  LColor2: Cardinal;
  LR, LG, LB: Integer;
begin
  LColor1 := ColorToRGB(AColor1);
  LColor2 := ColorToRGB(AColor2);

  LR := (
    GetRValue(LColor1) * (255 - AWeight) +
    GetRValue(LColor2) * AWeight
  ) div 255;
  LG := (
    GetGValue(LColor1) * (255 - AWeight) +
    GetGValue(LColor2) * AWeight
  ) div 255;
  LB := (
    GetBValue(LColor1) * (255 - AWeight) +
    GetBValue(LColor2) * AWeight
  ) div 255;

  Result := RGB(LR, LG, LB);
end;

function h5uColorToVcl(const AColor: Th5uColor): TColor;
begin
  if AColor = h5uColorDefault then
    Exit(clDefault);
  if AColor = h5uColorNone then
    Exit(clNone);

  Result := RGB(
    (Cardinal(AColor) shr 16) and $FF,
    (Cardinal(AColor) shr 8) and $FF,
    Cardinal(AColor) and $FF
  );
end;

function h5uGetVclPalette(ATheme: Th5uGridTheme): Th5uVclPalette;
var
  LWindow: TColor;
  LText: TColor;
  LButton: TColor;
  LHighlight: TColor;
  LHighlightText: TColor;
begin
  case ATheme of
    Th5uGridTheme.Classic2000:
      begin
        Result.GridBackground := clBtnFace;
        Result.EmptyArea := clBtnFace;
        Result.CellBackground := clWindow;
        Result.CellText := clWindowText;
        Result.CellBorder := clSilver;
        Result.HeaderBackground := clBtnFace;
        Result.HeaderText := clBtnText;
        Result.FixedBackground := clBtnFace;
        Result.OddBackground := clWindow;
        Result.EvenBackground := $00F5F5F5;
        Result.StripeBackground := $00E8EDF3;
        Result.HighlightedColumnBackground := $00FFF3D8;
        Result.SelectedBackground := clHighlight;
        Result.SelectedText := clHighlightText;
        Result.FocusBorder := clNavy;
        Result.ErrorBackground := $00D7D7FF;
        Result.WarningBackground := $00D6F4FF;
        Result.TreeBranchEndBackground := $00D6DCE3;
        Result.AdjacentGroupEndBackground := $00CAD4DE;
        Result.DisabledText := clGrayText;
        Result.ThumbHintBackground := clInfoBk;
        Result.ThumbHintText := clInfoText;
      end;

    Th5uGridTheme.Dark:
      begin
        Result.GridBackground := $00242424;
        Result.EmptyArea := $00202020;
        Result.CellBackground := $002B2B2B;
        Result.CellText := $00E8E8E8;
        Result.CellBorder := $00454545;
        Result.HeaderBackground := $00353535;
        Result.HeaderText := $00F0F0F0;
        Result.FixedBackground := $00313131;
        Result.OddBackground := $002B2B2B;
        Result.EvenBackground := $00272727;
        Result.StripeBackground := $00323B46;
        Result.HighlightedColumnBackground := $00423C2B;
        Result.SelectedBackground := $00905A26;
        Result.SelectedText := clWhite;
        Result.FocusBorder := $00F2B66D;
        Result.ErrorBackground := $004D3038;
        Result.WarningBackground := $00473F2B;
        Result.TreeBranchEndBackground := $00414B55;
        Result.AdjacentGroupEndBackground := $00495561;
        Result.DisabledText := $00888888;
        Result.ThumbHintBackground := $00404040;
        Result.ThumbHintText := clWhite;
      end;

    Th5uGridTheme.Modern:
      begin
        Result.GridBackground := $00F5F5F5;
        Result.EmptyArea := $00F1F1F1;
        Result.CellBackground := clWhite;
        Result.CellText := $00252525;
        Result.CellBorder := $00DDDDDD;
        Result.HeaderBackground := $00E8E8E8;
        Result.HeaderText := $00202020;
        Result.FixedBackground := $00EEEEEE;
        Result.OddBackground := clWhite;
        Result.EvenBackground := $00FAFAFA;
        Result.StripeBackground := $00EEF5FB;
        Result.HighlightedColumnBackground := $00FFF7E3;
        Result.SelectedBackground := $00D77800;
        Result.SelectedText := clWhite;
        Result.FocusBorder := $009E5600;
        Result.ErrorBackground := $00E7E7FF;
        Result.WarningBackground := $00DDF5FF;
        Result.TreeBranchEndBackground := $00D8E2EB;
        Result.AdjacentGroupEndBackground := $00CBD9E5;
        Result.DisabledText := $00808080;
        Result.ThumbHintBackground := $00383838;
        Result.ThumbHintText := clWhite;
      end;

  else
    begin
      LWindow := StyleServices.GetSystemColor(clWindow);
      LText := StyleServices.GetSystemColor(clWindowText);
      LButton := StyleServices.GetSystemColor(clBtnFace);
      LHighlight := StyleServices.GetSystemColor(clHighlight);
      LHighlightText := StyleServices.GetSystemColor(clHighlightText);

      Result.GridBackground := LButton;
      Result.EmptyArea := LButton;
      Result.CellBackground := LWindow;
      Result.CellText := LText;
      Result.CellBorder := h5uBlendColor(LText, LWindow, 205);
      Result.HeaderBackground := LButton;
      Result.HeaderText := StyleServices.GetSystemColor(clBtnText);
      Result.FixedBackground := LButton;
      Result.OddBackground := LWindow;
      Result.EvenBackground := h5uBlendColor(LWindow, LButton, 35);
      Result.StripeBackground := h5uBlendColor(LWindow, LHighlight, 28);
      Result.HighlightedColumnBackground :=
        h5uBlendColor(LWindow, clYellow, 25);
      Result.SelectedBackground := LHighlight;
      Result.SelectedText := LHighlightText;
      Result.FocusBorder := LHighlight;
      Result.ErrorBackground :=
        h5uBlendColor(LWindow, clRed, 35);
      Result.WarningBackground :=
        h5uBlendColor(LWindow, clYellow, 45);
      Result.TreeBranchEndBackground :=
        h5uBlendColor(LWindow, LHighlight, 20);
      Result.AdjacentGroupEndBackground :=
        h5uBlendColor(LWindow, LHighlight, 28);
      Result.DisabledText := StyleServices.GetSystemColor(clGrayText);
      Result.ThumbHintBackground :=
        StyleServices.GetSystemColor(clInfoBk);
      Result.ThumbHintText :=
        StyleServices.GetSystemColor(clInfoText);
    end;
  end;
end;

function h5uVclToColor(const AColor: TColor): Th5uColor;
var
  LColor: Cardinal;
begin
  LColor := ColorToRGB(AColor);
  Result := Th5uColor(
    $FF000000 or
    (GetRValue(LColor) shl 16) or
    (GetGValue(LColor) shl 8) or
    GetBValue(LColor)
  );
end;

end.
