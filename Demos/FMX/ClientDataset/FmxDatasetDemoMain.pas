unit FmxDatasetDemoMain;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.UITypes,
  Data.DB,
  FMX.Controls,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Controls.Presentation,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.DataSet,
  h5u.Grid.SampleData,
  Fmx.h5u.Grid;

type
  TFmxDatasetDemoForm = class(TForm)
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
    AdjacentGroupCheck: TCheckBox;
    AdjacentBandModeLabel: TLabel;
    AdjacentBandModeCombo: TComboBox;
    ToggleGroupsButton: TButton;
    NextPageButton: TButton;
    Grid: Th5uFmxGrid;
    SampleData: Th5uSampleClientDataSet;
    DataSource: TDataSource;
    DataController: Th5uDataSetController;
    procedure FormCreate(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetThumbHint(Sender: TObject; const AContext: Th5uFmxThumbHintContext; var AText: string; var AVisible: Boolean);
  private
    FAllAdjacentGroupsCollapsed: Boolean;
    procedure ApplyOptions;
  end;

var
  FmxDatasetDemoForm: TFmxDatasetDemoForm;

implementation

{$R *.fmx}

uses
  h5u.Grid.Columns,
  h5u.Grid.Types;

procedure TFmxDatasetDemoForm.ApplyOptions;
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

  Grid.AdjacentGroupFolding.Enabled := AdjacentGroupCheck.IsChecked;
  Grid.AdjacentGroupFolding.IdColumnId := 'fold_group';
  Grid.AdjacentGroupFolding.ShowFoldGlyph := True;
  Grid.AdjacentGroupFolding.EndBand.Height := 7;
  Grid.AdjacentGroupFolding.EndBand.StyleName := 'AdjacentGroupEnd';
  case AdjacentBandModeCombo.ItemIndex of
    0: Grid.AdjacentGroupFolding.EndBand.Visibility := Th5uAdjacentGroupEndBandVisibility.Never;
    1: Grid.AdjacentGroupFolding.EndBand.Visibility := Th5uAdjacentGroupEndBandVisibility.CollapsedOnly;
    2: Grid.AdjacentGroupFolding.EndBand.Visibility := Th5uAdjacentGroupEndBandVisibility.ExpandedOnly;
    else Grid.AdjacentGroupFolding.EndBand.Visibility := Th5uAdjacentGroupEndBandVisibility.Always;
  end;
  ToggleGroupsButton.Enabled := AdjacentGroupCheck.IsChecked;

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
    DataController.Pagination.Mode := Th5uPaginationMode.NumberedPages;
    DataController.Pagination.PageSize := 10;
  end
  else
  begin
    DataController.Pagination.Mode := Th5uPaginationMode.Continuous;
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
      Grid.Appearance.DefaultCellColor := $001F1F1F;
      if Assigned(LNameColumn) then
        LNameColumn.Color := $00362B1F;
      if Assigned(LActiveColumn) then
        LActiveColumn.Color := $0022311D;
    end
    else
    begin
      Grid.Appearance.DefaultCellColor := $00FDFDFD;
      if Assigned(LNameColumn) then
        LNameColumn.Color := $00FFF4EA;
      if Assigned(LActiveColumn) then
        LActiveColumn.Color := $00ECF8EA;
    end;
  end
  else
  begin
    Grid.Appearance.DefaultCellColor := TColorRec.SysDefault;
    if Assigned(LNameColumn) then
      LNameColumn.Color := TColorRec.SysDefault;
    if Assigned(LActiveColumn) then
      LActiveColumn.Color := TColorRec.SysDefault;
  end;

  LPicture := Grid.Columns.FindById('picture');
  if Assigned(LPicture) then
    Grid.SetColumnVisible(LPicture, PictureCheck.IsChecked);

  Grid.InvalidateAllRowHeights;
  Grid.Repaint;
end;

procedure TFmxDatasetDemoForm.FormCreate(Sender: TObject);
begin
  if AdjacentBandModeCombo.ItemIndex < 0 then
    AdjacentBandModeCombo.ItemIndex := 3;
  FAllAdjacentGroupsCollapsed := False;

  if not SampleData.Active then
    SampleData.RecreateSampleData;
  ApplyOptions;
end;

procedure TFmxDatasetDemoForm.GridGetThumbHint(Sender: TObject; const AContext: Th5uFmxThumbHintContext; var AText: string; var AVisible: Boolean);
begin
  if AContext.Axis = Th5uScrollAxis.Vertical then
    AText := 'FMX: ' + AText;
end;

procedure TFmxDatasetDemoForm.ToggleGroupsButtonClick(Sender: TObject);
begin
  if not Grid.AdjacentGroupFolding.Enabled then
    Exit;

  if FAllAdjacentGroupsCollapsed then
  begin
    Grid.ExpandAllAdjacentGroups;
    FAllAdjacentGroupsCollapsed := False;
    ToggleGroupsButton.Text := 'Alle falten';
  end
  else
  begin
    Grid.CollapseAllAdjacentGroups;
    FAllAdjacentGroupsCollapsed := True;
    ToggleGroupsButton.Text := 'Alle öffnen';
  end;
end;

procedure TFmxDatasetDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <> Th5uPaginationMode.NumberedPages then
    Exit;
  LPageCount := (DataController.GetTotalRowCount + DataController.Pagination.PageSize - 1) div DataController.Pagination.PageSize;
  DataController.Pagination.PageIndex := (DataController.Pagination.PageIndex + 1) mod Max(1, LPageCount);
end;

procedure TFmxDatasetDemoForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

end.
