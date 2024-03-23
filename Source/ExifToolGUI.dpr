program ExifToolGUI;

{.$DEFINE STACKTRACE}
// Requires JCL to compile. https://github.com/project-jedi/jcl
// Will show a dialog when an exception occurs to copy the Stacktrace on the clipboard.

{$DEFINE LANGOVERRIDE}
// Allows for overriding the default language, without writing to the registry.
// CommandLine example: /OverrideLanguage=NLD

{$R 'ExifToolsGui_Data.res' 'ExifToolsGui_Data.rc'}

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
  MainDef in 'MainDef.pas',
  UnitLangResources in 'UnitLangResources.pas',
  ExifToolsGUI_Utils in 'ExifToolsGUI_Utils.pas',
  UnitFilesOnClipBoard in 'UnitFilesOnClipBoard.pas',
  ExifToolsGui_ValEdit in 'ExifToolsGui_ValEdit.pas',
  ExifToolsGui_ShellList in 'ExifToolsGui_ShellList.pas',
  ExifToolsGui_ShellTree in 'ExifToolsGui_ShellTree.pas',
  ExifToolsGUI_MultiContextMenu in 'ExifToolsGUI_MultiContextMenu.pas',
  ExifToolsGUI_Thumbnails in 'ExifToolsGUI_Thumbnails.pas',
  ExifToolsGui_LossLess in 'ExifToolsGui_LossLess.pas',
  ExifToolsGUI_OpenPicture in 'ExifToolsGUI_OpenPicture.pas',
  ExifToolsGui_Versions in 'ExifToolsGui_Versions.pas',
  ExifToolsGui_Data in 'ExifToolsGui_Data.pas',
  ExifToolsGUI_StringList in 'ExifToolsGUI_StringList.pas',
  ExifInfo in 'ExifInfo.pas',
  ExifTool in 'ExifTool.pas',
  ExifTool_PipeStream in 'ExifTool_PipeStream.pas',
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
  UFrmCheckVersions in 'UFrmCheckVersions.pas' {FrmCheckVersions};

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
  Application.CreateForm(TFrmPlaces, FrmPlaces);
  Application.CreateForm(TFrmStyle, FrmStyle);
  Application.CreateForm(TFrmAbout, FrmAbout);
  Application.CreateForm(TFrmCheckVersions, FrmCheckVersions);
  Application.CreateForm(TFrmGenerate, FrmGenerate);
  Application.CreateForm(TFDateTimeShift, FDateTimeShift);
  Application.CreateForm(TFGeoSearch, FGeoSearch);
  Application.CreateForm(TFGeotagFiles, FGeotagFiles);
  Application.CreateForm(TFGeoSetup, FGeoSetup);
  Application.Run;
end.
