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
 Copy-Item -LiteralPath "$recordPath\claude-exit.txt" -Destination "$recordPath\claude-initial-exit.txt"
 Remove-Item -LiteralPath "$recordPath\claude-exit.txt"
}
$reviewPrompt = 'Codex已独立初审，暂不部署。请完整阅读 E:/research-wiki/文档/方法家族与LLM-Wiki改造/codex-review-round1.md 并完成其中五项修复。必须重读 implementation-plan.md 的最新追加章节和跨来源去重审查要求.md；你初次运行后用户追加了来源去重、八步skill与panel存储要求。编码仍由你执行，Codex只审查。不要安装依赖或启动子代理。独立pytest还在运行，近期有并行测试不应当作最终post-fix验证；修完再跑必要测试。完成写 claude-review-round1-result.md并更新claude-result.md。继续执行，不要停在计划。'
$reviewPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --resume 'efb59f79-e3a4-4f75-a2a6-2944cae907ef' --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose 1>> "$recordPath\claude-stream.jsonl" 2>> "$recordPath\claude-stderr.log"
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath "$recordPath\claude-exit.txt"
