program GridLclVirtualLiveDemo;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  Forms,
  LclVirtualDemoMain;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TLclVirtualDemoForm, LclVirtualDemoForm);
  Application.Run;
end.
