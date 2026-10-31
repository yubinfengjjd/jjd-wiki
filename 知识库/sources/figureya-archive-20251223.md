---
type: source
id: figureya-archive-20251223
title: 压缩包可视化模块增量来源
url: https://github.com/ying-ge/FigureYa
commit: 3c99b485b37db10e66b21fbc26387f106f14c6ad
license: CC-BY-NC-SA-4.0
license_notice: 本机压缩包导入；commit 为本地导入快照，不是上游提交。完整原始包及各文件哈希见本页。CC BY-NC-SA 4.0：非商业、署名与相同方式共享；源码不进
  Wiki Git。
cite:
- 'Lu X, et al. (2025). FigureYa. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
adapter: figureya
trusted: true
snapshot: figureya-archive-20251223
tags: []
keywords:
- FigureYa
- 压缩包
- 可视化
- 模块清单
- 版本差异
- 本地导入
summary: 本地压缩包330项盘点：286项复用旧入口，33项新增或差异Rmd，10项多语言工具，1项贡献模板。
---
# 压缩包可视化模块增量来源

<!-- facts:start -->
- 上游：https://github.com/ying-ge/FigureYa · commit `3c99b485b37d`
- 许可证：CC-BY-NC-SA-4.0；白名单：是（按需获取不再询问）
- 适配器：figureya；快照：`<sources_root>/figureya-archive-20251223`（不进 Wiki）
- L0 目录：33 项（`sources/figureya-archive-20251223/items.jsonl`）；自动领域分布：survival-analysis 24、transcriptomics 18、machine-learning 16、diagnostic-roc 11、multi-omics 5、single-cell 3、experimental-statistics 2
- L1 配方：0 个
<!-- facts:end -->

## 这是什么

2026-10-31 收录作者提供的 `FigureYa-compressed-main.zip`。330 个模块包全部解包并计算逐文件 SHA-256；上游包内 `.last_run` 为 `2025-12-23T15:16:41Z`，`.last_source_commit` 声称为 `86f947d23467f1f63f2642db3bf6e80de765a54a`。这个声明未被当成压缩包内容与上游 Git 树逐字节一致的证明。

- 原始压缩包 SHA-256：`df3f31a321dd581adec92394430205a88bbaff9466c321942136d9086feec01a`。
- 全量只读原始层：`<sources_root>/figureya-compressed-20251223-raw`；保留所有模块原字节、Notebook、网页、示例数据和参考图。
- 增量快照：`<sources_root>/figureya-archive-20251223`；只收 33 个新增/主 Rmd 有差异的模块，以及 10 个非 Rmd 工具和贡献模板。Git 导入时关闭换行转换。
- 本页 facts 的 commit 是**本地导入提交**，不是上游 commit；`IMPORT-PROVENANCE.json` 同时记录原包声明与逐文件哈希。
- 完整对应表与哈希：`sources/figureya-archive-20251223/ingestion-manifest.json`（330 项）。

## 怎么用

先用 `rwiki find <研究场景或图型>`，再 `rwiki show <id>`。已有 [[sources/figureya|FigureYa 来源]] 中的条目及配方保留原 id、源码、状态和收据。

- 286 个模块：仅主 Rmd 在 CRLF 转 LF 后与既有模块文本相同，因此复用旧检索入口；**不宣称依赖、输入数据和全目录字节相同**。原始压缩包版本仍完整保留。
- 33 个模块：本来源新增 L0 目录项。`rwiki show figureya-archive-20251223:<模块名>` 查看；`rwiki use figureya-archive-20251223:<模块名> --project <课题目录>` 复制本版本。没有本版本运行收据，不继承其他版本的 pass 或 ready。
- 10 个非 Rmd 工具：见 [[methods/figureya-multilanguage-assets|交互绘图与多语言工具索引]]；当前适配器只支持 Rmd，这些工具仅作来源与输入说明登记，不能交给 `rwiki run`。
- 1 个贡献模板：`FigureYa000ContributionTemplate`，仅贡献说明，不计作可视化工具。

本地导入提交不存在于远端 Git。异机恢复需要先取回同 SHA-256 的原包，按本清单恢复本地快照并核验；不要用远端最新版本替代后仍沿用这里的提交或收据。当前机器的快照已物化，L0 的 show/use 可直接使用（已抽查 `FigureYa6rHRs` 的 show 与 use，未执行模块）。

