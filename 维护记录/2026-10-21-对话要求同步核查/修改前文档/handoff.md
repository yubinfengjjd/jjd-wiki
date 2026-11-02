# research-wiki · 交接

开发目录：`E:\桌面\ARIS\research-wiki-dev-20261020`（沿用 T 任务书 → codex exec → review 流程）。开发与测试只写 `test-wiki/` 和 `test-gallery/`，不写真实总库与画廊，直到 T7。

## 实施前核实（需用户）

| ID | 事项 | 阻塞 |
|---|---|---|
| V1 | 目视签核 post01 六面板（目前 status=review）；签核方式可以等 T6 的网页，也可以先在对话里口头确认 | T7 |
| V2 | 提供 1–2 篇简单图帖子（推荐森林图、热图或分组柱，能用上 V3 的数据），用 sci-figure-replica 复刻 | T7 |
| V3 | 确认验收数据：ANCHOR-OCT 的 ST07（AUROC 矩阵）/ ST06 或 ST04（估计值 + CI），以及用正式课题目录还是开发快照 | T7 |
| V4 | 同意联网创建 research-wiki venv（PyYAML、FastAPI、uvicorn）和 npm 安装前端依赖 | T1（已完成） |
| V5 | 同意新建生信 Python 环境 `research-wiki-bio` 并联网安装 xgboost、shap、scikit-learn（锁定版本） | M2 |

## Codex 任务书通用约束

写进每份任务书，审查时逐条核对：

- 不写防御性代码：不为不可能的输入写兜底；不用宽泛的 `try/except`；错误在 CLI 边界统一报告并以非零退出码结束。
- 不加未使用的配置项、参数、抽象基类、插件机制、兼容层。
- 每个模块只负责一件事；函数优先，没有必要不写类。
- 测试用 pytest 和临时目录，覆盖验收场景，不 mock 文件系统。
- 交付：代码、测试日志（先红后绿）、`T*-delivery.md`。

## 任务

| # | 负责 | 目的 | 产物 | 验证 / 完成条件 |
|---|---|---|---|---|
| T1 | Codex | wiki 核心 | `rwiki` 包：config、页面读写（frontmatter + 保护区块）、双链解析、git commit、`ingest-figure`、`lint`、`AGENTS.md` 规则模板 | 用 test-gallery 中 post01 副本收录：生成模板页、场景页、图型页、index/log、一次提交；lint 能检出人为制造的断链与状态不一致；保护区块在重新收录后不变 |
| T2 | Codex | 模板化与运行 | `scaffold-template`、`verify-template`、`render`、`mark`、`pending`、spec.json 校验 | 以 post01 为例完成一个模板（代码改写部分在任务书中由 Codex 作为 agent 完成）；回放输出三格式与并排图；`--style` 覆盖一个颜色后输出变化 |
| T3 | Codex | 推荐与套用 | `suggest`、`contact-sheet`、`record-use` | 只返回 ready 且非归档的模板；拼图有编号与名称；record-use 建课题页并在模板页出现反链 |
| T4 | Codex | 本地服务 | FastAPI 应用、`serve` 命令 | 接口测试覆盖签核/退回/标签/收藏/备注/归档/恢复，每次写入产生 git 提交；越界路径返回 404；只绑定 127.0.0.1 |
| T5 | Claude | 前端 | Vite + React + TS 应用，构建产物供 T4 托管 | 类型检查与构建通过；对 test-wiki 截图检查画廊、详情、3D 网络、待办/归档、日志，深浅主题各一遍 |
| P1 | Codex | 面板拆分改造 | 版式页类型与 layout.json；ingest 改建版式页；panel 模板（`panel.py` 的 `draw` 约定）；`scaffold-template` 新参数、`verify-layout`、`render-layout`、`mark-ready` 扩展、suggest 含版式；签核/退回接口移到版式（spec/api.md 同步修改）；lint 覆盖新关系 | 最小假版式（两个假 panel 模板）测试：拆分、单 panel 回放、拼回整图、版式在模板未全部 ready 时不能 ready；签核接口作用于版式 |
| P2 | Codex（作为 agent）+ Claude 审查 | post01 重做 | 在新的测试库中把 post01 拆为 3 个 panel 模板 + 1 个版式，代码复用 T2 已有的绘图函数 | 三个模板各自用示例数据单独出图；版式拼回整图与原复刻图差异接近 0，Claude 目视；单用蜂群图模板配 T2 的变形数据出图成功 |
| M1 | Codex | 方法库核心 | 接口页与方法页类型、method.json/params.yaml 校验、`add-interface`、`scaffold-method`、`verify-method`、`run-method`、`suggest-pipeline`、`record-use --method`；模板 spec 增加 `interface` 并由 lint 校验；facts 中“可接的图”；graph API 边 `kind`；方法的 confirm/return 等写接口；config 增加 `bio_python_exe`、`bio_r_libs` | 用最小假方法与假接口（Python 写 CSV）测试：draft→pending_confirm→ready；输出表头不符、输出为空、参数键未知各报错；两个方法输出同一接口时 suggest-pipeline 对同一模板列出两者及适用正文；graph 中 feeds 边方向正确 |
| M2 | Codex（作为 agent）+ Claude 审查 | 首个真实方法 | 在 test-wiki-t2 上：为 post01 模板补两个 SHAP 接口；从 post01 原帖代码抽出 XGBoost + SHAP 方法（scikit-learn 公开小数据集做示例），输出两个接口表；verify-method 跑通 | 示例输出能直接被 SHAP 模板 render 成图（Claude 目视）；网络中出现方法→接口→模板箭头；方法页“适用/不适用/参数”有依据，不编造 |
| M3 | Claude | 前端增量 | 方法页与接口页视图、画廊“方法库”分栏、方法确认/退回按钮、网络中方法（方形）与接口（菱形）节点和 feeds 箭头、模板页“可接的分析方法” | 构建通过；对 M2 的 test-wiki-t2 截图检查；确认按钮端到端产生 git 提交 |
| T6 | Claude | 技能与集成 | `research-wiki` 技能（两侧）；sci-figure-replica、medfig-render、medpaper-pipeline 增补步骤；改前备份 | 安装清单与备份存在；一次全新会话中按技能说明完成收录与推荐（test-wiki） |
| T7 | Claude + 用户 | 真实验收 | 初始化 `E:\桌面\科研知识库`；收录 post01 与 V2 新图；网页签核；处理待办；用 V3 数据推荐与套用 | requirements A1–A9 逐条记录到 `review/T7-acceptance.md`；A3/A4 需作者目视确认 |

