unit Lcl.h5u.Grid.Design;

{$MODE OBJFPC}{$H+}
{$CODEPAGE UTF8}

interface

procedure Register;

implementation

uses
  Classes,
  LResources,
  Lcl.h5u.Grid;

procedure Register;
begin
  {$I Lcl.h5u.Grid.Design_icon.lrs}
  RegisterComponents('hiiGrid', [ThiiGrid]);
end;

end.
