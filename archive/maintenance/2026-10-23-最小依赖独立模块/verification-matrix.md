# 验证矩阵

日期：2026-10-23。实施：Claude Code 单会话；等待 Codex 独立审查。

## 环境与固定参数

- R：`D:/R-4.5.0/bin/Rscript.exe`；库：`E:/research-wiki-env/R-lib-scp/4.5`。
- Python（wiki/pytest）：`C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8`。
- 通用 Python：`D:/anaconda/python.exe -X utf8`。
- 所有分析测试显式 `BiocParallel::SerialParam()`、`future::plan("sequential")`；未改上游默认。首次 codex-reference 的 18-worker 崩溃作为失败证据保留。
- 每个独立运行在调用前后 `serialize()` 输入对象并比较，`result.json` 的 `input_unchanged=true`；receipt 记录该检查。
- 模块覆盖 `check_R`/`check_Python`/`PrepareEnv`/`conda_install` 为 fail-only，调用后用 `options(old)` 恢复调用前的 options；不自动安装或创建环境。
- 夹具：`E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda`，仅软件调用，不代表科学有效或真实课题。

## 方法实现

| 家族 | 实现 | 旧入口 | 新入口 | 独立迁移 | 算法 | 参考对照 | 证据 |
|---|---|---|---|---|---|---|---|
| cell-quality-control | scp-runcellqc | `analysis.R` 整库加载 | `run_cell_quality_control` | verified | passed | QC 表逐值一致 | `verification/scp-runcellqc-portability.json`; `scp-runcellqc-standalone.json` |
| doublet-detection | scp-rundoublet | 整库加载 | `run_doublet_detection` | not_run | not_run | 缺 scDblFinder，精确错误 | `verification/scp-rundoublet-*.json` |
| dimensionality-reduction | scp-dimreduction | 整库加载 | `run_dimensionality_reduction` | verified | passed | PCA/UMAP 逐值一致 | `verification/scp-dimreduction-*.json` |
| batch-integration | scp-seurat | 整库加载 | `run_seurat_integration` | verified | passed | 整合 UMAP/聚类逐值一致 | `verification/scp-seurat-*.json` |
| batch-integration | scp-harmony | 整库加载 | `run_batch_integration` | not_run | not_run | 缺 harmony，精确错误 | `verification/scp-harmony-*.json` |
| cell-type-annotation | scp-singler | 整库加载 | `run_cell_type_annotation` | not_run | not_run | 缺 SingleR，精确错误 | `verification/scp-singler-*.json` |
| differential-expression | scp-detest | 整库加载 | `run_differential_expression` | verified | passed | marker 表完全一致 | `verification/scp-detest-*.json` |
| gene-set-enrichment | scp-enrichment | 整库加载 | `run_gene_set_enrichment` | verified | passed | ORA 表完全一致 | `verification/scp-enrichment-*.json` |
| gene-set-scoring | scp-cellscoring | 整库加载 | `run_gene_set_scoring` | verified | passed | 分数列逐值一致 | `verification/scp-cellscoring-*.json` |
| trajectory-inference | scp-slingshot | 整库加载 | `run_trajectory_inference` | verified | passed（show_plot=FALSE） | pseudotime/BranchID 一致 | `verification/scp-slingshot-*.json` |
| trajectory-inference | scp-monocle2 | bundle 内只有原函数 | `run_trajectory_monocle2` | not_run | not_run | 缺 monocle，精确错误；静态闭包已提取 | `verification/scp-monocle2-*.json` |
| trajectory-inference | scp-monocle3 | bundle 内只有原函数 | `run_trajectory_monocle3` | not_run | not_run | 缺 monocle3，精确错误；静态闭包已提取 | `verification/scp-monocle3-*.json` |
| dynamic-feature-analysis | scp-dynamicfeatures | 整库加载 | `run_dynamic_feature_analysis` | verified | passed | GAM 表完全一致 | `verification/scp-dynamicfeatures-*.json` |
| reference-mapping | seurat-label-transfer | 已是显式 Seurat 调用 | `run_reference_label_transfer` | verified | passed | 每 query 细胞预测、顺序、anchor 数 | `verification/seurat-label-transfer-*.json` |
| reference-mapping | scp-runseuratmap | 整库加载 | `run_reference_mapping` | not_run | not_run | Seurat 5.6 `dim.` 上游错误；原 bundle 同样失败 | `verification/scp-runseuratmap-*.json` |
| rna-velocity | scp-scvelo | 整库加载 | `run_rna_velocity` | not_run | not_run | 缺 RETICULATE_PYTHON/scvelo，未创建环境 | `verification/scp-scvelo-*.json` |

统计：9 个分支独立迁移+算法通过；7 个分支精确 not_run；0 个把声明、source、文件存在或旧整库收据写成通过。

