---
type: method
id: immune-infiltration-tme
title: 肿瘤微环境与免疫浸润评估
status: ready
tags:
- transcriptomics
- multi-omics
data_domains:
- bulk-transcriptomics
- multi-omics
inputs:
- bulk-de-table
outputs:
- pathway-score-table
render_bridges: []
source:
  kind: written
license: none
cite:
- Newman AM, et al. Robust enumeration of cell subsets from tissue expression profiles
  (CIBERSORT). Nature Methods, 2015.
- Yoshihara K, et al. Inferring tumour purity and stromal and immune cell admixture
  from expression data (ESTIMATE). Nature Communications, 2013.
- Becht E, et al. Estimating the population abundance of tissue-infiltrating immune
  and stromal cell populations using gene expression (MCP-counter). Genome Biology,
  2016.
favorite: false
method_kind: analysis
purposes:
- 细胞通讯与微环境
summary: 基于 Bulk 转录组标准化表达矩阵，采用 CIBERSORT、ssGSEA、MCP-counter、xCell 与 ESTIMATE 等算法估计肿瘤微环境免疫/基质细胞浸润丰度与纯度评分，并与关键基因、分子分型或预后风险关联分析。
data_contract:
  input: 经过统一归一化的 Bulk 表达矩阵（TPM/FPKM 或对数芯片信号）及可选差异对比表 bulk-de-table，配对免疫细胞特征矩阵或基因集。
  output: 样本×免疫细胞/微环境评分表 pathway-score-table（含各算法丰度/富集得分、分组标签及校正 P 值）。
keywords:
- CIBERSORT
- ESTIMATE
- ssGSEA
- MCPcounter
- xCell
- tumor microenvironment
- immune infiltration
- 免疫浸润
- 肿瘤微环境
figure_relations:
- figure: templates/clustered-corr-boxes
  compatibility: adaptable
  reason: Bulk 队列免疫/基质反卷积丰度与细胞亚群特征间的对称层次聚类相关矩阵及对角黑框可作为 default 主推共现相关矩阵。
  prerequisites:
  - 相关系数矩阵须来自同一标准化队列，对称且主对角线为 1；样本量须满足相关检验。
  adaptation: 导出 corr_matrix.csv（首列 feature + N 列对称相关系数，或 tidy 格式 row, col, r）。
  evidence:
  - methods/immune-infiltration-tme.md#输出
  - templates/clustered-corr-boxes/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/checkpoint-group-boxplot
  compatibility: adaptable
  reason: 按高/低免疫基质评分或关键标志物四分位分组的多免疫检查点表达分布及 Wilcoxon 检验可切换为 variant 分组箱线图。
  prerequisites:
  - 分组定义与检验方法（Wilcoxon）在上游明确；展示截断分位数须在图注说明。
  adaptation: 导出 checkpoint_expr.csv（sample_id, gene, group, expression, 可选 pval）。
  evidence:
  - methods/immune-infiltration-tme.md#输出
  - templates/checkpoint-group-boxplot/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/lr-bipartite-bubble
  compatibility: adaptable
  reason: 关键免疫抑制基质亚群（发送群）与耗竭 T 细胞（接收群）间的配受体连线及两端平均表达量（着色）/0–100% 阳性细胞比例（尺寸）可切换为 variant
    双轴连线气泡图；模板不重算检验。
  prerequisites:
  - 须明确发送群与接收群定义，并从单细胞表达矩阵额外汇总两群内配体/受体的平均表达量及 0–100% 阳性细胞比例（分母为各自定义细胞群总细胞数）。
  adaptation: 从配受体清单结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr,
    ligand_pct, receptor_expr, receptor_pct）。
  evidence:
  - methods/immune-infiltration-tme.md#输出
  - templates/lr-bipartite-bubble/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：免疫浸润亚型与临床生存预后关联
  when: 按免疫浸润模式或 ESTIMATE 评分划分微环境亚型后，检验其总生存或无进展生存差异时
  analysis_templates:
  - methods/survival-prognosis-analysis
  - recipes/figureya-211multicohortimmsubtype
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
  - templates/clustered-corr-boxes
  - templates/checkpoint-group-boxplot
  - templates/lr-bipartite-bubble
