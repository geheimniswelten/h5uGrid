{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit h5uGridCoreLazarusDesign;

{$warn 5023 off : no warning about unused units}
interface

uses
  h5u.Grid.Design, h5u.Grid.SampleData, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('h5u.Grid.Design', @h5u.Grid.Design.Register);
end;

initialization
  RegisterPackage('h5uGridCoreLazarusDesign', @Register);

end.
