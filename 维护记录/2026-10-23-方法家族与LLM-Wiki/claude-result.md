# Claude 完成报告 — 2026-10-23 方法家族与 LLM-Wiki

## 1. 结论

本轮完成了方法家族后端门槛、前端复验、13 个单细胞分析家族的来源封装与验证（含 handoff 指定 10 个，以及降维、聚类、动态特征）、旧页分类/关系迁移、15 个分析家族内容编译，以及正式 AGENTS / staged AGENTS / SKILL / references 的规则同步。开发仓库保持未提交、可审查工作树；未部署五处全局技能，未重启正式服务，未安装任何依赖。

当前状态：

- 15 个 `analysis` 家族：12 个至少有一个 `verified` 实现；3 个仅 `not_run`（doublet、annotation、rna-velocity）。reference-mapping 的标签转移已 verified，但其 SCP UMAP 投影分支单独 not_run。
- 2 个 `workflow` 资料页、9 个 `technical` 资料页；无 `method_kind` 缺失，无重复分析家族标题。
- 旧 13 页全部保留旧 id、`source/` 原字节与作者 user 区块；status 未改；旧 `figure_relations` 已迁往分析家族。
- 新 13 个家族页保持 `draft`，等待作者按正常流程确认；没有代签。
- 正式库 `lint`：OK，仅 5 条预期 `not_run` WARN。

### 第一轮 Codex 审查后的补充（2026-10-23）

Codex 初审提出五项修复；已完成，详见 [claude-review-round1-result.md](claude-review-round1-result.md)：

1. 15 个分析家族全部补“来源与实现选择”表；cell-type-annotation 补青光眼 marker 手工注释，doublet-detection 补 DoubletFinder 来源/差异，均不伪造验证。
2. 新增 [migration-map.md](migration-map.md)：旧页 → 规范家族 → 具体实现 → 原始来源，覆盖全部旧页并含同家族多来源规则。
3. 八步入库流程、跨来源去重、来源 panel 存储同步进 AGENTS/assets AGENTS/SKILL/references；新增同源加分支、技术页主关系 lint、共享代码分支测试。
4. 分析详情首屏显示用途，正文用途/输入/输出不再重复；technical/workflow 不再套分析实现/空配图总览；用真实 API 页面 fixture 做 SSR 核对。
5. `code-files` 按入口文件派生每文件分支状态；共享文件列全部分支，原始版保持来源状态；API/UI 均有测试。

修复后重跑：定向后端 `103 passed, 2 skipped`；全套 `435 passed, 2 skipped`；前端 30 figure + 9 method checks、typecheck、build 通过；lint OK。R 分析代码/receipt 未改，未重跑 R 调用。

### 第二轮 Codex 审查后的补充（2026-10-23）

Codex 复核只提出两类遗留，已完成，详见 [claude-review-round2-result.md](claude-review-round2-result.md)：

1. 面包屑、反向链接和知识网络节点按 `method_kind` 显示“分析家族/组合流程/技术资料/待分类”，不再用 `type=method` 冒充“分析方法”；通用类型标签改为“方法页”。真实 source/workflow 页 SSR 断言通过，路由、id、图谱拓扑不变。
2. 11 个旧 technical/workflow 页的“本轮未安装/当前 Matrix 冲突”等环境断言改为明确的 2026-10-22 历史记录，并链接 2026-10-23 规范家族的 verified/not_run 范围；未删除历史，未改 source/user/status，未把部分通过扩大为全部算法已运行。

重跑：前端 30 figure + 10 method checks、typecheck、build 通过；正式库 lint OK；源码哈希/旧 user/status 未变。未重跑后端与 R 分析（本轮未改算法/receipt）。

## 2. 基线与环境