### 规模与名称变化（不替代默认参数的参考对照）

在已通过的 6 个分支上换合法规模并重命名细胞（`SCP_TEST_CELLS`/`SCP_TEST_RENAME`），全部 exit 0、输入未变，输出结构正确：

| 分支 | 规模/命名 | 结果 |
|---|---|---|
| cell-quality-control | 60 细胞，细胞名改为 `cell_1…` | passed |
| dimensionality-reduction | 150 细胞，重命名 | passed |
| batch-integration/Seurat | 120 与 100 细胞、两组连续批次 | passed |
| gene-set-scoring | 60 细胞，重命名 | passed |
| trajectory-inference/Slingshot | 60 细胞，重命名 | passed |
| dynamic-feature-analysis | 60 细胞，重命名 | passed |

这些运行只证明可移植/规模变化，数值不与默认参考逐值比较；默认规模的对照另列上表。

## 绘图模板

全部 16 个 SCP 单 panel 模板在同一隔离流程中渲染：复制 `spec.json`/`code/`/`example/` 到维护记录目录，工作目录为无关临时目录，新 `Rscript` 进程，不提供 SCP 路径，使用 `example/style.json`。

| 模板 | 渲染 | PNG 与既有回放 | 复制文件 | 证据 |
|---|---|---|---|---|
| fig01-volcano | exit 0 | MAD=0（逐像素一致） | 5 + palette | `verify/runtime-portability.json` |
| fig02-ring | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig03-pie | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig04-rose | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig05-trend | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig06-area | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig07-dot | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig08-group-heatmap | exit 0 | MAD=0 | 6 + palette | 同上 |
| fig09-bar | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig10-sankey | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig11-chord | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig12-venn | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig13-upset | exit 0 | MAD=0 | 5 + palette | 同上 |
| fig14-feature-heatmap | exit 0 | MAD=0 | 6 + palette | 同上 |
| fig15-cell-cor-heatmap | exit 0 | MAD=0 | 6 + palette | 同上 |
| fig16-cell-density | exit 0 | MAD=0 | 5 + palette | 同上 |

PDF 因生成时间戳不同未按字节比较；fig01/fig02 的 SVG 因设备标识不同未按字节比较，其余 SVG 字节一致。像素证据存 `portability/templates-evidence.json`，逐模板输出在 `portability/templates/<id>/out/`。

### CLI 标准输入与 bindings

- `wiki.py render 2026-10-22-scp-example__fig01-volcano--volcano --data .../example --out cli-render/volcano`：exit 0，PNG 与既有回放 MAD=0。
- Python 模板 `2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar`：exit 0，PNG 与既有回放 MAD=0。
- bindings：把 bar 模板的 `group` 列改名为 `cell_type`，用 `columns: {group: cell_type}` 映射；`render` exit 0，`bindings-report.json` 生成，PNG 与标准输入 MAD=0。源 CSV 未改。
- volcano 的 bindings 负例因上游表含 `Inf` 被现有数值检查拒绝；不是本轮回归，未改验证规则。

## 软件测试

| 检查 | 命令 | 结果 |
|---|---|---|
| 运行清单/接口 | `python -m pytest tests/test_runtime_contract.py -q` | 17 passed |
| 定向后端 | `pytest tests/test_runtime_contract.py tests/test_method_implementations.py tests/test_code_assets.py tests/test_lint.py -q` | 120 passed / 2 skipped |
| 全套后端 | `pytest -q` | 507 passed / 2 skipped，exit 0；`pytest-full.log`、`pytest-full-final.log`、`pytest-full-final2.log`（最终） |
| 前端测试 | `npm test` | 24 passed / 0 failed |
| 前端类型 | `npm run typecheck` | exit 0 |
| 前端构建 | `npm run build` | exit 0；产物写入 staged |
| 正式库 lint | `wiki.py lint` | exit 0；0 ERROR；WARN 含预期 not_run |
| check-entry | 12 方法 + 16 SCP 模板 | 28 项 `--record` 通过 |
| 完整性 | `scripts/integrity_check.py` | 962 source 文件哈希不变；123 页 id/status/favorite/user 不变 |

## 浏览器（测试服务 8787）

- headless Chrome（`--headless=new`）实际执行前端 JS，`--dump-dom` 与截图：
  - `browser/method-qc-final.html`：显示“独立模块”“独立迁移已验证”“必要依赖：Seurat、SeuratObject、Matrix、rlang”。
  - `browser/method-traj.html`：三个分支，Slingshot verified，Monocle2/3 not_run，依赖分别列出。
  - `browser/template-volcano.html`：模板“运行方式与依赖”、复制清单和证据。
  - `browser/methods-domain.html`：领域“单细胞分析”→用途“预处理与质量控制”筛选仍返回规范页。