每个 Codex 任务完成后，Claude 审查（正确性、屎山、防御性代码、测试真实性），写 `review/T*-review.md`，必要时返工后再进下一步。T5 可在 T4 的接口定稿后与 T3 并行。

顺序：P1 → P2 → M1 → M2，前端改动（版式与方法的页面、网络节点）合并在 M3 一次做；T6 的技能一次覆盖模板、版式、方法三套流程；T7 验收覆盖 A1–A16。面板拆分先做，是因为方法要接的是 panel 模板的接口。

## 已知限制

- 推荐准确度依赖标签与适用说明的质量，首版没有量化指标。
- 单写者：网页与 agent 同时写同一页面不保证安全。
- 第二版（文献 wiki）只预留目录与页面类型，未设计导入流程；开始前需另行访谈 Zotero 读取方式与页面粒度。

## 需求 → 设计 → 验收

| 需求 | 设计落点 | 验收 |
|---|---|---|
| R1 Obsidian + git | 总库结构、双链、commit() | A1, A6 |
| R2 画廊只读 | 状态与权威来源表 | A2, A8 |
| R3 自动收录 | ingest-figure + sci-figure-replica 增补 | A1 |
| R4 签核/退回 | signoff/reject 接口 | A2 |
| R5 模板化 | scaffold/verify-template、spec.json | A3 |
| R6 表格输入 | spec.json tables | A3, A4 |
| R7 推荐 | suggest + contact-sheet | A4 |
| R8 保留风格 | style 覆盖 | A3 |
| R9 使用记录 | record-use、课题页 | A4 |
| R10 网页编辑 | 写接口 + 前端操作 | A2, A5 |
| R11 保护区块 + git | 页面读写、commit() | A1, A5, A8 |
| R12 3D 网络 | /api/graph + 3d-force-graph | A7 |
| R13 规模检索 | suggest 过滤与关键词 | A4 |
| R14 两侧技能 | research-wiki 技能 | A9, T6 |
| R15 主题 | 前端主题 | A7 |
