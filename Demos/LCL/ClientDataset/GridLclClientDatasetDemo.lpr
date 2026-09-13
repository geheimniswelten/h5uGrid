program GridLclClientDatasetDemo;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces,
  Forms,
  LclDatasetDemoMain;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TLclDatasetDemoForm, LclDatasetDemoForm);
  Application.Run;
end.
