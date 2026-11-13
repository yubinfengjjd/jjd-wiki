# 执行进度：方法两级分类与灵活输入

日期：2026-10-23。执行者：Claude Code（唯一编码者）。状态：T0–T4 完成到可审查状态；未部署、未重启正式服务、未提交开发仓库。

## T0 基线与保护

- 沿用本轮基线：`wiki-baseline-head.txt`（475691c…）、`development-baseline-head.txt`（2bbe879…）、`development-baseline-status.json`、`source-hashes-before.json`（210 个 source 文件）。
- 未执行 reset/clean、未覆盖上轮维护记录、未批量提交开发仓库历史改动。
- 保护检查（`protection-check.json`）：210 个 source SHA256 全部一致；作者 `user` 区块、`status`、`favorite`、`archived_from`、旧 `id` 全部一致；知识库 16 个本轮 save 提交，工作区干净。
- 正式库 lint 退出 0；仅 5 条既有 not_run WARN。

## T1 领域 → 用途

### RED → GREEN

- 后端 RED：`pytest tests/test_method_taxonomy.py` 首次收集失败 `ModuleNotFoundError: rwiki.method_taxonomy`。
- 后端 GREEN：17 passed；新增 `rwiki/method_taxonomy.py`、`GET /api/method-taxonomy`、lint 校验、facts 分析用途行、check-entry 提示。
- 前端 RED：`npm test` 首次构建失败，`src/methods.ts` 缺少 `filterAnalysisMethods/normalizeMethodSelection/parseMethodQuery/purposeOptionsFor`。
- 前端 GREEN：24 条方法检查 + 30 条图库检查全部通过；新增领域/用途导航、计数、URL、搜索、空结果、同一 id 单卡、折叠接口入口。
- 真实 API/SSR：用 TestClient 从正式 Wiki 生成 `tests/real-taxonomy.ts`（123 页、15 个 analysis、0 未分类），SSR 断言 15/13/4 与用途交集；不是手写分类夹具。

### 内容迁移（15 个 analysis 家族）

| 家族 | purposes |
|---|---|
| cell-quality-control | 预处理与质量控制 |
| doublet-detection | 预处理与质量控制 |
| dimensionality-reduction | 降维与聚类 |
| cell-clustering | 降维与聚类 |
| batch-integration | 整合与批次校正 |
| cell-type-annotation | 注释与参考映射 |
| reference-mapping | 注释与参考映射 |
| differential-expression | 差异与功能分析（补 `转录组` 标签） |
| gene-set-enrichment | 差异与功能分析 |
| gene-set-scoring | 差异与功能分析 |
| trajectory-inference | 轨迹与动态分析 |
| rna-velocity | 轨迹与动态分析 |
| dynamic-feature-analysis | 轨迹与动态分析 |
| regression-resampling-evaluation | 模型评价 |
| shap-explanation | 模型解释 |

- 真实计数：15 个 analysis；领域 单细胞分析 13、转录组 4、机器学习 2、实验统计 1、模型解释与特征重要性 1；域计数之和 21 > 15，证明去重计数。
- 分类变化只更新元数据/facts/验收；两个 ready 方法重录 acceptance，未改 status；实现收据仍 valid。

## T2 输入映射与可选约束

### RED → GREEN

- RED：`pytest tests/test_input_binding.py` 首次 `ModuleNotFoundError: rwiki.input_binding`；随后“缺必需字段/重复映射/非数值/pivot/可选表/CLI 绑定/R 等价”逐项失败后修正。
- GREEN：`tests/test_input_binding.py` 36 passed（含真实 Python/R 子进程）；`tests/test_spec.py` 35 passed。
- 新增 `rwiki/input_binding.py`（stdlib，可复制）、`assets/input_binding.R`（base R）、`render --bindings`、`spec`/接口 `required:false`、映射报告、无聚合 melt/pivot、单位提示不换算。
- 真实模板可选机制：`render-dotplot-long.target_group`（缺失按 feature 文件顺序）与 `render-cell-metadata.cell`（缺失时只按 group/stat 计数）。两处均无核心代码改动。
- 增加 `required:false` 使接口列哈希变化：重跑受影响 7 个模板的 `verify-template`，全部 exit 0；dotplot/bar 因“数据要求”正文更新重录 acceptance；lint 无 ERROR。
- 旧标准 render 与改动前基线逐字节一致（3 个真实模板，SHA256 相同）。

## T3 前端输入说明、规则与 skill

