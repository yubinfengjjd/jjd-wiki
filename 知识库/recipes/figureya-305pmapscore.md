---
type: recipe
id: figureya-305pmapscore
title: KEGG通路突变预后评分图
status: draft
source:
  id: figureya
  item: FigureYa305PMAPscore
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa305PMAPscore.Rmd
inputs: []
outputs: []
packages:
  cran:
  - PMAPscore
  - remotes
  bioc:
  - SPIA
  - ComplexHeatmap
  - KEGGREST
  github: []
  library:
  - PMAPscore
  - ComplexHeatmap
  - KEGGREST
  - SPIA
  namespaced:
  - knitr
  - dplyr
tags:
- multi-omics
- survival-analysis
keywords:
- PMAPscore
- iPMP
- KEGGREST
- SPIA
- ComplexHeatmap
- kgml
chart_types:
- km-curve
- roc
- heatmap
- waterfall
summary: 按KEGG通路拓扑把样本突变基因加权成通路PFS评分（iPMP/PMAPscore），筛预后相关通路签名计算风险得分，画KM曲线、ROC、通路oncoplot与
favorite: false
---
# KEGG通路突变预后评分图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa305PMAPscore` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa305PMAPscore.Rmd`）
- 依赖：CRAN PMAPscore, remotes；Bioconductor SPIA, ComplexHeatmap, KEGGREST
- 最近运行：fail（as-is，2026-11-04 12:16 UTC，15.1 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

按KEGG通路拓扑把样本突变基因加权成通路PFS评分（iPMP/PMAPscore），筛预后相关通路签名计算风险得分，画KM曲线、ROC、通路oncoplot与评分热图。

## 适用

有队列maf突变+生存+分组数据，想用WES/突变数据做全KEGG通路水平预后评分（把原文120+通路扩展到200+）。

## 不适用

输入件多且格式固定（maf对象、基因单变量Cox结果、生存表、symbol-Entrez对应表、sample/response分组表）；通路必须kgml/SPIA格式，msigdb基因集不能直接用；分组cut_off写死。

## 输入

- 见 Rmd“输入文件”节（适配器未识别出文件名）。

示例直接用PMAPscore自带数据（maffile/gene_Ucox_res/sur/gene_symbol_Entrez/roc_data）；sur行名须与maf样本名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-305pmapscore`
- 用到课题：`wiki.py use figureya-305pmapscore --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：首次需联网从rest.kegg.jp批量下载全部通路kgml并用makeSPIAdata生成hsaSPIA.RData（eval=FALSE只跑一次，快照已含结果文件）；需同目录修正脚本utils.R。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]] · [[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
