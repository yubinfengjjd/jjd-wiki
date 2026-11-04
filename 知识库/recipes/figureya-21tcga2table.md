---
type: recipe
id: figureya-21tcga2table
title: TCGA临床特征三线表
status: draft
source:
  id: figureya
  item: FigureYa21TCGA2table
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa21TCGA2table.Rmd
inputs:
- file: easy_input.csv
  note: ''
outputs: []
packages:
  cran:
  - dplyr
  - kableExtra
  bioc:
  - TCGAbiolinks
  github: []
  library:
  - TCGAbiolinks
  - dplyr
  - kableExtra
  namespaced:
  - knitr
tags:
- other
keywords:
- TCGAbiolinks
- kableExtra
- TCGA
- chisq.test
- baseline table
chart_types:
- table
summary: 按生存状态把临床样本分成Alive/Dead with tumor/Dead tumor free，对性别、年龄、分期等特征算计数百分比和卡方检验，用kable
favorite: false
---
# TCGA临床特征三线表

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa21TCGA2table` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa21TCGA2table.Rmd`）
- 依赖：CRAN dplyr, kableExtra；Bioconductor TCGAbiolinks
- 最近运行：pass（as-is，2026-11-04 15:07 UTC，18.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

按生存状态把临床样本分成Alive/Dead with tumor/Dead tumor free，对性别、年龄、分期等特征算计数百分比和卡方检验，用kableExtra拼三线表。

## 适用

整理TCGA或自有临床样本信息，做论文基线特征表（Table 1）展示各组分布差异。

## 不适用

只做描述统计和卡方检验，不含回归建模；分组与字段名按TCGA示例写死（vital_status、person_neoplasm_cancer_status、stage_event_pathologic_stage等），自有数据需对齐列名。

## 输入

- `easy_input.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-21tcga2table`
- 用到课题：`wiki.py use figureya-21tcga2table --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：含TCGAbiolinks从GDC在线下载临床数据的代码段；导出PDF需本地装pdflatex。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
