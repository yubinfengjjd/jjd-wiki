---
type: recipe
id: figureya-10chromosomev2-update
title: 染色体特征分布图
status: ready
source:
  id: figureya
  item: FigureYa10chromosomeV2_update
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa10chromosomeV2_update.Rmd
inputs:
- file: karyotype.csv
  note: karyotype.csv，用于画染色体轮廓。包含五列：第一列为染色体名，第二、三列为染色体的起始和终止点。如果能提供着丝粒的开始和结束位置，就给出第四列（起始）和第五列（终止），如果着丝粒位置未知，就只给前三列。0-based基因组坐标(以0-based开始、1-based结束)。
- file: easy_input_heatmap.csv
  note: easy_input_heatmap.csv，用来绘制染色体heatmap。包含四列，第一列染色体名，第二、三列为染色体上的位置，第四列为相应位置上的值。例如差异基因的log2foldchange、甲基化水平等。
- file: easy_input_mark.csv
  note: easy_input_mark.csv，如果想画染色体旁边的形状标记，就要提供这个文件。包含六列，第一列type，第二列形状（只支持三种形状：box正方形、triangle三角形和circle圆。如果需要标记的特征超过3种，就用第六列里的颜色区分吧，例如红色的三角形，蓝色的三角形等），第三列染色体，第四、五列染色体上的位置，第六列颜色。**注意：**同一type对应的颜色一致。
outputs: []
packages:
  cran:
  - RIdeogram
  - knitr
  bioc:
  - rtracklayer
  github: []
  library:
  - RIdeogram
  - rtracklayer
  - dplyr
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- RIdeogram
- rtracklayer
- karyotype
- GTF
chart_types:
- ideogram
summary: 用RIdeogram在直线型染色体（核型Ideogram）上叠加数值热图轨道和形状标记，展示基因组特征分布。
favorite: false
---
# 染色体特征分布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa10chromosomeV2_update` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa10chromosomeV2_update.Rmd`）
- 依赖：CRAN RIdeogram, knitr；Bioconductor rtracklayer
- 最近运行：pass（as-is，2026-11-04 10:59 UTC，475.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `chromosome.pdf` 第 1 页）：

![[recipes/figureya-10chromosomev2-update/preview.png]]
<!-- facts:end -->

## 用途

用RIdeogram在直线型染色体（核型Ideogram）上叠加数值热图轨道和形状标记，展示基因组特征分布。

## 适用

展示差异表达基因、开放染色质、CTCF结合位点、突变位点或DNA甲基化等在染色体上的分布，也可只画核型图。

## 不适用

只输出SVG需再转png/pdf；标记形状仅box/triangle/circle三种、同type颜色须一致；画环状圈图需改用Circos类条目。

## 输入

- `karyotype.csv`：karyotype.csv，用于画染色体轮廓。包含五列：第一列为染色体名，第二、三列为染色体的起始和终止点。如果能提供着丝粒的开始和结束位置，就给出第四列（起始）和第五列（终止），如果着丝粒位置未知，就只给前三列。0-based基因组坐标(以0-based开始、1-based结束)。
- `easy_input_heatmap.csv`：easy_input_heatmap.csv，用来绘制染色体heatmap。包含四列，第一列染色体名，第二、三列为染色体上的位置，第四列为相应位置上的值。例如差异基因的log2foldchange、甲基化水平等。
- `easy_input_mark.csv`：easy_input_mark.csv，如果想画染色体旁边的形状标记，就要提供这个文件。包含六列，第一列type，第二列形状（只支持三种形状：box正方形、triangle三角形和circle圆。如果需要标记的特征超过3种，就用第六列里的颜色区分吧，例如红色的三角形，蓝色的三角形等），第三列染色体，第四、五列染色体上的位置，第六列颜色。**注意：**同一type对应的颜色一致。
- `your_file.gtf`：见 Rmd“输入文件”节

karyotype.csv必需（染色体名+起止位点+可选着丝粒两列，0-based坐标）；热图表与标记表可选；三个文件染色体名须一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-10chromosomev2-update`
- 用到课题：`wiki.py use figureya-10chromosomev2-update --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：SVG转png/pdf用包内convertSVG（依赖rsvg）；附录用rtracklayer或dplyr从GTF生成karyotype为可选预处理步骤。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
