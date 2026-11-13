# v3-dim 模板开发结果（tasks 15.1 / 15.4 代码部分，2026-10-26T15:33Z）

软件夹具（SCP 示例数据 pancreas_sub）原生输出，不是科学结论。只写暂存区，没有写 wiki/画廊，也没有运行 wiki.py 写命令。

## 结果

| 结构 | ready_candidate | PNG 对照 | SVG 对照 | MAE | 参数对照 | required 包（R） | 未通过原因 |
|---|---|---|---|---|---|---|---|
| celldimplot-group | true | equal（逐像素） | equal | 0 | SubCellType、label=FALSE 对 CellDimPlot-subcelltype/oracle.png：PNG equal | ggplot2, grid, rlang, methods, ggrepel, jsonlite, svglite | — |
| celldimplot-group-mark | true | equal（hull） | equal | 0 | ellipse / rect / circle：PNG+SVG 全部 equal | ggplot2, grid, rlang, methods, ggforce, ggnewscale, jsonlite, svglite | — |
| celldimplot-hex | true | equal | equal | 0 | — | ggplot2, grid, rlang, methods, hexbin, jsonlite, svglite | — |
| featuredimplot-single | true | equal（Neurog3） | equal | 0 | FeatureDimPlot-keep_all 未对照（要 split.by=Phase，接口里没有这一列，模板直接报错拒绝） | ggplot2, grid, rlang, methods, patchwork, jsonlite, svglite | — |
| featuredimplot-blend | true | equal（指定的 oracle.png） | equal（用 v3-dim/FeatureDimPlot-blend-blend 的 SVG，它的 PNG 与 oracle.png sha256 相同） | 0 | average / screen / multiply：PNG+SVG 全部 equal | ggplot2, grid, gtable, rlang, methods, patchwork, ggnewscale, jsonlite, svglite | — |
| celldimplot-stat-inset | false（跳过） | — | — | — | — | — | 原生默认调用失败：add_grob() 中 gtable_add_grob 报 "`grobs` must be a single grob or a list of grobs, not a list matrix."。另一个子代理独立运行得到同样的错误（CellDimPlot-stat-pie）。没有原生 PNG，按规定跳过；legend.position='none' 那个探针少了图例，是另一种结构，不拿来对照 |

## 做法
- 每个结构一个目录：`E:/research-wiki-env/work/kiro-scp-templates/<structure_id>/`，含 code/render.R、core.R、sizing.R、fns/*.R、data/palette_list.rda，以及 spec.json、runtime.json、example/、gallery/（data、original_code+provenance.json、replica）、verify/、structure.json。
- 绘图核心：按行号从 `<SRC>/R/SCP-plot.R`、`SCP-workflow.R`、`utils.R` 原样复制 SCP 函数块。唯一的文本修改是 palette_scp 里 `SCP::palette_list` → `palette_list`。用一个轻量 S4 对象（SCPLiteSrt）代替 Seurat 对象，只带原生函数实际读取的槽：meta.data、reductions@cell.embeddings/@key、assays（矩阵型、带 data 槽）。不加载 Seurat/SeuratObject/SCP。所有改写都记在 runtime.json `source.modifications`。
- 接口：复用 render-umap-groups（celldim ×3）和 render-umap-feature-long（featuredim ×2），列集合完全一致，所以没有新增接口文件。glaucoma fig01/fig02 是另一套绘图实现，没有合并，三节说明里写了区别。
- 输入一致性：示例表直接取自原生调用用的同一对象（坐标用 17 位有效数字写出，读回逐位相等）。4 个 celldim 结构和 featuredimplot-single 的渲染 p$data 与原生 p$data `identical()=TRUE`。blend 的原生返回值是 patchwork 包装，取不到 p$data，一致性由逐像素 equal 加列来源说明保证。
- 验证：只把 runtime.json `files` 列出的文件复制到全新 tmp 目录，在新 Rscript 进程里运行，再用 compare-native.py 对照。换数据鲁棒性每结构 2–3 个变体：组数不同、长标签、"01"/"10" 这类数字型标签加显式顺序、乱序子集、字面 "NA" 标签、缺行或 NA 值、全零特征、calculate_coexp、3 特征 multiply。全部渲染成功，输出 sha256 记在 verify/verify.json。临时目录已清理。

## 新生成的原生材料
- `E:/research-wiki-env/work/kiro-scp-native/v3-dim/native_v3dim.R`（运行日志 native.log，汇总 references.json）
  - cell-dim-hex：CellDimPlot(group.by='CellType', reduction='UMAP', hex=TRUE)，8×6 in，150 dpi，seed 11。PNG d4dab7c5…3067a，SVG 486a743e…f63ae。
  - cell-dim-stat-inset-Phase：reference_failed（错误见上表）。
  - extract/：接口表、原生 p$data RDS；另有 extract_subcelltype.R 生成的 SubCellType 表。
- 主会话需自行回写 visual-structures.json：celldimplot-hex 的 native 状态改为 generated；celldimplot-stat-inset 改为原生失败。

## 证据
- 每结构：`verify/verify.json`、`verify/cmp-png.json`、`verify/cmp-svg.json`、`verify/params/*`、`verify/robustness/*`、`verify/replay.log`。
- 构建与验证脚本：`E:/research-wiki-env/work/kiro-scp-templates/_v3-dim-dev/{build_v3dim.py,verify_v3dim.py,core.R,celldim/render.R,featuredim/render.R}`。

## 未完成项
- celldimplot-stat-inset：原生失败，已跳过。如果要入库，需要先决定是否接受修过 add_grob 的版本，或者只接受无图例的结构。这属于产品决定，本次不做。
- featuredimplot-single 不支持 split.by，所以没和 keep_all（split.by=Phase）原生材料对照。
