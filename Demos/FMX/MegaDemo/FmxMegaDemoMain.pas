unit FmxMegaDemoMain;

interface

{$SCOPEDENUMS ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([vcPublic, vcPublished]) FIELDS([])}

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.StrUtils,
  System.UITypes,
  System.TypInfo,
  System.Generics.Collections,  // for Th5uVirtualController
  System.Rtti,                  // for Th5uVirtualController
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
  FMX.ApplicationEvents,
  h5u.Grid.Types,
  h5u.Grid.Columns,
  h5u.Grid.Data.Core,
  h5u.Grid.Data.DataSet,  // for Th5uDatasetController + TDataSource + TDataSet(Th5uSampleClientDataSet)
  h5u.Grid.Data.Objects,  // for Th5uObjectListController + TDataRow(RTTI)
  h5u.Grid.Data.Virtual,  // for Th5uVirtualController + TDataRow(manual)
  h5u.Grid.SampleData,
  Fmx.h5u.Grid;

type
  TDataRow = class  // for Th5uObjectListController
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
    Grid: Th5uFmxGrid;
    SampleData: Th5uSampleClientDataSet;
    DataSource: TDataSource;
    DataController: Th5uDataSetController;
    MultiView1: TMultiView;
    AniIndicator1: TAniIndicator;
    ApplicationEvents: TApplicationEvents;
    StyleBook: TStyleBook;
    CornerButton1: TCornerButton;
    Expander1: TExpander;
    Layout2: TLayout;
    Expander2: TExpander;
    Expander3: TExpander;
    Expander4: TExpander;
    Expander5: TExpander;
    Label1: TLabel;
    edAGFIdColumn: TEdit;
    cbAGFEnabled: TSwitch;
    cbAGFEBVisibility: TComboBox;
    cbAGFEBColor: TColorComboBox;
    edAGFEBHeight: TSpinBox;
    cbOptAllowEditing: TSwitch;
    cbOptDefaultCellColor: TColorComboBox;
    edOptAutoWidthRowLimit: TSpinBox;
    VertScrollBox1: TVertScrollBox;
    cbCustAllowColumnHiding: TSwitch;
    cbCustAllowColumnMoving: TSwitch;
    cbCustAllowColumnResizing: TSwitch;
    cbCustAllowRowMoving: TSwitch;
    cbCustColumnMovingGesture: TComboBox;
    edCustColumnResizeHitZoneLeft: TSpinBox;
    edCustColumnResizeHitZoneRight: TSpinBox;
    edCustLastColumnResizeHitZoneLeft: TSpinBox;
    cbCustRowMovingGesture: TComboBox;
    cbCustShowColumnChooser: TSwitch;
    edCustTouchColumnResizeHitZoneLeft: TSpinBox;
    edCustTouchColumnResizeHitZoneRight: TSpinBox;
    edCustTouchLastColumnResizeHitZoneLeft: TSpinBox;
    Expander6: TExpander;
    Expander7: TExpander;
    Expander8: TExpander;
    ObjectController: Th5uObjectListController;
    VirtualController: Th5uVirtualController;
    UpdateTimer: TTimer;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    ComboBox9: TComboBox;
    ComboBox10: TComboBox;
    ComboBox11: TComboBox;
    cbOptGridLines: TSwitch;
    edOptHeaderRowHeight: TSpinBox;
    cbOptImmediateEdit: TSwitch;
    SpinBox9: TSpinBox;
    SpinBox10: TSpinBox;
    SpinBox11: TSpinBox;
    ComboBox12: TComboBox;
    SpinBox12: TSpinBox;
    ComboBox13: TComboBox;
    edOptRowIndicatorWidth: TSpinBox;
    cbAGFGroupEmptyValues: TSwitch;
    cbAGFShowFoldGlyph: TSwitch;
    GroupBox1: TGroupBox;
    cbAGFEBStyleName: TComboEdit;
    ToggleGroupsButton: TButton;
    {$ENDREGION}
    {$REGION 'Events'}
    procedure FormCreate(Sender: TObject);
    procedure ToggleGroupsButtonClick(Sender: TObject);
    procedure GridGetThumbHint(Sender: TObject; const AContext: Th5uFmxThumbHintContext; var AText: string; var AVisible: Boolean);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure VirtualControllerGetRowCount(Sender: TObject; var ARowCount: Int64);
    procedure VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
    procedure VirtualControllerGetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; var AValue: TValue);
    procedure VirtualControllerSetValue(Sender: TObject; ASourceRowIndex: Int64; const AFieldName: string; const AValue: TValue; var AHandled: Boolean);
    procedure edConfigChange(Sender: TObject);
    {$ENDREGION}
  private
    FLoading: Boolean;
    FRows: TObjectList<TDataRow>;  // for TDataRow/Th5uVirtualController
    FNextId: Integer;              // for TDataRow/Th5uObjectListController
    FAllAdjacentGroupsCollapsed: Boolean;
    procedure InitOptions;
    procedure LoadOptions;
    procedure ApplyOptions(Sender: TObject);
  private
    function GetEnumNames(Enum: PTypeInfo): string;
    function GetStyleNames: string;
  end;

