unit Vcl.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Vcl.h5u.Grid, Vcl.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'MinWidth', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'MaxWidth', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'AutoWidthRowLimit', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'HeaderLayout', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'Theme', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'HeaderRowHeight', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'RowIndicatorWidth', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'ShowHeader', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'ShowRowIndicator', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'AllowEditing', nil);
  RegisterPropertyEditor(nil, Th5uVclCustomGrid, 'ImmediateEdit', nil);

  RegisterComponents('h5u Grid', [Th5uVclGrid]);
  RegisterComponents('h5u FormDesign', [Th5uVclStructureView, Th5uVclPropertyEditor]);
end;

end.

