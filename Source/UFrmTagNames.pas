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
    FSearchString: string;
    FSample: string;
    UseSample: string;
    procedure GuessGroupAndTagName(var GroupName, TagName: string);
    procedure LookupSearchString;
  public
    { Public declarations }
    procedure EnableExclude(Enable: boolean);
    procedure SetSample(ASample: string);
    function PreferredFamily: string;
    procedure SetSearchString(ASearchString: string);
    function SelectedTag(AllowExclude: boolean = false): string;
  end;

var
  FrmTagNames: TFrmTagNames;

implementation

uses
  System.StrUtils,
  ExifTool, ExifToolsGUI_Utils, UnitLangResources, Main;

{$R *.dfm}

procedure TFrmTagNames.GuessGroupAndTagName(var GroupName, TagName: string);
var
  P: integer;
  ETCmd, ETOut: string;
  ETOuts: TStringList;
begin
  GroupName := '';
  TagName := FSearchString;
  P := Pos(':', FSearchString);
  if (P > 0) then
  begin
    GroupName := Copy(FSearchString, 1, P -1);
    if (UseSample = '') then
    begin
      TagName := Copy(FSearchString, P +1);
      if (TagName = '') then
        TagName := 'All';
    end;
    exit;
  end;
  if (UseSample = '') then // No, Get the Group and Tag from the sample
    exit;

  ETOuts := TStringList.Create;
  try
    ETCmd := '-s' + CRLF + '-G1' + CRLF + '-f' + CRLF + '-' + TagName + '*';
    ET.OpenExec(ETCmd, UseSample, ETOuts, false);
    if (ETOuts.Count > 0) then
    begin
      ETOut := ETOuts[0];
      GroupName   := NextField(ETOut, '[');                         // Strip Leading [
      GroupName   := NextField(ETOut, ']');                         // Group name
      TagName     := GroupName + ':' + Trim(NextField(ETOut, ':')); // Group + Tag Name
    end;
  finally
    ETOuts.Free;
  end;
end;

procedure TFrmTagNames.LookupSearchString;
var
  Index: integer;
  GroupName, TagName: string;
begin
  CmbFamily.ItemIndex := 1; // Allways 1

  GuessGroupAndTagName(GroupName, TagName);
  if (GroupName = '') then
    CmbFamilyChange(CmbFamily) // Could not guess, Present all data
  else
  begin
    CmbGroupName.Text := GroupName;
    for Index := 0 to CmbGroupName.Items.Count -1 do
    begin
      if (StartsText(GroupName, CmbGroupName.Items[Index])) then
      begin
        CmbGroupName.ItemIndex := Index;
        break;
      end;
    end;
    CmbGroupNameChange(CmbGroupName);

    CmbTagName.ItemIndex := -1;
    CmbTagName.Text := TagName;
    for Index := 0 to CmbTagName.Items.Count -1 do
    begin
      if (StartsText(TagName, CmbTagName.Items[Index])) then
      begin
        CmbTagName.ItemIndex := Index;
        break;
      end;
    end;
    CmbTagNameChange(CmbTagName);
  end;
end;

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
  CmbGroupName.EnableFullTextSearch;
  CmbGroupName.ItemIndex := 0;
  CmbGroupNameChange(CmbGroupName);
end;

procedure TFrmTagNames.CmbGroupNameChange(Sender: TObject);
begin
  FillTagsInCombo(UseSample, CmbTagName, PreferredFamily, CmbGroupName.Text);
  CmbTagName.EnableFullTextSearch;

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

  if (FSample <> '') then
    RadTagValues.ItemIndex := 0
  else
    RadTagValues.ItemIndex := 1;
  RadTagValuesClick(RadTagValues);
end;

procedure TFrmTagNames.EnableExclude(Enable: boolean);
begin
  ChkExclude.Visible := Enable;
end;

procedure TFrmTagNames.SetSample(ASample: string);
begin
  FSample := ASample;
  FSearchString := ''; // Default no searching
  EnableExclude(true); // Default visible
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
  CmbGroupName.EnableFullTextSearch;
  if (FSearchString <> '') then
    LookupSearchString
  else
  begin
    CmbGroupNameChange(Sender);
    CmbTagNameChange(Sender);
  end;
end;

procedure TFrmTagNames.SetSearchString(ASearchString: string);
begin
  FSearchString := ASearchString;
end;

function TFrmTagNames.SelectedTag(AllowExclude: boolean = false): string;
begin
  result := RemoveInvalidTags(EdTagName.Text, AllowExclude);
end;

end.