var
  FmxMegaDemoForm: TFmxMegaDemoForm;

implementation

{$R *.fmx}

procedure TFmxMegaDemoForm.ApplyOptions(Sender: TObject);
var
  LPicture: Th5uGridColumn;
  LNameColumn: Th5uGridColumn;
  LActiveColumn: Th5uGridColumn;
  LDescriptionColumn: Th5uGridColumn;
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
//    DataController.Pagination.Mode := Th5uPaginationMode.NumberedPages;
//    DataController.Pagination.PageSize := 10;
//  end
//  else
//  begin
//    DataController.Pagination.Mode := Th5uPaginationMode.Continuous;
//    DataController.Pagination.PageIndex := 0;
//  end;
//  NextPageButton.Enabled := PagedCheck.IsChecked;
{
procedure TFmxMegaDemoForm.NextPageButtonClick(Sender: TObject);
var
  LPageCount: Integer;
begin
  if DataController.Pagination.Mode <> Th5uPaginationMode.NumberedPages then
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
  Grid.AdjacentGroupFolding.IdColumnId         := edAGFIdColumn.Text;
  Grid.AdjacentGroupFolding.Enabled            := cbAGFEnabled.IsChecked;
  Grid.AdjacentGroupFolding.GroupEmptyValues   := cbAGFGroupEmptyValues.IsChecked;
  Grid.AdjacentGroupFolding.ShowFoldGlyph      := cbAGFShowFoldGlyph.IsChecked;
  Grid.AdjacentGroupFolding.EndBand.Height     := Round(edAGFEBHeight.Value);
  Grid.AdjacentGroupFolding.EndBand.Visibility := Th5uAdjacentGroupEndBandVisibility(cbAGFEBVisibility.ItemIndex);
  Grid.AdjacentGroupFolding.EndBand.Color      := cbAGFEBColor.Color;
  Grid.AdjacentGroupFolding.EndBand.StyleName  := cbAGFEBStyleName.Text;
  ToggleGroupsButton.Enabled                   := cbAGFEnabled.IsChecked;

  { Grouping }

  { Sorting }

  { Options }
  Grid.AllowEditing                := cbOptAllowEditing.IsChecked;
  Grid.Appearance.DefaultCellColor := cbOptDefaultCellColor.Color;
  Grid.AutoWidthRowLimit           := Round(edOptAutoWidthRowLimit.Value);
  Grid.GridLines                   := cbOptGridLines.IsChecked;
  Grid.HeaderRowHeight             := edOptHeaderRowHeight.Value;
  Grid.ImmediateEdit               := cbOptImmediateEdit.IsChecked;
  Grid.RowIndicatorWidth           := edOptRowIndicatorWidth.Value;

  { Customization }
  Grid.Customization.AllowColumnHiding                := cbCustAllowColumnHiding.IsChecked;
  Grid.Customization.AllowColumnMoving                := cbCustAllowColumnMoving.IsChecked;
  Grid.Customization.AllowColumnResizing              := cbCustAllowColumnResizing.IsChecked;
  Grid.Customization.AllowRowMoving                   := cbCustAllowRowMoving.IsChecked;
  Grid.Customization.ColumnMovingGesture              := Th5uColumnRowMovingGesture(cbCustColumnMovingGesture.ItemIndex);
  Grid.Customization.ColumnResizeHitZoneLeft          := Round(edCustColumnResizeHitZoneLeft.Value);
  Grid.Customization.ColumnResizeHitZoneRight         := Round(edCustColumnResizeHitZoneRight.Value);
  Grid.Customization.LastColumnResizeHitZoneLeft      := Round(edCustLastColumnResizeHitZoneLeft.Value);
  Grid.Customization.RowMovingGesture                 := Th5uColumnRowMovingGesture(cbCustRowMovingGesture.ItemIndex);
  Grid.Customization.ShowColumnChooser                := cbCustShowColumnChooser.IsChecked;
  Grid.Customization.TouchColumnResizeHitZoneLeft     := Round(edCustTouchColumnResizeHitZoneLeft.Value);
  Grid.Customization.TouchColumnResizeHitZoneRight    := Round(edCustTouchColumnResizeHitZoneRight.Value);
  Grid.Customization.TouchLastColumnResizeHitZoneLeft := Round(edCustTouchLastColumnResizeHitZoneLeft.Value);

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
  Grid.Customization.ColumnMovingGesture := Th5uColumnRowMovingGesture.Drag;  // wird nicht in DFM gespeichert?

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
end;

function TFmxMegaDemoForm.GetEnumNames(Enum: PTypeInfo): string;
begin
  //Result := SetToString(Enum, ($1 shl Enum.TypeData.MaxValue) - 1, False).Replace(',', sLineBreak);   Benötigt einen SetTypen. Funktioniert nicht mit einem EnumTyp.
  Result := GetEnumName(Enum, 0);
  for var i := 1 to Enum.TypeData.MaxValue do
    Result := Result + sLineBreak + GetEnumName(Enum, 1);
end;

function TFmxMegaDemoForm.GetStyleNames: string;
begin
  Result := '';
end;

procedure TFmxMegaDemoForm.GridGetThumbHint(Sender: TObject; const AContext: Th5uFmxThumbHintContext; var AText: string; var AVisible: Boolean);
begin
  if AContext.Axis = Th5uScrollAxis.Vertical then
    AText := 'FMX: ' + AText;
end;

procedure TFmxMegaDemoForm.InitOptions;
begin
  FLoading := True;

  { AdjacentGroupFolding }
  cbAGFEBVisibility.Items.Text := GetEnumNames(TypeInfo(Th5uAdjacentGroupEndBandVisibility));
  cbAGFEBStyleName.Items.Text  := GetStyleNames;
  { Customization }
  cbCustColumnMovingGesture.Items.Text := GetEnumNames(TypeInfo(Th5uColumnRowMovingGesture));
  cbCustRowMovingGesture.Items.Text    := GetEnumNames(TypeInfo(Th5uColumnRowMovingGesture));

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

    else if (C is TLabel) and (TLabel(C).Hint = '') then begin
      TLabel(C).Hint     := TLabel(C).Text;
      TLabel(C).ShowHint := True;
    end;

  FLoading := False;
end;

procedure TFmxMegaDemoForm.LoadOptions;
begin
  FLoading := True;

  { AdjacentGroupFolding }
  edAGFIdColumn.Text              := Grid.AdjacentGroupFolding.IdColumnId;
  cbAGFEnabled.IsChecked          := Grid.AdjacentGroupFolding.Enabled;
  cbAGFGroupEmptyValues.IsChecked := Grid.AdjacentGroupFolding.GroupEmptyValues;
  cbAGFShowFoldGlyph.IsChecked    := Grid.AdjacentGroupFolding.ShowFoldGlyph;
  edAGFEBHeight.Value             := Grid.AdjacentGroupFolding.EndBand.Height;
  cbAGFEBVisibility.ItemIndex     := Ord(Grid.AdjacentGroupFolding.EndBand.Visibility);
  cbAGFEBColor.Color              := Grid.AdjacentGroupFolding.EndBand.Color;
  cbAGFEBStyleName.Text           := Grid.AdjacentGroupFolding.EndBand.StyleName;
  ToggleGroupsButton.Enabled      := cbAGFEnabled.IsChecked;

  { Grouping }

  { Sorting }

  { Options }
  cbOptAllowEditing.IsChecked  := Grid.AllowEditing;
  cbOptDefaultCellColor.Color  := Grid.Appearance.DefaultCellColor;
  edOptAutoWidthRowLimit.Value := Grid.AutoWidthRowLimit;
  cbOptGridLines.IsChecked     := Grid.GridLines;
  edOptHeaderRowHeight.Value   := Grid.HeaderRowHeight;
  cbOptImmediateEdit.IsChecked := Grid.ImmediateEdit;
  edOptRowIndicatorWidth.Value := Grid.RowIndicatorWidth;

  { Customization }
  cbCustAllowColumnHiding.IsChecked            := Grid.Customization.AllowColumnHiding;
  cbCustAllowColumnMoving.IsChecked            := Grid.Customization.AllowColumnMoving;
  cbCustAllowColumnResizing.IsChecked          := Grid.Customization.AllowColumnResizing;
  cbCustAllowRowMoving.IsChecked               := Grid.Customization.AllowRowMoving;
  cbCustColumnMovingGesture.ItemIndex          := Ord(Grid.Customization.ColumnMovingGesture);
  edCustColumnResizeHitZoneLeft.Value          := Grid.Customization.ColumnResizeHitZoneLeft;
  edCustColumnResizeHitZoneRight.Value         := Grid.Customization.ColumnResizeHitZoneRight;
  edCustLastColumnResizeHitZoneLeft.Value      := Grid.Customization.LastColumnResizeHitZoneLeft;
  cbCustRowMovingGesture.ItemIndex             := Ord(Grid.Customization.RowMovingGesture);
  cbCustShowColumnChooser.IsChecked            := Grid.Customization.ShowColumnChooser;
  edCustTouchColumnResizeHitZoneLeft.Value     := Grid.Customization.TouchColumnResizeHitZoneLeft;
  edCustTouchColumnResizeHitZoneRight.Value    := Grid.Customization.TouchColumnResizeHitZoneRight;
  edCustTouchLastColumnResizeHitZoneLeft.Value := Grid.Customization.TouchLastColumnResizeHitZoneLeft;

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

procedure TFmxMegaDemoForm.VirtualControllerGetRowKey(Sender: TObject; ASourceRowIndex: Int64; var ARowKey: Th5uRowKey);
begin
//  if not Assigned(FRows) then
//    Exit;
//  if (ASourceRowIndex >= 0) and (ASourceRowIndex < FRows.Count) then
//    ARowKey := Th5uRowKey.FromInt64(FRows[ASourceRowIndex].Id);
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
//  case IndexText(AFieldName, ['id', 'name', 'category', 'description', 'quantity', 'unit_price', 'priority', 'active', 'updated_at', 'picture', 'fold_group']) of
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
//  case IndexText(AFieldName, ['id', 'name', 'category', 'description', 'quantity', 'unit_price', 'priority', 'active', 'updated_at', 'picture', 'fold_group']) of
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
  if Assigned(APicture) then begin
    if not Assigned(FPicture) then
      FPicture := TBitmap.Create(APicture.Width, APicture.Height);
    FPicture.Assign(APicture);
  end else
    FreeAndNil(FPicture);
end;

end.

