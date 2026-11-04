---
type: recipe
id: figureya-132alteration
title: 泛癌通路基因变异扫雷图
status: draft
source:
  id: figureya
  item: FigureYa132alteration
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa132alteration.Rmd
inputs:
- file: NIHMS957693-supplement-5.xlsx
  note: NIHMS957693-supplement-5.xlsx，TCGA里所有sample的信息，包括disease和subtype。
- file: NIHMS957693-supplement-7.xlsx
  note: NIHMS957693-supplement-7.xlsx，作者整理的重要pathway所包含的基因，共187个。例文Figure 4画的是RTK
    RAS，因此读取相应的sheet“RTK RAS”。如果画**其他pathway，读取对应的sheet即可**。
- file: NIHMS957693-supplement-8.xlsx
  note: NIHMS957693-supplement-8.xlsx，TCGA里9千多个sample里187个基因发生的alteration，三个sheet分别是alteration层面、gene层面和pathway层面。如果想知道这三个sheet是怎样获得的，看method里的Generation
    of Genomic Alteration Matrices (GAMs)。
outputs:
- alteration.pdf
packages:
  cran:
  - BRCA_Basal
  - BRCA_Her2
  - BRCA_LumA
  - BRCA_LumB
  - BRCA_Normal
  - CESC_AdenoCarcinoma
  - CESC_SquamousCarcinoma
  - GBM_IDHwt
  - LGG_IDHwt
  - SARC_Other
  - TGCT_seminoma
  - Total
  - ggplot2
  - reshape2
  bioc: []
  github: []
  library:
  - ggplot2
  - reshape2
  namespaced:
  - knitr
  - readxl
  - ggpubr
tags:
- multi-omics
keywords:
- TCGA
- readxl
- ggplot2
- reshape2
- ggpubr
- GAM
chart_types:
- heatmap
- bar
summary: 按“基因×癌症亚型”统计各类型基因组变异（突变/扩增/缺失/融合等）的样本数，画中央色块矩阵加顶部、右侧变异类型频率条的扫雷图。
favorite: false
---
# 泛癌通路基因变异扫雷图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa132alteration` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa132alteration.Rmd`）
- 依赖：CRAN BRCA_Basal, BRCA_Her2, BRCA_LumA, BRCA_LumB, BRCA_Normal, CESC_AdenoCarcinoma, CESC_SquamousCarcinoma, GBM_IDHwt, LGG_IDHwt, SARC_Other, TGCT_seminoma, Total, ggplot2, reshape2
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

按“基因×癌症亚型”统计各类型基因组变异（突变/扩增/缺失/融合等）的样本数，画中央色块矩阵加顶部、右侧变异类型频率条的扫雷图。

## 适用

展示某通路基因集合在多种癌症或亚型中的变异频率格局，如例文RTK-RAS通路的泛癌Figure 4。

## 不适用

强绑定例文三个xlsx补充表结构（GAM变异矩阵/通路基因表/样本信息表，按sheet读取）；癌症顺序、器官分组、OG/TSG标注均写死需手改；数值与原文有出入。

## 输入

- `NIHMS957693-supplement-5.xlsx`：NIHMS957693-supplement-5.xlsx，TCGA里所有sample的信息，包括disease和subtype。
- `NIHMS957693-supplement-7.xlsx`：NIHMS957693-supplement-7.xlsx，作者整理的重要pathway所包含的基因，共187个。例文Figure 4画的是RTK RAS，因此读取相应的sheet“RTK RAS”。如果画**其他pathway，读取对应的sheet即可**。
- `NIHMS957693-supplement-8.xlsx`：NIHMS957693-supplement-8.xlsx，TCGA里9千多个sample里187个基因发生的alteration，三个sheet分别是alteration层面、gene层面和pathway层面。如果想知道这三个sheet是怎样获得的，看method里的Generation of Genomic Alteration Matrices (GAMs)。

NIHMS957693-supplement-8.xlsx三个sheet依次为alteration/gene/pathway层矩阵（行名均为SAMPLE_BARCODE）；-7按通路sheet取基因；-5提供DISEASE+SUBTYPE。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-132alteration`
- 用到课题：`wiki.py use figureya-132alteration --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `alteration.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