| 项目 | 值 |
|---|---|
| 开发仓库基线 | `2bbe879`；原始 dirty tree 保留，未 reset/clean/提交 |
| 知识库基线 | `6841992` |
| 计划 / handoff | `文档/方法家族与LLM-Wiki改造/implementation-plan.md`、`claude-handoff.md` |
| 基线证据 | `维护记录/2026-10-23-方法家族与LLM-Wiki/{before,source-hashes-before.json,development-baseline-*}` |
| wiki Python | `C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe` |
| 分析 R | `D:\R-4.5.0\bin\Rscript.exe`，`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，先按 `scp-runtime.ps1` 设置 AMD64/TEMP/locale |
| 分析 Python | `E:/research-wiki-env/bio-python/Scripts/python.exe` |
| 数据 | `E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda` |
| 已存在依赖 | Seurat 5.6.0、SeuratObject 5.4.0、slingshot 2.16.0、clusterProfiler 4.16.0、mgcv 1.9.1、BiocParallel 1.42.0、DOSE 4.2.0、shap 0.54.1 |
| 缺失依赖（未安装） | harmony、SingleR、scDblFinder、scanpy、scvelo、anndata、RETICULATE_PYTHON |

## 3. 本轮实际修改

### 3.1 开发仓库（未提交）

本轮新增/修改：

- `staged/research-wiki/rwiki/workflow.py`：ready 的 `workflow`/`technical` 页显示“流程资料已确认/技术资料已确认”，不再被排成 analysis 的“待实现”。
- `staged/research-wiki/tests/test_method_implementations.py`：新增 ready 参考资料不进入分析实现队列的测试。
- `staged/research-wiki/tests/conftest.py`：新增合成 implementation 收据 fixture（明确仅软件夹具）。
- `staged/research-wiki/tests/test_acceptance_gates.py`、`test_m1_integration.py`、`test_semantic_relations.py`：按新契约更新夹具/断言；没有放宽门槛。
- `staged/research-wiki/SKILL.md`、`assets/AGENTS.md`、`references/{code-assets,knowledge-linking,project-reuse}.md`：同步家族/收据/LLM Wiki 规则。
- 新增 `staged/research-wiki/references/llm-wiki-mode.md`、`references/method-families.md`。
- 第一轮审查修复另改：`rwiki/code_assets.py`（按入口文件派生 branches）、`rwiki/lint.py`（workflow/technical 主关系报错）、`tests/test_method_implementations.py`、`tests/test_semantic_relations.py`；前端 `src/api.ts`、`src/CodeViewer.tsx`、`src/markdown.ts`、`src/relations.ts`、`src/styles.css`、`views/PageView.tsx`、`views/MethodOverview.tsx`；新增 `frontend/tests/real-pages.ts` 和对应 SSR/API 断言。

已存在但本轮复验、未改的先前实现（来自前一执行者）：

- `rwiki/method_implementations.py`
- `rwiki/{acceptance,catalog,suggest,lint,cli,server,facts,ingest,code_assets,templates}.py` 的相关门槛/API/索引改动
- `tests/test_method_implementations.py` 的 25 个既有门槛测试
- 前端 `frontend/src/{api,methods,components,markdown}.ts/tsx`、`views/{MethodsView,MethodOverview,PageView,ItemPanel}.tsx`、`tests/methods.*`
- 前端 `package.json` 等既有改动

本轮没有改前端代码，只复验了测试/typecheck/build。

### 3.2 知识库（wiki.py save 自动提交）

方法页：

- 15 个 analysis 家族：`cell-quality-control`、`doublet-detection`、`batch-integration`、`differential-expression`、`gene-set-enrichment`、`gene-set-scoring`、`trajectory-inference`、`rna-velocity`、`cell-type-annotation`、`reference-mapping`、`dimensionality-reduction`、`cell-clustering`、`dynamic-feature-analysis`、`shap-explanation`、`regression-resampling-evaluation`。
- 9 个 technical：`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-integration`、`scp-local-source`、`scp-trajectory-velocity`、`scp-visualization-interface`、`scrna-marker-annotation`、`scrna-pathway-signature-ensemble`。
- 2 个 workflow：`scp-standard-workflow`、`scrna-preprocess-doublet-qc-harmony`。
- 旧页正文保留，增加“资料类型/不是默认分析家族”横幅和家族链接；`figure_relations` 主记录清除；`知识关联检查` 改写为迁移说明。
- 新家族页写用途、原理与选择、适用/不适用、输入、怎么做、代码、输出、知识关联检查；`data_contract` 写真实对象/矩阵/模型，不强制 CSV。
- `shap-explanation` 更新为纯函数 `explain_model` 的输入/输出/验证说明；`regression-resampling-evaluation` 更新验证收据说明。

代码/收据：

- 12 个 SCP wrapper `code/analysis.R`（QC、doublet、batch、DE、enrichment、scoring、trajectory、velocity、annotation、reference、dimred、dynamic）。
- `cell-clustering/code/clustering.R`：显式 FindNeighbors/FindClusters 分支。
- `reference-mapping/code/transfer.R`：Seurat 锚点标签转移分支。
- `batch-integration/code/analysis.R` 追加 `run_seurat_integration` 分支（SCP `Seurat_integrate`）。
- 18 个 `verification/*.json`：17 个 analysis 分支 + 1 个 technical 表适配分支；`files` 覆盖当前 `code/` 全部源文件。
- `scp-local-source/code/SCP-local/load_scp_local.R`：`Assays(object, assay)` shim 改用 `Seurat::GetAssay`（Seurat 5.6 兼容；不改统计逻辑）；`PATCHES.md` 记录。`source/` 原字节未动。
- `scp-visualization-interface` 声明 `scp-table-adapters` 实现；测试从旧记录的 20 项复跑为 25 PASS / 0 FAIL，并更新页面/verification/receipt。

规则/索引：

- `知识库/AGENTS.md`：新增 Karpathy 可定制 LLM Wiki 模式、方法家族/实现收据/推荐门槛；删除“知识库不运行它们”的绝对说法，保留“页面/网页不代跑课题”。
- `index.md` 已由 `save` 重建，按分析家族/组合流程/技术资料分组，方法页带 summary。
- `log.md` 只追加，未手改。
- 13 个旧 ready 页（含 shap/regression）的 `acceptance.json` 重新记录；status 未改。

维护记录：

- `test_scientific_R.R`：最终 R 测试，32 PASS + 5 预期 not_run。
- `test_scientific_python.py`：SHAP + 回归，2 PASS。
- `make_receipts.py`：收据生成器（已运行）。
- `function-inventory.json`：15 家族 / 17 分支 / 当前状态。
- `create_scientific_assets.py`：保留为 bootstrap 生成器，并加入拒绝覆盖最终资产的 guard。
- `migrate_method_pages.py`：本次页面迁移脚本。
- `claude-progress.md`、本报告。
- 日志：`E:/research-wiki-env/tmp/test_scientific_R.log`、`test_scp_tables.log`、`pytest-full-2.log`、`frontend-build.log`。

## 4. 实际命令与结果

### 4.1 后端

```powershell
cd E:\research-wiki\开发\staged\research-wiki
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'; $env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
& 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe' -X utf8 -m pytest tests/test_method_implementations.py -q
# 27 passed, 1 warning

& 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe' -X utf8 -m pytest -q
# 首轮：432 passed, 2 skipped, 1 warning in 354.46s
# Codex 初审修复后：435 passed, 2 skipped, 1 warning in 323.23s
```

### 4.2 前端

```powershell
cd E:\research-wiki\开发\frontend
npm test
# figure models and Gallery SSR: 30 checks passed
# PASS default methods contains analysis only...
# PASS method detail renders canonical purpose...
# PASS each implementation displays its own verification scope...
# PASS missing derived implementation status is never inferred from a receipt path
npm run typecheck
# passed
npm run build
# built in 6.22s
```

### 4.3 实际分析调用

```powershell
$env:PROCESSOR_ARCHITECTURE='AMD64'
$env:R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5'
$env:TEMP=$env:TMP='E:/research-wiki-env/tmp'; $env:MPLCONFIGDIR='E:/research-wiki-env/tmp/mpl'
D:\R-4.5.0\bin\Rscript.exe --vanilla `
  E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\test_scientific_R.R `
  E:\research-wiki\知识库 E:\research-wiki-env\sources\scp-2026-10-22\data\pancreas_sub.rda
# 32 PASS; 0 failure(s); 5 expected not_run branch(es)
```

异目录复制验收（复制 `code/` 与完整 `SCP-local` 到 `E:/research-wiki-env/tmp/rw-portability-20261023`，用绝对 bundle/数据路径重跑代表调用）：

```powershell
D:\R-4.5.0\bin\Rscript.exe --vanilla `
  E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\test_portability.R `
  E:\research-wiki\知识库 E:\research-wiki-env\sources\scp-2026-10-22\data\pancreas_sub.rda `
  E:\research-wiki-env\tmp\rw-portability-20261023
# 14 PASS; 0 failure(s)（11 个 verified 路径 + 3 个预期缺包错误路径 + 表适配）
```

```powershell
E:\research-wiki-env\bio-python\Scripts\python.exe -X utf8 `
  E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\test_portability_python.py `
  E:\research-wiki\知识库 E:\research-wiki-env\tmp\rw-portability-python-20261023
# SHAP + 回归 2 PASS；代码从 Wiki 外目录加载
```

```powershell
cd E:\research-wiki\知识库\methods\scp-visualization-interface\code
D:\R-4.5.0\bin\Rscript.exe --vanilla test_scp_tables.R
# 25 PASS, 0 FAIL
```

```powershell
E:\research-wiki-env\bio-python\Scripts\python.exe -X utf8 `
  E:\research-wiki\维护记录\2026-10-23-方法家族与LLM-Wiki\test_scientific_python.py `
  E:\research-wiki\知识库\methods
# PASS SHAP analytical linear solution...
# PASS regression hand-derived metrics...
```

### 4.4 正式库 lint / API

```powershell
cd E:\research-wiki\开发\staged\research-wiki
& 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe' -X utf8 wiki.py --config config.json lint
# OK
# WARN batch-integration scp-harmony not_run
# WARN cell-type-annotation scp-singler not_run
# WARN doublet-detection scp-rundoublet not_run
# WARN reference-mapping scp-runseuratmap not_run
# WARN rna-velocity scp-scvelo not_run
```

TestClient 实查（真实 config，非夹具）：

- `/api/pages`：15 analysis、9 technical、2 workflow。
- 旧 `scp-cellqc-doublet`：`method_kind=technical`，workflow `技术资料已确认`，queue `None`，无 `figure_relations`。
- 新 `cell-quality-control`：`method_kind=analysis`，workflow `待你确认`（draft），implementation `scp-runcellqc=verified`。
- `/api/page?path=methods/cell-quality-control.md`：`implementation_status` 为 verified；`meta` 不含派生 `implementation_status`。
- `/api/methods/cell-quality-control/code-files`：返回 `code/analysis.R`，只读。
- `/`：200，内置 `assets/index-*.js` 可加载。

### 4.5 迁移完整性检查

脚本检查结果：

- `source-hashes-before.json`：全部 source 文件 SHA-256 一致。
- 旧页 user 区块：全部逐字节一致。
- 旧页 status：全部未变。
- 旧 id：全部未变。
- 旧 technical/workflow 页：`figure_relations` 全部清除。
- method_kind 计数：analysis 15、workflow 2、technical 9、缺失 0。
- 重复标题：无。
- 所有 analysis 页必需章节：存在且非空/非 TODO。

## 5. 各实现验证状态

所有 `passed` 收据都额外含 `portability`：把 `code/`（及 SCP-local）复制到 Wiki 外目录，用绝对 bundle/数据路径重跑代表调用；不依赖知识库工作目录。14 个异目录代表调用 0 FAIL，Python 2 个检查通过。下表只列实际分析与上游等价的范围，不把软件夹具扩大成科学结论。

| 家族 | 分支 | 状态 | 实际范围 |
|---|---|---|---|
| cell-quality-control | SCP RunCellQC | verified | pancreas_sub 80 细胞；UMI/基因数/线粒体阈值；封装=上游 CellQC；输入未变 |
| doublet-detection | SCP RunDoubletCalling (scDblFinder) | not_run | `Missing R dependency: scDblFinder` |
| batch-integration | SCP Seurat_integrate | verified | 120 细胞/2 批/300 HVF/20 PC/k.weight=30；封装=上游 UMAP |
| batch-integration | SCP Harmony_integrate | not_run | `Missing R dependency: harmony` |
| differential-expression | SCP RunDEtest (wilcox) | verified | 全 pancreas_sub，Ductal vs Endocrine；封装=上游 AllMarkers 表 |
| gene-set-enrichment | SCP RunEnrichment ORA | verified | 自定义 TERM2GENE/TERM2NAME；封装=上游结果表；未跑在线 GO/KEGG/GSEA |
| gene-set-scoring | SCP CellScoring (Seurat) | verified | 显式 `name="X"`；封装=上游分数；AUCell/UCell 未运行 |
| trajectory-inference | SCP RunSlingshot | verified | 80 细胞，CellType，UMAP 1:2；封装=上游 Lineage1/BranchID |
| rna-velocity | SCP RunSCVELO | not_run | `Set RETICULATE_PYTHON...`；无 scVelo/scanpy |
| cell-type-annotation | SCP RunSingleR | not_run | `Missing R dependency: SingleR` |
| reference-mapping | Seurat 锚点标签转移 | verified | 300 参考/700 查询；每 query 细胞预测、顺序、anchor 数；不含 UMAP 投影 |
| reference-mapping | SCP RunSeuratMap 投影 | not_run | `Argument 'dim.' must be an integer vector of length two` |
| dimensionality-reduction | SCP RunDimReduction PCA+UMAP | verified | 200 细胞/100 HVF/20 PC；封装=上游 UMAP |
| cell-clustering | 显式 Seurat FindNeighbors/FindClusters | verified | 200 细胞/PCA 1:20/res 0.5；与相同 Seurat 调用逐标签一致 |
| dynamic-feature-analysis | SCP RunDynamicFeatures | verified | 80 细胞 + 显式 fixture pseudotime，Gcg/Krt19；封装=上游 GAM 表；fixture 非真实轨迹 |
| shap-explanation | explain_model | verified | 解析线性模型 SHAP 精确解；输入/模型未变；特征顺序保护 |
| regression-resampling-evaluation | summarize_predictions | verified | 手算指标、常数预测 r 未定义、输入未变、coverage 拒绝 |
| scp-visualization-interface | scp_tables.R adapters | verified | 25 PASS / 0 FAIL；仅表适配，不证明 SCP 绘图等价 |

## 6. 未运行 / 未完成项

- 双细胞检测：scDblFinder 缺失；未安装。
- Harmony 整合：harmony 缺失；未安装。
- RNA velocity：RETICULATE_PYTHON/scVelo/scanpy 缺失；未安装。
- 细胞类型注释：SingleR 缺失；未安装。
- reference-mapping 的 SCP UMAP 投影：Seurat 5.6 下 `dim.` 错误；未通过，保留 not_run。
- 在线 GO/KEGG 注释下载、GSEA、GO simplify：未运行；只验证自定义 TERM2GENE 的 ORA。
- AUCell/UCell 打分、Monocle2/3/PAGA、计数/负二项动态特征分支：未运行。
- 真实 GSE251716/青光眼课题数据、真实模型训练/重采样、真实轨迹/速度/注释：未运行；`pancreas_sub` 只用于软件调用与上游等价检查，不是科学验证。
- 未做真实浏览器截图；用 TestClient + 构建产物检查默认目录/API/代码资产。正式浏览器人工查看留 Codex/作者。
- 未部署五处全局技能、未重启正式服务。

## 7. 需要 Codex 审查的风险

1. **SCP-local loader 兼容补丁**：`SCP_local$Assays` 从 `SeuratObject::GetAssay` 改为 `Seurat::GetAssay`。这是 Seurat 5 命名空间修复，不改统计逻辑；但它是共享复用代码，需确认没有引入其他分支行为变化。`PATCHES.md` 已记录，wrapper 的 bundle 哈希已重新生成。
2. **直接分支 vs upstream wrapper**：`cell-clustering` 的 FindNeighbors/FindClusters 和 `reference-mapping` 的 TransferData 是按 SCP 源码分支显式重写，不是上游同名函数封装。收据 scope 已写明，并分别与相同 Seurat 调用/标签转移输出对照；如审查要求严格的 upstream wrapper 等价，这两项需再包装或降级标记。
3. **reference-mapping 的投影分支**：只验证了标签转移；`RunSeuratMap` 的 UMAP 投影在 Seurat 5.6 下失败，未修。页面明确“不包含投影”，不要把标签转移通过扩大为投影能力。
4. **gene-set-scoring 的 `name="X"`**：这是对 SCP 0.5.6 空 name 列名缺陷的调用参数适配，不是算法修改；输出列名因此为 `X_<set>`。需确认是否接受这种适配方式。
5. **batch-integration 的 `k.weight=30`**：小数据夹具需要；函数默认仍为 100，测试显式传 30。需确认页面/收据没有把它写成通用默认。
6. **code-files API 的 verification 仍显示 unknown**：方法详情的 `implementation_status` 已 verified，但 `/api/methods/.../code-files` 仍从 `code-manifest.json`/无 manifest 推断 unknown。当前是保守显示，不冒充验证；若前端要求代码卡也显示 verified，需要把 implementation receipts 接入 code-assets（本轮未做）。
7. **acceptance 重新记录**：13 个旧 ready 页（含 shap/regression）的 acceptance 因正文/分类变化更新；status 与作者 user 区块未变。需确认 Codex 不把这理解为作者重新签核。
8. **新家族均为 draft**：13 个新家族页尚未由作者确认；默认分析目录可见但 `suggest_methods` 只返回 shap/regression。不要把 draft + verified 误读为“可推荐”。
9. **SCP table count**：旧 `verification.md` 的 20 PASS 已更新为 25 PASS；全库检查后仅 `before/` 备份和历史 `claude-stream.jsonl` 仍保留 20，不作为当前证据。
10. **开发仓库未提交**：前端/后端既有改动 + 本轮改动都在工作树；本报告不能替代 git diff review。

## 8. 复现与审查入口

- 计划/交接：`文档/方法家族与LLM-Wiki改造/{implementation-plan.md,claude-handoff.md}`
- 台账：`维护记录/2026-10-23-方法家族与LLM-Wiki/claude-progress.md`
- 收据：`知识库/methods/*/verification/*.json`
- 迁移对照表：`维护记录/2026-10-23-方法家族与LLM-Wiki/migration-map.md`
- 第一轮审查修复：`维护记录/2026-10-23-方法家族与LLM-Wiki/claude-review-round1-result.md`
- 第二轮审查修复：`维护记录/2026-10-23-方法家族与LLM-Wiki/claude-review-round2-result.md`
- 函数清单：`维护记录/2026-10-23-方法家族与LLM-Wiki/function-inventory.json`
- 测试日志：`E:/research-wiki-env/tmp/{test_scientific_R.log,test_scp_tables.log,test_portability_R.log,test_portability_python.log,pytest-full-2.log,frontend-build.log,wiki-lint-final.log}`
- 迁移脚本：`维护记录/2026-10-23-方法家族与LLM-Wiki/{migrate_method_pages.py,make_receipts.py}`
- 基线对比：`维护记录/2026-10-23-方法家族与LLM-Wiki/before/`、`source-hashes-before.json`
- 知识库提交：`git -C E:/research-wiki/知识库 log --oneline`（含 scaffold、migration、acceptance、rules 提交）