- 方法详情：语义 `data_contract` 在前；新增折叠“内部表格式与可选字段”，列出必需/可选、`--bindings` 步骤、不验证单位；完整 schema 默认折叠。
- 模板详情：API 返回 `input_contract`（表键/接口/必需/列必需）；前端折叠显示；接口页提示改为“内部执行约定 + bindings”。
- 方法库数据接口从 22 张展开卡片改为折叠入口。
- 正式 `知识库/AGENTS.md` 与 `staged/assets/AGENTS.md` 同步（同一 SHA256）；`SKILL.md`、`references/method-families.md`、`project-reuse.md`、`code-assets.md`、`llm-wiki-mode.md` 更新；新增 `references/input-binding.md`。
- 五处安装副本未同步（按交接要求等待 Codex 审查后部署）；哈希与差异见 `deployment-copies.json`。

## T4 验收

- 全套 pytest：490 passed / 2 skipped，exit 0（`logs/full-pytest-review2.log`）。
- 前端：`npm test` exit 0（24 + 30 checks）；`npm run typecheck` exit 0；`npm run build` exit 0。
- 正式库 lint：exit 0，5 条既有 not_run WARN，无 ERROR。
- 真实 CLI：5 个绑定案例全部出图；必需列缺失 exit 1 且无输出；未绑定改名文件被拒。
- R/Python 对照：点图/柱图/SHAP 条形图标准 vs 绑定 PNG 逐字节一致；可选 `cell` 缺省一致；可选 `target_group` 缺省成功但排序回退导致像素差 8.005（已解释）。
- 真实 API/SSR：领域→用途→详情；多领域页面单卡；模板块显示 required/optional。
- 保护检查：source 字节、作者区块、status/favorite、旧 id 全部未变。

## Codex 第一轮审查修复（2026-10-23）

- **P1 路由**：`route.ts` 先分离 path/query，再逐段 decode；`Route.query` 原样传给 `MethodsView`，`#/methods?domain=...` 不再被当成 view。搜索框改为受控输入并由 URL 同步，清除/刷新不残留旧值；搜索 haystack 加入 `purposes`。
- **P1 适配器覆盖源**：`prepare_tables` 先校验所有表、记录写前源哈希、预检全部来源/输出（同名、另一表输入、硬链接/符号链接别名），再 staging 写入，全部成功后才替换；失败删除本次输出并恢复旧输出。R `prepare_binding_table` 同样预检自身与其他来源，写前哈希，`reshape` 不再用分隔符还原 index。
- **P2 有效映射**：Python/R 都检查显式映射 + 同名回退；同一作者列被多个内部字段消费时报具体冲突，不再用同名回退填补必需字段。
- **P2 R pivot**：按原值身份识别 index，空字符串与嵌入 `\r` 原样保留；空/缺失 pivot 类别显式拒绝；R/Python 同夹具比较。
- **证据质量**：新 `binding-validation-review1.json` 在 render 前后分别记录 example 与 author 文件哈希，报告 `source_sha256` 为写前 author 哈希；旧 `binding-validation.json` 保留不覆盖。真实浏览器（临时 8788 服务 + headless Chrome/CDP）点击领域、用途、搜索、清除、刷新保留、方法卡路由，证据 `browser-review1.json`/`browser-review1.png`。
- Codex 复现脚本 `scripts/codex-review-probes.py`/`.R` 已重跑：双消费拒绝、源输出冲突拒绝且源不变、R 空字符串/嵌入 CR pivot 保真。

## Codex 第二轮审查修复（2026-10-23）

- **R 报告 semantics 为 NULL**：新增 `.binding_semantics` 共用常量；`bind_table` 与 `prepare_binding_table` 都返回非空限制说明（不验证单位/粒度/配对，不自动换算）。`codex-review-repeat.R` 现输出 `semantics nonempty: TRUE`。
- **无 fs 时硬链接可能改源**：R 写输出不再 `file.copy(overwrite=TRUE)` 写穿现有目录项；改为先 `file.rename` 移开旧输出，再把 staging 文件 `file.rename` 到目标，失败恢复旧目录项。即使没有 `fs`、未提前识别硬链接/符号链接，源 inode 也不会被覆盖；正常重复运行仍成功。
- 新增强制无 fs 硬链接负例（Python 创建 hardlink，R 以 `RWIKI_DISABLE_FS=1` 运行）：源字节不变、输出正确、无 backup 残留；R 探针同时覆盖已有独立输出重跑与第二个来源。
- 旧 RED 日志 `logs/codex-r-repeat-red.log` 保留；新证据 `logs/codex-r-repeat-review2.log`、`logs/codex-r-nofs-review2.log`。

## 最小实现选择与缺项

- `--bindings` 只加在单模板 `render`；`render-layout` 组合入口未加 bindings（组合仍用标准表），未声称支持。
- 可选表在 schema 支持并有夹具测试；真实模板只演示可选列，没有真实可选表。
- R 映射报告在无 `openssl` 时 `source_sha256` 为 NA；CLI（Python）报告始终有 SHA256。
- 五处安装副本保持旧版，等待 Codex 审查后由 `tools/deploy.py` 同步。
- 未运行真实课题数据；所有图/表等价仅为软件夹具证据，不代表科学有效性。
