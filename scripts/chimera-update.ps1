# CHIMERA: is there a newer stable build for this channel? Asks before changing anything.
# Run from the repository root (the launcher does). Exit code 0 always: a failed check never
# stops the game from starting.
param([string]$Channel = 'stable-nvidia')

$ErrorActionPreference = 'SilentlyContinue'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "CHIMERA: checking for a newer $Channel build..."
git fetch --tags --force --quiet origin 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  no connection to GitHub; starting the installed build."; exit 0 }

# Tags look like stable-nvidia-2026.11.25 (or -2026.11.25.2); the newest by version wins.
$tags = git tag --list "$Channel-*" | Sort-Object { [version](($_ -replace "^$Channel-", '') -replace '[^0-9.]', '') }
if (-not $tags) { Write-Host "  no $Channel release published yet."; exit 0 }
$latest = @($tags)[-1]
$here = git rev-parse HEAD
$there = git rev-parse "$latest^{commit}"
if ($here -eq $there) { Write-Host "  up to date ($latest)."; exit 0 }

# Newer only if the installed commit is an ancestor of the release (never downgrade a dev build).
git merge-base --is-ancestor $here $there
if ($LASTEXITCODE -ne 0) { Write-Host "  installed build is not behind $latest; nothing to do."; exit 0 }

$answer = Read-Host "  $latest is available. Update now? It rebuilds (5-15 min) and translates the shaders again (~4 min). [Y/n]"
if ($answer -match '^[Nn]') { exit 0 }

git -c advice.detachedHead=false checkout --quiet $latest
if ($LASTEXITCODE -ne 0) { Write-Host "  could not switch to $latest (local changes?); keeping the installed build."; exit 0 }
cargo build --release -p victory
if ($LASTEXITCODE -ne 0) { Write-Host "  the build failed; check the messages above."; exit 0 }
cargo xtask agility
& cmd /c "scripts\chimera-turbo.cmd warm"
Write-Host "  updated to $latest."
exit 0
