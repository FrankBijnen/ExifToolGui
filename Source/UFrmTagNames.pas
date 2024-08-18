unit UFrmTagNames;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, UnitScaleForm, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  ExifToolsGui_ComboBox;

type
  TFrmTagNames = class(TScaleForm)
    PnlBottom: TPanel;
    BtnOk: TBitBtn;
    BtnCancel: TBitBtn;
    CmbGroupName: TComboBox;
    CmbTagName: TComboBox;
    EdTagName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RadTagValues: TRadioGroup;
    CmbFamily: TComboBox;
    Label4: TLabel;
    Bevel1: TBevel;
    ChkExclude: TCheckBox;
    procedure CmbTagNameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure CmbGroupNameChange(Sender: TObject);
    procedure CmbTagNameChange(Sender: TObject);
    procedure RadTagValuesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CmbFamilyChange(Sender: TObject);
    procedure ChkExcludeClick(Sender: TObject);
  private
    { Private declarations }
    FSample: string;
    UseSample: string;
  public
    { Public declarations }
    procedure SetSample(ASample: string);
    function PreferredFamily: string;
    function SelectedTag(AllowExclude: boolean = false): string;
  end;

var
  FrmTagNames: TFrmTagNames;

implementation

uses
  ExifToolsGUI_Utils, UnitLangResources, Main;

{$R *.dfm}

procedure TFrmTagNames.ChkExcludeClick(Sender: TObject);
var
  IsExclude: boolean;
begin
  IsExclude := Copy(EdTagName.Text, 1, 1) = '-';
  if ChkExclude.Checked <> IsExclude then
  begin
    if IsExclude then
      EdTagName.Text := Copy(EdTagName.Text, 2)
    else
      EdTagName.Text := '-' + EdTagName.Text;
  end;
end;

procedure TFrmTagNames.CmbFamilyChange(Sender: TObject);
begin
  FillGroupsInCombo(UseSample, CmbGroupName, PreferredFamily);
  CmbGroupName.ItemIndex := 0;
  CmbGroupNameChange(CmbGroupName);
end;

procedure TFrmTagNames.CmbGroupNameChange(Sender: TObject);
begin
  FillTagsInCombo(UseSample, CmbTagName, PreferredFamily, CmbGroupName.Text);
  CmbTagNameChange(Sender);
end;

procedure TFrmTagNames.CmbTagNameChange(Sender: TObject);
var
  Tag: string;
begin
  if (UseSample = '') then
    Tag := CmbGroupName.Text + ':' + CmbTagName.Text + '|'
  else
    Tag := CmbTagName.Text;
  EdTagName.Text := NextField(Tag, '|');
end;

procedure TFrmTagNames.CmbTagNameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  DrawItemTagName(Control, Index, Rect, State);
end;

procedure TFrmTagNames.FormShow(Sender: TObject);
begin
  Left := FMain.GetFormOffset.X;
  Top := FMain.GetFormOffset.Y;

  RadTagValuesClick(RadTagValues);
end;

procedure TFrmTagNames.SetSample(ASample: string);
begin
  FSample := ASample;
end;

function TFrmTagNames.PreferredFamily: string;
begin
  result := IntToStr(CmbFamily.ItemIndex);
end;

procedure TFrmTagNames.RadTagValuesClick(Sender: TObject);
begin
  ChkExclude.Checked := false;
  CmbGroupName.Items.Clear;
  CmbTagName.Items.Clear;

  case RadTagValues.ItemIndex of
    0:
      begin
        EdTagName.Text := '';
        UseSample := FSample;
        EdTagName.Enabled := false;
        CmbFamily.Enabled := true;
        CmbGroupName.Enabled := true;
        CmbTagName.Enabled := true;
        CmbGroupName.SetFocus;
      end;
    1:
      begin
        EdTagName.Text := '';
        UseSample := '';
        EdTagName.Enabled := false;
        CmbFamily.Enabled := true;
        CmbGroupName.Enabled := true;
        CmbTagName.Enabled := true;
        CmbGroupName.SetFocus;
      end;
    2:
      begin
        UseSample := '';
        EdTagName.Enabled := true;
        CmbFamily.Enabled := false;
        CmbGroupName.Enabled := false;
        CmbTagName.Enabled := false;
        EdTagName.SetFocus;
        exit;
      end;
  end;

  FillGroupsInCombo(UseSample, CmbGroupName, PreferredFamily);
  CmbGroupNameChange(Sender);
  CmbTagNameChange(Sender);
end;

function TFrmTagNames.SelectedTag(AllowExclude: boolean = false): string;
begin
  result := RemoveInvalidTags(EdTagName.Text, AllowExclude);
end;

end.

