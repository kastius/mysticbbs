Unit bbs_UserChat;

{$I M_OPS.PAS}

Interface

Procedure PageUserForChat;
Procedure OpenUserChat (Split, Forced: Boolean; ToNode: Byte);

Implementation

Uses
  m_Strings,
  m_FileIO,
  m_DateTime,
  bbs_Core,
  bbs_Common,
  bbs_NodeInfo;

Procedure PageUserForChat;
Var
  Str      : String;
  ToNode   : Byte;
  ReqType  : Byte = 8;
  TempChat : ChatRec;
Begin
  Repeat
    Session.io.OutFull (Session.GetPrompt(479));

    Str := Session.io.GetInput(3, 3, 12, '');

    If Str = '?' Then Show_Whos_Online Else
    If Str = 'Q' Then Exit Else Break;
  Until False;

  ToNode := strS2I(Str);

  If (Not GetChatRecord(ToNode, TempChat)) or (ToNode = Session.NodeNum) or
     (Not TempChat.Active) or (Not TempChat.Available) Then Begin
       Session.io.OutFull(Session.GetPrompt(480));
       Exit;
  End;

  If Session.User.Access(Config.ACSSysop) Then
    If Session.io.GetYN(Session.GetPrompt(481), False) Then
      ReqType := 9;

  FileErase (Config.DataPath + 'userchat.' + strI2S(ToNode));
  FileErase (Config.DataPath + 'userchat.' + strI2S(Session.NodeNum));

  Session.io.PromptInfo[1] := TempChat.Name;
  Session.io.PromptInfo[2] := strI2S(ToNode);

  Session.io.OutFull(Session.GetPrompt(482));

  Send_Node_Message (ReqType, strI2S(ToNode) + ';' + strI2S(Session.io.Graphics), 0);
End;

Procedure OpenUserChat (Split, Forced: Boolean; ToNode: Byte);
Var
  fOut     : File;
  fIn      : File;
  Ch       : Char;
  Str1     : String  = '';
  Str2     : String  = '';
  InRemote : Byte;

  Procedure LineChat;
  Begin
    Session.io.BufFlush;

    Repeat
      If Not Eof(fIn) Then Begin
        BlockRead (fIn, Ch, 1);

        If Ch = #255 Then Break;

        InRemote := 1;

        Session.io.AnsiColor (Session.Lang.LineChat1);
      End Else Begin
        Ch := Session.io.InKey(200);

        If Ch = #255 Then Continue;

        Session.io.AnsiColor (Session.Lang.LineChat2);

        BlockWrite (fOut, Ch, 1);

        InRemote := 0;
      End;

      Case Ch of
        #08 : If Length(Str1) > 0 Then Begin
                Session.io.OutBS(1, True);
                Dec (Str1[0]);
              End;
        #10 : ;
        #13 : Begin
                Str1 := '';
                Session.io.OutRawLn('');
              End;
        #27 : If Not Forced And (InRemote = 0) Then Begin
                Ch := #255;
                BlockWrite(fOut, Ch, 1);
                Break;
              End;
      Else
        Str1 := Str1 + Ch;

        If Length(Str1) > 79 Then Begin
          strWrap(Str1, Str2, 79);

          Session.io.OutBS(Length(Str2), True);
          Session.io.OutRawLn('');

          Str1 := Str2;

          Session.io.OutRaw(Str1);
        End Else
          Session.io.OutRaw(Ch);
      End;

      Session.io.BufFlush;
    Until False;
  End;

Begin
  Session.io.OutFullLn(Session.GetPrompt(483));

  Assign (fOut, Config.DataPath + 'userchat.' + strI2S(ToNode));
  Assign (fIn,  Config.DataPath + 'userchat.' + strI2S(Session.NodeNum));

  FileMode := 66;

  ReWrite (fOut, 1);
  ReWrite (fIn,  1);

  Case Split of
    False : LineChat;
    True  : LineChat;
  End;

  Close(fOut);
  Close(fIn);

  Erase(fOut);
  Erase(fIn);

  Session.io.OutFullLn(Session.GetPrompt(484));
End;

End.