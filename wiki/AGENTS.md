# 科研知识库 · agent 维护规则（v5，2026-11-19）

这是作者的个人科研 LLM Wiki：互链的 Markdown 页面，加上可直接调用的绘图模板、分析方法与思路分支树（Playbook）。agent 收录、编译和维护页面；作者阅读、确认、写备注。
任何 agent（Claude Code、Codex、Kiro、opencode）都用同一套命令 `rwiki <命令>`，即 research-wiki 技能的 `wiki.py <命令>`，参数相同；命令输出里的 `wiki.py …` 可直接换成 `rwiki …`，参数以 `--help` 为准。
本文件只写底线与页面分工，实现细节在技能目录的 `references/`（见文末）。改页面前读完本文件。

## 四支柱与目录结构

- **底层去重积木网（DAG）+ 表层可组合分支树 + 统一多风格模板**：所有新建可复用绘图代码一律统一归类为 `templates/<short-slug>/` **绘图模板**（不再新建或区分 L1/L2）；`recipes/` 为只读历史归档目录（存留 146 个历史归档模板以防断链，不再新增条目）。
- 原始层（只读）：上游来源快照（`config.sources_root`，不在 Wiki 内）、画廊（`config.gallery_root`，sci-figure-replica 的复刻产物）、历史归档模板与方法的 `source/` 原字节。
- Wiki 层：本目录，agent 编译的页面。
- 规则层：本文件，加技能的 `SKILL.md` 与 `references/`。

| 位置 | type | 内容 |
|---|---|---|
| `sources/<id>.md`、`sources/<id>/items.jsonl` | source | 来源登记（URL、commit、许可证、适配器、trusted）与来源目录项 |
| `templates/<id>.md`、`templates/<id>/` | template | **统一绘图模板**：`spec.json`、`code/`、`example/`、`runtime.json`、回放 `verify/`；含 `style_tier`（`default` \| `variant`）与 `journal_style` |
| `recipes/<id>.md`、`recipes/<id>/` | recipe | 只读历史归档模板（保留 `source/`、`runs/`、`preview.png`，不再新增或分档） |
| `methods/<id>.md`、`methods/<id>/` | method | 分析方法家族：笔记、可选 `source/`、`code/`、`runtime.json`、`verification/`、`figure_relations` 与 `next_steps` |
| `scenarios/<id>.md` | scenario | 思路分支树（Playbook）：`picks` 与 `steps` DAG（含 `when`、`method_id`、`templates` 与多上游汇合 `requires`） |
| `interfaces/<slug>.md` | interface | 数据接口：列、必需/可选与“含义” |
| `chart-types/<slug>.md` | chart-type | 图型概念页 |
| `layouts/<id>.md`、`layouts/<id>/` | layout | 画廊复刻图样的来源记录 |
| `projects/<slug>.md` | project | 课题研究走线实录卡：记录每阶段假设、方法、可切换模板与关键发现 |
| `index.md`、`catalog.jsonl`、`log.md` | — | 前两个由 `save` 重建，`log.md` 只追加；都不手改 |

## 状态与验证口径

