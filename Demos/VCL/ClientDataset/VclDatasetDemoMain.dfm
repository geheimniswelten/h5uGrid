object VclDatasetDemoForm: TVclDatasetDemoForm
  Left = 0
  Top = 0
  Caption = 'h5u.Grid VCL - TClientDataset / Designer-Demo'
  ClientHeight = 650
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object OptionsPanel: TPanel
    Left = 0
    Top = 0
    Width = 1120
    Height = 104
    Align = alTop
    TabOrder = 0
    object InfoLabel: TLabel
      Left = 12
      Top = 76
      Width = 828
      Height = 15
      Caption = 
        'Designer-Test: Musterdaten, Tree und Folgegruppen sind vorgef'#252'll' +
        't. Das +/- im Zeilenkopf faltet nur direkt aufeinanderfolgende g' +
        'leiche FOLD_GROUP-Werte.'
    end
    object AdjacentBandModeLabel: TLabel
      Left = 666
      Top = 44
      Width = 83
      Height = 15
      Caption = 'Abschlussleiste:'
    end
    object AutoHeightCheck: TCheckBox
      Left = 12
      Top = 12
      Width = 112
      Height = 20
      Caption = 'AutoHeight'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = OptionClick
    end
    object MultiHeaderCheck: TCheckBox
      Left = 130
      Top = 12
      Width = 144
      Height = 20
      Caption = 'Mehrzeiliger Header'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = OptionClick
    end
    object EveryFifthCheck: TCheckBox
      Left = 280
      Top = 12
      Width = 135
      Height = 20
      Caption = 'Jede 5. Zeile'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = OptionClick
    end
    object PagedCheck: TCheckBox
      Left = 420
      Top = 12
      Width = 94
      Height = 20
      Caption = 'Pagination'
      TabOrder = 3
      OnClick = OptionClick
    end
    object CacheCheck: TCheckBox
      Left = 520
      Top = 12
      Width = 98
      Height = 20
      Caption = 'Page-Cache'
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = OptionClick
    end
    object DarkCheck: TCheckBox
      Left = 624
      Top = 12
      Width = 89
      Height = 20
      Caption = 'Dark Mode'
      TabOrder = 5
      OnClick = OptionClick
    end
    object PictureCheck: TCheckBox
      Left = 719
      Top = 12
      Width = 87
      Height = 20
      Caption = 'Bildspalte'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = OptionClick
    end
    object SeparatorsCheck: TCheckBox
      Left = 12
      Top = 42
      Width = 122
      Height = 20
      Caption = '1 px Trennlinien'
      Checked = True
      State = cbChecked
      TabOrder = 9
      OnClick = OptionClick
    end
    object ColumnColorsCheck: TCheckBox
      Left = 142
      Top = 42
      Width = 126
      Height = 20
      Caption = 'Spaltenfarben'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = OptionClick
    end
    object TreeEndBandCheck: TCheckBox
      Left = 278
      Top = 42
      Width = 190
      Height = 20
      Caption = 'Tree-Abschlussleiste'
      Checked = True
      State = cbChecked
      TabOrder = 11
      OnClick = OptionClick
    end
    object AdjacentGroupCheck: TCheckBox
      Left = 478
      Top = 42
      Width = 182
      Height = 20
      Caption = 'Folgegruppen falten'
      Checked = True
      State = cbChecked
      TabOrder = 12
      OnClick = OptionClick
    end
    object AdjacentBandModeCombo: TComboBox
      Left = 770
      Top = 39
      Width = 150
      Height = 23
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 13
      Text = 'Immer'
      OnChange = OptionClick
      Items.Strings = (
        'Nie'
        'Nur eingeklappt'
        'Nur ausgeklappt'
        'Immer')
    end
    object ToggleGroupsButton: TButton
      Left = 928
      Top = 38
      Width = 112
      Height = 28
      Caption = 'Alle falten'
      TabOrder = 14
      OnClick = ToggleGroupsButtonClick
    end
    object NextPageButton: TButton
      Left = 816
      Top = 8
      Width = 112
      Height = 29
      Caption = 'N'#228'chste Seite'
      TabOrder = 7
      OnClick = NextPageButtonClick
    end
    object MoveNameButton: TButton
      Left = 936
      Top = 8
      Width = 165
      Height = 29
      Caption = 'Name nach rechts'
      TabOrder = 8
      OnClick = MoveNameButtonClick
    end
  end
  object Grid: Th5uVclGrid
    Left = 0
    Top = 104
    Width = 1120
    Height = 546
    Align = alClient
    TabOrder = 1
    TabStop = True
    DataController = DataController
    Columns = <
      item
        Id = 'id'
        Caption = 'ID'
        FieldName = 'ID'
        Width = 72
        VisibleIndex = 0
        FixedKind = Left
        ReadOnly = True
        DataType = Integer
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'name'
        Caption = 'Name'
        FieldName = 'NAME'
        Width = 145
        VisibleIndex = 1
        DataType = Text
        ScrollHintText = 'Artikelname'
        Color = 16774378
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'category'
        Caption = 'Kategorie'
        FieldName = 'CATEGORY'
        Width = 125
        VisibleIndex = 2
        DataType = Text
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'description'
        Caption = 'Beschreibung'
        FieldName = 'DESCRIPTION'
        Width = 285
        VisibleIndex = 3
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 110
        MaxLines = 5
        RightSpacing = 8
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'quantity'
        Caption = 'Menge'
        FieldName = 'QUANTITY'
        Width = 78
        VisibleIndex = 4
        DataType = Float
        DisplayFormat = '0.##'
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'unit_price'
        Caption = 'Einzelpreis'
        FieldName = 'UNIT_PRICE'
        Width = 105
        VisibleIndex = 5
        DataType = Currency
        DisplayFormat = '#,##0.00'
        Highlighted = True
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'priority'
        Caption = 'Priorit'#228't'
        FieldName = 'PRIORITY'
        Width = 86
        VisibleIndex = 6
        DataType = Integer
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'ACTIVE'
        Width = 65
        VisibleIndex = 7
        DataType = Boolean
        EditorKind = Boolean
        Color = 15530218
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'updated_at'
        Caption = 'Aktualisiert'
        FieldName = 'UPDATED_AT'
        Width = 135
        VisibleIndex = 8
        DataType = DateTime
        DisplayFormat = 'dd.mm.yyyy hh:nn'
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'picture'
        Caption = 'Bild'
        FieldName = 'PICTURE'
        Width = 96
        VisibleIndex = 9
        DataType = Image
        EditorKind = Image
        AutoHeight = True
        MaxAutoHeight = 90
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'fold_group'
        Caption = 'Faltgruppe'
        FieldName = 'FOLD_GROUP'
        Width = 80
        Visible = False
        VisibleIndex = 10
        ReadOnly = True
        DataType = Integer
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end>
    HeaderLayout.Enabled = True
    HeaderLayout.RowCount = 2
    HeaderLayout.Cells = <
      item
        Id = 'master'
        Caption = 'Stammdaten'
        ColumnSpan = 4
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = 'values'
        Caption = 'Mengen und Bewertung'
        LayoutColumn = 4
        ColumnSpan = 3
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = 'state'
        Caption = 'Status / Medien'
        LayoutColumn = 7
        ColumnSpan = 3
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'ID'
        ColumnId = 'id'
        LayoutRow = 1
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Name'
        ColumnId = 'name'
        LayoutRow = 1
        LayoutColumn = 1
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Kategorie'
        ColumnId = 'category'
        LayoutRow = 1
        LayoutColumn = 2
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Beschreibung'
        ColumnId = 'description'
        LayoutRow = 1
        LayoutColumn = 3
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Menge'
        ColumnId = 'quantity'
        LayoutRow = 1
        LayoutColumn = 4
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Einzelpreis'
        ColumnId = 'unit_price'
        LayoutRow = 1
        LayoutColumn = 5
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Priorit'#228't'
        ColumnId = 'priority'
        LayoutRow = 1
        LayoutColumn = 6
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Aktiv'
        ColumnId = 'active'
        LayoutRow = 1
        LayoutColumn = 7
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Aktualisiert'
        ColumnId = 'updated_at'
        LayoutRow = 1
        LayoutColumn = 8
        ClassId = 'h5u.grid.visual.cell.header-group'
      end
      item
        Id = ''
        Caption = 'Bild'
        ColumnId = 'picture'
        LayoutRow = 1
        LayoutColumn = 9
        ClassId = 'h5u.grid.visual.cell.header-group'
      end>
    Selection.AllowedKinds = [Rows, Columns, CellRanges]
    RowHeight.Mode = Automatic
    RowHeight.FixedHeight = 25
    RowHeight.MinHeight = 24
    RowHeight.MaxHeight = 130
    RowHeight.EstimatedHeight = 30
    ScrollHints.Triggers = [ThumbTracking, MouseWheel]
    ScrollHints.VerticalColumnId = 'name'
    RowStyles.StripePeriod = 5
    RowStyles.StripeOffset = 5
    RowStyles.StripeStyleName = 'Stripe'
    RowStyles.OddStyleName = 'Odd'
    RowStyles.EvenStyleName = 'Even'
    RowStyles.StyleKeyColumnId = 'priority'
    RowStyles.Mappings = <
      item
        Value = 2
        StyleName = 'Warning'
      end
      item
        Value = 3
        StyleName = 'Error'
      end>
    Tree.Enabled = True
    Tree.LevelColumnId = 'TREE_LEVEL'
    Tree.BranchEndBand.Enabled = True
    Tree.BranchEndBand.Height = 7
    Tree.BranchEndBand.StyleName = 'TreeBranchEnd'
    AdjacentGroupFolding.Enabled = True
    AdjacentGroupFolding.IdColumnId = 'fold_group'
    AdjacentGroupFolding.EndBand.Visibility = Always
    AdjacentGroupFolding.EndBand.Height = 7
    AdjacentGroupFolding.EndBand.StyleName = 'AdjacentGroupEnd'
    HeaderRowHeight = 27
    RowIndicatorWidth = 38
    OnGetRowHeight = GridGetRowHeight
    OnGetThumbHint = GridGetThumbHint
  end
  object SampleData: Th5uSampleClientDataset
    IncludeImages = True
    Left = 40
    Top = 112
    AutoCreateSampleData = True
    SampleRowCount = 40
  end
  object DataSource: TDataSource
    Dataset = SampleData
    Left = 120
    Top = 112
  end
  object DataController: Th5uDatasetController
    Cache.Mode = Paged
    Cache.PageSize = 100
    Cache.MaxMemoryBytes = 67108864
    Pagination.PageSize = 10
    DataSource = DataSource
    KeyFieldName = 'ID'
    Left = 208
    Top = 112
  end
end
