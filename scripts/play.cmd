@echo off
rem CHIMERA launcher.
rem   scripts\play.cmd "<your dump>\<the title's exe>"      Series X profile
rem   scripts\play.cmd "<your dump>\<the title's exe>" s    Series S profile
rem Run scripts\precompile.cmd once first, or the first minutes are very slow.
if "%~1"=="" (
  echo Usage: scripts\play.cmd "D:\path\to\your\dump\^<the title's exe^>" [s]
  exit /b 1
)
call "%~dp0env.cmd"
if not exist "%CHIMERA_EXE%" (
  echo victory.exe not found at "%CHIMERA_EXE%". Build it first: cargo build --release -p victory
  exit /b 1
)

set "CONSOLE="
set "PROFILE=x"
if /i "%~2"=="s" (
  set "CONSOLE=--console series-s"
  set "PROFILE=s"
)

if not exist "%CHIMERA_ROOT%\logs" mkdir "%CHIMERA_ROOT%\logs"
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set TS=%%t
set "LOG=%CHIMERA_ROOT%\logs\chimera-%PROFILE%-%TS%.log"

"%CHIMERA_EXE%" run %CONSOLE% --execute "%~1" > "%LOG%" 2>&1
echo Game exited. Log: %LOG%
echo Crash reports: %LOCALAPPDATA%\victory\data\crashes.log
pause
