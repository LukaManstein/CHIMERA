@echo off
rem CHIMERA turbo: the launch profile of branch turbo-next (see docs/CHIMERA.md).
rem Set GAME to the folder of your own copy of the title, then run from the repository root
rem after `cargo build --release -p victory` and `cargo xtask agility` (Windows 10).
if "%GAME%"=="" set GAME=%~dp0..\game
set VICTORY_ASYNC_SUBMIT=1
set VICTORY_QUEUE2=1
set VICTORY_INDIRECT_WINDOW=1
set VICTORY_TEXTURE_NO_WAIT=1
set VICTORY_LATE_WAIT=3
set VICTORY_WIDE_BACK=1
set VICTORY_CARD_BUFFERS_MIN_MB=1
set VICTORY_CARD_BUFFERS_MB=1024
rem leave the card's memory to textures on 8-12 GB cards (they drew black otherwise)
set VICTORY_CARD_ROOM_FOR_TARGETS_MB=2048
rem the card's memory only for the texture levels in use (saved 3.8 GB in the city; textures/faces drew empty on 12 GB cards)
set VICTORY_LEVELS_ON_DEMAND=1
rem at most 128 MB of textures staged a frame: fewer dips while an area streams in
set VICTORY_TEXTURE_STAGE_MB=128
set VICTORY_WIDE_REFRESH=1
set VICTORY_WIDE_MERGE=1
set VICTORY_JOIN_COPIES=1
set VICTORY_PIPELINE_WORKERS=12
set VICTORY_PIPELINE_NORMAL=1
set VICTORY_DISPLAY_MODE=1280x720
set VICTORY_AMBIENT=0.6
rem title-memory copies in user mode (victory-fork 0b0074e)
set VICTORY_COPY_PLAIN=1
rem victory-fork 3973179: one submission for parts in a row, copy-back through our own view
set VICTORY_JOIN_PARTS=1
set VICTORY_BACK_OWN_VIEW=1
rem victory-fork 465b94f: scattered indirect records clamped once per list
set VICTORY_INDIRECT_GATHER=1
if "%1"=="warm" (
  target\release\victory.exe warm --jobs 16 "%GAME%\shaders.rpf"
  goto :eof
)
set EXE=%GAME%\game_scarlett_master.exe
if not exist "%EXE%" for %%f in ("%GAME%\*.exe") do set EXE=%%f
target\release\victory.exe run "%EXE%" --execute
