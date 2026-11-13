# Codex 独立审查补充：R helper 重复调用与报告（2026-10-23）

第一轮修复过程中独立调用同一 R helper 连续两次，发现以下遗漏。请在上一轮进程结束后用同一会话继续最小修复，不启动子代理、不安装包。

1. `prepare_binding_table` 检查调用了不存在的 `file.identical`（base R 4.5 `exists('file.identical') == FALSE`）。第一次写新输出成功，第二次合法重跑却报 `could not find function "file.identical"`。请改为真正可用的路径/原始文件保护方案；仅相同字节不能等同于硬链接，也不能因此拒绝正常重复运行。必须覆盖已有独立输出、输出别名/硬链接、第二个来源等情况，保证不改任何输入。尽量通过写临时文件+替换目录项确保安全，不对可能关联源的 inode 直接覆盖。
2. 同函数返回 `semantics = mapped$semantics`，但 `.map_binding` 不返回该字段，导致独立 R 报告 semantics=NULL，与 CLI 的明确限制不一致。使用共用语义说明常量或显式值，测试确实非空，不验证单位/统计粒度、配对，不自动换算。

独立脚本：维护记录/2026-10-23-分类与灵活输入/scripts/codex-review-repeat.R；RED日志：logs/codex-r-repeat-red.log。只修改本范围及必要回归，更新报告，保留旧证据。本轮完成前不部署。

补记：Codex 初轮全套477 pass/1 failed/2 skipped的单个失败来自启动测试时未加载 scp-runtime.ps1 导致 R locale/中文路径失败，不是待修产品缺陷；最终独立测试会先加载正确进程环境重跑。无需为此修改产品逻辑。

13:00 复核补记：合法重复调用已成功，`file.identical` 已移除；semantics 仍为 NULL。新增 `.same_file` 只有 fs 已安装时检查硬链接，base R fallback 返回 FALSE，但写入仍 file.copy(..., overwrite=TRUE)，无 fs 的课题环境遇到硬链接会改原表。这与“base-R可复制/不改源”的承诺不符。请用不依赖fs的安全输出替换方式，或在无法确认安全的既有输出上明确拒绝；加入强制模拟无fs的硬链接负例。不要安装fs。其他已修项不需重做。
