unit NSession;
{
  Unit yang berisi Class TNSession untuk mengelola session
  dari setiap koneksi
  Createdby     : Nasruddin Mohammad
  date          : 26 Maret 2005
  Version       : V 1.0.0 
  function      : Manage session
  Note          : Pencarian menggunakan sequensial perlu diperbaiki
}
interface

Uses
  Classes,SysUtils;

Type
   TSessId = string[32];
   TUserId = string[32];
   TCmd = integer;
   TCrypt = integer;
   TZipType = integer;

   TNSess = class(TObject) //Data Session
     SessionId:TSessId;
     UserId:TUserId;
     FirstCmd:TDateTime;
     LastCmd:TDateTime;
     Cmd:TCmd;
     CryptType:TCrypt;
     CryptKey:String;
     ZipType:TZipType;
     TimeOut:Integer;
     ThreadId:Pointer;
   end;
   //PSess = ^NSess;
   TNSession = class
     private
        VList:TThreadList;
        VPSession:TNSess;
        VSessionId:TSessId;
        VUserId:TUserId;
        VFirstCmd:TDateTime;
        VLastCmd:TDateTime;
        VCmd:TCmd;
        //VCount:Integer;
        VCryptType:TCrypt;
        VCryptKey:String;
        VZipType:TZipType;
        VTimeOut:Integer;
        VThreadId:Pointer;
        procedure SetSessionId(Const value :TSessId);
        procedure SetUserId(Const value :TUserId);
        procedure SetFirstCmd(Const value :TDateTime);
        procedure SetLastCmd(Const value :TDateTime);
        procedure SetCmd(Const value :TCmd);
        procedure SetCryptType(Const value :TCrypt);
        procedure SetCryptKey(Const value :String);
        procedure SetZipType(Const value :TZipType);
        procedure SetTimeOut(Const value :Integer);
        procedure SetThreadId(Const value :Pointer);
        function  Search(Const value :TSessId):Boolean;overload;
        function  Search(Const value :Integer):Boolean;overload;
        function GetCount:Integer;
     protected

     public
       property SessionId:TSessId read VSessionId write SetSessionId;
       property UserId:TUserId read VUserId write SetUserId;
       property FirstCmd:TDateTime read VFirstCmd write SetFirstCmd;
       property LastCmd:TDateTime read VlastCmd write SetLastCmd;
       property Cmd:TCmd read VCmd write SetCmd;
       property CryptType:TCrypt read VCryptType write SetCryptType;
       property CryptKey:String Read VCryptKey write SetCryptKey;
       property ZipType:TZipType read VZipType write SetZipType;
       property Timeout:Integer read VTimeOut write SetTimeOut;
       property ThreadId:Pointer read VThreadId write SetThreadId;
       property Count:Integer read GetCount;
       property SessObj:TNSess read VPSession;
       function Add:boolean;
       function EditSession(const value:TSessId):boolean;overload;
       function EditSession(const value:Integer):boolean;overload;
       function DelSession(const value:TSessId):boolean;overload;
       function DelSession(const value:Integer):boolean;overload;
       function DelTimeOut:Integer;
       function GetSession(const value:TSessId):boolean;overload;
       function GetSession(const value:Integer):boolean;overload;
       constructor Create;
       destructor Destroy;override;
     end;
implementation

procedure TNSession.SetSessionId(Const value :TSessId);
begin
   VSessionId:=Value;
end;

procedure TNSession.SetUserId(Const value :TUserId);
begin
  VUserId:=Value;
end;

procedure TNSession.SetFirstCmd(Const value :TDateTime);
begin
  VFirstCmd:=Value;
end;

procedure TNSession.SetLastCmd(Const value :TDateTime);
begin
  VLastCmd:=Value;
end;

procedure TNSession.SetCmd(Const value :TCmd);
begin
  VCmd:=Value;
end;

procedure TNSession.SetCryptType(Const value :TCrypt);
begin
  VCryptType:=Value;
end;

procedure TNSession.SetCryptKey(Const value :String);
begin
  VCryptKey:=Value;
end;

procedure TNSession.SetZipType(Const value :TZipType);
begin
  VZipType:=Value;
end;

procedure TNSession.SetTimeOut(Const value :Integer);
begin
  VTimeOut:=Value;
end;

procedure TNSession.SetThreadId(Const value :Pointer);
begin
  VThreadId:=Value;
end;

function TNSession.GetCount:Integer;
begin
  with Vlist.LockList do
    Try
      Result:=Count;
    Finally
      Vlist.UnlockList;
    end;
end;

function TNSession.Search(Const value :TSessId):Boolean;
var
  i:Integer;
begin
  Result:=False;
  i:=0;
  try
    with Vlist.LockList do
    Try
      while i < count do
      begin
        VPSession:=Items[i];
        if VPSession.SessionId=Value then
        begin
          Result:=True;
          i:=count;
        end;
        i:=i+1;
      end;
    Finally
      Vlist.UnlockList;
    end;
  except
    Result:=False;
  end;
