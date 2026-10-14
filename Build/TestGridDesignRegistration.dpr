program TestGridDesignRegistration;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.TypInfo,
  DesignIntf, DesignEditors, ColnEdit,
  {$IFDEF TEST_FMX}
  Fmx.h5u.Grid, Fmx.h5u.Grid.Design;
  {$ELSE}
  Winapi.Windows, Winapi.Messages, System.Types, Vcl.Forms, Vcl.ExtCtrls,
  h5u.Grid.Design, h5u.Grid.Moving,
  Vcl.h5u.Grid, Vcl.h5u.Grid.Design;
  {$ENDIF}

type
  TPersistentAccess = class(TPersistent);
  TRegisterComponentsHook = procedure(const Page: string; const ComponentClasses: array of TComponentClass);
  TDesignFixture = class(TComponent)
  private
    FOptions: TPersistent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MarkDesigning;
  published
    property Options: TPersistent read FOptions;
  end;
  TPropertyProbe = class
  public
    Names: TStringList;
    SelectedColumn: ThiiGridColumn;
    SelectionCalls: Integer;
    CollectionProperty: IProperty;
    procedure Collect(const Prop: IProperty);
    procedure SelectColumn(AColumn: ThiiGridColumn);
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
  if Prop.GetName = 'Cells' then CollectionProperty := Prop;
end;

procedure TDesignFixture.MarkDesigning;
begin
  SetDesigning(True, True);
end;

procedure TPropertyProbe.SelectColumn(AColumn: ThiiGridColumn);
begin
  SelectedColumn := AColumn;
  Inc(SelectionCalls);
end;

{$IFNDEF TEST_FMX}
procedure CheckNativeDesignerClickObserver;
var
  Fixture: TDesignFixture;
  Columns: ThiiGridColumns;
  Column: ThiiGridColumn;
  Probe: TPropertyProbe;
  Origin: TPoint;

  procedure MouseMessage(AMessage: Cardinal; const APoint: TPoint);
  var
    Msg: TMsg;
    Handled: Boolean;
  begin
    Msg := Default(TMsg);
    Msg.message := AMessage;
    Msg.pt := APoint;
    Handled := False;
    Check(Assigned(Application.OnMessage), 'Designer click observer must be installed');
    Application.OnMessage(Msg, Handled);
    Check(not Handled, 'Designer observation must not consume native input');
  end;

  procedure CompleteClick;
  var
    Observer: TComponent;
    Timer: TTimer;
  begin
    Check(Fixture.ComponentCount = 1, 'Click observer lifetime belongs to the grid');
    Observer := Fixture.Components[0];
    Timer := TTimer(Observer.Components[0]);
    Timer.OnTimer(Timer);
    Check(Fixture.ComponentCount = 0, 'Completed observer is released');
  end;

begin
  Fixture := TDesignFixture.Create(nil);
  Columns := ThiiGridColumns.Create(Fixture);
  Probe := TPropertyProbe.Create;
  try
    Fixture.MarkDesigning;
    Column := Columns.Add;
    GetCursorPos(Origin);
    MouseMessage(WM_LBUTTONDOWN, Origin);
    h5uObserveDesignColumnClick(Fixture, Column, Probe.SelectColumn);
    MouseMessage(WM_LBUTTONUP, Origin);
    CompleteClick;
    Check((Probe.SelectionCalls = 1) and (Probe.SelectedColumn = Column), 'Native data-cell click selects its original collection item');
    MouseMessage(WM_LBUTTONDOWN, Origin);
    h5uObserveDesignColumnClick(Fixture, Column, Probe.SelectColumn);
    MouseMessage(WM_MOUSEMOVE, Point(Origin.X + 10, Origin.Y));
    MouseMessage(WM_LBUTTONUP, Origin);
    CompleteClick;
    Check(Probe.SelectionCalls = 1, 'Native component drag returning to its origin must not select a column');
    MouseMessage(WM_LBUTTONDOWN, Origin);
    MouseMessage(WM_MOUSEMOVE, Point(Origin.X + 10, Origin.Y));
    h5uObserveDesignColumnClick(Fixture, Column, Probe.SelectColumn);
    Check(Fixture.ComponentCount = 0, 'An already active component drag does not become a column click');
    MouseMessage(WM_LBUTTONUP, Origin);
    MouseMessage(WM_LBUTTONDOWN, Origin);
    h5uObserveDesignColumnClick(Fixture, Column, Probe.SelectColumn);
    Column.Free;
    MouseMessage(WM_LBUTTONUP, Origin);
    CompleteClick;
    Check(Probe.SelectionCalls = 1, 'Deleted collection item is not selected after native input');
    Column := Columns.Add;
    MouseMessage(WM_LBUTTONDOWN, Origin);
    h5uObserveDesignColumnClick(Fixture, Column, Probe.SelectColumn);
    Fixture.Free;
    Fixture := nil;
    MouseMessage(WM_MOUSEMOVE, Origin);
    MouseMessage(WM_LBUTTONUP, Origin);
    Check(Probe.SelectionCalls = 1, 'Grid destruction releases pending observer callbacks');
    Writeln('PASS: native designer clicks, drag pass-through, deleted items and observer lifetime');
  finally
    Columns.Free;
    Fixture.Free;
    Probe.Free;
  end;
end;
{$ENDIF}

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
    Check(TPersistentAccess(Grid.Header.Layout).GetOwner = Grid.Header, 'Header layout must expose its persistent owner');
    Check(TPersistentAccess(Grid.Header).GetOwner = Grid, 'Header options must lead back to the grid');
    Selection := CreateSelectionList;
    Selection.Add(Grid.Header.Layout);
    Probe.Names.Clear;
    GetComponentProperties(Selection, [tkClass], nil, Probe.Collect);
    Check(Assigned(Probe.CollectionProperty), 'Nested Cells property must have an SDK property editor');
    Check(Probe.CollectionProperty is TCollectionProperty, 'Nested Cells must use the standard collection editor');
    Check(paDialog in Probe.CollectionProperty.GetAttributes, 'Nested Cells must offer the collection dialog');
    Writeln('PASS: nested header collection SDK editor and complete owner chain');
    Writeln('PASS: real SDK property lookup, unrelated class properties and visible grouped grid options');
  finally
    Selection := nil;
    Probe.CollectionProperty := nil;
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
      {$IFNDEF TEST_FMX}
      CheckNativeDesignerClickObserver;
      {$ENDIF}
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
