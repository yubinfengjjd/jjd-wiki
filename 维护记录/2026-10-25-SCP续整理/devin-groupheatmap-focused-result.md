我先读取工作区结构和必读文件，了解当前状态后再更新 progress.md。继续读必读材料和历史资产。再读历史 heatmap 材料和现有 ht1 模板结构。先按要求更新 progress.md 记录新阶段，然后继续读源函数与既有模板。现在读既有 ht1 模板代码、接口页和 GroupHeatmap 源函数。继续读 GroupHeatmap 函数中部（cell_fun/add_dot 与 Heatmap 构造）。继续读 GroupHeatmap 尾段（各矩阵 Heatmap 构造、cell_fun、返回值）。源函数已读完。关键点：`layer_fun` 里 add_dot 用 `pindex(mat_perc_list[[cell_group]], i, j)` + `grid.points`；legend 是 `lgd[["point"]]`。现在读既有 ht1 模板的拆分代码。模板结构清楚了：`percent` 列已在接口和 `build_matrices` 中读取，`plot_scp_group_heatmap` 已有 `percent` 参数但未用。现在查 SCP-local 加载器和 staged 目录。本地有 SCP-local 副本（B/wiki/methods/scp-local-source）。读它的加载器与 PATCHES，确认能否用作原生参考加载器。确认本地 SCP-plot.R 与固定源的差异仅是已记录补丁。本地 SCP-plot.R 与固定源只差已记录的命名空间补丁，GroupHeatmap 本体未动，可作参考加载器。接下来看 fig08 画廊条目元数据、sci-figure-replica 的 init_entry 工具与本批 wiki.py 配置。scaffold-template 要求 layout 为 `pending_template`（作者签核后才到），所以确实是作者门。现在看 fig08 画廊的 replica.R 与 original_code，确认原生参考图是怎么导出的。查旧工作区 fig08 的原生参考是怎么导出的，保证 same device。看 init_entry/dedupe 的实现细节与 fig08 画廊条目 data 目录。看 ht1 模板的 sizing.R 与 verify.json，弄清 fixed/adaptive 判定。结构清楚了。建任务清单并开始执行。所有必需 helper 定位完成。现在写原生捕获脚本。写原生捕获脚本。改为直接 dot-source scp-runtime.ps1 再启动 R。`saveRDS(ht_dot)` 对含环境引用的 plot 对象递归过深。改为先导出图，RDS 只存纯数据内部量。捕获成功。检查产物与哈希。清掉第一轮失败残留的半截 native-dot.rds，然后开始写候选模块。不删了，先确认它是什么状态再留记录。开始搭候选模块。先复制已验证的 helpers/sizing/palette 资源（与 ht1 同字节），再写点阵核心。写点阵核心模块（在 ht1 拆分基础上只加原生 add_dot/add_reticle 区块）。补 panel.R/core.R/render.R/spec.json/example/runtime 与 prepare 层文件。复制 prepare 层文件（表半，仅捕获/对照用，不进 render 闭包）。先在候选目录跑 render 并与原生 PNG 对哈希。`figure.png` 与原生输出**逐字节一致**（7CC121E7…）。继续：reticle 分支、2 矩阵分支、数值 identical 校验。三个 FAIL 要查：percent 一致但 value 矩阵不一致（PNG 却字节相同）——先看是属性差异还是精度差异；gTree 检查层级写错了。两处差异：①捕获矩阵带 `scaled:center/scale` 残留属性（`scale()` 副产品，渲染不用，属预期）；②CSV 只写 15 位有效数字，误差 4.7e-15。PNG 字节一致说明渲染无影响，但"数值 identical"是硬性要求——把 CSV 精度提到 17 位有效数字重写。改 capture 脚本：CSV 的 value/percent 用 17 位有效数字，保证 round-trip 后 `identical()`。然后重跑。18/18 通过。继续渲染对照：reticle 分支与双矩阵分支对原生 PNG 哈希。2m 目录里文件名不对（接口名应为 `render-group-heatmap.csv`）。放到独立数据目录重跑。三个分支 PNG 全部逐字节一致。下一步：合法变体表测试——长标签、显式顺序变更、特征数变化、显式尺寸/adaptive。变体渲染成功。程序化确认显式顺序真的生效（不靠目检）。cat 输出被吞了，改成写文件再读。顺序与规模校验全部正确（Endocrine 转到首列、特征反转、6×3 合法规模）。写 runtime.json 后做异目录独立性验证。先看 ht1 的 runtime.json 结构。异目录独立性验证：只复制 runtime.json 声明的文件到无关目录，新进程渲染，不提供 SCP/Seurat/Wiki 源路径。异目录新进程 PNG 同样逐字节一致。写回执（含全部清单文件哈希）与对比说明。SVG 也逐字节一致；PDF 因 cairo 时间戳不同（预期）。看 ht1 验证收据格式，写同款。写回执前先取接口文件哈希与时间戳。补两个占位值：example/style.json 哈希与执行时间戳。写 README 与 comparison.md，然后建画廊条目。画廊条目：先查 id 冲突与 init_entry 用法。看 init_entry.py 如何处理 --source 与产出目录结构。init_entry 会建 `draft` 条目，source 必须是 PNG——用本次实跑的 `native-dot.png`。确认 post meta 存在后建条目。条目已建（draft）。按 fig08 的布局填充 replica 资产。先看 fig08 的 qa_report/README/provenance 格式。填充 fig17 条目资产（沿用 fig08 布局）。先复制代码与数据、生成 spec/provenance。写 figure_spec.json、qa_report、README、run.log；生成 side_by_side 与 thumb。更新条目 meta.json 的 files 映射（不动 status/id/scenarios）。画廊条目完成。现在跑隔离 wiki.py ingest-figure，生成 pending_signoff 版式页。缺 `figure.panel_map`。补进 meta 后重跑。版式页生成，`status: pending_signoff` —— 正停在作者签核门。跑 lint 与 check-entry 验证无污染。lint 干净（仅剩既有 not_run WARN，与本次无关）。check-entry 新条目。填充 fig17 版式页三节（沿用 fig08 写法，保守表述候选关系）。写三份报告与进度更新。先看现有 progress.md 结构与残留 native-dot.rds 的处置记录。更新 progress.md 阶段状态。核对既有条目未被改动、接口页措辞是否需要澄清。接口页措辞实际已正确（联合键、`percent` 0–1 语义都在正文），无需改。fig08 spec 哈希与既有收据一致，未动。收尾更新任务清单。阶段完成，停在作者签核门。交付摘要：

