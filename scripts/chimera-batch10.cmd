@echo off
rem CHIMERA batch10 (NVIDIA, experimental): turbo-next + texture-format fixes (BCPack BC7, 3D pitch, mip tails)
rem + Nitric Acid (VIctory-Omega) shader work: paired wave64, mesh+pixel link, geometry shaders,
rem loop limits, dispatches past 65,535 groups, texture streaming fixes, sRGB views.
rem Usage: scripts\chimera-batch10.cmd        - run the title (GAME from chimera.cfg)
rem        scripts\chimera-batch10.cmd warm   - translate every shader into the cache first
cd /d "%~dp0.."
if exist chimera.cfg for /f "usebackq tokens=1,* delims==" %%a in ("chimera.cfg") do if /i "%%a"=="GAME" set GAME=%%b
if "%GAME%"=="" ( echo No game folder set: run scripts\install.ps1, or set GAME=^<your folder^> & exit /b 1 )

rem --- fork author, "Frame rate, second night" ---
set VICTORY_ASYNC_SUBMIT=1
set VICTORY_QUEUE2=1
set VICTORY_INDIRECT_WINDOW=1
rem 0: a texture refresh waits for the runtime remapping (trustno1: rainbow, pixelated skin with 1)
set VICTORY_TEXTURE_NO_WAIT=0
set VICTORY_MERGE_RUNS=4096
rem --- older switches of the fork ---
set VICTORY_LATE_WAIT=3
set VICTORY_WIDE_BACK=1
rem leave more of the 12 GB card to textures (default keeps 3 GB for targets; textures waited and drew black)
set VICTORY_CARD_ROOM_FOR_TARGETS_MB=2048
rem at most 128 MB of textures staged a frame (192 by default): smoother frames while an area streams in
set VICTORY_TEXTURE_STAGE_MB=128
rem the card's memory only for the texture levels in use (saved 3.8 GB in the city)
set VICTORY_LEVELS_ON_DEMAND=1
rem --- VItoriaBr preset ---
set VICTORY_WIDE_REFRESH=1
set VICTORY_WIDE_MERGE=1
set VICTORY_JOIN_COPIES=1
rem --- our own: build card pipelines on 12 threads at normal priority ---
set VICTORY_PIPELINE_WORKERS=12
set VICTORY_PIPELINE_NORMAL=1
rem 720p internal resolution: less work on the card and fewer bytes copied back
set VICTORY_DISPLAY_MODE=1280x720
set VICTORY_FULLSCREEN=0
rem constant indirect light where the game's ray-traced light does not run (0 = none, off = game's own)
set VICTORY_AMBIENT=0.6
rem victory-fork 0b0074e: title-memory copies in user mode instead of a kernel call per piece
set VICTORY_COPY_PLAIN=1
rem victory-fork 3973179: parts in a row go to the card as one submission (~6%), copy-back through our own view (~9%)
set VICTORY_JOIN_PARTS=1
set VICTORY_BACK_OWN_VIEW=1
rem victory-fork 465b94f: scattered indirect records clamped once per list
set VICTORY_INDIRECT_GATHER=1
rem CHIMERA: fills of upload memory in a row copied on several threads
set VICTORY_WIDE_FILL=1
rem every frame's parts in the log (frame times, copies, waits)
set VICTORY_FRAME_LOG=1
set VICTORY_WRITE_STATS=1
set VICTORY_WIDE_HEAP=1
rem from VItoriaBr v19 preset: late-written placed textures uploaded again (black skin and ground), table buffers (their 2.7 to 5.8 fps)
set VICTORY_PAGE_WRITES=slots
set VICTORY_TABLE_BUFFERS=1
set VICTORY_UNWATCHED_FRAMES=4
rem water textures copied back (boat floats): off by default since fxceless PR 999
set VICTORY_TEXTURE_BACK=1
rem rays miss while no structure is built: sky light instead of black bounce light (vx-layer, Flamingo)
set VICTORY_BVH_MISS=1
rem NaN/inf colours become 0 (black sun, black blobs; trustno1-coder)
set VICTORY_NAN_SCRUB=1
rem NVIDIA caps the view heap: the dynamic slot pool may take up to half (trustno1-coder)
set VICTORY_DYNAMIC_SLOTS=524288
rem the bindless-texture pass on its own thread (760 ms a frame on the recording thread without it)
set VICTORY_HEAP_WORKER=1
rem --- fork survey 2026-11-26 ---
rem hold the title's GPU heap defrag shader: its moves left coloured blocks and stale textures (SPOOKEXE 66af26c0)
set VICTORY_SKIP_PIPELINES=02384a60fda6f2d0
rem a fill that reads ahead of a flight waits for it (the 2 KiB race fired in our log; blurred ovals)
set VICTORY_FILL_WAIT=1
rem buffer host-copy lookups answered from a cache (fxceless run 293: -14 ms a frame)
set VICTORY_LOOKUP_CACHE=1
rem from fxceless best-playing set (run 279)
set VICTORY_CARD_HASH_LEN=1
rem smaller buffers compared on the card too (card work 68 -> 50 ms a frame)
set VICTORY_CARD_BUFFERS_MIN_KB=64
set VICTORY_CARD_BUFFERS_MB=1280

if "%1"=="warm" (
  rem warm-up keys must match the device: wave32 lanes and the NVIDIA view heap cap minus the null slot (RTX 20xx-50xx)
  set VICTORY_HOST_WAVE=32
  set VICTORY_VIEW_LIMIT=999999
  target\release\victory.exe warm --jobs 16 "%GAME%\shaders.rpf"
  goto :eof
)
set EXE=%GAME%\game_scarlett_master.exe
if not exist "%EXE%" for %%f in ("%GAME%\*.exe") do set EXE=%%f
target\release\victory.exe run "%EXE%" --execute
