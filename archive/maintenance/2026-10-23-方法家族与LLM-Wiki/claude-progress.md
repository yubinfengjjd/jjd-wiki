# Claude 实施台账 — 2026-10-23 方法家族与 LLM-Wiki

Plan: 文档/方法家族与LLM-Wiki改造/implementation-plan.md
Baseline dev: 2bbe879（保留原 dirty tree；未 reset/clean/提交）
Baseline wiki: 6841992

## 计划外的流程决定

- Ruling: 不建 worktree、不提交开发仓库 — handoff 明确要求保留可审查工作树并禁止覆盖未提交工作 — 代价：无法用提交边界做最终 diff，只能依赖 baseline 与 git diff。
- Ruling: 旧测试按新契约修夹具，不放宽门槛 — 计划要求 analysis + ready + 完整笔记 + 当前 verified 实现才可推荐；文字笔记确认后仍不推荐 — 代价：旧测试语义从“文字笔记可推荐”改为“可确认但不可执行”。
- Ruling: 修 R loader 的 `Assays(object, assay)` shim 为 `Seurat::GetAssay` — `GetAssay` 不在 SeuratObject 命名空间，Seurat 5.6 下 DE 等分支报错；仅命名空间兼容，不改统计逻辑 — 代价：共享 SCP-local 复用文件哈希变化，需重新生成 wrapper 哈希。
- Ruling: `reference-mapping` 只把 Seurat 锚点标签转移标 verified，SCP `RunSeuratMap` 的 UMAP 投影分支保留 not_run — 实际报 `Argument 'dim.' must be an integer vector of length two`；不把标签转移通过扩大成投影通过 — 代价：参考图谱投影仍不可用。
- Ruling: `cell-clustering` 用显式 FindNeighbors/FindClusters 分支，不冒充独立 SCP 函数封装 — SCP 没有独立聚类入口，代码来自 Standard_SCP 的同一分支并逐标签对照 — 代价：不是 upstream wrapper 等价，收据 scope 已写明。
- Ruling: `gene-set-scoring` 调用显式 `name="X"` — SCP 0.5.6 空 name 与 Seurat 5 列名不匹配；只改调用参数，不改打分算法 — 代价：输出列名为 `X_<set>`。
- Ruling: 13 个新家族保持 `status: draft`，不代作者确认 — handoff 明确禁止伪造科学签核 — 代价：默认分析目录可见但需作者确认后才进入推荐。
- Ruling: 重新运行 `check-entry --record` 只更新 agent 验收指纹，不改 status — 旧页正文/分类变化使 acceptance stale；作者确认事实保留。

## 完成情况

- 后端：27 个方法门槛测试通过；全套 432 passed / 2 skipped。
- 前端：30 figure checks + 4 SSR method checks；typecheck；build。
- R 实际调用：32 PASS；5 个预期 not_run（scDblFinder、harmony、RETICULATE_PYTHON/scVelo、SingleR、RunSeuratMap dim. 错误）。
- 异目录复制：14 PASS / 0 FAIL；Python 2 PASS；passed 收据均含 `portability`。
- SCP 表适配：25 PASS / 0 FAIL。
- Python：SHAP 解析线性模型 + 回归指标 2 PASS。
- 正式库 lint：OK；仅 5 条预期 not_run WARN。
- 源码 SHA256：baseline 全部一致；旧页 user 区块与 status 全部未变；旧 id 未变。
- 15 个 analysis 家族（12 个至少一个 verified，3 个仅 not_run）；2 个 workflow；9 个 technical；无待分类；无重复标题。
- 旧 `figure_relations` 已迁往家族，旧 technical/workflow 页不再保留主记录。
- 规则：正式 AGENTS、staged/assets/AGENTS、SKILL、references 已同步 Karpathy 模式与方法家族/收据契约。
- 未部署五处全局技能、未重启正式服务、未安装任何依赖、未提交开发仓库。

## 第一轮 Codex 审查修复（2026-10-23）

- 15 家族补“来源与实现选择”表；cell-type 补 marker 手工注释，doublet 补 DoubletFinder 对照。
- 新增 `migration-map.md`；八步入库/去重/来源 panel 规则同步 AGENTS、assets AGENTS、SKILL、references。
- analysis 详情用途首屏、输入输出只一次；technical/workflow 不套分析总览；真实 API fixture SSR。
- `code-files` 按入口文件派生分支状态；共享文件列全部分支；原始版不提升。
- 修复后：定向后端 103 passed；全套 435 passed；前端 30+9、typecheck、build；lint OK。
- 未改 analysis code/receipt/status/user/source；R 调用未重跑；未部署。

## 第二轮 Codex 审查修复（2026-10-23）

- 面包屑/反向链接/知识网络节点按 method_kind 显示；通用 method 标签改为“方法页”；真实 source/workflow SSR 断言。
- 11 个旧 technical/workflow 页的旧环境/验证断言标为 2026-10-22 历史，并链接 2026-10-23 规范家族 verified/not_run；保留历史与 source/user/status。
- 重跑前端 30+10、typecheck、build；正式库 lint OK；源码/user/status 完整性通过。
- 未改算法/receipt；未重跑后端/R；未安装/部署/子代理。
