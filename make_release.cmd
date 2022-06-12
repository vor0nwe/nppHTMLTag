@echo off
::
:: Copyright (c) 2022 Robert Di Pardo <dipardo.r@gmail.com>
::
:: This Source Code Form is subject to the terms of the Mozilla Public License,
:: v. 2.0. If a copy of the MPL was not distributed with this file, You can
:: obtain one at http://mozilla.org/MPL/2.0/.
::
SETLOCAL

set "VERSION=131"
set "PLUGIN=HTMLTag"
set "PLUGIN_LEGACY_DLL=out\i386-win32\Release\%PLUGIN%_unicode.dll"
set "SLUG_SRC=out\%PLUGIN%_v%VERSION%"
set "SLUGX64_SRC=out\%PLUGIN%_v%VERSION%_x64"
set "SLUG=%SLUG_SRC%.zip"
set "SLUGX64=%SLUGX64_SRC%.zip"

del /S /Q /F out\*.zip

xcopy /DIY *.textile "out\Doc"

:: https://fossil.2of4.net/npp_htmltag/doc/trunk/doc/HTMLTag-readme.txt
echo F | xcopy /DV ".\out\i386-win32\Release\%PLUGIN%.dll" ".\%PLUGIN_LEGACY_DLL%"
7z a -tzip "%SLUG%" ".\%PLUGIN_LEGACY_DLL%" ".\dat\*.ini" ".\out\Doc" -y
7z a -tzip "%SLUGX64%" ".\out\x86_64-win64\Release\%PLUGIN%.dll" ".\dat\*.ini" ".\out\Doc" -y

ENDLOCAL
