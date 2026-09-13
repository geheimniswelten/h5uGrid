program GridFmxObjectListDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  h5u.Grid.AdjacentGroups in '..\..\..\Source\Common\h5u.Grid.AdjacentGroups.pas',
  h5u.Grid.Columns in '..\..\..\Source\Common\h5u.Grid.Columns.pas',
  h5u.Grid.Editors in '..\..\..\Source\Common\h5u.Grid.Editors.pas',
  h5u.Grid.Factory in '..\..\..\Source\Common\h5u.Grid.Factory.pas',
  h5u.Grid.Layout in '..\..\..\Source\Common\h5u.Grid.Layout.pas',
  h5u.Grid.Moving in '..\..\..\Source\Common\h5u.Grid.Moving.pas',
  h5u.Grid.Navigation in '..\..\..\Source\Common\h5u.Grid.Navigation.pas',
  h5u.Grid.Options in '..\..\..\Source\Common\h5u.Grid.Options.pas',
  h5u.Grid.Resizing in '..\..\..\Source\Common\h5u.Grid.Resizing.pas',
  h5u.Grid.RowMetrics in '..\..\..\Source\Common\h5u.Grid.RowMetrics.pas',
  h5u.Grid.Selection in '..\..\..\Source\Common\h5u.Grid.Selection.pas',
  h5u.Grid.Types in '..\..\..\Source\Common\h5u.Grid.Types.pas',
  h5u.Grid.Values in '..\..\..\Source\Common\h5u.Grid.Values.pas',
  h5u.Grid.View in '..\..\..\Source\Common\h5u.Grid.View.pas',
  h5u.Grid.Data.Core in '..\..\..\Source\Common\h5u.Grid.Data.Core.pas',
  h5u.Grid.Data.Dataset in '..\..\..\Source\Common\h5u.Grid.Data.Dataset.pas',
  h5u.Grid.Data.Memory in '..\..\..\Source\Common\h5u.Grid.Data.Memory.pas',
  h5u.Grid.Data.Objects in '..\..\..\Source\Common\h5u.Grid.Data.Objects.pas',
  h5u.Grid.Data.Virtual in '..\..\..\Source\Common\h5u.Grid.Data.Virtual.pas',
  h5u.Grid.SampleData in '..\..\..\Source\Design\h5u.Grid.SampleData.pas',
  Fmx.h5u.Grid.Styles in '..\..\..\Source\FMX\Fmx.h5u.Grid.Styles.pas',
  Fmx.h5u.Grid.Editors in '..\..\..\Source\FMX\Fmx.h5u.Grid.Editors.pas',
  Fmx.h5u.Grid in '..\..\..\Source\FMX\Fmx.h5u.Grid.pas',
  FmxListDemoMain in 'FmxListDemoMain.pas' {FmxListDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmxListDemoForm, FmxListDemoForm);
  Application.Run;
end.

