program GridFmxObjectListDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmxListDemoMain in 'FmxListDemoMain.pas' {FmxListDemoForm},
  h5u.Grid.Types in '..\..\..\Source\Common\h5u.Grid.Types.pas',
  h5u.Grid.Factory in '..\..\..\Source\Common\h5u.Grid.Factory.pas',
  h5u.Grid.Columns in '..\..\..\Source\Common\h5u.Grid.Columns.pas',
  h5u.Grid.Options in '..\..\..\Source\Common\h5u.Grid.Options.pas',
  h5u.Grid.Selection in '..\..\..\Source\Common\h5u.Grid.Selection.pas',
  h5u.Grid.Data.Core in '..\..\..\Source\Common\h5u.Grid.Data.Core.pas',
  h5u.Grid.Data.Dataset in '..\..\..\Source\Common\h5u.Grid.Data.Dataset.pas',
  h5u.Grid.Data.Objects in '..\..\..\Source\Common\h5u.Grid.Data.Objects.pas',
  h5u.Grid.Data.Virtual in '..\..\..\Source\Common\h5u.Grid.Data.Virtual.pas',
  h5u.Grid.AdjacentGroups in '..\..\..\Source\Common\h5u.Grid.AdjacentGroups.pas',
  h5u.Grid.Data.Memory in '..\..\..\Source\Common\h5u.Grid.Data.Memory.pas',
  h5u.Grid.SampleData in '..\..\..\Source\Common\h5u.Grid.SampleData.pas',
  Fmx.h5u.Grid.Styles in '..\..\..\Source\FMX\Fmx.h5u.Grid.Styles.pas',
  Fmx.h5u.Grid.Editors in '..\..\..\Source\FMX\Fmx.h5u.Grid.Editors.pas',
  Fmx.h5u.Grid in '..\..\..\Source\FMX\Fmx.h5u.Grid.pas';

begin
  Application.Initialize;
  Application.CreateForm(TFmxListDemoForm, FmxListDemoForm);
  Application.Run;
end.