CLI 的来源链接有已知限制：`show` 会把本地导入 commit 拼进 GitHub `/tree/<commit>/...`，这个合成地址不在远端存在，不能用来查上游。查来源请用 [包内声明的上游版本](https://github.com/ying-ge/FigureYa/tree/86f947d23467f1f63f2642db3bf6e80de765a54a) 与本页哈希清单；本地快照才是本次收录字节的依据。同名模块的不同版本还可能派生出已有配方的相同 id，不能直接批量 `promote` 覆盖旧配方；后续升级需另行制定版本标识方案。本次仅登记 L0 与技术笔记，不做配方升级。

## 许可与引用

沿用对应上游提交的 [CC BY-NC-SA 4.0 许可证](https://raw.githubusercontent.com/ying-ge/FigureYa/86f947d23467f1f63f2642db3bf6e80de765a54a/LICENSE)，许可证原字节和哈希保存在增量快照。保留模块原作者、审阅者与来源文献；使用时署名并引用 FigureYa，非商业与相同方式共享条件继续适用。源码、Notebook、HTML 工具及来源图留在 Wiki 之外的原始层，不进入 Wiki Git。

引用：Lu X, et al. (2025). FigureYa. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005。

## 知识关联检查

已对照 [[sources/figureya|既有 FigureYa 来源]] 的 313 项和 30 个配方；本次没有修改这些配方的原始层或验收记录，不创建批量 L2 模板，不从模块名称推断新的分析家族。源 Rmd 与示例图的存在不证明本机运行成功或科学有效。本次无装包、无模块执行、无 ready 签核。

多语言模块的输入与调用边界由 [[methods/figureya-multilanguage-assets|技术索引]] 说明；同画法优先复用既有入口，Python、Shiny 和浏览器版是不同调用实现，未认定与 R 配方等价。

### 新增或主 Rmd 有差异的版本

| 压缩包模块 | 对应的既有入口 | 本次处理 |
|---|---|---|
| `FigureYa111markerGene` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa128Prognostic` | `figureya:FigureYa128Prognostic` | 新增本包版本 L0，未运行 |
| `FigureYa130coxSVM` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa138NiceCalibration` | `figureya:FigureYa138NiceCalibration` | 新增本包版本 L0，未运行 |
| `FigureYa141risk` | `figureya:FigureYa141risk` | 新增本包版本 L0，未运行 |
| `FigureYa143survCor` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa177RNAvelocity` | `figureya:FigureYa177RNAvelocity` | 新增本包版本 L0，未运行 |
| `FigureYa184ranger` | `figureya:FigureYa184ranger` | 新增本包版本 L0，未运行 |
| `FigureYa187RMS` | `figureya:FigureYa187RMS` | 新增本包版本 L0，未运行 |
| `FigureYa193RiskTable` | `figureya:FigureYa193RiskTable` | 新增本包版本 L0，未运行 |
| `FigureYa200pairwiseAUC` | `figureya:FigureYa200pairwiseAUC` | 新增本包版本 L0，未运行 |
| `FigureYa210survivalScape` | `figureya:FigureYa210survivalScape` | 新增本包版本 L0，未运行 |
| `FigureYa218Elasticnet` | `figureya:FigureYa218Elasticnet` | 新增本包版本 L0，未运行 |
| `FigureYa220repeatedLasso` | `figureya:FigureYa220repeatedLasso` | 新增本包版本 L0，未运行 |
| `FigureYa226scRNA_cNMF` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa245VarDecompose` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa24ROC` | `figureya:FigureYa24ROC` | 新增本包版本 L0，未运行 |
| `FigureYa250ImmGenePair` | `figureya:FigureYa250ImmGenePair` | 新增本包版本 L0，未运行 |
| `FigureYa293machineLearning` | `figureya:FigureYa293machineLearning` | 新增本包版本 L0，未运行 |
| `FigureYa30nomogram_update` | `figureya:FigureYa30nomogram_update` | 新增本包版本 L0，未运行 |
| `FigureYa316RF_XGBoost_Boruta` | `figureya:FigureYa316RF_XGBoost_Boruta` | 新增本包版本 L0，未运行 |
| `FigureYa31lasso_update` | `figureya:FigureYa31lasso_update` | 新增本包版本 L0，未运行 |
| `FigureYa33DCA_update` | `figureya:FigureYa33DCA_update` | 新增本包版本 L0，未运行 |
| `FigureYa47HRtable` | `figureya:FigureYa47HRtable` | 新增本包版本 L0，未运行 |
| `FigureYa65SVM` | `figureya:FigureYa65SVM` | 新增本包版本 L0，未运行 |
| `FigureYa66单因素cox` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa69cancerSubtype` | `figureya:FigureYa69cancerSubtype` | 新增本包版本 L0，未运行 |
| `FigureYa6rHRs` | 无同名项 | 新增本包版本 L0，未运行 |
| `FigureYa6rHRsV2` | `figureya:FigureYa6rHRsV2` | 新增本包版本 L0，未运行 |
| `FigureYa85timeROC` | `figureya:FigureYa85timeROC` | 新增本包版本 L0，未运行 |
| `FigureYa88DAVIDkappa` | `figureya:FigureYa88DAVIDkappa` | 新增本包版本 L0，未运行 |
| `FigureYa90subgroup` | `figureya:FigureYa90subgroup` | 新增本包版本 L0，未运行 |
| `FigureYa99smoothHRv2` | `figureya:FigureYa99smoothHRv2` | 新增本包版本 L0，未运行 |

<!-- user:start -->
<!-- user:end -->
