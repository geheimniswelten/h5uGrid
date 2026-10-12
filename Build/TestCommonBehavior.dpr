program TestCommonBehavior;

{$IFDEF FPC}
{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$CODEPAGE UTF8}
{$ELSE}
{$APPTYPE CONSOLE}
{$ENDIF}
{$SCOPEDENUMS ON}

uses
{$IFDEF FPC}
  h5u.Grid.Compat,
  SysUtils, Math, Rtti, Classes, DateUtils,
{$ENDIF}
{$IFNDEF FPC}
  System.SysUtils,
{$ENDIF}
  h5u.Grid.Values,
{$IFNDEF FPC}
  System.Math,
{$ENDIF}
  h5u.Grid.Layout,
  h5u.Grid.RowMetrics,
{$IFNDEF FPC}
  System.Rtti,
{$ENDIF}
  h5u.Grid.AdjacentGroups,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.Memory,
  h5u.Grid.View,
{$IFNDEF FPC}
  System.Classes,
{$ENDIF}
{$IFNDEF FPC}
  System.DateUtils,
{$ENDIF}
{$IFNDEF FPC}
  System.UITypes,
{$ENDIF}
  h5u.Grid.Types,
  h5u.Grid.Sizing,
  h5u.Grid.Selection,
  h5u.Grid.Navigation,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  h5u.Grid.Resizing;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TestColumnWidths;
var
  C, CopyColumns: Th5uGridColumns;
  H, CopyHeader: Th5uHeaderLayout;
  A, B, D, Outside: Th5uGridColumn;
  G, Nested: Th5uHeaderLayoutCell;
  I: Integer;
  Total: Single;
begin
  C := Th5uGridColumns.Create(nil);
  H := Th5uHeaderLayout.Create(nil);
  CopyColumns := Th5uGridColumns.Create(nil);
  CopyHeader := Th5uHeaderLayout.Create(nil);
  try
    A := C.Add; A.Id := 'fixed'; A.Width := 100;
    B := C.Add; B.Id := 'quarter'; B.WidthInPercent := 25;
    D := C.Add; D.Id := 'rest'; D.WidthInPercent := 75;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((A.LayoutWidth = 100) and (B.LayoutWidth = 100) and (D.LayoutWidth = 300), 'fixed width and spacing before percentages');
    Check((B.Width = -25) and (D.Width = -75), 'layout must preserve configured percentage specifications');
    B.MinWidth := 150;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 150) and (D.LayoutWidth = 250), Format('minimum redistributes remaining width: %.9f %.9f', [B.LayoutWidth, D.LayoutWidth]));
    B.MinWidth := 24;
    D.MaxWidth := 200;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 200) and (D.LayoutWidth = 200), 'maximum redistributes remaining width');
    D.MaxWidth := 1000;
    h5uResolveColumnWidths(C, H, 1, 503, 703, 0);
    Check((B.LayoutWidth = 150) and (D.LayoutWidth = 450), 'grid minimum applies to total column content');
    h5uResolveColumnWidths(C, H, 1, 503, 0, 403);
    Check((B.LayoutWidth = 75) and (D.LayoutWidth = 225), 'grid maximum applies to total column content');
    h5uResolveColumnWidths(C, H, 1, 80);
    Check((A.LayoutWidth = 100) and (B.LayoutWidth = 24) and (D.LayoutWidth = 24), 'overconstrained content preserves pixels and minima');
    B.AutoWidth := True;
    B.SetMeasuredWidth(180);
    h5uResolveColumnWidths(C, H, 1, 503);
    Check((B.LayoutWidth = 180) and (D.LayoutWidth = 220), 'AutoWidth precedes percent and reserves measured content');
    B.Visible := False;
    h5uResolveColumnWidths(C, H, 1, 503);
    Check(D.LayoutWidth = 401, 'hidden columns consume neither width nor spacing');
    B.Visible := True;
    B.AutoWidth := False;
    A.FixedKind := Th5uFixedKind.Left;
    D.FixedKind := Th5uFixedKind.Right;
    h5uResolveColumnWidths(C, H, 1, 504);
    Check(B.LayoutWidth + D.LayoutWidth = 401, 'rounding conserves pixels including pinned columns');
    A.FixedKind := Th5uFixedKind.None;
    D.FixedKind := Th5uFixedKind.None;
    h5uTryResizeColumn(C, B, B.LayoutWidth, 10);
    Check((B.WidthInPercent = 0) and not B.AutoWidth, 'manual resizing selects pixel mode');
    B.WidthInPercent := 30;
    D.WidthInPercent := 70;
    H.Enabled := True;
    G := H.Cells.Add;
    G.ColumnSpan := 3;
    G.Width := 400;
    Outside := C.Add; Outside.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 90) and (D.LayoutWidth = 210) and (Outside.LayoutWidth = 600), 'parent group budget and independent view remainder');
    Nested := H.Cells.Add;
    Nested.LayoutRow := 1; Nested.LayoutColumn := 1; Nested.ColumnSpan := 2;
    Nested.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 90) and (D.LayoutWidth = 210), 'nested group uses allocated parent remainder');
    G.MinWidth := 500;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check((B.LayoutWidth = 120) and (D.LayoutWidth = 280) and (Outside.LayoutWidth = 500), 'group minimum');
    G.MinWidth := 0;
    G.Width := 0;
    G.WidthInPercent := 50;
    Outside.WidthInPercent := 50;
    h5uResolveColumnWidths(C, H, 0, 1000);
    Check(A.LayoutWidth + B.LayoutWidth + D.LayoutWidth = 500, 'percent group reserves its share in the view');
    CopyColumns.Assign(C);
    CopyHeader.Assign(H);
    Check((CopyColumns[1].WidthInPercent = 30) and (CopyHeader.Cells[0].WidthInPercent = 50), 'Assign retains column and group sizing');
    h5uResolveColumnWidths(CopyColumns, CopyHeader, 0, 1000);
    Check(CopyColumns[2].LayoutWidth = D.LayoutWidth, 'copied layout resolves identically');
    H.Enabled := False;
    for I := 1 to 4 do
    begin
      h5uResolveColumnWidths(C, H, 1, 651.75);
      Total := 0;
      for A in C.VisibleColumns do
        Total := Total + A.LayoutWidth + 1;
      Check(Abs(Total - 651.75) < 0.001, 'fractional viewport is preserved across repeated layout');
    end;
    B.WidthInPercent := 1E-30;
    h5uResolveColumnWidths(C, H, 1, 651);
    Check(B.LayoutWidth = B.MinWidth, 'tiny percentage cannot overflow the allocator');
    C[0].Visible := False;
    D.Visible := False;
    Outside.Visible := False;
    B.MinWidth := 0;
    B.WidthInPercent := 100;
    h5uResolveColumnWidths(C, H, 0, 0);
    Check(B.LayoutWidth = 0, 'zero column minimum remains supported');
    Writeln('PASS: auto, percent, fixed, hidden and pinned widths, grid limits, nested groups, rounding, Assign and manual resize');
  finally
    CopyHeader.Free;
    CopyColumns.Free;
    H.Free;
    C.Free;
  end;
end;

type
  TWidthStreamHost = class(TComponent)
  private
    FColumns: Th5uGridColumns;
    FHeader: Th5uHeaderLayout;
    FModernSizing: Boolean;
    FSizing: Th5uColumnSizingOptions;
    procedure SetColumns(AValue: Th5uGridColumns);
    procedure SetHeader(AValue: Th5uHeaderLayout);
    procedure SetSizing(AValue: Th5uColumnSizingOptions);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ModernSizing: Boolean read FModernSizing write FModernSizing;
    property Columns: Th5uGridColumns read FColumns write SetColumns;
    property Header: Th5uHeaderLayout read FHeader write SetHeader;
    property Sizing: Th5uColumnSizingOptions read FSizing write SetSizing;
  end;