end;

function TNSession.Search(Const value :Integer):Boolean;
begin
  Result:=True;
  try
    with Vlist.LockList do
    Try
      VPSession:=Items[value];
    Finally
      Vlist.UnlockList;
    end;
  except
    Result:=False;
  end;
end;

function TNSession.Add:Boolean;
//var
//  SessData:TNSess;
begin
  Result:=True;
  try
     VPSession:=TNsess.Create;
     with VPSession do
     begin
       SessionId:=VSessionId;
       UserId:=VUserId;
       FirstCmd:=VFirstCmd;
       LastCmd:=VLastCmd;
       Cmd:=VCmd;
       CryptType:=VCryptType;
       CryptKey:=VCryptKey;
       ZipType:=VZipType;
       TimeOut:=VTimeOut;
       ThreadId:=VThreadId;
     end;
     Vlist.Add(VPSession);
  except
    Result:=False;
  end;
end;

function TNSession.EditSession(Const value :TSessId):Boolean;
begin
  Result:=true;
  try
    if Search(value) then
    begin
      with VPSession do
      begin
         SessionId:=VSessionId;
         UserId:=VUserId;
         FirstCmd:=VFirstCmd;
         LastCmd:=VLastCmd;
         Cmd:=VCmd;
         CryptType:=VCryptType;
         CryptKey:=VCryptKey;
         ZipType:=VZipType;
         TimeOut:=VTimeOut;
         ThreadId:=VThreadId;
      end;
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

function TNSession.EditSession(Const value :Integer):Boolean;
begin
  Result:=true;
  try
    if Search(value) then
    begin
      with VPSession do
      begin
         SessionId:=VSessionId;
         UserId:=VUserId;
         FirstCmd:=VFirstCmd;
         LastCmd:=VLastCmd;
         Cmd:=VCmd;
         CryptType:=VCryptType;
         CryptKey:=VCryptKey;
         ZipType:=VZipType;
         TimeOut:=VTimeOut;
         ThreadId:=VThreadId;
      end;
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

function TNSession.DelSession(Const value :TSessId):Boolean;
begin
  Result:=true;
  try
    if Search(value) then
    begin
      with Vlist.LockList do
      Try
        Remove(VpSession);
      Finally
        Vlist.UnlockList;
      end;
      FreeAndNil(VpSession);
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

function TNSession.DelSession(Const value :Integer):Boolean;
begin
  Result:=True;
  try
    if Search(value) then
    begin
      with Vlist.LockList do
      Try
        Remove(VpSession);
      Finally
        Vlist.UnlockList;
      end;
      FreeAndNil(VpSession);
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

function TNSession.DelTimeout:Integer;
var
  i,c:Integer;
begin
  i:=0;
  c:=0;
  with Vlist.LockList do
  Try
    while i < count do
    begin
      VPSession:=Items[i];
      if (
      TimeStampToMSecs(DateTimeToTimeStamp(now))-
      TimeStampToMSecs(DateTimeToTimeStamp(VPSession.LastCmd))>VPSession.Timeout) then
      begin
        Remove(VpSession);
        c:=c+1;
        i:=i-1;
      end;
      i:=i+1;
    end;
  Finally
    Vlist.UnlockList;
  end;
  Result:=c;
end;

function TNSession.GetSession(Const value :TSessId):Boolean;
begin
  Result:=True;
  try
    if Search(value) then
    begin
      with VPSession do
      begin
        VSessionId:=SessionId;
        VUserId:=UserId;
        VFirstCmd:=FirstCmd;
        VLastCmd:=LastCmd;
        VCmd:=Cmd;
        VCryptType:=CryptType;
        VCryptKey:=CryptKey;
        VZipType:=ZipType;
        VTimeOut:=TimeOut;
        VThreadId:=ThreadId;
      end;
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

function TNSession.GetSession(Const value :Integer):Boolean;
begin
  Result:=True;
  try
    if Search(value) then
    begin
      with VPSession do
      begin
        VSessionId:=SessionId;
        VUserId:=UserId;
        VFirstCmd:=FirstCmd;
        VLastCmd:=LastCmd;
        VCmd:=Cmd;
        VCryptType:=CryptType;
        VCryptKey:=CryptKey;
        VZipType:=ZipType;
        VTimeOut:=TimeOut;
        VThreadId:=ThreadId;
      end;
    end else
      Result:=False;
  except
    Result:=False;
  end;
end;

constructor TNSession.Create;
begin
  VList:= TThreadList.Create;
end;

destructor TNSession.Destroy;
var
  i:Integer;
  PSession:TNSess;
begin
  if VList <> Nil then
  begin
    with Vlist.LockList do
    try
      for i:=0 to Count-1 do
      begin
        PSession:=Items[i];
        FreeAndNil(Psession);
      end;
      Clear;
    finally
      Vlist.UnlockList;
    end;
    FreeAndNil(VList);
  end;
end;

end.
