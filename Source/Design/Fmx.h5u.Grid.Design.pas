unit Fmx.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Fmx.h5u.Grid, Fmx.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('h5u Grid', [Th5uFmxGrid]);
  RegisterComponents('h5u FormDesign', [Th5uFmxStructureView, Th5uFmxPropertyEditor, Th5uFmxEventEditor,
    Th5uFmxComponentPaletteOld, Th5uFmxComponentPalette]);
end;

end.

