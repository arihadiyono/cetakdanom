{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{
--------------------------------------------------------------------------------
Program        : Cetak Danom
Author         : Lukim
Email          :
Create date    : 25 Des 2023
Description    : Aplikasi untuk cetak daftar nominatif

                 Pola Kerja:
                 - Ambil data per kabupaten
                 - Split jadi beberapa file berdasarkan kelurahan
                 - Load data per kelurahan
                 - Pilihan preview dan cetak

--------------------------------------------------------------------------------
}

unit Utama;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  Grids, Db,ComCtrls,  StdCtrls, ExtCtrls,Graphics,
  NCONN,NCrypt, Nzip,NUtility, Kbmmemtable,
  dxCore, dxButtons, DBGrids, bvDBGrid,
  Nmemtable, frxClass, frxDBSet,frxExportPDF, frxBarcode, frxpngimage,
  AHMTLabel, GPanel, Gauges, FileCtrl, JvGIF,
  JvExControls, JvAnimatedImage, JvGIFCtrl, ShellApi;

const
  InputBoxMessage = WM_USER + 200;

type
  TFrm_Main = class(TForm)
    ds: TDataSource;
    dsconn: TDataSource;
    frxBarCodeObject1: TfrxBarCodeObject;
    frxReport: TfrxReport;
    frxDataset: TfrxDBDataset;
    pnl_Judul: TGPanel;
    lblHeader: TAHMLabel;
    pnl_Login: TPanel;
    lblVersion: TLabel;
    pnlAmbilData: TPanel;
    P_top: TPanel;
    Label19: TLabel;
    lbl_status: TLabel;
    bt_connect: TdxButton;
    pnlProsesAmbil: TPanel;
    Panel3: TPanel;
    pnl_TombolMenu: TPanel;
    btn_Simpan: TdxButton;
    pnlTampilData: TPanel;
    Memo1: TMemo;
    pnl_BukaFile: TPanel;
    pnl_ListFile: TPanel;
    listFile: TListBox;
    pnl_DaftarFile: TPanel;
    Label8: TLabel;
    pnl_FooterTampilData: TPanel;
    Label3: TLabel;
    lbl_row: TLabel;
    Label9: TLabel;
    lblDaerah: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Panel1: TPanel;
    btnCetak: TdxButton;
    ds_load: TDataSource;
    memKelurahan: TMemo;
    LS: TMemo;
    Panel5: TPanel;
    btnPreview: TdxButton;
    Memo2: TMemo;
    griddata: TbvDBGrid;
    Label2: TLabel;
    cboJenis: TComboBox;
    Label6: TLabel;
    edtNopend: TEdit;
    pnl_TombolBukaFile: TPanel;
    Label16: TLabel;
    Image2: TImage;
    Label4: TLabel;
    btnAmbilDaftarFile: TdxButton;
    cboJenisAmbilData: TComboBox;
    Label7: TLabel;
    lblJumlahFile: TLabel;
    Label5: TLabel;
    lbl_time: TLabel;
    Label18: TLabel;
    GroupBox1: TGroupBox;
    memLogProses: TMemo;
    Panel4: TPanel;
    btn_cetakrekap: TdxButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    cboKelurahan: TComboBox;
    cboKecamatan: TComboBox;
    cboKabupaten: TComboBox;
    bt_open: TdxButton;
    Label12: TLabel;
    lbl_JmlKel: TLabel;
    pb: TGauge;
    pnlProgress: TPanel;
    gifSedangProses: TJvGIFAnimator;
    lblSedangProses: TLabel;
    frPDF: TfrxPDFExport;
    btnTampilData: TdxButton;
    btnCetakBuktiTerima: TdxButton;
    pnlBuktiTerima: TPanel;
    Memo3: TMemo;
    Panel6: TPanel;
    Panel7: TPanel;
    listFile_bt: TListBox;
    Panel8: TPanel;
    Label15: TLabel;
    Panel9: TPanel;
    Label17: TLabel;
    Image1: TImage;
    Label20: TLabel;
    Label21: TLabel;
    lblJumlahFileBT: TLabel;
    btnAmbilDaftarFileBT: TdxButton;
    cboJenisAmbilDataBT: TComboBox;
    Panel10: TPanel;
    Label23: TLabel;
    lbl_rowBT: TLabel;
    Label25: TLabel;
    lblDaerahBT: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Panel11: TPanel;
    btnCetakBT: TdxButton;
    btnPreviewBT: TdxButton;
    Panel12: TPanel;
    Memo4: TMemo;
    griddata_bt: TbvDBGrid;
    frxReportBT: TfrxReport;
    cboTahap: TComboBox;
    Label22: TLabel;
    Label24: TLabel;
    cbb_project: TComboBox;
    Label26: TLabel;
    cbb_sort: TComboBox;
    cbb_headerdanom: TComboBox;
    cbb_pilSP: TComboBox;
    procedure bt_connectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Sync_openEnter(Sender: TObject);
    procedure Sync_openExit(Sender: TObject);
    procedure sync_execEnter(Sender: TObject);
    procedure sync_execExit(Sender: TObject);
    procedure rdataEnter(Sender: TObject);
    procedure rdataExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnTampilDataClick(Sender: TObject);
    procedure btnCetakClick(Sender: TObject);
    function  lpad(str:string;nlen:integer;pos:char):string;
    function  rpad(str:string;nlen:integer;pos:char):string;
    function  replicate(c:char;nlen:integer):string;
    procedure FileSearch(const PathName, FileName :string ; opt: string);
    procedure Split(pString : String; pChar : Char; var pArResult : Array of String);
    procedure btn_SimpanClick(Sender: TObject);
    procedure btnAmbilDaftarFileClick(Sender: TObject);
    procedure listFileDblClick(Sender: TObject);
    procedure cboKabupatenChange(Sender: TObject);
    procedure btn_ExitClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure cboJenisChange(Sender: TObject);
    procedure cboKecamatanChange(Sender: TObject);
    procedure cboKelurahanChange(Sender: TObject);
    procedure bt_openClick(Sender: TObject);
    procedure btnAmbilDaftarFileBTClick(Sender: TObject);
    procedure btnCetakBuktiTerimaClick(Sender: TObject);
    procedure listFile_btDblClick(Sender: TObject);
    procedure btnPreviewBTClick(Sender: TObject);
    procedure btnCetakBTClick(Sender: TObject);
    procedure cboTahapChange(Sender: TObject);
    procedure cbb_projectChange(Sender: TObject);

  private
    { Private declarations }
    procedure ResetForm;
    procedure GetData;

  public
    { Public declarations }
    ArrPropinsi : array[0..1] of string;
    ArrKabupaten : array[0..3] of string;
    ArrKecamatan : array[0..3] of string;
    ArrKelurahan : array[0..3] of string;
    ArrKelurahanSplit : array[0..3] of string;
    ArrNamaFile: array[0..1] of string;
    teksVersi: string;
    dataDir: string;
    rootDir: string;
    databayarDir: string;
    dataDir2: string;
    tempIdPetugas,tempNippos,tempNamaPetugas,
    tempNopend,tempKantor,tempJabatan: string;
    fileTerpilih: string;
    isMandiri:boolean;

    idproject: string;
    
  end;

  nstr=string[100];
  TMem=Tkbmmemtable;

var
  Frm_Main: TFrm_Main;
  a : TNCmd;
  h1, th1: cardinal;

implementation

uses ServerConf,UParam,ULogin;
// the calls here are assumed 32 bit compilation, so, adjust accordingly

{$R *.DFM}

function CreateDanomTable:TMem;
var
  DBconf : Tmem;
  ConfFmt : TFmt;
begin
  DBconf := Tmem.Create(nil);
  ConfFmt := TFmt.Create(nil);
  DBconf.DefaultFormat := ConfFmt;
  with DBconf.FieldDefs do
  begin
    Clear;

    {
    0 kps
    1 nama
    2 alamat
    3 bsu
    4 id_kel
    5 kel
    6 id_kec
    7 kec
    8 id_kab
    9 kab
    0 id_prop
    1 prop
    2 id_kprk
    3 kprk
    4 id_kantor
    5 kantor
    6 id_status
    7 opt
    }

    Add('ID_PELANGGAN',ftString,20,true);
    Add('PELANGGAN',ftString,50,true);
    Add('ALAMAT',ftString,100,true);
    Add('AMOUNT',ftInteger,0,true);
    Add('ID_KELURAHAN',ftString,7,true);
    Add('KELURAHAN',ftString,100,true);
    Add('ID_KECAMATAN',ftString,7,true);
    Add('KECAMATAN',ftString,100,true);
    Add('ID_KABUPATEN',ftString,7,true);
    Add('KABUPATEN',ftString,100,true);
    Add('ID_PROPINSI',ftString,7,true);
    Add('PROPINSI',ftString,100,true);
    Add('ID_KANTOR',ftString,7,true);
    Add('KANTOR',ftString,100,true);
    Add('ID_KPRK',ftString,7,true);
    Add('KPRK',ftString,100,true);
    Add('ID_STATUS',ftString,3,true);
    Add('OPT',ftString,200,true);
    Add('MSBAYAR',ftString,200,true);
  end;
  Dbconf.IndexDefs.Add('ID_PELANGGANx_fd','ID_PELANGGAN',[ixUnique]);
  DbConf.CreateTable;
  Result:=DbConf;
end;

function LoadFromDanomFile(value : String):TDataset;
var
  ds :Tmem;
  mem, mem1 : TmemoryStream;
begin
  mem := TmemoryStream.create;
  mem1 := TmemoryStream.create;
  mem.LoadFromFile(Value);
  with TNCipher.Create do
  begin
    //Key:=vkey;
    GetDeCryptStream(mem,mem1);
    Free;
  end;
  mem.Clear;
  with TNZip.Create do
  begin
    GetUnZipStream(mem1,mem);
    Free;
  end;
  ds := CreateDanomTable;
  ds.LoadFromStream(mem);
  Result := ds;
  FreeAndNil(mem);
  FreeAndNil(mem1);
end;

function ToFloat(fl : Double):String;
begin
  if fl=0 then
    Result:='0'
  else
    Result:=formatfloat('#,##',fl);
end;

function SubStr(str:String;len:Integer):String;
begin
  Result:=Copy(str,1,len);
end;


procedure TFrm_Main.Split(pString : String; pChar : Char; var pArResult : Array of String);
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

function TFrm_Main.lpad(str:string;nlen:integer;pos:char):string;
var
  i : Integer;
begin
  for i:=length(str) to nlen-1 do
    str := pos+str;
  result:=str;
end;

function TFrm_Main.rpad(str:string;nlen:integer;pos:char):string;
var
  i : Integer;
begin
  for i:=length(str) to nlen-1 do
    str := str+pos;
  result:=str;
end;

function TFrm_Main.replicate(c:char;nlen:integer):string;
var
  i:integer;
begin
  result:='';
  for i:=1 to nlen do
    result:=result+c;
end;

procedure TFrm_Main.FileSearch(const PathName, FileName : string; opt: string);
var
  Rec  : TSearchRec;
  Path : string;
  i,len: integer;
begin
  if opt='1' then
  begin
    Path := IncludeTrailingBackslash(PathName);
    if FindFirst(Path + FileName, faAnyFile - faDirectory, Rec) = 0 then
      try
        repeat
          listFile.Items.Add(Rec.Name);
        until FindNext(Rec) <> 0;
      finally
      FindClose(Rec);
    end;
    if listFile.Items.Count=0 then
    begin
      listFile.Clear;
    end else
    begin
      with listFile do
      begin
        len := listFile.Width;
        for i := 0 to items.count -1 do
        begin
          len := canvas.textwidth(items[i]);
        end;
        //set listbox's horizontal scrollbar width
        Perform(LB_SETHORIZONTALEXTENT,len+100,0);
      end;
    end;
  end
  else
  begin
    Path := IncludeTrailingBackslash(PathName);
    if FindFirst(Path + FileName, faAnyFile - faDirectory, Rec) = 0 then
      try
        repeat
          listFile_bt.Items.Add(Rec.Name);
        until FindNext(Rec) <> 0;
      finally
      FindClose(Rec);
    end;
    if listFile_bt.Items.Count=0 then
    begin
      listFile_bt.Clear;
    end else
    begin
      with listFile_bt do
      begin
        len := listFile_bt.Width;
        for i := 0 to items.count -1 do
        begin
          len := canvas.textwidth(items[i]);
        end;
        //set listbox's horizontal scrollbar width
        Perform(LB_SETHORIZONTALEXTENT,len+100,0);
      end;
    end;
  end;
end; //procedure FileSearch

procedure TFrm_Main.ResetForm;
begin
  lbl_status.Caption:='NOK';
  lbl_status.Font.Color:= clRed;
  btn_CetakRekap.Enabled:=false;
  bt_open.Enabled:=False;
  cboJenis.Enabled:=false;
  cboTahap.Enabled:=false;
  cbb_project.Enabled:=false;
  cboKabupaten.Enabled:=false;
  cboKecamatan.Enabled:=false;
  cboKelurahan.Enabled:=false;

  cbb_sort.Enabled := false;
  cbb_sort.ItemIndex := -1;

  cboJenis.ItemIndex:=-1;
  cboTahap.ItemIndex:=-1;
  cbb_project.ItemIndex:=-1;
  cboKabupaten.Items.Clear;
  cboKecamatan.Items.Clear;
  cboKelurahan.Items.Clear;
  lbl_jmlKel.Caption:='0';
  lblSedangProses.Caption:=' ';
end;

procedure TFrm_Main.bt_connectClick(Sender: TObject);
var
  C:Cardinal;
  constr : String;
begin
  Screen.cursor := crHourGlass;
  if dsconn.DataSet.Locate('id','SKS',[loCaseInsensitive]) then
  begin
    if bt_connect.Caption='&CONNECT' then
    begin
      C := GetTickCount;
      with dsconn.DataSet do
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
      a.TypeCmd:=trim(dsconn.DataSet.Fields[1].AsString); //fb, sock dll

      if not a.Connect  then
      begin
        a.DisConnect;
        lbl_time.caption:=inttostr(GetTickCount-C);
        ResetForm;
      end else
      begin
        bt_connect.Caption:='&DISCONNECT';
        lbl_time.caption:=inttostr(GetTickCount-C);
        lbl_status.Caption:='OK';
        lbl_status.Font.Color:= clTeal;
        btn_CetakRekap.Enabled:=false;
        cboJenis.Enabled:=true;
        cboJenis.ItemIndex:=-1;
        cboKabupaten.Items.Clear;
        cboKecamatan.Items.Clear;
        cboKelurahan.Items.Clear;
      end;
    end
    else
    begin
      bt_connect.Caption:='&CONNECT';
      C:=GetTickCount;
      a.DisConnect;
      lbl_time.caption:=inttostr(GetTickCount-C);
      ResetForm;
    end;
  end
  else
  begin
    MessageDlg('Gagal mengambil konfigurasi server', mtError, [mbOK], 0);
  end;

  Screen.Cursor := CrDefault;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
begin
  DateSeparator:='/';
  ShortdateFormat:='mm/dd/yyyy';
  a:=TNCmd.Create;

  //parameter versi
  teksVersi:='V'+appVersi;
  Frm_Main.Caption:=appTitle+' [ Versi '+appVersi+' - '+appDate+' ]';
  Application.Title:=appTitle+' [ Versi '+appVersi+' - '+appDate+' ]';
  lblVersion.Caption:='';

  rootDir:=ExtractFilePath(ParamStr(0))+'data\';
  dataDir:='data\';
  dataDir2:='data\sudah_cetak\';
  dataBayarDir:=ExtractFilePath(ParamStr(0))+'data\sudah_cetak\';
end;

procedure TFrm_Main.FormShow(Sender: TObject);
begin
  if FileExists(ExtractFilePath(paramstr(0))+'conf.bns') then
  begin
    dsconn.DataSet:= LoadFromFile(ExtractFilePath(paramstr(0))+'conf.bns');
  end else
  begin
    dsconn.DataSet := CreateTable;
    frm_server.Dsserver.DataSet     := dsconn.DataSet;
    frm_server.Dsserver.DataSet.Open;
    frm_server.lstserver.KeyField   :='id';
    frm_server.lstserver.DataField  :='id';
    frm_server.Position             := poDesktopCenter;
    Frm_Server.ShowModal;
  end;
  pnlTampilData.Visible:=false;
  pnlAmbilData.Align:=alClient;
  pnlAmbilData.Visible:=true;
  btn_Simpan.Click;
  edtnopend.Text:=tempNopend;
  isMandiri:=false;
  cboJenis.ItemIndex:=-1;
  cboKabupaten.ItemIndex:=0;
end;

procedure TFrm_Main.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    PostMessage(handle, WM_NEXTDLGCTL,0,0);
  end;
end;

procedure TFrm_Main.Sync_openEnter(Sender: TObject);
begin
  KeyPreview:=false;
end;

procedure TFrm_Main.Sync_openExit(Sender: TObject);
begin
  KeyPreview:=True;
end;

procedure TFrm_Main.sync_execEnter(Sender: TObject);
begin
  KeyPreview:=false;
end;

procedure TFrm_Main.sync_execExit(Sender: TObject);
begin
  KeyPreview:=True;
end;

procedure TFrm_Main.rdataEnter(Sender: TObject);
begin
  KeyPreview:=false;
end;

procedure TFrm_Main.rdataExit(Sender: TObject);
begin
  KeyPreview:=true;
end;

procedure TFrm_Main.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  P,Q : Pointer;
  H : HWND;
begin
  H := FindWindow(nil,'CetakDataDanom');
  try
     if H <> 0 then PostMessage(H, WM_CLOSE,0,0);
  except
  end;

  if MessageDlg('YAKIN AKAN LOGOUT APLIKASI ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    TerminateThread(h1,0);

    P := dsconn.DataSet;
    if P <> nil then
    begin
      Tmem(P).Close;
      Q:=Tmem(P).DefaultFormat;
      FreeAndNil(Q);
      FreeandNil(P);
    end;
    a.Destroy;
    Application.Terminate;
  end
  else
    CanClose := False;

end;

procedure TFrm_Main.btnTampilDataClick(Sender: TObject);
begin
  //kelola panel

  //kelola tombol menu
{  if Frm_Login.isLokal then
    btn_Simpan.Enabled:=false
  else
    btn_Simpan.Enabled:=true;}
  btn_Simpan.Enabled:=false;
  //btnCetakBuktiTerima.Enabled:=true;
 // btnTampilData.Enabled:=false;

  ShellExecute(Handle,'open', 'cetak.exe', nil, Pchar(GetCurrentDir), SW_SHOWNORMAL) ;

  pnlAmbilData.Visible:=true;
  pnlAmbilData.Align:=alClient;
  pnlBuktiTerima.Visible:=false;
//  pnlTampilData.Align:=alClient;
//  pnlTampilData.Visible:=true;

  {listFile.Items.Clear;
  griddata.Visible:=false;
  cboJenisAmbilData.ItemIndex:=0;
  lblDaerah.Caption:='';
  lbl_Row.Caption:='0';
  lblJumlahFile.Caption:='0';
  fileTerpilih:='';
  btnPreview.Enabled:=false;
  btnCetak.Enabled:=false;}
end;

procedure TFrm_Main.btnCetakClick(Sender: TObject);
var
  Component, Component1:TfrxComponent;
begin
  Screen.Cursor:=crHourGlass;
  ds_load.DataSet.First;
  //AWAL TAMBAHAN
  with frxReport do
  begin
    if isMandiri then
    begin
      Component := frxReport.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR NOMINATIF MANDIRI E-CASH');
      Component1 := frxReport.FindObject('Memo1');
      TfrxMemoView(Component1).Memo.Text := uppercase('');
    End
    Else
    begin
      Component := frxReport.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR NOMINATIF REKENING GIRO SKS');
      Component1 := frxReport.FindObject('Memo1');
      TfrxMemoView(Component1).Memo.Text := 'DANOM INI BERFUNGSI SEBAGAI GIR-1 DAN ATAU GIR-3 DAN ATAU GIR-6';
    End;
  end;
  //AKHIR TAMBAHAN

  frxReport.PrepareReport;
  //frxReport.ShowPreparedReport;
  frxReport.Print;

  if not DirectoryExists(dataBayarDir) then
  begin
    if not CreateDir(dataBayarDir) then
    begin
      MessageDlg('ERROR PENANGANAN FOLDER DATA [GAGAL MEMINDAHKAN DATA]', mtError, [mbOK], 0);
    end
    else
    begin
      MoveFile(pchar(rootDir+fileTerpilih),pchar(dataBayarDir+fileTerpilih));
    end;
  end
  else
  begin
    MoveFile(pchar(rootDir+fileTerpilih),pchar(dataBayarDir+fileTerpilih));
  end;

  btnAmbilDaftarFile.Click;

  Screen.Cursor:=crDefault;
end;

procedure TFrm_Main.btn_SimpanClick(Sender: TObject);
begin
  pnlTampilData.Visible:=false;
  pnlBuktiTerima.Visible:=false;
  pnlAmbilData.Align:=alClient;
  pnlAmbilData.Visible:=true;
  btnTampilData.Enabled:=true;
  btnCetakBuktiTerima.Enabled:=true;
  btn_Simpan.Enabled:=false;
  if bt_connect.Caption='&DISCONNECT' then
    bt_connect.Click;
  memLogProses.Lines.Clear;
  pb.Progress:=pb.MinValue;
end;

procedure TFrm_Main.btnAmbilDaftarFileClick(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  lblJumlahFile.Caption:='0';
  fileTerpilih:='';
  btnPreview.Enabled:=false;
  btnCetak.Enabled:=false;

  if not DirectoryExists(rootDir) then
  begin
    MessageDlg('FOLDER DATA TIDAK DITEMUKAN', mtError, [mbOK], 0);
  end
  else
  begin
    listFile.Clear;
    griddata.Visible:=false;
    lblDaerah.Caption:='';
    lbl_Row.Caption:='0';
    if cboJenisAmbilData.ItemIndex=1 then
    begin
      //ambil danom mandiri
      FileSearch(rootDir, '*.DNM','1');
      isMandiri:=True;
    end
    else
    begin
      //ambil danom pos
      FileSearch(rootDir, '*.DNP','1');
      isMandiri:=False;
    end;
    lblJumlahFile.Caption:=IntToStr(listFile.Items.Count);
    if listFile.Items.Count=0 then
    begin
      MessageDlg('TIDAK ADA FILE YANG AKAN DIPROSES', mtInformation, [mbOK], 0);
    end;
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.listFileDblClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
begin
  Screen.cursor := crHourGlass;
  SelectedFile := listFile.Items.Strings[listFile.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;
  ds_load.DataSet := LoadFromDanomFile(dataDir+SelectedFile);
  //split(arrNamaFile[0],'_',arrDaerah);
  lbl_row.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata.Visible:=TRUE;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerah.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreview.Enabled:=true;
  btnCetak.Enabled:=true;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.cboKabupatenChange(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  split(cboKabupaten.text,'|',arrKabupaten);

  cboKecamatan.Enabled:=true;
  cboKecamatan.Items.Clear;
  cboKelurahan.Enabled:=false;
  cboKelurahan.Items.Clear;
  bt_open.Enabled:=false;
  memKelurahan.Lines.Clear;
  lbl_jmlKel.Caption:='0';
  lblSedangProses.Caption:=' ';

  IF ds.DataSet<>nil then
    a.Close(ds.DataSet);

  a.SQL.Clear;

  if isMandiri then
  begin
    a.SQL.text:='exec SIKAP_GET_KECAMATAN '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end
  else
  begin
    a.SQL.text:='exec SIKAP_GET_KECAMATAN '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end;

  if a.Open then
  begin
    if a.Count=0 then
    begin
       //showmessage('Tidak ada data...');
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
       a.close;
    end
    else
    begin
      ds.DataSet:=a.Data;
      ds.DataSet.First;
      cboKecamatan.Items.Add('---[ SEMUA KECAMATAN ]---');
      while not ds.DataSet.Eof do
      begin
          cboKecamatan.Items.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
      end;
      a.close;
      cboKecamatan.ItemIndex:=-1;
    end;
  end
  else
  begin
    bt_connect.Caption:='&CONNECT';
    MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
    ResetForm;
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.btn_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrm_Main.btnPreviewClick(Sender: TObject);
var
  Component,Component1:TfrxComponent;
begin
  frPDF.FileName:=listFile.Items.Strings[listFile.ItemIndex];
  ds_load.DataSet.First;
   //AWAL TAMBAHAN
  with frxReport do
  begin
    if isMandiri then
    begin
      Component := frxReport.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR NOMINATIF MANDIRI E-CASH');
      Component1 := frxReport.FindObject('Memo1');
      TfrxMemoView(Component1).Memo.Text := '';
    End
    Else
    begin
      Component := frxReport.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR NOMINATIF REKENING GIRO SKS');
      Component1 := frxReport.FindObject('Memo1');
      TfrxMemoView(Component1).Memo.Text := 'DANOM INI BERFUNGSI SEBAGAI GIR-1 DAN ATAU GIR-3 DAN ATAU GIR-6';
    End;
  end;
  //AKHIR TAMBAHAN

  frxReport.ShowReport;
end;

procedure TFrm_Main.cboJenisChange(Sender: TObject);
begin
  if cboJenis.ItemIndex = 0 then //SKS POS BANTUAN PUSAT
  begin
      {cbb_project.ItemIndex := -1;
      cbb_project.Enabled := false;
      cboTahap.Enabled:=true;
      cboTahap.SetFocus;

      Screen.cursor := crHourGlass;

      cboTahap.Items.Clear;
      IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

      a.SQL.Clear;

      a.SQL.text:='exec SIKAP_GET_TAHAP';

      if a.Open then
      begin
        if a.Count=0 then
        begin
           //showmessage('Tidak ada data...');
           MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
           a.close;
        end
        else
        begin
          ds.DataSet:=a.Data;
          ds.DataSet.First;
          while not ds.DataSet.Eof do
          begin
              cboTahap.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
              ds.DataSet.Next;
          end;

          a.close;
          cboTahap.ItemIndex:= 0;
        end;
      end
      else
      begin
        bt_connect.Caption:='&CONNECT';
        MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
        ResetForm;
      end;
      //SKS POS LAMA}

      cbb_project.ItemIndex := -1;
      cbb_headerdanom.ItemIndex := -1;
      cbb_pilSP.ItemIndex := -1;

      cbb_project.Enabled:=true;
      cbb_project.SetFocus;

      Screen.cursor := crHourGlass;

      cbb_project.Items.Clear;
      cbb_headerdanom.Items.Clear;
      cbb_pilSP.Items.Clear;

      IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

      a.SQL.Clear;

      a.SQL.text:='exec BANSOS_GETPROJECT_NAS';

      if a.Open then
      begin
        if a.Count=0 then
        begin
           //showmessage('Tidak ada data...');
           MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
           a.close;
        end
        else
        begin
          ds.DataSet:=a.Data;
          ds.DataSet.First;
          while not ds.DataSet.Eof do
          begin
              cbb_project.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
              cbb_headerdanom.Items.Add(ds.DataSet.Fields[2].AsString);
              cbb_pilSP.Items.Add(ds.DataSet.Fields[3].AsString);
              ds.DataSet.Next;
          end;
          a.close;
          cbb_project.ItemIndex:= 0;
        end;
      end
      else
      begin
        bt_connect.Caption:='&CONNECT';
        MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
        ResetForm;
      end;
  end else
  {11/11/2020 select id project institusi/lembaga ItemIndex=2}
  if cboJenis.ItemIndex = 2 then
  begin
      cbb_project.ItemIndex := -1;
      cbb_headerdanom.ItemIndex := -1;
      cbb_pilSP.ItemIndex := -1;
      //cbb_project.Enabled := False;
      cbb_project.Enabled:=true;
      cbb_project.SetFocus;

      Screen.cursor := crHourGlass;

      cbb_project.Items.Clear;
      cbb_headerdanom.Items.Clear;
      cbb_pilSP.Items.Clear;

      IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

      a.SQL.Clear;

      a.SQL.text:='exec BANSOS_GETPROJECT_INS';

      if a.Open then
      begin
        if a.Count=0 then
        begin
           //showmessage('Tidak ada data...');
           MessageDlg('DATA TIDAK ADA 2', mtInformation, [mbOK], 0);
           a.close;
        end
        else
        begin
          ds.DataSet:=a.Data;
          ds.DataSet.First;
          while not ds.DataSet.Eof do
          begin
              cbb_project.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
              cbb_headerdanom.Items.Add(ds.DataSet.Fields[2].AsString);
              cbb_pilSP.Items.Add(ds.DataSet.Fields[3].AsString);
              ds.DataSet.Next;
          end;
          a.close;
          cbb_project.ItemIndex:= 0;
        end;
      end
      else
      begin
        bt_connect.Caption:='&CONNECT';
        MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
        ResetForm;
      end;
  end else
  {11/11/2020}
  begin
      cbb_project.Enabled := True;

      cbb_project.SetFocus;

      Screen.cursor := crHourGlass;
      cbb_project.Items.Clear;
      cbb_headerdanom.Items.Clear;
      cbb_pilSP.Items.Clear;
      IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

      a.SQL.Clear;

      a.SQL.text:='exec BANSOS_GETPROJECT_KOTAKAB';

      if a.Open then
      begin
        if a.Count=0 then
        begin
           //showmessage('Tidak ada data...');
           MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
           a.close;
        end
        else
        begin
          ds.DataSet:=a.Data;
          ds.DataSet.First;
          while not ds.DataSet.Eof do
          begin
              cbb_project.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
              cbb_headerdanom.Items.Add(ds.DataSet.Fields[2].AsString);
              cbb_pilSP.Items.Add(ds.DataSet.Fields[3].AsString);
              ds.DataSet.Next;
          end;
          a.close;
          cbb_project.ItemIndex:= -1;
        end;
      end
      else
      begin
        bt_connect.Caption:='&CONNECT';
        MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
        ResetForm;
      end;
  end;


  {btn_cetakrekap.Enabled:=true;
  cboKabupaten.Enabled:=true;
  cboKabupaten.Items.Clear;
  cboKecamatan.Enabled:=false;
  cboKecamatan.Items.Clear;
  cboKelurahan.Enabled:=false;
  cboKelurahan.Items.Clear;
  bt_open.Enabled:=false;
  memKelurahan.Lines.Clear;
  lbl_jmlKel.Caption:='0';
  lblSedangProses.Caption:=' ';

  //ShowMessage(IntToStr(cboJenis.ItemIndex));
  IF ds.DataSet<>nil then
  a.Close(ds.DataSet);

  a.SQL.Clear;

  if cboJenis.ItemIndex=1 then
  begin
    isMandiri:=true;
    a.SQL.text:='exec SIKAP_GET_KABUPATEN '+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end
  else
  begin
    isMandiri:=false;
    a.SQL.text:='exec SIKAP_GET_KABUPATEN '+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end;

  if a.Open then
  begin
    if a.Count=0 then
    begin
       //showmessage('Tidak ada data...');
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
       a.close;
    end
    else
    begin
      ds.DataSet:=a.Data;
      ds.DataSet.First;
      while not ds.DataSet.Eof do
      begin
          cboKabupaten.Items.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
      end;
      a.close;
      cboKabupaten.ItemIndex:=-1;
    end;
  end
  else
  begin
    bt_connect.Caption:='&CONNECT';
    MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
    ResetForm;
  end;}
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.cboKecamatanChange(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  cbb_sort.Enabled := true;
  cbb_sort.ItemIndex := 0;

  if cboKecamatan.ItemIndex=0 then
  begin
    cboKelurahan.Enabled:=false;
    cboKelurahan.Items.Clear;
    bt_open.Enabled:=true;
    memKelurahan.Lines.Clear;
    lbl_jmlKel.Caption:='0';
    lblSedangProses.Caption:=' ';

    IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

    a.SQL.Clear;

    if isMandiri then
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKAB '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end
    else
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKAB '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end;

    if a.Open then
    begin
      if a.Count=0 then
      begin
         //showmessage('Tidak ada data...');
         MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
         a.close;
      end
      else
      begin
        ds.DataSet:=a.Data;
        ds.DataSet.First;
        while not ds.DataSet.Eof do
        begin
          memKelurahan.Lines.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
        end;
        lbl_jmlKel.Caption:=IntToStr(memKelurahan.Lines.Count);
        a.close;

      end;
    end
    else
    begin
      bt_connect.Caption:='&CONNECT';
      MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
      ResetForm;
    end;
  end
  else
  begin
    split(cboKecamatan.text,'|',arrKecamatan);

    cboKelurahan.Enabled:=true;
    cboKelurahan.Items.Clear;
    bt_open.Enabled:=false;
    memKelurahan.Lines.Clear;
    lbl_jmlKel.Caption:='0';
    lblSedangProses.Caption:=' ';    

    IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

    a.SQL.Clear;

    if isMandiri then
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end
    else
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end;

    if a.Open then
    begin
      if a.Count=0 then
      begin
         //showmessage('Tidak ada data...');
         MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
         a.close;
      end
      else
      begin
        ds.DataSet:=a.Data;
        ds.DataSet.First;
        cboKelurahan.Items.Add('---[ SEMUA KELURAHAN ]---');
        while not ds.DataSet.Eof do
        begin
            Split(ds.DataSet.Fields[0].AsString,'|',ArrKelurahanSplit);
            cboKelurahan.Items.Add(ArrKelurahanSplit[0]+'|'+ArrKelurahanSplit[1]);
            //cboKelurahan.Items.Add(ds.DataSet.Fields[0].AsString);
            ds.DataSet.Next;
        end;
        a.close;
        cboKelurahan.ItemIndex:=-1;
      end;
    end
    else
    begin
      bt_connect.Caption:='&CONNECT';
      MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
      ResetForm;
    end;
  end;

  Screen.cursor := crDefault;
end;


procedure TFrm_Main.cboKelurahanChange(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  if cboKelurahan.ItemIndex=0 then
  begin
    memKelurahan.Lines.Clear;
    bt_open.Enabled:=true;
    lbl_jmlKel.Caption:='0';
    lblSedangProses.Caption:=' ';    

    IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

    a.SQL.Clear;

    if isMandiri then
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end
    else
    begin
      a.SQL.text:='exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
    end;

    if a.Open then
    begin
      if a.Count=0 then
      begin
         //showmessage('Tidak ada data...');
         MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
         a.close;
      end
      else
      begin
        ds.DataSet:=a.Data;
        ds.DataSet.First;
        while not ds.DataSet.Eof do
        begin
          memKelurahan.Lines.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
        end;
        lbl_jmlKel.Caption:=IntToStr(memKelurahan.Lines.Count);
        a.close;
      end;
    end
    else
    begin
      bt_connect.Caption:='&CONNECT';
      MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
      ResetForm;
    end;
  end
  else
  begin
    lbl_jmlKel.Caption:='1';
    split(cboKelurahan.text,'|',arrKelurahan);
    memKelurahan.Lines.Clear;
    memKelurahan.Lines.Add(cboKelurahan.Text+'|'+arrKecamatan[1]);
    bt_open.Enabled:=true;
  end;
  Screen.cursor := crDefault;
end;

Procedure TFrm_main.GetData;
var
  Pds : Pointer;
  i : integer;
  fileDanom: string;
  jmlKelurahan,jmlSukses,jmlGagal,jmlKosong: integer;

begin
  Screen.Cursor:=crHourGlass;
  jmlSukses:=0;
  jmlGagal:=0;
  jmlKosong:=0;

  with Frm_main do
  begin
    jmlKelurahan:= memKelurahan.Lines.Count;
    pb.MaxValue:= memKelurahan.Lines.Count;
    pb.Progress:=0;
    memLogProses.Lines.Clear;
    memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'Mulai proses ambil data Danom dari '+IntToStr(jmlKelurahan)+' kelurahan');
    bt_open.Enabled:=false;
    gifSedangProses.Animate:=true;
    pnl_Login.Enabled:=false;
    //lblSedangProses.Caption:='Sedang proses 1 dari '+IntToStr(jmlKelurahan)+' kelurahan';

    for i:=0 to memKelurahan.Lines.Count-1 do
    begin
      //Application.ProcessMessages;
      lblSedangProses.Caption:='Sedang'+#13+ 'Proses '+IntToStr(i+1)+' Dari '+IntToStr(jmlKelurahan)+' Kelurahan';
      split(memKelurahan.Lines.Strings[i],'|',arrKelurahan);
      IF ds.DataSet<>nil then
        a.Close(ds.DataSet);

      a.SQL.Clear;

      if isMandiri then
      begin
        a.SQL.text:='SIKAP_GET_DAFTARNOMINATIF_KOTAKAB_V4 '+quotedstr(arrKelurahan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex))+','+quotedstr(copy(cboTahap.Text,1,6))+','+quotedstr(cbb_sort.Text)+','+quotedstr(copy(cbb_project.Text,1,4));
      end
      else
      begin
        {11/11/2020 ItemIndex 2=Instansi 0=Sks Pos/Pusat}
        if cboJenis.ItemIndex= 2 then
        begin
             a.SQL.text:='SIKAP_GET_DAFTARNOMINATIF_INSTANSI_V4 '+quotedstr(arrKelurahan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex))+','+quotedstr(copy(cboTahap.Text,1,6))+','+quotedstr(cbb_sort.Text)+','+quotedstr(copy(cbb_project.Text,1,4));
        end
        else if cboJenis.ItemIndex= 0 then
        begin
             a.SQL.text:='SIKAP_GET_DAFTARNOMINATIF_NAS_V4 '+quotedstr(arrKelurahan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex))+','+quotedstr(copy(cboTahap.Text,1,6))+','+quotedstr(cbb_sort.Text)+','+quotedstr(copy(cbb_project.Text,1,4));
        end else
            //a.SQL.text:='SIKAP_GET_DAFTARNOMINATIF_tes '+quotedstr(arrKelurahan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex))+','+quotedstr(copy(cboTahap.Text,1,6))+','+quotedstr(cbb_sort.Text);
            a.SQL.text:='SIKAP_GET_DAFTARNOMINATIF_KOTAKAB '+quotedstr(arrKelurahan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex))+','+quotedstr(copy(cboTahap.Text,1,6))+','+quotedstr(cbb_sort.Text)+','+quotedstr(copy(cbb_project.Text,1,4));
      end;

      if a.Open then
      begin
        if a.Count=0 then
        begin
          //MessageDlg('Tidak ada data', mtInformation, [mbOK], 0);
          a.close;
          jmlKosong:=jmlKosong+1;
          memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'TIDAK ADA DATA - KELURAHAN -> '+arrKelurahan[1]+ ', KECAMATAN : '+arrKecamatan[1]);
        end else
        begin
          ds.DataSet:=a.Data;
          Pds := Ds.DataSet;
          if isMandiri then
          begin
            if copy(cbb_project.Text,1,2)='PD' then
                    fileDanom:=dataDir2+uppercase(copy(cbb_project.Text,1,4))+'_'+uppercase(TRIM(cbb_pilSP.Text))+'_'+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+IntToStr(ds.DataSet.RecordCount)+'_'+Trim(cbb_headerdanom.Text)+'.POS'
            else
                    fileDanom:=dataDir+uppercase(copy(cbb_project.Text,1,4))+'_'+uppercase(TRIM(cbb_pilSP.Text))+'_'+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+IntToStr(ds.DataSet.RecordCount)+'_'+Trim(cbb_headerdanom.Text)+'.POS';
          end
          else
          begin
             {//Handle untuk SKS POS Jika idproject kosong diisi PU1
             if (cbb_project.Text='') then
             begin
                cbb_project.Text:='PU1' ;
             end;
             }
            //nama file lama
            //fileDanom:=dataDir+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+edtNopend.text+'_'+IntToStr(ds.DataSet.RecordCount)+'.POS';
            //nama file baru tambah idproject
            if copy(cbb_project.Text,1,2)='PD' then
                fileDanom:=dataDir2+uppercase(copy(cbb_project.Text,1,4))+'_'+uppercase(TRIM(cbb_pilSP.Text))+'_'+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+edtNopend.text+'_'+IntToStr(ds.DataSet.RecordCount)+'_'+Trim(cbb_headerdanom.Text)+'.POS'
            else
                fileDanom:=dataDir+uppercase(copy(cbb_project.Text,1,4))+'_'+uppercase(TRIM(cbb_pilSP.Text))+'_'+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+edtNopend.text+'_'+IntToStr(ds.DataSet.RecordCount)+'_'+Trim(cbb_headerdanom.Text)+'.POS';
          end;
          SaveToFile(Pds,fileDanom);
          a.close;
          jmlSukses:=jmlSukses+1;
          memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'SUKSES GENERATE FILE -> KELURAHAN : '+arrKelurahan[1]+', '+arrKelurahan[2]);
        end;
      end
      else
      begin
        ResetForm;
        //MessageDlg('GAGAL MENGAMBIL DATA', mtError, [mbOK], 0);
        jmlGagal:=jmlGagal+1;
        memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'GAGAL AMBIL DATA -> KELURAHAN : '+arrKelurahan[1]+', '+arrKelurahan[2]);
      end;
      pb.Progress:=i+1;
    end;
    memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'Selesai proses ambil data Danom '+IntToStr(jmlKelurahan)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Sukses generate file : '+IntToStr(jmlSukses)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Gagal generate file   : '+IntToStr(jmlGagal)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Data tidak ada          : '+IntToStr(jmlKosong)+' kelurahan');
    lblSedangProses.Caption:='Selesai'+#13+ 'Proses '+IntToStr(jmlKelurahan)+' Kelurahan';
    gifSedangProses.Animate:=false;
    pnl_Login.Enabled:=true;
  end;
  Screen.cursor := crDefault;
