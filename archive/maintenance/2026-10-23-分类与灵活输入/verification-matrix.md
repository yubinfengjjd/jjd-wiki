# 验收矩阵：方法两级分类与灵活输入

日期：2026-10-23。状态图例：PASS = 本轮实际运行/实查通过；PENDING = 按交接要求留给 Codex 审查后部署；N/A = 本轮明确不做。

## 1. 需求 × 前端 / 后端 / CLI / 规则 / 五处安装

| 需求 | 后端 | 前端 | CLI | 规则与文档 | 五处安装 | 状态 |
|---|---|---|---|---|---|---|
| 领域 → 用途两级入口 | `rwiki/method_taxonomy.py` 单一词表；`GET /api/method-taxonomy` 与 lint 同源；`tests/test_method_taxonomy.py` 17 passed | `MethodsView` 两级导航、计数、用途交集；SSR 24 checks；真实浏览器点击通过 | 无新增命令（浏览由 API/网页） | 正式 AGENTS、staged AGENTS、SKILL、method-families.md | 文件已生成，未同步 | PASS（源码）；PENDING（安装） |
| 真实路由与 query | `route.ts` 分离 path/query，逐段 decode；`Route.query` 传给 App | 点击领域/用途/搜索/清除/刷新均留在方法库；方法卡进入 page 路由；无 console error | 浏览器 `browser-review1.json` | 前端测试 + 浏览器证据 | 未同步 | PASS |
| 多标签多入口、同一 id/规范页 | taxonomy 以 path 去重；`select_methods` 交集；API 计数为去重页数 | 每页只渲染一张卡；URL 保留 domain/purpose/q | N/A | AGENTS“研究领域与分析用途” | 同上 | PASS |
| 去重计数不把重叠相加 | 真实 15 页：域计数和 21 > 15 | 显示 15/13/4 等去重数 | N/A | AGENTS 明写 | 同上 | PASS |
| 分类不是科学/执行硬门槛 | `suggest`/`ready_for_use` 未改；分类只进 lint/API | 分类只筛卡片 | `suggest-methods` 未改 | AGENTS/SKILL 明写 | 同上 | PASS |
| 保留 analysis / workflow / technical | 原 `method_kind` 门槛与 API 未改 | 辅助资料折叠区仍可达；测试断言不混入 | `pending`/`suggest` 未改 | 原规则保留 | 同上 | PASS |
| 缺用途旧页可读 + 提示 | lint WARN；`check-entry` warnings；不改 status | 旧页仍出现在“全部”，不进入用途筛选 | `check-entry` 输出 warnings | AGENTS“缺 purposes…” | 同上 | PASS |
| 非法/重复用途报错 | `purpose_errors` → metadata ERROR | 前端只使用 API 词表 | lint exit 1（夹具测试） | AGENTS/SKILL 明写 | 同上 | PASS |
| 分类变化不使算法收据失效 | 收据只哈希 code；测试断言 purposes 变化后仍 verified | 实现状态来自后端 | N/A | AGENTS 明写 | 同上 | PASS |
| 三层输入（语义/实现/内部表） | `data_contract` + spec/接口 + `input_binding` | 方法详情语义在前、内部 schema 折叠 | `render --bindings` | 正式/staged AGENTS、SKILL、`references/input-binding.md` | 同上 | PASS |
| 外部文件/列显式映射 | `input_binding.prepare_tables`；未知表/字段/重复/越界/非数值先失败 | 模板页显示 `input_contract` 与 `--bindings` | `tests/test_input_binding.py` 36 passed | 同上 + project-reuse.md | 同上 | PASS |
| 输出不得覆盖源 | 写前预检全部来源/输出（同名、另一表输入、samefile 别名）；staging 后替换；失败恢复。R 无 fs 时也以“移开旧目录项 + 重命名”避免写穿源 inode | N/A | Python 单例/批处理/硬链接；R overwrite/other_sources/无 fs 硬链接/重复运行探针 | AGENTS/SKILL/reference | 同上 | PASS |
| R 报告语义非空 | `prepare_binding_table`/`bind_table` 共用 `.binding_semantics` | N/A | `codex-review-repeat.R` 输出 `semantics nonempty: TRUE` | reference | 同上 | PASS |
| 有效映射不双消费 | 显式 + 同名回退统一统计来源列消费者；冲突报具体字段 | N/A | Codex 探针 + 单测 + R 探针 | AGENTS/SKILL/reference | 同上 | PASS |
| R pivot 主键保真 | 按值身份识别 index；空字符串/嵌入 `\r` 保留；空/缺失 pivot 拒绝 | N/A | R/Python 同夹具比较 + Codex R 探针 | reference | 同上 | PASS |
| 不改原表 | 源 SHA256 在写前采集、写后一致；报告 `source_sha256` = 写前 author 哈希 | 文案明确“原表不改” | `inputs_unchanged=true`；旧标准 example 也未变 | AGENTS/SKILL | 同上 | PASS |
| 不猜列/不补值/不换算/不统计 | 只按 map/同名列；缺失可选项省略；数值仅校验 | 不声称单位已验证 | 负例：缺 `avg_expression` exit 1 | AGENTS/SKILL/reference | 同上 | PASS |
| 0–1 / 0–100 提示不换算 | 描述匹配警告；值原样写入；测试断言 0.4 不变 40 | 文案写明不换算 | 真实 SHAP `percent` 无假警告 | 同上 | 同上 | PASS |
| 无聚合 melt/pivot | `reshape_records`；pivot 重复键拒绝；index 值身份保真；空/缺失 pivot 拒绝 | N/A | bindings `reshape` 字段 + R/Python 夹具 | reference/AGENTS | 同上 | PASS |
| 必需/可选按实现能力 | 接口列/表 `required:false`；`check_data` 只查必需；两个真实模板有可选机制 | API 返回 required；模板页显示必需/可选 | 省略 `cell` 输出一致；省略 `target_group` 成功 | reference/AGENTS | 同上 | PASS |
| 可选表/列不被滥用 | 只对 `target_group`、`cell` 声明可选；核心代码未改 | 折叠表标注 | 真实运行验证 | AGENTS 明写“核心仍索引的列不得改可选” | 同上 | PASS |
| 映射报告 | `bindings-report.json`：源路径/哈希、映射、缺失可选项、范围、警告、语义边界 | 模板页提示报告位置 | 真实案例逐项检查 | reference/AGENTS | 同上 | PASS |
| 可复制纯适配模块 | `rwiki/input_binding.py`（stdlib） | N/A | 可直接复制 | `references/input-binding.md`、code-assets.md | 未同步 | PASS（源码）；PENDING（安装） |
| R/Python 同夹具等价 | — | — | `test_r_and_python_adapters_agree...` 全列/省略可选两模式 | reference | 未同步 | PASS |
| 真实 R/Python 模板前后对照 | — | — | 3 个真实模板、5 个绑定案例 | reference 记录结果 | 未同步 | PASS |
| 旧标准 render / verify / 单panel 回放兼容 | `verify-template` 未改；7 个受影响模板重跑 exit 0；lint 无 stale | 图库 30 checks 通过 | 标准 render 与改动前 PNG 逐字节一致 | AGENTS“旧标准入口” | 未同步 | PASS |
| 前端语义优先、schema 折叠 | `/api/page` 返回 `input_contract`；方法 facts 含用途 | 方法详情、模板详情、接口页；SSR 真实 API 快照 | N/A | AGENTS 验收“编译内容” | 未同步 | PASS（源码） |
| 八步入库：先查重/分类/读语义再绑定 | lint/check-entry 分类提示；API 词表 | N/A | — | 正式/staged AGENTS、SKILL、method-families、project-reuse | 未同步 | PASS（文档+代码）；PENDING（安装） |
| 不按文件名/列名/来源重复建方法或接口 | 无新接口；只给两个既有接口加可选标记 | N/A | 绑定不新建接口 | AGENTS/SKILL 明写 | 未同步 | PASS |
| 五处 skill 同步 | source 文件齐全；`tools/deploy.py` 自动包含新模块/文档 | N/A | N/A | 五处当前仍为旧版 | 见下节 | PENDING（按指令） |

