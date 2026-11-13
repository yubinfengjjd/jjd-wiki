---
type: interface
slug: render-cell-proportions
title: 细胞类型比例表
columns:
  group:
    type: str
    description: 样本或条件分组；x 轴
  celltype:
    type: str
    description: 细胞类型；堆叠/流带类别
  proportion:
    type: float
    description: 该组内该细胞类型的比例；每组应归一化到 1
---
# 细胞类型比例表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| group | str | 必需 | 样本或条件分组；x 轴 |
| celltype | str | 必需 | 细胞类型；堆叠/流带类别 |
| proportion | float | 必需 | 该组内该细胞类型的比例；每组应归一化到 1 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]] · [[templates/2026-10-22-scp-example__fig02-ring--ring|分组构成同心环图]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/batch-integration|单细胞批次整合]]（adaptable） · [[methods/cell-clustering|单细胞聚类分析]]（adaptable） · [[methods/cell-quality-control|单细胞质量控制]]（adaptable） · [[methods/cell-type-annotation|细胞类型注释]]（adaptable） · [[methods/doublet-detection|双细胞检测]]（adaptable） · [[methods/reference-mapping|参考图谱映射]]（adaptable）
<!-- facts:end -->

## 含义

一行不是单个细胞，而是某个 group（样本或条件）内一个 celltype 的汇总比例；同一 group 的所有行合起来才是该组的完整组成。proportion 用 0–1 小数而不是 0–100，接口约定每组和为 1，ring 只在显示时乘 100 成百分比、stacked-bar-flow 的 y 轴也是 0–1，且 ring 未显式给 levels 时按输入行序决定类别与环的顺序。比例由上游按细胞计数汇总后给定，模板不重算、也不做组间检验；缺失的 group×celltype 组合要显式写 0（ring 会补 0 且遇 NA 报错，stacked-bar-flow 会静默丢弃含 NA 的行），重复的 group×celltype 行在 ring 报错、在 stacked-bar-flow 不查重，重复的细胞行在接口层则看不出来。归一化责任两者不同：stacked-bar-flow 默认 normalize: true，绘图前再按组内和归一化（传计数进去也会被当成比例重新闭合），ring 不归一化、每组和与 1 的偏差超过 1e-8 就报错；stacked-bar-flow 的 spec 还把示例的组/类型顺序写进 x_levels/stack_levels，换数据需在 style 覆盖，否则新组会被 factor 成 NA。与 render-cell-metadata 的关键区别是行单位：后者一行一个细胞，pie/rose/trend/area/dot 模板在内部计数；已有细胞级标签、要画这些图型时用 render-cell-metadata，比例已汇总或要画堆叠/流带与环图时用 render-cell-proportions，而 render-grouped-values 是单个数值的分组分布表，不表达组成。

<!-- user:start -->
<!-- user:end -->
