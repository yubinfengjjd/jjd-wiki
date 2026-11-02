Incomplete ACP turn; not a completion report.

收到新指令：先读两份 Codex 审查文件，然后 DE 只做有界收尾（不做隐藏 I/O），主交付转 GroupHeatmap。已读完两份审查。Codex 裁决要点清楚：注册表/隐藏 I/O 方案被否决，`options_restored` 必须按严格 `identical()` 报真值，且重复调用要立刻可用。给 DE 一个有界收口尝试：

- 移除 tempdir 注册表与全部隐藏 I/O。
- 入口侧：对已加载的 `use` 包重跑其自身 `.onLoad`（显式代码，重建设包默认值；调用方自定义值由快照恢复兜底），另对先前移除后遗留的"corrupt 不可读"内部 option 按名称前缀重跑属主 `.onLoad`。
- 恢复侧：`options_restored` = 严格 `identical(options(), before)`；对证明无法用公共 API 移除的内部受检 option（如 `future.globals.method.default`），如实记录在 `options_unreadable_after_restore`，不谎称残留为零、也不靠放宽判定造假绿。新错误：`impl$RunDEtest` 为 NULL。先最小复现定位：找到了：`for (name in names(options()))` 覆盖了 `run_scp` 的 `name` 参数，导致 `impl[[name]]` 用最后一个 option 名取函数。改名：进步：首调与错误路径全过。第二次调用仍挂在 `future.globals.method.default` corrupt——corrupt option 可能不出现在 `names(options())` 里。快速验证：`getOption` 在该 option 未由 future 加载设定时不会 corrupt——corrupt 状态只对包初始化设定过的内部 option 生效，且不出现在 `names(options())`，无法枚举。修复方向改为：入口对所有"非 R 核心、且本调用前已加载"的 namespace 重跑其自身 `.onLoad`（覆盖 future 这类传递依赖），不设隐藏状态；corrupt 披露字段保留。