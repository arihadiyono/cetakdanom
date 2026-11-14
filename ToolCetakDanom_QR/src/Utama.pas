{
--------------------------------------------------------------------------------
Program        : FDPOS - Cetak Danom
Author         : Saha Cik
                 Modify from CFDPOS - Cetak Danom |
Email          : jajat.lukman@posindonesia.co.id
Create date    : 17 Oktober 2014
Description    : Aplikasi untuk cetak daftar nominatif

                 Pola Kerja:
                 - Ambil data per kabupaten
                 - Split jadi beberapa file berdasarkan kelurahan
                 - Load data per kelurahan
                 - Pilihan preview dan cetak
                 - export pdf daftar nominatif(Preview cetak)
                 - fungsi update otomatis jika versi tidak sama

--------------------------------------------------------------------------------
}

unit Utama;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  Grids, Db,ComCtrls,  StdCtrls, ExtCtrls,Graphics,
  NCONN,NCrypt, Nzip,NUtility, Kbmmemtable,
  dxCore, dxButtons, DBGrids, bvDBGrid,
  Nmemtable, frxClass, frxDBSet, ShellApi,
  frxBarcode, GPanel, frxpngimage, Gauges, FileCtrl, JvGIF,
  JvExControls, JvAnimatedImage, JvGIFCtrl, frxExportPDF,
  frxExportBaseDialog, ADODB, NxCollection, SdfData, idHTTP, RAWPrinter, uLkJSON, tLhELP32;

const
  InputBoxMessage = WM_USER + 200;

type
  TFrm_Main = class(TForm)
    ds: TDataSource;
    dsconn: TDataSource;
    frxBarCodeObject1: TfrxBarCodeObject;
    frxReport: TfrxReport;
    frxDataset: TfrxDBDataset;
    pnl_Login: TPanel;
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
    listFile_bt: TListBox;   //BNT
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
    con1: TADOConnection;
    Query: TADOQuery;
    csvds: TSdfDataSet;
    mmo1: TMemo;
    mmo2: TMemo;
    lbl1: TLabel;
    cbb_awal: TComboBox;
    cbbakhir: TComboBox;
    btnCetakBuktiPernyataan: TdxButton;
    PnlBuktiPernyataan: TPanel;
    Memo5: TMemo;
    Panel13: TPanel;
    Panel14: TPanel;
    listFile_btPernyataan: TListBox;
    Panel15: TPanel;
    Label22: TLabel;
    Panel16: TPanel;
    Label24: TLabel;
    Image3: TImage;
    Label26: TLabel;
    Label29: TLabel;
    lblJumlahFileBTPernyataan: TLabel;
    Label31: TLabel;
    ComboBox1: TComboBox;
    btnAmbilDaftarFileBTPernyataan: TdxButton;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Panel17: TPanel;
    Label32: TLabel;
    lbl_rowBTPernyataan: TLabel;
    Label34: TLabel;
    lblDaerahBTPernyataan: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Panel18: TPanel;
    btnCetakBTPernyataan: TdxButton;
    btnPreviewBTPernyataan: TdxButton;
    Panel19: TPanel;
    Memo6: TMemo;
    griddata_btPernyataan: TbvDBGrid;
    frxReportBTPernyataan: TfrxReport;
    btn_BNBA: TdxButton;
    btnCds: TdxButton;
    pnlCDS: TPanel;
    Memo7: TMemo;
    Panel2: TPanel;
    Label30: TLabel;
    Label33: TLabel;
    label_nama: TLabel;
    Label35: TLabel;
    Label_nik: TLabel;
    Label38: TLabel;
    Label_bsu: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    label_noVoucher: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    label_nmPerusahaan: TLabel;
    Label_alamatperusahaan: TLabel;
    label_header: TLabel;
    label_prov: TLabel;
    label_kab: TLabel;
    label_kec: TLabel;
    label_kel: TLabel;
    NIK: TEdit;
    Button1: TButton;
    Panel20: TPanel;
    Panel21: TPanel;
    btnCtkCds: TdxButton;
    btnPrevcds: TdxButton;
    Panel22: TPanel;
    Memo8: TMemo;
    bvDBGrid1: TbvDBGrid;
    frxReport1: TfrxReport;
    NxButton1: TNxButton;
    NxButton2: TNxButton;
    frxReport2: TfrxReport;
    frxReport3: TfrxReport;
    frxReport4: TfrxReport;
    frxReportYapi: TfrxReport;
    frxReportDnmYapi: TfrxReport;
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
    procedure listFile_btPernyataanDblClick(Sender: TObject);
    procedure btnPreviewBTClick(Sender: TObject);
    procedure btnCetakBTClick(Sender: TObject);
    procedure cboTahapChange(Sender: TObject);
    procedure btnCetakBuktiPernyataanClick(Sender: TObject);
    procedure btnAmbilDaftarFileBTPernyataanClick(Sender: TObject);
    procedure listFile_btPernyataanClick(Sender: TObject);
    procedure btnPreviewBTPernyataanClick(Sender: TObject);
    procedure btnCetakBTPernyataanClick(Sender: TObject);
    procedure listFile_btDblClick(Control: TWinControl; Index: Integer;
      var DataObject: TObject);
    procedure listFile_btClick(Sender: TObject);
    procedure btn_BNBAClick(Sender: TObject);
    procedure listFileClick(Sender: TObject);
    procedure btnCdsClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnPrevcdsClick(Sender: TObject);
    procedure btnCtkCdsClick(Sender: TObject);
    procedure NxButton1Click(Sender: TObject);
    procedure NxButton2Click(Sender: TObject); //BNT

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
    rootDir, dataBNBA: string;
    databayarDir: string;
    databayarpernyataanDir: string;
    dataDir2: string;
    dataDir3: string;
    tempIdPetugas,tempNippos,tempNamaPetugas,
    idsp,idheaderdanom,tempNopend,tempKantor,tempJabatan: string;
    fileTerpilih: string;
    isMandiri:boolean;
  end;

  nstr=string[100];
  TMem=Tkbmmemtable;

var
  Frm_Main: TFrm_Main;
  a : TNCmd;
  h1, th1: cardinal;
  namaBNBA: string;
  idproject,nmFile,subfix : string;

implementation

uses ServerConf,UParam,ULogin, StrUtils;
// the calls here are assumed 32 bit compilation, so, adjust accordingly

{$R *.DFM}
function MessageBoxTimeOut(hWnd: HWND; lpText: PChar; lpCaption: PChar; uType: UINT; wLanguageId: WORD; dwMilliseconds: DWORD): Integer; stdcall; external user32 name 'MessageBoxTimeoutA';

function processExists(exeFileName: string): Boolean; 
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
    begin
      Result := True;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

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
    Add('PERCENTILE',ftString,200,true);
    Add('FOOTER',ftString,1000,true);
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
  // else
  else if opt='2' then   //diubah karena BNT
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
  end
  // bnt
  else begin
         Path := IncludeTrailingBackslash(PathName);
    if FindFirst(Path + FileName, faAnyFile - faDirectory, Rec) = 0 then
      try
        repeat
          listFile_btPernyataan.Items.Add(Rec.Name);
        until FindNext(Rec) <> 0;
      finally
      FindClose(Rec);
    end;
    if listFile_btPernyataan.Items.Count=0 then
    begin
      listFile_btPernyataan.Clear;
    end else
    begin
      with listFile_btPernyataan do
      begin
        len := listFile_btPernyataan.Width;
        for i := 0 to items.count -1 do
        begin
          len := canvas.textwidth(items[i]);
        end;
        //set listbox's horizontal scrollbar width
        Perform(LB_SETHORIZONTALEXTENT,len+100,0);
      end;
    end;
  end;
  //BNT

