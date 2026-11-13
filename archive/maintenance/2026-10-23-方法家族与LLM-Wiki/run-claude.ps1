$ErrorActionPreference = 'Stop'
$env:TEMP = $env:TMP = 'E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR = 'E:\research-wiki-env\tmp\mpl'
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$taskPrompt = Get-Content -Raw -Encoding utf8 -LiteralPath 'E:\research-wiki\文档\方法家族与LLM-Wiki改造\claude-handoff.md'
Set-Location -LiteralPath 'E:\research-wiki'
$taskPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose --session-id 'efb59f79-e3a4-4f75-a2a6-2944cae907ef' 1> 'E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\claude-stream.jsonl' 2> 'E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\claude-stderr.log'
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath 'E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\claude-exit.txt'
