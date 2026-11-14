object Form1: TForm1
  Left = 480
  Top = 254
  BorderStyle = bsNone
  Caption = 'Form1'
  ClientHeight = 84
  ClientWidth = 368
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GPanel1: TGPanel
    Left = 0
    Top = 0
    Width = 368
    Height = 86
    Align = alTop
    BevelInner = bvSpace
    BevelWidth = 2
    Caption = 'GPanel1'
    Color = clTeal
    TabOrder = 0
    Color_1 = clTeal
    Color_2 = clMoneyGreen
    Color_3 = clNone
    Horizontal = False
    object pb: TGauge
      Left = 12
      Top = 40
      Width = 345
      Height = 34
      ForeColor = clYellow
      Progress = 0
    end
    object lblJudul: TLabel
      Left = 4
      Top = 4
      Width = 360
      Height = 23
      Align = alTop
      Alignment = taCenter
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Button1: TButton
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      Visible = False
      OnClick = Button1Click
    end
  end
  object txtPenanda: TEdit
    Left = 136
    Top = 90
    Width = 121
    Height = 21
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = txtPenandaChange
  end
  object idHTTP: TIdHTTP
    MaxLineAction = maException
    ReadTimeout = 0
    OnWork = idHTTPWork
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
    Left = 136
    Top = 48
  end
end
