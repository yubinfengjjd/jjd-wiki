$ErrorActionPreference='Stop'
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
[Console]::InputEncoding=[System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath 'E:\research-wiki'
$taskSession='d7153f8d-0836-4bc1-ae92-2ffdc7b77c76'
$existing=Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'claude.exe' -and $_.CommandLine -match 'd7153f8d-0836-4bc1-ae92-2ffdc7b77c76|efb59f79-e3a4-4f75-a2a6-2944cae907ef' }
if ($existing) { throw 'Prior or duplicate Claude session still active; refusing parallel writers.' }
$taskPrompt=Get-Content -Raw -Encoding utf8 -LiteralPath 'E:\research-wiki\文档\方法分类与灵活输入改造\claude-handoff.md'
$taskPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose --session-id $taskSession 1> 'E:\research-wiki\维护记录\2026-10-23-分类与灵活输入\claude-stream.jsonl' 2> 'E:\research-wiki\维护记录\2026-10-23-分类与灵活输入\claude-stderr.log'
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath 'E:\research-wiki\维护记录\2026-10-23-分类与灵活输入\claude-exit.txt'
