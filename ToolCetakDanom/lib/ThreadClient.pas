unit ThreadClient;

interface

uses
  Classes, SysUtils, NConn, Db, Nutility;

type
  TNThread = class(TThread)
  private
    { Private declarations }
    VRun,
    VStop,
    VError,
    VInisialisasi,
    VSinkronisasi       : Boolean;
    VBlok               : Integer;
    Q,
    Q1                  :TNCmd;
    VOutput,
    VEOutput            : TStrings;
    VKdVer,
    VKdKtr,
    VkdPet              : String;
    VProses             : Integer;
    VControl            : Pointer;
    procedure SetBlok(Const value:Integer);
    procedure SetControl(Const value:Pointer);
    procedure SetDownConn(Const value:TNCmd);
    procedure SetUpConn(Const value:TNCmd);
    procedure SetOutput(Const value:TStrings);
    procedure SetEOutput(Const value:TStrings);
    procedure SetRun(Const value:boolean);
    procedure SetInisialisasi(Const value:boolean);
    procedure SetSinkronisasi(Const value:boolean);
    procedure SetKdPet(Const value:String);
    procedure SetKdKtr(Const value:String);
    procedure SetKdVer(Const value:String);
    procedure Plog(Const value:String);
    function inisialisasi:boolean;
    function singkronisasi:boolean;
    function Petik(Const value:String):String;
    function MakeCmd(Const InData,Str,Data :String):String;
    function NowToStr(Const Value:TDateTime):String;
  protected
    procedure Execute; override;
  public
    property Blok : Integer write SetBlok;
    property IsStop : Boolean Read Vstop ;
    property Control : Pointer Read VControl write SetControl;
    property DownConn : TNCmd Read Q write SetDownConn;
    property UpConn : TNCmd Read Q1 write SetUpConn;
    property OutPut : TStrings Read VOutput write SetOutput;
    property EOutPut : TStrings Read VEOutput write SetEOutput;
    property KdPet : String Read VKdPet write SetKdPet;
    property KdKtr : String Read VKdKtr write SetKdKtr;
    property KdVer : String Read VKdVer write SetKdVer;
    property IsInisialisasi : Boolean Read VInisialisasi write Setinisialisasi;
    property IsSinkrosasi : Boolean Read VSinkronisasi write SetSinkronisasi;
    property IsError : Boolean Read VError;
    property Run : Boolean Read VRun write SetRun;
    property Proses : Integer Read VProses;
  end;

implementation

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure NThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ NThread }
procedure TNThread.SetBlok(Const value:Integer);
begin
  VBlok := Value;
end;

procedure TNThread.SetDownConn(Const value:TNCmd);
begin
  Q := Value;
end;

procedure TNThread.SetUpConn(Const value:TNCmd);
begin
  Q1 := Value;
end;

procedure TNThread.SetOutPut(Const value:TStrings);
begin
  VOutPut := Value;
end;

procedure TNThread.SetKdKtr(Const value:String);
begin
  VKdKtr := Value;
end;

procedure TNThread.SetKdPet(Const value:String);
begin
  VKdPet := Value;
end;

procedure TNThread.SetKdVer(Const value:String);
begin
  VKdVer := Value;
end;

procedure TNThread.SetEOutPut(Const value:TStrings);
begin
  VEOutPut := Value;
end;

function TNThread.MakeCmd(Const InData,Str,Data :String):String;
var
  TmpData :String;
begin
  if pos(UpperCase(Str),UpperCase(InData)) > 0 then
  begin
     TmpData:= Copy(InData,0,pos(UpperCase(Str),UpperCase(InData))-1);
     Result:=TMpData+ Data+ Copy(InData,pos(UpperCase(Str),UpperCase(InData))+Length(Str),Length(InData))
  end else
    Result:=InData;
end;

function TNThread.Petik(Const value:String):String;
begin
   Result:=chr(39)+Value+Chr(39);
end;

procedure TNThread.SetControl(Const value:Pointer);
begin
  VControl := Value;
end;

procedure TNThread.SetRun(Const value:Boolean);
begin
  VRun := Value;
end;

procedure TNThread.SetInisialisasi(Const value:Boolean);
begin
  VInisialisasi := Value;
end;

procedure TNThread.SetSinkronisasi(Const value:Boolean);
begin
  VSinkronisasi := Value;
end;

Procedure TNThread.PLog(Const Value:String);
begin
 If VOutPut <> Nil then
   VOutPut.Insert(0,NowToStr(Now)+' '+Value);
end;

function TNThread.NowToStr(Const Value:TDateTime):String;
begin
   result:=formatdatetime('dd/mm/yy hh:nn:ss:zzz',Value);
end;

function TNThread.Inisialisasi:boolean;
var
  Counts, Count, LCount:Integer;
  PDs,Pdw : Pointer;
  UCmd,
  DCmd,
  Ver,
  Ktr,
  Pet : String;
