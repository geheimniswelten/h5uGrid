program TestGridDesignRegistration;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.TypInfo,
  DesignIntf, DesignEditors,
  {$IFDEF TEST_FMX}
  Fmx.h5u.Grid, Fmx.h5u.Grid.Design;
  {$ELSE}
  Vcl.h5u.Grid, Vcl.h5u.Grid.Design;
  {$ENDIF}

type
  TRegisterComponentsHook = procedure(const Page: string; const ComponentClasses: array of TComponentClass);
  TDesignFixture = class(TComponent)
  private
    FOptions: TPersistent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Options: TPersistent read FOptions;
  end;
  TPropertyProbe = class
  public
    Names: TStringList;
    procedure Collect(const Prop: IProperty);
  end;

var
  SavedPropertyHook: TRegisterPropertyEditorProc;
  SavedComponentsHook: TRegisterComponentsHook;
  HiddenProperties, RegisteredComponents: Integer;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckPropertyRegistration(PropertyType: PTypeInfo; ComponentClass: TClass; const PropertyName: string; EditorClass: TPropertyEditorClass);
var
  Prop: PPropInfo;
begin
  Check(PropertyType <> nil, 'Nil property type would corrupt the designer registry: ' + PropertyName);
  Prop := GetPropInfo(ThiiGrid, PropertyName);
  Check(Prop <> nil, 'Unknown published property: ' + PropertyName);
  Check(PropertyType = Prop^.PropType^, 'Registration type differs from published RTTI: ' + PropertyName);
  Check(ComponentClass = ThiiCustomGrid, 'Legacy hiding must cover the custom grid and its descendants');
  Check(EditorClass = nil, 'Legacy aliases must stay hidden');
  Inc(HiddenProperties);
  // Exercise the real SDK registry as well as validating the callback arguments.
  SavedPropertyHook(PropertyType, ComponentClass, PropertyName, EditorClass);
end;

procedure CheckComponentRegistration(const Page: string; const ComponentClasses: array of TComponentClass);
begin
  Inc(RegisteredComponents, Length(ComponentClasses));
end;

constructor TDesignFixture.Create(AOwner: TComponent);
begin
  inherited;
  FOptions := TPersistent.Create;
end;

destructor TDesignFixture.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TPropertyProbe.Collect(const Prop: IProperty);
begin
  Names.Add(Prop.GetName);
end;

procedure CheckDesignerLookup;
var
  Fixture: TDesignFixture;
  Grid: ThiiGrid;
  Probe: TPropertyProbe;
  Selection: IDesignerSelections;
begin
  Fixture := TDesignFixture.Create(nil);
  Grid := nil;
  Probe := TPropertyProbe.Create;
  Probe.Names := TStringList.Create;
  try
    Selection := CreateSelectionList;
    Selection.Add(Fixture);
    GetComponentProperties(Selection, [tkClass], nil, Probe.Collect);
    Check(Probe.Names.IndexOf('Options') >= 0, 'SDK class-property lookup must work for unrelated components');
    Selection := CreateSelectionList;
    Probe.Names.Clear;
    Grid := ThiiGrid.Create(nil);
    Selection.Add(Grid);
    GetComponentProperties(Selection, [tkClass, tkInteger, tkFloat, tkEnumeration], nil, Probe.Collect);
    Check(Probe.Names.IndexOf('ColumnSizing') >= 0, 'Modern grouped sizing must remain visible');
    Check(Probe.Names.IndexOf('Header') >= 0, 'Modern header options must remain visible');
    Check(Probe.Names.IndexOf('Appearance') >= 0, 'Modern appearance must remain visible');
    Check(Probe.Names.IndexOf('MinWidth') < 0, 'Legacy integer/float alias must stay hidden');
    Check(Probe.Names.IndexOf('HeaderLayout') < 0, 'Legacy class alias must stay hidden');
    Check(Probe.Names.IndexOf('Theme') < 0, 'Legacy enum alias must stay hidden');
    Writeln('PASS: real SDK property lookup, unrelated class properties and visible grouped grid options');
  finally
    Selection := nil;
    Grid.Free;
    Probe.Names.Free;
    Probe.Free;
    Fixture.Free;
  end;
end;

begin
  try
    SavedPropertyHook := DesignIntf.RegisterPropertyEditorProc;
    SavedComponentsHook := System.Classes.RegisterComponentsProc;
    DesignIntf.RegisterPropertyEditorProc := CheckPropertyRegistration;
    System.Classes.RegisterComponentsProc := CheckComponentRegistration;
    try
      {$IFDEF TEST_FMX}
      Fmx.h5u.Grid.Design.Register;
      {$ELSE}
      Vcl.h5u.Grid.Design.Register;
      {$ENDIF}
      Check(HiddenProperties = 11, 'All eleven legacy aliases must be registered');
      Check(RegisteredComponents = 3, 'Grid and inspector components must remain registered');
      CheckDesignerLookup;
    finally
      DesignIntf.RegisterPropertyEditorProc := SavedPropertyHook;
      System.Classes.RegisterComponentsProc := SavedComponentsHook;
    end;
    Writeln('PASS: non-nil matching RTTI types, hidden legacy aliases and registered components');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
