# Claude Code 实施结果：方法两级分类与灵活输入

日期：2026-10-23。执行者：Claude Code（单进程，无子代理、无 Codex 调用）。状态：T0–T4 完成到可审查状态。**未部署、未重启正式 8765、未提交开发仓库。**

## 1. 完成内容

### 1.1 领域 → 用途两级浏览（T1）

- 新增 `rwiki/method_taxonomy.py`：8 个受控用途的单一词表；`taxonomy()` 从现有 analysis 页派生领域/用途计数；`select_methods()` 交集筛选；`purpose_errors()` 校验。
- `GET /api/method-taxonomy` 与 `lint` 共用同一派生；计数按规范页去重，重叠分类之和不等于方法数。
- `lint`：缺用途 WARN；非法、重复、非 analysis 使用 ERROR。`check-entry` 输出 warnings，不改作者状态。
- `facts.method_facts` 增加“分析用途”行。
- 前端：
  - `App` 与 `api` 从后端取 taxonomy；
  - `MethodsView` 领域/用途两级导航、去重计数、URL 保留、搜索、空结果返回全部；
  - `route.ts` 先分离 path/query 再逐段 decode，`#/methods?domain=...` 正确进入方法库；搜索框受控并由 URL 同步，清除/刷新不残留旧值；
  - 同一 id 只渲染一张卡；
  - 22 个接口技术清单从展开卡片改为折叠入口。
- 内容迁移：15 个 analysis 家族全部补 `purposes`；`differential-expression` 补 `转录组` 领域标签（正文支持）。未改作者 status/favorite/user 区块。

### 1.2 灵活输入与可选约束（T2）

- 新增 `rwiki/input_binding.py`（仅标准库，可复制到课题）：
  - 显式 `columns`（内部字段 → 作者列）、`file` 相对 `--data`；
  - 未知表/字段、重复映射、重复源表头、越界/网络/隐藏路径、必需表/列缺失、非法数值先失败；
  - 完整有效映射（显式 + 同名回退）中同一作者列只能消费一次；
  - 写前预检全部来源/输出（同名、另一表输入、硬链接/符号链接别名），源哈希写前采集，staging 全部成功后才替换，失败不留部分输出；
  - 额外列保留；可选列省略并报告；
  - 无聚合 melt/pivot，pivot 重复键拒绝，index 按原值身份保留（空字符串/嵌入 `\r`），空/缺失 pivot 类别显式拒绝；
  - 映射报告：源路径/写前 SHA256、映射、保留/省略列、观测范围、缺失、检查、警告、语义边界；
  - 0–1 / 0–100 只提示不换算。
- 新增 `assets/input_binding.R`（base R）：`bind_table(df, columns, mapping)`、`reshape_table(df, reshape)`、`prepare_binding_table(...)`；支持 `other_sources`，安装 `fs` 时用 device/inode 识别别名。
- `templates.render(..., bindings=...)`：在输出目录建临时规范表，旧 render 脚本不变；结束清理临时内容。`render-layout` 未加 bindings。
- `spec`/接口支持 `required:false`；`check_data` 只检查必需列；`requirements_markdown` 在存在可选时显示必需/可选。
- 真实可选机制（不改绘图核心）：
  - `render-dotplot-long.target_group`：缺失时按 feature 文件顺序；
  - `render-cell-metadata.cell`：缺失时只按 group/stat 计数。

### 1.3 前端输入说明、规则与 skill（T3）

- 方法详情：语义输入/输出在前；新增折叠“内部表格式与可选字段”，含必需/可选、bindings 步骤、不验证单位。
- 模板详情：`/api/page` 返回 `input_contract`（表键/接口/表必需/列必需），前端折叠显示。
- 接口页提示改为“标准文件名是内部执行约定，外部列用 `--bindings`”。
- 正式 `知识库/AGENTS.md` 与 `staged/assets/AGENTS.md` 同步（SHA256 相同）；`SKILL.md`、method-families、project-reuse、code-assets、llm-wiki-mode 更新；新增 `references/input-binding.md`。
- 八步入库、语义去重、分类、先读语义再绑定、可选项依据、变换报告与验证已写入规则。

### 1.4 Codex 第一轮审查修复

