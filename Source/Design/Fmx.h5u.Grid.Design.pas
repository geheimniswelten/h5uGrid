unit Fmx.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Fmx.h5u.Grid, Fmx.h5u.PropertyEditor, Fmx.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'MinWidth', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'MaxWidth', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'AutoWidthRowLimit', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'HeaderLayout', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'Theme', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'HeaderRowHeight', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'RowIndicatorWidth', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'ShowHeader', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'ShowRowIndicator', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'AllowEditing', nil);
  RegisterPropertyEditor(nil, ThiiCustomGrid, 'ImmediateEdit', nil);

  RegisterComponents('hiiGrid', [ThiiGrid]);
  RegisterComponents('hii FormDesign', [ThiiStructureView, ThiiPropertyEditor]);
end;

end.

