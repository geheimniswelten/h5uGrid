{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit h5uGridCoreLazarus;

{$warn 5023 off : no warning about unused units}
interface

uses
  h5u.Grid.AdjacentGroups, h5u.Grid.Columns, h5u.Grid.Compat, 
  h5u.Grid.Editors, h5u.Grid.Factory, h5u.Grid.Layout, h5u.Grid.Moving, 
  h5u.Grid.Navigation, h5u.Grid.Options, h5u.Grid.Resizing, 
  h5u.Grid.RowMetrics, h5u.Grid.Selection, h5u.Grid.Types, h5u.Grid.Values, 
  h5u.Grid.View, h5u.Grid.Data.Core, h5u.Grid.Data.Dataset, 
  h5u.Grid.Data.Memory, h5u.Grid.Data.Objects, h5u.Grid.Data.Virtual, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('h5uGridCoreLazarus', @Register);
end.
