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
    tp : string;
    key : string;
    value : string;
    time : Tdatetime;
    constructor Create(DataStr: string; Format: TCometFormat = JSONFormat);
end;


TComet = class(TThread)
  private
    poolConnected : boolean;
    //debug_memo: TMemo;
    pool : TTcpClient;
    NotifyProc : TCometNotify;
    // data: TObjectList; // TRCometRec
    last_id : integer;
    buffer_str : string;
    r_json : TregExpr;

    // procedure TcpClientDisconnect(Sender: TObject);

  public

    blankCount : integer;
    constructor Create(owner:Tcomponent; uri:string;  proc:TcometNotify);
    destructor Destroy;  override;

   protected

    path,host:string;
    port : integer;

    procedure Reconnect;
    procedure Execute; override;

end;

implementation

function GetJSonVal(js: TlkJSONobject; name : string):string;
var idx : integer;
begin
  idx := js.IndexOfName(name);
  if idx >0 then
    result := vartostr(js.FieldByIndex[idx].Value)
  else result := '';

end;

constructor TCometRec.Create(DataStr: string; Format: TCometFormat = JSONFormat);
var   js:TlkJSONobject;
begin
  if Format <> JSONFormat then raise TCometException.Create('Only JSON format implemented now');
  js := TlkJSON.ParseText(DataStr) as TlkJSONobject;
//  {"m":"Subscribed to matches=168320,","t":"servermessageplayer","tp":"Info","k":"","p":"","i":"","servertime":"2012-09-06 18:00:57.871"}

  id     := StrToIntDef(GetJSonVal(js,'i'),-1);
  tp     := GetJSonVal(js,'tp');
  parent := StrToIntDef(GetJSonVal(js,'p'),-1);
  match  := StrToIntDef(GetJSonVal(js,'t'),-1);
  key    := GetJSonVal(js,'k');
  value  := GetJSonVal(js,'m');
  time   := StrToDatetimeDef(GetJSonVal(js,'servertime'),0);
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
constructor Tcomet.Create(owner:Tcomponent; uri:string;  proc:TcometNotify);
var s : string;
    r : TRegExpr;
    uri_ok : boolean;
begin
  inherited Create(true);

  last_id := -1;

  r_json := TRegExpr.Create;
  r_json.Expression := '(?im)<script.*?>parent.push\(''({.*?})\''\)</script>';

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
   // pool.OnDisConnect := TcpClientDisconnect;

   Reconnect;
   self.Resume;

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
    rec: TcometRec;
begin
  // условие выхода
  blankCount := 0;
  while  not self.Suspended and not self.Terminated do begin
    str := pool.Receiveln();
    if str = '' then  begin
      inc(blankCount);
      if blankCount > 10 then Reconnect;
    end else blankCount := 0;

    if r_json.Exec(str) and not self.Suspended and not self.Terminated then begin

//      if not (self.debug_memo = nil) then
//        debug_memo.Lines.Add(r_json.Match[1]);

      if not(@NotifyProc = nil) then begin
        try
          rec := TCometRec.Create(r_json.Match[1]);
          if (rec.id <0) or (rec.id > last_id) then
            if self.NotifyProc(rec) then last_id := rec.id;
        except
        end;
      end;

    end;
  end;
end;

end.

