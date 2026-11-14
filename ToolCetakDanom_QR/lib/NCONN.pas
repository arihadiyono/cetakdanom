unit NCONN;
{
   Modul         : Modul Standar Antar muka Jaringan
   Deskripsi     : Modul ini menyediakan akses ke database baik lokal, remote
                   maupun lokal remote dengan protokol 2P
   Autor         : Nasruddin M.
   E-Mail        : nas@posindonesia.co.id
   Versi         : 1.00
   Tanggal       : 12 Mei 2005
   Library lain  :
     1. kbmmemtable V 5.00
     2. NZip V 1.00
     
   Feture        :
   - Open
   - ExecSql
   - SendData
   - SendDataSet
}
interface
uses
  FastShareMem,
  Forms,
  classes,SYsUTils, Windows,Db,
  kbmMemBinaryStreamFormat,
  kbmMemTable,
  Ncrypt,
  NSession,
  SyncObjs,
  Nzip,
  NFileData;
type
  TNloglevel=(nOne,nError,nAll);
  TMem=Tkbmmemtable;
  TFmt=TkbmBinaryStreamFormat;
  TNCmd=class(TObject)
    private
       VType:String; //fb, sock, mysql, mssql
       VHeadCmd:String;
       VEndCmd:String;
       VConStr:String;
       VName:String;
       VConn:Pointer;
       VZip:Pointer;
       VCrypt:Pointer;
       VNSess:Pointer;
       VDmz:String;
       VPDataSet:Pointer;
       VOutDataSet:Tmem;
       NCritSec : TCriticalSection;
       IsConnect : Boolean;
       VLogLevel : TNloglevel;
       VOutDataStr:TstringList;
       VSQL:Tstringlist;
       VInData,
       VInDataSet :TMem;
       VInFmt,VOutFmt:TFmt;
       VERRData:Tstringlist;
       VCount:Integer;
       VCommit:Integer;
       HDll:THandle;
       VLog: TNLog;
       VCurrDir:string;
       procedure SetSQL(Const Value:TStringList);
       procedure SetInData(Const Value:Tmem);
       procedure SetInDataSet(Const Value:Tmem);
       procedure SetHeadCmd(const Value:String);
       procedure SetEndCmd(const Value:String);
       procedure SetCommit(const Value:Integer);
       procedure SetType(const Value:String);
       procedure SetConStr(const Value:String);
       procedure AddLog;
    protected

    public
       property LastError:TStringList read VERRData;
       property Count:Integer read VCount;
       property Data:Tmem read VOutDataset;
       property DataStr:TstringList read VOutDataStr;
       property TypeCmd:String write SetType;
       property LogLevel:TNloglevel read VLogLevel write VLogLevel;
       property Name:String read VName write VName;
       property ConStr:String write SetConStr;
       property Commit:Integer write SetCommit;
       property SQL:TStringList read VSQL write SetSQL;
       property INData:Tmem read VInData write SetInData;
       property INDataSet:Tmem  write SetInDataSet;
       property HeadCmd:String read VHeadCmd write SetHeadCmd;
       property EndCmd:String read VEndCMD write SetEndCmd;
       function Connect:boolean; //Connect
       property Connected:boolean read Isconnect;
       function DisConnect:boolean; //DisConnect
       function Open:boolean; //Balikan min 1 row
       function ExecSql:boolean; //Balikan true / false
       function SendData:boolean; //Kirim Bulk Data
       function SendDataSet:boolean; //Kirim Bulk Data
       function SendFile:boolean; //Kirim File
       procedure Close(const DtSet:Pointer);overload; //Close memori lokal
       procedure Close(const value:boolean=true);overload;//Close transaksi
       procedure Close(const value:boolean;DtSet:Pointer); overload; //Close memori lokal dan transaski
       constructor Create;
       destructor Destroy;override;
  end;
  TNhdl = Integer;

implementation

{
##########################################################################
                                IMPLEMENTASI KELAS TNCmd

##########################################################################
}

