unit L_SpecialFolders;

{$IFDEF FPC}
{$mode delphiunicode}
{$typedAddress on}
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////////////////////////
/// This Source Code Form is subject to the terms of the Mozilla Public
/// License, v. 2.0. If a copy of the MPL was not distributed with this file,
/// You can obtain one at https://mozilla.org/MPL/2.0/.

/// Extracted and adapted for FPC from L_SpecialFolders.pas, part of HTMLTag <http://fossil.2of4.net/npp_htmltag>
/// Original unit (c) 2012 MCO and DGMR raadgevende ingenieurs BV
/// Revisions Copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>
////////////////////////////////////////////////////////////////////////////////////////////////////

interface

type
  TSpecialFolders = class
  private
    class function GetModulePathName: string;
    class function GetDll: string; static; inline;
    class function GetDllDir: string; static; inline;
    class function GetDllBaseName: string; static; inline;
  public
    class property DLL: string                    read GetDllDir;
    class property DLLFullName: string            read GetDll;
  end;

  function ChangeFilePath(const FileName, Path: string): string;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation
uses
  Windows, SysUtils;

{ ------------------------------------------------------------------------------------------------ }
/// From SysUtils.pas, part of Delphi_MiniRTL, <https://github.com/paulocalaes/Delphi_MiniRTL>
/// Copyright (c) 1995-2010 Embarcadero Technologies, Inc.
function ChangeFilePath(const FileName, Path: string): string;
begin
  Result := IncludeTrailingPathDelimiter(Path) + ExtractFileName(FileName);
end;

{ ================================================================================================ }
{ TSpecialFolders }

{ ------------------------------------------------------------------------------------------------ }
class function TSpecialFolders.GetDll: string;
begin
  Result := GetModulePathName;
end {TSpecialFolders.GetDll};

{ ------------------------------------------------------------------------------------------------ }
class function TSpecialFolders.GetDllDir: string;
begin
  Result := ExtractFilePath(GetDll);
end {TSpecialFolders.GetDllDir};

{ ------------------------------------------------------------------------------------------------ }
class function TSpecialFolders.GetDllBaseName: string;
begin
  Result := ChangeFileExt(ExtractFileName(GetDll), '');
end {TSpecialFolders.GetDllBaseName};

{ ------------------------------------------------------------------------------------------------ }
class function TSpecialFolders.GetModulePathName: string;
var
  iSize, iResult, iError: integer;
begin
  repeat
    iSize := MAX_PATH;
    SetLength(Result, iSize);
    SetLastError(0);
    iResult := GetModuleFileNameW(HInstance, PWideChar(Result), iSize);
    iError := GetLastError;
    if iResult = 0 then begin
      if iError in [ERROR_SUCCESS, ERROR_MOD_NOT_FOUND] then begin
        Result := '';
        Exit;
      end else begin
        RaiseLastOSError;
      end;
    end else if iResult >= iSize then begin
      iSize := iResult + 1;
    end else begin
      SetLength(Result, iResult);
      Break;
    end;
  until iResult < iSize;

  if (WideCompareText(Copy(Result, 1, 4), '\\?\') = 0) then
      Result := Copy(Result, 5);
end {TSpecialFolders.GetModulePathName};

end.