- direction: 方向 2：高/低免疫浸润组间差异表达与功能富集
  when: 对比高浸润（热肿瘤）与低浸润（冷肿瘤）亚群的差异基因、免疫检查点与富集通路时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/bulk-de-volcano
- direction: 方向 3：回溯单细胞水平解析细胞间通讯与组成重塑
  when: 在单细胞转录组数据中进一步定位 Bulk 推断出的关键免疫细胞亚群及其配受体通讯轴时
  analysis_templates:
  - methods/cell-cell-communication
  - methods/cell-proportion-composition
  intermediate_interface: cellchat-lr-table
  viz_templates:
  - templates/cellchat-circos-multi
---
# 肿瘤微环境与免疫浸润评估

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Newman AM, et al. Robust enumeration of cell subsets from tissue expression profiles (CIBERSORT). Nature Methods, 2015.；Yoshihara K, et al. Inferring tumour purity and stromal and immune cell admixture from expression data (ESTIMATE). Nature Communications, 2013.；Becht E, et al. Estimating the population abundance of tissue-infiltrating immune and stromal cell populations using gene expression (MCP-counter). Genome Biology, 2016.
- 标签：transcriptomics、multi-omics
- 分析用途：细胞通讯与微环境
- 输入接口：[[interfaces/bulk-de-table|bulk 差异表达结果表]]
- 输出接口：[[interfaces/pathway-score-table|通路富集与多算法基因集打分表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：免疫浸润亚型与临床生存预后关联**（触发条件：按免疫浸润模式或 ESTIMATE 评分划分微环境亚型后，检验其总生存或无进展生存差异时；中间表：survival-time-event-group；分析模版：methods/survival-prognosis-analysis、recipes/figureya-211multicohortimmsubtype；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest、templates/clustered-corr-boxes、templates/checkpoint-group-boxplot、templates/lr-bipartite-bubble）
  - **方向 2：高/低免疫浸润组间差异表达与功能富集**（触发条件：对比高浸润（热肿瘤）与低浸润（冷肿瘤）亚群的差异基因、免疫检查点与富集通路时；中间表：deg-result-table；分析模版：methods/differential-expression、methods/gene-set-enrichment；可视化模版：templates/bulk-de-volcano）
  - **方向 3：回溯单细胞水平解析细胞间通讯与组成重塑**（触发条件：在单细胞转录组数据中进一步定位 Bulk 推断出的关键免疫细胞亚群及其配受体通讯轴时；中间表：cellchat-lr-table；分析模版：methods/cell-cell-communication、methods/cell-proportion-composition；可视化模版：templates/cellchat-circos-multi）

- 方法配图关系（语义审查）：
  - [[templates/clustered-corr-boxes|带聚类框与引线的相关矩阵]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：Bulk 队列免疫/基质反卷积丰度与细胞亚群特征间的对称层次聚类相关矩阵及对角黑框可作为 default 主推共现相关矩阵。；前提：相关系数矩阵须来自同一标准化队列，对称且主对角线为 1；样本量须满足相关检验。；适配：导出 corr_matrix.csv（首列 feature + N 列对称相关系数，或 tidy 格式 row, col, r）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/clustered-corr-boxes/spec.json；运行证据：无
  - [[templates/checkpoint-group-boxplot|检查点分组表达箱线图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：按高/低免疫基质评分或关键标志物四分位分组的多免疫检查点表达分布及 Wilcoxon 检验可切换为 variant 分组箱线图。；前提：分组定义与检验方法（Wilcoxon）在上游明确；展示截断分位数须在图注说明。；适配：导出 checkpoint_expr.csv（sample_id, gene, group, expression, 可选 pval）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/checkpoint-group-boxplot/spec.json；运行证据：无
  - [[templates/lr-bipartite-bubble|配受体双轴连线气泡图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：关键免疫抑制基质亚群（发送群）与耗竭 T 细胞（接收群）间的配受体连线及两端平均表达量（着色）/0–100% 阳性细胞比例（尺寸）可切换为 variant 双轴连线气泡图；模板不重算检验。；前提：须明确发送群与接收群定义，并从单细胞表达矩阵额外汇总两群内配体/受体的平均表达量及 0–100% 阳性细胞比例（分母为各自定义细胞群总细胞数）。；适配：从配受体清单结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr, ligand_pct, receptor_expr, receptor_pct）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
<!-- facts:end -->

## 用途

利用 Bulk RNA-seq 或芯片表达谱推断样本中免疫细胞与基质细胞的浸润丰度、肿瘤纯度及免疫调节特征，用于比较不同分子亚型、风险分组或基因组变异状态下的肿瘤微环境（TME）格局。

## 适用

- 具备明确组织来源、相同平台或已去批次的 Bulk 基因表达矩阵（推荐使用 TPM/线性尺度供 CIBERSORT 回归类算法，或样本内排秩供 ssGSEA 类算法）。
- 基因标识（Symbol）覆盖目标特征矩阵（如 LM22、28 种免疫细胞基因集、MCP-counter 基因）的绝大多数基因。
- 需结合多算法交叉验证（如 CIBERSORT + ssGSEA + MCP-counter + ESTIMATE），而非依赖单一算法的单次打分。

## 不适用

- **混用不兼容的尺度前提**：把 log2 变换后的数据或极少基因子集直接喂给假定非负线性混合的 CIBERSORT；或直接跨算法数值混排在同一颜色标尺下比较绝对值。
- **跨样本绝对比例误读**：ssGSEA、MCP-counter 等输出的是相对富集/丰度得分（不可跨不同细胞类型横向比较谁占比更高），只有 CIBERSORT 相对模式输出总和为 1 的比例估计。
- **把去卷积推断等同于流式/单细胞实测计数**。

## 输入

关联 [[interfaces/bulk-de-table|bulk 差异表达结果表]]（或上游标准化的样本×基因表达矩阵）与明确的临床/分子分组表及免疫细胞参考特征库。

## 怎么做

1. **按算法前提准备表达矩阵**：CIBERSORT 使用线性非负 TPM/FPKM（无负数与 NA）；ssGSEA/GSVA/MCP-counter 可用对数表达矩阵；合并多队列前先做 ComBat 等批次核查。
2. **多算法并行推断**：分别计算 CIBERSORT（含置换 P 值过滤）、ESTIMATE（ImmuneScore/StromalScore/TumorPurity）、ssGSEA 及 MCP-counter 得分。
3. **关联分析与统计检验**：检验目标基因/风险评分与免疫细胞得分的 Spearman 相关性，或比较分组间的免疫细胞丰度差异（Wilcoxon/Kruskal-Wallis + FDR 校正）。
4. **整理输出**：将标准化后的微环境得分表输出为 `pathway-score-table`。

## 代码

本锚点页当前尚未封装独立可运行的本库分析模块（状态为 `not_run`）。可参考库内已收录的免疫浸润源码配方：
- 多算法组合热图与分型：[[recipes/figureya-230immunelandscape]]、[[recipes/figureya-211multicohortimmsubtype]]
- ssGSEA / MCPcounter / MeTIL 景观热图：[[recipes/figureya-71ssgsea-update]]、[[recipes/figureya-56immune-inflitrationv3]]、[[recipes/figureya-255time]]
- 基因与免疫浸润相关性：[[recipes/figureya-92immune-gene-update]]、[[recipes/figureya-97correlationv3]]

## 输出

[[interfaces/pathway-score-table|通路富集与多算法基因集打分表]]：记录每个样本或分组在免疫细胞签名与微环境模块上的多算法得分及校正 P 值。

## 知识关联检查

2026-11-19 更新：已接入 Bulk 共现相关矩阵 [[templates/clustered-corr-boxes]]（default）、检查点分组箱线图 [[templates/checkpoint-group-boxplot]] 与双轴配受体气泡图 [[templates/lr-bipartite-bubble]]（均为 adaptable，模板不重算检验）；多算法注释热图仍可参考历史归档模板 [[recipes/figureya-230immunelandscape]] 与 [[recipes/figureya-71ssgsea-update]]。

## 使用记录

<!-- user:start -->
<!-- user:end -->
