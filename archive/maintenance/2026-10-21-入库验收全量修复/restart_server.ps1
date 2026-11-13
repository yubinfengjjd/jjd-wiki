$ErrorActionPreference = 'Stop'
$port = 8765
$python = 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
$wiki = 'C:\Users\86186\.claude\skills\research-wiki\wiki.py'

$servers = Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
    Where-Object { $_.CommandLine -like '*wiki.py serve*' }
foreach ($server in $servers) {
    Stop-Process -Id $server.ProcessId -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 500

$env:TEMP = 'E:\research-wiki-env\tmp'
$env:TMP = 'E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR = 'E:\research-wiki-env\tmp\mpl'
$env:PYTHONDONTWRITEBYTECODE = '1'
Start-Process -FilePath $python -ArgumentList @('-X', 'utf8', $wiki, 'serve', '--no-browser') -WindowStyle Hidden

$ready = $false
for ($i = 0; $i -lt 80; $i++) {
    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $task = $client.ConnectAsync('127.0.0.1', $port)
        if ($task.Wait(300) -and $client.Connected) { $ready = $true; break }
    } catch {
    } finally {
        $client.Close()
    }
    Start-Sleep -Milliseconds 250
}
if (-not $ready) { throw 'server did not become ready' }
Write-Output 'server ready'
