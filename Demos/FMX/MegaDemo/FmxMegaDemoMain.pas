unit FmxMegaDemoMain;

interface

{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  System.Classes,
  System.Types,
  System.Math,
  System.SysUtils,
  System.StrUtils,
  System.UITypes,
  System.TypInfo,
  System.Generics.Collections,  // for ThiiVirtualController
  System.Rtti,                  // for ThiiVirtualController
  Data.DB,
  Datasnap.DBClient,
  FMX.Types,
  FMX.Colors,
  FMX.Platform,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Graphics,
  FMX.Forms,
  FMX.Layouts,
  FMX.ListBox,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.EditBox,
  FMX.ComboEdit,
  FMX.NumberBox,
  FMX.SpinBox,
  FMX.MultiView,
  FMX.MultiView.Types,
  FMX.ApplicationEvents,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.DataSet,  // for ThiiDatasetController + TDataSource + TDataSet(ThiiSampleClientDataset)
  h5u.Grid.Data.Objects,  // for ThiiObjectListController + TDataRow(RTTI)
  h5u.Grid.Data.Virtual,  // for ThiiVirtualController + TDataRow(manual)
  h5u.Grid.SampleData,
  Fmx.h5u.Grid,
  Fmx.h5u.PropertyEditor;

type
  TDataRow = class  // for ThiiObjectListController
  private
    {$REGION 'Fields'}
    FId: Int64;
    FName: string;
    FCategory: string;
    FDescription: string;
    FQuantity: Integer;
    FUnitPrice: Currency;
    FPriority: Integer;
    FActive: Boolean;
    FUpdatedAt: TDateTime;
    FPicture: TBitmap;
    FFoldGroup: Integer;
    procedure SetPicture(APicture: TBitmap);
    {$ENDREGION}
  public
    destructor Destroy; override;
    property id: Int64 read FId write FId;
    property name: string read FName write FName;
    property category: string read FCategory write FCategory;
    property description: string read FDescription write FDescription;
    property quantity: Integer read FQuantity write FQuantity;
    property unit_price: Currency read FUnitPrice write FUnitPrice;
    property priority: Integer read FPriority write FPriority;
    property active: Boolean read FActive write FActive;
    property updated_at: TDateTime read FUpdatedAt write FUpdatedAt;
    property picture: TBitmap read FPicture write SetPicture;
    property fold_group: Integer read FFoldGroup write FFoldGroup;
  end;

