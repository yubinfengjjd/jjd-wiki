# Codex 首轮审查修复矩阵

日期：2026-10-23。同一 Claude Code 会话修复；未启动子代理、未安装依赖、未部署、未重启正式 8765、未提交开发仓库。旧 507 passed 与旧报告不作为本轮验收。

## 逐项矩阵

| 编号 | 审查问题 | 修复文件/位置 | 精确命令 | 结果证据 | 限制 |
|---|---|---|---|---|---|
| E1 | 嵌套课题 driver source 时取外层 `ofile` | 12 个 `methods/*/code/analysis.R`、`monocle2.R`、`monocle3.R`（生成器 `scripts/generate_wrappers_v2.py`） | `Rscript --vanilla scripts/codex-source-probe.R "<pilot3>/cell-quality-control/code/analysis.R"`；batch 同 | `review1-e1-green2.log`：direct PASS、nested PASS；`review1-e1-batch-green.log` 同 | 取最内层 frame 的 `ofile`；`sys.source` 无 `ofile` 时用 `chdir=TRUE` 或 cwd 回退，已在 references 说明 |
| E2 | 多模块 source 同一环境互相覆盖 engine/helper | 所有入口改为 `name <- local({...})`，engine/helper/分支都在闭包内 | `Rscript --vanilla scripts/codex-multi-module-probe.R "<pilot3>"`；`scripts/all-modules-probe.R "<pilot3>"` | `review1-e2-green2.log`：load QC→scoring→call QC PASS；`review1-e2-all-green.log`：20 个入口同环境加载后 QC PASS | 入口名仍按页面 id 唯一；同名入口后加载者覆盖，属预期 |
| E3 | `library()` 自动 attach 的依赖未恢复 | 入口统一保存 `search()`/`options()`，调用后按依赖逆序 detach 本次新增包并重试；diagnostics 记录 `search_restored/options_restored` | `codex-qc-probe.R`；`e3-user-attached.R`；`e3-error-path.R`；`e3-batch-restore.R` | `review1-e3-green2.log` SEARCH_RESTORED TRUE、FUTURE_OPTION_RESTORED TRUE；`review1-e3-user-green.log` 用户 ggplot2 保持；`review1-e3-error-green.log` 异常路径恢复；`review1-e3-batch-green.log` 多包整合恢复 | 不 unload namespace；若某包 detach 仍失败，diagnostics 明确 restoration incomplete，不写 none |
| R1 | resources 不在闭包指纹，改字节仍 verified | `rwiki/runtime_contract.py`：resources 必须列入 files，核对 sha256；closure_hash 覆盖 files | `pytest tests/test_runtime_contract.py::test_resource_must_be_in_files_and_hash_must_match` | 测试通过；slingshot 实际 manifest 中 palette 同时在 files/resources，sha 核对 | 资源必须同时在 files；只写 resources 会清单错误 |
| R2 | 页面 entrypoint 与清单/函数未交叉绑定 | `runtime_contract.py` 校验入口函数定义；`method_implementations.py` 比对页面 entrypoint 与清单 entry/entry_function，并比较页面 dependencies 与 required_packages | `pytest tests/test_runtime_contract.py::test_entry_function_must_exist_in_entry_file`、`::test_page_entrypoint_mismatch_invalidates_portability` | 两项通过；实际 12 方法 `dependency_match=True`，入口状态 verified/not_run 与清单一致 | 页面 dependencies 保留为兼容字段；前端有 runtime 时只显示清单事实 |
| R3 | resources=7 导致 TypeError/500 | `runtime_contract.py` 校验 resources/source/packages/evidence 容器；`runtime_facts` 顶层捕获并返回 issue | `pytest tests/test_runtime_contract.py::test_malformed_resources_do_not_raise`、`::test_malformed_manifest_does_not_break_api` | 两项通过；`/api/page`、`/api/pages` 均 200，runtime unknown + issues | 错误清单显示为“未登记/清单错误”，不当作普通未审计 |
| E4 | Monocle2/3 混合分析、绘图、交互、Seurat 转换 | `code/monocle2_core.R`/`monocle3_core.R`（分析核心，无 Seurat/绘图/交互）、`code/monocle2.R`/`monocle3.R`（Seurat 适配）、`code/monocle2_plot.R`/`monocle3_plot.R`（可选绘图）；核心必须显式 `root_state`/`use_partition`+root | `scripts/portable_run.R monocle2-core/monocle3-core/monocle2/monocle3/monocle2-plot/monocle3-plot`；`scripts/source_core_probe.R` | 6 个分支均精确 `not_run`（缺 monocle/monocle3 或绘图需 core 结果）；source 只定义函数；核心无 `CellDimPlot/select.list/Sys.sleep/Seurat` 调用 | 本机缺 monocle/monocle3，未实际运行算法；交互/绘图默认行为已改变，写在 `source.modifications`，不承诺同 seed 数值等价 |
| R4 | Monocle 清单与实际包检查不同、继承 Slingshot optional | `scripts/install_modules.py` 为 core/adapter/plot 分别生成 required/optional；`trajectory-inference/runtime.json` | `python scripts/install_modules.py`；`runtime_contract.read_manifest` | 清单：core 8 R 包、adapter +Seurat/SeuratObject、plot 2/2 包；monocle optional 为空；dependency_match 全部 True | 缺包仍 not_run；未安装 monocle |
| R5 | 前端重复依赖、默认原始代码、旧文案 | `frontend/src/views/MethodOverview.tsx`（唯一依赖列、折叠入口/范围）、`CodeViewer.tsx`（默认复用版与入口文件）、`trajectory-inference.md`/`doublet-detection.md` 状态文案；`rwiki/lint.py` 依赖一致性提示 | `npm test`、`npm run typecheck`、`npm run build`；测试服务 8787 + CDP 真实点击 | `browser/browser-click-round1-fix.json`：41 卡片→点击轨迹→hash 正确；`必要依赖` 仅 1 处；Monocle core/adapter 行 2；代码弹窗默认“复用版 10”，入口含 `monocle2_core.R` | 页面依赖字段仍保留作兼容，有 runtime 时不展示第二份；长 scope 折叠 |
| R6 | 收据检查项超出脚本、命令不可重放、算法 state 硬编码 | `scripts/portable_run.R`（输入快照、实际命令、case、R 版本、输出）、`scripts/compare_results.R`（comparison.json）、`scripts/install_modules.py`（收据从 summary/comparison 派生，删除硬编码 algorithm 表） | 全部 `scripts/portable_run.R` 分支重跑；8 个 compare_results；`python scripts/install_modules.py` | 每份 portability 收据含实际 `command`/`case`/`isolated_code_dir`/`fixture`/`input_sha256`/`output_sha256`；算法 passed 仅当 summary passed 且 comparison passed；doublet/SeuratMap/velocity/Monocle 为实际 not_run | 比较产物只覆盖已跑分支；未跑分支如实 not_run；旧的 `review1-before` 与首轮报告保留 |
| R6b | 17:43 batch `not_run` 与旧报告 passed 冲突 | `scripts/batch-alternating-investigation.R`、`batch-alternating-investigation.json/log` | 同环境原版/新模块分别调用 120 细胞、A/B 交替批次 | 原版与新模块同报 `invalid class "Assay" object: 'counts' must have the same cells as 'data'`；最终有效运行使用连续批次（60/60），原版/新模块 UMAP/聚类逐值一致 | 交替批次属于上游/Seurat 行为，不是新模块独有回归；未改数据/阈值绕过 |

