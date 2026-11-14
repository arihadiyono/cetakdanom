unit NFile;
{
   Modul        : NFile
   Deskripsi    : Modul ini menangani pengelolaan log file
   Autor        : Nasruddin M.
   E-Mail       : nas@posindonesia.co.id
   Versi        : 1.00
   Tanggal      : 21 Oktober 2004

}

interface

Uses
  Classes, SysUtils, FileCtrl,JvSHFileOperation;

Type
  TNLog = class
    private
      VActive           :Boolean;
      VFileStatus       :integer;
      VLogFile          :TextFile;
      VLogName,
      VDir              :String;
      VSLog             :Tstrings;
      VTLog             :TMemoryStream;
      procedure SetActive(const value:Boolean);
      procedure SetDir(const value:String);
      procedure SetLogName(const value:String);
      function SetPetik(const value:String):String;
    protected

    public
      constructor Create;
      destructor Destroy;override;
      property Active : Boolean read VActive write SetActive;
      function Add(const value:String):Boolean;
      function GetLogStr:TStrings;
      property Dir : String read VDir write SetDir;
      property LogName : String read VLogName write SetLogName;
  end;

implementation

constructor TNLog.Create;
begin
  VSlog:= TStringList.Create;
  VTLog:= TMemoryStream.Create;
  VFileStatus:=0;
  VActive:=True;
end;

destructor TNLog.Destroy;
begin
  // nothing to destroy
  if VFileStatus<>0 then
    CloseFile(VLogFile);
  FreeAndNil(VSlog);
  FreeAndNil(VTlog);
end;



function TNLog.Add(const value:String):Boolean;
begin
  try
    if VActive=True then
    begin
      WriteLn(VLogFile,SetPetik(FormatDateTime('dd/mm/yyyy hh:nn:ss:zzz',now))+','+SetPetik(value));
      Flush(VLogFile);
    end;
    Result:= True;
  except
    Result:=false;
  end;
end;

function TNLog.GetLogStr:TStrings;
var
  Fileop: TJvSHFileOperation;
begin
  Fileop:= TJvSHFileOperation.Create(nil);
  FileOp.SourceFiles.Text:=VLogName;
  FileOp.DestFiles.Text:=VlogName+'tmp';
  FileOp.Operation:=foCopy;
  FileOp.Options:=[fofNoErrorUI,fofNoConfirmation,fofNoConfirmMkDir];
  if FileOp.Execute then
    VSLog.LoadFromFile(VlogName+'tmp');
  DeleteFile(VlogName+'tmp');
  FreeAndNil(FileOp);
  Result:=VSLog;
end;

procedure TNLog.SetActive(const value:Boolean);
begin
   VActive:=value;
end;

procedure TNLog.SetDir(const value:String);
begin
   VDir:=value;
end;

procedure TNLog.SetLogName(const value:String);
begin
  If  not DirectoryExists(VDir) then
    ForceDirectories(VDir);
  VLogName:=VDir+'\'+value;
  If not FileExists(VLogName) then
  begin
    if VFileStatus<>0 then
      CloseFile(VLogFile);
    AssignFile(VLogFile,VlogName );
    rewrite(VLogFile);
  end else
  begin
    if VFileStatus=0 then
    begin
      AssignFile(VLogFile,VlogName );
      Append(VLogFile);
    end;
  end;
  VFileStatus:=1;
end;

function TNLog.SetPetik(const value:String):String;
begin
   Result:=chr(39)+value+Chr(39);
end;

end.
