unit Fmx.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Fmx.h5u.Grid, Fmx.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'MinWidth', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'MaxWidth', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'AutoWidthRowLimit', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'HeaderLayout', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'Theme', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'HeaderRowHeight', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'RowIndicatorWidth', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'ShowHeader', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'ShowRowIndicator', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'AllowEditing', nil);
  RegisterPropertyEditor(nil, Th5uFmxCustomGrid, 'ImmediateEdit', nil);

  RegisterComponents('h5u Grid', [Th5uFmxGrid]);
  RegisterComponents('h5u FormDesign', [Th5uFmxStructureView, Th5uFmxPropertyEditor]);
end;

end.

