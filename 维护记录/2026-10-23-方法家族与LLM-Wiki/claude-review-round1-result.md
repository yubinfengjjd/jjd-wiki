# Claude 第一轮 Codex 审查修复结果 — 2026-10-23

审查文件：`文档/方法家族与LLM-Wiki改造/codex-review-round1.md`
追加要求：`implementation-plan.md` 的“后续入库技能流程”“来源 panel 存储”、`跨来源去重审查要求.md`
状态：五项已修复；未部署、未安装依赖、未启动子代理、未改 status/user/source 字节。

## 1. 跨来源知识编译（P1）

- 15 个 analysis 家族页全部新增 `## 来源与实现选择` 表（15/15），列出策略/实现、原始来源、输入/目标、本库函数化/验证状态。
- `cell-type-annotation.md` 已重写：
  - 参考标签路线：SCP `RunSingleR`（`scp-singler`，SingleR 缺失，`not_run`）；
  - 青光眼 marker 手工注释：`annotation.R` 的硬编码 marker/`celltype_map`，来源页 [[methods/scrna-marker-annotation]]，未函数化、未验证；
  - 参考图谱映射 Seurat 标签转移：属 [[methods/reference-mapping]]，不混为同算法；
  - “不适用”不再把所有无参考情况排除；明确无参考时只能用有依据的 marker 路线，并保留其主观性/局限。
- `doublet-detection.md` 已重写：
  - scDblFinder 与 DoubletFinder 并列比较（预期率、pK 参数扫描、同型校正、每样本独立）；
  - DoubletFinder 来源为青光眼 `preprocess.R`（7.5% + paramSweep + modelHomotypic），来源页 [[methods/scrna-preprocess-doublet-qc-harmony]]，未函数化、未验证；
  - Scrublet/DoubletDetection/scds 明确未实现；不把不同算法当可互换。
- 其他 13 个家族补齐了青光眼/SCP 来源对照：QC 的 MAD 来源、Harmony 来源、青光眼五种通路分数相加、marker 注释、PCA/UMAP/FindClusters 等；未提炼的代码均明确“未函数化/未验证”，没有新增算法或伪造验证。
- 原始 `source/` 字节未改；旧页 user/status 未改；所有旧页仍可从家族表反向链接追溯。

## 2. 迁移对照表（P1）

新增：`维护记录/2026-10-23-方法家族与LLM-Wiki/migration-map.md`

- 表 1：旧 method 页 → 分类后 `method_kind` → 规范家族 → 具体实现/分支 → 原始来源；覆盖全部 13 个旧页及多家族去向。
- 表 2：15 个规范家族 → 声明分支 → 当前状态 → 原始来源。
- 表 3：同家族多来源处理规则（同算法补来源、异算法加分支、组合流程、技术资料、参数变化、新分析目的）。
- 家族页的“来源与实现选择”表与旧页 banner 形成双向链接；旧页不再保留主 `figure_relations`。

## 3. 八步入库流程与去重（P1）

已同步：

- `知识库/AGENTS.md`：新增“后续入库八步”“跨来源去重要求”“来源 panel 存储”；“收录方法”前明确不得先 scaffold 同义家族。
- `staged/research-wiki/assets/AGENTS.md`：与正式 AGENTS 逐字节同步。
- `staged/research-wiki/SKILL.md`：新增八步清单、跨来源判定、来源 panel 规则、常见错误。
- `references/method-families.md`：重写为八步 + 去重判定 + 来源 panel + frontmatter/收据/家族库存。
- `references/llm-wiki-mode.md`、`knowledge-linking.md`、`code-assets.md`、`project-reuse.md`：同步引用、去重和代码分支状态。

行为测试/夹具：

- `test_second_source_adds_branch_without_creating_another_family`：同一家族两个实现不增加分析家族数；只推荐 verified 分支。
- `test_technical_source_page_cannot_keep_primary_figure_relations`：workflow/technical 页保留主 `figure_relations` 会被 lint 报错。
- `test_code_files_expose_shared_branch_status_without_promoting_originals`：共享入口列出多分支。
- 现有标题重复、technical 不推荐、旧页分类测试继续通过。
- 语义同义性不伪装成自动检查：八步和文档明确要求 agent 人工判断；lint 只做结构/标题/收据/断链/技术页关系检查。

