# Hidden launcher for the knowledge-base UI.
# Starts the local server, opens one browser window, and stops the server when that window closes.
# Log: .launcher.log in the vault checkout.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$log = Join-Path $root '.launcher.log'

function Write-Log($message) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $message" | Add-Content -LiteralPath $log -Encoding UTF8
}

try {
    . (Join-Path $PSScriptRoot 'machine-paths.ps1')
    $machine = Get-RWikiMachine
    Set-RWikiEnvironment $machine
    $port = if ($machine.Config.port) { [int]$machine.Config.port } else { 8765 }
    if ($port -lt 1 -or $port -gt 65535) { throw 'Invalid machine config port; expected 1..65535.' }
} catch {
    Write-Log "bootstrap failed: $($_.Exception.Message)"
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
$url = "http://127.0.0.1:$port/"
$python = $machine.Python
$wiki = $machine.Wiki

function Test-Port([int]$p) {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync('127.0.0.1', $p)
        if (-not $task.Wait(300)) { return $false }
        return $client.Connected
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Find-Browser {
    $candidates = @(
        'C:\Program Files\Google\Chrome\Application\chrome.exe',
        'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
        'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
    )
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return $null
}

# Stop the server and the child interpreter that actually owns the port.
function Stop-WikiServer {
    $pids = @()
    $listening = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($listening) { $pids += ($listening | Select-Object -ExpandProperty OwningProcess) }
    if ($script:server -and -not $script:server.HasExited) { $pids += $script:server.Id }
    foreach ($id in ($pids | Select-Object -Unique)) {
        Stop-Process -Id $id -Force -ErrorAction SilentlyContinue
        Write-Log "stopped process $id"
    }
}

Write-Log '--- start'

$serverArgs = @('-X', 'utf8', ('"' + $wiki + '"'), '--config', ('"' + $machine.ConfigPath + '"'))
if ($env:RWIKI_WIKI_ROOT) {
    # UI writes go to the task-branch checkout set up by `wiki.py gh start-task --worktree`.
    # Start-Process joins arguments with spaces, so quote the path (no trailing backslash before the quote).
    $serverArgs += @('--wiki-root', ('"' + $env:RWIKI_WIKI_ROOT.TrimEnd('\') + '"'))
}
$serverArgs += @('serve', '--no-browser')

$script:server = $null
if (Test-Port $port) {
    # A server is already running (started from a terminal). Open a window and leave it alone.
    Write-Log "port $port already listening, reuse it (its wiki root is unchanged)"
} else {
    if ($env:RWIKI_WIKI_ROOT) { Write-Log "wiki root: $env:RWIKI_WIKI_ROOT" }
    $script:server = Start-Process -FilePath $python -ArgumentList $serverArgs -PassThru -WindowStyle Hidden
    Write-Log "server started: $($script:server.Id)"

    $ready = $false
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Milliseconds 250
        if (Test-Port $port) { $ready = $true; break }
        if ($script:server.HasExited) { break }
    }
    if (-not $ready) {
        Write-Log 'server did not come up'
        Stop-WikiServer
        exit 1
    }
    Write-Log 'server ready'
}

$browserExe = Find-Browser
$browser = $null
if ($browserExe) {
    # A private profile per run keeps the window tied to this process: closing it exits the process.
    $profile = Join-Path $env:TEMP ('wiki-browser-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    $browser = Start-Process -FilePath $browserExe -PassThru -ArgumentList @(
        "--app=$url",
        ('--user-data-dir="' + $profile + '"'),
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-background-mode',
        '--window-size=1440,900'
    )
    Start-Sleep -Milliseconds 1500
    if ($browser.HasExited) {
        Write-Log "browser exited immediately: $browserExe"
        $browser = $null
    } else {
        Write-Log "browser started: $($browser.Id) $browserExe"
        $browser.WaitForExit()
        Write-Log 'browser window closed'
        for ($i = 0; $i -lt 10; $i++) {
            try { [System.IO.Directory]::Delete($profile, $true); break } catch { Start-Sleep -Milliseconds 300 }
        }
    }
}

if (-not $browser) {
    # No usable browser window of our own: fall back to the default browser, without auto-stop.
    Write-Log 'fallback to default browser; the server keeps running until closed manually'
    Start-Process $url
    return
}

if ($script:server) {
    Stop-WikiServer
} else {
    Write-Log 'server was pre-existing; left running'
}
Write-Log '--- end'
