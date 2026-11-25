# CHIMERA installer (NVIDIA channel).
#
# One line in PowerShell:
#   irm https://raw.githubusercontent.com/LukaManstein/CHIMERA/turbo-next/scripts/install.ps1 | iex
#
# It checks the tools (Git, Rust, Visual Studio Build Tools with C++) and offers to install the
# missing ones with winget, downloads CHIMERA into %LOCALAPPDATA%\CHIMERA, switches to the newest
# stable-nvidia release, builds it, asks for the folder of YOUR OWN copy of the title, translates
# the shaders ahead of time and puts a "CHIMERA (NVIDIA)" shortcut on the desktop.
# Nothing of the title is downloaded: you need your own dump of the Xbox Series build 1.0.2.1.

$ErrorActionPreference = 'Stop'
$Repo = 'https://github.com/LukaManstein/CHIMERA.git'
$Channel = 'stable-nvidia'
$Dir = Join-Path $env:LOCALAPPDATA 'CHIMERA'

function Step($text) { Write-Host ""; Write-Host "== $text" -ForegroundColor Cyan }
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + (Join-Path $env:USERPROFILE '.cargo\bin')
}

Write-Host "CHIMERA installer - NVIDIA channel ($Channel)" -ForegroundColor Green
Write-Host "Needs: Windows 10/11 64-bit, an RTX 20xx or newer (8 GB+, 12 GB recommended), 32 GB RAM, ~15 GB free."

# The card: this channel is tuned and tested on NVIDIA only.
$gpus = (Get-CimInstance Win32_VideoController | ForEach-Object Name) -join ', '
Write-Host "Graphics: $gpus"
if ($gpus -notmatch 'NVIDIA') {
    Write-Host "No NVIDIA card found. This channel is tested on NVIDIA only; for AMD Radeon see Belobug/VIctory-Belobug-AMD." -ForegroundColor Yellow
    if ((Read-Host "Install anyway? [y/N]") -notmatch '^[Yy]') { return }
}

Step "Tools"
$missing = @()
if (-not (Have git)) { $missing += @{ name = 'Git'; id = 'Git.Git'; extra = @() } }
Refresh-Path
if (-not (Have cargo)) { $missing += @{ name = 'Rust (rustup)'; id = 'Rustlang.Rustup'; extra = @() } }
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vc = (Test-Path $vswhere) -and (& $vswhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)
if (-not $vc) {
    $missing += @{ name = 'Visual Studio 2022 Build Tools (C++)'; id = 'Microsoft.VisualStudio.2022.BuildTools'
        extra = @('--override', '--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended') }
}
if ($missing.Count -gt 0) {
    Write-Host ("Missing: " + (($missing | ForEach-Object { $_.name }) -join ', '))
    if (-not (Have winget)) { throw "winget is not available: install the tools above by hand, then run this again." }
    if ((Read-Host "Install them with winget now? [Y/n]") -match '^[Nn]') { throw "Install the tools above, then run this again." }
    foreach ($m in $missing) {
        Write-Host "Installing $($m.name)..."
        winget install --id $m.id -e --accept-source-agreements --accept-package-agreements @($m.extra)
    }
    Refresh-Path
    if (-not (Have cargo)) { throw "Rust was installed but 'cargo' is not on PATH yet: open a new PowerShell window and run the installer again." }
}
Write-Host "Git, Rust and the C++ build tools are there."

Step "Download"
if (Test-Path (Join-Path $Dir '.git')) {
    git -C $Dir fetch --tags --force origin
} else {
    git clone $Repo $Dir
}
Set-Location $Dir
$tags = git tag --list "$Channel-*" | Sort-Object { [version](($_ -replace "^$Channel-", '') -replace '[^0-9.]', '') }
if ($tags) {
    $latest = @($tags)[-1]
    git -c advice.detachedHead=false checkout --quiet $latest
    Write-Host "Using release $latest."
} else {
    git checkout --quiet turbo-next
    Write-Host "No stable release yet: using branch turbo-next (the newest build)."
}

Step "Build (5-15 minutes the first time)"
cargo build --release -p victory
if ($LASTEXITCODE -ne 0) { throw "The build failed; see the messages above." }
cargo xtask agility
if ($LASTEXITCODE -ne 0) { throw "Could not fetch the D3D12 Agility SDK (needed on Windows 10)." }

Step "Your copy of the title"
$game = $null
$cfg = Join-Path $Dir 'chimera.cfg'
if (Test-Path $cfg) { $game = ((Get-Content $cfg | Where-Object { $_ -like 'GAME=*' }) -replace '^GAME=', '') }
while (-not $game -or -not (Test-Path (Join-Path $game 'shaders.rpf'))) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = 'Choose the folder of your own copy of the title (it holds shaders.rpf)'
    if ($dlg.ShowDialog() -ne 'OK') { throw "No folder chosen." }
    $game = $dlg.SelectedPath
    if (-not (Test-Path (Join-Path $game 'shaders.rpf'))) { Write-Host "No shaders.rpf in $game; choose the title's own folder." -ForegroundColor Yellow }
}
Set-Content -Path $cfg -Value "GAME=$game" -Encoding ASCII
Write-Host "Title folder: $game"

Step "Translate the shaders ahead of time (~4 minutes)"
$env:GAME = $game
cmd /c "scripts\chimera-turbo.cmd warm"

Step "Desktop shortcut"
$desktop = [Environment]::GetFolderPath('Desktop')
$link = Join-Path $desktop 'CHIMERA (NVIDIA).lnk'
$shell = New-Object -ComObject WScript.Shell
$s = $shell.CreateShortcut($link)
$s.TargetPath = Join-Path $Dir 'scripts\chimera-play.cmd'
$s.WorkingDirectory = $Dir
$s.Description = 'CHIMERA (NVIDIA): checks for a newer stable build, then starts the title'
$s.Save()
Write-Host "Shortcut: $link"

Write-Host ""
Write-Host "Done. Start it from the 'CHIMERA (NVIDIA)' shortcut on the desktop." -ForegroundColor Green
Write-Host "Each start checks GitHub for a newer $Channel release and asks before updating."
Write-Host "The first time in the world, give it a minute: the card's pipelines are being built."
