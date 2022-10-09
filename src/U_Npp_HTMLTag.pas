unit U_Npp_HTMLTag;

////////////////////////////////////////////////////////////////////////////////////////////////////
/// This Source Code Form is subject to the terms of the Mozilla Public
/// License, v. 2.0. If a copy of the MPL was not distributed with this file,
/// You can obtain one at https://mozilla.org/MPL/2.0/.

/// Copyright (c) Martijn Coppoolse <https://sourceforge.net/u/vor0nwe>
/// Revisions copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>
////////////////////////////////////////////////////////////////////////////////////////////////////
interface

uses
  SysUtils, Windows,
  NppPlugin,
  fpg_main,
  AboutForm,
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

    procedure ShellExecute(const FullName: WideString; const Verb: WideString = 'open'; const WorkingDir: WideString = '';
      const ShowWindow: Integer = SW_SHOWDEFAULT);

    property App: TApplication  read FApp;
    property Version: nppString  read FVersionStr;
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
  About: TFrmAbout;

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
{$IFDEF FPC}
     FVersionStr := UTF8ToString(ChangeFileExt(ExtractFileName(UTF8Encode(TSpecialFolders.DLLFullName)), ''));
{$ELSE}
     FVersionStr := ChangeFileExt(ExtractFileName(TSpecialFolders.DLLFullName), '');
{$ENDIF}
     FVersionStr :=
      Concat(FVersionStr,
        WideFormat(' %d.%d.%d (%s bit)',
          [FVersionInfo.MajorVersion, FVersionInfo.MinorVersion, FVersionInfo.Revision,
          {$IFDEF CPUX64}'64'{$ELSE}'32'{$ENDIF}]));
  except
    FreeAndNil(FVersionInfo);
  end;

{$IFNDEF CPUX64}
  FVersionStr := UTF8ToString(ReplaceStr(UTF8Encode(FVersionStr), '_unicode', ''));
{$ENDIF}
end;

{ ------------------------------------------------------------------------------------------------ }
destructor TNppPluginHTMLTag.Destroy;
begin
  if Assigned(FVersionInfo) then
    FreeAndNil(FVersionInfo);
  if Assigned(About) then
    FreeAndNil(About);
  inherited;
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
{$IFDEF FPC}
  ShellExecuteExW(LPSHELLEXECUTEINFOW(@SEI));
{$ELSE}
  ShellExecuteExW(@SEI);
{$ENDIF}
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
begin
  try
    if not Assigned(About) then begin
      About := TFrmAbout.Create(nil);
    end;
      About.Show;
  except
    HandleException(ExceptObject, ExceptAddr);
  end;
end {TNppPluginHTMLTag.commandAbout};

{ ------------------------------------------------------------------------------------------------ }






////////////////////////////////////////////////////////////////////////////////////////////////////
initialization
  Npp := TNppPluginHTMLTag.Create;
  fpgApplication.Initialize;
end.
