# 方法两级分类与灵活输入改造实施计划

> 2026-10-23 用户已确定“研究领域→分析用途”并授权：先写本计划，再调用Claude Code实施，Codex独立code review。用户不允许Codex子代理，缺包不安装。直接按此授权执行，不再次询问同一实施许可。

**Goal:** 方法页按领域/用途浏览；作者数据无需改成固定文件名/列名才能复用；前端、后端、CLI、知识正文与skill同一契约。

**Architecture:** Markdown仍是唯一知识本体。复用tags表达领域，新增轻量purposes表达分析用途，后端提供统一分类词表/计数给前端。数据语义契约与执行格式分开，以显式bindings将课题副本/内存表适配为内部标准表，再调用现有R/Python核心。保留旧render调用和已有单panel模板。

**Tech Stack:** 现有Python/FastAPI、React/TypeScript、R/Python绘图函数、互链Markdown、pytest/SSR。

**Spec:** 本对话已确认需求；前一轮验收见../方法家族与LLM-Wiki改造/final-acceptance.md。不是重做前一轮，不更改方法的统计逻辑或作者签核。

## 全局约束

- 不读取/调用E:/paper-harness；不启动Codex或其他编码子代理。Claude单进程编码，Codex独立审查。
- 不安装依赖；脚本使用D:/anaconda/python.exe -X utf8，wiki/pytest使用C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe。TEMP/TMP/MPLCONFIGDIR使用E:/research-wiki-env/tmp。
- 保留dirty tree、旧id/路径、source/original_code字节、作者user区块、status/favorite与原始数据。改造前保存新基线及hash，不覆盖上轮维护记录。
- data_contract的对象语义与inputs/outputs内部表契约并存。不得把任意矩阵自动当Seurat对象，也不把同名列等同于同一统计单位。
- 不隐式聚合、插补、筛选、重新训练、计算统计、单位换算或改分组。必要变化须说明并取得相应选择；本次允许字段映射和无统计变化的显式长宽表整理。
- 新接口不按来源/列名不同重复新建；分类只用于发现，不作为科学适用性或可执行推荐硬门槛。保留逐实现验证门槛。
- 不改五处安装配置所指库，不引入数据库、网页执行器、自动安装或新环境。

## 当前问题与范围

当前15个analysis页面已有tags，但前端只有平铺卡片；method_kind只是分析/流程/技术类型。spec.py/check_data固定读取<interface>.csv与全部列；前端把22个接口技术清单默认铺在方法页。发现阶段列匹配只是评分，已经允许语义适配，这部分不能倒退。

本轮分三块：T1分类、T2输入与执行契约、T3前端/规则/迁移/联调。每块可独立验证，顺序实施。

## 契约A：研究领域→分析用途

- 领域继续用frontmatter.tags中的现有受控大类，保留原标签与keywords含义，不新造重复domains字段。
- analysis新增purposes字符串列表，来自单一后端受控词表。用途为：预处理与质量控制、降维与聚类、整合与批次校正、注释与参考映射、差异与功能分析、轨迹与动态分析、模型评价、模型解释。允许多选；以后新增用途须更新词表、文档、测试和迁移。
- 领域和用途是两个维度，不做互斥父子文件夹。一页可有多个领域和用途，所有视图仍引用同一id；计数为去重页数，不能把重叠分类数之和当总方法数。
- `method_kind`独立保留；辅助资料不混进analysis计数和卡片。
- 缺分类历史analysis保持可读并提示补充，不凭缺用途新增方法/退回作者状态/伪造验证。新入库在check-entry/lint提示缺用途，非法值报错。分类元数据变化不得让算法验证收据失效；笔记验收指纹如变化则重录，不代签。
- 后端统一提供分类视图（建议GET /api/method-taxonomy），包括领域/用途词表、当前数量、领域内用途数量。前端不复制另一套词表、拼写或筛选逻辑。输出由现有页面派生，不持久化计数。
- 前端一级领域入口（全部+有内容的领域），二级当前领域下有内容的用途（全部+用途），支持搜索；切换领域重置无效用途，URL保留选择。空结果明确、返回全部方便，辅助资料仍可访问。
- 跨领域方法只有实际有依据才加领域标签；不为了填满分类把SCP实现宣称支持所有模态。当前gene-set-enrichment/scoring、DE可按正文说明整理转录组标签，科学适用性与已验证实现范围仍分开。

初始用途映射：QC/doublet→预处理与质量控制；dimensionality-reduction/cell-clustering→降维与聚类；batch-integration→整合与批次校正；cell-type-annotation/reference-mapping→注释与参考映射；differential-expression/gene-set-enrichment/gene-set-scoring→差异与功能分析；trajectory-inference/rna-velocity/dynamic-feature-analysis→轨迹与动态分析；regression-resampling-evaluation→模型评价；shap-explanation→模型解释。

