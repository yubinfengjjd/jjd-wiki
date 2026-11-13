# Claude 第二轮 Codex 审查修复结果 — 2026-10-23

审查文件：`文档/方法家族与LLM-Wiki改造/codex-review-round2.md`
范围：只修两类遗留（资料类型标注、历史环境断言）；未安装、未部署、未启动子代理、未改算法。
状态：两类修复完成；前端 30+10 检查、typecheck、build 通过；正式库 lint OK。

## 1. 资料类型不再被标成“分析方法”（P2）

- `api.ts`：`TYPE_LABEL.method` 从“分析方法”改为中性的“方法页”；存储类型不再冒充分析家族。
- 新增 `methods.ts:pageTypeLabel(meta, fallback)`：
  - `analysis` → “分析家族”
  - `workflow` → “组合流程”
  - `technical` → “技术资料”
  - 无 `method_kind` → “待分类”
- `PageView`：
  - 面包屑改用 `pageTypeLabel(meta)`；SCP 源码本地化页显示“方法库 / 技术资料”，标准流程页显示“方法库 / 组合流程”。
  - 反向链接 tooltip 按目标页的 `method_kind` 取标签；找不到目标 meta 时回退“方法页”，不再写“分析方法”。
  - 旧路由、id、页面链接不变。
- `GraphView`：
  - 悬停卡和节点面板使用目标页 `method_kind` 显示“分析家族/组合流程/技术资料/待分类”；
  - 页面类型筛选仍按存储类型 `method`，标签改为“方法页”，不改变图谱拓扑、节点或边。
- 测试：新增真实 API 页面 SSR 断言，覆盖 `scp-cellqc-doublet`（technical）与 `scp-standard-workflow`（workflow）的面包屑，以及真实 `cell-quality-control` 页反向链接 tooltip 的“技术资料/组合流程”；断言不出现“分析方法”。

## 2. 历史环境断言不再冒充当前事实（P2）

检查并修改 11 个旧 technical/workflow 页：

`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-integration`、`scp-local-source`、`scp-standard-workflow`、`scp-trajectory-velocity`、`scp-visualization-interface`、`scrna-marker-annotation`、`scrna-pathway-signature-ensemble`、`scrna-preprocess-doublet-qc-harmony`。

处理方式：

- 把“本轮未安装/未运行”“当前 R 环境 Seurat 加载失败（Matrix 冲突）”“当前环境未安装”等改为明确的 **2026-10-22 历史记录**，保留当时观察，不删除历史。
- 在每处补 **2026-10-23 当前规范家族范围**和链接：
  - QC 阈值 `verified`；scDblFinder/DoubletFinder/SeuratMap 投影等仍 `not_run` 或未函数化；
  - DE、ORA、Seurat 打分、Gaussian 动态特征、Seurat_integrate、Slingshot、PCA/UMAP、FindClusters 等有 verified 收据；
  - Harmony、SingleR、scVelo、Monocle/PAGA、在线 GO/KEGG/GSEA、AUCell/UCell 等未运行；
  - 青光眼 marker 手工注释、DoubletFinder、五种分数相加、preprocess 等仍未函数化/未验证。
- `scp-local-source`：把 61 PASS 标为 2026-10-22 记录、2026-10-23 未重跑；把“RunDEtest 等未全部跑通”改为“2026-10-23 规范家族补验 DE/Slingshot/Seurat_integrate 等通过，RunSeuratMap 投影/部分富集/轨迹/速度仍 not_run”。
- `scp-visualization-interface`：把旧全家族视觉等价的限制标为 2026-10-22 记录；2026-10-23 表适配层 25 PASS，SCP 绘图全家族视觉等价仍未验证。
- 没有扩大为“所有算法已运行”；没有改 source/original_code 字节、user 区块、status、算法或科学结论。
- 11 页正文变化后重新 `save`，并对 11 个 ready 页重新 `check-entry --record` 记录验收指纹；作者状态未改。

## 3. 本轮实际重跑

| 检查 | 结果 |
|---|---|
| 前端 `npm test` | 30 figure checks + 10 method checks 通过 |
| 前端 `npm run typecheck` | 通过 |
| 前端 `npm run build` | 通过 |
| 正式库 `wiki.py lint` | `OK`；仅 5 条预期 not_run WARN |
| 源码 SHA256 / 旧页 user / status | 全部未变 |
| 真实 source/workflow SSR | 面包屑与反向链接标签断言通过 |

未重跑后端 pytest / R 分析：本轮没有改后端分析代码、receipt、数据或算法；上一轮修复后的 435 项后端与 R 收据仍有效。未使用 Codex 正在进行中的独立测试日志作为本轮证据。

## 4. 未改与未做

- 未改图谱拓扑、节点/边、旧路由或 id。
- 未改作者 status、user 区块、原始 source/original_code 字节。
- 未安装任何依赖；未部署五处技能；未重启正式服务；未启动子代理。
- 历史页仍保留旧观察原文，只是加上日期、当前范围、家族链接和 not_run/verified 边界。
- 仍缺：DoubletFinder、SingleR、Harmony、scVelo/scanpy、在线 GO/KEGG/GSEA、Monocle/PAGA 等分支未运行；不因正文标注而升级。

## 5. 仍需 Codex 审查

1. 面包屑/反向链接/图谱节点已按 `method_kind` 显示；图谱“页面类型”筛选仍以存储类型 `method` 聚合，标签为“方法页”，不改拓扑。请确认这个粒度符合要求。
2. 历史页中保留的 2026-10-22 观察仍可能提到旧 R 4.3.1/Matrix 环境；均已标明历史，并与当前家族证据并列。请确认没有把历史记录误读为当前阻塞。
3. 11 个旧页 acceptance 已重新记录，但 status 未改；这是验收指纹更新，不是作者重新签核。
