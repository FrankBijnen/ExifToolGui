object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'FMain'
  ClientHeight = 581
  ClientWidth = 944
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 240
    Top = 25
    Width = 5
    Height = 537
    AutoSnap = False
    Color = clBtnFace
    MinSize = 160
    ParentColor = False
    ResizeStyle = rsLine
    OnCanResize = Splitter1CanResize
    OnMoved = Splitter1Moved
    ExplicitTop = 0
    ExplicitHeight = 563
  end
  object Splitter2: TSplitter
    Left = 619
    Top = 25
    Width = 5
    Height = 537
    Align = alRight
    AutoSnap = False
    MinSize = 320
    ResizeStyle = rsLine
    OnCanResize = Splitter2CanResize
    OnMoved = Splitter2Moved
    ExplicitLeft = 623
    ExplicitTop = -6
    ExplicitHeight = 563
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 562
    Width = 944
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
    ExplicitTop = 561
    ExplicitWidth = 940
  end
  object AdvPanelBrowse: TPanel
    Left = 0
    Top = 25
    Width = 240
    Height = 537
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
    ExplicitHeight = 536
    object Splitter3: TSplitter
      Left = 1
      Top = 311
      Width = 238
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      MinSize = 128
      ResizeStyle = rsLine
      ExplicitTop = 362
    end
    object AdvPageBrowse: TPageControl
      Left = 1
      Top = 1
      Width = 238
      Height = 310
      ActivePage = AdvTabBrowse
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 309
      object AdvTabBrowse: TTabSheet
        Caption = 'Browse'
        object ShellTree: TShellTreeView
          Left = 0
          Top = 0
          Width = 230
          Height = 282
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
          OnChanging = ShellTreeChanging
          ExplicitHeight = 281
        end
      end
    end
    object AdvPagePreview: TPageControl
      Left = 1
      Top = 315
      Width = 238
      Height = 221
      ActivePage = AdvTabPreview
      Align = alBottom
      TabOrder = 1
      OnResize = AdvPagePreviewResize
      ExplicitTop = 314
      object AdvTabPreview: TTabSheet
        Caption = 'Preview '
        object RotateImg: TImage
          Left = 0
          Top = 0
          Width = 230
          Height = 193
          Align = alClient
          ExplicitLeft = -1
          ExplicitTop = -1
        end
      end
    end
  end
  object AdvPageMetadata: TPageControl
    Left = 624
    Top = 25
    Width = 320
    Height = 537
    ActivePage = AdvTabMetadata
    Align = alRight
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    ExplicitLeft = 620
    ExplicitHeight = 536
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
        object EditFindMeta: TLabeledEdit
          Left = 124
          Top = 29
          Width = 136
          Height = 21
          Color = clWhite
          EditLabel.Width = 20
          EditLabel.Height = 21
          EditLabel.Caption = 'Find'
          LabelPosition = lpLeft
          TabOrder = 0
          Text = ''
          OnKeyPress = EditFindMetaKeyPress
        end
      end
      object AdvPanelMetaBottom: TPanel
        Left = 0
        Top = 403
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
        ExplicitTop = 402
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
          StyleElements = [seFont, seBorder]
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
          StyleElements = [seFont, seBorder]
          OnEnter = EditQuickEnter
          OnExit = EditQuickExit
          OnKeyDown = EditQuickKeyDown
        end
      end
      object MetadataList: TValueListEditor
        Left = 0
        Top = 57
        Width = 312
        Height = 346
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
        ParentShowHint = False
        PopupMenu = QuickPopUpMenu
        ShowHint = True
        TabOrder = 2
        TitleCaptions.Strings = (
          'Tag name'
          'Value')
        OnDblClick = MetadataListDblClick
        OnDrawCell = MetadataListDrawCell
        OnExit = MetadataListExit
        OnKeyDown = MetadataListKeyDown
        OnMouseDown = MetadataListMouseDown
        OnMouseMove = MetadataListMouseMove
        OnSelectCell = MetadataListSelectCell
        ExplicitHeight = 345
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
          OnKeyDown = EditMapFindKeyDown
        end
      end
      object AdvPanel_MapBottom: TPanel
        Left = 0
        Top = 477
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
          AlignWithMargins = True
          Left = 3
          Top = 5
          Width = 70
          Height = 22
          Margins.Top = 5
          Margins.Bottom = 5
          Align = alLeft
          Caption = 'Geotag files'
          OnClick = SpeedBtn_GeotagClick
        end
        object EditMapBounds: TLabeledEdit
          AlignWithMargins = True
          Left = 121
          Top = 6
          Width = 188
          Height = 23
          Hint = 'Coordinates of the visible area (South,West,North,East)'
          Margins.Left = 45
          Margins.Top = 6
          TabStop = False
          Align = alLeft
          EditLabel.Width = 39
          EditLabel.Height = 23
          EditLabel.Caption = 'Bounds:'
          LabelPosition = lpLeft
          MaxLength = 200
          ParentShowHint = False
          ReadOnly = True
          ShowHint = True
          TabOrder = 0
          Text = ''
          ExplicitHeight = 21
        end
      end
      object EdgeBrowser1: TEdgeBrowser
        Left = 0
        Top = 57
        Width = 312
        Height = 420
        Align = alClient
        TabOrder = 2
        UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
        OnCreateWebViewCompleted = EdgeBrowser1CreateWebViewCompleted
        OnNavigationStarting = EdgeBrowser1NavigationStarting
        OnWebMessageReceived = EdgeBrowser1WebMessageReceived
        OnZoomFactorChanged = EdgeBrowser1ZoomFactorChanged
      end
    end
  end
  object AdvPageFilelist: TPageControl
    Left = 245
    Top = 25
    Width = 374
    Height = 537
    ActivePage = AdvTabFilelist
    Align = alClient
    Constraints.MinWidth = 364
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 3
    ExplicitWidth = 370
    ExplicitHeight = 536
    object AdvTabFilelist: TTabSheet
      Caption = 'Filelist'
      object AdvPanelFileTop: TPanel
        Left = 0
        Top = 0
        Width = 366
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
        ExplicitWidth = 362
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
        Top = 325
        Width = 366
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
        ExplicitTop = 324
        ExplicitWidth = 362
        DesignSize = (
          366
          184)
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
          Left = 275
          Top = 79
          Width = 90
          Height = 21
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Edit predefined'
          OnClick = SpeedBtn_ETeditClick
        end
        object SpeedBtnShowLog: TSpeedButton
          Left = 275
          Top = 6
          Width = 90
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
          Left = 70
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Replace'
          Enabled = False
          OnClick = BtnETdirectReplaceClick
        end
        object SpeedBtnETdirectAdd: TSpeedButton
          Left = 138
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Add new'
          Enabled = False
          OnClick = BtnETdirectAddClick
        end
        object SpeedBtn_ETdSetDef: TSpeedButton
          Left = 206
          Top = 114
          Width = 63
          Height = 25
          Caption = '^ Default'
          OnClick = SpeedBtn_ETdSetDefClick
        end
        object SpeedBtn_ETclear: TSpeedButton
          Left = 275
          Top = 114
          Width = 58
          Height = 25
          Caption = 'Deselect'
          OnClick = SpeedBtn_ETclearClick
        end
        object CmbETDirectMode: TComboBox
          Left = 115
          Top = 6
          Width = 114
          Height = 21
          Hint = 'Choose how the command(s) must be executed '
          DropDownWidth = 200
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          TabStop = False
          Text = 'CmbETDirectMode'
          OnChange = CmbETDirectModeChange
          Items.Strings = (
            'StayOpen'
            'Classic')
        end
        object EditETdirect: TLabeledEdit
          Left = 1
          Top = 50
          Width = 293
          Height = 23
          Hint = 
            'Spaces in data require double quotes, double quotes in data requ' +
            'ires prefixing it with a \. Examples -Make="abde fghi"  -Make="A' +
            'bcde\"fghi"'
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
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Text = ''
          OnChange = EditETdirectChange
          OnKeyDown = EditETdirectKeyDown
          ExplicitWidth = 289
        end
        object CBoxETdirect: TComboBox
          Left = 1
          Top = 79
          Width = 271
          Height = 21
          Style = csDropDownList
          DropDownCount = 16
          TabOrder = 1
          OnChange = CBoxETdirectChange
        end
        object EditETcmdName: TLabeledEdit
          Left = 1
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
        Top = 79
        Width = 366
        Height = 246
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
        OnKeyPress = EditFindMetaKeyPress
        OnKeyUp = ShellListKeyUp
      end
      object PnlBreadCrumb: TPanel
        Left = 0
        Top = 57
        Width = 366
        Height = 22
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 3
        ExplicitWidth = 362
      end
    end
    object AdvTabChart: TTabSheet
      Caption = 'Chart'
      object AdvPanel1: TPanel
        Left = 0
        Top = 0
        Width = 366
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
        Width = 366
        Height = 372
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
  object ActionMainMenuBar: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 944
    Height = 25
    UseSystemFont = False
    ActionManager = MainActionManager
    Caption = 'ActionMainMenuBar'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
    ExplicitWidth = 940
  end
  object OpenPictureDlg: TOpenPictureDialog
    Options = [ofHideReadOnly, ofNoValidate, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 163
    Top = 117
  end
  object OpenFileDlg: TOpenDialog
    Options = [ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 163
    Top = 181
  end
  object SaveFileDlg: TSaveDialog
    Options = [ofHideReadOnly, ofEnableSizing, ofDontAddToRecent]
    Left = 163
    Top = 245
  end
  object MainActionManager: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Items = <
              item
                Action = MaAbout
                Caption = '&About...'
              end
              item
                Action = MaPreferences
                Caption = '&Preferences...'
              end
              item
                Action = MaQuickManager
                Caption = '&Workspace manager...'
              end
              item
                Items = <
                  item
                    Action = MaWorkspaceLoad
                    Caption = '&Load..'
                  end
                  item
                    Action = MaWorkspaceSave
                    Caption = '&Save...'
                  end>
                Caption = 'W&orkspace definition file'
                UsageCount = 1
              end
              item
                Action = MaGUIStyle
                Caption = '&Style...'
              end
              item
                Caption = '-'
              end
              item
                Action = MaExit
                Caption = '&Exit'
              end>
            Caption = '&Program'
          end
          item
            Items = <
              item
                Action = MaDontBackup
                Caption = '&Don'#39't make backup files'
              end
              item
                Action = MaPreserveDateMod
                Caption = '&Preserve Date modified of files'
              end
              item
                Action = MaIgnoreErrors
                Caption = '&Ignore minor errors in metadata'
              end
              item
                Caption = '-'
              end
              item
                Action = MaShowGPSdecimal
                Caption = '&Show Exif:GPS in decimal notation'
              end
              item
                Action = MaShowSorted
                Caption = 'S&how sorted tags (not in Workspace)'
              end
              item
                Action = MaShowComposite
                Caption = 'Sh&ow Composite tags in view ALL'
              end
              item
                Action = MaNotDuplicated
                Caption = 'Do&n'#39't show duplicated tags'
              end
              item
                Caption = '-'
              end
              item
                Action = MaShowNumbers
                Caption = 'Sho&w tag values as numbers'
              end
              item
                Action = MaShowHexID
                Caption = 'P&refix tag names with ID number'
              end
              item
                Action = MaGroup_g4
                Caption = '&Group tags by instance (-g4)'
              end
              item
                Caption = '-'
              end
              item
                Action = MaAPIWindowsWideFile
                Caption = '&API WindowsWideFile (Requires Exiftool V12.66)'
              end
              item
                Caption = '-'
              end
              item
                Action = MaCustomOptions
                Caption = '&Custom options'
              end>
            Tag = 1
            Caption = '&Options'
          end
          item
            Items = <
              item
                Items = <
                  item
                    Action = MaExportMetaTXT
                    Caption = '&TXT files'
                  end
                  item
                    Action = MaExportMetaMIE
                    Caption = '&MIE files'
                  end
                  item
                    Action = MaExportMetaXMP
                    Caption = '&XMP files'
                  end
                  item
                    Action = MaExportMetaEXIF
                    Caption = '&EXIF files'
                  end
                  item
                    Action = MaExportMetaHTML
                    Caption = '&HTML files'
                  end>
                Caption = '&Export metadata into'
                UsageCount = 1
              end
              item
                Action = MaImportMetaSingle
                Caption = '&Copy metadata from single file...'
              end
              item
                Action = MaImportMetaSelected
                Caption = 'C&opy metadata into JPG or TIF files...'
              end
              item
                Action = MaImportRecursiveAll
                Caption = 'Co&py metadata into all JPG or TIF files...'
              end
              item
                Items = <
                  item
                    Action = MaImportGPSLog
                    Caption = '&Log files...'
                  end
                  item
                    Action = MaImportXmpLog
                    Caption = '&Xmp files...'
                  end>
                Caption = '&Import GPS data from'
                UsageCount = 1
              end
              item
                Caption = '-'
              end
              item
                Action = MaGenericExtractPreviews
                Caption = '&Generic extract previews...'
              end
              item
                Action = MaGenericImportPreview
                Caption = 'Ge&neric import preview...'
              end>
            Caption = '&Export/Import'
          end
          item
            Items = <
              item
                Action = MaExifDateTimeshift
                Caption = '&Exif: DateTime shift...'
              end
              item
                Action = MaExifDateTimeEqualize
                Caption = 'E&xif: DateTime equalize...'
              end
              item
                Action = MaExifLensFromMaker
                Caption = 'Ex&if: LensInfo from Makernotes...'
              end
              item
                Caption = '-'
              end
              item
                Action = MaRemoveMeta
                Caption = '&Remove metadata...'
              end
              item
                Caption = '-'
              end
              item
                Action = MaUpdateLocationfromGPScoordinates
                Caption = '&Update City, Province, Country from GPS coordinates...'
              end>
            Caption = '&Modify'
          end
          item
            Items = <
              item
                Action = MaFileDateFromExif
                Caption = '&File: Date modified as in Exif...'
              end
              item
                Action = MaFileNameDateTime
                Caption = 'F&ile: Name=DateTime+Name...'
              end
              item
                Action = MaJPGGenericlosslessautorotate
                Caption = '&JPG:  Lossless rotate + crop...'
              end>
            Caption = '&Various'
          end
          item
            Items = <
              item
                Action = MaOnlineDocumentation
                Caption = '&Online Documentation'
              end>
            Caption = '&Help'
          end>
        ActionBar = ActionMainMenuBar
      end>
    Left = 163
    Top = 53
    StyleName = 'Platform Default'
    object MaExportMetaTXT: TAction
      Tag = 20
      Category = 'Export_Metadata'
      Caption = 'TXT files'
      OnExecute = MExportMetaTXTClick
    end
    object MaExportMetaMIE: TAction
      Tag = 20
      Category = 'Export_Metadata'
      Caption = 'MIE files'
      OnExecute = MExportMetaTXTClick
    end
    object MaAbout: TAction
      Tag = 99
      Category = 'Program'
      Caption = 'About...'
      OnExecute = MAboutClick
    end
    object MaPreferences: TAction
      Tag = 99
      Category = 'Program'
      Caption = 'Preferences...'
      OnExecute = MPreferencesClick
    end
    object MaQuickManager: TAction
      Category = 'Program'
      Caption = 'Workspace manager...'
      OnExecute = MQuickManagerClick
    end
    object MaGUIStyle: TAction
      Category = 'Program'
      Caption = 'Style...'
      OnExecute = MGUIStyleClick
    end
    object MaExit: TAction
      Tag = 99
      Category = 'Program'
      Caption = 'Exit'
      OnExecute = MExitClick
    end
    object MaWorkspaceLoad: TAction
      Category = 'Program_Workspace'
      Caption = 'Load..'
      OnExecute = MWorkspaceLoadClick
    end
    object MaWorkspaceSave: TAction
      Category = 'Program_Workspace'
      Caption = 'Save...'
      OnExecute = MWorkspaceSaveClick
    end
    object MaDontBackup: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Don'#39't make backup files'
      Checked = True
      OnExecute = MDontBackupClick
    end
    object MaPreserveDateMod: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Preserve Date modified of files'
      OnExecute = MPreserveDateModClick
    end
    object MaIgnoreErrors: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Ignore minor errors in metadata'
      OnExecute = MIgnoreErrorsClick
    end
    object MaShowGPSdecimal: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Show Exif:GPS in decimal notation'
      Checked = True
      OnExecute = MShowNumbersClick
    end
    object MaShowSorted: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Show sorted tags (not in Workspace)'
      OnExecute = MShowNumbersClick
    end
    object MaShowComposite: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Show Composite tags in view ALL'
      OnExecute = MShowNumbersClick
    end
    object MaNotDuplicated: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Don'#39't show duplicated tags'
      OnExecute = MShowNumbersClick
    end
    object MaShowNumbers: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Show tag values as numbers'
      OnExecute = MShowNumbersClick
    end
    object MaShowHexID: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Prefix tag names with ID number'
      OnExecute = MShowNumbersClick
    end
    object MaGroup_g4: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'Group tags by instance (-g4)'
      OnExecute = MShowNumbersClick
    end
    object MaAPIWindowsWideFile: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'API WindowsWideFile (Requires Exiftool V12.66)'
      Checked = True
      OnExecute = MAPIWindowsWideFileClick
    end
    object MaCustomOptions: TAction
      Tag = 10
      Category = 'Options'
      Caption = 'Custom options'
      OnExecute = MCustomOptionsClick
    end
    object MaExportMetaXMP: TAction
      Tag = 20
      Category = 'Export_Metadata'
      Caption = 'XMP files'
      OnExecute = MExportMetaTXTClick
    end
    object MaExportMetaEXIF: TAction
      Tag = 20
      Category = 'Export_Metadata'
      Caption = 'EXIF files'
      OnExecute = MExportMetaTXTClick
    end
    object MaExportMetaHTML: TAction
      Tag = 20
      Category = 'Export_Metadata'
      Caption = 'HTML files'
      OnExecute = MExportMetaTXTClick
    end
    object MaImportMetaSingle: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Copy metadata from single file...'
      OnExecute = MImportMetaSingleClick
    end
    object MaImportMetaSelected: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Copy metadata into JPG or TIF files...'
      OnExecute = MImportMetaSelectedClick
    end
    object MaImportRecursiveAll: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Copy metadata into all JPG or TIF files...'
      OnExecute = MImportRecursiveAllClick
    end
    object MaImportGPS: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Import GPS data from'
    end
    object MaImportGPSLog: TAction
      Tag = 20
      Category = 'Import_GPS'
      Caption = 'Log files...'
      OnExecute = MImportGPSLogClick
    end
    object MaImportXmpLog: TAction
      Tag = 20
      Category = 'Import_GPS'
      Caption = 'Xmp files...'
      OnExecute = MImportXMPLogClick
    end
    object MaGenericExtractPreviews: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Generic extract previews...'
      OnExecute = GenericExtractPreviewsClick
    end
    object MaGenericImportPreview: TAction
      Tag = 20
      Category = 'Export_Import'
      Caption = 'Generic import preview...'
      OnExecute = GenericImportPreviewClick
    end
    object MaExifDateTimeshift: TAction
      Tag = 30
      Category = 'Modify'
      Caption = 'Exif: DateTime shift...'
      OnExecute = MExifDateTimeshiftClick
    end
    object MaExifDateTimeEqualize: TAction
      Tag = 30
      Category = 'Modify'
      Caption = 'Exif: DateTime equalize...'
      OnExecute = MExifDateTimeEqualizeClick
    end
    object MaExifLensFromMaker: TAction
      Tag = 30
      Category = 'Modify'
      Caption = 'Exif: LensInfo from Makernotes...'
      OnExecute = MExifLensFromMakerClick
    end
    object MaRemoveMeta: TAction
      Tag = 30
      Category = 'Modify'
      Caption = 'Remove metadata...'
      OnExecute = MRemoveMetaClick
    end
    object MaUpdateLocationfromGPScoordinates: TAction
      Tag = 30
      Category = 'Modify'
      Caption = 'Update City, Province, Country from GPS coordinates...'
      OnExecute = UpdateLocationfromGPScoordinatesClick
    end
    object MaFileDateFromExif: TAction
      Tag = 40
      Category = 'Various'
      Caption = 'File: Date modified as in Exif...'
      OnExecute = MFileDateFromExifClick
    end
    object MaFileNameDateTime: TAction
      Tag = 40
      Category = 'Various'
      Caption = 'File: Name=DateTime+Name...'
      OnExecute = MFileNameDateTimeClick
    end
    object MaJPGGenericlosslessautorotate: TAction
      Tag = 40
      Category = 'Various'
      Caption = 'JPG:  Lossless rotate + crop...'
      OnExecute = JPGGenericlosslessautorotate1Click
    end
    object MaOnlineDocumentation: TAction
      Tag = 50
      Category = 'Help'
      Caption = 'Online Documentation'
      OnExecute = OnlineDocumentation1Click
    end
  end
  object QuickPopUpMenu: TPopupMenu
    Images = VirtualImageListMetadata
    OnPopup = QuickPopUpMenuPopup
    Left = 702
    Top = 159
    object QuickPopUp_FillQuickAct: TMenuItem
      Caption = 'Fill in default values'
      ImageIndex = 0
      ImageName = 'QuickPopUp_FillQuick'
      OnClick = QuickPopUp_FillQuickClick
    end
    object QuickPopUp_UndoEditAct: TMenuItem
      Caption = 'Undo selected editing'
      ImageIndex = 1
      ImageName = 'QuickPopUp_UndoEdit'
      OnClick = QuickPopUp_UndoEditClick
    end
    object QuickPopUp_AddQuickAct: TMenuItem
      Caption = 'Add tag to Workspace'
      ImageIndex = 2
      ImageName = 'QuickPopUp_AddQuick'
      OnClick = QuickPopUp_AddQuickClick
    end
    object QuickPopUp_DelQuickAct: TMenuItem
      Caption = 'Remove tag from Workspace'
      ImageIndex = 3
      ImageName = 'QuickPopUp_DelQuick'
      OnClick = QuickPopUp_DelQuickClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object QuickPopUp_AddCustomAct: TMenuItem
      Caption = 'Add tag to Custom view'
      ImageIndex = 4
      ImageName = 'QuickPopUp_AddCustom'
      OnClick = QuickPopUp_AddCustomClick
    end
    object QuickPopUp_DelCustomAct: TMenuItem
      Caption = 'Remove tag from Custom view'
      ImageIndex = 5
      ImageName = 'QuickPopUp_DelCustom'
      OnClick = QuickPopUp_DelCustomClick
    end
    object QuickPopUp_AddDetailsUserAct: TMenuItem
      Caption = 'Add tag to Filelist Details'
      ImageIndex = 6
      ImageName = 'QuickPopUp_AddDetailsUser'
      OnClick = QuickPopUp_AddDetailsUserClick
    end
    object QuickPopUp_MarkTagAct: TMenuItem
      Caption = 'Mark/Unmark tag'
      ImageIndex = 7
      ImageName = 'QuickPopUp_MarkTag'
      OnClick = QuickPopUp_MarkTagClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object QuickPopUp_CopyTagAct: TMenuItem
      Caption = 'Copy Value to Clipboard'
      ImageIndex = 8
      ImageName = 'QuickPopUp_CopyTag'
      ShortCut = 16451
      OnClick = QuickPopUp_CopyTagClick
    end
  end
  object ImageCollectionMetadata: TImageCollection
    Images = <
      item
        Name = 'QuickPopUp_AddCustom'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              000000000000000000000000000000000000000000008C8C8C00C6C6C600F7F7
              F700F7F7F700EFEFEF00E7E7E700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00E7E7E700E7E7E700CECECE00C6C6C600DEDEDE00F7F7F700FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00D6D6D600EFEF
              EF00ADADAD00636363004A4A4A00525252005A5A5A005A5A5A005A5A5A005252
              52004A4A4A005A5A5A008C8C8C00C6C6C600EFEFEF00F7F7F700FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00DEDEDE00E7E7
              E7008C8C8C002121210008080800101010001818180018181800181818001010
              1000080808002121210073737300C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00D6D6D600F7F7
              F700C6C6C6007B7B7B0063636300737373007373730073737300737373007373
              73006B6B6B00737373009C9C9C00C6C6C600EFEFEF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00C6C6C600EFEF
              EF00F7F7F700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7
              E700E7E7E700E7E7E700D6D6D600C6C6C600DEDEDE00F7F7F700F7F7F700F7F7
              F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F70084848400ADADAD00D6D6
              D600EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00F7F7F700EFEFEF00D6D6D600C6C6C600CECECE00D6D6D600DEDEDE00DEDE
              DE00D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D60084848400A5A5A500C6C6
              C600CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400B5B5B500DEDE
              DE00EFEFEF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700FFFFFF00F7F7F700DEDEDE00C6C6C600CECECE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE008C8C8C00C6C6C600F7F7
              F700EFEFEF00DEDEDE00D6D6D600DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00CECECE00C6C6C600DEDEDE00F7F7F700FFFFFF00F7F7
              F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F7008C8C8C00D6D6D600F7F7
              F700B5B5B5006363630052525200636363006363630063636300636363006363
              630052525200636363008C949400C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00DEDEDE00E7E7
              E7008C8C8C002121210000000000181818001818180018181800181818001010
              1000080808002121210073737300C6C6C600E7F7E700E7F7E700EFFFF700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00D6D6D600F7F7
              F700C6C6C60073737300636363006B6B6B007373730073737300737373006B6B
              6B006363630073737300B5A5AD00CEC6CE00A5CEAD008CD69C00CEEFD600F7FF
              F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008C8C8C00C6C6C600EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFDEE700ADBDB500399C520010A539006BC68400E7F7
              EF00FFFFFF00FFFFFF00FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F70084848400ADADAD00D6D6
              D600EFEFEF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700F7F7F700EFEFEF00A5CEAD004AA56300008C21000094180018A5390073C6
              8C00DEF7E700FFFFFF00F7F7F700DED6DE00D6D6D600D6D6D600D6D6D600D6D6
              D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D60084848400A5A5A500C6C6
              C600D6D6D600CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00D6CE
              D600E7CEDE00C6C6C6005AB57300109C31000094210000942100008C180018A5
              390084D69C00E7F7E700EFE7EF00D6CECE00C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600CECECE00CECECE00CECECE0084848400B5B5B500DEDE
              DE00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00F7EFF700D6DED60052CE7B0000B5310000A5180000942100008410000094
              210021AD4A007BCE9400CEE7D600EFE7EF00EFE7EF00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00E7E7E700EFE7EF00EFEFEF008C8C8C00C6C6C600F7F7
              F700F7F7F700DEDEDE00D6D6D600DEDEDE00DEDEDE00DEDEDE00D6D6D600DEDE
              DE00F7EFF700EFF7EF0094F7B50039E76B0010BD3900009C2900009421000094
              2900008C180021A5390084CE9400DEEFE700FFFFFF00F7F7F700F7F7F700F7F7
              F700F7F7F700F7F7F700F7F7F700DEEFE700DEEFE7008C8C8C00D6D6D600EFEF
              EF00B5B5B500636363005252520063636300636363005A5A5A00525252006B6B
              6B00BDB5BD00F7F7F700E7FFEF009CF7BD0042DE730008BD390000A521000094
              2100008410000094210021AD4A0084D69C00DEF7E700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00CEE7D60084BD94006BB584008C8C8C00DEDEDE00E7E7
              E7008C8C8C002121210008080800080808000808080008080800080808002121
              21008C8C8C00F7F7F700FFFFFF00E7FFEF0094F7B50039E76B0008BD3900009C
              29000094290000942900008C180021A539007BCE9400E7F7EF00FFFFFF00FFFF
              FF00FFFFFF00DEEFDE0073B5840018732100086308008C8C8C00D6D6D600F7F7
              F700CECECE0084848400737373007B7B7B007B7B7B007B7B7B00737373008484
              8400C6CEC600F7F7F700F7F7F700F7EFF700E7F7EF00A5FFC6004AEF7B0008BD
              3900009C210000942100008410000094180018A542007BCE9400EFF7EF00FFFF
              FF00DEEFE70073C68C00188C3900005A08000052000084848400BDBDBD00EFEF
              EF00F7F7F700F7F7F700EFEFEF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700F7F7F700EFEFEF00D6D6D600CEC6C600E7DEE700E7F7E7009CF7BD0031E7
              6B0008BD3900009C31000094290000942900008C180018A539009CDEAD00DEEF
              E70084D69C00189C3100007B1000006B2100006B2100848484009C9C9C00B5B5
              B500C6C6C600CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00C6C6C600B5B5B5009C9C9C009C9C9C00B5A5AD00C6BDC600CEE7D6009CF7
              BD004AEF7B0008C6420000A5290000942100008410000094210042B563006BC6
              840031B55A00008C2100007B1000006B2100006B210084848400848484008C8C
              8C008C8C8C008C8C8C008C8C8C008C8C8C008C8C8C008C8C8C008C8C8C008C8C
              8C008C8C8C008C8C8C0084848400847B84007B7B7B0094949400DEC6D600E7F7
              EF009CF7BD0031D6630010BD390008A5310000942900009C2900109C3100189C
              3100089C31000094290000842100006B2100006B210084848400949494009C9C
              9C00A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
              A500A5A5A5009C9C9C00848484007B7B7B0084848400A5A5A500E7CEDE00EFE7
              EF00CEE7D60073D6940039D66B0018C64A0000B53900009C2900008C21000094
              1800009C21000094290000842900006B2100006B210084848400A5A5A500BDBD
              BD00C6C6C600BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
              BD00C6C6C600BDBDBD0094949400848484009C9C9C00BDBDBD00C6C6C600C6C6
              C600DEC6D600C6CEC6007BDE940029DE630000BD3900009C290000942900009C
              2900009C31000094290000842900006B2100006B210073737300848484009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C00949494007B7B7B007373730084848400949494008C8C8C009494
              9400EFC6E700EFE7EF009CE7B50021C6520000AD2900009C290000942900009C
              3100009C31000094290000842900006B2100006B210084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484007B7B7B00948C
              9400DECED600DEEFDE0073CE9400189C3100008C180000942900009C2900009C
              2900009C31000094290000842900006B2100006B2100C6C6C600BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00C6C6C600C6C6C600BDBDBD00BDBDBD00CEBDC600CEBD
              C600B5CEBD006BC6840029A54A00008C2100008C180000942900009429000094
              2900009429000094290000842100006B2100006B2100EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00F7F7F700FFF7FF00DEEF
              E70073C68C0010A5390000942100009C3100089C3100089C3100089C3100089C
              310008A53100009C310000842900006B2100006B2100FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFF700DEFFE70094F7
              B50031D6630008BD390000B5310010BD4A0018C64A0018C64A0018C64A0018C6
              4A0018C64A0010BD4A0008943100006B2100006B2100FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E7F7EF0094F7B50029E7
              630010DE520029DE630029DE630029DE630029DE630029DE630029DE630029E7
              630031EF6B0029DE630010A542000073210000631800FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DEF7E70084EFA50010DE
              520008E74A0031E76B0031E76B0031E76B0031E76B0031E76B0031E76B0031EF
              6B0031F7730029DE630018A542000073210000631800}
          end>
      end
      item
        Name = 'QuickPopUp_AddDetailsUser'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              0000000000000000000000000000000000000000000084848400424242000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000848484007B7B7B007373
              7300737373007373730073737300737373007373730073737300847B73007373
              7300395A7B00084A7B00005A840008737B00087B7B0008737B0008737B000873
              7B00087B7B0008737B00005A8400084A7B00395A7B0073737300847B73007373
              7300848484007373730039393900000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF008CCEFF0010ADFF0000CEFF0010FFFF0010FFFF0010FFFF0010FFFF0010FF
              FF0010FFFF0010FFFF0000CEFF0010ADFF008CCEFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF0084848400000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF0073737300000000000000000084848400BDBDBD00F7F7
              F700FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7F700FFFFF700F7F7
              F7007BBDFF00009CFF0000BDFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
              FF0000FFFF0000FFFF0000BDFF00009CFF007BBDFF00F7F7F700FFFFF700F7F7
              F700FFFFFF00F7F7F7007B7B7B00000000000000000084848400B5B5B500EFEF
              EF00F7F7F700EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFF7EF00EFEF
              EF007BB5F700109CFF0000BDFF0010EFFF0010FFFF0010EFFF0010EFFF0010EF
              FF0010FFFF0010EFFF0000BDFF00109CFF007BB5F700EFEFEF00FFF7EF00EFEF
              EF00FFFFFF00EFEFEF007373730000000000000000008484840094949400ADAD
              AD00B5B5B500ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00BDB5AD00ADAD
              AD007394B5004284B5003194BD0042ADB50042B5B50042ADB50042ADB50042AD
              B50042B5B50042ADB5003194BD004284B5007394B500ADADAD00BDB5AD00ADAD
              AD00C6C6C600ADADAD005A5A5A00000000000000000084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84009494940084848400424242000000000000000000848484008C8C8C009494
              94009C9C9C009494940094949400949494009494940094949400949494009494
              9400A59C9400B5A59400B59C9400B5949400B5949400B5949400B5949400B594
              9400B5949400B5949400B59C9400B5A59400A59C940094949400949494009494
              9400ADADAD00949494004A4A4A00000000000000000084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600DEDEDE00C6C6C60063636300000000000000000084848400A5A5A500CECE
              CE00D6D6D600CECECE00CECECE00CECECE00CECECE00CECECE00DEDEDE00E7E7
              E700E7E7E700D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600F7F7F700D6D6D60063636300000000000000000084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600DEDEDE00C6C6C60063636300000000000000000084848400A5A5A500BDBD
              BD00C6C6C600BDBDBD00BDBDBD00BDBDBD00CECECE00BDBDBD008C8C8C006363
              6300737373009C9C9C00A5A5A5009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C006B6B6B00424242003131310084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600DEDEDE00C6C6C600525252000000
              0000292929008484840094949400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400BDBDBD00EFEF
              EF00FFFFFF00EFEFEF00EFEFEF00EFEFEF00FFFFFF00EFEFEF00525252000000
              0000212121009C9C9C00B5B5B500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
              A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5A500A5A5
              A500A5A5A500A5A5A5009C9C9C00949494008C8C8C0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00636363000000
              000042424200C6C6C600DEDEDE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600CECECE00C6C6C600A5A5A500848484007B7B7B0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600DEDEDE00C6C6C6004A4A4A000000
              000052525200CECECE00D6D6D600ADADAD00A5A5A500ADADAD00ADADAD00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00B5B5B500ADADAD0094949400848484007B7B7B0084848400848484008484
              8400848484008484840084848400848484009494940084848400292929000000
              00005A5A5A00C6C6C600BDBDBD00848484007B7B7B0084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484007B7B7B007373
              7300737373007373730073737300737373008484840073737300212121000000
              00005A5A5A00C6C6C600B5B5B5007B7B7B006B6B6B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B008484840084848400}
          end>
      end
      item
        Name = 'QuickPopUp_AddQuick'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              0000000000000000000000000000000000000000000084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00E7E7E700DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00CECECE00C6C6C600CECECE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700FFFFFF00F7F7F700DEDEDE00C6C6C600C6C6C600DEDEDE00EFE7EF00FFEF
              F700EFE7EF00DEDEDE00D6D6D600DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C6006363630052525200636363006363630063636300636363006363
              63005A5A5A0063636300848C8400BDBDBD00FFF7FF00FFFFFF00D6EFDE0084C6
              9C00B5DEBD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000000000000000005A5A5A00C6C6C600FFFFFF00FFFFFF0063B57B00007B
              21005AAD7300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C6006363630052525200636363006363630063636300636363006363
              63005252520063636300C6A5B500FFE7F700EFFFF7007BEF9C0000942900006B
              08005AA57300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007BF7A50000D6420000940000007B
              21007BB58C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700FFFFFF00FFFFFF00FFFFFF0084F7A50018E7520000D62900008C0000007B
              210094BD9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700DEDEDE00D6D6D600DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600BDBDBD00C6C6
              C600FFE7F700FFFFFF0084F7A50000D6420000DE290000D6420000941000007B
              21007BB58C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700C6C6C600BDBDBD00C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00E7E7E700DEDEDE00DEDEDE00DEDEDE00D6D6D600DEDEDE00FFDEF700FFDE
              F700D6EFDE007BEF9C0018DE520000D6290000DE290000D64200009C2100006B
              2100398452007BB58C008CB59C007BB58C006BAD84007BBD9400C6E7CE00FFFF
              FF00FFF7FF00DEDEDE00D6D6D600DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007BEF9C0000D6420000D6290000D6420000DE420000D6420000AD3100007B
              2100006B2100007B2100007B2100007B2100006B0800007B21007BBD9400FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6FFD60063EF
              8C0008DE4A0000D6290000D6290000D6420000DE420000D6420000C6390000AD
              3100009C210000941000009C10000094100000630000005A00006BA57B00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007BEF9C0000D6
              420000D6290000D6420000D6420000D6420000D6420000D6420000D6420000D6
              420000D6420000D6420000DE420000D6420000941000007B21007BB58C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6FFD60063EF
              8C0008DE4A0000D6290000D6290000D6420000D6420000D6420000E7420000EF
              420000E7390000DE290000DE290000DE290000B5000000A518006BCE8C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007BEF9C0000D6420000D6290000D6420000D6420000D6420000D6420000D6
              420000D6420000D6420000D6420000D6420000D6290000D642007BEF9C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00E7E7E700DEDEDE00DEDEDE00DEDEDE00D6D6D600DEDEDE00FFDEF700FFDE
              F700D6EFDE007BEF9C0018DE520000D6290000D6290000D6420000B5290000AD
              310039C663007BEF9C008CF7AD007BEF9C006BEF94007BF7A500C6FFD600FFFF
              FF00FFEFF700DEDEDE00D6D6D600DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600BDBDBD00C6C6
              C600FFE7F700FFFFFF0084F7A50000D6420000DE290000D6420000941000007B
              21007BB58C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700C6C6C600BDBDBD00C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700F7F7F700F7F7F700F7F7F700F7F7
              F700FFFFFF00FFFFFF00FFFFFF0084F7A50018E7520000D62900008400000063
              180094A59C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700DEDEDE00D6D6D600DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007BF7A50000D6420000940000007B
              21007BB58C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C6006363630052525200636363006363630063636300636363006363
              63005252520063636300C6A5B500FFE7F700EFFFF7007BEF9C0000BD310000A5
              18005AC67B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000000000000000005A5A5A00C6C6C600FFFFFF00FFFFFF0063EF8C0000D6
              42005AE78400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF00CECECE006B6B6B005A5A5A006B6B6B006B6B6B006B6B6B006B6B6B006B6B
              6B00636363006B6B6B008C949400C6C6C600FFF7FF00FFFFFF00DEFFEF008CFF
              B500BDFFD600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840094949400B5B5
              B500CECECE00D6D6D600DEDEDE00D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600DEDEDE00D6D6D600BDBDBD00A5A5A500A5A5A500B5B5B500CEBDC600D6BD
              CE00CEBDC600B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B50084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484008C8C8C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C00848484007B7B7B00848484009C9C9C00A5A5A5009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600CECECE00C6C6C6009C9C9C00848484009C9C9C00C6C6C600CECECE00C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484840094949400ADAD
              AD00B5B5B500ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00B5B5B500ADADAD00949494008484840094949400ADADAD00B5B5B500ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD0084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B00848484007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B00}
          end>
      end
      item
        Name = 'QuickPopUp_CopyTag'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00ADADAD00ADADAD007B7B7B007373730073737300737373007373
              7300737373007373730073737300737373007373730073737300737373007373
              73007373730073737300737373007B7B7B00ADADAD00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00ADADAD00ADADAD007B7B7B007373730073737300737373007373
              7300737373007373730073737300737373007373730073737300737373007373
              73007373730073737300737373007B7B7B00ADADAD00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B009C9C9C00BDBDBD00BDBDBD00BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00BDBDBD009C9C9C007B7B7B00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007373730073737300BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD0073737300FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00BDBDBD0073737300FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00BDBDBD0073737300FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00FFFFFF00FFFFFF00BDBDBD0073737300FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007373730073737300BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD0073737300CECECE00CECECE00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00D6D6
              D600FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00BDBDBD0073737300CECECE00CECECE00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00D6D6
              D600FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00BDBDBD0073737300ADADAD00ADADAD00BDBD
              BD00CECECE00D6D6D600D6D6D600D6D6D600CECECE00D6D6D600D6D6D600E7E7
              E700FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00FFFFFF00FFFFFF00BDBDBD0073737300ADADAD00ADADAD00CECE
              CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7
              EF00FFFFFF007373730073737300BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD0073737300ADADAD00ADADAD00D6D6
              D600FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00EFDE
              C600FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD0073737300ADADAD00ADADAD00D6D6
              D600FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00EFDE
              C600FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00B57B3900B57B3900B57B
              3900B57B3900FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD0073737300ADADAD00ADADAD00D6D6
              D600FFFFFF00EFD6B500EFD6B500EFD6B500EFD6B500EFD6B500EFD6B500F7E7
              DE00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00FFFFFF00FFFFFF00F7F7F700C6C6C600BDBDBD00BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00BDBDBD009C9C9C0073737300ADADAD00ADADAD00D6D6
              D600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFF7
              EF00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6007B7B7B0073737300737373007B7B
              7B007B7B7B0073737300737373007B7B7B008C8C8C00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00EFDE
              C600FFFFFF007373730073737300BDBDBD00FFFFFF00B5733900B5733900B573
              3900B57B3900FFFFFF00FFFFFF00BDBDBD007B7B7B00FFFFFF00FFFFFF00FFFF
              FF00EFEFEF008C8C8C008C8C8C007B7B7B00DEDEDE00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00DEA56B00EFDE
              C600FFFFFF007373730073737300BDBDBD00FFFFFF00B5733900B5733900B573
              3900B57B3900FFFFFF00FFFFFF00BDBDBD007B7B7B00FFFFFF00FFFFFF00FFFF
              FF00EFEFEF008C8C8C008C8C8C007B7B7B00DEDEDE00ADADAD00ADADAD00D6D6
              D600FFFFFF00EFD6B500EFD6B500EFD6B500EFD6B500EFD6B500EFD6B500F7E7
              DE00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00D6BD9C00D6BD9C00D6BD
              9C00D6BD9C00FFFFFF00FFFFFF00BDBDBD007B7B7B00FFFFFF00FFFFFF00E7E7
              E7008C8C8C008484840084848400DEDEDE00FFFFFF00ADADAD00ADADAD00D6D6
              D600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B00BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD007B7B7B00E7E7E700E7E7E7008484
              840084848400E7E7E700E7E7E700FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007373730073737300BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD007B7B7B0084848400848484008484
              8400E7E7E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007373730073737300BDBDBD00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00BDBDBD007B7B7B0084848400848484008484
              8400E7E7E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00D6D6
              D600FFFFFF00EFD6B500EFD6B500EFD6B500EFD6B500FFFFFF00FFFFFF00FFFF
              FF00FFFFFF007B7B7B007B7B7B009C9C9C00BDBDBD00BDBDBD00BDBDBD00BDBD
              BD00BDBDBD00BDBDBD00BDBDBD009C9C9C007B7B7B008C8C8C008C8C8C00EFEF
              EF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00D6D6
              D600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7
              F700FFFFFF00ADADAD00ADADAD007B7B7B00737373007B7B7B007B7B7B007B7B
              7B007B7B7B0073737300737373007B7B7B009C9C9C00EFEFEF00EFEFEF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00FFFFFF00FFFFFF00E7E7
              E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00DEA56B00DEA56B00DEA56B00DEA56B00FFFFFF00FFFFFF00E7E7
              E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00D6D6
              D600FFFFFF00EFD6B500EFD6B500EFD6B500EFD6B500FFFFFF00FFFFFF00D6D6
              D600BDBDBD00F7F7F700F7F7F700EFEFEF00D6D6D600D6D6D600D6D6D600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00D6D6
              D600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6D6
              D600ADADAD00EFEFEF00EFEFEF00ADADAD00ADADAD00EFEFEF00EFEFEF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECE
              CE00ADADAD00ADADAD00ADADAD00B5B5B500EFEFEF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00CECE
              CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECE
              CE00ADADAD00ADADAD00ADADAD00B5B5B500EFEFEF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD00ADADAD00BDBD
              BD00CECECE00D6D6D600D6D6D600D6D6D600CECECE00D6D6D600D6D6D600BDBD
              BD00ADADAD00B5B5B500B5B5B500F7F7F700FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECECE00CECECE00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00BDBDBD00F7F7F700F7F7F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
          end>
      end
      item
        Name = 'QuickPopUp_DelCustom'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              0000000000000000000000000000000000000000000084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00E7E7E700DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00CECECE00C6C6C600CECECE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700FFFFEF00FFF7DE00FFFFEF00F7F7
              F700FFFFFF00F7F7F700DEDEDE00C6C6C600C6C6C600DEDEDE00DEDEDE00DEDE
              DE00E7E7DE00FFF7DE00FFFFDE00FFF7DE00E7E7DE00DEDEDE00D6D6D600DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C600636363004A4A3900636363007384C600849CFF008C9CC6008484
              6B006B634A00636363008C8C8C00C6C6C600EFEFF700FFFFFF00FFFFFF00FFFF
              FF00DEE7FF00849CFF004A6BFF006384FF00ADBDFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C00000000000000000000000000001894000029F700001894000000
              000000000000000000005A5A5A00C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF007B94F7000029F7000000EF000029F7007B94F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C60063636300635A4200636363001031C6000000EF000000B5000000
              5A00292939007B7B6300ADA58C00C6C6C600FFFFEF00FFFFFF00F7F7FF007B94
              F7000029F7000000EF000018F7006384FF00CED6FF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007B94F7000029F7000000EF000029
              F700849CFF00FFFFFF00FFF7DE00C6C6C600FFF7DE00FFFFFF00849CFF000029
              F7000000EF000029F7007B94F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700BDC6E7005A73D6000018EF000010
              FF002952FF009CB5FF00E7E7E700DED6C600CECED6007B94F7000031FF000000
              EF000010DE005A73D600C6C6D600FFF7DE00FFF7DE00DEDEDE00D6D6D600DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600DED6C600C6C6C600637BDE000029
              F7000000F7000029F7007B8CD600C6C6C6007B8CD6000029F7000000F7000029
              F700637BDE00C6C6C600DED6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700FFFFF700FFFFFF00F7F7FF009CB5
              FF00214AFF000010EF001839DE00637BDE002142E7000010EF000839FF007B94
              F700D6DEEF00FFF7DE00FFF7DE00DEDEDE00D6D6D600DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007B94F7000029F7000010EF000029F7000010EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C6006363630052525200636363006363630063636300948C52009C94
              63005A6BAD000029F7000000FF000000F7000000F7000029F700ADBDF700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000107B000029F7000031FF000029F7000010EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C600636363005252520063636300848463007B7B630031314A000000
              5A000000AD000018F700315AFF00637BDE002142E7000018F7000839FF007B94
              F700E7EFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007B94F7000029
              F7000000EF000029F7007B8CD600C6C6C6007B8CD6000029F7000000EF000029
              F7007B94F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00EFEFF700F7F7F700FFFFFF00FFFFFF00F7F7FF009CB5FF00214AFF000010
              FF000021F7005A73D600BDBDBD00DED6C600C6C6C6005A73D6000010DE000000
              EF000029F7007B94F700C6CEEF00DEDEDE00E7E7DE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600DED6C600C6C6C600637BDE000029F7000000F7000029
              F700637BDE00C6C6C600DED6C600C6C6C600DED6C600C6C6C600637BDE000029
              F7000000F7000029F700637BDE00C6C6C600DED6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00FFFFF700F7F7F700BDCEF7005A7BF7000021FF000010FF00214AFF009CB5
              FF00FFFFFF00FFFFFF00FFF7DE00C6C6C600DEDEC600FFF7DE00DEDEEF007B94
              F7000021F7000000EF003152E700DEDEDE00FFF7DE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF007B94F7000029F7000000EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF005A7BF7000029F7005A7BF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00DED6C6006363630000084A0000005A0000005A0000005A0031395A007B7B
              63007B735A00636363008C8C8C00C6C6C600EFEFF700FFFFFF00FFFFFF00FFFF
              FF00BDCEF7007B94F700ADBDFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000000000000000005A5A5A00C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF00CECECE006B6B6B006B6B5A008C8C7300949473008C8C73007B7B73006B6B
              6B00636363006B6B6B0094949400CECECE00F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840094949400B5B5
              B500CECECE00D6D6D600DEDEDE00D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600DEDEDE00D6D6D600BDBDBD00A5A5A500A5A5A500B5B5B500BDBDBD00B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B50084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484008C8C8C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C00848484007B7B7B00848484009C9C9C00A5A5A5009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600CECECE00C6C6C6009C9C9C00848484009C9C9C00C6C6C600CECECE00C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484840094949400ADAD
              AD00B5B5B500ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00B5B5B500ADADAD00949494008484840094949400ADADAD00B5B5B500ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD0084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B00848484007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B00}
          end>
      end
      item
        Name = 'QuickPopUp_DelQuick'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              0000000000000000000000000000000000000000000084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00E7E7E700DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00CECECE00C6C6C600CECECE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700FFFFEF00FFF7DE00FFFFEF00F7F7
              F700FFFFFF00F7F7F700DEDEDE00C6C6C600C6C6C600DEDEDE00DEDEDE00DEDE
              DE00E7E7DE00FFF7DE00FFFFDE00FFF7DE00E7E7DE00DEDEDE00D6D6D600DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C600636363004A4A3900636363007384C600849CFF008C9CC6008484
              6B006B634A00636363008C8C8C00C6C6C600EFEFF700FFFFFF00FFFFFF00FFFF
              FF00DEE7FF00849CFF004A6BFF006384FF00ADBDFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C00000000000000000000000000001894000029F700001894000000
              000000000000000000005A5A5A00C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF007B94F7000029F7000000EF000029F7007B94F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C60063636300635A4200636363001031C6000000EF000000B5000000
              5A00292939007B7B6300ADA58C00C6C6C600FFFFEF00FFFFFF00F7F7FF007B94
              F7000029F7000000EF000018F7006384FF00CED6FF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007B94F7000029F7000000EF000029
              F700849CFF00FFFFFF00FFF7DE00C6C6C600FFF7DE00FFFFFF00849CFF000029
              F7000000EF000029F7007B94F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700BDC6E7005A73D6000018EF000010
              FF002952FF009CB5FF00E7E7E700DED6C600CECED6007B94F7000031FF000000
              EF000010DE005A73D600C6C6D600FFF7DE00FFF7DE00DEDEDE00D6D6D600DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600DED6C600C6C6C600637BDE000029
              F7000000F7000029F7007B8CD600C6C6C6007B8CD6000029F7000000F7000029
              F700637BDE00C6C6C600DED6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00F7F7F700F7F7F700FFFFFF00F7F7F700FFFFF700FFFFFF00F7F7FF009CB5
              FF00214AFF000010EF001839DE00637BDE002142E7000010EF000839FF007B94
              F700D6DEEF00FFF7DE00FFF7DE00DEDEDE00D6D6D600DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007B94F7000029F7000010EF000029F7000010EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C6006363630052525200636363006363630063636300948C52009C94
              63005A6BAD000029F7000000FF000000F7000000F7000029F700ADBDF700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000107B000029F7000031FF000029F7000010EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00C6C6C600636363005252520063636300848463007B7B630031314A000000
              5A000000AD000018F700315AFF00637BDE002142E7000018F7000839FF007B94
              F700E7EFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007B94F7000029
              F7000000EF000029F7007B8CD600C6C6C6007B8CD6000029F7000000EF000029
              F7007B94F700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400ADADAD00DEDE
              DE00EFEFF700F7F7F700FFFFFF00FFFFFF00F7F7FF009CB5FF00214AFF000010
              FF000021F7005A73D600BDBDBD00DED6C600C6C6C6005A73D6000010DE000000
              EF000029F7007B94F700C6CEEF00DEDEDE00E7E7DE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400A5A5A500C6C6
              C600CECECE00C6C6C600DED6C600C6C6C600637BDE000029F7000000F7000029
              F700637BDE00C6C6C600DED6C600C6C6C600DED6C600C6C6C600637BDE000029
              F7000000F7000029F700637BDE00C6C6C600DED6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400ADADAD00DEDE
              DE00FFFFF700F7F7F700BDCEF7005A7BF7000021FF000010FF00214AFF009CB5
              FF00FFFFFF00FFFFFF00FFF7DE00C6C6C600DEDEC600FFF7DE00DEDEEF007B94
              F7000021F7000000EF003152E700DEDEDE00FFF7DE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF007B94F7000029F7000000EF000029F7007B94F700FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF005A7BF7000029F7005A7BF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6D6D600FFFF
              FF00DED6C6006363630000084A0000005A0000005A0000005A0031395A007B7B
              63007B735A00636363008C8C8C00C6C6C600EFEFF700FFFFFF00FFFFFF00FFFF
              FF00BDCEF7007B94F700ADBDFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF008C8C8C000000000000000000000000000000000000000000000000000000
              000000000000000000005A5A5A00C6C6C600F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400DEDEDE00FFFF
              FF00CECECE006B6B6B006B6B5A008C8C7300949473008C8C73007B7B73006B6B
              6B00636363006B6B6B0094949400CECECE00F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400BDBDBD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840094949400B5B5
              B500CECECE00D6D6D600DEDEDE00D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600DEDEDE00D6D6D600BDBDBD00A5A5A500A5A5A500B5B5B500BDBDBD00B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B50084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484008C8C8C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C00848484007B7B7B00848484009C9C9C00A5A5A5009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600CECECE00C6C6C6009C9C9C00848484009C9C9C00C6C6C600CECECE00C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484840094949400ADAD
              AD00B5B5B500ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00B5B5B500ADADAD00949494008484840094949400ADADAD00B5B5B500ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD0084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              84008484840084848400848484008484840084848400848484007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B00848484007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B00}
          end>
      end
      item
        Name = 'QuickPopUp_FillQuick'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              0000000000000000000000000000000000000000000084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400B5B5B500E7E7
              E700EFEFEF00E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7
              E700E7E7E700E7E7E700CECECE00C6C6C600CECECE00E7E7E700E7E7E700E7E7
              E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7
              E700E7E7E700E7E7E700E7E7E700E7E7E700E7E7E70084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400D6CEC600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00EFE7DE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840084A5C6008CBD
              FF0084C6FF008CBDFF008CBDFF008CBDFF008CBDFF008CBDFF008CBDFF008CBD
              FF0084C6FF008CCEFF00A5C6DE00C6C6C600D6CEC600DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00848484004A8CC600109C
              FF00009CFF00109CFF00109CFF00109CFF00109CFF00109CFF00109CFF00109C
              FF000094FF00109CFF006BADE700C6C6C600DECEC600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60084848400399CC60000B5
              FF0000BDFF0000B5FF0000B5FF0000B5FF0000B5FF0000B5FF0000BDFF0000B5
              FF00009CFF00008CFF005AA5E700C6C6C600EFDECE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00848484004ABDC60010EF
              FF0000FFFF0010EFFF0010EFFF0010EFFF0010EFFF0010EFFF0010FFFF0010EF
              FF0000BDFF00109CFF00639CDE00C6C6C600FFEFDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840039BDC60000F7
              FF0000FFFF0000F7FF0000F7FF0000F7FF0000F7FF0000F7FF0000FFFF0000F7
              FF0000BDFF00008CFF005294DE00C6C6C600FFEFDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00848484004ABDC60010EF
              FF0000FFFF0010EFFF0010EFFF0010EFFF0010EFFF0010EFFF0010FFFF0010EF
              FF0000BDFF00109CFF00639CDE00C6C6C600FFEFDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840084BDC6008CF7
              FF008CFFFF008CF7FF008CF7FF008CF7FF008CF7FF008CF7FF008CFFFF008CF7
              FF0084E7FF008CCEFF00A5C6DE00C6C6C600D6CEC600DEDEDE00D6D6D600DEDE
              DE00E7E7E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700DEDEDE00D6D6D600DEDEDE00DEDEDE0084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00E7E7E700C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600E7E7E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00E7E7E700C6C6C600C6C6C600C6C6C600C6C6C60084848400DEC6BD00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFEFDE00C6C6C600C6CECE00E7E7E700DEDEDE00DEDE
              DE00FFEFFF00FFFFFF00DEFFEF0084EFA5005ABD7B007BAD8C00D6DED600FFFF
              FF00FFFFFF00DEDEDE00D6D6D600E7E7E700E7E7E70084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF008CF7AD0010D64A00008C0000007321007BAD8C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840084A5C6008CBD
              FF0084C6FF008CBDFF008CBDFF008CBDFF008CBDFF008CBDFF008CBDFF008CBD
              FF0084C6FF008CCEFF00A5C6DE00C6C6C600D6CEC600E7E7E700FFFFFF00FFFF
              FF00F7FFF70084EFA50029DE630000CE310000AD080000941800188C39007BAD
              8C00EFEFEF00FFFFFF00FFFFFF00E7E7E700DEDEDE00848484004A8CC600109C
              FF00009CFF00109CFF00109CFF00109CFF00109CFF00109CFF00109CFF00109C
              FF000094FF00109CFF006BADE700C6C6C600D6C6B500C6C6C600FFE7F700FFFF
              FF008CF7AD0010D64A0000CE310010D64A0010DE520010D64A00009418000073
              210084B59400FFFFFF00FFF7FF00C6C6C600C6C6C60084848400399CC60000B5
              FF0000BDFF0000B5FF0000B5FF0000B5FF0000B5FF0000B5FF0000BDFF0000B5
              FF00009CFF00008CFF0052A5DE00C6C6C600FFDEDE00FFE7F700DEEFDE0084EF
              A50029DE630000CE310000CE310010D64A0018E75A0010DE520000B529000094
              1800188C39007BAD8C00CECECE00FFEFF700FFF7FF00848484004ABDC60010EF
              FF0000FFFF0010EFFF0010EFFF0010EFFF0010EFFF0010EFFF0010FFFF0010EF
              FF0000BDFF00109CFF00639CDE00C6C6C600FFEFF700FFFFFF008CF7AD0010D6
              4A0000CE310010D64A0010D64A0010D64A0010D64A0010D64A0010DE520010D6
              4A0000941800007321007BAD8C00FFFFFF00FFFFFF008484840039BDC60000F7
              FF0000FFFF0000F7FF0000F7FF0000F7FF0000F7FF0000F7FF0000FFFF0000F7
              FF0000BDFF00008CFF006B94EF00C6C6C600CEE7B50073EF940010DE520000C6
              210000C6210000CE420010D64A0010D64A0010D64A0010D64A0018EF5A0010EF
              520000BD2100008C0000088C310063AD7B007BAD8C00848484004ABDC60010EF
              FF0000FFFF0010EFFF0010EFFF0010EFFF0010EFFF0010EFFF0010FFFF0010EF
              FF0000BDFF00109CFF0084A5F700C6C6C60084D6840010D64A0000D6390010D6
              4A0010D64A0010D64A0010D64A0010D64A0010D64A0010D64A0010D64A0010D6
              4A0010DE520010D64A0000A531000073210000631800848484008CC6CE0094FF
              FF009CFFFF0094FFFF0094FFFF0094FFFF0094FFFF0094FFFF0094FFFF0094FF
              FF008CF7FF0094DEFF00BDCEF700CECECE00A5DEAD007BF79C0084FFAD0094FF
              B50073F79C0042EF730018DE5A0010D64A0008D64A0010D64A0000AD310000A5
              310052D67B009CFFBD0094EFB5006BB584006BAD7B0084848400C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00DEDEDE00C6C6C600DEDEDE00FFFFFF00FFFFFF00FFFF
              FF00C6FFD60073FF9C0031EF6B0010D64A0000DE4A0010D64A00009418000073
              21007BAD8C00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400AD9C9C00D6BD
              B500DEC6BD00D6BDB500D6BDB500D6BDB500D6BDB500D6BDB500D6BDB500D6BD
              B500DEC6BD00D6C6B500B5B5AD00A5A5A500B5ADB500D6BDCE00E7B5DE00D6BD
              CE00B5E7C6007BFFA50039F7730010D64A0000DE4A0010D64A00009421000063
              180063846B00D6BDCE00F7CEE700D6CED600D6CED60084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              840084848400848484008484840084848400848484008484840084737B008484
              840084C69C0073FF9C0039F7730010D64A0000DE4A0010D64A00009C29000073
              2100396B4A008484840094848C008484840084848400848484008C8C8C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C00848484007B7B7B00848484009C9C9C00A594A5009C9C
              9C0094D6A50073FF9C0039F7730010D64A0000DE4A0010D64A00009C29000073
              21004A7B5A009C9C9C00B5A5AD009C9C9C009C9C9C0084848400A5A5A500C6C6
              C600CECECE00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
              C600CECECE00C6C6C6009C9C9C00848484009C9C9C00C6C6C600D6CED600C6C6
              C600ADEFBD0073FF9C0031EF6B0010D64A0000DE4A0010D64A00009421000073
              2100638C6B00C6C6C600DECED600C6C6C600C6C6C600737373008C8C8C009C9C
              9C00A5A5A5009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00A5A5A5009C9C9C008484840073737300848484009C9C9C00AD9CA5009C9C
              9C0094D6A50073FF9C0039F7730010D64A0000DE4A0010D64A00009C29000073
              21004A7B5A009C9C9C00B5A5AD009C9C9C009C9C9C0084848400848484008484
              8400848484008484840084848400848484008484840084848400848484008484
              840084848400848484008484840084848400848484008484840084737B008484
              840084C69C0073FF9C0039F7730010D64A0000DE4A0010D64A00009C29000073
              2100396B4A008484840094848C008484840084848400B5B5B500B5B5B500ADAD
              AD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADADAD00ADAD
              AD00ADADAD00ADADAD00B5B5B500B5B5B500B5B5B500ADADAD00B5A5AD00ADAD
              AD009CDEAD0073FF9C0039F7730010D64A0000DE4A0010D64A00009C21000073
              210052846300ADADAD00C6B5C600ADADAD00ADADAD00EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00FFE7F700EFEF
              EF00BDFFCE0073FF9C0031EF6B0010D64A0000DE4A0010D64A00009421000073
              210073A58400EFEFEF00FFFFFF00EFEFEF00EFEFEF00F7FFF700F7FFF700F7FF
              F700F7FFF700F7FFF700F7FFF700F7FFF700F7FFF700F7FFF700F7FFF700F7FF
              F700F7FFF700F7FFF700F7FFF700F7FFF700F7FFF700F7FFF700FFF7FF00F7FF
              F700C6FFD60073FF9C0031EF6B0010D64A0000DE4A0010D64A00009418000073
              21007BAD8C00F7FFF700FFFFFF00F7FFF700F7FFF700}
          end>
      end
      item
        Name = 'QuickPopUp_MarkTag'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BDBDBD006B6B6B00525252006363
              63005A5A5A006363630063636300636363006363630063636300636363006363
              63005A5A5A0063636300525252006B6B6B00B5B5B500FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00CECECE006363630000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000063636300CECECE00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00C6C6C600636363002929290029292900525252007B7B
              7B007B7B7B00636363005A5A5A00636363006363630063636300636363006363
              63006B6B6B006363630029292900101010001818180063636300B5B5B500EFEF
              EF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF006B6B6B0000000000101010007B7B7B00CECECE00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00CECECE007B7B7B00101010000000000052525200CECE
              CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ADADAD006363
              63006B6B6B007B7B7B002929290000000000000000004A4A4A00636363007B7B
              7B00D6D6D600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00CECECE002929290000000000000000008C8C
              8C00DEDEDE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007B7B7B000000
              0000000000000000000000000000000000000000000000000000000000000000
              00007B7B7B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF006B6B6B0000000000101010007B7B
              7B00CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECECE006B6B
              6B00000000000000000000000000000000000000000000000000000000006B6B
              6B00CECECE00FFFFFF00FFFFFF00FFFFFF00F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECECE008C8C8C008C8C8C00BDBD
              BD00EFEFEF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007B7B7B0000000000000000000000000000000000000000007B7B7B00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CECECE00E7E7E700DEDE
              DE00C6C6C6007B7B7B001010100000000000101010007B7B7B00C6C6C600DEDE
              DE00DEDEDE00CECECE00E7E7E700FFFFFF00FFFFFF00FFFFFF00E7E7E700CECE
              CE00C6C6C600C6C6C600BDBDBD00C6C6C600D6D6D600DEDEDE00DEDEDE00CECE
              CE00C6C6C600C6C6C600C6C6C600CECECE00CECECE009C9C9C00949494009C9C
              9C00EFEFEF00FFFFFF006B6B6B00000000006B6B6B00FFFFFF00EFEFEF009C9C
              9C00848484009C9C9C00CECECE00FFFFFF00FFFFFF00FFFFFF00CECECE009C9C
              9C00949494009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C00949494009C9C9C00C6C6
              C600FFFFFF00FFFFFF00E7DEC6009C947B00E7DEC600FFFFFF00FFFFFF00C6C6
              C6008C8C8C0094949400C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009494
              94009C9C9C00C6C6C600CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00C6C6C600A5A5AD00949494008C8C8C009C9C9C00CECECE00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00C6C6C6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00CECECE009C9C9C00949494009C9C9C00E7E7D600FFFF
              FF00D6DEFF00849CFF008CA5FF00A5BDFF008CA5FF00849CFF00D6DEFF00FFFF
              FF00D6D6CE009C9C9C00BDBDBD00FFFFFF00FFFFFF00FFFFFF00BDBDBD009C9C
              9C00CECECE00FFFFFF00FFFFFF00D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600FFFFFF00FFFFFF00D6D6D6009C9C9C008C8C8C009C9C9C00EFE7CE00FFFF
              FF0094ADFF001039FF000021FF001039FF000021FF001039FF0094ADFF00FFFF
              FF00E7DEC6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00CECECE00FFFFFF00D6D6D6009C9C9C00949494009C9C9C00949494009C9C
              9C00D6D6D600FFFFFF00D6D6D6009C9C9C00949494009C9C9C00EFE7CE00FFFF
              FF00849CFF000021FF000008FF000021FF000008FF000021FF00849CFF00FFFF
              FF00E7DEC6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00CECECE00FFFFFF00D6D6D600949494008484840094949400848484009494
              9400D6D6D600FFFFFF00DEDEDE009C9C9C00949494009C9C9C00EFE7CE00FFFF
              FF0094ADFF001039FF000021FF001039FF000021FF001039FF0094ADFF00FFFF
              FF00E7DEC6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00CECECE00FFFFFF00D6D6D6009C9C9C00949494009C9C9C00949494009C9C
              9C00D6D6D600FFFFFF00D6D6D6009C9C9C00949494009C9C9C00EFE7CE00FFFF
              FF00849CFF000021FF000008FF000021FF000008FF000021FF00849CFF00FFFF
              FF00E7DEC6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00CECECE00FFFFFF00D6D6D600949494008484840094949400848484009494
              9400D6D6D600FFFFFF00DEDEDE009C9C9C00949494009C9C9C00EFE7CE00FFFF
              FF0094ADFF001039FF000021FF001039FF000021FF001039FF0094ADFF00FFFF
              FF00E7DEC6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00CECECE00FFFFFF00D6D6D6009C9C9C00949494009C9C9C00949494009C9C
              9C00D6D6D600FFFFFF00D6D6D6009C9C9C00949494009C9C9C00E7E7D600FFFF
              FF00DEEFFF0094ADFF00849CFF0094ADFF00849CFF0094ADFF00DEEFFF00FFFF
              FF00D6D6CE009C9C9C00BDBDBD00FFFFFF00FFFFFF00FFFFFF00BDBDBD009C9C
              9C00CECECE00FFFFFF00F7F7F700CECECE00D6D6D600EFEFEF00D6D6D600CECE
              CE00F7F7F700FFFFFF00DEDEDE009C9C9C008C8C8C009C9C9C00CECECE00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00C6C6C6009C9C9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009C9C
              9C00C6C6C600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00CECECE009C9C9C009494940094949400A5A5AD00C6C6
              C600D6D6CE00E7DEC600E7DEC600E7DEC600E7DEC600E7DEC600D6D6CE00C6C6
              C6009C9C9C0094949400C6C6C600FFFFFF00FFFFFF00FFFFFF00C6C6C6009494
              94008C8C8C00C6C6C600FFFFFF00FFFFFF00D6D6D6008C8C8C00D6D6D600FFFF
              FF00FFFFFF00C6C6C6009C9C9C00949494008C8C8C009C9C9C009C9C9C009C9C
              9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C9C009C9C
              9C00949494009C9C9C00CECECE00FFFFFF00FFFFFF00FFFFFF00CECECE009C9C
              9C00848484009C9C9C00EFEFEF00FFFFFF006B6B6B00000000006B6B6B00FFFF
              FF00EFEFEF009C9C9C00949494009C9C9C009C9C9C00CECECE00C6C6C600C6C6
              C600C6C6C600CECECE00DEDEDE00DEDEDE00D6D6D600C6C6C600BDBDBD00C6C6
              C600C6C6C600CECECE00E7E7E700FFFFFF00FFFFFF00FFFFFF00E7E7E700CECE
              CE00DEDEDE00DEDEDE00C6C6C6007B7B7B001010100000000000101010007B7B
              7B00C6C6C600DEDEDE00E7E7E700CECECE00CECECE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF007B7B7B00000000000000000000000000000000000000
              00007B7B7B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00EFEFEF00BDBDBD008C8C8C008C8C8C00CECECE00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700FFFFFF00FFFFFF00FFFF
              FF00CECECE006B6B6B0000000000000000000000000000000000000000000000
              0000000000006B6B6B00CECECE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00CECECE007B7B7B0010101000000000006B6B6B00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF007B7B7B000000000000000000000000000000000000000000000000000000
              000000000000000000007B7B7B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00DEDEDE008C8C8C00000000000000000029292900CECECE00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00D6D6D6007B7B7B00636363004A4A4A000000000000000000292929007B7B
              7B006B6B6B0063636300ADADAD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00CECECE005252520000000000101010007B7B7B00CECECE00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00CECECE007B7B7B0010101000000000006B6B6B00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00EFEFEF00ADADAD00636363002929290029292900525252007B7B
              7B008C8C8C007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
              7B009C9C9C009C9C9C00737373004A4A4A003939390063636300C6C6C600FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7F7F700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00CECECE006363630000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000063636300CECECE00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00E7E7E7006B6B6B0000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000006B6B6B00E7E7E700FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
          end>
      end
      item
        Name = 'QuickPopUp_UndoEdit'
        SourceImages = <
          item
            Image.Data = {
              424D361000000000000036000000280000002000000020000000010020000000
              00000000000000000000000000000000000000000000B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5
              B500B5B5B500B5B5B500B5B5B500B5B5B500B5B5B500BDC6BD00BDC6BD00BDC6
              BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6
              BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00C6BDC600C6BDC600D6C6CE00D6C6
              D600CEBDCE00BDBDC600BDBDC600BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6
              BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00BDC6BD00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00D6C6CE00CECECE00BDDEB5009CDE9C0063CE7B005ABD
              7B0094CE9C00DEDECE00F7E7EF00EFDEE700DED6DE00CECECE00C6C6C600CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00D6C6D600CECECE00B5DEAD007BE77B0018C6420000AD
              31004AC66300BDDEB500DEDECE00CECECE00CECECE00CECECE00CECECE00CECE
              CE00CECECE00CECECE00CECECE00CECECE00CECECE00D6D6D600D6D6D600D6D6
              D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
              D600D6D6D600D6D6D600DED6DE00D6D6D600CEE7CE00A5E7A50052DE630018C6
              390021C642004AC6630052A5630063947300B5B5B500F7E7EF00F7E7EF00D6D6
              D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00EFDEEF00DEDEDE00BDE7B5007BE7
              7B0031D6520000AD3100007B08000073210073A57B00DEDEDE00FFEFF700DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00EFDEE700EFDEE700E7E7E700BDE7
              B5006BDE730018C63900009C0800007B1000087B310073A58400CECECE00FFEF
              F700FFEFFF00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDE
              DE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00DEDEDE00EFDEEF00DEDE
              DE00BDE7B5007BE77B0031D6520000AD3100007B08000073210073A57B00DEDE
              DE00FFEFF700DEDEDE00DEDEDE00DEDEDE00DEDEDE00FFF7FF00FFF7FF00FFF7
              FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7
              FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFF7FF00FFEFFF00F7E7
              F700EFEFE700C6F7C60084EF8C0031D6520000A5180000841000087B310073A5
              7B00CECECE00FFEFFF00FFF7FF00E7E7E700E7E7E700EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEFEF00EFEF
              EF00FFEFFF00EFEFEF00C6F7C6007BE77B0031CE520000AD3100007B08000073
              21007BAD8400EFEFEF00FFFFFF00EFEFEF00EFEFEF007BAD8C007BAD8C007BAD
              8C007BAD8C007BAD8C007BAD8C007BAD8C007BAD8C007BAD8C007BAD8C007BAD
              8C007BAD8C007BAD8C007BAD8C007BB58C005AA56B005AA57300A5C6AD00EFEF
              EF00FFFFFF00FFEFFF00EFEFDE00A5E7940042D65A0000AD3100008400000084
              100018A542007BDE9C00CEF7D600EFEFEF00FFF7FF0000732100007321000073
              2100007321000073210000732100007321000073210000732100007321000073
              210000732100007321000073210000732100005A0800007321007BAD8C00EFEF
              EF00FFFFFF00EFEFEF00EFEFDE00BDDEB5005AC66B0000AD310000AD290000AD
              310000A5210000AD31007BD69400EFEFEF00FFF7FF00007B1000007B1000007B
              1000007B1000007B1000007B1000007B1000007B1000007B1000007B1000007B
              1000008C18000084100000630000004A0000006B180063A57300C6DECE00F7F7
              F700FFFFFF00F7F7F700FFF7FF00EFEFDE009CDE9C0039CE5A0010C6390000B5
              3900008C0000008410006BBD8400F7F7F700FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000AD310000AD310000AD310000AD
              310000B5390000AD3100007B1000007321007BAD8C00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6F7C6007BE77B0029CE4A0000AD
              3100007B0800007321007BAD8C00FFFFFF00FFFFFF0000B5390000B5390000B5
              390000B5390000B5390000B5390000B5390000B5390000B5390000C6390000BD
              3900009C180000841000188C39007BB58C00E7EFE700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00DEFFD6008CEF840031D6520000AD
              310000730000006B180084AD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000AD310000AD310000B5390000AD
              3100007B1000007321007BAD8C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6F7C6007BE77B0029CE4A0000AD
              3100007B0800007321007BAD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000B5390000AD310000941800008C
              290039945A009CC6AD00F7EFF700FFFFFF00FFFFFF00FFFFFF00F7FFF700FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6F7CE007BE77B0029CE4A0000AD
              3100007B0800007321007BAD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000B5390000AD3100007B10000073
              21007BAD8C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6F7C6007BE77B0029CE4A0000AD
              3100007B0800007321007BAD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000B5390000B5390000BD390000AD310000941800008C
              290039945A009CC6AD00EFEFEF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00F7FFEF00C6F7C600B5FFAD008CEF840042D65A0000AD
              310000730000006B18007BAD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000AD310000AD310000B5390000AD
              3100007B1000007321007BAD8C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00BDF7BD007BE77B007BE77B007BE77B0042D65A0000AD
              3100007B0800007321007BAD8C00FFFFFF00FFFFFF0000AD310000AD310000AD
              310000BD390000B53900009C210000841800008C180000AD290000BD390000B5
              390000941800007B1000298C4A007BAD8C0084C69C007BD69C00BDEFC600F7EF
              E700FFFFFF00F7EFE70094DE940029C64A0021C6420039CE5A0021C64A0000AD
              310000840000008410006BBD8400FFFFFF00FFFFFF0000AD310000AD310000AD
              310000B5390000AD3100008C290000732100008C290000AD310000B5390000AD
              310000B5390000AD3100008C2900007321000084180000AD310063CE7300BDDE
              B500F7EFCE00BDDEB50063CE730000AD310000AD290000AD310000AD310000AD
              310000A5180000AD31007BD69C00FFFFFF00FFFFFF0000AD310000BD390000B5
              390000941800007B1000188431005A9C5A005ABD630029C64A0008BD390000AD
              290000AD310000AD310000941800007B10000084080000A5180018BD42005AC6
              6B0073CE7B005AC66B0021B54A0000AD290000A5210000AD2900009C100000A5
              180018BD4A007BDE9C00D6F7DE00FFFFFF00FFFFFF0000AD310000B5390000AD
              310000841800007321006BA56B00BDDEB500C6F7AD007BE77B0031CE520000AD
              310000AD290000AD310000AD310000AD310000AD310000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000AD310000AD310000A5180000AD
              31007BD69C00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000B5390000941000007B
              1000188439007BAD8C00D6DED600F7FFEF00FFFFEF00C6F7C60073DE840029C6
              4A0029C6420031CE520010BD420000AD310000AD290000AD290000AD290000AD
              290000A5210000AD290000AD290000AD290000A5100000A5180018BD4A007BD6
              9C00E7F7EF00FFFFFF00FFFFFF00FFFFFF00F7FFF70000AD3100007B10000073
              21007BAD8C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BDF7BD007BE7
              7B007BE77B007BE77B0039CE5A0000AD310000AD290000AD310000AD310000AD
              310000AD310000AD310000AD310000AD310000A5180000AD31007BD69C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00007B1000188C39007BAD
              8C00E7E7E700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7FFEF00C6F7
              C600BDEFB500A5E7940063D66B0029C64A0029C6420029C64A0000B5310000A5
              1800009C100000A5180010B539005AC66B0063CE7B007BD69C00D6F7DE00FFFF
              FF00FFFFFF00FFFFFF00F7FFF700FFFFFF00FFFFFF00007321007BB58C00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00EFEFDE00BDDEB50094DE8C007BE77B0084EF7B007BE77B0039CE5A0000AD
              310000A5210000AD31005AC66B00BDDEB500F7EFE700FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF007BAD8C00D6DED600FFFF
              FF00FFFFFF00FFFFFF00F7FFF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFF7FF00EFEFDE00D6F7CE00C6F7C600D6FFCE00C6F7C600A5EFB5007BD6
              9C0063CE8C007BD69C00B5E7BD00F7EFE700FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00F7FFF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00F7FFF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
              FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
          end>
      end>
    Left = 702
    Top = 295
  end
  object VirtualImageListMetadata: TVirtualImageList
    Images = <
      item
        CollectionIndex = 6
        CollectionName = 'QuickPopUp_FillQuick'
        Name = 'QuickPopUp_FillQuick'
      end
      item
        CollectionIndex = 8
        CollectionName = 'QuickPopUp_UndoEdit'
        Name = 'QuickPopUp_UndoEdit'
      end
      item
        CollectionIndex = 2
        CollectionName = 'QuickPopUp_AddQuick'
        Name = 'QuickPopUp_AddQuick'
      end
      item
        CollectionIndex = 5
        CollectionName = 'QuickPopUp_DelQuick'
        Name = 'QuickPopUp_DelQuick'
      end
      item
        CollectionIndex = 0
        CollectionName = 'QuickPopUp_AddCustom'
        Name = 'QuickPopUp_AddCustom'
      end
      item
        CollectionIndex = 4
        CollectionName = 'QuickPopUp_DelCustom'
        Name = 'QuickPopUp_DelCustom'
      end
      item
        CollectionIndex = 1
        CollectionName = 'QuickPopUp_AddDetailsUser'
        Name = 'QuickPopUp_AddDetailsUser'
      end
      item
        CollectionIndex = 7
        CollectionName = 'QuickPopUp_MarkTag'
        Name = 'QuickPopUp_MarkTag'
      end
      item
        CollectionIndex = 3
        CollectionName = 'QuickPopUp_CopyTag'
        Name = 'QuickPopUp_CopyTag'
      end>
    ImageCollection = ImageCollectionMetadata
    ImageNameAvailable = False
    PreserveItems = True
    Left = 702
    Top = 221
  end
  object TrayIcon: TTrayIcon
    BalloonFlags = bfInfo
    Icon.Data = {
      0000010001002020100000000000E80200001600000028000000200000004000
      0000010004000000000080020000000000000000000000000000000000000000
      000000008000008000000080800080000000800080008080000080808000C0C0
      C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      7CCCCCCCCCCCCCCCCCCCCCCCCC0000007CFFFFFFFFFFFFFFFFFFFFFFFC000000
      7CFFFFFFFFFFFFFFFFFFFFFFFC0000007CFFFFFFFFFFFFFFFFFFFFFFFC000000
      7CFFFF4444FFFF4444FFF44FFC0000007CFFF44FF44FF44FF44FF44FFC000000
      7CFFF44FF44FF44FF44FF44FFC0000007CFFF44F444FF44FF44FF44FFC000000
      7CFFF44FFFFFF44FF44FF44FFC0000007CFFF44FFFFFF44FF44FF44FFC000000
      7CFFFF4444FFF44FF44FF44FFC0000007CFFFFFFFFFFFFFFFFFFFFFFFC000000
      7CFFFFFFFFFFFFFFFFFFFFFFFC0077777CFFFFFFFFFFFFFFFFFFFFFFFC070000
      7CCCCCCCCCCCCCCCCCCCCCCCCC0000007CCCCCCCCCCCCCCCCCCCCCCCCC000000
      7CCCCCCCCCCCCCCCCCCCCCCCCC00000077777777777777777777777777000000
      0000000000000000000000000000000000000000000000000000000000000FFF
      F0F00F0F00F000FF0FFF0FFF0FF00F00000FF00F00F000F00F0F0F0F0F000F00
      000FF00F00F000F00F0F0F0F0F000FFF00F00F0F0FFF0FFF0FFF0FFF0F000F00
      0000000000F000F0000000000F000FFFF000000F000F00F0000000000F000000
      000000000000000000000000000000000000000000000000000000000000CCCC
      CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCFFFF
      FFFFFC000001F0000001F0000001F0000001F0000001F0000001F0000001F000
      0001F0000001F0000001F0000001F0000001F0000001F0000001000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000}
    OnMouseUp = TrayIconMouseUp
    Left = 836
    Top = 154
  end
  object TrayPopupMenu: TPopupMenu
    Images = ImgListTray_TaskBar
    OnPopup = TrayPopupMenuPopup
    Left = 836
    Top = 217
    object Tray_ExifToolGui: TMenuItem
      Caption = 'ExifToolGui'
      ImageIndex = 0
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Tray_Resetwindowsize: TMenuItem
      Caption = 'Reset window sizes to default'
      ImageIndex = 1
      OnClick = Tray_ResetwindowsizeClick
    end
  end
  object ImgListTray_TaskBar: TImageList
    Left = 836
    Top = 290
    Bitmap = {
      494C010102000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000B5B5B5FFB5B5B5FFB5B5B5FFB5B5
      B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5
      B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF00000000000000CCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000000000000CCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF7DE57DFF00B036FFC1E1B1FFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000008000000080000000000000000000000080000000800000000000
      00008000000000000000FF00000000000000E0E0E0FFE0E0E0FFE0E0E0FFE0E0
      E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FF7DE57DFF00B036FF0070
      22FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000800000000000000080000000000000008000000000000000800000000000
      00008000000000000000FF00000000000000E0E0E0FFE0E0E0FFE0E0E0FFE0E0
      E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FF7DE57DFF00B0
      36FF007022FFE0E0E0FFE0E0E0FFE0E0E0FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000800000000000000000000000000000008000000000000000800000000000
      00008000000000000000FF00000000000000F2F2F2FFF2F2F2FFF2F2F2FFF2F2
      F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FF7DE5
      7DFF00B036FF007022FFF2F2F2FFF2F2F2FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000008000000080000000000000008000000000000000800000000000
      00008000000000000000FF00000000000000007022FF007022FF007022FF0070
      22FF007022FF007022FF007022FF007022FF007022FFF2F2F2FFF2F2F2FFC1E1
      B1FF00B036FF00B036FF00B036FFF2F2F2FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF0000000000000000B036FF00B036FF00B036FF00B0
      36FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF7DE57DFF00B036FF007022FFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000B036FF00B036FF00B036FF00B0
      36FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF7DE57DFF00B036FF007022FFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000B036FF00B036FF00B036FF00B0
      36FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF7DE57DFF00B036FF007022FFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000B036FF00B036FF00B036FF00B0
      36FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7DE5
      7DFF7DE57DFF00B036FF007022FFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000B036FF00B036FF00B036FF0070
      22FF00B036FF00B036FF00B036FF007022FF00B036FFC1E1B1FFC1E1B1FF00B0
      36FF00B036FF00B036FF00B036FFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000B036FF00B036FF007022FFC1E1
      B1FF7DE57DFF00B036FF00B036FF00B036FF00B036FF00B036FF00B036FF00B0
      36FF00B036FF00B036FFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000B036FF007022FFFFFFFFFFFFFF
      FFFFFFFFFFFF7DE57DFF7DE57DFF00B036FF00B036FF00B036FF00B036FF00B0
      36FF00B036FFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000007022FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC1E1B1FF7DE57DFF7DE57DFF00B036FF00B036FFC1E1
      B1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000C001000000000000
      DFFD000000000000D995000000000000D555000000000000D755000000000000
      D955000000000000DFFD00000000000000000000000000000000000000000000
      0000000000000000CC7E000000000000943E0000000000008002000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object Taskbar: TTaskbar
    TaskBarButtons = <
      item
        Action = TaskBarResetWindow
        Hint = 'Reset window sizes to default'
        Icon.Data = {
          0000010001001010200000000000680400001600000028000000100000002000
          000001002000000000000004000000000000000000000000000000000000B5B5
          B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5
          B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFB5B5B5FFCCCC
          CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
          CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
          CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF7DE5
          7DFF00B036FFC1E1B1FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFE0E0
          E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0
          E0FF7DE57DFF00B036FF007022FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0
          E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0E0FFE0E0
          E0FFE0E0E0FF7DE57DFF00B036FF007022FFE0E0E0FFE0E0E0FFE0E0E0FFF2F2
          F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2F2FFF2F2
          F2FFF2F2F2FFF2F2F2FF7DE57DFF00B036FF007022FFF2F2F2FFF2F2F2FF0070
          22FF007022FF007022FF007022FF007022FF007022FF007022FF007022FF0070
          22FFF2F2F2FFF2F2F2FFC1E1B1FF00B036FF00B036FF00B036FFF2F2F2FF00B0
          36FF00B036FF00B036FF00B036FF00B036FF00B036FF00B036FF007022FFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B0
          36FF00B036FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B0
          36FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF7DE57DFF00B036FF007022FFFFFFFFFF00B0
          36FF00B036FF00B036FF00B036FF00B036FF00B036FF007022FFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFF7DE57DFF7DE57DFF00B036FF007022FFFFFFFFFF00B0
          36FF00B036FF00B036FF007022FF00B036FF00B036FF00B036FF007022FF00B0
          36FFC1E1B1FFC1E1B1FF00B036FF00B036FF00B036FF00B036FFFFFFFFFF00B0
          36FF00B036FF007022FFC1E1B1FF7DE57DFF00B036FF00B036FF00B036FF00B0
          36FF00B036FF00B036FF00B036FF00B036FF00B036FFFFFFFFFFFFFFFFFF00B0
          36FF007022FFFFFFFFFFFFFFFFFFFFFFFFFF7DE57DFF7DE57DFF00B036FF00B0
          36FF00B036FF00B036FF00B036FF00B036FFFFFFFFFFFFFFFFFFFFFFFFFF0070
          22FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC1E1B1FF7DE57DFF7DE5
          7DFF00B036FF00B036FFC1E1B1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000}
      end>
    TabProperties = [AppThumbAlways]
    OnThumbButtonClick = TaskbarThumbButtonClick
    Left = 702
    Top = 377
  end
  object ActLstTaskbar: TActionList
    Images = ImgListTray_TaskBar
    Left = 831
    Top = 380
    object TaskBarResetWindow: TAction
      Caption = 'Reset window sizes to default'
      Hint = 'Reset window sizes to default'
      ImageIndex = 1
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnMinimize = ApplicationEventsMinimize
    Left = 72
    Top = 383
  end
end
