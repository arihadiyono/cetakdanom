unit NUtility;


interface

uses
  Classes,Forms,SysUtils,NCrypt, NMessage, NZip, Windows, Registry,winsock,NB30;

  function BacaDataTeks(Str, Pad: String; Posisi: Byte): String;
  function BikinUang(Str:String):String;
  function GetDosOutput(const CommandLine: string): string;
  function LoadDll(sDLL,sFunc : string;PDb,PLst,PApp:pointer): boolean;
  function MakeCmd(InData,Str,Data :String):String;
  function MsgBox(Msg1,Msg2,Msg3:String;Mode:Integer):Boolean;
  function NomorJadiKata(Str:String):String;
  function NowToStr(wkt:TDateTime):String;
  function Padding(Str:String;posisi,Jumlah:Integer;kar:Char):String;
  function Parser(var indata:string;dmz :string):string;
  function Petik(Data:String):String;
  function StrToMd5(Str:String):String;
  function GetIP:String;
  function GetMAC:String;
  function GetRegData(RootKey: HKEY; Key,Value: string): variant;
  procedure SetRegData(RootKey: HKEY; Key, Value: string;
  RegDataType: TRegDataType; Data: variant);
  procedure DelRegData(RootKey: HKEY; Key, Value: string);
const
  arrBulan : array [1..12] of string = ('Januari','Februari','Maret','April',
                                       'Mei','Juni','Juli','Agustus','September',
                                       'Oktober','Nopember','Desember');

  ArrHari : array [1..7] of string = ('Minggu','Senin','Selasa','Rabu','Kamis','Jum''At','Sabtu');

  arrAngka : array[1..19] of string =
  ('satu','dua','tiga','empat','lima','enam','tujuh','delapan','sembilan',
  'sepuluh','sebelas','dua belas','tiga belas','empat belas','lima belas',
  'enam belas','tujuh belas','delapan belas','sembilan belas');

implementation

function GetIP:string;
type
  TapInAddr = array[0..10] of Pinaddr;
  PaPinAddr = ^TapInAddr;
var
  phe:PhostEnt;
  pptr:PaPInAddr;
  Buffer:array[0..63] of char;
  I:integer;
  GInitData:TWSAData;
  IPs:TStrings;
begin
  WSAStartup($101,GInitData);
  IPs:=Tstringlist.create;
  IPs.clear;
  GethostName(buffer,Sizeof(Buffer));
  phe:=Gethostbyname(Buffer);
  if phe=nil then exit;
  pptr:=PaPInAddr(phe^.h_addr_list);
  I:=0;
  while pptr^[I] <> nil do
  begin
    IPs.add(inet_ntoa(pptr^[I]^));
    Inc(I);
  end;
  WSACleanup;
  Result:=IPs.Strings[0];
end;

function GetMAC: string;
var 
  NCB: PNCB; 
  Adapter: PAdapterStatus;
  //URetCode: PChar;
  RetCode: char; 
  I: integer; 
  Lenum: PlanaEnum; 
  _SystemID: string; 
  //TMPSTR: string; 
begin 
  Result    := ''; 
  _SystemID := ''; 
  Getmem(NCB, SizeOf(TNCB)); 
  Fillchar(NCB^, SizeOf(TNCB), 0); 
  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0); 
  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);
  Lenum.Length    := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer  := Pointer(Lenum);
  NCB.ncb_length  := SizeOf(Lenum);
  RetCode         := Netbios(NCB);
  i := 0;
  repeat 
    Fillchar(NCB^, SizeOf(TNCB), 0); 
    Ncb.ncb_command  := chr(NCBRESET); 
    Ncb.ncb_lana_num := lenum.lana[I]; 
    RetCode          := Netbios(Ncb);
    Fillchar(NCB^, SizeOf(TNCB), 0); 
    Ncb.ncb_command  := chr(NCBASTAT); 
    Ncb.ncb_lana_num := lenum.lana[I]; 
    // Must be 16 
    Ncb.ncb_callname := '*               ';
    Ncb.ncb_buffer := Pointer(Adapter);
    Ncb.ncb_length := SizeOf(TAdapterStatus); 
    RetCode        := Netbios(Ncb); 
    //---- calc _systemId from mac-address[2-5] XOR mac-address[1]... 
    if (RetCode = chr(0)) or (RetCode = chr(6)) then 
    begin 
      _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' + 
        IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' + 
        IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' + 
        IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' + 
        IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[5]), 2);
    end;
    Inc(i);
  until (i >= Ord(Lenum.Length)) or (_SystemID <> '00-00-00-00-00-00');
  FreeMem(NCB); 
  FreeMem(Adapter); 
  FreeMem(Lenum); 
  GetMac := _SystemID; 