- 所有 `template`、`method`（以及只读历史 `recipe`）的状态统一为 `draft` / `ready` / `archived`，`ready` 表示作者已确认。`layout` 只来自画廊（`ingest-figure`），其 `pending_signoff` / `pending_template` 是历史状态，只读保留；开源库与新模板不再新建 `layout`。
- **能否执行看收据，不看 status**：绘图模板须经 `verify-template` 生成 `verify/` 回放收据；分析方法每个实现分支须经 `rwiki verify-method <method_id> --impl <impl_id>` 生成独立的 `verification/<impl_id>.json`（`schema_version: 1`，`state: "passed"`，无机器绝对盘符路径，绑定该实现在 `runtime.json` 声明的闭包文件 SHA256 与输出哈希）；没有当前版本的成功运行收据，就不能声称为已验证可运行。
- **分析方法多实现槽位 3 条硬门禁（v5.7+）**：同一规范 `analysis` 方法家族可并存多套不同数据模态/语言的可执行实现分支（`implementations[]`，支持可选元数据 `impl_tier: default | variant`、`modality`、`source_paper`）；当 `runtime.json` 声明了 `files` 闭包时，各实现的 SHA256 收据仅校验其自身声明闭包（新增第 2 套实现文件不破坏第 1 套既有收据）。对任意活跃 `method_kind: analysis` 方法页，若至少 1 个实现声明了 `impl_tier` 或 `modality`，`rwiki lint` 强制执行：① 仅有 1 个实现时**禁止孤立标为 `impl_tier: variant`**（必须为 `default`）；② 含 `>= 2` 个实现时必须**有且仅有 1 个 `impl_tier: default`**、其余全部为 `variant`；③ 全员必须声明非空 `modality` 与 `language`。
- **一类图允许多套顶刊风格模板并存**：同一分析方法或图型下可并存多个可切换画风模板；新建模板应标注 `style_tier`（`default` \| `variant`）与 `journal_style`（历史旧模板可渐进补齐）。`rwiki lint` 对包含至少 1 个声明了 `style_tier` 或 `journal_style` 的 `(primary_method, chart_types[0])` 输出槽位执行 **3 条硬门禁**：① **禁止孤立 `variant`**（槽位只有 1 个活跃模板时不得标为 `variant`，必须为 `default`）；② **多模板槽位完整性**（槽位有 `>= 2` 个活跃模板时，必须有且仅有 1 个 `default`，且全员均须声明非空 `journal_style` 与合法 `style_tier`）；③ **同槽位主标签对齐**（多模板槽位若 `default` 声明了非空 `tags`，同槽位每个 `variant` 的 `tags` 必须包含 `default.tags[0]`，防止按标签筛选时变体隐身）。`check-dup` 支持期刊画风感知：同方法/同图型/同接口但 `journal_style` 不同且标题不完全相同的变体自动降级为 `medium` 建议提示而不硬拦截；检索排序与前端展示默认优先呈现 `ready` 且 `style_tier: default` 的模板，折叠其余变体防选择瘫痪（多画风槽位在图库卡片右上角显示 `N 种画风` 胶囊角标）。
- **分支树拓扑与覆盖清单自动化校验**：`rwiki lint` 对所有 `scenario.steps` 执行悬空 `next_steps`、失效 `subtree` 与有向环检测；`studio.py` 自动标注不属于本树上游产出的 `external_requires` 外部数据前提供前端「我手里有哪些数据？」就绪过滤；复刻流程可选附带 `panel-manifest.yaml` 由 `rwiki lint` 校验并由 `rwiki save` 自动汇总覆盖与证据分层事实。
- **单 panel 约束**：每个 `templates/<slug>/` 对应一个逻辑 panel（inset、色标、边际分布或配对对照小图随主 panel 一并封装），严禁把整篇论文多 Panel 拼图直接当单个通用模板。

## 收录与复利流程（「三查一记」）

画廊是来源之一，不是必经入口。按批次推进，作者按批次确认。

1. **来源登记**：`source add <id> --title … --url … --license <SPDX> --adapter <名> [--trusted]` 登记 → `source fetch <id>`（固定 commit 的稀疏快照）→ `source scan <id>`（生成目录项）。
2. **一查方法库与主干**：
   - 先按研究问题、输入、单位、估计目标、算法假设查已有 `methods/<id>.md`（26 个规范 `analysis` 家族），不按包名重复建方法；同一分析目的的新算法作为 `implementations` 分支挂入既有家族；多方法串联记为 `workflow`；源码/环境适配记为 `technical`；只有全新的分析目的才建新家族。
   - 原代码以原语言、原字节进 `source/`；`code/` 显式参数化；写 `runtime.json`；逐分支实际调用并写收据，缺包或失败写精确 `not_run`。
   - 常规单次检验（t 检验、Wilcoxon、卡方等）写进所属方法或图注，不单独成页。
