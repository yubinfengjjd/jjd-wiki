# Codex 第二轮审查修复矩阵（C1–C5）

日期：2026-10-24。同一 Claude 会话修复；未启动子代理、未安装依赖、未读 paper-harness、未部署、未重启正式 8765、未代作者签核、未提交开发仓库。保留 review1/round2 报告与 RED 日志。

## C1 — Monocle 分析核心的真实步骤与输入前提

| 检查 | 修复 | 证据 |
|---|---|---|
| Monocle2 两次 ordering | `monocle2_core.R` 第一次按原版 `orderCells(cds)`（`root_state=NULL`）产生 State，第二次 `orderCells(cds, root_state=root_state)`；未新增 `initial_root_state`，测试不传“1”绕过 | `scripts/codex-monocle-contract.R`：`PASS Monocle2 keeps preliminary and rooted ordering calls`，`review2-monocle-contract-green.log` |
| 最终根由作者明确 | 核心要求非空 `root_state`；缺失时明确拒绝，不 `select.list`/猜根；初步排序随机性/seed 保留并注明未验证 | 同上；轨迹页“代码/输入/输出”正文 |
| Monocle3 嵌入前提 | `reduced_dim` 必须非 NULL、行数等于细胞数、行名与细胞顺序一致；缺失/不匹配在包检查前拒绝，不补降维算法 | 同上两条 `PASS`；`Observed ... reduced_dim ...` |
| 页面输入/输出 | `data_contract` 区共同语义与实现差异；正文分别写 Slingshot/核心/Seurat 适配的输入输出，不把 CDS 冒充标准表 | `知识库/methods/trajectory-inference.md` |

限制：`monocle`/`monocle3` 未安装，真实算法仍 `not_run`；静态 contract 检查不等于算法验证。第一次初步排序在无根状态下的行为沿用原版，未在本机实际执行。

## C2 — 绘图辅助移出分析实现

| 检查 | 修复 | 证据 |
|---|---|---|
| 纯绘图不进入 analysis implementations | 删除 `scp-monocle2-plot`/`scp-monocle3-plot` 的 frontmatter、runtime.json、portability/algorithm 收据；不写入分析 recommended/verified 计数 | `trajectory-inference/runtime.json` 只含 Slingshot、Monocle2/3 core+adapter；页面实现表无 plot 行 |
| 不新造未经选定画法 | `monocle2_plot.R`/`monocle3_plot.R` 留在维护快照（`monocle-custom/`、`pilot3`），不进入正式 KB；16 个既有模板未重画 | `知识库/methods/trajectory-inference/code/` 无 plot 文件 |
| 规则同步 | 正式/staged AGENTS、SKILL：运行函数不等于分析实现；绘图/辅助不得授予分析 verified | `知识库/AGENTS.md`、`staged/research-wiki/assets/AGENTS.md`、`SKILL.md` |

## C3 — Python 必需依赖统一事实

| 检查 | 修复 | 证据 |
|---|---|---|
| Python 必需包进入统一事实 | `rna-velocity` manifest `required_packages={"R":[...],"Python":["scanpy","numpy","scvelo"]}`；删除独立 `python` 必需字段；页面 dependencies 同步 | `runtime.json`、`rna-velocity.md`；`pytest tests/test_runtime_contract.py::test_python_required_packages_are_in_the_unified_fact` |
| 前端语言归属 | `packageFacts()` 输出 `R: …；Python: …`；方法表/代码查看器使用 | `npm test`；浏览器 DOM `R: reticulate…；Python: scanpy、numpy、scvelo` |
| 文档示例合法 | `references/minimal-runtime.md` 示例 files 包含 palette 资源；说明 Python 用 required_packages 语言键，不另设必需字段 | 文件更新 |
| 缺 scvelo 仍 not_run | portable 运行仍在 Python 门禁精确失败 | `portability/rna-velocity/result.json`、`scp-scvelo-*` 收据 |

## C4 — malformed 清单诊断传播

