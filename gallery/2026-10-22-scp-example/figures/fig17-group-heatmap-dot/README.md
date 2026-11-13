# fig17 分组表达点阵热图（GroupHeatmap add_dot）

Source: SCP v0.5.6 `GroupHeatmap(srt = pancreas_sub, features = <12 markers>, group.by = "CellType", add_dot = TRUE)`,
commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, GPL (>= 3).

状态：draft（复刻与对照已完成，等待作者签核与人工目检）。

- `source/fig17.png` 是本次原函数实跑的 add_dot 输出（8×6 in, 150 dpi），即黄金参考；非裁自其他静态图。
- `output/replica.png`/`replica.svg` 为模块代码在归档长表上的产物，与 source 字节一致；`replica.pdf` 因 cairo 内嵌时间戳不可逐字节比，**结构比较未做**。
- `data/render-group-heatmap.csv` 长表：matrix×feature×group 一行一格；`percent` 为逐细胞表达（lib_normalize 后、聚合前）`> exp_cutoff` 的比例（0–1），驱动圆点**直径**（`size = dot_size * perc`）；圆点 fill 颜色映射 zscore 聚合值，格底色为白，列顶色条仅分组身份。
- `code/`：加载入口 `core.R`（私有环境装载，仅导出 3 个函数）；`replica.R` 为本条目可运行驱动（`Rscript code/replica.R`）；`render.R` + 根目录 `spec.json` 为候选 CLI 同款（`--data data --out output`）；`scp_group_heatmap_dot_native.R` 只覆盖 add_dot 分支。两 reader 对 matrix/feature/group 列 `colClasses="character"`（digit-like 身份保留字面量）。
- `original_code/groupheatmap.R` 为固定源 `R/SCP-plot.R` 7911–9036 行**字节精确**切片（含 CRLF 行尾，`1497d20d…`）；旧带 header 注释版存 `evidence/groupheatmap-dot/history/`。
- 与 fig08 ht1 热图的关系：同一原函数的两个视觉分支（纯色块 vs 点阵叠加），非同一模板。
- 兼容性修改（记录在案）：上游 `eval(parse())` 插值标签/样式字符串已改同语义闭包，含引号/中文等标签按数据处理不执行；固定对照仍逐字节一致。
- 未验证/不支持：add_violin、flip、split.by、feature_split、cell/feature annotation、flip 下 mat_perc 转置路径、真实课题数据端到端管线、科学有效性断言；无 rect-aware draw 适配。

## 代码与运行

```
Rscript code/replica.R                                                   # 条目内驱动
Rscript code/render.R --data data --out output --style data/style-fixed.json  # 候选 CLI（spec.json 已附；fixed 样式复现 8×6）
```

库内调用：`source("code/core.R")` → `ghdot_plot_panel(list(heatmap=df), list(add_dot=TRUE))`，返回 patchwork 对象。注意 `core.R` 的 `library()` 会把依赖包 attach 到当前会话 `search()`（共享会话副作用，不声称恢复）；隔离推荐 CLI 新进程。

依赖（R 4.5.0，**全部 required**）：ComplexHeatmap, circlize, grid, gtable, patchwork, ggplot2, jsonlite, svglite（SVG device，无 fallback；render.R 运行前 requireNamespace 预检，缺包清楚报错）。

## QA 与签核

见 qa_report.md。作者签核前保持 draft；Wiki 侧 layout 停在 pending_signoff。