begin
  PDs:=nil;
  PDw:=nil;
  Ver:='$VER$';
  Ktr:='$KTR$';
  Pet:='$PET$';
  LCount:=0;
  try
    PLog('Baca versi nasional');
    Q1.SQL.text:='select * from SP_TVERSI_GET('+
                petik(VKdVer)+
               ')';
    if Q1.Open then
    begin
      if Q1.Count > 0 then
      begin
        Q.InDataSet:=Q1.Data;
        PDs :=Q1.Data;
      end;
      Counts:=Q1.Count;
    end else
    begin
      PLog('Gagal');
      Result:=False;
      Q1.Close;
      exit;
    end;
    Q1.Close;
    if Counts > 0 then
    begin
      //insert data versi di lokal
      PLog('Simpan '+inttostr(Counts)+' versi di lokal');
      Q.HeadCmd:='execute procedure SP_TVERSI_INS';
      if Q.SendDataSet then
        PLog('Sukses')
      else
      begin
        PLog('Gagal');
        Result:=False;
        VEOutPut:=Q.LastError;
        Q.Close;
        exit;
      end;
      Q.Close;
      Q1.Close(PDs);
      //TInisialisasi
      PLog('Baca inisialisasi');
      Q1.SQL.Text:='select * from SP_INISIALISASI_GET('+
                   petik(VKdVer)+')';
      if Q1.open then
      begin
        if Q1.Count > 0 then
        begin
          Q.InDataSet:=Q1.Data;
          PDs :=Q1.Data;
        end;
        Count:=Q1.Count;
      end else
      begin
        PLog('Gagal');
        Result:=False;
        Q1.Close;
        exit;
      end;
      Q1.Close;
      if Count > 0 then
      begin
        //Ambil data inisialisasi di lokal
        PLog('Ambil '+inttostr(Count)+' data inisialisasi');
        //looping ambil data inisialisasi
        while not Tmem(PDs).Eof do
        begin
          PLog('Baca '+LowerCase(Tmem(PDs).Fields[1].AsString));
          UCmd:= Tmem(PDs).Fields[4].AsString+' '+Tmem(PDs).Fields[5].AsString;
          DCmd:= Tmem(PDs).Fields[6].AsString+' '+Tmem(PDs).Fields[7].AsString;
          if Tmem(PDs).Fields[3].AsString='01' then //Ambil data
          begin
            UCmd:=MakeCmd(UCmd,Pet,Petik(VKdPet));
            UCmd:=MakeCmd(UCmd,Ktr,Petik(VKdKtr));
            UCmd:=MakeCmd(UCmd,Ver,Petik(VKdVer));
            Q1.SQL.Text:=UCmd;
            if Q1.open then
            begin
              if Q1.Count>0 then
              begin
                Q.InDataSet:=Q1.Data;
                PDw:=Q1.Data;
              end;
              LCount:=Q1.Count;
            end else
            begin
              PLog('Gagal');
              Result:=False;
              Q1.Close;
              exit;
            end;
            Q1.Close;
            if LCount > 0 then
            begin
              PLog('Simpan '+inttostr(LCount)+' data di lokal');
              Q.HeadCmd:=DCmd;
              if Q.SendDataSet then
                PLog('Sukses')
              else
              begin
                PLog('Gagal');
                Result:=False;
                VEOutPut:=Q.LastError;
                Q.Close;
                exit;
              end;
              Q.Close;
              Q1.Close(PDw);
            end;
          end else //Kirim data
          begin

          end;
          Tmem(PDs).Next;
        end;
        Q1.Close(PDs);
      end;
      //Update versi lokal
      PLog('Update versi');
      Q.SQL.Text:='execute procedure SP_TVERSI_UPD';
      if not Q.ExecSql then
      begin
        PLog('Gagal');
        Result:=False;
        Q.Close;
        exit;
      end else
      begin
        PLog('Sukses');
      end;
      Q.Close;
    end else
      PLog('Versi sama');
    Result:=true;
  except
    PLog('Gagal');
    Result:=False;
  end;
end;

function TNThread.Singkronisasi:boolean;
var
  Count,
  UCount,i,icount,ipos:Integer;
  PDs,
  PDw : Pointer;
  HCmd,
  ECmd,
  Ver,
  Ktr,
  Pet, Tmp : String;
  isBlob : Boolean;
  Data : TStrings;
