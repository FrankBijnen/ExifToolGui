program ExifToolGUI;

// Requires JCL to compile. https://github.com/project-jedi/jcl
// Will show a dialog when an exception occurs to copy the Stacktrace on the clipboard.

{.$DEFINE STACKTRACE}

uses
  {$IFDEF STACKTRACE}
  UnitStackTrace,
  {$ENDIF }
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  MainDef in 'MainDef.pas',
  ExifToolsGUI_Utils in 'ExifToolsGUI_Utils.pas',
  UnitFilesOnClipBoard in 'UnitFilesOnClipBoard.pas',
  ExifToolsGui_ShellList in 'ExifToolsGui_ShellList.pas',
  ExifToolsGui_ShellTree in 'ExifToolsGui_ShellTree.pas',
  ExifToolsGUI_MultiContextMenu in 'ExifToolsGUI_MultiContextMenu.pas',
  ExifToolsGUI_Thumbnails in 'ExifToolsGUI_Thumbnails.pas',
  ExifToolsGui_LossLess in 'ExifToolsGui_LossLess.pas',
  ExifInfo in 'ExifInfo.pas',
  ExifTool in 'ExifTool.pas',
  Main in 'Main.pas' {FMain},
  LogWin in 'LogWin.pas' {FLogWin},
  Preferences in 'Preferences.pas' {FPreferences},
  EditFFilter in 'EditFFilter.pas' {FEditFFilter},
  EditFCol in 'EditFCol.pas' {FEditFColumn},
  QuickMngr in 'QuickMngr.pas' {FQuickManager},
  UFrmGenericImport in 'UFrmGenericImport.pas' {FGenericImport},
  UFrmGenericExtract in 'UFrmGenericExtract.pas' {FGenericExtract},
  CopyMeta in 'CopyMeta.pas' {FCopyMetadata},
  Geotag in 'Geotag.pas' {FGeotag},
  DateTimeEqual in 'DateTimeEqual.pas' {FDateTimeEqual},
  RemoveMeta in 'RemoveMeta.pas' {FRemoveMeta},
  Geomap in 'Geomap.pas',
  CopyMetaSingle in 'CopyMetaSingle.pas' {FCopyMetaSingle},
  FileDateTime in 'FileDateTime.pas' {FFileDateTime},
  UFrmPlaces in 'UFrmPlaces.pas' {FrmPlaces},
  UFrmStyle in 'UFrmStyle.pas' {FrmStyle},
  UFrmAbout in 'UFrmAbout.pas' {FrmAbout},
  UFrmGenerate in 'UFrmGenerate.pas' {FrmGenerate},
  DateTimeShift in 'DateTimeShift.pas' {FDateTimeShift};

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ExifToolGui';
  Application.HintHidePause := 5000; // For old people like me!
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFLogWin, FLogWin);
  Application.CreateForm(TFPreferences, FPreferences);
  Application.CreateForm(TFEditFFilter, FEditFFilter);
  Application.CreateForm(TFEditFColumn, FEditFColumn);
  Application.CreateForm(TFQuickManager, FQuickManager);
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
  Application.CreateForm(TFrmGenerate, FrmGenerate);
  Application.CreateForm(TFDateTimeShift, FDateTimeShift);
  Application.CreateForm(TFGenericExtract, FGenericExtract);
  Application.Run;
end.
