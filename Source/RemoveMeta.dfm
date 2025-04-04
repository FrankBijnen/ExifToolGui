object FRemoveMeta: TFRemoveMeta
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Remove metadata'
  ClientHeight = 461
  ClientWidth = 456
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 442
    Width = 456
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 430
    ExplicitWidth = 448
  end
  object AdvPanel1: TPanel
    Left = 0
    Top = 0
    Width = 339
    Height = 442
    Align = alClient
    DoubleBuffered = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 0
    object LvTagNames: TListView
      AlignWithMargins = True
      Left = 11
      Top = 73
      Width = 324
      Height = 365
      Margins.Left = 10
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Caption = 'Tag name'
          Width = 320
        end>
      GridLines = True
      HideSelection = False
      PopupMenu = PopupMenuLv
      SmallImages = VirtualImageList
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = LvTagNamesCustomDrawItem
      OnItemChecked = LvTagNamesItemChecked
      ExplicitWidth = 318
      ExplicitHeight = 353
    end
    object PnlButtons: TPanel
      AlignWithMargins = True
      Left = 11
      Top = 42
      Width = 324
      Height = 25
      Margins.Left = 10
      Align = alTop
      TabOrder = 0
      object SpbPredefined: TSpeedButton
        Left = 228
        Top = 1
        Width = 95
        Height = 23
        Align = alRight
        Caption = 'Predefined'
        OnClick = SpbPredefinedClick
        ExplicitLeft = 252
        ExplicitTop = 2
      end
      object CmbPredefined: TComboBox
        Left = 1
        Top = 1
        Width = 227
        Height = 22
        Align = alClient
        TabOrder = 0
        Text = 'CmbPredefined'
        OnChange = CmbPredefinedChange
      end
    end
    object PnlRemoveAll: TPanel
      Left = 1
      Top = 1
      Width = 337
      Height = 38
      Align = alTop
      TabOrder = 2
      ExplicitWidth = 331
      object ChkRemoveAll: TCheckBox
        AlignWithMargins = True
        Left = 11
        Top = 4
        Width = 322
        Height = 30
        Margins.Left = 10
        Align = alClient
        Caption = '-remove ALL metadata'
        TabOrder = 0
        OnClick = ChkRemoveAllClick
        ExplicitWidth = 316
      end
    end
  end
  object PnlRight: TPanel
    Left = 339
    Top = 0
    Width = 117
    Height = 442
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      117
      442)
    object Label1: TLabel
      Left = 4
      Top = 367
      Width = 110
      Height = 25
      Alignment = taCenter
      Anchors = [akRight, akBottom]
      AutoSize = False
      Caption = 'Label1'
      WordWrap = True
      ExplicitLeft = 2
      ExplicitTop = 373
    end
    object BtnCancel: TButton
      Left = 4
      Top = 12
      Width = 110
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
      ExplicitLeft = 2
    end
    object BtnPreview: TButton
      Left = 4
      Top = 331
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Preview'
      Enabled = False
      TabOrder = 1
      OnClick = BtnPreviewClick
      ExplicitLeft = 2
      ExplicitTop = 319
    end
    object BtnExecute: TButton
      Left = 4
      Top = 404
      Width = 110
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Execute'
      Default = True
      Enabled = False
      TabOrder = 2
      OnClick = BtnExecuteClick
      ExplicitLeft = 2
      ExplicitTop = 392
    end
  end
  object ImageCollection: TImageCollection
    Images = <
      item
        Name = 'LvExcludeTag Unsel'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000004600000046080300000046F012
              B60000000774494D4507E8071A0E1903B3D08D0C000000097048597300000AF0
              00000AF00142AC34980000000467414D410000B18F0BFC61050000000F504C54
              45FFFFFFF7F7F7080000EFEFEFC0C0C08A2501F5000000534944415478DAEDD4
              410A0020080551B5EE7FE62282DC052914316FE56A16115F040000ECA8BB2D20
              A7B23AFDACA7464767E6B832428F65E4C70C4F4CE652C65C26B437F3F795D8FA
              B9518E5454570700805C0DA6F0125B2690D80F0000000049454E44AE426082}
          end>
      end
      item
        Name = 'LvExcludeTag'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000004600000046080300000046F012
              B60000000774494D4507E8071A0E1F07E2E7EE93000000097048597300000AF0
              00000AF00142AC34980000000467414D410000B18F0BFC610500000300504C54
              45FFFFFFF7F7F73131312929292121213939394242424A4A4A5A5A5AEFEFEF08
              08080800001800001000000000001818181010106300008400008C00007B0000
              6B0000730000CE0808D61818CE2121CE1818D61010D60808DE0000DE0808E710
              10EF1818EF3131EF2929EF2121EF1010EF0000CE0000D60000C60000BD0000B5
              0000AD0000A500009C00009400005A0000290000DE4A4ADE6363DE5252DE5A5A
              E75252E74242E74A4ADE4242E73939E73131E72929F71010F70808FF0000F700
              00310000E76B6BE76363E75A5AF72121F71818FF1010FF0808E7737339000021
              0000DE6B6B4A0000E77B7BCE2929E78484C61010D63939D64242D64A4ADE3939
              DE3131E72121C60808DE2929E70000420000DE21215200000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000000000000000000000C0C0
              C09323547C000000554944415478DAEDD4310A00200846619D3B40F7BF691142
              6E810A45BC6F727A43C42F0200004ED4DD2DA1A6B23BF3EC51ABA396095756E8
              B18CFC98E189C95CCA349749ED8DFDBE9E5B3F37CA998AEAEE0000506B007DA8
              68BAED7F2A370000000049454E44AE426082}
          end>
      end
      item
        Name = 'LvIncludeTag Unsel'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000004600000046080300000046F012
              B60000000774494D4507E8071A0E192D6F0680C3000000097048597300000AF0
              00000AF00142AC34980000000467414D410000B18F0BFC61050000000C504C54
              45FFFFFFF7F7F7080000EFEFEFF9D2B0200000000174524E530040E6D8660000
              00A84944415478DAED98E10AC0200884A7BEFF3BAF416CB4B92877B10C0FFAD9
              871E7552DBE64F9497497C138662E3A46D52CA047A500E0E0AD36D34A61A19DA
              D44F98259B026168AA6AA229E79851B145C5164D0A866BE382BF60B8527E874E
              C316C380BC990B131607C60DE625DDF2E993D6F4AB871FB566B13E5F882E4ED3
              64481801CC29D3A341C5F4BF861C60BA255355E30113DE2C8B110C86404D817E
              4C50FF373051F315DA01A6CE18150E1DA3610000000049454E44AE426082}
          end>
      end
      item
        Name = 'LvIncludeTag'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D494844520000004600000046080300000046F012
              B60000000774494D4507E8071A0E151895000BEC000000097048597300000AF0
              00000AF00142AC34980000000467414D410000B18F0BFC610500000300504C54
              45FFFFFFF7F7F742424218181810101021212129292939393931313152525221
              0000290000310000180000100000080000080808000000630000D60000C60000
              BD0000CE0000AD0000B500009C00009400008400007B0000EFEFEF6B6B6BF700
              00FF0000EF00004A4A4ADE0000F70808FF1010FF0808A50000F710108C0000E7
              0000F71818EF0808730000EF1010EF21216B0000F72121EF1818420000390000
              EF29295A5A5A5200004A0000EF3131CE0808D61818CE2121CE1818D61010D608
              08DE0808E710105A0000DE4A4ADE6363DE5252DE5A5AE75252E74242E74A4ADE
              4242E73939E73131E72929E76B6BE76363E75A5AE77373DE6B6BE77B7BCE2929
              E78484C61010D63939D64242D64A4ADE3939DE3131E72121C60808DE2929DE21
              21D62929DE1010DE1818DE737363636300000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000000000000000FF
              004BBE289D0000000174524E530040E6D866000000AB4944415478DAED98D109
              C0200C44CD049920FB8FD95A90165B2BC69ED4480EFCF4911C7A4143B0274AAB
              4B7C1386D2C789DBB65C5DA007E5E0A0306AA331D5C8D0A67EC22CD914084353
              55E34D19C78C8A2DCAB69454C0706D5CF0170C57CA57E8346C310CC89BB9306E
              B163CC605ED22D9D3E694DBF7AF8516B1697E70BD1C5699A0C11238039D5F568
              2862F4AF210318B564AA6A2C60DC9B653182C110A829D08F09EAFF06266ABE42
              3B2DA8D14BD1E0765A0000000049454E44AE426082}
          end>
      end>
    Left = 394
    Top = 77
  end
  object VirtualImageList: TVirtualImageList
    DisabledOpacity = 127
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'LvExcludeTag Unsel'
        Name = 'LvExcludeTag Unsel'
      end
      item
        CollectionIndex = 1
        CollectionName = 'LvExcludeTag'
        Name = 'LvExcludeTag'
      end
      item
        CollectionIndex = 2
        CollectionName = 'LvIncludeTag Unsel'
        Name = 'LvIncludeTag Unsel'
      end
      item
        CollectionIndex = 3
        CollectionName = 'LvIncludeTag'
        Name = 'LvIncludeTag'
      end>
    ImageCollection = ImageCollection
    Left = 398
    Top = 144
  end
  object PopupMenuLv: TPopupMenu
    OnPopup = PopupMenuLvPopup
    Left = 387
    Top = 242
    object Groupview1: TMenuItem
      AutoCheck = True
      Caption = 'Group view'
      OnClick = Groupview1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Checkgroup1: TMenuItem
      Caption = 'Check group'
      OnClick = CheckGroup1Click
    end
    object Uncheckgroup1: TMenuItem
      Tag = 1
      Caption = 'Uncheck group'
      OnClick = CheckGroup1Click
    end
  end
end
