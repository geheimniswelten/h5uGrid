unit h5u.Grid.Design;

{$IFDEF FPC}
  {$MODE OBJFPC}{$H+}
  {$MODESWITCH ADVANCEDRECORDS}
  {$CODEPAGE UTF8}
{$ENDIF}

interface

procedure Register;

implementation

uses
  {$IFDEF FPC}
    Classes,
    //Graphics,
    LResources,
    LazarusPackageIntf,
  {$ELSE}
    System.Classes,
    Imaging.pngimage,
    DesignIntf,
    ToolsAPI,
  {$ENDIF}
  h5u.Grid.Factory,
  h5u.Grid.Data.Dataset,
  h5u.Grid.Data.Memory,
  h5u.Grid.Data.Objects,
  h5u.Grid.Data.Virtual,
  h5u.Grid.SampleData;

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
    {$I h5u.Grid.Design_icon.lrs}
  {$ENDIF}
  RegisterComponents('h5u Grid', [Th5uClassFactory, Th5uDatasetController, Th5uMemoryController, Th5uObjectListController, Th5uVirtualController,
    Th5uSampleClientDataset]);

  {$IFnDEF FPC}
    Icon := TPngImage.Create;
    try
      Icon.LoadFromResourceName(HInstance, 'h5uGridComponent_32x32');
      SplashScreenServices.AddPluginBitmap('h5uGrid', [Icon], False, '', '');
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

