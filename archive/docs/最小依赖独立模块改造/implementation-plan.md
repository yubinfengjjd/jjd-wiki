# 方法与绘图最小依赖独立模块 Implementation Plan

> For agentic workers：作者指定单个 Claude Code 顺序执行；Codex 仅审查和独立验证。不得使用 subagent-driven-development 或启动任何子代理。按 executing-plans 的逐任务检查方式执行，不重复请求本轮已有授权。

**Goal:** 已入库方法和绘图在课题中仅凭所选实现的必要代码、资源与算法包独立运行，前后端与后续入库规则准确反映依赖及验证范围。

**Architecture:** 提取局部调用闭包，保留原生算法/绘图核心；完整 SCP 只作来源与对照。共享运行清单解析及独立性证据，与现有算法验证分离。既有方法家族、输入 bindings、render 和作者 workflow 保持兼容。

**Tech Stack:** Python rwiki、R 原生模块、React/TypeScript、既有 pytest/npm 工具链；无新增安装。

**Spec:** E:/research-wiki/文档/最小依赖独立模块改造/design.md。

## 全局约束

### 2026-10-23 18:42 执行阻塞与续接

- Claude 同会话 review1 已退出，exit 1；最终接口错误为 `402 Insufficient Balance`，不是代码验收完成。未启动 review2，无并发writer、无部署。
- 已保存 review1 报告/验证矩阵/progress/修复矩阵及下一轮相关文件快照。后端本轮512passed/2skipped；Codex独立正式模块source/隔离/输入保护及QC、评分、DE7956行原版对照通过；962源hash与123页作者状态保护通过。
- 独立审查仍未通过，剩余具体项见 `codex-review-round2.md`（C1-C5）及其链接补充，不能用上述测试覆盖这些问题。
- 必须先恢复Claude Code所用接口额度，再按维护记录 `run-claude-review2.ps1` 的防并发保护resume同会话。Codex不接替编码、不改模型/计费配置、不安装、不部署；修复后继续独立审查并按原授权收尾。

- Claude 是唯一编码者，不启动任何子代理、不调用 Codex 编码；Codex 只做计划、审查、独立验证和验收后部署。
- 不安装依赖，不读取/调用 E:/paper-harness；不运行 paperflow.* 或相关安装脚本。
- 不更改 source/original_code、作者 user/status/favorite/旧 id、原图及原数据；不重写已有历史收据。源归档保留 GPL/commit/字节/哈希。
- 开发仓库已有 61 项 dirty，禁止 reset/clean、批量覆盖或提交既有修改；知识库初始 clean，写操作最终 wiki.py save，lint/pending/check-entry 按实际范围处理，不伪造确认。
- 不删除历史资产，不更改科学默认/阈值/算法来求测试通过。原生图核心不换近似重画。外部成熟算法不重新实现。
- wiki/pytest：C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8；通用脚本：D:/anaconda/python.exe -X utf8。
- R：D:/R-4.5.0/bin/Rscript.exe；先读/应用 E:/research-wiki-env/work/scp-runtime.ps1；TEMP/TMP/MPLCONFIGDIR 使用 E:/research-wiki-env/tmp。
- 缺包保持精确 not_run，不将静态/假引擎/源码加载或上一轮整库封装的收据写成独立算法运行通过。
- 未通过 Codex 审查不部署、不重启正式服务、不提交开发仓库。过程状态写本轮维护记录。

## 路径及已有基线

- 规则：知识库/AGENTS.md；源码副本：开发/staged/research-wiki/assets/AGENTS.md。
- 后端：开发/staged/research-wiki/rwiki/{method_implementations,code_assets,server,lint,acceptance,verification,templates,spec}.py。
- 前端：开发/frontend/src/{api,CodeViewer,methods}.ts[x]、views/{MethodOverview,PageView,MethodsView}.tsx、tests/。
- skill：开发/staged/research-wiki/SKILL.md、references/；五处安装由 tools/deploy.py 处理，Claude 不直接覆盖安装。
- 内容：知识库/methods/*.md 及各 code/；知识库/templates/*/code/、spec.json 与页面。完整来源仅在 methods/scp-local-source/code/SCP-local 与既有 source/original_code。
- 维护记录：维护记录/2026-10-23-最小依赖独立模块/。before/ 与 baseline.json 由 Codex 在启动前建立。
- 已验收成果：文档/方法分类与灵活输入改造/final-acceptance.md，方法家族与LLM-Wiki改造/final-acceptance.md。

## T0 — 全量依赖清单及分支边界

**产出：** dependency-inventory.json/md；每个受影响旧入口→新入口→源函数→依赖/文件/可选功能→验证范围映射。必须从实际调用追踪，不只 grep 包名。