3. **二查模板库与画风归属**：
   - 已有相同图元与风格直接复用；若引入新的顶刊风格或功能变体，通过 `scaffold-template <slug> --native --primary-method <method>` 新建在 `wiki/templates/<slug>/`，标明 `style_tier`（`default` 或 `variant`）与 `journal_style`，并在 `## 知识关联检查` 写明与同方法下已有模板的差异与切换关系。
   - **同论文同质化去重 + 输出槽位衍生风格归类铁律（v5.5+）**：同一篇论文内部视觉同质的多个 Panel（相同图元结构、配色体系与数据映射逻辑，仅基因/分组/样本子集不同）**必须归并提炼为 1 套该论文代表性画风模板**，既避免模板库同质化膨胀，也不丢失该顶刊独有视觉样式；每套衍生风格模板必须挂入其对应的输出槽位 `(primary_method, chart_types[0])`（若槽位已有 `Standard` 默认模板则标 `style_tier: variant`，仅空槽位标 `default`，同时显式填写 `journal_style`），并对齐同槽位 `default` 模板的规范受控英文 `tags`（`config.taxonomy` 规范键如 `single-cell`、`transcriptomics`，避免中英文别名分裂导致筛选与画风切换器割裂），在论文 `panel-manifest.yaml` 中将所有同质 Panel 统一指向该 `template_id`。
   - 参数化写好 `spec.json`、`runtime.json`、`code/render.R`（或 `.py`）与 `example/` 后，严格逐个串行执行 `verify-template <slug>`，人工目视核对成图无误后方可交付；同时通过 `rwiki map-method` 与方法页 `figure_relations` 建立双向语义关系。
4. **三查思路分支树（Playbook）与四记案例走线卡**：
   - 优先复用并挂载到已有领域分支树（`wiki/scenarios/*.md`）；仅当文献引入新组学或新多上游汇合路线时，长出新的专题子树并在节点声明 `requires: [...]`。
   - 每篇完整复刻文献单独沉淀 1 张研究走线卡 `wiki/projects/<paper_id>.md`，隔离特定疾病基因、小规模抽样边界与湿实验排除清单，做到“通用回流、特例隔离”。
5. **作者确认**：作者核对一批条目后执行 `mark-ready <id…>`；多个 id 时先全部核对，任一不通过则全部不改。

## 默认入库交付（作者 2026-11-02 修订）

每次入库默认同时整理 **代码复用层 + 方法理论层**，并同步前端展示；不能只归档源文件或只写理论页就宣称入库全部完成。原始层只读、语义去重、作者确认和装包审批继续有效。

- **方法理论层**：明确研究问题、输入对象与行单位、估计目标、假设、适用/不适用、算法与统计边界、输出含义；相同目的合并到既有分析家族，组合流程与源码适配保留 `workflow`/`technical` 分类及互链。
- **代码复用层**：有源码时同步保留原字节来源，提炼原语言、显式参数的可复制入口、最小依赖闭包、`runtime.json` 与逐分支收据；做原版对照、真实合法数据调用和异目录新进程验证。缺代码、缺数据、缺依赖或未跑的分支写精确缺口/`not_run`，不编造实现或通过证据。
- 成熟依赖（如 irGSEA、SCP、Seurat）原生图与项目自定义计算/绘图分开登记；优先复用既有闭包或薄调用适配，不因项目、文件名或 PDF 不同重复建模板。绘图代码在方法页显式登记 `code_roles: [visualization]`，其理论关联用 `theory_methods: [规范方法id]` 表达；这些只是发现入口，不是科学直连或可执行授权。
- **前端验收**：`save` 重建索引后，检查实际服务读取正式 Wiki；方法库可按标题、ID、函数/依赖和关键词找到理论、流程与代码资料，图库展示可切换风格模板及历史归档模板入口。打开详情核对入口、依赖、当前逐分支验证范围和代码查看/下载，缺包状态不得继承其他分支的通过结果。
- 修改前端/技能源码时，完成构建、部署副本哈希核对及实际浏览器检查；已打开页面可用“同步知识库”刷新数据。只完成提交、`save` 或 `lint` 不等于已同步前端。

## 检索与调用

