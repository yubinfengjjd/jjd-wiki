# research-wiki · 设计

依据：`requirements.md` R1–R15；决定见 `session.md`。

## 设计原则

LLM Wiki 三层（D018）：

1. **原始层**（只读）：画廊 `E:\桌面\科研绘图画廊` 的条目；第二版加 Zotero、笔记、PDF。
2. **wiki 层**：`E:\桌面\科研知识库` 中 agent 编译的 Markdown 页面。
3. **规则层**：总库根目录 `AGENTS.md`（`CLAUDE.md` 只写一行 `@AGENTS.md`），规定页面类型、frontmatter、操作流程。

agent 的工作是 ingest（收录）、query（查询/推荐）、lint（体检）。确定性的事情（建页骨架、解析链接、改状态、git 提交、跑模板、拼图）写成脚本；需要判断的事情（写适用说明、挑候选、改代码抽模板、导出用户数据）留给 agent。不建数据库：页面就是数据，链接图在请求时现算（几百页规模足够）。

## 总库结构

```text
科研知识库/
  AGENTS.md  CLAUDE.md  index.md  log.md
  templates/<id>.md                 # 模板页（id 同画廊条目 id）
  templates/<id>/                   # 模板资产（模板化后才有）
    spec.json                       # 数据说明书
    code/render.py | render.R       # 入口与它用到的辅助模块，模板自包含
    example/                        # 原复刻数据转成的示例表
    preview.png
    verify/                         # 回放产物，.gitignore 忽略
  scenarios/<key>.md                # 场景枢纽页（键来自 scenario_taxonomy）
  chart-types/<slug>.md             # 图型枢纽页
  projects/<slug>.md                # 课题页
  literature/  methods/             # 第二版
```

## 模板页

```markdown
---
type: template
id: 2026-08-17-shap-feature-mechanism__fig01-shap-a-f
status: pending_signoff        # pending_signoff | pending_template | ready | archived
gallery_entry: 2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f
language: python
scenarios: {primary: [model-explanation-shap], free: [LightGBM]}
chart_types: [shap-bar, beeswarm, radial-bar]
favorite: false
---
# SHAP 条形图 + 蜂群图 + 环形贡献图（六面板）

![[...thumb.png]]
场景：[[scenarios/model-explanation-shap]] · 图型：[[chart-types/beeswarm]] …

## 适用与不适用            ← agent 编写
## 数据要求                ← 模板化后由 spec.json 生成
## 使用记录                ← 课题页链接，agent 维护

<!-- user:start -->
用户备注（agent 不改；网页“备注”只写这里）
<!-- user:end -->
```

`status` 归档时保留原值到 `archived_from`，恢复时还原。

### 状态与权威来源

| 事实 | 权威 | 说明 |
|---|---|---|
| 签核状态 | 画廊 meta.json `status` | 网页签核/退回同时写画廊与模板页 |
| 场景标签 | 模板页 frontmatter | 收录时从画廊复制；之后的编辑只改 wiki，画廊保持原始记录 |
| 收藏、备注、归档、模板化状态、使用记录 | 模板页 | 画廊不知道这些 |

`lint` 检查签核状态是否一致（画廊 approved 而页面仍为 pending_signoff，或者反过来）。

## 模板约定（D006、D007、D010）

`spec.json`：

```json
{
  "entry": "code/render.py",
  "language": "python",
  "tables": {
    "shap_values": {"file": "shap_values.csv", "columns": {"feature": "str", "shap": "float", "value": "float"}, "description": "每行一个样本×特征"}
  },
  "style": {"palette": ["#..."], "font_family": "Arial", "width_mm": 180, "height_mm": 120, "label_lang": "en"}
}
```

入口约定（Python 与 R 相同）：`render --data <dir> --out <dir> [--style <json>]`。输出 `figure.png/pdf/svg`。`--style` 只覆盖 `style` 里已有的键；默认值就是原图风格。

模板化回放：用 `example/` 运行入口，与画廊里已签核的 `output/replica.png` 等尺寸并排并计算像素差异，结果交作者目视。不设自动通过阈值。

## CLI（Codex 实现）

一个 Python 包 `rwiki`，入口 `wiki.py <cmd>`，配置只有 `config.json`。最终键集合为 `wiki_root`、`gallery_root`、`taxonomy`（场景词表路径）、`python_exe`、`rscript_exe`、`port`；每个开发阶段只加入本阶段用到的键（T1：前三个；T2：python_exe、rscript_exe；T4：port）。

