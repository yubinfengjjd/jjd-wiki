收到。Codex 复核列了 R1–R5 实际问题，先读官方 runtime_contract 解析器弄清 v2 字段契约，再逐项修。先摸清 R 里 `environment()`/`parent.frame()` 在 source 嵌套下的真实行为，再写 core.R。`ofile` 深扫描可行。再确认 `local({})` 内 `parent.frame()` 是否就是 source 的 local 环境。`environment()` 顶层==eval env；且 `local({})` 内 `parent.env(environment())` 应等于调用环境（local 的 envir 以调用 env 为父）。验证后写 core.R。确认。写私有闭包版 `core.R` 与收紧的 `panel.R`（拒绝 factor/顺序冲突、移除 draw）。更新 verify_module.R 用新导出名，再写 loader 边界测试（嵌套 source/双模块同环境/重复调用/因子拒绝/顺序冲突）。写 R1 边界测试脚本（嵌套 source/导出隔离/双模块共存/重复调用/直接调用契约）。ht1 旧 loader 的 `sys.frame(1)` 在函数内 source 会解析错——这正是 R1 的红测。共存测试里把 ht1 的 source 放在脚本顶层（它自身能工作的场景），我的模块单独测二级嵌套。三处要修：①测试脚本顶层变量污染 .GlobalEnv 造成误报（包 `local({})`）；②ht1 旧 loader 内部 `source()` 无 local，只能全局加载——共存测试按真实可用场景写；③`Missing palette data` 说明 `scp_helpers.R` 也靠 ofile 定位 rda，sys.source 后解析错。看 helpers 的路径解析。helpers 也靠 ofile 定位 rda——改成：env 变量优先 + 深层 ofile 回退。core.R 注入模块目录。重写 verify_loader.R：整个驱动包 `local({})`（harness 变量不污染 .GlobalEnv），ht1 共存测试拆到独立顶层脚本。修 verify_coexist：顶层运行（ht1 需要真实顶层），`rm` 保留 harness 变量。23/23 PASS。跑共存测试。两处小 bug：`before_b`/`HARNESS` 自身进了差集。修。9/9 PASS。重跑数值校验与新代码渲染对照。2m CSV 路径已迁到 `work/data-2m/`。改路径。18/18。重渲染全部分支，确认新代码下输出仍逐字节一致。三分支仍逐字节一致。现在 R5：按官方解析器契约重写 runtime.json（script 入口、完整业务 id、invocation）。用官方解析器算 closure_hash，再按新代码重做独立性复制+运行。清单解析零 issue，closure=`5b7722b9…`。重建异目录复制并重跑。不删旧证据，新建 `portable-r2/` 目录重跑，旧证据保留。重跑通过。取新文件哈希，写绑定当前闭包的独立性回执。官方 `runtime_facts` 给出 `portability.state=verified`。继续：①接口页措辞澄清（用 CLI/改 frontmatter 同步）；②画廊 code 副本同步；③verify.json/文档更新。先看 add-interface 是否支持更新列定义。接口列定义是 frontmatter 驱动的，正文可编辑。同步更新 frontmatter 列描述、facts 表与正文措辞（保留 user 区块）。同步画廊 code 副本到新代码并重生成其输出。画廊 render.R 找不到 spec.json（画廊布局是 `data/figure_spec.json`）。看 fig08 的 render.R 怎么处理。fig08 画廊里 render.R 本就不存在——画廊用 `replica.R` 入口。改写画廊 `code/replica.R` 为自包含可运行驱动（条目相对路径），删除误导性的 render.R 拷贝。不删文件，直接跑 replica.R（会原地覆盖同名输出）。`code/render.R` 在画廊里缺 spec.json 会坏——删掉它（本次新建的文件），render_code 指向 replica.R。保留 render.R，给它补上缺的 spec.json 使画廊内可运行。两处入口都可用且输出一致。更新 verify.json 绑定新文件哈希。更新候选 README（私有闭包/真实 API/无 draw）与 comparison.md。更新画廊 qa_report/README/run.log 与版式页表述。更新版式页验证范围表述（R1–R5 修复后）。更新三份报告与 progress。source-map 补一行加载契约，然后 lint + check-entry 收尾。接口澄清使 ht1 的 verify 回执绑定的 `render-group-heatmap#columns` 哈希过期——按规则对 ht1 重跑 `verify-template` 重新生成证据（不改其代码）。需要先加载 runtime profile 再跑 verify-template。ht1 回执已重绑（exit 0、PNG 仍 `00b0698d…`）。收尾 `save` 记录日志。2m 参考图在主目录而非子目录。重新核对。R1–R5 修复完成，最后的 ht1 回执问题已解决。收尾状态：

## 最终验证

- **ht1 模板**：`verify-template` 在 dot-source `scp-runtime.ps1` 后重跑成功，exit 0，PNG 仍 `00b0698d…`（字节不变），接口哈希已重绑到当前版本。此前失败是缺 `R_LIBS` 环境导致，非代码问题。
- **lint**：`OK`，仅剩既有 `not_run` WARN（trajectory-inference 等，与本次无关）。
- **fig17 版式**：`check-entry` 通过，仍为 `pending_signoff`；画廊条目仍 `draft`。
- **源生参考图不可变**：`native-dot.png`=`7CC121E7…`、`native-dot-reticle.png`=`AC5B96AE…`、`native-dot-2m.png`=`CE44217C…`，画廊 `source/fig17.png` 同字节。
- **官方 runtime_facts**：`entry=code/render.R`、`entry_kind=script`、`fingerprint_mode=v2`、portability `verified`、issues `[]`，新证据在 `evidence/groupheatmap-dot/portable-r2/`（旧证据保留）。
- **wiki.py save** 已记录本轮修复。

## R1–R5 落地情况

| 项 | 修复 | 证据 |
|---|---|---|
| R1 私有命名空间 | `core.R` 深扫 `ofile` + 私有闭包，`scp_helpers.R` 注入模块目录，导出仅 3 个 API | `verify_loader.R` 23/23，`verify_coexist.R` 9/9 |
| R2 输入/顺序校验 | 拒绝 factor/character/logical、非有限值、`percent∉[0,1]`、重复联合键、order 歧义与跨矩阵特征缺失 | `verify_module.R` 18/18；接口页措辞已更正 |
| R3 draw 契约 | 移除伪 `draw(rect)`；文档只声明直接函数返回原生对象 + `render.R` CLI | 候选/画廊 README、comparison、qa_report |
| R4 原生对照 | 三分支 PNG 修复后仍逐字节一致；PDF 时间戳差异、共享会话副作用范围已如实标注 | `verify/verify.json` + comparison.md |
| R5 runtime 契约 | `runtime.json` 重写为完整 id/script 入口/v2 字段；官方解析器验证，closure `5b7722b9…` | `runtime-portability.json`、`runtime-facts.json` |

停在审查点：版式待签核、画廊草稿、无正式模板、未部署。报告已更新：`result.md`、`groupheatmap-verification-matrix.md`、`source-map.md`、`progress.md`。