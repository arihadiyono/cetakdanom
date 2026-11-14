unit Nmemtable;

interface
uses
  classes,SysUtils, kbmMemBinaryStreamFormat, Nzip, NCrypt,
  kbmMemTable, Db;
type
  TMem=Tkbmmemtable;
  TFmt=TkbmBinaryStreamFormat;

  function CreateTable:TDataSet;
  function CreateLTable:TMem;
  procedure SaveToFile(ds :TMem;value : String);
  function LoadFromFile(value : String):TDataset;

implementation
  
function CreateTable:TDataSet;
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
    Add('id',ftString,20,true);
    Add('connType',ftString,10,true);
    Add('server',ftString,20,true);
    Add('database',ftString,32,true);
    Add('user',ftString,20,true);
    Add('password',ftString,20,true);
    Add('ziptype',ftinteger,0,true);
    Add('crypttype',ftInteger,0,true);
    Add('timeout',ftInteger,0,true);
  end;
  Dbconf.IndexDefs.Add('idx_dbconn','id',[ixUnique]);
  DbConf.CreateTable;
  Result:=DbConf;
end;

function CreateLTable:TMem;
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
    Add('id',ftString,20,true);
    Add('connType',ftString,10,true);
    Add('server',ftString,30,true);
    Add('database',ftString,50,true);
    Add('user',ftString,32,true);
    Add('password',ftString,32,true);
    Add('ziptype',ftinteger,0,true);
    Add('crypttype',ftInteger,0,true);
    Add('timeout',ftInteger,0,true);
  end;
  Dbconf.IndexDefs.Add('idx_dbconn','id',[ixUnique]);
  DbConf.CreateTable;
  Result:=DbConf;
end;

procedure SaveToFile(ds :TMem;value : String);
var
  mem,mem1 : TmemoryStream;
begin
  mem := TmemoryStream.create;
  mem1 := TmemoryStream.create;
  ds.SaveToStream(mem);
  with TNZip.Create do
  begin
    GetZipStream(mem,mem1);
    Free;
  end;
  mem.Clear;
  with TNCipher.Create do
  begin
    //Key:=vkey;
    GetEnCryptStream(mem1,mem);
    Free;
  end;
  mem.SaveToFile(value);
  FreeAndNil(mem);
  FreeAndNil(mem1);
end;

function LoadFromFile(value : String):TDataset;
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
  ds := CreateLTable;
  ds.LoadFromStream(mem);
  Result := ds;
  FreeAndNil(mem);
  FreeAndNil(mem1);
end;

end.
