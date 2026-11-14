unit UFunction;

interface

implementation

uses SysUtils, Classes,  fs_iinterpreter;

type

  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;

function MyIntToHexFunction(Value, Digits: Integer): String;
begin
//Here you will call your function
  Result := IntToHex(Value, Digits);
end;

{ TFunctions }

constructor TFunctions.Create;
begin
  inherited Create(AScript);
  AScript.AddMethod('function MyIntToHexFunction(Value, Digits: Integer): String', CallMethod, 'ctConv', ' ');
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
begin
  if MethodName = 'MYINTTOHEXFUNCTION' then
    Result := MyIntToHexFunction(Params[0], Params[1]);
end;

{ TFunctiiFR }

initialization
  fsRTTIModules.Add(TFunctions);

end.
