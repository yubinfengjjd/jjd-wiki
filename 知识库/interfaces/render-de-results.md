---
type: interface
slug: render-de-results
title: 差异表达结果表
columns:
  gene:
    type: str
    description: 基因/特征标识；同一 group1 内唯一
  group1:
    type: str
    description: 比较组；一个模板文件只放一个 group1
  group2:
    type: str
    description: 参照组或 rest
  avg_log2FC:
    type: float
    description: group1 相对 group2 的 log2 倍数变化
  pct_1:
    type: float
    description: group1 中阳性细胞比例，0–1
  pct_2:
    type: float
    description: group2 中阳性细胞比例，0–1
  p_val:
    type: float
    description: 原始 p 值
  p_val_adj:
    type: float
    description: 多重校正后的 p 值
---
# 差异表达结果表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因/特征标识；同一 group1 内唯一 |
| group1 | str | 必需 | 比较组；一个模板文件只放一个 group1 |
| group2 | str | 必需 | 参照组或 rest |
| avg_log2FC | float | 必需 | group1 相对 group2 的 log2 倍数变化 |
| pct_1 | float | 必需 | group1 中阳性细胞比例，0–1 |
| pct_2 | float | 必需 | group2 中阳性细胞比例，0–1 |
| p_val | float | 必需 | 原始 p 值 |
| p_val_adj | float | 必需 | 多重校正后的 p 值 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/differential-expression|差异表达分析]]（adaptable）
<!-- facts:end -->

## 含义

一行是一个基因/特征在一个比较（group1 对 group2）中的差异表达结果，同一 group1 内 gene 唯一；接口约定一个文件只放一个 group1（示例为 Endocrine 对 Rest，7343 个基因），group2 是参照组或 rest。`pct_1`/`pct_2` 是 0–1 的阳性细胞比例（不是 0–100），`avg_log2FC` 是 group1 相对 group2 的 log2 倍数变化且允许 ±Inf（示例有 5 个），`p_val_adj` 必须落在 (0,1]，等于 0 会让 −log10 无定义并报错。DE 检验、log2FC 与 p 值/校正 p 值都是上游给定、模板不重算（不重跑 DE 或校正），模板只派生绘图量：默认 x 为 `diff_pct = pct_1 − pct_2`，y 为按 `avg_log2FC` 符号翻转的 −log10(`p_val_adj`)（刻度显示绝对值），颜色按 `avg_log2FC` 在分位数边界截断，DE 点由 style 阈值（默认 `avg_log2FC > 0 & p_val_adj < 0.05`）判定，负向显著基因默认不高亮。最容易出错的是从 Seurat/SCP 的 AllMarkers 表导出：必须把 `pct.1`/`pct.2` 改名为 `pct_1`/`pct_2`，填成 0–100、`p_val_adj = 0`、同组 gene 重复或必需列有 NA 都会让模板报错；文件里若有多个 group1，模板要求用 style `group` 选一个、仍是单 panel，且 y 轴是 SCP 的带符号 −log10(`p_val_adj`)（刻度取绝对值），不能按常规火山图的 y 解读。与 [[interfaces/render-dotplot-long]] 的区别：后者一行是“组 × 基因”，存平均表达与 0–100 的 `pct_expressed` 供点图使用，`avg_expression` 必须从表达矩阵计算、不能拿 `avg_log2FC` 顶替；要画一个比较的火山图或看 DE 统计选本接口，要展示多个细胞类型对选定 marker 的表达与检出率选 render-dotplot-long。

<!-- user:start -->
<!-- user:end -->
