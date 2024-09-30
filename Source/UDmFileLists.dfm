object DmFileLists: TDmFileLists
  OnCreate = DataModuleCreate
  Height = 341
  Width = 458
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
    Left = 352
    Top = 208
    object IntegerField1: TIntegerField
      FieldName = 'Key'
    end
    object StringField1: TStringField
      FieldName = 'Desc'
    end
  end
end
