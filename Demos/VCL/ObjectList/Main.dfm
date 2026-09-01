object MainForm: TMainForm
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
  OnCreate = FormCreate
  Position = poScreenCenter
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
      Width = 729
      Height = 17
      Caption = 'Direkter Property-Zugriff oder optionaler Viewport-Cache. Der Timer verändert Objekte und meldet sie gezielt an den Controller.'
    end
    object AddButton: TButton
      Left = 12
      Top = 7
      Width = 126
      Height = 27
      Caption = 'Objekt hinzufügen'
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
      Caption = 'Live ändern'
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
      end
      item
        Id = 'name'
        Caption = 'Name'
        FieldName = 'Name'
        Width = 150
        VisibleIndex = 1
        DataType = Text
      end
      item
        Id = 'department'
        Caption = 'Abteilung'
        FieldName = 'Department'
        Width = 120
        VisibleIndex = 2
        DataType = Text
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
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'Active'
        Width = 64
        VisibleIndex = 5
        DataType = Boolean
        EditorKind = Boolean
      end
      item
        Id = 'priority'
        Caption = 'Priorität'
        FieldName = 'Priority'
        Width = 80
        VisibleIndex = 6
        DataType = Integer
      end
      item
        Id = 'updated'
        Caption = 'Geändert'
        FieldName = 'UpdatedAt'
        Width = 140
        VisibleIndex = 7
        DataType = DateTime
        DisplayFormat = 'dd.mm.yyyy hh:nn:ss'
      end>
    RowHeight.Mode = Automatic
    RowHeight.MinHeight = 24
    RowHeight.MaxHeight = 110
    RowHeight.EstimatedHeight = 28
    ScrollHints.VerticalColumnId = 'name'
    RowStyles.StripePeriod = 3
    RowStyles.StripeOffset = 3
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
    TabOrder = 1
  end
  object ObjectController: Th5uObjectListController
    OwnsObjects = True
    KeyPropertyName = 'Id'
    Cache.Mode = None
    Left = 32
    Top = 88
  end
  object UpdateTimer: TTimer
    Enabled = True
    Interval = 800
    OnTimer = UpdateTimerTimer
    Left = 104
    Top = 88
  end
end
