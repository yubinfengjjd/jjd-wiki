---
type: chart-type
slug: heatmap
title: heatmap
---
# heatmap

## 回答什么问题

heatmap 回答的是：在一个特征×样本（或基因×细胞类型、通路×分组）的数值矩阵里，整体存在哪些块状的高低格局，哪些行与列组合共享同一模式。它服务模式发现和全局比较，不用于逐个单元格的精确读数，也不能直接回答组间差异是否显著。

## 什么时候选它

通用规则是：数据能排成完整、同量纲（或已统一标准化）的数值矩阵，行数多到表格难读，列是有意义的样本/分组/簇，且行列顺序或聚类有解释价值时选 heatmap。列若只是组均值，每组样本量要足以让均值稳定，并另配分布或统计结果；行列很少时改用 dotplot 或表格更清楚。

## 什么时候不要用

不要用 heatmap 展示部分-整体构成（各组比例之和），那会让人误读为可加总的组成，应改用 stacked-bar-flow 或 area。也不要用它比较组内分布、离散度或不确定性（改用 boxplot、violin、beeswarm 或 errorbar），或把颜色深浅当作显著性、因果和轨迹证据；两连续变量的联合密度、少量单元格、量纲不可比却硬塞进同一色标时，不要用 heatmap；本库没有计算二维密度的模板，需上游先算密度/分箱并确认色标；离散矩阵可改用 dotplot 或表格。

## 与相近图型怎么区分

在矩阵数据上，heatmap 与 dotplot 同为矩阵编码，但 dotplot 能用位置、颜色和大小同时编码两个量（如平均表达与阳性比例），稀疏矩阵或需要第二维信息时更合适；heatmap 填满每个单元格，适合密集矩阵和行列聚类，每个单元格却只有一个颜色通道。heatmap 与 stacked-bar-flow、area 的差别是后两者编码部分-整体和总量，heatmap 不表达求和关系；本库 density-scatter 只显示上游给定的配对坐标、RGB 与边缘条，不计算密度；heatmap 的格子是预先划定的离散矩阵单元，二维密度/hexbin 本库无现成模板，需上游先算密度/分箱或新建模板。

## 常见误用

最常见的是色标误导：未说明颜色是原始值、log 值还是按行 z-score，缩放会凭空造出“高表达”；超出色标范围的值被截断到端点会夸大差异，缺失值还必须与 0 区分。红绿或 rainbow 色阶对色盲不友好，顺序量应用感知均匀的色阶，只有围绕有意义中点（如 z=0）才用发散色阶并标出中点。小样本组均值热图（每组 n 很小、只画均值）会把抽样噪声读成模式，把聚类顺序当成生物学顺序或轨迹、行列过密导致标签不可读也是审稿常见质疑；颜色不能替代效应量与统计检验。

## 本库模板

- [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]]：SCP `GroupHeatmap()` 原生单 panel，读取 `render-group-heatmap` 长表；支持多个分组矩阵并排、zscore 色标、列注释和行标签。固定示例 8×6@150 与来源逐字节一致。
- [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]]：SCP `FeatureHeatmap()` 原生单 panel，读取 `render-feature-heatmap` 的 matrix×feature×cell 长表；cell-level zscore 热图、列分组注释与显式顺序。示例为 20 个 DE 基因 × CellType；`split.by`/`add_dot`/`add_violin`/annotation 未实现。
- [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]]：SCP `CellCorHeatmap()` 原生单 panel，读取 `render-correlation-heatmap` 相似度长表；模板只重建矩阵并绘制，不重算相似度。示例为 8×8 query-query cosine 相似度；参考数据集/细胞级不折叠/nlabel 未验证。
- GroupHeatmap正式模板目前只覆盖ht1。另有 [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]] 正式模板已确认：白色单元格内，圆点颜色编码聚合变换表达，圆点直径编码逐细胞阈值阳性比例，顶部色条编码分组身份；原生大小公式不是点面积正比。需要同时展示表达强度和普及度时可考虑此变体，不能将普通气泡图的编码方式直接替换它。add_violin、feature_split/row_split、cell/feature annotation、enrichment注释仍未实现；FeatureHeatmap也只覆盖默认单panel。该确认只覆盖点阵分支。
