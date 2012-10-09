unit LongPool;


interface
uses Classes, StdCtrls, SysUtils, Sockets, Contnrs, DateUtils,Variants, Math, StrUtils, uLkJSON, regExpr;

type

TCometRec = class;
TCometException = class(Exception) end;

TCometFormat = (
  XMLFormat,
  JSONFormat // поддерживается только JSON формат
);

// Call-back procs
TCometNotify = function(var rec: TCometRec) :boolean; // вызывается при получении каждой записи
TCometConnectionNotify = procedure(connected: boolean; LastId: integer; LastServerTime: TDateTime); // вызывается при разрыве - установке связи

TCometOptions = set of (
  coNotifyBlank,   // при данной опции в обработчик передаются информационные сообщения (без id)
  coURIWithLastId, // при переконнекте будет подставлен иденификатор в URI
  coIgnoreAnswer   // -->>-- ответ от call-back функции игнорируется (т.е. передаются все сообщения. включая ранне полученнык)
);

TCometRec = class
  public
    id : integer;
    parent : integer;
    match : integer;
    tp : string;
    key : string;
    value : string;
    serverTime : Tdatetime;
    clientTime : TDateTime;
    procedure SetFromData(DataStr: string; Format: TCometFormat = JSONFormat);
//    constructor Create(js : TlkJSONobject);
    procedure SetFromJSON(js : TlkJSONobject);
end;


TComet = class(TThread)
  private
    pool_connected : boolean;
    pool : TTcpClient;
    NotifyProc : TCometNotify;
    ConnectProc: TCometConnectionNotify;
    buffer_str : string;
    r_json : TregExpr;

  public
    last_id : integer;
    option_list : TcometOptions;
    last_server_time : TDateTime;
    last_client_time : TDateTime;

    blankCount : integer;
    constructor Create(Owner:Tcomponent; URI:string;  NotifyEvent :TCometNotify; ConnectionEvent : TCometConnectionNotify; Options:TcometOptions);
    destructor Destroy;  override;

   protected

    path,host:string;
    port : integer;

    procedure Reconnect;
    procedure Execute; override;

end;

// возращает количество секунд
function ServerDelta(t1, t2: TDateTime):Double;

implementation


function ServerDelta(t1, t2: TDateTime):Double;
var v1,v2: Extended;
begin
  v1 := 24. * t1;
  v2 := 24. * t2;
  v1 := v1 - floor(v1);
  v2 := v2 - floor(v2);
  result := 3600 * abs(v1-v2);
end;


function GetJSonVal(js: TlkJSONobject; name : string):string;
var idx : integer;
begin
  idx := js.IndexOfName(name);
  if idx >0 then
    result := vartostr(js.FieldByIndex[idx].Value)
  else result := '';

end;

function DateFromIso(str : string):TDateTime;
var r : TRegExpr;
begin
  result := 0;
  r := TRegExpr.Create();
  r.Expression := '(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\.?(\d+)';
  if r.Exec(str) then
    result := EncodeDateTime(
      StrToInt(r.Match[1]), // year
      StrToInt(r.Match[2]), // mon
      StrToInt(r.Match[3]), // day
      StrToInt(r.Match[4]), // hour
      StrToInt(r.Match[5]), // min
      StrToInt(r.Match[6]), // sec
      StrToInt(r.Match[7])  // msec
    );


end;

procedure TCometRec.SetFromData(DataStr: string; Format: TCometFormat = JSONFormat);
var js:TlkJSONobject;
    s : string;
begin
  if Format <> JSONFormat then raise TCometException.Create('Only JSON format implemented now');
  js := TlkJSON.ParseText(DataStr) as TlkJSONobject;
  SetFromJSON(js);
end;

