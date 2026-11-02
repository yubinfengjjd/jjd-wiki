# 子代理：可视化结构模板开发规范（S10 前置，2026-10-26）

先读公共约束 `kiro-subagent-common-20261026.md`（同目录）并严格遵守。另外：

## 你只在暂存区工作
- 每个结构一个目录：`E:/research-wiki-env/work/kiro-scp-templates/<structure_id>/`（structure_id 取自 `<B>/coverage/visual-structures.json`）。
- 不写 `<B>/wiki`、`<B>/gallery`、正式库/正式画廊；不运行 wiki.py 的任何写命令（ingest/scaffold/verify/mark-ready/save）、不启动 Wiki 服务。官方流水线由主会话串行执行。
- 结构清单：`<B>/coverage/visual-structures.json`（字段见 design.md D2；native.materials 给出原生 PNG/SVG 路径、sha256 与原生调用参数）。原生材料目录见公共约束。接口候选表：`E:/research-wiki-env/work/kiro-scp-native/interface-tables/<structure>/`（另一子代理正在生成，若暂缺就自己用相同原生参数调用原生函数抽取，写到你的暂存目录 `native-extract/`）。

## 每个结构的交付物（暂存目录内）
1. 模板资产，结构对齐范例 `E:/research-wiki/知识库/templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap`（只读参考）：
   - `code/render.R`：`Rscript code/render.R --data <dir> --out <dir> [--style <json>]`；读 `spec.json` 与 `<data>/<interface>.csv`；写 `figure.png`、`figure.pdf`（cairo_pdf）、`figure.svg`（svglite）与 `sizing.json`；启动时检查 required 包，缺包明确报错，不安装。
   - 绘图核心：**优先原样复用 SCP 原生绘图函数源码**（从 `<B>/coverage/modules/<module>/code/fns/*.R` 或 `<SRC>/R/SCP-plot.R` 复制所需函数，私有环境加载，像 fig17 的 core.R），由表驱动地构造原生函数需要的最小输入（可从表重建轻量对象或 ggplot 数据），目标是与原生 PNG **逐像素一致**；所有改写逐条记入 runtime.json `source.modifications`。不得加载 Seurat/SCP 包本身（SeuratObject 若原生函数必需须说明理由并列入 required_packages）。
   - `spec.json`：`{"entry":"code/render.R","language":"r","tables":{"<name>":{"interface":"<slug>","description":"…"}},"style":{…原生默认参数…}}`。
   - `runtime.json`：`kind=template, entry=code/render.R, entry_kind=script, language=r, runtime_mode=standalone, files[…], resources[{path,sha256,role}], required_packages{"R":[…]}, optional_packages, invocation{command,notes}, source{package:"SCP-local",version:"0.5.6",commit:"b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0",license:"GPL (>= 3)",functions:[…],modifications:[…]}`（id 字段写计划模板 id `<gallery_entry_id>--<chart_type>`）。只声明实际调用路径需要的包。
   - `example/<interface>.csv`（来自原生调用同输入同参数的结果表）与 `example/style.json`（固定原生尺寸 8×6 in、dpi 150、seed 11 等，使回放可与原生 PNG 直接比较；sizing 用 fixed）。
2. 接口：若清单中的 interface 在 `<B>/wiki/interfaces/` 不存在，写 `interface-<slug>.json`：`{"slug","title","columns":{col:{"type":"str|int|float","description":"…"}},"meaning":"一段中文含义说明（行代表什么、单位、易错前提、与相近接口区别）"}`。优先复用已有接口（列集合必须完全一致才算复用）。
3. 画廊材料：`gallery/` 下放 `data/<interface>.csv`（同 example）、`original_code/<fn>.R`（原生函数源码原字节片段）与 `original_code/provenance.json`（文件、行号、commit、sha256）、`replica/replica.png|pdf|svg`（render.R 在 example 上的输出）、`label`/`caption` 写在 structure.json。
4. 验证（必须实际运行）：
   - 把只含 runtime.json `files` 列出文件的副本复制到全新目录，新 Rscript 进程运行 render.R（--data example --out out --style example/style.json），用 `D:/anaconda/python.exe -X utf8 <B>/scripts/compare-native.py --kind png --native <原生png> --candidate out/figure.png --out cmp-png.json`，有原生 SVG 时再 `--kind svg`。目标 equal=true。若因字体栅格化等确定原因无法逐像素一致，写明 MAE（--tolerance-mae x --basis "原因"）且 SVG 结构比较必须 equal=true；否则判未通过并写原因，不要伪造。
   - 换数据鲁棒性：构造至少 2 种变体表（组数不同、长标签、显式顺序/数字型标签如 "01"），render 成功且无报错，记录输出 sha256。
   - 输入表与原生内部数据一致性：说明表的每列从原生函数哪一步数据得到。
5. `structure.json`：`{"structure_id","gallery_entry_id","template_id","chart_type","interface","title","label","caption","sections":{"适用":"…","不适用":"…","知识关联检查":"…"},"data_note":"软件夹具（SCP 示例数据 pancreas_sub）原生输出，不是科学结论","comparison":{"png":{"equal":..,"file":"cmp-png.json"},"svg":{…}},"robustness":[…],"ready_candidate":true|false,"not_ready_reason":null|"…"}`。三节用中文写实质内容（首行不得是 TODO/待补充/模板化后生成）：适用写什么数据/问题该用；不适用写边界（例如不重算统计、不读 Seurat、交互不支持等）；知识关联检查写与哪些方法家族/接口/已有模板相关、区别何在。

## 汇报
完成后在 `<A>` 写 `kiro-templates-<batch>-<UTC时间戳>.md`：每结构一行（ready_candidate、png/svg 对照结果、MAE、required 包、未通过原因），并在回复中汇报。若某结构原生材料缺失或原生失败，写明原因并跳过，不得用重画图冒充。
