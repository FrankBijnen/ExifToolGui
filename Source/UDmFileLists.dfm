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
    BeforeInsert = CdsFileListDefBeforeInsert
    AfterInsert = CdsFileListDefAfterInsert
    BeforePost = CdsFileListDefBeforePost
    AfterPost = CdsFileListDefAfterPost
    BeforeDelete = CdsFileListDefBeforeDelete
    AfterScroll = CdsFileListDefAfterScroll
    Left = 82
    Top = 28
    object CdsFileListDefId: TIntegerField
      FieldName = 'Id'
      Visible = False
    end
    object CdsFileListDefSort: TIntegerField
      FieldName = 'Sort'
    end
    object CdsFileListDefName: TWideStringField
      DisplayLabel = 'Name_'
      DisplayWidth = 25
      FieldName = 'Name'
      Size = 64
    end
    object CdsFileListDefType: TStringField
      DisplayLabel = 'Type_'
      DisplayWidth = 10
      FieldName = 'Type'
      Size = 10
    end
    object CdsFileListDefReadMode: TIntegerField
      DisplayLabel = 'ReadMode_'
      FieldName = 'ReadMode'
      OnChange = CdsFileListDefReadModeChange
    end
    object CdsFileListDefReadModeLookup: TStringField
      DisplayLabel = 'ReadModeLookup_'
      FieldKind = fkLookup
      FieldName = 'ReadModeLookup'
      LookupDataSet = CdsReadMode
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'ReadMode'
      Lookup = True
    end
    object CdsFileListDefOptions: TIntegerField
      DisplayLabel = 'Options_'
      FieldName = 'Options'
    end
  end
  object DsColumnSet: TDataSource
    DataSet = CdsColumnSet
    Left = 214
    Top = 119
  end
  object CdsColumnSet: TClientDataSet
    Aggregates = <>
    IndexFieldNames = 'Id;Seq'
    Params = <>
    AfterInsert = CdsColumnSetAfterInsert
    OnCalcFields = CdsColumnSetCalcFields
    Left = 81
    Top = 116
    object CdsColumnSetId: TIntegerField
      FieldName = 'Id'
    end
    object CdsColumnSetCaption: TWideStringField
      DisplayLabel = 'Caption_'
      DisplayWidth = 50
      FieldName = 'Caption'
      Size = 255
    end
    object CdsColumnSetCommand: TStringField
      DisplayLabel = 'Command_'
      DisplayWidth = 64
      FieldName = 'Command'
      OnValidate = CdsColumnSetCommandValidate
      Size = 255
    end
    object CdsColumnSetBackup: TIntegerField
      DisplayLabel = 'Backup_'
      FieldName = 'Backup'
    end
    object CdsColumnSetOption: TStringField
      DisplayLabel = 'Option_'
      FieldName = 'Option'
      Size = 10
    end
    object CdsColumnSetAlignR: TIntegerField
      DisplayLabel = 'AlignR_'
      FieldName = 'AlignR'
      DisplayFormat = '#'
    end
    object CdsColumnSetWidth: TStringField
      DisplayLabel = 'Width_'
      FieldName = 'Width'
    end
    object CdsColumnSetSort: TIntegerField
      DisplayLabel = 'Sort_'
      FieldName = 'Sort'
    end
    object CdsColumnSetBackupLookUp: TStringField
      DisplayLabel = 'BackupLookUp_'
      FieldKind = fkLookup
      FieldName = 'BackupLookUp'
      LookupDataSet = CdsBackup
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'Backup'
      Lookup = True
    end
    object CdsColumnSetOptionLookUp: TStringField
      DisplayLabel = 'OptionLookUp_'
      FieldKind = fkLookup
      FieldName = 'OptionLookUp'
      LookupDataSet = CdsOption
      LookupKeyFields = 'Key'
      LookupResultField = 'Desc'
      KeyFields = 'Option'
      Lookup = True
    end
    object CdsColumnSetSampleValue: TWideStringField
      DisplayLabel = 'SampleValue_'
      FieldKind = fkCalculated
      FieldName = 'SampleValue'
      Size = 64
      Calculated = True
    end
    object CdsColumnSetCommandLookup: TStringField
      DisplayLabel = 'CommandLookup_'
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
      DisplayLabel = 'TagName_'
      FieldName = 'TagName'
      Size = 64
    end
    object CdsTagNamesSampleValue: TWideStringField
      DisplayLabel = 'SampleValue_'
      FieldKind = fkCalculated
      FieldName = 'SampleValue'
      Size = 64
      Calculated = True
    end
  end
  object DsTagNames: TDataSource
    DataSet = CdsTagNames
    Left = 218
    Top = 292
  end
end
