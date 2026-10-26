# GroupHeatmap add_dot 点阵热图 — 模板候选

SCP `GroupHeatmap()` 的 `add_dot=TRUE` 单 panel 分支：每格底色白，格内圆点 **fill 颜色** = 聚合变换表达值（默认 zscore，RdBu 双向色标），圆点**直径** = `percent`（原式 `size = dot_size * perc`，按直径线性缩放、非面积正比）；右侧 `Percent` 点大小图例 + 各 group.by 分组色图例 + 行侧 marker 标注；列顶色条仅标识分组身份。

- 来源：SCP v0.5.6 `R/SCP-plot.R` `GroupHeatmap()` 行 7911–9036，commit `b9b0eb7a`，GPL (>= 3)。
- 只覆盖 `add_dot=TRUE`（含可选 `add_reticle`），**不覆盖** `add_violin` / `flip` / `split.by` / `feature_split` / cell/feature annotation / `cell_palcolor` 等其余分支——这些分支在本模块中显式拒绝，列为后续工作。
- 与既有 ht1 模板（`fig08-group-heatmap--heatmap`）为**不同结构变体**：ht1 是纯色块热图无点层；本模块是同函数的点阵分支。两者互为 candidate/adaptable 关系，非同义模板。
- `percent` 语义：**逐细胞**表达值经原调用声明的 `lib_normalize` 之后、聚合/zscore 之前，`> exp_cutoff` 的细胞比例（0–1），在 prepare 层由 Seurat 对象计算；**不能**对聚合后的 `value` 列再取阈值得到，不填补、不除 100。

## 公开 API（加载边界已实测）

`code/core.R` 是本模块唯一加载入口；它把全部实现文件 `sys.source` 进**模块私有环境**，只向调用环境暴露 3 个函数，不泄漏 helper/引擎名，不覆盖其他模块导出名（证据：`verify_loader.R`/`verify_coexist.R` 23+9 项检查）：

| 入口 | 签名 | 返回 |
|---|---|---|
| `ghdot_build_matrices(df, style)` | 长表 → 矩阵/percent/顺序 | list(matrices, percent, features) |
| `ghdot_plot_panel(tables, style, scp)` | 接口级面板入口（tables$heatmap 为长表） | list(plot=patchwork 包装 gTree, matrix_list, percent_list, …) |
| `plot_scp_group_heatmap_dot(matrices, percent, features, style, scp)` | 原生绘图层（矩阵直接输入） | 同上 |

```r
source("code/core.R")                 # 或 source("code/core.R", local = e)
p <- ghdot_plot_panel(list(heatmap = df), list(add_dot = TRUE))
print(p$plot)                          # patchwork 对象，grid/patchwork 组合由调用方处理
```

**无 `draw(fig, rect, tables, style)` 适配**：模块返回原生 `patchwork`-wrapped gTree 对象，区域内组合绘制（viewport/rect）由调用方用 patchwork/grid 完成；`print(p$plot)` 画整页，不是 rect-aware 组合。脚本入口：`Rscript code/render.R --data <dir> --out <dir> [--style json]`（runtime.json 已声明 `entry_kind="script"`）。

模块文件路径按"当前被 source 文件的最内层 `ofile`"解析：嵌套 `source`、函数内 `source(local=e)`、与既有 ht1 模块同环境先后加载均实测通过（不依赖全局 helper 名，不受 ht1 泄漏名影响也不影响 ht1）。

## 数据接口

与 ht1 模板共用 `render-group-heatmap` 长表，行键 = `matrix × feature × group`：

| 列 | 含义 |
|---|---|
| `matrix` | 热图矩阵名（= group.by 变量名，一个变量一个矩阵） |
| `feature` | 行名（特征）；同一矩阵内按每个 group 出现一次 |
| `group` | 列名（分组水平） |
| `value` | 聚合变换后表达值（默认 z-score of normalized counts） |
| `percent` | 该 feature×group 中逐细胞表达（lib_normalize 后、聚合前）`> exp_cutoff` 的比例，[0,1] |
| `matrix_order` / `group_order` / `feature_order` | 显式顺序：正整数（≥1，可不连续），各自与 identity 构成双射 |

校验（`ghdot_build_matrices`，实测拒绝项见 `numeric-checks.json` 44/44 与 `loader-checks.json` 23/23）：

