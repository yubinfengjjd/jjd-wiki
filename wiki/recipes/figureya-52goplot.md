---
type: recipe
id: figureya-52goplot
title: GO富集圈图与弦图
status: draft
source:
  id: figureya
  item: FigureYa52GOplot
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa52GOplot.Rmd
inputs:
- file: easy_input_Mm.csv
  note: ''
- file: easy_input_Zm.csv
  note: ''
- file: very_easy_input_Mm.csv
  note: ''
- file: enrichGO_output.csv
  note: ''
outputs:
- clusterProfiler_circle.pdf
- clusterProfiler_not_circle.pdf
- GOChord.pdf
- GOCluster.pdf
packages:
  cran:
  - GOplot
  - ggplot2
  bioc:
  - AnnotationHub
  - AnnotationDbi
  - clusterProfiler
  - org.Mm.eg.db
  github: []
  library:
  - clusterProfiler
  - AnnotationHub
  - AnnotationDbi
  - GOplot
  - ggplot2
  - org.Mm.eg.db
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- clusterProfiler
- GOplot
- AnnotationHub
- AnnotationDbi
- org.Mm.eg.db
- enrichGO
- GOChord
- bitr
chart_types:
- chord
- network
summary: 把clusterProfiler的GO富集结果转成GOplot所需格式，画环形/普通cnetplot、GOChord弦图和GOCluster圈图，展示基因-te
favorite: false
---
# GO富集圈图与弦图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa52GOplot` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa52GOplot.Rmd`）
- 依赖：CRAN GOplot, ggplot2；Bioconductor AnnotationHub, AnnotationDbi, clusterProfiler, org.Mm.eg.db
- 最近运行：fail（as-is，2026-11-04 12:17 UTC，127.4 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把clusterProfiler的GO富集结果转成GOplot所需格式，画环形/普通cnetplot、GOChord弦图和GOCluster圈图，展示基因-term关系及logFC。

## 适用

已用clusterProfiler（或其他输出enrichGO格式结果的流程）做完富集，想用GOplot/弦图展示基因与通路关系。

## 不适用

输入要求ENTREZ ID+log2fc两列，非ENTREZ需先做ID转换；富集依赖物种OrgDb注释包；GOChord只取前n个term展示。

## 输入

- `easy_input_Mm.csv`：见 Rmd“输入文件”节
- `easy_input_Zm.csv`：见 Rmd“输入文件”节
- `very_easy_input_Mm.csv`：见 Rmd“输入文件”节
- `enrichGO_output.csv`：见 Rmd“输入文件”节

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-52goplot`
- 用到课题：`wiki.py use figureya-52goplot --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：非模式生物需AnnotationHub联网下载OrgDb（可选步骤，已存sqlite可复用）；富集分析与ID转换均用本地OrgDb包。

## 输出

- `clusterProfiler_circle.pdf`
- `clusterProfiler_not_circle.pdf`
- `GOChord.pdf`
- `GOCluster.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