end; //procedure FileSearch

procedure TFrm_Main.ResetForm;
begin
  lbl_status.Caption:='NOK';
  lbl_status.Font.Color:= clRed;
  btn_CetakRekap.Enabled:=false;
  bt_open.Enabled:=False;
  cboJenis.Enabled:=false;
  cboTahap.Enabled:=false;
  cboKabupaten.Enabled:=false;
  cboKecamatan.Enabled:=false;
  cboKelurahan.Enabled:=false;
  cboJenis.ItemIndex:=-1;
  cboTahap.ItemIndex:=-1;
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
    if bt_connect.Caption='&CONNECT' then
    begin
        bt_connect.Caption:='&DISCONNECT';
        lbl_status.Caption:='OK';
        lbl_status.Font.Color:= clTeal;
        btn_CetakRekap.Enabled:=false;
        cboTahap.Enabled:=true;
        cboTahap.ItemIndex:=-1;
        cboTahap.SetFocus;
        cboKabupaten.Items.Clear;
        cboKecamatan.Items.Clear;
        cboKelurahan.Items.Clear;
    end
    else
    begin
      bt_connect.Caption:='&CONNECT';

      ResetForm;
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
  Application.Title:=appTitle;
  //lblVersion.Caption:='';

  rootDir:=ExtractFilePath(ParamStr(0))+'data\';
  dataDir:='data\';
  dataDir2:='data\sudah_cetak\';
  dataDir3:='data\sudah_cetak\sudah_cetak_bukti\';
  dataBayarDir:=ExtractFilePath(ParamStr(0))+'data\sudah_cetak\';
  dataBayarPernyataanDir:=ExtractFilePath(ParamStr(0))+'data\sudah_cetak\sudah_cetak_bukti\';

  CreateMutex(nil, true, PChar(Application.Title));
  if GetLastError = Error_Already_Exists then
  begin
    ShowMessage('APLIKASI SUDAH DIJALANKAN');
    Halt;
  end;

  dataBNBA := rootDir+'BNBA';
  if not DirectoryExists(dataBNBA) then
  begin
    if not CreateDir(dataBNBA) then
    begin
      ShowMessage('Error Penanganan Folder Data [Gagal Membuat Folder BNBA]');
      Application.Terminate;
    end;
  end;

  IF processExists('cetakDanom.exe') then
   begin

   end
  else
  Application.Terminate;
end;


procedure TFrm_Main.FormShow(Sender: TObject);
var
  i,j,k : Integer;
  Data,slFile : TstringList;
  tempDir1,tempParam1, nmFile1  : string;

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
  pnlTampilData.Align:=alClient;
  pnlTampilData.Visible:=true;
  btn_Simpan.Click;
  edtnopend.Text:=tempNopend;
  isMandiri:=false;
  cboJenis.ItemIndex:=-1;
  cboKabupaten.ItemIndex:=0;

  nmFile1 := 'logo_perusahaan.jpg';
  if FileExists(nmFile1) then begin

  end else
  begin
    tempDir1:=''+ExtractFilePath(ParamStr(0))+'';
      tempParam1:=tempURL+'|'+nmFile1+'|'+nmFile1+'|'+tempDir1+'|';
      ShellExecute(handle,'open',PChar(tempDir1+'download.exe'), PChar(tempParam1),'',SW_SHOWNORMAL);
  end;
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
begin
  try
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
  except
  end;
end;

procedure TFrm_Main.btnTampilDataClick(Sender: TObject);
begin
  //kelola panel
  pnlAmbilData.Visible:=false;
  pnlBuktiTerima.Visible:=false;
  PnlBuktiPernyataan.Visible:=false;
  pnlCDS.Visible:=false;

  pnlTampilData.Align:=alClient;
  pnlTampilData.Visible:=true;

  pnlBuktiPernyataan.Visible:=false;   //BNT

  btnTampilData.Enabled:=false;
  btnCetakBuktiPernyataan.Enabled:=false;
  btnCetakBuktiTerima.Enabled:=true;
  btnCds.Enabled:=true;

  listFile_bt.Items.Clear; //coba clear   BNT
  listFile.Items.Clear;
  griddata.Visible:=false;


  cboJenisAmbilData.ItemIndex:=0;
  lblDaerah.Caption:='';
  lbl_Row.Caption:='0';
  lblJumlahFile.Caption:='0';
  fileTerpilih:='';
  btnPreview.Enabled:=false;
  btnCetak.Enabled:=false;
end;

procedure TFrm_Main.btnCetakClick(Sender: TObject);
var
  photo1,photo2,Component:TfrxComponent;
begin
  btn_BNBA.Click();
  Screen.Cursor:=crHourGlass;
  ds_load.DataSet.First;

  if idheaderdanom='0' then
  begin
    with frxReport do
    begin
      Component := frxReport.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

        if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;

    end;

    frxReport.PrepareReport;
    frxReport.Print;
  end else if idheaderdanom='1' then
  begin
    with frxReport2 do
    begin
    Component := frxReport2.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

        if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport2.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport2.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;

    end;

    frxReport2.PrepareReport;
    frxReport2.Print;
  end else if idheaderdanom='3' then
  begin
    with frxReport3 do
    begin
        if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport3.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport3.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;

    end;

    frxReport3.PrepareReport;
    frxReport3.Print;
  end else if idheaderdanom='4' then
  begin
    with frxReportDnmYapi do
    begin
      Component := frxReportDnmYapi.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

        if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReportDnmYapi.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReportDnmYapi.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;

    end;

    frxReportDnmYapi.PrepareReport;
    frxReportDnmYapi.Print;
  end;

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

  //BNT
   if not DirectoryExists(dataBayarPernyataanDir) then
  begin
    if not CreateDir(dataBayarPernyataanDir) then
    begin
      MessageDlg('ERROR PENANGANAN FOLDER DATA [GAGAL MEMINDAHKAN DATA]', mtError, [mbOK], 0);
    end
    else
    begin
      MoveFile(pchar(rootDir+fileTerpilih),pchar(dataBayarPernyataanDir+fileTerpilih));
    end;
  end
  else
  begin
    MoveFile(pchar(rootDir+fileTerpilih),pchar(dataBayarPernyataanDir+fileTerpilih));
  end;

  btnAmbilDaftarFile.Click;

  Screen.Cursor:=crDefault;
end;

procedure TFrm_Main.btn_SimpanClick(Sender: TObject);
begin
  pnlTampilData.Visible:=true;
  pnlBuktiTerima.Visible:=false;

  pnlTampilData.Align:=alClient;
  pnlTampilData.Visible:=true;

  btnTampilData.Enabled:=False;
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

    FileSearch(rootDir, '*.POS','1');
    lblJumlahFile.Caption:=IntToStr(listFile.Items.Count);
    if listFile.Items.Count=0 then
    begin
      MessageDlg('TIDAK ADA FILE YANG AKAN DIPROSES', mtInformation, [mbOK], 0);
    end;
  end;
  Screen.cursor := crDefault;
end;

