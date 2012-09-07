program comserver;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  LongPool in 'LongPool.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