constructor TWidthStreamHost.Create(AOwner: TComponent);
begin
  inherited;
  FColumns := Th5uGridColumns.Create(Self);
  FHeader := Th5uHeaderLayout.Create(Self);
  FSizing := Th5uColumnSizingOptions.Create;
end;

destructor TWidthStreamHost.Destroy;
begin
  FSizing.Free;
  FHeader.Free;
  FColumns.Free;
  inherited;
end;

procedure TWidthStreamHost.SetColumns(AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure TWidthStreamHost.SetHeader(AValue: Th5uHeaderLayout);
begin
  FHeader.Assign(AValue);
end;

procedure TWidthStreamHost.SetSizing(AValue: Th5uColumnSizingOptions);
begin
  FSizing.Assign(AValue);
end;

procedure TWidthStreamHost.Loaded;
var
  I: Integer;
begin
  inherited;
  if not FModernSizing then
  begin
    for I := 0 to FColumns.Count - 1 do
      FColumns[I].ApplyLegacySizing;
    for I := 0 to FHeader.Cells.Count - 1 do
      FHeader.Cells[I].ApplyLegacySizing;
  end;
end;

procedure TestUnifiedColumnWidths;
var
  LColumns: Th5uGridColumns;
  LHeader: Th5uHeaderLayout;
  LOptions, LCopyOptions: Th5uColumnSizingOptions;
  LCheck, LText, LOther: Th5uGridColumn;
  LGroup: Th5uHeaderLayoutCell;
  LValue: Th5uWidth;
  LHost, LCopyHost: TWidthStreamHost;
  LSource: TStringStream;
  LStream: TMemoryStream;
  LFailed: Boolean;
  LSavedDecimal: Char;
begin
  LColumns := Th5uGridColumns.Create(nil);
  LHeader := Th5uHeaderLayout.Create(nil);
  LOptions := Th5uColumnSizingOptions.Create;
  LCopyOptions := Th5uColumnSizingOptions.Create;
  try
    LCheck := LColumns.Add;
    LCheck.SetWidthDefaults(28, 28, 28, 1000);
    LText := LColumns.Add;
    LText.Width := 200;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LCheck.LayoutWidth = 28) and (LText.LayoutWidth = 972),
      'AllColumns preserves fixed editor bounds and gives text the remaining width');
    Check((LCheck.Width = 0) and (LText.Width = 200), 'fitting must preserve requested widths');
    LText.MinWidth := 80;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 40, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LCheck.LayoutWidth = 28) and (LText.LayoutWidth = 80), 'fitting never scales pixel minima');
    LCheck.Visible := False;
    LOther := LColumns.Add;
    LText.Width := 100;
    LText.MinWidth := 0;
    LOther.Width := 200;
    LOther.MinWidth := 0;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 900, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LText.LayoutWidth = 300) and (LOther.LayoutWidth = 600), 'pixel widths become relative in AllColumns');
    LText.AutoWidth := True;
    LText.SetMeasuredWidth(100);
    h5uResolveColumnWidths(LColumns, LHeader, 0, 900, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LText.LayoutWidth = 300) and (LOther.LayoutWidth = 600), 'AllColumns includes measured AutoWidth in proportional fitting');
    LText.AutoWidth := False;
    LText.Width := -20;
    LOther.Width := -20;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.None);
    Check((LText.LayoutWidth = 200) and (LOther.LayoutWidth = 200), 'None treats percentages as literal viewport fractions');
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.PercentColumns);
    Check((LText.LayoutWidth = 500) and (LOther.LayoutWidth = 500), 'PercentColumns normalizes visible percentage weights');
    LText.Width := -200;
    LOther.Width := -12.5;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.None);
    Check((LText.LayoutWidth = 2000) and (LOther.LayoutWidth = 125), 'percent widths allow fractions and values over100');
    LText.Width := 100;
    LText.MaxWidth := -25;
    LOther.Width := 100;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LText.LayoutWidth = 250) and (LOther.LayoutWidth = 750), 'resolved percent maxima are bounds rather than fitting weights');
    h5uResolveColumnWidths(LColumns, LHeader, 0, 800, 0, 0, Th5uColumnFitMode.AllColumns);
    Check((LText.LayoutWidth = 200) and (LOther.LayoutWidth = 600), 'percent maximum follows current reference width');
    LText.Width := 0;
    LText.MaxWidth := 0;
    LText.SetWidthDefaults(-25, 12, 700, 1000);
    LOther.Visible := False;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.None);
    Check(LText.LayoutWidth = 250, 'default chain may itself resolve to a percentage');
    LText.SetWidthDefaults(100, 12, 3000, 1000);
    LText.AutoWidth := True;
    LText.SetMeasuredWidth(100000);
    Check(LText.MeasuredWidth = 3000, 'AutoWidth applies the default text maximum');
    LText.MaxWidth := 0;
    LText.AutoWidth := False;
    LText.Width := -50;
    LOther.Visible := True;
    LOther.Width := -50;
    LHeader.Enabled := True;
    LGroup := LHeader.Cells.Add;
    LGroup.ColumnSpan := 2;
    LGroup.Width := 400;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.None);
    Check((LText.LayoutWidth = 200) and (LOther.LayoutWidth = 200), 'literal child percentages use their enclosing group width');
    LText.MaxWidth := -25;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, Th5uColumnFitMode.PercentColumns);
    Check((LText.LayoutWidth = 100) and (LOther.LayoutWidth = 300), 'nested percentage maximum resolves from allocated group');
    LOptions.DefaultWidth := -12.5;
    LOptions.DefaultMaxWidth := -200;
    LOptions.FitMode := Th5uColumnFitMode.AllColumns;
    LOptions.MaxWidthSource := Th5uMaxWidthSource.Monitor;
    LCopyOptions.Assign(LOptions);
    Check((LCopyOptions.DefaultWidth = -12.5) and (LCopyOptions.DefaultMaxWidth = -200)
      and (LCopyOptions.FitMode = Th5uColumnFitMode.AllColumns)
      and (LCopyOptions.MaxWidthSource = Th5uMaxWidthSource.Monitor), 'sizing Assign copies settings');
    Check(h5uTryTextToWidth('Default', LValue) and (LValue = 0), 'default width input');
    Check(h5uTryTextToWidth('200 %', LValue) and (LValue = -200), 'percent width input');
    Check(h5uTryTextToWidth('120 px', LValue) and (LValue = 120), 'pixel width input');
    Check(h5uTryTextToWidth('-200', LValue) and (LValue = -200), 'raw negative width input');
    Check(h5uTryTextToWidth('Unlimited', LValue) and (LValue = h5uUnlimitedWidth), 'unlimited migration value input');
    Check(not h5uTryTextToWidth('1e300', LValue), 'overflowing width input rejected');
    Check(not h5uTryTextToWidth('', LValue), 'empty width input rejected');
    {$IFNDEF FPC}
    LSavedDecimal := FormatSettings.DecimalSeparator;
    FormatSettings.DecimalSeparator := ',';
    try
      Check(h5uTryTextToWidth('12,5 %', LValue) and (LValue = -12.5), 'localized fractional percent input');
      Check(h5uWidthToText(-12.5) = '12,5 %', 'localized fractional percent display');
    finally
      FormatSettings.DecimalSeparator := LSavedDecimal;
    end;
    {$ENDIF}
    LFailed := False;
    try
      LText.Width := NaN;
    except
      on E: EArgumentOutOfRangeException do
        LFailed := True;
    end;
    Check(LFailed, 'invalid floating width property rejected');
  finally
    LCopyOptions.Free;
    LOptions.Free;
    LHeader.Free;
    LColumns.Free;
  end;
  RegisterClass(TWidthStreamHost);
  LSource := TStringStream.Create(
    'object WidthHost: TWidthStreamHost' + sLineBreak
    + '  Columns = <' + sLineBreak
    + '    item end' + sLineBreak
    + '    item Width = 120 MaxWidth = 0 WidthInPercent = 25.0 end' + sLineBreak
    + '    item WidthInPercent = 12.5 Width = 200 MaxWidth = 400 end' + sLineBreak
    + '    item Width = -75.0 WidthInPercent = 25.0 end' + sLineBreak
    + '    item Width = 123.25 MinWidth = 12.5 MaxWidth = 536870911 end>' + sLineBreak
    + '  Header.Cells = <item WidthInPercent = 25.0 Width = 100 end>' + sLineBreak
    + 'end');
  LStream := TMemoryStream.Create;
  LHost := nil;
  LCopyHost := nil;
  try
    ObjectTextToBinary(LSource, LStream);
    LStream.Position := 0;
    LHost := TWidthStreamHost(LStream.ReadComponent(nil));
    Check((LHost.Columns[0].Width = 100) and (LHost.Columns[0].MaxWidth = 1000),
      'legacy omitted column defaults survive migration');
    Check((LHost.Columns[1].Width = -25) and (LHost.Columns[1].MaxWidth = h5uUnlimitedWidth),
      'legacy integer width, zero unlimited maximum and percentage survive migration');
    Check((LHost.Columns[2].Width = -12.5) and (LHost.Columns[2].MaxWidth = 400),
      'legacy percentage migration does not depend on stream property order');
    Check(LHost.Columns[3].Width = -75, 'new negative width wins over old percentage property');
    Check((LHost.Columns[4].Width = 123.25) and (LHost.Columns[4].MinWidth = 12.5)
      and (LHost.Columns[4].MaxWidth = h5uUnlimitedWidth), 'old numeric sentinel and fractional properties load into Single storage');
    Check(LHost.Header.Cells[0].Width = -25, 'legacy group percentage does not depend on stream order');
    LHost.ModernSizing := True;
    LHost.Columns[0].Width := 0;
    LHost.Columns[0].MaxWidth := 0;
    LHost.Columns[0].MinWidth := 0;
    LHost.Columns[0].RightSpacing := 0;
    LHost.Columns[0].MaxAutoHeight := 0;
    LStream.Clear;
    LStream.WriteComponent(LHost);
    LStream.Position := 0;
    LCopyHost := TWidthStreamHost(LStream.ReadComponent(nil));
    Check((LCopyHost.Columns[0].Width = 0) and (LCopyHost.Columns[0].MaxWidth = 0)
      and (LCopyHost.Columns[0].MinWidth = 0), Format('modern default widths and explicit zero minimum round trip %.4f %.4f %.4f', [LCopyHost.Columns[0].Width, LCopyHost.Columns[0].MaxWidth, LCopyHost.Columns[0].MinWidth]));
    Check(LCopyHost.Columns[2].Width = -12.5, 'modern fractional percent width round trip');
    Check((LCopyHost.Columns[0].RightSpacing = 0) and (LCopyHost.Columns[0].MaxAutoHeight = 0),
      'explicit zero Single values survive nonzero constructor defaults');
    Check((LCopyHost.Columns[4].Width = 123.25) and (LCopyHost.Columns[4].MinWidth = 12.5)
      and (LCopyHost.Columns[4].MaxWidth = h5uUnlimitedWidth), 'Single widths and normalized sentinel round trip');
    Writeln('PASS: unified width modes, unscaled bounds, type defaults, nested percent limits, text input and legacy streams');
  finally
    LCopyHost.Free;
    LHost.Free;
    LStream.Free;
    LSource.Free;
    UnRegisterClass(TWidthStreamHost);
  end;
