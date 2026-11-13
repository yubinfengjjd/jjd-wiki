# Codex 独立审查结果

2026-10-24。C1–C5 软件修复审查通过，允许进入原计划的备份部署阶段；部署结果另见 final-acceptance.md。此结论不批准缺包分支，不代作者签核或真实课题验证。

- C1：正式 Monocle2 保留初步 ordering→显式 root ordering；Monocle3 拒绝缺失或不匹配嵌入。独立 `codex-monocle-contract-formal-green.log` 3项通过，仅静态/参数契约，算法仍 not_run。
- C2：实际元数据/API/浏览器均只列5个轨迹分析入口（Slingshot、两个核心和两个Seurat适配），没有纯绘图实现。Claude矩阵中“4个分析实现”为文字计数误差，最终以5个入口为准；旧自写绘图helper留维护快照。
- C3：独立后端事实检查和真实浏览器确认 required_packages 同含R与Python三包scanpy/numpy/scvelo；前端保留语言归属，代码默认复用版，原始来源仍可追溯。
- C4：资源变动/错误容器/实际入口不匹配复现脚本通过；前端模板与代码查看器展示清单问题；历史无清单页仍可读。
- C5：独立检查9个成功案例的执行副本SHA与实际副本一致、输入不变；正式方法9 verified / 9 not_run，16模板verified；当前清单及收据哈希无失配、命令无占位符。ORA改为比较真实基因和映射表。交替批次上游错误如实保留。

独立证据在维护记录/2026-10-23-最小依赖独立模块/：`codex-review2-targeted.log`（69通过）、`codex-review2-frontend-green.log`、`codex-review2-typecheck.log`、`codex-review2-receipt-audit.json`、两张浏览器截图、`codex-integrity.json`。正式/staged AGENTS逐字节一致；962原始来源及123页作者/id/status/favorite保护均通过。

完整后端回归由Claude执行：513通过/2跳过；Codex独立验证受影响范围，不混写成独立全套。前一轮独立QC/评分/DE原版对照仍有效（DE7956行完全一致）；本轮没有改动这些算法核心。16模板实际隔离重放PNG一致，R/Python标准render与bindings回归见原实施矩阵，相关实现未改算法。

待办3项为注释、双细胞、velocity家族缺少已验证实现；不安装依赖、不改状态清零。Monocle、Harmony、SingleR、scDblFinder等缺包及SeuratMap/Slingshot可选绘图兼容性限制继续公开。未核验的任何课题数据/科学推断不在本次软件验收范围。