## 2. 五处安装副本对照

安装路径与逐文件 SHA256 见 `deployment-copies.json`。本轮**未部署**，按交接要求由 Codex 审查后执行 `python tools/deploy.py <本维护记录> "<说明>"`。

| 安装 | 目录存在 | 与本轮 staged 的差异 | 状态 |
|---|---|---|---|
| `.agents` | 是 | SKILL/AGENTS/references 旧版；缺 `method_taxonomy.py`、`input_binding.py`、`input_binding.R`、`input-binding.md` | 待部署 |
| `.claude` | 是 | 同上 | 待部署 |
| `.codex` | 是 | 同上 | 待部署 |
| `.cc-switch` | 是 | 同上 | 待部署 |
| `.config/opencode` | 是 | 同上 | 待部署 |

- 五处当前 `config.json` 与 staged 一致（deploy.py 会再次断言）。
- 部署脚本会遍历 staged 全部文件，新增模块、参考文档、R helper 会自动包含；未运行部署脚本。

## 3. 实际命令 / 退出码

| 命令 | 退出码 | 证据 |
|---|---|---|
| `pytest tests/test_method_taxonomy.py -q` | 0（17 passed） | 会话输出 |
| `pytest tests/test_input_binding.py -q` | 0（36 passed，含 R/Python 等价、覆盖/别名/有效映射/pivot/无 fs 硬链接） | 会话输出 |
| `pytest tests/test_input_binding.py tests/test_spec.py -q` | 0（71 passed） | 会话输出 |
| `codex-review-repeat.R` / 无 fs 硬链接 R 探针 | 0 / 0 | `logs/codex-r-repeat-review2.log`、`logs/codex-r-nofs-review2.log` |
| 定向回归 8 个测试文件 | 0（188 passed；随后 binding 测试增至 35，最终全套 489） | `logs/targeted-review1.log` |
| `pytest -q`（全套，第二轮审查修复后） | 0（490 passed / 2 skipped） | `logs/full-pytest-review2.log` |
| `npm --prefix 开发/frontend test` | 0（24 PASS + 30 checks） | `logs/frontend-test-review1.log` |
| `npm run typecheck` / `build` | 0 / 0 | `logs/frontend-typecheck-review1.log`、`logs/frontend-build-review1.log` |
| `wiki.py lint`（正式库） | 0（5 WARN not_run，无 ERROR） | `logs/final-lint.log` |
| `validate_bindings.py`（审查修复后） | 0 | `binding-validation-review1.json`、`logs/binding-validation-review1.log` |
| `codex-review-probes.py` / `.R` | 0 / 0 | 本记录 `scripts/` |
| 真实浏览器（临时 8788 + headless Chrome/CDP） | 0 | `browser-review1.json`、`browser-review1.png`、`logs/browser-review1.log` |
| `verify-template` × 7 | 0 × 7 | `logs/reverify.txt` |
| 保护检查脚本 | 0 | `protection-check.json` |
| 标准 render 基线对照 | 0 | `standard-render-regression.json` |