end;

procedure TestNormalizedGroupMaxima;
var
  LColumns: Th5uGridColumns;
  LHeader: Th5uHeaderLayout;
  LColumn: Th5uGridColumn;
  LGroup: Th5uHeaderLayoutCell;
  I: Integer;
  LFitMode: Th5uColumnFitMode;
begin
  LColumns := Th5uGridColumns.Create(nil);
  LHeader := Th5uHeaderLayout.Create(nil);
  try
    LHeader.Enabled := True;
    for I := 0 to 1 do
    begin
      LColumn := LColumns.Add;
      LColumn.Width := -100;
      LColumn.MinWidth := 0;
      LColumn.MaxWidth := -200;
      LGroup := LHeader.Cells.Add;
      LGroup.LayoutColumn := I;
      LGroup.Width := -20;
    end;
    for LFitMode in [Th5uColumnFitMode.PercentColumns, Th5uColumnFitMode.AllColumns] do
    begin
      h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, LFitMode);
      Check((LColumns[0].LayoutWidth = 500) and (LColumns[1].LayoutWidth = 500),
        Format('normalized group maxima must use allocated reference: %g/%g',
          [LColumns[0].LayoutWidth, LColumns[1].LayoutWidth]));
    end;
    LColumns[0].MaxWidth := -100;
    LColumns[1].MaxWidth := -100;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000);
    Check((LColumns[0].LayoutWidth = 500) and (LColumns[1].LayoutWidth = 500),
      '100 percent child maxima do not freeze preliminary group widths');
    for I := 0 to 1 do
    begin
      LColumns[I].MaxWidth := 0;
      LColumns[I].SetWidthDefaults(100, 0, -200, 1000);
    end;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000);
    Check((LColumns[0].LayoutWidth = 500) and (LColumns[1].LayoutWidth = 500),
      'inherited percentage maxima use the eventual group reference');
    LColumns[0].MaxWidth := 300;
    LColumns[1].MaxWidth := 2000;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000);
    Check((LColumns[0].LayoutWidth = 300) and (LColumns[1].LayoutWidth = 700),
      'static child maximum remains an absolute group cap');
    LColumns.Clear;
    LHeader.Cells.Clear;
    LColumn := LColumns.Add;
    LColumn.Width := 100;
    LColumn.MinWidth := 100;
    LColumn.MaxWidth := 100;
    LColumn := LColumns.Add;
    LColumn.Width := -100;
    LColumn.MinWidth := 0;
    LColumn.MaxWidth := -50;
    LColumn := LColumns.Add;
    LColumn.Width := -100;
    LColumn.MinWidth := 0;
    LColumn.MaxWidth := 2000;
    LGroup := LHeader.Cells.Add;
    LGroup.Width := -20;
    LGroup.ColumnSpan := 2;
    LGroup := LHeader.Cells.Add;
    LGroup.Width := -20;
    LGroup.LayoutColumn := 2;
    LGroup := LHeader.Cells.Add;
    LGroup.Width := -100;
    LGroup.LayoutRow := 1;
    LGroup.ColumnSpan := 2;
    for LFitMode in [Th5uColumnFitMode.PercentColumns, Th5uColumnFitMode.AllColumns] do
    begin
      h5uResolveColumnWidths(LColumns, LHeader, 0, 1000, 0, 0, LFitMode);
      Check((LColumns[0].LayoutWidth = 100) and (LColumns[1].LayoutWidth = 100)
        and (LColumns[2].LayoutWidth = 800),
        'nested group with fixed100 and percent maximum50 has intrinsic maximum200');
    end;
    LColumns[1].MaxWidth := -12.5;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 1000);
    Check((LColumns[0].LayoutWidth = 100) and (Abs(LColumns[1].LayoutWidth - 100 / 7) < 0.001)
      and (Abs(LColumns[2].LayoutWidth - 6200 / 7) < 0.001), 'fractional intrinsic limits remain unquantized');
    Writeln('PASS: normalized group-relative percentage maxima and intrinsic nested limits');
  finally
    LHeader.Free;
    LColumns.Free;
  end;
