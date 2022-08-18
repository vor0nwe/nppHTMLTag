@echo off
SETLOCAL
set EXIT_CODE=0
pushd %~dp0fpg
git apply -v "%~dp0patches\no_drag_and_drop.diff" 2>NUL
git grep -niE "Ole(Un|)Initialize" -- src/corelib/gdi 2>NUL
popd
if %ERRORLEVEL%==0 (SET EXIT_CODE=2)
exit /B %EXIT_CODE%
ENDLOCAL
