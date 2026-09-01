unit h5u.Grid.Design;

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  h5u.Grid.Factory,
  h5u.Grid.Data.DataSet,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData;

procedure Register;
begin
  RegisterComponents('h5u Data', [
    Th5uClassFactory,
    Th5uDataSetController,
    Th5uMemoryController,
    Th5uObjectListController,
    Th5uVirtualController,
    Th5uSampleClientDataSet
  ]);
end;

end.
