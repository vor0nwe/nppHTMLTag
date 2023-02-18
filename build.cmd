@echo off
::
:: Copyright (c) 2023 Robert Di Pardo <dipardo.r@gmail.com>
::
:: This Source Code Form is subject to the terms of the Mozilla Public
:: License, v. 2.0. If a copy of the MPL was not distributed with this file,
:: You can obtain one at https://mozilla.org/MPL/2.0/.
::
SETLOCAL

set "FPC_BUILD_TYPE=Debug"
set "FPC_CPU=x86_64"

if "%1" NEQ "" ( set "FPC_BUILD_TYPE=%1" )
if "%2" NEQ "" ( set "FPC_CPU=%2" )
call :%FPC_BUILD_TYPE% 2>NUL:
if %errorlevel%==1 ( goto :USAGE )

:Release
del /S /Q /F out\*.zip 2>NUL:
:Debug

call %~dp0src\Forms\suppress_ole_init.cmd
if %errorlevel%==2 (
  echo Patch failed
  goto :END
)

set "BUILD_ALL="
if "%3"=="clean" (
  rmdir /S /Q out 2>NUL:
  set "BUILD_ALL=-B"
)

lazbuild %BUILD_ALL% --bm=%FPC_BUILD_TYPE% --cpu=%FPC_CPU% src\prj\HTMLTag.lpi
goto :END

:USAGE
echo Usage: ".\%~n0 [Debug,Release] [i386,x86_64] [clean]"

:END
exit /B %errorlevel%

ENDLOCAL
