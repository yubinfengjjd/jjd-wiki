# 最小依赖独立模块 · 进度

日期：2026-10-23。实施：Claude Code 单会话；审查：Codex。本文件每阶段更新。

## 进程与证据

- 首次进程异常退出码 -1073740791，原日志 `claude-stream.jsonl`、`claude-stderr.log`、`claude-exit.txt` 保留。
- 恢复进程日志 `claude-recovery1-stream.jsonl`、`claude-recovery1-stderr.log`；本文件由恢复进程续写。
- Codex 已清理其上游对照测试遗留的 18-worker 进程；记录 `codex-reference-stopped-processes.json`。工具进程存在不代表本轮进度。
- 本轮 R 验证一律显式 `BiocParallel::SerialParam()`、`future::plan(sequential)`；不改变原算法默认，缺省仍按上游。首轮 codex-reference.R 在 CellScoring 阶段因 BiocParallel 18 worker 崩溃，作为失败证据保留，后续重跑用 SerialParam。

## T0 — 全量依赖清单及分支边界（进行中）

已完成：

- 阅读 design / implementation-plan / claude-handoff / 正式 AGENTS / README / 两轮旧 final-acceptance。
- 确认 12 个 SCP 分析包装（cell-quality-control、doublet-detection、dimensionality-reduction、batch-integration、cell-type-annotation、differential-expression、gene-set-enrichment、gene-set-scoring、trajectory-inference、dynamic-feature-analysis、reference-mapping、rna-velocity）当前均为 `load_scp_engine(bundle)` 整库加载器；cell-clustering 已是显式 Seurat 调用。
- 16 个 SCP 模板均含 `code/core.R + scp_helpers.R + scp_*_native.R + data/`，局部 helper/资源已提取；需逐模板审计与本轮 bootstrapping。
- 静态调用闭包：`scripts/dep_trace.R`（R codetools，不执行上游代码）已对 15 个上游入口生成闭包、外部函数与全局变量，结果 `scripts/dep_trace.rds`、`scripts/dep_trace_summary.txt`、`scripts/fn_bodies.txt`。
- 包映射：`scripts/map_packages.R` 输出 `scripts/pkg_map.txt`（按已安装命名空间导出映射外部函数→包；未映射项逐一处理）。
- R 环境：`D:/R-4.5.0` + `E:/research-wiki-env/R-lib-scp/4.5`，486 包。已安装 Seurat/SeuratObject/slingshot/clusterProfiler/ggplot2/circlize/ComplexHeatmap/reticulate/mgcv/BiocParallel 等；缺 SCP、monocle、monocle3、SingleR、scDblFinder、harmony、ggsankey、AUCell/UCell、scmap、scds、org.Hs.eg.db、DDRTree、destiny、batchelor、glmGamPoi、symphony、conos 等。

待完成：

- 逐分支 source/:::/get/getFromNamespace/check_R/check_Python/options/资源/网络归类，区分必要传递依赖与整库加载。
- 固定运行清单 schema、派生态与 API 字段（写入 implementation-plan 执行记录）。
- 产出 `dependency-inventory.json/md`。

## T1 — 共享运行清单与后端（已完成）

- 新增 `rwiki/runtime_contract.py`：解析 `runtime.json`、校验资产内路径/文件/重复/依赖、派生 standalone/bundle/unknown 与 portability 状态、闭包哈希。
- `method_implementations`、`server`、`code_assets`、`lint`、`cli check-entry` 共用同一事实；方法分支、模板详情、代码查看器 API 均返回 runtime。
- `tests/test_runtime_contract.py` 17 项通过；相关后端定向测试 120 passed / 2 skipped。
- 未改变算法 receipt 语义：`portability=verified` 不授予算法 `verified`。

## T2 — 分析实现拆解（已完成本轮范围）

- 12 个分析家族全部改为最小调用闭包；9 个分支在异目录、新进程、不提供 bundle 路径下真实通过，并与保留的完整 bundle 参考逐值一致：
  cell-quality-control、dimensionality-reduction、batch-integration/Seurat、differential-expression、gene-set-enrichment、gene-set-scoring、trajectory-inference/Slingshot、dynamic-feature-analysis、reference-mapping/label-transfer。
