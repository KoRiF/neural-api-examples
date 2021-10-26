object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'NeuralAPI CIFAR-10 example'
  ClientHeight = 136
  ClientWidth = 273
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Image1: TImage
    Left = 208
    Top = 80
    Width = 33
    Height = 33
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Train CIFAR-10'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 80
    Width = 105
    Height = 25
    Caption = 'Recognize'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ButtonedEdit1: TButtonedEdit
    Left = 8
    Top = 39
    Width = 129
    Height = 23
    Hint = 'Filename of the trained network'
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    RightButton.Visible = True
    ShowHint = True
    TabOrder = 2
    Text = 'ButtonedEdit1'
    OnRightButtonClick = ButtonedEdit1RightButtonClick
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Title = 'Open 32x32 bitmap picture to recognize'
    Left = 136
    Top = 72
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Neural Network Data|*.nn'
    Title = 'Open trained neural network data...'
    Left = 136
    Top = 40
  end
end
