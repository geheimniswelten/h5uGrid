unit Vcl.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Vcl.h5u.Grid, Vcl.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('h5u Grid', [Th5uVclGrid]);
  RegisterComponents('h5u FormDesign', [{Th5uVclStructureView, Th5uVclPropertyEditor, Th5uVclEventEditor,
    Th5uVclComponentPaletteOld, Th5uVclComponentPalette}]);
end;

end.

