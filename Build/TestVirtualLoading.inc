uses
  System.Classes,
  System.Rtti,
  System.SysUtils,
  h5u.Grid.Data.Virtual,
  h5u.Grid.Types,
{$IFDEF TEST_FMX}
  FMX.Forms,
  FMX.Graphics,
  Fmx.h5u.Grid,
  FmxVirtualDemoMain in '..\Demos\FMX\VirtualLive\FmxVirtualDemoMain.pas';
{$ELSE}
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.h5u.Grid,
  VclVirtualDemoMain in '..\Demos\VCL\VirtualLive\VclVirtualDemoMain.pas';
{$ENDIF}

type
{$IFDEF TEST_FMX}
  TTestGrid = Th5uFmxGrid;
  TDemoForm = TFmxVirtualDemoForm;
{$ELSE}
  TTestGrid = Th5uVclGrid;
  TDemoForm = TVclVirtualDemoForm;
{$ENDIF}

  TProbeController = class(Th5uVirtualController)
  private
    procedure RowCount(Sender: TObject; var ACount: Int64);
  public
    CallCount: Integer;
    constructor Create(AOwner: TComponent); override;
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

constructor TProbeController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnGetRowCount := RowCount;
end;

procedure TProbeController.RowCount(Sender: TObject; var ACount: Int64);
var
  LGrid: TComponent;
begin
  Inc(CallCount);
  LGrid := Owner.FindComponent('Grid');
  Check(Owner.ComponentState * [csLoading, csReading] = [], 'Callback while owner is streaming');
  Check(not Assigned(LGrid) or (LGrid.ComponentState * [csLoading, csReading] = []), 'Callback while grid is streaming');
  ACount := 0;
end;

procedure TestStreaming;
var
  LRoot: TForm;
  LText: TStringStream;
  LBinary: TMemoryStream;
  LController: TProbeController;
  LGrid: TTestGrid;
begin
  LRoot := TForm.CreateNew(nil);
  try
    LText := TStringStream.Create('object Root: TForm' + sLineBreak
      + '  object Controller: TProbeController' + sLineBreak + '  end' + sLineBreak
      + '  object Grid: ' + TTestGrid.ClassName + sLineBreak
      + '    DataController = Controller' + sLineBreak
      + '    RowHeight.Mode = Automatic' + sLineBreak
      + '    Width = 720' + sLineBreak + '    Height = 360' + sLineBreak
      + '  end' + sLineBreak + 'end');
    try
      LBinary := TMemoryStream.Create;
      try
        ObjectTextToBinary(LText, LBinary);
        LBinary.Position := 0;
        LBinary.ReadComponent(LRoot);
      finally
        LBinary.Free;
      end;
    finally
      LText.Free;
    end;
    LController := LRoot.FindComponent('Controller') as TProbeController;
    LGrid := LRoot.FindComponent('Grid') as TTestGrid;
    Check(Assigned(LGrid), 'Streamed grid missing');
    LController.CallCount := 0;
    LController.NotifyReset;
    Check(LController.CallCount > 0, 'Updates were not resumed after streaming');
    LGrid.Width := 740;
  finally
    LRoot.Free;
  end;
end;

procedure TestDemo;
var
  LForm: TDemoForm;
  LBitmap: TBitmap;
begin
  LForm := TDemoForm.Create(nil);
  try
    LForm.LiveTimer.Enabled := False;
    Check(LForm.VirtualController.GetTotalRowCount = 60, 'Initial live rows missing');
    LForm.AppendButtonClick(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 61, 'Append did not update row count');
    LForm.LiveTimerTimer(nil);
    LForm.VirtualController.SetValue(0, 'MESSAGE', TValue.From<string>('Edited message'));
    Check(LForm.VirtualController.GetDisplayText(0, 'MESSAGE') = 'Edited message', 'Live edit did not update');
{$IFDEF TEST_FMX}
    LBitmap := LForm.Grid.MakeScreenshot;
{$ELSE}
    LBitmap := TBitmap.Create;
    LBitmap.SetSize(LForm.Grid.Width, LForm.Grid.Height);
{$ENDIF}
    try
{$IFNDEF TEST_FMX}
      LForm.Grid.PaintTo(LBitmap.Canvas.Handle, 0, 0);
{$ENDIF}
      Check((LBitmap.Width > 0) and (LBitmap.Height > 0), 'Grid painting returned an empty bitmap');
    finally
      LBitmap.Free;
    end;
    LForm.ClearButtonClick(nil);
    Check(LForm.VirtualController.GetTotalRowCount = 0, 'Clear did not update row count');
    LForm.FormDestroy(nil);
    Check(LForm.Grid.DataController = nil, 'Grid was not disconnected before freeing live rows');
    Check(LForm.VirtualController.GetTotalRowCount = 0, 'Callbacks after cleanup must return zero rows');
  finally
    LForm.Free;
  end;
end;

procedure TestEarlyCallbacks;
var
  LForm: TDemoForm;
  LCount: Int64;
  LKey: Th5uRowKey;
  LValue: TValue;
  LHandled: Boolean;
begin
  LForm := TDemoForm.CreateNew(nil);
  try
    LCount := -1;
    LValue := TValue.Empty;
    LKey := Default(Th5uRowKey);
    LHandled := True;
{$IFDEF TEST_FMX}
    LForm.VirtualGetRowCount(nil, LCount);
    LForm.VirtualGetRowKey(nil, 0, LKey);
    LForm.VirtualGetValue(nil, 0, 'MESSAGE', LValue);
    LForm.VirtualSetValue(nil, 0, 'MESSAGE', LValue, LHandled);
{$ELSE}
    LForm.VirtualControllerGetRowCount(nil, LCount);
    LForm.VirtualControllerGetRowKey(nil, 0, LKey);
    LForm.VirtualControllerGetValue(nil, 0, 'MESSAGE', LValue);
    LForm.VirtualControllerSetValue(nil, 0, 'MESSAGE', LValue, LHandled);
    LForm.VirtualControllerPrepareRange(nil, 0, 10, 1);
{$ENDIF}
    Check(LCount = 0, 'Uninitialized demo must have zero rows');
    Check(LValue.IsEmpty, 'Uninitialized demo returned a value');
    Check(not LHandled, 'Uninitialized demo accepted an edit');
  finally
    LForm.Free;
  end;
end;

const
  CTestNames: array[0..2] of string = ('streaming', 'early callbacks', 'demo lifecycle');
var
  LIndex: Integer;
  LFailures: Integer;
begin
  LFailures := 0;
  Application.Initialize;
  RegisterClass(TProbeController);
  RegisterClass(TTestGrid);
  for LIndex := 0 to 8 do
  try
    case LIndex mod 3 of
      0: TestStreaming;
      1: TestEarlyCallbacks;
      2: TestDemo;
    end;
    Writeln('PASS: ', CTestNames[LIndex mod 3], ', run ', LIndex div 3 + 1);
  except
    on E: Exception do
    begin
      Inc(LFailures);
      Writeln('FAIL: ', CTestNames[LIndex mod 3], ': ', E.ClassName, ': ', E.Message);
    end;
  end;
  if LFailures > 0 then
    ExitCode := 1;
end.
