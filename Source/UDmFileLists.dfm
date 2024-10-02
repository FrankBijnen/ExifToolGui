object DmFileLists: TDmFileLists
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 371
  Width = 470
  object DsFileListDef: TDataSource
    DataSet = CdsFileListDef
    Left = 217
    Top = 32
  end
  object CdsFileListDef: TClientDataSet
    Aggregates = <
      item
        Visible = False
      end
      item
        Visible = False
      end>
    Params = <>
    AfterInsert = CdsFileListDefAfterInsert
    BeforeScroll = CdsFileListDefBeforeScroll
    Left = 82
    Top = 32
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
    object CdsFileListDefType: TStringField
      DisplayWidth = 10
      FieldName = 'Type'
      Size = 10
    end
    object CdsFileListDefReadMode: TIntegerField
      FieldName = 'ReadMode'
    end
    object CdsFileListDefReadModeLookup: TStringField
      FieldKind = fkLookup
      FieldName = 'ReadModeLookup'
      LookupDataSet = CdsReadMode
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'ReadMode'
      Lookup = True
    end
  end
  object DsColumnSet: TDataSource
    DataSet = CdsColumnSet
    Left = 214
    Top = 119
  end
  object CdsColumnSet: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'FileListName;Seq'
    Params = <>
    BeforeInsert = CdsColumnSetBeforeInsert
    AfterInsert = CdsColumnSetAfterInsert
    OnCalcFields = CdsColumnSetCalcFields
    Left = 82
    Top = 116
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
      OnValidate = CdsColumnSetCommandValidate
      Size = 255
    end
    object CdsColumnSetBackup: TIntegerField
      FieldName = 'Backup'
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
    object CdsColumnSetSeq: TFloatField
      FieldName = 'Seq'
    end
    object CdsColumnSetBackupLookUp: TStringField
      FieldKind = fkLookup
      FieldName = 'BackupLookUp'
      LookupDataSet = CdsBackup
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'Backup'
      Lookup = True
    end
    object CdsColumnSetOptionLookUp: TStringField
      FieldKind = fkLookup
      FieldName = 'OptionLookUp'
      LookupDataSet = CdsOption
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'Option'
      Lookup = True
    end
    object CdsColumnSetSampleValue: TStringField
      FieldKind = fkCalculated
      FieldName = 'SampleValue'
      Size = 64
      Calculated = True
    end
    object CdsColumnSetCommandLookup: TStringField
      FieldKind = fkLookup
      FieldName = 'CommandLookup'
      LookupDataSet = CdsTagNames
      LookupKeyFields = 'TagName'
      LookupResultField = 'TagName'
      KeyFields = 'Command'
      Lookup = True
    end
  end
  object CdsReadMode: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'Key'
    Params = <>
    Left = 82
    Top = 204
    object CdsReadModeKey: TIntegerField
      FieldName = 'Key'
    end
    object CdsReadModeDesc: TStringField
      FieldName = 'Desc'
    end
  end
  object CdsBackup: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'Key'
    Params = <>
    Left = 217
    Top = 203
    object CdsBackupKey: TIntegerField
      FieldName = 'Key'
    end
    object CdsBackupDesc: TStringField
      FieldName = 'Desc'
    end
  end
  object CdsOption: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'Key'
    Params = <>
    Left = 349
    Top = 205
    object CdsOptionKey: TIntegerField
      FieldName = 'Key'
    end
    object CdsOptionDesc: TStringField
      FieldName = 'Desc'
    end
  end
  object CdsTagNames: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    OnCalcFields = CdsTagNamesCalcFields
    OnFilterRecord = CdsTagNamesFilterRecord
    Left = 78
    Top = 285
    object CdsTagNamesTagName: TStringField
      FieldName = 'TagName'
      Size = 64
    end
    object CdsTagNamesSampleValue: TStringField
      FieldKind = fkCalculated
      FieldName = 'SampleValue'
      Size = 64
      Calculated = True
    end
  end
  object DsTagNames: TDataSource
    DataSet = CdsTagNames
    Left = 219
    Top = 294
  end
end