- `find` → `show` → `use` → `render` 或分析调用。`find <关键词…>` 读 `catalog.jsonl`，场景首选与 `default` 主推模板排在前面，每条给出下一步命令；`show <id>` 看用途、适用/不适用、输入、许可与最近运行；`use <id> --project <课题>` 把代码复制到 `<课题>/wiki-use/<名>/`，附 `RWIKI-USE.md`（换数据说明），模板另附 `bindings.draft.json`。`use` 不写 Wiki。
- 换数据后运行：绘图模板 `render <id> --data … --out … --bindings …`；历史归档模板副本 `run --dir <副本>`（收据写在副本 `rwiki-runs/`）；方法在课题环境调用 `code/` 入口。
- 推荐前读候选页的“适用 / 不适用 / 输入”；列名相同不证明适用，列名不同也不排除。给作者 1–3 个候选与风格差异，等作者选；已有选择就复用。
- 课题数据、脚本、成图留在课题目录，不进 Wiki。只有任务授权包含正式 Wiki 写入时才 `record-use`（配图）或 `record-method-use`（只做分析），只记路径与判断。
- 课题证据与经验草稿用 `project …` 写在 `<课题>/wiki-use/_project/`，不进 `save` 链。

## 环境与依赖

- `wiki.py` 只用 research-wiki 专用 Python；临时文件与缓存写指定工作盘临时目录（不写本机系统盘硬编码路径进 Wiki）。
- 模板 `render` 与历史归档模板 `run` 使用 Wiki 专用 R 库（`config.r_libs`）。运行时不联网装包：`install_dependencies.R` 换成只检查不安装的桩。
- 装包只经 `deps --install`：先 `deps` 列出一批缺包清单，作者按批次批准后执行，只装进 `r_libs` 的第一个目录；不往课题环境或系统库装包。
- 缺包写 `not_run`，上游报错写 `fail`，都保留精确原因；不伪造通过，不用近似实现顶替。
- 课题自己的 Python/R 环境由作者管理：缺包时列出包名问作者。

## 收据

- 绘图模板：`verify/` 回放回执，绑定 code、spec、示例数据、接口与输出哈希（如遇 Windows R 4.5.0 `rlang` 退出清理触发 `0xC0000005` 且成图文件已完整落盘，须如实记录，严禁伪造 `exit_code: 0`）。
- 分析方法：`verification/*.json` 逐分支；独立迁移证据随 `runtime.json`。
- 历史归档模板：`recipes/<id>/runs/<run_id>.json`（`schema_version: 2`，`scope = as-is / new-data / other-dir`，`state = pass / fail / not_run`，本机路径脱敏）；`run --dir` 的收据留在课题副本。
- 代码或输入变了，旧收据就不再代表当前版本。收据只证明“在记录的环境里跑通”，不证明统计或科学有效。
- 检查项与检查者如实写；没有看图能力时，把目视检查写成待办并写明由谁核查。

## 底线（不能破）

1. 来源快照与原始层只读：保留原字节、哈希、许可证；`recipes/*/source/`、`methods/*/source/`、画廊不改。
2. `<!-- user:start -->` 与 `<!-- user:end -->` 之间是作者内容，agent 一字不改、不移动；`<!-- facts:start -->`…`<!-- facts:end -->` 只由脚本生成；frontmatter 的 `status`、`favorite`、`archived_from` 只经 `wiki.py` 或网页改。
3. 不编造数据、文献、收据或适用结论；没跑写“未跑”，不确定写“待作者确认”。
4. 改变统计逻辑、补缺失算法、改分组含义，或缺原始数据需要估读、合成时，先问作者。
5. 列映射显式写（内部字段 → 作者列）；不猜列、不补值、不换算单位、不聚合。
6. 知识库的所有知识默认保存 Git，包括方法理论、源码、复用代码、公开示例、画廊知识、模板资源与验证材料。私有数据、密码和私钥不进 Git、不推送；保留原许可证、署名、来源与用途限制，不因保存 Git 改变许可。
7. 网页服务只接受本机访问，不为外部访问放开。

## 页面写什么

