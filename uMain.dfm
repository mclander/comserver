object Form1: TForm1
  Left = 242
  Top = 117
  Width = 1305
  Height = 675
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 560
    Top = 180
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 552
    Top = 316
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 652
    Top = 308
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Memo2: TMemo
    Left = 12
    Top = 44
    Width = 485
    Height = 397
    Lines.Strings = (
      'Memo2')
    TabOrder = 3
  end
  object Button3: TButton
    Left = 520
    Top = 12
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 196
    Top = 488
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 5
    OnClick = Button4Click
  end
  object ComboBox1: TComboBox
    Left = 12
    Top = 12
    Width = 485
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    Text = 'http://tech02:8080/'
    Items.Strings = (
      
        'http://www.rtsportscast.com:8080/comserver/recieve?formattername' +
        '=xml&userid=2&token=b6q15DSLNwQmH7kcxphueSdN3hCycCXFMmRdrA==&mat' +
        'ches=1,2,3,4,5,6,7'
      'http://tech02:8080/')
  end
  object tcpTest: TTcpClient
    RemoteHost = 'www.rtsportscast.com'
    RemotePort = '8080'
    OnConnect = tcpTestConnect
    OnDisconnect = tcpTestDisconnect
    OnReceive = tcpTestReceive
    Left = 636
    Top = 72
  end
  object WebDispatcher1: TWebDispatcher
    OldCreateOrder = False
    Actions = <>
    Left = 712
    Top = 52
    Height = 0
    Width = 0
  end
end
