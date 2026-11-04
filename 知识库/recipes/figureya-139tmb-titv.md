---
type: recipe
id: figureya-139tmb-titv
title: 泛癌突变负荷与碱基谱图
status: draft
source:
  id: figureya
  item: FigureYa139TMB_titv
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa139TMB_titv.Rmd
inputs:
- file: TMB_titv.RData
  note: ''
- file: easy_input.csv
  note: ''
outputs:
- TMB_titv.pdf
- TMB_titv2.pdf
packages:
  cran:
  - darkblue
  - ggplot2
  - ggsci
  - tidyverse
  bioc:
  - TCGAbiolinks
  - maftools
  github: []
  library:
  - TCGAbiolinks
  - maftools
  - ggplot2
  - tidyverse
  - ggsci
  namespaced:
  - knitr
  - BiocManager
  - plyr
tags:
- multi-omics
keywords:
- maftools
- TCGAbiolinks
- TMB
- Ti/Tv
- ggsci
- tidyverse
chart_types:
- scatter
- bar
summary: 用base plot拼图：上层按癌种中位TMB排序的逐样本突变频率散点（含中位线），下层每样本6种碱基替换（Ti/Tv）比例条。
favorite: false
---
# 泛癌突变负荷与碱基谱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa139TMB_titv` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa139TMB_titv.Rmd`）
- 依赖：CRAN darkblue, ggplot2, ggsci, tidyverse；Bioconductor TCGAbiolinks, maftools
- 最近运行：pass（as-is，2026-11-04 15:07 UTC，22.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `TMB_titv.pdf` 第 1 页）：

![[recipes/figureya-139tmb-titv/preview.png]]
<!-- facts:end -->

## 用途

用base plot拼图：上层按癌种中位TMB排序的逐样本突变频率散点（含中位线），下层每样本6种碱基替换（Ti/Tv）比例条。

## 适用

把目标癌种或自定义分组（如同一疾病不同亚型）放进TCGA泛癌谱里对比TMB水平和突变方式构成。

## 不适用

输入需预先整理成cohort/样本/TMB三列及逐样本Ti/Tv比例表，且底部样本顺序须按TMB排序对齐；出版级细节需Illustrator后修。

## 输入

- `TMB_titv.RData`：见 Rmd“输入文件”节
- `easy_input.csv`：见 Rmd“输入文件”节

TMB表与titv表须同一批样本且逐癌种内顺序一致；TMB按nonsynonymous总数/35Mb换算。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-139tmb-titv`
- 用到课题：`wiki.py use figureya-139tmb-titv --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：示例依赖已存的TMB_titv.RData；从头构建需TCGAbiolinks在线下载全部TCGA癌种maf（数据量大、耗时长）。

## 输出

- `TMB_titv.pdf`
- `TMB_titv2.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
