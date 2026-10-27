---
type: template
id: figureya-59volcanov2--volcano
title: bulk 差异火山图（分级着色）
status: draft
layouts: []
sources:
- recipes/figureya-59volcanov2
panels: []
language: r
license: CC-BY-NC-SA-4.0
tags:
- transcriptomics
chart_types:
- volcano
keywords:
- limma
- ggrepel
- log2FC
- adjusted P
- ggthemes
- gridExtra
favorite: false
---
# bulk 差异火山图（分级着色）

> 许可：CC BY-NC-SA 4.0（FigureYa，Lu X, et al. iMetaMed 2025, doi:10.1002/imm3.70005）。仅限非商业使用，署名并引用；改编代码须相同方式共享；`code/` 与 `example/` 不进 Git、不推送。

<!-- facts:start -->
- 来源：[[recipes/figureya-59volcanov2|差异表达火山图（经典与进阶）]]
- 语言：r
- 许可证：CC-BY-NC-SA-4.0
- 标签：transcriptomics
- 图型：[[chart-types/volcano]]
- 输入接口：[[interfaces/bulk-de-table|bulk 差异表达结果表]] · [[interfaces/highlight-gene-sets|待标注基因与所属基因集]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

bulk 两组比较的全部基因（log2FC 与原始 P，上游给定）画火山图；`advanced` 为上游分级着色/分级点大小，`classic` 为红/蓝/灰。可选第二张表圈出并标注指定基因，按基因集着色并在左上列出基因集。

## 不适用

单细胞 marker 表（含阳性比例，用 [[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]）；多组同时比较；还没做差异分析。阈值按原始 P（与上游一致），要改用校正 P 属于改统计口径，先问作者。

## 知识关联检查

2026-10-27：查了 chart-types/volcano、[[templates/2026-10-22-scp-example__fig01-volcano--volcano]] 与 [[methods/differential-expression]]。SCP 火山图读 render-de-results（单细胞，含 pct_1/pct_2），本模板读 bulk-de-table，画法与输入不同，保留为两个模板。differential-expression 的输出接口不是 bulk-de-table，未写 figure_relations（需要适配时由课题列映射 logFC→log2fc、P.Value→pvalue）。示例的 KRT6A 不在差异表中，上游 merge() 静默丢弃；模板默认报错，示例用 `missing_highlight: drop` 复现上游。

## 数据要求

模板化后生成。

## 使用记录

<!-- user:start -->
<!-- user:end -->
