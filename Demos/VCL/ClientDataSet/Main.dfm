object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'h5u.Grid VCL - TClientDataSet / Designer-Demo'
  ClientHeight = 650
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  Position = poScreenCenter
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
      Width = 913
      Height = 17
      Caption = 'Designer-Test: Grid, DataSource, Controller, Spalten und Musterdaten liegen auf dem Formular. Doppelklick editiert; Rechtsklick im Header öffnet den Column Chooser.'
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
    object NextPageButton: TButton
      Left = 816
      Top = 8
      Width = 112
      Height = 29
      Caption = 'Nächste Seite'
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
    DataController = DataController
    Appearance.DefaultCellColor = 4294835709
    HeaderLayout.Enabled = True
    HeaderLayout.RowCount = 2
    HeaderLayout.Cells = <
      item
        Id = 'master'
        Caption = 'Stammdaten'
        LayoutRow = 0
        LayoutColumn = 0
        RowSpan = 1
        ColumnSpan = 4
      end
      item
        Id = 'values'
        Caption = 'Mengen und Bewertung'
        LayoutRow = 0
        LayoutColumn = 4
        RowSpan = 1
        ColumnSpan = 3
      end
      item
        Id = 'state'
        Caption = 'Status / Medien'
        LayoutRow = 0
        LayoutColumn = 7
        RowSpan = 1
        ColumnSpan = 3
      end
      item
        Caption = 'ID'
        ColumnId = 'id'
        LayoutRow = 1
        LayoutColumn = 0
      end
      item
        Caption = 'Name'
        ColumnId = 'name'
        LayoutRow = 1
        LayoutColumn = 1
      end
      item
        Caption = 'Kategorie'
        ColumnId = 'category'
        LayoutRow = 1
        LayoutColumn = 2
      end
      item
        Caption = 'Beschreibung'
        ColumnId = 'description'
        LayoutRow = 1
        LayoutColumn = 3
      end
      item
        Caption = 'Menge'
        ColumnId = 'quantity'
        LayoutRow = 1
        LayoutColumn = 4
      end
      item
        Caption = 'Einzelpreis'
        ColumnId = 'unit_price'
        LayoutRow = 1
        LayoutColumn = 5
      end
      item
        Caption = 'Priorität'
        ColumnId = 'priority'
        LayoutRow = 1
        LayoutColumn = 6
      end
      item
        Caption = 'Aktiv'
        ColumnId = 'active'
        LayoutRow = 1
        LayoutColumn = 7
      end
      item
        Caption = 'Erstellt'
        ColumnId = 'created_at'
        LayoutRow = 1
        LayoutColumn = 8
      end
      item
        Caption = 'Bild'
        ColumnId = 'picture'
        LayoutRow = 1
        LayoutColumn = 9
      end>
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
      end
      item
        Id = 'name'
        Caption = 'Name'
        FieldName = 'NAME'
        Width = 145
        VisibleIndex = 1
        DataType = Text
        Color = 4293588223
        ScrollHintText = 'Artikelname'
      end
      item
        Id = 'category'
        Caption = 'Kategorie'
        FieldName = 'CATEGORY'
        Width = 125
        VisibleIndex = 2
        DataType = Text
      end
      item
        Id = 'description'
        Caption = 'Beschreibung'
        FieldName = 'DESCRIPTION'
        Width = 285
        VisibleIndex = 3
        RightSpacing = 8
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 110
        MaxLines = 5
      end
      item
        Id = 'quantity'
        Caption = 'Menge'
        FieldName = 'QUANTITY'
        Width = 78
        VisibleIndex = 4
        DataType = Float
        DisplayFormat = '0.##'
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
      end
      item
        Id = 'priority'
        Caption = 'Priorität'
        FieldName = 'PRIORITY'
        Width = 86
        VisibleIndex = 6
        DataType = Integer
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'ACTIVE'
        Width = 65
        VisibleIndex = 7
        DataType = Boolean
        EditorKind = Boolean
        Color = 4293589228
      end
      item
        Id = 'created_at'
        Caption = 'Erstellt'
        FieldName = 'CREATED_AT'
        Width = 135
        VisibleIndex = 8
        DataType = DateTime
        DisplayFormat = 'dd.mm.yyyy hh:nn'
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
      end>
    RowHeight.Mode = Automatic
    RowHeight.FixedHeight = 25
    RowHeight.MinHeight = 24
    RowHeight.MaxHeight = 130
    RowHeight.EstimatedHeight = 30
    Scrolling.VerticalMode = Pixel
    Scrolling.HorizontalMode = Pixel
    Scrolling.OverscanRows = 2
    ScrollHints.Enabled = True
    ScrollHints.Triggers = [ThumbTracking, MouseWheel]
    ScrollHints.VerticalColumnId = 'name'
    ScrollHints.ShowRowPosition = True
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
    HeaderRowHeight = 27
    RowIndicatorWidth = 38
    ShowHeader = True
    ShowRowIndicator = True
    AllowEditing = True
    GridLines = True
    TabOrder = 1
    OnGetRowHeight = GridGetRowHeight
    OnGetThumbHint = GridGetThumbHint
  end
  object SampleData: Th5uSampleClientDataSet
    PopulateAtDesignTime = True
    SampleDataKind = Mixed
    SampleRecordCount = 36
    IncludeImages = True
    Left = 40
    Top = 112
    AutoCreateSampleData = True
    SampleRowCount = 40
  end
  object DataSource: TDataSource
    DataSet = SampleData
    Left = 120
    Top = 112
  end
  object DataController: Th5uDataSetController
    DataSource = DataSource
    KeyFieldName = 'ID'
    Cache.Mode = Paged
    Cache.PageSize = 100
    Pagination.Mode = Continuous
    Pagination.PageSize = 10
    Left = 208
    Top = 112
  end
end
