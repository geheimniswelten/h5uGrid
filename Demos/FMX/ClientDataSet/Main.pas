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
    SeparatorsCheck: TCheckBox;
    ColumnColorsCheck: TCheckBox;
    TreeEndBandCheck: TCheckBox;
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
  LNameColumn: Th5uGridColumn;
  LActiveColumn: Th5uGridColumn;
  LDescriptionColumn: Th5uGridColumn;
begin
  if AutoHeightCheck.IsChecked then
    Grid.RowHeight.Mode := Th5uRowHeightMode.Automatic
  else
    Grid.RowHeight.Mode := Th5uRowHeightMode.Fixed;

  Grid.Tree.Enabled := TreeEndBandCheck.IsChecked;
  Grid.Tree.LevelColumnId := 'TREE_LEVEL';
  Grid.Tree.BranchEndBand.Enabled := TreeEndBandCheck.IsChecked;

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

  // GridLines toggles all grid-wide one-pixel separator bands.
  // Explicit per-column RightSpacing values remain independent.
  Grid.GridLines := SeparatorsCheck.IsChecked;

  LDescriptionColumn := Grid.Columns.FindById('description');
  if Assigned(LDescriptionColumn) then
    if SeparatorsCheck.IsChecked then
      LDescriptionColumn.RightSpacing := 8
    else
      LDescriptionColumn.RightSpacing := 0;

  LNameColumn := Grid.Columns.FindById('name');
  LActiveColumn := Grid.Columns.FindById('active');
  if ColumnColorsCheck.IsChecked then
  begin
    if DarkCheck.IsChecked then
    begin
      Grid.Appearance.DefaultCellColor := h5uColorFromRgb(31, 31, 31);
      if Assigned(LNameColumn) then
        LNameColumn.Color := h5uColorFromRgb(31, 43, 54);
      if Assigned(LActiveColumn) then
        LActiveColumn.Color := h5uColorFromRgb(29, 49, 34);
    end
    else
    begin
      Grid.Appearance.DefaultCellColor := h5uColorFromRgb(253, 253, 253);
      if Assigned(LNameColumn) then
        LNameColumn.Color := h5uColorFromRgb(234, 244, 255);
      if Assigned(LActiveColumn) then
        LActiveColumn.Color := h5uColorFromRgb(234, 248, 236);
    end;
  end
  else
  begin
    Grid.Appearance.DefaultCellColor := h5uColorDefault;
    if Assigned(LNameColumn) then
      LNameColumn.Color := h5uColorDefault;
    if Assigned(LActiveColumn) then
      LActiveColumn.Color := h5uColorDefault;
  end;

  LPicture := Grid.Columns.FindById('picture');
  if Assigned(LPicture) then
    Grid.SetColumnVisible(LPicture, PictureCheck.IsChecked);

  Grid.InvalidateAllRowHeights;
  Grid.Repaint;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if not SampleData.Active then
    SampleData.RecreateSampleData;
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
