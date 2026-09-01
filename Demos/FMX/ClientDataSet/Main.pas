unit Main;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  FMX.Controls,
  FMX.Forms,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  Data.DB,
  h5u.Grid.Data.DataSet,
  h5u.Grid.SampleData,
  FMX.h5u.Grid;

type
  TMainForm = class(TForm)
    ToolBar: TToolBar;
    AutoHeightCheck: TCheckBox;
    EveryFifthCheck: TCheckBox;
    CacheCheck: TCheckBox;
    PagedCheck: TCheckBox;
    DarkCheck: TCheckBox;
    PictureCheck: TCheckBox;
    NextPageButton: TButton;
    Grid: Th5uFmxGrid;
    SampleData: Th5uSampleClientDataSet;
    DataSource: TDataSource;
    DataController: Th5uDataSetController;
    procedure FormCreate(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure GridGetThumbHint(
      Sender: TObject;
      const AContext: Th5uFmxThumbHintContext;
      var AText: string;
      var AVisible: Boolean
    );
  private
    procedure ApplyOptions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  h5u.Grid.Columns,
  h5u.Grid.Types;

procedure TMainForm.ApplyOptions;
var
  LPicture: Th5uGridColumn;
begin
  if AutoHeightCheck.IsChecked then
    Grid.RowHeight.Mode := Th5uRowHeightMode.Automatic
  else
    Grid.RowHeight.Mode := Th5uRowHeightMode.Fixed;

  if EveryFifthCheck.IsChecked then
  begin
    Grid.RowStyles.StripePeriod := 5;
    Grid.RowStyles.StripeOffset := 5;
  end
  else
  begin
    Grid.RowStyles.StripePeriod := 2;
    Grid.RowStyles.StripeOffset := 1;
  end;

  if CacheCheck.IsChecked then
    DataController.Cache.Mode := Th5uCacheMode.Paged
  else
    DataController.Cache.Mode := Th5uCacheMode.None;

  if PagedCheck.IsChecked then
  begin
    DataController.Pagination.Mode :=
      Th5uPaginationMode.NumberedPages;
    DataController.Pagination.PageSize := 10;
  end
  else
  begin
    DataController.Pagination.Mode :=
      Th5uPaginationMode.Continuous;
    DataController.Pagination.PageIndex := 0;
  end;

  if DarkCheck.IsChecked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;

  LPicture := Grid.Columns.FindById('picture');
  if Assigned(LPicture) then
    Grid.SetColumnVisible(LPicture, PictureCheck.IsChecked);

  Grid.InvalidateAllRowHeights;
  Grid.Repaint;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if not SampleData.Active then
    SampleData.RebuildSampleData;
  ApplyOptions;
end;

procedure TMainForm.GridGetThumbHint(
  Sender: TObject;
  const AContext: Th5uFmxThumbHintContext;
  var AText: string;
  var AVisible: Boolean);
begin
  if AContext.Axis = Th5uScrollAxis.Vertical then
    AText := 'FMX: ' + AText;
end;

procedure TMainForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <>
     Th5uPaginationMode.NumberedPages then
    Exit;
  LPageCount := (
    DataController.GetTotalRowCount +
    DataController.Pagination.PageSize - 1
  ) div DataController.Pagination.PageSize;
  DataController.Pagination.PageIndex :=
    (DataController.Pagination.PageIndex + 1) mod
    Max(1, LPageCount);
end;

procedure TMainForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

end.
