unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
  Dialogs, StdCtrls, HTTPApp, Sockets, RegExpr, LongPool, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, uLkJSON;

type
  TForm1 = class(TForm)
    mOut: TMemo;
    Button3: TButton;
    cbUrl: TComboBox;
    Edit1: TEdit;
    IdHTTP1: TIdHTTP;
    Button1: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

// legasy (try avoid exception than thread die)
procedure TForm1.FormCreate(Sender: TObject);
begin
  test:=nil;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if (test <> nil) then begin
      test.terminate;
      sleep(200);
      test.Free;
    end;
  except
  end;
end;

// NOTIFY Record!
function Notify(var rec: TCometRec):boolean;
begin
  Form1.mOut.Lines.Add(
    'id: '+ inttostr(rec.id)+
    ', at: '+DateTimeTostr(rec.servertime)+
    ', k: '+rec.key+
    ', delay in sec: '+FloatTostr(ServerDelta(rec.clientTime,rec.serverTime))
  );
  result:= true;
end;

// Notfy Connection
procedure ConnectNotify(connected: boolean; LastId:integer; LastServerTime: TDateTime);
begin
  if connected then Form1.mOut.Lines.Add('CONNECTED at: '+DateTimeTostr(LastServerTime))
               else Form1.mOut.Lines.Add('DISCONNECTED at: '+DateTimeTostr(LastServerTime));
end;

// Run COMET (receive)
procedure TForm1.Button3Click(Sender: TObject);
begin
  test := TComet.create(self, cbUrl.Text, Notify, ConnectNotify, [coURIWithLastId]);
end;

// Run GetEvent
procedure TForm1.Button1Click(Sender: TObject);
var js, js_item:TlkJSONobject;
  i :integer;
  rec : TCometRec;

begin
   rec:=TCometRec.Create();
   js := TlkJSON.ParseText(idhttp1.Get(Edit1.Text)) as TlkJSONobject;
   if js.Field['events'].Count >0 then
    for i:=1 to js.Field['events'].Count do begin
      rec.SetFromJSON(js.Field['events'].Child[i-1] as TlkJSONobject); 
      Notify(rec);
    end
   else
    showMessage('Nothing get');
end;


end.