procedure setHeader();
begin
  with Frm_Main do
  begin
    griddata.Columns[0].FieldName := 'ID_PELANGGAN';
    griddata.Columns[0].Title.Caption := 'ID_PELANGGAN';
    griddata.Columns[1].Title.Caption := 'PELANGGAN';
    griddata.Columns[2].Title.Caption := 'ALAMAT';
    griddata.Columns[3].Title.Caption := 'AMOUNT';
    griddata.Columns[4].Title.Caption := 'ID_KELURAHAN';
    griddata.Columns[5].Title.Caption := 'KELURAHAN';
    griddata.Columns[6].Title.Caption := 'ID_KECAMATAN';
    griddata.Columns[7].Title.Caption := 'KECAMATAN';
    griddata.Columns[8].Title.Caption := 'ID_KABUPATEN';
    griddata.Columns[9].Title.Caption := 'KABUPATEN';
    griddata.Columns[10].Title.Caption := 'ID_PROPINSI';
    griddata.Columns[11].Title.Caption := 'PROPINSI';
    griddata.Columns[12].Title.Caption := 'NIK';
    griddata.Columns[13].Title.Caption := 'bs1';
    griddata.Columns[14].Title.Caption := 'bs2';
    griddata.Columns[15].Title.Caption := 'bs3';
    griddata.Columns[16].Title.Caption := 'Potongan PPH 21 (Rp.)';
    griddata.Columns[17].Title.Caption := 'Potongan ASKES (Rp.)';
    griddata.Columns[18].Title.Caption := 'Potongan Hutang (Rp.)';
    griddata.Columns[19].Title.Caption := 'Potongan Lain (Rp.)';
    griddata.Columns[20].Title.Caption := 'Jumlah Potongan (Rp.)';
    griddata.Columns[21].Title.Caption := 'Jumlah Netto (Rp.)';
    griddata.Columns[22].Title.Caption := 'Bank Rekening';
    griddata.Columns[23].Title.Caption := 'Jenis Rekening';

    griddata.Columns[0].Width := 200;
    griddata.Columns[1].Width := 200;
    griddata.Columns[2].Width := 200;
    griddata.Columns[3].Width := 200;
    griddata.Columns[4].Width := 200;
    griddata.Columns[5].Width := 200;
    griddata.Columns[6].Width := 200;
    griddata.Columns[7].Width := 200;
    griddata.Columns[8].Width := 200;
    griddata.Columns[9].Width := 200;
    griddata.Columns[10].Width := 200;
    griddata.Columns[11].Width := 200;
    griddata.Columns[12].Width := 200;
    griddata.Columns[13].Width := 200;
    griddata.Columns[14].Width := 200;
    griddata.Columns[15].Width := 200;
    griddata.Columns[16].Width := 200;
    griddata.Columns[17].Width := 200;
    griddata.Columns[18].Width := 200;
    griddata.Columns[19].Width := 200;
    griddata.Columns[20].Width := 200;
    griddata.Columns[21].Width := 200;
    griddata.Columns[22].Width := 200;
    griddata.Columns[23].Width := 200;
  end;
end;


procedure TFrm_Main.listFileDblClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
  //load file
  tempParam2,tempDir2, idproject2,nmFile2 : string;
  i : Integer;
  Data,slFile : TstringList;
  //load file

begin
  idheaderdanom := '';
  Screen.cursor := crHourGlass;
  SelectedFile := listFile.Items.Strings[listFile.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;
  ds_load.DataSet := LoadFromDanomFile(dataDir+SelectedFile);

  lbl_row.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata.Visible:=TRUE;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerah.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreview.Enabled:=true;
  btnCetak.Enabled:=true;
  btn_BNBA.Enabled:=true;
  Screen.cursor := crDefault;

   idproject2 :=copy(SelectedFile,1,3);
   idproject2 := LowerCase(idproject2); // S2 := 'foo';
   subfix := copy(SelectedFile,4,1);
   subfix := LowerCase(subfix);
   nmFile2 := 'logo_'+idproject2+'_'+subfix+'.jpg';
   idproject := nmFile2;

   idheaderdanom := copy(RightStr(SelectedFile,5),1,1);
    if idheaderdanom <> '3' then
    begin
      if FileExists(nmFile2) then begin

      end else
      begin
        tempDir2:=''+ExtractFilePath(ParamStr(0))+'';
        tempParam2:=tempURL+'|'+nmFile2+'|'+nmFile2+'|'+tempDir2+'|';
        ShellExecute(handle,'open',PChar(tempDir2+'download.exe'), PChar(tempParam2),'',SW_SHOWNORMAL);

      end;
    end;
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

  cboKecamatan.Items.Clear;

  Query.Close;
  Query.SQL.Text := 'exec SIKAP_GET_KECAMATAN '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr('0');
  Query.Open;

if (ds.DataSet.Fields[0].AsString<>'') then
  begin
    ds.DataSet.First;
    cboKecamatan.Items.Add('---[ SEMUA KECAMATAN ]---');
      while not ds.DataSet.Eof do
      begin
          cboKecamatan.Items.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
      end;
      cboKecamatan.ItemIndex:=-1;
  end else
     MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);

  Screen.cursor := crDefault;
end;

procedure TFrm_Main.btn_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrm_Main.btnPreviewClick(Sender: TObject);
var
  photo1,photo2,Component:TfrxComponent;
begin
  frPDF.FileName:=listFile.Items.Strings[listFile.ItemIndex];
  ds_load.DataSet.First;

  if idheaderdanom='0' then
  begin
    with frxReport do
    begin
      Component := frxReport.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

      if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;
    end;
    frxReport.ShowReport;
  end else if idheaderdanom='1' then
  begin
    with frxReport2 do
    begin
      Component := frxReport2.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

      if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport2.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport2.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;
    end;
    frxReport2.ShowReport;
  end else if idheaderdanom='3' then
  begin
    with frxReport3 do
    begin

      if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReport3.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReport3.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;
    end;
    frxReport3.ShowReport;
  end else if idheaderdanom='4' then
  begin
    with frxReportDnmYapi do
    begin
      Component := frxReportDnmYapi.FindObject('memo1');
      TfrxMemoView(Component).Memo.Text := mmo2.Text;

      if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
        begin
          photo1 := frxReportDnmYapi.FindObject('photo1');
          TfrxMemoView(photo1).Memo.Text := 'logo_perusahaan.jpg';
        end;

      if FileExists(ExtractFilePath(paramstr(0))+idproject) then
        begin
          photo2 := frxReportDnmYapi.FindObject('photo2');
          TfrxMemoView(photo2).Memo.Text := idproject;
        end;
    end;
    frxReportDnmYapi.ShowReport;
  end;
end;

procedure TFrm_Main.cboJenisChange(Sender: TObject);
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


  cboKabupaten.Items.Clear;

  Query.Close;
  Query.SQL.Text := 'exec SIKAP_GET_KABUPATEN '+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr('0');
  Query.Open;

if (ds.DataSet.Fields[0].AsString<>'') then
  begin
    ds.DataSet.First;
      while not ds.DataSet.Eof do
      begin
          cboKabupaten.Items.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
      end;
      cboKabupaten.ItemIndex:=-1;
  end else
     MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);

  Screen.cursor := crDefault;
end;

