object FrmTemplate: TFrmTemplate
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 155
  ClientWidth = 600
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Shp1: TShape
    Left = 198
    Top = 55
    Width = 2
    Height = 95
  end
  object Shp2: TShape
    Left = 398
    Top = 55
    Width = 2
    Height = 95
  end
  object LblFirstPersonTitle: TLabel
    Left = 16
    Top = 64
    Width = 87
    Height = 16
    Caption = 'Auszubildender'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblFirstPersonSign: TLabel
    Left = 8
    Top = 109
    Width = 180
    Height = 10
    Caption = 
      '................................................................' +
      '..........................'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblFirstPersonName: TLabel
    Left = 8
    Top = 126
    Width = 93
    Height = 16
    Caption = 'Auzubildender'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblSecondPersonSign: TLabel
    Left = 208
    Top = 109
    Width = 180
    Height = 10
    Caption = 
      '................................................................' +
      '..........................'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblThirdPersonSign: TLabel
    Left = 408
    Top = 109
    Width = 180
    Height = 10
    Caption = 
      '................................................................' +
      '..........................'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object PnlName: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 49
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 673
    object EdtName: TMemo
      Left = 160
      Top = 10
      Width = 280
      Height = 27
      Alignment = taCenter
      Lines.Strings = (
        'Name')
      TabOrder = 0
      WantReturns = False
    end
    object BtnEdit: TButton
      Left = 527
      Top = 3
      Width = 67
      Height = 25
      Caption = 'Speichern'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = BtnEditClick
    end
    object BtnAbbort: TButton
      Left = 447
      Top = 3
      Width = 75
      Height = 25
      Caption = 'Abbrechen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = BtnAbbortClick
    end
    object BtnDelete: TButton
      Left = 8
      Top = 3
      Width = 75
      Height = 25
      Caption = 'L'#246'schen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = BtnDeleteClick
    end
  end
  object EdtSecondPersonTitle: TMemo
    Left = 211
    Top = 61
    Width = 180
    Height = 27
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'Ausbilder')
    ParentFont = False
    TabOrder = 1
    WantReturns = False
  end
  object EdtThirdPersonTitle: TMemo
    Left = 411
    Top = 61
    Width = 180
    Height = 27
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'Sonstige')
    ParentFont = False
    TabOrder = 2
    WantReturns = False
  end
  object EdtThirdPersonName: TMemo
    Left = 403
    Top = 123
    Width = 180
    Height = 27
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Lines.Strings = (
      'Name:')
    ParentFont = False
    TabOrder = 3
    WantReturns = False
  end
  object EdtSecondPersonName: TMemo
    Left = 203
    Top = 123
    Width = 180
    Height = 27
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    Lines.Strings = (
      'Name:')
    ParentFont = False
    TabOrder = 4
    WantReturns = False
  end
end
