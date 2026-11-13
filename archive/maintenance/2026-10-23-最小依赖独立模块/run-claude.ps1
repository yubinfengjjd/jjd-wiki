$ErrorActionPreference='Stop'
. 'E:\research-wiki-env\work\scp-runtime.ps1'
[Console]::InputEncoding=[System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath 'E:\research-wiki'
$taskSession='60c0159e-9c13-45c6-bfd5-b81dfc41e567'
$existing=Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'claude.exe' }
if($existing){throw 'Existing Claude process detected; inspect before starting another writer.'}
$taskPrompt=Get-Content -Raw -Encoding utf8 -LiteralPath 'E:\research-wiki\文档\最小依赖独立模块改造\claude-handoff.md'
$taskPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose --session-id $taskSession 1> 'E:\research-wiki\维护记录\2026-10-23-最小依赖独立模块\claude-stream.jsonl' 2> 'E:\research-wiki\维护记录\2026-10-23-最小依赖独立模块\claude-stderr.log'
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath 'E:\research-wiki\维护记录\2026-10-23-最小依赖独立模块\claude-exit.txt'
