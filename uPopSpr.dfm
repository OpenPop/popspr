object PopSprExt: TPopSprExt
  Left = 192
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Pop Sprite Extractor'
  ClientHeight = 226
  ClientWidth = 217
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object txtPal: TLabel
    Left = 8
    Top = 8
    Width = 89
    Height = 13
    Caption = 'Palette: not loaded'
  end
  object txtSpr: TLabel
    Left = 8
    Top = 24
    Width = 83
    Height = 13
    Caption = 'Sprite: not loaded'
  end
  object txtFrames: TLabel
    Left = 8
    Top = 40
    Width = 46
    Height = 13
    Caption = 'Frames: 0'
  end
  object txtALACN: TLabel
    Left = 160
    Top = 208
    Width = 49
    Height = 13
    Caption = 'by ALACN'
  end
  object btnLoadPal: TButton
    Left = 8
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Load Palette'
    TabOrder = 0
    OnClick = load_pal
  end
  object btnLoadSpr: TButton
    Left = 8
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Load Sprite'
    TabOrder = 1
    OnClick = load_spr
  end
  object btnExtract: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Extract'
    TabOrder = 2
    OnClick = extract
  end
  object progress: TProgressBar
    Left = 8
    Top = 184
    Width = 201
    Height = 17
    Min = 0
    Max = 100
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 8
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object pnlImg: TPanel
    Left = 88
    Top = 56
    Width = 121
    Height = 121
    BevelOuter = bvLowered
    TabOrder = 5
    object img: TImage
      Left = 0
      Top = 0
      Width = 65
      Height = 65
    end
  end
end