end;

procedure TestInheritedWidthDefaults;
var
  LAncestor, LDescendant, LLoaded: TWidthStreamHost;
  LStream: TMemoryStream;
begin
  RegisterClass(TWidthStreamHost);
  LAncestor := TWidthStreamHost.Create(nil);
  LDescendant := TWidthStreamHost.Create(nil);
  LLoaded := TWidthStreamHost.Create(nil);
  LStream := TMemoryStream.Create;
  try
    LAncestor.Name := 'WidthHost';
    LAncestor.ModernSizing := True;
    LAncestor.Sizing.DefaultWidth := -25;
    LAncestor.Sizing.DefaultMaxWidth := 600;
    LAncestor.Columns.Add.Width := -50;
    LAncestor.Columns[0].MaxWidth := 400;
    LAncestor.Header.Cells.Add.Width := 300;
    LAncestor.Header.Cells[0].MaxWidth := 800;
    LDescendant.Name := LAncestor.Name;
    LDescendant.ModernSizing := True;
    LDescendant.Columns.Assign(LAncestor.Columns);
    LDescendant.Header.Assign(LAncestor.Header);
    LDescendant.Columns[0].Width := 0;
    LDescendant.Columns[0].MaxWidth := 0;
    LDescendant.Header.Cells[0].Width := 0;
    LDescendant.Header.Cells[0].MaxWidth := 0;
    LLoaded.Name := LAncestor.Name;
    LLoaded.ModernSizing := True;
    LLoaded.Sizing.Assign(LAncestor.Sizing);
    LLoaded.Columns.Assign(LAncestor.Columns);
    LLoaded.Header.Assign(LAncestor.Header);
    LStream.WriteDescendent(LDescendant, LAncestor);
    LStream.Position := 0;
    LStream.ReadComponent(LLoaded);
    Check((LLoaded.Sizing.DefaultWidth = 0) and (LLoaded.Sizing.DefaultMaxWidth = 0),
      'inherited form resets nonzero sizing defaults to Default');
    Check((LLoaded.Columns[0].Width = 0) and (LLoaded.Columns[0].MaxWidth = 0),
      'inherited form resets column width and maximum to Default');
    Check((LLoaded.Header.Cells[0].Width = 0) and (LLoaded.Header.Cells[0].MaxWidth = 0),
      'inherited form resets group width and maximum to Default');
    Writeln('PASS: inherited form streaming preserves explicit resets to width defaults');
  finally
    LStream.Free;
    LLoaded.Free;
    LDescendant.Free;
    LAncestor.Free;
    UnRegisterClass(TWidthStreamHost);
  end;
end;

procedure TestSingleWidthGeometry;
var
  LColumns: Th5uGridColumns;
  LHeader: Th5uHeaderLayout;
  LValue: Th5uWidth;
  LBefore: Single;
begin
  Check(SizeOf(Th5uWidth) = SizeOf(Single), 'public width type must use Single storage');
  Check(h5uTryTextToWidth('536870911', LValue) and (LValue = h5uUnlimitedWidth),
    'previous unlimited sentinel is accepted and normalized to its exact Single value');
  Check(h5uWidthToText(LValue) = 'Unlimited', 'normalized sentinel retains its display name');
  LColumns := Th5uGridColumns.Create(nil);
  LHeader := Th5uHeaderLayout.Create(nil);
  try
    LColumns.Add.Width := 100.25;
    LColumns[0].MinWidth := 12.5;
    LColumns[0].MaxWidth := 100.5;
    LColumns[0].RightSpacing := 0.25;
    LColumns.Add.Width := -100;
    h5uResolveColumnWidths(LColumns, LHeader, 0.5, 300.75);
    Check((LColumns[0].LayoutWidth = 100.25) and (LColumns[1].LayoutWidth = 199.75),
      'fractional fixed width and spacing survive shared allocation');
    LColumns[0].SetMeasuredWidth(70.75);
    Check(LColumns[0].MeasuredWidth = 70.75, 'measured width cache preserves fractional geometry');
    LColumns[0].AutoWidth := True;
    h5uResolveColumnWidths(LColumns, LHeader, 0.5, 300.75);
    Check((LColumns[0].LayoutWidth = 70.75) and (LColumns[1].LayoutWidth = 229.25),
      'AutoWidth does not quantize its measured value');
    LBefore := LColumns[0].LayoutWidth;
    h5uTryResizeColumn(LColumns, LColumns[0], LBefore, 0.125);
    Check(LColumns[0].Width = 70.875, 'manual logical resize preserves fractional deltas');
    LColumns[0].RightSpacing := 0;
    LColumns[0].MinWidth := 0;
    LColumns[0].Width := -1E-30;
    LColumns[0].MaxWidth := 1000;
    LColumns[1].Width := -100;
    LColumns[1].MaxWidth := 100;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 500.25);
    Check((Abs(LColumns[0].LayoutWidth - 400.25) < 0.001)
      and (LColumns[1].LayoutWidth = 100), 'tiny Single weights receive remainder after other columns reach their maxima');
    LColumns[0].Width := -100;
    LColumns[1].MaxWidth := 1000;
    h5uResolveColumnWidths(LColumns, LHeader, 0, 101.25);
    Check((LColumns[0].LayoutWidth = 50.625) and (LColumns[1].LayoutWidth = 50.625),
      'equal columns retain subpixel proportions');
    Writeln('PASS: Single widths, fractional layout/measurement/resize and legacy unlimited sentinel');
  finally
    LHeader.Free;
    LColumns.Free;
  end;
end;

procedure TestResizeBoundaries;
var
  LColumns: Th5uGridColumns;
  LOptions: Th5uCustomizationOptions;
  LItems: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uResizeCandidate>;
  LRemoved: Th5uGridColumn;
begin
  LColumns := Th5uGridColumns.Create(nil);
  LOptions := Th5uCustomizationOptions.Create;
  try
    SetLength(LItems, 2);
    LItems[0].Column := LColumns.Add;
    LItems[0].VisibleIndex := 0;
    LItems[0].Right := 100;
    LItems[0].ViewLeft := 0;
    LItems[0].ViewRight := 300;
    LItems[1].Column := LColumns.Add;
    LItems[1].VisibleIndex := 1;
    LItems[1].Right := 200;
    LItems[1].ViewLeft := 0;
    LItems[1].ViewRight := 300;
    LOptions.ColumnResizeHitZoneLeft := 8;
    LOptions.ColumnResizeHitZoneRight := 2;
    LOptions.LastColumnResizeHitZoneLeft := 20;
    LOptions.TouchColumnResizeHitZoneLeft := 14;
    LOptions.TouchColumnResizeHitZoneRight := 9;
    LOptions.TouchLastColumnResizeHitZoneLeft := -1;
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 92, 5, False, nil) = LItems[0].Column, 'inclusive left edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 91.9, 5, False, nil) = nil, 'outside left edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 102, 5, False, nil) = LItems[0].Column, 'inclusive right edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 102.1, 5, False, nil) = nil, 'outside right edge');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 180, 5, False, nil) = LItems[1].Column, 'last-column override');
    Check(h5uColumnResizeAt(LOptions, LItems, 2, 180, 5, False, nil) = nil, 'viewport last is not model last');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 186, 5, True, nil) = LItems[1].Column, 'touch default inheritance');
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 185.9, 5, True, nil) = nil, 'touch inherited boundary');
    LItems[1].ViewRight := 195;
    Check(h5uColumnResizeAt(LOptions, LItems, 1, 194, 5, False, nil) = nil, 'clipped edge');
    LRemoved := LColumns.Add;
    LRemoved.Free;
    Check(not h5uTryResizeColumn(LColumns, LRemoved, 100, 10), 'removed resize source');
    LItems[0].Column.CanResize := False;
    Check(not h5uTryResizeColumn(LColumns, LItems[0].Column, 100, 10), 'disabled resize source');
    Writeln('PASS: common asymmetric resize, touch inheritance, clipping and removed sources');
  finally
    LOptions.Free;
    LColumns.Free;
  end;
