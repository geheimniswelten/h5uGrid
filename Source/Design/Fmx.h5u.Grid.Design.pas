unit Fmx.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Fmx.h5u.Grid, Fmx.h5u.PropertyEditor, Fmx.h5u.FormDesigner;

procedure Register;

implementation

procedure Register;
begin
  // A nil editor hides legacy aliases; the property type must remain valid.
  RegisterPropertyEditor(TypeInfo(Single), ThiiCustomGrid, 'MinWidth', nil);
  RegisterPropertyEditor(TypeInfo(Single), ThiiCustomGrid, 'MaxWidth', nil);
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'AutoWidthRowLimit', nil);
  RegisterPropertyEditor(TypeInfo(ThiiHeaderLayout), ThiiCustomGrid, 'HeaderLayout', nil);
  RegisterPropertyEditor(TypeInfo(ThiiGridTheme), ThiiCustomGrid, 'Theme', nil);
  RegisterPropertyEditor(TypeInfo(Single), ThiiCustomGrid, 'HeaderRowHeight', nil);
  RegisterPropertyEditor(TypeInfo(Single), ThiiCustomGrid, 'RowIndicatorWidth', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ShowHeader', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ShowRowIndicator', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'AllowEditing', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ImmediateEdit', nil);

  RegisterComponents('hiiGrid', [ThiiGrid]);
  RegisterComponents('hii FormDesign', [ThiiStructureView, ThiiPropertyEditor]);
end;

end.

