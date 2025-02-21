program ExifToolGUI;

{.$DEFINE STACKTRACE}
// Requires JCL to compile. https://github.com/project-jedi/jcl
// Will show a dialog when an exception occurs to copy the Stacktrace on the clipboard.

{$DEFINE LANGOVERRIDE}
// Allows for overriding the default language, without writing to the registry.
// CommandLine example: /OverrideLanguage=NLD

{$R 'ExifToolsGui_Files.res' 'Resources\ExifToolsGui_Files.rc'}

uses
  {$IFDEF STACKTRACE}
  UnitStackTrace,
  {$ENDIF }
  {$IFDEF LANGOVERRIDE}
  UnitLangOverride,
  {$ENDIF }
  UnitSingleApp,
  UnitDpiAwareness,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  MidasLib,
  MainDef in 'MainDef.pas',
  ExifToolsGui_ResourceStrings in 'ExifToolsGui_ResourceStrings.pas',
  UnitLangResources in 'UnitLangResources.pas',
  ExifToolsGUI_Utils in 'ExifToolsGUI_Utils.pas',
  UnitFilesOnClipBoard in 'UnitFilesOnClipBoard.pas',
  UnitColumnDefs in 'UnitColumnDefs.pas',
  ExifToolsGui_AutoComplete in 'ExifToolsGui_AutoComplete.pas',
  ExifToolsGui_ValEdit in 'ExifToolsGui_ValEdit.pas',
  ExifToolsGui_ThreadPool in 'ExifToolsGui_ThreadPool.pas',
  ExifToolsGui_ShellList in 'ExifToolsGui_ShellList.pas',
  ExifToolsGui_FileListColumns in 'ExifToolsGui_FileListColumns.pas',
  ExifToolsGui_ShellTree in 'ExifToolsGui_ShellTree.pas',
  ExifToolsGUI_MultiContextMenu in 'ExifToolsGUI_MultiContextMenu.pas',
  ExifToolsGUI_Thumbnails in 'ExifToolsGUI_Thumbnails.pas',
  ExifToolsGui_LossLess in 'ExifToolsGui_LossLess.pas',
  ExifToolsGUI_OpenPicture in 'ExifToolsGUI_OpenPicture.pas',
  ExifToolsGui_Versions in 'ExifToolsGui_Versions.pas',
  ExifToolsGUI_StringList in 'ExifToolsGUI_StringList.pas',
  ExifToolsGui_ComboBox in 'ExifToolsGui_ComboBox.pas',
  ExifToolsGui_Listview in 'ExifToolsGui_Listview.pas',
  ExifToolsGui_AutoEdit in 'ExifToolsGui_AutoEdit.pas',
  ExifInfo in 'ExifInfo.pas',
  ExifTool in 'ExifTool.pas',
  ExifTool_PipeStream in 'ExifTool_PipeStream.pas',
  UDmFileLists in 'UDmFileLists.pas' {DmFileLists: TDataModule},
  Main in 'Main.pas' {FMain},
  LogWin in 'LogWin.pas' {FLogWin},
  Preferences in 'Preferences.pas' {FPreferences},
  EditFFilter in 'EditFFilter.pas' {FEditFFilter},
  EditFCol in 'EditFCol.pas' {FEditFColumn},
  QuickMngr in 'QuickMngr.pas' {FQuickManager},
  UFrmLossLessRotate in 'UFrmLossLessRotate.pas' {FLossLessRotate},
  UFrmGenericExtract in 'UFrmGenericExtract.pas' {FGenericExtract},
  UFrmGenericImport in 'UFrmGenericImport.pas' {FGenericImport},
  CopyMeta in 'CopyMeta.pas' {FCopyMetadata},
  Geotag in 'Geotag.pas' {FGeotag},
  Geomap in 'Geomap.pas',
  DateTimeShift in 'DateTimeShift.pas' {FDateTimeShift},
  DateTimeEqual in 'DateTimeEqual.pas' {FDateTimeEqual},
  RemoveMeta in 'RemoveMeta.pas' {FRemoveMeta},
  CopyMetaSingle in 'CopyMetaSingle.pas' {FCopyMetaSingle},
  FileDateTime in 'FileDateTime.pas' {FFileDateTime},
  UFrmPlaces in 'UFrmPlaces.pas' {FrmPlaces},
  UFrmGeoSearch in 'UFrmGeoSearch.pas' {FGeoSearch},
  UFrmGeoTagFiles in 'UFrmGeoTagFiles.pas' {FGeotagFiles},
  UFrmGeoSetup in 'UFrmGeoSetup.pas' {FGeoSetup},
  UFrmStyle in 'UFrmStyle.pas' {FrmStyle},
  UFrmAbout in 'UFrmAbout.pas' {FrmAbout},
  UFrmGenerate in 'UFrmGenerate.pas' {FrmGenerate},
  UFrmCheckVersions in 'UFrmCheckVersions.pas' {FrmCheckVersions},
  UFrmTagNames in 'UFrmTagNames.pas' {FrmTagNames},
  UFrmPredefinedTags in 'UFrmPredefinedTags.pas' {FrmPredefinedTags},
  UFrmDiff in 'UFrmDiff.pas' {FrmDiff};

{$R *.res}

begin

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

  Application.Title := 'ExifToolGui';

  CheckOverride;

  if ReadSingleInstanceApp and
     not FSharedMem.IsOwner then
  begin
    FSharedMem.ActivateCurrentWindow;
    halt;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TDmFileLists, DmFileLists);
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFLogWin, FLogWin);
  Application.CreateForm(TFPreferences, FPreferences);
  Application.CreateForm(TFEditFFilter, FEditFFilter);
  Application.CreateForm(TFEditFColumn, FEditFColumn);
  Application.CreateForm(TFQuickManager, FQuickManager);
  Application.CreateForm(TFLossLessRotate, FLossLessRotate);
  Application.CreateForm(TFGenericExtract, FGenericExtract);
  Application.CreateForm(TFGenericImport, FGenericImport);
  Application.CreateForm(TFCopyMetadata, FCopyMetadata);
  Application.CreateForm(TFGeotag, FGeotag);
  Application.CreateForm(TFDateTimeEqual, FDateTimeEqual);
  Application.CreateForm(TFRemoveMeta, FRemoveMeta);
  Application.CreateForm(TFCopyMetaSingle, FCopyMetaSingle);
  Application.CreateForm(TFFileDateTime, FFileDateTime);
  Application.CreateForm(TFrmDiff, FrmDiff);
  Application.CreateForm(TFrmStyle, FrmStyle);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.CreateForm(TFrmCheckVersions, FrmCheckVersions);
  Application.CreateForm(TFrmGenerate, FrmGenerate);
  Application.CreateForm(TFDateTimeShift, FDateTimeShift);
  Application.CreateForm(TFGeoSearch, FGeoSearch);
  Application.CreateForm(TFGeotagFiles, FGeotagFiles);
  Application.CreateForm(TFGeoSetup, FGeoSetup);
  Application.CreateForm(TFrmTagNames, FrmTagNames);
  Application.CreateForm(TFrmPredefinedTags, FrmPredefinedTags);
  Application.CreateForm(TFrmPlaces, FrmPlaces);
  Application.Run;
end.
