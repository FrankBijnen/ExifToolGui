object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'FMain'
  ClientHeight = 580
  ClientWidth = 940
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnCanResize = FormCanResize
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 240
    Top = 25
    Width = 5
    Height = 536
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
    Left = 615
    Top = 25
    Width = 5
    Height = 536
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
    Top = 561
    Width = 940
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
    ExplicitTop = 560
    ExplicitWidth = 936
  end
  object AdvPanelBrowse: TPanel
    Left = 0
    Top = 25
    Width = 240
    Height = 536
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
    ExplicitHeight = 535
    object Splitter3: TSplitter
      Left = 1
      Top = 310
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
      Height = 309
      ActivePage = AdvTabBrowse
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 308
      object AdvTabBrowse: TTabSheet
        Caption = 'Folders'
        object ShellTree: TShellTreeView
          Left = 0
          Top = 0
          Width = 230
          Height = 281
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
          OnKeyDown = ShellTreeKeyDown
          OnChanging = ShellTreeChanging
          ExplicitHeight = 280
        end
      end
    end
    object AdvPagePreview: TPageControl
      Left = 1
      Top = 314
      Width = 238
      Height = 221
      ActivePage = AdvTabPreview
      Align = alBottom
      TabOrder = 1
      OnResize = AdvPagePreviewResize
      ExplicitTop = 313
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
    Left = 620
    Top = 25
    Width = 320
    Height = 536
    ActivePage = AdvTabMetadata
    Align = alRight
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    ExplicitLeft = 616
    ExplicitHeight = 535
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
          Left = 1
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'Exif'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnIptc: TSpeedButton
          Left = 103
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'Iptc'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnXmp: TSpeedButton
          Left = 52
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'Xmp'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnMaker: TSpeedButton
          Left = 155
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'Maker'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnALL: TSpeedButton
          Left = 206
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'ALL'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnCustom: TSpeedButton
          Left = 258
          Top = 2
          Width = 52
          Height = 21
          GroupIndex = 1
          Caption = 'Custom'
          OnClick = SpeedBtnExifClick
        end
        object SpeedBtnQuick: TSpeedButton
          Left = 1
          Top = 29
          Width = 102
          Height = 22
          GroupIndex = 1
          Down = True
          Caption = 'Workspace'
          OnClick = SpeedBtnExifClick
        end
        object EditFindMeta: TLabeledEdit
          Left = 155
          Top = 29
          Width = 157
          Height = 21
          Color = clWhite
          EditLabel.Width = 20
          EditLabel.Height = 21
          EditLabel.Caption = 'Find'
          LabelPosition = lpLeft
          LabelSpacing = 1
          TabOrder = 0
          Text = ''
          OnKeyPress = EditFindMetaKeyPress
        end
      end
      object AdvPanelMetaBottom: TPanel
        Left = 0
        Top = 402
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
        ExplicitTop = 401
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
          Left = 256
          Top = 6
          Width = 52
          Height = 22
          Anchors = [akTop, akRight]
          Caption = '&Save'
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
          Width = 200
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
        Height = 345
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
        ExplicitHeight = 344
        ColWidths = (
          150
          160)
      end
    end
    object AdvTabOSMMap: TTabSheet
      Caption = 'OSM Map'
      object AdvPanelBrowser: TPanel
        Left = 0
        Top = 57
        Width = 312
        Height = 419
        Align = alClient
        Caption = 'Internet access not enabled in preferences'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object EdgeBrowser1: TEdgeBrowser
          Left = 1
          Top = 1
          Width = 310
          Height = 417
          Align = alClient
          TabOrder = 0
          UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
          OnCreateWebViewCompleted = EdgeBrowser1CreateWebViewCompleted
          OnNavigationStarting = EdgeBrowser1NavigationStarting
          OnWebMessageReceived = EdgeBrowser1WebMessageReceived
          OnZoomFactorChanged = EdgeBrowser1ZoomFactorChanged
        end
      end
      object AdvPanel_MapBottom: TPanel
        Left = 0
        Top = 476
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
          Left = 1
          Top = 5
          Width = 90
          Height = 22
          Margins.Left = 1
          Margins.Top = 5
          Margins.Right = 1
          Margins.Bottom = 5
          Align = alLeft
          Caption = 'Geotag files'
          OnClick = SpeedBtn_GeotagClick
        end
        object EditMapBounds: TLabeledEdit
          AlignWithMargins = True
          Left = 142
          Top = 6
          Width = 167
          Height = 23
          Hint = 'Coordinates of the visible area (South,West,North,East)'
          Margins.Left = 50
          Margins.Top = 6
          TabStop = False
          Align = alClient
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
        TabOrder = 2
        object SpeedBtn_ShowOnMap: TSpeedButton
          Left = 1
          Top = 2
          Width = 85
          Height = 22
          Caption = 'Show on map'
          OnClick = SpeedBtn_ShowOnMapClick
        end
        object SpeedBtn_MapHome: TSpeedButton
          Left = 268
          Top = 2
          Width = 44
          Height = 22
          Caption = 'Home'
          OnClick = SpeedBtn_MapHomeClick
        end
        object SpeedBtn_MapSetHome: TSpeedButton
          Left = 268
          Top = 30
          Width = 44
          Height = 21
          Caption = 'Set^'
          OnClick = SpeedBtn_MapSetHomeClick
        end
        object Spb_GoBack: TSpeedButton
          Left = 130
          Top = 2
          Width = 61
          Height = 22
          Caption = '<< Back'
          OnClick = Spb_GoBackClick
        end
        object Spb_Forward: TSpeedButton
          Left = 197
          Top = 2
          Width = 66
          Height = 22
          Caption = 'Forward>>'
          OnClick = Spb_ForwardClick
        end
        object SpeedBtn_GetLoc: TSpeedButton
          Left = 1
          Top = 28
          Width = 85
          Height = 22
          Hint = 'Sets to Lat/Lon values to the center of map'
          Caption = 'Get location'
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedBtn_GetLocClick
        end
        object EditMapFind: TLabeledEdit
          Left = 129
          Top = 30
          Width = 136
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
    end
  end
  object AdvPageFilelist: TPageControl
    Left = 245
    Top = 25
    Width = 370
    Height = 536
    ActivePage = AdvTabFilelist
    Align = alClient
    Constraints.MinWidth = 364
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 3
    ExplicitWidth = 366
    ExplicitHeight = 535
    object AdvTabFilelist: TTabSheet
      Caption = 'Filelist'
      object AdvPanelFileTop: TPanel
        Left = 0
        Top = 0
        Width = 362
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
        ExplicitWidth = 358
        object SpeedBtnDetails: TSpeedButton
          Left = 2
          Top = 29
          Width = 75
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
          Width = 75
          Height = 21
          Caption = 'Refresh'
          OnClick = BtnFListRefreshClick
        end
        object SpeedBtnFilterEdit: TSpeedButton
          Left = 250
          Top = 2
          Width = 60
          Height = 21
          Caption = 'Edit'
          OnClick = BtnFilterEditClick
        end
        object SpeedBtnColumnEdit: TSpeedButton
          Left = 250
          Top = 29
          Width = 60
          Height = 22
          Caption = 'Edit'
          OnClick = BtnColumnEditClick
        end
        object CBoxDetails: TComboBox
          Left = 80
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
          Left = 80
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
        Top = 324
        Width = 362
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
        ExplicitTop = 323
        ExplicitWidth = 358
        DesignSize = (
          362
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
          Left = 273
          Top = 79
          Width = 86
          Height = 21
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Edit predefined'
          OnClick = SpeedBtn_ETeditClick
        end
        object SpeedBtnShowLog: TSpeedButton
          Left = 235
          Top = 6
          Width = 124
          Height = 22
          Caption = 'Show Log window'
          OnClick = BtnShowLogClick
        end
        object SpeedBtnETdirectDel: TSpeedButton
          Left = 2
          Top = 114
          Width = 66
          Height = 25
          Caption = '^ Delete'
          Enabled = False
          OnClick = BtnETdirectDelClick
        end
        object SpeedBtnETdirectReplace: TSpeedButton
          Left = 70
          Top = 114
          Width = 66
          Height = 25
          Caption = '^ Replace'
          Enabled = False
          OnClick = BtnETdirectReplaceClick
        end
        object SpeedBtnETdirectAdd: TSpeedButton
          Left = 138
          Top = 114
          Width = 66
          Height = 25
          Caption = '^ Add new'
          Enabled = False
          OnClick = BtnETdirectAddClick
        end
        object SpeedBtn_ETdSetDef: TSpeedButton
          Left = 206
          Top = 114
          Width = 66
          Height = 25
          Caption = '^ Default'
          OnClick = SpeedBtn_ETdSetDefClick
        end
        object SpeedBtn_ETclear: TSpeedButton
          Left = 273
          Top = 114
          Width = 66
          Height = 25
          Caption = 'Deselect'
          OnClick = SpeedBtn_ETclearClick
        end
        object CmbETDirectMode: TComboBox
          Left = 115
          Top = 6
          Width = 114
          Height = 21
          Hint = 'Choose how the command(s) must be executed'
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
          Width = 339
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
          ExplicitWidth = 335
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
        Width = 362
        Height = 245
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
        OnEnter = ShellListEnter
        ParentFont = False
        TabOrder = 2
        ViewStyle = vsReport
        OnKeyDown = ShellListKeyDown
        OnKeyUp = ShellListKeyUp
      end
      object PnlBreadCrumb: TPanel
        Left = 0
        Top = 57
        Width = 362
        Height = 22
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 3
        ExplicitWidth = 358
      end
    end
    object AdvTabChart: TTabSheet
      Caption = 'Chart'
      object AdvPanel1: TPanel
        Left = 0
        Top = 0
        Width = 362
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
        Width = 362
        Height = 371
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
    Width = 940
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
    ExplicitWidth = 936
  end
  object OpenPictureDlg: TOpenPictureDialog
    Filter = 
      'All (*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.ico;*.emf;*.wmf;*.tif;*.ti' +
      'ff)|*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.ico;*.emf;*.wmf;*.tif;*.tif' +
      'f|GIF Image (*.gif)|*.gif|JPEG Image File (*.jpg)|*.jpg|JPEG Ima' +
      'ge File (*.jpeg)|*.jpeg|Portable Network Graphics (*.png)|*.png|' +
      'Bitmaps (*.bmp)|*.bmp|Icons (*.ico)|*.ico|Enhanced Metafiles (*.' +
      'emf)|*.emf|Metafiles (*.wmf)|*.wmf|TIFF Images (*.tif)|*.tif|TIF' +
      'F Images (*.tiff)|*.tiff|*.*|*.*'
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
                Action = MaPreferences
                Caption = '&Preferences...'
              end
              item
                Action = MaQuickManager
                Caption = '&Workspace manager...'
              end
              item
                Caption = '-'
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
                Items = <
                  item
                    Action = MaETDirectLoad
                    Caption = '&Load..'
                  end
                  item
                    Action = MaEtDirectSave
                    Caption = '&Save...'
                  end>
                Caption = 'E&xifTool direct definition file'
                UsageCount = 1
              end
              item
                Items = <
                  item
                    Action = MaUserDefLoad
                    Caption = '&Load..'
                  end
                  item
                    Action = MaUserDefSave
                    Caption = '&Save...'
                  end>
                Caption = '&User defined fields definition file'
                UsageCount = 1
              end
              item
                Items = <
                  item
                    Action = MaCustomViewLoad
                    Caption = '&Load..'
                  end
                  item
                    Action = MaCustomViewSave
                    Caption = '&Save...'
                  end>
                Caption = '&Custom view definition file'
                UsageCount = 1
              end
              item
                Items = <
                  item
                    Action = MaMarkedLoad
                    Caption = '&Load..'
                  end
                  item
                    Action = MaMarkedSave
                    Caption = '&Save...'
                  end>
                Caption = '&Marked tags definition file'
                UsageCount = 1
              end
              item
                Caption = '-'
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
                Action = MaAPILargeFileSupport
                Caption = 'API &LargeFileSupport'
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
              end
              item
                Caption = '-'
              end
              item
                Action = MaCheckVersions
                Caption = '&Check Versions'
              end
              item
                Caption = '-'
              end
              item
                Action = MaAbout
                Caption = '&About...'
              end>
            Caption = '&Help'
          end>
        ActionBar = ActionMainMenuBar
      end>
    Left = 163
    Top = 52
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
      Tag = 50
      Category = 'Help'
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
    object MaAPILargeFileSupport: TAction
      Tag = 10
      Category = 'Options'
      AutoCheck = True
      Caption = 'API LargeFileSupport'
      OnExecute = MaAPILargeFileSupportExecute
    end
    object MaCustomOptions: TAction
      Tag = 10
      Category = 'Options'
      Caption = 'Custom options'
      OnExecute = MCustomOptionsClick
    end
    object MaCheckVersions: TAction
      Tag = 50
      Category = 'Help'
      Caption = 'Check Versions'
      OnExecute = MaCheckVersionsExecute
    end
    object MaETDirectLoad: TAction
      Category = 'Program_ETDirect'
      Caption = 'Load..'
      OnExecute = MaETDirectLoadExecute
    end
    object MaEtDirectSave: TAction
      Category = 'Program_ETDirect'
      Caption = 'Save...'
      OnExecute = MaEtDirectSaveExecute
    end
    object MaUserDefLoad: TAction
      Category = 'Program_UserDef'
      Caption = 'Load..'
      OnExecute = MaUserDefLoadExecute
    end
    object MaUserDefSave: TAction
      Category = 'Program_UserDef'
      Caption = 'Save...'
      OnExecute = MaUserDefSaveExecute
    end
    object MaCustomViewLoad: TAction
      Category = 'Program_CustomView'
      Caption = 'Load..'
      OnExecute = MaCustomViewLoadExecute
    end
    object MaCustomViewSave: TAction
      Category = 'Program_CustomView'
      Caption = 'Save...'
      OnExecute = MaCustomViewSaveExecute
    end
    object MaMarkedLoad: TAction
      Category = 'Program_Marked'
      Caption = 'Load..'
      OnExecute = MaMarkedLoadExecute
    end
    object MaMarkedSave: TAction
      Category = 'Program_Marked'
      Caption = 'Save...'
      OnExecute = MaMarkedSaveExecute
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
        Name = 'QuickPopUp_FillQuick'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152E14075BBADF000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC6105000001B6504C54
              45848484A5A5A5C6C6C6CECECEB5B5B5E7E7E7EFEFEFFFFFFFDEDEDEC6CED6DE
              E7EFC6A584FFBD8CFFC684FFCE8CDEC6A5C68C4AFF9C10FF9C00FF9400E7AD6B
              C6CEDEC69C39FFB500FFBD00FF8C00E7A55ACEDEEFC6BD4AFFEF10FFFF00FFFF
              10DE9C63DEEFFFC6BD39FFF700DE9452C6BD84FFF78CFFFF8CFFE784D6D6D6BD
              C6DECECEC6FFEFFFEFFFDEA5EF847BBD5A8CAD7BD6DED6ADF78C4AD610008C00
              217300F7FFF763DE2931CE0008AD00189400398C18B5C6D6F7E7FF52DE1094B5
              84FFF7FFDEA552DEDEFFDEEFDE5AE71829B500F7EFFFEF946BB5E7CE94EF7321
              C60042CE005AEF1852EF1021BD00318C087BAD63F7A58484D68439D60031A500
              186300CEC68CFFFF94FFFF9CFFDE94F7CEBDADDEA59CF77BADFF84B5FF949CF7
              7373EF425ADE184AD60831AD007BD652BDFF9CB5EF9484B56B7BAD6BD6FFC69C
              FF736BEF314ADE009C9CADB5BDD6ADB5B5B5ADB5CEBDD6DEB5E7C6E7B5A5FF7B
              73F7392194006B8463E7CEF7D6CED67B73849CC684299C004A6B398C84948C8C
              8C9C9C9C7B7B7BA594A5A5D6945A7B4AADA5B5BDEFAD6B8C63D6CEDE737373A5
              9CADADADADADDE9C219C00638452C6B5C6CEFFBD84A5739B4A1EB6000001D449
              44415478DA8593E957D34014C55F5F3A994101292E2D42AB502D5205AB436245
              5AAA282AEE0AE202B86FA86851C1BAC0B8A0425CFF63679242D369CEE9EF434E
              5E72DF3DF7DC3903B64EC17E32F3943FE30356C6A6B60DA64ECEFCEB0AE6AD7F
              26354D08879D0A61392D3B3F67DE48C12FEBB7F3C771A08677F0DE157CB03EC2
              A29C57964448788404AC8058155FCA82AF62590880101AE861A0008125FC56CE
              F01D7F20022C095171F804E2B3EE502F033C9F4DCF7AA4075F845E16E78AAF5E
              2BC1FCF842F16DA90480B40243269FEB45A94F005727AE4D78A4AEDF306E4E4E
              4DDFBA7D87DFE5F7C6EE3F78F8E83140473C1157EC88C72297F032BFC2D7C8F3
              316B1CA02B99482A12C958DB493C753A3F3A7A46FD3E7BEE7CFF858B996A879D
              38420FF26C79DF4D01B02D1A8B2A62D1D6B6A3782C37DC77289BE5C7F327068E
              648C9102404BA435E2B139B2050731E77AA8FD215A504D6E6C6C6AF4686ADE84
              0D84525B7A1C96FB26A58405F540A547BFD782CA90F6093A712F616C1FEDEDDB
              9F3920F53D84543B10F754897F02D89DEA4E29BA537B5406D6C3D605F29DE93D
              74528DEA26770509EA3AF89BDC8EED4C436F722B6AD43459EB10D464558606DF
              B4214850D7214C4CB2868106D1F0DFAC40FE0362D68AC7A7E303290000000049
              454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_UndoEdit'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152E2BB13D97E2000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC6105000001C2504C54
              45B5B5B5BDC6BDC6BDC6CEC6D6D6C6D6CEBDCEC6BDBDCECECEB5DEBD9CDE9C7B
              CE637BBD5A9CCE94CEDEDEEFE7F7E7DEEFDED6DEC6C6C6ADDEB57BE77B42C618
              31AD0063C64AD6D6D6CEE7CEA5E7A563DE5239C61842C62163A552739463DEDE
              DEEFDEEFB5E7BD52D631087B002173007BA573F7EFFFE7E7E773DE6B089C0010
              7B00317B0884A573FFEFFFFFF7FFF7E7F7E7EFEFC6F7C68CEF8418A500108400
              EFEFEF52CE3184AD7BFFFFFF8CAD7B8CB57B6BA55A73A55AADC6A5DEEFEF94E7
              A55AD64200840042A5189CDE7BD6F7CE085A006BC65A29AD0021A50094D67B18
              8C00006300004A00186B0073A563CEDEC6F7F7F75ACE3939C61039B500008C00
              84BD6B4ACE2939C60039BD00189C00398C18E7EFE7D6FFDE84EF8C0073008CAD
              84189400298C005A9439ADC69CF7EFF7F7FFF7CEF7D6EFFFF7ADFFB5BDF7BD21
              9C001884004A8C299CC6849CD67BC6EFBDE7EFF794DE944AC6294AC62173CE63
              CEEFF73184185A9C5A63BD5A39BD0808840042BD187BCE734AB521109C004ABD
              18DEF7D66BA56BADF7C6109400398418D6DED6EFFFFF84DE7342C62942BD1010
              A500EFF7E7B5EFBD6BD66331B50039B5108CDE947BEF84CEFFD6B5EFA58CCE63
              BDE7B549FB3615000001FB4944415478DA85928B5793501C806F6A82969B8557
              2BADE944971814017659854B8B2DCBDABAA9CBB2B61EAE5AD1227B97DAC3B297
              D9EBFFEDDE3179B593DF391BDCCBF7FBCE800184D02DF41F00DA04A0AFB80DC9
              98977FCABFACDFD69F0ADAD8057CD2950D769DFBC1E560069A6CC52D08B37AA2
              7A5692BF8E7EB357ED356551F96EB65ACB4E034081D7ABC21D8E23D369E8A040
              AB56C0EF84F7FA4AE983FCD15E1DF904D3840CF97C5696AC2FB401208665FE0D
              FB961B71A7030D00F3B8203C79FACC7E4EAE178417CA4BF395F99A541695A5F1
              652A40D228F245F24D8F65B8C03E6617AAB56A830A797CB73C91A6A57BFA7DEB
              4105551EDA3DB947F0843AE5080ED8BD1FE78E52B09FAE1D01E33C2C14AFDFD0
              6A4249BE3D9782572775AFE09FA7C8DCB4BF40055AB8E9BE97F9B0106E7805BC
              C14CFE923A9BBC5C13AECCC5C96FB8E62F041B5E41F09850CF9C9D3C773E8BB2
              92D192BB802FAA5359F27F08728AD735A419AC499E65069ED624A007481E3D76
              5C43A2319A22CF716CFC2411B47F113599BCDB7EFE086969400A231E3C241F8E
              2BEAF000234A89048885E98DF57171323F101BA4CBB0108D26FAF6770F09C307
              9841B19E109A2742979FF6AE5DBBF774F774EEDD072211670B307E9A989D5C07
              EC64DBBCADA0D0C8B02DADDBB6B745A2EDCC8E7A421DC096200D0D8D4D5B9B9B
              BD0DB0197F01F8B1B8456400AEC60000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_AddQuick'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152D1952C795A1000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC61050000010E504C54
              45848484BDBDBDFFFFFFDEDEDEC6C6C6ADADADE7E7E7CECECEA5A5A5F7F7F7EF
              E7EFF7EFFFD6D6D66363635252525A5A5A848C84FFF7FFDEEFD69CC684BDDEB5
              8C8C8C0000007BB563217B0073AD5AB5A5C6F7E7FFF7FFEF9CEF7B299400086B
              0073A55AA5F77B42D6000094008CB57BA5F78452E71829D600008C009CBD9429
              DE00109400F7DEFF52DE18219C00216B005284399CB58C84AD6B94BD7BCEE7C6
              42DE0031AD00D6FFC68CEF634ADE0839C600109C00006300005A007BA56B42E7
              0042EF0039E70000B50018A5008CCE6B29B50063C639ADF78C94EF6B00840018
              63009CA59431BD007BC65A84E75A6B6B6B94948CEFFFDEB5FF8CD6FFBD949494
              B5B5B5C6BDCECEBDD69C9C9C7B7B7BAD3351EF000001634944415478DA8D937B
              5B823014C6C7360414322D6B65642E8D42D3CABC74BFD8FD661731FCFE5F2416
              201B69FAFB83E739DBCBCB39EF0600431EB1FA5D994E5F76641F47EE73550000
              2A56B08F825DE08EAA0000726E88EA8221F09E02B3F4E0283AD219489754D519
              7C0F1C0E00241881308231004050E9A57B0CA3F78E33F0E3F32B2EC82D85A431
              841DFA260A74888D39833167ACE6D7CC97EEAB2890844F16E92629890219691A
              D4185E59DEB21E9F9E83BD04D2118A9294701E96A94D2B238784B78699430221
              4F5BAD66CD5DCBA2B7AD3BF3DE7C28B661CA77887A30A945432C6A863DE060BB
              DD39B298E0E2F2CAB6EDEBEE4D7C0AFEFD66D449DCA1498F5BB5CA49E5F4ECFC
              6F0ECCA3495BA44E0829904694033F854D6BF5BDD27EE9A071083333E72026B9
              4D76C424A79E45FC34D70B1BFFDF8765B232C9216DCC4B19985D589C7C1FC6DE
              496E0A0D618C92A924EB3E84FFB3C61226E9A36005C598DAC30FABC046BB9652
              B4090000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_DelQuick'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152E056DEB9A2D000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC610500000123504C54
              45848484BDBDBDFFFFFFDEDEDEC6C6C6ADADADE7E7E7CECECEA5A5A5F7F7F7EF
              FFFFDEF7FFDEE7E7DEFFFFD6D6D6636363394A4AC68473FF9C84C69C8C6B8484
              4A636B8C8C8CF7EFEFFFE7DEFF6B4AFF8463FFBDAD000000941800F729005A5A
              5AF7947BEF0000425A63C63110B500005A0000392929637B7B8CA5ADFFF7F7F7
              1800FFD6CEE7C6BDD6735AEF1800FF1000FF5229FFB59CC6D6DED6CECEFF3100
              DE1000D6C6C6DE7B63F70000D68C7BF7FFFFFF4A21EF1000DE3918E74221FF39
              08EFDED6525252528C9463949CAD6B5AFF0000F7BDAD7B10006384844A3131AD
              0000FF5A31FFEFE7F72100EFCEC6F7CEBDF77B5AFF2100C6DEDEEFDEDEE75231
              4A08005A39315A737B6B6B6B5A6B6B738C8C739494737B7B949494B5B5B59C9C
              9C7B7B7BD39538A50000019B4944415478DA8D937B57823018C6C736029CB1B2
              D2AE6B56645A669AA69565F7BB6977B344BFFFA76804C8E5E0A9DF1F83EDBC7B
              78DE870D80819FE0EC77E56F7AB229DB9872CF37730040C50AB651701FF48733
              0700927D17B50F06408C01FEE3C15474A45B205D52555332030020410F84110C
              0100824AE7B3FBD5FDEED04E4FD1A20A928B2ECB38A2408725FA6618C67BE683
              26714AACB5F882BFC0F2C0599AF1A187366BFB0B6474A0B5DA4F85C32284043F
              9317DE4CBF22821CEC244BB8CA6AAC2A9EDEDB304919A584B36CF1B0D0CC4B25
              9CAF88AF3DA2B8A7E0E660F9D8C7FB8E9B4017989ED29BCCAD7197BBAF1EE71A
              FC61540ED7ACCCEAC1FD9E02A567E717ECB2566357E102EF5F70B13F4241469A
              06B503AB8FFA51F5B8DEE02784203D980376FAB7BA08A460E760296CE5B70B3B
              C5B1D22E2FA72BF93D4FC3F560A5901051139808266177B14257D36BC67A6603
              C76056D4E6E637C3392CB1A5E179E07E0D5B61824E26A6A6679CF3309B989B5F
              88CA61C499B4BB8891981811C6C2789C8C93B8D7851ABE4BE19B25A3313735A4
              600585F8D3C30FB5E44F67FCD37DC40000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_AddCustom'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152D0431C1F978000000097048597300000B42
              00000B420164E82B5F0000000467414D410000B18F0BFC6105000001B9504C54
              458C8C8CC6C6C6F7F7F7EFEFEFE7E7E7CECECEDEDEDEFFFFFFD6D6D6ADADAD63
              63634A4A4A5252525A5A5A2121210808081010101818187373737B7B7B6B6B6B
              9C9C9C848484A5A5A5B5B5B594948C000000E7F7E7F7FFEFADA5B5CEC6CEADCE
              A59CD68CD6EFCEF7FFF7E7DEEFB5BDAD529C3939A51084C66BEFF7E763A54A21
              8C0018940039A5188CC673E7F7DEDED6DED6CED6DECEE773B55A319C10219400
              188C009CD684EFE7EFCECED6F7EFF7D6DED67BCE5231B50018A5001084004AAD
              2194CE7BD6E7CEEFF7EFB5F7946BE73939BD10299C0029940039A52194CE84E7
              EFDEBDB5BDEFFFE7BDF79C73DE4239BD0821A50094BD8484B56BDEEFDE84B573
              217318086308C6CEC6C6FFA57BEF4A219C0042A518398C18085A00005200BDBD
              BDC6C6CEE7DEE76BE731319C00ADDE9C319C18107B00216B00C6BDC642C60829
              A50063B5425AB531847B84949494D6C6DE63D63131A508319C0821840094D673
              6BD6394AC61839B50029840094DE7B63DE2939BD00E7C6EFB5E79C52C62129AD
              00948C94D6CEDE94CE73C6BDCEBDCEB54AA529FFF7FFE7FFDE4ABD1031940863
              E72952DE106BEF3142A510217300186300A5EF844AE70873F7311C0F77590000
              02444944415478DA6D928B5BD2501887CF391BDB9C80B6B10345665909712B73
              409419886EB5242A2B532B4A22BBE2A5B2A27B7631B5EB5FDC39678C70F23EF0
              3C83E777CEF77DEF3E20BA48FDDEFC33CFD8FADB98FBF90BB803D1E2C66683B1
              B1D5F8D12130F0ADB8541E595FA5AC7F5F58009C0BF4D54A0EEAD515C272F525
              09C04A1B90FC5A5BFB1CF9124B9B94A72480DDA81F3E4E7DAAA54DC3A89AF406
              056B2DEAAA82EBA0FE26FBF6DD7BC3ACDA011CAC385560A58E35526671FA55E3
              B561366FC0752DE8A061150787B28567CF575F18B1F8AC1DC0E03FF8895A5F8C
              969626964D63B8B66237A985A0C7068634ADEF7EA134F3E0A13EAA3F8A3C8EDD
              A3810A8710F95038E9F69D7069BE5C35CD74E2AE95A9D1009090072BAA4A0698
              462817BD3E539ED547E373F931D14ADEB8790B008107FE1E8A1F2071B2385E36
              C8F9B3F928D13E75E5EA3572031792BDB2ECF306CEA3C9D285F24552FF4C26C5
              5E4CE1D265002042822408E49B1B2B8E4F183A397FCE12EDAE2C0BE090E0BCA7
              DCC95323A7E9F97C219B15287C962326A1644F796C081E1FD6F5742213CE9E80
              0CF22FC05D5273483266FF91583C914C89E8A8E4407AE0506B190E1E3A3C18A1
              FDA316D40354E480A2280159E9DBD7BFFFC0C0B60DB33DECD945E8EDF12B301C
              DE2BBA0212621E085E793744EE1DA51E38E681E281026AABCF7AA01E9ACF2212
              A04770413D785AC09D300FCEC67312F4906A523BCC03EF20911E5C300FAAAC50
              028A06B99D53B07DE8753C741853E2BAE46EAFCFE7F376FB68BD0E1E10C7B326
              799E79D8CE3FABA97F4300730F240000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_DelCustom'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152D341718C9D4000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC610500000123504C54
              45848484BDBDBDFFFFFFDEDEDEC6C6C6ADADADE7E7E7CECECEA5A5A5F7F7F7EF
              FFFFDEF7FFDEE7E7DEFFFFD6D6D6636363394A4AC68473FF9C84C69C8C6B8484
              4A636B8C8C8CF7EFEFFFE7DEFF6B4AFF8463FFBDAD000000941800F729005A5A
              5AF7947BEF0000425A63C63110B500005A0000392929637B7B8CA5ADFFF7F7F7
              1800FFD6CEE7C6BDD6735AEF1800FF1000FF5229FFB59CC6D6DED6CECEFF3100
              DE1000D6C6C6DE7B63F70000D68C7BF7FFFFFF4A21EF1000DE3918E74221FF39
              08EFDED6525252528C9463949CAD6B5AFF0000F7BDAD7B10006384844A3131AD
              0000FF5A31FFEFE7F72100EFCEC6F7CEBDF77B5AFF2100C6DEDEEFDEDEE75231
              4A08005A39315A737B6B6B6B5A6B6B738C8C739494737B7B949494B5B5B59C9C
              9C7B7B7BD39538A50000019B4944415478DA8D937B57823018C6C736029CB1B2
              D2AE6B56645A669AA69565F7BB6977B344BFFFA76804C8E5E0A9DF1F83EDBC7B
              78DE870D80819FE0EC77E56F7AB229DB9872CF37730040C50AB651701FF48733
              0700927D17B50F06408C01FEE3C15474A45B205D52555332030020410F84110C
              0100824AE7B3FBD5FDEED04E4FD1A20A928B2ECB38A2408725FA6618C67BE683
              26714AACB5F882BFC0F2C0599AF1A187366BFB0B6474A0B5DA4F85C32284043F
              9317DE4CBF22821CEC244BB8CA6AAC2A9EDEDB304919A584B36CF1B0D0CC4B25
              9CAF88AF3DA2B8A7E0E660F9D8C7FB8E9B4017989ED29BCCAD7197BBAF1EE71A
              FC61540ED7ACCCEAC1FD9E02A567E717ECB2566357E102EF5F70B13F4241469A
              06B503AB8FFA51F5B8DEE02784203D980376FAB7BA08A460E760296CE5B70B3B
              C5B1D22E2FA72BF93D4FC3F560A5901051139808266177B14257D36BC67A6603
              C76056D4E6E637C3392CB1A5E179E07E0D5B61824E26A6A6679CF3309B989B5F
              88CA61C499B4BB8891981811C6C2789C8C93B8D7851ABE4BE19B25A3313735A4
              600585F8D3C30FB5E44F67FCD37DC40000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_AddDetailsUser'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152D0ED1141066000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC6105000000AE504C54
              458484844242420000007B7B7B737373737B847B5A397B4A08845A007B73087B
              7B08393939B5B5B5EFEFEFF7F7F7EFF7FFF7B57BFF9C10FFBD00FFEF10FFFF10
              FFFFFFC6C6C6FFCE8CFFAD10FFCE00BDBDBDF7FFFFFFBD7BFF9C00FFFF009494
              94ADADADADB5BDB59473B58442BD9431B5AD42B5B5425A5A5A8C8C8C9C9C9C94
              9CA594A5B5949CB59494B54A4A4AA5A5A5CECECEDEDEDE636363D6D6D6E7E7E7
              6B6B6B313131525252292929212121037F1C410000010F4944415478DAEDD3D1
              6E82301406E0523A958D32055BB5D395A94C50670BE8D0F77FB19DDAA090B8CD
              CB5DEC4BCEC5DFFC1C0801845C622072C22BEEBB07B7055D48748482408DA39A
              E29A739EF31DAE7419ABF8CA8FA5B94030ABC00ED49A3457E7026594C254F894
              F9AA2D93E9F516153EC293DCA004174268911624535993CA0ECE67BDE1969C17
              18434197DAC8F7FBB22D286DE1B70DA9CCA4B5DE6C3FACED660D39963B53F89E
              448E29487863C65B3C5F2C93F72481592EE69079BC32059F06D478A6FD41180D
              A308261CF421334A4C41042C305E82E92C7CB5C2D914320BDCBB36FC17FE4E81
              B3DA683C195A93F1E87C82EEDA60FF6E421E48A7DBF31E3D0FA6D7ED4046E4C9
              14E0BBFBC917FDB3468BD91CA1E60000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_MarkTag'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152E1EE78E53C1000000097048597300000B32
              00000B320140F55F680000000467414D410000B18F0BFC61050000007E504C54
              45FFFFFFBDBDBD6B6B6B5252526363635A5A5AB5B5B5CECECE000000C6C6C629
              29297B7B7B101010181818EFEFEFADADAD4A4A4AD6D6D68C8C8CDEDEDEF7F7F7
              E7E7E79C9C9C949494848484C6DEE77B949CADA5A5D6E7E7FFDED6FF9C84FFA5
              8CFFBDA5CED6D6CEE7EFFFAD94FF3910FF2100FF0800FFEFDE73737339393992
              28D9B30000015E4944415478DABD536D7382300C0EA5338432B40552998A73CE
              B9FDFF3FB81410AA7377EECB9EDC11F2DAA449017A342ABB866AE00AA86F1C34
              C6E672A9F33C35CE0C60FE5C7D69EA4DF5109F66858943D014999AC5CA65591E
              D9ADD12BD118A59777FDC14C9598B184C4B94B8270265E5A525795C28F1C433C
              12115695A5447868BE1189E4D0C250D52002CFF01C5222AFB904255595A261F0
              1B3AB40107621F7A27EF845967E597BD039E0B21A6E93BF6C71E780BE7632774
              860327A24C24A4465B5AACA162C9F006C7F793D011DA31038295D33DDBC08343
              77FA10EA6207BF16B292C1FF4B862DECBAFDEBBEDB455D800D10C60FDC830F72
              FBD28AC58D37C9840368136ED24F37BF1E67E1A3F9306033CDAE1AA74932592B
              529833DE4EFF0EAEF7A7BE689D4BCA5F36B0879AF77CA995C9B36CA58D8DD28A
              C65577FDA73D4F6305F52FCBE8271DA0745E3CEB45F987B71926A0D2315E0B4F
              D5021EC537E17E23E6EF0B90990000000049454E44AE426082}
          end>
      end
      item
        Name = 'QuickPopUp_CopyTag'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000002000000020080300000044A48A
              C60000000774494D4507E80309152D280319959B000000097048597300000B22
              00000B220109E14FA20000000467414D410000B18F0BFC610500000048504C54
              45FFFFFFADADAD7B7B7B7373739C9C9CBDBDBD397BB59CBDD6CECECED6D6D6E7
              E7E7EFF7FF6BA5DEC6DEEFB5D6EFDEE7F7F7F7F7C6C6C68C8C8C3973B5EFEFEF
              DEDEDE848484B5B5B5E7A19614000000E44944415478DAAD928B0E83200C454B
              910D98738888FFFFA72B2A0F1DDBC8B293901072A4975A9092458431F00A9D4B
              A5142DC196C5D404B9EFC2558BFB4550FB4E31E718AD8A301024504847712A25
              7A024043950621DE69688F1C09CEB14B59720600C44E6C7468AD3B9700E05CEC
              9F09F4DEEB5621BF0B310B5A93A18B0CC3F058852B11047A95F57ECE25FAFEBE
              9698A6E9B209E0ACC5B94588196E458631F4222CFB268319F77EF05588258270
              21729F4593205386DCA883106752A70C9155C853AD5289489B5052CD5052CD70
              163E96F84786389322CDE669C2E9071E40F6557802A8230E82E7C44AB8000000
              0049454E44AE426082}
          end>
      end>
    Left = 702
    Top = 295
  end
  object VirtualImageListMetadata: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'QuickPopUp_FillQuick'
        Name = 'QuickPopUp_FillQuick'
      end
      item
        CollectionIndex = 1
        CollectionName = 'QuickPopUp_UndoEdit'
        Name = 'QuickPopUp_UndoEdit'
      end
      item
        CollectionIndex = 2
        CollectionName = 'QuickPopUp_AddQuick'
        Name = 'QuickPopUp_AddQuick'
      end
      item
        CollectionIndex = 3
        CollectionName = 'QuickPopUp_DelQuick'
        Name = 'QuickPopUp_DelQuick'
      end
      item
        CollectionIndex = 4
        CollectionName = 'QuickPopUp_AddCustom'
        Name = 'QuickPopUp_AddCustom'
      end
      item
        CollectionIndex = 5
        CollectionName = 'QuickPopUp_DelCustom'
        Name = 'QuickPopUp_DelCustom'
      end
      item
        CollectionIndex = 6
        CollectionName = 'QuickPopUp_AddDetailsUser'
        Name = 'QuickPopUp_AddDetailsUser'
      end
      item
        CollectionIndex = 7
        CollectionName = 'QuickPopUp_MarkTag'
        Name = 'QuickPopUp_MarkTag'
      end
      item
        CollectionIndex = 8
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
    OnBalloonClick = TrayIconBalloonClick
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
end
