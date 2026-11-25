@echo off
rem CHIMERA (NVIDIA): what the desktop shortcut runs. Checks for a newer stable build,
rem then starts the title from the folder saved by the installer (chimera.cfg).
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\chimera-update.ps1" -Channel stable-nvidia
if exist chimera.cfg for /f "usebackq tokens=1,* delims==" %%a in ("chimera.cfg") do if /i "%%a"=="GAME" set GAME=%%b
if "%GAME%"=="" (
  echo No game folder set. Run scripts\install.ps1 again, or: set GAME=^<your folder^>
  pause
  exit /b 1
)
call scripts\chimera-turbo.cmd
echo.
echo The game has closed. Saves: %LOCALAPPDATA%\victory\data
pause
