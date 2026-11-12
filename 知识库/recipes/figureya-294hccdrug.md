---
type: recipe
id: figureya-294hccdrug
title: 药物靶点相关性火山图
status: draft
source:
  id: figureya
  item: FigureYa294HCCdrug
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa294HCCdrug.Rmd
inputs:
- file: table s10 target.txt
  note: ''
- file: table s3 pps.txt
  note: ''
- file: LIHC-CN-TPM.subset.txt
  note: ''
- file: LIHC-CN-MAF.subset.txt
  note: ''
- file: LIHC-CN-SINFO.txt
  note: ''
- file: LIHC-CN-Proteome.subset.txt
  note: ''
- file: sample_info.csv
  note: ''
outputs:
- correlation between proteome and pps in china cohort.pdf
- correlation between ceres and pps in ccle dataset.pdf
- combined plot.pdf
packages:
  cran:
  - cowplot
  - ggplot2
  - ggrepel
  - readr
  bioc: []
  github: []
  library:
  - readr
  - ggplot2
  - ggrepel
  - cowplot
  namespaced:
  - knitr
tags:
- computational-drug-design
- proteomics
keywords:
- DepMap
- CCLE
- CERES
- CRISPR
- PPS
- Spearman
- ggrepel
- cowplot
- readr
chart_types:
- volcano
- scatter
summary: 算基因集评分（示例PPS）与临床蛋白组、细胞系CRISPR CERES得分的Spearman相关，火山图筛显著靶点加散点图展示相关细节。
favorite: false
---
# 药物靶点相关性火山图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa294HCCdrug` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa294HCCdrug.Rmd`）
- 依赖：CRAN cowplot, ggplot2, ggrepel, readr
- 最近运行：fail（as-is，2026-11-11 06:09 UTC，3.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

算基因集评分（示例PPS）与临床蛋白组、细胞系CRISPR CERES得分的Spearman相关，火山图筛显著靶点加散点图展示相关细节。

## 适用

为特定亚型或高评分患者寻找潜在药物靶点，可用自定义基因集替换PPS。

## 不适用

需肿瘤表达谱+配对蛋白组+DepMap表达/CERES/突变/注释多表齐备；筛选阈值硬编码（r>0.3、r<-0.5）；示例只处理TP53突变肝癌细胞系。

## 输入

- ⚠️ 本配方部分输入为**合成输入**（格式相符的构造数据），仅用于执行验证，不构成真实数据分析结论；明细见 `repair/SYNTHETIC_INPUTS.md`。
- `table s10 target.txt`：见 Rmd“输入文件”节
- `table s3 pps.txt`：见 Rmd“输入文件”节
- `LIHC-CN-TPM.subset.txt`：见 Rmd“输入文件”节
- `LIHC-CN-MAF.subset.txt`：见 Rmd“输入文件”节
- `LIHC-CN-SINFO.txt`：见 Rmd“输入文件”节
- `LIHC-CN-Proteome.subset.txt`：见 Rmd“输入文件”节
- `sample_info.csv`：见 Rmd“输入文件”节
- `CCLE_expression.csv`：见 Rmd“输入文件”节
- `CRISPR_gene_effect.csv`：见 Rmd“输入文件”节
- `CCLE_mutations.csv`：见 Rmd“输入文件”节

临床队列需表达谱（行=基因）+蛋白组+样本信息表且样本互相对应；DepMap矩阵行=细胞系、列名含"基因 (Entrez)"需拆列名。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-294hccdrug`
- 用到课题：`wiki.py use figureya-294hccdrug --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：CCLE_expression.csv、CRISPR_gene_effect.csv、CCLE_mutations.csv等大文件需从DepMap门户手工下载（快照未含，仅sample_info.csv）。

## 输出

- `correlation between proteome and pps in china cohort.pdf`
- `correlation between ceres and pps in ccle dataset.pdf`
- `combined plot.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]] · [[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