## 结果

原生 `GroupHeatmap(add_dot=TRUE)` 点阵分支已拆分并验证完毕。**绘图层与原生输出三分支逐字节一致**：

| 用例 | PNG sha256 | 一致 |
|---|---|---|
| CellType 12×5 add_dot | `7CC121E7…` | ✅ PNG+SVG 均字节相同 |
| + reticle | `AC5B96AE…` | ✅ |
| CellType+SubCellType 12×5+12×8 | `CE44217C…` | ✅ PNG+SVG |

数值层：CSV→矩阵 vs 帧捕获 `mat_list`/`mat_perc_list` `identical()`（18/18 PASS，含 8 个显式拒绝分支）；prepare 半 `scp_group_heatmap_matrix()` 与捕获 identical。独立性：异目录清单复制 + 新进程、无 SCP/Wiki 路径 → 字节相同（`runtime-portability.json` passed）。CSV 已改 17 位有效数字保证 round-trip identical。

## 落点

- 候选模板：`candidates/group-heatmap-dot/`（code/spec/example/runtime/verify/README）
- 画廊：`gallery/…/fig17-group-heatmap-dot`（draft，资产齐：source/original_code/code/data/output/compare/thumb/qa）
- Wiki：`layouts/2026-10-22-scp-example__fig17-group-heatmap-dot.md` — **pending_signoff**，check-entry passed，lint 无新增问题
- 报告：`result.md`、`groupheatmap-verification-matrix.md`、`source-map.md`、更新后 `progress.md`

## 如实边界

- PDF 因 cairo 时间戳不可逐字节比；**人工目检未做**（字节一致已证像素/矢量等价，视觉确认留给你/Codex）
- 不支持分支显式拒绝：add_violin、flip、split.by、feature_split、annotation
- 残留 `native-dot.rds`（首轮失败半截文件）未删——删除被工具门拒绝，已留档说明，无产物引用
- fig08/ht1 模板、DE、NMF 等均未触碰

## 作者门

`scaffold-template` 要求来源版式先签核 → 正式 `templates/` 页未建，候选资产齐备待签核后组装。需要你：① 签核 fig17 版式；② 人工目检（`compare/side_by_side.png`、`overlay.png` 已生成）。