end;

type
  TNavigationData = class
    UnicodeText: Boolean;
    function RowKey(ARow: Int64): Th5uRowKey;
    function Extent(ARow: Int64): Single;
    procedure Prepare(AFirst, ACount: Int64);
    function Text(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
  end;

function TNavigationData.RowKey(ARow: Int64): Th5uRowKey;
begin
  Result := Th5uRowKey.FromInt64(ARow + 100);
end;

function TNavigationData.Extent(ARow: Int64): Single;
begin
  Result := 20;
end;

procedure TNavigationData.Prepare(AFirst, ACount: Int64);
begin
  Check((AFirst >= 0) and (ACount = 1), 'search preparation range');
end;

function TNavigationData.Text(AColumn: Th5uGridColumn; ARow: Int64; ADisplay: Boolean): string;
begin
  if UnicodeText then
  begin
    case ARow of
      0: Result := 'Äpfel';
      1: Result := '東京';
      2: Result := 'ıstanbul';
      else Result := '';
    end;
    Exit;
  end;
  case ARow of
    0: Result := 'Alpha';
    1: Result := 'Beta';
    2: Result := 'Alpine';
    else Result := '';
  end;
end;

procedure TestNavigation;
var
  LData: TNavigationData;
  LColumns: Th5uGridColumns;
  LSelection: Th5uGridSelection;
  LNav, LOther: Th5uGridNavigation;
  LAction: Th5uNavigationAction;
  LCell: Th5uCellAddress;
  LRange: Th5uCellRange;
  LRow: Int64;
  LColumn: Integer;
begin
  LData := TNavigationData.Create;
  LColumns := Th5uGridColumns.Create(nil);
  LSelection := Th5uGridSelection.Create;
  try
    LColumns.Add.Id := 'a';
    LColumns.Add.Id := 'b';
    LNav := Default(Th5uGridNavigation);
    LOther := Default(Th5uGridNavigation);
    Check(LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkF2, [],
      LAction), 'F2 not handled');
    Check((LAction.Kind = Th5uNavigationActionKind.Focus) and LAction.EditAfterFocus
      and not LAction.AutomaticEdit, 'F2 initial focus and manual edit');
    Check(h5uPlanCellFocus(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, 0, 0, False, LCell, LRange), 'focus plan');
    LSelection.SetFocus(LCell, True);
    LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkNext, [ssShift,
      ssCtrl], LAction);
    Check((LAction.Cell.RowIndex = 3) and LAction.Extend and LAction.Add, 'page navigation and additive extension');
    LNav.SelectHeaderRange(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, Th5uSelectionKind.Columns, -1, 0, []);
    LNav.Navigate(LColumns, LSelection, 10, {$IFDEF FPC}@{$ENDIF}LData.RowKey, {$IFDEF FPC}@{$ENDIF}LData.Extent, 45, vkRight, [ssShift], LAction);
    Check((LAction.Kind = Th5uNavigationActionKind.Header) and (LAction.Cell.ColumnIndex = 1), 'header navigation action');
    Check(not LOther.HeaderSelectionActive, 'navigation state shared between grids');
    LNav.Cancel(LSelection);
    Check(not LNav.HeaderSelectionActive, 'cancel did not reset header selection');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'a', 100, LRow,
      LColumn) and (LRow = 2), 'new search must start after focused row');
    h5uPlanCellFocus(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.RowKey, LRow, LColumn, False, LCell, LRange);
    LSelection.SetFocus(LCell, True);
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'l',
      100 + 200 / MSecsPerDay, LRow, LColumn) and (LRow = 2) and (LNav.SearchText = 'al'), 'continued search must include focused row');
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'b',
      100 + 1500 / MSecsPerDay, LRow, LColumn) and (LRow = 1) and (LNav.SearchText = 'b'), 'search timeout and wrap');
    LData.UnicodeText := True;
    LNav.Cancel(LSelection);
    {$IFDEF FPC}
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, 'ä',
      101, LRow, LColumn) and (LRow = 0), 'Unicode case-insensitive search');
    LNav.Cancel(LSelection);
    {$ENDIF}
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, '東',
      101, LRow, LColumn) and (LRow = 1), 'whole UTF-8 search character');
    h5uPlanCellFocus(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.RowKey, LRow, LColumn, False, LCell, LRange);
    LSelection.SetFocus(LCell, True);
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, '京',
      101 + 200 / MSecsPerDay, LRow, LColumn) and (LRow = 1) and (LNav.SearchText = '東京'), 'continued UTF-8 search');
    {$IFDEF FPC}
    LNav.Cancel(LSelection);
    Check(LNav.SearchCharacter(LColumns, LSelection, 3, @LData.Prepare, @LData.Text, 'I', 102, LRow, LColumn) and (LRow
      = 2), 'Unicode prefix comparison must not use UTF-8 byte lengths');
    {$ENDIF}
    LNav.Cancel(LSelection);
    Check(not LNav.SearchCharacter(LColumns, LSelection, 3, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Text, '',
      102, LRow, LColumn) and (LNav.SearchText = ''), 'empty search input');
    Writeln('PASS: common navigation, page distance, header extension, independent state and search timeout');
  finally
    LSelection.Free;
    LColumns.Free;
    LData.Free;
  end;
end;

type
  TViewData = class
    Controller: Th5uMemoryController;
    Events: Integer;
    function GetController: Th5uCustomDataController;
    procedure GroupChanged(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext);
  end;

function TViewData.GetController: Th5uCustomDataController;
begin
  Result := Controller;
end;

procedure TViewData.GroupChanged(Sender: TObject; const AContext: Th5uAdjacentGroupStateChangedContext);
begin
  Check((Sender = Self) and (AContext.Grid = Self) and (AContext.DataController = Controller), 'group event owner/context');
  Inc(Events);
end;

procedure TestIndependentViews;
var
  LData: TViewData;
  LColumns: Th5uGridColumns;
  LTree: Th5uTreeOptions;
  LGroups: Th5uAdjacentGroupFoldingOptions;
  LView, LOther: Th5uGridView;
  LInfo: Th5uAdjacentGroupRowInfo;
  LChanges: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uAdjacentGroupRowInfo>;
  LLevel, LClosed: Integer;
