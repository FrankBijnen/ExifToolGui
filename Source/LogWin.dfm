object FLogWin: TFLogWin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'ExifTool LOG'
  ClientHeight = 551
  ClientWidth = 879
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 193
    Width = 879
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 97
    ExplicitWidth = 200
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 412
    Width = 879
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = -8
    ExplicitTop = 283
  end
  object PctExecs: TPageControl
    Left = 0
    Top = 0
    Width = 879
    Height = 193
    ActivePage = TabExecs
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 875
    object TabExecs: TTabSheet
      Caption = 'Logged ExifTool commands'
      object LBExecs: TListBox
        Left = 0
        Top = 0
        Width = 871
        Height = 165
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = LBExecsClick
        ExplicitWidth = 867
      end
    end
  end
  object PnlMidle: TPanel
    Left = 0
    Top = 196
    Width = 879
    Height = 216
    Align = alClient
    Constraints.MinWidth = 200
    TabOrder = 2
    ExplicitWidth = 875
    ExplicitHeight = 215
    object Splitter3: TSplitter
      Left = 386
      Top = 1
      Height = 214
      ExplicitLeft = 446
      ExplicitTop = 91
      ExplicitHeight = 100
    end
    object PCTCommands: TPageControl
      Left = 1
      Top = 1
      Width = 385
      Height = 214
      ActivePage = TabCommands
      Align = alLeft
      TabOrder = 1
      ExplicitHeight = 213
      object TabCommands: TTabSheet
        Caption = 'Executed commands'
        object MemoCmds: TMemo
          Left = 0
          Top = 0
          Width = 377
          Height = 186
          Align = alClient
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitHeight = 185
        end
      end
    end
    object PCTOutput: TPageControl
      Left = 389
      Top = 1
      Width = 489
      Height = 214
      ActivePage = TabOutput
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 485
      ExplicitHeight = 213
      object TabOutput: TTabSheet
        Caption = 'Output from commands'
        object MemoOuts: TMemo
          Left = 0
          Top = 0
          Width = 481
          Height = 186
          Align = alClient
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitWidth = 477
          ExplicitHeight = 185
        end
      end
    end
  end
  object PCTErrors: TPageControl
    Left = 0
    Top = 415
    Width = 879
    Height = 136
    ActivePage = TabErrors
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 414
    ExplicitWidth = 875
    object TabErrors: TTabSheet
      Caption = 'Errors'
      object MemoErrs: TMemo
        Left = 0
        Top = 0
        Width = 871
        Height = 108
        Align = alClient
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitWidth = 867
      end
    end
  end
end
