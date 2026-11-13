---
type: recipe
id: figureya-73batchcorrelation
title: 目标基因批量相关散点图
status: ready
source:
  id: figureya
  item: FigureYa73batchCorrelation
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa73batchCorrelation.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，基因表达矩阵，第一列是gene symbol，后面是表达矩阵。
outputs: []
packages:
  cran:
  - cowplot
  - ggplot2
  - plyr
  - reshape2
  bioc: []
  github: []
  library:
  - reshape2
  - ggplot2
  - cowplot
  - plyr
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- pearson
- spearman
- cowplot
- plyr
- reshape2
chart_types:
- scatter
summary: 批量算一个目标基因与其余全部基因的pearson/spearman相关及P值，取正/负相关各topN，样本按目标基因表达排序后按bin取中位数画带回归线的散点小
favorite: false
---
# 目标基因批量相关散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa73batchCorrelation` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa73batchCorrelation.Rmd`）
- 依赖：CRAN cowplot, ggplot2, plyr, reshape2
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，49.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-73batchcorrelation/preview.png]]
<!-- facts:end -->

## 用途

批量算一个目标基因与其余全部基因的pearson/spearman相关及P值，取正/负相关各topN，样本按目标基因表达排序后按bin取中位数画带回归线的散点小图矩阵。

## 适用

筛与兴趣基因正/负相关的候选基因；也适用ChIP/ATAC/甲基化等海量位点（bin画法压点）。

## 不适用

只支持“一个目标基因vs其余行”模式，symbol须命中矩阵行名；cor.test逐基因算P值，基因多时很慢；r/P标注坐标与bin点数需按数据范围手调。

## 输入

- `easy_input.csv`：easy_input.csv，基因表达矩阵，第一列是gene symbol，后面是表达矩阵。
- `not_easy_input_expr.txt`：示例数据取自FigureYa71ssGSEA的not_easy_input_expr.txt文件，把表达矩阵的第一列gene_id换成gene symbol，可参考FigureYa71ssGSEA或FigureYa56immune_inflitration的处理方式。为方便传输，取了表达量最高的1000个基因。

easy_input.csv行=基因（symbol）列=样本；bin为样本按目标基因表达排序后等分取中位。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-73batchcorrelation`
- 用到课题：`wiki.py use figureya-73batchcorrelation --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
