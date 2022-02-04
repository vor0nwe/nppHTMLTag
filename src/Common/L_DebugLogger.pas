unit L_DebugLogger;

interface

  procedure DebugWrite(AFunction: string; AText: string = ''; const ADetails: TObject = nil); overload;
  procedure DebugWrite(AFunction: string; AText: RawByteString; const ADetails: TObject = nil); overload; inline;

  var
    DebugLogging: boolean;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation
  uses
    Classes, SysUtils, Windows,
    L_GetLongPath;

  var
    Debug: TStreamWriter;

{ ------------------------------------------------------------------------------------------------ }
// like "Application.ExeName", but in a DLL you get the name of
// the DLL instead of the application name
function DLLName: String;
var
  szFileName: array[0..MAX_PATH] of Char;
begin
  GetModuleFileName(hInstance, szFileName, MAX_PATH);
  Result := szFileName;
end;

{ ------------------------------------------------------------------------------------------------ }

procedure InitLogger;
var
  LogFilename: string;
  FS: TFileStream;
begin
  LogFilename := ChangeFileExt(GetLongPath(ParamStr(0)), '-' + ChangeFileExt(ExtractFileName(GetLongPath(DLLName)), '.log'));
  LogFilename := IncludeTrailingPathDelimiter(ExtractFilePath(DLLName)) + ExtractFilename(LogFilename);
//  LogFilename := ChangeFilePath(ChangeFileExt(GetLongPath(ParamStr(0)), '-' + ChangeFileExt(ExtractFileName(GetLongPath(DLLName)), '.log')), ExtractFilePath(DLLName));
  if FileExists(LogFilename) then begin
    FS := TFileStream.Create(LogFilename, fmOpenReadWrite, fmShareDenyNone);
    FS.Seek(0, soEnd);
    Debug := TStreamWriter.Create(FS, TEncoding.UTF8);
    Debug.WriteLine;
    Debug.Write(StringOfChar('=', 78));
    Debug.WriteLine;
  end else begin
    FS := TFileStream.Create(LogFilename, fmCreate, fmShareDenyNone);
    Debug := TStreamWriter.Create(FS, TEncoding.UTF8);
  end;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure DebugWrite(AFunction: string; AText: RawByteString; const ADetails: TObject = nil);
begin
  DebugWrite(AFunction, string(AText), ADetails);
end;
{ ------------------------------------------------------------------------------------------------ }
procedure DebugWrite(AFunction: string; AText: string = ''; const ADetails: TObject = nil);
var
  ModName: string;
  Text: string;
  Indentation: string;
begin
  ModName := ChangeFileExt(ExtractFileName(DLLName), '');
  OutputDebugString(PChar(ModName + ': ' + AFunction + ' '#9' ' + AText));
  if DebugLogging then begin
    if not Assigned(Debug) then begin
      InitLogger;
    end;

    Text := FormatDateTime('yyyy-MM-dd HH:mm:ss.zzz', Now) + ': ';
    Indentation := StringOfChar(' ', Length(Text) - 2);

    Debug.WriteLine;
    Debug.Write(Text + AFunction);
    Debug.WriteLine;
    if (AText <> '') then begin
      Debug.Write(Indentation + StringReplace(AText, sLineBreak, sLineBreak + Indentation, [rfReplaceAll]));
      Debug.WriteLine;
    end;
    if Assigned(ADetails) then begin
      try
        Debug.Write(Indentation + '[' + ADetails.ClassName + ']');
      except
        on E: Exception do begin
          Debug.Write(Indentation + '{' + E.Message + '}');
        end;
      end;
    end;
  end;
end{DebugWrite};


{ ------------------------------------------------------------------------------------------------ }
procedure ClearStream;
var
  BS: TStream;
begin
  if Assigned(Debug) then begin
    BS := Debug.BaseStream;
    FreeAndNil(Debug);
    FreeAndNil(BS);
  end;
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
initialization
  DebugLogging := {$IFDEF DEBUG}True{$ELSE}False{$ENDIF};

////////////////////////////////////////////////////////////////////////////////////////////////////
finalization
  ClearStream;

end.