## 契约B：语义要求稳定、执行格式可适配

### 1. 三层输入说明

- 方法家族：需要哪些信息、统计单位、配对关系、单位/编码和前提（data_contract/正文），不强制CSV。
- 具体实现：真实接受的对象、参数、依赖和输出；已有Seurat/模型纯函数入口继续有效。
- 绘图调用：消费已分析结果，外层映射/整理为内部表；内部接口是代码约定，不是要求作者改原表。

### 2. 显式bindings

建议CLI保持旧命令兼容，并增加：
```powershell
wiki.py render <template-id> --data <project-data-dir> --bindings <project>/bindings.json --out <project-output>
```

bindings格式固定由spec.tables的表键定位；以下dotplot键来自现有真实spec：
```json
{
  "tables": {
    "dotplot": {
      "file": "my_results.csv",
      "columns": {
        "group": "cell_type",
        "feature": "gene_symbol",
        "avg_expression": "mean_expr",
        "pct_expressed": "positive_percent",
        "target_group": "target_cell_type"
      }
    }
  }
}
```

- columns方向为内部语义字段→作者字段；file相对--data根目录，不允许越界、隐式网络地址或自动探测其他课题路径。
- 不给bindings时保持原<interface>.csv与列名入口。给bindings时不要求作者文件改名；内层render脚本读取暂存的内部表。
- 先检查所有必需表/列/映射/重复列名与数值格式，再运行。缺必需语义报出具体缺口，不能按字符串相似度猜列或自动补值。
- 保留额外原始列，不改源文件；返回/持久化映射报告含源路径/哈希、映射、整理操作和检查结果。只有映射调用才有报告也可；路径放课题输出，不向Wiki写课题数据。
- 字段名吻合不能宣称单位和配对关系验证过。0–1/0–100、不明单位或粒度不一致必须明确提示；本轮不实现自动单位换算。已声明单位可比较，不明语义交agent核对，不编造validator已知事实。
- 显式长宽表整理允许仅melt/pivot且无聚合，需明确id、变量列、值列；pivot重复键必须拒绝，不自动求均值。不是所有原始对象都可自动转表。
- 将纯表映射核心做成可复制到课题的轻量模块；Python内存DataFrame/记录表与R data.frame可在显式调用层映射，不依赖Wiki绝对路径、全局数据或网络。尽量共用小而明确的契约，R/Python实现以同一夹具测试等价。

### 3. 必需/可选

- 接口列可声明required:false，未写默认true；spec中的表也可声明required:false，未写默认true，旧模板行为不变。
- 可选只指真实实现允许缺失的字段/表。不能把所有列都改为可选绕过检查，也不能在核心仍索引该列时仅修改声明。
- 缺可选项只在已声明可视化默认或核心分支明确允许时处理，报告默认；禁止补造p值、样本、均值、分数。选择两个有真实可选机制的Python/R模板演示；若需改绘图适配核心则保留原图回放与数值逻辑。
- 固定CSV文件名仅存在于内部兼容层；前端默认不要求作者按其命名。完整内部契约仍可查看/下载，不删除接口页和溯源。

## T0 — 基线与执行交接

