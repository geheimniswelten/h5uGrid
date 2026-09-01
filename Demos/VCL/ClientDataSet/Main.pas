unit Main;

interface

{$SCOPEDENUMS ON}

uses
  System.Math,
  System.Classes,
  System.Rtti,
  System.SysUtils,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Data.DB,
  h5u.Grid.Data.DataSet,
  h5u.Grid.Factory,
  h5u.Grid.SampleData,
  h5u.Grid.Types,
  Vcl.h5u.Grid;

type
  TPriorityDemoCell = class(Th5uVclDataCell)
  protected
    procedure PaintDefault(
      AGrid: Th5uVclGrid;
      ACanvas: TCanvas
    ); override;
  end;

  TMainForm = class(TForm)
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
    SampleData: Th5uSampleClientDataSet;
    DataSource: TDataSource;
    DataController: Th5uDataSetController;
    Grid: Th5uVclGrid;
    procedure FormCreate(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure MoveNameButtonClick(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetRowHeight(
      Sender: TObject;
      const AContext: Th5uGetRowHeightContext;
      var AHeight: Integer;
      var ACacheResult: Boolean
    );
    procedure GridGetThumbHint(
      Sender: TObject;
      const AContext: Th5uThumbHintContext;
      var AText: string;
      var AVisible: Boolean
    );
  private
    FAllAdjacentGroupsCollapsed: Boolean;
    procedure ApplyOptions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Winapi.Windows,
  h5u.Grid.Columns,
  h5u.Grid.Options,
  Vcl.h5u.Grid.Styles;

{ TPriorityDemoCell }

procedure TPriorityDemoCell.PaintDefault(
  AGrid: Th5uVclGrid; ACanvas: TCanvas);
var
  LPriority: Integer;
  LRect: TRect;
begin
  inherited PaintDefault(AGrid, ACanvas);
  if Value.IsEmpty then
    Exit;

  LPriority := Value.AsInteger;
  LRect := Rect(
    Bounds.Left + 5,
    Bounds.Top + (Bounds.Height - 10) div 2,
    Bounds.Left + 15,
    Bounds.Top + (Bounds.Height - 10) div 2 + 10
  );

  case LPriority of
    2:
      ACanvas.Brush.Color := clYellow;
    3:
      ACanvas.Brush.Color := clRed;
  else
    ACanvas.Brush.Color := clLime;
  end;
  ACanvas.Pen.Color := clGray;
  ACanvas.Ellipse(LRect);
end;

{ TMainForm }

procedure TMainForm.ApplyOptions;
var
  LPictureColumn: Th5uGridColumn;
  LNameColumn: Th5uGridColumn;
  LActiveColumn: Th5uGridColumn;
  LDescriptionColumn: Th5uGridColumn;
begin
  if AutoHeightCheck.Checked then
    Grid.RowHeight.Mode := Th5uRowHeightMode.Automatic
  else
    Grid.RowHeight.Mode := Th5uRowHeightMode.Fixed;

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
    0:
      Grid.AdjacentGroupFolding.EndBand.Visibility :=
        Th5uAdjacentGroupEndBandVisibility.Never;
    1:
      Grid.AdjacentGroupFolding.EndBand.Visibility :=
        Th5uAdjacentGroupEndBandVisibility.CollapsedOnly;
    2:
      Grid.AdjacentGroupFolding.EndBand.Visibility :=
        Th5uAdjacentGroupEndBandVisibility.ExpandedOnly;
  else
    Grid.AdjacentGroupFolding.EndBand.Visibility :=
      Th5uAdjacentGroupEndBandVisibility.Always;
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

  if CacheCheck.Checked then
    DataController.Cache.Mode := Th5uCacheMode.Paged
  else
    DataController.Cache.Mode := Th5uCacheMode.None;

  if DarkCheck.Checked then
    Grid.Theme := Th5uGridTheme.Dark
  else
    Grid.Theme := Th5uGridTheme.ApplicationStyle;

  // GridLines toggles all grid-wide one-pixel separator bands.
  // Explicit per-column RightSpacing values remain independent.
  Grid.GridLines := SeparatorsCheck.Checked;

  LDescriptionColumn := Grid.Columns.FindById('description');
  if Assigned(LDescriptionColumn) then
    if SeparatorsCheck.Checked then
      LDescriptionColumn.RightSpacing := 8
    else
      LDescriptionColumn.RightSpacing := 0;

  LNameColumn := Grid.Columns.FindById('name');
  LActiveColumn := Grid.Columns.FindById('active');
  if ColumnColorsCheck.Checked then
  begin
    if DarkCheck.Checked then
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

  LPictureColumn := Grid.Columns.FindById('picture');
  if Assigned(LPictureColumn) then
    Grid.SetColumnVisible(
      LPictureColumn,
      PictureCheck.Checked
    );

  Grid.InvalidateAllRowHeights;
  Grid.Invalidate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  if AdjacentBandModeCombo.ItemIndex < 0 then
    AdjacentBandModeCombo.ItemIndex := 3;
  FAllAdjacentGroupsCollapsed := False;

  if not SampleData.Active then
    SampleData.RecreateSampleData;

  Grid.FactoryScope.RegisterClass(
    h5uClassIdGridDataCell,
    Th5uVclVisualCell,
    TPriorityDemoCell,
    100,
    function(const AContext: Th5uFactoryContext): Boolean
    begin
      Result :=
        (AContext.Grid = Grid) and
        (AContext.Column is Th5uGridColumn) and
        SameText(
          Th5uGridColumn(AContext.Column).Id,
          'priority'
        );
    end
  );

  ApplyOptions;
end;

procedure TMainForm.GridGetRowHeight(
  Sender: TObject;
  const AContext: Th5uGetRowHeightContext;
  var AHeight: Integer;
  var ACacheResult: Boolean);
begin
  // Demonstrates the proposed value as a var parameter.
  if ((AContext.ViewRowIndex + 1) mod 9) = 0 then
    Inc(AHeight, 8);
end;

procedure TMainForm.GridGetThumbHint(
  Sender: TObject;
  const AContext: Th5uThumbHintContext;
  var AText: string;
  var AVisible: Boolean);
begin
  if AContext.Axis = Th5uScrollAxis.Vertical then
    AText := 'Datensatz: ' + AText;
end;

procedure TMainForm.MoveNameButtonClick(Sender: TObject);
var
  LColumn: Th5uGridColumn;
begin
  LColumn := Grid.Columns.FindById('name');
  if Assigned(LColumn) then
    Grid.MoveColumn(LColumn, Grid.Columns.Count - 1);
end;

procedure TMainForm.ToggleGroupsButtonClick(Sender: TObject);
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
