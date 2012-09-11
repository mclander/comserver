unit LongPool;


interface
uses Classes, StdCtrls, SysUtils, Sockets, Contnrs, Variants,  StrUtils,uLkJSON, regExpr;

type

TCometRec = class;
TCometException = class(Exception) end;

TCometFormat = (XMLFormat, JSONFormat);

TCometNotify = function(var rec: TCometRec) :boolean;

TCometRec = class
  public
    id : integer;
    parent : integer;
    match : integer;
    tp : integer;
    key : string;
    value : string;
    time : Tdatetime;
    constructor Create(DataStr: string; Format: TCometFormat = JSONFormat);
end;


TComet = class(TThread)
  private
    poolConnected : boolean;
    debug_memo: TMemo;
    pool : TTcpClient;
    NotifyProc : TCometNotify;
    // data: TObjectList; // TRCometRec
    last_id : integer;
    buffer_str : string;
    r_json : TregExpr;

    procedure TcpClientDisconnect(Sender: TObject);

  public
    i :integer;
    constructor Create(owner:Tcomponent; uri:string;  proc:TcometNotify; var memo:TMemo);
    destructor Destroy;  override;

   protected

    path,host:string;
    port : integer;

    procedure Reconnect;
    procedure Execute; override;

end;

implementation

constructor TCometRec.Create(DataStr: string; Format: TCometFormat = JSONFormat);
var   js:TlkJSONobject;
begin
  if Format <> JSONFormat then raise TCometException.Create('Only JSON format implemented now');
  js := TlkJSON.ParseText(DataStr) as TlkJSONobject;
  id := StrToInt(VarToStr(js.Field['id'].Value));
end;

destructor Tcomet.Destroy;
begin
  if poolConnected then begin
    pool.Active := false;
    pool.Free;
  end;
  r_json.free;
end;

//constructor Tcomet.Create(owner);
constructor Tcomet.Create(owner:Tcomponent; uri:string;  proc:TcometNotify; var memo:TMemo);
var s : string;
    r : TRegExpr;
    uri_ok : boolean;
begin
  inherited Create(true);

  r_json := TRegExpr.Create;
  r_json.Expression := '(?im)<script.*?>parent.push\(''({.*?})\''\)</script>';

  debug_memo := memo;
  NotifyProc := proc;

  uri_ok := false;
  poolConnected := false;


  // разбор uri => host:port/path
  s := uri;
  r := TregExpr.Create();
  try
    r.Expression := '^(?i)(http\:\/\/)';
    if not r.Exec (s) then s:= 'http://' + s;
    r.Expression := '^http://([^/]+)(/?.*)?$';
    if r.Exec(s) then begin
      host := r.Match[1];
      if pos(':',host) >0 then begin
        port := StrToIntDef(midstr(host,pos(':',host)+1, 255),80);
        host := midstr(host,1,pos(':',host)-1);
      end
      else port := 80;
      path := r.Match[2];
      if path = '' then path := '/';
      uri_ok := true;
    end;
    finally
      r.Free;
   end;

   if not uri_ok then raise TCometException.Create('Wrong uri (cant parse): '+uri);

   // подготавливаем соединение
   pool := TTcpClient.Create(owner);
   pool.RemoteHost := host;
   pool.RemotePort := IntToStr(port);
   pool.BlockMode  := bmblocking;
   pool.OnDisConnect := TcpClientDisconnect;

   Reconnect;
   self.Resume;

   i :=1;
end;

procedure Tcomet.Reconnect;
begin
  pool.Active := not True;
  pool.Active := True;
  pool.sendLn('GET '+path+' HTTP/1.1');
  pool.sendLn('Host: '+host+':'+IntToStr(port));
  pool.sendLn('User-Agent: Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5');
  pool.sendLn('Accept: text/html');
  pool.sendLn('Connection: keep-alive');
  pool.sendLn('');
  poolConnected := true;
end;

procedure Tcomet.Execute;
var str :string;
begin
  // pool := TTcpClient.Create(self);
  while True do begin
    str := pool.Receiveln();
    // if str='' then raise TCometException.Create('WTF');
    if r_json.Exec(str) then begin
      if not (debug_memo = nil) then
        debug_memo.Lines.Add(IntToStr(i)+'. '+r_json.Match[1]);
      inc(i);
    end;
  end;
end;

procedure Tcomet.TcpClientDisconnect(Sender: TObject);
begin
  raise TCometException.Create('WTF');
end;



end.

