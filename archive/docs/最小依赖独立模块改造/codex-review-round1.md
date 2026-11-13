# Codex 独立审查第一轮：未通过，不部署

日期：2026-10-23。用户授权继续修复，Claude是唯一编码者，Codex仅审查/独立验证。先重读本轮 design.md、implementation-plan.md 的执行记录，以及 codex-review-early.md、codex-review-runtime.md。这些是运行中追加的独立审查意见，初始Claude未必已读；不要再把旧T0-T6勾选或507通过当成通过本轮审查。

## 已确认的正向证据

- Codex从before原包装实际运行QC/评分/DE并保存原版结果，codex-reference-final.log退出0，codex-reference.rds可用于逐值对照。是SCP示例的软件行为验证，不是作者课题/科学验收。
- QC新模块无需bundle即可运行，与原版逐值一致、输入不变；但有后述会话污染。
- Codex完整性：962源文件哈希、123页作者区块/id/status/favorite均不变；codex-integrity.json。
- 真实浏览器点击领域→用途→轨迹详情成功，15→13→3计数/URL正确；源码/回放的现有边界保留。
- 首轮后端507 passed/2 skipped，前端24通过、类型/构建通过。它们没有覆盖下述实际失败。

## 修复优先顺序

1. **E1/E2/E3，模块加载与隔离**（codex-review-early.md）：嵌套source找错目录；两个真实模块source同一环境后前一个失效；attach依赖残留。Codex已在正式知识库代码重现三项，维护记录/codex-initial-installed-results.json及三份日志全部exit1。要用私有闭包或等效可靠隔离，不能只改测试让每模块各开env绕过。成功/失败均恢复调用前状态，不卸载用户原有包。
2. **R1/R2/R3，通用运行契约**（codex-review-runtime.md）：资源内容变化仍verified；实际登记函数不同仍继承另一个入口的迁移verified；错误resources容器导致未捕获TypeError。scripts/codex-contract-probes.py已复现三项。修通用解析/证据，不只改当前清单。
3. **E4/R4，真正的最小算法核心与清单一致**：尤其Monocle2当前无条件绘图/交互，静态闭包连带PAGA/Velocity/Sankey等；清单与实际包检查不同。按已确认设计分开分析、对象适配、可选绘图，缺包保留not_run但源码必须是真实算法提取，不允许stub/骨架。根状态不明时明确要求输入，不擅猜。自定义TERM2GENE等所选功能不要无条件要求无关数据库/ID转换包，不能为了少依赖换算法或默认阈值。
4. **R5，前端与笔记**：只展示一个依赖事实；默认简短中文状态/必要条件，长入口/详细scope折叠，避免大表逐字折行；有复用入口时默认查看复用代码，原始版可切换。轨迹正文“Monocle2/3未实现”等过时状态同步。真实截图codex-browser-round1.png可见依赖重复且不一致。
5. **R6，证据真实性/重放**：首版portable_run没有输入不变断言却写进收据；当前Claude已自行补部分检查，需核对所有分支尤其ORA的gene_ids/TERM2GENE及ref/query。使用实际case/完整路径/输出/命令，执行时代码和资源hash，actual结果和比较断言约束passed。不要用硬编码算法passed或给旧输出重绑新代码hash。已补项用实际证据关闭，不重复改动。

## 验证方式

- R一律显式SerialParam/sequential及单线程测试配置，不安装依赖，不重复开启18worker；不修改统计默认来让测试通过。
- 每个修改模块的测试调用须脱离完整SCP，异目录+新进程+嵌套课题driver；两个模块同环境先后加载后再分别调用；输入不变、参数/输出/必要资源和状态恢复检查。
- Codex既有复现脚本：scripts/run_module_probes.py接受日志前缀，内部支持指定正式模块；codex-source-probe.R/codex-multi-module-probe.R/codex-qc-probe.R已支持传正式代码目录。保留原RED日志，GREEN写新文件。修正测试夹具的契约合理性可以说明，但不能改掉它们证明的业务场景。
- 后端新增定向回归，R1资源漏列可明确拒绝或强制纳入闭包；R2入口路径及函数都检查；R3错误清单给诊断不500。算法验证与独立性仍分离。
- 前端实际点击而不仅SSR/label函数；修改后需要重新build并重启准确的测试服务，不重启正式8765。
- 规则/skill加上对应新入库防线，更新正式/staged AGENTS和references，不改作者状态/原始来源。sci-figure-replica现行SKILL及code-handling已要求读取正式Wiki规则和只复制所需模块；检查该链路引用是否足够，不无端改外部整套技能。
- 先定向RED/GREEN、R真实调用和相应前端测试；代码稳定后按受影响范围跑一次必要回归，后端/前端都有变化时跑全套。不要无改动重复全套。

## 交付与边界

同会话resume修复，不创建新Claude会话/任何子代理。原进程未结束不得启动第二个writer。首次进程异常、首轮报告/收据/日志快照均保留，review1-before和review1-before-hashes.json已保存188个本轮产品变更文件。

更新claude-result/verification-matrix/progress，单列本轮每个审查项的修复文件、精确命令、结果/限制。当前仍缺monocle/monocle3/scDblFinder/harmony/SingleR/velocity后端，按原授权不装；新提取核心仍待实际验证。上游RunSeuratMap/Slingshot绘图失败与缺依赖分开写。

到可复核状态就退出进程，供Codex重新检查。不要部署、不要正式服务重启、不要代作者签核、不要提交开发仓库历史dirty变更；知识库按CLIsave/验收规则批次处理。
