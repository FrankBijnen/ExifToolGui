object FEditFColumn: TFEditFColumn
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Edit file columns'
  ClientHeight = 515
  ClientWidth = 937
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object VSplitter: TSplitter
    Left = 735
    Top = 0
    Width = 5
    Height = 486
    Align = alRight
    ExplicitLeft = 1
    ExplicitTop = 1
    ExplicitHeight = 473
  end
  object PnlGrids: TPanel
    Left = 0
    Top = 0
    Width = 735
    Height = 486
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 638
    ExplicitHeight = 474
    object HSplitter: TSplitter
      Left = 1
      Top = 200
      Width = 733
      Height = 5
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 211
      ExplicitWidth = 653
    end
    object PnlTop: TPanel
      Left = 1
      Top = 1
      Width = 733
      Height = 30
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 636
      object DBNavigator1: TDBNavigator
        Left = 10
        Top = 2
        Width = 216
        Height = 25
        DataSource = DsFileListDef
        VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbPost, nbCancel]
        TabOrder = 0
      end
    end
    object DbgFileListDef: TDBGrid
      Left = 1
      Top = 31
      Width = 733
      Height = 169
      Align = alTop
      DataSource = DsFileListDef
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'Id'
          ReadOnly = True
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Name'
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Description'
          Width = 291
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Mode'
          PickList.Strings = (
            'Internal'
            'ExifTool')
          ReadOnly = True
          Visible = True
        end>
    end
    object DbgColumnSet: TDBGrid
      Left = 1
      Top = 235
      Width = 733
      Height = 250
      Align = alClient
      DataSource = DsColumnSet
      Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      Columns = <
        item
          Expanded = False
          FieldName = 'Caption'
          Width = 158
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Command'
          Width = 263
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Backup'
          PickList.Strings = (
            ''
            'Yes')
          Width = 56
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'Option'
          PickList.Strings = (
            'Sys'
            'Decimal'
            'YesNo'
            'HorVer'
            'Flash'
            'Country')
          Width = 82
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'AlignR'
          Title.Caption = 'Align Right'
          Visible = True
        end>
    end
    object PnlMiddle: TPanel
      Left = 1
      Top = 205
      Width = 733
      Height = 30
      Align = alTop
      TabOrder = 3
      ExplicitWidth = 636
      object DBNavigator2: TDBNavigator
        Left = 10
        Top = 2
        Width = 216
        Height = 25
        DataSource = DsColumnSet
        VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbPost, nbCancel]
        TabOrder = 0
      end
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 486
    Width = 937
    Height = 29
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 474
    ExplicitWidth = 872
    DesignSize = (
      937
      29)
    object BtnOk: TBitBtn
      Left = 722
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
      ExplicitLeft = 657
    end
    object BtnCancel: TBitBtn
      Left = 813
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
      ExplicitLeft = 748
    end
  end
  object PnlRight: TPanel
    Left = 740
    Top = 0
    Width = 197
    Height = 486
    Align = alRight
    TabOrder = 1
  end
  object CdsColumnSet: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'FileListName'
    Params = <>
    AfterInsert = CdsColumnSetAfterInsert
    Left = 875
    Top = 266
    object CdsColumnSetFileListName: TStringField
      DisplayWidth = 25
      FieldName = 'FileListName'
      Visible = False
      Size = 64
    end
    object CdsColumnSetName: TStringField
      DisplayWidth = 50
      FieldName = 'Caption'
      Size = 255
    end
    object CdsColumnSetCommand: TStringField
      DisplayWidth = 64
      FieldName = 'Command'
      Size = 255
    end
    object CdsColumnSetBackup: TStringField
      DisplayWidth = 6
      FieldName = 'Backup'
      Size = 6
    end
    object CdsColumnSetOption: TStringField
      FieldName = 'Option'
      Size = 10
    end
    object CdsColumnSetAlignR: TIntegerField
      FieldName = 'AlignR'
      DisplayFormat = '#'
    end
    object CdsColumnSetWidth: TStringField
      FieldName = 'Width'
    end
  end
  object CdsFileListDef: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterInsert = CdsFileListDefAfterInsert
    Left = 862
    Top = 108
    object CdsFileListDefId: TIntegerField
      FieldName = 'Id'
      Visible = False
    end
    object CdsFileListDefName: TStringField
      DisplayWidth = 25
      FieldName = 'Name'
      Size = 64
    end
    object CdsFileListDefDescription: TStringField
      DisplayWidth = 50
      FieldName = 'Description'
      Size = 255
    end
    object CdsFileListDefMode: TStringField
      DisplayWidth = 10
      FieldName = 'Mode'
      Size = 10
    end
  end
  object DsFileListDef: TDataSource
    DataSet = CdsFileListDef
    Left = 785
    Top = 107
  end
  object DsColumnSet: TDataSource
    DataSet = CdsColumnSet
    Left = 784
    Top = 268
  end
end