constructor TNCmd.Create;
begin
   VSQL := TStringList.Create;
   VInData := Tmem.Create(nil);
   VInFmt := TFmt.Create(nil);
   VInData.DefaultFormat := VInFmt;
   VErrData := TStringList.Create;
   VCount := 0;
   HDll:=0;
   VDmz:='#';
   IsConnect:=False;
   LogLevel:=nOne;
   NCritSec := TCriticalSection.Create;
   Vlog:=TNLog.Create;
   VName:='Nconn';
   VCurrDir:= ExtractFilePath(ParamStr(0));
end;

destructor TNCmd.Destroy;
begin
  if hdll >=32  then
  begin
     Disconnect;
  end;
  If VSQL <> nil then
     FreeAndNil(VSQL);
  If VInData <> nil then
  begin
     FreeAndNil(VInData);
     FreeAndNil(VInFmt);
  end;
  If VErrData <> nil then
     FreeAndNil(VErrData);
  If NCritSec<>nil then
     FreeAndNil(NCritSec);
  If VLog<>nil then
     FreeAndNil(VLog);
end;

procedure TNCmd.AddLog;
begin
  if LogLevel<>nOne then
  begin
    VLog.Dir := VCurrDir + 'log\' + Formatdatetime('yyyy\yyyymm', now);
    VLog.LogName:= VName+FormatDateTime('yyyymmdd', now) + '.log';
    if VLogLevel=nError then
    begin
      VLog.Add(FormatDateTime('hh:MM:ss:zzz', now)+' '+trim(VERRData.Text));
    end else
    if VLogLevel=nAll then
    begin
      VLog.Add(FormatDateTime('hh:MM:ss:zzz', now)+' '+trim(trim(VHeadCmd)+' '+trim(VSQL.Text)+' '+trim(VEndCmd)));
      VLog.Add(FormatDateTime('hh:MM:ss:zzz', now)+' '+trim(VERRData.Text));
    end
  end;
end;

procedure TNCmd.SetSQL(const Value:TStringlist);
begin
  VSQL.Assign(Value);
end;

procedure TNCmd.SetInData(const Value:Tmem);
begin
  VInData.LoadFromDataSet(Value,[mtcpoStructure]);
  VInDataSet:=nil;
end;

procedure TNCmd.SetInDataSet(const Value:Tmem);
begin
  VInDataSet:=Value;
end;

procedure TNCmd.SetCommit(const Value:Integer);
begin
  VCommit:=Value;
end;

procedure TNCmd.SetHeadCmd(const Value:String);//Kirim Bulk Data
begin
  VHeadCmd:=Value;
end;

procedure TNCmd.SetEndCmd(const Value:String);//Kirim Bulk Data
begin
  VEndCmd:=Value;
end;

procedure TNCmd.SetConStr(const Value:String);//Kirim Bulk Data
begin
  VConStr:=Value;
end;

procedure TNCmd.SetType(const Value:String);//Type Cmd
begin
  VType:=Value;
end;

function TNCmd.Connect;//Connect
type
  TFunc_Start = function(ConnStr,Dmz,Err :Pstring;var Conn,NSess,Zip,Crypt :Pointer):boolean; stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  SMsg,Err      : String;
