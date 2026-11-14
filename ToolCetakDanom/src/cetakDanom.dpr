program cetakDanom;

uses
  Forms,
  Utama in 'Utama.pas' {Frm_Main},
  ServerConf in 'ServerConf.pas' {Frm_Server},
  ULogin in 'ULogin.pas' {Frm_Login},
  UParam in 'UParam.pas',
  UFunction in 'UFunction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Login, Frm_Login);
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.CreateForm(TFrm_Server, Frm_Server);
  Application.Run;
end.
