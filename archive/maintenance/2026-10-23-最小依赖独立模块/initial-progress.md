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
