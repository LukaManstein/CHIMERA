@echo off
rem CHIMERA launcher: scripts\play.cmd "<your dump>\<the title's exe>"
rem The first minutes are slow while shaders are translated; they are cached after that.
if "%~1"=="" (
  echo Usage: scripts\play.cmd "D:\path\to\your\dump\^<the title's exe^>"
  exit /b 1
)

rem Recommended switches (see README.md, "Switches").
if not defined VICTORY_LATE_WAIT set VICTORY_LATE_WAIT=3
if not defined VICTORY_WIDE_BACK set VICTORY_WIDE_BACK=1
if not defined VICTORY_CARD_BUFFERS_MIN_MB set VICTORY_CARD_BUFFERS_MIN_MB=1
if not defined VICTORY_CARD_BUFFERS_MB set VICTORY_CARD_BUFFERS_MB=1024
if not defined VICTORY_FULLSCREEN set VICTORY_FULLSCREEN=1

set "ROOT=%~dp0.."
set "EXE=%ROOT%\target\release\victory.exe"
if defined CARGO_TARGET_DIR set "EXE=%CARGO_TARGET_DIR%\release\victory.exe"
if not exist "%EXE%" (
  echo victory.exe not found at "%EXE%". Build it first: cargo build --release -p victory
  exit /b 1
)

if not exist "%ROOT%\logs" mkdir "%ROOT%\logs"
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set TS=%%t
set "LOG=%ROOT%\logs\chimera-%TS%.log"

"%EXE%" run "%~1" --execute > "%LOG%" 2>&1
echo Game exited. Log: %LOG%
echo Crash reports: %LOCALAPPDATA%\victory\data\crashes.log
pause
