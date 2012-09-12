object Form1: TForm1
  Left = 242
  Top = 117
  Width = 527
  Height = 761
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object mOut: TMemo
    Left = 12
    Top = 44
    Width = 485
    Height = 397
    Lines.Strings = (
      'Memo2')
    TabOrder = 0
  end
  object Button3: TButton
    Left = 416
    Top = 12
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 1
    OnClick = Button3Click
  end
  object cbUrl: TComboBox
    Left = 12
    Top = 12
    Width = 389
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = 'http://tech02:8080/'
    Items.Strings = (
      
        'http://www.rtsportscast.com:8080/comserver/recieve?formattername' +
        '=xml&userid=2&token=b6q15DSLNwQmH7kcxphueSdN3hCycCXFMmRdrA==&mat' +
        'ches=1,2,3,4,5,6,7'
      'http://tech02:8080/')
  end
  object Edit1: TEdit
    Left = 16
    Top = 504
    Width = 473
    Height = 21
    TabOrder = 3
    Text = 
      'http://member.rtsportscast.com/comserver/getevents?formattername' +
      '=json&userid=8375&token=test&lastid=0&topic=168920'
  end
  object Button1: TButton
    Left = 52
    Top = 552
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 4
    OnClick = Button1Click
  end
  object IdHTTP1: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    Host = 
      'http://member.rtsportscast.com/comserver/getevents?formattername' +
      '=json&userid=8375&token=test&lastid=0&topic=168920'
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 244
    Top = 536
  end
end
