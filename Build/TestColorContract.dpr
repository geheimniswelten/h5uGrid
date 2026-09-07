program TestColorContract;

{$APPTYPE CONSOLE}
{$RANGECHECKS ON}
{$OVERFLOWCHECKS ON}

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.UITypes,
  System.UIConsts,
  Winapi.Windows,
  Vcl.Graphics,
  h5u.Grid.Types,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  Fmx.h5u.Grid.Styles;

type
  TColorStreamFixture = class(TComponent)
  private
    FColumns: Th5uGridColumns;
    FAppearance: Th5uGridAppearanceOptions;
    procedure SetColumns(const AValue: Th5uGridColumns);
    procedure SetAppearance(const AValue: Th5uGridAppearanceOptions);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Columns: Th5uGridColumns read FColumns write SetColumns;
    property Appearance: Th5uGridAppearanceOptions read FAppearance write SetAppearance;
  end;

constructor TColorStreamFixture.Create(AOwner: TComponent);
begin
  inherited;
  FColumns := Th5uGridColumns.Create(Self);
  FAppearance := Th5uGridAppearanceOptions.Create;
end;

destructor TColorStreamFixture.Destroy;
begin
  FAppearance.Free;
  FColumns.Free;
  inherited;
end;

procedure TColorStreamFixture.SetColumns(const AValue: Th5uGridColumns);
begin
  FColumns.Assign(AValue);
end;

procedure TColorStreamFixture.SetAppearance(const AValue: Th5uGridAppearanceOptions);
begin
  FAppearance.Assign(AValue);
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckProperty(AClass: TClass; const AName: string; ADefault: TColor);
var
  LProp: PPropInfo;
begin
  LProp := GetPropInfo(AClass, AName);
  Check(LProp <> nil, AClass.ClassName + '.' + AName + ': missing RTTI');
  Check(LProp.PropType^ = TypeInfo(Vcl.Graphics.TColor), AClass.ClassName + '.' + AName + ': not standard TColor RTTI');
  Check(LProp.Default = ADefault, AClass.ClassName + '.' + AName + ': wrong default');
end;

procedure TestProperties;
var
  LColumns: Th5uGridColumns;
  LColumn: Th5uGridColumn;
  LSpacing: Th5uGridSpacingOptions;
  LAppearance: Th5uGridAppearanceOptions;
  LTree: Th5uTreeBranchEndBandOptions;
  LAdjacent: Th5uAdjacentGroupEndBandOptions;
begin
  CheckProperty(Th5uGridColumn, 'Color', clDefault);
  CheckProperty(Th5uGridSpacingOptions, 'RowSpacingColor', TColorRec.Lightgray);
  CheckProperty(Th5uGridSpacingOptions, 'ColumnSpacingColor', TColorRec.Lightgray);
  CheckProperty(Th5uGridSpacingOptions, 'ContentPaddingColor', TColorRec.Lightgray);
  CheckProperty(Th5uGridAppearanceOptions, 'DefaultCellColor', clDefault);
  CheckProperty(Th5uTreeBranchEndBandOptions, 'Color', clDefault);
  CheckProperty(Th5uAdjacentGroupEndBandOptions, 'Color', clDefault);
  Check(TColorRec.SysDefault = clDefault, 'Default constant');
  Check(TColorRec.SysNone = clNone, 'None constant');
  LColumns := Th5uGridColumns.Create(nil);
  LSpacing := Th5uGridSpacingOptions.Create;
  LAppearance := Th5uGridAppearanceOptions.Create;
  LTree := Th5uTreeBranchEndBandOptions.Create;
  LAdjacent := Th5uAdjacentGroupEndBandOptions.Create;
  try
    LColumn := LColumns.Add;
    Check(LColumn.Color = clDefault, 'Column constructor default');
    Check(LAppearance.DefaultCellColor = clDefault, 'Appearance constructor default');
    Check(LTree.Color = clDefault, 'Tree constructor default');
    Check(LAdjacent.Color = clDefault, 'Adjacent constructor default');
    Check(LSpacing.RowSpacingColor = $00D3D3D3, 'Row spacing constructor default');
    Check(LSpacing.ColumnSpacingColor = $00D3D3D3, 'Column spacing constructor default');
    Check(LSpacing.ContentPaddingColor = $00D3D3D3, 'Padding constructor default');
    SetOrdProp(LColumn, 'Color', Vcl.Graphics.StringToColor('clRed'));
    Check(LColumn.Color = clRed, 'Standard color name assignment');
    SetOrdProp(LColumn, 'Color', Vcl.Graphics.StringToColor('clNone'));
    Check(LColumn.Color = clNone, 'None name assignment');
    SetOrdProp(LColumn, 'Color', clWindow);
    Check(LColumn.Color = clWindow, 'System color must remain symbolic');
  finally
    LAdjacent.Free;
    LTree.Free;
    LAppearance.Free;
    LSpacing.Free;
    LColumns.Free;
  end;
