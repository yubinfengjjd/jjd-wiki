# 子代理：逐形态用例与原生对照（tasks 28.1 / 28.2，需求 17）

先读公共约束 `kiro-subagent-common-20261026.md` 与定义 `kiro-template-definition-20261027.md`（同目录），严格遵守。

## 目标
为分配给你的可视化入口，对 `<B>/coverage/branches.json` 中该入口（owner）的**每个形态值**建一个用例，并生成同输入同参数的原生 SCP 输出作为对照。一形态一用例：该参数取该值，其余参数取默认值（不做组合）。若该取值需要伴随开关才能生效（如 mark_type 需 add_mark=TRUE，stat_plot_type 需 stat.by，split_method 需 cluster/split 开关），读 `<SRC>/R/SCP-plot.R` 确认后加上最小必要伴随参数，并在用例 `form_note` 写明。

## 只写这些位置
- 暂存用例：`E:/research-wiki-env/work/kiro-scp-cases-staged/<Fn>.json`（与 `<B>/coverage/cases/<Fn>.json` 同格式；只放新用例，id 用 `f_<参数>_<取值>`，参数名里的点换成下划线；`_load` 写该文件需要的输入）。现有 `<B>/coverage/cases/<Fn>.json` 已有的形态（同参数同值）不要重复，写在汇报里"已覆盖"。
- 原生输出：`E:/research-wiki-env/work/kiro-scp-native/forms/<Fn>-<case>/`。
- 你需要的脚本放 `<B>/scripts/forms/`（新建）。可复制 `<B>/scripts/kiro_native_case_oracles.py` 改出一个读暂存目录、写暂存目录的版本（原脚本不得修改）。
- 禁止写 `<B>/coverage/cases/`（冻结中，主会话合并）。

## 用例格式（每个用例）
```json
{"args": {...}, "save_plot": ["png"], "w": 8, "h": 6, "seed": 11,
 "oracle_png": "E:/research-wiki-env/work/kiro-scp-native/forms/<Fn>-<case>/oracle.png",
 "comparisons": {"oracle_png_pixels_equal": {"oracle": "<同上>", "tolerance": 0, "basis": "exact RGBA pixels; same ggsave device, 8x6 in, 150 dpi"}},
 "form": {"parameter": "...", "value": "..."}, "form_note": "伴随参数说明（可空）",
 "data_note": "software fixture (SCP 0.5.6 example data pancreas_sub / real-count subset); comparison proves equality to the native SCP call, not a scientific result",
 "native_reference": {"dir": "...", "state": "reference_generated", "outputs_sha256": {"oracle.png": "..."}}}
```
- 原生 PNG 必须由与提炼模块完全相同的保存方式生成：`ggplot2::ggsave(path, p, width=w, height=h, dpi=150, bg="white")`，`p` 为返回值（list 时取 `$plot`；`recordedplot` 用 png 设备 replayPlot）。宽高：沿用该入口现有用例的 w/h（没有就 8×6）。
- 原生调用失败：用例写 `"expect_native_failure": "<原始错误>"`、`"expect_error_pattern": "<错误中稳定的一段>"`，不写 oracle。缺包/缺上游：写 `"missing_material"` 或 `"missing_package"` 字段（精确包名/对象），不写 oracle。
- 交互图（3D）：保存 `plotly::plotly_build(p)$x$data` 为 `oracle-traces.rds`，用例写 `plotly_build: true` 与 `oracle_traces_rds`，comparisons 键 `oracle_traces_fields_equal`。
- 每个原生调用新 Rscript 进程，900 秒超时；同时最多 2 个 Rscript。输入对象调用前后 sha256 不变须检查并记录。

## 汇报
在 `<A>` 写 `kiro-forms-<组名>-<UTC>.md`：每入口一张表（参数、取值、用例 id、状态 generated/native_failure/missing_*/timeout、原始错误摘要），以及已被现有用例覆盖的形态。回复中给出计数。
