program TestPropertyEditorPublicApi;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.h5u.PropertyEditor;
  {$ELSE}
  Vcl.Forms, Vcl.h5u.PropertyEditor;
  {$ENDIF}

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
