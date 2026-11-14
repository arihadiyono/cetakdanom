unit ServerConf;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, dxCore, dxButtons, Db, NMemtable, AHMTLabel,
  GPanel,NUtility;

type
  TFrm_Server = class(TForm)
    Dsserver: TDataSource;
    pnl_Login: TPanel;
    pnl_Isian: TPanel;
    GPanel1: TGPanel;
    lblJudul: TAHMLabel;
    Panel1: TPanel;
    lstserver: TDBLookupListBox;
    bt_save: TdxButton;
    bt_edit: TdxButton;
    bt_delete: TdxButton;
    bt_close: TdxButton;
    txt_timeout: TEdit;
    Label9: TLabel;
    Label2: TLabel;
    txt_host: TEdit;
    cbo_type: TComboBox;
    Label6: TLabel;
    Label1: TLabel;
    txt_Alias: TComboBox;
    bt_connect: TdxButton;
    Label3: TLabel;
    txt_user: TEdit;
    txt_pass: TEdit;
    Label4: TLabel;
    procedure bt_closeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure bt_saveClick(Sender: TObject);
    procedure lstserverClick(Sender: TObject);
    procedure bt_editClick(Sender: TObject);
    procedure bt_deleteClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure txt_aliasKeyPress(Sender: TObject; var Key: Char);
    procedure bt_connectClick(Sender: TObject);
    procedure txt_timeoutKeyPress(Sender: TObject; var Key: Char);
    procedure txt_aliasChange(Sender: TObject);
    procedure txt_AliasClick(Sender: TObject);
  private
    { Private declarations }
    Procedure disablebutton;
    Procedure cleartext;
  public
    { Public declarations }
  end;

var
  Frm_Server: TFrm_Server;

implementation

uses Utama;

{$R *.DFM}
Procedure TFrm_Server.disablebutton;
begin
  bt_save.Enabled:=false;
  bt_edit.Enabled:=false;
  bt_delete.Enabled:=false;
  bt_connect.Enabled:=false;
end;

Procedure TFrm_Server.cleartext;
begin
  txt_alias.Text:='';
  cbo_type.ItemIndex:=0;
  txt_host.text :='';
  txt_user.text :='';
  txt_pass.text :='';
  txt_timeout.Text:='20000';
  txt_alias.SetFocus;
end;

procedure TFrm_Server.bt_closeClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Server.FormActivate(Sender: TObject);
begin
  txt_alias.SetFocus;
end;

procedure TFrm_Server.bt_saveClick(Sender: TObject);
var
  Pds : Pointer;
begin
  with Dsserver.DataSet do
  begin
     Insert;
     FieldByName('id').AsString:=txt_alias.text;
     FieldByName('connType').AsString:=cbo_type.text;
     FieldByName('server').AsString:=txt_host.text;
     FieldByName('database').AsString:='';//txt_database.text;
     FieldByName('user').AsString:=txt_user.Text;
     FieldByName('password').AsString:=txt_pass.Text;
     FieldByName('ziptype').AsInteger:=3;//cbo_zip.ItemIndex;
     FieldByName('crypttype').AsInteger:=1;//cbo_crypt.ItemIndex;
     FieldByName('timeout').AsString:=txt_timeout.text;
     post;
  end;
  Pds := Dsserver.DataSet;
  SaveToFile(Pds,ExtractFilePath(paramstr(0))+'conf.bns');
  disablebutton;
  cleartext;
end;

procedure TFrm_Server.lstserverClick(Sender: TObject);
begin
  with Dsserver.DataSet do
  begin
     bt_save.Enabled:=false;
     //txt_alias.text:=FieldByName('id').AsString;
     if FieldByName('id').AsString='SKS' then
        txt_alias.ItemIndex:=0
     else if FieldByName('id').AsString='FDPOS' then
        txt_alias.ItemIndex:=1;
     //cbo_type.text:=FieldByName('connType').AsString;
     cbo_type.ItemIndex:=cbo_type.Items.IndexOf(FieldByName('connType').AsString);
     txt_host.text:=FieldByName('server').AsString;
     txt_timeout.text:=FieldByName('timeout').AsString;
     txt_user.text:=FieldByName('user').AsString;
     txt_pass.text:=FieldByName('password').AsString;
     bt_edit.Enabled:=true;
     bt_delete.Enabled:=true;
     bt_connect.Enabled:=true;
  end;