- [ ] 读取设计、正式规则、旧验收、本轮 baseline，确认没有同任务 Claude 并发进程。
- [ ] 审查全部方法/模板代码；当前发现 13 个 analysis 家族有 SCP 相关代码（不等于全都依赖整库），16 个 SCP 单 panel 已有局部核心。
- [ ] 逐分支列 source、::/:::、get/getFromNamespace、check_R/Python、加载文件、options/全局数据、资源、网络/安装、隐式绘图/保存等依赖。记录哪些是成熟包传递依赖，哪些是无关整库加载。
- [ ] 对可运行分支保留原版同输入输出基线（数值/对象关键槽/图数据和必要图像）。原始 full bundle 只用于审查对照，不复制进新模块、不成为新模块测试运行条件。
- [ ] 固定共享清单的最小 schema 和派生状态，并把决定记录在本计划末尾；后续前后端和 references 使用同一事实。

## T1 — 独立性清单、证据与后端同步

**Files:** 新 rwiki/runtime_contract.py 或等价小模块；method_implementations.py、code_assets.py、server.py、lint.py、acceptance.py、模板 metadata/spec 实际入口；tests/test_runtime_contract.py 及受影响测试。

**Consumes:** 方法实现/模板的清单路径、条目资产根；**Produces:** 安全解析的运行模式、必要包/可选包、复制文件清单、独立性证据状态/范围，供 API/前端/检查共用。不得在 API 自动执行或检查任意本机环境。

- [ ] RED：缺清单=unknown；bundle 不显示独立；standalone 声明但无证据只能显示声明未验证；非法路径/逃逸/缺文件/重复项报具体错误；改入口/helper/资源/清单使 portability 收据 stale；不以清单授予算法 verified。
- [ ] GREEN：共享解析、清单检查、API 派生、lint/check-entry、代码查看器分支信息同步；旧页无清单仍可读并准确提示，不能批量失效作者状态。
- [ ] 保持 schema1 算法证据兼容；新增证据绑定实际复制闭包和清单。未改变算法代码的非 SCP 方法不重复科学运行。
- [ ] 测试不以伪造 passed JSON 代替模块真实调用；结构测试仅说明结构检查能力。

## T2 — 分析实现拆解

**Files:** methods/{cell-quality-control,doublet-detection,dimensionality-reduction,batch-integration,cell-type-annotation,differential-expression,gene-set-enrichment,gene-set-scoring,trajectory-inference,dynamic-feature-analysis,reference-mapping,rna-velocity}/code/、运行清单、验证及正文；cell-clustering 和非 SCP 实现只核对必要差异。

- [ ] 先迁移一个现有可运行分支，做新进程异目录复制/真实调用/对照作为样板；不能先批量改清单后无真实样板。
- [ ] 每个分支提取原生函数和传递 helper，或对真实底层包做语义等价直接调用。source/加载时不检查其他分支包，不加载 palette/绘图/Python 等无关模块。
- [ ] 核心与输入适配分开；只宣称真实实现的输入格式。保留既有函数/返回结构，旧 bundle 参数可兼容接受但不能读取；不支持兼容时保留旧分支并明确新增。
- [ ] 双细胞分支只检查实际选中算法；明确捕获批次/预期双细胞率/随机性，外围检查 score/class 输出真实产生，不能吞错返回旧对象当成功。
- [ ] 整合/参考映射/差异/富集/动态算法保留当前源逻辑及参数；凡调整行为列出差异。velocity 只检查实际执行需要的 Python 环境，不创建环境。
- [ ] 从固定版本 RunMonocle2/RunMonocle3 实际源码提取已有家族分支及必要 helper；不从头补算法，缺包静态检查后 not_run，不按名称新建家族。
- [ ] 每个可运行分支：原版/新模块同输入同参数比较；复制所选文件到维护记录独立临时课题，不给 bundle，在新进程调用；换合法规模/名称数据；输入内容 hash/对象关键槽不变；记录加载命名空间。允许必需包正常传递依赖，不把“无法卸掉底层 Imports”当失败。
- [ ] 缺依赖/上游失败分支记录准确错误与影响；可完成源码提取和静态闭包审计，独立迁移/算法验证保持 not_run。

## T3 — 绘图独立性、旧 render 与灵活输入