- 判断优先：下一个 agent 读完会不会做出不同动作？会就写进页面；只是“知道有这回事”就链接到来源。不复制原始层大段内容。
- 绘图模板与分析方法都写清“适用 / 不适用 / 输入含义 / 知识关联检查”。模板须在 frontmatter 声明 `primary_method`、`style_tier`（`default` \| `variant`）与 `journal_style`，并在正文 `## 知识关联检查` 说明与同家族其他画风的区分及切换场景。
- 场景页：`picks: [{id, note}]` 与 `steps` DAG（含 `id`、`step`、`title`、`method_id`、`when`、`inputs`、`outputs`、`templates`、`next_steps` 及可选多上游汇合 `requires`）；正文写清什么时候用、决策分叉与注意。
- 接口页“含义”：一行代表什么、单位/编码、最容易出错的前提、与相近接口的区别；模板不重算的统计写“上游给定”。
- 图型页五节：回答什么问题、什么时候选它、什么时候不要用、与相近图型怎么区分、常见误用。
- 方法—图关系只在方法侧 `figure_relations` 维护（`direct` / `adaptable` / `candidate`），反向自动派生；接口结构匹配不等于可直接接。
- `tags` 只用受控词表（`config.taxonomy`）；`keywords` 严格限填分析方法、算法/软件/R或Python包名、数据集、通路/分子或图型术语，严禁混入公众号名、博主推广词、入库流程词或无意义纯数字日期（由 `lint` 拦截为 ERROR）；`purposes` 只用于 `analysis` 方法。
- 命名：`id` 冻结，是文件名和引用键；`title` 写中文内容名，约 8–20 字，不拼来源、版本、图型前缀或项目名。
- 链接用相对 Wiki 根的双链，如 `[[templates/<id>|显示名]]`、`[[methods/<id>|方法名]]`；frontmatter 列表存值，不存链接。

## Git

- 知识库写操作的最后一步是 `save "<说明>"`（多数命令自带）：重建 `facts`、`index.md`、`catalog.jsonl`，追加 `log.md`，只提交 Wiki 子树。本地 `main` 与批次分支可直接 `save`；`task/*` 分支需要写入锁（`gh start-task` 建）。
- 本地日常不需要 Issue / PR；推送由作者决定。要推送 GitHub 或开发代码大改时走 GitHub Flow：`gh start-task … --worktree`（从 `origin/main` 切）→ 提交 → `gh finish-task`（PR 到 `main`）→ 非编码 agent `gh review` → 只经 `gh merge` 合并。批次只是 Milestone（`gh start-batch` / `gh close-batch`）。细节与全部 `gh` 子命令见 `references/github-workflow.md`。
- 风险档按 base 上的 `.github/risk-tiers.json` 算，可先 `gh tier --range origin/main...HEAD` 自查：`risk:low` CI 通过即合；`risk:normal` 再要针对当前 head 的 pass 评审；`risk:high` 同 normal，`high_requires_owner` 为 true 时再要 `owner-approved`（当前为 false）。三档都要求 PR 已包含最新 `main`。
- `owner-approved` 只由作者在网页上添加，agent 禁止添加；单账号下 GitHub 分不出是谁加的，这是约定。
- `pre-push` 只拒绝 `legacy/*`，并扫描私有数据、课题数据、密码/令牌/私钥、超限文件与本机绝对路径。
- 作者 2026-11-02 修订：知识默认入 Git，取消按 GPL/CC 许可排除源码的旧规则；`save` 移除旧 `push-guard gpl` 托管块。仅敏感内容与非知识运行产物（环境、缓存、浏览器会话、重复备份）排除；大文件按内容核查后用 Git LFS 或精确 size 豁免保存，不能只留页面而漏掉代码。`restore` 仍可修复缺失或损坏的来源原字节。
- 不要在主检出检出 `legacy/master`：它跟踪过画廊与维护记录，切过去再切回会把这些文件从磁盘删除，远端没有副本。看旧历史用 `git log legacy/master` 或另建 worktree。

## 文献复刻源码目录与双份归档（2026-11-19）