- not_run（精确缺依赖/上游失败）：doublet/scDblFinder、harmony、SingleR、RunSeuratMap 投影、scVelo、Monocle2、Monocle3。
- Monocle2/3 从固定版本 SCP 原函数提取到 trajectory-inference 分支，未新写算法；缺包保持 not_run。
- 兼容改动：check_R/check_Python 改为 fail-only；SeuratObject >= 5 的 GetAssayData/Assays shim；`SCP::palette_list` 改为本地 palette 数据；编译版 asMatrix 排除（上游调用因 `inherits(matrix, ...)` 永不可达）。
- 旧 `analysis.R` 与旧 receipt 保留在 `before/` 和 Git 历史；新 receipt 写为 `verification/<impl>-standalone.json`。

## T3 — 绘图模板审计（已完成）

- 16 个 SCP 单 panel 模板全部在异目录、新 R 进程、不提供 SCP 路径下渲染成功。
- 16/16 PNG 与既有 `verify/figure.png` 逐像素一致（MAD=0）；PDF 因生成时间戳不同未按字节比较；2 个 SVG 因设备标识不同未按字节比较，其余 SVG 字节一致。
- 每个模板新增 `runtime.json` 与 `verify/runtime-portability.json`；未改作者 ready、spec、layout、尺寸或单 panel。

## T4 — 前端（已完成开发与测试服务验证）

- `api.ts` 增加 runtime 类型；方法实现表显示运行方式、独立性状态、必要/可选依赖、复制清单与证据；模板详情显示同一事实；代码查看器分支显示 runtime。
- `npm test` 24 项通过、`npm run typecheck` 通过、`npm run build` 成功并写入 staged 构建目录。
- 测试服务 8787 + headless Chrome 渲染：QC 方法、trajectory 三分支、volcano 模板、领域→用途筛选均显示正确 runtime；截图与 DOM 存 `browser/`。

## T5 — 规则/skill/入库（已完成）

- 正式 `知识库/AGENTS.md` 与 staged `assets/AGENTS.md` 同步；新增最小运行闭包、运行清单、独立性证据与八步 5/6/8 的闭包/异目录要求。
- `SKILL.md` 增加最小运行清单入口与常见错误；新增 `references/minimal-runtime.md`；`method-families`、`code-assets`、`project-reuse`、`llm-wiki-mode` 同步。
- 12 个方法页运行方式段落与依赖/frontmatter 更新；16 个 SCP 模板页增加“运行方式”；`save` 已提交知识库。

## T6 — 交付审查（可审查状态）

- 全套后端 `pytest -q`：最终 507 passed / 2 skipped，exit 0（425.27s），日志 `pytest-full-final2.log`；前两轮 `pytest-full.log`、`pytest-full-final.log` 同样 507/2。
- 真实 CLI render：SCP volcano、Python SHAP 均 exit 0 且 PNG MAD=0；bar 模板 bindings 改名输入 exit 0、PNG MAD=0。
- 规模/名称变化：6 个通过分支在 60/100/150 细胞与重命名细胞下全部 passed、输入未变（`portability-scale/`）。
- 前端 `npm test` 24 passed、typecheck exit 0、build exit 0。
- 正式库 lint：0 ERROR、14 WARN（均为预期 not_run）；check-entry 12 方法 + 16 模板共 28 项 `--record` 通过；`pending --json` 仅列 3 个无 verified 实现的家族。
- 完整性：962 source 哈希、123 页 id/status/favorite/user 全部未变。
- 已生成 `dependency-inventory.json/md`、`verification-matrix.md`、`claude-result.md`、`integrity-after.json`、浏览器 DOM/截图。
- 未部署、未重启正式 8765、未提交开发仓库；等待 Codex 审查。

## 审查修复阶段（review round 1，进行中）

Codex 首轮独立审查未通过。已完整阅读 `codex-review-round1.md`、`codex-review-early.md`、`codex-review-runtime.md`，并重新核对 design 与 implementation-plan 执行记录。旧 507 passed、旧收据和旧报告不视为本轮验收。

修复顺序：

1. E1/E2/E3：模块私有闭包、嵌套 source 定位、search/options 完整恢复。
2. R1/R2/R3：资源纳入闭包、页面入口与实际清单/函数交叉绑定、malformed 清单不抛异常。
3. E4/R4：Monocle2/3 分析核心、Seurat 适配、可选绘图分离；清单包检查与代码一致；Enrichment 自定义 TERM2GENE 不要求无关数据库/ID 转换包。
4. R5：前端唯一依赖事实、默认复用代码、旧状态文案。
5. R6：收据命令/输入哈希/执行哈希/比较断言来自实际运行，算法状态不硬编码；调查并保留 batch 失败。
6. 定向 RED/GREEN、真实 R、前端点击，稳定后一次全套回归；写逐项审查矩阵。

