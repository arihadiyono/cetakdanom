unit NJobThread;

interface

uses
  Classes,SysUtils, jvuib, jvuiblib, jvuibdataset,Windows,Nfile;

type
  TNJobThread = class(TThread)
  private
    { Private declarations }
    VIdCmd,
    VCmd,
    VConStr,
    Vdir,
    VIpDb,
    VNameDb,
    VUserDb,
    VPassDb     :String;
    Vtipe       :Integer;
    VStatus     :Boolean;
    function RunCmd(const value:String):String;
    function RunSql(const value:String):Boolean;
    procedure SetCMd(const value:String);
    procedure SetConStr(const value:String);
    procedure SetDir(const value:String);
    procedure SetIdCMd(const value:String);
    procedure SetIpDb(const value:String);
    procedure SetNameDb(const value:String);
    procedure SetUserDb(const value:String);
    procedure SetPassDb(const value:String);
    procedure SetTipe(const value:Integer);
    procedure SetLog;
  protected
    procedure Execute; override;
  public
    property Cmd:String read VCmd write SetCmd;
    property ConStr:String read VConStr write SetConStr;
    property Dir:String read VDir write SetDir;
    property IdCmd:String read VIdCmd write SetIdCmd;
    property IpDb:String read VIpDb write SetIpDb;
    property NameDb:String read VIdCmd write SetNameDb;
    property UserDb:String read VIdCmd write SetUserDb;
    property PassDb:String read VIdCmd write SetPassDb;
    property Tipe:Integer read Vtipe write SetTipe;
  end;
  TNDb=TJvUIBDataBase;
  TNTr=TJvUIBTransaction;
  TNQ=TJvUIBScript;
implementation
{ TNJobThread }
function TNJobThread.RunCmd(const value: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead,
  StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of Char;
  BytesRead: Cardinal;
  WorkDir,
  Line: string;
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
    WasOK := CreateProcess(nil, PChar(value), nil, nil, True, 0, nil, nil, SI,
      PI);
      CloseHandle(StdOutPipeWrite);

    if not WasOK then
      line := 'Could not execute command line!'
      //raise Exception.Create('Could not execute command line!')
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

function TNJobThread.RunSql(const value:String):Boolean;
var
  NDb           : TNDb;
  Q             : TNQ;  // Query
  Tr            : TNTr; // Transaction
begin
  Try
    NDb:= TNDb.Create(Nil);
    NDb.LibraryName:=Vdir+'\dll\fbclient.dll';
    NDb.DatabaseName:=VIpDb+':'+VNameDb;
    NDb.UserName:=VUserDb;
    NDb.PassWord:=VPassDb;
    NDb.Connected:=True;
    Q:=TNQ.Create(nil);
    Tr:=TNTR.Create(Nil);
    Tr.DataBase:=NDb;
    Q.Transaction:=Tr;
    {   Commansql
    }
    Q.Script.Text:=Trim(VCmd);
    Q.ExecuteScript;
    Tr.Commit;
    Result:=True;
  Except
    Result:=False;
  end;
end;

procedure TNJobThread.SetCmd(const value:String);
begin
  VCmd:=Value;
end;

procedure TNJobThread.SetConStr(const value:String);
begin
  VConStr:=Value;
end;

procedure TNJobThread.SetDir(const value:String);
begin
  VDir:=Value;
end;

procedure TNJobThread.SetIdCmd(const value:String);
begin
  VIdCmd:=Value;
end;

procedure TNJobThread.SetIpDb(const value:String);
begin
  VIpDb:=Value;
end;

procedure TNJobThread.SetNameDb(const value:String);
begin
  VNameDb:=Value;
end;

procedure TNJobThread.SetUserDb(const value:String);
begin
  VUserDb:=Value;
end;

procedure TNJobThread.SetPassDb(const value:String);
begin
  VPassDb:=Value;
end;

procedure TNJobThread.SetLog;
var
  Log:TNLog;
begin
  { Place thread code here }
  Log:=TNlog.Create;
  Log.Dir:=Vdir+'log';
  If VStatus then
  begin
    Log.LogName:='JobS'+FormatDateTime('ddmmyyyy',now)+'.log';
    Log.Add(trim(VIdCmd));
  end else
  begin
    Log.LogName:='JobE'+FormatDateTime('ddmmyyyy',now)+'.log';
    Log.Add(trim(VIdCmd));
  end;
  FreeAndNil(Log);
end;

procedure TNJobThread.SetTipe(const value:Integer);
begin
  VTipe:=Value;
end;

procedure TNJobThread.Execute;
begin
  FreeOnTerminate:=True;
  while not Terminated do
  begin
    If Vtipe=0 then
    begin
      If RunSql(VCmd) then
      begin
        VStatus:=True;
        Synchronize(SetLog)
      end else
      begin
        VStatus:=False;
        Synchronize(SetLog);
      end;
    end else
    If Vtipe=1 then
    begin
      If RunCmd(VCmd)='' then
      begin
        VStatus:=True;
        Synchronize(SetLog)
      end else
      begin
        VStatus:=False;
        Synchronize(SetLog);
      end;
    end;
    Terminate;
  end;
end;

end.
