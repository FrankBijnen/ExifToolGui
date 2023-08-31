program ExifToolGUI;

// Requires JCL to compile. https://github.com/project-jedi/jcl
// Will show a dialog when an exception occurs to copy the Stacktrace on the clipboard.

{.$DEFINE STACKTRACE}

uses

  {$IFDEF STACKTRACE}
  UnitStackTrace,
  {$ENDIF}

  Vcl.Forms,
  Main in 'Main.pas' {FMain},
  MainDef in 'MainDef.pas',
  LogWin in 'LogWin.pas' {FLogWin},
  Preferences in 'Preferences.pas' {FPreferences},
  EditFFilter in 'EditFFilter.pas' {FEditFFilter},
  EditFCol in 'EditFCol.pas' {FEditFColumn},
  QuickMngr in 'QuickMngr.pas' {FQuickManager},
  DateTimeShift in 'DateTimeShift.pas' {FDateTimeShift},
  CopyMeta in 'CopyMeta.pas' {FCopyMetadata},
  Geotag in 'Geotag.pas' {FGeotag},
  DateTimeEqual in 'DateTimeEqual.pas' {FDateTimeEqual},
  RemoveMeta in 'RemoveMeta.pas' {FRemoveMeta},
  Geomap in 'Geomap.pas',
  CopyMetaSingle in 'CopyMetaSingle.pas' {FCopyMetaSingle},
  FileDateTime in 'FileDateTime.pas' {FFileDateTime},
  UFrmPlaces in 'UFrmPlaces.pas' {FrmPlaces},
  ExifToolsGUI_Utils in 'ExifToolsGUI_Utils.pas',
  UnitFilesOnClipBoard in 'UnitFilesOnClipBoard.pas',
  ExiftoolsGui_ShellList in 'ExiftoolsGui_ShellList.pas',
  ExifToolsGUI_Thumbnails in 'ExifToolsGUI_Thumbnails.pas',
  ExifInfo in 'ExifInfo.pas',
  ExifTool in 'ExifTool.pas',
  Vcl.Themes,
  Vcl.Styles,
  UFrmStyle in 'UFrmStyle.pas' {FrmStyle},
  UFrmAbout in 'UFrmAbout.pas' {FrmAbout},
  UFrmGenerate in 'UFrmGenerate.pas' {FrmGenerate};

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ExifToolGui';
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFLogWin, FLogWin);
  Application.CreateForm(TFPreferences, FPreferences);
  Application.CreateForm(TFEditFFilter, FEditFFilter);
  Application.CreateForm(TFEditFColumn, FEditFColumn);
  Application.CreateForm(TFQuickManager, FQuickManager);
  Application.CreateForm(TFDateTimeShift, FDateTimeShift);
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
  Application.Run;
end.
