$ErrorActionPreference = 'Stop'
$env:TEMP = $env:TMP = 'E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR = 'E:\research-wiki-env\tmp\mpl'
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath 'E:\research-wiki'
$existing = Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'claude.exe' -and $_.CommandLine -match 'efb59f79-e3a4-4f75-a2a6-2944cae907ef' }
if ($existing) { throw 'Existing Claude session still running; do not duplicate.' }
$recordPath='E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki'
if (Test-Path -LiteralPath "$recordPath\claude-exit.txt") {
 Copy-Item -LiteralPath "$recordPath\claude-exit.txt" -Destination "$recordPath\claude-review1-exit.txt"
 Remove-Item -LiteralPath "$recordPath\claude-exit.txt"
}
$reviewPrompt = '请阅读 E:/research-wiki/文档/方法家族与LLM-Wiki改造/codex-review-round2.md。第一轮修复已基本通过，真实浏览器发现两处遗留：源码/流程面包屑与反向链接仍叫分析方法，以及历史缺包断言与当前环境矛盾。只完成文件中两类修复并写claude-review-round2-result.md，不扩范围、不安装、不部署、不启动子代理。继续执行。'
$reviewPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --resume 'efb59f79-e3a4-4f75-a2a6-2944cae907ef' --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose 1>> "$recordPath\claude-stream.jsonl" 2>> "$recordPath\claude-stderr.log"
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath "$recordPath\claude-exit.txt"