program TestDemoFormResources;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  {$IFDEF TEST_FMX}
  Fmx.Forms, Fmx.h5u.Grid,
  FmxDatasetDemoMain, FmxObjectDemoMain, FmxVirtualDemoMain, FmxMegaDemoMain;
  {$ELSE}
  Vcl.Forms, Vcl.h5u.Grid,
  VclDatasetDemoMain, VclObjectDemoMain, VclVirtualDemoMain, VclMegaDemoMain;
  {$ENDIF}

type
  TDemoFormClass = class of TForm;

procedure TestForm(AClass: TDemoFormClass);
var
  Form: TForm;
  Grid: ThiiGrid;
begin
  Form := AClass.Create(nil);
  try
    if Form.Visible then
      raise Exception.Create('Demo form must remain hidden');
    if not (Form.FindComponent('Grid') is ThiiGrid) then
      raise Exception.Create('Demo resource did not resolve ThiiGrid');
    Grid := ThiiGrid(Form.FindComponent('Grid'));
    if (Grid.Columns.Count = 0) or (Grid.DataController = nil) then
      raise Exception.Create('Demo columns or controller reference missing after loading');
    Writeln('PASS: ', AClass.ClassName, ' hidden form resource, ThiiGrid, columns and controller reference');
  finally
    Form.Free;
  end;
end;

begin
  try
    Application.Initialize;
    {$IFDEF TEST_FMX}
    TestForm(TFmxDatasetDemoForm);
    TestForm(TFmxObjectDemoForm);
    TestForm(TFmxVirtualDemoForm);
    TestForm(TFmxMegaDemoForm);
    {$ELSE}
    TestForm(TVclDatasetDemoForm);
    TestForm(TVclObjectDemoForm);
    TestForm(TVclVirtualDemoForm);
    TestForm(TVclMegaDemoForm);
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
