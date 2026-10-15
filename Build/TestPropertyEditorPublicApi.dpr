program TestPropertyEditorPublicApi;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.h5u.PropertyEditor;
  {$ELSE}
  Vcl.Forms, Vcl.h5u.PropertyEditor;
  {$ENDIF}

type
  TChildOptions = class(TPersistent)
  private
    FEnabled: Boolean;
    FParent: TPersistent;
  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property Parent: TPersistent read FParent write FParent;
  end;

  TGroupedObject = class(TPersistent)
  private
    FChild: TChildOptions;
  public
    destructor Destroy; override;
  published
    property Child: TChildOptions read FChild write FChild;
  end;

destructor TGroupedObject.Destroy;
begin
  FChild.Free;
  inherited;
end;

procedure TestNestedObjects;
var
  Model: ThiiPropertyModel;
  Obj: TGroupedObject;
  Previous: TChildOptions;
begin
  Model := ThiiPropertyModel.Create(nil);
  Obj := TGroupedObject.Create;
  try
    Obj.Child := TChildOptions.Create;
    Obj.Child.Parent := Obj;
    Model.ExpandSubProperties := True;
    Model.RootGroupName := 'Options';
    Model.DataObject := Obj;
    if (Model.Items.Count > 10) or (Model.FindProperty('Child.Enabled') = nil) then
      raise Exception.Create('Nested cyclic objects did not terminate or expand');
    Previous := Obj.Child;
    Obj.Child := nil;
    Previous.Free;
    Model.Refresh;
    if Model.FindProperty('Child.Enabled') <> nil then
      raise Exception.Create('Refresh retained properties of a freed child');
    Obj.Child := TChildOptions.Create;
    Model.Refresh;
    if (Model.FindProperty('Child.Enabled') = nil) or (Model.FindProperty('Child.Enabled').Instance <> Pointer(Obj.Child)) then
      raise Exception.Create('Refresh did not expand/bind a replacement child');
    Writeln('PASS: nested object cycles and replacement lifetime');
  finally
    Model.Free;
    Obj.Free;
  end;
end;

var
  Inspector, Copy: ThiiPropertyEditor;
  Model: ThiiPropertyModel;
  Item: ThiiPropertyItem;
  SortOrder: ThiiPropertySortOrder;
  Events: ThiiPropertyItemChangedEvent;
  Controller: ThiiPropertyListController;
  Stream: TMemoryStream;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

begin
  try
    Application.Initialize;
    TestNestedObjects;
    RegisterClass(ThiiPropertyEditor);
    Inspector := ThiiPropertyEditor.Create(nil);
    Copy := nil;
    Stream := TMemoryStream.Create;
    try
      Check(Inspector.ClassName = 'ThiiPropertyEditor', 'Independent visual component class name');
      Model := Inspector.PropertyEditor;
      Check((Model is ThiiPropertyModel) and (ThiiPropertyModel.ClassName = 'ThiiPropertyModel'), 'Shared model type identity');
      Controller := Inspector.ObjectListController;
      Check(Controller.PropertyEditor = Model, 'Single shared model instance');
      Events := nil;
      Model.OnItemChanged := Events;
      SortOrder := ThiiPropertySortOrder.psoDeclaration;
      Model.SortOrder := SortOrder;
      Model.PublicProperties := True;
      Model.NameMask := 'Caption';
      Inspector.ShowGroups := False;
      Item := Model.FindProperty('missing');
      Check(Item = nil, 'Property model API available through framework unit');
      Stream.WriteComponent(Inspector);
      Stream.Position := 0;
      Copy := ThiiPropertyEditor(Stream.ReadComponent(nil));
      Check(Copy.ClassName = 'ThiiPropertyEditor', 'New property editor class resolves when streamed');
      Check(Copy.PropertyEditor.PublicProperties and (Copy.PropertyEditor.NameMask = 'Caption'), 'Model options round trip');
      Check((Copy.PropertyEditor.SortOrder = SortOrder) and not Copy.ShowGroups, 'Property editor options round trip');
      Check(Copy.Columns.Count = 2, 'Property editor columns are not duplicated');
      Writeln('PASS: single framework property-editor unit, model aliases and streaming');
    finally
      Copy.Free;
      Stream.Free;
      Inspector.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
