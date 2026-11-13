# 逐形态用例与原生对照：stat-dim（20261027T064647Z）

任务：tasks 28.1 / 28.2（需求 17）。一形态一用例，其余参数取该入口现有用例基准参数；原生输出为软件夹具（SCP 示例数据 pancreas_sub / meta_synth / meta_venn）原生输出，不是科学结论。

- 暂存用例：`E:/research-wiki-env/work/kiro-scp-cases-staged/<Fn>.json`（未写 `<B>/coverage/cases/`）
- 原生输出：`E:/research-wiki-env/work/kiro-scp-native/forms/<Fn>-<case>/`（job.json、args.json、native.R、native.log、reference.json、oracle.png）
- 脚本：`E:/research-wiki-env/work/scp-full-ingest-20261025/scripts/forms/kiro_forms_stat_dim.py`（由 kiro_native_case_oracles.py 复制改写，原脚本未改）
- 每个原生调用独立 Rscript 进程、900 s 超时、最多 2 个并发；保存方式 `ggplot2::ggsave(path, p, width=w, height=h, dpi=150, bg='white')`；输入对象调用前后 sha256 记录在各 reference.json

## StatPlot

基准用例：`bar (minus plot_type/stat_type)`，基准参数 `{"meta.data": "@meta_synth", "stat.by": "grp"}`，8×6 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/StatPlot.json`，未重复建）：plot_type=bar → `bar`；plot_type=rose → `rose`；plot_type=ring → `ring`；plot_type=pie → `pie`；plot_type=trend → `trend`；plot_type=area → `area`；plot_type=dot → `dot`；plot_type=sankey → `sankey`；plot_type=chord → `chord`；plot_type=venn → `venn`；plot_type=upset → `upset`；stat_type=count → `bar`

## CellStatPlot

基准用例：`bar_celltype`，基准参数 `{"srt": "@pancreas_sub", "stat.by": "CellType", "group.by": "orig.ident"}`，7×5 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/CellStatPlot.json`，未重复建）：plot_type=bar → `bar_celltype`

## FeatureStatPlot

基准用例：`violin (minus plot_type)`，基准参数 `{"srt": "@pancreas_sub", "stat.by": "Sox9", "group.by": "CellType"}`，8×6 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/FeatureStatPlot.json`，未重复建）：plot_type=violin → `violin`；plot_type=box → `box`；plot_type=bar → `bar`；plot_type=dot → `dot`；plot_type=col → `col`

## CellDimPlot

基准用例：`mark_hull (minus add_mark/mark_type)`，基准参数 `{"srt": "@pancreas_sub", "group.by": "CellType", "reduction": "UMAP"}`，8×6 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/CellDimPlot.json`，未重复建）：mark_type=hull → `mark_hull`；mark_type=ellipse → `mark_ellipse`；mark_type=rect → `mark_rect`；mark_type=circle → `mark_circle`

## FeatureDimPlot

基准用例：`two_blend (color_blend_mode) / keep_all (keep_scale)`，基准参数 `{"srt": "@pancreas_sub", "reduction": "UMAP"}`，8×6 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/FeatureDimPlot.json`，未重复建）：color_blend_mode=blend → `two_blend`；keep_scale=all → `keep_all`

## CellDensityPlot

基准用例：`ins1_density`，基准参数 `{"srt": "@pancreas_sub", "features": "Ins1"}`，7×5 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|
| x_order | rank | `f_x_order_rank` | generated | True |  |

已被现有用例覆盖（`<B>/coverage/cases/CellDensityPlot.json`，未重复建）：无

## FeatureCorPlot

基准用例：`two_markers`，基准参数 `{"srt": "@pancreas_sub", "features": ["Sox9", "Anxa2"], "group.by": "CellType"}`，8×6 in。

| 参数 | 取值 | 用例 id | 状态 | 输入不变 | 伴随参数 / 原始错误摘要 |
|---|---|---|---|---|---|

已被现有用例覆盖（`<B>/coverage/cases/FeatureCorPlot.json`，未重复建）：无

## 计数

新建用例 1 个：generated 1；已被现有用例覆盖的形态 24 个；branches.json 中本组形态合计 25 个。
