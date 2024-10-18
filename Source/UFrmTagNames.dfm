object FrmTagNames: TFrmTagNames
  Left = 0
  Top = 0
  Caption = 'Select tag name'
  ClientHeight = 318
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object Bevel1: TBevel
    Left = 5
    Top = 61
    Width = 550
    Height = 152
  end
  object Label1: TLabel
    Left = 18
    Top = 118
    Width = 530
    Height = 15
    AutoSize = False
    Caption = 'Group'
  end
  object Label2: TLabel
    Left = 18
    Top = 162
    Width = 530
    Height = 15
    AutoSize = False
    Caption = 'Tag'
  end
  object Label3: TLabel
    Left = 5
    Top = 243
    Width = 550
    Height = 15
    AutoSize = False
    Caption = 'Selected Tag name'
  end
  object Label4: TLabel
    Left = 18
    Top = 74
    Width = 530
    Height = 15
    AutoSize = False
    Caption = 'Family'
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 289
    Width = 560
    Height = 29
    Align = alBottom
    TabOrder = 6
    ExplicitTop = 288
    ExplicitWidth = 556
    DesignSize = (
      560
      29)
    object BtnOk: TBitBtn
      Left = 373
      Top = 3
      Width = 85
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      ModalResult = 1
      NumGlyphs = 2
      TabOrder = 0
      ExplicitLeft = 369
    end
    object BtnCancel: TBitBtn
      Left = 464
      Top = 3
      Width = 85
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333333333333333000033338833333333333333333F333333333333
        0000333911833333983333333388F333333F3333000033391118333911833333
        38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
        911118111118333338F3338F833338F3000033333911111111833333338F3338
        3333F8330000333333911111183333333338F333333F83330000333333311111
        8333333333338F3333383333000033333339111183333333333338F333833333
        00003333339111118333333333333833338F3333000033333911181118333333
        33338333338F333300003333911183911183333333383338F338F33300003333
        9118333911183333338F33838F338F33000033333913333391113333338FF833
        38F338F300003333333333333919333333388333338FFF830000333333333333
        3333333333333333333888330000333333333333333333333333333333333333
        0000}
      ModalResult = 2
      NumGlyphs = 2
      TabOrder = 1
      ExplicitLeft = 460
    end
  end
  object CmbGroupName: TComboBox
    Left = 18
    Top = 136
    Width = 530
    Height = 23
    TabOrder = 2
    OnChange = CmbGroupNameChange
  end
  object CmbTagName: TComboBox
    Left = 18
    Top = 180
    Width = 530
    Height = 23
    TabOrder = 3
    OnChange = CmbTagNameChange
    OnDrawItem = CmbTagNameDrawItem
  end
  object EdTagName: TEdit
    Left = 5
    Top = 260
    Width = 550
    Height = 23
    TabOrder = 5
    Text = 'EdTagName'
  end
  object RadTagValues: TRadioGroup
    Left = 5
    Top = 8
    Width = 550
    Height = 42
    Caption = 'Tag selection'
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'From sample'
      'All writable tags'
      'Free choice')
    TabOrder = 0
    OnClick = RadTagValuesClick
  end
  object CmbFamily: TComboBox
    Left = 18
    Top = 92
    Width = 530
    Height = 23
    ItemIndex = 1
    TabOrder = 1
    Text = '1 - Specific location'
    OnChange = CmbFamilyChange
    Items.Strings = (
      '0 - Information Type'
      '1 - Specific location')
  end
  object ChkExclude: TCheckBox
    Left = 5
    Top = 220
    Width = 550
    Height = 17
    Caption = 'Exclude Tag (Prefix with -)'
    TabOrder = 4
    OnClick = ChkExcludeClick
  end
end
