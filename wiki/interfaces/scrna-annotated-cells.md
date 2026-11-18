---
type: interface
slug: scrna-annotated-cells
title: 已注释单细胞元数据与降维表
columns:
  cell_id:
    type: str
    description: 唯一细胞条形码/标识
    required: true
  sample_id:
    type: str
    description: 样本或供体编号
    required: true
  group:
    type: str
    description: 实验分组或临床表型（如 Control、Disease）
    required: true
  cell_type:
    type: str
    description: 主细胞类型注释标签
    required: true
  subcluster:
    type: str
    description: 亚群或精细状态注释标签
    required: false
  umap_1:
    type: float
    description: UMAP 第一维坐标
    required: true
  umap_2:
    type: float
    description: UMAP 第二维坐标
    required: true
---
# 已注释单细胞元数据与降维表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 唯一细胞条形码/标识 |
| sample_id | str | 必需 | 样本或供体编号 |
| group | str | 必需 | 实验分组或临床表型（如 Control、Disease） |
| cell_type | str | 必需 | 主细胞类型注释标签 |
| subcluster | str | 可选 | 亚群或精细状态注释标签 |
| umap_1 | float | 必需 | UMAP 第一维坐标 |
| umap_2 | float | 必需 | UMAP 第二维坐标 |

- 产出方法：[[methods/batch-integration|单细胞批次整合]] · [[methods/cell-type-annotation|细胞类型注释]]
- 读取方法：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]] · [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]] · [[methods/differential-expression|差异表达分析]] · [[methods/gene-set-scoring|基因集与通路签名打分]] · [[methods/rna-velocity|RNA 速度分析]] · [[methods/trajectory-inference|拟时序与轨迹推断]]
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表一个通过质控与细胞类型注释的单个细胞（cell-level），是单细胞转录组分析中承上启下的核心标准中间表。`cell_id` 必须与 Seurat/SingleCellExperiment 对象中的细胞条形码严格一致；`sample_id` 用于样本级比例统计与伪批量（pseudobulk）聚合，不可缺失或混入分组名；`umap_1`、`umap_2` 必须来自同一次降维嵌入。常见错误是把 cluster 数字编号直接当作 `cell_type`，或在做子集重降维后未同步更新 `umap_1`/`umap_2` 坐标。与 `render-umap-groups` / `render-cell-metadata` 的区别：本接口同时携带样本归属、主细胞类型、亚群标签与 UMAP 坐标，可直接作为下游比例统计、亚群差异分析、通路打分、拟时序与 CellChat 细胞通讯的标准上游契约。

<!-- user:start -->
<!-- user:end -->