end;

procedure TFrm_Server.bt_editClick(Sender: TObject);
var
  Pds : Pointer;
begin
  with Dsserver.DataSet do
  begin
     Edit;
     FieldByName('id').AsString:=txt_alias.text;
     FieldByName('connType').AsString:=cbo_type.text;
     FieldByName('server').AsString:=txt_host.text;
     FieldByName('database').AsString:='';//txt_database.text;
     FieldByName('user').AsString:=txt_user.Text;
     FieldByName('password').AsString:=txt_pass.Text;
     FieldByName('ziptype').AsInteger:=3;//cbo_zip.ItemIndex;
     FieldByName('crypttype').AsInteger:=1;//cbo_crypt.ItemIndex;
     FieldByName('timeout').AsString:=txt_timeout.text;
     post;
  end;
  Pds := Dsserver.DataSet;
  SaveToFile(Pds,ExtractFilePath(paramstr(0))+'conf.bns');
  disablebutton;
  cleartext;
end;

procedure TFrm_Server.bt_deleteClick(Sender: TObject);
var
  Pds : Pointer;
begin
  Dsserver.DataSet.Delete;
  Pds := Dsserver.DataSet;
  SaveToFile(Pds,ExtractFilePath(paramstr(0))+'conf.bns');
  disablebutton;
  cleartext;
end;

procedure TFrm_Server.FormKeyPress(Sender: TObject; var Key: Char);
begin
 if key = #13 then
  begin
    PostMessage(handle, WM_NEXTDLGCTL,0,0);
  end;
end;

procedure TFrm_Server.txt_aliasKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then            
  begin
    if Dsserver.DataSet.Locate('id',txt_alias.text,[loCaseInsensitive]) then
    begin
       lstserverClick(Self);
       bt_connect.Enabled:=true;
    end else
    begin
      disablebutton;
      bt_save.Enabled:=true;
    end;
  end;
end;

procedure TFrm_Server.bt_connectClick(Sender: TObject);
var
  constr : String;
begin
  Screen.cursor := crHourGlass;
  with Frm_Main.dsconn.DataSet do
  begin
    constr:= Fields[2].AsString +':'+Fields[3].AsString+';';//server
    constr:= constr +Fields[4].AsString +';';//user
    constr:= constr +StrToMD5(Fields[4].AsString +Fields[5].AsString)+';';//pass
    constr:= constr +Fields[6].AsString +';';//zip
    constr:= constr +Fields[7].AsString +';';//crypt
    constr:= constr +Fields[8].AsString +';';//timeout
    constr:= constr +';;';
  end;
  a.ConStr:= constr;
  a.TypeCmd:=trim(Frm_Main.dsconn.DataSet.Fields[1].AsString); //fb, sock dll

  if not a.Connect  then
  begin
    MessageDlg('Gagal terhubung ke server', mtError, [mbOK], 0);  
    a.DisConnect;
  end else
  begin
    MessageDlg('Sukses terhubung ke server', mtInformation, [mbOK], 0);
    a.DisConnect;
  end;
  Screen.Cursor := CrDefault;
end;

procedure TFrm_Server.txt_timeoutKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9'])  then
    key := #0;
end;

procedure TFrm_Server.txt_aliasChange(Sender: TObject);
begin
  if Dsserver.DataSet.Locate('id',txt_alias.text,[loCaseInsensitive]) then
  begin
     lstserverClick(Self);
     bt_connect.Enabled:=true;
  end else
  begin
    disablebutton;
    bt_save.Enabled:=true;
  end;
end;

procedure TFrm_Server.txt_AliasClick(Sender: TObject);
begin
  if Dsserver.DataSet.Locate('id',txt_alias.text,[loCaseInsensitive]) then
  begin
     lstserverClick(Self);
     bt_connect.Enabled:=true;
  end else
  begin
    disablebutton;
    bt_save.Enabled:=true;
  end;
end;

end.
