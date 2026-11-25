@echo off
rem CHIMERA's recommended switches. play.cmd and precompile.cmd both call this file:
rem the shader cache is keyed by these switches, so they must match.
rem A variable already set in the environment is kept.

if not defined VICTORY_CARD_BUFFERS_MIN_MB set VICTORY_CARD_BUFFERS_MIN_MB=1
if not defined VICTORY_CARD_BUFFERS_MB set VICTORY_CARD_BUFFERS_MB=2048
if not defined VICTORY_RELAY set VICTORY_RELAY=2
if not defined VICTORY_LATE_WAIT set VICTORY_LATE_WAIT=3
if not defined VICTORY_WIDE_BACK set VICTORY_WIDE_BACK=1
if not defined VICTORY_LIBRARY_TRIM set VICTORY_LIBRARY_TRIM=0
if not defined VICTORY_REBAR set VICTORY_REBAR=0
if not defined VICTORY_COPY_BACK_ONLY_READBACK set VICTORY_COPY_BACK_ONLY_READBACK=0
if not defined VICTORY_AMBIENT_STUB set VICTORY_AMBIENT_STUB=1
if not defined VICTORY_SHADOWMASK_STUB set VICTORY_SHADOWMASK_STUB=1
if not defined VICTORY_OWN_UPSCALER set VICTORY_OWN_UPSCALER=1
if not defined VICTORY_RENDER_SCALE set VICTORY_RENDER_SCALE=0.5
rem A frame waits at most 100 ms for a pipeline still being built (upstream: up to 12 s).
if not defined VICTORY_PIPELINE_WAIT_MS set VICTORY_PIPELINE_WAIT_MS=100

set "CHIMERA_ROOT=%~dp0.."
set "CHIMERA_EXE=%CHIMERA_ROOT%\target\release\victory.exe"
if defined CARGO_TARGET_DIR set "CHIMERA_EXE=%CARGO_TARGET_DIR%\release\victory.exe"
