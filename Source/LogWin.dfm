object FLogWin: TFLogWin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
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
    Top = 184
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
    Height = 184
    ActivePage = TabExecs
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 578
    object TabExecs: TTabSheet
      Caption = 'Logged ExifTool commands'
      object LBExecs: TListBox
        Left = 0
        Top = 0
        Width = 574
        Height = 156
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = LBExecsClick
        ExplicitWidth = 570
      end
    end
  end
  object PnlMidle: TPanel
    Left = 0
    Top = 190
    Width = 582
    Height = 212
    Align = alClient
    Constraints.MinHeight = 200
    Constraints.MinWidth = 200
    TabOrder = 2
    ExplicitWidth = 578
    ExplicitHeight = 211
    object Splitter3: TSplitter
      Left = 288
      Top = 1
      Width = 6
      Height = 210
      ExplicitHeight = 220
    end
    object PCTCommands: TPageControl
      Left = 1
      Top = 1
      Width = 287
      Height = 210
      ActivePage = TabCommands
      Align = alLeft
      Constraints.MinWidth = 285
      TabOrder = 1
      ExplicitHeight = 209
      object TabCommands: TTabSheet
        Caption = 'Executed commands'
        object MemoCmds: TMemo
          Left = 0
          Top = 28
          Width = 279
          Height = 154
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
          ExplicitHeight = 153
        end
        object PnlCommands: TPanel
          Left = 0
          Top = 0
          Width = 279
          Height = 28
          Align = alTop
          TabOrder = 1
          object BtnArgs: TButton
            Left = -1
            Top = 1
            Width = 75
            Height = 25
            Caption = 'Args'
            TabOrder = 0
            OnClick = BtnArgsClick
          end
          object BtnCommand: TButton
            Left = 85
            Top = 1
            Width = 75
            Height = 25
            Caption = 'Command'
            TabOrder = 1
            OnClick = BtnCommandClick
          end
          object BtnPowerShell: TButton
            Left = 171
            Top = 1
            Width = 75
            Height = 25
            Caption = 'PowerShell'
            TabOrder = 2
            OnClick = BtnPowerShellClick
          end
        end
      end
    end
    object PCTOutput: TPageControl
      Left = 294
      Top = 1
      Width = 287
      Height = 210
      ActivePage = TabOutput
      Align = alClient
      Constraints.MinWidth = 100
      TabOrder = 0
      ExplicitWidth = 283
      ExplicitHeight = 209
      object TabOutput: TTabSheet
        Caption = 'Output from commands'
        object MemoOuts: TMemo
          Left = 0
          Top = 0
          Width = 279
          Height = 182
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
          ExplicitWidth = 275
          ExplicitHeight = 181
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
    ExplicitTop = 407
    ExplicitWidth = 578
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
        ExplicitWidth = 570
      end
    end
  end
  object ChkShowAll: TCheckBox
    Left = 155
    Top = 1
    Width = 131
    Height = 17
    Hint = 
      'Show also non-critical commands to populate the Metadata and fil' +
      'elist?'
    Caption = 'Show all Commands'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object SaveDialogPS: TSaveDialog
    DefaultExt = '*.ps1'
    Filter = 'Powershell files|*.ps1|All|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 123
    Top = 288
  end
end
