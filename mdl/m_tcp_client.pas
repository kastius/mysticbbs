Unit m_TCP_Client;

{$I M_OPS.PAS}

Interface

Uses
  Classes,
  m_Strings,
  m_IO_Sockets;

Type
  TTCPClient = Class
    Client       : TIOSocket;
    ResponseType : Integer;
    ResponseData : TStringList;

    Constructor Create;
    Destructor  Destroy; Override;
    Function    Connect (Address: String; Port: Word) : Boolean;
    Function    SendCommand (Str: String) : Integer;
    Function    GetResponse : Integer;
  End;

Implementation

Constructor TTCPClient.Create;
Begin
  Inherited Create;

  Client       := NIL;
  ResponseData := TStringList.Create;
End;

Destructor TTCPClient.Destroy;
Begin
  Client.Free;
  ResponseData.Free;

  Inherited Destroy;
End;

Function TTCPClient.Connect (Address: String; Port: Word) : Boolean;
Begin
  Client := TIOSocket.Create;

  Result := Client.Connect(Address, Port);
End;

Function TTCPClient.SendCommand (Str: String) : Integer;
Begin
  Result := -1;

  If Client.FSocketHandle = -1 Then Exit;

  Client.WriteLine(Str);
  //WriteLn(Str);

  Result := GetResponse;
End;

Function TTCPClient.GetResponse : Integer;
Var
  Str : String;
Begin
  Result := -1;

  If Client.FSocketHandle = -1 Then Exit;

  If Client.ReadLine(Str) > 0 Then Begin
    ResponseType := strS2I(Copy(Str, 1, 3));
    Result       := ResponseType;

    //WriteLn(Str);

    If Str[4] = '-' Then Begin
      ResponseData.Clear;

      Repeat
        If Client.ReadLine(Str) <= 0 Then Break;

        ResponseData.Add(Str);

        //WriteLn(Str);
      Until Copy(Str, 1, 4) = strI2S(ResponseType) + ' ';
    End;
  End;
End;

End.