  TFmxMegaDemoForm = class(TForm)
    Grid: ThiiGrid;
    SampleData: ThiiSampleClientDataset;
    DataSource: TDataSource;
    DataController: ThiiDatasetController;
    MultiView1: TMultiView;
    AniIndicator1: TAniIndicator;
    ApplicationEvents: TApplicationEvents;
    StyleBook: TStyleBook;
    CornerButton1: TCornerButton;
    Layout2: TLayout;
    ObjectController: ThiiObjectListController;
    VirtualController: ThiiVirtualController;
    UpdateTimer: TTimer;
    ToggleGroupsButton: TButton;
    Properties: ThiiPropertyEditor;
    Splitter1: TSplitter;
    {$ENDREGION}
    {$REGION 'Events'}
    procedure FormCreate(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
    procedure VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: ThiiRowKey);
    procedure VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
    procedure VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
    procedure edConfigChange(Sender: TObject);
    {$ENDREGION}
  private
    FLoading: Boolean;
    FRows: TObjectList<TDataRow>;  // for TDataRow/ThiiVirtualController
    FNextId: Integer;              // for TDataRow/ThiiObjectListController
    FAllAdjacentGroupsCollapsed: Boolean;
    FSidebarReady: Boolean;
    FSidebarOverlay: Boolean;
    FSidebarUpdating: Boolean;
    FSidebarButton: TButton;
    procedure InitializePropertyEditor;
    procedure InitializeSidebar;
    procedure SidebarToggle(Sender: TObject);
    procedure SidebarFocusChanged(Sender: TObject);
    procedure InitOptions;
    procedure LoadOptions;
    procedure ApplyOptions(Sender: TObject);
  private
    function GetEnumNames(Enum: PTypeInfo): string;
    function GetStyleNames: string;
  protected
    procedure Resize; override;
  public
    procedure SetSidebarWidth(AWidth: Single);
  end;

var
  FmxMegaDemoForm: TFmxMegaDemoForm;

implementation

{$R *.fmx}

type
  TSidebarSplitter = class(TSplitter)
  private
    FDragging: Boolean;
    FStartX: Single;
    FStartWidth: Single;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  end;

procedure TSidebarSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;
  FStartX := LocalToAbsolute(TPointF.Create(X, Y)).X;
  FStartWidth := TFmxMegaDemoForm(Owner).MultiView1.Width;
  FDragging := True;
  Capture;
end;

procedure TSidebarSplitter.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  if FDragging then
    TFmxMegaDemoForm(Owner).SetSidebarWidth(FStartWidth + LocalToAbsolute(TPointF.Create(X, Y)).X - FStartX);
end;

procedure TSidebarSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;
  FDragging := False;
  ReleaseCapture;
end;

procedure TFmxMegaDemoForm.InitializePropertyEditor;
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

procedure TFmxMegaDemoForm.InitializeSidebar;
begin
  Splitter1.Free;
  Splitter1 := TSidebarSplitter.Create(Self);
  Splitter1.Name := 'Splitter1';
  Splitter1.Parent := MultiView1;
  Splitter1.Align := TAlignLayout.Right;
  Splitter1.Width := 8;
  Splitter1.Cursor := crHSplit;
  Splitter1.HitTest := True;
  Grid.Margins.Left := 0;
  MultiView1.Mode := TMultiViewMode.Panel;
  MultiView1.Width := 300;
  MultiView1.DrawerOptions.Placement := TPanelPlacement.Left;
  MultiView1.DrawerOptions.Mode := TSlidingMode.OverlapDetailView;
  MultiView1.DrawerOptions.DurationSliding := 0;
  CornerButton1.Text := '×';
  CornerButton1.OnClick := SidebarToggle;
  FSidebarButton := TButton.Create(Self);
  FSidebarButton.Name := 'SidebarToggleButton';
  FSidebarButton.Parent := Self;
  FSidebarButton.Align := TAlignLayout.Top;
  FSidebarButton.Height := 32;
  FSidebarButton.Text := 'Grid-Eigenschaften';
  // Drawer presentation manages the master button's click and visibility.
  MultiView1.MasterButton := FSidebarButton;
  OnFocusChanged := SidebarFocusChanged;
  FSidebarReady := True;
  Resize;
end;

procedure TFmxMegaDemoForm.SetSidebarWidth(AWidth: Single);
begin
  MultiView1.Width := EnsureRange(AWidth, Min(180.0, Max(80.0, ClientWidth - 40.0)), Max(80.0, ClientWidth - IfThen(FSidebarOverlay, 40.0, 280.0)));
  MultiView1.UpdateAlignment;
end;

procedure TFmxMegaDemoForm.Resize;
var
  Overlay: Boolean;
begin
  inherited;
  if not FSidebarReady or FSidebarUpdating then
    Exit;
  FSidebarUpdating := True;
  try
    Overlay := ClientWidth < 700;
    {$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    Overlay := Overlay or (ClientWidth < ClientHeight);
    {$ENDIF}
    if Overlay then
    begin
      if MultiView1.Mode <> TMultiViewMode.Drawer then
      begin
        MultiView1.Mode := TMultiViewMode.Drawer;
        MultiView1.HideMaster;
      end;
    end
    else
    begin
      if MultiView1.Mode <> TMultiViewMode.Panel then MultiView1.Mode := TMultiViewMode.Panel;
      MultiView1.ShowMaster;
    end;
    FSidebarOverlay := Overlay;
    CornerButton1.Visible := Overlay;
    SetSidebarWidth(MultiView1.Width);
  finally
    FSidebarUpdating := False;
  end;
end;

procedure TFmxMegaDemoForm.SidebarToggle(Sender: TObject);
begin
  if MultiView1.IsShowed then MultiView1.HideMaster else MultiView1.ShowMaster;
end;

procedure TFmxMegaDemoForm.SidebarFocusChanged(Sender: TObject);
var
  Control: TFmxObject;
begin
  if not FSidebarOverlay or not MultiView1.IsShowed or (Focused = nil) then
    Exit;
  Control := Focused.GetObject;
  while Control <> nil do
  begin
    if (Control = MultiView1) or (Control = FSidebarButton) then
      Exit;
    Control := Control.Parent;
  end;
  MultiView1.HideMaster;
end;


procedure TFmxMegaDemoForm.ApplyOptions(Sender: TObject);
var
  LPicture: ThiiGridColumn;
  LNameColumn: ThiiGridColumn;
  LActiveColumn: ThiiGridColumn;
  LDescriptionColumn: ThiiGridColumn;
begin
  if FLoading or (csLoading in Self.ComponentState) then
    Exit;

  {$REGION 'MyRegion'}
//  if EveryFifthCheck.IsChecked then
//  begin
//    Grid.RowStyles.StripePeriod := 5;
//    Grid.RowStyles.StripeOffset := 5;
//  end
//  else
//  begin
//    Grid.RowStyles.StripePeriod := 2;
//    Grid.RowStyles.StripeOffset := 1;
//  end;

//  if PagedCheck.IsChecked then
//  begin
//    DataController.Pagination.Mode := ThiiPaginationMode.NumberedPages;
//    DataController.Pagination.PageSize := 10;
//  end
//  else
//  begin
//    DataController.Pagination.Mode := ThiiPaginationMode.Continuous;
//    DataController.Pagination.PageIndex := 0;
//  end;
//  NextPageButton.Enabled := PagedCheck.IsChecked;
{
procedure TFmxMegaDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <> ThiiPaginationMode.NumberedPages then
    Exit;
  LPageCount := (DataController.GetTotalRowCount + DataController.Pagination.PageSize - 1) div DataController.Pagination.PageSize;
  DataController.Pagination.PageIndex := (DataController.Pagination.PageIndex + 1) mod Max(1, LPageCount);
end;
}

//  LDescriptionColumn := Grid.Columns.FindById('description');
//  if Assigned(LDescriptionColumn) then
//    LDescriptionColumn.RightSpacing := 8;

//  LNameColumn := Grid.Columns.FindById('name');
//  LActiveColumn := Grid.Columns.FindById('active');
//  if ColumnColorsCheck.IsChecked then
//  begin
//    if DarkCheck.IsChecked then
//    begin
//      Grid.Appearance.DefaultCellColor := $001F1F1F;
//      if Assigned(LNameColumn) then
//        LNameColumn.Color := $00362B1F;
//      if Assigned(LActiveColumn) then
//        LActiveColumn.Color := $0022311D;
//    end
//    else
//    begin
//      Grid.Appearance.DefaultCellColor := $00FDFDFD;
//      if Assigned(LNameColumn) then
//        LNameColumn.Color := $00FFF4EA;
//      if Assigned(LActiveColumn) then
//        LActiveColumn.Color := $00ECF8EA;
//    end;
//  end
//  else
//  begin
//    Grid.Appearance.DefaultCellColor := TColorRec.SysDefault;
//    if Assigned(LNameColumn) then
//      LNameColumn.Color := TColorRec.SysDefault;
//    if Assigned(LActiveColumn) then
//      LActiveColumn.Color := TColorRec.SysDefault;
//  end;

//  LPicture := Grid.Columns.FindById('picture');
//  if Assigned(LPicture) then
//    Grid.SetColumnVisible(LPicture, PictureCheck.IsChecked);
  {$ENDREGION}

  { AdjacentGroupFolding }
//  Grid.AdjacentGroupFolding.IdColumnId         := edAGFIdColumn.Text;
//  Grid.AdjacentGroupFolding.Enabled            := cbAGFEnabled.IsChecked;
//  Grid.AdjacentGroupFolding.GroupEmptyValues   := cbAGFGroupEmptyValues.IsChecked;
//  Grid.AdjacentGroupFolding.ShowFoldGlyph      := cbAGFShowFoldGlyph.IsChecked;
//  Grid.AdjacentGroupFolding.EndBand.Height     := Round(edAGFEBHeight.Value);
//  Grid.AdjacentGroupFolding.EndBand.Visibility := ThiiAdjacentGroupEndBandVisibility(cbAGFEBVisibility.ItemIndex);
//  Grid.AdjacentGroupFolding.EndBand.Color      := cbAGFEBColor.Color;
//  Grid.AdjacentGroupFolding.EndBand.StyleName  := cbAGFEBStyleName.Text;
//  ToggleGroupsButton.Enabled                   := cbAGFEnabled.IsChecked;

  { Grouping }

  { Sorting }

  { Options }
//  Grid.AllowEditing                := cbOptAllowEditing.IsChecked;
//  Grid.Appearance.DefaultCellColor := cbOptDefaultCellColor.Color;
//  Grid.AutoWidthRowLimit           := Round(edOptAutoWidthRowLimit.Value);
//  Grid.GridLines                   := cbOptGridLines.IsChecked;
//  Grid.HeaderRowHeight             := edOptHeaderRowHeight.Value;
//  Grid.ImmediateEdit               := cbOptImmediateEdit.IsChecked;
//  Grid.RowIndicatorWidth           := edOptRowIndicatorWidth.Value;

  { Customization }
//  Grid.Customization.AllowColumnHiding                := cbCustAllowColumnHiding.IsChecked;
//  Grid.Customization.AllowColumnMoving                := cbCustAllowColumnMoving.IsChecked;
//  Grid.Customization.AllowColumnResizing              := cbCustAllowColumnResizing.IsChecked;
//  Grid.Customization.AllowRowMoving                   := cbCustAllowRowMoving.IsChecked;
//  Grid.Customization.ColumnMovingGesture              := ThiiColumnRowMovingGesture(cbCustColumnMovingGesture.ItemIndex);
//  Grid.Customization.ColumnResizeHitZoneLeft          := Round(edCustColumnResizeHitZoneLeft.Value);
//  Grid.Customization.ColumnResizeHitZoneRight         := Round(edCustColumnResizeHitZoneRight.Value);
//  Grid.Customization.LastColumnResizeHitZoneLeft      := Round(edCustLastColumnResizeHitZoneLeft.Value);
//  Grid.Customization.RowMovingGesture                 := ThiiColumnRowMovingGesture(cbCustRowMovingGesture.ItemIndex);
//  Grid.Customization.ShowColumnChooser                := cbCustShowColumnChooser.IsChecked;
//  Grid.Customization.TouchColumnResizeHitZoneLeft     := Round(edCustTouchColumnResizeHitZoneLeft.Value);
//  Grid.Customization.TouchColumnResizeHitZoneRight    := Round(edCustTouchColumnResizeHitZoneRight.Value);
//  Grid.Customization.TouchLastColumnResizeHitZoneLeft := Round(edCustTouchLastColumnResizeHitZoneLeft.Value);

  if Sender = nil then
    Grid.InvalidateAllRowHeights;
  Grid.Repaint;
end;

procedure TFmxMegaDemoForm.edConfigChange(Sender: TObject);
begin
  ApplyOptions(Sender);
end;

procedure TFmxMegaDemoForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FLoading := True;
  Grid.Customization.ColumnMovingGesture := ThiiColumnRowMovingGesture.Drag;  // wird nicht in DFM gespeichert?

  FAllAdjacentGroupsCollapsed := False;

  if not SampleData.Active then
    SampleData.RecreateSampleData;

  ObjectController.BeginUpdate;
  try
    //for I := 1 to 80 do
    //  AddPerson;
    {
function TFmxObjectDemoForm.AddPerson: TPersonRow;
const
  CDepartments: array[0..4] of string = ('Fertigung', 'Konstruktion', 'Einkauf', 'QS', 'Vertrieb');
begin
  Inc(FNextId);
  Result := TPersonRow.Create;
  Result.Id := FNextId;
  Result.Name := Format('Objekt %d', [FNextId]);
  Result.Department := CDepartments[FNextId mod Length(CDepartments)];
  Result.Active := (FNextId mod 5) <> 0;
  Result.Priority := FNextId mod 4;
  Result.Amount := 800 + FNextId * 31.45;
  Result.UpdatedAt := IncMinute(Now, -FNextId);
  if (FNextId mod 6) = 0 then
    Result.Notes := 'Mehrzeiliger RTTI-Inhalt. Der ObjectListController kann direkt aus der Liste lesen oder Werte optional cachen.'
  else
    Result.Notes := 'Kurzer Objekteintrag.';
  ObjectController.Add(Result);
end;
    }
  finally
    ObjectController.EndUpdate;
  end;

  //FRows := TObjectList<TDataRow>.Create(True);
  //for I := 1 to 60 do
  //  AppendRow;

  InitOptions;
  LoadOptions;
  ApplyOptions(nil);  // für die alten Options in der ToolBar
  FLoading := False;
  InitializePropertyEditor;
  InitializeSidebar;
end;

function TFmxMegaDemoForm.GetEnumNames(Enum: PTypeInfo): string;
begin
  //Result := SetToString(Enum, ($1 shl Enum.TypeData.MaxValue) - 1, False).Replace(',', sLineBreak);   Benötigt einen SetTypen.
// Funktioniert nicht mit einem EnumTyp.
  Result := GetEnumName(Enum, 0);
  for var i := 1 to Enum.TypeData.MaxValue do
    Result := Result + sLineBreak + GetEnumName(Enum, 1);
end;

function TFmxMegaDemoForm.GetStyleNames: string;
begin
  Result := '';
end;

procedure TFmxMegaDemoForm.GridGetThumbHint(Sender: TObject; const AContext: ThiiThumbHintContext; var AText: string; var AVisible: Boolean);
begin
  if AContext.Axis = ThiiScrollAxis.Vertical then
    AText := 'FMX: ' + AText;
end;

procedure TFmxMegaDemoForm.InitOptions;
begin
  FLoading := True;

  { AdjacentGroupFolding }
//  cbAGFEBVisibility.Items.Text := GetEnumNames(TypeInfo(ThiiAdjacentGroupEndBandVisibility));
//  cbAGFEBStyleName.Items.Text  := GetStyleNames;
  { Customization }
//  cbCustColumnMovingGesture.Items.Text := GetEnumNames(TypeInfo(ThiiColumnRowMovingGesture));
//  cbCustRowMovingGesture.Items.Text    := GetEnumNames(TypeInfo(ThiiColumnRowMovingGesture));

  for var C in Self do
    if C is TCustomEdit then
      TEdit(C).OnChange := edConfigChange  // TEdit TComboEdit TSpinBox

    else if C is TComboBox then
      TComboBox(C).OnChange := edConfigChange

    else if C is TColorComboBox then
      TColorComboBox(C).OnChange := edConfigChange

    else if C is TCheckBox then
      TCheckBox(C).OnChange := edConfigChange

    else if C is TSwitch then
      TSwitch(C).OnSwitch := edConfigChange

    else if (C is TLabel) and (TLabel(C).Hint = '') then
    begin
      TLabel(C).Hint     := TLabel(C).Text;
      TLabel(C).ShowHint := True;
    end;

  FLoading := False;
end;

procedure TFmxMegaDemoForm.LoadOptions;
begin
  FLoading := True;

  { AdjacentGroupFolding }
//  edAGFIdColumn.Text              := Grid.AdjacentGroupFolding.IdColumnId;
//  cbAGFEnabled.IsChecked          := Grid.AdjacentGroupFolding.Enabled;
//  cbAGFGroupEmptyValues.IsChecked := Grid.AdjacentGroupFolding.GroupEmptyValues;
//  cbAGFShowFoldGlyph.IsChecked    := Grid.AdjacentGroupFolding.ShowFoldGlyph;
//  edAGFEBHeight.Value             := Grid.AdjacentGroupFolding.EndBand.Height;
//  cbAGFEBVisibility.ItemIndex     := Ord(Grid.AdjacentGroupFolding.EndBand.Visibility);
//  cbAGFEBColor.Color              := Grid.AdjacentGroupFolding.EndBand.Color;
//  cbAGFEBStyleName.Text           := Grid.AdjacentGroupFolding.EndBand.StyleName;
//  ToggleGroupsButton.Enabled      := cbAGFEnabled.IsChecked;

  { Grouping }

  { Sorting }

  { Options }
//  cbOptAllowEditing.IsChecked  := Grid.AllowEditing;
//  cbOptDefaultCellColor.Color  := Grid.Appearance.DefaultCellColor;
//  edOptAutoWidthRowLimit.Value := Grid.AutoWidthRowLimit;
//  cbOptGridLines.IsChecked     := Grid.GridLines;
//  edOptHeaderRowHeight.Value   := Grid.HeaderRowHeight;
//  cbOptImmediateEdit.IsChecked := Grid.ImmediateEdit;
//  edOptRowIndicatorWidth.Value := Grid.RowIndicatorWidth;

  { Customization }
//  cbCustAllowColumnHiding.IsChecked            := Grid.Customization.AllowColumnHiding;
//  cbCustAllowColumnMoving.IsChecked            := Grid.Customization.AllowColumnMoving;
//  cbCustAllowColumnResizing.IsChecked          := Grid.Customization.AllowColumnResizing;
//  cbCustAllowRowMoving.IsChecked               := Grid.Customization.AllowRowMoving;
//  cbCustColumnMovingGesture.ItemIndex          := Ord(Grid.Customization.ColumnMovingGesture);
//  edCustColumnResizeHitZoneLeft.Value          := Grid.Customization.ColumnResizeHitZoneLeft;
//  edCustColumnResizeHitZoneRight.Value         := Grid.Customization.ColumnResizeHitZoneRight;
//  edCustLastColumnResizeHitZoneLeft.Value      := Grid.Customization.LastColumnResizeHitZoneLeft;
//  cbCustRowMovingGesture.ItemIndex             := Ord(Grid.Customization.RowMovingGesture);
//  cbCustShowColumnChooser.IsChecked            := Grid.Customization.ShowColumnChooser;
//  edCustTouchColumnResizeHitZoneLeft.Value     := Grid.Customization.TouchColumnResizeHitZoneLeft;
//  edCustTouchColumnResizeHitZoneRight.Value    := Grid.Customization.TouchColumnResizeHitZoneRight;
//  edCustTouchLastColumnResizeHitZoneLeft.Value := Grid.Customization.TouchLastColumnResizeHitZoneLeft;

  FLoading := False;
end;

procedure TFmxMegaDemoForm.ToggleGroupsButtonClick(Sender: TObject);
begin
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

procedure TFmxMegaDemoForm.UpdateTimerTimer(Sender: TObject);
//var
//  LIndex: Integer;
//  LPerson: TPersonRow;
begin
//  if ObjectController.Count = 0 then
//    Exit;
//  LIndex := Random(ObjectController.Count);
//  LPerson := TPersonRow(ObjectController.Item(LIndex));
//  LPerson.Amount := LPerson.Amount + 7.5;
//  LPerson.Priority := (LPerson.Priority + 1) mod 4;
//  LPerson.UpdatedAt := Now;
//  ObjectController.NotifyObjectChanged(LPerson);
end;

procedure TFmxMegaDemoForm.VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
begin
//  ARowCount := 0;
//  if Assigned(FRows) then
//    ARowCount := FRows.Count;
end;

procedure TFmxMegaDemoForm.VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: ThiiRowKey);
begin
//  if not Assigned(FRows) then
//    Exit;
//  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
//    ARowKey := ThiiRowKey.FromInt64(FRows[ASourceRowIndex].Id);
end;

procedure TFmxMegaDemoForm.VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
//var
//  LRow: TDataRow;
begin
//  if not Assigned(FRows) then
//    Exit;
//  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
//    Exit;
//  LRow := FRows[ASourceRowIndex];
//
//  case IndexText(AFieldName, ['id', 'name', 'category', 'description', 'quantity', 'unit_price', 'priority', 'active', 'updated_at',
// 'picture', 'fold_group']) of
//    0: AValue := TValue.From<Int64>(LRow.id);
//    1: AValue := TValue.From<string>(LRow.name);
//    2: AValue := TValue.From<string>(LRow.category);
//    3: AValue := TValue.From<string>(LRow.description);
//    4: AValue := TValue.From<Integer>(LRow.quantity);
//    5: AValue := TValue.From<Currency>(LRow.unit_price);
//    6: AValue := TValue.From<Integer>(LRow.priority);
//    7: AValue := TValue.From<Boolean>(LRow.active);
//    8: AValue := TValue.From<TDateTime>(LRow.updated_at);
//    9: AValue := TValue.From<TBitmap>(LRow.picture);
//    10: AValue := TValue.From<Integer>(LRow.fold_group);
//  end;
end;

procedure TFmxMegaDemoForm.VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
//var
//  LRow: TDataRow;
begin
//  AHandled := False;
//  if not Assigned(FRows) then
//    Exit;
//  if (ASourceRowIndex < 0) or (ASourceRowIndex >= FRows.Count) then
//    Exit;
//  LRow := FRows[ASourceRowIndex];
//
//  case IndexText(AFieldName, ['id', 'name', 'category', 'description', 'quantity', 'unit_price', 'priority', 'active', 'updated_at',
// 'picture', 'fold_group']) of
//    //0: LRow.id        := AValue.AsInt64;
//    1: LRow.name        := AValue.AsString;
//    2: LRow.category    := AValue.AsString;
//    3: LRow.description := AValue.AsString;
//    4: LRow.quantity    := AValue.AsInteger;
//    5: LRow.unit_price  := AValue.AsCurrency;
//    6: LRow.priority    := AValue.AsInteger;
//    7: LRow.active      := AValue.AsBoolean;
//    8: LRow.updated_at  := AValue.AsType<TDateTime>;
//    9: LRow.picture     := AValue.AsObject;
//    10: LRow.fold_group := AValue.AsInteger;
//    else Exit;
//  end;
//  AHandled := True;
end;

{ TDataRow }

destructor TDataRow.Destroy;
begin
  FreeAndNil(FPicture);
  inherited;
end;

procedure TDataRow.SetPicture(APicture: TBitmap);
begin
  if Assigned(APicture) then
  begin
    if not Assigned(FPicture) then
      FPicture := TBitmap.Create(APicture.Width, APicture.Height);
    FPicture.Assign(APicture);
  end else
    FreeAndNil(FPicture);
end;

end.

