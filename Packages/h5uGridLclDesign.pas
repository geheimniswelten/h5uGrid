{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit h5uGridLclDesign;

{$warn 5023 off : no warning about unused units}
interface

uses
  Lcl.h5u.Grid.Design, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('Lcl.h5u.Grid.Design', @Lcl.h5u.Grid.Design.Register);
end;

initialization
  RegisterPackage('h5uGridLclDesign', @Register);
end.
