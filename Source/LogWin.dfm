object FLogWin: TFLogWin
  Left = 108
  Top = 106
  BorderIcons = [biSystemMenu]
  Caption = 'ExifTool LOG'
  ClientHeight = 538
  ClientWidth = 613
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 184
    Width = 613
    Height = 6
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 172
    ExplicitWidth = 568
  end
  object Splitter2: TSplitter
    Left = 0
    Top = 396
    Width = 613
    Height = 6
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 403
    ExplicitWidth = 568
  end
  object PctExecs: TPageControl
    Left = 0
    Top = 0
    Width = 613
    Height = 184
    ActivePage = TabExecs
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 609
    object TabExecs: TTabSheet
      Caption = 'Logged ExifTool commands'
      object LBExecs: TListBox
        Left = 0
        Top = 0
        Width = 605
        Height = 156
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
        OnClick = LBExecsClick
        ExplicitWidth = 601
      end
    end
  end
  object PnlMidle: TPanel
    Left = 0
    Top = 190
    Width = 613
    Height = 206
    Align = alClient
    Constraints.MinHeight = 200
    Constraints.MinWidth = 200
    TabOrder = 2
    ExplicitWidth = 609
    ExplicitHeight = 205
    object Splitter3: TSplitter
      Left = 331
      Top = 1
      Width = 6
      Height = 204
      ExplicitLeft = 288
      ExplicitHeight = 220
    end
    object PCTCommands: TPageControl
      Left = 1
      Top = 1
      Width = 330
      Height = 204
      ActivePage = TabCommands
      Align = alLeft
      Constraints.MinWidth = 285
      TabOrder = 1
      ExplicitHeight = 203
      object TabCommands: TTabSheet
        Caption = 'Executed commands'
        object PnlCommands: TPanel
          Left = 0
          Top = 0
          Width = 322
          Height = 40
          Align = alTop
          TabOrder = 0
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
            ItemIndex = 0
            Items.Strings = (
              'Args'
              'CmdLine')
            TabOrder = 2
            OnClick = RadShowCmdsClick
          end
        end
        object MemoCmds: TMemo
          Left = 0
          Top = 40
          Width = 322
          Height = 136
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
          TabOrder = 1
          WordWrap = False
          OnKeyDown = MemoKeyDown
          ExplicitHeight = 135
        end
      end
      object TabRestRequest: TTabSheet
        Caption = 'Rest request'
        ImageIndex = 1
        object PnlUrl: TPanel
          Left = 0
          Top = 0
          Width = 322
          Height = 34
          Align = alTop
          TabOrder = 0
          object BtnUrl: TButton
            Left = 0
            Top = 4
            Width = 85
            Height = 25
            Caption = 'Open Url'
            TabOrder = 0
            OnClick = BtnUrlClick
          end
        end
        object MemoUrl: TMemo
          Left = 0
          Top = 34
          Width = 322
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
          TabOrder = 1
          WordWrap = False
          OnKeyDown = MemoKeyDown
        end
      end
    end
    object PCTOutput: TPageControl
      Left = 337
      Top = 1
      Width = 275
      Height = 204
      ActivePage = TabOutput
      Align = alClient
      Constraints.MinWidth = 100
      TabOrder = 0
      ExplicitWidth = 271
      ExplicitHeight = 203
      object TabOutput: TTabSheet
        Caption = 'Output from commands'
        object MemoOuts: TMemo
          Left = 0
          Top = 0
          Width = 267
          Height = 176
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
          ExplicitWidth = 263
          ExplicitHeight = 175
        end
      end
    end
  end
  object PCTErrors: TPageControl
    Left = 0
    Top = 402
    Width = 613
    Height = 136
    ActivePage = TabErrors
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 401
    ExplicitWidth = 609
    object TabErrors: TTabSheet
      Caption = 'Errors'
      object MemoErrs: TMemo
        Left = 0
        Top = 0
        Width = 605
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
        ExplicitWidth = 601
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
