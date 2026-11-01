---
type: recipe
id: figureya-92immune-gene-update
title: 基因与免疫浸润相关性图
status: ready
source:
  id: figureya
  item: FigureYa92immune_gene_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa92immune_gene_update.Rmd
inputs:
- file: ssGSEA_output.csv
  note: ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。在FigureYa71ssGSEA读取文件的命令行里添加`check.names
    = F`，避免行名TCGA id的“-”变成“.”。列也可以是基因，即基因表达矩阵。
- file: easy_input_expr.txt
  note: easy_input_expr.txt，基因表达矩阵，列是样本，行是基因。行也可以是转录本，甚至是临床信息。另外，作者还提供了从TCGA表达矩阵（例如not_easy_input_expr.txt）提取某一基因表达谱的代码，见pick1gene.R文件。
outputs:
- gene_Xcell.pdf
- gene_1cell_ggscatterstats.pdf
- gene_1cell_ggplot2.pdf
packages:
  cran:
  - data.table
  - dplyr
  - tidyr
  - ggstatsplot
  - ggplot2
  bioc: []
  github: []
  library:
  - ggstatsplot
  - data.table
  - dplyr
  - tidyr
  - ggplot2
  namespaced:
  - knitr
  - forcats
tags:
- transcriptomics
keywords:
- ssGSEA
- immune infiltration
- ggstatsplot
- Spearman
- data.table
chart_types:
- scatter
- dotplot
summary: 计算一个基因与各免疫细胞浸润评分的相关，画汇总点图和单个细胞的散点图（带边缘分布）。
favorite: false
---
# 基因与免疫浸润相关性图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa92immune_gene_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa92immune_gene_update.Rmd`）
- 依赖：CRAN data.table, dplyr, tidyr, ggstatsplot, ggplot2
- 最近运行：pass（as-is，2026-10-27 12:37 UTC，4.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-92immune-gene-update/preview.png]]
<!-- facts:end -->

## 用途

计算一个基因与各免疫细胞浸润评分的相关，画汇总点图和单个细胞的散点图（带边缘分布）。

## 适用

表达矩阵与免疫浸润矩阵（如 ssGSEA/xCell 输出），样本名对齐。

## 不适用

还没算免疫浸润；需要校正肿瘤纯度等混杂时要另行确认方法。

## 输入

- `ssGSEA_output.csv`：ssGSEA_output.csv，免疫细胞矩阵，列是免疫细胞，行是样本，由FigureYa71ssGSEA产生。在FigureYa71ssGSEA读取文件的命令行里添加`check.names = F`，避免行名TCGA id的“-”变成“.”。列也可以是基因，即基因表达矩阵。
- `easy_input_expr.txt`：easy_input_expr.txt，基因表达矩阵，列是样本，行是基因。行也可以是转录本，甚至是临床信息。另外，作者还提供了从TCGA表达矩阵（例如not_easy_input_expr.txt）提取某一基因表达谱的代码，见pick1gene.R文件。
- `例如not_easy_input_expr.txt`：easy_input_expr.txt，基因表达矩阵，列是样本，行是基因。行也可以是转录本，甚至是临床信息。另外，作者还提供了从TCGA表达矩阵（例如not_easy_input_expr.txt）提取某一基因表达谱的代码，见pick1gene.R文件。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-92immune-gene-update`
- 用到课题：`wiki.py use figureya-92immune-gene-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `gene_Xcell.pdf`
- `gene_1cell_ggscatterstats.pdf`
- `gene_1cell_ggplot2.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- figureya-selection:start -->
## 样式筛选记录

2026-11-02 整理时，此配方对应的 FigureYa 模块已被作者从样式候选中移除，不再作为默认推荐。

本页、原始源码和既有运行收据保留；原确认状态不代表当前样式仍被选用。当前取舍以 `sources/figureya-curation.json` 为准，可在前端恢复。
<!-- figureya-selection:end -->

<!-- user:start -->
<!-- user:end -->
