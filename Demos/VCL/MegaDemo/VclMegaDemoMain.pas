unit VclMegaDemoMain;

interface

{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  h5u.Grid.Types,
  System.Math,
  System.Types,
  System.Classes,
  System.Rtti,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.AppEvnts,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.WinXCtrls,
  Vcl.FormTabsBar,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.DataSet,
  h5u.Grid.Factory,
  h5u.Grid.SampleData,
  Vcl.h5u.Grid.Styles,
  Vcl.h5u.Grid,
  Vcl.h5u.PropertyEditor;

type
  TPriorityDemoCell = class(ThiiVclDataCell)
  protected
    procedure PaintDefault(AGrid: ThiiCustomGrid; ACanvas: TCanvas); override;
  end;

  TVclMegaDemoForm = class(TForm)
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
    SampleData: ThiiSampleClientDataset;
    DataSource: TDataSource;
    DataController: ThiiDatasetController;
    Grid: ThiiGrid;
    SplitView1: TSplitView;
    Properties: ThiiPropertyEditor;
    Splitter1: TSplitter;
    Panel1: TPanel;
    ActivityIndicator1: TActivityIndicator;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure OptionClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure MoveNameButtonClick(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetRowHeight(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean);
    procedure GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
  private
    FAllAdjacentGroupsCollapsed: Boolean;
    FSidebarReady: Boolean;
    FSidebarOverlay: Boolean;
    FSidebarUpdating: Boolean;
    FSidebarButton: TButton;
    procedure InitializePropertyEditor;
    procedure InitializeSidebar;
    procedure SidebarToggle(Sender: TObject);
    procedure SidebarMessage(var Msg: TMsg; var Handled: Boolean);
    procedure SidebarGridEnter(Sender: TObject);
    procedure SidebarIdle(Sender: TObject; var Done: Boolean);
    procedure ApplyOptions;
  protected
    procedure Resize; override;
  public
    procedure SetSidebarWidth(AWidth: Integer);
  end;

var
  VclMegaDemoForm: TVclMegaDemoForm;

implementation

{$R *.dfm}

type
  TSidebarSplitter = class(TSplitter)
  private
    FDragging: Boolean;
    FStartX: Integer;
    FStartWidth: Integer;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

procedure TSidebarSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then
    Exit;
  FStartX := ClientToScreen(Point(X, Y)).X;
  FStartWidth := TVclMegaDemoForm(Owner).SplitView1.OpenedWidth;
  FDragging := True;
  MouseCapture := True;
end;

procedure TSidebarSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
    TVclMegaDemoForm(Owner).SetSidebarWidth(FStartWidth + ClientToScreen(Point(X, Y)).X - FStartX);
end;

procedure TSidebarSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then
    Exit;
  FDragging := False;
  MouseCapture := False;
end;

procedure TVclMegaDemoForm.InitializePropertyEditor;
const
  CHiddenProperties = 'Name,Tag,Left,Top,Width,Height,Align,AlignWithMargins,Anchors,Constraints,Margins,Padding,Position,Size,Scale,'
    + 'RotationAngle,RotationCenter,TabOrder,TabStop,CanFocus,HitTest,AutoCapture,ClipChildren,ClipParent,Visible,'
    + 'DragMode,DragKind,DragCursor,Touch,Action,PopupMenu,Hint,ShowHint,ParentShowHint,CustomHint,ParentCustomHint,'
    + 'HelpContext,HelpKeyword,HelpType,StyleName,StyleLookup,Locked,Stored,DataController,SharedClassFactory,On*';
var
  LName: string;
  LFilter: ThiiPropertyFilter;
begin
  // Only the grid component's integration properties are hidden; widths/heights
  // inside grid options (headers, bands, columns) remain available.
  for LName in CHiddenProperties.Split([',']) do
  begin
    LFilter := Properties.PropertyEditor.Filters.Add;
    LFilter.ClassMask := 'ThiiCustomGrid';
    LFilter.NameMask := LName;
    LFilter.Hidden := True;
  end;
  Properties.DataObject := Grid;
end;

procedure TVclMegaDemoForm.InitializeSidebar;
var
  Events: TApplicationEvents;
begin
  // The resize grip belongs to the sidebar, also when it floats over the grid.
  Splitter1.Free;
  Splitter1 := TSidebarSplitter.Create(Self);
  Splitter1.Name := 'Splitter1';
  Splitter1.Parent := SplitView1;
  Splitter1.Align := alRight;
  Splitter1.Width := 8;
  Splitter1.Cursor := crHSplit;
  SplitView1.UseAnimation := False;
  SplitView1.CloseStyle := svcCollapse;
  SplitView1.CompactWidth := 0;
  SplitView1.OpenedWidth := 300;
  Button1.Caption := '×';
  Button1.Hint := 'Eigenschaften schließen/öffnen';
  Button1.ShowHint := True;
  Button1.OnClick := SidebarToggle;
  FSidebarButton := TButton.Create(Self);
  FSidebarButton.Name := 'SidebarToggleButton';
  FSidebarButton.Parent := Self;
  FSidebarButton.Align := alTop;
  FSidebarButton.Height := 28;
  FSidebarButton.Caption := 'Grid-Eigenschaften';
  FSidebarButton.OnClick := SidebarToggle;
  Events := TApplicationEvents.Create(Self);
  Events.OnMessage := SidebarMessage;
  Events.OnIdle := SidebarIdle;
  Grid.OnEnter := SidebarGridEnter;
  FSidebarReady := True;
  Resize;
end;

procedure TVclMegaDemoForm.SetSidebarWidth(AWidth: Integer);
begin
  SplitView1.OpenedWidth := EnsureRange(AWidth, Min(180, Max(80, ClientWidth - 40)), Max(80, ClientWidth - IfThen(FSidebarOverlay, 40, 280)));
end;

procedure TVclMegaDemoForm.Resize;
var
  Overlay: Boolean;
begin
  inherited;
  if not FSidebarReady or FSidebarUpdating then
    Exit;
  FSidebarUpdating := True;
  try
    Overlay := ClientWidth < 700;
    if Overlay then
    begin
      if not FSidebarOverlay or (SplitView1.DisplayMode <> svmOverlay) then
      begin
        SplitView1.Close;
        SplitView1.DisplayMode := svmOverlay;
      end;
      SplitView1.Top := Grid.Top;
      SplitView1.Height := Grid.Height;
    end
    else
    begin
      SplitView1.DisplayMode := svmDocked;
      if FSidebarOverlay or not SplitView1.Opened then SplitView1.Open;
    end;
    FSidebarOverlay := Overlay;
    SetSidebarWidth(SplitView1.OpenedWidth);
    FSidebarButton.Visible := Overlay;
    Button1.Visible := Overlay;
    SplitView1.BringToFront;
  finally
    FSidebarUpdating := False;
  end;
end;

procedure TVclMegaDemoForm.SidebarToggle(Sender: TObject);
begin
  SplitView1.Opened := not SplitView1.Opened;
  if SplitView1.Opened then SplitView1.BringToFront;
end;

procedure TVclMegaDemoForm.SidebarGridEnter(Sender: TObject);
begin
  if FSidebarOverlay then SplitView1.Close;
end;

procedure TVclMegaDemoForm.SidebarMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if not FSidebarOverlay or not SplitView1.Opened then
    Exit;
  if (Msg.message <> WM_LBUTTONDOWN) and (Msg.message <> WM_RBUTTONDOWN) and (Msg.message <> WM_MBUTTONDOWN) then
    Exit;
  if (Msg.hwnd <> Handle) and not IsChild(Handle, Msg.hwnd) then
    Exit;
  if (Msg.hwnd = SplitView1.Handle) or IsChild(SplitView1.Handle, Msg.hwnd) then
    Exit;
  if Msg.hwnd = FSidebarButton.Handle then
    Exit;
  SplitView1.Close;
end;


procedure TVclMegaDemoForm.SidebarIdle(Sender: TObject; var Done: Boolean);
begin
  if not FSidebarOverlay or not SplitView1.Opened or (ActiveControl = nil) then
    Exit;
  if (ActiveControl = FSidebarButton) or (ActiveControl = SplitView1) then
    Exit;
  if IsChild(SplitView1.Handle, ActiveControl.Handle) then
    Exit;
  SplitView1.Close;
end;

{ TPriorityDemoCell }

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

{ TVclDatasetDemoForm }

procedure TVclMegaDemoForm.ApplyOptions;
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

procedure TVclMegaDemoForm.FormCreate(Sender: TObject);
begin
  Grid.Customization.ColumnMovingGesture := ThiiColumnRowMovingGesture.Drag;
  if AdjacentBandModeCombo.ItemIndex < 0 then
    AdjacentBandModeCombo.ItemIndex := 3;
  FAllAdjacentGroupsCollapsed := False;

  if not SampleData.Active then
    SampleData.RecreateSampleData;

  Grid.FactoryScope.RegisterClass(h5uClassIdGridDataCell, ThiiVclVisualCell, TPriorityDemoCell, 100,
    function(const AContext: ThiiFactoryContext): Boolean
    begin
      Result := (AContext.Grid = Grid) and (AContext.Column is ThiiGridColumn) and SameText(ThiiGridColumn(AContext.Column).Id, 'priority');
    end);

  ApplyOptions;
  InitializePropertyEditor;
  InitializeSidebar;
end;

procedure TVclMegaDemoForm.GridGetRowHeight(Sender: TObject; const AContext: ThiiGetRowHeightContext; var AHeight: Integer; var ACacheResult: Boolean);
begin
  // Demonstrates the proposed value as a var parameter.
  if ((AContext.ViewRowIndex + 1) mod 9) = 0 then
    Inc(AHeight, 8);
end;

procedure TVclMegaDemoForm.GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
begin
  if AContext.Axis = ThiiScrollAxis.Vertical then
    AText := 'Datensatz: ' + AText;
end;

procedure TVclMegaDemoForm.MoveNameButtonClick(Sender: TObject);
var
  LColumn: ThiiGridColumn;
begin
  LColumn := Grid.Columns.FindById('name');
  if Assigned(LColumn) then
    Grid.MoveColumn(LColumn, Grid.Columns.Count - 1);
end;

procedure TVclMegaDemoForm.ToggleGroupsButtonClick(Sender: TObject);
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

procedure TVclMegaDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <> ThiiPaginationMode.NumberedPages then
    Exit;

  LPageCount := (DataController.GetTotalRowCount + DataController.Pagination.PageSize - 1) div DataController.Pagination.PageSize;

  DataController.Pagination.PageIndex := (DataController.Pagination.PageIndex + 1) mod Max(1, LPageCount);
end;

procedure TVclMegaDemoForm.OptionClick(Sender: TObject);
begin
  ApplyOptions;
end;

end.

