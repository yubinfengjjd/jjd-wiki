---
type: method
id: bulk-expression-preprocessing
title: Bulk 转录组表达定量、探针重注释与批次校正
status: ready
tags:
- transcriptomics
data_domains:
- bulk-transcriptomics
inputs: []
outputs: []
render_bridges: []
source:
  kind: written
license: none
cite:
- Conesa A, et al. A survey of best practices for RNA-seq data analysis. Genome Biology,
  2016.
- Johnson WE, et al. Adjusting batch effects in microarray expression data using empirical
  Bayes methods (ComBat). Biostatistics, 2007.
favorite: false
method_kind: analysis
purposes:
- 预处理与质量控制
- 整合与批次校正
summary: 完成 Bulk RNA-seq 原始 Counts 向 TPM/FPKM 的标化换算、芯片探针向 Gene Symbol/lncRNA 的重注释、子集表达矩阵提取与多队列
  ComBat 批次效应校正；本库当前作为分析规范锚点与 L1 参考配方索引，尚未封装独立可执行实现。
data_contract:
  input: 原始基因计数矩阵（Raw Counts）、GEO/芯片探针矩阵或待合并的多队列表达谱，配对有效基因长度（GTF/外显子总长）与真实批次标签。
  output: 尺度统一的标准化表达矩阵（Counts 供差异检验，TPM/log-TPM 供跨样本/热图比较与去卷积，含明确的样本分组与批次注释）。
keywords:
- TPM
- FPKM
- ComBat
- batch effect
- probe reannotation
- lncRNA
- 表达定量
- 批次校正
figure_relations: []
next_steps:
- direction: 方向 1：进入组间差异表达分析（使用原始 Counts）
  when: 完成探针重注释或筛选出目标队列后，进行两两或临床分组差异表达检验时
  analysis_templates:
  - methods/differential-expression
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/bulk-de-volcano
- direction: 方向 2：肿瘤微环境与免疫浸润评估（使用线性 TPM）
  when: 表达矩阵已转换为非负线性 TPM 且消除跨队列批次后，推断免疫与基质细胞浸润丰度时
  analysis_templates:
  - methods/immune-infiltration-tme
  intermediate_interface: pathway-score-table
  viz_templates: []
- direction: 方向 3：构建 WGCNA 共表达网络或分子分型聚类
  when: 对归一化与批次校正后的表达矩阵识别共表达基因模块或无监督患者亚型时
  analysis_templates:
  - methods/coexpression-ppi-network
  - methods/molecular-subtyping-clustering
  intermediate_interface: candidate-biomarker-list
  viz_templates: []
---
# Bulk 转录组表达定量、探针重注释与批次校正

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Conesa A, et al. A survey of best practices for RNA-seq data analysis. Genome Biology, 2016.；Johnson WE, et al. Adjusting batch effects in microarray expression data using empirical Bayes methods (ComBat). Biostatistics, 2007.
- 标签：transcriptomics
- 分析用途：预处理与质量控制、整合与批次校正
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：进入组间差异表达分析（使用原始 Counts）**（触发条件：完成探针重注释或筛选出目标队列后，进行两两或临床分组差异表达检验时；中间表：deg-result-table；分析模版：methods/differential-expression；可视化模版：templates/bulk-de-volcano）
  - **方向 2：肿瘤微环境与免疫浸润评估（使用线性 TPM）**（触发条件：表达矩阵已转换为非负线性 TPM 且消除跨队列批次后，推断免疫与基质细胞浸润丰度时；中间表：pathway-score-table；分析模版：methods/immune-infiltration-tme；可视化模版：无）
  - **方向 3：构建 WGCNA 共表达网络或分子分型聚类**（触发条件：对归一化与批次校正后的表达矩阵识别共表达基因模块或无监督患者亚型时；中间表：candidate-biomarker-list；分析模版：methods/coexpression-ppi-network、methods/molecular-subtyping-clustering；可视化模版：无）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

规范 Bulk RNA-seq 与基因芯片表达谱分析前的数据准备流程：区分用于假设检验的原始 Counts 与用于横向展示/去卷积的 TPM 标化，处理跨平台探针重注释（如蛋白编码基因与 lncRNA 分离），并在合并多中心队列前评估与校正批次效应。

## 适用

- 原始 Counts 矩阵按有效基因外显子长度与测序深度转换为 TPM/FPKM。
- GEO/Affymetrix/Agilent 芯片探针按最新 GENCODE/Ensembl GTF 重注释为标准化 Symbol 与基因生物类型。
- 已知技术批次（平台、中心、测序批）与目标生物学变量非完全共线性时的 ComBat 批次调整。

## 不适用

- **将 TPM/FPKM 或 ComBat 校正后矩阵直接喂给 DESeq2/edgeR**：离散计数统计模型必须接收原始整数 Counts（并将批次作为设计矩阵协变量纳入模型）。
- **组别与批次完全混杂时强行 ComBat**：会抹除真实生物学差异或制造假阳性信号。
- **把基因长度缺失或混合基因组版本的注释直接做跨队列合并**。

## 输入

原始 RNA-seq Counts（含样本注释与 GTF 基因长度）或带有明确平台编号（GPL）与样本批次标签的芯片表达矩阵。

## 怎么做

1. **单位与生物型规范**：Counts 仅保留整数原始读数用于差异分析；可视化与免疫去卷积统一转换为 TPM；通过 GTF `gene_biotype` 准确区分 mRNA 与 lncRNA。
2. **重复探针折叠**：同一基因对应多条探针时记录清晰聚合规则（如均值、中位数或 IQR 最大值）并检查平台映射覆蓋率。
3. **批次核查与校正**：先通过 PCA 评估批次结构，确认实验分组与批次存在交叉样本后再运行 `sva::ComBat` 或在下游线性模型中纳入批次协变量，并复查校正前后分布与主成分变化。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块。请参考下方的 FigureYa L1 参考源码配方（如 `figureya-23count2tpm`、`figureya-34count2fpkmv2`、`figureya-41geo2lncrna-update`、`figureya-58lncrnareannotation`、`figureya-203combat`）执行表达量换算、探针重注释与批次校正。

## 输出

标准化且注释口径一致的 Bulk 表达矩阵与样本元数据表（明确区分统计检验用 Counts 与展示/下游打分用 TPM/log2-TPM）。

## 参数

- `normalization_scale`：明确区分 `raw_counts`、`TPM` 与 `log2(TPM + 1)`。
- `probe_collapse`：多探针映射同一基因时的折叠策略（如 `max_iqr` 或 `mean`）。
- `batch_variable` 与 `mod`：批次校正时必须声明需保护的生物学协变量矩阵，避免吞并分组效应。

## 上一步 / 下一步

- 确定研究分组后衔接 [[methods/differential-expression]] 进行差异检验，或衔接 [[methods/immune-infiltration-tme]]、[[methods/coexpression-ppi-network]]、[[methods/molecular-subtyping-clustering]] 进行微环境评估、共表达网络与分型聚类。

## 知识关联检查

已核对本方法作为 Bulk 转录组上游数据准备锚点的边界：不产出虚构标准接口文件，仅通过 `next_steps` 显式衔接 [[methods/differential-expression]]、[[methods/immune-infiltration-tme]]、[[methods/coexpression-ppi-network]] 与 [[methods/molecular-subtyping-clustering]]，并在 `wiki/recipes/method-map.json` 挂接对应 L1 参考配方。

## 使用记录

<!-- user:start -->
<!-- user:end -->
