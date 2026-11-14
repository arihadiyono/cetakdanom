unit NMessage;

interface

uses
  classes,SYsUTils, Windows;

  type
  TNMessage=class(TObject)
    private
       //0,1,2,3(Informasi, warning, error, konfirmasi )
       VMsg:TStrings;
       HDll:THandle;
       function parser(var indata:string;dmz :string):string;
    protected

    public
       function MsgBox(Const HMsg,KodeMsg,EMsg:String;const Mode:Integer):boolean;
       constructor Create;
       destructor Destroy;override;
  end;
  
implementation

//################################################
//########## Implementasi kelas Msg ##############
constructor TNMessage.Create;
begin
  try
    hDll   := LoadLibrary(PChar('nmsg.dll') );
    if(hDll < 32)then
    begin
      MessageBox(0, 'File nmsg.dll' + ' tidak di temukan !', 'Error',MB_OK );
    end else
    begin
      VMsg:= TStringList.Create;
      try
        VMsg.LoadFromFile(ExtractFilePath(ParamStr(0))+'Nmsg.msg');
      finally
      end;
    end;
  except
      MessageBox(0, PChar( 'Gagal membuat Message' ), 'Error',MB_OK );
  end;
end;

destructor TNMessage.Destroy;
begin
  if hdll >= 32  then
  Begin
    FreeAndNil(VMsg);
    FreeLibrary(hDll);
  end;
end;

function TNMessage.parser(var indata:string;dmz :string):string;
var
  Tmp:string;
  pd,ld:integer;
begin
   indata:=trim(indata);
   if (length(indata)<>0) then
   begin
      pd:=pos(dmz,indata);
      ld:=length(dmz);
      Tmp:=copy(indata,1,pd-1);
      if (pd=0)then
      begin
        parser:=indata;
        indata:='';
      end else
      begin
        parser:= Tmp;
        indata:=copy(indata,pd+ld,length(indata));
      end;
   end;
end;

function TNMessage.MsgBox(Const HMsg,KodeMsg,EMsg:String;const Mode:Integer):boolean;
type
  TFunc_Start = function(Hmsg,KodeMsg,EMsg:PString;Mode:Integer;var Value:Integer):Integer;stdcall;
var
  Func_Start    : TFunc_Start;
  FuncPtr       : TFarProc;
  Value, i      : Integer;
  Str,data,Msg  : String;
begin
  try
    FuncPtr := GetProcAddress(hDll, PChar('MsgBox') );
    @Func_Start := FuncPtr;
    if(@Func_Start<>nil)then
    begin
      i:=0;
      Msg:='';
      if kodeMsg<>'' then
      begin
        While i < VMsg.Count-1 do
        begin
          Str := VMsg.Strings[i];
          data := parser(Str,' ');
          i:=i+1;
          if data = KodeMsg then
          begin
            Msg := Str;
            i := VMsg.Count;
          end else
            Msg := 'Error belum terdefinisi';
        end;
      end;
      Func_Start(@Hmsg,@Msg,@EMsg,Mode,Value);
      if Value=0 then
        Result := True
      else
        Result := False;
    end else
    begin
      MessageBox(0, 'Fungsi MsgBox tidak ada dalam dll', 'Error',MB_OK );
      Result := False;
    end;
  Except
    Result := False;
  end;
end;  

//########## End Implementasi kelas Msg ##########
//################################################

end.
