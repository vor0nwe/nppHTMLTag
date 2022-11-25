procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
  DLL_PROCESS_ATTACH:
  begin
    // create the main object
    //Npp := TDbgpNppPlugin.Create;
  end;
  DLL_PROCESS_DETACH:
  begin
    try
      if Assigned(Npp) then
        Npp.Free;
    except
      ShowException(ExceptObject, ExceptAddr);
    end;
  end;
  //DLL_THREAD_ATTACH: MessageBeep(0);
  //DLL_THREAD_DETACH: MessageBeep(0);
  end;
end;

procedure setInfo(NppData: TNppData); cdecl; export;
begin
  if Assigned(Npp) then
    Npp.SetInfo(NppData);
end;

function getName(): nppPchar; cdecl; export;
begin
  if Assigned(Npp) then
    Result := Npp.GetName
  else
    Result := '(plugin not initialized)';
end;

function getFuncsArray(var nFuncs:integer):Pointer;cdecl; export;
begin
  if Assigned(Npp) then
    Result := Npp.GetFuncsArray(nFuncs)
  else begin
    Result := nil;
    nFuncs := 0;
  end;
end;

procedure beNotified(sn: PSCNotification); cdecl; export;
begin
  if Assigned(Npp) then
    Npp.BeNotified(sn);
end;

function messageProc(msg: Integer; _wParam: WPARAM; _lParam: LPARAM): LRESULT; cdecl; export;
var xmsg:TMessage;
begin
  xmsg.Msg := msg;
  xmsg.WParam := _wParam;
  xmsg.LParam := _lParam;
  xmsg.Result := 0;
  if Assigned(Npp) then
    Npp.MessageProc(xmsg);
  Result := xmsg.Result;
end;

function isUnicode : Boolean; cdecl; export;
begin
  Result := true;
end;

exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;