### 审查修复完成项

- E1：所有入口改为最内层 `ofile` 定位；nested driver source PASS（QC、batch）。
- E2：入口改为私有 `local({})` 闭包；QC→scoring 同环境覆盖测试 PASS；20 入口同环境加载后 QC PASS。
- E3：调用前后恢复 search/options；成功、异常、用户已 attach、batch 多包场景全部 PASS；diagnostics 记录实际恢复状态。
- R1：resources 必须列入 files 并核对 sha256；资源改字节使清单/证据失效。
- R2：入口路径/函数与页面 entrypoint 交叉绑定；页面 dependencies 与清单一致性检查；实际 12 方法全部 True。
- R3：malformed resources/source/packages/evidence 统一返回 issue；API 200，不 500。
- E4/R4：Monocle2/3 拆为 core/adapter；绘图 helper 不进入交付/分析实现。核心无 Seurat/绘图/交互，显式 root；清单按分支列出真实包；缺包 not_run。
- R5：单一依赖事实、入口/范围折叠、默认复用代码；CDP 真点击验证“必要依赖”1 处、Monocle 2 行、复用版 10 文件、入口含 monocle2_core.R。
- R6：portable 收据由实际 summary（命令/case/输入/输出哈希）与 comparison.json 派生；删除硬编码算法表；batch 交替批次原版/新模块同错，连续批次最终通过。
- 审查修复后全套后端：512 passed / 2 skipped，exit 0（329.23s），`pytest-review1-full-final.log`。
- 审查修复后前端：npm test 24 passed、typecheck/build exit 0；CDP 真点击证据 `browser/browser-click-round1-fix.json`。
- 正式库 lint：0 ERROR；check-entry 受影响页重新记录；知识库工作区干净。

## 第二轮审查修复（C1–C5，2026-10-24）

- C1：Monocle2 core 恢复原版两次 ordering：第一次 `orderCells(cds)`（root_state=NULL）产生 State，第二次显式 `root_state`；删除必填 `initial_root_state`。Monocle3 core 要求已有 `reduced_dim` 且细胞顺序一致，不补降维。`codex-monocle-contract.R` 3 项 PASS。
- C2：`scp-monocle2-plot`/`scp-monocle3-plot` 从分析 implementations、runtime 清单、算法/独立性收据移除；plot helper 仅留维护快照，不进入正式 KB；16 个既有模板未重画。AGENTS/SKILL 增加“运行函数≠分析实现”。
- C3：rna-velocity 必需 Python 包并入 `required_packages.Python=[scanpy,numpy,scvelo]`，删除独立 `python` 字段；页面依赖同步；前端按 `R: …；Python: …` 显示归属。文档示例补 palette 到 files。
- C4：implementation fallback 保留 issues；PageView 模板 runtime 与代码查看器显示清单问题；API 200 测试。
- C5：ORA 保存并比较真实 `gene_ids/TERM2GENE/TERM2NAME`；portable_run 记录执行副本 `code_sha256`，installer 对比正式代码，不一致不 passed；模板收据使用实际命令/目录/时间/哈希，无占位符；batch 交替顺序改为“合法标签，原版/新分支同错”的准确限制。
- 定向：`pytest tests/test_runtime_contract.py` 23 passed；前端 26 项通过、typecheck/build 通过；浏览器 velocity 显示语言归属、trajectory 无 plot 行。
- 全套回归：`pytest-review2-full.log`（最终计数见下）。
- 第二轮全套后端：513 passed / 2 skipped，exit 0（326.71s），`pytest-review2-full.log`。
- 前端：26 项通过、typecheck/build exit 0；浏览器 velocity/trajectory DOM 证据在 `browser/*-r2.html`。
- 正式库 lint 0 ERROR；知识库已 save，工作区干净。


## Codex最终验收与部署

C1-C5独立审查通过，五处安装每处285文件SHA核验、备份完成；正式8765 API/资源与实际浏览器验收通过。详见文档/最小依赖独立模块改造/final-acceptance.md。962源与123页作者保护通过。9分析实现verified、9not_run、16模板verified，pending3项保留缺包/待验证。未代作者签核。
