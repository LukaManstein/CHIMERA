@echo off
rem Translates every shader of the title and builds its compute pipelines ahead of
rem time, into the cache play.cmd uses (same switches: scripts\env.cmd).
rem   scripts\precompile.cmd "<your dump folder>"
rem About 20 minutes on an 8-core CPU. Resumable: run it again to go on.
if "%~1"=="" (
  echo Usage: scripts\precompile.cmd "D:\path\to\your\dump"
  exit /b 1
)
call "%~dp0env.cmd"
if not exist "%CHIMERA_EXE%" (
  echo victory.exe not found at "%CHIMERA_EXE%". Build it first: cargo build --release -p victory
  exit /b 1
)
"%CHIMERA_EXE%" precompile "%~1" --pipelines
pause