procedure TFrm_Main.cboKecamatanChange(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  if cboKecamatan.ItemIndex=0 then
  begin
    cboKelurahan.Enabled:=false;
    cboKelurahan.Items.Clear;
    bt_open.Enabled:=true;
    memKelurahan.Lines.Clear;
    lbl_jmlKel.Caption:='0';
    lblSedangProses.Caption:=' ';


    cboKelurahan.Items.Clear;

    Query.Close;
    Query.SQL.Text := 'exec SIKAP_GET_KELURAHAN_BYKAB '+quotedstr(arrKabupaten[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr('0');
    Query.Open;

    if (ds.DataSet.Fields[0].AsString<>'') then
    begin
      ds.DataSet.First;
        while not ds.DataSet.Eof do
        begin
            memKelurahan.Lines.Add(ds.DataSet.Fields[0].AsString);
            ds.DataSet.Next;
        end;
        lbl_jmlKel.Caption:=IntToStr(memKelurahan.Lines.Count);
    end else
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);

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

    cboKelurahan.Items.Clear;

    Query.Close;
    Query.SQL.Text := 'exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr('0');
    Query.Open;

    if (ds.DataSet.Fields[0].AsString<>'') then
    begin
      ds.DataSet.First;
        cboKelurahan.Items.Add('---[ SEMUA KELURAHAN ]---');
        while not ds.DataSet.Eof do
        begin
            Split(ds.DataSet.Fields[0].AsString,'|',ArrKelurahanSplit);
            cboKelurahan.Items.Add(ArrKelurahanSplit[0]+'|'+ArrKelurahanSplit[1]);
            ds.DataSet.Next;
        end;
        a.close;
        cboKelurahan.ItemIndex:=-1;
    end else
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);

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

    memKelurahan.Lines.Clear;

    Query.Close;
    Query.SQL.Text := 'exec SIKAP_GET_KELURAHAN_BYKEC '+quotedstr(arrKecamatan[0])+','+quotedstr(edtnopend.Text)+','+quotedstr(tempIdPetugas)+','+quotedstr(tempNippos)+','+quotedstr('0');
    Query.Open;

    if (ds.DataSet.Fields[0].AsString<>'') then
    begin
      ds.DataSet.First;
        while not ds.DataSet.Eof do
        begin
          memKelurahan.Lines.Add(ds.DataSet.Fields[0].AsString);
          ds.DataSet.Next;
        end;
        lbl_jmlKel.Caption:=IntToStr(memKelurahan.Lines.Count);
    end else
       MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);
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
  strdata: TStringList;
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
    memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'Mulai proses ambil data daftar nominatif dari '+IntToStr(jmlKelurahan)+' kelurahan');
    bt_open.Enabled:=false;
    gifSedangProses.Animate:=true;
    pnl_Login.Enabled:=false;

    for i:=0 to memKelurahan.Lines.Count-1 do
    begin
      //Application.ProcessMessages;
      lblSedangProses.Caption:='Sedang proses '+IntToStr(i+1)+' dari '+IntToStr(jmlKelurahan)+' kelurahan';
      split(memKelurahan.Lines.Strings[i],'|',arrKelurahan);

      Query.Close;
      Query.SQL.Text := 'EXEC SIKAP_GET_DATA_BANSOSRS '+quotedstr(arrKelurahan[0])+','+quotedstr(copy(cboJenis.Text,1,2))+','+quotedstr('0');
      Query.Open;

      strdata:=TStringList.Create;
      if (ds.DataSet.Fields[0].AsString<>'') then
      begin
        Pds := ds.DataSet;
        fileDanom:=dataDir+uppercase(TRIM(arrKabupaten[1]))+'_'+uppercase(TRIM(arrKelurahan[2]))+'_'+uppercase(TRIM(arrKelurahan[1]))+'_'+edtNopend.text+'_'+IntToStr(ds.DataSet.RecordCount)+'.POS';

        try
          with ds.DataSet do
          begin
            while not Eof do
            begin
              strData.Add(Fields[0].AsString + ';' +
                Fields[1].AsString + ';' +
                Fields[2].AsString + ';' +
                Fields[3].AsString + ';' +
                Fields[4].AsString + ';' +
                Fields[5].AsString + ';' +
                Fields[6].AsString + ';' +
                Fields[7].AsString + ';' +
                Fields[8].AsString + ';' +
                Fields[9].AsString + ';' +
                Fields[10].AsString + ';' +
                Fields[11].AsString + ';' +
                Fields[12].AsString + ';' +
                Fields[13].AsString + ';' +
                Fields[14].AsString + ';' +
                Fields[15].AsString + ';' +
                Fields[16].AsString + ';' +
                Fields[17].AsString + ';' +
                Fields[18].AsString + ';' +
                Fields[19].AsString + ';' +
                Fields[20].AsString + ';' +
                Fields[21].AsString + ';' +
                Fields[22].AsString + ';' +
                Fields[23].AsString
              );
              Next;
            end;

          end;
          strdata.SaveToFile(fileDanom);
        finally
          FreeAndNil(strdata);
        end;


        //SaveToFile(Pds,fileDanom);
        jmlSukses:=jmlSukses+1;
        memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'SUKSES GENERATE FILE -> KELURAHAN : '+arrKelurahan[1]+', '+arrKelurahan[2]);
      end else
      begin
        jmlKosong:=jmlKosong+1;
        memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'TIDAK ADA DATA - KELURAHAN -> '+arrKelurahan[1]+ ', KECAMATAN : '+arrKecamatan[1]);
      end;;

      pb.Progress:=i+1;
    end;
    memLogProses.Lines.Add(formatdatetime('yyyy-mm-dd HH:MM:SS zzz',now)+' : '+'Selesai proses ambil data daftar nominatif '+IntToStr(jmlKelurahan)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Sukses generate file : '+IntToStr(jmlSukses)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Gagal generate file   : '+IntToStr(jmlGagal)+' kelurahan');
    memLogProses.Lines.Add(' =>  '+'Data tidak ada          : '+IntToStr(jmlKosong)+' kelurahan');
    lblSedangProses.Caption:='Selesai proses '+IntToStr(jmlKelurahan)+' kelurahan';
    gifSedangProses.Animate:=false;
    pnl_Login.Enabled:=true;
  end;
  Screen.cursor := crDefault;
end;


procedure TFrm_Main.bt_openClick(Sender: TObject);
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
      FileSearch(dataBayarDir, '*.POS','2');
    lblJumlahFileBT.Caption:=IntToStr(listFile_bt.Items.Count);
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.btnCetakBuktiTerimaClick(Sender: TObject);
begin
  //kelola panel
  pnlAmbilData.Visible:=false;
  pnlTampilData.Visible:=false;
  PnlBuktiPernyataan.Visible:=false;
  pnlCDS.Visible:=false;

  pnlBuktiTerima.Align:=alClient;
  pnlBuktiTerima.Visible:=true;

  btnCetakBuktiTerima.Enabled:=false;

  btnTampilData.Enabled:=true;
  btnCetakBuktiPernyataan.Enabled:=true;
  btnCds.Enabled:=true;

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

// BNT
procedure TFrm_Main.btnCetakBuktiPernyataanClick(Sender: TObject);
begin
    //kelola panel
  pnlAmbilData.Visible:=false;
  pnlTampilData.Visible:=false;
  pnlBuktiTerima.Visible:=false;
  PnlBuktiPernyataan.Align:=alClient;
  PnlBuktiPernyataan.Visible:=true;

  //kelola tombol menu
  btnCetakBuktiPernyataan.Enabled:=false;
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
//  BNT

procedure TFrm_Main.listFile_btPernyataanDblClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
  //load file
  idproject,nmFile,subfix : string;
  i : Integer;
  Data,slFile : TstringList;
  //load file

