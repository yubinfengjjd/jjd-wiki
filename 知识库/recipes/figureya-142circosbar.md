---
type: recipe
id: figureya-142circosbar
title: 环状热图连线柱图
status: draft
source:
  id: figureya
  item: FigureYa142circosBar
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa142circosBar.Rmd
inputs:
- file: karyotype.txt
  note: data/karyotype.txt，染色体，可以替换成想展示的其他类型信息，例如，第一、二列基本不变，第三列表示在输入文件中表示哪条染色体（即染色体号），第四列是在circos图中染色体的名称，第五列到第六列表示该条染色体起始终止位置（即染色体长度），最后一列表示染色体颜色。circos一般是用于表现单条或者多条染色体上得特征。当然也可以用于表现其他内容，只要符合数据格式都可以展示。比如本图，先
- file: GS1.txt
  note: data/GS1.txt，热图数据文件。第一列表示要展示的染色体号，第二第三列为KO起始终止位置，第四列为该KO的数值（相对丰度），GS2~GS10同理。只要是能用热图展示的数据，都可以绘制，比如转录组表达矩阵到组间差异基因的热图展示，宏基因组中群落OTU等热图展示。
- file: KO_orthology_text.txt
  note: data/KO_orthology_text.txt，在hs1染色体上要展示的KO的名称。第一列是要展示的染色体号，第二第三列是起始终止位置，第四列是该位置区间的KO名称，第四列设置该KO的颜色，其中red为红，lred=light
    red，dred=dark red，vlred=very light red，vdred=very dark red。
- file: class_text.txt
  note: data/class_text.txt，hs2号染色体上展示KEGG B级分类名称。跟data/KO_orthology_text.txt类似。
- file: links.txt
  note: data/links.txt，连线文件。因为link连线展示的是两个有关联的数据，所以这个文件格式含有两条染色体。一般就是不同染色体上有联系的内容的设置，可扩展于差异基因于相应富集通路所属关系，细胞于所属分群的关系，甚至是DNA和TF相互作用的关系或者基因和转录调控元件等等。如该文件第一行表示hs1染色体上的0到1位置的KO与hs2号染色体上18到19位置上的通路是所属关系，往下以此类推。这个文件
- file: hist_3.txt
  note: 设置hs2号染色体上的黑色边框和刻度，首先黑色框通过etc/circos.conf中的part4中的<axes>设置，其次0~8，0~20的刻度横线设置通过data/light_border.txt文件设置。另外，还有一个弧形刻度线在hs2（0.86r-1.00r）上展示，对应文件是data/hist_3.txt。（原谅我这个小白实在不知道这里的刻度和弧线刻度怎么弄，我只想到了这种办法）
- file: highlight.txt
  note: data/highlight.txt，设置染色体hs2上的背景色，这个背景色是按照将KEGG 的A级分类分配背景色的。第一列是染色体号，二三列是背景色起始终止位置，第四列是背景色颜色和半径。
- file: light_border.txt
  note: 设置hs2号染色体上的黑色边框和刻度，首先黑色框通过etc/circos.conf中的part4中的<axes>设置，其次0~8，0~20的刻度横线设置通过data/light_border.txt文件设置。另外，还有一个弧形刻度线在hs2（0.86r-1.00r）上展示，对应文件是data/hist_3.txt。（原谅我这个小白实在不知道这里的刻度和弧线刻度怎么弄，我只想到了这种办法）
- file: hist_GSH.txt
  note: data/hist_GSH.txt和hist_GSL.txt，柱状图文件。本图中柱状图文件表示的是KEGG B级分类在连线中有多少个KO属于这个通路，红色表示该通路在GSH有多少个KOs，绿色表示在GSL有多少个KOs。
- file: hist_GSL.txt
  note: data/hist_GSH.txt和hist_GSL.txt，柱状图文件。本图中柱状图文件表示的是KEGG B级分类在连线中有多少个KO属于这个通路，红色表示该通路在GSH有多少个KOs，绿色表示在GSL有多少个KOs。
- file: 1.GSH and GSL.csv
  note: ''
outputs: []
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- experimental-statistics
- multi-omics
keywords:
- circos
- KEGG
- KO
- wilcox.test
- karyotype
chart_types:
- heatmap
- chord
- bar
summary: 用circos把条目丰度热图、条目-类别归属连线和类别计数柱状图叠成一张环状组合图（例：KO与其所属KEGG B级通路）。
favorite: false
---
# 环状热图连线柱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa142circosBar` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa142circosBar.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:00 UTC，21.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用circos把条目丰度热图、条目-类别归属连线和类别计数柱状图叠成一张环状组合图（例：KO与其所属KEGG B级通路）。

