# Codex 后端运行契约早期审查

2026-10-23。对象为当前 staged/rwiki/runtime_contract.py 与 method_implementations.py。修复由 Claude 负责；最终若代码改变须按复现重新判断。

证据：维护记录/2026-10-23-最小依赖独立模块/scripts/codex-contract-probes.py、codex-contract-probes.json。该脚本只造 validator 结构夹具，不声称运行算法。三项均真实复现，命令退出1。

## R1 — 资源不参与闭包指纹（必须修复）

runtime 的 resources 与 files 是独立字段。resources 中声明 data/palette.txt（包括 sha256），但未重复写进 files 时，read_manifest 接受、portability 可 verified；修改该资源内容后仍然 verified。closure_hash 只算 files，resource.sha256 也没有和当前字节比较。

必须将每个实际运行资源纳入证据闭包，或明确拒绝未列入 files 的资源声明；检查声明资源 sha256 是否一致，收据应覆盖完整代码+资源+清单。资源缺失、改字节、改声明时都不得继续 verified。不要只通过给本轮生成清单补文件来掩盖通用验证器漏洞。

## R2 — 实际登记入口与运行清单未交叉绑定（必须修复）

同一个 method implementation.id，页面 entrypoint=code/other.R:other，但 runtime 清单与既有 portability 收据针对 code/run.R:run，implementation_status 仍给该分支 runtime.portability=verified。入口文件都存在，旧 id/语言合法，单靠同 implementation.id 不足以证明该函数独立。

需要交叉核对页面登记入口路径和函数名、清单入口路径和函数名、证据闭包。一个改变而另一个未更新时明确失效/错误，不把另一个模块的独立性迁移给当前入口。依赖列表若仍保留于页面，要与共享清单有一致性检查，或明确一个为旧兼容字段、展示只使用唯一事实。

## R3 — malformed resources 导致未捕获 TypeError（需修复）

resources=7 时，runtime_facts 抛 TypeError: 'int' object is not iterable。当前 /api/pages 和 /api/page 都会调用它，一条错误清单可能使整个列表/页面500。

在解析层检查 resources 为 list、每个元素为对象等，统一返回问题列表；同样检查 evidence/source/packages 等 malformed 容器。页面可读且显示清单错误，lint/check-entry 能给具体说明，不把错误清单当成普通未审计历史。

## 与早期模块审查一起处理

同目录 codex-review-early.md 已有真实 E1 nested source、E2 同环境多模块相互覆盖、E3 attach残留。不能仅用每模块私有env的测试把它们绕开。

## R4 — Monocle 清单与实际包检查不同（内容与展示同步，必须修）

当前 trajectory-inference/runtime.json 的 scp-monocle2.required_packages.R 仅列 monocle、DDRTree、VGAM、BiocGenerics、Biobase；实际 code/monocle2.R:.scp_run 还无条件检查 Seurat、SeuratObject、Matrix、igraph、ggplot2、rlang。清单又继承了 Slingshot plot branch 的可选依赖说明。code/monocle2_native.R 还无条件使用多种绘图/交互（详见早期审查E4）。

前端将从清单显示少于实际要求的依赖，正是作者要求避免的前后端/代码不同步。按拆解后的真实分支生成清单，不复制家族另一算法的optional/source/modifications；生成和验收加入代码guard/所选功能/清单/前端的一致性核对。不能只补几行文案而继续无条件加载不需要的功能包。

同类实际遗漏：rna-velocity清单把scvelo放在独立的python列表，但runtime_facts将该列表丢弃，required_packages只有R包，前端因此不显示必需Python后端。应统一到required_packages.Python（及实际按功能需要的Python包），API/代码检查/页面同源；不要维持一份清单字段供执行、另一份字段供展示。RETICULATE_PYTHON选择既有解释器是运行条件，不能当成Python算法包本身已满足。

## R5 — 实际浏览器已证实重复且矛盾的依赖展示（需修复）

真实浏览器 localhost:8787：方法库→单细胞分析→轨迹与动态分析→拟时序与轨迹推断，URL筛选和15→13→3计数正常。详情表同时有旧“依赖”列和新“运行方式/必要依赖”段，Monocle2一处显示11包、另一处显示5包。截图：维护记录/2026-10-23-最小依赖独立模块/codex-browser-round1.png。

保留唯一依赖事实；有有效runtime清单时只用该事实，旧dependencies仅作历史兼容回退，不能并列两份列表。入口/复制清单/详细英文scope/精确错误放可展开部分；默认实现名、简短中文运行/验证状态和必要条件应可读，不把长函数名/包名挤成逐字换行。可以用紧凑行或小卡片，不需要大改整站。

代码查看器当前 setVariant 明确优先 original，即使已有独立复用版也先展示原始大文件；这会延续作者“方法看起来还是原始代码”的问题。已有复用入口的分析/模板默认打开复用版及真实入口文件，原始归档仍可切换查看；只有原版时如实回退，not_run 标签不能因默认选中复用代码而提升。加真实页面点击验证，不只测试label函数。

页面正文还残留“Monocle2/3分支未在本页实现”，但表中已登记提取分支。更新为“已提取、缺包未运行”或最终真实状态，不能正文、清单、代码和API各说一种状态。检查其他迁移页同类历史措辞。

## R6 — 收据检查项超出实际脚本、命令不可直接重放（必须修复证据）

当前各 portability 收据统一写了 `Input object serialized before and after the call`，但 scripts/portable_run.R 全文没有 serialize/before/input不变断言；它只运行后保存输出及诊断。Codex已独立验证QC输入不变，但不能替代其他分支的该项证明。请补充实际输入不变检查并重跑受影响分支，或者删除没有执行的检查项并明确限制；设计要求的输入不变仍须完成，而不是只改措辞。

当前收据 command 含 `<isolated-code-dir>`、`<out.rds>`，不是实际精确命令；portable_command(method,iid)又忽略iid，例如Monocle2/3或Harmony的命令可能选择到同家族另一实现。写入实际运行目录、具体case、输出和日志路径，能够直接重放该分支。测试日志/结果记录执行时代码/资源SHA与输入指纹；修复代码后必须重新运行，不能给旧输出重绑新哈希。

install_modules.py 的 algorithm receipt state 来自 config['algorithm'] 中硬编码 passed，不从本轮实际result/比较检查派生。当前看到的实际result.json与9个通过分支一致，但该生成方式会在将来失败/漏跑时仍产生 passed。修改为受实际执行/输出断言/比较结果约束，缺日志、未执行、失败则not_run/保留失败，不能静态配方授予算法通过。

保留首轮收据/日志快照，不伪造作者签核或抹掉失败。矩阵中“只缺依赖”的说法也修正：RunSeuratMap属于上游执行失败，不是缺包；Slingshot plot失败应在可选功能范围可见。

2026-10-23 17:43 的实际后续证据：portability/batch-integration/result.json 已为 not_run，错误为 invalid class "Assay" object: 'counts' must have the same cells as 'data'，input_unchanged=true。此时首轮报告与既有新收据仍宣称该分支passed。调查期间保留此失败；最终必须用同环境原版/新模块对照说明回归或上游问题，并以最终真实结果决定有效状态，不用早前通过或硬编码state覆盖失败。不要修改数据/阈值来绕过Assay一致性问题。