begin
mmo1.Clear;   //clear mmo1 tambahan

  Screen.cursor := crHourGlass;
  SelectedFile := listFile_btPernyataan.Items.Strings[listFile_btPernyataan.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;

  ds_load.DataSet := LoadFromDanomFile(dataDir3+SelectedFile);

  //split(arrNamaFile[0],'_',arrDaerah);
  lbl_rowBTPernyataan.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata_btPernyataan.Visible:=TRUE;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerahBTPernyataan.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreviewBTPernyataan.Enabled:=true;
  btnCetakBTPernyataan.Enabled:=true;
  Screen.cursor := crDefault;

  //awal load nama file
   //ShowMessage(SelectedFile);
   idproject :=copy(SelectedFile,1,2);
   idproject := LowerCase(idproject); // S2 := 'foo';
   subfix := copy(SelectedFile,3,1);
   subfix := LowerCase(subfix);
   //ShowMessage(idproject);
   nmFile := 'param_b'+idproject+'_'+subfix+'.pos';
   //ShowMessage(nmFile);
   if FileExists(nmFile) then begin
    try
      slFile := TStringList.Create();
      slFile.Clear;
      slFile.LoadFromFile(nmFile);
      if slFile.Count>0 then
      begin
        for i:=0 to slFile.count-1 do begin
          begin
           Data:=TStringList.Create();

           //ShowMessage(slFile.Strings[i]);

           if i=0 then mmo2.Lines.Add(slFile.Strings[i])
           else mmo1.Lines.Add(slFile.Strings[i]);

           Data.Free;
          end;
        end;
      end
    finally
      FreeAndNil(slFile);
    end;
  end else
  begin
    ShowMessage('Format Surat Belum Ada, Silahkan Buat terlebih dahulu!');
    Application.Terminate;
  end;
  //akhir load nama file

end;

procedure TFrm_Main.btnPreviewBTClick(Sender: TObject);
var
  Component, Component1, Component2, Component3, photo1,photo2,photo3,photo4:TfrxComponent;
begin

    ds_load.DataSet.First;
    if idsp='0' then
      begin
        with frxReportBT do
        begin
          Component := frxReportBT.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportBT.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportBT.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportBT.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportBT.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportBT.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;
        frxReportBT.ShowReport;
    end else if idsp='1' then
    begin
        with frxReportBTPernyataan do
        begin
          Component := frxReportBTPernyataan.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportBTPernyataan.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportBTPernyataan.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportBTPernyataan.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportBTPernyataan.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportBTPernyataan.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;
        frxReportBTPernyataan.ShowReport;
    end else if idsp='2' then
    begin
        with frxReport4 do
        begin
          Component := frxReport4.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          //Component3 := frxReport4.FindObject('memo29');
          //TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReport4.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReport4.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReport4.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReport4.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;
        frxReport4.ShowReport;
    end else if idsp='3' then
      begin
        with frxReportYapi do
        begin
          Component := frxReportYapi.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportYapi.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportYapi.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportYapi.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportYapi.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportYapi.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;
        frxReportYapi.ShowReport;
    end;
end;

procedure TFrm_Main.btnCetakBTClick(Sender: TObject);
var
  Component, Component1,Component2,Component3, photo1,photo2,photo3,photo4:TfrxComponent;
begin
  Screen.Cursor:=crHourGlass;
    ds_load.DataSet.First;
    if idsp='0' then
      begin
        with frxReportBT do
        begin
          Component := frxReportBT.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportBT.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportBT.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportBT.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportBT.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportBT.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;

        frxReportBT.PrepareReport;
        //frxReport.ShowPreparedReport;
        frxReportBT.Print;
      end else if idsp='1' then
      begin
        with frxReportBTPernyataan do
        begin
          Component := frxReportBTPernyataan.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportBTPernyataan.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportBTPernyataan.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportBTPernyataan.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportBTPernyataan.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportBTPernyataan.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;

        frxReportBTPernyataan.PrepareReport;
        //frxReport.ShowPreparedReport;
        frxReportBTPernyataan.Print;
      end else if idsp='2' then
      begin
        with frxReport4 do
        begin
          Component := frxReport4.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReport4.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReport4.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReport4.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReport4.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReport4.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;

        frxReport4.PrepareReport;
        //frxReport.ShowPreparedReport;
        frxReport4.Print;
      end else if idsp='3' then
      begin
        with frxReportYapi do
        begin
          Component := frxReportYapi.FindObject('memPegawai');
          TfrxMemoView(Component).Memo.Text := tempIdPetugas;

          Component3 := frxReportYapi.FindObject('memo29');
          TfrxMemoView(Component3).Memo.Text := mmo1.Text;

          Component1 := frxReportYapi.FindObject('thp_awal');
          TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

          Component2 := frxReportYapi.FindObject('thp_akhir');
          TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_perusahaan.jpg') then
          begin
            photo1 := frxReportYapi.FindObject('photo1');
            TfrxMemoView(photo1).Memo.Text := 'ada';

          end;

          if FileExists(ExtractFilePath(paramstr(0))+'logo_'+idproject+'_'+subfix+'.jpg') then
          begin
            photo2 := frxReportYapi.FindObject('photo2');
            TfrxMemoView(photo2).Memo.Text := 'logo_'+idproject+'_'+subfix+'.jpg';

          end;
        end;

        frxReportYapi.PrepareReport;
        //frxReport.ShowPreparedReport;
        frxReportYapi.Print;
      end;
    mmo1.Clear;   //clear mmo1 tambahan

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
//  end;

end;

procedure TFrm_Main.cboTahapChange(Sender: TObject);
begin
  cboJenis.Items.Clear;

  Query.Close;
  Query.SQL.Text := 'exec SIKAP_GET_LAYANAN';
  Query.Open;

if (ds.DataSet.Fields[0].AsString<>'') then
  begin
    ds.DataSet.First;
      while not ds.DataSet.Eof do
      begin
          cboJenis.Items.Add(ds.DataSet.Fields[0].AsString +'|'+ ds.DataSet.Fields[1].AsString);
          ds.DataSet.Next;
      end;
      cboJenis.ItemIndex:=-1;
  end else
     MessageDlg('DATA TIDAK ADA', mtInformation, [mbOK], 0);

        cboJenis.Enabled:=true;
        cboJenis.SetFocus;
end;


//BNT
procedure TFrm_Main.btnAmbilDaftarFileBTPernyataanClick(Sender: TObject);
begin
  Screen.cursor := crHourGlass;
  lblJumlahFileBTPernyataan.Caption:='0';
  fileTerpilih:='';
  btnPreviewBTPernyataan.Enabled:=false;
  btnCetakBTPernyataan.Enabled:=false;

  if not DirectoryExists(dataBayarPernyataanDir) then
  begin
    MessageDlg('FOLDER PENYIMPANAN DATA BUKTI TERIMA TIDAK DITEMUKAN'+#13+'PASTIKAN DANOM SUDAH DICETAK TERLEBIH DAHULU', mtError, [mbOK], 0);
  end
  else
  begin
    listFile_btPernyataan.Clear;
    griddata_btPernyataan.Visible:=false;
    lblDaerahBTPernyataan.Caption:='';
    lbl_RowBTPernyataan.Caption:='0';
      //ambil danom mandiri
      FileSearch(dataBayarPernyataanDir, '*.POS','3');
    lblJumlahFileBTPernyataan.Caption:=IntToStr(listFile_btPernyataan.Items.Count);
  end;
  Screen.cursor := crDefault;
end;

procedure TFrm_Main.listFile_btPernyataanClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
  //load file
  idproject,nmFile,subfix : string;
  i : Integer;
  Data,slFile : TstringList;
  //load file

begin
mmo1.Clear;   //clear mmo1 tambahan

  Screen.cursor := crHourGlass;
  SelectedFile := listFile_btPernyataan.Items.Strings[listFile_btPernyataan.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;

  ds_load.DataSet := LoadFromDanomFile(dataDir3+SelectedFile);

  //split(arrNamaFile[0],'_',arrDaerah);
  lbl_rowBTPernyataan.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata_btPernyataan.Visible:=TRUE;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerahBTPernyataan.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreviewBTPernyataan.Enabled:=true;
  btnCetakBTPernyataan.Enabled:=true;
  Screen.cursor := crDefault;

  //awal load nama file
   //ShowMessage(SelectedFile);
   idproject :=copy(SelectedFile,1,2);
   idproject := LowerCase(idproject); // S2 := 'foo';
   subfix := copy(SelectedFile,3,1);
   subfix := LowerCase(subfix);
   //ShowMessage(idproject);
   nmFile := 'param_b'+idproject+'_'+subfix+'.pos';
   //ShowMessage(nmFile);
   if FileExists(nmFile) then begin
    try
      slFile := TStringList.Create();
      slFile.Clear;
      slFile.LoadFromFile(nmFile);
      if slFile.Count>0 then
      begin
        for i:=0 to slFile.count-1 do begin
          begin
           Data:=TStringList.Create();

           //ShowMessage(slFile.Strings[i]);

           if i=0 then mmo2.Lines.Add(slFile.Strings[i])
           else mmo1.Lines.Add(slFile.Strings[i]);

           Data.Free;
          end;
        end;
      end
    finally
      FreeAndNil(slFile);
    end;
  end else
  begin
    ShowMessage('Format Surat Belum Ada, Silahkan Buat terlebih dahulu!');
    Application.Terminate;
  end;
  //akhir load nama file
end;


procedure TFrm_Main.btnPreviewBTPernyataanClick(Sender: TObject);
var
  Component, Component1, Component2, Component3:TfrxComponent;
begin
    ds_load.DataSet.First;
    with frxReportBTPernyataan do
    begin
      Component := frxReportBT.FindObject('memPegawai');
      TfrxMemoView(Component).Memo.Text := tempIdPetugas;

      Component3 := frxReportBT.FindObject('memo29');
      TfrxMemoView(Component3).Memo.Text := mmo1.Text;

      Component1 := frxReportBT.FindObject('thp_awal');
      TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

      Component2 := frxReportBT.FindObject('thp_akhir');
      TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;

    end;
    frxReportBTPernyataan.ShowReport;



end;
//BNT

procedure TFrm_Main.btnCetakBTPernyataanClick(Sender: TObject);
var
  Component, Component1,Component2,Component3:TfrxComponent;
begin
  Screen.Cursor:=crHourGlass;

    ds_load.DataSet.First;

    with frxReportBTPernyataan do
    begin
      Component := frxReportBTPernyataan.FindObject('memPegawai');
      TfrxMemoView(Component).Memo.Text := tempIdPetugas;

      Component3 := frxReportBTPernyataan.FindObject('memo29');
      TfrxMemoView(Component3).Memo.Text := mmo1.Text;

      Component1 := frxReportBTPernyataan.FindObject('thp_awal');
      //TfrxMemoView(Component1).Memo.Text := cbb_awal.Text;

      Component2 := frxReportBTPernyataan.FindObject('thp_akhir');
      //TfrxMemoView(Component2).Memo.Text := cbbakhir.Text;
    end;
    frxReportBTPernyataan.PrepareReport;
    //frxReport.ShowPreparedReport;
    frxReportBTPernyataan.Print;

    mmo1.Clear;   //clear mmo1 tambahan

    if not DirectoryExists(dataBayarPernyataanDir+'sudah_cetak_pernyataan\') then
    begin
      if not CreateDir(dataBayarPernyataanDir+'sudah_cetak_pernyataan\') then
      begin
        MessageDlg('ERROR PENANGANAN FOLDER DATA [GAGAL MEMINDAHKAN DATA]', mtError, [mbOK], 0);
      end
      else
      begin
        MoveFile(pchar(dataBayarPernyataanDir+fileTerpilih),pchar(dataBayarPernyataanDir+'sudah_cetak_pernyataan\'+fileTerpilih));
      end;
    end
    else
    begin
      MoveFile(pchar(dataBayarPernyataanDir+fileTerpilih),pchar(dataBayarPernyataanDir+'sudah_cetak_pernyataan\'+fileTerpilih));
    end;

    btnAmbilDaftarFileBTPernyataan.Click;

    Screen.Cursor:=crDefault;
//  end;


end;
//BNT
procedure TFrm_Main.listFile_btDblClick(Control: TWinControl;
  Index: Integer; var DataObject: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
  //load file
  idproject,nmFile,subfix : string;
  i : Integer;
  Data,slFile : TstringList;
  //load file

begin
  mmo1.Clear;   //clear mmo1 tambahan
  idsp := '';

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

  //awal load nama file
   //ShowMessage(SelectedFile);
   idproject :=copy(SelectedFile,1,2);
   idproject := LowerCase(idproject); // S2 := 'foo';
   subfix := copy(SelectedFile,3,1);
   subfix := LowerCase(subfix);
   //ShowMessage(idproject);
   nmFile := 'param_b'+idproject+'_'+subfix+'.pos';
   //ShowMessage(nmFile);

   //idsp := copy(RightStr(SelectedFile,5),1,1);
   idsp := copy(LeftStr(SelectedFile,6),6,1);

   if FileExists(nmFile) then begin
    try
      slFile := TStringList.Create();
      slFile.Clear;
      slFile.LoadFromFile(nmFile);
      if slFile.Count>0 then
      begin
        for i:=0 to slFile.count-1 do begin
          begin
           Data:=TStringList.Create();

           //ShowMessage(slFile.Strings[i]);

           if i=0 then mmo2.Lines.Add(slFile.Strings[i])
           else mmo1.Lines.Add(slFile.Strings[i]);

           Data.Free;
          end;
        end;
      end
    finally
      FreeAndNil(slFile);
    end;
  end else
  begin
    ShowMessage('Format Surat Belum Ada, Silahkan Buat terlebih dahulu!');
    Application.Terminate;
  end;
  //akhir load nama file

end;

procedure TFrm_Main.listFile_btClick(Sender: TObject);
var
  SelectedFile : string;
  vKelurahan,vKecamatan,vKabupaten,vPropinsi: string;
  //load file
  i : Integer;
  Data,slFile : TstringList;
  //load file
  tempParam3,tempDir3, idproject3,nmFile3 : string;

begin
  mmo1.Clear;   //clear mmo1 tambahan
  idsp := '';

  Screen.cursor := crHourGlass;
  SelectedFile := listFile_bt.Items.Strings[listFile_bt.ItemIndex];
  LS.Visible:=false;
  split(SelectedFile,'.',arrNamaFile);
  fileTerpilih:=SelectedFile;

  ds_load.DataSet := LoadFromDanomFile(dataDir2+SelectedFile);

  //split(arrNamaFile[0],'_',arrDaerah);
  lbl_rowBT.Caption:=intToStr(ds_load.DataSet.RecordCount);
  griddata_bt.Visible:=TRUE;
//  vKelurahan:=ds_load.DataSet.FieldByName('PERCENTILE').AsString;
  vKelurahan:=ds_load.DataSet.FieldByName('KELURAHAN').AsString;
  vKecamatan:=ds_load.DataSet.FieldByName('KECAMATAN').AsString;
  vKabupaten:=ds_load.DataSet.FieldByName('KABUPATEN').AsString;
  vPropinsi:=ds_load.DataSet.FieldByName('PROPINSI').AsString;
  lblDaerahBT.Caption:=vKelurahan+', '+vKecamatan+', '+vKabupaten;
  btnPreviewBT.Enabled:=true;
  btnCetakBT.Enabled:=true;
  Screen.cursor := crDefault;

  //awal load nama file
   //ShowMessage(SelectedFile);
   idproject3 :=copy(SelectedFile,1,3);
   idproject3 := LowerCase(idproject3); // S2 := 'foo';
   subfix := copy(SelectedFile,4,1);
   subfix := LowerCase(subfix);
   //ShowMessage(idproject);
   nmFile3 := 'param_'+idproject3+'_'+subfix+'.pos';

   idproject := idproject3;

   //idsp := copy(RightStr(SelectedFile,5),1,1);
   idsp := copy(LeftStr(SelectedFile,6),6,1);

  // if FileExists(nmFile3) then begin
    try
      slFile := TStringList.Create();
      slFile.Clear;
      slFile.LoadFromFile(nmFile3);
      if slFile.Count>0 then
      begin
        for i:=0 to slFile.count-1 do begin
          begin
           Data:=TStringList.Create();

           //ShowMessage(slFile.Strings[i]);

           if i=0 then mmo2.Lines.Add(slFile.Strings[i])
           else mmo1.Lines.Add(slFile.Strings[i]);

           Data.Free;
          end;
        end;
      end
    finally
      FreeAndNil(slFile);
    end;

end;

procedure TFrm_Main.btn_BNBAClick(Sender: TObject);
var
  strdata : TStringList;
  prov : string;
  iFlags : integer;
begin
  namaBNBA := ExtractFilePath(ParamStr(0))+'data\BNBA\'+'BNBA_'+copy(fileTerpilih,1,length(fileTerpilih)-4)+'.csv';
  strdata := TStringList.Create;
  strdata.Add('BST;REGIONAL;KANTOR;PROVINSI;KABUPATEN;KECAMATAN;DESA/KELURAHAN;BATCH;NAMA;NOMINAL;NIK;ALAMAT;DANOM;PERCENTILE');
  ds_load.DataSet.First;
  try
    with ds_load.DataSet do
    begin
      while not Eof do
      begin
        prov:= StringReplace(Fields[14].AsString,'   ','', [rfReplaceAll,rfIgnoreCase]);
        strdata.Add(
          Fields[0].AsString + ';' + //bst
          Fields[20].AsString + ';' + //regional
          Fields[17].AsString +'-'+Fields[16].AsString + ';' + //kantor
          Fields[14].AsString + ';' +//copy(prov,1,Length(prov)-14) + ';' + //prov
          Fields[12].AsString + ';' + //kec//copy(Fields[10].AsString,1,Length(Fields[10].AsString)-8) + ';' + //kab
          Fields[10].AsString + ';' + //kec
          Fields[8].AsString + ';' + //dsa
          Fields[19].AsString + ';' + //batch
          //copy(Fields[10].AsString,Length(Fields[10].AsString)-6,6) + ';' +
          Fields[1].AsString + ';' +
          Fields[6].AsString + ';' +
          '`'+Fields[21].AsString + ';' +
          Fields[2].AsString + ';' +
          //'`'+Fields[11].AsString+Fields[9].AsString+Fields[7].AsString+Fields[5].AsString + ';'
          '`'+Fields[7].AsString + ';' +
          Fields[32].AsString + ';'
        );
        Next;
      end;
    end;
    strdata.SaveToFile(namaBNBA);
    ShowMessage('Selesai Membuat File By Name By Address!'+sLineBreak+'Klik OK Untuk Melanjutkan Cetak!');
  finally
    FreeAndNil(strdata);
  end;
end;
procedure TFrm_Main.listFileClick(Sender: TObject);
var SelectedFile : string;
begin
  idproject :=copy(SelectedFile,1,3);
   idproject := LowerCase(idproject); // S2 := 'foo';
   subfix := copy(SelectedFile,4,1);
   subfix := LowerCase(subfix);

end;

procedure TFrm_Main.btnCdsClick(Sender: TObject);
begin
//kelola panel
  pnlAmbilData.Visible:=false;
  pnlTampilData.Visible:=false;
  PnlBuktiPernyataan.Visible:=false;
  pnlBuktiTerima.Visible:=false;

  pnlCDS.Align:=alClient;
  pnlCDS.Visible:=true;

  btnTampilData.Enabled:=true;
  btnCetakBuktiPernyataan.Enabled:=false;
  btnCetakBuktiTerima.Enabled:=true;
  btnCds.Enabled:=false;


end;

procedure TFrm_Main.Button3Click(Sender: TObject);
var
  responURL : string;
  kimHTTP : TIdHTTP;
  JsonToSend: TStringStream;
  js,xs,xl:TlkJSONobject;
  ws: TlkJSONstring;
  nik_user, s: String;
  ret, ret1: LongWord;
  I,bsu :integer;
begin
  if NIK.Text <> '' then
  begin

          kimHTTP := TIdHTTP.Create(nil);

          nik_user:=NIK.Text;

                  JsonToSend := TStringStream.Create(
                  '{"NIK": "'+ nik_user +'"}'
                  );
        try
              kimHTTP.Request.ContentType := 'application/json';
              kimHTTP.Request.Accept := '*/*';
//              responURL := trim(kimHTTP.Post('http://10.60.64.25:8280/cds_blt/1.0.0/getData', JsonToSend));
              responURL := trim(kimHTTP.Post('http://10.33.41.252:8280/cds_blt/getData', JsonToSend));
        except
          on E:Exception do
            responURL := trim(E.Message);
        end;
        //MessageDlg('Response from gateway:'+#13+UpperCase(responURL), mtInformation, [mbOK], 0);
        s:= responURL;
        js := TlkJSON.ParseText(s) as TlkJSONobject;
        if not assigned(js) then
          begin
            ShowMessage('Data Tidak Ada / Gagal Mendapatkan Respon!!');
          end
        else
          begin
            xs := js.Field['NIKResponse'] as TlkJSONobject;
            xl := xs.Field['Response'] as TlkJSONobject;

            label_noVoucher.Caption := xl.getString('Id_Pelanggan');
            Label_nik.Caption := xl.getString('NIK');
            //Label_nik.Caption := copy(xl.getString('Id_Pelanggan'),4,Length(label_noVoucher.Caption)-4);
            label_nama.Caption := xl.getString('NAMA');
            label_nmPerusahaan.Caption := xl.getString('NMDESA_DTKS');
            Label_alamatperusahaan.Caption := xl.getString('ALAMAT_DTKS');
            bsu := StrToInt(xl.getString('KUANTITAS')) * StrToInt(xl.getString('NOMINAL'));
            Label_bsu.Caption := IntToStr(bsu);

            label_header.Caption := xl.getString('HEADER_DANOM');
            label_prov.Caption := xl.getString('NMPROP_DTKS');
            label_kab.Caption := xl.getString('NMKAB_DTKS');
            label_kec.Caption := xl.getString('NMKEC_DTKS');
            label_kel.Caption := xl.getString('NMDESA_DTKS');
          end;

        kimHTTP.Free;
        btnPrevCds.Enabled := True;
        btnCtkCds.Enabled := True;
  end else
  begin
    Showmessage('NIK Tidak Boleh Kosong!!');
  end;

end;

procedure TFrm_Main.Button2Click(Sender: TObject);
begin
  btnPrevcds.Enabled := False;
  btnCtkCds.Enabled := False;

  label_noVoucher.Caption := '';
  Label_nik.Caption := '';
  label_nama.Caption := '';
  label_nmPerusahaan.Caption := '';
  Label_alamatperusahaan.Caption := '';
  Label_bsu.Caption := '';

  NIK.Text := '';
  NIK.SetFocus;

end;

procedure TFrm_Main.btnPrevcdsClick(Sender: TObject);
var
  Component,barcode,prov,kab,kec,kel:TfrxComponent;
begin
  //frPDF.FileName:=listFile.Items.Strings[listFile.ItemIndex];
//  DataSource.DataSet.First;
  with frxReport1 do
  begin
    Component := frxReport1.FindObject('Memo42');
    TfrxMemoView(Component).Memo.Text := label_header.Caption;
    Component := frxReport1.FindObject('memPropinsi');
    TfrxMemoView(Component).Memo.Text := label_prov.Caption;
    Component := frxReport1.FindObject('memKabupaten');
    TfrxMemoView(Component).Memo.Text := label_kab.Caption;
    Component := frxReport1.FindObject('memKecamatan');
    TfrxMemoView(Component).Memo.Text := label_kec.Caption;
    Component := frxReport1.FindObject('memKelurahan');
    TfrxMemoView(Component).Memo.Text := label_kel.Caption;

    Component := frxReport1.FindObject('memo45');
    TfrxMemoView(Component).Memo.Text := Label_nik.Caption +' '+ label_nama.Caption;
    Component := frxReport1.FindObject('memo55');
    TfrxMemoView(Component).Memo.Text := Label_alamatperusahaan.Caption;
    Component := frxReport1.FindObject('memo41');
    TfrxMemoView(Component).Memo.Text := label_noVoucher.Caption;
    //barcode := frxReport1.FindObject('Barcode2D4');
    //TfrxBarCodeView(barcode).SetText('123');
    Component := frxReport1.FindObject('memo56');
    TfrxMemoView(Component).Memo.Text := Label_bsu.Caption;


  end;
  frxReport1.ShowReport;
end;
procedure TFrm_Main.btnCtkCdsClick(Sender: TObject);
var
  i, max: integer;
  MyPrinter: TRAWPrinter;
begin
  max := 3;
  MyPrinter := TRAWPrinter.Create(nil);
  Myprinter.BeginDoc;
  //MyPrinter.write(Chr(15));
  //MyPrinter.WriteLn('');
  MyPrinter.WriteLn(format('%32s', [#13 + label_header.Caption]));
//  MyPrinter.WriteLn(format('%32s', [#13 + 'KEMENTRIAN TENAGA KERJA RI']));
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');

  MyPrinter.WriteLn(format('%-14s', [#8 + 'No Voucher       : '+label_noVoucher.Caption]));
  MyPrinter.WriteLn(format('%-14s', [#8 + 'NIK              : '+Label_nik.Caption]));
  MyPrinter.WriteLn(format('%-14s', [#8 + 'Nama             : '+label_nama.Caption]));
  MyPrinter.WriteLn(format('%-14s', [#8 + 'Nama Perusahaan  : '+label_nmPerusahaan.Caption]));
  MyPrinter.WriteLn(format('%-14s', [#8 + 'Alamat Perusahaan: '+Label_alamatperusahaan.Caption]));
  MyPrinter.WriteLn(format('%-14s', [#8 + 'BSU              : Rp. '+formatfloat('#,##0.00', StrToInt(Label_bsu.Caption))]));


  MyPrinter.writeLn(format('%-14s', [#8 + 'Tanggal Cetak    : ' +DateToStr(Now)]));
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn(format('%-14s', [#8 + 'Tanda Tangan']));


  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn('');
  MyPrinter.WriteLn(format('%-14s', [#8 + '(...............)']));

  //  max:=max-(VInfoCetak.Count+1);
  //MyPrinter.Writeln('');
{  for i:=0 to VInfoCetak.Count-1 do
  begin
    MyPrinter.writeln(format('%-24s', [#8 + VInfoCetak.Strings[i] ]));
  end;}
  for i := 1 to max do
  begin
    //membuang sisa halaman
    MyPrinter.Writeln('');
  end;
  Myprinter.EndDoc;
  FreeAndNil(MyPrinter);
end;

procedure TFrm_Main.NxButton1Click(Sender: TObject);
var
  responURL : string;
  kimHTTP : TIdHTTP;
  JsonToSend: TStringStream;
  js,xs,xl:TlkJSONobject;
  ws: TlkJSONstring;
  nik_user, s: String;
  ret, ret1: LongWord;
  I,bsu :integer;
begin
  if NIK.Text <> '' then
  begin

          kimHTTP := TIdHTTP.Create(nil);

          nik_user:=NIK.Text;

                  JsonToSend := TStringStream.Create(
                  '{"NIK": "'+ nik_user +'"}'
                  );
        try
              kimHTTP.Request.ContentType := 'application/json';
              kimHTTP.Request.Accept := '*/*';
//              responURL := trim(kimHTTP.Post('http://10.60.64.25:8280/cds_blt/1.0.0/getData', JsonToSend));
              responURL := trim(kimHTTP.Post('http://10.33.41.252:8280/cds_blt/getData', JsonToSend));
        except
          on E:Exception do
            responURL := trim(E.Message);
        end;
        //MessageDlg('Response from gateway:'+#13+UpperCase(responURL), mtInformation, [mbOK], 0);
        s:= responURL;
        js := TlkJSON.ParseText(s) as TlkJSONobject;
        if not assigned(js) then
          begin
            ShowMessage('Data Tidak Ada / Gagal Mendapatkan Respon!!');
          end
        else
          begin
            xs := js.Field['NIKResponse'] as TlkJSONobject;
            xl := xs.Field['Response'] as TlkJSONobject;

            label_noVoucher.Caption := xl.getString('Id_Pelanggan');
            Label_nik.Caption := xl.getString('NIK');
            //Label_nik.Caption := copy(xl.getString('Id_Pelanggan'),4,Length(label_noVoucher.Caption)-4);
            label_nama.Caption := xl.getString('NAMA');
            label_nmPerusahaan.Caption := xl.getString('NMDESA_DTKS');
            Label_alamatperusahaan.Caption := xl.getString('ALAMAT_DTKS');
            bsu := StrToInt(xl.getString('KUANTITAS')) * StrToInt(xl.getString('NOMINAL'));
            Label_bsu.Caption := IntToStr(bsu);

            label_header.Caption := xl.getString('HEADER_DANOM');
            label_prov.Caption := xl.getString('NMPROP_DTKS');
            label_kab.Caption := xl.getString('NMKAB_DTKS');
            label_kec.Caption := xl.getString('NMKEC_DTKS');
            label_kel.Caption := xl.getString('NMDESA_DTKS');
          end;

        kimHTTP.Free;
        btnPrevCds.Enabled := True;
        btnCtkCds.Enabled := True;
  end else
  begin
    Showmessage('NIK Tidak Boleh Kosong!!');
  end;
end;

procedure TFrm_Main.NxButton2Click(Sender: TObject);
begin
  btnPrevcds.Enabled := False;
  btnCtkCds.Enabled := False;

  label_noVoucher.Caption := '';
  Label_nik.Caption := '';
  label_nama.Caption := '';
  label_nmPerusahaan.Caption := '';
  Label_alamatperusahaan.Caption := '';
  Label_bsu.Caption := '';

  NIK.Text := '';
  NIK.SetFocus;
end;

end.