procedure TCometRec.SetFromJSON(js : TlkJSONobject);
begin
  id          := StrToIntDef(GetJSonVal(js,'i'),-1);
  tp          := GetJSonVal(js,'tp');
  parent      := StrToIntDef(GetJSonVal(js,'p'),-1);
  match       := StrToIntDef(GetJSonVal(js,'t'),-1);
  key         := GetJSonVal(js,'k');
  value       := GetJSonVal(js,'m');
  serverTime  := DateFromISo( GetJSonVal(js,'servertime'));
  clientTime  := Now;
end;

destructor Tcomet.Destroy;
begin
  if pool_connected then begin
    pool.Active := false;
    pool.Free;
  end;
  r_json.free;
end;

//constructor Tcomet.Create(owner);
constructor Tcomet.Create(Owner:Tcomponent; URI:string;  NotifyEvent :TCometNotify; ConnectionEvent : TCometConnectionNotify; Options:TcometOptions);
var s : string;
    r : TRegExpr;
    uri_ok : boolean;
begin
  inherited Create(true);

  last_id := -1;
  option_list := Options;
  last_server_time := Now;
  last_client_time := Now;

  r_json := TRegExpr.Create;
  r_json.Expression := '(?im)<script.*?>parent.push\(''({.*?})\''\)</script>';

  NotifyProc := NotifyEvent;
  ConnectProc := ConnectionEvent;

  uri_ok := false;
  pool_connected := true;


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
var
  r_last_id : TregExpr;
  s : string;
begin
  if (last_id > 0) and (coURIWithLastId in option_list) then begin
    r_last_id := TRegExpr.Create();
    r_last_id.Expression := '^(.*?)eventid=(\d+)(.*?)$';
    if r_last_id.Exec(path) then
      path := r_last_id.Match[1]+'eventid='+inttostr(last_id)+r_last_id.Match[3]
    else
      if pos('?', path)>0 then path := path + '&eventid'+inttostr(last_id)
                          else path := path + '?eventid='+inttostr(last_id);

  end;


  pool.Active := not True;

  pool.Active := True;
  pool.sendLn('GET '+path+' HTTP/1.1');
  pool.sendLn('Host: '+host+':'+IntToStr(port));
  pool.sendLn('User-Agent: Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5');
  pool.sendLn('Accept: text/html');
  pool.sendLn('Connection: keep-alive');
  pool.sendLn('');
  // HACK
  s:=pool.Receiveln();
  if not (@ConnectProc=nil) then begin

    if s<>'' then
      self.ConnectProc(true, last_id, last_server_time)
    else if pool_connected then begin
      self.ConnectProc(false, last_id, last_server_time);
      pool_connected := false;
    end;
  end;
  if s<>'' then pool_connected := true;
end;

procedure Tcomet.Execute;
var str :string;
    rec: TcometRec;
    ret : boolean;
begin
  // условие выхода
  blankCount := 0;
  while  not self.Suspended and not self.Terminated do begin
    str := pool.Receiveln();
    // HACK: если коннект обломается, нам прилетит несколько пустых строк (в исходном файле такого быть не может, не по крайней мере пока не поменятся формат - максимум две пустые строки в заголовка HTTP)
    if str = '' then  begin
      inc(blankCount);
      if blankCount > 4 then begin

        if not (@ConnectProc=nil) and pool_connected then
          self.ConnectProc(false, last_id, last_server_time);


        pool_connected := false;
        Reconnect;
      end;

    end else blankCount := 0;

    // всё хорошо - разбираем JSONчик
    if r_json.Exec(str) and not self.Suspended and not self.Terminated then begin

      if not(@NotifyProc = nil) then begin
        try
          rec := TCometRec.Create();
          rec.SetFromData(r_json.Match[1]);
          self.last_server_time := rec.serverTime;
          self.last_client_time := Now;
          if ((coNotifyBlank in self.option_list) and  (rec.id <0)) or (rec.id > last_id) then
              ret := self.NotifyProc(rec);
              if (ret or (coIgnoreAnswer in option_list)) and (rec.id>0) then last_id := rec.id;
        except
        end;
      end;

    end;
  end;
end;

end.

