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
      Left = 326
      Top = 1
      Width = 6
      Height = 210
      ExplicitLeft = 288
      ExplicitHeight = 220
    end
    object PCTCommands: TPageControl
      Left = 1
      Top = 1
      Width = 325
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
          Top = 40
          Width = 317
          Height = 142
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
          WordWrap = False
          OnKeyDown = MemoKeyDown
          ExplicitHeight = 141
        end
        object PnlCommands: TPanel
          Left = 0
          Top = 0
          Width = 317
          Height = 40
          Align = alTop
          TabOrder = 1
          object BtnPowerShell: TButton
            Left = 233
            Top = 10
            Width = 85
            Height = 25
            Caption = 'PowerShell'
            TabOrder = 0
            OnClick = BtnPowerShellClick
          end
          object BtnCmd: TButton
            Left = 145
            Top = 10
            Width = 85
            Height = 25
            Caption = 'Cmd prompt'
            TabOrder = 1
            OnClick = BtnCmdClick
          end
          object RadShowCmds: TRadioGroup
            Left = 1
            Top = 1
            Width = 140
            Height = 38
            Align = alLeft
            Caption = 'Show commands as'
            Columns = 2
            Items.Strings = (
              'Args'
              'CmdLine')
            TabOrder = 2
            OnClick = RadShowCmdsClick
          end
        end
      end
    end
    object PCTOutput: TPageControl
      Left = 332
      Top = 1
      Width = 249
      Height = 210
      ActivePage = TabOutput
      Align = alClient
      Constraints.MinWidth = 100
      TabOrder = 0
      ExplicitWidth = 245
      ExplicitHeight = 209
      object TabOutput: TTabSheet
        Caption = 'Output from commands'
        object MemoOuts: TMemo
          Left = 0
          Top = 0
          Width = 241
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
          ExplicitWidth = 237
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
    Left = 200
    Top = 1
    Width = 364
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
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 123
    Top = 288
  end
  object SaveDialogCmd: TSaveDialog
    DefaultExt = '*.cmd'
    Filter = 'Command Files|*.cmd|All|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 225
    Top = 296
  end
end