| 检查 | 修复 | 证据 |
|---|---|---|
| 分支/API 保留 issues | `implementation_runtime` fallback 保留 `runtime_facts` 顶层 issues；方法分支、代码查看器显示清单问题 | `pytest tests/test_runtime_contract.py::test_malformed_manifest_does_not_break_api`；`test_malformed_resources_do_not_raise` |
| 模板 UI | PageView 的 template-runtime 渲染 `portability.issues`；CodeBranchList 也显示 | 前端测试 `template runtime issues stay visible without blocking the page`；`npm test` |
| 不 500、不封禁历史页 | `runtime_facts` 顶层捕获异常返回 unknown+issues；无清单仍可读 | API 测试 200；lint 不因历史页无清单报 ERROR |

## C5 — 证据与限制

| 检查 | 修复 | 证据 |
|---|---|---|
| ORA 真实输入不变 | 保存并比较实际 `gene_ids`、`TERM2GENE`、`TERM2NAME`；不再比较 NULL | `portability/gene-set-enrichment/result.json` `input_unchanged=true`；`result.rds`/`-input.rds` |
| 执行时代码哈希 | `portable_run.R` 记录隔离副本 `code_sha256`；installer 只对声明文件比较正式 code 与执行副本，不一致则 not_run/不重绑旧结果 | `portability/*/result.json` 的 `code_sha256`；收据 `executed_files`；`pytest` 定向 |
| 收据实际命令 | 方法收据使用实际 `Rscript --vanilla <portable_run.R> …`、实际隔离目录、case、输入/输出 SHA；模板 `render_templates.py` 记录实际命令、目录、start/end、code_sha256 | `verification/*-portability.json`、`verify/runtime-portability.json` |
| 模板不重复渲染 | 本轮重跑 16 个模板并记录实际磁盘路径/命令/哈希，不使用 `<isolated>` 占位符 | `portability/templates-evidence.json` |
| batch 限制表述 | 交替 A/B 标签是合法批次；原版与新分支同报 Assay counts/data cell mismatch；连续分组夹具通过仅覆盖该场景，不改统计默认 | `batch-alternating-investigation.json/log` |
| 旧输出不重绑 | 执行副本 hash 与正式 code 不一致时 installer 将 passed 降为 not_run；旧收据保留 | `install_modules.py` 逻辑；`grep code_mismatch` |

## 验证命令与结果

- 后端定向：`pytest tests/test_runtime_contract.py -q` → 23 passed（含 R1/R2/R3/API/Python）。
- Monocle contract：`Rscript --vanilla scripts/codex-monocle-contract.R <KB trajectory code>` → 3 PASS，exit 0。
- 隔离运行：`stage_isolated.py` + `portable_run.R` 全部 18 个 method key；8 个 compare_results PASS；模板 16/16 render exit 0、PNG MAD=0。
- 前端：`npm test` 26 项（新增 packageFacts/模板 issues）通过；`typecheck`、`build` exit 0。
- 浏览器：测试服务 8787；velocity DOM 显示 `R: …；Python: scanpy、numpy、scvelo`，仅 1 个“必要依赖”；trajectory 显示 4 个分析实现、无 plot 行。
- 全套回归：`pytest-review2-full.log`：513 passed / 2 skipped，exit 0。

## 明确未解决/限制

1. 缺 `monocle`/`monocle3`/`scDblFinder`/`harmony`/`SingleR`/scVelo 后端；所有相关分支 `not_run`。
2. 第一次 Monocle2 初步 ordering 的无根行为沿用原版，本机无法实际验证；静态 contract 只检查调用形态与输入拒绝。
3. RunSeuratMap 投影仍因 Seurat 5.6 `dim.` 上游错误 not_run；Slingshot `show_plot=TRUE` 的上游绘图错误与缺包分开记录。
4. 交替 batch 顺序的原版/新分支同错；连续分组夹具通过不代表所有合法细胞顺序已验证。
5. 未部署、未重启正式 8765、未提交开发仓库；等待 Codex 复核。
