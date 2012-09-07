unit LongPool;


interface
uses Classes, StdCtrls, SysUtils, Sockets;

type

TLongPool = class(TThread)
  private
    debug_memo: TMemo;
    pool : TTcpClient;
  public
    i :integer;
    constructor Create(memo:Tmemo);

    procedure SetI(n: integer);
   protected
    procedure Execute; override;

end;

implementation

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
  pool := TTcpClient.Create(self);
  while True do begin
    debug_memo.Lines.Add(IntToStr(i));
    inc(i);
    Sleep(1000);
  end;
end;


end.

