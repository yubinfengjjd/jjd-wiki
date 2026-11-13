# 2026-10-22 原始层、尺寸与命名治理

本记录覆盖本轮“格式/去重 → 命名 → SCP GroupHeatmap”三段工作。部署清单与逐文件哈希见同目录 `deployment-verification.json`。

## 1. 青光眼模板 adaptive sizing

- 5 个模板：fig01 CNS UMAP、fig02 marker UMAP 小多图、fig03 气泡点图、fig04 比例堆叠流带、fig06 分组小提琴。
- `spec.style.sizing` 增加 adaptive 参数；`code/sizing.R` 提供固定/自适应两种模式；`example/style.json` 用 fixed 保持回放尺寸。
- fig06 的 `geom_jitter` 增加 `seed=11`，回放可重复；fig01/02 的 `--style` 数组覆盖改为 `simplify_style`，修复 group_levels 不生效。
- 固定回放：fig01/02/03/04 与原哈希一致；fig06 因 seed 变化，已重新 `verify-template`。
- 规模测试：fig01 3→18 组、fig02 3→6 行、fig03 3→104 特征、fig04 2→4 组、fig06 4→18 类型；超限 `max_width_in` 正确报错。
- 5 页 `verify-template` exit 0、`check-entry --record` 完成；使用记录改为作者已确认。

## 2. 方法原始代码去重

- 同字节清单：`shap-explanation` 6 个、`regression-resampling-evaluation` 8 个文件与画廊 `original_code` 完全相同。
- 删除 Wiki 内重复 `source/`；`source.gallery_entry` 指向画廊原始层。
- `rwiki/code_assets.py` 的方法页也读取画廊 `original_code`（公开路径 `gallery/<entry>/original_code/...`）；新增方法专用测试。
- SCP 本地包、作者课题脚本等无画廊来源的归档保留。
- 实查：SHAP/回归代码抽屉只剩可复用版 + 画廊原始版，原始版可读/下载。

## 3. 命名治理（ID 全部冻结）

- 43 个页面改标题（17 模板、13 方法、17 layout 中的变更项），只改 frontmatter `title` 与 H1；ID/路径/spec/code 不动。
- 模板去掉 `图型 ·`、`单panel：`、项目名/GSE 号、来源/版本、`图表复刻`、`示例数据图型`；方法去掉“（SCP 源码本地化）”；layout 去掉“单panel：”和后缀。
- 生成器：
  - `rwiki/ingest.py`：layout 标题不再拼接 `post.title`，去掉“单panel：”前缀；`scenarios.free` 移入 `keywords`，不再混入受控 `tags`；facts 增加“关键词”行。
  - `rwiki/templates.py`：`scaffold_template` 新增 `--title`，不再拼 `chart_type · layout.title`。
  - `rwiki/cli.py`：`scaffold-template --title`。
- 规则：`知识库/AGENTS.md` 新增“页面命名（2026-10-22）”；`SKILL.md` 同步；五处安装已部署。
- 前端实查：SCP 8 张、青光眼 5 张卡片标题不再同名；模板/方法/来源页 API 标题为新名称。

## 4. SCP GroupHeatmap（第 8 个 SCP 模板）

- 画廊条目：`2026-10-22-scp-example/figures/fig08-group-heatmap`；来源为 `GroupHeatmap()` 原生 ht1（8×6@150）。
- 表半 `scp_group_heatmap_matrix()` 与原生 `ht1$matrix_list` `identical: TRUE`（13×5、13×8）。
- 绘图半 `plot_scp_group_heatmap()` 保留原生 ComplexHeatmap 构造，固定输出与 `ht1.png` 逐字节一致（SHA256 `00b0698d…`）。
- 新接口 `render-group-heatmap`（长表：matrix/feature/group/value/percent/顺序），含义已写。
- 模板 `2026-10-22-scp-example__fig08-group-heatmap--heatmap`：ready，读取长表；fixed/adaptive sizing；small/large 测试通过。
- 方法关系登记在 `scp-visualization-interface`（adaptable, example）。
- 未实现：`add_dot`、`add_violin`、`feature_split`/`row_split`、cell/feature annotation、enrichment 注释。

## 5. 验证

- `pytest`：**405 passed, 2 skipped**。
- `wiki.py lint`：**OK**。
- 部署：五处安装各 **270 files verified**，逐文件 SHA-256 核对。
- 线上 API：GroupHeatmap 模板 `status=ready`、`preview.kind=replay`；`preview.png` HTTP 200（59786 B）。
- `verify-template`：GroupHeatmap exit 0；5 个青光眼模板 exit 0。
- `check-entry --record`：17 模板 + 13 方法全部通过。

## 6. 剩余

- `sci-figure-replica` 独立画廊 index 仍以 `post.title` 作卡片标题；research-wiki 前端不受影响。若也要改，按该技能维护记录修改 `build_index.py` 并重建 index。
- 3 个 SHAP 历史模板仍为固定尺寸；页面已明确 legacy，未迁移 adaptive。
- GroupHeatmap 的 `add_dot`/`add_violin`/split/annotation 分支未实现。
- SCP 下一批：CellStatPlot bar/sankey/chord/venn/upset。
