我先读取指定的 staged 版 SKILL.md（而非全局旧版），并并行查看课题目录、工作根和 R 运行配置。工作区里的 `.agents/skills/research-wiki` 是空壳，按用户指示以 staged 目录为准。现在读总库 AGENTS.md、查看 Wiki 中已有方法/模板/项目页，并确认专用 Python 解释器存在。发现清单输出被截断，读完整文件看其余候选和未验证分支。模板 render 用 `jsonlite`/`ggplot2`/`svglite`。确认这三个包在环境里，并看 fig04 的 core/panel 还需要什么。依赖齐全（jsonlite 2.0.0、svglite 2.2.2、ggplot2/dplyr）。方案定为：按 GSM 样本统计细胞类型比例 → `render-cell-proportions` 接口 → fig04 ready 模板出图。先建任务清单，然后检查 rds 对象取得可证实状态证据。需要加载 Seurat 包。修复后重跑。看 project_state.py 里 style 输入的声明方式（影响分级的判定依据）。ID 需小写安全字符，改用 `gsm7986396/gsm7986397`。登记授权约定与候选任务（主线/探索/补材料三类）。再登记探索补充与需要补材料的候选任务。写 style 覆盖文件并运行比例脚本。比例表已生成，每组和为 1。查看 CSV 内容并渲染 fig04 模板。CSV 正确（18 行、完备网格、计数与 meta.data 一致）。登记 compute run，然后渲染。图已生成。按流程打开 PNG 目检。`project check` 全部通过。看看领域 profile 有哪些可用，跑 evaluate。单细胞 profile 匹配。其前提按 `properties`/`claim` 匹配——查 evaluate 的匹配实现，确定观察 claim 该怎么写才算满足。看 `add_object` 是否允许同 id 更新（要补 `assay/organism/id_system` 属性供 evaluate 匹配）。范围语义符合设计（前提只认登记词表与属性，about 不外溢）。现在做影响判断演示：先给 style 文件登记 `role=style` 对象，再在 `demo/` 下做数据/样式副本，分别跑 `project impact`。`$r` 未在新会话定义，补上重跑。经验草稿已登记（pending）。现在取关键文件哈希，写交接文档（context.json / recommendations.md / mapping.json / 图-输入对应检查 / HANDOVER.md）。最后确认原课题目录未被改动（wiki-use 之外无今日写入）。全部完成。交付汇总如下。

## 本次实际产出（均在 `acceptance-20261024/`）

**成图**：`figures/proportions-by-gsm/figure.png|.pdf|.svg`（+sizing.json）——`2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow` ready 模板，`--style` 覆盖 `x_levels=[GSM7986396,GSM7986397]` 后出图，目检无裁切。

**分析链**：`scripts/proportions_by_sample.R`（复用 annotation.R Step6 聚合，`group` 由 phenotype 改为 `orig.ident`）→ `analysis/render-cell-proportions.csv`（2×9 完备网格、组和=1）→ `render` 出图。已按 `figure-input-check.md` 逐行核对表↔图。

**登记**：`_project` 状态层（2 entity、11 object、9 observation、2 route、8 task、2 completed run、6 current artifact、1 authorization、1 pending lesson）；Wiki 侧 `record-use` → `projects/gse251716-glaucoma-scrna.md`。

## 候选分析（详见 `recommendations.md`）

- **主线**：GSM 细胞组成描述（本轮已完成）。理由：材料齐备、纯描述、与 `route-descriptive-gsm` 一致。
- **探索补充**：fig03 marker dotplot（中量级聚合）；通路热图（ComplexHeatmap 在库、课题函数可复用）；slingshot（包在库、分支 verified，缺 root 依据需先定）。
- **需要补材料**：fig01/fig02（缺 `ggunchull`，精确 not_run 原因）；疾病对比/DE（设计未知+范围外）；RNA velocity（无 spliced/unspliced）；原脚本重跑（10 个包缺失+授权禁止）。

## 关键演示结果

- **数据变更**（`object:seurat-annotated`）：compute 级传导至 CSV→图全部产物与 6 个消费任务；**样式变更**（`role=style` 的 style-fig04-gsm.json）：仅 `task-render-prop-fig` 标记 `style_only`（重渲染不重分析）；**修改过的副本**无登记消费者、无传导（不按文件名猜）；改副本字节后 `check` 精确标 `stale`，旧产物保留。
- **接手**：`status/summary.md/recover` 可读全部状态；同身份 `record-run` 返回 `duplicate_of` 不重算；`evaluate` 按 subject 范围与登记词表如实给 satisfied/unsatisfied/unknown。
- **经验草稿** `lesson-gsm-style-override`（pending）：模板 spec 固化的示例 levels 必须 `--style` 覆盖；登记对象用 profile 词表 kind+`assay/organism/id_system` 否则前提 unknown——待作者评审，未写正式 Wiki。

## 边界说明

两样本 GSM7986396（4118 cells）/GSM7986397（5982 cells）；`phenotype` 与 GSM 一一对应但疾病含义未证实（author_stated/unknown），本轮全部按 GSM 口径、仅描述性。原课题目录核验无改动。