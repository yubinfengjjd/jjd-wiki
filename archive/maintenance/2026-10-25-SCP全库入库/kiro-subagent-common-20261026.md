# 子代理公共约束（scp-full-ingest，2026-10-26）

- spec（权威，先读与你任务相关的部分）：`E:/research-wiki/.kiro/specs/scp-full-ingest/{requirements,design,tasks}.md`；当前交接：`E:/research-wiki/维护记录/2026-10-25-SCP全库入库/kiro-handoff-20261026T1415.md`。
- 路径：<B>=E:/research-wiki-env/work/scp-full-ingest-20261025；<A>=E:/research-wiki/维护记录/2026-10-25-SCP全库入库（只追加新带时间戳文件）；<SRC>=E:/research-wiki-env/sources/scp-2026-10-22（只读）；<skill>=E:/research-wiki/开发/staged/research-wiki（只读）；sci-figure-replica 官方脚本 C:/Users/86186/.codex/skills/sci-figure-replica/scripts（只调用不改）；临时文件只写 E:/research-wiki-env/tmp/kiro-scp-*。
- **禁止写**：正式知识库 E:/research-wiki/知识库、正式画廊 E:/research-wiki/画廊、<B>/wiki/methods/**、<B>/coverage/modules/**、<B>/coverage/cases/**、<B>/scripts 下已有的 assemble-modules3.py / integrate-wiki2.py / repair-collisions.py / run-iso-case.py / run-family-cases.py / replay-legacy.py / replay-portable.R / run-module-case.R（处于 Code_Freeze `code-freeze-20261026T143250.json`，主会话的全量收据重跑正在使用）。只新建你任务指定的文件。
- 不安装/下载/升级任何 R/Python 依赖；缺包如实记录精确包名和原始错误。不调用 Devin/Codex；不读 E:/paper-harness；不写 C 盘 memory。
- Python：通用 D:/anaconda/python.exe -X utf8（有 psutil、PIL、websocket-client）；Wiki CLI 用 C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8。PATH 上的 python 是 Windows 商店占位，禁用。
- R：设 R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5、PROCESSOR_ARCHITECTURE=AMD64、TEMP/TMP=E:/research-wiki-env/tmp，删 LANG/LC_*（或先 `. E:/research-wiki-env/work/scp-runtime.ps1`），再用 D:/R-4.5.0/bin/x64/Rscript.exe --vanilla。成败以脚本捕获的真实错误为准，不以退出码 0 为准。
- 原生 SCP 调用方式（只读整库本地化包）：`options(SCP.local.root='E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'); source(file.path(getOption('SCP.local.root'),'load_scp_local.R')); SCP_local$<Fn>(...)`；示例数据 `load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')`。参考写法：<A>/scripts/codex_native_structural_oracles.R、<B>/scripts/kiro_native_case_oracles.py。
- 已有原生材料（不要重复生成同一控制）：<A>/native-oracles；E:/research-wiki-env/work/codex-scp-native-{structures,trajectory,graph,3d,largevis,fr}；E:/research-wiki-env/work/kiro-scp-native/cases（references.json 汇总）。
- 代签核授权（作者 2026-10-26 原话："不用我审签了你直接代替我审签，全部入库成为模板"）；fig17 已由作者本人签核并 ready，不动。
- 产出的数据与图均注明"软件夹具（SCP 示例数据）原生输出，不是科学结论"。
- 完成后在 <A> 写一份带时间戳的中文结果说明（做了什么、证据文件路径、未完成项与原因），并在回复中汇报。
