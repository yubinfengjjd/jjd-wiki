---
type: method
id: drug-sensitivity-repositioning
title: 药物敏感性预测、CMap 重定位与靶点关联分析
status: ready
tags:
- computational-drug-design
- network-pharmacology
- transcriptomics
data_domains:
- bulk-transcriptomics
- multi-omics
inputs:
- bulk-de-table
- candidate-biomarker-list
outputs:
- subgroup-effect-table
render_bridges: []
source:
  kind: written
license: none
cite:
- Subramanian A, et al. A Next Generation Connectivity Map (CMap) L1000 Platform and the First 1,000,000 Profiles. Cell, 2017.
- Maeser D, Gruener RF, Huang RS. oncoPredict: an R package for predicting in vivo or cancer patient drug response and biomarkers from cell line screening data. Briefings in Bioinformatics, 2021.
favorite: false
method_kind: analysis
purposes:
- 差异与功能分析
summary: 基于临床/分子亚型表达谱与体外细胞系药敏数据（GDSC/CTRP/PRISM）预测患者亚组药物敏感性（IC50/AUC 估计），或基于疾病上下调特征基因对接 Connectivity Map (CMap) 筛选潜在小分子重定位化合物与靶点关联；本库尚未封装独立可执行实现。
data_contract:
  input: 组间差异基因表达特征 bulk-de-table（供 CMap 富集）、临床队列标准化表达谱（供 pRRophetic/oncoPredict 药敏预测）及候选靶点基因 list candidate-biomarker-list。
  output: subgroup-effect-table（各亚组/高风险组预测药物反应差异统计量，或 CMap 化合物逆转富集评分与机制 MoA）。
keywords:
- CMap
- drug sensitivity
- pRRophetic
- oncoPredict
- GDSC
- CTRP
- drug repositioning
- 药敏预测
- 药物重定位
figure_relations: []
next_steps:
- direction: 方向 1：联合高风险亚组生存特征筛选获益人群
  when: 验证候选药物敏感组或目标基因抑制表型与患者临床预后的关系时
  analysis_templates:
  - methods/survival-prognosis-analysis
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
- direction: 方向 2：探索候选药物靶点在共表达/PPI 网络中的拓扑位置
  when: 进一步分析敏感药物对应靶蛋白在核心互作模块或信号通路中的协同调控角色时
  analysis_templates:
  - methods/coexpression-ppi-network
  - methods/gene-set-enrichment
  intermediate_interface: highlight-gene-sets
  viz_templates: []
---
# 药物敏感性预测、CMap 重定位与靶点关联分析

<!-- facts:start -->
<!-- facts:end -->

## 用途

将转录组分子分型、高/低风险分组或疾病差异表达特征转化为治疗敏感性假设：通过细胞系药物筛选参考库（GDSC / CTRP / PRISM）估算组织队列的体外药物半数抑制浓度趋势（`oncoPredict`/`pRRophetic`），或通过 CMap 查询可逆转疾病基因表达谱的潜在候选小分子与作用机制（MoA）。

## 适用

- 已经完成差异表达分析（具备高质量 Top 150 上/下调基因签名）用于 CMap 化合物检索与泛癌化合物 MoA 汇总。
- 拥有标准化组织 RNA-seq/芯片表达谱且平台基因覆盖度满足药敏训练集要求的亚组药物反应比较。

## 不适用

- **将细胞系回归模型预测值直接当成真实临床有效率或具体给药剂量（IC50 绝对值）**。
- **跨瘤种混杂对比而未校正组织谱系效应或样本质量**。
- **输入基因签名过短或随机噪声基因导致 CMap 富集结果不可重复**。

## 输入

关联 [[interfaces/bulk-de-table|Bulk 差异表达结果表]]（上下调特征基因签名）、[[interfaces/candidate-biomarker-list|核心候选标志物列表]] 以及统一归一化的临床队列与药物参考表达矩阵。

## 怎么做

1. **特征构建或药敏建模**：CMap 分支提取差异显著的上下调基因（通常各 100–150 个）提交 CLUE/CMap 查询连接分数（Connectivity Score）及 MoA 分类；药敏分支确保测试队列与 GDSC/CTRP 训练集基因交集并做均值中心化处理后运行岭回归预测。
2. **组间差异检验**：按分子亚型、风险分组或关键基因高低表达对比各组预测敏感性与药物-靶点相关性（Wilcoxon + FDR 校正）。
3. **多证据交叉**：筛选在 CMap 负相关逆转强、组间 IC50/AUC 预测差异显著且具备蛋白靶点关联证据的候选药物。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块。请参考下方的 FigureYa L1 参考源码配方（`figureya-131cmap-update`、`figureya-212drugtargetv2`、`figureya-294hccdrug`）查看 CMap 化合物富集、亚组药敏预测与药物靶点火山图源码。

## 输出

输出 [[interfaces/subgroup-effect-table|分组药物敏感性与富集效应表]]，同时记录参考药敏库版本、基因匹配比例与计算假设边界。

## 参数

- `drug_reference`：GDSC1 / GDSC2 / CTRP / PRISM / CMap L1000。
- `signature_size`：CMap 上下调输入基因数阈值。
- `batchCorrect`：训练集与测试队列的标准化方式（如 `eb` / `qn` / `standardize`）。

## 上一步 / 下一步

- 上一步通常衔接 [[methods/differential-expression]]、[[methods/molecular-subtyping-clustering]] 或 [[methods/survival-prognosis-analysis]]；下游可接入 [[methods/coexpression-ppi-network]] 与 [[methods/gene-set-enrichment]]。

## 知识关联检查

已核对输入接口 [[interfaces/bulk-de-table]]、[[interfaces/candidate-biomarker-list]] 与输出接口 [[interfaces/subgroup-effect-table]] 的命名一致；同时明确区分细胞系回归预测值与真实临床药效证据边界。

## 使用记录

<!-- user:start -->
<!-- user:end -->
