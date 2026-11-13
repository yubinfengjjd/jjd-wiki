---
type: recipe
id: figureya-67phastcons
title: 基因组区域保守性曲线
status: draft
source:
  id: figureya
  item: FigureYa67phastCons
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa67phastCons.Rmd
inputs:
- file: all_dsDMR.bed
  note: all_dsDMR.bed, non_exon_dsDMR.bed, download from <https://epigenome.wustl.edu/Zebrafish_DNAme/browse.php>
- file: non_exon_dsDMR.bed
  note: all_dsDMR.bed, non_exon_dsDMR.bed, download from <https://epigenome.wustl.edu/Zebrafish_DNAme/browse.php>
- file: random.bed
  note: random.bed, random regions generation (randomBed -l 500 -n 8225 -seed 6666
    -g danRer7.chrom.sizes > random.bed)
- file: average_signal.csv
  note: ''
outputs: []
packages:
  cran:
  - all_dsDMR.bed
  - fish.phastCons8way.bw
  - indianred3
  - non_exon_dsDMR.bed
  - random.bed
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
  - data.table
tags:
- multi-omics
keywords:
- phastCons
- bigWig
- bigWigSummary
- UCSC
- bedtools
chart_types:
- trend
summary: 提取bed区域中心±5kb的phastCons bigWig信号（调Python脚本与awk汇总），画多组区域的平均保守性profile曲线。
favorite: false
---
# 基因组区域保守性曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa67phastCons` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa67phastCons.Rmd`）
- 依赖：CRAN all_dsDMR.bed, fish.phastCons8way.bw, indianred3, non_exon_dsDMR.bed, random.bed
- 最近运行：fail（as-is，2026-11-04 11:19 UTC，20.1 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

提取bed区域中心±5kb的phastCons bigWig信号（调Python脚本与awk汇总），画多组区域的平均保守性profile曲线。

## 适用

比较DMR、ChIP-seq peak等功能区域与随机区域在序列保守性上的差异。

## 不适用

仅支持Linux/Mac，依赖awk、python2.7、UCSC bigWigSummary二进制和本地getBigWigValue.py；phastCons bw与bed文件需按物种基因组手动下载。

## 输入

- ⚠️ 本配方部分输入为**合成输入**（格式相符的构造数据），仅用于执行验证，不构成真实数据分析结论；明细见 `repair/SYNTHETIC_INPUTS.md`。
- `all_dsDMR.bed`：all_dsDMR.bed, non_exon_dsDMR.bed, download from <https://epigenome.wustl.edu/Zebrafish_DNAme/browse.php>
- `non_exon_dsDMR.bed`：all_dsDMR.bed, non_exon_dsDMR.bed, download from <https://epigenome.wustl.edu/Zebrafish_DNAme/browse.php>
- `random.bed`：random.bed, random regions generation (randomBed -l 500 -n 8225 -seed 6666 -g danRer7.chrom.sizes > random.bed)
- `fish.phastCons8way.bw`：fish.phastCons8way.bw，保守性文件，下载的步骤：
- `temp_signal_rev.txt`：见 Rmd“输入文件”节
- `average_signal.csv`：见 Rmd“输入文件”节

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-67phastcons`
- 用到课题：`wiki.py use figureya-67phastcons --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：系统需awk+python2.7环境；bigWigSummary按平台从UCSC下载并chmod；随机区域用bedtools randomBed生成；bed与bw基因组版本须一致。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-12：作者 jb 接受的结论是 repair-pass，不是 as-is pass。最新 as-is 收据 `runs/20261104T111903Z.json` 仍为 fail，原因是缺输入文件（File 'temp_signal_rev.txt' does not exist or is non-readable）。修补副本收据 `repair-runs/20261111T064717Z.json`（scope=repair）为 pass，只证明修补副本在记录环境可执行。catalog 的 `run` 保持该 as-is 收据的 fail，不改成 pass。

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
