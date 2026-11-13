---
type: interface
slug: render-dotplot-long
title: 细胞类型 × 基因点图表
columns:
  group:
    type: str
    description: 细胞类型或分组；点图 x 轴
  feature:
    type: str
    description: 基因/marker 名称；点图 y 轴
  avg_expression:
    type: float
    description: 该组该基因的平均表达；缩放方式由课题说明
  pct_expressed:
    type: float
    description: 该组该基因的阳性细胞百分比，0–100
  target_group:
    type: str
    description: 该基因对应的目标细胞类型，可为空；仅用于基因排序
    required: false
---
# 细胞类型 × 基因点图表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| group | str | 必需 | 细胞类型或分组；点图 x 轴 |
| feature | str | 必需 | 基因/marker 名称；点图 y 轴 |
| avg_expression | float | 必需 | 该组该基因的平均表达；缩放方式由课题说明 |
| pct_expressed | float | 必需 | 该组该基因的阳性细胞百分比，0–100 |
| target_group | str | 可选 | 该基因对应的目标细胞类型，可为空；仅用于基因排序 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/cell-type-annotation|细胞类型注释]]（adaptable） · [[methods/differential-expression|差异表达分析]]（adaptable）
<!-- facts:end -->

## 含义

一行是一个 group（细胞类型或分组）× 一个 feature（基因）的汇总，不是每个细胞一行：avg_expression 和 pct_expressed 必须由表达矩阵在上游按组算好（示例是 9 个细胞类型 × 52 个基因的完整网格），模板只画点，不重算均值或阳性率，也不做差异检验（上游给定/模板不重算）。pct_expressed 用 0–100 的百分比（传 0–1 的比例会让气泡几乎缩到最小）；avg_expression 是 scaled data 还是 log-normalized 由课题说明，spec 的色标默认 0–1，超出范围的值会被钳到色标端点而不是重新归一化；target_group 是可选列（接口声明 required:false）：缺失时模板按 feature 在文件中的出现顺序排序，不生成目标组；存在但为 NA 只表示该基因没有目标细胞类型、排序时落在最后，缺失的 group×feature 行留空，不补 0。最容易出错的是把逐细胞表达表或 avg_log2FC 当作 avg_expression、把 pct 写成 0–1，或同一 group×feature 重复多行（模板不去重、不合并，会叠画多个气泡）；换数据时 group 名不在 spec 的 x_levels 里的行会被静默丢弃，target_group 按 feature 取首行，各行取值不一致也不会报错。与 render-umap-feature-long 的区别是后者一行一个细胞 × 一个 feature、用于在 UMAP 上看表达位置，这里只放组级汇总；与 render-de-results 的区别是后者带 log2FC 与 p 值、pct 为 0–1，需要显著性/火山图时用它，而本接口的颜色和气泡大小只是表达量与阳性比例、不表示显著性；与 render-grouped-values 的区别是后者保留细胞级数值让模板做分布与统计，本接口不保留细胞级信息。

<!-- user:start -->
<!-- user:end -->
