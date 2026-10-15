object VclMegaDemoForm: TVclMegaDemoForm
  Left = 0
  Top = 0
  Caption = 'hiiGrid VCL / Mega-Demo'
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
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
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
      Left = 280
      Top = 41
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
  object Grid: ThiiGrid
    Left = 300
    Top = 73
    Width = 820
    Height = 577
    Align = alClient
    TabOrder = 1
    TabStop = True
    DataController = DataController
    Editors = <>
    Columns = <
      item
        Id = 'id'
        Caption = 'ID'
        FieldName = 'ID'
        Width = 72.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 0
        FixedKind = Left
        ReadOnly = True
        DataType = Integer
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'name'
        Caption = 'Name'
        FieldName = 'NAME'
        Width = 145.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 1
        DataType = Text
        MaxAutoHeight = 160.000000000000000000
        ScrollHintText = 'Artikelname'
        RightSpacing = -1.000000000000000000
        Color = 16774378
      end
      item
        Id = 'category'
        Caption = 'Kategorie'
        FieldName = 'CATEGORY'
        Width = 125.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 2
        DataType = Text
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'description'
        Caption = 'Beschreibung'
        FieldName = 'DESCRIPTION'
        Width = 285.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 3
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 110.000000000000000000
        MaxLines = 5
        RightSpacing = 8.000000000000000000
      end
      item
        Id = 'quantity'
        Caption = 'Menge'
        FieldName = 'QUANTITY'
        Width = 78.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 4
        DataType = Integer
        MaxAutoHeight = 160.000000000000000000
        DisplayFormat = '0.##'
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'unit_price'
        Caption = 'Einzelpreis'
        FieldName = 'UNIT_PRICE'
        Width = 105.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 5
        DataType = Currency
        MaxAutoHeight = 160.000000000000000000
        DisplayFormat = '#,##0.00'
        Highlighted = True
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'priority'
        Caption = 'Priorit'#228't'
        FieldName = 'PRIORITY'
        Width = 86.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 6
        DataType = Integer
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'ACTIVE'
        Width = 65.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 7
        DataType = Boolean
        EditorKind = Boolean
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
        Color = 15530218
      end
      item
        Id = 'updated_at'
        Caption = 'Aktualisiert'
        FieldName = 'UPDATED_AT'
        Width = 135.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 8
        DataType = DateTime
        MaxAutoHeight = 160.000000000000000000
        DisplayFormat = 'dd.mm.yyyy hh:nn'
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'picture'
        Caption = 'Bild'
        FieldName = 'PICTURE'
        Width = 96.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 9
        DataType = Image
        EditorKind = Image
        AutoHeight = True
        MaxAutoHeight = 90.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'fold_group'
        Caption = 'Faltgruppe'
        FieldName = 'FOLD_GROUP'
        Width = 80.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        Visible = False
        VisibleIndex = 10
        ReadOnly = True
        DataType = Integer
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end>
    Header.RowHeight = 27.000000000000000000
    Header.Layout.Enabled = True
    Header.Layout.RowCount = 2
    Header.Layout.Cells = <
      item
        Id = 'master'
        Caption = 'Stammdaten'
        LayoutColumn = 1
        ColumnSpan = 3
      end
      item
        Id = 'values'
        Caption = 'Mengen und Bewertung'
        LayoutColumn = 4
        ColumnSpan = 3
      end
      item
        Id = 'state'
        Caption = 'Status / Medien'
        LayoutColumn = 7
        ColumnSpan = 3
      end
      item
        Id = ''
        Caption = 'ID'
        ColumnId = 'id'
        RowSpan = 2
      end
      item
        Id = ''
        Caption = 'Name'
        ColumnId = 'name'
        LayoutRow = 1
        LayoutColumn = 1
      end
      item
        Id = ''
        Caption = 'Kategorie'
        ColumnId = 'category'
        LayoutRow = 1
        LayoutColumn = 2
      end
      item
        Id = ''
        Caption = 'Beschreibung'
        ColumnId = 'description'
        LayoutRow = 1
        LayoutColumn = 3
      end
      item
        Id = ''
        Caption = 'Menge'
        ColumnId = 'quantity'
        LayoutRow = 1
        LayoutColumn = 4
      end
      item
        Id = ''
        Caption = 'Einzelpreis'
        ColumnId = 'unit_price'
        LayoutRow = 1
        LayoutColumn = 5
      end
      item
        Id = ''
        Caption = 'Priorit'#228't'
        ColumnId = 'priority'
        LayoutRow = 1
        LayoutColumn = 6
      end
      item
        Id = ''
        Caption = 'Aktiv'
        ColumnId = 'active'
        LayoutRow = 1
        LayoutColumn = 7
      end
      item
        Id = ''
        Caption = 'Aktualisiert'
        ColumnId = 'updated_at'
        LayoutRow = 1
        LayoutColumn = 8
      end
      item
        Id = ''
        Caption = 'Bild'
        ColumnId = 'picture'
        LayoutRow = 1
        LayoutColumn = 9
      end>
    RowIndicator.Width = 38.000000000000000000
    Selection.AllowedKinds = [Rows, Columns, CellRanges]
    RowHeight.Mode = Automatic
    RowHeight.FixedHeight = 24.000000000000000000
    RowHeight.MinHeight = 20.000000000000000000
    RowHeight.MaxHeight = 180.000000000000000000
    RowHeight.EstimatedHeight = 24.000000000000000000
    ScrollHints.VerticalColumnId = 'name'
    RowStyles.StripePeriod = 5
    RowStyles.StripeOffset = 5
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
    Customization.ColumnResizeHitZoneLeft = 4.000000000000000000
    Customization.ColumnResizeHitZoneRight = 4.000000000000000000
    Customization.TouchColumnResizeHitZoneLeft = 12.000000000000000000
    Customization.TouchColumnResizeHitZoneRight = 12.000000000000000000
    Customization.LastColumnResizeHitZoneLeft = -1.000000000000000000
    Customization.TouchLastColumnResizeHitZoneLeft = -1.000000000000000000
    Spacing.Left = 1.000000000000000000
    Spacing.Top = 1.000000000000000000
    Spacing.Right = 1.000000000000000000
    Spacing.Bottom = 1.000000000000000000
    Spacing.RowSpacing = 1.000000000000000000
    Spacing.DefaultColumnRightSpacing = 1.000000000000000000
    AdjacentGroupFolding.Enabled = True
    AdjacentGroupFolding.IdColumnId = 'fold_group'
    AdjacentGroupFolding.EndBand.Visibility = Always
    AdjacentGroupFolding.EndBand.Height = 7.000000000000000000
    AdjacentGroupFolding.EndBand.StyleName = 'AdjacentGroupEnd'
    Tree.Enabled = True
    Tree.LevelColumnId = 'TREE_LEVEL'
    Tree.BranchEndBand.Enabled = True
    Tree.BranchEndBand.Height = 7.000000000000000000
    Tree.BranchEndBand.StyleName = 'TreeBranchEnd'
    OnGetRowHeight = GridGetRowHeight
    OnGetThumbHint = GridGetThumbHint
    SizingVersion = 1
  end
  object SplitView1: TSplitView
    Left = 0
    Top = 73
    Width = 300
    Height = 577
    OpenedWidth = 300
    Placement = svpLeft
    TabOrder = 2
    UseAnimation = False
    object Splitter1: TSplitter
      Left = 292
      Top = 25
      Width = 8
      Height = 552
      Align = alRight
      ResizeStyle = rsUpdate
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 300
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object ActivityIndicator1: TActivityIndicator
        Left = 0
        Top = 0
        Align = alLeft
      end
      object Button1: TButton
        Left = 268
        Top = 0
        Width = 32
        Height = 25
        Align = alRight
        Caption = 'Button1'
        TabOrder = 1
      end
    end
    object Properties: ThiiPropertyEditor
      Left = 0
      Top = 25
      Width = 292
      Height = 552
      ColumnSizing.FitMode = AllColumns
      Header.RowHeight = 26.000000000000000000
      Header.Layout.Cells = <>
      RowIndicator.Visible = False
      RowIndicator.Width = 34.000000000000000000
      PropertyEditor.ExpandSubProperties = True
      PropertyEditor.RootGroupName = 'Options'
      Align = alClient
      TabOrder = 1
      TabStop = True
      Columns = <
        item
          Id = 'Name'
          Caption = 'Property'
          FieldName = 'Caption'
          Width = -60.000000000000000000
          VisibleIndex = 0
          ReadOnly = True
          MaxAutoHeight = 160.000000000000000000
          RightSpacing = -1.000000000000000000
        end
        item
          Id = 'Value'
          Caption = 'Value'
          FieldName = 'DisplayValue'
          Width = -40.000000000000000000
          VisibleIndex = 1
          DataType = Text
          Editor = 'PropertyValue'
          MaxAutoHeight = 160.000000000000000000
          RightSpacing = -1.000000000000000000
        end>
      RowHeight.FixedHeight = 24.000000000000000000
      RowHeight.MinHeight = 20.000000000000000000
      RowHeight.MaxHeight = 180.000000000000000000
      RowHeight.EstimatedHeight = 24.000000000000000000
      SizingVersion = 1
    end
  end
  object SampleData: ThiiSampleClientDataset
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ID'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'TREE_LEVEL'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'FOLD_GROUP'
        Attributes = [faRequired]
        DataType = ftInteger
      end
      item
        Name = 'NAME'
        DataType = ftWideString
        Size = 80
      end
      item
        Name = 'CATEGORY'
        DataType = ftWideString
        Size = 40
      end
      item
        Name = 'DESCRIPTION'
        DataType = ftWideMemo
      end
      item
        Name = 'QUANTITY'
        DataType = ftInteger
      end
      item
        Name = 'UNIT_PRICE'
        DataType = ftCurrency
      end
      item
        Name = 'ACTIVE'
        DataType = ftBoolean
      end
      item
        Name = 'PRIORITY'
        DataType = ftInteger
      end
      item
        Name = 'UPDATED_AT'
        DataType = ftDateTime
      end
      item
        Name = 'PICTURE'
        DataType = ftBlob
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    SampleRowCount = 40
    Left = 408
    Top = 272
  end
  object DataSource: TDataSource
    DataSet = SampleData
    Left = 488
    Top = 272
  end
  object DataController: ThiiDatasetController
    Cache.Mode = Paged
    Cache.PageSize = 100
    Cache.MaxMemoryBytes = 67108864
    Pagination.PageSize = 10
    DataSource = DataSource
    KeyFieldName = 'ID'
    Left = 576
    Top = 272
  end
end
