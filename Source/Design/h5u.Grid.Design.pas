unit h5u.Grid.Design;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    Classes,
    //Graphics,
    LResources,
    LazarusPackageIntf,
  {$ELSE}
    System.Classes,
    System.SysUtils,
    Imaging.pngimage,
    DesignIntf,
    DesignEditors,
    ToolsAPI,
    h5u.FormDesigner,
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Sizing,
  h5u.Grid.Data.Dataset,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData;

procedure Register;

implementation

{$IFNDEF FPC}
uses
  Winapi.Windows, Winapi.Messages, System.Types, System.Generics.Collections,
  Vcl.ExtCtrls, Vcl.AppEvnts, h5u.Grid.Columns, h5u.Grid.Moving;

type
  // Observe a native designer click without capturing or consuming its mouse messages.
  Th5uDesignClickObserver = class(TComponent)
  private
    FTimer: TTimer;
    FColumn: ThiiGridColumn;
    FColumns: ThiiGridColumns;
    FSelect: Th5uDesignColumnSelect;
    FOrigin: TPoint;
    FDragged: Boolean;
    FPressSerial: Cardinal;
    procedure Tick(Sender: TObject);
  public
    constructor CreateClick(AGrid: TComponent; AColumn: ThiiGridColumn; ASelect: Th5uDesignColumnSelect);
    destructor Destroy; override;
    procedure TrackMovement;
  end;

  Th5uDesignMouseMessages = class
    DownOrigin: TPoint;
    Pressed, Dragged: Boolean;
    PressSerial: Cardinal;
    procedure Message(var Msg: TMsg; var Handled: Boolean);
  end;

  Th5uWidthProperty = class(TFloatProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

var
  ClickObservers: TList<Th5uDesignClickObserver>;
  MouseMessages: Th5uDesignMouseMessages;
  ApplicationEvents: TApplicationEvents;

constructor Th5uDesignClickObserver.CreateClick(AGrid: TComponent; AColumn: ThiiGridColumn; ASelect: Th5uDesignColumnSelect);
begin
  inherited Create(AGrid);
  FColumn := AColumn;
  FColumns := ThiiGridColumns(AColumn.Collection);
  FSelect := ASelect;
  FOrigin := MouseMessages.DownOrigin;
  FPressSerial := MouseMessages.PressSerial;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 20;
  FTimer.OnTimer := Tick;
  ClickObservers.Add(Self);
end;

destructor Th5uDesignClickObserver.Destroy;
begin
  ClickObservers.Remove(Self);
  inherited;
end;

procedure Th5uDesignClickObserver.TrackMovement;
var
  Position: TPoint;
begin
  GetCursorPos(Position);
  FDragged := FDragged or (Abs(Position.X - FOrigin.X) >= 4) or (Abs(Position.Y - FOrigin.Y) >= 4);
end;

procedure Th5uDesignClickObserver.Tick(Sender: TObject);
var
  I: Integer;
begin
  TrackMovement;
  if (FPressSerial = MouseMessages.PressSerial) and MouseMessages.Pressed then Exit;
  FTimer.Enabled := False;
  try
    if FDragged or MouseMessages.Dragged or (FPressSerial <> MouseMessages.PressSerial) or not (csDesigning in Owner.ComponentState)
      or (csDestroying in Owner.ComponentState) then Exit;
    // The collection item may have been deleted while the native designer handled the click.
    for I := 0 to FColumns.Count - 1 do
      if FColumns[I] = FColumn then
      begin
        FSelect(FColumn);
        Break;
      end;
  finally
    Free;
  end;
end;

procedure Th5uDesignMouseMessages.Message(var Msg: TMsg; var Handled: Boolean);
var
  Observer: Th5uDesignClickObserver;
begin
  case Msg.message of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
      begin
        DownOrigin := Msg.pt;
        Pressed := True;
        Dragged := False;
        Inc(PressSerial);
      end;
    WM_MOUSEMOVE:
      begin
        if Pressed then
          Dragged := Dragged or (Abs(Msg.pt.X - DownOrigin.X) >= 4) or (Abs(Msg.pt.Y - DownOrigin.Y) >= 4);
        for Observer in ClickObservers do Observer.TrackMovement;
      end;
    WM_LBUTTONUP:
      begin
        Dragged := Dragged or (Abs(Msg.pt.X - DownOrigin.X) >= 4) or (Abs(Msg.pt.Y - DownOrigin.Y) >= 4);
        Pressed := False;
      end;
  end;
end;

procedure ObserveDesignColumnClick(AGrid: TComponent; AColumn: ThiiGridColumn; ASelect: Th5uDesignColumnSelect);
var
  Observer: Th5uDesignClickObserver;
begin
  if not (csDesigning in AGrid.ComponentState) or not MouseMessages.Pressed or MouseMessages.Dragged or not Assigned(AColumn) then Exit;
  for Observer in ClickObservers do
    if Observer.Owner = AGrid then Exit;
  Th5uDesignClickObserver.CreateClick(AGrid, AColumn, ASelect);
end;

function Th5uWidthProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paValueList];
end;

function Th5uWidthProperty.GetValue: string;
begin
  Result := h5uWidthToText(GetFloatValue);
end;

procedure Th5uWidthProperty.GetValues(Proc: TGetStrProc);
begin
  Proc('Default');
end;

procedure Th5uWidthProperty.SetValue(const Value: string);
var
  Width: ThiiWidth;
begin
  if not h5uTryTextToWidth(Value, Width) then
    raise EConvertError.Create('Breite als Zahl, Prozentangabe oder Default erwartet.');
  SetFloatValue(Width);
end;
{$ENDIF}

procedure Register;
{$IFnDEF FPC}
var
  Icon: TPngImage;
{$ELSE}
//var
//  Icon: TPortableNetworkGraphic;
{$ENDIF}
begin
  {$IFnDEF FPC}
    RegisterPropertyEditor(TypeInfo(ThiiWidth), nil, '', Th5uWidthProperty);
    {$I h5u.Grid.Design_icon.lrs}
  {$ENDIF}
  RegisterComponents('hiiGrid',
    [ThiiClassFactory, ThiiDatasetController, ThiiMemoryController, ThiiObjectListController, ThiiVirtualController, ThiiSampleClientDataset]);
  {$IFNDEF FPC}
  RegisterComponents('hii FormDesign', [ThiiFormDesigner]);
  {$ENDIF}

  {$IFnDEF FPC}
    Icon := TPngImage.Create;
    try
      Icon.LoadFromResourceName(HInstance, 'h5uGridComponent_32x32');
      SplashScreenServices.AddPluginBitmap('hiiGrid', [Icon], False, '', '');
    finally
      Icon.Free
    end;
  {$ELSE}
    //Icon := TPortableNetworkGraphic.Create;
    //try
    //  Icon.LoadFromLazarusResource('h5uGridComponent_32x32');
    //  ...
    //finally
    //  Icon.Free
    //end;
  {$ENDIF}
end;

{$IFNDEF FPC}
initialization
  ClickObservers := TList<Th5uDesignClickObserver>.Create;
  MouseMessages := Th5uDesignMouseMessages.Create;
  ApplicationEvents := TApplicationEvents.Create(nil);
  ApplicationEvents.OnMessage := MouseMessages.Message;
  h5uObserveDesignColumnClick := ObserveDesignColumnClick;

finalization
  h5uObserveDesignColumnClick := nil;
  ApplicationEvents.Free;
  while ClickObservers.Count > 0 do ClickObservers.Last.Free;
  ClickObservers.Free;
  MouseMessages.Free;
{$ENDIF}

end.

