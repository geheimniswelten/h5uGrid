{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit h5uGridLcl;

{$warn 5023 off : no warning about unused units}
interface

uses
  Lcl.h5u.Grid.Compat, Lcl.h5u.Grid, Lcl.h5u.Grid.Editors, 
  Lcl.h5u.Grid.Styles, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('h5uGridLcl', @Register);
end.
