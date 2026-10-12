unit LclDatasetDemoMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

{$SCOPEDENUMS ON}

uses
  h5u.Grid.Types,
  Math,
  Classes,
  Rtti,
  SysUtils,
  DB,
  Controls,
  ExtCtrls,
  Forms,
  Graphics,
  StdCtrls,
  h5u.Grid.Data.DataSet,
  h5u.Grid.Factory,
  h5u.Grid.SampleData,
  Lcl.h5u.Grid;

type
  TPriorityDemoCell = class(ThiiLclDataCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  TLclDatasetDemoForm = class(TForm)
    OptionsPanel: TPanel;
    AutoHeightCheck: TCheckBox;
    MultiHeaderCheck: TCheckBox;
    EveryFifthCheck: TCheckBox;
    PagedCheck: TCheckBox;
    CacheCheck: TCheckBox;
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
    MoveNameButton: TButton;
    InfoLabel: TLabel;
    SampleData: ThiiSampleClientDataset;
    DataSource: TDataSource;
    DataController: ThiiDatasetController;
    Grid: ThiiGrid;
    procedure FormCreate(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure MoveNameButtonClick(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetRowHeight(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean);
    procedure GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
  private
    FAllAdjacentGroupsCollapsed: Boolean;
    procedure ApplyOptions;
  end;

var
  LclDatasetDemoForm: TLclDatasetDemoForm;

implementation

{$R *.lfm}

uses
  Types,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  Lcl.h5u.Grid.Styles;

{ TPriorityDemoCell }

function IsPriorityColumn(const AContext: ThiiFactoryContext): Boolean;
begin
  // Registered on this grid's scope, so no captured form reference is needed.
  Result := (AContext.Column is ThiiGridColumn) and SameText(ThiiGridColumn(AContext.Column).Id, 'priority');
end;

procedure TPriorityDemoCell.PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas);
var
  LPriority: Integer;
  LRect: TRect;
begin
  inherited;
  if Value.IsEmpty then
    Exit;

  LPriority := Value.AsInteger;
  LRect := Rect(Bounds.Left + 5, Bounds.Top + (Bounds.Height - 10) div 2, Bounds.Left + 15, Bounds.Top + (Bounds.Height - 10) div 2 + 10);

  case LPriority of
    2: ACanvas.Brush.Color := clYellow;
    3: ACanvas.Brush.Color := clRed;
    else ACanvas.Brush.Color := clLime;
  end;
  ACanvas.Pen.Color := clGray;
  ACanvas.Ellipse(LRect);
end;

{ TLclDatasetDemoForm }

procedure TLclDatasetDemoForm.ApplyOptions;
var
  LPictureColumn: ThiiGridColumn;
  LNameColumn: ThiiGridColumn;
  LActiveColumn: ThiiGridColumn;
  LDescriptionColumn: ThiiGridColumn;
begin
  if AutoHeightCheck.Checked then
    Grid.RowHeight.Mode := ThiiRowHeightMode.Automatic
  else
    Grid.RowHeight.Mode := ThiiRowHeightMode.Fixed;

  Grid.HeaderLayout.Enabled := MultiHeaderCheck.Checked;

  Grid.Tree.Enabled := TreeEndBandCheck.Checked;
  Grid.Tree.LevelColumnId := 'TREE_LEVEL';
  Grid.Tree.BranchEndBand.Enabled := TreeEndBandCheck.Checked;

  Grid.AdjacentGroupFolding.Enabled := AdjacentGroupCheck.Checked;
  Grid.AdjacentGroupFolding.IdColumnId := 'fold_group';
  Grid.AdjacentGroupFolding.ShowFoldGlyph := True;
  Grid.AdjacentGroupFolding.EndBand.Height := 7;
  Grid.AdjacentGroupFolding.EndBand.StyleName := 'AdjacentGroupEnd';
  case AdjacentBandModeCombo.ItemIndex of
    0: Grid.AdjacentGroupFolding.EndBand.Visibility := ThiiAdjacentGroupEndBandVisibility.Never;
    1: Grid.AdjacentGroupFolding.EndBand.Visibility := ThiiAdjacentGroupEndBandVisibility.CollapsedOnly;
    2: Grid.AdjacentGroupFolding.EndBand.Visibility := ThiiAdjacentGroupEndBandVisibility.ExpandedOnly;
    else Grid.AdjacentGroupFolding.EndBand.Visibility := ThiiAdjacentGroupEndBandVisibility.Always;
  end;
  ToggleGroupsButton.Enabled := AdjacentGroupCheck.Checked;

  if EveryFifthCheck.Checked then
  begin
    Grid.RowStyles.StripePeriod := 5;
    Grid.RowStyles.StripeOffset := 5;
  end
  else
  begin
    Grid.RowStyles.StripePeriod := 2;
    Grid.RowStyles.StripeOffset := 1;
  end;

  if PagedCheck.Checked then
  begin
    DataController.Pagination.Mode := ThiiPaginationMode.NumberedPages;
    DataController.Pagination.PageSize := 10;
  end
  else
  begin
    DataController.Pagination.Mode := ThiiPaginationMode.Continuous;
    DataController.Pagination.PageIndex := 0;
  end;
  NextPageButton.Enabled := PagedCheck.Checked;

  if CacheCheck.Checked then
    DataController.Cache.Mode := ThiiCacheMode.Paged
  else
    DataController.Cache.Mode := ThiiCacheMode.None;

  if DarkCheck.Checked then
    Grid.Theme := ThiiGridTheme.Dark
  else
    Grid.Theme := ThiiGridTheme.ApplicationStyle;

  // GridLines toggles all grid-wide one-pixel separator bands.
  // Explicit per-column RightSpacing values remain independent.
  Grid.GridLines := SeparatorsCheck.Checked;

  LDescriptionColumn := Grid.Columns.FindById('description');
  if Assigned(LDescriptionColumn) then
    LDescriptionColumn.RightSpacing := 8;

  LNameColumn := Grid.Columns.FindById('name');
  LActiveColumn := Grid.Columns.FindById('active');
  if ColumnColorsCheck.Checked then
  begin
    if DarkCheck.Checked then
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
    Grid.Appearance.DefaultCellColor := clDefault;
    if Assigned(LNameColumn) then
      LNameColumn.Color := clDefault;
    if Assigned(LActiveColumn) then
      LActiveColumn.Color := clDefault;
  end;

  LPictureColumn := Grid.Columns.FindById('picture');
  if Assigned(LPictureColumn) then
    Grid.SetColumnVisible(LPictureColumn, PictureCheck.Checked);

  Grid.InvalidateAllRowHeights;
  Grid.Invalidate;
end;

procedure TLclDatasetDemoForm.FormCreate(Sender: TObject);
begin
  if AdjacentBandModeCombo.ItemIndex < 0 then
    AdjacentBandModeCombo.ItemIndex := 3;
  FAllAdjacentGroupsCollapsed := False;

  if not SampleData.Active then
    SampleData.RecreateSampleData;

  Grid.FactoryScope.RegisterClass(h5uClassIdGridDataCell, ThiiLclVisualCell, TPriorityDemoCell, 100, @IsPriorityColumn);

  ApplyOptions;
end;

procedure TLclDatasetDemoForm.GridGetRowHeight(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean);
begin
  // Demonstrates the proposed value as a var parameter.
  if ((AContext.ViewRowIndex + 1) mod 9) = 0 then
    Inc(AHeight, 8);
end;

procedure TLclDatasetDemoForm.GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
begin
  if AContext.Axis = ThiiScrollAxis.Vertical then
    AText := 'Datensatz: ' + AText;
end;

procedure TLclDatasetDemoForm.MoveNameButtonClick(Sender: TObject);
var
  LColumn: ThiiGridColumn;
begin
  LColumn := Grid.Columns.FindById('name');
  if Assigned(LColumn) then
    Grid.MoveColumn(LColumn, Grid.Columns.Count - 1);
end;

procedure TLclDatasetDemoForm.ToggleGroupsButtonClick(Sender: TObject);
begin
  if not Grid.AdjacentGroupFolding.Enabled then
    Exit;

  if FAllAdjacentGroupsCollapsed then
  begin
    Grid.ExpandAllAdjacentGroups;
    FAllAdjacentGroupsCollapsed := False;
    ToggleGroupsButton.Caption := 'Alle falten';
  end
  else
  begin
    Grid.CollapseAllAdjacentGroups;
    FAllAdjacentGroupsCollapsed := True;
    ToggleGroupsButton.Caption := 'Alle öffnen';
  end;
end;

procedure TLclDatasetDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <> ThiiPaginationMode.NumberedPages then
    Exit;

  LPageCount := (DataController.GetTotalRowCount + DataController.Pagination.PageSize - 1) div DataController.Pagination.PageSize;

  DataController.Pagination.PageIndex := (DataController.Pagination.PageIndex + 1) mod Max(1, LPageCount);
end;

procedure TLclDatasetDemoForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

end.