## 适用

想在一图同时展示两组样品的条目丰度差异热图、条目与上层类别的归属关系及各类别计数。

## 不适用

需手工准备十余个data文件，karyotype长度要按条目数计算；R只负责整理数据，正式出图靠终端circos命令；刻度数字、外层分类名等还需AI/PS补画。

## 输入

- `karyotype.txt`：data/karyotype.txt，染色体，可以替换成想展示的其他类型信息，例如，第一、二列基本不变，第三列表示在输入文件中表示哪条染色体（即染色体号），第四列是在circos图中染色体的名称，第五列到第六列表示该条染色体起始终止位置（即染色体长度），最后一列表示染色体颜色。circos一般是用于表现单条或者多条染色体上得特征。当然也可以用于表现其他内容，只要符合数据格式都可以展示。比如本图，先
- `GS1.txt`：data/GS1.txt，热图数据文件。第一列表示要展示的染色体号，第二第三列为KO起始终止位置，第四列为该KO的数值（相对丰度），GS2~GS10同理。只要是能用热图展示的数据，都可以绘制，比如转录组表达矩阵到组间差异基因的热图展示，宏基因组中群落OTU等热图展示。
- `KO_orthology_text.txt`：data/KO_orthology_text.txt，在hs1染色体上要展示的KO的名称。第一列是要展示的染色体号，第二第三列是起始终止位置，第四列是该位置区间的KO名称，第四列设置该KO的颜色，其中red为红，lred=light red，dred=dark red，vlred=very light red，vdred=very dark red。
- `class_text.txt`：data/class_text.txt，hs2号染色体上展示KEGG B级分类名称。跟data/KO_orthology_text.txt类似。
- `links.txt`：data/links.txt，连线文件。因为link连线展示的是两个有关联的数据，所以这个文件格式含有两条染色体。一般就是不同染色体上有联系的内容的设置，可扩展于差异基因于相应富集通路所属关系，细胞于所属分群的关系，甚至是DNA和TF相互作用的关系或者基因和转录调控元件等等。如该文件第一行表示hs1染色体上的0到1位置的KO与hs2号染色体上18到19位置上的通路是所属关系，往下以此类推。这个文件
- `hist_3.txt`：设置hs2号染色体上的黑色边框和刻度，首先黑色框通过etc/circos.conf中的part4中的<axes>设置，其次0~8，0~20的刻度横线设置通过data/light_border.txt文件设置。另外，还有一个弧形刻度线在hs2（0.86r-1.00r）上展示，对应文件是data/hist_3.txt。（原谅我这个小白实在不知道这里的刻度和弧线刻度怎么弄，我只想到了这种办法）
- `hist_GSH.txt和hist_GSL.txt`：data/hist_GSH.txt和hist_GSL.txt，柱状图文件。本图中柱状图文件表示的是KEGG B级分类在连线中有多少个KO属于这个通路，红色表示该通路在GSH有多少个KOs，绿色表示在GSL有多少个KOs。
- `highlight.txt`：data/highlight.txt，设置染色体hs2上的背景色，这个背景色是按照将KEGG 的A级分类分配背景色的。第一列是染色体号，二三列是背景色起始终止位置，第四列是背景色颜色和半径。
- `light_border.txt`：设置hs2号染色体上的黑色边框和刻度，首先黑色框通过etc/circos.conf中的part4中的<axes>设置，其次0~8，0~20的刻度横线设置通过data/light_border.txt文件设置。另外，还有一个弧形刻度线在hs2（0.86r-1.00r）上展示，对应文件是data/hist_3.txt。（原谅我这个小白实在不知道这里的刻度和弧线刻度怎么弄，我只想到了这种办法）
- `hist_GSH.txt`：data/hist_GSH.txt和hist_GSL.txt，柱状图文件。本图中柱状图文件表示的是KEGG B级分类在连线中有多少个KO属于这个通路，红色表示该通路在GSH有多少个KOs，绿色表示在GSL有多少个KOs。
- `hist_GSL.txt`：data/hist_GSH.txt和hist_GSL.txt，柱状图文件。本图中柱状图文件表示的是KEGG B级分类在连线中有多少个KO属于这个通路，红色表示该通路在GSH有多少个KOs，绿色表示在GSL有多少个KOs。
- `1.GSH and GSL.csv`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-142circosbar`
- 用到课题：`wiki.py use figureya-142circosbar --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：依赖外部circos（Perl）软件，须在Linux/Mac终端或Windows WSL里运行circos -conf circos.conf；配置文件在Ya_circos/etc。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]] · [[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
