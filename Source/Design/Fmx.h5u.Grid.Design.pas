unit Fmx.h5u.Grid.Design;

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  Fmx.h5u.Grid;

procedure Register;
begin
  RegisterComponents('h5u Grid', [Th5uFmxGrid]);
end;

end.