| 命令 | 作用 |
|---|---|
| `ingest-figure <entry_id>` | 从画廊 meta.json 建/更新模板页骨架、补场景与图型枢纽页、更新 index/log、提交 |
| `pending` | 列出 pending_template 条目 |
| `scaffold-template <id>` | 建 `templates/<id>/` 目录、把复刻数据拷进 example/；代码改写由 agent 完成 |
| `verify-template <id>` | 用 example/ 跑入口，输出到 verify/（不进 git），生成并排图与差异数，写 preview.png |
| `mark-ready <id>` | 作者确认回放结果后由 agent 调用：pending_template → ready，按 spec.json 重写“数据要求”节 |
| `suggest --scenario … --chart-type … --columns … --q …` | 只返回 ready 模板，按匹配度排序输出 JSON |
| `contact-sheet <id>… --out <png>` | 候选并排拼图，标编号与名称 |
| `render <id> --data <dir> --out <dir> [--style json]` | 运行模板 |
| `record-use <id> --project <slug> --output <path>` | 建/更新课题页、链接模板、写 log、提交 |
| `lint` | 断链、frontmatter、状态一致性、模板资产缺失 |
| `serve` | 启动本地服务并打开浏览器 |

git：总库为仓库，`save(message)` 一个函数，所有写操作结束后调用一次：重建 index 后若工作区无变化，直接返回（不写日志、不提交）；有变化才追加 log 并提交。

## 本地服务（Codex 实现）

FastAPI + uvicorn，监听 `127.0.0.1:<port>`，无登录（单人本机）。服务端只负责：

- `GET /api/pages`（所有页面 frontmatter + 路径）、`GET /api/page/{path}`（原文 + 反链）、`GET /api/graph`（节点与边）、`GET /api/log`
- `POST /api/template/{id}/signoff`、`/reject {reason}`、`/scenarios {primary, free}`、`/favorite`、`/note {text}`、`/archive`、`/restore`
- `GET /files/wiki/{path}`、`/files/gallery/{path}`：只能读两个根目录内的文件，越界返回 404
- 托管前端构建产物

每个写接口：改文件 → 追加 log → git 提交。没有队列与后台任务（“待办”就是页面状态）。

## 前端（Claude 实现）

Vite + React 18 + TypeScript；three.js 0.170 自研图谱引擎（d3-force-3d 3.0.5 布局，平面/立体切换）与首页知识晶格；Canvas2D 流场背景；motion 11.18.2 做按钮弹簧动效；`markdown-it` 加双链插件渲染页面。依赖版本均锁定。

页面：画廊（首页 3D 知识晶格 + 可翻面的卡纸图版；筛选：场景、图型、语言、状态、收藏；搜索）· 模板详情（原图/复刻/回放并排、数据要求、适用说明、使用记录、备注、操作按钮；卡片到详情用 View Transition 变形）· 枢纽页与课题页 · 知识网络（Obsidian 式平面图谱，可切 3D，悬停高亮邻居，拖拽节点，单击侧边面板，双击打开）· 待办/归档 · 日志。浅色期刊插图风格（D038–D043）。

## 面板拆分与组合版式（D060–D062）

### 页面

```text
layouts/<entry_id>.md          # 组合版式页（type: layout），一个画廊条目一页，id 同画廊条目
layouts/<entry_id>/
  thumb.png
  layout.json                  # 画布尺寸、各面板：字母、模板 id、区域 rect、数据映射、样式覆盖
  example/                     # 原复刻数据（各面板所需的表）
  verify/                      # 拼回整图的回放产物（不进 git）
  preview.png
templates/<template_id>.md     # panel 模板页，id = <entry_id>--<图型 slug>
templates/<template_id>/       # 与原模板目录相同，另加 code/panel.py
```

- 版式页承载整图的签核状态，沿用原模板状态机：pending_signoff → pending_template → ready / archived。`ingest-figure` 改为建/更新版式页（不再建模板页），网页签核/退回作用于版式。
- panel 模板页 frontmatter 增加 `layouts`（引用它的版式 id，第一个是来源版式）与 `panels`（在来源版式中覆盖哪些面板，如 [A, D]）；版式页用 `template_panels` 记录每个模板在本版式覆盖的字母（复用到别的版式时字母可能不同，P1 实现时补充）。状态为 draft（拆出待回放）→ ready（回放通过、作者确认）→ archived。一个模板可以被多个版式引用（以后不同帖子出现同一图型时，agent 优先复用已有模板，只在差异明显时新建）。
- 版式就绪条件：引用的全部 panel 模板 ready，且按版式拼回的整图与画廊 replica.png 回放对比经作者确认。

### panel 模板代码约定

