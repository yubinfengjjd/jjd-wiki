$ErrorActionPreference='Stop'
. 'E:\research-wiki-env\work\scp-runtime.ps1'
$env:OMP_NUM_THREADS='1'
$env:OPENBLAS_NUM_THREADS='1'
$env:MKL_NUM_THREADS='1'
[Console]::InputEncoding=[System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath 'E:\research-wiki'
$taskRecord='E:\research-wiki\维护记录\2026-10-23-最小依赖独立模块'
$taskSession='60c0159e-9c13-45c6-bfd5-b81dfc41e567'
$existing=Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'claude.exe' }
if($existing){throw 'Existing Claude process still active; do not start another writer.'}
if(!(Test-Path -LiteralPath "$taskRecord\claude-review1-exit.txt")){throw 'Review1 has not exited; inspect its process and logs first.'}
if(Test-Path -LiteralPath "$taskRecord\claude-review2-stream.jsonl"){throw 'Review2 already launched; never overwrite its logs.'}
$taskPrompt='继续同一会话的独立审查修复，不新开会话。先完整阅读 E:/research-wiki/文档/最小依赖独立模块改造/codex-review-round2.md、codex-review-monocle-core.md、codex-review-auxiliary.md，并核对design/implementation-plan最新尾部。C1-C5是在你review1运行期间新增加，不能假设已经处理。重点：Monocle2遗漏初次orderCells；Monocle3真实UMAP输入前提；纯绘图移出分析实现/verified计数且不新造未经选定画法；velocity必需Python包统一事实；实际执行文件hash绑定及ORA真实输入检查/模板命令。不要重写已通过的隔离机制。用户已授权，不重复问许可；只你编码、禁止子代理、不安装、不读paper-harness、不改原始source/作者状态、不部署。Codex独立复测正式QC/评分/DE对原包装数值全部一致，7956行DE逐值相同；formal source/multimodule/QC输入及search保护通过，证据codex-review1-formal-results.json、codex-analysis-compare.log。这些不替代C1-C5。runtime malformed fallback新版本已保留issues，确认并补UI即可，别重复重写。修复收据时记录实际执行副本hash，写入时与正式code比较，不能把旧结果重绑新hash；保护各轮报告和RED日志。先定向验证，稳定后必要回归一次，写review2-fix-matrix/progress/claude-result/verification-matrix/计划实际状态；完成可审查结果后退出。不要把缺包或假引擎标为算法通过，不代作者确认。'
$taskPrompt | & 'C:\Users\86186\AppData\Roaming\npm\claude.ps1' -p --permission-mode acceptEdits --allowedTools 'Read,Write,Edit,Glob,Grep,Bash,PowerShell' --output-format stream-json --verbose --resume $taskSession 1> "$taskRecord\claude-review2-stream.jsonl" 2> "$taskRecord\claude-review2-stderr.log"
$LASTEXITCODE | Set-Content -Encoding utf8 -LiteralPath "$taskRecord\claude-review2-exit.txt"