begin
  LData := TViewData.Create;
  LData.Controller := Th5uMemoryController.Create(nil);
  LColumns := Th5uGridColumns.Create(nil);
  LTree := Th5uTreeOptions.Create;
  LGroups := Th5uAdjacentGroupFoldingOptions.Create;
  LView := nil;
  LOther := nil;
  try
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('B'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('B'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(1)]);
    LData.Controller.AppendValues(['group', 'level'], [TValue.{$IFDEF FPC}specialize {$ENDIF}From<string>('A'),
      TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0)]);
    LGroups.Enabled := True;
    LGroups.IdColumnId := 'group';
    LGroups.InitialState := Th5uAdjacentGroupInitialState.Expanded;
    LTree.Enabled := True;
    LTree.LevelColumnId := 'level';
    LView := Th5uGridView.Create(LData, LColumns, LTree, LGroups, {$IFDEF FPC}@{$ENDIF}LData.GetController);
    LOther := Th5uGridView.Create(LData, LColumns, LTree, LGroups, {$IFDEF FPC}@{$ENDIF}LData.GetController);
    LView.OnAdjacentGroupStateChanged := {$IFDEF FPC}@{$ENDIF}LData.GroupChanged;
    Check((LView.GetViewRowCount = 5) and (LOther.GetViewRowCount = 5), 'initial view count');
    Check(LView.ChangeAdjacentGroup(0, False, True, LInfo), 'collapse first run');
    LView.DoAdjacentGroupStateChanged(LInfo);
    Check((LData.Events = 1) and (LView.GetViewRowCount = 4) and (LOther.GetViewRowCount = 5), 'per-view folding and event');
    Check((LView.GetViewSourceRowIndex(1) = 2) and (LView.GetViewRowKey(1) = LData.Controller.GetRowKey(2)), 'collapsed row/source mapping');
    Check(LView.GetViewValue(1, 'group').AsString = 'B', 'view value mapping');
    Check(LView.CanEditViewValue(1, 'level'), 'view edit permission');
    LView.SetViewValue(1, 'level', TValue.{$IFDEF FPC}specialize {$ENDIF}From<Integer>(0));
    Check(LView.GetTreeBranchEndInfo(2, LView.GetViewRowKey(2), LLevel, LClosed) and (LLevel = 1) and (LClosed
      = 1), 'tree branch closes at next visible row');
    Check(not LView.IsViewRowAvailable(4), 'folded look-ahead passed end');
    LChanges := LView.ChangeAllAdjacentGroups(True);
    Check((Length(LChanges) = 1) and (LView.GetViewRowCount = 3), 'collapse only remaining foldable run');
    LChanges := LView.ChangeAllAdjacentGroups(False);
    Check((Length(LChanges) = 2) and (LView.GetViewRowCount = 5), 'expand independent repeated IDs');
    LData.Controller.Clear;
    LView.InvalidateAdjacentGroupMap(True);
    Check(LView.GetViewRowCount = 0, 'empty data after invalidation');
    Writeln('PASS: common independent views, repeated group IDs, row mapping, tree closure and event owner');
  finally
    LOther.Free;
    LView.Free;
    LGroups.Free;
    LTree.Free;
    LColumns.Free;
    LData.Controller.Free;
    LData.Free;
  end;
end;

type
  TMetricData = class
    Measures: Integer;
    Forced: Boolean;
    ForceHeight: Single;
    Cache: Boolean;
    ExtentValue: Single;
    Prepared: Int64;
    Extents: Integer;
    function Measure(ARow: Int64; AColumn: Th5uGridColumn): Single;
    procedure Adjust(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean);
    function Extent(ARow: Int64; AAllowMeasure: Boolean): Single;
    procedure Prepare(AFirst, ACount: Int64);
  end;

function TMetricData.Measure(ARow: Int64; AColumn: Th5uGridColumn): Single;
begin
  Inc(Measures);
  Result := StrToInt(AColumn.Caption);
end;

procedure TMetricData.Adjust(ARow: Int64; const AKey: Th5uRowKey; AEstimated: Boolean; var AHeight: Single; var ACacheResult: Boolean);
begin
  if Forced then AHeight := ForceHeight;
  ACacheResult := Cache;
end;

function TMetricData.Extent(ARow: Int64; AAllowMeasure: Boolean): Single;
begin
  Inc(Extents);
  Result := ExtentValue;
end;

procedure TMetricData.Prepare(AFirst, ACount: Int64);
begin
  Prepared := ACount;
end;

procedure TestRowMetrics;
const
  LargeCount: Int64 = 9007199254740993;
var
  LData: TMetricData;
  LColumns: Th5uGridColumns;
  LOptions: Th5uRowHeightOptions;
  LMetrics: Th5uGridRowMetrics;
  LTotal: Th5uTotalRowHeight;
  LKey: Th5uRowKey;
  LBefore, LTop: Integer;
  LFloatTop: Single;