- `code/panel.py` 提供 `draw(fig, rect, tables, style)`：在画布 `fig` 的区域 `rect`（[x, y, w, h]，画布比例坐标）内作画，可自建坐标轴、inset 和色标；`tables` 为表名到 DataFrame 的映射。
- `code/render.py` 是独立出图入口（约定同前），内部建画布后调用 `draw`。
- 版式渲染：rwiki 带一个通用拼合脚本，由 `python_exe` 运行；按 layout.json 建画布，逐面板导入对应模板的 `panel.py` 调用 `draw`，写面板字母，导出三格式。这样拼合结果与原复刻图可以逐像素对比。
- `draw` 不改全局 matplotlib rcParams：同一画布上可能有来自不同图的模板，字体、线宽等从 style 读取后显式设置在自己创建的对象上。拼合脚本统一设置 `pdf.fonttype=42`、`svg.fonttype=none`（矢量输出中文字可编辑）。
- 样式分两层：layout.json 中各面板的 style 写版式本身的选择（如 A、D 用哪套配色）；只属于原图那份数据的取值（坐标范围、刻度、特征顺序）放 `example/style.json`，只在回放时使用，换数据套用时自动计算。
- labels 每项为 `{text, x, y, size, weight}`，(x, y) 是字母的左下角。
- 首版只支持 Python panel 的拼合；R panel 可以单独出图，R 版式拼合在出现 R 多面板图时另做。

### 命令变化

| 命令 | 变化 |
|---|---|
| `ingest-figure` | 建/更新版式页与缩略图；面板信息取自画廊 meta.json 的 `figure.panel_map`（字母 → 图型、bbox；sci-figure-replica 在 T6 增加此字段，post01 先在测试副本中手工补上） |
| `pending` | 列出待模板化的版式 |
| `scaffold-template <layout_id> --chart-type <slug> --panels A,D` | 为版式拆出一个 panel 模板骨架 |
| `verify-template <template_id>` | 用 example 单独回放该 panel（无原图可比，产出预览供作者看） |
| `verify-layout <layout_id>` | 按 layout.json 拼回整图，与 replica.png 并排、计算差异 |
| `mark-ready` | 对模板与版式都可用；版式要求全部模板已 ready |
| `render-layout <layout_id> --data … --out … [--style …]` | 按原版式用新数据一次出整图 |
| `suggest` | 候选包括 panel 模板与版式；版式的数据要求是各面板接口的并集 |

## 分析方法库（第 1.5 版，D045–D059；R1 后按 D063–D067 改为方法笔记）

知识库写给 agent 读：方法页说明一步分析怎么做，有的附可复用代码模板；agent 在作者课题的环境里改参数、运行、整理结果。知识库不管理分析环境、不代跑分析。

### 页面类型

```text
科研知识库/
  methods/<id>.md                 # 方法笔记（type: method）
  methods/<id>/
    source/                       # 可选：原代码归档（只读）
    code/                         # 可选：可复用代码模板，参数集中在脚本开头
  interfaces/<slug>.md            # 数据接口页（type: interface）
```

方法页 frontmatter：`type`、`id`、`title`、`status`（draft → ready，另有 archived/archived_from）、`tags`（自由标签）、`inputs`、`outputs`（接口 slug 列表）、`source`（`kind: post|project|repo|written`；post 记 `gallery_entry`，repo 记 `url`、`commit`；written 必须写 `cite`）、`license`、`cite`、`favorite`。

正文节：`## 用途`、`## 适用`、`## 不适用`、`## 输入`、`## 怎么做`（步骤、要改的地方、结果是否可信怎么判断）、`## 代码`（模板说明或片段）、`## 输出`（怎样整理成接口表）、`## 使用记录`，加上 user 区块。facts 区块由 save 重建：来源、许可证、引用、标签、输入/输出接口、可接的图、可接的下一步方法、`code/` 文件链接。

一个方法不绑定工具：SHAP 解释写成适用于任意模型的方法（树模型 TreeExplainer、线性模型 LinearExplainer、其他模型 `shap.Explainer`），换模型只改脚本开头的参数。

接口页 frontmatter：`type`、`slug`、`title`、`columns`。接口是唯一的列定义来源。图模板 spec 的表只写 `interface` 与 `description`，文件名固定为 `<接口 slug>.csv`，所以分析输出目录可以直接交给模板出图。

### 连接规则