end;


procedure TFrm_Main.bt_openClick(Sender: TObject);
var statParam, nama_param, logo_param, tempParam, tempDir :string;
begin
nama_param := LowerCase('param_'+copy(cbb_project.Text,1,3)+'_'+copy(cbb_project.Text,4,1)+'.pos');
logo_param := LowerCase('logo_'+copy(cbb_project.Text,1,3)+'_'+copy(cbb_project.Text,4,1));
if FileExists(nama_param) then
  begin
    if DeleteFile(nama_param) then
    begin
        Sleep(2000);
        tempDir := ''+ExtractFilePath(ParamStr(0))+'';
        tempParam := tempURLParam+'|'+nama_param+'|'+nama_param+'|'+tempDir+'+';
        ShellExecute(Handle,'open',PChar(tempDir+'download.exe'),PChar(tempParam),'',SW_SHOWNORMAL);
        MessageDlg('Selesai Update Param, Klik OK untuk Melanjutkan',mtInformation, [mbOK], 0);
        statParam:='1';
    end else
        statParam:='0';
  end else
  begin
    tempDir := ''+ExtractFilePath(ParamStr(0))+'';
    tempParam := tempURLParam+'|'+nama_param+'|'+nama_param+'|'+tempDir+'+';
    ShellExecute(Handle,'open',PChar(tempDir+'download.exe'),PChar(tempParam),'',SW_SHOWNORMAL);
    Sleep(2000);
    if FileExists(nama_param) then
        begin
                MessageDlg('Selesai Download Param, Klik OK untuk Melanjutkan',mtInformation, [mbOK], 0);
                statParam:='1';
        end
    else
        statParam:='0';
  end;

  if statParam='1' then
  begin
      if not DirectoryExists(rootDir) then
      begin
        if not CreateDir(rootDir) then
        begin
          MessageDlg('ERROR PENANGANAN FOLDER DATA [GAGAL MEMBUAT FOLDER DATA]', mtError, [mbOK], 0);
          Application.Terminate;
        end;
      end;     
      h1:=BeginThread(nil,1024,@TFrm_Main.GetData,nil,0,th1);
  end
  else
      MessageDlg('Gagal Download Param, Pastikan Param Tersedia!!',mtInformation, [mbOK], 0);