文献纯生信复刻严禁在桌面、仓库根目录或 `tmp/` 散落脚本；必须同时保持**本机完整工程目录**与**Wiki 受控代码存档**两份清晰对齐，且在 Wiki Markdown 中用逻辑占位符 `<sources_root>`（不写本机绝对路径）：

```text
<sources_root>/papers/<paper_id>/         # 本机复刻工程全集（非 Git）
├── paper.json                            # 元数据、DOI/PMID、步骤↔附件↔图映射状态机
├── plan.md                               # 复刻计划：湿实验剔除、小规模降维、查重与全图目标
├── intake/                               # 只读入口资料：post.html/txt、paper.pdf、supp/*、manifest.json
├── extracted/                            # 解析产物：full_text.md、methods_computational.md、excluded_wet_lab.md、
│                                         #   supp_index.md、supp_full_text.md、step_supp_map.json、captions.json、pages/
├── upstream_repo/<repo_name>/            # 作者开源仓库稀疏浅克隆（含 LICENSE 与 commit）
├── src/                                  # ★ 本机复现源码固定位置（按编号分模块）
│   ├── README.md                         #   运行顺序与和 upstream_repo 差异说明
│   ├── runtime.json                      #   本机运行依赖清单
│   ├── 00_sample_data.R / .py            #   小规模抽样/子集构建脚本（固定 seed=42）
│   ├── 01_<step_slug>.R / .py …          #   分步计算脚本（严禁无编号散落调试脚本）
│   └── figures/                          #   单面板复刻（figXX_panelY.*）与整图拼图（compose_figXX.*）
├── data_small/                           # 抽样后的小规模输入子集（禁存 GB 级原始大库）
├── runs/                                 # 分步运行日志、中间 RDS/CSV 与实测收据
└── review/                               # 主协调者自审：side_by_side.png、参数核查表、QA 报告
```