## 受影响的真实验证

- 入口 probes：`review1-e1-green2.log`、`review1-e2-green2.log`、`review1-e2-all-green.log`、`review1-e3-green2.log`、`review1-e3-user-green.log`、`review1-e3-error-green.log`、`review1-e3-batch-green.log`。
- 方法 portability：`portability/<key>/result.json` 与 `result.rds`；所有命令含实际目录/case；比较产物 `comparison.json`。
- 浏览器：测试服务 8787，CDP 真实点击领域→用途/卡片→代码；证据 `browser/browser-click-round1-fix.json`；未重启正式 8765。
- 后端定向：`tests/test_runtime_contract.py` 22 passed（含新增 R1/R2/R3/API 测试）；相关方法/验收/代码/ lint 定向 124 passed / 2 skipped。
- 全套回归：`pytest-review1-full-final.log`（见 progress）。
- 完整性：`integrity-after.json`，962 source 哈希、123 页作者/id/status/favorite 未变。

## 仍需 Codex 复核

1. Monocle2/3 core 的算法步骤是否与固定源码等价（本机缺包，无法实际运行）。
2. 私有闭包对 `source(local=env)` 与直接 `source` 的组合是否覆盖所有日常用法。
3. 实际 comparison 产物是否足以约束算法 passed（未跑分支仍应 not_run）。
4. 前端唯一依赖展示与默认复用代码的真实浏览器行为。
