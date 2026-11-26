# Running CHIMERA

## Which build is mine?

| Your graphics card | Take | What it is |
|---|---|---|
| **NVIDIA** RTX 20xx / 30xx / 40xx / 50xx | **CHIMERA (NVIDIA) — `stable-nvidia-…` release** | tested builds; the installer and the shortcut use these |
| NVIDIA, want the newest | branch `next-nvidia` (= `turbo-next`) | today's work, not yet tested as long |
| NVIDIA, testing | branch `chimera-batch10` | experimental: texture-format fixes + Nitric Acid's shader work, launcher with progress; see [CHIMERA batch10](#chimera-batch10-experimental) |
| **AMD** Radeon | not CHIMERA for now: [Belobug/VIctory-Belobug-AMD](https://github.com/Belobug/VIctory-Belobug-AMD) | CHIMERA has not been run on AMD |

## The easy way: installer + desktop shortcut

In **PowerShell** (not as administrator):

```powershell
irm https://raw.githubusercontent.com/LukaManstein/CHIMERA/turbo-next/scripts/install.ps1 | iex
```

It checks Git, Rust and the Visual Studio C++ build tools (and offers to install the
missing ones with `winget`), downloads CHIMERA into `%LOCALAPPDATA%\CHIMERA`, builds the
newest `stable-nvidia` release, asks for the folder of your own copy of the title,
translates the shaders ahead of time and puts **CHIMERA (NVIDIA)** on the desktop.

**Every start from the shortcut checks GitHub for a newer `stable-nvidia` release** and
asks before updating (an update rebuilds and translates the shaders again). Without a
connection it just starts the installed build.

## By hand (branch `turbo-next`)

CHIMERA runs an Xbox Series title natively on Windows from **your own copy** of it.
Nothing of the title is in this repository, and there is no ready-made download:
anything offering one is a scam.

What to expect today: the world plays slowly (about 4–5 frames a second on a
Ryzen 7 2700 + RTX 3080 Ti), the boat in the first mission floats, shadowed
places are lit by a constant instead of ray tracing, and some effects are missing.

## 1. What you need

| | |
|---|---|
| Windows | 10 (21H2 or newer) or 11, 64-bit |
| Graphics | a DirectX 12 card with shader model 6.6: NVIDIA RTX 20xx or newer, AMD RX 6000 or newer; 8 GB of video memory at least, 12 GB+ recommended; a current driver |
| Processor / memory | 8 cores or more; **32 GB of RAM** (the process uses 15–20 GB) |
| Disk | about 15 GB free for the build and the caches, on an SSD |
| The title | your own dump of the Xbox Series build `1.0.2.1`, as a folder |
| Tools | [Git](https://git-scm.com/download/win), [Rust](https://rustup.rs) (`rustup` picks the pinned 1.98.1 itself), [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) with **"Desktop development with C++"** |

## 2. Get and build it (once)

Open **x64 Native Tools Command Prompt for VS** (or any terminal where `cargo` works):

```bat
git clone --branch turbo-next https://github.com/LukaManstein/CHIMERA.git
cd CHIMERA
cargo build --release -p victory
cargo xtask agility
```

- The build takes 5–15 minutes the first time.
- `cargo xtask agility` downloads Microsoft's D3D12 Agility SDK from nuget.org
  (checked against its published SHA-512) into `target\release\D3D12\`.
  **Windows 10 needs it**; on Windows 11 it does no harm.

## 3. Point it at your copy of the title

```bat
set GAME=D:\path\to\your\title-folder
```

The folder is the one holding the title's executable and `shaders.rpf`.
(Or put the folder next to the repository as `game\`, which is the default.)

## 4. Translate the shaders ahead of time (once per build)

```bat
scripts\chimera-turbo.cmd warm
```

About 4 minutes on 16 threads (≈26,000 shaders). Without it the first launch
sits on a black or frozen screen for many minutes while shaders translate.

## 5. Play

```bat
scripts\chimera-turbo.cmd
```

- **First time in the world:** about a minute of stutter and missing objects
  while the card's pipelines are built; they are kept on disk after that.
- The window caption shows the frame rate.
- **Saves** are written by the title itself at its own checkpoints, into
  `%LOCALAPPDATA%\victory\data`. There are no save states: closing the window
  in the middle of a mission loses everything since the last checkpoint.
  Back that folder up after a mission.

### Keyboard (no controller needed)

| Keys | Controller |
|---|---|
| W A S D / I J K L | left stick / right stick |
| Arrows | D-pad |
| Enter, Backspace, X, Y | A, B, X, Y |
| Q / E | LB / RB |
| Z / C | LT / RT (C = throttle in vehicles) |
| F / H | L3 / R3 |
| Esc, Tab | Menu, View |

An XInput controller works as well.

## 6. If something goes wrong

| Symptom | Try |
|---|---|
| "shader model 6.5" error, or nothing draws on Windows 10 | `cargo xtask agility` was not run, or `target\release\D3D12\` is missing |
| Black screen for minutes on the first launch | step 4 was skipped; it carries on where it stopped if you run it again |
| Black textures, a dark world on an 8–12 GB card | already set in the launcher (`VICTORY_CARD_BUFFERS_MB=1024`, `VICTORY_CARD_ROOM_FOR_TARGETS_MB=2048`); close other programs that use the GPU (browsers, recorders) |
| The boat sinks in the first mission | you are not on `turbo` / `turbo-next` (the fix is vx-layer's texture copy-back, `eee5667d`) |
| Display driver reset (screens flash black) | add `set VICTORY_INDIRECT_WINDOW=0` to the launcher |
| A crash | the log is printed to the terminal; `%LOCALAPPDATA%\victory\data\crashes.log` has the details. Open an issue with both |

## What the launcher switches do

All of them are in `scripts\chimera-turbo.cmd` and can be turned off one by one
(set to `0`) to find which one a problem comes from. The speed switches come
from fxceless/victory-fork, the shader fixes from uiliannn/VItoriaBr, the boat
fix from Geckomacabre/vx-layer, the ambient light from Belobug; see the README's
credits.

## CHIMERA batch10 (experimental)

Branch `chimera-batch10` = `next-nvidia` plus:

- texture formats: BCPack BC7, depth pitch of 3D textures, thick 3D mip tails;
- from [Nitric Acid's VIctory-Omega](https://github.com/NitricAcidDev/VIctory-Omega-Fork): the paired wave64
  form (7 compute shaders the NVIDIA driver refused), mesh+pixel linking, geometry shaders
  (GS_Voxelize) and their pipelines, per-stage loop limits, dispatches past 65,535 groups,
  normalized buffer formats, texture streaming fixes (late blocks, remapped memory, retries),
  sRGB on compressed materials, CBV tables on replay;
- `VICTORY_HEAP_WORKER=1`: the pass over textures picked by index runs on its own thread
  (it took ~760 ms a frame on the recording thread in 3D scenes);
- `scripts\chimera-batch10.cmd warm` warms the shader cache with the device's keys
  (`VICTORY_HOST_WAVE=32`, `VICTORY_VIEW_LIMIT=1000000` on NVIDIA);
- `scripts\chimera-launcher.ps1`: a window with the warm-up progress, then the game and its frame rate.

Measured (Ryzen 7 2700 + RTX 3080 Ti, Windows 10 LTSC, 720p): menus 30 fps; 3D scenes 2-6 fps and
**unstable** (median frame 170-200 ms, spikes to 1 s). Known problems being worked on: shaders still
translated during play after a warm-up, CPU-bound submission (the card is 6-16% busy), texture
artifacts ("a texture picked by index changed after its upload"). Not a release: use `stable-nvidia`
to play.

```bat
git checkout chimera-batch10
cargo build --release
scripts\chimera-batch10.cmd warm
powershell -ExecutionPolicy Bypass -File scripts\chimera-launcher.ps1
```
