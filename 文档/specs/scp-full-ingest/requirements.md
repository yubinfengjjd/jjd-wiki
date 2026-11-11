# Requirements Document

> **状态：暂停（2026-10-27，作者决定 1=a）。** v2 精简规则已落地（见 文档/v2精简与FigureYa入库/计划.md）。剩余任务不再按本文件的旧门禁（八步逐条确认、Issue/PR/他人评审、写入锁、只经画廊）推进，待按 v2 规则（来源登记 → L0/L1 批次 → 用到再做 L2）重排后另行执行。已入库的 SCP 模板与方法保留 id 与证据。


## Introduction

本特性把 SCP 仓库（固定源码提交 `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，SCP 0.5.6）的**全部分析方法与全部可视化**，按 research-wiki 现行入库规则（正式库 `AGENTS.md`、research-wiki `SKILL.md` 及 references）入库并模板化。范围是整库：142 个 NAMESPACE 导出、238 个 function/ggproto 原始 AST，其中 22 个主要可视化入口，富集/GSEA/统计/速度等图有多个具名形态。

上一轮由 Devin 编码、Codex 审查，已在隔离工作区留下 79 个自包含模块、32 个方法/技术页和若干已通过的原生对照证据，但正式库尚未合入本轮候选，且有六类未闭合项。本轮不再使用 Devin，由 Kiro 自己编码、验证、合入。可复用上一轮已通过且哈希仍现行的资产与证据；最终代码冻结后改过的部分必须重验。代码存在、加载成功或进程 exit 0 都不算 verified。

已从上下文确认的事实（作为约束）：

- 隔离快照（`codex-method-states-isolated-20261026T082332.json`）：7 verified、11 stale、1 invalid、83 not_run、0 ready_for_use。
- 正式库基线：12 个 ready 分析家族、13 个 verified 实现、17 个 SCP 示例模板（含作者已签核并 ready 的 fig17 GroupHeatmap 点阵模板 `2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap`）。
- 导出分类（`coverage/exports.json`）：analysis 27、analysis_backend 28、visualization 22、workflow 2、helper 42、environment 12、reexport 5、resource 4。
- `coverage/wiki-map.json` 仍为旧版；隔离画廊尚无本轮新原生来源草稿。
- fig17 点阵图由作者本人签核并已 ready。
- 作者于 2026-10-26 口头授权（原话："不用我审签了你直接代替我审签，全部入库成为模板"）：由 Kiro_Implementer 代作者签核本轮其余全部 SCP 可视化图样（Delegated_Approval），范围为 22 个可视化入口及其具名形态中每个尚无模板覆盖、结构实质不同的结构，全部入库并转成正式可调用模板。代签核只表示"图形结构与原生输出一致、可作模板"，不代表科学认可；是否进入 ready 仍以模板回放与原生对照的实际结果为准。

## Glossary

- **Fixed_Source**：只读 SCP 源码，`E:/research-wiki-env/sources/scp-2026-10-22`，提交 `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`。
- **导出入口**：Fixed_Source NAMESPACE 中的 142 个导出对象。
- **原始AST**：从 Fixed_Source 提取的 238 个 function/ggproto 定义及其字节哈希。
- **具名形态**：一个导出入口内由 `plot_type`、`match.arg`、后端参数等分派出的、有独立科研或结构意义的分支（如 EnrichmentPlot 各型、StatPlot 11 型、NMF 后端）。
- **Isolation_Workspace**：隔离工作区 B，`E:/research-wiki-env/work/scp-full-ingest-20261025`，含 `coverage/`、`wiki/`、`gallery/`、`scripts/`、`development/`。
- **Formal_Wiki**：正式知识库 `E:/research-wiki/知识库`。
- **Maintenance_Record**：维护记录区 A，`E:/research-wiki/维护记录/2026-10-25-SCP全库入库`。
- **Module**：`coverage/modules-index.json` 登记的 79 个自包含模块之一（分类 analysis 27、analysis_backend 28、visualization 22、workflow 2）；该索引是模块权威索引，其他历史目录不计。
- **Module_Loader**：模块的私有闭包加载层（由 `scripts/assemble-modules3.py` 组装），负责符号解析、包加载与调用后恢复。
- **Coverage_Map**：142 个导出入口及其具名形态的唯一去向表（机器可读文件 `coverage/wiki-map.json` 及人读对照表）。
- **Method_Family**：`method_kind=analysis` 的规范分析家族页；`workflow` 为组合流程资料，`technical` 为源码/环境/绘图接口技术资料。
- **Runtime_Manifest**：实现或模板资产根的 `runtime.json`，由 `rwiki/runtime_contract.py` 唯一解析。
- **Algorithm_Receipt**：`verification/<实现id>.json` 算法验证收据，状态 passed/not_run 等。
- **Portability_Receipt**：独立迁移收据，记录异目录复制、新进程、不提供来源库路径的实际调用。
- **Native_Oracle**：已有原生对照材料，位于 `Maintenance_Record/native-oracles` 及 `E:/research-wiki-env/work/codex-scp-native-{structures,trajectory,graph,3d,largevis,fr}`。
- **Case_Runner**：`scripts/run-iso-case.py`、`scripts/run-family-cases.py` 等生成收据的执行脚本。
- **Legacy_Replay**：`scripts/replay-legacy.py`/`replay-portable.R`，用旧基线 `result.rds` 做语义比较的回放。
- **Code_Freeze**：所有模块代码、helper、`runtime.json` 定稿后的时点；之后算法收据与独立性收据才可作为最终证据。
- **Gallery_Draft**：按真实画廊 schema 建立、以原生真实输出为来源、经官方 `ingest-figure` 收录的单 panel 来源条目；收录后经 Delegated_Approval 转为 approved。
- **Delegated_Approval（代签核）**：作者于 2026-10-26 口头授权 Kiro_Implementer 代为签核本轮 SCP 图样（fig17 除外，fig17 已由作者本人签核）。每次代签核须留一条审计记录，含授权原话、授权日期、签核者=Kiro_Implementer、签核时间、依据的原生对照证据路径与 sha256；审计记录写入 Maintenance_Record 和条目备注/日志，且不写入或改动 `<!-- user:start/end -->` 作者区块。
- **Visual_Structure**：一个可视化入口或其具名形态下，视觉编码与附属结构实质不同、需单独模板覆盖的图形结构。
- **Scaffold_Template**：经官方 `wiki.py scaffold-template` 从 approved Gallery_Draft 生成的正式可调用模板。
- **Protected_Assets**：Fixed_Source 字节、画廊原始资产、`<!-- user:start/end -->` 作者区块（字节级含换行）、页面 frontmatter `status`、既有页面/实现 ID、正式开发代码。
- **Wiki_CLI**：`wiki.py`，以 `C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8` 运行。
- **Wiki_Server**：本机正式 Wiki 网页服务（端口 8765），提供 API（如 `/api/page?path=methods/foo.md`）与 SPA（如 `/#/page/templates/<id>.md`）。
- **R_Runtime**：先 source `E:/research-wiki-env/work/scp-runtime.ps1`，再以 `D:/R-4.5.0/bin/x64/Rscript.exe --vanilla` 运行，`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，AMD64，清空 `LANG`/`LC_*`。
- **Kiro_Implementer**：本轮唯一的编码、验证与合入执行者。
- **Baseline**：正式库 12 个 ready 分析家族、13 个 verified 实现与 17 个 SCP 示例模板（含 fig17 ready）。

## Requirements

### Requirement 1: 唯一执行者与工作区接续

**User Story:** 作为作者，我希望本轮由 Kiro 独立接续同一磁盘任务，以便不会出现并发编码者覆盖彼此成果。

#### Acceptance Criteria

1. WHEN Kiro_Implementer 开始写入 Isolation_Workspace 之前，THE Kiro_Implementer SHALL 用精确命令行进程核对确认上一轮 Devin 会话（finalize10，session cuddly-custard）及其测试进程已不存在，并把核对结果写入 Maintenance_Record。
2. IF 核对发现仍有上一轮编码或测试进程在写 Isolation_Workspace，THEN THE Kiro_Implementer SHALL 停止写入并向作者报告进程标识与命令行。
3. THE Kiro_Implementer SHALL 把 `task-state.json` 的编码负责人更新为 Kiro_Implementer，并保留上一轮 session 记录。
4. THE Kiro_Implementer SHALL 以 `codex-independent-checkpoint-20261026T0830.md`、`codex-finalize10-live-review.md` 与 `codex-finalize10-handoff.md` 列出的未闭合项为工作起点，复用已有 Module、Wiki 页与 Native_Oracle，不从零重新盘点或重写生成器。

### Requirement 2: 全量覆盖与唯一去向表

**User Story:** 作为作者，我希望 SCP 每个导出入口都有一条真实可追踪的去向，以便确认整库没有遗漏或被合并计数掩盖。

#### Acceptance Criteria

1. THE Coverage_Map SHALL 为 142 个导出入口各保留恰好一条主记录，主记录键为导出名。
2. THE Coverage_Map SHALL 为每条主记录写明分类（analysis、analysis_backend、visualization、workflow、helper、environment、reexport、resource 之一）、Fixed_Source 内源文件路径与原始AST 哈希。
3. WHEN 主记录分类为 analysis、analysis_backend、visualization 或 workflow，THE Coverage_Map SHALL 写明所属规范页 ID、实现 ID、Module 名和官方当前状态（从 Wiki_CLI 的 implementation_status 读取）。
4. WHEN 主记录分类为 helper 或 resource，THE Coverage_Map SHALL 列出实际消费该对象的 Module 名单。
5. WHEN 主记录分类为 environment 或 reexport，或某导出不入库，THE Coverage_Map SHALL 写明有依据的排除理由。
6. THE Coverage_Map SHALL 为每个导出入口内的具名形态另列子记录，包含分派参数值、去向和各自验证状态。
7. THE Coverage_Map SHALL 把 GeneConvert 与 PrepareDB 记为函数，而不是包数据资源。
8. THE Coverage_Map SHALL 让 238 个原始AST 中每个定义都能追溯到至少一条主记录或子记录。
9. THE Coverage_Map SHALL 分别计数源码覆盖、实际入库、仅存源码、数值或绘图对照通过、独立迁移通过五个指标，并把第六个指标拆为代签核数、模板化数与 ready 数分别计数，且不把记录行数当作入库数。
10. IF Coverage_Map 任一记录的去向为空、为"稍后整理"类占位或指向不存在的页面/实现，THEN THE Kiro_Implementer SHALL 判定覆盖未闭合并补齐该记录。

### Requirement 3: 方法家族归属与语义去重

**User Story:** 作为作者，我希望 SCP 的分析入口汇入已有规范家族而不是按包新建同义页，以便方法库保持一个规范入口。

#### Acceptance Criteria

1. WHEN 一个分析类 Module 入库，THE Kiro_Implementer SHALL 按研究问题、输入语义、行/样本单位、估计目标和算法假设决定其归入已有 Method_Family、作为新分支、记为 workflow 或 technical，并在页面正文写出判定依据。
2. THE Kiro_Implementer SHALL 只在确认出现新的分析目的时提议新建 Method_Family，并在提议中说明与最相近已有家族的差异。
3. THE Kiro_Implementer SHALL 把纯绘图函数和辅助函数排除在 analysis 页的 `implementations` 之外，并把它们记录在技术资料页或正文辅助说明中。
4. THE Kiro_Implementer SHALL 保留上一轮已纠正的归属：PAGA、Palantir、WOT 归入 trajectory-inference（WOT 注明真实时间输运边界），Integration_SCP 归入 workflow，Count-recovery 为独立 draft 家族，RunFR 为图布局，LargeVis 为 R uwot 实现。
5. WHEN 旧 SCP 实现页被改为来源/实现资料，THE Kiro_Implementer SHALL 保留其旧 ID、`source/` 与作者备注，并在正文链接到规范家族。
6. THE Kiro_Implementer SHALL 为每个 analysis 家族只使用 `rwiki/method_taxonomy.py` 词表中的 `purposes` 值，并且只使用受控词表中的 `tags` 值。
7. THE Kiro_Implementer SHALL 交付"旧页/来源 → 规范家族 → 具体实现 → 原始来源"对照表，覆盖本轮全部受影响页面。
8. WHERE 同一家族含多个后端（整合、降维、双细胞、注释、映射、富集、轨迹、速度），THE Kiro_Implementer SHALL 为每个后端单独登记实现与验证状态。

### Requirement 4: 模块封装与环境隔离

**User Story:** 作为课题 agent，我希望复制的 SCP 模块在共享 R 会话中不受作者全局变量影响，以便同一入口在不同课题环境给出相同结果。

#### Acceptance Criteria

1. THE Module_Loader SHALL 把每个入口及其 engine、helper、包检查封装在模块私有闭包中，只向 source 环境暴露入口函数。
2. THE Module_Loader SHALL 以当前被 source 文件（最内层 `ofile`）定位模块目录。
3. THE Module_Loader SHALL 以 baseenv 及受控的标准包 namespace 与显式导入符号作为模块解析链，而不是以 globalenv 作为 imports 父环境。
4. WHILE 作者全局环境存在与模块内部符号同名的普通变量（如 `matrix` 为 dgCMatrix），THE Module_Loader SHALL 使公开 MDS 入口对同一真实 counts 输入产生与无该变量时相同的数值结果。
5. THE Kiro_Implementer SHALL 在修复解析链时保持原 `as_matrix` 等源算法字节不变，并且不要求作者改名或删除自己的变量。
6. WHEN 模块以 `source(local=env)`、嵌套课题 driver source、或多个模块先后加载到同一环境的方式使用，THE Module_Loader SHALL 让每个入口分别调用成功并使用自己的引擎。
7. WHEN 修复解析链后，THE Kiro_Implementer SHALL 在新进程用公开 MDS、NMF（`nmf.method=NMF`）、GraphPlot 与两个 3D 入口做回归，并与 Native_Oracle 比对一致。

### Requirement 5: 调用前后会话状态恢复

**User Story:** 作为课题 agent，我希望调用 SCP 模块后会话的 search 路径与 options 被如实恢复，以便后续分析不受隐性副作用影响。

#### Acceptance Criteria

1. WHEN 入口调用结束（成功或异常路径），THE Module_Loader SHALL 只 detach 本次调用新增的包，并按依赖逆序重试直到新增包全部移除或一轮重试无进展。
2. IF 重试无进展后仍有本次新增的包残留，THEN THE Module_Loader SHALL 在诊断中列出残留包名并把 `search_restored` 记为 false。
3. THE Module_Loader SHALL 保留调用前用户已 attach 的全部包。
4. WHEN 公开 MDS 与 NMF 入口调用结束，THE Module_Loader SHALL 使 `search()` 与调用前一致，且不残留 `package:generics`。
5. THE Module_Loader SHALL 使调用前已存在的 options 取值在调用后保持不变。
6. THE Module_Loader SHALL 在诊断中分别列出 namespace 首次初始化新增的默认选项与算法临时新增或改动的选项（如 `RcppML.verbose`、`RcppML.threads`）。
7. THE Module_Loader SHALL 保留 namespace 初始化必需的默认选项，使 3D 入口返回的 plotly 对象在调用后可被外部 `plotly_build` 与 HTML 保存。
8. THE Module_Loader SHALL 在调用结束时恢复算法临时新增或改动的选项。
9. IF 恢复未完成，THEN THE Module_Loader SHALL 在诊断中写出未恢复项，而不是写 "none"。

### Requirement 6: 最小依赖声明与可复制运行

**User Story:** 作为课题 agent，我希望每个实现只声明自身分支真正需要的依赖并能复制到课题目录独立运行，以便不被无关包阻塞。

#### Acceptance Criteria

1. THE Kiro_Implementer SHALL 为每个实现和模板写 Runtime_Manifest，字段符合 `references/minimal-runtime.md`。
2. THE Kiro_Implementer SHALL 把实现分为分析核心、对象适配、可选绘图三层，并为每层分别声明能力、依赖与验证范围。
3. THE Runtime_Manifest SHALL 只在 `required_packages` 列出该分支实际调用路径需要的包，并把仅特定功能需要的包列入 `optional_packages` 且写明触发条件。
4. THE Runtime_Manifest SHALL 为 GraphPlot 声明 ggplot2、grid、reshape2、rlang 为必要包，并且不声明 Seurat。
5. THE Runtime_Manifest SHALL 把每个 resource 同时列入 `files` 并给出与当前字节一致的 sha256。
6. THE Runtime_Manifest SHALL 让 `entry` 与 `entry_function` 和页面 `implementations[].entrypoint` 的路径与函数一致。
7. THE Kiro_Implementer SHALL 从模块中移除 PrepareEnv、check_Python、check_R、conda_install 等安装器调用，代之以只报告缺包的守卫。
8. WHEN 一个 Module 被复制到异目录并在新进程中不提供 Fixed_Source 路径调用，THE Module SHALL 只依赖 Runtime_Manifest 列出的文件与资源。
9. IF 某分支无法拆成独立闭包，THEN THE Runtime_Manifest SHALL 把该分支标为 `bundle` 或 `unknown`，并写明阻塞原因。

### Requirement 7: 验证收据与证据真实性

**User Story:** 作为作者，我希望 verified 只代表实际运行并经比较断言通过的分支，以便方法推荐不建立在执行成功的假象上。

#### Acceptance Criteria

1. THE Case_Runner SHALL 只在存在实际算法输出与 Native_Oracle 或明确结果断言的比较产物且比较通过时，把 Algorithm_Receipt 的 `state` 写为 passed。
2. IF 一个分支只完成执行（exit 0、加载成功、`input_unchanged`/`search_restored` 为 true 或仅有 `output_digest`）而没有结果比较，THEN THE Case_Runner SHALL 把该分支记为 not_run，并记录 `executed=true` 与"缺少结果比较"的原因。
3. THE Case_Runner SHALL 把 `checks` 中的自由文本描述与已执行的比较分开记录，且不以自由文本授予 passed。
4. THE Algorithm_Receipt SHALL 记录可重放的完整命令（含实际代码目录、case、输入与输出路径）、实际参数、输入与输出 sha256，以及执行期间采集的家族 `code/` 全部源文件 sha256。
5. IF 执行开始与结束时采集的代码哈希不一致，THEN THE Case_Runner SHALL 把该收据记为 invalid。
6. THE Kiro_Implementer SHALL 不为旧输出补绑新代码哈希，也不用硬编码配方生成 passed。
7. WHEN 页面实现指向收据，THE Kiro_Implementer SHALL 选择当前有效且 scope 与该实现一致的收据，而不是历史上第一个 passed 收据。
8. THE Kiro_Implementer SHALL 只把 NMF 实现的 verified 范围限定为 `nmf.method=NMF`，并把默认 RcppML 后端单独记为缺包 not_run。
9. THE Kiro_Implementer SHALL 把 Portability_Receipt 与 Algorithm_Receipt 分开写入与展示，且两者互不授予状态。
10. IF Legacy_Replay 回放的是 Python 实现（如 SHAP、回归评价），THEN THE Legacy_Replay SHALL 在 environment 字段写实际 Python 版本，而不是 R 4.5。

### Requirement 8: 原生对照（数值、像素、绘图数据）

**User Story:** 作为作者，我希望提炼版与 SCP 原生实现在相同输入下被实际比对，以便确认提炼没有改变算法或图形结构。

#### Acceptance Criteria

1. WHEN 分析实现可在 R_Runtime 中运行，THE Kiro_Implementer SHALL 以同一输入与参数分别调用原生函数与提炼版，比较数值结果、行顺序、缺失值处理和随机种子行为，并在收据中写明容差及其依据。
2. WHEN 可视化实现产出栅格或矢量图，THE Kiro_Implementer SHALL 以 Native_Oracle 的精确参数（尺寸、dpi、特征、种子）做逐像素或结构比较。
3. WHEN 可视化实现产出 plotly 对象，THE Kiro_Implementer SHALL 比较 trace 的 x、y、z、type、mode、name、text、marker 字段，并验证外部 `plotly_build` 与 HTML 保存成功。
4. THE Kiro_Implementer SHALL 在每次对照中验证输入对象调用前后未被修改。
5. THE Kiro_Implementer SHALL 复用已有 Native_Oracle（MDS/NMF/2D/stat/correlation、GroupHeatmap 5 结构、CellDimPlot 4 圈选、Slingshot 3 lineage、真实 50 细胞 SNN 图、3D cell/feature、LargeVis、FR），不重新生成同一控制。
6. IF 原生函数本身在给定输入上失败（如 CellDimPlot lineages 叠加 grobs list-matrix 错误），THEN THE Kiro_Implementer SHALL 记录原生失败的精确错误，并且不以重画图掩盖该失败。
7. THE Kiro_Implementer SHALL 在提炼版 3D 入口上完成实际浏览器渲染与图例隐藏/恢复交互检查，并把截图仅作为辅助证据。
8. THE Kiro_Implementer SHALL 在收据与页面中注明对照所用数据为软件夹具或真实示例子集，并且不把对照通过写成科学结论。

### Requirement 9: 证据复用与重验边界

**User Story:** 作为作者，我希望已通过的证据不被重复返工，同时冻结后变动的代码必须重新验证，以便效率与证据有效性兼顾。

#### Acceptance Criteria

1. WHERE 上一轮证据绑定的代码、清单与输入哈希与当前文件一致，THE Kiro_Implementer SHALL 复用该证据并在交付中注明复用来源。
2. THE Kiro_Implementer SHALL 在完成 Requirement 4 与 Requirement 5 的加载层修复后宣布 Code_Freeze，并在 Code_Freeze 后只执行一次模块重建与 Wiki 整合。
3. WHEN Code_Freeze 之后任一代码、helper、资源或 Runtime_Manifest 发生变化，THE Kiro_Implementer SHALL 把受影响收据视为 stale 并重新执行验证。
4. WHEN Code_Freeze 完成，THE Kiro_Implementer SHALL 重新运行 Legacy_Replay，使旧基线语义比较对冻结后代码有效。
5. WHERE 某分支代码未改且旧收据仍现行（如 SHAP、回归评价），THE Kiro_Implementer SHALL 保留原收据而不重新改动该分支。
6. THE Kiro_Implementer SHALL 保留全部旧收据和旧失败记录，不改写为重新执行。
7. WHEN Code_Freeze 后，THE Kiro_Implementer SHALL 对全部 79 个 Module 执行加载审计，确认加载不改变任何 Fixed_Source 状态并记录结果。

### Requirement 10: 可视化结构全部入库、代签核与模板化

**User Story:** 作为作者，我希望 SCP 的每个结构实质不同的可视化结构都由 Kiro 代我签核并转成正式可调用模板，以便课题中可以直接调用，同时只有回放与原生对照实际通过的模板才进入 ready。

#### Acceptance Criteria

1. THE Kiro_Implementer SHALL 为 22 个主要可视化入口及其具名形态逐一列出 Visual_Structure，并与正式库 17 个 SCP 示例模板比较视觉编码与附属结构，结构相同时复用已有模板，结构实质不同时才列为新增并写明差异。
2. WHEN 一个 Visual_Structure 被列为新增，THE Kiro_Implementer SHALL 以该结构原生函数的真实输出（PNG/SVG/HTML）和对应原生调用，按真实画廊 schema 建立 `panel_map` 恰好一项的单 panel Gallery_Draft，并通过官方 `wiki.py ingest-figure` 收录。
3. WHEN 一个 Gallery_Draft 已收录且其原生对照证据存在，THE Kiro_Implementer SHALL 依据 Delegated_Approval 把该条目签核为 approved，并且只通过 Wiki_CLI 或网页修改状态，不手改 frontmatter `status`。
4. WHEN 执行一次 Delegated_Approval，THE Kiro_Implementer SHALL 写入一条审计记录（授权原话、授权日期 2026-10-26、签核者=Kiro_Implementer、签核时间、原生对照证据路径与 sha256）到 Maintenance_Record 和该条目的备注或日志，并保持 `<!-- user:start/end -->` 作者区块字节不变。
5. IF 某 Visual_Structure 的原生函数在给定输入上失败，THEN THE Kiro_Implementer SHALL 记录原生失败的精确错误，并且不把该结构签核为 approved。
6. WHEN 一个 Gallery_Draft 经 Delegated_Approval 签核为 approved，THE Kiro_Implementer SHALL 对其执行官方 `wiki.py scaffold-template` 生成 Scaffold_Template，模板绘图层直接读取准备好的结果表并只声明最小依赖。
7. WHEN 一个 Scaffold_Template 的回放与原生对照（栅格逐像素、矢量结构或 plotly trace 字段）实际通过，THE Kiro_Implementer SHALL 对其执行官方 `wiki.py mark-ready`。
8. IF 某 Scaffold_Template 回放失败、缺依赖或缺原生材料，THEN THE Kiro_Implementer SHALL 保留该模板为非 ready 状态并写明精确原因，且不放宽 validator，不以通用重画图冒充回放。
9. THE Kiro_Implementer SHALL 保持 fig17 GroupHeatmap 点阵模板的 ready 状态、作者签核记录与回放证据不变。
10. THE Kiro_Implementer SHALL 把来源图片只保存在画廊原始层，Wiki 页面只存路径、哈希与证据指针，并把无回放的预览标为"来源参考图／尚无回放"。
11. THE Kiro_Implementer SHALL 在每个 Gallery_Draft 与 Scaffold_Template 中注明来源图为软件夹具原生输出，而不是已发表或科学结论，并注明代签核仅表示图形结构与原生一致、可作模板，不代表科学认可。
12. IF 某可视化入口缺依赖或缺原生材料而无法产出真实输出，THEN THE Kiro_Implementer SHALL 在对应技术页给出真实实现、参数说明与精确 not_run 原因，并且不以通用重画图替代。
13. WHERE 可视化为交互/3D，THE Kiro_Implementer SHALL 记录原生 HTML 及依赖文件与交互支持边界，并以实际浏览器检查作为交互验收依据，截图仅作辅助证据。

### Requirement 11: 文档与可复制示例正确性

**User Story:** 作为课题 agent，我希望页面中的签名、参数和示例与真实源码一致，以便照抄示例时不会出错。

#### Acceptance Criteria

1. THE Kiro_Implementer SHALL 让每个页面代码示例能被 R 解析器（`parse`）成功解析。
2. THE Kiro_Implementer SHALL 让每个示例调用中的参数名存在于对应入口的真实签名中，或在源码中被 `...` 实际转交给可接受该参数的函数。
3. THE Kiro_Implementer SHALL 在 RunWOT 示例中给出源码要求的 `group_by` 参数（真实时间字段），而不是 `time.by`。
4. THE Kiro_Implementer SHALL 依据源码核实 FindExpressedMarkers 的 `group_by` 经 `...` 转交的语义后再写入示例。
5. THE Kiro_Implementer SHALL 把 RunMonocle2 依赖的包名写为 `monocle`。
6. THE Kiro_Implementer SHALL 只对实际执行过的示例标注"已实际调用"，未执行的示例标注为声明示例。
7. THE Kiro_Implementer SHALL 在涉及 Seurat Assay5 的页面写明已验证范围为旧 Assay 结构，并把 Assay5 标为待适配，且不隐式合并 layer。
8. THE Kiro_Implementer SHALL 删除页面正文中循环引用"见 data_contract"之类的占位，代之以具体输入、必要参数、输出与限制。
9. THE Kiro_Implementer SHALL 把 `methods/scp-local-source.md` 正文中"6个分析族和可视化都引用这个本地包"更正为：整库为历史归档、审计与原版对照用途，课题优先使用各规范家族声明的 standalone 闭包，实际验证以分支收据为准；历史兼容说明保留并标为历史。
10. THE Kiro_Implementer SHALL 只修改与 SCP 相关的页面，且不向 SHAP 与回归评价页面加入 SCP 内容。
11. THE Kiro_Implementer SHALL 只把真实存在于 NAMESPACE 的导出名写入 CALLS 或调用说明，不机械添加大小写别名。

### Requirement 12: 既有能力不退步

**User Story:** 作为作者，我希望本轮合入后正式库已有的可用方法和模板全部保持可用，以便整库入库不以牺牲现有能力为代价。

#### Acceptance Criteria

1. WHEN 合入完成，THE Formal_Wiki SHALL 至少保有 Baseline 中 12 个 ready 分析家族与 13 个 verified 实现，并保持其 ready_for_use 结果不变。
2. WHEN 合入完成，THE Formal_Wiki SHALL 保有 17 个既有 SCP 示例模板及其当前状态与回放证据，且任一既有模板状态不低于合入前。
3. WHEN 合入完成，THE Formal_Wiki SHALL 使 SCP 模板总数等于 17 加本轮新增 Scaffold_Template 数，并与可视化结构清单中模板化计数一致。
4. THE Kiro_Implementer SHALL 不放宽 Wiki_CLI 的 validator、lint 或 check-entry 规则以使条目通过。
5. IF 合入前后的 Baseline 比对出现任一家族、实现或模板状态下降，THEN THE Kiro_Implementer SHALL 回退该增量并定位原因。
6. THE Kiro_Implementer SHALL 在合入前后各导出一次 Baseline 状态快照并写入 Maintenance_Record。

### Requirement 13: 受控合入正式库与保护

**User Story:** 作为作者，我希望隔离区成果以受控增量合入正式库并全程保护原始资产，以便合入过程可审计、可回退。

#### Acceptance Criteria

1. WHEN 合入正式库之前，THE Kiro_Implementer SHALL 备份 Formal_Wiki 的受影响路径，并在 Maintenance_Record 记录备份位置。
2. THE Kiro_Implementer SHALL 只把已验证的增量从 Isolation_Workspace 合入 Formal_Wiki，并且不用 Isolation_Workspace 中早于正式 fig17 发布的状态、`index.md` 或 `log.md` 整体覆盖正式库。
3. THE Kiro_Implementer SHALL 在合入前后对 Protected_Assets 做哈希比对，并要求 Fixed_Source、画廊原始资产与正式开发代码零变化。
4. THE Kiro_Implementer SHALL 使所有页面的作者区块在合入前后字节级一致（含换行符）。
5. THE Kiro_Implementer SHALL 只通过 Wiki_CLI 或网页修改 frontmatter `status`，并保留全部既有页面 ID 与实现 ID。
6. WHEN 合入完成，THE Kiro_Implementer SHALL 对受影响页面执行 `check-entry --record`，并执行 `lint`、`pending --json` 与 `save`。
7. IF `lint` 报 ERROR，THEN THE Kiro_Implementer SHALL 修复页面后重新执行 `lint`，直到无 ERROR。
8. THE Kiro_Implementer SHALL 不安装、下载或升级任何 R/Python 依赖。
9. THE Kiro_Implementer SHALL 把临时文件写入 `E:/research-wiki-env/tmp`，不写 C 盘 memory，且不读取、调用或引用 `E:/paper-harness`。
10. WHERE 本轮改动涉及 research-wiki 规则或产品代码，THE Kiro_Implementer SHALL 在备份后同步五处全局安装（.agents、.codex、.claude、.cc-switch、.config/opencode）。
11. WHERE 本轮改动仅为内容，THE Kiro_Implementer SHALL 不执行五处全局安装同步。

### Requirement 14: 前端与 API 展示核验

**User Story:** 作为作者，我希望合入结果在网页与 API 上的呈现与底层事实一致，以便我在网页上看到的状态可信。

#### Acceptance Criteria

1. WHEN 合入完成，THE Kiro_Implementer SHALL 先用精确进程命令行核对 Wiki_Server 的运行状态，复用已运行实例或按原配置重启，而不另起重复服务。
2. THE Kiro_Implementer SHALL 通过 Wiki_Server API 读取每个受影响方法页，核对 `implementation_status`、独立性状态与收据状态和 Wiki_CLI 输出一致。
3. THE Kiro_Implementer SHALL 在浏览器中核对方法目录只把满足推荐门槛的 analysis 家族显示为可执行推荐，workflow 与 technical 页不进入分析推荐。
4. THE Kiro_Implementer SHALL 在浏览器中核对代码查看器按入口文件显示逐分支状态，共享文件显示 `mixed`，无收据分支不被提升。
5. THE Kiro_Implementer SHALL 在浏览器中核对每个新 Gallery_Draft 显示 approved 与代签核标识，每个新 Scaffold_Template 显示与 Wiki_CLI 一致的状态（ready 或非 ready 及原因），且无回放的来源图标为"来源参考图"。
6. THE Kiro_Implementer SHALL 核对 `methods/scp-local-source.md` 在网页中显示为技术资料，且不冒充分析可用。
7. THE Kiro_Implementer SHALL 把前端核验的页面路径、检查项与截图位置写入 Maintenance_Record。
8. THE Wiki_Server SHALL 保持只接受本机地址访问。

### Requirement 15: 未验证分支的准确标注

**User Story:** 作为作者，我希望每个没跑通的分支都写明具体原因，以便我知道缺什么、哪些不能用。

#### Acceptance Criteria

1. IF 某分支因缺包（如 scDblFinder、SingleR、monocle、RcppML）无法运行，THEN THE Kiro_Implementer SHALL 把其 Algorithm_Receipt 记为 not_run，并写出精确缺包名与原始错误消息。
2. IF 某分支因缺上游结果或原生材料无法运行，THEN THE Kiro_Implementer SHALL 写明缺少的具体对象或文件。
3. THE Kiro_Implementer SHALL 使每个分支只依据自身收据获得状态，不继承同家族兄弟分支的 verified。
4. THE Kiro_Implementer SHALL 为参数分支表中的每一项写明去向、范围与状态，不以同函数其他分支的结果代替。
5. THE Kiro_Implementer SHALL 在页面与 Coverage_Map 中分别区分"历史 not_run""当前缺包""未探测"三种事实。
6. THE Kiro_Implementer SHALL 在最终交付中分别列出入库完整、当前可运行、原生图形验证通过、真实课题科学有效（本轮不评估）、代签核清单（含审计记录指针）与未达 ready 的模板清单及各自原因。
7. THE Kiro_Implementer SHALL 在交付报告中列出全部未闭合项，且不在存在未闭合项时宣称全库入库完成。

### Requirement 16: 执行环境约束

**User Story:** 作为维护者，我希望所有验证在固定的现有环境中执行，以便结果可重放且不污染系统环境。

#### Acceptance Criteria

1. THE Kiro_Implementer SHALL 以 `C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8` 运行 Wiki_CLI，以 `D:/anaconda/python.exe -X utf8` 运行通用脚本，且不使用 PATH 上的 Windows 商店 Python 占位程序。
2. THE Kiro_Implementer SHALL 以 R_Runtime 执行全部 R 验证，并在收据 environment 字段记录 R 版本、`R_LIBS_USER` 与平台。
3. THE Kiro_Implementer SHALL 在运行 Wiki_CLI 前把 `TEMP`、`TMP`、`MPLCONFIGDIR` 设到 `E:/research-wiki-env/tmp` 下。
4. THE Kiro_Implementer SHALL 以脚本捕获的真实错误判定成败，而不是以 R 进程退出码 0 代替。
5. THE Kiro_Implementer SHALL 在验证结束后清理本轮在 `E:/research-wiki-env/tmp` 下创建的临时文件，并保留写入 Maintenance_Record 的证据文件。

### Requirement 17: 模板定义（作者 2026-10-27 采访，修订需求 10）

**User Story:** 作为作者，我希望绘图模板直接接收 Seurat 对象与上游分析结果、一个入口覆盖全部形态并逐形态验证，以便新课题中 agent 能先组织方法、再自主选择图样出图。

记录：`template-definition-interview.md`（同目录）与 `维护记录/2026-10-25-SCP全库入库/kiro-template-definition-20261027.md`。本需求与需求 10 冲突处以本需求为准；需求 10 的画廊 → 代签核 → scaffold 流程只适用于已完成的 CSV 表驱动模板与 3D draft。

#### Acceptance Criteria

1. THE Kiro_Implementer SHALL 把 22 个可视化入口各作为一个绘图模板（方法页 `methods/scp-viz-*` 下的可视化实现），输入为 Seurat 对象及上游分析结果，直接调用独立模块中的原生绘图函数，不要求改写为读表驱动，不依赖 SCP 包本身。
2. THE Kiro_Implementer SHALL 为每个入口的每个具名形态（branches.json 中该入口的每个参数取值）建立一个用例：该参数取该值、其余参数取默认值，并以同输入同参数的原生 SCP 输出逐像素比较（PNG）；交互图比较 plotly trace 字段。
3. IF 某形态的原生调用本身失败，THEN THE Kiro_Implementer SHALL 记为 native_failure 并保存原始错误，不计入已验证。
4. IF 某形态需要的上游结果在当前环境无法生成（缺包或缺材料），THEN THE Kiro_Implementer SHALL 记为 missing_package 或 missing_material，写明缺少的包或对象。
5. THE Kiro_Implementer SHALL 在每个绘图模板页写明上游方法（方法家族与实现 id）和所需对象槽位，验证用的上游对象由原生上游方法生成并以 RDS 保存，收据记录其 sha256。
6. THE Kiro_Implementer SHALL 在每个可视化技术页提供形态表：参数、取值、状态（verified/native_failure/missing_*/not_probed）、收据指针与形态图样（取自验证回放输出，不是来源原图）。
7. THE Kiro_Implementer SHALL 保留已有 17 个与本轮 11 个 CSV 表驱动模板并与对应 Seurat 版页面互相链接，写明各自适用场景（非 Seurat 数据用表驱动版）。
8. THE Kiro_Implementer SHALL 在技术页使用说明中写明应用场景：自然语言出图、已知函数取代码、非 Seurat 数据、agent 先组织方法再按链路自主选图样；出图后的使用记录由 agent 提议、作者确认后才写入。
9. THE Kiro_Implementer SHALL 不修改 research-wiki 产品代码，不执行五处全局同步。