**Files:** 维护记录/2026-10-23-分类与灵活输入/*、本计划、claude-handoff.md。

- [x] 保存开发/知识库当前head与dirty列表、当前修改文件副本、源文件/作者区块/状态hash；旧轮成果不reset、不覆盖。
- [x] Claude先读计划、当前正式AGENTS与前轮final-acceptance，确认无同任务进程后启动本轮单一Claude会话；本轮审查修复恢复该会话，不重启整项工作，不创建子代理。

## T1 — 两级分类的后端、前端与内容

**Files:** 新rwiki/method_taxonomy.py（或同等单一小模块）；rwiki/{lint,server,catalog,methods,acceptance}.py；frontend/src/{api,methods}.ts、views/MethodsView.tsx、styles.css；methods/*.md；tests/test_method_taxonomy.py、前端methods测试。

**Interfaces:** taxonomy读取meta.tags/purposes，后端统一派生分类计数；API与前端同构，不改变推荐科学门槛。

- [x] RED：多标签页只计一个总页；选领域+用途取交集；technical/workflow不混入；非法用途报错；无结果与切换重置；同一id始终一页。
- [x] GREEN：实现词表、校验、API、前端两级导航/筛选/URL与计数。迁移15家族用途，核对标签依据，记录前后字段对照。
- [x] 真实API与SSR一起检查，不能仅手写分类夹具；记录章节metadata变动但实现收据不被误判失效。

## T2 — 输入映射、可选约束与R/Python兼容

**Files:** 新rwiki/input_binding.py（或等价）；rwiki/{interfaces,spec,templates,cli,layouts,verification}.py中实际受影响入口；可复制输入helper与对应文档；相关tests/test_input_binding.py及既有render/layout测试；两个真实模板适配/示例。

**Interfaces:** input_binding接受spec/明确bindings和输入根，产出受检的内部表及映射报告；旧render/verify/composition行为不变，新增参数必须逐调用链检查。

- [x] RED：改文件名/列名后不能直接旧渲染；明确mapping后结果与标准输入相同；缺必需字段失败；可选缺省成功且有依据；额外列保留；原字节/输入对象不变；无绑定兼容旧行为。
- [x] RED：列名相似但语义未确认不自动认领；非法路径/重复源header/错误数值/未知表/未知映射字段失败；0–1/0–100的冲突不自动换算；显式reshape不聚合、重复pivot键报错。
- [x] GREEN：纯适配模块、CLI入口与所有受影响调用者同步。保证不同工作目录、复制到课题后可运行，临时规范表在课题/指定临时目录，结束清理自己新建临时内容。
- [x] Python/R同夹具换列名与改文件名，比较适配表；两份真实模板原输入vs绑定输入输出像素/数值等价，不改变科学量、分组或图形核心。
- [x] 映射/输入改变须反映在执行证据和使用记录；不把以前标准输入的verify收据扩大为任意外部文件已验证。

## T3 — 前端输入说明、规则与skill同步

**Files:** views/{MethodsView,MethodOverview,PageView}.tsx及输入说明组件；正式AGENTS/staged/assets/AGENTS；SKILL；references/{method-families,project-reuse,code-assets,llm-wiki-mode}.md及新增input-binding.md；接口/模板/方法正文。

- [x] 前端默认显示语义输入、对象、必要信息/可选信息与适配步骤；完整内部schema/列名折叠。方法页不铺22张技术接口卡片，保留折叠入口或独立详情可达。
- [x] 数据接口、方法、图模板三处相同required/optional/含义；API含映射能力与约束，前端不声称尚未实现的格式能力。
- [x] 八步入库增加领域/用途分类、先查家族防重复、先读语义再绑定、可选项依据、变换报告与验证。新入库不按来源、文件名或列名差异新建方法/接口。
- [x] 修订现有“持久化必须<接口>.csv/只允许固定列”等过时绝对表述，标明内部约定、外部映射与课题副本适配边界；不能一面写灵活接口一面默认拦截。
- [x] 检查五处部署副本和源码references的可达性，新增词表/文档/代码一并部署；原始来源和作者区块不动。

## T4 — 集成验收与交付给Codex审查

- [x] 先跑定向RED/GREEN，再跑全套pytest；npm test/typecheck/build；正式库lint，ERROR修复、WARN逐条列理由。
- [x] 真实端到端：领域→用途→方法详情；多领域同页无重复id；用途/验证标签、原始输入/内部约定显示一致；真实改名CSV经CLI成功出图；未映射必需数据合理拒绝；R/Python结果保持。
- [x] source哈希/原数据hash/user/status一致；旧标准render、单panel图库、关系、推荐与逐实现验证不回退。
- [x] 写claude-result.md、verification-matrix.md（后端/前端/CLI/规则/五处skill对照）、未完成项、精确命令/退出码。没有现证据不能写完成。
- [x] Claude到可审查状态即停止：先不部署、不重启正式服务、不提交开发仓库。Codex独立审查diff、科学边界与真实API/浏览器，再重跑必要检查；修复仍交Claude。
- [x] 审查通过后由Codex调用tools/deploy.py备份同步五处，每文件hash核对，重启精确正式服务并验API；写最终验收。源码dirty tree保持可审查，不替用户批量提交历史改动。

## 计划自查与完成判据

需求追溯：领域→用途=T1；灵活输入=T2；前后端同步=T1/T2/T3/T4；以后入库规则=T3；skill及安装同步=T3/T4；Claude执行/Codex审查=T0/T4。

只有字段和文档没有真实调用不算完成；只有前端筛选没有后端词表/校验不算完成；仅CLI适配而独立函数仍宣称任意格式可用不算完成；仅源码改动未核对五处部署不算交付。已明确的未实现对象格式不冒充支持。

验收状态（2026-10-23）：T0–T4 已完成、两轮审查通过并部署五处。真实可选表、组合bindings、R可选哈希依赖和作者确认范围见 final-acceptance.md，未扩大科学验证。

