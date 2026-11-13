# Codex 第二轮补充：修复完成后逐项核对

2026-10-23。此文件在 review1 运行过程中补充；不得并发启动第二个编码进程。只有 review1 已退出后，仍未解决的项才在原会话 resume。用户继续授权 Claude 唯一编码、Codex 审查与独立验证；不安装、不启动子代理、不改统计算法、不部署、不代作者确认。

## C1：Monocle 分析核心保留计算步骤和真实前提

完整阅读 `codex-review-monocle-core.md`。目前正式 monocle2_core.R 只有一次带 root_state 的 orderCells，遗漏原代码先初步排序生成 State 的步骤。monocle3_core.R reduced_dim=NULL 时没有计算 UMAP 的路径，应显式要求已有对应细胞嵌入，不补新算法。保留精确缺包 not_run；静态解析、参数拒绝和假引擎测试不得称真实 Monocle 验证。

同步轨迹页输入/输出概述：当前默认仍只写Seurat对象和Lineage/BranchID，但core实际接受counts/元数据、返回CDS/State等不同对象。按实现说明共同语义与实际差别，不让新core被前端固定输入概述掩盖，也不要把不同输出冒充同一标准表。

23:12 中断续接的具体纠正：pilot3 的 monocle2_core.R 新增 `initial_root_state` 并强制非NULL，再第一次调用 `orderCells(cds, root_state=initial_root_state)`，这仍不正确。原版第一次是 `orderCells(cds)`，helper默认 `root_state=NULL`，此时才产生State；不能在State尚未产生时要求State标签。请保持原版第一次无根状态参数/NULL的初步排序，只有第二次最终定根才要求作者明确的root_state。不要新增必填initial_root_state，也不要在测试里传"1"绕过。保留第一步原有随机性/seed并记未验证，不把初步构图误解为作者最终生物学根选择。Codex的codex-monocle-contract.R可以复核两次调用与缺嵌入校验，缺包仍not_run。

## C2：辅助绘图不能授予分析可用，且避免新造未经选择的画法

完整阅读 `codex-review-auxiliary.md`。scp-monocle2-plot/scp-monocle3-plot 仍注册为 analysis 实现，纯绘图将来一旦 verified 就可能通过分析推荐门槛。移出分析实现与算法计数，作为辅助说明或已有技术资料的入口，不新造图库条目或平台。

新 monocle2_plot.R 仍将 reducedDimK 图节点坐标与每细胞 State 混用，label 分支也缺 x/y。优先薄封装官方绘图函数或忠实原代码，明确范围并保持缺包未运行。16 个已有模板不因此重画。同步正式/staged AGENTS、SKILL/references：运行函数不等于分析实现。

## C3：Python 必需依赖与真实调用一致

rna-velocity/runtime.json 使用独立 `python:[scvelo]` 字段，但 runtime_facts 和前端只消费 required_packages，Python 必需依赖被遗漏。将真实所需 Python 包纳入统一事实并同步页面 dependencies/代码guard；不要要求与选定分支无关的包。检查相似跨语言项，避免两个互相矛盾来源。加后端/API及前端定向断言，缺 scvelo 仍 not_run。

相应文档示例也要合法：references/minimal-runtime.md 当前示例 resources 列 palette，但 files 未包含它，与新校验矛盾；统一Python写法时一并修正示例，避免今后入库照抄生成无效清单。

C3具体核对：velocity_native.R的srt_to_adata实际 `check_Python(c("scanpy","numpy"))`，RunSCVELO还需scvelo，不应只把旧python:[scvelo]机械搬到required_packages。前端allPackages当前直接扁平化语言分组，R入口会让Python包看似也是R包；混合语言依赖请保留R/Python归属（短文本分组或带语言前缀），不再引入第二份包事实。

## C4：错误运行清单的诊断不能在分支/API或模板UI丢失

runtime_facts 已保留 malformed 清单 issues，但 implementation_runtime 的 fallback 把 issues 清空；方法分支不再显示具体错误。PageView 的 template-runtime 也没有渲染 portability.issues，方法/代码查看器需一并核对。缺历史清单可显示未审计，有错误清单应显示具体错误。修复通用传播与展示，不让清单错误触发500，也不把未声明的历史页整体封禁。

## C5：交付范围与实际证据

完成后重读 R6 并写逐项审查矩阵。尤其 batch 的现有上游错误、ORA 的 gene_ids/TERM2GENE/TERM2NAME 输入不变、实际执行时代码哈希、完整命令、真实比较结果必须准确。旧输出不得重绑新文件hash。新增辅助/核心分支需要单列not_run，不硬套旧9/7数量。

18:32 再核对：implementation_runtime 已开始保留 fallback issues，此部分先确认而不要重复重写；前端具体错误提示仍需核对。

18:35 证据复查的具体尚存问题：

- portable_run.R 的 ORA 分支仍用 `srt <- NULL; input_state <- serialize(NULL,NULL)`，末尾再比较NULL，不能据此断言 gene_ids/TERM2GENE/TERM2NAME 输入不变。请直接保存并比较实际传入对象；明确其中哪些只是测试夹具，不能宣称验证了任意输入。
- result.json 当前没有执行时 code 文件SHA；install_modules.py 读摘要后在写收据时从当前正式 code 重新计算hash。若文件曾在运行后变动，这会把旧执行错误地绑定到新代码。执行前后记录实际副本文件hash，写收据时核对正式文件与执行副本一致；不一致应待验证/重跑受影响项。算法收据、portability收据应采用相同原理，不能只看passed字符串。
- templates 的 receipt command 仍是 `<isolated>` 占位符，executed_at用写收据时间。render_templates.py应记录原实际命令、目录、运行时间和执行文件/资源hash，写入证据；不为改描述而无故重复16次渲染，若历史日志/实际隔离副本可准确核对就引用并明确证据形成方式，否则仅重跑缺失范围。
- batch-alternating-investigation.json 把交替A/B细胞顺序称为 `invalid batch layout` 不准确。合法的批次标签不因细胞交错排列就无效；证据是当前原版/新提取版同有该Assay错误。保留为已知上游/兼容性限制，连续分组夹具通过仅覆盖该场景，不泛称已支持所有合法细胞顺序，也不通过修改统计默认来修。

review1 已证明的隔离/嵌套source/资源hash等修复不无故重写。先做上述相关定向测试；代码稳定后按影响范围最后跑必要回归一次。保留各轮失败日志/报告；更新计划实际结果、清单、逐项证据和限制后退出，供Codex验收。
