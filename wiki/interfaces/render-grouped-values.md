---
type: interface
slug: render-grouped-values
title: 分组细胞级数值表
columns:
  celltype:
    type: str
    description: 细胞类型或类别；x 轴
  group:
    type: str
    description: 比较组；用于小提琴/箱线/散点分组
  value:
    type: float
    description: 细胞级或样本级数值；采样单位由课题说明
---
# 分组细胞级数值表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| celltype | str | 必需 | 细胞类型或类别；x 轴 |
| group | str | 必需 | 比较组；用于小提琴/箱线/散点分组 |
| value | float | 必需 | 细胞级或样本级数值；采样单位由课题说明 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/cell-quality-control|单细胞质量控制]]（adaptable） · [[methods/dynamic-feature-analysis|拟时序动态特征分析]]（adaptable） · [[methods/gene-set-scoring|基因集与通路签名打分]]（adaptable） · [[methods/trajectory-inference|拟时序与轨迹推断]]（adaptable）
<!-- facts:end -->

## 含义

一行是一条观测：某一个细胞（或某一样本）在某个 celltype、某个 group 下的单个数值，小提琴、箱线和抖动点都直接由这些行画出；示例中每个 celltype×group 的 80 行是按图估读的合成点，不代表真实细胞数或样本量。value 用原尺度浮点数，模板不做归一化或 log 转换，也没有缺失值约定（现有 SCP 适配函数 scp_grouped_values() 遇到 celltype/group/value 的 NA 直接报错），所以量纲必须在导出前统一并在课题里说明——示例的通路得分约 −0.20 至 0.67，并不是 0–1 百分比；同时一个文件只能承载一个指标。最容易出错的是同一批细胞被重复导出（表里没有 cell_id，模板无法察觉，会虚增密度和表观样本量）、把细胞级 p 当成样本级推断（组内只有 1 个样本时不能做组间比较），以及 group 标签与 spec/style 的 group_levels 不一致而被当作 NA 丢点。配套的 render-group-summaries 提供上游给定的 mean/SD、p 标签和标注位置，模板不重算检验与这些标签（小提琴和箱体本身由原始 value 现画），且 p 标签按 celltype 去重后只画一条，因此每个 celltype 只应有一个 p，两组摘要行给不同 p 时只有第一条生效；已有同源逐点值与摘要、且需要显式抖动时，用 render-category-points 配 render-box-summaries；只有摘要时当前没有模板能单独出图，只有逐点值时需先补同源摘要，若要按细胞做 UMAP 特征着色（一个文件含多个 feature），用 render-umap-feature-long，不要用本接口。spec 还固定了示例的 celltype_levels/group_levels，换数据必须覆盖或置空，否则新类别会被 factor 成 NA 并静默丢点。

<!-- user:start -->
<!-- user:end -->
