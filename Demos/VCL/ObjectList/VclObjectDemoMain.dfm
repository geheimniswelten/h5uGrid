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
  object Grid: ThiiGrid
    Left = 0
    Top = 64
    Width = 1040
    Height = 546
    Align = alClient
    TabOrder = 1
    TabStop = True
    DataController = ObjectController
    Editors = <>
    Columns = <
      item
        Id = 'id'
        Caption = 'ID'
        FieldName = 'Id'
        Width = 64.000000000000000000
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
        FieldName = 'Name'
        Width = 150.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 1
        DataType = Text
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'department'
        Caption = 'Abteilung'
        FieldName = 'Department'
        Width = 120.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 2
        DataType = Text
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'notes'
        Caption = 'Hinweis'
        FieldName = 'Notes'
        Width = 320.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 3
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 95.000000000000000000
        MaxLines = 4
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'amount'
        Caption = 'Betrag'
        FieldName = 'Amount'
        Width = 110.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 4
        DataType = Currency
        MaxAutoHeight = 160.000000000000000000
        DisplayFormat = '#,##0.00'
        Highlighted = True
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'active'
        Caption = 'Aktiv'
        FieldName = 'Active'
        Width = 64.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 5
        DataType = Boolean
        EditorKind = Boolean
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'priority'
        Caption = 'Priorit'#228't'
        FieldName = 'Priority'
        Width = 80.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 6
        DataType = Integer
        MaxAutoHeight = 160.000000000000000000
        RightSpacing = -1.000000000000000000
      end
      item
        Id = 'updated'
        Caption = 'Ge'#228'ndert'
        FieldName = 'UpdatedAt'
        Width = 140.000000000000000000
        MinWidth = 24.000000000000000000
        MaxWidth = 1000.000000000000000000
        VisibleIndex = 7
        DataType = DateTime
        MaxAutoHeight = 160.000000000000000000
        DisplayFormat = 'dd.mm.yyyy hh:nn:ss'
        RightSpacing = -1.000000000000000000
      end>
    Header.RowHeight = 26.000000000000000000
    Header.Layout.Cells = <>
    RowIndicator.Width = 34.000000000000000000
    Selection.AllowedKinds = [Rows, Columns, CellRanges]
    RowHeight.Mode = Automatic
    RowHeight.FixedHeight = 24.000000000000000000
    RowHeight.MinHeight = 20.000000000000000000
    RowHeight.MaxHeight = 180.000000000000000000
    RowHeight.EstimatedHeight = 24.000000000000000000
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
    AdjacentGroupFolding.EndBand.Height = 6.000000000000000000
    Tree.BranchEndBand.Height = 6.000000000000000000
    SizingVersion = 1
  end
  object ObjectController: ThiiObjectListController
    Cache.Mode = None
    Cache.MaxMemoryBytes = 67108864
    OwnsObjects = True
    KeyPropertyName = 'Id'
    Left = 56
    Top = 112
  end
  object UpdateTimer: TTimer
    Interval = 800
    OnTimer = UpdateTimerTimer
    Left = 152
    Top = 112
  end
end
