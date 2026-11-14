program update;

uses
  Forms,
  uUpdate in 'uUpdate.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'downloadParam';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