## 4. 详情展示顺序与冗余（P2）

- `PageView`/`MethodOverview`：
  - analysis 详情的“研究问题与用途”在首屏、位于输入对象和实现表之前；
  - 正文 `## 用途` 从渲染正文中移除，只由首屏渲染一次；
  - 有 `data_contract` 时，正文 `## 输入`/`## 输出` 不再重复渲染；完整 Markdown 仍可通过“查看完整 Wiki 记录”打开；
  - technical/workflow 不再套 analysis 的输入/实现/空配图总览，也不渲染分析链，只显示正文与资料类型提示。
- 测试使用真实 API fixture `frontend/tests/real-pages.ts`（从真实 Wiki API 生成）：
  - 真实 `cell-quality-control`：用途只一次且在首屏，data_contract 只一次；
  - 真实 `scp-cellqc-doublet`（technical）：无分析实现表/空配图/首屏用途总览；
  - 真实 `batch-integration`：两个分支各自状态不被合并。

## 5. 代码查看器与实现状态（P2）

- `rwiki.code_assets.code_files` 从同一 `implementation_status` 按入口文件派生逐文件 `branches`：
  - 共享入口文件列出全部分支（如 `batch-integration/code/analysis.R`：verified + not_run，整体 `mixed`）；
  - 每个分支带自己的 scope 和 receipt；
  - 原始版不提升，仍按来源清单状态（如 gallery original、`shap_explain.py` 的 not_run）；
  - 没有 receipt 的分支保持 `not_run`，不因代码存在而显示 verified。
- `CodeFile` 类型、`CodeViewer` 增加“实现分支”区块；新增 `CodeBranchList` SSR 测试。
- API 测试同时覆盖 `/api/methods/analysis/code-files` 的 shared `branches` 和 `mixed`。

## 6. 本轮实际重跑

| 测试 | 结果 |
|---|---|
| 定向后端：`test_method_implementations.py test_code_assets.py test_lint.py` | `103 passed, 2 skipped` |
| 全套后端 `pytest -q`（修复后） | `435 passed, 2 skipped` |
| 前端 `npm test` | 30 figure checks + 9 method checks 通过 |
| 前端 `npm run typecheck` | 通过 |
| 前端 `npm run build` | 通过 |
| 正式库 `wiki.py lint` | `OK`；仅 5 条预期 not_run WARN |
| 真实 API fixture SSR | 3 个真实页面通过上述顺序/技术页断言 |
| 源码哈希/旧 user/status/旧页主关系检查 | 全部通过 |

未重跑 R 分析调用：本轮没有改任何 analysis code、receipt、数据或算法；R 收据仍是上一轮实际调用与异目录复制的结果。未使用 Codex 的 `review-pytest.log` 作为本轮证据；本报告只列 Claude 自己修复后的命令与结果。

## 7. 科学范围未改

- 没有新增/替换统计算法、阈值、估计量或验证设计。
- 没有安装 harmony、SingleR、scDblFinder、DoubletFinder、scVelo、scanpy/anndata。
- 没有把 not_run 分支改成 verified；没有改作者 status、user 区块、原始 source/original_code 字节。
- 新增内容只是跨来源策略对照、来源链接、迁移表、展示顺序、代码分支状态和流程规则。
- 仍未运行：DoubletFinder、SingleR、scVelo、Harmony、在线 GO/KEGG/GSEA、Monocle/PAGA、真实课题数据和真实模型训练。

## 8. 仍需 Codex 审查

1. 八步流程已写入规则并有结构测试，但“语义同义性”仍是人工判断；请检查是否满足“不只写不重复标题”的交付标准。
2. `code-files` 的 `branches` 只按入口文件归属；共享 helper 文件没有独立入口时不会列出分支。当前资产没有这种 helper；若要求按 receipt 覆盖文件列出所有分支，需要另定归属规则，避免把每个文件都列成所有分支。
3. technical/workflow 详情不再显示分析实现/空配图总览；请确认这是期望的极简程度。
4. `shap_explain.py`、gallery 原始代码仍按来源清单显示 not_run；没有因 `explain_model.py` verified 而提升。
5. 本轮未部署五处全局技能、未重启正式服务；开发仓库保持未提交工作树。