end;

function BacaDataTeks(Str, Pad: String; Posisi: Byte): String;
var
  Hasil : String;
  i : Byte;
begin
  if Posisi = 1 then
     Hasil := Copy(Str,0,Pos(Pad,Str)-1)
  else begin
      for i := 1 to Posisi-1 do begin
         Hasil := Copy(Str, Pos(Pad,Str)+1,length(Str));
         Str := Hasil;
      end;
      if Pos(Pad,Str) > 0 then
         Hasil := Copy(Str,0,Pos(Pad,Str)-1)
      else
         Hasil := Copy(Str,0,length(Str));
  end;
  Result := Hasil;
end;

function BikinUang(str:String):String;
var
  uang : Real;
begin
  uang := StrToFloat(str);
  BikinUang := FloatToStrF(uang,ffNumber,14,0);
end;

function GetDosOutput(const CommandLine: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of Char;
  BytesRead: Cardinal;
  WorkDir, Line: string;
begin
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  {create pipe for standard output redirection}
  CreatePipe(StdOutPipeRead, {read handle}
    StdOutPipeWrite, {write handle}
    @SA, {security attributes}
    0 {number of bytes reserved for pipe - 0 default}
    );
  try
    {Make child process use StdOutPipeWrite as standard out, and
    make sure it does not show on screen}
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); {don't redirect stdinput}
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := '';
    WasOK := CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, nil, SI,
      PI);
      CloseHandle(StdOutPipeWrite);

    if not WasOK then
      raise Exception.Create('Could not execute command line!')
    else
    try
      Line := '';
      repeat
        WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
        if BytesRead > 0 then
        begin
          Buffer[BytesRead] := #0;
          Line := Line + Buffer;
        end;
      until
        not WasOK or (BytesRead = 0);
      WaitForSingleObject(PI.hProcess, INFINITE);
    finally
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
    end;
  finally
    result := Line;
    CloseHandle(StdOutPipeRead);
  end;
end;

function LoadDll(sDLL,sFunc : string;PDb,PLst,PApp:pointer): boolean;
type
  TFunc_Start = function(PDb,PLst,PApp:pointer):integer;stdcall;
var
  Func_Start : TFunc_Start;
  hDll       : THandle;
  FuncPtr    : TFarProc;
begin
  Result := False;
  hDll   := LoadLibrary(PChar( sDLL ) );
  if(hDll > 32)then
  begin
    FuncPtr := GetProcAddress(hDll, PChar( sFunc ) );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      Func_Start(PDb,PLst,PApp);
      Result := True;
    end;
  end;
end;

function MakeCmd(InData,Str,Data :String):String;
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

function MsgBox(Msg1,Msg2,Msg3:String;Mode:Integer):Boolean;
begin
  with TNMessage.Create do
  begin
    Result := MsgBox(Msg1,Msg2,Msg3,Mode);
    Application.ProcessMessages;
    Free;
  end;
end;

function NomorJadiKata(Str:String):String;
var
  fUang : int64;
  Hsl,kiri,kanan : Integer;
  StrUang : String;
  Kesini : BOOLEAN;
