unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GPanel, dxCore, dxButtons, ExtCtrls, StdCtrls,
  Nmemtable, Db, NUtility, JvGIF, JvDrawImage, JvExControls,
  JvAnimatedImage, JvGIFCtrl,ShellApi, frxClass, frxpngimage, ADODB,
  NxCollection;

type
  TFrm_Login = class(TForm)
    pnl_Login: TPanel;
    pnl_Isian: TPanel;
    txt_Passwd: TEdit;
    txt_UserId: TEdit;
    Panel1: TPanel;
    img_Login: TImage;
    btn_Exit: TdxButton;
    btn_Login: TdxButton;
    GPanel1: TGPanel;
    dslogin: TDataSource;
    ADOloginQuery: TADOQuery;
    conADOLogincon: TADOConnection;
    lblJudul: TNxLabel;
    lblVersi: TNxLabel;
    NxLabel2: TNxLabel;
    NxLabel3: TNxLabel;
    procedure img_LoginClick(Sender: TObject);
    procedure btn_LoginClick(Sender: TObject);
    procedure btn_ExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure txt_UserIdKeyPress(Sender: TObject; var Key: Char);
    procedure txt_PasswdKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    arrPetugas : array[0..10] of string;
    isLokal:boolean;
  end;

var
  Frm_Login: TFrm_Login;

implementation

uses Utama, ServerConf,UParam;

{$R *.DFM}

procedure TFrm_Login.img_LoginClick(Sender: TObject);
var
  key : char;
begin
{  key :=#13;
  Frm_Server.Dsserver.DataSet:= Frm_Main.dsconn.DataSet;
  frm_server.lstserver.KeyField:='id';
  frm_server.lstserver.DataField:='id';
  frm_server.txt_alias.ItemIndex:= 0;
  frm_server.txt_aliasKeyPress(self,key);
  Frm_Server.ShowModal;}
end;

procedure TFrm_Login.btn_LoginClick(Sender: TObject);
var
  constr : String;
  tempParam: string;
  tempDir: string;
begin
  Screen.cursor := crHourGlass;
  if txt_UserId.Text='' then
  begin
    MessageDlg('USER ID HARUS DIISI', mtInformation, [mbOK], 0);
  end
  else if txt_Passwd.Text='' then
  begin
    MessageDlg('PASSWORD HARUS DIISI', mtInformation, [mbOK], 0);
  end
  else
  begin
    ADOloginQuery.Close;
    ADOloginQuery.SQL.Text := 'exec SIKAP_LOGIN :ID_PETUGAS,:PASS_PETUGAS,:APPVERSI';
    ADOloginQuery.Parameters.ParamByName('ID_PETUGAS').Value := txt_UserId.Text;
    ADOloginQuery.Parameters.ParamByName('PASS_PETUGAS').Value := StrToMD5(txt_UserId.Text+txt_Passwd.Text);
    ADOloginQuery.Parameters.ParamByName('APPVERSI').Value := appVersi;
    ADOloginQuery.Open;

    if ADOloginQuery.Recordcount > 0 then
      begin
        if (dslogin.DataSet.Fields[0].AsString='000') then
        begin
          Frm_Main.Split(dslogin.DataSet.Fields[1].AsString,'|',arrPetugas);
          {
          0 - idpetugas
          1 - nippos
          2 - nama
          3 - nopend
          4 - kantor
          5 - jabatan = man layanan
          }
          Frm_Main.tempIdPetugas:=arrPetugas[0];
          Frm_Main.tempNippos:=arrPetugas[1];
          Frm_Main.tempNamaPetugas:=arrPetugas[2];
          Frm_Main.tempNopend:=arrPetugas[3];
          Frm_Main.tempKantor:=arrPetugas[4];
          Frm_Main.tempJabatan:=arrPetugas[5];
          Frm_Main.Show;
          Hide;
        end else
        begin
          MessageDlg(dslogin.DataSet.Fields[0].AsString+' - '+dslogin.DataSet.Fields[1].AsString, mtInformation, [mbOK], 0);
          txt_UserId.Text :='';
          txt_Passwd.Text :='';
          txt_UserId.SetFocus;
        end;
      end
      else
      begin
        MessageDlg('USER TIDAK TERDAFTAR', mtInformation, [mbOK], 0);
        txt_UserId.Text :='';
        txt_Passwd.Text :='';
        txt_UserId.SetFocus;
      end;
  end;
  Screen.Cursor := CrDefault;
  ADOloginQuery.Close;
end;

procedure TFrm_Login.btn_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrm_Login.FormShow(Sender: TObject);
begin
  isLokal:=false;
  if FileExists(ExtractFilePath(paramstr(0))+'conf.bns') then
  begin
    Frm_Main.dsconn.DataSet:= LoadFromFile(ExtractFilePath(paramstr(0))+'conf.bns');
  end else
  begin
    Frm_Main.dsconn.DataSet := CreateTable;
    frm_server.Dsserver.DataSet     := Frm_Main.dsconn.DataSet;
    frm_server.Dsserver.DataSet.Open;
    frm_server.lstserver.KeyField   :='id';
    frm_server.lstserver.DataField  :='id';
    frm_server.Position             := poDesktopCenter;
    Frm_Server.ShowModal;
  end;

  txt_userid.setfocus;
end;

procedure TFrm_Login.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    if MessageDlg('PERHATIAN ANDA AKAN PINDAH KE MODE LOKAL !' + CHR(13) +
      'MODE LOKAL HANYA UNTUK PENCETAKAN DATA !' + CHR(13) + 'LANJUT KE MODE LOKAL ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      isLokal:=true;
      //lbljudul.Caption := 'Fund Distribution [ Cetak Danom (Lokal) ]';    
    end;
end;

procedure TFrm_Login.FormCreate(Sender: TObject);
begin
  lblVersi.Caption:='Versi '+appVersi;

   //cek apakah aplikasi sudah dijalankan
  CreateMutex(nil, true, PChar(Application.Title));
  if GetLastError = Error_Already_Exists then
  begin
  //  ShowMessage('APLIKASI SUDAH DIJALANKAN');
  //  Halt;
  end;

end;

procedure TFrm_Login.txt_UserIdKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then
  begin
    txt_Passwd.SetFocus;
  end;
end;

procedure TFrm_Login.txt_PasswdKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then
  begin
    btn_Login.SetFocus;
  end;
end;

end.
