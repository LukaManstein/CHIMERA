@echo off
rem CHIMERA turbo: the launch profile the Chapter 1 recording was made with.
rem Set GAME to the folder of your own copy of the title, then run from the repository root
rem after `cargo build --release -p victory` and `cargo xtask agility` (Windows 10).
if "%GAME%"=="" set GAME=%~dp0..\game
set VICTORY_ASYNC_SUBMIT=1
set VICTORY_QUEUE2=1
set VICTORY_INDIRECT_WINDOW=1
set VICTORY_TEXTURE_NO_WAIT=1
set VICTORY_MERGE_GAP=64
set VICTORY_MERGE_RUNS=4096
set VICTORY_LATE_WAIT=3
set VICTORY_WIDE_BACK=1
set VICTORY_CARD_BUFFERS_MIN_MB=1
set VICTORY_CARD_BUFFERS_MB=4096
set VICTORY_WIDE_REFRESH=1
set VICTORY_WIDE_MERGE=1
set VICTORY_JOIN_COPIES=1
set VICTORY_PIPELINE_WORKERS=12
set VICTORY_PIPELINE_NORMAL=1
set VICTORY_DISPLAY_MODE=1280x720
set VICTORY_AMBIENT=0.6
if "%1"=="warm" (
  target\release\victory.exe warm --jobs 16 "%GAME%\shaders.rpf"
  goto :eof
)
for %%f in ("%GAME%\*.exe") do set EXE=%%f
target\release\victory.exe run "%EXE%" --execute
