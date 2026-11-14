unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GPanel, dxCore, dxButtons, ExtCtrls, StdCtrls, AHMTLabel,
  Nmemtable, Db, NUtility, JvGIF, JvDrawImage, JvExControls,
  JvAnimatedImage, JvGIFCtrl,ShellApi, frxClass, frxpngimage;

type
  TFrm_Login = class(TForm)
    pnl_Login: TPanel;
    pnl_Isian: TPanel;
    lbl_UserId: TAHMLabel;
    lbl_Passwd: TAHMLabel;
    txt_Passwd: TEdit;
    txt_UserId: TEdit;
    Panel1: TPanel;
    img_Login: TImage;
    lblVersi: TAHMLabel;
    btn_Exit: TdxButton;
    btn_Login: TdxButton;
    GPanel1: TGPanel;
    lblJudul: TAHMLabel;
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
  key :=#13;
  Frm_Server.Dsserver.DataSet:= Frm_Main.dsconn.DataSet;
  frm_server.lstserver.KeyField:='id';
  frm_server.lstserver.DataField:='id';
  frm_server.txt_alias.ItemIndex:= 0;
  frm_server.txt_aliasKeyPress(self,key);
  Frm_Server.ShowModal;
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
    if Frm_Main.dsconn.DataSet.Locate('id','FDPOS',[loCaseInsensitive]) then
    begin
      if isLokal then
      begin
        if ((txt_UserId.Text=Frm_Main.dsconn.DataSet.Fields[4].AsString) and
            (txt_Passwd.Text=Frm_Main.dsconn.DataSet.Fields[5].AsString)) then
        begin
          Frm_Main.Show;
          Hide;
          Frm_Main.lblHeader.Caption := 'Fund Distribution [ Cetak Danom (Lokal) ]';
          Frm_Main.btnTampilData.Click;
          Frm_Main.btnCetakBuktiTerima.Enabled:=true;
          Frm_Main.btn_Simpan.Enabled:=false;
          Frm_Main.tempIdPetugas:=txt_UserId.Text;
        end
        else
        begin
          MessageDlg('LOGIN SALAH', mtInformation, [mbOK], 0);
        end;
      end
      else
      begin
        with Frm_Main.dsconn.DataSet do
        begin
          constr:= Fields[2].AsString +':'+Fields[3].AsString+';';//server
          constr:= constr +Fields[4].AsString +';';//user
          constr:= constr +StrToMD5(Fields[4].AsString +Fields[5].AsString)+';';//pass
          //constr:= constr +StrToMD5(Fields[4].AsString +currPassword)+';';//pass
          constr:= constr +Fields[6].AsString +';';//zip
          constr:= constr +Fields[7].AsString +';';//crypt
          constr:= constr +Fields[8].AsString +';';//timeout
          constr:= constr +';;';
        end;
        a.ConStr:= constr;
        a.TypeCmd:=trim(Frm_Main.dsconn.DataSet.Fields[1].AsString); //fb, sock dll

        if not a.Connect  then
        begin
          a.DisConnect;
          MessageDlg('GAGAL KONEKSI KE SERVER', mtError, [mbOK], 0);
        end else
        begin
          Frm_Main.edtNopend.Text:='';

          IF Frm_Main.ds.DataSet<>nil then
            a.Close(Frm_Main.ds.DataSet);

          a.SQL.Clear;
          a.SQL.text:='exec LOGIN_BANSOS '+quotedstr(txt_UserId.Text)+','+quotedstr(StrToMD5(txt_UserId.Text+txt_Passwd.Text))+','+quotedstr(appVersi);

          if a.Open then
          begin
            if a.Count=0 then
            begin
              //showmessage('Tidak ada data...');
              MessageDlg('USER TIDAK TERDAFTAR', mtInformation, [mbOK], 0);
              a.close;
            end
            else
            begin
              Frm_Main.ds.DataSet:=a.Data;
              if Frm_Main.ds.DataSet.Fields[0].AsString='000' then
              begin
                MessageDlg('SUKSES LOGIN - PROGRAM DANOM', mtInformation, [mbOK], 0);
                Frm_Main.Split(Frm_Main.ds.DataSet.Fields[2].AsString,'|',arrPetugas);
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
              end
              else if Frm_Main.ds.DataSet.Fields[0].AsString='105' then
              begin
                MessageDlg(uppercase(Frm_Main.ds.DataSet.Fields[1].AsString), mtInformation, [mbOK], 0);
                if MessageDlg('AKAN MELANJUTKAN PROSES UPDATE APLIKASI ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                begin
                  tempDir:=''+ExtractFilePath(ParamStr(0))+'';
                  try
                        tempParam:=tempURL+'|'+tempNmFileSrc1+'|'+tempNmFileDst1+'|'+tempDir+'|';
                        ShellExecute(handle,'open',PChar(tempDir+'update.exe'), PChar(tempParam),'',SW_SHOWNORMAL);
                  except
                  end;

                  try
                  tempParam:=tempURL+'|'+tempNmFileSrc+'|'+tempNmFileDst+'|'+tempDir+'|';
                  ShellExecute(handle,'open',PChar(tempDir+'update.exe'), PChar(tempParam),'',SW_SHOWNORMAL);
                  except
                  end;
                  
                  Application.Terminate;
                end
                else
                begin
                  Application.Terminate;
                end;
              end
              else
              begin
                MessageDlg(uppercase(Frm_Main.ds.DataSet.Fields[1].AsString), mtInformation, [mbOK], 0);
              end;
              a.close;
            end;
          end
          else
          begin
            MessageDlg('GAGAL MENDAPATKAN DATA DARI SERVER', mtError, [mbOK], 0);
          end;
          a.DisConnect;
        end;
      end;
    end
    else
    begin
      MessageDlg('GAGAL MENGAMBIL KONFIGURASI SERVER', mtError, [mbOK], 0);
    end;
  end;
  Screen.Cursor := CrDefault;
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
      lbljudul.Caption := 'Fund Distribution [ Cetak Danom (Lokal) ]';    
    end;
end;

procedure TFrm_Login.FormCreate(Sender: TObject);
begin
  lblVersi.Caption:='Versi '+appVersi;

   //cek apakah aplikasi sudah dijalankan
  CreateMutex(nil, true, PChar(Application.Title));
  if GetLastError = Error_Already_Exists then
  begin
    ShowMessage('APLIKASI SUDAH DIJALANKAN');
    Halt;
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
