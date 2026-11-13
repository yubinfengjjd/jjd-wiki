---
type: recipe
id: figureya-323stpathseq
title: 空间转录组微生物分布图
status: ready
source:
  id: figureya
  item: FigureYa323STpathseq
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa323STpathseq.Rmd
inputs:
- file: sample_sheet.csv
  note: 在InputData/sample_sheet.csv文件中写入样本信息，包括sample、slide、area。
outputs: []
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- single-cell
keywords:
- PathSeq
- GATK
- Space Ranger
- 10x Visium
- microbiome
- fastq
- BWA
chart_types:
- spatial-map
summary: 记录一条shell流水线：Space Ranger处理Visium fastq与切片图像，GATK PathSeq提取微生物UMI，后处理输出组织内细菌总信号的
favorite: false
---
# 空间转录组微生物分布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa323STpathseq` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa323STpathseq.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:13 UTC，7.2 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

记录一条shell流水线：Space Ranger处理Visium fastq与切片图像，GATK PathSeq提取微生物UMI，后处理输出组织内细菌总信号的空间分布PDF。

## 适用

空间转录组测序样本制备时保留了非人源reads，想挖掘组织内微生物的空间分布（例文为OSCC/CRC）。

## 不适用

仅在样本含可提取微生物reads时可用，绝大多数公共ST数据集不满足条件；本Rmd只是流程文档，真正计算靠bash脚本而非R代码。

## 输入

- `.fastq.gz`：InputData/CRC_16/CRC_16_*.fastq.gz
- `sample_sheet.csv`：在InputData/sample_sheet.csv文件中写入样本信息，包括sample、slide、area。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-323stpathseq`
- 用到课题：`wiki.py use figureya-323stpathseq --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需Space Ranger、GATK4（gatk命令或java -Xmx100G -jar gatk.jar）、BWA、Python后处理脚本及约150G参考库（BuildReference.sh用wget下载）；内存≥200G、可用存储≥300G。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