end;

procedure TestFmxColors;
begin
  Check(h5uColorToFmx(clRed) = $FFFF0000, 'Red channel');
  Check(h5uColorToFmx(clBlue) = $FF0000FF, 'Blue channel');
  Check(h5uColorToFmx(clBlack) = $FF000000, 'Black must be opaque');
  Check(h5uColorToFmx(clWhite) = $FFFFFFFF, 'White must not become Default');
  Check(h5uColorToFmx($00FEFFFF) = $FFFFFFFE, 'Near-white must not become None');
  Check(h5uColorToFmx($00362B1F) = $FF1F2B36, 'Asymmetric RGB channels');
  Check(h5uColorToFmx(clNone) = TAlphaColorRec.Null, 'None must be transparent');
  Check(h5uColorToFmx(clDefault) = TAlphaColorRec.Null, 'Default handled by theme fallback');
  Check(AlphaColorToColor(h5uColorToFmx(clWindow)) = TColor(GetSysColor(COLOR_WINDOW)), 'System color resolution');
  Check(AlphaColorToColor(h5uColorToFmx($00FFF4EA)) = $00FFF4EA, 'Demo name color round trip');
  Check(AlphaColorToColor(h5uColorToFmx($00ECF8EA)) = $00ECF8EA, 'Demo active color round trip');
end;

procedure TestColorStreaming;
const
  CFormText = 'object Fixture: TColorStreamFixture'#13#10 + '  Appearance.DefaultCellColor = clWhite'#13#10 + '  Columns = <'#13#10
    + '    item Id = ''name'' Color = 16774378 end'#13#10 + '    item Id = ''active'' Color = 15530218 end'#13#10
    + '    item Id = ''red'' Color = clRed end'#13#10 + '    item Id = ''none'' Color = clNone end'#13#10
    + '    item Id = ''default'' Color = clDefault end'#13#10 + '    item Id = ''window'' Color = clWindow end>'#13#10 + 'end'#13#10;
var
  LText: TStringStream;
  LBinary: TMemoryStream;
  LFixture: TColorStreamFixture;
begin
  System.Classes.RegisterClass(TColorStreamFixture);
  LText := TStringStream.Create(CFormText);
  LBinary := TMemoryStream.Create;
  try
    ObjectTextToBinary(LText, LBinary);
    LBinary.Position := 0;
    LFixture := TColorStreamFixture(LBinary.ReadComponent(nil));
    try
      Check(LFixture.Appearance.DefaultCellColor = clWhite, 'White appearance streaming');
      Check(LFixture.Columns.FindById('name').Color = $00FFF4EA, 'Name demo value streaming');
      Check(LFixture.Columns.FindById('active').Color = $00ECF8EA, 'Active demo value streaming');
      Check(LFixture.Columns.FindById('red').Color = clRed, 'Named color streaming');
      Check(LFixture.Columns.FindById('none').Color = clNone, 'None streaming');
      Check(LFixture.Columns.FindById('default').Color = clDefault, 'Default streaming');
      Check(LFixture.Columns.FindById('window').Color = clWindow, 'System color streaming');
    finally
      LFixture.Free;
    end;
  finally
    LBinary.Free;
    LText.Free;
    System.Classes.UnRegisterClass(TColorStreamFixture);
  end;
end;

begin
  try
    TestProperties;
    TestFmxColors;
    TestColorStreaming;
    Writeln('PASS: TColor RTTI, defaults, symbolic colors, DFM streaming and FMX channel conversion');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
