# CHIMERA launcher (batch10): warms the shader cache with the keys the title will ask for,
# shows the progress, then starts the title and shows its frame rate from the log.
# Run from the repository: powershell -ExecutionPolicy Bypass -File scripts\chimera-launcher.ps1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$root  = Split-Path -Parent $PSScriptRoot
$exe   = Join-Path $root 'target\release\victory.exe'
$play  = Join-Path $root 'scripts\chimera-batch10.cmd'
$logs  = Join-Path $root 'logs'
New-Item -ItemType Directory -Force -Path $logs | Out-Null
$game = $env:GAME
$cfg = Join-Path $root 'chimera.cfg'
if (-not $game -and (Test-Path $cfg)) {
    foreach ($l in Get-Content $cfg) { if ($l -match '^\s*GAME\s*=\s*(.+)$') { $game = $matches[1].Trim() } }
}
$cache = if ($env:VICTORY_CACHE_DIR) { $env:VICTORY_CACHE_DIR } else { Join-Path $env:LOCALAPPDATA 'victory\cache' }
$cacheSh = Join-Path $cache 'shaders'
# A new build changes the cache keys: the warm-up mark carries the build's time
$stamp = if (Test-Path $exe) { (Get-Item $exe).LastWriteTimeUtc.ToString('yyyyMMddHHmmss') } else { 'none' }
$markWarm = Join-Path $root ".chimera-warm-$stamp"
$warmTotal = 25889

$form = New-Object System.Windows.Forms.Form
$form.Text = 'CHIMERA batch10'
$form.Size = New-Object System.Drawing.Size(720, 420)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
function New-Row($y, $title) {
    $l = New-Object System.Windows.Forms.Label
    $l.Location = New-Object System.Drawing.Point(16, $y); $l.Size = New-Object System.Drawing.Size(670, 22); $l.Text = $title
    $b = New-Object System.Windows.Forms.ProgressBar
    $b.Location = New-Object System.Drawing.Point(16, ($y + 24)); $b.Size = New-Object System.Drawing.Size(670, 22); $b.Maximum = 1000
    $form.Controls.Add($l); $form.Controls.Add($b)
    return @{ Label = $l; Bar = $b; Title = $title }
}
$rowWarm = New-Row 12 '1. Shader cache'
$rowGame = New-Row 70 '2. Game'
$box = New-Object System.Windows.Forms.TextBox
$box.Location = New-Object System.Drawing.Point(16, 130); $box.Size = New-Object System.Drawing.Size(670, 200)
$box.Multiline = $true; $box.ScrollBars = 'Vertical'; $box.ReadOnly = $true
$box.Font = New-Object System.Drawing.Font('Consolas', 9)
$form.Controls.Add($box)
$btnLogs = New-Object System.Windows.Forms.Button
$btnLogs.Text = 'Logs'; $btnLogs.Location = New-Object System.Drawing.Point(16, 338); $btnLogs.Size = New-Object System.Drawing.Size(120, 30)
$btnLogs.Add_Click({ Start-Process explorer.exe $logs })
$form.Controls.Add($btnLogs)

function Write-Line($s) { $box.AppendText((Get-Date -Format 'HH:mm:ss') + '  ' + $s + "`r`n") }
function Set-Row($row, $done, $total, $extra) {
    $row.Bar.Value = if ($total -gt 0) { [Math]::Min(1000, [int](1000 * $done / $total)) } else { 0 }
    $row.Label.Text = '{0}: {1}' -f $row.Title, $extra
}
function Format-Time($sec) { '{0}:{1:00}' -f [int][Math]::Floor($sec / 60), [int]($sec % 60) }
function Read-Last($path, $bytes) {
    $fs = [System.IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
    try { $fs.Position = [Math]::Max(0, $fs.Length - $bytes); return (New-Object System.IO.StreamReader($fs)).ReadToEnd() } finally { $fs.Close() }
}

if (-not (Test-Path $exe)) { [System.Windows.Forms.MessageBox]::Show("No build: $exe`nBuild with: cargo build --release"); exit 1 }
if (-not $game) { [System.Windows.Forms.MessageBox]::Show('No game folder: run scripts\install.ps1 or put GAME=<folder> in chimera.cfg'); exit 1 }

$ts = Get-Date -Format yyyyMMdd-HHmmss
$script:state = 'warm'
$script:since = Get-Date
$script:proc = $null
$script:gameLog = Join-Path $logs "chimera-batch10-$ts.log"
$env:GAME = $game

if (Test-Path $markWarm) { Set-Row $rowWarm 1 1 'ready (warmed before)'; $script:state = 'game' }
else {
    $script:proc = Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"`"$play`" warm > `"$logs\warm-$ts.log`" 2>&1`"" -WindowStyle Hidden -PassThru
    Write-Line 'Shader cache warm-up started (first run after a build: a few minutes).'
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({
  try {
    $el = ((Get-Date) - $script:since).TotalSeconds
    switch ($script:state) {
      'warm' {
        $n = if (Test-Path $cacheSh) { (Get-ChildItem $cacheSh -Recurse -File | Where-Object { $_.LastWriteTime -gt $script:since } | Measure-Object).Count } else { 0 }
        $eta = if ($n -gt 0 -and $n -lt $warmTotal) { ', left ~' + (Format-Time ($el * ($warmTotal - $n) / $n)) } else { '' }
        Set-Row $rowWarm $n $warmTotal ('{0} / {1} ({2}%), {3}{4}' -f $n, $warmTotal, [int](100 * $n / $warmTotal), (Format-Time $el), $eta)
        if ($script:proc.HasExited) {
            Set-Row $rowWarm 1 1 "ready: $n shaders in $(Format-Time $el)"
            Write-Line "Warm-up done: $n shaders."
            New-Item -ItemType File -Path $markWarm -Force | Out-Null
            $script:state = 'game'
        }
      }
      'game' {
        Write-Line "Starting the game. Log: $($script:gameLog)"
        $script:since = Get-Date
        $script:proc = Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"`"$play`" > `"$($script:gameLog)`" 2>&1`"" -WindowStyle Hidden -PassThru
        Set-Row $rowGame 0 1 'starting...'
        $script:state = 'running'
      }
      'running' {
        if (Test-Path $script:gameLog) {
            $t = (Read-Last $script:gameLog 400000) -replace '\x1b\[[0-9;]*m', ''
            $m = [regex]::Matches($t, 'frame times: (\d+) frames in ([\d.]+) s: shortest \d+ ms, median (\d+)')
            if ($m.Count -gt 0) {
                $x = $m[$m.Count - 1]
                $fps = [double]$x.Groups[1].Value / [double]$x.Groups[2].Value
                Set-Row $rowGame ([Math]::Min(60, $fps)) 60 ('running {0}, {1:0.0} fps (median frame {2} ms)' -f (Format-Time $el), $fps, $x.Groups[3].Value)
            } else { Set-Row $rowGame 0 1 ('loading, ' + (Format-Time $el)) }
        }
        if ($script:proc.HasExited) { Write-Line 'The game has closed.'; Set-Row $rowGame 0 1 'closed'; $script:state = 'done' }
      }
    }
  } catch { Write-Line ('Error: ' + $_.Exception.Message) }
})
$timer.Start()
[void]$form.ShowDialog()