## 4. R/Python 输入绑定前后对照

标准输入 = 模板自带 `example/<interface>.csv`；绑定输入 = 改名/改列后的作者文件 + `--bindings`。图中“同字节”指 PNG SHA256 相同；“MAD”为 0–255 平均绝对像素差。

| 案例 | 模板/表键 | 标准 exit | 绑定 exit | 同尺寸 | 同字节 | MAD | 省略可选项 | 警告 |
|---|---|---|---|---|---|---|---|---|
| R 点图 | dotplot / `dotplot` | 0 | 0 | 是 | 是 | 0 | — | 无 |
| R 点图省略 target_group | dotplot / `dotplot` | 0 | 0 | 是 | 否 | 8.005185978 | `target_group` | 无（排序回退，预期差异） |
| R 分组柱图 | bar / `metadata` | 0 | 0 | 是 | 是 | 0 | — | 无 |
| R 分组柱图省略 cell | bar / `metadata` | 0 | 0 | 是 | 是 | 0 | `cell` | 无 |
| Python SHAP 条形图 | shap bar / `SHAP汇总` | 0 | 0 | 是 | 是 | 0 | — | 无 |
| 缺必需 `avg_expression` | dotplot / `dotplot` | — | 1 | — | — | — | — | `数据绑定失败: 缺少必需字段: avg_expression`，无输出 |

