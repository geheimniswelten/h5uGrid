program h5uGridVclClientDataSetDemo;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  h5u.Grid.Types in '..\..\..\Source\Common\h5u.Grid.Types.pas',
  h5u.Grid.Factory in '..\..\..\Source\Common\h5u.Grid.Factory.pas',
  h5u.Grid.Columns in '..\..\..\Source\Common\h5u.Grid.Columns.pas',
  h5u.Grid.Options in '..\..\..\Source\Common\h5u.Grid.Options.pas',
  h5u.Grid.Selection in '..\..\..\Source\Common\h5u.Grid.Selection.pas',
  h5u.Grid.Data.Core in '..\..\..\Source\Common\h5u.Grid.Data.Core.pas',
  h5u.Grid.Data.DataSet in '..\..\..\Source\Common\h5u.Grid.Data.DataSet.pas',
  h5u.Grid.Data.Objects in '..\..\..\Source\Common\h5u.Grid.Data.Objects.pas',
  h5u.Grid.Data.Virtual in '..\..\..\Source\Common\h5u.Grid.Data.Virtual.pas',
  h5u.Grid.Data.Memory in '..\..\..\Source\Common\h5u.Grid.Data.Memory.pas',
  h5u.Grid.SampleData in '..\..\..\Source\Common\h5u.Grid.SampleData.pas',
  Vcl.h5u.Grid.Styles in '..\..\..\Source\Vcl\Vcl.h5u.Grid.Styles.pas',
  Vcl.h5u.Grid.Editors in '..\..\..\Source\Vcl\Vcl.h5u.Grid.Editors.pas',
  Vcl.h5u.Grid in '..\..\..\Source\Vcl\Vcl.h5u.Grid.pas';
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