begin
  LData := TMetricData.Create;
  LColumns := Th5uGridColumns.Create(nil);
  LOptions := Th5uRowHeightOptions.Create;
  LMetrics := Th5uGridRowMetrics.Create;
  try
    LData.Cache := True;
    LColumns.Add.Caption := '40';
    LColumns[0].AutoHeight := True;
    LColumns.Add.Caption := '80';
    LColumns.Add.Caption := '100';
    LColumns[2].Visible := False;
    LOptions.Mode := Th5uRowHeightMode.Automatic;
    LOptions.MinHeight := 1;
    LOptions.MaxHeight := 100;
    LOptions.EstimatedHeight := 17;
    LKey := Th5uRowKey.FromString('metric-row');
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 40,
      'explicit height contributors');
    LBefore := LData.Measures;
    Check(LMetrics.GetHeight(LOptions, LColumns, 3, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 40,
      'cache follows row key');
    Check(LData.Measures = LBefore, 'height cache not reused');
    LOptions.MeasureScope := Th5uAutoHeightMeasureScope.AllVisibleColumns;
    LMetrics.Clear;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 80,
      'all visible contributors and hidden exclusion');
    LMetrics.Remove(LKey.ToString);
    LData.Cache := False;
    LData.Forced := True;
    LData.ForceHeight := 0;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 1,
      'event minimum height');
    LData.ForceHeight := 12.5;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True, {$IFDEF FPC}@{$ENDIF}LData.Measure,
      {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 12.5, 'fractional event height and cache opt-out');
    LData.Forced := False;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, False, {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 17,
      'estimated height');
    LData.Cache := True;
    LMetrics.Clear;
    LBefore := LData.Measures;
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, False,
      {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 17,
      'an estimate must not become a measured cache entry');
    Check(LMetrics.GetHeight(LOptions, LColumns, 0, LKey, True,
      {$IFDEF FPC}@{$ENDIF}LData.Measure, {$IFDEF FPC}@{$ENDIF}LData.Adjust) = 80,
      'visible row must be measured after an estimated lookup');
    Check(LData.Measures > LBefore, 'estimate suppressed later measurement');
    LData.ExtentValue := 10.25;
    LTotal := h5uTotalRowHeight(LOptions, 3001, 0, True, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check((LData.Prepared = 3001) and SameValue(LTotal.AsFloat, 3001 * 10.25), 'shared exact measurement threshold and fractional sum');
    LTotal := h5uTotalRowHeight(LOptions, h5uExactRowHeightLimit + 1, 0, True, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check(LTotal.Whole = (h5uExactRowHeightLimit + 1) * LOptions.EstimatedHeight, 'large automatic-height estimate');
    LOptions.Mode := Th5uRowHeightMode.Fixed;
    LTotal := h5uTotalRowHeight(LOptions, LargeCount, 0, False, {$IFDEF FPC}@{$ENDIF}LData.Prepare, {$IFDEF FPC}@{$ENDIF}LData.Extent);
    Check(LTotal.Whole = LargeCount * Round(LOptions.FixedHeight), 'Int64 total lost precision above 2^53');
    LData.ExtentValue := 20;
    Check((h5uFindFirstVisibleRow(5, Int64(40), 100, {$IFDEF FPC}@{$ENDIF}LData.Extent, LTop) = 2) and (LTop = 100), 'integer row boundary');
    LData.ExtentValue := 20.25;
    Check((h5uFindFirstVisibleRow(5, 40.75, 100.0, {$IFDEF FPC}@{$ENDIF}LData.Extent, LFloatTop) = 2) and SameValue(LFloatTop, 99.75),
      'fractional row offset');
    Check((h5uFindFirstVisibleRow(5, -1.0, 100.0, {$IFDEF FPC}@{$ENDIF}LData.Extent, LFloatTop) = 0) and (LFloatTop = 100), 'negative offset clamp');
    Writeln('PASS: common row metrics, measurement scope, cache, override minimum, fractions and large Int64 totals');
  finally
    LMetrics.Free;
    LOptions.Free;
    LColumns.Free;
    LData.Free;
  end;
end;

procedure TestIndexedRowMetrics;
const
  RowCount: Int64 = 3000000;
  DeepRow: Int64 = 2999990;
  LargeCount: Int64 = 9007199254740993;
var
  Metrics: Th5uGridRowMetrics;
  Options: Th5uRowHeightOptions;
  Columns: Th5uGridColumns;
  Data: TMetricData;
  Total, Top: Th5uTotalRowHeight;
  FloatTop: Single;
  ExpectedTop, Delta, PrefixDelta: Double;
  IntegerTop, I, Before: Integer;
  Key: Th5uRowKey;
begin
  Metrics := Th5uGridRowMetrics.Create;
  Options := Th5uRowHeightOptions.Create;
  Columns := Th5uGridColumns.Create(nil);
  Data := TMetricData.Create;
  try
    Options.Mode := Th5uRowHeightMode.Automatic;
    Options.EstimatedHeight := 17;
    Data.ExtentValue := 20.25;
    Metrics.Configure(Options, 8, 3, True,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Total := Metrics.Total(False);
    Check((Total.Whole = 160) and (Data.Extents = 0), 'provisional totals must not measure');
    Total := Metrics.Total;
    Check(SameValue(Total.AsFloat, 162) and (Data.Extents = 8) and (Data.Prepared = 8),
      'small lists retain exact fractional row extents');
    Check((Metrics.FindFirstVisibleRow(40.75, 100.0, FloatTop) = 2)
      and SameValue(FloatTop, 99.75), 'indexed fractional boundary');
    Top := Metrics.RowTop(7);
    Total := Metrics.Total;
    Check(SameValue(Top.AsFloat, 141.75) and (Data.Extents = 8),
      'exact extent callbacks must be reused across positioning and totals');
    Metrics.InvalidateRow(3);
    Total := Metrics.Total;
    Check((Data.Extents = 16) and SameValue(Total.AsFloat, 162), 'invalidated exact extents are recomputed');

    Metrics.Configure(Options, RowCount, 3, True,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Before := Data.Extents;
    Total := Metrics.Total;
    Check((Total.Whole = RowCount * 20) and (Metrics.ExtentCount = 0),
      'large lists begin with a sparse uniform estimate');
    for I := 0 to 99 do
    begin
      Check((Metrics.FindFirstVisibleRow(DeepRow * 20.0 + 7.5, 100.0, FloatTop) = DeepRow)
        and SameValue(FloatTop, 92.5), 'deep lookup must locate a uniform gap directly');
      Top := Metrics.RowTop(DeepRow);
      Check(Top.Whole = DeepRow * 20, 'deep row top must use the shared index');
    end;
    Check((Data.Extents = Before) and (Metrics.ExtentCount = 0),
      'three million unvisited rows must cause no callbacks or extent allocations');
    Metrics.RecordExtent(0, 25.5);
    Metrics.RecordExtent(10000, 15.25);
    Metrics.RecordExtent(DeepRow - 2, 33.25);
    Metrics.RecordExtent(DeepRow, 30.5);
    Top := Metrics.RowTop(DeepRow);
    Check(SameValue(Top.AsFloat, DeepRow * 20.0 + 14), 'positive and negative sparse deltas accumulate');
    Check((Metrics.FindFirstVisibleRow(Top.AsFloat + 30.25, 100.0, FloatTop) = DeepRow)
      and SameValue(FloatTop, 69.75), 'measured row extent controls hit testing');
    Check((Metrics.FindFirstVisibleRow(Top.AsFloat + 30.5, 100.0, FloatTop) = DeepRow + 1)
      and SameValue(FloatTop, 100), 'measured row end belongs to the following row');
    Total := Metrics.Total;
    Check(SameValue(Total.AsFloat, RowCount * 20.0 + 24.5) and (Metrics.ExtentCount = 4),
      'total includes only the four known deviations');
    Metrics.RecordExtent(10000, 20);
    Check(Metrics.ExtentCount = 3, 'returning to the estimate removes a sparse node');

    Metrics.InvalidateExtents;
    for I := 0 to 4095 do
      Metrics.RecordExtent(Int64(I) * 701, 20 + ((I mod 7) - 3) * 0.25);
    PrefixDelta := 0;
    for I := 0 to 4095 do
    begin
      Delta := ((I mod 7) - 3) * 0.25;
      ExpectedTop := Int64(I) * 701 * 20.0 + PrefixDelta;
      Top := Metrics.RowTop(Int64(I) * 701);
      Check(SameValue(Top.AsFloat, ExpectedTop), 'sorted sparse insertion preserves prefix sums');
      Check(Metrics.FindFirstVisibleRow(ExpectedTop + 1, 0.0, FloatTop) = Int64(I) * 701,
        'balanced sparse search agrees with measured prefix offsets');
      PrefixDelta := PrefixDelta + Delta;
    end;
    for I := 0 to 2047 do
      Metrics.InvalidateRow(Int64(I) * 2 * 701);
    PrefixDelta := 0;
    for I := 0 to 4095 do
    begin
      Top := Metrics.RowTop(Int64(I) * 701);
      Check(SameValue(Top.AsFloat, Int64(I) * 701 * 20.0 + PrefixDelta),
        'sparse removal preserves remaining prefix sums');
      if Odd(I) then
        PrefixDelta := PrefixDelta + ((I mod 7) - 3) * 0.25;
    end;
    Check(Data.Extents = Before, 'sparse lookup cost must not invoke skipped-row callbacks');

    Options.Mode := Th5uRowHeightMode.Fixed;
    Metrics.Configure(Options, LargeCount, 0, False,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Total := Metrics.Total;
    Check(Total.Whole = LargeCount * Round(Options.FixedHeight), 'indexed total preserves Int64 above 2^53');
    Top := Metrics.RowTop(LargeCount - 2);
    Check(Top.Whole = (LargeCount - 2) * Round(Options.FixedHeight), 'indexed row top preserves Int64 above 2^53');
    Check((Metrics.FindFirstVisibleRow(Top.Whole + 3, 100, IntegerTop) = LargeCount - 2)
      and (IntegerTop = 97), 'integer offset lookup must not pass through floating-point row numbers');

    Options.Mode := Th5uRowHeightMode.Automatic;
    Options.MinHeight := 1;
    Columns.Add.Caption := '40';
    Columns[0].AutoHeight := True;
    Data.Cache := True;
    Metrics.CheckColumnWidths(Columns);
    Metrics.Configure(Options, RowCount, 3, True,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Key := Th5uRowKey.FromString('reordered-row');
    Metrics.GetHeight(Options, Columns, 100, Key, True,
      {$IFDEF FPC}@{$ENDIF}Data.Measure, {$IFDEF FPC}@{$ENDIF}Data.Adjust);
    Metrics.RecordExtent(100, 43);
    Before := Data.Measures;
    Metrics.InvalidateExtents;
    Metrics.GetHeight(Options, Columns, DeepRow, Key, True,
      {$IFDEF FPC}@{$ENDIF}Data.Measure, {$IFDEF FPC}@{$ENDIF}Data.Adjust);
    Metrics.RecordExtent(DeepRow, 43);
    Check(Data.Measures = Before, 'reordered rows retain their keyed measured height');
    Metrics.Remove(Key.ToString);
    Check(Metrics.ExtentCount = 0, 'key invalidation removes its current view-row extent');
    Metrics.GetHeight(Options, Columns, DeepRow, Key, True,
      {$IFDEF FPC}@{$ENDIF}Data.Measure, {$IFDEF FPC}@{$ENDIF}Data.Adjust);
    Check(Data.Measures > Before, 'key invalidation permits remeasurement');
    Before := Data.Measures;
    Check(not Metrics.CheckColumnWidths(Columns), 'unchanged widths retain measured cache');
    Columns[0].SetLayoutWidth(Columns[0].LayoutWidth + 25);
    Check(Metrics.CheckColumnWidths(Columns), 'changed actual width invalidates measured cache');
    Metrics.GetHeight(Options, Columns, DeepRow, Key, True,
      {$IFDEF FPC}@{$ENDIF}Data.Measure, {$IFDEF FPC}@{$ENDIF}Data.Adjust);
    Check(Data.Measures > Before, 'actual width change causes remeasurement');
    Options.Mode := Th5uRowHeightMode.Fixed;
    Options.FixedHeight := 20.25;
    Metrics.Configure(Options, RowCount, 0.5, False,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Total := Metrics.Total;
    Check((Total.Whole = 62250000) and (Total.Fraction = 0), 'three million fractional Single row extents retain exact total');
    Top := Metrics.RowTop(DeepRow);
    Check((Metrics.FindFirstVisibleRow(Top.AsFloat + 0.75, 100, FloatTop) = DeepRow)
      and (FloatTop = 99.25), 'fractional Single baseline retains deep viewport precision');
    Options.FixedHeight := 24.25;
    Metrics.Configure(Options, LargeCount, 0, False,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Total := Metrics.Total;
    Check((Total.Whole = 218424581927469080) and (Total.Fraction = 0.25),
      'Single fixed heights retain exact fractional totals above 2^53 rows');
    Metrics.PixelAligned := True;
    Options.FixedHeight := 20.5;
    Metrics.Configure(Options, RowCount, 0.5, False,
      {$IFDEF FPC}@{$ENDIF}Data.Prepare, {$IFDEF FPC}@{$ENDIF}Data.Extent);
    Check(Metrics.Total.Whole = 60000000, 'pixel-aligned metrics quantize local height and spacing once');
    Writeln('PASS: sparse three-million-row offsets, bounded callbacks, AVL updates, exact small lists, keyed invalidation and Int64');
  finally
    Data.Free;
    Columns.Free;
    Options.Free;
    Metrics.Free;
  end;
end;

procedure TestColumnLayout;
var
  LColumns: Th5uGridColumns;
  LLayout: {$IFDEF FPC}specialize {$ENDIF}TArray<Th5uColumnLayoutInfo>;
  LLeft, LRight: Single;
begin
  LColumns := Th5uGridColumns.Create(nil);
  try
    LColumns.Add.Width := 50;
    LColumns[0].FixedKind := Th5uFixedKind.Left;
    LColumns[0].RightSpacing := 3;
    LColumns.Add.Width := 100;
    LColumns.Add.Width := 40;
    LColumns[2].FixedKind := Th5uFixedKind.Right;
    LColumns[2].RightSpacing := 0;
    LLayout := h5uBuildColumnLayout(LColumns, 1, 0, 200, 10, 20, True);
    Check((LLayout[0].Left = 10) and (LLayout[1].Left = 43) and (LLayout[2].Left = 160), 'fixed/scrollable column positions');
    LLeft := 0; LRight := 200;
    h5uColumnViewport(LColumns, LColumns[1], 1, 10, LLeft, LRight);
    Check((LLeft = 63) and (LRight = 160), 'scrollable viewport between fixed columns');
    LLayout := h5uBuildColumnLayout(LColumns, 1, 0, 200, 10, 20.25, True);
    Check(LLayout[1].Left = 42.75, 'fractional horizontal offset');
    LLayout := h5uBuildColumnLayout(LColumns, 1, 1048576.25, 1048776.25, 10, 20, True);
    Check(LLayout[0].Left = 1048586.25, 'Single layout preserves fractional positions within its geometry range');
    Check(h5uRevealOffset(50, 40, 20, 100) = 40, 'reveal before viewport');
    Check(h5uRevealOffset(50, 140, 20, 100) = 60, 'reveal after viewport');
    Writeln('PASS: common column layout, fixed boundaries, custom spacing, fractional coordinates and pixel precision');
  finally
    LColumns.Free;
  end;
end;

procedure TestControllerLinkLifetime;
var
  LController, LReplacement: Th5uMemoryController;
  LFirst, LSecond: Th5uDataControllerLink;
begin
  LController := Th5uMemoryController.Create(nil);
  LReplacement := Th5uMemoryController.Create(nil);
  LFirst := Th5uDataControllerLink.Create;
  LSecond := Th5uDataControllerLink.Create;
  try
    LFirst.Controller := LController;
    LSecond.Controller := LController;
    FreeAndNil(LController);
    Check((LFirst.Controller = nil) and (LSecond.Controller = nil), 'destroyed controller must detach every surviving link');
    LFirst.Controller := LReplacement;
    LSecond.Controller := LReplacement;
    FreeAndNil(LFirst);
    LReplacement.Invalidate;
    FreeAndNil(LReplacement);
    Check(LSecond.Controller = nil, 'links remain reusable and may be freed before or after their controller');
    Writeln('PASS: common controller destruction, multiple surviving links and link reuse');
  finally
    LFirst.Free;
    LSecond.Free;
    LController.Free;
    LReplacement.Free;
  end;
end;

procedure TestValueConversion;
var
  LType: Th5uColumnDataType;
  LValue: TValue;
  LFailed: Boolean;
begin
  Check(h5uParseEditorValue(Th5uColumnDataType.Integer, '9223372036854775807').AsInt64 = High(Int64), 'Int64 parsing');
  Check(SameValue(h5uParseEditorValue(Th5uColumnDataType.Float, FloatToStr(1.5)).AsExtended, 1.5), 'locale float parsing');
  Check(h5uParseEditorValue(Th5uColumnDataType.Currency, CurrToStr(12.25)).{$IFDEF FPC}specialize {$ENDIF}AsType<Currency> = 12.25,
    'currency parsing');
  Check(h5uParseEditorValue(Th5uColumnDataType.Text, ' abc ').AsString = ' abc ', 'text whitespace preservation');
  for LType
    in [Th5uColumnDataType.Integer, Th5uColumnDataType.Float, Th5uColumnDataType.Currency, Th5uColumnDataType.Date, Th5uColumnDataType.DateTime,
    Th5uColumnDataType.Time] do
  begin
    LFailed := False;
    try
      LValue := h5uParseEditorValue(LType, 'invalid-input');
    except
      on E: EConvertError do
      begin
        LFailed := True;
        Check(Pos('"invalid-input"', E.Message) > 0, 'conversion error must include rejected text');
      end;
    end;
    Check(LFailed, 'invalid input was accepted');
  end;
  Writeln('PASS: common value conversion, locale, Int64 bounds and consistent rejected-input errors');
end;

begin
  try
    TestResizeBoundaries;
    TestNavigation;
    TestIndependentViews;
    TestRowMetrics;
    TestIndexedRowMetrics;
    TestColumnLayout;
    TestColumnWidths;
    TestUnifiedColumnWidths;
    TestInheritedWidthDefaults;
    TestNormalizedGroupMaxima;
    TestSingleWidthGeometry;
    TestControllerLinkLifetime;
    TestValueConversion;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
