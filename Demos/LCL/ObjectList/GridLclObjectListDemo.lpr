program GridLclObjectListDemo;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  Forms,
  LclObjectDemoMain;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TLclObjectDemoForm, LclObjectDemoForm);
  Application.Run;
end.