**Files:** 16 个 SCP templates/*/code/、运行清单、页面/spec（必要时）；rwiki/templates.py/verification.py/脚手架与相应 tests（只改受影响调用链）。

- [ ] 逐个检查已提取的 scp_*_native.R、scp_helpers.R、core.R、draw.R/render.R、palette/data 文件；已独立不重写。删除无关加载必须有调用审计依据，不删原始归档。
- [ ] 保留单 panel 原生核心、图层/主题/配色/统计输入的来源与行为。可选叠加层依赖只在启用时检查，必要底层包不硬剥。
- [ ] 每个现有环境能跑的模板：复制清单文件/资源到异目录，新 R 进程直接调用绘图入口；同输入与旧版比较关键绘图数据和 PNG/PDF/SVG，给出视觉或差异容差理由。
- [ ] 从真实 CLI 调用原标准输入 render；代表 Python/R 模板调用已部署的 bindings 改名输入，与标准结果对照；不把绘图变成统计重算，不影响 layout/单 panel/尺寸策略。
- [ ] 记录每个模板的实际通过/未运行和资源依赖；来源参考图不能替代本轮真实回放，不更改作者 ready。

## T4 — 前端展示与实际路由

**Files:** frontend/src/api.ts、CodeViewer.tsx、views/{MethodOverview,PageView}.tsx、必要样式/测试。保持 MethodsView 两级分类和 URL 现有行为。

- [ ] RED/GREEN：同一后端事实在方法分支、模板详情、代码查看器显示一致；无证据不显示“独立已验证”；bundle/unknown/standalone+not_run 区分明确。
- [ ] 默认只显示简短运行方式和必要依赖，复制文件/可选功能/证据折叠可达；不复制一套包列表或将 backend server 的安装状态标为课题可用。
- [ ] 使用测试服务（不同端口），真实浏览器点击领域→用途→具体方法→代码；模板详情→代码/复制清单；验证新状态、旧搜索/计数/URL、来源/回放和单 panel 展示。
- [ ] npm test/typecheck/build，通过后构建产物放 staged 现有目录，Claude 不部署。

## T5 — 正式规则、skill、入库与知识编译

**Files:** 正式/staged AGENTS、SKILL、references/{method-families,project-reuse,code-assets,llm-wiki-mode}.md 及真实存在的 source-functions/函数化相关 references；可新增 minimal-runtime.md；README/当前要求索引；受影响方法/模板笔记。

- [ ] 八步收录的方案/提炼/验证/验收增加最小调用闭包、必要/可选依赖、资源、独立复制、新进程执行、精确证据范围；保留语义去重和分类/bindings，不按来源或模块包装重复入库。
- [ ] 写清新收录不得以完整来源库加载器冒充独立；未拆解只能标 bundle/unknown，不能因 JSON 声明推荐为独立已验证。
- [ ] 全文检索并修订当前仍要求“复制完整 SCP-local 才能运行”的活跃使用说明；历史维护记录/来源档案不抹掉，改为明确历史口径或指向新入口。
- [ ] 方法正文缩短重复技术说明，默认讲研究用途/输入输出/分支选择；复制和依赖细节指向对应清单；保留旧 id/来源/作者块和语义关系。
- [ ] save 重建 index/追加 log；受影响条目 check-entry --record，不代作者签新版本或改变状态；lint/pending 明确预期 not_run 和实际开放项。

## T6 — 交付 Codex 审查、修复及部署

- [ ] 写 progress.md、claude-result.md、verification-matrix.md、dependency-inventory、精确测试命令/退出码/逐分支和逐模板表；列出部分完成和缺依赖，不只报告测试总数。
- [ ] 全套 pytest 与前端 test/typecheck/build（新失败留日志并解决）；源码/原图/作者/旧 id/原输入保护与 baseline 比较；禁止只用入口加载/假引擎/收据结构测试代替真实验证。
- [ ] Claude 停止到可审查状态。Codex 独立看实际差分、抽查必要 helper/隐藏依赖、运行已迁移代表分支和真实 CLI/浏览器。发现问题写 review-roundN.md，仅原进程结束后 resume 同会话修复，不重复启动。
- [ ] 审查通过后 Codex 调 tools/deploy.py，备份五处安装并逐文件 hash 核验；准确重启正式 8765 服务，检查 API/静态资源/真实浏览器；保留部署和回滚资料。
- [ ] 最终验收给出方法分支/模板迁移数量、真实通过范围、not_run 和剩余作者确认。若仍有活跃实现依赖整库且未明确隔离，不能宣称本轮完整完成。

## 需求追溯与自查

最小依赖实际代码=T0/T2/T3；Monocle2/3=T2；必要与可选依赖=T1/T2/T3；前后端一致=T1/T4；后续入库/skill=T5；源/作者保护与 LLM Wiki=T0/T5/T6；Claude 执行、Codex 审查=T6。

不引入无关平台、不发布公共包、不自动安装、不新增批量上游方法、不以改清单替代真实拆解。当前设计已由作者连续确认，本轮直接实施，技术选择按最小可行实现记录，不重复问已明确范围。

## 执行记录

Claude 首次实现共享清单时在此追加：字段、清单位置、证据绑定、API 字段和兼容方式的最终选择；后续审查以实际契约和设计验收。

Codex 早期样板审查补充：见同目录 codex-review-early.md。nested project source 已真实复现资源定位错误；多模块同环境加载的引擎/通用名称隔离须实际验证。正式迁移/交付前处理并保留 RED/GREEN，不以单个私有env回放覆盖日常组合调用。

Codex 后端结构审查补充：同目录 codex-review-runtime.md，R1资源指纹漏绑、R2实际登记入口与清单入口不一致仍verified、R3错误resources容器导致API未捕获TypeError，均有独立复现。交付前修复通用检查而不只修本轮清单数据。

修复中的Monocle核心静态对照补充见 codex-review-monocle-core.md：保留Monocle2初步orderCells→显式root_state再次orderCells的原步骤，Monocle3需明确已有嵌入前提，不补新降维算法。缺包保持not_run。

辅助绘图边界补充见 codex-review-auxiliary.md：plot_monocle2/3不能进入analysis实现计数/算法推荐门槛；新helper需正确区分细胞与图节点、具备x/y美学，优先底层官方/原生入口，不为解耦创造未经验证的新样式。

## 执行记录（Claude，2026-10-23）

- 运行清单：资产根 `runtime.json`，`schema_version=1`；方法用 `implementations[]`，模板用单对象；字段为 `entry`、`entry_function`、`language`、`runtime_mode`、`files`、`resources`、`required_packages`、`optional_packages`、`python`、`source`、`evidence.portability`。
- 解析与派生：`rwiki/runtime_contract.py` 唯一实现；拒绝绝对/越界/隐藏路径、缺失文件、重复文件/包/实现、符号链接逃逸。API 只读，不扫描课题目录。
- 状态：`runtime_mode=standalone|bundle|unknown`；`portability=verified|declared|not_run|stale|invalid|bundle|unknown`。`verified` 要求独立性收据 `closure_hash` 与当前清单+文件一致，且异目录/新进程/实际调用检查齐全。
- 与算法验证分离：方法分支仍读 `implementations[].verification` 的 schema1 收据；runtime 只附在 `implementation_status[].runtime`、模板详情的 `runtime` 和代码查看器分支，不改变算法 `state`。
- 证据绑定：独立性收据记录 `closure_hash`（runtime.json + 声明文件）与逐文件 SHA-256；清单/入口/helper/资源/依赖变化即 stale。旧算法收据保留，新收据命名 `verification/<impl>-standalone.json`。
- 兼容：入口保留 `(srt, bundle = NULL, parameters)` 等旧签名；`bundle` 非空只警告、不读取。SeuratObject >= 5 的 `GetAssayData(slot=)`/`Assays(object, assay)` 用显式 shim 映射到同值；`SCP::palette_list` 改为本地 palette 数据；`check_R`/`check_Python` 改为 fail-only。
- 前端：方法实现表、模板详情、代码查看器共用后端字段；默认只显示运行方式、独立性状态与必要依赖，复制清单/可选包/证据折叠。

## 实际状态（2026-10-24，review2 修复后）

- 方法实现 19 个：9 个独立迁移+算法 verified（cell QC、dimred、Seurat integration、DE、ORA、scoring、Slingshot、dynamic features、Seurat label transfer）；9 个 not_run（doublet、harmony、SingleR、RunSeuratMap、scVelo、Monocle2/3 core、Monocle2/3 adapter）；其余非 SCP 方法未登记 runtime。
- Monocle2 core 保留原版两次 ordering：第一次无 root_state 产生 State，第二次显式 root_state；Monocle3 core 要求已有且顺序一致的 reduced_dim。缺 monocle/monocle3，真实算法 not_run；静态 contract 3 PASS。
- 纯绘图辅助（monocle2_plot.R/monocle3_plot.R）不进入 analysis implementations、runtime 或算法计数，只留维护快照；16 个既有模板未重画。
- Python 必需包并入 required_packages（rna-velocity: scanpy/numpy/scvelo），前端按语言显示；缺 scvelo 仍 not_run。
- 独立性/算法收据记录实际命令、case、执行副本 code hash、输入/输出哈希；正式 code 与执行副本不一致即不 passed。模板收据记录实际命令/目录/时间/哈希。
- 限制：Monocle 初步 ordering 与真实算法未运行；RunSeuratMap 投影与 Slingshot plot 是上游/绘图失败，单独 not_run；交替 batch 顺序原版/新分支同错，连续分组夹具不代表所有合法顺序；未部署、未提交开发仓库。


## 最终执行状态（2026-10-24，Codex）

T0–T6的软件实施、独立审查、备份部署和正式服务验收已完成；原始检查清单作为计划历史保留，最终逐项结果以同目录final-acceptance.md及codex-review-accepted.md为准。五处各285文件SHA一致；513全套通过/2跳过（Claude执行），Codex独立后端定向69通过及R/浏览器/证据审计通过。18分支9 verified/9 not_run，16模板verified；缺包和上游兼容性限制未被宣称解决。pending仍有3个家族待实现验证，作者状态与原始来源保持。