end;

procedure TFrm_Main.btnAmbilDaftarFileBTClick(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  lblJumlahFileBT.Caption:='0';
  fileTerpilih:='';
  btnPreviewBT.Enabled:=false;
  btnCetakBT.Enabled:=false;

  if not DirectoryExists(dataBayarDir) then
  begin
    MessageDlg('FOLDER PENYIMPANAN DATA BUKTI TERIMA TIDAK DITEMUKAN'+#13+'PASTIKAN DANOM SUDAH DICETAK TERLEBIH DAHULU', mtError, [mbOK], 0);
  end
  else
  begin
    listFile_bt.Clear;
    griddata_bt.Visible:=false;
    lblDaerahBT.Caption:='';
    lbl_RowBT.Caption:='0';
    if cboJenisAmbilDataBT.ItemIndex=1 then
    begin
      //ambil danom mandiri
      FileSearch(dataBayarDir, '*.DNM','2');
      isMandiri:=True;
    end
    else
    begin
      //ambil danom pos
      FileSearch(dataBayarDir, '*.DNP','2');
      isMandiri:=False;
    end;
    lblJumlahFileBT.Caption:=IntToStr(listFile_bt.Items.Count);
    if listFile_bt.Items.Count=0 then
    begin
      MessageDlg('TIDAK ADA FILE YANG AKAN DIPROSES'+#13+'BELUM ADA DANOM YANG SUDAH DICETAK', mtInformation, [mbOK], 0);
    end;
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.btnCetakBuktiTerimaClick(Sender: TObject);
begin
  //kelola panel
  pnlAmbilData.Visible:=false;
  pnlTampilData.Visible:=false;
  pnlBuktiTerima.Align:=alClient;
  pnlBuktiTerima.Visible:=true;
  //kelola tombol menu
  if Frm_Login.isLokal then
    btn_Simpan.Enabled:=false
  else
    btn_Simpan.Enabled:=true;
  btnCetakBuktiTerima.Enabled:=false;
  btnTampilData.Enabled:=true;

  listFile_bt.Items.Clear;
  griddata_bt.Visible:=false;
  cboJenisAmbilDataBT.ItemIndex:=0;
  lblDaerahBT.Caption:='';
  lbl_RowBT.Caption:='0';
  lblJumlahFileBT.Caption:='0';
  fileTerpilih:='';
  btnPreviewBT.Enabled:=false;
  btnCetakBT.Enabled:=false;
end;

procedure TFrm_Main.listFile_btDblClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
begin
  Screen.cursor := crHourGlass;
  SelectedFile := listFile_bt.Items.Strings[listFile_bt.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;
  ds_load.DataSet := LoadFromDanomFile(dataDir2+SelectedFile);
  //split(arrNamaFile[0],'_',arrDaerah);
  lbl_rowBT.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata_bt.Visible:=TRUE;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerahBT.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreviewBT.Enabled:=true;
  btnCetakBT.Enabled:=true;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.btnPreviewBTClick(Sender: TObject);
var
  Component:TfrxComponent;
begin
  ds_load.DataSet.First;
   //AWAL TAMBAHAN
  with frxReportBT do
  begin
    if isMandiri then
    begin
      Component := frxReportBT.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR BUKTI PEMBAYARAN MANDIRI E-CASH');
    End
    Else
    begin
      Component := frxReportBT.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR BUKTI PEMBAYARAN REKENING GIROPOS SKS');
    End;
  end;
  //AKHIR TAMBAHAN

  {with frxReportBT do
  begin
    Component := frxReportBT.FindObject('memPegawai');
    TfrxMemoView(Component).Memo.Text := tempIdPetugas;
  end;}
  frxReportBT.ShowReport;
end;

procedure TFrm_Main.btnCetakBTClick(Sender: TObject);
var
  Component:TfrxComponent;
begin
  Screen.Cursor:=crHourGlass;
  ds_load.DataSet.First;
   //AWAL TAMBAHAN
  with frxReportBT do
  begin
    if isMandiri then
    begin
      Component := frxReportBT.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR BUKTI PEMBAYARAN MANDIRI E-CASH');
    End
    Else
    begin
      Component := frxReportBT.FindObject('memTitleReport');
      TfrxMemoView(Component).Memo.Text := uppercase('DAFTAR BUKTI PEMBAYARAN REKENING GIROPOS SKS');
    End;  end;
  //AKHIR TAMBAHAN
                        {
  with frxReportBT do
  begin
    Component := frxReportBT.FindObject('memPegawai');
    TfrxMemoView(Component).Memo.Text := tempIdPetugas;
  end;                   }
  frxReportBT.PrepareReport;
  //frxReport.ShowPreparedReport;
  frxReportBT.Print;

  if not DirectoryExists(dataBayarDir+'sudah_cetak_bukti\') then
  begin
    if not CreateDir(dataBayarDir+'sudah_cetak_bukti\') then
    begin
      MessageDlg('ERROR PENANGANAN FOLDER DATA [GAGAL MEMINDAHKAN DATA]', mtError, [mbOK], 0);
    end
    else
    begin
      MoveFile(pchar(dataBayarDir+fileTerpilih),pchar(dataBayarDir+'sudah_cetak_bukti\'+fileTerpilih));
    end;
  end
  else
  begin
    MoveFile(pchar(dataBayarDir+fileTerpilih),pchar(dataBayarDir+'sudah_cetak_bukti\'+fileTerpilih));
  end;

  btnAmbilDaftarFileBT.Click;

  Screen.Cursor:=crDefault;
end;

procedure TFrm_Main.cboTahapChange(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  btn_cetakrekap.Enabled:=true;
  cboKabupaten.Enabled:=true;
  cboKabupaten.Items.Clear;
  cboKecamatan.Enabled:=false;
  cboKecamatan.Items.Clear;
  cboKelurahan.Enabled:=false;
  cboKelurahan.Items.Clear;
  bt_open.Enabled:=false;
  memKelurahan.Lines.Clear;
  lbl_jmlKel.Caption:='0';
  lblSedangProses.Caption:=' ';

  //ShowMessage(IntToStr(cboJenis.ItemIndex));
  IF ds.DataSet<>nil then
  a.Close(ds.DataSet);

  a.SQL.Clear;

  if cboJenis.ItemIndex=1 then
  begin
    isMandiri:=true;
    a.SQL.text:='exec SIKAP_GET_KABUPATEN '+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end
  else
  begin
    isMandiri:=false;
    a.SQL.text:='exec SIKAP_GET_KABUPATEN '+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr(IntToStr(cboJenis.ItemIndex));
  end;

  if a.Open then
  begin
    if a.Count=0 then
    begin
       //showmessage('Tidak ada data...');
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
       a.close;
    end
    else
    begin
      ds.DataSet:=a.Data;
      ds.DataSet.First;
      while not ds.DataSet.Eof do
      begin
          cboKabupaten.Items.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
      end;
      a.close;
      cboKabupaten.ItemIndex:=-1;
    end;
  end
  else
  begin
    bt_connect.Caption:='&CONNECT';
    MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
    ResetForm;
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.cbb_projectChange(Sender: TObject);
begin
      cbb_headerdanom.ItemIndex := cbb_project.ItemIndex;
      cbb_pilSP.ItemIndex := cbb_project.ItemIndex;

      Screen.cursor := crHourGlass;
      cboTahap.Enabled:=true;
      cboTahap.Items.Clear;
      IF ds.DataSet<>nil then
      a.Close(ds.DataSet);

      a.SQL.Clear;

      {ambil tahap instansi}
      if cboJenis.ItemIndex= 1
      then begin
         a.SQL.text:='exec SIKAP_GET_TAHAP_KOTAKAB ' + copy(cbb_project.Text,1,4);
      end
      else if cboJenis.ItemIndex= 2
      then begin
         a.SQL.text:='exec SIKAP_GET_TAHAP_INS ' + copy(cbb_project.Text,1,4);
      end
      else if cboJenis.ItemIndex= 0
      then begin
         a.SQL.text:='exec SIKAP_GET_TAHAP_NAS ' + copy(cbb_project.Text,1,4);
      end ;
      {////}

      if a.Open then
      begin
        if a.Count=0 then
        begin
           //showmessage('Tidak ada data...');
           MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
           a.close;
        end
        else
        begin
          ds.DataSet:=a.Data;
          ds.DataSet.First;
          while not ds.DataSet.Eof do
          begin
              cboTahap.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
              ds.DataSet.Next;
          end;
          a.close;
          cboTahap.ItemIndex:= 0;
        end;
      end
      else
      begin
        bt_connect.Caption:='&CONNECT';
        MessageDlg('GAGAL MENGAMBIL DATA', mtInformation, [mbOK], 0);
        ResetForm;
      end;
  Screen.cursor := crDefault;
end;

end.
