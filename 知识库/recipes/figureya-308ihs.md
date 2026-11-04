---
type: recipe
id: figureya-308ihs
title: 蛋白活性异质性评分图
status: draft
source:
  id: figureya
  item: FigureYa308IHS
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa308IHS.Rmd
inputs:
- file: easy_input_cli.csv
  note: easy_input_cli.csv，样本分组信息。共三列，第一列为样本名，跟表达矩阵里面的样本名一致；第二列是Patient ID；第三列是该Patient的Sample
    ID。
- file: Renji_cohort_MR_exp.matrix
  note: Renji_cohort_MR_exp.matrix，样本表达矩阵。每行一个基因，每列一个样本。第一行是样本名，第一列是基因名。下载自<https://zenodo.org/record/7336311#.ZBE6xbRBzt0>
outputs: []
packages:
  cran:
  - ggplot2
  - ggrepel
  - nlme
  - optparse
  - spatstat.explore
  - kernlab
  bioc:
  - viper
  github: []
  library:
  - viper
  - nlme
  - spatstat.explore
  - ggplot2
  - ggrepel
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- VIPER
- ARACNe
- pisce
- IHS
- nlme
- spatstat.explore
- ggrepel
- viper
chart_types:
- dot
summary: 用weighted VIPER推断蛋白活性后，以nlme与层次聚类两种方法各算患者内异质性得分，几何平均得IHS并画排序点图。
favorite: false
---
# 蛋白活性异质性评分图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa308IHS` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa308IHS.Rmd`）
- 依赖：CRAN ggplot2, ggrepel, nlme, optparse, spatstat.explore, kernlab；Bioconductor viper
- 最近运行：pass（as-is，2026-11-04 12:16 UTC，981.4 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-308ihs/preview.png]]
<!-- facts:end -->

## 用途

用weighted VIPER推断蛋白活性后，以nlme与层次聚类两种方法各算患者内异质性得分，几何平均得IHS并画排序点图。

## 适用

多区域取样队列的瘤内异质性量化，方法可扩展到任意蛋白/regulon活性。

## 不适用

需同一患者≥2个区域样本且样本属肿瘤组织；须先跑ARACNe构建调控网络；只产出单一IHS指标不做分组检验。

## 输入

- `easy_input_cli.csv`：easy_input_cli.csv，样本分组信息。共三列，第一列为样本名，跟表达矩阵里面的样本名一致；第二列是Patient ID；第三列是该Patient的Sample ID。
- `Renji_cohort_MR_exp.matrix`：Renji_cohort_MR_exp.matrix，样本表达矩阵。每行一个基因，每列一个样本。第一行是样本名，第一列是基因名。下载自<https://zenodo.org/record/7336311#.ZBE6xbRBzt0>

表达矩阵行=基因列=样本（示例剔除N开头正常样本）；cli表三列（样本名/Patient/Sample），样本名与矩阵列名须一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-308ihs`
- 用到课题：`wiki.py use figureya-308ihs --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：pisce.R经system调用Rscript+bash脚本及java -Xmx5G -jar aracne-ap.jar跑ARACNe，需Java环境；200次bootstrap约2天；示例矩阵原载Zenodo。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig07-dot--dot|分组构成点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
