unit UFunction;

interface

implementation

uses SysUtils, Classes,  fs_iinterpreter, NCrypt, NUTility;

type

  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;

  {
function ToMD5(Value: String): String;
begin
//Here you will call your function
  //Result := StrToMD5('9823808890853210365909150091571000danomhost');//StrToMD5(Value);
  Result := StrToMD5(Value);
  {
  with TNHash.create do
  begin
    Result := GetHash(Value);
    Free;
  end;
  }
//end;
 
{ TFunctions }

constructor TFunctions.Create;
begin
  inherited Create(AScript);
  AScript.AddMethod('function ToMD5(Value: String): String', CallMethod, 'ctConv', ' ');
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
begin
  if MethodName = 'TOMD5' then
    Result := StrToMD5(trim(Params[0]));
end;

{ TFunctiiFR }

initialization
  fsRTTIModules.Add(TFunctions);

end.
