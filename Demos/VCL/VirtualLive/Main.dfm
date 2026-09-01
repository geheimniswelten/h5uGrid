object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'h5u.Grid VCL - VirtualSource / Live-Ereignisse'
  ClientHeight = 630
  ClientWidth = 1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  Position = poScreenCenter
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 66
    Align = alTop
    TabOrder = 0
    object StatusLabel: TLabel
      Left = 12
      Top = 41
      Width = 179
      Height = 17
      Caption = 'VirtualSource wird vorbereitet ...'
    end
    object PauseCheck: TCheckBox
      Left = 12
      Top = 10
      Width = 83
      Height = 20
      Caption = 'Pause'
      TabOrder = 0
      OnClick = OptionClick
    end
    object CacheCheck: TCheckBox
      Left = 103
      Top = 10
      Width = 112
      Height = 20
      Caption = 'Viewport-Cache'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = OptionClick
    end
    object PagedCheck: TCheckBox
      Left = 224
      Top = 10
      Width = 93
      Height = 20
      Caption = 'Pagination'
      TabOrder = 2
      OnClick = OptionClick
    end
    object DarkCheck: TCheckBox
      Left = 326
      Top = 10
      Width = 102
      Height = 20
      Caption = 'Dark Mode'
      TabOrder = 3
      OnClick = OptionClick
    end
    object AppendButton: TButton
      Left = 444
      Top = 7
      Width = 116
      Height = 28
      Caption = 'Event anhängen'
      TabOrder = 4
      OnClick = AppendButtonClick
    end
    object ClearButton: TButton
      Left = 568
      Top = 7
      Width = 92
      Height = 28
      Caption = 'Leeren'
      TabOrder = 5
      OnClick = ClearButtonClick
    end
    object NextPageButton: TButton
      Left = 668
      Top = 7
      Width = 112
      Height = 28
      Caption = 'Nächste Seite'
      TabOrder = 6
      OnClick = NextPageButtonClick
    end
  end
  object Grid: Th5uVclGrid
    Left = 0
    Top = 66
    Width = 1080
    Height = 564
    Align = alClient
    DataController = VirtualController
    Columns = <
      item
        Id = 'id'
        Caption = 'ID'
        FieldName = 'ID'
        Width = 70
        VisibleIndex = 0
        FixedKind = Left
        ReadOnly = True
        DataType = Integer
      end
      item
        Id = 'timestamp'
        Caption = 'Zeit'
        FieldName = 'TIMESTAMP'
        Width = 145
        VisibleIndex = 1
        ReadOnly = True
        DataType = DateTime
        DisplayFormat = 'dd.mm.yyyy hh:nn:ss'
      end
      item
        Id = 'source'
        Caption = 'Quelle'
        FieldName = 'SOURCE'
        Width = 115
        VisibleIndex = 2
        ReadOnly = True
        DataType = Text
      end
      item
        Id = 'message'
        Caption = 'Meldung'
        FieldName = 'MESSAGE'
        Width = 560
        VisibleIndex = 3
        DataType = Text
        WordWrap = True
        AutoHeight = True
        MaxAutoHeight = 100
        MaxLines = 4
      end
      item
        Id = 'severity'
        Caption = 'Stufe'
        FieldName = 'SEVERITY'
        Width = 70
        VisibleIndex = 4
        ReadOnly = True
        DataType = Integer
      end
      item
        Id = 'ack'
        Caption = 'Quittiert'
        FieldName = 'ACK'
        Width = 80
        VisibleIndex = 5
        DataType = Boolean
        EditorKind = Boolean
      end>
    RowHeight.Mode = Automatic
    RowHeight.MinHeight = 24
    RowHeight.MaxHeight = 110
    RowHeight.EstimatedHeight = 28
    ScrollHints.VerticalColumnId = 'message'
    RowStyles.StripePeriod = 5
    RowStyles.StripeOffset = 5
    RowStyles.StyleKeyColumnId = 'severity'
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
  object VirtualController: Th5uVirtualController
    Cache.Mode = Viewport
    Pagination.Mode = Continuous
    Pagination.PageSize = 20
    OnGetRowCount = VirtualControllerGetRowCount
    OnGetRowKey = VirtualControllerGetRowKey
    OnGetValue = VirtualControllerGetValue
    OnSetValue = VirtualControllerSetValue
    OnPrepareRange = VirtualControllerPrepareRange
    Left = 24
    Top = 88
  end
  object LiveTimer: TTimer
    Enabled = True
    Interval = 900
    OnTimer = LiveTimerTimer
    Left = 96
    Top = 88
  end
end