begin
   kesini := FALSE;
   StrUang := '';
   fUang := strtoint(Str);
   Hsl := fUang DIV 1000000000; //Puluhan Milyar
   if Hsl > 0 then begin
     if Hsl > 19 then begin
        Kiri  := Hsl DIV 10;
        Kanan := Hsl MOD 10;
        StrUang := StrUang + arrAngka[Kiri] + ' puluh ';
        if Kanan <> 0 then
           StrUang := StrUang + arrAngka[Kanan] + ' ';
     end else
        StrUang := StrUang + arrAngka[Hsl] + ' ';

     StrUang := StrUang + 'milyar ';
     fUang := fuang - (Hsl * int64(1000000000));
   end;
   //ratusan juta
   Hsl := fUang DIV 100000000;
   if Hsl > 0 then begin
      Kesini := TRUE;
      if Hsl = 1 then
         StrUang := StrUang + 'seratus '
      else
         StrUang := StrUang + arrAngka[Hsl] + ' ratus ';
      fUang := fUang - (Hsl * 100000000);
   end;
   //puluhan s/d 1 jutaan
   Hsl := fUang DIV 1000000;
   if Hsl > 0 then begin
      if Hsl > 19 then begin
        Kiri  := Hsl DIV 10;
        Kanan := Hsl MOD 10;
        StrUang := StrUang + arrAngka[Kiri] + 'puluh ';
        if Kanan <> 0 then
           StrUang := StrUang + arrAngka[Kanan] + ' ';
      end else
          StrUang := StrUang + arrAngka[Hsl] + ' ';
      StrUang := StrUang + 'juta ';
      fUang := fuang - (Hsl * int64(1000000));
   end else if Kesini then begin
      StrUang := StrUang + 'juta ';
      Kesini := FALSE;
   end;
   //ratusan ribu
   Hsl := fUang DIV 100000;
   if Hsl > 0 then begin
      //Kesini := TRUE;
      if Hsl = 1 then
         StrUang := StrUang + ' seratus '
      else
         StrUang := StrUang + arrAngka[Hsl] + ' ratus ';
      fUang := fUang - (Hsl * 100000);
      //Kesini := TRUE;
   end;
   Hsl := fUang DIV 1000;
   if Hsl > 0 then begin
      if Hsl > 19 then begin
        Kiri  := Hsl DIV 10;
        Kanan := Hsl MOD 10;
        StrUang := StrUang + arrAngka[Kiri] + ' puluh ';
        if Kanan <> 0 then
           StrUang := StrUang + arrAngka[Kanan] + ' ';
      end else
          StrUang := StrUang + arrAngka[Hsl] + ' ';
      StrUang := StrUang + 'ribu ';
      fUang := fuang - (Hsl * int64(1000));
   end else if Kesini then begin
      StrUang := StrUang + 'ribu ';
     // Kesini := FALSE;
   end;
   //ratusan
   Hsl := fUang DIV 100;
   if Hsl > 0 then begin
      //Kesini := TRUE;
      if Hsl = 1 then
         StrUang := StrUang + 'seratus '
      else
         StrUang := StrUang + arrAngka[Hsl] + ' ratus ';
      fUang := fUang - (Hsl * 100);
     // Kesini := TRUE;
   end;
   Hsl := fUang DIV 1;
   if Hsl > 0 then begin
      if Hsl > 19 then begin
        Kiri  := Hsl DIV 10;
        Kanan := Hsl MOD 10;
        StrUang := StrUang + arrAngka[Kiri] + ' puluh ';
        if Kanan <> 0 then
           StrUang := StrUang + arrAngka[Kanan] + ' ';
      end else
          StrUang := StrUang + arrAngka[Hsl] + ' ';
   end;
   Result := StrUang;
end;

function NowToStr(Wkt:TDateTime):String;
begin
   result:=formatdatetime('dd/mm/yy hh:nn:ss:zzz',Wkt);
end;

function Padding(str:String;posisi,Jumlah:Integer;kar:Char):String;
begin
   if Posisi = 0 then
      Padding := StringofChar(kar,Jumlah-length(str))+Str
   else
      Padding := Str+StringOfChar(kar,Jumlah-length(str));
end;

