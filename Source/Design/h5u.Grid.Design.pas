unit h5u.Grid.Design;

interface

procedure Register;

implementation

uses
  System.Classes,
  Imaging.pngimage,
  DesignIntf,
  ToolsAPI,
  h5u.Grid.Factory,
  h5u.Grid.Data.DataSet,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData;

procedure Register;
var
  Icon: TPngImage;
begin
  RegisterComponents('h5u', [
    Th5uClassFactory,
    Th5uDataSetController,
    Th5uMemoryController,
    Th5uObjectListController,
    Th5uVirtualController,
    Th5uSampleClientDataSet
  ]);

  Icon := TPngImage.Create;
  try
    Icon.LoadFromResourceName(HInstance, 'h5uGridComponent_32x32');
    SplashScreenServices.AddPluginBitmap('h5uGrid', [Icon], False, '', '');
  finally
    Icon.Free
  end;
end;

end.