- **路由（P1）**：`parseRoute` 分离 `#/path` 与 query，逐段 decode path；query 原样交给 `URLSearchParams`，`%26`/`%2F` 保持数据含义。`App` 传 `route.query`；`MethodsView` 搜索框改为受控输入并由 URL 同步；`filterAnalysisMethods` 的 haystack 加入 `purposes`。新增路由单测与真实浏览器点击回归。
- **适配器覆盖源（P1）**：`prepare_tables` 先完成所有表读取/映射/校验，记录写前源哈希；预检全部来源与全部输出（同名、其他表输入、`samefile` 别名），冲突整体失败；所有规范表写 staging，全部成功后才替换，失败恢复旧输出并清理 staging。R `prepare_binding_table` 增加组件边界路径检查、输出/其他来源冲突检查、写前哈希、单文件备份恢复；`other_sources` 供批量调用。
- **有效映射双消费（P2）**：Python/R 在包含同名回退后统计每个来源列的消费者；同一列被多个内部字段消费时报 `同一来源列被多个内部字段消费: feature → group, feature`。
- **R pivot 主键（P2）**：不再用 `\r` 拼接/还原 index；按原值身份建立 key，空字符串与嵌入 `\r` 原样保留；空/缺失 pivot 类别显式拒绝。R/Python 同夹具比较通过。
- **证据质量**：`validate_bindings.py` 在 render 前后分别记录 example 与 author 文件哈希，统一断言不变；报告 `source_sha256` 等于写前 author 哈希。旧 `binding-validation.json` 保留，新证据写入 `binding-validation-review1.json`。
- **真实浏览器**：临时 8788 服务 + headless Chrome/CDP 点击领域、用途、搜索、清除、刷新保留、方法卡路由；`browser-review1.json`、`browser-review1.png`，无 console error。正式 8765 未触碰。

### 1.5 Codex 第二轮审查修复

- **R 报告 `semantics` 为 NULL**：新增 `.binding_semantics` 共用常量；`bind_table` 与 `prepare_binding_table` 都返回非空限制说明（不验证单位/粒度/配对，不自动换算）。提供的 `codex-review-repeat.R` 现输出 `report semantics nonempty: TRUE`。
- **无 `fs` 时硬链接可能改源**：R 输出写入改为“移开旧目录项 + 重命名 staging 文件”；不再用 `file.copy(overwrite=TRUE)` 写穿现有 inode。即使没有 `fs`、未提前识别硬链接/符号链接，源内容也不会被修改；正常重复运行仍成功。
- **负例**：Python 创建 output→source 硬链接，R 以 `RWIKI_DISABLE_FS=1` 运行：源字节不变、输出为正确规范表、无 backup 残留；同一探针覆盖已有独立输出重跑和其他来源冲突。旧 RED 日志保留。

## 2. 实际命令与退出码

| 命令 | 退出码 | 结果 |
|---|---|---|
| `pytest tests/test_method_taxonomy.py -q` | 0 | 17 passed（含 facts 与 check-entry） |
| `pytest tests/test_input_binding.py tests/test_spec.py -q` | 0 | 71 passed |
| `pytest tests/test_input_binding.py -q` | 0 | 36 passed（含覆盖/别名/有效映射/pivot/无 fs 硬链接/R 等价） |
| 定向回归 8 个测试文件 | 0 | 188 passed（当时；随后 binding 测试增至 35，最终全套 489） |
| `pytest -q` 全套（第二轮审查修复后） | 0 | **490 passed / 2 skipped**，248.41s |
| `npm --prefix 开发/frontend test` | 0 | 24 PASS + 30 图库 checks |
| `npm run typecheck` | 0 | — |
| `npm run build` | 0 | 写入 staged app |
| `wiki.py lint`（正式库） | 0 | 5 条既有 not_run WARN，无 ERROR |
| `validate_bindings.py`（审查修复后） | 0 | 5 案例 + 1 负例；输入前后哈希不变 |
| `codex-review-repeat.R` | 0 | `semantics nonempty: TRUE`；重复调用 success |
| 无 fs 硬链接 R 探针 | 0 | 源不变、输出正确、无 backup |
| `verify-template` × 7 | 0 × 7 | 受影响模板回放刷新 |
| 保护检查 | 0 | 210 source 哈希、作者区块/状态/id 全一致 |

