object FrmShadow: TFrmShadow
  Left = 0
  Top = 0
  AlphaBlend = True
  AlphaBlendValue = 200
  BorderStyle = bsNone
  ClientHeight = 519
  ClientWidth = 718
  Color = clMedGray
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage
    Tag = 1
    Left = 291
    Top = 171
    Width = 150
    Height = 150
    Align = alCustom
    Proportional = True
    Transparent = True
  end
  object Image2: TImage
    Tag = 1
    Left = 291
    Top = 171
    Width = 150
    Height = 150
    Align = alCustom
    Proportional = True
    Transparent = True
  end
  object LoaderTimer: TTimer
    Tag = 1
    Interval = 60
    OnTimer = LoaderTimerTimer
    Left = 328
    Top = 96
  end
end