function Parser(var InData:string;Dmz :string):string;
var
  Tmp:string;
  pd,ld:integer;
begin
   InData:=trim(InData);
   if (length(InData)<>0) then
   begin
      pd:=pos(Dmz,InData);
      ld:=length(Dmz);
      Tmp:=copy(InData,1,pd-1);
      if (pd=0)then
      begin
        Result:=InData;
        InData:='';
      end else
      begin
        Result:= Tmp;
        InData:=copy(InData,pd+ld,length(InData));
      end;
   end else
     Result:= '';
end;

function Petik(Data:String):String;
begin
   Result:=chr(39)+Data+Chr(39);
   //Result:= Data;
end;

function StrToMd5(Str:String):String;
begin
   with TNHash.create do
   begin
     Result:= GetHash(Str);
     Free;
   end;
end;

function GetRegData(RootKey: HKEY; Key,
  Value: string): variant;
var
  Reg: TRegistry;
  RegDataType: TRegDataType;
  DataSize, Len: integer;
  s: string;
label
  cantread;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_QUERY_VALUE);
    Reg.RootKey := RootKey;
    if Reg.OpenKeyReadOnly(Key) then
    begin
      try
        RegDataType := Reg.GetDataType(Value);
        if (RegDataType = rdString) or
          (RegDataType = rdExpandString) then
          Result := Reg.ReadString(Value)
        else if RegDataType = rdInteger then
          Result := Reg.ReadInteger(Value)
        else if RegDataType = rdBinary then
        begin
          DataSize := Reg.GetDataSize(Value);
          if DataSize = -1 then
            raise Exception.Create(SysErrorMessage(ERROR_CANTREAD));
          SetLength(s, DataSize);
          Len := Reg.ReadBinaryData(Value, PChar(s)^, DataSize);
          if Len <> DataSize then
            raise Exception.Create(SysErrorMessage(ERROR_CANTREAD));
          Result := s;
        end
        else
          raise Exception.Create(SysErrorMessage(ERROR_CANTREAD));
      except
        s := ''; // Deallocates memory if allocated
        Reg.CloseKey;
        raise;
      end;
      Reg.CloseKey;
    end
    else
      raise Exception.Create(SysErrorMessage(GetLastError));
  except
    Reg.Free;
    raise;
  end;
  Reg.Free;
end;

procedure SetRegData(RootKey: HKEY; Key, Value: string;
  RegDataType: TRegDataType; Data: variant);
var
  Reg: TRegistry;
  s: string;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_WRITE);
    Reg.RootKey := RootKey;
    if Reg.OpenKey(Key, True) then
    begin
      try
        if RegDataType = rdUnknown then
          RegDataType := Reg.GetDataType(Value);
        if RegDataType = rdString then
          Reg.WriteString(Value, Data)
        else if RegDataType = rdExpandString then
          Reg.WriteExpandString(Value, Data)
        else if RegDataType = rdInteger then
          Reg.WriteInteger(Value, Data)
        else if RegDataType = rdBinary then
        begin
          s := Data;
          Reg.WriteBinaryData(Value, PChar(s)^, Length(s));
        end
        else
          raise Exception.Create(SysErrorMessage(ERROR_CANTWRITE));
      except
        Reg.CloseKey;
        raise;
      end;
      Reg.CloseKey;
    end
    else
      raise Exception.Create(SysErrorMessage(GetLastError));
  except
    Reg.Free;
    raise;
  end;
  Reg.Free;
end;

procedure DelRegData(RootKey: HKEY; Key, Value: string);
var
  Reg: TRegistry;
begin
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_WRITE);
    Reg.RootKey := RootKey;
    if Reg.OpenKey(Key, True) then
    begin
      try
        if value='' then
          Reg.DeleteKey(Key)
        else
          Reg.DeleteValue(value);
      except
        Reg.CloseKey;
        raise;
      end;
      Reg.CloseKey;
    end
    else
      raise Exception.Create(SysErrorMessage(GetLastError));
  except
    Reg.Free;
    raise;
  end;
  Reg.Free;
end;
end.
