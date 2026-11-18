---
type: method
id: genomic-epigenomic-landscape
title: 基因组突变、CNV 与表观遗传图谱
status: ready
tags:
- multi-omics
data_domains:
- genomics-epigenomics
inputs: []
outputs: []
render_bridges: []
source:
  kind: written
license: none
cite:
- 'Mayakonda A, et al. Maftools: efficient and comprehensive analysis of somatic variants
  in cancer. Genome Research, 2018.'
- Mermel CH, et al. GISTIC2.0 facilitates sensitive and confident localization of
  the targets of focal somatic copy-number alteration in human cancers. Genome Biology,
  2011.
- 'Blokzijl F, et al. MutationalPatterns: comprehensive genome-wide analysis of mutational
  processes. Genome Medicine, 2018.'
favorite: false
method_kind: analysis
purposes:
- 变异与表观调控
summary: 涵盖体细胞突变景观（oncoplot / TMB / TiTv / 共现互斥 / COSMIC 突变签名）、拷贝数变异（GISTIC CNV）、DNA
  甲基化年龄/差异及 ChIP-seq/bigWig 信号轨迹分析；本库当前以参考配方形式组织，未封装独立可执行方法闭包。
data_contract:
  input: 体细胞突变 MAF 文件、GISTIC 拷贝数矩阵、甲基化芯片 Beta 矩阵或基因组 bigWig/BED 区间轨及样本分组信息。
  output: 高频突变频率表、TMB 与碱基替换谱、COSMIC 签名权重、显著 CNV 区域/基因变异景观及表观信号曲线数据。
keywords:
- oncoplot
- MAF
- maftools
- TMB
- CNV
- GISTIC
- methylation
- ChIP-seq
- mutational signature
- 基因组变异
- 表观遗传
figure_relations: []
next_steps:
- direction: 方向 1：高频突变或 CNV 状态驱动的转录组表达差异检验
  when: 识别关键驱动突变基因或拷贝数扩增/缺失后，检验其对下游基因表达或通路活性的顺式/反式影响时
  analysis_templates:
  - methods/differential-expression
  - recipes/figureya-129tcgabox
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/bulk-de-volcano
- direction: 方向 2：肿瘤突变负荷（TMB）/通路突变评分与生存预后建模
  when: 评估高/低 TMB、特定突变签名或通路突变评分对患者临床结局的分层价值时
  analysis_templates:
  - methods/survival-prognosis-analysis
  - recipes/figureya-305pmapscore
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
- direction: 方向 3：基因组变异景观与免疫微环境浸润耦合分析
  when: 分析高频突变/新抗原负荷或 MSI 状态是否与免疫细胞浸润及免疫逃逸特征相关时
  analysis_templates:
  - methods/immune-infiltration-tme
  - recipes/figureya-71ssgsea-update
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/scp-cell-cor-heatmap
---
# 基因组突变、CNV 与表观遗传图谱

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Mayakonda A, et al. Maftools: efficient and comprehensive analysis of somatic variants in cancer. Genome Research, 2018.；Mermel CH, et al. GISTIC2.0 facilitates sensitive and confident localization of the targets of focal somatic copy-number alteration in human cancers. Genome Biology, 2011.；Blokzijl F, et al. MutationalPatterns: comprehensive genome-wide analysis of mutational processes. Genome Medicine, 2018.
- 标签：multi-omics
- 分析用途：变异与表观调控
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：高频突变或 CNV 状态驱动的转录组表达差异检验**（触发条件：识别关键驱动突变基因或拷贝数扩增/缺失后，检验其对下游基因表达或通路活性的顺式/反式影响时；中间表：deg-result-table；分析模版：methods/differential-expression、recipes/figureya-129tcgabox；可视化模版：templates/bulk-de-volcano）
  - **方向 2：肿瘤突变负荷（TMB）/通路突变评分与生存预后建模**（触发条件：评估高/低 TMB、特定突变签名或通路突变评分对患者临床结局的分层价值时；中间表：survival-time-event-group；分析模版：methods/survival-prognosis-analysis、recipes/figureya-305pmapscore；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）
  - **方向 3：基因组变异景观与免疫微环境浸润耦合分析**（触发条件：分析高频突变/新抗原负荷或 MSI 状态是否与免疫细胞浸润及免疫逃逸特征相关时；中间表：pathway-score-table；分析模版：methods/immune-infiltration-tme、recipes/figureya-71ssgsea-update；可视化模版：templates/scp-cell-cor-heatmap）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

