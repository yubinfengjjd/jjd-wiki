---
type: template
id: km-survival-risk-grid
title: 多基因 TCGA 生存风险网格图
status: ready
layouts: []
sources:
- methods/survival-prognosis-analysis
panels: []
language: python
primary_method: survival-prognosis-analysis
style_tier: variant
journal_style: Cancer Discovery
tags:
- survival-analysis
- transcriptomics
chart_types:
- km-curve
keywords:
- Kaplan-Meier
- TCGA-SKCM
- survival-grid
- hazard-ratio
- Cancer Discovery
favorite: false
---
# 多基因 TCGA 生存风险网格图

![[templates/km-survival-risk-grid/preview.png]]

<!-- facts:start -->
- 来源：[[methods/survival-prognosis-analysis|生存分析与临床预后建模]]
- 语言：python
- 标签：survival-analysis、transcriptomics
- 图型：[[chart-types/km-curve]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/survival-prognosis-analysis|生存分析与临床预后建模]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：多基因或枢纽基因模块在外部队列按中位数高低分组后的预计算 KM 阶跃曲线与 Logrank/Cox 统计可整理为 default 多基因网格图；模板不拟合生存回归。；前提：各基因按同一分组规则（如中位数）与同一生存终点（OS/PFS）拟合；明确缺测基因与抽样边界。；适配：导出 km_survival_curves.csv 与 km_survival_stats.csv。
    - 关系证据：methods/survival-prognosis-analysis.md#输出；templates/km-survival-risk-grid/spec.json；运行证据：无
<!-- facts:end -->

## 适用

多基因（如共表达模块枢纽基因）在外部临床队列（TCGA-SKCM）中按中位数划分高/低表达组后的分面 Kaplan-Meier 生存网格图：每个子面板含 95% 置信区间虚线、删失 `+` 标记、`Logrank p`、`HR(high)`、`p(HR)` 与组内样本量标注，底部共享统一图例。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. S6F 风格。

## 不适用

本模板直接绘制预计算好的 KM 阶跃曲线与 Cox 统计汇总，不执行生存回归或最佳切点搜索；单基因带 number-at-risk 风险表的经典 KM 曲线请使用 [[templates/km-survival-curve]]。示例数据直接取自 UCSC Xena TCGA-SKCM 抽样 120 例重算表（`figs6f_tcga_km_curves.csv`、`figs6f_tcga_survival_stats.csv`，其中 `PMEL` 映射自旧名 `SILV`，`MT-ND2` 因 Legacy HiSeqV2 缺测而未包含）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/survival-prognosis-analysis]]；2026-11-21 槽位审查对齐“标准版为默认、期刊版为变体”原则，由 [[templates/km-survival-curve]]（Standard）担任 `default`，本模板置为 `style_tier: variant`（`journal_style: Cancer Discovery`）。

## 数据要求

### km_curves（km_survival_curves.csv）：多基因 Kaplan-Meier 阶跃生存率与 95% CI 曲线表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因符号 |
| group | str | 必需 | 分组（High / Low） |
| time_years | float | 必需 | 随访时间（年） |
| surv | float | 必需 | 生存概率 |
| lower | float | 可选 | 95% CI 下界 |
| upper | float | 可选 | 95% CI 上界 |
| n_censor | int | 可选 | 删失数 |

### km_stats（km_survival_stats.csv）：各基因 Logrank P 与单因素 Cox HR 汇总统计表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| gene | str | 基因符号 |
| logrank_p | float | Log-rank P 值 |
| cox_hr_high_vs_low | float | High vs Low 风险比 HR |
| cox_p | float | Cox 回归 P 值 |
| n_high | int | 高表达组样本数 |
| n_low | int | 低表达组样本数 |

### 可覆盖的 style

- `low_color`：`"#E29D7A"`
- `high_color`：`"#284560"`
- `ncols`：`2`
- `xlabel`：`"Time (years)"`
- `ylabel`：`"Survival probability"`
- `cohort_label`：`""`
- `dpi`：`300`
- `width_in`：`5.8`
- `height_in`：`8.6`
- `rect`：`[0.13, 0.04, 0.83, 0.92]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