- **Wiki 正式存档（入 Git，受 5 MB 门禁约束）**：`rwiki paper publish` 在 `wiki/methods/<workflow-id>.md`（`method_kind: workflow`）下固定保存两套可读源码：`methods/<workflow-id>/source/`（作者原版核心脚本快照 + `source-manifest.json` 记仓库 URL、commit、SPDX 许可与 sha256）与 `methods/<workflow-id>/code/`（同步自 `<paper_id>/src/` 的分步复刻源码 + `runtime.json`），`verification/` 存小规模验证收据。共用算法补分支到既有规范 `methods/<canonical-id>/`；可复用单面板图模板入 `templates/<short-slug>/`；整图拼图对比归入 `gallery/`。
- **附加材料与全图覆盖**：`fetch --supp` 统一纳管 Supplementary PDF/DOCX/XLSX/CSV，`parse` 生成 `step_supp_map.json` 捋顺「正文步骤 ↔ 附加材料 ↔ 开源脚本 ↔ 图面板」对照；`plan` 默认包含全部可复刻 Main Figures 与生信 Supplementary Figures，**明确排除三类非计算面板**：湿实验（`excluded_wet_lab`）、非计算研究设计/机制模式示意图（`excluded_schematic`，如 Fig 1A 队列流程示意）与纯显微/IHC/mIF 影像（`excluded_imaging`），禁止为示意图或纯影像硬画通用模板。
- **1:1 视觉忠实度硬门禁**：禁止脱离原图与作者源码“各自画一张能出图的版本”。每张复刻图必须满足五项硬边界方可验收：① **精确采样原图/作者源码十六进制配色**（禁止随意替换调色板）；② **1:1 匹配原图整图高宽比与各 Panel 面积占比**；③ **图元类型、坐标形式（如带框相关性矩阵、双轴连线、无轴箭头 UMAP）与图例位置严格对齐原图**；④ **逐张人工看图比对 `side_by_side.png`**，凡出现比例失调、散点呈孤立针孔点、配色偏差或标签裁剪，**必须原地打回重修，禁止带瑕疵进入下一张或入库**；⑤ **单进程串行执行**（一步一跑、跑完即释放内存，严禁并发多进程挤爆本机内存）。
- **两层资产规范、Schema v2 入库硬门禁、真实数据 `example/` 与方法–可视化–课题思路闭环**：
  1. **论文复刻两层资产规范 + Schema v2 `panel-manifest.yaml` 硬门禁**：每篇复刻论文必须在 `methods/<workflow-id>/` 下产出 `schema_version: 2` 原子级 `panel-manifest.yaml`（采用 `figXX/A`、`sfig03/B` 键，包含 `figure_slug`、`panel_letter`、`script_path`、`input_tables`、`description`、`template_disposition`、`template_id` 及按需 `disposition_note`）、`code/panels/` 逐计算 Panel 独立可运行 CLI 脚本与 `panel-receipts.json`；同时按**同论文同质化去重**原则，将同论文内视觉同质的多个 Panel 归并提炼为 **1 套**代表性 `wiki/templates/<slug>/` 跨论文模板（不再新建 `recipes/` 条目），挂入对应 `(primary_method, chart_types[0])` 输出槽位（已有 `Standard`/默认模板则标 `style_tier: variant`，仅空槽位标 `default`），显式声明 `journal_style`、对齐同槽位 `default.tags[0]` 受控词表标签。`rwiki lint` 对 `schema_version >= 2` 的**每一条非排除（`not excluded_*`）计算面板**强制执行以下硬门禁（不达标直接 ERROR）：
     - **`script_path` 实体存在**：`script_path` 必须为非空安全相对路径，且在 `methods/<workflow-id>/` 资产目录内真实存在（防止空壳路径）；
     - **必须声明 `template_disposition`**（三选一）：
       - `paper_variant`：关联论文衍生风格模板；`template_id` 必须非空且解析到已存在的模板页，且该模板页必须同时满足 `status: ready`、非空 `primary_method`、`style_tier in ("default", "variant")` 与非空 `journal_style`；
       - `reuse_identical`：直接复用既有模板；`template_id` 必须非空且解析到已存在的模板页，且必须声明非空字符串 `disposition_note`（说明为何视觉/画风高度一致无需新建变体）；
       - `paper_specific_only`：强论文特异/单用途不进通用模板库；`template_id` 必须为 `null`（`None`），且必须声明非空字符串 `disposition_note`（说明为何不进通用模板库）。
  2. **论文算法入库硬门禁（`method-manifest.yaml` + `rwiki verify-method`，v5.7+）**：凡工作流声明了 `schema_version >= 2` 的 `panel-manifest.yaml`，`rwiki lint` 强制要求同目录下同时存在 `method-manifest.yaml`（缺则直接 `ERROR`），顶层必填 `schema_version`（`>= 1`）、`paper_id`、`workflow_id` 与 `steps[]`，每条计算步骤必须声明唯一安全 `step_id`、非空 `title`、资产目录内真实存在的 `script_path` 与 `method_disposition`（三选一）：
     - `method_impl`：新提炼或补充进规范分析方法家族的可复用实现；必须声明存在的活跃 `method_kind: analysis` `method_id` 与该页已登记的 `implementation_id`，该实现须具备合法 `impl_tier`（`default`/`variant`）与非空 `modality`，且 `implementation_status()` 实测状态**必须为 `verified`**（须先实跑 `rwiki verify-method <method_id> --impl <impl_id>` 签发 SHA256 收据，严禁 `not_run`/`stale`/`invalid` 蒙混过关）；
     - `reuse_impl`：直接复用既有已验证实现；必须声明存在的 `method_id`、`implementation_id`（实测状态须为 `verified`）及非空 `disposition_note`；
     - `paper_specific_only`：仅论文特异数据清洗/队列映射步骤；`method_id` 与 `implementation_id` 必须为 `null`（`None`），且必须声明非空 `disposition_note`。
  3. **真实数据 `example/` 硬铁律**：从复刻论文提炼的 `wiki/templates/<slug>/`，其 `example/*.csv` 与 `code/render.*` 必须直接来自该论文对应 Panel 的真实数据与精调绘图代码（严禁用随机高斯团块或假 H&E 方块应付 `verify-template`）；
  4. **计算 Panel 覆盖与三类排除**：逐张盘点全篇 Main + Supp Figure 的全部计算面板并落盘逐 Panel 独立脚本与模板归属；`excluded_schematic`、`excluded_imaging` 与 `excluded_wet_lab` 面板在 `panel-manifest.yaml` 中不要求 `template_id`、`template_disposition` 与 `script_path`；
  5. **方法 ↔ 可视化语义关系显式入库**：必须按研究推进顺序，把每个分析方法与对应单图模板写入规范方法页的 `figure_relations`、`next_steps` 及 `method-map.json`（`rwiki map-method`），严禁停留在“暂无已记录关系”；
  6. **课题研究思路沉淀入知识库**：每篇文献复刻收口前，必须同步沉淀：① 通用可复用领域决策树 `wiki/scenarios/<domain>-playbook.md`（若已有同域 Playbook 则嫁接新分支并声明 `requires` 多上游汇合）；② 本课题步进思路卡 `wiki/projects/<paper_id>.md`（逐阶段记录「科学问题/假设 → 方法 → 可切换模板 → 观察发现 → 下一步分叉」）。

