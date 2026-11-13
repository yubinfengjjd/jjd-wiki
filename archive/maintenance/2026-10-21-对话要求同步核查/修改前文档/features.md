# 功能索引

每个能力一段：做什么、入口、关键文件、测试、已知限制、相关审查。给未来的 agent 定位用，替代已丢失的任务书。

通用背景见 `design.md`（架构与规则）、`session.md`（决策表 D001–D067）、`知识库\AGENTS.md`（agent 工作手册）。命令都通过 `wiki.py <命令>`（技能目录下，配置见 `config.json`）。

## 1. 收录（ingest）

- **做什么**：从画廊条目建/更新整图版式页、图型枢纽页、标签与 facts，然后 git 提交。标签由画廊场景键经词表翻译 + 自由标签。
- **入口**：`wiki.py ingest-figure <条目 id | --all>`
- **关键文件**：`rwiki/ingest.py`、`rwiki/facts.py`、`rwiki/pages.py`
- **测试**：`test_ingest.py`、`test_pages.py`
- **已知限制**：画廊条目必须有 `figure.panel_map`（sci-figure-replica 记录），否则报错；画廊只读，唯一回写是签核状态。
- **审查**：`review/T1-review.md`、`P1-review.md`、`R1-review.md`

## 2. 拆模板与回放（template / layout）

- **做什么**：从已签核版式拆出单图模板（`panel.py` 的 `draw(fig, rect, tables, style)`），单独回放、按 layout.json 拼回整图，与画廊 replica 比对像素差，作者确认后置为可用。
- **入口**：`pending` → `scaffold-template <版式> --chart-type <图型> --panels A,D` → `verify-template <模板>` → `verify-layout <版式>` → `mark-ready <id>`
- **关键文件**：`rwiki/templates.py`、`rwiki/layouts.py`、`rwiki/spec.py`、`rwiki/compose_runner.py`
- **测试**：`test_templates.py`、`test_panels.py`、`test_layouts.py`、`test_spec.py`
- **已知限制**：单图模板版心是固定 rect，短标签数据一侧留白；版式拼合只支持 Python panel；spec 的表只写 `interface`，文件名固定 `<接口>.csv`。
- **审查**：`T2-review.md`、`T2-fix-review.md`、`P1-review.md`、`P2-review.md`、`M2-review.md`（版心）

## 3. 推荐与套用（suggest / render / record-use）

- **做什么**：按图型、列名、关键词给 ready 模板排序；生成候选拼图；用数据渲染模板；在课题页记录使用。`suggest-pipeline` 给“方法 + 可接的图”组合。
- **入口**：`suggest --chart-type … --columns a,b --q …`、`contact-sheet <1–3 个模板> --out png`、`render <模板> --data <目录> --out <目录> [--style json]`、`render-layout <版式> …`、`record-use <模板> --project <slug> --title … --output … --method <方法>`
- **关键文件**：`rwiki/suggest.py`、`rwiki/contact_sheet.py`、`rwiki/usage.py`、`rwiki/templates.py`
- **测试**：`test_t3.py`
- **已知限制**：只推荐 ready；`suggest` 只搜标题、标签与“适用”节，不搜备注；`contact-sheet` 最多 3 个模板。
- **审查**：`T3-review.md`、`R1-review.md`

## 4. 方法笔记（method / interface）

- **做什么**：一步分析一篇笔记（用途、适用、输入、怎么做、代码、输出），可附 `source/` 原代码与 `code/` 可复用模板；声明 `outputs` 接口后自动与图模板连成“分析 → 出图”，facts 重建、网络带箭头。方法不绑定模型。
- **入口**：`scaffold-method <id> --title … --license … (--from-entry | --from-path | --written) [--url --commit]`、`add-interface <slug> --title … --columns json`、`mark-ready`/网页确认
- **关键文件**：`rwiki/methods.py`、`rwiki/interfaces.py`、`rwiki/facts.py`
- **测试**：`test_methods.py`、`test_m1_integration.py`、`test_r1.py`
- **已知限制**：知识库不运行方法、不装包；`--written` 必须写 `cite`；多分类 SHAP 每个类别一套值，模板一次画一类。
- **审查**：`M1-review.md`、`M2-review.md`、`M2c-review.md`、`R1-review.md`

## 5. 网页服务（serve）

- **做什么**：FastAPI 本地服务，提供页面、图谱、日志、文件与写接口（签核/退回、方法确认/退回、标签、收藏、备注、归档/恢复），每次写入 git 提交；托管前端构建产物。
- **入口**：`wiki.py serve [--no-browser]`，只绑 `127.0.0.1:<port>`
- **关键文件**：`rwiki/server.py`、`frontend/src/`、构建产物 `staged/research-wiki/app/`
- **测试**：`test_server.py`（TestClient）
- **已知限制**：无登录、单写者；文件服务只读两个根目录；网页外壳 `no-store`，资源带哈希。
- **审查**：`T4-review.md`、`M3-notes.md`、`R1-review.md`
- **双击启动**：项目根 `启动知识库.vbs` → `tools/launcher.ps1`：后台起服务、开独立浏览器应用窗口，窗口关闭即停服务；日志 `.launcher.log`。

## 6. 规则与体检（init / lint / save）

- **做什么**：`init` 建库或把已有库的 `AGENTS.md`/`CLAUDE.md` 更新到技能包版本；`lint` 查断链、frontmatter、状态一致性、空白适用说明；`save` 重建 index 与 facts，有变化才写 log 并提交。
- **入口**：`init`、`lint`、`save "<说明>"`
- **关键文件**：`rwiki/store.py`、`rwiki/lint.py`、`rwiki/catalog.py`、`assets/AGENTS.md`
- **测试**：`test_store.py`、`test_lint.py`、`test_links.py`、`test_config.py`
- **已知限制**：旧 schema 的库必须先跑迁移（`codex/R1-migrate.py`）再 `init`，否则 `save` 重建 facts 会因缺 `tags` 报错。
- **审查**：`T1-review.md`、`M2c-review.md`、`R1-review.md`、`T7-acceptance.md`

## 7. 迁移（一次性，已执行）

- **做什么**：把旧库（method.json / params.yaml / example / scenarios）迁到新结构（方法笔记 + 自由 tags），可重复执行。
- **入口**：`python codex/R1-migrate.py <总库根> --config <配置>`
- **测试**：`test_r1_migration.py`
- **状态**：正式库与 test-wiki-r1 已迁移；脚本按测试重建过。
