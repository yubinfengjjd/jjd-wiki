---
type: interface
slug: render-group-summaries
title: 预计算分组分布摘要表
columns:
  celltype:
    type: str
    description: 细胞类型或类别；与值表一一对应
  group:
    type: str
    description: 比较组；与值表一一对应
  mean:
    type: float
    description: 上游给定的组内均值
  sd:
    type: float
    description: 上游给定的组内标准差
  p_label:
    type: str
    description: 上游给定的 p 值标签；模板不重算检验
  p_y:
    type: float
    description: p 标签的 y 位置，由上游给定
  mean_sd_label:
    type: str
    description: 上游给定的 Mean/SD 文本标签
  mean_y:
    type: float
    description: Mean/SD 标签的 y 位置，由上游给定
---
# 预计算分组分布摘要表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| celltype | str | 必需 | 细胞类型或类别；与值表一一对应 |
| group | str | 必需 | 比较组；与值表一一对应 |
| mean | float | 必需 | 上游给定的组内均值 |
| sd | float | 必需 | 上游给定的组内标准差 |
| p_label | str | 必需 | 上游给定的 p 值标签；模板不重算检验 |
| p_y | float | 必需 | p 标签的 y 位置，由上游给定 |
| mean_sd_label | str | 必需 | 上游给定的 Mean/SD 文本标签 |
| mean_y | float | 必需 | Mean/SD 标签的 y 位置，由上游给定 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/cell-quality-control|单细胞质量控制]]（adaptable） · [[methods/dynamic-feature-analysis|拟时序动态特征分析]]（adaptable） · [[methods/gene-set-scoring|基因集与通路签名打分]]（adaptable） · [[methods/trajectory-inference|拟时序与轨迹推断]]（adaptable）
<!-- facts:end -->

## 含义

本表一行代表一个细胞类型与一个比较组的组合（示例为 9 个细胞类型 × 2 组 = 18 行），mean、sd 和 Mean/SD 文本按组各一行，同一细胞类型的 p 标签与 p_y 在两行中重复。mean、sd、p 标签及 p_y/mean_y 全部由上游给定、模板不重算均值和检验，mean/sd 是值表 value 的组内统计并与之同单位（示例为约 −0.20–0.67 的通路得分，不是 0–100 百分比或 0–1 比例），p_y/mean_y 是 y 轴上的绝对数据坐标而非相对位置；本表不记录检验方法与推断层级，示例方法页注明其细胞级 p 仅作描述、不能当样本级推断。最容易出错的是摘要与值表不同源或标签对不上：celltype/group 必须与值表逐字一致并落在 style 的 levels 内、示例中每个 celltype×group 恰好一行，同一 celltype 两行的 p 标签和 p_y 必须相同（当前模板只按文件行序取第一行画一次 p 标签）；实际画出的数字来自上游给的 Mean/SD 文本，模板既不用 mean/sd 重算也不拿它们校验该文本，改数值或 y 尺度却不同步更新标签与位置，图上会静默显示旧数字或错位；表内没有 n_cells、样本或配对标识，重复计数与配对关系只能在分析阶段核对。与 render-grouped-values 的区别：后者每个细胞或样本一行（示例 1440 行，每类每组 80 个细胞）提供小提琴/箱线/抖动所需的原始分布，本接口只有每组一行的摘要、不能单独成图，仅在需要 p 与 Mean/SD 文本标注时随值表一起提供。与 render-box-summaries 的区别：后者每类一行、由上游给出 q1/median/q3/须，没有 group 维度和标注位置列；预计算箱线图用 render-box-summaries，带分组与统计标注的小提琴用本接口并配 render-grouped-values。接口未定义 NA；模板不做缺失值检查，含 NA 的摘要行可能被 ggplot 丢弃或告警，正式导出前应在上游清理。示例 CSV 含未声明的 p_value 列，它不参与模板，正式导出可删除。

<!-- user:start -->
<!-- user:end -->
