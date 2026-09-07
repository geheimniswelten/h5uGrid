object VclObjectDemoForm: TVclObjectDemoForm
  Left = 0
  Top = 0
  Caption = 'h5u.Grid VCL - Objektliste / RTTI'
  ClientHeight = 610
  ClientWidth = 1040
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1040
    Height = 64
    Align = alTop
    TabOrder = 0
    object InfoLabel: TLabel
      Left = 12
      Top = 39
      Width = 673
      Height = 15
      Caption = 
        'Direkter Property-Zugriff oder optionaler Viewport-Cache. Der Ti' +
        'mer ver'#228'ndert Objekte und meldet sie gezielt an den Controller.'
    end
    object AddButton: TButton
      Left = 12
      Top = 7
      Width = 126
      Height = 27
      Caption = 'Objekt hinzuf'#252'gen'
      TabOrder = 0
      OnClick = AddButtonClick
    end
    object CacheCheck: TCheckBox
      Left = 154
      Top = 10
      Width = 130
      Height = 20
      Caption = 'RTTI-Wertcache'
      TabOrder = 1
      OnClick = CacheCheckClick
    end
    object LiveCheck: TCheckBox
      Left = 297
      Top = 10
      Width = 122
      Height = 20
      Caption = 'Live '#228'ndern'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = LiveCheckClick
    end
    object DarkCheck: TCheckBox
      Left = 429
      Top = 10
      Width = 102
      Height = 20
      Caption = 'Dark Mode'
      TabOrder = 3
      OnClick = DarkCheckClick
    end
  end
  object Grid: Th5uVclGrid
    Left = 0
    Top = 64
    Width = 1040
    Height = 546
    Align = alClient
    TabOrder = 1
    TabStop = True
    DataController = ObjectController
    Columns = <
      item
        Id = 'id'
        Caption = 'ID'
        FieldName = 'Id'
        Width = 64
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
        FieldName = 'Name'
        Width = 150
        VisibleIndex = 1
        DataType = Text
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'department'
        Caption = 'Abteilung'
        FieldName = 'Department'
        Width = 120
        VisibleIndex = 2
        DataType = Text
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'notes'
        Caption = 'Hinweis'
        FieldName = 'Notes'
        Width = 320
        VisibleIndex = 3
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 95
        MaxLines = 4
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'amount'
        Caption = 'Betrag'
        FieldName = 'Amount'
        Width = 110
        VisibleIndex = 4
        DataType = Currency
        DisplayFormat = '#,##0.00'
        Highlighted = True
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'Active'
        Width = 64
        VisibleIndex = 5
        DataType = Boolean
        EditorKind = Boolean
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'priority'
        Caption = 'Priorit'#228't'
        FieldName = 'Priority'
        Width = 80
        VisibleIndex = 6
        DataType = Integer
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end
      item
        Id = 'updated'
        Caption = 'Ge'#228'ndert'
        FieldName = 'UpdatedAt'
        Width = 140
        VisibleIndex = 7
        DataType = DateTime
        DisplayFormat = 'dd.mm.yyyy hh:nn:ss'
        ClassId = 'h5u.grid.column.default'
        CellClassId = 'h5u.grid.visual.cell.data'
        HeaderCellClassId = 'h5u.grid.visual.cell.header'
      end>
    HeaderLayout.Cells = <>
    Selection.AllowedKinds = [Rows, Columns, CellRanges]
    RowHeight.Mode = Automatic
    RowHeight.MinHeight = 24
    RowHeight.MaxHeight = 110
    RowHeight.EstimatedHeight = 28
    ScrollHints.Triggers = [ThumbTracking]
    ScrollHints.VerticalColumnId = 'name'
    RowStyles.StripePeriod = 3
    RowStyles.StripeOffset = 3
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
  end
  object ObjectController: Th5uObjectListController
    Cache.Mode = None
    Cache.MaxMemoryBytes = 67108864
    OwnsObjects = True
    KeyPropertyName = 'Id'
    Left = 32
    Top = 88
  end
  object UpdateTimer: TTimer
    Interval = 800
    OnTimer = UpdateTimerTimer
    Left = 104
    Top = 88
  end
end