系统刻画体细胞点突变/插入缺失（MAF）、肿瘤突变负荷（TMB）、COSMIC 三核苷酸突变签名、体细胞拷贝数变异（GISTIC2 CNV）、DNA 甲基化（如甲基化年龄加速与表观调控）及 ChIP-seq / ATAC-seq 基因组区间信号分布。

## 适用

- 统一参考基因组版本（hg19 vs hg38）下的 WES/WGS 体细胞突变 MAF、SNP6/WES 拷贝数片段或 450K/EPIC 甲基化 Beta 值矩阵。
- 拥有标准化信号轨（bigWig）与明确区域注释（BED）的染色质修饰或转录因子结合富集分析。
- 多组学分子分型中需要将突变、CNV 与转录/免疫/临床特征联合注释的场景。

## 不适用

- **混用不同参考基因组版本或捕获区域口径**：未核对外显子捕获区间大小（如 38 Mb vs 50 Mb）即直接跨队列比较 TMB 数值。
- **忽略肿瘤纯度与倍性**：在低纯度样本中未考虑测序深度与纯度限制而武断解释低频突变或 CNV 缺失。
- **把相关性当作表观因果调控**：仅凭甲基化与表达负相关即断言表观沉默因果机制。

## 输入

标准输入材料依具体子任务而定：MAF 体细胞突变注释表、GISTIC `all_thresholded.by_genes.txt`、甲基化 Beta 值矩阵或 ChIP-seq/bigWig 与 BED 区间文件（本页 `inputs` 暂留空以适配多类基因组输入格式）。

## 怎么做

1. **核对参考基因组与样本条码**：确认 hg19/hg38 一致性，统一 TCGA/队列样本 ID 截取粒度（如患者级 vs 样本级）。
2. **变异/信号定量**：使用 `maftools` / `MutSigCV` 计算高频突变、TMB、Ti/Tv 与共现互斥（DISCOVER）；使用 `deconstructSigs` + NMF 分解突变签名；使用 `GISTIC2` 或 `ChAMP` 处理 CNV 与甲基化。
3. **多维度整合注释**：按分子亚型或通路分组汇总变异事件，并检验与表达谱、免疫浸润及生存结局的关联。

## 代码

本锚点页当前尚未封装独立可运行的本库分析模块（状态为 `not_run`）。库内已收录丰富的基因组与表观遗传参考源码配方：
- 突变瀑布图、TMB、共现互斥与突变签名：[[recipes/figureya-18oncoplot-update]]、[[recipes/figureya-42oncoprintv2-update]]、[[recipes/figureya-113mutsigcv]]、[[recipes/figureya-139tmb-titv]]、[[recipes/figureya-70mutationevents]]、[[recipes/figureya-110mutationsignature]]、[[recipes/figureya-19lollipop]]
- CNV、多组学景观与通路突变评分：[[recipes/figureya-307cnvheatmap]]、[[recipes/figureya-248mutlandscape]]、[[recipes/figureya-132alteration]]、[[recipes/figureya-305pmapscore]]、[[recipes/figureya-45v2]]
- 甲基化与基因组区间信号轨：[[recipes/figureya-215dnaage]]、[[recipes/figureya-3genomeview]]、[[recipes/figureya-44profile]]、[[recipes/figureya-57profile-1bw]]、[[recipes/figureya-67phastcons]]、[[recipes/figureya-10chromosomev2-update]]、[[recipes/figureya-14circos]]

## 输出

本页暂无统一标准化接口输出（`outputs: []`）；各上游工作流产出突变频率矩阵、COSMIC 签名权重表、CNV 阈值矩阵或区域信号均值矩阵供下游关联分析或专用绘图脚本消费。

## 知识关联检查

库内现存 31 个交互/参数化单 panel 模板主要面向单细胞、通用集合与预后模型，`oncoprint` / `genome-track` 等基因组专用图形目前均以 FigureYa 源码配方形式沉淀于 `wiki/recipes/`（见上节清单），尚未拆分为独立 `templates/*` 单 panel 模板，故本页不虚构 `figure_relations`。

## 使用记录

<!-- user:start -->
<!-- user:end -->
