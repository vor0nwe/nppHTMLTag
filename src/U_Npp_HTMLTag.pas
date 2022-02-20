unit U_Npp_HTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
interface

uses
  SysUtils, Windows,
  NppPlugin, SciSupport,
  NppSimpleObjects, L_VersionInfoW;

type
  TNppPluginHTMLTag = class(TNppPlugin)
  private
    FApp: TApplication;
    FVersionInfo: TFileVersionInfo;
    FVersionStr: nppString;
    function SupportsBigFiles: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure commandFindMatchingTag;
    procedure commandSelectTagContents;
    procedure commandSelectTagContentsOnly;
    procedure commandEncodeEntities(const InclLineBreaks: Boolean = False);
    procedure commandDecodeEntities;
    procedure commandEncodeJS;
    procedure commandDecodeJS;
    procedure commandAbout;
    procedure DoNppnToolbarModification; override;

    procedure ShellExecute(const FullName: string; const Verb: string = 'open'; const WorkingDir: string = ''; const ShowWindow: Integer = SW_SHOWDEFAULT);

    property App: TApplication  read FApp;
  end;

procedure _commandFindMatchingTag(); cdecl;
procedure _commandSelectTagContents(); cdecl;
procedure _commandSelectTagContentsOnly(); cdecl;
procedure _commandEncodeEntities(); cdecl;
procedure _commandDecodeEntities(); cdecl;
procedure _commandEncodeJS(); cdecl;
procedure _commandDecodeJS(); cdecl;
procedure _commandAbout(); cdecl;


var
  Npp: TNppPluginHTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation

uses
  Strutils,
  ShellAPI,
  L_SpecialFolders,
  U_HTMLTagFinder, U_Entities, U_JSEncode;

{ ------------------------------------------------------------------------------------------------ }
procedure _commandFindMatchingTag(); cdecl;
begin
  npp.commandFindMatchingTag;
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
procedure HandleException(AException: TObject; AAddress: Pointer);
begin
  ShowException(AException, AAddress);
end;


{ ================================================================================================ }
{ TNppPluginHTMLTag }

{ ------------------------------------------------------------------------------------------------ }
constructor TNppPluginHTMLTag.Create;
var
  sk: TShortcutKey;
begin
  inherited;

  self.PluginName := '&HTML Tag';

  sk.IsShift := False; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'T'; // Ctrl-T
  self.AddFuncItem('&Find matching tag', _commandFindMatchingTag, sk);

  sk.IsShift := True; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'T'; // Ctrl-Shift-T
  self.AddFuncItem('&Select tag and contents', _commandSelectTagContents, sk);

  self.AddFuncItem('Select tag &contents only', _commandSelectTagContentsOnly);

  self.AddFuncSeparator;

  sk.IsShift := False; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'E'; // Ctrl-E
  self.AddFuncItem('&Encode entities', _commandEncodeEntities, sk);

  self.AddFuncItem('&Encode entities (incl. line breaks)', _commandEncodeEntitiesInclLineBreaks, False);

  sk.IsShift := True; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'E'; // Ctrl-Shift-E
  self.AddFuncItem('&Decode entities', _commandDecodeEntities, sk);

  self.AddFuncSeparator;

  sk.IsShift := False; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'J'; // Ctrl-J
  self.AddFuncItem('Encode &JS', _commandEncodeJS, sk);

  sk.IsShift := True; sk.IsCtrl := true; sk.IsAlt := False;
  sk.Key := 'J'; // Ctrl-Shift-J
  self.AddFuncItem('Dec&ode JS', _commandDecodeJS, sk);

  self.AddFuncSeparator;

  self.AddFuncItem('&About...', _commandAbout);

  try
     FVersionInfo := TFileVersionInfo.Create(TSpecialFolders.DLLFullName);
     FVersionStr := ChangeFileExt(ExtractFileName(TSpecialFolders.DLLFullName), '');
     FVersionStr :=
      Concat(FVersionStr,
        Format(' %d.%d.%d (%s bit)',
          [FVersionInfo.MajorVersion, FVersionInfo.MinorVersion, FVersionInfo.Revision,
          {$IFDEF CPUX64}'64'{$ELSE}'32'{$ENDIF}]));
  except
    FreeAndNil(FVersionInfo);
  end;

{$IFNDEF CPUX64}
  FVersionStr := ReplaceStr(FVersionStr, '_unicode', '');
{$ENDIF}
end;

{ ------------------------------------------------------------------------------------------------ }
destructor TNppPluginHTMLTag.Destroy;
begin
  if Assigned(FVersionInfo) then
    FreeAndNil(FVersionInfo);
  inherited;
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.DoNppnToolbarModification;
var
  Msg: string;
begin
  inherited;
  FApp := GetApplication(@Self.NppData);

{$IFDEF CPUX64}
  try
    if not SupportsBigFiles then begin
      Msg := 'The installed version of HTML Tag requires Notepad++ 8.3 or newer.'#13#10
             + 'Running any plugin command will crash the application!';
      MessageBox(App.WindowHandle, PChar(Msg), PChar(FVersionStr), MB_ICONWARNING);
    end;
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
{$ENDIF}
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.ShellExecute(const FullName, Verb, WorkingDir: string; const ShowWindow: Integer);
var
  SEI: TShellExecuteInfo;
begin
  SEI := Default(TShellExecuteInfo);
  SEI.cbSize := SizeOf(SEI);
  SEI.Wnd := App.WindowHandle;
  SEI.lpVerb := PChar(Verb);
  SEI.lpFile := PChar(FullName);
  SEI.lpParameters := nil;
  SEI.lpDirectory := PChar(WorkingDir);
  SEI.nShow := ShowWindow;
  ShellExecuteEx(@SEI);
end;

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandFindMatchingTag;
begin
  try
    U_HTMLTagFinder.FindMatchingTag(False, False);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandFindMatchingTag};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectTagContents;
begin
  try
    U_HTMLTagFinder.FindMatchingTag(True, False);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandSelectTagContents};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectTagContentsOnly;
begin
  try
    U_HTMLTagFinder.FindMatchingTag(True, True);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandSelectTagContentsOnly};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandEncodeEntities(const InclLineBreaks: Boolean = False);
begin
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
  try
    U_Entities.DecodeEntities();
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandDecodeEntities};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandEncodeJS;
begin
  try
    U_JSEncode.EncodeJS();
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandEncodeJS};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandDecodeJS;
begin
  try
    U_JSEncode.DecodeJS();
  except
    HandleException(ExceptObject, ExceptAddr);
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
function TNppPluginHTMLTag.SupportsBigFiles: Boolean;
var
  NppVerison: Cardinal;
begin
  NppVerison := FApp.SendMessage(NPPM_GETNPPVERSION);
  Result :=
    (HIWORD(NppVerison) > 8) or
    ((HIWORD(NppVerison) = 8) and
      // 8.3 -> 8,3 (*not* 8,30)
      ((LOWORD(NppVerison) = 3) or (LOWORD(NppVerison) > 21)));
end {TNppPluginHTMLTag.SupportsBigFiles};






////////////////////////////////////////////////////////////////////////////////////////////////////
initialization
  Npp := TNppPluginHTMLTag.Create;
end.
