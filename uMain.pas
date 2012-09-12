unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
  Dialogs, StdCtrls, HTTPApp, Sockets, RegExpr, LongPool;

type
  TForm1 = class(TForm)
    mOut: TMemo;
    Button3: TButton;
    cbUrl: TComboBox;
    TcpClient1: TTcpClient;
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    test : TComet;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function Notify(var rec: TCometRec):boolean;
begin
  Form1.mOut.Lines.Add(inttostr(rec.id));
  result:= true;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  test := TComet.create(self, cbUrl.Text, Notify);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    test.terminate;
    sleep(200);
    test.Free;
  except
  end;
end;

end.