证据文件：`logs/full-pytest-review2.log`、`logs/targeted-review1.log`、`logs/frontend-test-review1.log`、`logs/frontend-build-review1.log`、`logs/final-lint.log`、`logs/reverify.txt`、`binding-validation-review1.json`、`browser-review1.json`、`browser-review1.png`、`logs/codex-r-repeat-review2.log`、`logs/codex-r-nofs-review2.log`、`standard-render-regression.json`、`protection-check.json`、`deployment-copies.json`。旧 `binding-validation.json`、`logs/codex-r-repeat-red.log` 与旧日志保留。

## 3. R/Python 输入绑定前后对照

标准输入 = 模板自带 example；绑定输入 = 改名/改列后的作者文件 + `--bindings`。

| 模板 | 标准 | 绑定 | 结果 |
|---|---|---|---|
| R 点图（dotplot） | exit 0 | exit 0 | PNG 同尺寸、同字节、MAD 0 |
| R 点图省略 `target_group` | exit 0 | exit 0 | 同尺寸；MAD 8.005185978，排序回退导致（已声明行为，不是数值变化） |
| R 分组柱图（bar） | exit 0 | exit 0 | PNG 同字节、MAD 0 |
| R 柱图省略 `cell` | exit 0 | exit 0 | PNG 同字节、MAD 0（cell 只用于唯一性检查） |
| Python SHAP 条形图 | exit 0 | exit 0 | PNG 同字节、MAD 0 |
| 缺必需 `avg_expression` | — | exit 1 | `数据绑定失败: 缺少必需字段: avg_expression`，无 figure 输出 |

- 改名文件不给 bindings：旧严格入口拒绝（缺 `<接口>.csv`）。
- 三个模板当前标准 render 与改动前基线 PNG **逐字节相同**（`standard-render-regression.json`）。
- 源文件 SHA256 写前/写后一致（example 与 author 分别记录）；报告 `source_sha256` 等于写前 author 哈希；SHAP `percent` 不再被误报为 0–1。
- 这些是软件等价证据，不代表真实课题科学有效。

## 4. 保护检查

- 210 个 `source/` 文件 SHA256 与基线全部一致；无删除、无改写。
- 所有 methods/layouts/templates 的 `user` 区块、`status`、`favorite`、`archived_from`、旧 `id` 与基线提交 475691c 一致（`protection-check.json`）。
- 两个 ready 方法（shap、regression）因 purposes 变化重录 acceptance，未改 status；实现收据仍 `verified`。
- 7 个受接口 `required` 影响模板重跑 verify，lint 无 stale；dotplot/bar 因正文“数据要求”更新重录 acceptance。
- 知识库本轮 16 个 save 提交，工作区干净；未 reset/clean，未覆盖旧维护记录。
- 开发仓库保留既有 dirty tree；未提交、未部署、未重启服务。

## 5. 缺项、最小实现与风险

1. **未部署五处**：按交接要求等待 Codex 审查。五处当前仍是旧版；`deployment-copies.json` 记录逐文件哈希。`tools/deploy.py` 会自动包含新增模块、R helper、reference 与构建产物。
2. **`render-layout` 不支持 bindings**：本轮只给单模板 `render` 增加；组合入口继续用标准表。未声称支持。
3. **没有真实可选表案例**：真实模板只演示可选列（`target_group`、`cell`）；可选表由 schema + 夹具测试覆盖。
4. **R 报告哈希与别名检测**：无 `openssl` 时 R helper 的 `source_sha256`/`output_sha256` 为 NA；无 `fs` 时不能提前识别所有硬链接，但写入采用“移开旧目录项 + 重命名”，不会写穿源 inode（已用强制无 fs 硬链接负例验证）。CLI（Python）始终有 SHA256，并用 `samefile` 识别链接别名。
5. **点图省略 `target_group` 会改变基因顺序**：这是 core 已声明回退行为，像素差 8.005；不是数值/统计变化，但出图前应确认排序需求。
6. **分类与科学适用性分离**：用途只用于发现；未改 `suggest`/`ready_for_use` 门槛；未用分类替代实现验证。
7. **未运行真实课题**：没有真实数据、科学或临床有效性结论；未安装依赖、未改统计/绘图算法。
8. **浏览器验证范围**：headless Chrome/CDP 已验证领域/用途/搜索/清除/刷新/方法卡路由，截图见 `browser-review1.png`；未做作者视觉签核或多浏览器矩阵。
9. **开发仓库 dirty tree**：包含上轮已部署成果与本轮改动，按指令不替作者批量提交；Codex 可对照 `development-baseline-status.json` 区分。
