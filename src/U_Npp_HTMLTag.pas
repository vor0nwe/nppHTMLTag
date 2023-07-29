unit U_Npp_HTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
interface

uses
  SysUtils, Windows,
  NppPlugin,
  NppSimpleObjects, L_VersionInfoW;

type
  TDecodeCmd = (dcAuto = -1, dcEntity, dcUnicode);
  TCmdMenuPosition = (cmpUnicode = 3, cmpEntities);
  TPluginOptions = packed record
    LiveEntityDecoding: LongBool;
    LiveUnicodeDecoding: LongBool;
  end;
  PPluginOption = ^LongBool;

  TNppPluginHTMLTag = class(TNppPlugin)
  private
    FApp: TApplication;
    FVersionInfo: TFileVersionInfo;
    FVersionStr: nppString;
    FOptions: TPluginOptions;
    function GetOptionsFilePath: nppString;
    function GetEntitiesFilePath: nppString;
    function GetDefaultEntitiesPath: nppString;
    function PluginNameFromModule: nppString;
    function GetConfigDir: nppString;
    procedure LoadOptions;
    procedure SaveOptions;
    procedure FindAndDecode(const KeyCode: Integer; Cmd: TDecodeCmd = dcAuto);
  public
    constructor Create;
    destructor Destroy; override;
    procedure commandFindMatchingTag;
    procedure commandSelectMatchingTags;
    procedure commandSelectTagContents;
    procedure commandSelectTagContentsOnly;
    procedure commandEncodeEntities(const InclLineBreaks: Boolean = False);
    procedure commandDecodeEntities;
    procedure commandEncodeJS;
    procedure commandDecodeJS;
    procedure commandAbout;
    procedure SetInfo(NppData: TNppData); override;
    procedure DoNppnToolbarModification; override;
    procedure DoCharAdded({%H-}const hwnd: HWND; const ch: Integer); override;
    procedure ToggleOption(OptionPtr: PPluginOption; MenuPos: TCmdMenuPosition);
    procedure ShellExecute(const FullName: WideString; const Verb: WideString = 'open'; const WorkingDir: WideString = '';
      const ShowWindow: Integer = SW_SHOWDEFAULT);

    property App: TApplication  read FApp;
    property Options: TPluginOptions read FOptions;
    property Version: nppString  read FVersionStr;
    property OptionsConfig: nppString  read GetOptionsFilePath;
    property Entities: nppString  read GetEntitiesFilePath;
    property DefaultEntitiesPath: nppString  read GetDefaultEntitiesPath;
    property PluginConfigDir: nppString read GetConfigDir;
  end;

procedure _commandFindMatchingTag(); cdecl;
procedure _commandSelectMatchingTags(); cdecl;
procedure _commandSelectTagContents(); cdecl;
procedure _commandSelectTagContentsOnly(); cdecl;
procedure _commandEncodeEntities(); cdecl;
procedure _commandDecodeEntities(); cdecl;
procedure _commandEncodeJS(); cdecl;
procedure _commandDecodeJS(); cdecl;
procedure _toggleLiveEntityecoding; cdecl;
procedure _toggleLiveUnicodeDecoding; cdecl;
procedure _commandAbout(); cdecl;


var
  Npp: TNppPluginHTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation

uses
  ShellAPI,
  L_SpecialFolders,
  SciSupport,
  Utf8IniFiles,
  U_HTMLTagFinder, U_Entities, U_JSEncode;

{ ------------------------------------------------------------------------------------------------ }
procedure _commandFindMatchingTag(); cdecl;
begin
  npp.commandFindMatchingTag;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandSelectMatchingTags(); cdecl;
begin
  npp.commandSelectMatchingTags;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandSelectTagContents(); cdecl;
begin
  npp.commandSelectTagContents;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandSelectTagContentsOnly(); cdecl;
begin
  npp.commandSelectTagContentsOnly;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandEncodeEntities(); cdecl;
begin
  npp.commandEncodeEntities;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandEncodeEntitiesInclLineBreaks(); cdecl;
begin
  npp.commandEncodeEntities(True);
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandDecodeEntities(); cdecl;
begin
  npp.commandDecodeEntities;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandEncodeJS(); cdecl;
begin
  npp.commandEncodeJS;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandDecodeJS(); cdecl;
begin
  npp.commandDecodeJS;
end;
{ ------------------------------------------------------------------------------------------------ }
procedure _commandAbout(); cdecl;
begin
  npp.commandAbout;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure _toggleLiveEntityecoding; cdecl;
begin
  npp.ToggleOption(@(npp.Options.LiveEntityDecoding), cmpEntities);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure _toggleLiveUnicodeDecoding; cdecl;
begin
  npp.ToggleOption(@(npp.Options.LiveUnicodeDecoding), cmpUnicode);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure HandleException(AException: TObject; AAddress: Pointer);
