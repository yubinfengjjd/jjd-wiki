---
type: recipe
id: figureya-311pam50heatmap
title: PAM50分型签名注释热图
status: draft
source:
  id: figureya
  item: FigureYa311PAM50Heatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa311PAM50Heatmap.Rmd
inputs:
- file: easyinput_signature.txt
  note: easyinput_signature.txt，基因签名，用于计算图中的Molecular signature scores ，即AR、NE、CCP、FGF-MEK签名。出自ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx里的Table
    S13。可以替换成自己感兴趣的签名。
- file: easyinput_clin.txt
  note: easyinput_clin.txt，样本分组信息，对应图中的Phenotype。其中Sample列里是样本名，跟表达矩阵的列名一致。出自ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx里的Table
    S1。可以替换成自己想要对比展示的注释信息。
outputs:
- logFC.PAM50Heatmap.pdf
packages:
  cran:
  - genefu
  - AnnotationDbi
  - org.Hs.eg.db
  - GSVA
  - ComplexHeatmap
  - circlize
  bioc:
  - genefu
  - AnnotationDbi
  - org.Hs.eg.db
  - GSVA
  - ComplexHeatmap
  - circlize
  github: []
  library:
  - genefu
  - AnnotationDbi
  - org.Hs.eg.db
  - GSVA
  - ComplexHeatmap
  - circlize
  namespaced:
  - knitr
tags:
- transcriptomics
- machine-learning
keywords:
- genefu
- PAM50
- GSVA
- ComplexHeatmap
- circlize
- AnnotationDbi
- org.Hs.eg.db
chart_types:
- heatmap
summary: genefu的PAM50（裁剪为LumA/LumB/Basal）预测样本内在亚型，GSVA算AR/NE/CCP/FGF-MEK签名得分，ComplexHeatm
favorite: false
---
# PAM50分型签名注释热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa311PAM50Heatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa311PAM50Heatmap.Rmd`）
- 依赖：CRAN genefu, AnnotationDbi, org.Hs.eg.db, GSVA, ComplexHeatmap, circlize；Bioconductor genefu, AnnotationDbi, org.Hs.eg.db, GSVA, ComplexHeatmap, circlize
- 最近运行：pass（as-is，2026-11-04 12:17 UTC，83.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-311pam50heatmap/preview.png]]
<!-- facts:end -->

## 用途

genefu的PAM50（裁剪为LumA/LumB/Basal）预测样本内在亚型，GSVA算AR/NE/CCP/FGF-MEK签名得分，ComplexHeatmap画PAM50基因热图并叠加多层注释。

## 适用

表达谱样本需要做内在分子分型，并在一张热图上同时展示亚型、多个签名得分和表型注释。

## 不适用

基因须为Gene Symbol且经org.Hs.eg.db映射ENTREZID（限人类）；示例把5个亚型裁成3个，换亚型集要改centroids、levels和配色；clin的Sample必须与表达矩阵列名一致。

## 输入

- `data_mrna_seq_fpkm_polya.txt`：data_mrna_seq_fpkm_polya.txt，表达矩阵。
- `easyinput_signature.txt`：easyinput_signature.txt，基因签名，用于计算图中的Molecular signature scores ，即AR、NE、CCP、FGF-MEK签名。出自ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx里的Table S13。可以替换成自己感兴趣的签名。
- `easyinput_clin.txt`：easyinput_clin.txt，样本分组信息，对应图中的Phenotype。其中Sample列里是样本名，跟表达矩阵的列名一致。出自ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx里的Table S1。可以替换成自己想要对比展示的注释信息。
- `ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx`：easyinput_signature.txt，基因签名，用于计算图中的Molecular signature scores ，即AR、NE、CCP、FGF-MEK签名。出自ccr-21-4289_supplementary_tables_ts1-13_suppts1-13.xlsx里的Table S13。可以替换成自己感兴趣的签名。

表达矩阵行名Hugo_Symbol、列为样本（示例从zip内unz读取）；signature表含Signature/Gene.Symbol两列；clin表含Sample及表型列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-311pam50heatmap`
- 用到课题：`wiki.py use figureya-311pam50heatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `logFC.PAM50Heatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
