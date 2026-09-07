program TestVclDatasetLoading;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  Vcl.Graphics,
  MidasLib,
  VclDatasetDemoMain in '..\Demos\VCL\ClientDataset\VclDatasetDemoMain.pas';

type
  TComponentAccess = class(TComponent);

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TestForm(ADesigning: Boolean);
var
  LForm: TVclDatasetDemoForm;
  LBitmap: TBitmap;
begin
  Writeln('Loading demo, designing=', ADesigning);
  if ADesigning then
  begin
    LForm := TVclDatasetDemoForm.CreateNew(nil);
    try
      TComponentAccess(LForm).SetDesigning(True);
      Check(InitInheritedComponent(LForm, TForm), 'Demo form resource missing');
    except
      LForm.Free;
      raise;
    end;
  end
  else
    LForm := TVclDatasetDemoForm.Create(nil);
  try
    Check((csDesigning in LForm.Grid.ComponentState) = ADesigning, 'Wrong grid design state');
    Check(LForm.SampleData.Active, 'Sample dataset is inactive');
    Check(LForm.SampleData.RecordCount = 40, 'Expected 40 demo records');
    Check(LForm.Grid.DataController = LForm.DataController, 'Grid controller was not streamed');
    LBitmap := TBitmap.Create;
    try
      LBitmap.SetSize(LForm.Grid.Width, LForm.Grid.Height);
      LForm.Grid.PaintTo(LBitmap.Canvas.Handle, 0, 0);
      LForm.Grid.CollapseAllAdjacentGroups;
      LForm.Grid.PaintTo(LBitmap.Canvas.Handle, 0, 0);
      LForm.Grid.ExpandAllAdjacentGroups;
      LForm.SampleData.RecNo := 21;
      LForm.SampleData.DisableControls;
      try
        LForm.SampleData.Edit;
        LForm.SampleData.FieldByName('DESCRIPTION').AsString := 'Changed after loading';
        LForm.SampleData.Post;
      finally
        LForm.SampleData.EnableControls;
      end;
      LForm.Grid.PaintTo(LBitmap.Canvas.Handle, 0, 0);
      Check(LForm.DataController.GetDisplayText(20, 'DESCRIPTION') = 'Changed after loading', 'Stale demo cell after edit');
    finally
      LBitmap.Free;
    end;
  finally
    LForm.Free;
  end;
end;

var
  LIndex: Integer;
begin
  try
    Application.Initialize;
    Application.ShowMainForm := False;
    for LIndex := 1 to 5 do
    begin
      TestForm(False);
      TestForm(True);
    end;
    Writeln('PASS: 5 runtime and 5 design-mode demo loads, painting, group folding and edits');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
