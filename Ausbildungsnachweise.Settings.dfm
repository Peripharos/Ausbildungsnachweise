object FrmSettings: TFrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 478
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 822
    Height = 41
    Align = alTop
    Caption = 'Einstellungen'
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
  end
  object PnlSettingsFrame: TPanel
    Left = 0
    Top = 41
    Width = 320
    Height = 437
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 362
    DesignSize = (
      320
      437)
    object BtnSave: TButton
      Left = 202
      Top = 395
      Width = 81
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Speichern'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = BtnSaveClick
    end
    object BtnAbbort: TButton
      Left = 24
      Top = 395
      Width = 81
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Abbrechen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = BtnAbbortClick
    end
    object PnlMainSettings: TGroupBox
      Left = 1
      Top = 1
      Width = 318
      Height = 190
      Align = alTop
      Caption = 'Standard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      object LblTrainingEndDate: TLabel
        Left = 24
        Top = 150
        Width = 112
        Height = 18
        Caption = 'Ausbildungsende:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object LblTrainingStartDate: TLabel
        Left = 24
        Top = 100
        Width = 110
        Height = 18
        Caption = 'Ausbildungsstart:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object LblUserName: TLabel
        Left = 24
        Top = 50
        Width = 101
        Height = 18
        Caption = 'Auszubildender:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object EdtTrainingEndDate: TMaskEdit
        Left = 216
        Top = 149
        Width = 81
        Height = 24
        EditMask = '!90/90/0000;1;_'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 10
        ParentFont = False
        TabOrder = 0
        Text = '  .  .    '
      end
      object EdtTrainingStartDate: TMaskEdit
        Left = 216
        Top = 99
        Width = 81
        Height = 24
        EditMask = '!90/90/0000;1;_'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 10
        ParentFont = False
        TabOrder = 1
        Text = '  .  .    '
      end
      object EdtUserName: TEdit
        Left = 168
        Top = 49
        Width = 129
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
    end
    object PnlServiceSettings: TGroupBox
      AlignWithMargins = True
      Left = 1
      Top = 196
      Width = 318
      Height = 190
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Align = alTop
      Caption = 'Erinnerungs-Dienst'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      ExplicitLeft = 2
      ExplicitTop = 182
      object LblIsActive: TLabel
        Left = 24
        Top = 50
        Width = 56
        Height = 18
        Caption = 'Aktiviert:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object LblOnStart: TLabel
        Left = 24
        Top = 100
        Width = 146
        Height = 18
        Caption = 'Nachricht bei PC-Start:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object LblInterval: TLabel
        Left = 24
        Top = 150
        Width = 92
        Height = 18
        Caption = 'Wiederholung:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object EdtIsActive: TImage
        Left = 277
        Top = 49
        Width = 20
        Height = 20
        OnClick = EdtIsActiveClick
      end
      object EdtOnStart: TImage
        Left = 277
        Top = 99
        Width = 20
        Height = 20
        OnClick = EdtOnStartClick
      end
      object EdtInterval: TComboBox
        Left = 224
        Top = 149
        Width = 73
        Height = 24
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 0
        ItemIndex = 0
        ParentFont = False
        TabOrder = 0
        Text = '30 min'
        Items.Strings = (
          '30 min'
          '1 h'
          '2 h'
          '3 h'
          '6 h'
          '8 h'
          '12 h'
          'nie')
      end
    end
  end
  object PnlTemplatesFrame: TPanel
    Left = 320
    Top = 41
    Width = 502
    Height = 437
    Align = alClient
    Caption = 'PnlTemplatesFrame'
    TabOrder = 2
    ExplicitHeight = 362
    object PnlTemplates: TScrollBox
      Left = 1
      Top = 36
      Width = 500
      Height = 400
      Align = alClient
      BorderStyle = bsNone
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      ExplicitHeight = 325
      object Image: TImage
        Left = 0
        Top = 0
        Width = 500
        Height = 105
        Align = alTop
        OnClick = ImageClick
        OnMouseLeave = ImageMouseLeave
        OnMouseMove = ImageMouseMove
        ExplicitWidth = 400
      end
      object PnlAdd: TPanel
        Left = 0
        Top = 105
        Width = 500
        Height = 25
        Align = alTop
        Color = clInactiveBorder
        ParentBackground = False
        TabOrder = 0
        object BtnAdd: TSpeedButton
          Left = 1
          Top = 1
          Width = 498
          Height = 23
          Align = alClient
          Caption = '+'
          Flat = True
          OnClick = BtnAddClick
          ExplicitLeft = 16
          ExplicitTop = 0
          ExplicitWidth = 23
          ExplicitHeight = 30
        end
      end
    end
    object PnlTemplatesHeading: TPanel
      Left = 1
      Top = 1
      Width = 500
      Height = 35
      Align = alTop
      Caption = 'Templates'
      Color = clCream
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
    end
  end
end
