<p align="center">
  <img src="docs/assets/chimera-banner.svg" alt="CHIMERA" width="100%">
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: GPL-3.0-or-later" src="https://img.shields.io/badge/license-GPL--3.0--or--later-7a5cff"></a>
  <img alt="Language: Rust" src="https://img.shields.io/badge/rust-stable-ff9a3c">
  <img alt="Platform: Windows 10/11" src="https://img.shields.io/badge/windows-10%20%7C%2011-ff4d8d">
  <img alt="Status: work in progress" src="https://img.shields.io/badge/status-work%20in%20progress-555">
  <a href="https://t.me/+rL9uLOqRWck2ZDMx"><img alt="Telegram" src="https://img.shields.io/badge/telegram-join-26A5E4?logo=telegram&logoColor=white"></a>
</p>

**CHIMERA** runs an Xbox Series title natively on Windows, from files you
supply yourself. It is built on
[victory-perf](https://github.com/vitutu1/victory-perf) — the fastest public
fork of [VIctory](https://github.com/Marvisak/VIctory) /
[victory-fork](https://github.com/fxceless/victory-fork) — and adds
**Windows 10 support**, **stability fixes** and **faster memory copies**
gathered from across the community, plus its own audio work. The name is the
point: it is stitched together from the best parts of many people's work.

> **This repository contains no game files, keys, code or assets of the title,
> and never links to any.** You need your own copy. CHIMERA is not affiliated
> with or endorsed by the title's developer or publisher, or by Microsoft.
> There is no download of a ready-to-play build — anything offering one is a scam.

---

## Status

Measured on **Windows 10 LTSC 21H2 · AMD Ryzen 7 2700 · NVIDIA RTX 3080 Ti 12 GB · 32 GB RAM**
(a 2018 CPU — the emulation is bound by single-thread speed and CPU↔GPU synchronisation).

| Stage | State |
|---|---|
| Boot, first-boot screens, intro, menus | works, 30 fps |
| Saves and settings | work |
| Prologue gameplay (Series X profile, 50 % render scale) | plays, **4.3–4.9 fps** once shaders are built; 3–4 fps in heavy scenes |
| Shadowed interiors | lit by stand-ins (`VICTORY_AMBIENT_STUB`, `VICTORY_SHADOWMASK_STUB`), not real ray tracing |
| First launch | slow: shaders and pipelines are built — run `scripts\precompile.cmd` first |
| Series S profile | boots; may crash while streaming the prologue's scripted scene |

For the upstream author's numbers on a faster PC (9–14 fps on a Ryzen 7 9800X3D) see
[docs/victory-perf-README.md](docs/victory-perf-README.md).

## What CHIMERA adds on top of victory-perf

| Change | From | Why |
|---|---|---|
| D3D12 Agility SDK runtime | kykifox1337-source | **Windows 10**: shader model 6.6 without Windows 11 |
| Title-memory copies in user mode, guard pages kept (`VICTORY_TITLE_COPY`, on) | TG0000 (triippywhale/victory-fork) | no system call per copy — the copies are the biggest part of a frame |
| Compute loops capped at 256, bounded direct dispatches | spacede (Emiriley/victory-fork) | no GPU driver reset (TDR) after minutes of play |
| XMA decoder at time-critical priority, decoder state carried across contexts (`VICTORY_XMA_CARRY`, on), audio stats in the log | LukaManstein | audio crackles at every stream seam |

## Requirements

- Windows 10 or 11, x64, a CPU with AVX2
- A Direct3D 12 GPU with shader model 6.6 and mesh shaders (NVIDIA RTX 20 series or newer)
- [Rust](https://rustup.rs) — the version is pinned in `rust-toolchain.toml`
- 32 GB RAM recommended. If `crashes.log` reports Windows error **1455**, enlarge the paging file.

## Build

```powershell
git clone https://github.com/LukaManstein/CHIMERA
cd CHIMERA
cargo build --release -p victory
cargo xtask agility          # Windows 10 only: puts the D3D12 runtime beside victory.exe
```

## Play

```powershell
scripts\precompile.cmd "D:\path\to\your\dump"                       # once: ~20 min, resumable
scripts\play.cmd       "D:\path\to\your\dump\<the title's exe>"     # Series X profile
scripts\play.cmd       "D:\path\to\your\dump\<the title's exe>" s   # Series S profile
```

The launcher sets the fastest known switches (below), runs windowed and writes a
log next to the repository.

Keyboard (when no pad is connected): **WASD** left stick · **IJKL** right stick ·
**arrows** D-pad · **Enter** A · **Backspace** B · **X / Y** · **Q / E** shoulders ·
**Z / C** triggers · **Esc** Menu · **Tab** View. XInput pads work as they are.

### The launcher's switches

| Variable | Effect |
|---|---|
| `VICTORY_OWN_UPSCALER=1`, `VICTORY_RENDER_SCALE=0.5` | render at half resolution through the title's own upscaler |
| `VICTORY_AMBIENT_STUB=1`, `VICTORY_SHADOWMASK_STUB=1` | light pitch-black shadowed areas with stand-ins |
| `VICTORY_RELAY=2`, `VICTORY_LATE_WAIT=3`, `VICTORY_WIDE_BACK=1` | overlap CPU and GPU work |
| `VICTORY_CARD_BUFFERS_MIN_MB=1`, `VICTORY_CARD_BUFFERS_MB=2048` | keep title buffers in video memory |
| `VICTORY_PIPELINE_WAIT_MS=100` | a frame waits at most 100 ms for a pipeline still being built (upstream waits up to 12 s) |
| `VICTORY_TITLE_COPY=0` / `VICTORY_XMA_CARRY=0` | turn CHIMERA's copy or audio change off, for comparison |

## Roadmap

- [ ] Audio without crackles — state carry is in, still being verified
- [ ] A steady 5+ fps in the world on a Ryzen 7 2700-class CPU
- [ ] GPU particle emitters the host refuses (27 compute pipelines, `E_INVALIDARG`)
- [ ] Textures that change after upload without being noticed
- [ ] Real ray-traced light and shadows

## Community

News, build help and progress videos: **[Telegram](https://t.me/+rL9uLOqRWck2ZDMx)**.
Bugs go to [Issues](https://github.com/LukaManstein/CHIMERA/issues) (use the form).
Never post game files, keys, executables or links to them — anywhere.

## Credits

CHIMERA is mostly other people's work, and proud of it. Every commit keeps its original author.

- **[VIctory](https://github.com/Marvisak/VIctory)** by **Marvisak** and its contributors — the loader, runtime services, Direct3D 12 back end and shader recompiler.
- **[victory-fork](https://github.com/fxceless/victory-fork)** by **fxceless** and contributors — rendering, speed and stability work that takes the title into the world.
- **[victory-perf](https://github.com/vitutu1/victory-perf)** by **vitutu1** — the copy, barrier and CPU-stall work CHIMERA is built on, and its port of modules from **[ScarlettPort](https://github.com/ZigZagBoi1/ScarlettPort)** by **ZigZagBoi1** (lighting stand-ins, merged lowering, overlay, keyboard and mouse, loader hooks).
- **TG0000** and the **[triippywhale/victory-fork](https://github.com/triippywhale/victory-fork)** collection — user-mode title copies.
- **spacede** ([Emiriley/victory-fork](https://github.com/Emiriley/victory-fork)) — the stability caps.
- **kykifox1337-source** — Windows 10 Agility SDK support; **LovettCustoms** and the Windows 10 / RTX 30 testers for the findings behind it.
- **[XCL](https://github.com/ivall/xcl)** by **ivall** — used upstream as a reference.
- Audio work and CHIMERA packaging: **LukaManstein**. Much of this family of forks was developed with [Claude Code](https://claude.com/claude-code).

## License

GPL-3.0-or-later, the same as VIctory — see [LICENSE](LICENSE). If you share a
build, you must share its source under the same license.
