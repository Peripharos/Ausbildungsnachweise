object FrmAdd: TFrmAdd
  Left = 0
  Top = 0
  ClientHeight = 303
  ClientWidth = 327
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
  object LblFromDate: TLabel
    Left = 48
    Top = 80
    Width = 28
    Height = 19
    Caption = 'Von'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblToDate: TLabel
    Left = 48
    Top = 143
    Width = 20
    Height = 19
    Caption = 'Bis'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblTemplate: TLabel
    Left = 48
    Top = 200
    Width = 66
    Height = 19
    Caption = 'Template'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 327
    Height = 41
    Align = alTop
    Caption = 'Nachweise Hinzuf'#252'gen'
    Color = cl3DLight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
  end
  object EdtFrom: TComboBox
    Left = 136
    Top = 80
    Width = 161
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 1
  end
  object EdtTo: TComboBox
    Left = 136
    Top = 143
    Width = 161
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 2
  end
  object BtnAdd: TButton
    Left = 112
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Hinzuf'#252'gen'
    TabOrder = 3
    OnClick = BtnAddClick
  end
  object EdtTemplates: TComboBox
    Left = 136
    Top = 200
    Width = 161
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 4
  end
end
