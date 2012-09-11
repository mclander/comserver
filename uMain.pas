unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
  Dialogs, StdCtrls, HTTPApp, Sockets, RegExpr, LongPool;

type
  TForm1 = class(TForm)
    Memo2: TMemo;
    Button3: TButton;
    cbUrl: TComboBox;
    TcpClient1: TTcpClient;
    procedure Button2Click(Sender: TObject);
    procedure tcpTestConnect(Sender: TObject);
    procedure tcpTestReceive(Sender: TObject; Buf: PAnsiChar;
      var DataLen: Integer);
    procedure tcpTestDisconnect(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
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

procedure TForm1.Button2Click(Sender: TObject);
begin
//  test.SetI(1);
end;

procedure TForm1.tcpTestConnect(Sender: TObject);
begin
  memo2.Lines.Add('connected');
end;

procedure TForm1.tcpTestReceive(Sender: TObject; Buf: PAnsiChar;
  var DataLen: Integer);
begin
  memo2.Lines.Add('received:'+ AnsiString(Buf));
end;

procedure TForm1.tcpTestDisconnect(Sender: TObject);
begin
  memo2.Lines.Add('connected');
end;

function Notify(var rec: TCometRec):boolean;
begin
  result:= true;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  test := TComet.create(self, cbUrl.Text, Notify , Memo2);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
//  memo2.Lines.Add(tcpTest.Receiveln());

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    test.suspend;
    test.Free;
  except
  end;
end;

end.