- 绑定调用还验证了“改名文件不给 bindings”会被旧严格入口拒绝。
- 证据质量：`binding-validation-review1.json` 对每个案例记录 `example_sha256_before/after` 与 `author_sha256_before/after`，全部 `inputs_unchanged=true`；报告 `source_sha256` 等于写前 author 哈希（`source_sha256_matches_input_before=true`）。旧 `binding-validation.json` 保留未覆盖。
- 报告检查：`checks` 四项齐全；`semantics` 明写不验证单位/粒度/配对；SHAP `percent` 不再被误报为 0–1。
- 标准输入回归：3 个模板当前标准 PNG 与改动前基线 PNG **逐字节相同**（`standard-render-regression.json`）。
- Codex 复现：`scripts/codex-review-probes.py` 输出双消费拒绝、源输出冲突拒绝且 `source_changed=false`；`scripts/codex-review-probes.R` 输出双消费拒绝、空字符串/嵌入 CR 的 pivot index 原样保留。
- R 第二轮：`codex-review-repeat.R` 的 `semantics nonempty: TRUE`、重复调用 success；强制无 `fs` 硬链接探针源字节不变、输出正确、无 backup 残留。

## 5. 真实 API / SSR 对照

- `/api/method-taxonomy`（正式库）：`total=15`，`unclassified=[]`；域：单细胞分析 13、转录组 4、机器学习 2、实验统计 1、模型解释与特征重要性 1；用途：预处理 2、降维 2、整合 1、注释 2、差异 3、轨迹 3、模型评价 1、模型解释 1。
- `/api/page`（模板）：dotplot `input_contract` 显示 `target_group.required=false`；bar 显示 `cell.required=false`。
- SSR 使用 `tests/real-taxonomy.ts`（由 TestClient 从正式库生成，123 页）：
  - 默认目录显示 15、领域/用途计数；
  - `gene-set-scoring` 有两个领域标签但只出现一张卡；
  - 单细胞分析 × 轨迹与动态分析只显示 3 个家族；
  - 方法详情语义输入在“内部表格式”之前且只出现一次；
  - 两个真实模板详情显示必需/可选、`--bindings`、不验证单位。
- 真实浏览器（临时 8788，未触碰 8765）：初始 15 卡；点击“单细胞分析”→13 卡；点击“轨迹与动态分析”→3 卡；搜索“模型解释”→1 卡；清除后输入为空；带 domain/purpose 刷新仍 3 卡；点击方法卡进入 `#/page/methods/dynamic-feature-analysis.md`；`window.__rwikiErrors=[]`。证据 `browser-review1.json`、截图 `browser-review1.png`。

## 6. 保护与未完成

- 210 个 source 文件 SHA256、作者 `user` 区块、`status`、`favorite`、`archived_from`、旧 id 全部未变（`protection-check.json`）。
- 知识库本轮 16 个 save 提交，工作区干净；未 reset/clean，未覆盖旧维护记录。
- 未部署五处、未重启正式 8765、未提交开发仓库；开发仓库保留既有 dirty tree 与本轮改动供 Codex 审查。
- 未运行真实课题数据；未新增/修改统计或绘图算法；未安装依赖。
- 真实可选表没有案例（只演示可选列）；`render-layout` 不支持 bindings；R 在无 openssl 时无 SHA256；无 fs 时不能提前识别所有硬链接，但替换目录项保证不写穿源 inode。以上均已在 `claude-result.md` 列为缺项/风险。