## 历史临时产物与过期脚本清理规定（2026-11-19）

- **禁止散落临时脚本**：临时探针脚本（如 `chk.R`、`a.py`、`audit_*.py`）、`Rplots.pdf`、浏览器测试 profile（`t06-ui-*`）与 `.pytest_cache` 严禁留在仓库根目录或持久目录；临时运行统一使用系统临时区，任务结束前清理。
- **长期测试与临时调试截图分离**：自动化测试（`tests/test_*.py`）随源码入 Git 长期维护；临时调试截图（如 `tests/e2e/shots/`）与排查过程图像仅作一次性现场核验，严禁长期提交进 Git。
- **一次性执行计划与迁移脚本及时归档**：已完成的一次性执行计划（如 `docs/superpowers/plans/*.md`）与一次性迁移脚本必须在交付收口后及时归档移入 `docs/archive/`，不与现行设计规范和活跃代码混放。
- **统一安全清理与收口门禁（`rwiki clean`）**：`rwiki clean` 默认只读预览（`--dry-run`），`--apply` 仅清理 `env/tmp/*`、`t06-ui-*`、已退役探索探针与失效符号链接/接点；`R-lib*`、`bio-python`、`pip-cache`、`sources/`、`projects/`、`papers/`、`worktrees/` 与 `work/rwiki/{runs,search,studio_*}` 列入硬白名单永不自动删除。每次功能开发或文献复刻收口门禁必须运行 `rwiki clean --apply` 并核查活跃目录是否存在过期计划或散落临时脚本。

## 体检

`lint` 只查结构：frontmatter、断链、状态、收据结构、必需节是否空白、`index.md` 与 `catalog.jsonl` 是否过期。lint 通过不代表语义正确，跨来源同义与科学适用性由 agent 审查；逐条修复后 `save`。处理待办用 `pending --json`，确认前用 `check-entry <id>` 查缺项。

## 细则（research-wiki 技能目录 references/）

| 文件 | 什么时候读 |
|---|---|
| `sources-and-recipes.md` | 来源登记、适配器、目录扫描、历史归档模板运行与收据、`use` 副本、装包审批、`restore`、许可托管块、catalog 字段、画廊来源、确认与待办 |
| `input-binding.md` | 写 `bindings`、长宽整理 |
| `adaptive-sizing.md` | 做绘图模板的组数与尺寸适配 |
| `minimal-runtime.md` | 写 `runtime.json`、独立性证据、R 模块封装与环境恢复 |
| `method-families.md` | 方法家族、实现、验证收据、函数契约 |
| `knowledge-linking.md` | `figure_relations`、一方法多图与一图多方法 |
| `code-assets.md` | 原生代码与网页“查看代码” |
| `project-reuse.md`、`project-state.md` | 在课题里选方法/图、适配、课题状态层 |
| `llm-wiki-mode.md` | 知识层与 `ingest`/`query`/`lint`、网页删除与预览、Obsidian |
| `github-workflow.md` | GitHub Flow、全部 `gh` 子命令、风险档与门禁、`config.json` 的 env 段、CI 跳过范围 |
