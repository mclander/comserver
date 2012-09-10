unit LongPool;


interface
uses Classes, StdCtrls, SysUtils, Sockets, Contnrs, Variants, uLkJSON;

type

TCometException = class(Exception) end;

TCometFormat = (XMLFormat, JSONFormat);

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


TLongPool = class(TThread)
  private
    debug_memo: TMemo;
    pool : TTcpClient;
    data: TObjectList; // TRCometRec
  public
    i :integer;
    constructor Create(memo:Tmemo);

    procedure SetI(n: integer);
   protected
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

constructor TlongPool.Create(memo:Tmemo);
begin
  inherited Create(false);
  debug_memo := memo;
  i :=1;
end;

procedure TlongPool.SetI(n : integer);
begin
  i := n;
end;

procedure TLongPool.Execute;
begin
  // pool := TTcpClient.Create(self);
  while True do begin
    debug_memo.Lines.Add(IntToStr(i));
    inc(i);
    Sleep(1000);
  end;
end;


end.