- 方法 → 接口：方法页 `outputs`；接口 → 图模板：模板 spec 的表接口；接口 → 方法：方法页 `inputs`。
- 方法“可接的图”：某模板所需的全部接口都在该方法的 outputs 中（单一方法不能满足时不列，串联由 agent 推荐时组合）。由 `save` 前的目录重建写进方法页 facts 区块，因此出现在双链与网络中。
- 出处：source.kind 为 post 的方法，在方法页正文写明来自哪个帖子与版式，但不建专属连线；方法与模板只经接口相连（D059）。
- 网络 API 给边加 `kind`：`feeds`（方法→接口、接口→模板、接口→方法，带方向）与 `link`（其余双链，无向）。前端对 `feeds` 画箭头。

### 场景 → 自由标签（R1）

版式、模板、方法的 `scenarios{primary,free}` 改为 `tags`（自由字符串列表）。`ingest-figure` 把画廊的场景键经受控词表翻成中文标签，再加自由标签；词表只用于这一步翻译，不再有场景枢纽页、受控校验或按场景筛选。推荐由 agent 读页面“适用/不适用”按语义判断；`suggest` 的关键词只搜标题、tags 与“适用”节。

### CLI

| 命令 | 作用 |
|---|---|
| `scaffold-method <id> --title … --license … (--from-entry <条目> \| --from-path <路径> \| --written) [--url --commit]` | 建 draft 方法页骨架；有来源时把原代码复制到 `source/` |
| `add-interface <slug> --title … --columns <json>` | 新建接口页 |
| `mark-ready <id>` / 网页 `confirm` | 方法 draft → ready；`return` 为 ready → draft（附理由） |
| `suggest-pipeline [--figure <模板 id>] [--q …]` | 给出“方法 + 可接模板”组合，附各方法的适用/不适用与代码文件清单 |
| `record-use <模板 id> … --method <方法 id>` | 课题页记录用了哪个方法 |

已删除：`verify-method`、`run-method`、method.json、params.yaml、report.json、`bio_python_exe`/`bio_r_libs`、`requirements-bio.lock.txt`、bio 测试标记。

### 环境

- 图模板运行仍用 config 的 `python_exe` 与 `rscript_exe`。
- 分析方法在作者课题自己的环境里运行，知识库不装包；缺包时 agent 列出来问作者。
- 开发与测试的临时文件、pytest basetemp、pip 缓存放 `E:\research-wiki-env\tmp` 与 `E:\research-wiki-env\pip-cache`（作者要求不写 C 盘）。
- `E:\research-wiki-env\bio-python` 保留作本机实验环境，不再由知识库管理。

## 技能与集成

- 新技能 `research-wiki`（Claude 与 Codex 两侧各一份，内容相同）：说明三类操作、推荐与套用流程、何时调用哪个 CLI；指示 agent 先读总库 `AGENTS.md`。R1 后技能写明：知识库是说明书，分析在课题环境里由 agent 写代码运行。
- sci-figure-replica：第 9 步 `build_index.py` 之后加一步 `rwiki ingest-figure`。
- medfig-render、medpaper-pipeline：出图步骤前加“先 `rwiki suggest`，有候选按推荐流程走，无则照常”。
- sci-figure-replica：帖子含分析代码时，收录图后提示作者“是否抽成方法”，同意则 `scaffold-method --from-entry <画廊条目>`（draft，进待办）。复刻时在 `meta.json` 记 `figure.panel_map`（字母 → 图型），知识库按它拆单图模板。
- research-wiki 技能与 AGENTS.md 增加方法与接口的规则：一步一个方法；优先复用已有接口，新接口须说明与已有接口的区别；方法最后一步改名为接口列名；推荐按 D053/D057。
- 改动已装技能前备份，两侧同步。

## 运行环境

- 新 venv `C:\Users\86186\.codex\venvs\research-wiki`（Python 3.12），装 PyYAML、FastAPI、uvicorn，版本锁定；不改其他 venv。
- 模板运行仍用 sci-figure-replica 的 Python 与 R 4.5.0（由 config 指定）。
- Node 24.19 / npm 11.17 构建前端。

## 风险

| 风险 | 缓解 |
|---|---|
| agent 重写页面覆盖用户内容 | 保护区块 + 每次写入 git 提交；lint 检查保护区块完整 |
| 网页写画廊 meta.json 与复刻技能同时写 | 沿用单写者假设；服务写前重读文件 |
| Codex 沙箱中 Rscript 不退出（上次项目的已知问题） | R 模板验证放在普通 shell 进行 |
| 推荐准确度依赖标签质量 | 网页可改标签；适用说明由 agent 撰写；lint 报告缺标签的页面 |
| 本地服务无登录 | 只绑定 127.0.0.1；文件服务限制在两个根目录 |
