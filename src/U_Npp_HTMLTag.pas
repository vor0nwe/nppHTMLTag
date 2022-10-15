unit U_Npp_HTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
interface

uses
  SysUtils, Windows,
  NppPlugin,
  NppSimpleObjects, L_VersionInfoW;

type
  TNppPluginHTMLTag = class(TNppPlugin)
  private
    FApp: TApplication;
    FVersionInfo: TFileVersionInfo;
    FVersionStr: nppString;
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
  sk: PShortcutKey;
begin
  inherited;

  self.PluginName := '&HTML Tag';

  sk := self.MakeShortcutKey(True, False, False, 'T'); // Ctrl-T
  self.AddFuncItem('&Find matching tag', _commandFindMatchingTag, sk);

  sk := self.MakeShortcutKey(True, False, True, 'T'); // Ctrl-Shift-T
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
  FApp := GetApplication(@Self.NppData, NppSimpleObjects.TSciApiLevel(Self.GetApiLevel));

{$IFDEF CPUX64}
  try
    if not SupportsBigFiles then begin
      Msg := 'The installed version of HTML Tag requires Notepad++ 8.3 or newer.'#13#10
             + 'Plugin commands have been disabled.';
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
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag(False, False);
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandFindMatchingTag};

{ ------------------------------------------------------------------------------------------------ }
procedure TNppPluginHTMLTag.commandSelectTagContents;
begin
{$IFDEF CPUX64}
  if not SupportsBigFiles then
    Exit;
{$ENDIF}
  try
    U_HTMLTagFinder.FindMatchingTag(True, False);
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
    U_HTMLTagFinder.FindMatchingTag(True, True);
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
  try
    U_Entities.DecodeEntities();
  except
    HandleException(ExceptObject, ExceptAddr);
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






////////////////////////////////////////////////////////////////////////////////////////////////////
initialization
  Npp := TNppPluginHTMLTag.Create;
end.
