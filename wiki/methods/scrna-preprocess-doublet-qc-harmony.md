---
type: method
id: scrna-preprocess-doublet-qc-harmony
title: 单细胞预处理、批次校正与聚类
status: ready
tags:
- 单细胞分析
inputs: []
outputs: []
source:
  kind: project
  path: E:\青光眼单细胞\preprocess.R
license: none
cite: []
favorite: false
keywords:
- GSE251716
- Seurat
- DoubletFinder
- Harmony
- 聚类
- 质量控制
- 单细胞
method_kind: workflow
summary: 青光眼课题的预处理、QC、双细胞与 Harmony 组合流程记录；单步方法见对应家族。
data_contract:
  input: GSE251716 原始计数和样本元数据；流程参数在 source/ 中。
  output: 预处理 Seurat 对象、UMAP/cluster 和作者流程结果；本页不重新运行。
---
# 单细胞预处理、批次校正与聚类

<!-- facts:start -->
- 来源：E:\青光眼单细胞\preprocess.R
- 许可证：仅供个人研究参考
- 引用：无
- 标签：单细胞分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：组合流程，不是默认分析家族。**
> 当前分析问题见：[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

从 10x Genomics 矩阵开始，完成双细胞去除、样本合并、QC、标准化、高变基因、PCA、Harmony 批次校正、UMAP 与多分辨率聚类，产出可用于注释和下游分析的 Seurat 对象与嵌入坐标。适用于同一组织、少量样本的探索性 scRNA-seq 分析，不绑定青光眼或小鼠。

## 原始实现与家族范围

来源是作者课题脚本 `preprocess.R`，具体实现为 Seurat v5 + DoubletFinder + harmony + clustree + ggunchull。家族限定为“基于 Seurat 的单细胞预处理与聚类”；Scanpy 等等价实现不在本页代码范围内。DoubletFinder 的 7.5% 预期双细胞率、MAD 3× QC、8 个聚类分辨率都是本数据的设定，换组织或换建库方式必须重新检查，不能当通用最优参数。

## 适用

- 每个样本有 `barcodes.tsv.gz`、`features.tsv.gz`、`matrix.mtx.gz`，或 Read10X 可读的等价矩阵。
- 样本数少、批次可用样本 ID 表示；需要 UMAP + 聚类的探索性分析。
- 需要保留原始 counts、样本/条件元数据和 QC 指标，便于后续注释、比例和通路分析。
- 需要检查双细胞、批次混合和聚类分辨率稳定性。

## 不适用

- 不适用于空间转录组、单核多组学、配对/纵向设计或需要去卷积的数据；这些需要额外方法。
- 不能把 7.5% 双细胞率当成所有组织的真值；不同组织、不同上机量的双细胞率不同。
- 不能用 MAD 阈值替代人工检查；QC 阈值会改变细胞数和下游聚类。
- 不能用 UMAP 外观或聚类分辨率证明生物亚群存在；需要 marker 和统计支持。
- 2026-10-22 历史记录：当时 R 4.3.1 的 Seurat 因 Matrix 版本冲突无法加载，本页不声称脚本已重跑通过。2026-10-23 当前 Seurat 5.6.0 可加载，但 `preprocess.R` 仍未函数化/重跑；DoubletFinder/harmony 仍缺。规范家族状态见 [[methods/cell-quality-control]]、[[methods/doublet-detection]]、[[methods/batch-integration]] 等。

## 输入

- 每个样本一个目录，含 10x 三件套；一行代表一个细胞（barcode），一列代表一个基因，counts 为非负整数。
- 样本 ID 与分组映射（本脚本用 `orig.ident` 中的 GSM 编号判断 Control/Glaucoma）。
- 需要记录物种、组织、建库版本、基因符号大小写；小鼠线粒体基因用 `^mt-`，核糖体用 `^Rp[sl]`，血红蛋白用 `^Hb[^(p)]`。
- 需要说明是否已有生物学重复；只有 1 个样本/组时，后续组间比较不能做样本级推断。

## 怎么做

1. 每个样本单独 Read10X/CreateSeuratObject（本脚本 `min.cells=5`、`min.features=300`），先不要合并。
2. 每个样本独立跑 DoubletFinder：Normalize/HVG/PCA/FindNeighbors/FindClusters/UMAP → `paramSweep` → 最优 pK → 7.5% 预期双细胞率 × 同型比例 → `doubletFinder` → 只保留 Singlet。双细胞必须在样本内独立判断，不能合并后跑；pK 和预期比例要按数据检查。
3. 合并样本（`merge`，`add.cell.ids`）；Seurat v5 用 `JoinLayers` 合并 layers。
4. QC：计算 `percent.mt`、`percent.rp`、`percent.hb`；用 median ± 3×MAD 计算 nFeature 上下界，percent.mt/percent.hb 上界；nFeature 下限至少 200；MAD=0 时跳过该指标。原脚本只过滤 nFeature、percent.mt、percent.hb，percent.rp 只计算不过滤。
5. `NormalizeData` → `FindVariableFeatures(vst, 2000)` → `ScaleData` → `RunPCA(50 PCs)` → `RunHarmony(group.by.vars="orig.ident")`。
6. `FindNeighbors(reduction="harmony", dims=1:30)` → `RunUMAP`；在 0.05–1.2 共 8 个分辨率上 `FindClusters`；用 clustree 检查分辨率稳定性。
7. 导出 UMAP 坐标、聚类标签、样本/条件、QC 指标；保存 Seurat 对象。
8. 必要诊断：双细胞比例、QC 前后细胞数、Harmony 前后样本混合、聚类分辨率是否稳定、每个 cluster 的最小细胞数。诊断图是流程的一部分，不是可选美图。

## 代码

- `source/preprocess.R` 为原字节归档，未修改。依赖 Seurat、DoubletFinder、harmony、clustree、ggunchull、ggplot2、dplyr、patchwork、cowplot、RColorBrewer。
- 原脚本含 `setwd`、`unlink("./GSE251716_RAW")`、`file.rename` 等路径和文件操作；复用时应复制到课题目录并显式设置输入/输出，不要直接运行原脚本覆盖数据。
- 验证状态：2026-10-22 记录 R 4.3.1 的 Matrix 1.5-4.1 低于 SeuratObject 要求，Seurat/SCP 无法加载，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但脚本未函数化/重跑，DoubletFinder/harmony 缺失；只归档原脚本，不声称已在当前机器验证。见规范家族收据。
- 没有把流程包装成公共函数；它依赖 Seurat 对象、样本循环和真实矩阵，未验证的封装不写入知识库。

## 输出

- `GSE251716_seurat.Rdata`：含 counts、样本、QC、PCA/harmony/UMAP、8 个分辨率聚类。
- 课题内可导出为下游表（不是原脚本自动写出的 CSV）：
  - `umap-coordinates.csv`：`cell_id, umap_1, umap_2`，供 UMAP 类图使用。
  - `cell-metadata.csv`：`cell_id, sample, condition, cluster, celltype, nFeature_RNA, nCount_RNA, percent_mt`。
  - `feature-long.csv`：`cell_id, feature, value`，供 marker 特征图使用。
- 导出时保持 `cell_id` 一致；不要在导出阶段重新聚类或改标签。

## 知识关联检查

2026-10-23 分类为组合流程：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页，归档原脚本；作者已确认方法页。fig01/fig02 模板已建并用合成示例回放，待作者确认模板。

<!-- user:start -->
<!-- user:end -->
