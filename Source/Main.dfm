object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'FMain'
  ClientHeight = 600
  ClientWidth = 965
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 240
    Top = 0
    Width = 5
    Height = 581
    Color = clBtnFace
    MinSize = 160
    ParentColor = False
    OnCanResize = Splitter1CanResize
    ExplicitHeight = 587
  end
  object Splitter2: TSplitter
    Left = 640
    Top = 0
    Width = 5
    Height = 581
    Align = alRight
    MinSize = 284
    OnCanResize = Splitter2CanResize
    ExplicitLeft = 645
    ExplicitHeight = 587
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 581
    Width = 965
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
    ExplicitTop = 580
    ExplicitWidth = 961
  end
  object AdvPanelBrowse: TPanel
    Left = 0
    Top = 0
    Width = 240
    Height = 581
    Align = alLeft
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 1
    ExplicitHeight = 580
    object Splitter3: TSplitter
      Left = 1
      Top = 355
      Width = 238
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      MinSize = 128
      OnCanResize = Splitter3CanResize
      ExplicitTop = 362
    end
    object AdvPageBrowse: TPageControl
      Left = 1
      Top = 1
      Width = 238
      Height = 354
      ActivePage = AdvTabBrowse
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 353
      object AdvTabBrowse: TTabSheet
        Caption = 'Browse'
        object ShellTree: TShellTreeView
          Left = 0
          Top = 0
          Width = 230
          Height = 326
          ObjectTypes = [otFolders]
          Root = 'rfDesktop'
          ShellListView = ShellList
          UseShellImages = True
          Align = alClient
          AutoRefresh = False
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          HideSelection = False
          Indent = 23
          ParentColor = False
          ParentFont = False
          RightClickSelect = True
          ShowRoot = False
          TabOrder = 0
          OnClick = ShellTreeClick
          OnChange = ShellTreeChange
          ExplicitHeight = 325
        end
      end
    end
    object AdvPagePreview: TPageControl
      Left = 1
      Top = 359
      Width = 238
      Height = 221
      ActivePage = AdvTabPreview
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 358
      object AdvTabPreview: TTabSheet
        Caption = 'Preview '
        object RotateImg: TImage
          Left = 0
          Top = 0
          Width = 230
          Height = 193
          Align = alClient
          Proportional = True
          Stretch = True
          ExplicitLeft = 46
          ExplicitTop = 60
          ExplicitWidth = 105
          ExplicitHeight = 105
        end
      end
    end
  end
  object AdvPageMetadata: TPageControl
    Left = 645
    Top = 0
    Width = 320
    Height = 581
    ActivePage = AdvTabMetadata
    Align = alRight
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    ExplicitLeft = 641
    ExplicitHeight = 580
    object AdvTabMetadata: TTabSheet
      Caption = 'Metadata'
      object AdvPanelMetaTop: TPanel
        Left = 0
        Top = 0
        Width = 312
        Height = 57
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object SpeedBtnExif: TSpeedButton
          Left = 2
          Top = 2
          Width = 50
          Height = 21
          GroupIndex = 1
          Caption = 'Exif'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnIptc: TSpeedButton
          Left = 94
          Top = 2
          Width = 42
          Height = 21
          GroupIndex = 1
          Caption = 'Iptc'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnXmp: TSpeedButton
          Left = 52
          Top = 2
          Width = 42
          Height = 21
          GroupIndex = 1
          Caption = 'Xmp'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnMaker: TSpeedButton
          Left = 136
          Top = 2
          Width = 42
          Height = 21
          GroupIndex = 1
          Caption = 'Maker'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnALL: TSpeedButton
          Left = 178
          Top = 2
          Width = 32
          Height = 21
          GroupIndex = 1
          Caption = 'ALL'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnCustom: TSpeedButton
          Left = 210
          Top = 2
          Width = 50
          Height = 21
          GroupIndex = 1
          Caption = 'Custom'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnQuick: TSpeedButton
          Left = 2
          Top = 29
          Width = 92
          Height = 22
          GroupIndex = 1
          Down = True
          Caption = 'Workspace'
          OnClick = SpeedBtnExifClick
        end
      end
      object AdvPanelMetaBottom: TPanel
        Left = 0
        Top = 447
        Width = 312
        Height = 106
        Align = alBottom
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        ExplicitTop = 446
        DesignSize = (
          312
          106)
        object SpeedBtnLarge: TSpeedButton
          Left = 2
          Top = 6
          Width = 42
          Height = 22
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'Large'
          OnClick = SpeedBtnLargeClick
        end
        object SpeedBtnQuickSave: TSpeedButton
          Left = 266
          Top = 6
          Width = 42
          Height = 22
          Anchors = [akTop, akRight]
          Caption = 'Save'
          OnClick = BtnQuickSaveClick
        end
        object MemoQuick: TMemo
          Left = 2
          Top = 40
          Width = 306
          Height = 63
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          WantReturns = False
          OnEnter = EditQuickEnter
          OnExit = EditQuickExit
          OnKeyDown = EditQuickKeyDown
        end
        object EditQuick: TEdit
          Left = 48
          Top = 6
          Width = 212
          Height = 22
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnEnter = EditQuickEnter
          OnExit = EditQuickExit
          OnKeyDown = EditQuickKeyDown
        end
      end
      object MetadataList: TValueListEditor
        Left = 0
        Top = 57
        Width = 312
        Height = 390
        Align = alClient
        BorderStyle = bsNone
        DefaultRowHeight = 19
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goThumbTracking]
        ParentFont = False
        PopupMenu = QuickPopUpMenu
        TabOrder = 2
        TitleCaptions.Strings = (
          'Tag name'
          'Value')
        OnDrawCell = MetadataListDrawCell
        OnExit = MetadataListExit
        OnKeyDown = MetadataListKeyDown
        OnMouseDown = MetadataListMouseDown
        OnSelectCell = MetadataListSelectCell
        ExplicitHeight = 389
        ColWidths = (
          150
          160)
      end
    end
    object AdvTabOSMMap: TTabSheet
      Caption = 'OSM Map'
      object AdvPanel_MapTop: TPanel
        Left = 0
        Top = 0
        Width = 312
        Height = 57
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object SpeedBtn_ShowOnMap: TSpeedButton
          Left = 2
          Top = 2
          Width = 79
          Height = 22
          Caption = 'Show on map'
          OnClick = SpeedBtn_ShowOnMapClick
        end
        object SpeedBtn_MapHome: TSpeedButton
          Left = 271
          Top = 2
          Width = 40
          Height = 22
          Caption = 'Home'
          OnClick = SpeedBtn_MapHomeClick
        end
        object SpeedBtn_MapSetHome: TSpeedButton
          Left = 271
          Top = 28
          Width = 40
          Height = 21
          Caption = 'Set^'
          OnClick = SpeedBtn_MapSetHomeClick
        end
        object Spb_GoBack: TSpeedButton
          Left = 105
          Top = 2
          Width = 61
          Height = 22
          Caption = '<< Back'
          OnClick = Spb_GoBackClick
        end
        object Spb_Forward: TSpeedButton
          Left = 199
          Top = 2
          Width = 66
          Height = 22
          Caption = 'Forward>>'
          OnClick = Spb_ForwardClick
        end
        object SpeedBtn_GetLoc: TSpeedButton
          Left = 2
          Top = 28
          Width = 79
          Height = 22
          Hint = 'Sets to Lat/Lon values to the center of map'
          Caption = 'Get location'
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedBtn_GetLocClick
        end
        object EditMapFind: TLabeledEdit
          Left = 112
          Top = 30
          Width = 153
          Height = 21
          Hint = 'Use Ctrl+Click on the map to set the Lat/Lon values'
          EditLabel.Width = 24
          EditLabel.Height = 21
          EditLabel.Caption = 'Find:'
          LabelPosition = lpLeft
          MaxLength = 127
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Text = ''
          TextHint = '0.1234, 0.1234'
          OnChange = EditMapFindChange
          OnKeyDown = EditMapFindKeyDown
        end
      end
      object AdvPanel_MapBottom: TPanel
        Left = 0
        Top = 521
        Width = 312
        Height = 32
        Align = alBottom
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object SpeedBtn_Geotag: TSpeedButton
          Left = 2
          Top = 6
          Width = 79
          Height = 21
          Caption = 'Geotag files'
          OnClick = SpeedBtn_GeotagClick
        end
      end
      object EdgeBrowser1: TEdgeBrowser
        Left = 0
        Top = 57
        Width = 312
        Height = 464
        Align = alClient
        TabOrder = 2
        UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
        OnWebMessageReceived = EdgeBrowser1WebMessageReceived
      end
    end
  end
  object AdvPageFilelist: TPageControl
    Left = 245
    Top = 0
    Width = 395
    Height = 581
    ActivePage = AdvTabFilelist
    Align = alClient
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 3
    ExplicitWidth = 391
    ExplicitHeight = 580
    object AdvTabFilelist: TTabSheet
      Caption = 'Filelist'
      object AdvPanelFileTop: TPanel
        Left = 0
        Top = 0
        Width = 387
        Height = 57
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        ExplicitWidth = 383
        object SpeedBtnDetails: TSpeedButton
          Left = 2
          Top = 29
          Width = 55
          Height = 22
          AllowAllUp = True
          GroupIndex = 1
          Down = True
          Caption = 'Details:'
          OnClick = SpeedBtnDetailsClick
        end
        object SpeedBtnFListRefresh: TSpeedButton
          Left = 2
          Top = 2
          Width = 55
          Height = 21
          Caption = 'Refresh'
          OnClick = BtnFListRefreshClick
        end
        object SpeedBtnFilterEdit: TSpeedButton
          Left = 231
          Top = 2
          Width = 42
          Height = 21
          Caption = 'Edit'
          OnClick = BtnFilterEditClick
        end
        object SpeedBtnColumnEdit: TSpeedButton
          Left = 231
          Top = 29
          Width = 42
          Height = 22
          Caption = 'Edit'
          OnClick = BtnColumnEditClick
        end
        object CBoxDetails: TComboBox
          Left = 61
          Top = 29
          Width = 164
          Height = 21
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'Standard filelist'
          OnChange = CBoxDetailsChange
          Items.Strings = (
            'Standard filelist'
            'Camera settings'
            'Location info'
            'About photo'
            'User defined')
        end
        object CBoxFileFilter: TComboBox
          Left = 61
          Top = 2
          Width = 164
          Height = 21
          AutoComplete = False
          DropDownCount = 16
          TabOrder = 1
          OnChange = CBoxFileFilterChange
          OnKeyDown = CBoxFileFilterKeyDown
          Items.Strings = (
            '-')
        end
      end
      object AdvPanelETdirect: TPanel
        Left = 0
        Top = 369
        Width = 387
        Height = 184
        Align = alBottom
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        ExplicitTop = 368
        ExplicitWidth = 383
        DesignSize = (
          387
          184)
        object LabelCounter: TLabel
          Left = 124
          Top = 6
          Width = 32
          Height = 18
          Alignment = taRightJustify
          Caption = '0000'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -15
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Visible = False
        end
        object SpeedBtn_ETdirect: TSpeedButton
          Left = 2
          Top = 6
          Width = 103
          Height = 22
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'ExifTool direct'
          OnClick = SpeedBtn_ETdirectClick
        end
        object SpeedBtn_ETedit: TSpeedButton
          Left = 287
          Top = 79
          Width = 98
          Height = 21
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Edit predefined'
          OnClick = SpeedBtn_ETeditClick
        end
        object SpeedBtnShowLog: TSpeedButton
          Left = 170
          Top = 6
          Width = 103
          Height = 22
          Caption = 'Show Log window'
          OnClick = BtnShowLogClick
        end
        object SpeedBtnETdirectDel: TSpeedButton
          Left = 2
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Delete'
          Enabled = False
          OnClick = BtnETdirectDelClick
        end
        object SpeedBtnETdirectReplace: TSpeedButton
          Left = 71
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Replace'
          Enabled = False
          OnClick = BtnETdirectReplaceClick
        end
        object SpeedBtnETdirectAdd: TSpeedButton
          Left = 141
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Add new'
          Enabled = False
          OnClick = BtnETdirectAddClick
        end
        object SpeedBtn_ETdSetDef: TSpeedButton
          Left = 210
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Default'
          OnClick = SpeedBtn_ETdSetDefClick
        end
        object SpeedBtn_ETclear: TSpeedButton
          Left = 287
          Top = 114
          Width = 58
          Height = 25
          Caption = 'Deselect'
          OnClick = SpeedBtn_ETclearClick
        end
        object EditETdirect: TLabeledEdit
          Left = 2
          Top = 50
          Width = 280
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          EditLabel.Width = 172
          EditLabel.Height = 13
          EditLabel.Caption = 'Command (press Enter to execute):'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          Text = ''
          OnChange = EditETdirectChange
          OnKeyDown = EditETdirectKeyDown
          ExplicitWidth = 276
        end
        object CBoxETdirect: TComboBox
          Left = 2
          Top = 79
          Width = 271
          Height = 21
          Style = csDropDownList
          DropDownCount = 16
          TabOrder = 1
          OnChange = CBoxETdirectChange
        end
        object EditETcmdName: TLabeledEdit
          Left = 2
          Top = 156
          Width = 271
          Height = 22
          EditLabel.Width = 80
          EditLabel.Height = 13
          EditLabel.Caption = 'Command name:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          Text = ''
          OnChange = EditETcmdNameChange
        end
      end
      object ShellList: TShellListView
        Left = 0
        Top = 57
        Width = 387
        Height = 312
        ObjectTypes = [otNonFolders]
        Root = 'rfDesktop'
        ShellTreeView = ShellTree
        Sorted = True
        OnAddFolder = ShellListAddItem
        Align = alClient
        BorderStyle = bsNone
        Color = clWhite
        OnClick = ShellListClick
        ReadOnly = False
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        GridLines = True
        HideSelection = False
        IconOptions.AutoArrange = True
        MultiSelect = True
        RowSelect = True
        OnChange = ShellListChange
        OnColumnClick = ShellListColumnClick
        ParentFont = False
        TabOrder = 2
        ViewStyle = vsReport
        OnKeyUp = ShellListKeyUp
      end
    end
    object AdvTabChart: TTabSheet
      Caption = 'Chart'
      object AdvPanel1: TPanel
        Left = 0
        Top = 0
        Width = 387
        Height = 137
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object SpeedBtnChartRefresh: TSpeedButton
          Left = 214
          Top = 104
          Width = 74
          Height = 24
          Caption = 'Refresh'
          OnClick = SpeedBtnChartRefreshClick
        end
        object AdvCheckBox_Subfolders: TCheckBox
          Left = 8
          Top = 104
          Width = 120
          Height = 20
          Alignment = taLeftJustify
          Caption = '+subfolders'
          TabOrder = 0
        end
        object AdvRadioGroup1: TRadioGroup
          Left = 8
          Top = 0
          Width = 280
          Height = 42
          Caption = 'Files'
          Columns = 6
          ItemIndex = 0
          Items.Strings = (
            'Any'
            'JPG'
            'CR2'
            'NEF'
            'PEF'
            'DNG')
          ParentBackground = False
          TabOrder = 1
          OnClick = AdvRadioGroup1Click
        end
        object AdvRadioGroup2: TRadioGroup
          Left = 8
          Top = 48
          Width = 280
          Height = 50
          Caption = 'Value'
          Columns = 3
          ItemIndex = 0
          Items.Strings = (
            'FLength [4-300]'
            'FNumber [1.2-22]'
            'ISO [50-6400]')
          ParentBackground = False
          TabOrder = 2
          WordWrap = True
          OnClick = AdvRadioGroup2Click
        end
      end
      object ETChart: TChart
        Left = 0
        Top = 137
        Width = 387
        Height = 416
        Legend.Visible = False
        Title.Font.Color = clBlack
        Title.Font.Height = -19
        Title.Text.Strings = (
          'Focal Length')
        LeftAxis.Automatic = False
        LeftAxis.AutomaticMaximum = False
        LeftAxis.AutomaticMinimum = False
        LeftAxis.Maximum = 15.000000000000000000
        Align = alClient
        TabOrder = 1
        DefaultCanvas = 'TGDIPlusCanvas'
        PrintMargins = (
          27
          15
          27
          15)
        ColorPaletteIndex = 13
        object Series1: TBarSeries
          HoverElement = []
          Marks.Visible = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
          Data = {
            0406000000000000000000F03FFF03000000322E300000000000000040FF0300
            0000322E380000000000002040FF03000000342E300000000000002040FF0300
            0000352E360000000000001040FF03000000382E300000000000001040FF0400
            000031312E30}
        end
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 120
    object MProgram: TMenuItem
      Caption = 'Program'
      object MAbout: TMenuItem
        Tag = 1
        Caption = 'About...'
        OnClick = MAboutClick
      end
      object MPreferences: TMenuItem
        Tag = 1
        Caption = 'Preferences...'
        OnClick = MPreferencesClick
      end
      object MQuickManager: TMenuItem
        Caption = 'Workspace manager...'
        OnClick = MQuickManagerClick
      end
      object MWorkspace: TMenuItem
        Caption = 'Workspace definition file'
        object MWorkspaceLoad: TMenuItem
          Caption = 'Load...'
          OnClick = MWorkspaceLoadClick
        end
        object MWorkspaceSave: TMenuItem
          Caption = 'Save...'
          OnClick = MWorkspaceSaveClick
        end
      end
      object MGUIStyle: TMenuItem
        AutoHotkeys = maManual
        Caption = 'Style'
        OnClick = MGUIStyleClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object MExit: TMenuItem
        Tag = 1
        Caption = 'Exit'
        OnClick = MExitClick
      end
    end
    object MOptions: TMenuItem
      Caption = 'Options'
      object MDontBackup: TMenuItem
        AutoCheck = True
        Caption = 'Don'#39't make backup files'
        Checked = True
        OnClick = MDontBackupClick
      end
      object MPreserveDateMod: TMenuItem
        AutoCheck = True
        Caption = 'Preserve Date modified of files'
        OnClick = MPreserveDateModClick
      end
      object MIgnoreErrors: TMenuItem
        AutoCheck = True
        Caption = 'Ignore minor errors in metadata'
        OnClick = MIgnoreErrorsClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MShowGPSdecimal: TMenuItem
        AutoCheck = True
        Caption = 'Show Exif:GPS in decimal notation'
        Checked = True
        OnClick = MShowNumbersClick
      end
      object MShowSorted: TMenuItem
        AutoCheck = True
        Caption = 'Show sorted tags (not in Workspace)'
        OnClick = MShowNumbersClick
      end
      object MShowComposite: TMenuItem
        AutoCheck = True
        Caption = 'Show Composite tags in view ALL'
        OnClick = MShowNumbersClick
      end
      object MNotDuplicated: TMenuItem
        AutoCheck = True
        Caption = 'Don'#39't show duplicated tags'
        OnClick = MShowNumbersClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object MShowNumbers: TMenuItem
        AutoCheck = True
        Caption = 'Show tag values as numbers'
        OnClick = MShowNumbersClick
      end
      object MShowHexID: TMenuItem
        AutoCheck = True
        Caption = 'Prefix tag names with ID number'
        OnClick = MShowNumbersClick
      end
      object MGroup_g4: TMenuItem
        AutoCheck = True
        Caption = 'Group tags by instance (-g4)'
        OnClick = MShowNumbersClick
      end
    end
    object MExportImport: TMenuItem
      Caption = 'Export/Import'
      object MExportMeta: TMenuItem
        Caption = 'Export metadata into'
        object MExportMetaTXT: TMenuItem
          Caption = 'TXT files'
          OnClick = MExportMetaTXTClick
        end
        object MExportMetaMIE: TMenuItem
          Caption = 'MIE files'
          OnClick = MExportMetaTXTClick
        end
        object MExportMetaXMP: TMenuItem
          Caption = 'XMP files'
          OnClick = MExportMetaTXTClick
        end
        object MExportMetaEXIF: TMenuItem
          Caption = 'EXIF files'
          OnClick = MExportMetaTXTClick
        end
        object MExportMetaHTM: TMenuItem
          Caption = 'HTML files'
          OnClick = MExportMetaTXTClick
        end
      end
      object MImportMetaSingle: TMenuItem
        Caption = 'Copy metadata from single file...'
        OnClick = MImportMetaSingleClick
      end
      object MImportMetaSelected: TMenuItem
        Caption = 'Copy metadata into JPG or TIF files...'
        OnClick = MImportMetaSelectedClick
      end
      object MImportRecursiveAll: TMenuItem
        Caption = 'Copy metadata into all JPG or TIF files...'
        OnClick = MImportRecursiveAllClick
      end
      object MImportGPS: TMenuItem
        Caption = 'Import GPS data from'
        object MImportGPSLog: TMenuItem
          Caption = 'Log files...'
          OnClick = MImportGPSLogClick
        end
        object MImportXMPLog: TMenuItem
          Caption = 'Xmp files...'
          OnClick = MImportXMPLogClick
        end
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object MExtractPreview: TMenuItem
        Caption = 'Extract preview image from selected'
        object MJPGfromCR2: TMenuItem
          Caption = 'CR2/DNG files'
          OnClick = MJPGfromCR2Click
        end
        object MJPGfromNEF: TMenuItem
          Caption = 'NEF/NRW files'
          OnClick = MJPGfromCR2Click
        end
        object MJPGfromRW2: TMenuItem
          Caption = 'RW2/PEF files'
          OnClick = MJPGfromCR2Click
        end
      end
      object MEmbedPreview: TMenuItem
        Caption = 'Embed preview image into selected'
        object MJPGtoCR2: TMenuItem
          Caption = 'CR2 files...'
          OnClick = MJPGtoCR2Click
        end
      end
    end
    object MModify: TMenuItem
      Caption = 'Modify'
      object MExifDateTimeshift: TMenuItem
        Caption = 'Exif: DateTime shift...'
        OnClick = MExifDateTimeshiftClick
      end
      object MExifDateTimeEqualize: TMenuItem
        Caption = 'Exif: DateTime equalize...'
        OnClick = MExifDateTimeEqualizeClick
      end
      object MExifLensFromMaker: TMenuItem
        Caption = 'Exif: LensInfo from Makernotes...'
        OnClick = MExifLensFromMakerClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object MRemoveMeta: TMenuItem
        Caption = 'Remove metadata...'
        OnClick = MRemoveMetaClick
      end
    end
    object MVarious: TMenuItem
      Caption = 'Various'
      object MFileDateFromExif: TMenuItem
        Caption = 'File: Date modified as in Exif...'
        OnClick = MFileDateFromExifClick
      end
      object MFileNameDateTime: TMenuItem
        Caption = 'File: Name=DateTime+Name...'
        OnClick = MFileNameDateTimeClick
      end
      object MJPGAutorotate: TMenuItem
        Caption = 'JPG: Lossless autorotate...'
        OnClick = MJPGAutorotateClick
      end
    end
  end
  object QuickPopUpMenu: TPopupMenu
    OnPopup = QuickPopUpMenuPopup
    Left = 736
    Top = 128
    object QuickPopUp_FillQuick: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FF1198
        FFFF1198FFFF1198FFFF1198FFFF1198FFFF1198FFFFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FF11EF
        FFFF11EFFFFF11EFFFFF11EFFFFF11EFFFFF1198FFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FF11EF
        FFFF11EFFFFF11EFFFFF11EFFFFF11EFFFFF1198FFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFC7C7C7FFC7C7
        C7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFF0FD44DFF007022FFFFFFFFFFFFFFFFFFFFFFFFFF828282FF1198
        FFFF1198FFFF1198FFFF1198FFFF1198FFFF1198FFFFC7C7C7FFC7C7C7FFFFFF
        FFFF0FD44DFF0FD44DFF0FD44DFF007022FFFFFFFFFFC7C7C7FF828282FF11EF
        FFFF11EFFFFF11EFFFFF11EFFFFF11EFFFFF1198FFFFC7C7C7FFFFFFFFFF0FD4
        4DFF0FD44DFF0FD44DFF0FD44DFF0FD44DFF007022FFFFFFFFFF828282FF11EF
        FFFF11EFFFFF11EFFFFF11EFFFFF11EFFFFF1198FFFFC7C7C7FF0FD44DFF0FD4
        4DFF0FD44DFF0FD44DFF0FD44DFF0FD44DFF0FD44DFF007022FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFF71FF9DFF0FD44DFF0FD44DFF007022FFFFFFFFFFFFFFFFFF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF71FF9DFF0FD44DFF0FD44DFF007022FF828282FF828282FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFC7C7C7FFC7C7
        C7FF71FF9DFF0FD44DFF0FD44DFF007022FFC7C7C7FFC7C7C7FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF71FF9DFF0FD44DFF0FD44DFF007022FF828282FF828282FFEDEDEDFFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFFEDED
        EDFF71FF9DFF0FD44DFF0FD44DFF007022FFEDEDEDFFEDEDEDFF}
      Caption = 'Fill in default values'
      OnClick = QuickPopUp_FillQuickClick
    end
    object QuickPopUp_UndoEdit: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000B5B5B5FFB5B5
        B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5
        B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF7DE57DFF00B0
        36FFC1E1B1FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFE0E0E0FFE0E0
        E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FF7DE5
        7DFF00B036FF007022FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0
        E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0
        E0FF7DE57DFF00B036FF007022FFE0E0E0FFE0E0E0FFE0E0E0FFF2F2F2FFF2F2
        F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2
        F2FFF2F2F2FF7DE57DFF00B036FF007022FFF2F2F2FFF2F2F2FF007022FF0070
        22FF007022FF007022FF007022FF007022FF007022FF007022FF007022FFF2F2
        F2FFF2F2F2FFC1E1B1FF00B036FF00B036FF00B036FFF2F2F2FF00B036FF00B0
        36FF00B036FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B036FF00B0
        36FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B036FF00B0
        36FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B036FF00B0
        36FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF7DE57DFF7DE57DFF00B036FF007022FFFFFFFFFF00B036FF00B0
        36FF00B036FF007022FF00B036FF00B036FF00B036FF007022FF00B036FFC1E1
        B1FFC1E1B1FF00B036FF00B036FF00B036FF00B036FFFFFFFFFF00B036FF00B0
        36FF007022FFC1E1B1FF7DE57DFF00B036FF00B036FF00B036FF00B036FF00B0
        36FF00B036FF00B036FF00B036FF00B036FFFFFFFFFFFFFFFFFF00B036FF0070
        22FFFFFFFFFFFFFFFFFFFFFFFFFF7DE57DFF7DE57DFF00B036FF00B036FF00B0
        36FF00B036FF00B036FF00B036FFFFFFFFFFFFFFFFFFFFFFFFFF007022FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC1E1B1FF7DE57DFF7DE57DFF00B0
        36FF00B036FFC1E1B1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Caption = 'Undo selected editing'
      OnClick = QuickPopUp_UndoEditClick
    end
    object QuickPopUp_AddQuick: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFF007A
        25FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00D640FF007A
        25FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFFFFFFFFF00D640FF00D640FF007A
        25FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00D640FF00D640FF00D640FF007A
        25FF007A25FF007A25FF007A25FFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF00D640FF00D640FF00D640FF00D640FF00D6
        40FF00D640FF00D640FF007A25FFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00D640FF00D640FF00D640FF00D6
        40FF00D640FF00D640FF00D640FFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFFFFFFFFF00D640FF00D640FF007A
        25FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00D640FF007A
        25FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFF00D6
        40FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF}
      Caption = 'Add tag to Workspace'
      OnClick = QuickPopUp_AddQuickClick
    end
    object QuickPopUp_DelQuick: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF002CF0FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFF002CF0FF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FFFFFFFFFFC7C7C7FFFFFFFFFF002C
        F0FF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FF002CF0FF002CF0FFC7C7C7FF002CF0FF002C
        F0FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FF002CF0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF002CF0FF002CF0FF002CF0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FFC7C7C7FF002CF0FF002C
        F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FF002CF0FF002CF0FFC7C7C7FFC7C7C7FFC7C7C7FF002C
        F0FF002CF0FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFF002CF0FF002CF0FFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF}
      Caption = 'Remove tag from Workspace'
      OnClick = QuickPopUp_DelQuickClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object QuickPopUp_AddCustom: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FF009C2FFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF009C2FFF009C2FFF009C
        2FFFFFFFFFFFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2BE365FF009C2FFF009C
        2FFF009C2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFF2BE365FF009C
        2FFF009C2FFF009C2FFFFFFFFFFFFFFFFFFFFFFFFFFF007022FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFF2BE3
        65FF009C2FFF009C2FFF009C2FFFFFFFFFFF009C2FFF007022FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FFFFFF
        FFFF2BE365FF009C2FFF009C2FFF009C2FFF009C2FFF007022FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFC7C7C7FFC7C7
        C7FFC7C7C7FF2BE365FF009C2FFF009C2FFF009C2FFF007022FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FFFFFFFFFF009C2FFF009C2FFF009C2FFF009C2FFF007022FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF009C2FFF009C2FFF009C2FFF009C2FFF009C2FFF007022FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2BE3
        65FF2BE365FF2BE365FF2BE365FF2BE365FF2BE365FF007022FF}
      Caption = 'Add tag to Custom view'
      OnClick = QuickPopUp_AddCustomClick
    end
    object QuickPopUp_DelCustom: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF002CF0FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFF002CF0FF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FFFFFFFFFFC7C7C7FFFFFFFFFF002C
        F0FF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FF002CF0FF002CF0FFC7C7C7FF002CF0FF002C
        F0FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FF002CF0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF002CF0FF002CF0FF002CF0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF002CF0FF002CF0FFC7C7C7FF002CF0FF002C
        F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FF002CF0FF002CF0FFC7C7C7FFC7C7C7FFC7C7C7FF002C
        F0FF002CF0FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFFFFF
        FFFFFFFFFFFF002CF0FF002CF0FFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFF002CF0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC7C7C7FFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF}
      Caption = 'Remove tag from Custom view'
      OnClick = QuickPopUp_DelCustomClick
    end
    object QuickPopUp_AddDetailsUser: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000828282FF0000
        00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
        00FF000000FF000000FF000000FF000000FF000000FF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FFEDED
        EDFFEDEDEDFFEDEDEDFFEDEDEDFFEDEDEDFF1198FFFF11EFFFFF11EFFFFF11EF
        FFFF11EFFFFF1198FFFFEDEDEDFFEDEDEDFFEDEDEDFF000000FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF000000FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF000000FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF000000FF828282FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FF000000FF828282FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF828282FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7
        C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FFC7C7C7FF828282FF828282FF8282
        82FF828282FF828282FF828282FF000000FFC7C7C7FF828282FF828282FF8282
        82FF828282FF828282FF828282FF828282FF828282FF828282FF}
      Caption = 'Add tag to Filelist Details'
      OnClick = QuickPopUp_AddDetailsUserClick
    end
    object QuickPopUp_MarkTag: TMenuItem
      Bitmap.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFCFCFCFFF000000FF000000FF000000FF000000FF000000FF0000
        00FF000000FF000000FFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF000000FF7D7D7DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF7D7D7DFF000000FFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
        00FF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFF000000FF7D7D7DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9E9E9EFF9E9E
        9EFFFFFFFFFF000000FFFFFFFFFF9E9E9EFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9E9E9EFF9E9E9EFFFFFF
        FFFF113DFFFF113DFFFF113DFFFFFFFFFFFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFFFFFFFFFF9E9E9EFF9E9E9EFF9E9E9EFFFFFFFFFF9E9E9EFF9E9E9EFFFFFF
        FFFF113DFFFF113DFFFF113DFFFFFFFFFFFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFFFFFFFFFF9E9E9EFF9E9E9EFF9E9E9EFFFFFFFFFF9E9E9EFF9E9E9EFFFFFF
        FFFF113DFFFF113DFFFF113DFFFFFFFFFFFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFFFFFFFFFF9E9E9EFF9E9E9EFF9E9E9EFFFFFFFFFF9E9E9EFF9E9E9EFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9E9E9EFF9E9E9EFF9E9E
        9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFF9E9E9EFFFFFFFFFFFFFFFFFF9E9E
        9EFF9E9E9EFFFFFFFFFF000000FFFFFFFFFF9E9E9EFF9E9E9EFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF7D7D7DFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF000000FF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFF
        FFFFCFCFCFFF000000FF7D7D7DFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF7D7D7DFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFCFCFCFFF000000FF000000FF000000FF000000FF000000FF0000
        00FF000000FF000000FFCFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      Caption = 'Mark/Unmark tag'
      OnClick = QuickPopUp_MarkTagClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object QuickPopUp_CopyTag: TMenuItem
      Caption = 'Copy Value to Clipboard'
      GroupIndex = 1
      ShortCut = 16451
      OnClick = QuickPopUp_CopyTagClick
    end
  end
  object OpenPictureDlg: TOpenPictureDialog
    Options = [ofHideReadOnly, ofNoValidate, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 184
    Top = 112
  end
  object OpenFileDlg: TOpenDialog
    Options = [ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 184
    Top = 168
  end
  object SaveFileDlg: TSaveDialog
    Options = [ofHideReadOnly, ofEnableSizing, ofDontAddToRecent]
    Left = 184
    Top = 216
  end
end
