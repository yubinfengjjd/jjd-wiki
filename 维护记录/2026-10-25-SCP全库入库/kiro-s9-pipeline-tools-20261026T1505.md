# S9 流水线工具（tasks 12.2 / 12.3 / 12.4 / 12.5 / 12.7）结果说明

时间：2026-10-26T15:05Z；执行者：Kiro 子代理。数据与图均为软件夹具（SCP 示例数据）原生输出，不是科学结论。

## 新建文件（全部在 `<B>/scripts/`，未改动任何既有/冻结脚本）

| 文件 | sha256 | 作用 |
|---|---|---|
| `build-gallery-entry.py` | `1865346112856f64fa8d850a3885120ef8f96ebc4d544528f489859c2c95fd36` | C9：dedupe --dry-run → init_entry → data/<interface>.csv、original_code（原字节 + provenance.json，自动在 `<SRC>/R/*.R` 中定位字节精确行号）→ output/replica.* → thumb → make_compare → 原生对照 → meta（panel_map 恰好一项、provenance、files）→ qa_check → README/qa_report 软件夹具与代签核声明 → build_index。状态默认 review（可选 draft），从不写 approved。另加可选 `--replica-code`（复制为 code/replica.R，qa_check 需要）。 |
| `compare-native.py` | `3073fef9e4e82af4d30cb21244b72f7f2c831e5a6b28f4e6b548700b6a76a46d` | png 逐像素（同尺寸；`--tolerance-mae` 必须配 `--basis`，并标记须同时通过 SVG 结构比较）；svg 元素类型计数/文本节点集合/path 数；plotly 用 Rscript 比较 x/y/z/type/mode/name/text/marker（all.equal tol 1e-10）。退出码 0 相等 / 1 不等 / 2 错误。 |
| `delegated-template-pipeline.py` | `d8840b923926323b22310b030d972a9eb376c6f7075f9a85bde41aac47c2c1de` | C10：子命令 ingest / signoff / scaffold / verify / ready，见下。 |
| `kiro_browser_check.py` | `866fca91e0179d603b5fdd8fbf35cee89ff8c836e26f2b48d1a9eedbe4792625` | Edge/Chrome `--headless=new` + CDP（websocket-client），1200×900 截图，plotly 图例第一项点击隐藏/恢复并读 `gd.data[i].visible`，结束时 psutil 终止进程树并删临时 profile。 |
| `tests/test_pipeline_guards.py` | `a94f5e79e8d4eddb74f386556b6ff7e2a4e0b58633519c6ca9ec74666bd0c2fc` | 12.7 守卫测试（7 项）。 |

## delegated-template-pipeline.py 要点

- signoff 前置：结构在清单内且唯一、`dedupe.decision=new`、条目 id 匹配 `2026-10-22-scp-example__figNN…` 且 NN≥18、`native.state=generated`、每个原生证据文件存在且 sha256 与清单一致、版式为 pending_signoff；任一不满足即拒绝（不调 API、不写审计）。
- 签核只走 `POST http://127.0.0.1:<port>/api/layouts/<id>/signoff`（urllib，可注入）；从不调用 `/note`。随后在版式页 agent 正文 `## 使用记录` 前（即 `<!-- user:start -->` 前）追加 `## 代签核记录`，经 `rwiki.pages.read_page/write_page` 写入；写后按字节比对作者区块，不一致即还原原文件并报错；再 `wiki.py save`，取 wiki HEAD 写入 D3 审计（seq 自增、授权原话、2026-10-26、approver=Kiro_Implementer、evidence 路径+sha256、official_call、official_result、wiki_commit）。
- scaffold：官方 scaffold-template 后把 spec.tables 改为接口 slug、example CSV 改名为 `<interface>.csv`；可选 `--assets`（code/、runtime.json、example/style.json、spec.json 的 style 与表描述）与 `--sections`（适用/不适用/知识关联检查，用官方占位规则拒绝 TODO 类首行）。接口页不存在时拒绝（需先 add-interface）。
- verify：设 R_LIBS_USER/PROCESSOR_ARCHITECTURE/TEMP/TMP、删 LANG/LC_* 后跑 verify-template；按清单材料与 verify/figure.* 对照，写 `templates/<tid>/verify/native-comparison.json` 并 save。
- ready：`interactive` 非空（3D）直接拒绝并写 `action=not_ready`、reason="交互输出，官方回放（PNG/PDF/SVG）不支持，未 ready"；对照未过或 check-entry 未过同样写 not_ready；通过时 check-entry → 写模板页代签核节 + save → 再 check-entry → mark-ready → 审计 template_ready。代签核节在 mark-ready 之前写入，避免 acceptance 指纹立即过期。
- 批次状态写 `<B>/coverage/visual-batches/<batch>.json`（`--batch`，缺省取结构的 batch 字段或 ungrouped）。

