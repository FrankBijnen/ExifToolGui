object FLogWin: TFLogWin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'ExifTool LOG'
  ClientHeight = 544
  ClientWidth = 582
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 159
    Width = 582
    Height = 6
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 172
    ExplicitWidth = 568
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 402
    Width = 582
    Height = 6
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 403
    ExplicitWidth = 568
  end
  object PctExecs: TPageControl
    Left = 0
    Top = 0
    Width = 582
    Height = 159
    ActivePage = TabExecs
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 568
    object TabExecs: TTabSheet
      Caption = 'Logged ExifTool commands'
      object LBExecs: TListBox
        Left = 0
        Top = 0
        Width = 574
        Height = 131
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = LBExecsClick
        ExplicitWidth = 867
        ExplicitHeight = 165
      end
    end
  end
  object PnlMidle: TPanel
    Left = 0
    Top = 165
    Width = 582
    Height = 237
    Align = alClient
    Constraints.MinWidth = 200
    TabOrder = 2
    ExplicitTop = 196
    ExplicitWidth = 875
    ExplicitHeight = 215
    object Splitter3: TSplitter
      Left = 288
      Top = 1
      Width = 6
      Height = 235
      ExplicitHeight = 220
    end
    object PCTCommands: TPageControl
      Left = 1
      Top = 1
      Width = 287
      Height = 235
      ActivePage = TabCommands
      Align = alLeft
      TabOrder = 1
      ExplicitHeight = 205
      object TabCommands: TTabSheet
        Caption = 'Executed commands'
        object MemoCmds: TMemo
          Left = 0
          Top = 0
          Width = 279
          Height = 207
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
          OnKeyDown = MemoKeyDown
          ExplicitWidth = 377
          ExplicitHeight = 185
        end
      end
    end
    object PCTOutput: TPageControl
      Left = 294
      Top = 1
      Width = 287
      Height = 235
      ActivePage = TabOutput
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 389
      ExplicitWidth = 485
      ExplicitHeight = 213
      object TabOutput: TTabSheet
        Caption = 'Output from commands'
        object MemoOuts: TMemo
          Left = 0
          Top = 0
          Width = 279
          Height = 207
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
          OnKeyDown = MemoKeyDown
          ExplicitWidth = 477
          ExplicitHeight = 185
        end
      end
    end
  end
  object PCTErrors: TPageControl
    Left = 0
    Top = 408
    Width = 582
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
        Width = 574
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
        OnKeyDown = MemoKeyDown
        ExplicitWidth = 867
      end
    end
  end
end
