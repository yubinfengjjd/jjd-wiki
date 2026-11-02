---
type: method
id: uc-spatial-workflows
title: 空间转录组分支与推断边界
status: draft
tags:
- single-cell
- transcriptomics
- multi-omics
inputs: []
outputs: []
source:
  kind: written
license: LicenseRef-Project-Unresolved
cite:
- 作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256
  账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
favorite: false
method_kind: workflow
summary: 区分原空间探索、整理版主线、历史 CellTrek/伪超分辨与 RCTD+CellChat 最终来源及其后处理，保留算法替代的真实含义。
keywords:
- UC-20种修饰
- 空间转录组
- RCTD
- spacexr
- CellChat
- BayesSpace
- CellTrek
- pseudo-superres
- Moran
- SPARK-X
- cell2location
- UBE2L6
- '9.20'
- '9.25'
data_contract:
  input: 来源脚本、静态调用、对象/表结构与来源版本；数据和图片留在课题目录。
  output: 来源去重、规范方法映射、依赖绘图/自定义实现与工作流导航；不提供已验证可执行实现。
---
# 空间转录组分支与推断边界

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：LicenseRef-Project-Unresolved
- 引用：作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256 账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
- 标签：single-cell、transcriptomics、multi-omics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

UC 空间来源的分支导航，避免将结果打包目录、旧 branch 与最终保留的 RCTD 通信版本混合计为新方法。

## 适用

判断某个空间图读的是 spot、RCTD 权重、CellTrek 投影还是 CellChat 对象；选择后续实际验证入口。

## 不适用

本批仅完成来源归档与知识编译；执行状态为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 来源 README 称“final/complete”只记录来源整理决定，不证明当前可运行或科学有效。README 所指外部工作树不在本次指定目录，未擅自读取或认定当前存在。

## 输入

空间 Seurat/计数/切片图像/坐标与样本键；RCTD 还需单细胞参考计数、细胞类型与基因对应；BayesSpace 域、邻域与 Moran’s I 依赖各自图/距离/坐标；CellChat 需要其模型输入与分组。spot 不等于一个细胞，反卷积权重不等于实测细胞位置。

## 怎么做

按来源分层选择：

| 分支 | 来源路径（UC 根下） | 处理 |
|---|---|---|
| 原目录探索 | `20.空间转录组/`、`scripts/Phase*` | 记录各脚本实际算法与可选分支，不按脚本名替代事实 |
| 整理版主线 | `整理_1-20_code_pdf/20.sptial/01_main_workflow_from_raw/` | 0 visual spec→1 QC→2 preprocess/reference→3 RCTD→4 SVG→5 BayesSpace→6 UBE2L6→7 neighborhood→8 PTM→10 paper-ready→11 audit |
| 旧分支 | `20.sptial/02_legacy_celltrek_superres_branch/` | CellTrek 或 pseudo-superres fallback，仅历史来源；不混入保留的 RCTD 主线 |
| RCTD 通信 | `20.sptial/03_rctd_cellchat_branch/9.20_cellchat_rctd_spot_final/` | 来源 README 记录的最终保留分支；9.20 主对象，9.21–9.25 为增强/分层/上皮展示变体 |

路径简写 `20.sptial/` 均指 UC 整理目录下，原版和整理版分别保存 SHA-256。

## 容易误认的算法与验证

`Phase1_3_sparkx.R` 第 37–39 行构邻接，第 49 行 `spdep::moran.test`，68 行 BH 校正；这是 Moran’s I 替代探索，不是执行 SPARK-X。`Phase2_3_cell2location_validation.R` 只在探测可导入后写出候选 Python 脚本；否则对已有 RCTD 权重做相关/PCA，不能记为 cell2location 完成或独立验证。该候选 Python 内容也未经执行或 API 核验。

`Phase1_1_data_preparation.py` 等扩展名为 Python 的文件必须按实际内容解析；语法失败不当成已实现 Python 后端。legacy 的 pseudo-superres 显示/构造不等于真实单细胞坐标。原有组织图、打包表和 CSV 文件名不能证明以上算法已经运行。

## 绘图与计算分层

Seurat SpatialFeaturePlot/SpatialDimPlot、CellChat netVisual/netAnalysis 属依赖直接绘图；plot_helpers、workflow_helpers 与 9.2x 自定义后处理记录为技术适配。若绘图层重算聚合、差值、关联或检验，不能仅称换颜色。多个 step 带同字节 helper 时共享来源对象；不同 helper 版本各保留，不批量合并为一个闭包。

## 代码

整理 README.md 与 README_20260310_ORGANIZED.md 保存在外部快照元数据（相对路径与 SHA-256），记录 RCTD+CellChat 保留决定、旧 CellTrek 分支和“整理包只是导航副本”的说明。没有把来源 README 的复现承诺改写为本库验证；未执行 install/check/PrepareEnv 或分析脚本。

## 输出

空间分支/对象/算法边界的知识导航，不输出空间推断或新通信图；本页 workflow，未新增 analysis 或 template。

## 知识关联检查

来源见 [[methods/uc-ptm-source-catalog]]；方法选择见 [[methods/local-omics-analysis-guide]]；图形分流见 [[methods/local-omics-visualization-guide]]。可对照 [[methods/scop-analysis-guide]] / [[methods/scop-visualization-guide]] 的相关候选，但 scop 与本项目/SCP 不继承接口和运行证据。

## 使用记录

2026-11-02：读取指定目录内代码与整理说明，编译分支与替代分析边界；未改原始材料、未安装或运行。

<!-- user:start -->
<!-- user:end -->
