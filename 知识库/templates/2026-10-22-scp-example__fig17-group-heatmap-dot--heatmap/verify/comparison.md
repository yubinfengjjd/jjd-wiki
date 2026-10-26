# 对照记录：原生 GroupHeatmap(add_dot=TRUE) vs 提炼模块

设备/尺寸/字体/种子一致：`ggsave` PNG 150dpi 8×6in white bg；PDF `cairo_pdf`；SVG `svglite`（required 依赖，无 fallback）；seed=11。原生参考由 `scripts/groupheatmap-dot/capture_native.R` 本次实跑生成（`evidence/groupheatmap-dot/native/`）。所有结论由当前代码版本重新执行产出（panel.R `21c1de7d…` / scp_group_heatmap_dot_native.R `53de1e26…` / render.R `7b4da191…` / core.R `12ced853…` / helpers `8e941e41…`）。

## A. 输出层

| 分支 | 原生 sha256 | 模块 sha256 | 一致 |
|---|---|---|---|
| add_dot, CellType 12×5 PNG | `7CC121E7…` | `7CC121E7…` | ✅ 字节相同 |
| add_dot+reticle PNG | `AC5B96AE…` | `AC5B96AE…` | ✅ 字节相同 |
| add_dot, CellType+SubCellType 12×5+12×8 PNG | `CE44217C…` | `CE44217C…` | ✅ 字节相同 |
| 1m SVG | `1803D5FC…` | `1803D5FC…` | ✅ 字节相同 |
| 2m SVG | `9A4F9D58…` | `9A4F9D58…` | ✅ 字节相同 |
| reticle SVG | — | — | ⛔ 未做 SVG 对照（仅 PNG） |
| PDF | 见下 | 见下 | ⚠ cairo 时间戳内嵌不可逐字节比；**结构比较未做** |

## B. 数据层（identical() 级，`numeric-checks.json` 44/44）

- `csv_*_identical_native`：CSV 重建矩阵 vs 帧捕获 `mat_list`，值与 dimnames `identical()`（上游 `scale()` 残留的 `scaled:center`/`scaled:scale` 属性渲染不用，对照时移除）。
- `csv*perc_identical_native`：percent 矩阵与 `mat_perc_list` `identical()`。
- `prepare_*_identical_native`：`scp_group_heatmap_matrix()` 输出矩阵与捕获 `identical()`。
- `plot_*`：返回 `patchwork` 包 `wrapped_patch`（同原生 `wrap_plots(gTree)` 结构）。
- 输入 rda MD5 不变；绘图不修改输入表。

## C. 加载边界（`loader-checks.json` 23/23，`coexist-checks.json` 9/9）

- `source(code/core.R, local=e)`：e 中仅出现 3 个入口名；`.GlobalEnv` 无新增名。
- `source(code/core.R)` 默认：.GlobalEnv 仅新增同样 3 个入口；无 helper/引擎名泄漏。
- 二级嵌套（函数内 `source(local=e)`）：模块文件按最内层 ofile 自定位，仍可渲染。
- 重复调用：`ghdot_build_matrices`×2 `identical()`；`ghdot_plot_panel`×2 均为 patchwork。
- 与既有 ht1 模板同环境（ht1 以其自身全局泄漏方式加载）：两种顺序下各自入口可调用。
- 副作用边界：`core.R` 的 `library()` 会把依赖包 attach 到 `search()`——有意的共享会话副作用，不声称恢复；隔离推荐用 `render.R` 新进程。

## D. 组合入口

无 `draw(fig, rect, …)` 适配器——模块返回 `patchwork`-wrapped gTree，`print()` 为整页绘制，不声明 rect-aware 组合；区域组合属调用方（patchwork/grid）。

## E. 输入契约（Codex round-2 新增，`numeric-checks.json` 内）

- 序号列：`matrix_order`/`group_order`/`feature_order` 各拒 NA、Inf、小数、0、负数（15/15）；不连续正整数（×7/×3+1/×5）仍 `identical()`。
- 键列：factor matrix 列、空字符串 feature、NA group、数值 feature 列均拒绝；重复列名、零行表拒绝。
- 既有：factor/character/logical value/percent；order 双射歧义（三类）；percent>1/NA/缺列；重复联合键；缺 feature；flip/add_violin/add_dot=FALSE/调色板长度；非有限值。

## F. 标签字面量（Codex round-2）

上游 `eval(parse())` 把 group 标签/matrix 名/reticle_color/palcolor 插值进源码——"Patient's ductal cells" 即 parse error，且用户字符串作为代码执行。已改为同语义闭包（block_fill/panel_fun 捕获预算色向量；layer_fun `local({cg<-cell_group; …})` 捕获矩阵名），固定三分支仍逐字节一致。`quoted_labels_render/png_drawn/not_executed` 与 `reticle_color_literal` 实测：单双引号、反斜线、中文（内分泌细胞/基因甲）、形似代码（`z');assign(...)…`）标签正常渲染且不执行。

## G. 合法性变体（无原生对照）

- 长标签+显式顺序置换 → fixed 10×7 渲染成功，顺序生效（variant-order-check.txt）；Codex 目检未见明显裁切。
- 6×3 规模 → adaptive 6×5（min clamp）渲染成功。

## H. 独立性

`runtime.json`（v2 字段、script 入口、完整业务 id、svglite 列 required）→ 官方 `rwiki.runtime_contract.runtime_facts`：`portability.state=verified`、`closure_hash=c474e19d…`、`issues=[]`；旧回执 `portable/`–`portable-r3/` 保留为失效历史（官方解析器按指纹正确判 invalid），新证据在 `portable-r4/`。CLI CSV 读取：matrix/feature/group 列 `colClasses="character"`（digit-like 身份 `"001"`/`"01"` 保留，Codex fixture `9DCD07C7…` 实渲染 PNG/PDF/SVG），`na.strings=character(0)` 使字面 `"NA"` 保字符串、空单元格仍拒绝；quoted 数值列兼容（首轮宽 colClasses 撞引号报错已收窄为仅身份列）。直接函数 `ghdot_build_matrices` 类型规则不变。

## I. 未做/边界

- PDF 结构 diff 未做；reticle SVG 对照未做。
- 未测分支：add_violin、flip、split.by、feature_split、cell/feature annotation、非 zscore exp_method、超容量调色板扩展、真实课题 Seurat→CSV 端到端管线。
- 不声称共享 R 会话零副作用或 options 已恢复（`library()` attach 见 C 节）。