- 表结构：`matrix`/`feature`/`group` 必须为**非空非缺失字符串列**（factor/数值显式拒绝）；重复列名、零行表显式拒绝。
- 列类型：value/percent/order 必须为数值向量；**factor/character/logical 显式拒绝**（`as.numeric` 不隐式转换 factor level code）。
- 联合键：matrix×feature×group 唯一、完备（缺 cell / 缺 feature → 报错）。
- 顺序列：**有限、非缺失、正整数（≥1）**——NA/Inf/小数/零/负数显式拒绝；不连续合法；matrix↔matrix_order 全局双射；group↔group_order 每矩阵内双射；feature↔feature_order 全局双射（共享行轴，跨矩阵须一致）——同 identity 多 order、同 order 多 identity、跨矩阵 feature 顺序冲突均显式拒绝。
- 值域：value/percent 有限，percent ∈ [0,1]。
- 分支：flip / add_violin / add_dot=FALSE / split / annotation 显式拒绝。
- 标签字面量：group/matrix/feature 名与 `reticle_color` 等样式字符串按**数据**处理——上游 `eval(parse())` 插值已改为同语义闭包（记录在案的兼容性修改，固定对照仍逐字节一致）；含单双引号、反斜线、中文、形似代码的标签均可正常绘制且不执行。

## 运行

```powershell
Rscript code/render.R --data <含 render-group-heatmap.csv 的目录> --out <输出目录> [--style <json>]
```

CSV 读取：`matrix`/`feature`/`group` 三列显式 `colClasses="character"`——digit-like 身份（`"001"`、`"01"`）按字面保留进 dimnames；`na.strings=character(0)` 使字面 `"NA"` 保字符串、空身份格为 `""`（下游拒绝）、空数值格为 NA（下游拒绝）；引号数值与多余列兼容。直接函数输入仍要求表本身类型正确（不隐式修正）。

输出 `figure.png` / `figure.pdf` / `figure.svg` / `sizing.json`。尺寸：`sizing.mode=fixed` 时读 `width_in`/`height_in`；`adaptive` 时按列数/行数/最长标签推算。

依赖全部为 **required**（见 `runtime.json`）：ComplexHeatmap、circlize、grid、gtable、patchwork、ggplot2、jsonlite、**svglite**（figure.svg 的 device，无 fallback）。render.R 在运行前对直接依赖做 `requireNamespace` 预检，缺包即清楚报错。

副作用边界（如实）：`core.R` 顶部 `library()` 会把 ComplexHeatmap/circlize/patchwork/gtable/grid **attach 到当前会话的 `search()`**，这是有意的共享会话副作用；本模块不声称恢复 `search()`/options，也不声称在共享 R 会话中零副作用。**推荐隔离方式是 CLI**：`render.R` 在新 Rscript 进程内运行（独立性证据即按此采集）。

## 文件

```
code/render.R                        脚本入口（runtime.json 声明 entry_kind=script）
code/core.R                          包加载 + 模块私有环境装载（唯一加载入口）
code/panel.R                         长表 → 矩阵 + 契约校验 + 面板入口
code/scp_group_heatmap_dot_native.R  原生构造的 add_dot 分支（绘图半）
code/scp_helpers.R                   palette_scp 等本地 helper（data 路径自定位）
code/sizing.R                        尺寸方案（与 ht1 相同）
code/data/palette_list.rda           SCP 色板资源
prepare/scp_group_heatmap_matrix.R   表半（prepare 层，需 Seurat + SCP_local，仅用于造表/对照）
spec.json / runtime.json             spec 与正式 runtime 契约（runtime_facts 复核 verified）
example/                             真实捕获表（CellType，12×5）+ fixed 8×6 style
verify/                              回执、对照输出、comparison.md
```

## 验证范围（详见 verify/ 与 evidence/groupheatmap-dot/）

- **PNG 逐字节一致**：1 矩阵、reticle、2 矩阵共 3 分支（`7CC121E7…` / `AC5B96AE…` / `CE44217C…`）；**SVG 逐字节一致**：1 矩阵、2 矩阵两分支（`1803D5FC…` / `9A4F9D58…`）；reticle 分支仅 PNG 对照。PDF 内嵌 cairo 时间戳不可逐字节比，**未做结构比较**。
- CSV→矩阵与原生帧捕获 `mat_list`/`mat_perc_list` 值与 dimnames `identical()`（忽略上游 `scale()` 残留的 `scaled:*` 属性）。
- prepare 半（`scp_group_heatmap_matrix`）与同一捕获 `identical()`。
- 加载边界：嵌套/双层 source 仅暴露 3 个入口名、无全局泄漏；与 ht1 同环境两种加载顺序后两入口各自可调用；重复调用结果一致。
- 输入契约（44/44）：序号列正整数、键列字符串、重复列名/空表拒绝；引号/反斜线/双引号/中文/形似代码标签正常渲染且不执行（`quoted-labels.png`）。
- 异目录清单复制 + 新进程渲染 → 输出 PNG/SVG 与原生参考逐字节一致（官方 `runtime_facts` → `portability.state=verified`，fingerprint v2，闭包 `66c3c968…`，证据 `evidence/groupheatmap-dot/portable-r3/`；旧 portable/portable-r2 保留为失效历史）。
- 目检（视觉结构、标签可读性）已由 Codex 对固定图复核通过、长标签未见明显裁切；作者签核仍独立，本条目不声称完成作者级评审。
