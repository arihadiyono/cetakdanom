unit uUpdate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  URLMon, ShellApi, StdCtrls, JvExControls, JvAnimatedImage, JvGIFCtrl,
  ExtCtrls, GPanel, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Gauges;

type
  TForm1 = class(TForm)
    GPanel1: TGPanel;
    Button1: TButton;
    idHTTP: TIdHTTP;
    pb: TGauge;
    txtPenanda: TEdit;
    lblJudul: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure idHTTPWork(Sender: TObject; AWorkMode: TWorkMode;
      const AWorkCount: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure txtPenandaChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ArrParam : array[0..10] of string;
    tempURL,tempNmFileSrc,tempNmFileDst,tempDir:string;
    procedure Split(pString : String; pChar : Char; var pArResult : Array of String);
    procedure GoDownload;
  end;

var
  Form1: TForm1;
  h1, th1: cardinal;

implementation

{$R *.DFM}

procedure TForm1.Split(pString : String; pChar : Char; var pArResult : Array of String);
{ split string with mark pChar into array}
Var
  LastSplit, i : Integer;
begin
  i := 0;
  while Pos(pChar,pString) > 0 do
  begin
    LastSplit := Pos(pChar, pString);
    pArResult[i] := Copy(pString, 1, LastSplit - 1);
    pString := Copy(pString, LastSplit + 1, Length(pString));
    Inc(i);
  end;
  pArResult[i] := pString;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if ParamCount>0 then
  begin
    Split(ParamStr(1),'|',arrParam);
    //'http://10.33.41.25/sikap/|cetakDanom.exe|cetakDanom.exe|'+ExtractFilePath(ParamStr(0))

    {
    tempURL:='http://10.33.41.25/cetakdanom/';//arrParam[0];
    tempNmFileSrc:='cetakDanom.exe';//arrParam[1];
    tempNmFileDst:='cetakDanom.exe';//arrParam[2];
    tempDir:=ExtractFilePath(ParamStr(0));//arrParam[3];
    }

    tempURL:=arrParam[0];
    tempNmFileSrc:=arrParam[1];
    tempNmFileDst:=arrParam[2];
    tempDir:=ExtractFilePath(ParamStr(0));//arrParam[3];

    lblJudul.Caption:='Sedang Download Param...';
    h1:=BeginThread(nil,1024,@TForm1.GoDownload,nil,0,th1);
  end
  else
  begin
    lblJudul.Caption:='Tidak dapat menjalankan proses update';
    MessageDlg('TIDAK DAPAT MENJALANKAN PROSES DOWNLOAD', mtInformation, [mbOK], 0);
    Application.Terminate;
  end;
end;

procedure TForm1.GoDownload;
var
  MS: TMemoryStream;
begin
  try
    with Form1 do
    begin
      MS := TMemoryStream.Create;
      try
        pb.MinValue:=0;
        pb.MaxValue:=100;
        idHTTP.Get(tempURL+tempNmFileSrc, MS);
        MS.SaveToFile(tempDir+tempNmFileDst);
      finally
        MS.Free;
      end;
      txtPenanda.Text:='ok';
    end;
  except
    on E : Exception do
    begin
      Form1.txtPenanda.Text:=E.Message;
    end;
  end;
end;

procedure TForm1.idHTTPWork(Sender: TObject; AWorkMode: TWorkMode;
  const AWorkCount: Integer);
var
  ContentLength: Int64;
  Percent: Integer;
begin
  ContentLength := idHTTP.Response.ContentLength;
  if (Pos('chunked', LowerCase(idHTTP.Response.ContentEncoding)) = 0) and
     (ContentLength > 0) then
  begin
    Percent := 100*AWorkCount div ContentLength;
    pb.Progress:=percent;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TerminateThread(h1,0);
  Application.Terminate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lblJudul.Caption:='';
  Button1.Click;
end;

procedure TForm1.txtPenandaChange(Sender: TObject);
begin
  if txtPenanda.Text='ok' then
  begin
    lblJudul.Caption:='Selesai Download Param..';
    //MessageDlg('SELESAI MENGUPDATE APLIKASI', mtInformation, [mbOK], 0);
    Form1.Close;
    //ShellExecute(Handle,'open',PChar(tempDir+tempNmFileDst),'','',SW_NORMAL);
  end
  else
  begin
    lblJudul.Caption:='Gagal Proses Download Parameter';
    pb.Progress:=0;
    MessageDlg('GAGAL MELANJUTKAN PROSES DOWNLOAD -> '+txtPenanda.Text, mtError, [mbOK], 0);
    Form1.Close;
  end;
end;

end.
