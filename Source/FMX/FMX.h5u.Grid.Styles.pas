unit FMX.h5u.Grid.Styles;

interface

{$SCOPEDENUMS ON}

uses
  System.UITypes,
  FMX.Graphics,
  h5u.Grid.Types;

type
  Th5uFmxPalette = record
    GridBackground: TAlphaColor;
    EmptyArea: TAlphaColor;
    CellBackground: TAlphaColor;
    CellText: TAlphaColor;
    CellBorder: TAlphaColor;
    HeaderBackground: TAlphaColor;
    HeaderText: TAlphaColor;
    FixedBackground: TAlphaColor;
    OddBackground: TAlphaColor;
    EvenBackground: TAlphaColor;
    StripeBackground: TAlphaColor;
    HighlightedColumnBackground: TAlphaColor;
    SelectedBackground: TAlphaColor;
    SelectedText: TAlphaColor;
    FocusBorder: TAlphaColor;
    ErrorBackground: TAlphaColor;
    WarningBackground: TAlphaColor;
    TreeBranchEndBackground: TAlphaColor;
    DisabledText: TAlphaColor;
    ThumbHintBackground: TAlphaColor;
    ThumbHintText: TAlphaColor;
  end;

function h5uGetFmxPalette(ATheme: Th5uGridTheme): Th5uFmxPalette;
function h5uColorToFmx(const AColor: Th5uColor): TAlphaColor;
function h5uFmxToColor(const AColor: TAlphaColor): Th5uColor;

implementation

function h5uColorToFmx(const AColor: Th5uColor): TAlphaColor;
begin
  if (AColor = h5uColorDefault) or
     (AColor = h5uColorNone) then
    Exit(TAlphaColorRec.Null);

  Result := TAlphaColor(Cardinal(AColor));
end;

function h5uFmxToColor(const AColor: TAlphaColor): Th5uColor;
begin
  Result := Th5uColor(Cardinal(AColor));
end;

function h5uGetFmxPalette(ATheme: Th5uGridTheme): Th5uFmxPalette;
begin
  case ATheme of
    Th5uGridTheme.Classic2000:
      begin
        Result.GridBackground := $FFC0C0C0;
        Result.EmptyArea := $FFC0C0C0;
        Result.CellBackground := $FFFFFFFF;
        Result.CellText := $FF000000;
        Result.CellBorder := $FFA0A0A0;
        Result.HeaderBackground := $FFC0C0C0;
        Result.HeaderText := $FF000000;
        Result.FixedBackground := $FFD4D0C8;
        Result.OddBackground := $FFFFFFFF;
        Result.EvenBackground := $FFF5F5F5;
        Result.StripeBackground := $FFF3EDE8;
        Result.HighlightedColumnBackground := $FFFFF3D8;
        Result.SelectedBackground := $FF0A246A;
        Result.SelectedText := $FFFFFFFF;
        Result.FocusBorder := $FF000080;
        Result.ErrorBackground := $FFFFD7D7;
        Result.WarningBackground := $FFFFF4D6;
        Result.TreeBranchEndBackground := $FFD6DCE3;
        Result.DisabledText := $FF808080;
        Result.ThumbHintBackground := $FFFFFFE1;
        Result.ThumbHintText := $FF000000;
      end;

    Th5uGridTheme.Dark:
      begin
        Result.GridBackground := $FF242424;
        Result.EmptyArea := $FF202020;
        Result.CellBackground := $FF2B2B2B;
        Result.CellText := $FFE8E8E8;
        Result.CellBorder := $FF454545;
        Result.HeaderBackground := $FF353535;
        Result.HeaderText := $FFF0F0F0;
        Result.FixedBackground := $FF313131;
        Result.OddBackground := $FF2B2B2B;
        Result.EvenBackground := $FF272727;
        Result.StripeBackground := $FF463B32;
        Result.HighlightedColumnBackground := $FF423C2B;
        Result.SelectedBackground := $FF265A90;
        Result.SelectedText := $FFFFFFFF;
        Result.FocusBorder := $FF6DB6F2;
        Result.ErrorBackground := $FF4D3038;
        Result.WarningBackground := $FF473F2B;
        Result.TreeBranchEndBackground := $FF414B55;
        Result.DisabledText := $FF888888;
        Result.ThumbHintBackground := $FF404040;
        Result.ThumbHintText := $FFFFFFFF;
      end;

  else
    begin
      // FMX controls, scrollbars and embedded editors still use the active
      // application style. These semantic colors are the canvas fallback.
      Result.GridBackground := $FFF5F5F5;
      Result.EmptyArea := $FFF1F1F1;
      Result.CellBackground := $FFFFFFFF;
      Result.CellText := $FF252525;
      Result.CellBorder := $FFDDDDDD;
      Result.HeaderBackground := $FFE8E8E8;
      Result.HeaderText := $FF202020;
      Result.FixedBackground := $FFEEEEEE;
      Result.OddBackground := $FFFFFFFF;
      Result.EvenBackground := $FFFAFAFA;
      Result.StripeBackground := $FFEEF5FB;
      Result.HighlightedColumnBackground := $FFFFF7E3;
      Result.SelectedBackground := $FF0078D7;
      Result.SelectedText := $FFFFFFFF;
      Result.FocusBorder := $FF00569E;
      Result.ErrorBackground := $FFFFE7E7;
      Result.WarningBackground := $FFFFF5DD;
      Result.TreeBranchEndBackground := $FFD8E2EB;
      Result.DisabledText := $FF808080;
      Result.ThumbHintBackground := $FF383838;
      Result.ThumbHintText := $FFFFFFFF;
    end;
  end;
end;

end.
