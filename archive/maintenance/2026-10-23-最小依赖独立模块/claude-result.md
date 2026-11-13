# Claude 实施结果（待 Codex 审查）

日期：2026-10-23。单 Claude Code 会话实施；未启动子代理、未调用 Codex 编码、未安装依赖、未读/调用 `E:/paper-harness`、未部署、未重启正式 8765、未提交开发仓库。

## 完成范围

- 12 个分析家族从 `load_scp_engine(bundle)` 整库加载改为最小调用闭包；8 个家族共 9 个分支在异目录、新进程、不提供 SCP-local 路径下真实通过，并与保留的完整 bundle 参考逐值一致。
- 6 个通过分支另做合法规模/细胞名变化（60/100/150 细胞、重命名），全部通过且输入未变；不与默认参考逐值比较。
- 7 个分支保持精确 `not_run`：scDblFinder、harmony、SingleR、RunSeuratMap 投影、scVelo、Monocle2、Monocle3。未安装包、未创建 Python 环境。
- Monocle2/3 从固定版本 SCP 原函数 `RunMonocle2`/`RunMonocle3` 提取到既有 `trajectory-inference` 家族，未新写算法；缺包只做静态闭包与精确门禁。
- 16 个 SCP 单 panel 模板逐模板审计：全部在异目录、新 R 进程、无 SCP 路径渲染成功；16/16 PNG 与既有回放逐像素一致（MAD=0）。模板代码、spec、layout、尺寸、单 panel 与作者 ready 未改。
- 真实 CLI：`wiki.py render` 跑通 SCP volcano 与 Python SHAP 模板；bar 模板用显式 bindings 把 `group` 映射到作者列 `cell_type`，输出与标准输入 MAD=0，源表未改。
- 新增 `runtime.json`（12 方法、16 模板）与独立性证据；新增 `rwiki/runtime_contract.py`，后端 API、lint、check-entry、代码查看器与前端共用同一事实。
- 前端方法表、模板详情、代码查看器显示运行方式/独立性/必要依赖；复制清单与可选依赖折叠。`npm test` 24 通过、typecheck/build 通过。
- 正式/staged AGENTS、SKILL、references 同步；新增 `references/minimal-runtime.md`；八步流程第 5/6/8 步加入闭包、异目录与新进程验证。
- 知识库已 `save` 提交；旧算法收据、旧 `analysis.R`、source/original_code、原图、作者 user/status/favorite/旧 id 全部保留。

## 关键结果

| 项目 | 数量/状态 |
|---|---|
| 分析家族改为独立闭包 | 12/12 |
| 独立迁移 + 算法通过的分支 | 9 |
| 精确 not_run 分支 | 7 |
| SCP 模板隔离渲染通过 | 16/16 |
| 模板 PNG 与既有回放逐像素一致 | 16/16 |
| runtime 清单 | 12 方法 + 16 模板 |
| 后端全套测试 | 513 passed / 2 skipped，exit 0（review2 修复后） |
| 后端定向测试 | 120 passed / 2 skipped |
| 新增 runtime 合约测试 | 17 passed |
| 前端测试/typecheck/build | 24 passed / exit 0 / exit 0 |
| 正式库 lint | 0 ERROR；WARN 仅为预期 not_run 与既有项 |
| 完整性 | 962 source 文件哈希不变；123 页作者/状态/id 不变 |

## 兼容性改动（均已记录在 runtime.json source.modifications）

1. `check_R`/`check_Python` 改为 fail-only：缺包报精确错误，不自动安装。
2. SeuratObject >= 5：`GetAssayData(slot=)` → `layer`；`Assays(object, assay)` 恢复取单个 Assay 的旧行为。只改参数名，不改值/默认。
3. `SCP::palette_list` → 本地 `palette_list`，palette 数据随模块复制并记录 SHA-256。
4. 编译版 `asMatrix` 未复制：上游 `as_matrix` 用 `inherits(matrix, "dgCMatrix")`（对函数符号判断），该分支不可达；`as_matrix` 本身保留原样。
5. Slingshot/velocity 的绘图辅助函数仍在闭包内，但绘图包只在 `show_plot` 请求时检查/加载。

## 证据位置