- 不是人工点击验收；未部署正式 8765，未重启正式服务。

## 明确未完成 / 限制

1. 7 个 not_run 分支未安装包、未创建 Python 环境；保持精确错误。
2. Slingshot 的 `show_plot=TRUE` 在当前 ggplot2/patchwork 版本下报 `grobs must be ... not a list matrix`；原始 bundle 在同环境同样报错，未改上游绘图代码。
3. Monocle/velocity 的缺失依赖分支未运行；静态提取和缺包门禁已验证。
4. 未做真实课题分析或科学有效性验证；示例夹具只证明软件调用与数值等价。
5. 前端浏览器验证为 headless DOM/截图，不是人工逐项点击。

## 首轮审查修复复验（review round 1）

| 项 | 复验命令/证据 | 结果 |
|---|---|---|
| E1 嵌套 source | `scripts/codex-source-probe.R` QC/batch | direct PASS、nested PASS；`review1-e1-green2.log`、`review1-e1-batch-green.log` |
| E2 多模块同环境 | `codex-multi-module-probe.R`、`all-modules-probe.R` | QC→scoring→QC PASS；20 入口同环境 QC PASS；`review1-e2-*.log` |
| E3 search/options 恢复 | `codex-qc-probe.R`、`e3-user-attached.R`、`e3-error-path.R`、`e3-batch-restore.R` | 成功/异常/用户包/batch 均 TRUE；`review1-e3-*.log` |
| R1 资源闭包 | `pytest tests/test_runtime_contract.py -q` | 资源必须在 files、sha 不符即清单错误；22 passed |
| R2 入口交叉绑定 | 同上 + 实际 12 方法 | entry/entry_function 不符即 invalid；12 方法 dependency_match=True |
| R3 malformed 清单 | 同上 `test_malformed_manifest_does_not_break_api` | `/api/page`、`/api/pages` 200；runtime unknown + issues |
| E4/R4 Monocle 拆分 | `source_core_probe.R`、6 个 portability 分支 | core 无 Seurat/绘图/交互；6 分支精确 not_run；清单按 core/adapter/plot 列包 |
| R5 前端 | `npm test/typecheck/build`；CDP 点击 | 24 passed；必要依赖 1 处、Monocle 2 行、默认复用版 10 文件、入口 monocle2_core.R |
| R6 证据 | `portable_run.R` 全部重跑、8 个 compare_results、installer | 实际 command/case/input/output 哈希；算法 passed 仅由 comparison 产生；batch 交替批次原版/新模块同错 |

方法实现现为 18 个（9 verified、9 not_run；Monocle 绘图辅助不计入），SCP 模板 16 个（全部 portability verified）。最终全套回归见 `pytest-review2-full.log`（513 passed / 2 skipped）。

## 第二轮审查修复（C1–C5，2026-10-24）

| 项 | 复验 | 结果 |
|---|---|---|
| C1 Monocle2 两次 ordering | `Rscript --vanilla scripts/codex-monocle-contract.R <KB trajectory code>` | 3 PASS；第一次无 root_state、第二次带 root_state；无 `initial_root_state` |
| C1 Monocle3 嵌入前提 | 同上 | 缺 `reduced_dim` / 行数/顺序不符在包检查前明确拒绝 |
| C2 绘图移除 | `trajectory-inference/runtime.json`、页面实现表、KB code | 只剩 Slingshot + Monocle core/adapter；无 plot 实现/收据；维护快照保留未交付 helper |
| C3 Python 事实 | `pytest test_runtime_contract.py`、`npm test`、浏览器 | `required_packages.Python=[scanpy,numpy,scvelo]`；DOM `R: …；Python: …`；无独立 python 字段 |
| C4 清单问题 | `test_malformed_manifest_does_not_break_api`、前端模板 issues 测试 | API 200；模板详情/代码查看器显示“清单问题” |
| C5 ORA 输入 | `portability/gene-set-enrichment/result.json` | `input_unchanged=true`，比较实际 gene_ids/TERM2GENE/TERM2NAME |
| C5 执行哈希 | `portability/*/result.json` `code_sha256`；收据 `executed_files` | 正式 code 与执行副本不一致即不 passed；旧结果不重绑 |
| C5 模板证据 | `portability/templates-evidence.json`、`verify/runtime-portability.json` | 实际命令/隔离目录/start/end/code hash；16/16 render exit 0、PNG MAD=0 |
| C5 batch 限制 | `batch-alternating-investigation.json` | 合法交替标签，原版/新分支同报 Assay 错误；连续分组通过仅覆盖该场景 |

最终全套回归：`pytest-review2-full.log`：513 passed / 2 skipped，exit 0。