begin
  PDs:=nil;
  PDw:=nil;
  Ver:='$VER$';
  Ktr:='$KTR$';
  Pet:='$PET$';
  Count:=0;
  UCount:=0;
  try
    Result:=true;
    PLog('Inisialisasi .... ');
    //Ambil data command bisa lokal / nasional
    Q.SQL.text:='select * from TSinkronisasi order by kd_kelompok,urut';
    {
    Field ID,Ket,Urut,Tipe,Up_Cmd,Cmd,Down_Cmd
    0 ID_SINKRONISASI -> Id command
    1 KET_SINKRONISASI -> Keterangan command
    2 URUT -> No Urut eksekusi comand
    3 TIPE -> Tipe command
      00-update Down command
      01-Down select command
      02-Down send command
      10-update Up command
      11-Up select command
      12-Up send command
      
    4 HCMD -> Head Cmd
    5 ECMD -> End Cmd
    }
    if Q.Open then
    begin
      Count:=Q.Count;
      PDs :=Q.Data;
      Q.Close;
      if Count > 0 then
      begin
        while not Tmem(PDs).Eof do
        begin
          if Tmem(PDs).Fields[3].AsString = '00' then //Down update
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString;
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString;
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if trim(HCmd+' '+ECmd) <> '' then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q.SQL.Clear;
              Q.SQL.Add(HCmd);
              Q.SQL.Add(ECmd);
              if not(Q.ExecSql) then
              begin
                Plog('Gagal update data di lokal');
                Tmem(PDs).Last;
                Result:=false;
                exit;
              end;
              Q.Close;
            end;
          end else
          if Tmem(PDs).Fields[3].AsString = '01' then //Down Select
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString; //update cmd
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString; //update cmd
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if trim(HCmd+' '+ECmd) <> '' then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q.SQL.Clear;
              Q.SQL.Add(HCmd);
              Q.SQL.Add(ECmd);
              if Q.open then
              begin
                if Q.Count>0 then
                begin
                  PDw:=Q.Data;
                end;
                UCount:=Q.Count;
              end else
              begin
                PLog('Gagal kirim data ke server');
                Tmem(PDs).Last;
                Result:=False;
                exit;
              end;
              Q.Close;
            end;
            PLog('Kirim '+inttostr(UCount)+' data ke server');
          end else
          if Tmem(PDs).Fields[3].AsString = '02' then //Down Send
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString; //update cmd
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString; //update cmd
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if (trim(HCmd+' '+ECmd) <> '')and (UCount >0) then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q.SQL.Clear;
              Q.HeadCmd:=HCmd;
              Q.EndCmd:=ECmd;
              Q.INDataSet:=TMem(PDw);
              if Q.SendDataSet then
                PLog('Sukses simpan data di lokal')
              else
              begin
                PLog('Gagal simpan data di lokal');
                Tmem(PDs).Last;
                Result:=False;
                VEOutPut:=Q.LastError;
                Exit;
              end;
              Q.Close;
              Q1.Close(PDw);
            end;
          end else
          if Tmem(PDs).Fields[3].AsString = '10' then //Up update
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString; 
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString;
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if trim(HCmd+' '+ECmd) <> '' then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q1.SQL.Clear;
              Q1.SQL.Add(HCmd);
              Q1.SQL.Add(ECmd);
              if not(Q1.ExecSql) then
              begin
                Plog('Gagal update data di server nasional');
                Tmem(PDs).Last;
                Result:=false;
                Exit;
              end;
              Q1.Close;
            end;
          end else
          if Tmem(PDs).Fields[3].AsString = '11' then //Up Select
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString;
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString;
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if trim(HCmd+' '+ECmd) <> '' then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q1.SQL.Clear;
              Q1.SQL.Add(HCmd);
              Q1.SQL.Add(ECmd);
              if Q1.open then
              begin
                if Q1.Count>0 then
                begin
                  PDw:=Q1.Data;
                end;
                UCount:=Q1.Count;
              end else
              begin
                PLog('Gagal ambil data dari server');
                Tmem(PDs).Last;
                Result:=False;
                Exit;
              end;
              Q1.Close;
            end;
            PLog('Ambil '+inttostr(UCount)+' data dari server');
          end else
          if Tmem(PDs).Fields[3].AsString = '12' then //Up Send
          begin
            HCmd:=Tmem(PDs).Fields[4].AsString;
            HCmd:=MakeCmd(HCmd,Pet,Petik(VKdPet));
            HCmd:=MakeCmd(HCmd,Ktr,Petik(VKdKtr));
            HCmd:=MakeCmd(HCmd,Ver,Petik(VKdVer));
            ECmd:=Tmem(PDs).Fields[5].AsString;
            ECmd:=MakeCmd(ECmd,Pet,Petik(VKdPet));
            ECmd:=MakeCmd(ECmd,Ktr,Petik(VKdKtr));
            ECmd:=MakeCmd(ECmd,Ver,Petik(VKdVer));
            if (trim(HCmd+' '+ECmd) <> '') and (UCount >0)  then
            begin
              PLog(Tmem(PDs).Fields[1].AsString);
              Q1.SQL.Clear;
              Q1.HeadCmd:=HCmd;
              Q1.EndCmd:=ECmd;
              //Ceck Tipe data ada blob  tambahan untuk optimalisasi kirim data
              isBlob:=false;
              for i:=0 to TMem(PDw).FieldCount-1 do
              begin
                if (TMem(PDw).Fields[i].DataType in[
                ftBlob,
                ftMemo,
                ftGraphic,
                ftFmtMemo,
                ftParadoxOle,
                ftDBaseOle,
                ftTypedBinary,
                ftCursor,
                ftADT,
                ftArray,
                ftReference,
                ftDataSet,
                ftOraBlob,
                ftOraClob,
                ftVariant,
                ftInterface,
                ftIDispatch,
                ftGuid
               ]) then
                 isblob:=true;
              end;
              if isblob then
              begin
                Q1.INDataSet:=TMem(PDw);
                if Q1.SendDataSet then
                  PLog('Sukses simpan data di nasional')
                else
                begin
                  //tampilkan
                  PLog('Gagal simpan data di nasional');
                  Tmem(PDs).Last;
                  Result:=False;
                  VEOutPut:=Q1.LastError;
                  Exit;
                end;
                Q1.Close;
                Q.Close(PDw);
              end else
              begin
              //Kirim data dalam string list
                //blok:=1000;
                icount:=0;
                ipos:=0;
                Data:=TStringList.Create;
                Tmp:='';
                TMem(PDw).First;
                while not (TMem(PDw).Eof) do
                begin
                  for i:=0 to TMem(PDw).FieldCount-1 do
                  begin
                    if (TMem(PDw).Fields[i].DataType in[
                      ftString,
                      ftDate,
                      ftTime,
                      ftDateTime,
                      ftFixedChar,
                      ftWideString
                      ]
                      )
                    then begin
                      if i= 0 then
                        Tmp:=Petik(TMem(PDw).Fields[i].AsString)
                      else
                        Tmp:= Tmp+','+Petik(TMem(PDw).Fields[i].AsString);
                    end else
                    begin
                      if i= 0 then
                        Tmp:=TMem(PDw).Fields[i].AsString
                      else
                        Tmp:= Tmp+','+TMem(PDw).Fields[i].AsString;
                    end;
                  end;
                  Data.Add(Tmp);
                  Tmp:='';
                  icount:=icount+1;
                  ipos:=ipos+1;
                  if (icount >= Vblok) then  //data blok
                  begin
                    Q1.SQL.Text:=Data.Text;
                    PLog('Simpan '+inttostr(ipos-(icount-1))+' - '+inttostr(ipos)+' data di nasional');
                    if Q1.SendData then
                    begin
                      PLog('Sukses simpan data di nasional')
                    end else
                    begin
                      PLog('Gagal simpan data di nasional');
                      Tmem(PDs).Last;
                      Result:=False;
                      VEOutPut:=Q1.LastError;
                      exit;
                    end;
                    Q1.Close;
                    Data.Clear;
                    icount:=0;
                  end;
                  TMem(PDw).Next;
                end;
                //kirim data
                if Data.Count>0 then
                begin
                  Q1.SQL.Text:=Data.Text;
                  PLog('Simpan '+inttostr(ipos-(icount-1))+' - '+inttostr(ipos)+' data di nasional');
                  if Q1.SendData then
                  begin
                    PLog('Sukses simpan data di nasional')
                  end else
                  begin
                    PLog('Gagal simpan data di nasional');
                    Tmem(PDs).Last;
                    Result:=False;
                    VEOutPut:=Q1.LastError;
                    Exit;
                  end;
                  Q1.Close;
                  icount:=0;
                end;
              end;
            end;
          end;
          Tmem(PDs).Next;
        end;
      end else
      begin
        PLog('Perintah kosong');
      end;
      Q.close(PDs);
    end else
    begin
      PLog('Terdapat kesalahan perintah');
      Result:=False;
      Q.Close;
      exit;
    end;
    Result:=true;
  except
    PLog('Gagal');
    Result:=False;
  end;
end;

procedure TNThread.Execute;
begin
   {Place thread code here }
  FreeOnTerminate := True;
  VRun:=True;
  if VInisialisasi then
  begin
    if inisialisasi then
    begin
      VError:=False;
      Plog('Sukses inisialisasi data');
    end
    else
    begin
      VError:=True;
      VEOutput:=Q.LastError;
      Plog('Gagal inisialisasi data');
    end;
    VRun:=False;
    VInisialisasi:=false;
  end;
  if VSinkronisasi then
  begin
    if singkronisasi then
    begin
      VError:=False;
      Plog('Sukses singkronisasi data');
    end
    else
    begin
      VError:=True;
      VEOutput:=Q1.LastError;
      Plog('Gagal singkronisasi data');
    end;
    VRun:=False;
    VSinkronisasi :=false;
  end;
end;

end.
