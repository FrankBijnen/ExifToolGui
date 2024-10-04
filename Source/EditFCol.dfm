object FEditFColumn: TFEditFColumn
  Left = 0
  Top = 0
  Caption = 'Edit file columns'
  ClientHeight = 512
  ClientWidth = 1230
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object PnlGrids: TPanel
    Left = 0
    Top = 0
    Width = 1230
    Height = 483
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 1226
    ExplicitHeight = 482
    object HSplitter: TSplitter
      Left = 1
      Top = 200
      Width = 1228
      Height = 5
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 211
      ExplicitWidth = 653
    end
    object VSplitter: TSplitter
      Left = 876
      Top = 235
      Width = 5
      Height = 247
      Align = alRight
      Visible = False
      ExplicitLeft = 503
      ExplicitTop = 241
    end
    object PnlTop: TPanel
      Left = 1
      Top = 1
      Width = 1228
      Height = 30
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 1224
      object DBNavigator1: TDBNavigator
        Left = 10
        Top = 2
        Width = 216
        Height = 25
        DataSource = DmFileLists.DsFileListDef
        VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbPost, nbCancel]
        TabOrder = 0
      end
    end
    object DbgFileListDef: TDBGrid
      Left = 1
      Top = 31
      Width = 1228
      Height = 169
      Align = alTop
      DataSource = DmFileLists.DsFileListDef
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnKeyUp = DbGridKeyUp
      Columns = <
        item
          Expanded = False
          FieldName = 'Description'
          Width = 313
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Type'
          PickList.Strings = (
            'Internal'
            'ExifTool')
          ReadOnly = True
          Width = 96
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'ReadModeLookup'
          Title.Caption = 'ReadMode'
          Visible = True
        end>
    end
    object DbgColumnSet: TDBGrid
      Left = 1
      Top = 235
      Width = 875
      Height = 247
      Align = alClient
      DataSource = DmFileLists.DsColumnSet
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnEditButtonClick = DbgColumnSetEditButtonClick
      OnKeyUp = DbGridKeyUp
      Columns = <
        item
          Expanded = False
          FieldName = 'Caption'
          Width = 191
          Visible = True
        end
        item
          ButtonStyle = cbsEllipsis
          DropDownRows = 30
          Expanded = False
          FieldName = 'Command'
          Width = 186
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'OptionLookUp'
          Title.Caption = 'Option'
          Width = 83
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'AlignR'
          Title.Caption = 'Align Right'
          Width = 63
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'BackupLookUp'
          Title.Caption = 'Backup'
          Width = 59
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'SampleValue'
          Width = 252
          Visible = True
        end>
    end
    object PnlMiddle: TPanel
      Left = 1
      Top = 205
      Width = 1228
      Height = 30
      Align = alTop
      TabOrder = 3
      ExplicitWidth = 1224
      object DBNavigator2: TDBNavigator
        Left = 10
        Top = 2
        Width = 216
        Height = 25
        DataSource = DmFileLists.DsColumnSet
        VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbPost, nbCancel]
        TabOrder = 0
      end
    end
    object PnlDetail: TPanel
      Left = 881
      Top = 235
      Width = 348
      Height = 247
      Align = alRight
      TabOrder = 4
      Visible = False
      ExplicitLeft = 877
      ExplicitHeight = 246
      object DbgTagNames: TDBGrid
        Left = 1
        Top = 46
        Width = 346
        Height = 200
        Align = alClient
        DataSource = DmFileLists.DsTagNames
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDblClick = DbgTagNamesDblClick
        Columns = <
          item
            Expanded = False
            FieldName = 'TagName'
            Width = 125
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SampleValue'
            Width = 180
            Visible = True
          end>
      end
      object PnlEdSearch: TPanel
        Left = 1
        Top = 1
        Width = 346
        Height = 45
        Align = alTop
        TabOrder = 1
        DesignSize = (
          346
          45)
        object EdSearchTag: TLabeledEdit
          Left = 1
          Top = 23
          Width = 344
          Height = 21
          Align = alBottom
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = 'Search Tag name'
          TabOrder = 0
          Text = ''
          OnKeyUp = EdSearchTagKeyUp
        end
        object BtnLoadXMP: TButton
          Left = 263
          Top = 1
          Width = 82
          Height = 22
          Anchors = [akTop, akRight]
          Caption = 'Load XMP Tags'
          TabOrder = 1
          Visible = False
          OnClick = BtnLoadXMPClick
        end
      end
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 483
    Width = 1230
    Height = 29
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 482
    ExplicitWidth = 1226
    DesignSize = (
      1230
      29)
    object BtnOk: TBitBtn
      Left = 1005
      Top = 2
      Width = 87
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
      ExplicitLeft = 1001
    end
    object BtnCancel: TBitBtn
      Left = 1096
      Top = 2
      Width = 87
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
      ExplicitLeft = 1092
    end
  end
end
