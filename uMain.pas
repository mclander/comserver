unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LongPool, HTTPApp, Sockets;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Memo2: TMemo;
    eUrl: TEdit;
    Button3: TButton;
    tcpTest: TTcpClient;
    WebDispatcher1: TWebDispatcher;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure tcpTestConnect(Sender: TObject);
    procedure tcpTestReceive(Sender: TObject; Buf: PAnsiChar;
      var DataLen: Integer);
    procedure tcpTestDisconnect(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    test : TLongPool;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  test := TLongPool.create(memo1);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  test.SetI(1);
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

procedure TForm1.Button3Click(Sender: TObject);
begin
  tcpTest.Active := True;
  tcpTest.sendLn('GET /comserver/recieve?formattername=xml&userid=2&token=b6q15DSLNwQmH7kcxphueSdN3hCycCXFMmRdrA==&matches=1,2,3,4,5,6,7 HTTP/1.1');
  tcpTest.sendLn('Host: www.rtsportcast.com:8080');
  tcpTest.sendLn('User-Agent: Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5');
  tcpTest.sendLn('Accept: text/html');
  tcpTest.sendLn('Connection: keep-alive');
  tcpTest.sendLn('');
  tcpTest.sendLn('');


end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  memo2.Lines.Add(tcpTest.Receiveln());

end;

end.