begin
  ShowException(AException, AAddress);
end;


{ ================================================================================================ }
{ TNppPluginHTMLTag }

{ ------------------------------------------------------------------------------------------------ }
constructor TNppPluginHTMLTag.Create;
var
  sk: PShortcutKey;
begin
  inherited;

  self.PluginName := '&HTML Tag';

  sk := self.MakeShortcutKey(False, True, False, 'T'); // Alt-T
  self.AddFuncItem('&Find matching tag', _commandFindMatchingTag, sk);

  sk := self.MakeShortcutKey(False, True, False, #113); // Alt-F2
  self.AddFuncItem('Select &matching tags', _commandSelectMatchingTags, sk);

  sk := self.MakeShortcutKey(False, True, True, 'T'); // Alt-Shift-T
  self.AddFuncItem('&Select tag and contents', _commandSelectTagContents, sk);

  sk := self.MakeShortcutKey(True, True, False, 'T'); // Ctrl-Alt-T
  self.AddFuncItem('Select tag &contents only', _commandSelectTagContentsOnly, sk);

  self.AddFuncSeparator;

  sk := self.MakeShortcutKey(True, False, False, 'E'); // Ctrl-E
  self.AddFuncItem('&Encode entities', _commandEncodeEntities, sk);

  sk := self.MakeShortcutKey(True, True, False, 'E'); // Ctrl-Alt-E
  self.AddFuncItem('Encode entities (incl. line &breaks)', _commandEncodeEntitiesInclLineBreaks, sk);

  sk := self.MakeShortcutKey(True, False, True, 'E'); // Ctrl-Shift-E
  self.AddFuncItem('&Decode entities', _commandDecodeEntities, sk);

  self.AddFuncSeparator;

  sk := self.MakeShortcutKey(False, True, False, 'J'); // Alt-J
  self.AddFuncItem('Encode &JS', _commandEncodeJS, sk);

  sk := self.MakeShortcutKey(False, True, True, 'J'); // Alt-Shift-J
  self.AddFuncItem('Dec&ode JS', _commandDecodeJS, sk);

  self.AddFuncSeparator;

  self.AddFuncItem('Automatically decode entities', _toggleLiveEntityecoding, nil);
  self.AddFuncItem('Automatically decode Unicode characters', _toggleLiveUnicodeDecoding, nil);

  self.AddFuncSeparator;

  self.AddFuncItem('&About...', _commandAbout);

  try
     FVersionInfo := TFileVersionInfo.Create(TSpecialFolders.DLLFullName);
     FVersionStr := PluginNameFromModule();
     FVersionStr :=
      Concat(FVersionStr,
        WideFormat(' %d.%d.%d (%s bit)',
          [FVersionInfo.MajorVersion, FVersionInfo.MinorVersion, FVersionInfo.Revision,
          {$IFDEF CPUX64}'64'{$ELSE}'32'{$ENDIF}]));
  except
    FreeAndNil(FVersionInfo);
  end;
end;

{ ------------------------------------------------------------------------------------------------ }
destructor TNppPluginHTMLTag.Destroy;
begin
  SaveOptions;
  if Assigned(FVersionInfo) then
    FreeAndNil(FVersionInfo);
  inherited;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.SetInfo(NppData: TNppData);
begin
  inherited SetInfo(NppData);
  if not FileExists(Entities) then
    CopyFileW(PWChar(DefaultEntitiesPath), PWChar(Entities), True);

  LoadOptions;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.DoNppnToolbarModification;
var
  Msg: WideString;
begin
  inherited;
  FApp := GetApplication(@Self.NppData, NppSimpleObjects.TSciApiLevel(Self.GetApiLevel));

{$IFDEF CPUX64}
  try
    if not SupportsBigFiles then begin
      Msg := 'The installed version of HTML Tag requires Notepad++ 8.3 or newer.'#13#10
             + 'Plugin commands have been disabled.';
      MessageBoxW(App.WindowHandle, PWideChar(Msg), PWideChar(FVersionStr), MB_ICONWARNING);
    end;
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
{$ENDIF}
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.DoCharAdded({%H-}const hwnd: HWND; const ch: Integer);
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  FindAndDecode(ch);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.ToggleOption(OptionPtr: PPluginOption; MenuPos: TCmdMenuPosition);
var
  cmdIdx: Integer;
begin
  OptionPtr^ := (not OptionPtr^);
  cmdIdx := Length(FuncArray) - Integer(MenuPos);
  SendMessage(Npp.NppData.nppHandle, NPPM_SETMENUITEMCHECK, FuncArray[cmdIdx].CmdID, LPARAM(OptionPtr^));
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.ShellExecute(const FullName, Verb, WorkingDir: WideString; const ShowWindow: Integer);
var
  SEI: TShellExecuteInfoW;
begin
  SEI := Default(TShellExecuteInfoW);
  SEI.cbSize := SizeOf(SEI);
  SEI.Wnd := App.WindowHandle;
  SEI.lpVerb := PWideChar(Verb);
  SEI.lpFile := PWideChar(FullName);
  SEI.lpParameters := nil;
  SEI.lpDirectory := PWideChar(WorkingDir);
  SEI.nShow := ShowWindow;
  ShellExecuteEx(@SEI);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandFindMatchingTag;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag;
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandFindMatchingTag};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectMatchingTags;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag([soTags]);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandSelectMatchingTags};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectTagContents;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag([soContents, soTags]);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandSelectTagContents};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectTagContentsOnly;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag([soContents]);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandSelectTagContentsOnly};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandEncodeEntities(const InclLineBreaks: Boolean = False);
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    if InclLineBreaks then
      U_Entities.EncodeEntities(U_Entities.TEntityReplacementScope.ersSelection, [eroEncodeLineBreaks])
    else
      U_Entities.EncodeEntities();
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandEncodeEntities};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandDecodeEntities;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  if (App.ActiveDocument.Selection.Length = 0) then
    FindAndDecode(0, dcEntity)
  else begin
    try
      U_Entities.DecodeEntities();
    except
      HandleException(ExceptObject, ExceptAddr);
    end;
  end;