begin
  NCritSec.enter;
  try
    HDll := 0;
    hDll   := LoadLibrary(PChar(Vtype+'moddb.dll') );
    if(hDll < 32) then
    begin
      sMsg := 'File ' + Vtype+'moddb.dll' + ' Tidak di temukan !';
      VERRData.Text:=SMsg;
    end;
    FuncPtr := GetProcAddress(hDll, PChar('Connect') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      IsConnect := Func_Start(@VConStr,@VDmz,@Err, VConn,VNSess,VZip,VCrypt);
      if not IsConnect then
      begin
        VERRData.Text:=Err;
        FreeLibrary( hDll );
      end;
      Result:= IsConnect;
    end else
    begin
      VERRData.Text:='Fungsi Connect tidak ada dalam dll';
      Result := False;
      FreeLibrary( hDll );
    end;
  except
    VERRData.Text:=Err;
    Result := False;
  end;
  NCritSec.Leave;
  AddLog;
end;

function TNCmd.DisConnect;//DisConnect
type
  TFunc_Start = function(Conn:Pointer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  //SMsg          : String;
begin
    Result:=true;
    try
      if (hDll >= 32) and IsConnect then
      begin
        FuncPtr := GetProcAddress(hDll, PChar('DisConnect') );
        @Func_Start := FuncPtr;
        if(@Func_Start<>nil)then
        begin
          Result:= Func_Start(VConn);
          if Vconn<>nil then
            FreeAndNil(VConn);
          if VNSess<>nil then
            FreeAndNil(VNSess);
          if VZip<>nil then
            FreeAndNil(VZip);
          if VCrypt<>nil then
            FreeAndNil(VCrypt);
        end else
        begin
          Result := False;
          VERRData.Text:='Fungsi Disconnet tidak ada dalam dll';
        end;
        FreeLibrary( hDll );
      end;
    Except
      Result:=False;
    end;
    IsConnect:=false;
    AddLog;
end;

function TNCmd.Open;//Ada Balikan
type
  TFunc_Start = function(Cmd,Conn,NSess,Zip,Crypt :Pointer;Dmz,Err :Pstring;var DtSet:Pointer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  PCmd          : Pointer;
  isEmpty       : Boolean;
  Err         : String;
  i             : Integer;
begin
  Result:=true;
  if not IsConnect then
    Connect;
  try
    PCmd:=VSQL;
    FuncPtr := GetProcAddress(hDll, PChar('Open') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      if not Func_Start(PCmd,VConn,VNSess,VZip,VCrypt,@VDmz,@Err,VPDataSet) then
      begin
        VERRData.Text:=Err;
        Result := False;
      end else
      begin
        VOutDataSet := Tmem.Create(nil);
        VOutFmt := TFmt.Create(nil);
        VOutDataSet.DefaultFormat := VOutFmt;
        if VPDataSet<>nil then
        begin

          if upperCase(VType)='SOCK' then
          begin
            VOutDataSet.LoadFromStream(VPDataSet);
            VCount:=VOutDataSet.RecordCount;
            if VCount=1 then
            begin
              isEmpty:=true;
              for i:=0 to VOutDataSet.FieldCount-1 do
              begin
                if not VOutDataSet.Fields[i].IsNull then
                  isEmpty:=False;
              end;
              if isEmpty then
                VCount:=0;
            end;
            FreeAndNil(VPDataSet);
          end else
          begin
            VOutDataSet.LoadFromDataSet(VPDataSet,[mtcpoStructure]);
            VCount:=VOutDataSet.RecordCount;
            if VCount=1 then
            begin
              isEmpty:=true;
              for i:=0 to VOutDataSet.FieldCount-1 do
              begin
                if not VOutDataSet.Fields[i].Isnull then
                   isEmpty:=False;
              end;
              if isEmpty then
                VCount:=0;
            end;

            FreeAndNil(VPDataSet);
          end;
        end else
          VCount:=0;
        {
        if upperCase(VType)='SOCK' then
        begin
          if VPDataSet<>Nil then
          begin
            VOutDataSet.LoadFromStream(VPDataSet);
            VCount:=VOutDataSet.RecordCount;
            if VCount=1 then
            begin
              isEmpty:=true;
              for i:=0 to VOutDataSet.FieldCount-1 do
              begin
                if not VOutDataSet.Fields[i].IsNull then
                  isEmpty:=False;
              end;
              if isEmpty then
                VCount:=0;
            end;
            FreeAndNil(VPDataSet);
          end else
            VCount:=0;
        end else
        begin
          VOutDataSet.LoadFromDataSet(VPDataSet,[mtcpoStructure]);
          VCount:=VOutDataSet.RecordCount;
          if VCount=1 then
          begin
            isEmpty:=true;
            for i:=0 to VOutDataSet.FieldCount-1 do
            begin
              if not VOutDataSet.Fields[i].Isnull then
                 isEmpty:=False;
            end;
            if isEmpty then
              VCount:=0;
          end;

          FreeAndNil(VPDataSet);
        end;
        }
      end;
    end else
    begin
      Result := False;
      VERRData.Text:='Fungsi Open tidak ada dalam dll';
    end;
  Except
    Result:=False;
    VERRData.Text:='Fungsi Open tidak ada dalam dll';
  end;
  AddLog;
end;

function TNCmd.ExecSql:Boolean; //Balikan true / false
type
  TFunc_Start = function(Cmd,Conn,NSess,Zip,Crypt :Pointer;Dmz,Err :Pstring):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  PCmd          : Pointer;
  Err          : String;
begin
  Result:=true;
  if not IsConnect then
    Connect;
  try
    PCmd:=VSQL;
    FuncPtr := GetProcAddress(hDll, PChar('ExecSql') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      if not Func_Start(PCmd,VConn,VNSess,VZip,VCrypt,@VDmz,@Err) then
      begin
        Result := False;
        VERRData.Text:=Err;
      end;
    end else
    begin
      Result := False;
      VERRData.Text:='Fungsi ExecSql tidak ada dalam dll';
    end;
  Except
    VERRData.Text:='Fungsi ExecSql tidak ada dalam dll';
    Result:=False;
  end;
  AddLog;
  VSQL.Clear;
end;

function TNCmd.SendData;//Kirim Bulk Data PR Penanganan Error
type
  TFunc_Start = function(Data,Conn,NSess,Zip,Crypt :Pointer;Dmz :Pstring; Hdata,Edata:PString; Var ErrData:Pointer; Row:Integer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  PCmd ,PErr   : Pointer;
begin
  Result:=true;
  if not IsConnect then
    Connect;
    try                                                                                                                                                                                                                                                                                                                                                                                         TimePMString:='';
      PCmd:=VSQL;
      PErr:=VERRData;
      FuncPtr := GetProcAddress(hDll, PChar('SendData') );
      @Func_Start := FuncPtr;
      if(@Func_Start<>nil)then
      begin
        if not Func_Start(PCmd,VConn,VNSess,VZip,VCrypt,@VDmz,@VHeadCmd,@VEndCmd,PErr,VCommit) then
          Result := False;
      end else
      begin
        Result := False;
        VERRData.Text:='Fungsi SendData tidak ada dalam dll';
      end;
    Except
      Result:=False;
      VERRData.Text:='Fungsi SendData tidak ada dalam dll';
    end;
    AddLog;
    VSQL.Clear;
end;

function TNCmd.SendFile;//Kirim Bulk Data PR Penanganan Error
type
  TFunc_Start = function(Data,Conn,NSess,Zip,Crypt :Pointer;Dmz :Pstring; Hdata,Edata:PString; Var ErrData:Pointer; Row:Integer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  PCmd, PErr    : Pointer;
begin
  Result:=true;
  if not IsConnect then
  Connect;
  try
    PCmd:=VSQL;
    PErr:=VERRData;
    FuncPtr := GetProcAddress(hDll, PChar('SendFile') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      if not Func_Start(PCmd,VConn,VNSess,VZip,VCrypt,@VDmz,@VHeadCmd,@VEndCmd,PErr,VCommit) then
        Result := False;
    end else
    begin
      Result := False;
      VERRData.Text:='Fungsi SendFile tidak ada dalam dll';
    end;
  Except
    Result:=False;
    VERRData.Text:='Fungsi SendFile tidak ada dalam dll';
  end;
  AddLog;
  VSQL.Clear;
end;

function TNCmd.SendDataSet;//Kirim Bulk Data PR Penanganan Error
type
  TFunc_Start = function(Data,Conn,NSess,Zip,Crypt :Pointer;Dmz :Pstring; Hdata,Edata:PString; Var ErrData:Pointer; Row:Integer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  PCmd, PErr    : Pointer;  //Pzipmem,
  //SMsg          : String;
begin
  Result:=true;
  if not IsConnect then
    Connect;
  try
    if upperCase(VType)='SOCK' then
    begin
      PCmd:=TmemoryStream.create;
      if VInDataSet=nil then
        VInData.SaveToStream(PCmd)
      else
        VInDataSet.SaveToStream(PCmd);
    end else
    begin
       if VInDataSet=nil then
         PCmd:=VInData
       else
         PCmd:=VInDataSet;
    end;
    PErr:=VERRData;
    FuncPtr := GetProcAddress(hDll, PChar('SendDataSet') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin                                                                                                                                                          if not Func_Start(PCmd,VConn,VNSess,VZip,VCrypt,@VDmz,@VHeadCmd,@VEndCmd,PErr,VCommit) then
      begin
        Result := False;
      end;
    end else
    begin
      Result:=False;
      VERRData.Text:='Fungsi SendDataset tidak ada dalam dll';
    end;
  Except
    Result:=False;
    VERRData.Text:='Fungsi SendDataset tidak ada dalam dll';
  end;
  AddLog;
  VSQL.Clear;
end;

procedure TNCmd.Close(Const DtSet:Pointer);
var
  DataSet:pointer;
begin
  if IsConnect then
  begin
    try
      if DtSet=nil then
      begin
        DataSet:=VoutDataSet
      end else
      begin
        DataSet:= DtSet;
      end;
      VCount:=0;
      FreeAndNil(DataSet);
    Except
    end;
  end;
end;

procedure TNCmd.Close(const Value:Boolean=true);
type
  TFunc_Start = function(Cmd:integer;Conn,NSess,Zip,Crypt :Pointer;var DtSet:Pointer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  //SMsg          : String;
begin
  if IsConnect then
  begin
    try
      FuncPtr := GetProcAddress(hDll, PChar('Close') );
      @Func_Start := FuncPtr;
      if(@Func_Start<>nil)then
      begin
        if value then
          Func_Start(0,VConn,VNSess,VZip,VCrypt,VPDataSet) //commit
        else
          Func_Start(-1,VConn,VNSess,VZip,VCrypt,VPDataSet);//roollback
      end else
      begin
        //sMsg := 'Fungsi Close tidak ada dalam dll';
        //MessageBox(0, PChar( sMsg ), 'Error',MB_OK );
      end;
    Except

    end;
    VCount:=0;
  end;
end;

procedure TNCMD.Close(const value:boolean;DtSet:Pointer);
type
  TFunc_Start = function(Cmd:integer;Conn,NSess,Zip,Crypt :Pointer;var DtSet:Pointer):boolean;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  //SMsg          : String;
  DataSet       : Pointer;
begin
  if IsConnect then
  begin
    try
      FuncPtr := GetProcAddress(hDll, PChar('Close') );
      @Func_Start := FuncPtr;
      if(@Func_Start<>nil)then
      begin
        if DtSet = nil then
        begin
          DataSet:=VoutDataSet;
          if value then
            Func_Start(0,VConn,VNSess,VZip,VCrypt,VPDataSet) //commit
          else
            Func_Start(-1,VConn,VNSess,VZip,VCrypt,VPDataSet);//roollback
            FreeAndNil(DataSet);
        end else
        begin
          DataSet:=DtSet;
          if value then
            Func_Start(0,VConn,VNSess,VZip,VCrypt,VPDataSet) //commit
          else
            Func_Start(-1,VConn,VNSess,VZip,VCrypt,VPDataSet);//roollback
            FreeAndNil(DataSet);
        end;
      end else
      begin
        //sMsg := 'Fungsi Close tidak ada dalam dll';
        //MessageBox(0, PChar( sMsg ), 'Error',MB_OK );
      end;
    Except

    end;
    VCount:=0;
  end;
end;

end.