## 验证

- pytest（D:/anaconda，`-p no:cacheprovider`）：`tests/test_pipeline_guards.py` 7 passed。覆盖：reference_failed 与 sha256 不一致被拒且无审计；fig17、fig05、glaucoma 条目、清单外 structure_id 被拒（ingest 同样拒 fig17）；签核审计 D3 字段齐全、sha256 与文件一致、wiki_commit=HEAD、工作树干净；代签核节位于 `## 使用记录` 与作者区块之前、作者区块（含 CRLF 与伪标题）字节不变；作者区块被改动时还原；3D ready 被拒、未调用 wiki.py、写 not_ready。隔离 wiki 在 `E:/research-wiki-env/tmp/kiro-scp-pipeline-test/`（独立 git、非 main 分支），官方 ingest-figure 与 save 真实运行，签核 HTTP 由注入函数模拟官方端点行为。
- 额外冒烟（同一隔离副本，已删除）：scaffold → verify（Rscript 回放 rc=0，原生对照 equal=true）→ ready 全链路走通，模板变 ready，之后官方 check-entry passed=true（验收未过期）。
- compare-native.py：graph-straight.png 自比 equal=true；与 graph-curved.png 比 equal=false（17481 像素不同，MAE 0.4938）。SVG 直线/曲线 equal=false（元素计数不同），plotly cell-traces 自比 true、与 feature-traces 比 false。首版用 RGBA `getbbox()` 只看 alpha 通道误判为相同，已改为逐通道并集后复测。
- build-gallery-entry.py：在临时画廊冒烟一次（已删除），产出结构与 fig17 一致；GraphPlot 片段自动定位为 `R/SCP-plot.R` 6287–6631 行字节精确切片；官方 qa_check 如实报 `data/estimated_data.csv` FAIL（数据为原生导出，不伪造估读表）及无 PDF 时 `output/replica.pdf` FAIL。
- 浏览器实测（Edge 156.0.4314.42 headless）：`E:/research-wiki-env/work/codex-scp-native-3d/cell.html` → 5 条 scatter3d，WebGL 可用；初始 visible 全 true，点击图例第一项（Ductal）后为 `["legendonly",true,true,true,true]`，再点击恢复全 true；hide_ok=true、restore_ok=true；浏览器进程树已终止（remaining_pids 为空）。
  - 证据：`<A>/kiro-3d-browser-check-20261026T145225.json`（sha256 `f2ac9914484aac50957112c513294e68eef7ff79bb13fa33c08173ef4147924d`）
  - 截图：`E:/research-wiki-env/work/kiro-scp-native/v8-3d/cell-native-browser.png`（sha256 `eff0b881e5c4de137e810a65bc12220df21822ac91cf28f2c9f666c22d2050ff`，仅辅助证据/来源参考图）；隐藏态另存 `cell-native-browser-legend-hidden.png`。

## 未做 / 注意

- 未对 `<B>/wiki`、`<B>/gallery`、正式库执行任何官方写命令（彩排由主会话执行）；`<B>/coverage/visual-batches/` 尚未创建（测试用了隔离目录）。`<B>/wiki` 工作树本来就有 507 条未提交改动，HEAD 仍是 447798b，与本任务无关。
- `visual-structures.json`（C7）尚不存在；两个工具按 D2 字段读取。3D 的 traces RDS 材料 kind 接受 `plotly_traces`/`traces_rds`/`rds`，候选 traces 由 `verify --candidate-traces` 传入。
- compare-native 的 plotly 模式只比较 trace 字段；“外部 plotly_build 与 HTML 保存成功”须由生成脚本另留证据（输出中已写明）。
- qa_report 的人工视觉项需 Kiro_Implementer 实际读图后填写；脚本不评定。
- `<B>` 不是 git 仓库，本任务无提交。