end {TNppPluginHTMLTag.commandDecodeEntities};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandEncodeJS;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_JSEncode.EncodeJS();
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandEncodeJS};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandDecodeJS;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  if (App.ActiveDocument.Selection.Length = 0) then
    FindAndDecode(0, dcUnicode)
  else begin
    try
      U_JSEncode.DecodeJS();
    except
      HandleException(ExceptObject, ExceptAddr);
    end;
  end;
end {TNppPluginHTMLTag.commandDecodeJS};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandAbout;
var
  Text, DLLName: string;
begin
  try
    DLLName := TSpecialFolders.DLLFullName;
    if not Assigned(FVersionInfo) then begin
      FVersionInfo := TFileVersionInfo.Create(DLLName);
    end;

    Text := Format('%s'#10#10
                      + 'Plug-in location: %s'#10
                      + 'Config location: %s'#10
                      + 'Bugs: %s'#10
                      + 'Download: %s'#10#10
                      + #$00A9' 2011-2020 %s - %s'#10
                      + '  a.k.a. %s - %s (v0.1 - v1.1)'#10
                      + #$00A9' 2022 Robert Di Pardo (since v1.2)'#10#10
                      + 'Licensed under the %s - %s',
                     [FVersionStr,
                      ExtractFileDir(DLLName),
                      App.ConfigFolder,
                      FVersionInfo.Comments,
                      'https://bitbucket.org/rdipardo/htmltag/downloads',
                      FVersionInfo.LegalCopyright, 'http://fossil.2of4.net/npp_htmltag', // 'http://martijn.coppoolse.com/software',
                      'vor0nwe', 'http://sourceforge.net/users/vor0nwe',
                      'MPL 1.1', 'http://www.mozilla.org/MPL/1.1']);
    MessageBox(App.WindowHandle, PChar(Text), PChar(FVersionInfo.FileDescription), MB_ICONINFORMATION)
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandAbout};

{ ------------------------------------------------------------------------------------------------ }
function TNppPluginHTMLTag.GetEntitiesFilePath: nppString;
begin
  Result := IncludeTrailingPathDelimiter(Self.PluginConfigDir) + 'entities.ini';
end {TNppPluginHTMLTag.GetEntitiesFilePath};

{ ------------------------------------------------------------------------------------------------ }
function TNppPluginHTMLTag.GetOptionsFilePath: nppString;
begin
  Result := IncludeTrailingPathDelimiter(Self.PluginConfigDir) + 'options.ini';
end;

{ ------------------------------------------------------------------------------------------------ }
function TNppPluginHTMLTag.GetDefaultEntitiesPath: nppString;
begin
  Result := IncludeTrailingPathDelimiter(TSpecialFolders.DLL) + PluginNameFromModule() + '-entities.ini';
end;

{ ------------------------------------------------------------------------------------------------ }
function TNppPluginHTMLTag.PluginNameFromModule: nppString;
var
  PluginName: WideString;
begin
  PluginName := ChangeFileExt(ExtractFileName(TSpecialFolders.DLLFullName), EmptyWideStr);
  Result := StringReplace(PluginName, '_unicode', EmptyWideStr, []);
end;

{ ------------------------------------------------------------------------------------------------ }
function TNppPluginHTMLTag.GetConfigDir: nppString;
begin
  Result := IncludeTrailingPathDelimiter(Self.ConfigDir) + PluginNameFromModule();
  if (not DirectoryExists(Result)) then CreateDir(Result);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.LoadOptions;