- 逐实现/逐模板依赖：`dependency-inventory.md` / `.json`
- 验证矩阵：`verification-matrix.md`
- 全套 pytest：`pytest-full.log`、`pytest-full-final.log`
- 模板隔离证据：`portability/templates-evidence.json`、`portability/templates/<id>/`
- 方法隔离运行：`portability/<method>/result.rds`、`result.json`
- 与完整 bundle 对照：`reference/<method>.rds`、`scripts/compare_results.R`
- 浏览器：`browser/*.html`、`browser/*.png`
- 完整性：`integrity-after.json`
- 首次失败证据：`claude-stream.jsonl`、`claude-stderr.log`、`claude-exit.txt`

## 未完成 / 开放项

1. 7 个缺依赖分支未运行；`pending --json` 仍列 3 个无 verified 实现的分析家族（cell-type-annotation、doublet-detection、rna-velocity），属预期，不通过改状态清零。
2. Slingshot `show_plot=TRUE` 在当前 ggplot2/patchwork 版本下报 `grobs must be ... not a list matrix`；原始完整 bundle 在同环境同样失败，未改上游绘图代码。
3. 浏览器验证为 headless Chrome 执行 JS + DOM/截图，不是人工点击。
4. 未部署五处安装、未重启正式 8765；等待 Codex 审查。
5. 开发仓库保留既有 dirty tree，本轮未提交；知识库已按 `save` 提交。

## 请 Codex 重点审查

- `runtime_contract.py` 的路径/重复/哈希/状态派生是否有绕过口。
- 方法闭包是否真的没有隐式读取 SCP-local、Wiki 路径或全局 options/search path。
- SeuratObject 兼容 shim 是否只改 API 参数、不改变算法值。
- 模板 runtime 证据与既有 `verify/verify.json` 是否绑定同一代码/spec/example。
- 前端是否把 `declared`/`not_run` 误显示成“独立已验证”。

## 首轮审查修复（review round 1）

已逐项处理 E1–E4、R1–R6，矩阵与证据见 `review1-fix-matrix.md`。要点：

- E1/E2/E3：入口私有闭包、最内层 `ofile`、search/options 恢复；QC→scoring 同环境覆盖、全部 20 入口同环境、nested driver、异常路径、用户已 attach 包、batch 多包场景均通过。
- R1/R2/R3：resources 入闭包并核 sha256；页面 entrypoint 与清单 entry/entry_function 交叉绑定；malformed 清单返回具体 issue，API 200。
- E4/R4：Monocle2/3 拆为分析核心、Seurat 适配、可选绘图；核心无 Seurat/绘图/交互，root/use_partition 显式；清单按分支列真实包，缺包 not_run。
- R5：前端单一依赖事实、长入口/范围折叠、默认复用代码；CDP 真实点击验证。
- R6：收据命令/case/输入输出哈希来自实际运行；算法 passed 仅由 `comparison.json` 派生；删除硬编码算法表；batch 交替批次失败已用原版/新模块同错调查并保留。

旧 507 passed、旧收据与旧报告保留为历史，不作为本轮审查通过依据。仍待 Codex 复核 Monocle 静态核心、私有闭包组合用法、comparison 约束和前端真实行为。

## 第二轮审查修复（C1–C5，2026-10-24）

详见 `review2-fix-matrix.md`。

- C1：Monocle2 第一次 `orderCells(cds)` 按原版无根状态产生 State，第二次才显式 `root_state`；删除必填 `initial_root_state`。Monocle3 要求已有且顺序一致的 `reduced_dim`。静态 contract 3 PASS，真实算法仍缺包 not_run。
- C2：Monocle plot 辅助从 analysis implementations/runtime/收据移除，仅留维护快照；不新造图样，16 模板未动。
- C3：Python 必需包进入统一 `required_packages`（scanpy/numpy/scvelo），删除独立 python 字段；前端显示 R/Python 归属。
- C4：清单 issues 在方法分支、模板详情、代码查看器显示，API 不 500。
- C5：ORA 真实输入不变、执行副本 code hash 与正式 code 对齐、模板实际命令/目录/时间/哈希、batch 限制表述修正。

未解决：monocle/monocle3/scDblFinder/harmony/SingleR/scVelo 仍缺；Monocle 初步排序与真实算法未运行；RunSeuratMap/Slingshot plot 上游错误仍 not_run；未部署、未提交开发仓库。
