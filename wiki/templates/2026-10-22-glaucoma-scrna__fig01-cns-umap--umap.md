---
type: template
id: 2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
title: CNS 细胞类型 UMAP
status: ready
layouts:
- 2026-10-22-glaucoma-scrna__fig01-cns-umap
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- umap
favorite: false
keywords:
- GSE251716
---
# CNS 细胞类型 UMAP

![[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap|CNS 细胞类型 UMAP（GSE251716）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/umap]]
- 输入接口：[[interfaces/render-umap-groups|UMAP 坐标与分组表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/batch-integration|单细胞批次整合]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：整合后的嵌入可按 batch 或 celltype 着色，复用现有 UMAP 单 panel；模板不做整合。；前提：坐标与 group 来自同一整合嵌入；cell_id 唯一；坐标无 NA。；group 明确为 batch 或 celltype；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）；模板不读 RDS。
    - 关系证据：methods/batch-integration.md#输出；methods/scp-integration.md#知识关联检查；methods/scp-integration.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/cell-clustering|单细胞聚类分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：cluster 标签可作为 UMAP 着色变量；模板不聚类。；前提：celltype 标签与 UMAP 坐标来自同一 Seurat 对象；cell_id 一致。；group_levels 按注释顺序给出；不得把 cluster 编号直接当 celltype。；适配：导出 render-umap-groups.csv（group=cluster）；cluster 编号不是细胞类型。
    - 关系证据：methods/cell-clustering.md#输出；methods/scrna-marker-annotation.md#知识关联检查；methods/scrna-marker-annotation.md#输出；layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap.md#适用；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/cell-quality-control|单细胞质量控制]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：QC 的 Pass/Fail 或指标可作为 UMAP 着色变量；模板只画表，不计算 QC。；前提：UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。；group_levels 显式给出；Pass/Fail 顺序固定。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group=CellQC 或样本）；模板不读 RDS。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测细胞类型可作为 UMAP 着色变量；模板不执行注释。；前提：预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。；标签不是 cluster 编号；group_levels 按注释顺序给出。；适配：导出 render-umap-groups.csv（group=predicted celltype）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/dimensionality-reduction|单细胞降维分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：Standard_SCP 产出 StandardUMAP2D，可作为 UMAP 分组着色；模板只画表，不降维。；前提：坐标与 group 来自同一嵌入；cell_id 唯一；坐标无 NA。；group 明确为 cluster 或 celltype；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）。
    - 关系证据：methods/dimensionality-reduction.md#输出；methods/scp-standard-workflow.md#知识关联检查；methods/scp-standard-workflow.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/doublet-detection|双细胞检测]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：双细胞标签可作为 UMAP 着色变量检查分布；模板不检测双细胞。；前提：UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。；group_levels 显式给出；Pass/Fail 顺序固定。；适配：导出 render-umap-groups.csv（group=doublet class 或样本）；标签只作描述。
    - 关系证据：methods/doublet-detection.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/reference-mapping|参考图谱映射]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：查询细胞可按预测标签着色自身 UMAP；这不是参考 UMAP 投影，模板也不执行映射。；前提：预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。；标签不是 cluster 编号；group_levels 按注释顺序给出。；适配：导出 render-umap-groups.csv（group=predicted label）；不得把查询 UMAP 说成参考投影。
    - 关系证据：methods/reference-mapping.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：轨迹分组/lineage 标签可作为 UMAP 着色变量；现有模板不画 lineage 曲线。；前提：UMAP 坐标与 group 来自同一对象；cell_id 一致。；group 为 cluster/lineage 分组；group_levels 由课题给出。；适配：导出 render-umap-groups.csv（group=cluster/lineage）；曲线需另建模板。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

单细胞 UMAP 的分组/细胞类型展示：输入 `cell_id, umap_1, umap_2, group`，group 可为 cluster 或 celltype。画点、虚线非凸包、簇中心标签、左下短箭头和右侧图例。组数由 `style.group_levels` 控制（示例固定 9 组）；换数据必须覆盖或置空，否则新组可能报错或被丢弃。

## 不适用

没有 UMAP 坐标或分组列；需要组间统计检验；组数过多且标签无法排布；不能用包络形状证明群间差异。模板不读 Seurat 对象，也不重新聚类；坐标和分组必须来自同一嵌入。

## 知识关联检查

2026-10-22 查过 [[methods/scrna-preprocess-doublet-qc-harmony|M1 预处理/聚类]]、[[methods/scrna-marker-annotation|M2 注释]] 和 UMAP 图型页。M1 提供坐标和 cluster，M2 提供 celltype；同一模板可着两种 group。示例为合成数据，真实 GSE251716 尚未在本机回放（Seurat 不可加载）。方法侧 `figure_relations` 已登记为 adaptable；模板只读接口表，不重算分析。

## 数据要求

### umap（render-umap-groups.csv）：UMAP 坐标与分组；同一图内坐标和分组来自同一嵌入 [[interfaces/render-umap-groups|UMAP 坐标与分组表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell_id | str | 细胞标识；同一图内唯一 |
| umap_1 | float | UMAP 第一维坐标 |
| umap_2 | float | UMAP 第二维坐标 |
| group | str | 分组或细胞类型；用于着色、包络和标签 |

### 可覆盖的 style

- `font_family`：`"sans"`
- `dpi`：`192`
- `width_in`：`9`
- `height_in`：`7`
- `sizing`：`mode` 为 `adaptive`（换数据）或 `fixed`（固定示例回放）；base/per-item/min/max 参数见 `spec.json`。
- `point_size`：`0.9`
- `point_alpha`：`0.85`
- `hull_alpha`：`0.22`
- `hull_delta`：`0.45`
- `hull_size`：`0.35`
- `axis_len_ratio`：`0.12`
- `pad_ratio`：`0.04`
- `label_size`：`4.5`
- `legend_text_size`：`9`
- `group_levels`：`["Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor", "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"]`
- `palette`：`["#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85", "#E18727", "#20854E", "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97", "#A6CEE3", "#BC80BD", "#FFED6F", "#8DD3C7"]`

## 使用记录

2026-10-22 建模板；用 R 4.3.1 回放 PNG/PDF/SVG，`verify-template` 通过；preview 已生成。
2026-10-22 作者确认模板可用；补 adaptive sizing，固定示例用 `example/style.json` 的 fixed 模式；`check-entry --record` 已更新。

<!-- user:start -->
<!-- user:end -->