var
  config: TUtf8IniFile;
  autoDecodeJs, autoDecodeEntities: Integer;
begin
  FOptions := Default(TPluginOptions);
  if FileExists(OptionsConfig) then begin
    config := TUtf8IniFile.Create(OptionsConfig);
    try
      FOptions.LiveEntityDecoding := config.ReadBool('AUTO_DECODE', 'ENTITIES', False);
      FOptions.LiveUnicodeDecoding := config.ReadBool('AUTO_DECODE', 'UNICODE_ESCAPE_CHARS', False);
    finally
      config.Free;
    end;
  end;
  autoDecodeJs := Length(FuncArray) - Integer(cmpUnicode);
  autoDecodeEntities := Length(FuncArray) - Integer(cmpEntities);
  FuncArray[autoDecodeJs].Checked := Options.LiveUnicodeDecoding;
  FuncArray[autoDecodeEntities].Checked := Options.LiveEntityDecoding;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.SaveOptions;
var
  config: TUtf8IniFile;
begin
  config := TUtf8IniFile.Create(OptionsConfig);
  try
    config.WriteBool('AUTO_DECODE', 'ENTITIES', Options.LiveEntityDecoding);
    config.WriteBool('AUTO_DECODE', 'UNICODE_ESCAPE_CHARS', Options.LiveUnicodeDecoding);
  finally
    config.Free;
  end;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.FindAndDecode(const KeyCode: Integer; Cmd: TDecodeCmd);
type
  TReplaceFunc = function(Scope: U_Entities.TEntityReplacementScope = ersSelection): Integer;
var
  doc: TActiveDocument;
  anchor, caret, selStart, nextCaretPos: Sci_Position;
  ch, charOffset, chValue: Integer;
  didReplace: Boolean;

  function Replace(Func: TReplaceFunc; Start: Sci_Position; EndPos: Sci_Position): Boolean;
  var
    nDecoded: Integer;
  begin
    nDecoded := 0;
    doc.Select(start, endPos - start);
    try
      nDecoded := Func();
    except
      HandleException(ExceptObject, ExceptAddr);
    end;
    Result := (nDecoded > 0);
  end;

begin
  ch := KeyCode and $FF;
  if ((Cmd = dcAuto) and
      ((not (Options.LiveEntityDecoding or Options.LiveUnicodeDecoding)) or
        (not (ch in [$09..$0D, $20])))) then
    Exit;

  charOffset := 0;
  didReplace := False;
  doc := App.ActiveDocument;
  caret := doc.CurrentPosition;
  if (Cmd = dcAuto) then
    caret := doc.SendMessage(SCI_POSITIONBEFORE, doc.CurrentPosition);

  for anchor := caret - 1 downto 0 do begin
    case (Integer(doc.SendMessage(SCI_GETCHARAT, anchor))) of
      0..$20: Break;
      $26 {'&'}: begin
          if (Options.LiveEntityDecoding or (cmd = dcEntity)) then begin
            didReplace := Replace(U_Entities.DecodeEntities, anchor, caret);
            Break;
          end;
      end;
      $5C {'\'}: begin
          if (Options.LiveUnicodeDecoding or (cmd = dcUnicode)) then begin
            selStart := anchor;
            // backtrack to previous codepoint, in case it's part of a multi-byte glyph
            if Integer(doc.SendMessage(SCI_GETCHARAT, anchor - 6)) = $5C then begin
              doc.Select(anchor - 6, 6);
              chValue := StrToInt(Format('$%s', [Copy(doc.Selection.Text, 3, 4)]));
              if (chValue >= $D800) and (chValue <= $DBFF) then
                Dec(selStart, 6);
            end;
            didReplace := Replace(U_JSEncode.DecodeJS, selStart, caret);
            // compensate for both characters of '\u' prefix
            Inc(charOffset);
            Break;
          end;
      end;
    end;
  end;

  if didReplace then begin
    if (ch in [$0A, $0D]) then // ENTER was pressed
      doc.CurrentPosition := doc.NextLineStartPosition
    else begin
      nextCaretPos := doc.SendMessage(SCI_POSITIONAFTER, doc.CurrentPosition);
      // stay in current line if at EOL
      if (nextCaretPos >= doc.NextLineStartPosition) then
        Exit;
      // no inserted char, nothing to offset
      if (Cmd > dcAuto) then charOffset := -1;
      doc.CurrentPosition := nextCaretPos + charOffset;
    end;
  end else begin
    // place caret after inserted char
    if (Cmd = dcAuto) then begin
      Inc(caret);
      if (ch = $0A) and (doc.SendMessage(SCI_GETEOLMODE) = SC_EOL_CRLF) then
        Inc(caret);
    end;
    doc.Selection.ClearSelection;
    doc.CurrentPosition := caret;
  end;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
initialization
  Npp := TNppPluginHTMLTag.Create;
end.
