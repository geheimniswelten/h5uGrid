unit Vcl.h5u.Grid.Design;

interface

uses
  System.Classes, DesignIntf,
  Vcl.h5u.Grid, Vcl.h5u.PropertyEditor, Vcl.h5u.FormDesigner;

procedure Register;

implementation

uses
  System.SysUtils, Vcl.Forms;

procedure SelectGridColumn(AGrid: ThiiCustomGrid; AColumn: ThiiGridColumn);
var
  Form: TCustomForm;
  Designer: IDesigner;
begin
  if not (csDesigning in AGrid.ComponentState) then Exit;
  Form := GetParentForm(AGrid);
  if Assigned(Form) and Supports(Form.Designer, IDesigner, Designer) then
    Designer.SelectComponent(AColumn);
end;

procedure Register;
begin
  // A nil editor hides legacy aliases; the property type must remain valid.
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'MinWidth', nil);
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'MaxWidth', nil);
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'AutoWidthRowLimit', nil);
  RegisterPropertyEditor(TypeInfo(ThiiHeaderLayout), ThiiCustomGrid, 'HeaderLayout', nil);
  RegisterPropertyEditor(TypeInfo(ThiiGridTheme), ThiiCustomGrid, 'Theme', nil);
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'HeaderRowHeight', nil);
  RegisterPropertyEditor(TypeInfo(Integer), ThiiCustomGrid, 'RowIndicatorWidth', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ShowHeader', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ShowRowIndicator', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'AllowEditing', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), ThiiCustomGrid, 'ImmediateEdit', nil);

  RegisterComponents('hiiGrid', [ThiiGrid]);
  RegisterComponents('hii FormDesign', [ThiiStructureView, ThiiPropertyEditor]);
end;

initialization
  h5uVclDesignerColumnSelect := SelectGridColumn;

finalization
  h5uVclDesignerColumnSelect := nil;

end.

