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
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Sizing,
  h5u.Grid.Data.Dataset,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData,
  h5u.FormDesigner;

procedure Register;

implementation

{$IFNDEF FPC}
type
  Th5uWidthProperty = class(TFloatProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
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
  RegisterComponents('hii FormDesign', [ThiiFormDesigner]);

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

end.

