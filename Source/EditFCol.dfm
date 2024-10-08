object FEditFColumn: TFEditFColumn
  Left = 0
  Top = 0
  Caption = 'Edit file columns'
  ClientHeight = 512
  ClientWidth = 1157
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object PnlGrids: TPanel
    Left = 0
    Top = 0
    Width = 1157
    Height = 483
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 1226
    ExplicitHeight = 482
    object HSplitter: TSplitter
      Left = 1
      Top = 200
      Width = 1155
      Height = 5
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 211
      ExplicitWidth = 653
    end
    object VSplitter: TSplitter
      Left = 803
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
      Width = 1155
      Height = 30
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 1224
      object SpbAddPred: TSpeedButton
        Left = 2
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Add'
        OnClick = SpbAddPredClick
      end
      object SpbDelPred: TSpeedButton
        Left = 104
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Delete'
        OnClick = SpbDelPredClick
      end
      object SpbEditPred: TSpeedButton
        Left = 206
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Edit'
        OnClick = SpbEditPredClick
      end
      object SpbDuplicate: TSpeedButton
        Left = 308
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Duplicate'
        OnClick = SpbDuplicateClick
      end
      object SpbDefaults: TSpeedButton
        Left = 411
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Defaults'
        OnClick = SpbDefaultsClick
      end
      object DBNavFileList: TDBNavigator
        Left = 516
        Top = 3
        Width = 176
        Height = 25
        DataSource = DmFileLists.DsFileListDef
        VisibleButtons = [nbPrior, nbNext, nbPost, nbCancel]
        TabOrder = 0
      end
    end
    object DbgFileListDef: TDBGrid
      Left = 1
      Top = 31
      Width = 1155
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
          FieldName = 'Name'
          Visible = True
        end
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
          Width = 64
          Visible = True
        end>
    end
    object DbgColumnSet: TDBGrid
      Left = 1
      Top = 235
      Width = 802
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
      Width = 1155
      Height = 30
      Align = alTop
      TabOrder = 3
      ExplicitWidth = 1224
      object SpbAddTag: TSpeedButton
        Left = 2
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Add'
        OnClick = SpbAddTagClick
      end
      object SpbDelTag: TSpeedButton
        Left = 104
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Delete'
        OnClick = SpbDelTagClick
      end
      object SpbEditTag: TSpeedButton
        Left = 206
        Top = 3
        Width = 100
        Height = 25
        Caption = 'Edit'
        OnClick = SpbEditTagClick
      end
      object DBNavColumnSet: TDBNavigator
        Left = 310
        Top = 3
        Width = 176
        Height = 25
        DataSource = DmFileLists.DsColumnSet
        VisibleButtons = [nbPrior, nbNext, nbPost, nbCancel]
        TabOrder = 0
      end
    end
    object PnlDetail: TPanel
      Left = 808
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
        Top = 25
        Width = 346
        Height = 221
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
        Height = 24
        Align = alTop
        TabOrder = 1
        object BtnApplyTag: TButton
          Left = 270
          Top = 1
          Width = 75
          Height = 22
          Align = alRight
          Caption = 'Apply'
          TabOrder = 0
          OnClick = BtnApplyTagClick
        end
        object PnlSearch: TPanel
          Left = 1
          Top = 1
          Width = 269
          Height = 22
          Align = alClient
          Alignment = taLeftJustify
          TabOrder = 1
          object LblSearchTag: TLabel
            AlignWithMargins = True
            Left = 11
            Top = 4
            Width = 85
            Height = 14
            Margins.Left = 10
            Margins.Right = 5
            Align = alLeft
            Caption = 'Search tag name:'
            Layout = tlCenter
            ExplicitHeight = 13
          end
          object EdSearchTag: TEdit
            Left = 101
            Top = 1
            Width = 167
            Height = 20
            Align = alClient
            TabOrder = 0
            Text = 'EdSearchTag'
            OnKeyUp = EdSearchTagKeyUp
            ExplicitHeight = 21
          end
        end
      end
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 483
    Width = 1157
    Height = 29
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 482
    ExplicitWidth = 1226
    DesignSize = (
      1157
      29)
    object BtnOk: TBitBtn
      Left = 920
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
      ExplicitLeft = 989
    end
    object BtnCancel: TBitBtn
      Left = 1011
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
      ExplicitLeft = 1080
    end
  end
end
