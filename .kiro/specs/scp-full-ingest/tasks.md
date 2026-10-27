# Implementation Plan: scp-full-ingest

> **状态：暂停（2026-10-27，作者决定 1=a）。** v2 精简规则已落地（见 文档/v2精简与FigureYa入库/计划.md）。剩余任务不再按本文件的旧门禁（八步逐条确认、Issue/PR/他人评审、写入锁、只经画廊）推进，待按 v2 规则（来源登记 → L0/L1 批次 → 用到再做 L2）重排后另行执行。已入库的 SCP 模板与方法保留 id 与证据。


## Overview

按设计阶段 S0–S14 执行。代码语言：Python（隔离区脚本、测试驱动、合入与核验工具）与 R（模块加载层模板、原生材料用例、模板绘图代码）。顺序按风险递增：

1. S0 接续核对，在任何写入 A/B 之前完成。
2. S1–S3 在隔离区修加载层、Case_Runner 与文档示例；只在临时构建上测试，不覆盖 B 的正式模块目录。
3. S4 宣布 Code_Freeze；S5 只重建一次、只整合一次；S6 全量收据重跑。
4. S7–S10 去向表、结构清单、原生材料与隔离彩排（全部在 B、B 画廊、隔离 Wiki_Server 8882 上）。
5. S11 受控合入正式库（标【写正式库】），S12 官方验收命令，S13 API 与浏览器核验，S14 交付报告。

路径约定：

- `<B>` = `E:/research-wiki-env/work/scp-full-ingest-20261025`（Isolation_Workspace）
- `<A>` = `E:/research-wiki/维护记录/2026-10-25-SCP全库入库`（Maintenance_Record，只追加新时间戳文件）
- `<W>` = `E:/research-wiki/知识库`（Formal_Wiki）；`<G>` = `E:/research-wiki/画廊`（正式画廊）
- `<SRC>` = `E:/research-wiki-env/sources/scp-2026-10-22`（Fixed_Source，只读）
- `<skill>` = `E:/research-wiki/开发/staged/research-wiki`（正式开发代码，只读）
- `<sfr>` = `C:/Users/86186/.codex/skills/sci-figure-replica`（官方画廊脚本，只调用不修改）
- `<tmp>` = `E:/research-wiki-env/tmp`；`<stamp>` = UTC `YYYYMMDDTHHMMSS`

执行约束（每个任务都适用）：

- 不安装、下载或升级任何 R/Python 依赖（需求 13.8）。缺包即记精确 not_run。
- 临时文件只写 `<tmp>/kiro-scp-*`；不写 C 盘 memory；不读取、调用或引用 `E:/paper-harness`（需求 13.9）。
- Wiki_CLI 用 `C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8`；通用脚本用 `D:/anaconda/python.exe -X utf8`（有 psutil、websocket-client）；不用 PATH 上的商店 Python 占位程序。运行 Wiki_CLI 前把 `TEMP`、`TMP`、`MPLCONFIGDIR` 设到 `<tmp>` 下（需求 16.1、16.3）。
- R 验证一律先 source `E:/research-wiki-env/work/scp-runtime.ps1`，再 `D:/R-4.5.0/bin/x64/Rscript.exe --vanilla`，`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，清空 `LANG`/`LC_*`；成败以脚本捕获的真实错误判定，不以退出码 0 判定（需求 16.2、16.4）。
- 只经官方 Wiki_CLI 或 Wiki_Server API 改 frontmatter `status`；不放宽 validator、lint、check-entry；不改 `<!-- user:start/end -->` 作者区块。
- 性质测试不装 hypothesis：组合性质用标准库 `random.Random(seed)` 固定种子生成，每条 ≥ 100 次迭代（第 i 次用 `20261026 + i`），失败信息含 seed 与输入摘要；有限对象全集穷举检查。每个性质测试函数 docstring 标注 `Feature: scp-full-ingest, Property <n>: <标题>`。测试放 `<B>/scripts/tests/`，R 用例脚本放 `<B>/scripts/tests/r/`。
- 标【后台】的任务预计超过单命令 1800 秒上限：用后台进程启动，每用例 600 秒超时并终止整个进程树，进度写 `progress.json`，可从未完成项续跑，已完成且代码哈希一致的项跳过；前台只轮询进度。

## Tasks

- [x] 1. S0 接续核对（在任何写入 A/B 之前）
  - [x] 1.1 编写并运行接续核对器
    - 先只在 `<tmp>/kiro-scp-s0/kiro_takeover_check.py` 编写脚本（此时不写 A/B）：纯函数 `find_blockers(procs, b_path)`（psutil 枚举全部进程，命令行含 `devin`、`cuddly-custard`、`devin_acp_client.py`、`run-family-cases.py`、`run-iso-case.py`，或 `Rscript` 且 cwd/参数含 `<B>`；输出 pid、ppid、完整命令行、创建时间）与 `update_task_state(state, now)`（追加 `{"owner": "Kiro_Implementer", "since": <UTC>}`，保留原 `sessions` 全部记录）
    - 以 `--check-only` 运行；发现匹配进程即退出码 2，停止，向作者报告 pid 与命令行，不写 A/B
    - 通过后：把脚本复制到 `<B>/scripts/kiro_takeover_check.py`；更新 `<A>/task-state.json` 编码负责人；采集 `<B>/coverage/modules/**`、`<B>/wiki/methods/**/code/**`、`<B>/scripts/**` 与 A 关键文件的 sha256 快照
    - 完成判据：`<A>/kiro-s0-takeover-<stamp>.json`（核对结果、命令行原文、哈希快照、task-state 前后 diff）
    - _Requirements: 1.1, 1.2, 1.3_
  - [ ]* 1.2 属性测试：接续核对的阻断与保留
    - **Property 20: 接续核对的阻断与保留**
    - 文件 `<B>/scripts/tests/test_takeover.py`；`random.Random(seed)` 生成进程列表（混入匹配/不匹配命令行、指向/不指向 `<B>`）与既有 task-state，断言阻断当且仅当存在匹配且指向 B 的进程，更新后旧 sessions 全部保留
    - **Validates: Requirements 1.2, 1.3**
  - [x] 1.3 未闭合项清单与可复用证据登记
    - 读 `<A>/codex-independent-checkpoint-20261026T0830.md`、`<A>/codex-finalize10-live-review.md`、`<B>/codex-finalize10-handoff.md`，逐条列未闭合项并映射到本清单任务号
    - 写 `<B>/scripts/kiro_reuse_candidates.py`：对上一轮已通过证据（收据、Native_Oracle、3D 浏览器检查、视觉/模块探针）比较其绑定的代码、清单、输入哈希与当前文件，一致者登记为可复用，不一致者登记为需重验
    - 完成判据：`<A>/kiro-s0-open-items-<stamp>.json`、`<A>/kiro-s0-reuse-candidates-<stamp>.json`
    - _Requirements: 1.4, 9.1, 9.5_

- [ ] 2. S1 加载层修复（只在 `<tmp>/kiro-scp-s1-build/` 临时构建上测试，不覆盖 `<B>/coverage/modules`）
  - [x] 2.1 受控解析链（C2.1）
    - 修改 `<B>/scripts/assemble-modules3.py`：组装时对每个模块全部函数体运行 `codetools::findGlobals(fun, merge = FALSE)`，按 NAMESPACE 导入（`coverage/ns-sym2pkg.json`）> 标准包导出（`coverage/std-pkg-exports.json`）> 模块内定义（不绑定）> 其余（写 `coverage/symbol-residual.json`）生成 `.lazy_sym(pkg, sym)`；NAMESPACE 同名绑定优先
    - 保持 `imports` 父环境为 `baseenv()`、最内层 `ofile` 定位、源算法函数体字节不变；新增 `--out <dir>` 参数，S1 只输出到临时构建目录
    - _Requirements: 4.1, 4.2, 4.3, 4.5_
  - [x] 2.2 search 恢复（C2.2）
    - 修改 `assemble-modules3.py` 的 `MODULE_R` on.exit：每轮只 detach `setdiff(search(), .s0)`，依赖逆序重试至清空或一轮无进展；结束后写 `env$.scp_search_restored` 与 `env$.scp_detach_residual`；不 `unloadNamespace`
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  - [x] 2.3 options 分类恢复（C2.3）
    - 在 `MODULE_R` 中新增 `.scp_load_ns(pkg)`，替换 `.lazy_sym`、`.scp_ensure`、`.import_pkg`、`.check_R_guard` 的 namespace 加载点；on.exit 按设计表分 `options_existing_restored`、`options_ns_init_kept`（含 `datatable.`→`data.table` 前缀表）、`options_algorithm_removed`、`options_unrestored` 四类处理并写诊断，空类写空数组而非 `"none"`
    - _Requirements: 5.5, 5.6, 5.7, 5.8, 5.9_
  - [ ]* 2.4 属性测试：全局遮蔽不改变结果【后台】
    - **Property 4: 全局遮蔽不改变结果**
    - 文件 `<B>/scripts/tests/test_loader_shadow.py` + `r/loader_shadow_case.R`；按 seed 从模块自由符号中取子集，在 `globalenv()` 注入类型不同的同名对象（含 `matrix` 为 dgCMatrix），每次迭代新 Rscript 进程，与无注入结果比较；断言 `imports` 父环境为 `baseenv()`
    - **Validates: Requirements 4.3, 4.4**
  - [ ]* 2.5 属性测试：加载方式与顺序的汇合性【后台】
    - **Property 5: 加载方式与顺序的汇合性**
    - 文件 `test_loader_order.py` + `r/loader_order_case.R`；按 seed 生成模块子集、加载顺序与方式（顶层 `source`、`source(local=env)`、嵌套 driver），断言新增名字恰为入口名且结果与单独加载一致
    - **Validates: Requirements 4.1, 4.6**
  - [ ]* 2.6 属性测试：模块目录按最内层 ofile 定位【后台】
    - **Property 6: 模块目录按最内层 ofile 定位**
    - 同文件 `test_loader_order.py` 中独立测试函数；按 seed 生成嵌套深度与目录布局（模块目录、driver 目录、工作目录互不相同）
    - **Validates: Requirements 4.2**
  - [ ]* 2.7 属性测试：search 路径恢复【后台】
    - **Property 7: search 路径恢复**
    - 文件 `test_loader_restore.py` + `r/loader_restore_case.R`；按 seed 生成预先 attach 的包集合与成功/抛错调用；含 MDS/NMF 调用后无 `package:generics` 的示例
    - **Validates: Requirements 5.1, 5.2, 5.3**
  - [ ]* 2.8 属性测试：options 分类恢复【后台】
    - **Property 8: options 分类恢复**
    - 同文件 `test_loader_restore.py` 中独立测试函数；按 seed 生成预置 options 与算法临时选项；断言四类两两不相交、并集等于变化集合；含 3D 调用后外部 `plotly_build` 与 HTML 保存成功的示例
    - **Validates: Requirements 5.5, 5.6, 5.8, 5.9**
  - [x] 2.9 五入口新进程回归（C2.4，S1 退出判据）
    - 编写 `<B>/scripts/kiro_s1_regression.py`：在临时构建上新进程运行公开 MDS、NMF（`nmf.method="NMF"`）、GraphPlot straight/curved、CellDimPlot3D、FeatureDimPlot3D，复用 `codex_module_probe.py`、`codex_visual_probe.py` 的比较逻辑在 B 内等价复现，与 Native_Oracle 比较；作者全局 `matrix` 遮蔽下 MDS 数值不变；记录输入调用前后未改
    - 完成判据：`<A>/kiro-s1-regression-<stamp>.json` 全部通过
    - _Requirements: 4.4, 4.7, 5.4, 5.7, 8.4_
  - [x] 2.10 Runtime_Manifest 生成规则
    - 修改 `assemble-modules3.py` 的 `runtime.json` 生成：分析核心/对象适配/可选绘图三层分别声明能力、依赖与验证范围；`required_packages` 只列该分支实际调用路径所需，`optional_packages` 写触发条件；GraphPlot 必要包为 ggplot2、grid、reshape2、rlang 且无 Seurat；每个 resource 同时列入 `files` 并给当前 sha256；`entry`/`entry_function` 与页面 `entrypoint` 一致；PrepareEnv、check_Python、check_R、conda_install 调用替换为只报缺包的守卫；无法拆闭包的分支标 `bundle`/`unknown` 并写阻塞原因
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.9_
  - [ ]* 2.11 属性测试：运行清单与源字节一致
    - **Property 12: 运行清单与源字节一致**
    - 文件 `test_manifests.py`；穷举临时构建（S5 后对正式构建重跑）全部 `runtime.json`：官方 `read_manifest` 无 issue、resource 哈希、entry 一致、无安装器原始调用、提炼函数体哈希等于原始AST 或在 `source.modifications` 有记录；含 GraphPlot 必要包示例
    - **Validates: Requirements 4.5, 6.1, 6.5, 6.6, 6.7**

- [ ] 3. S2 Case_Runner 真实性修复
  - [x] 3.1 收据判定纯函数（C3.1）
    - 在 `<B>/scripts/run-iso-case.py` 抽出 `derive_algorithm_state(raw, case, code_hash_before, code_hash_after)` 与 `is_evidence_key`（前缀白名单 `oracle_`、`baseline_`、`trace_`、`pixel_`、`svg_`、`assert_`，且须在 case `comparisons` 声明并有 `out/comparison.json`）；`returns_ggplot`、`plotly_build_ok`、`input_unchanged:*`、`search_restored`、`options_restored`、`binding_locked:*` 视为 hygiene；期望报错与原生失败用例写 `verification/<impl>-<case>-guard.json`；`declared_checks` 与 `checks` 分开；`run-family-cases.py` 改为调用同一函数
    - _Requirements: 7.1, 7.2, 7.3, 8.6_
  - [x]* 3.2 属性测试：算法收据状态只由比较产物授予
    - **Property 9: 算法收据状态只由比较产物授予**
    - 文件 `test_receipt_state.py`；按 seed 生成 raw 结果、checks 组合、case 声明与前后哈希
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.5**
  - [x] 3.3 哈希、命令与环境字段（C3.2）
    - 修改 `run-iso-case.py`：运行前后各采集家族 `code/` 全部源文件 sha256（`files_before`、`files`），不一致即 `invalid`；`command` 写完整可重放 pwsh 命令；写 `case.args`、`inputs`/`outputs` 路径与 sha256；`environment` 从 driver 内 `R.version.string`、`.libPaths()`、`R_LIBS_USER`、平台读取；子进程设 `R_LIBS_USER`、删 `LANG`/`LC_*`、`TEMP/TMP` 指 `<tmp>/kiro-scp-runs`；批次只新增收据文件，已存在文件拒绝覆盖
    - 修改 `<B>/scripts/replay-legacy.py`：Python 回放（SHAP、回归评价）的 `environment` 写实际 Python 版本
    - _Requirements: 7.4, 7.5, 7.6, 7.10, 9.6, 16.2, 16.3, 16.4_
  - [x] 3.4 收据选择器（C3.3）
    - 新建 `<B>/scripts/select-receipts.py`：按实现 id、`files` 与当前 `code/` 全量一致、`scope` 与实现声明范围一致筛选；优先最新 passed，否则最新 not_run，否则无指针；与 Code_Freeze 清单不一致的收据永不选中；NMF 只认 `nmf.method=NMF`，默认 RcppML 后端单独记缺包 not_run
    - _Requirements: 7.7, 7.8, 9.3_
  - [x]* 3.5 属性测试：收据选择的现行性
    - **Property 10: 收据选择的现行性**
    - 文件 `test_receipt_select.py`；按 seed 生成收据集合（不同 scope、时间、哈希、状态）与当前哈希；含 NMF 范围示例
    - **Validates: Requirements 7.7, 9.3**
  - [x] 3.6 Portability_Receipt 分离（C3.4）
    - 修改 `run-iso-case.py`/`run-family-cases.py` 的 `-port.json` 写出：异目录复制 + 新进程 + 不提供 `<SRC>` + 实际调用完成，并断言 `.libPaths()` 不含 `<SRC>`；与算法收据互不授予状态
    - _Requirements: 6.8, 7.9_
  - [ ]* 3.7 属性测试：收据完整且只追加
    - **Property 11: 收据完整且只追加**
    - 文件 `test_receipt_shape.py`；在夹具收据目录上按 seed 生成批次，断言字段完整与旧文件字节不变（S6 后对真实全集重跑，见 8.7）；含 Python 回放环境字段示例
    - **Validates: Requirements 7.4, 7.6, 8.4, 9.6**
  - [x] 3.8 case 文件补比较声明
    - 用 `<B>/scripts/update-cases-native.py` 为每个可运行分析/可视化 case 补 `comparisons`（对照对象为 Native_Oracle 或明确结果断言、容差及依据、比较产物路径），注明数据为软件夹具或真实示例子集；复用 Native_Oracle（MDS/NMF/2D/stat/correlation、GroupHeatmap 5 结构、CellDimPlot 4 圈选、Slingshot 3 lineage、50 细胞 SNN 图、3D、LargeVis、FR），不重新生成同一控制
    - _Requirements: 8.1, 8.4, 8.5, 8.8_

- [ ] 4. S3 文档示例修正
  - [x] 4.1 修正 CALLS 与页面正文（C4）
    - 修改 `<B>/scripts/fill-pages2.py` 的 `CALLS` 与相关页面正文：RunWOT 用 `group_by`（真实时间字段）替换 `time.by`；读 `<SRC>` 中 FindExpressedMarkers 函数体核实 `group_by` 经 `...` 转交语义后再写示例，判定依据写入页面"怎么做"；RunMonocle2 依赖写 `monocle`；已执行示例链接收据、未执行标"声明示例"；Assay5 页面写已验证范围为旧 Assay、Assay5 待适配；删除"见 data_contract"类占位；只写 NAMESPACE 真实导出名
    - 改写 `<B>/wiki/methods/scp-local-source.md` 正文判断（整库为历史归档、审计与原版对照用途；课题优先用规范家族 standalone 闭包；验证以分支收据为准；历史兼容说明保留并标"历史"）
    - 只改 SCP 相关页面，不向 SHAP 与回归评价页面加 SCP 内容
    - _Requirements: 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11_
  - [x] 4.2 示例审计
    - 对 `fill-pages2.py` 在 `<tmp>/kiro-scp-s3-pages/` 的干跑输出运行 `<A>/scripts/codex_doc_calls_audit.py`（R `parse` 版），输出新时间戳文件
    - 完成判据：`<A>/codex-doc-calls-<stamp>.json` 零违规，全部示例 `parse` 成功
    - _Requirements: 11.1, 11.2_
  - [ ]* 4.3 属性测试：文档示例可照抄
    - **Property 17: 文档示例可照抄**
    - 文件 `test_doc_examples.py`；穷举受影响页面全部 R 示例；含 RunWOT、monocle、scp-local-source 示例
    - **Validates: Requirements 11.1, 11.2, 11.6, 11.8, 11.11**

- [x] 5. Checkpoint - 加载层与收据判定
  - 运行 `<B>/scripts/tests` 全部已写测试（R 生成输入测试读取后台 progress 结果）与 2.9 回归；确认 S1–S3 退出判据证据齐全；确保全部通过，有疑问时询问用户。

- [x] 6. S4 Code_Freeze
  - [x] 6.1 冻结记录器与漂移检查器（C5）
    - 新建 `<B>/scripts/code-freeze.py`：输出 `{frozen_at, generator_sha256, modules, families, resources, runtime_manifests}` 全部 sha256
    - 新建 `<B>/scripts/kiro_freeze_check.py`：对比当前文件与冻结清单，列出变化文件与受影响收据（供 S6 起所有阶段调用，变化即把受影响收据视为 stale 并回到 S6 重验）
    - _Requirements: 9.2, 9.3_
  - [x] 6.2 宣布 Code_Freeze
    - 确认 5 的 Checkpoint 已通过后运行 `code-freeze.py`；在 `<A>/task-state.json` 追加冻结时点
    - 完成判据：`<A>/code-freeze-<stamp>.json`
    - _Requirements: 9.2_

- [x] 7. S5 一次性重建与整合
  - [x] 7.1 重建 79 模块并整合 Wiki（只执行一次）
    - 运行一次 `assemble-modules3.py`（输出 `<B>/coverage/modules`）与一次 `<B>/scripts/integrate-wiki2.py`；运行 `kiro_freeze_check.py` 确认重建产物哈希与冻结清单一致；若已写 2.11 测试，对正式构建重跑
    - 若不一致：不再次重建，定位差异来源并报告
    - 完成判据：`<A>/kiro-s5-rebuild-<stamp>.json`（命令、起止时间、哈希比对结果）
    - _Requirements: 9.2_

- [ ] 8. S6 全量收据重跑
  - [x] 8.1 批次运行器
    - 新建 `<B>/scripts/kiro_run_all_cases.py`：遍历全部分支 case，调用 `run-iso-case.py`；每用例 600 秒超时，psutil 终止进程树并记 `not_run`+`timeout`；进度写 `<B>/coverage/runs/<run>/progress.json`；`--resume` 跳过已完成且代码哈希与冻结清单一致的用例；每批开始前调用 `kiro_freeze_check.py`
    - _Requirements: 7.4, 7.5, 9.3_
  - [ ] 8.2 全量算法收据重跑【后台】
    - 用后台进程运行 `kiro_run_all_cases.py --resume`，前台轮询 progress；缺包分支写精确包名与原始错误，缺上游结果写缺少的具体对象或文件，原生失败写错误原文；保留全部旧收据与旧失败记录
    - 完成判据：每个分支一条现行收据（passed 或精确 not_run/invalid），`<A>/kiro-s6-receipts-<stamp>.json` 汇总
    - _Requirements: 7.1, 7.2, 8.1, 8.3, 8.6, 9.6, 15.1, 15.2, 15.3_
  - [ ] 8.3 独立迁移收据【后台】
    - 对每个已有算法 passed 的实现执行异目录复制 + 新进程 + 不提供 `<SRC>` 调用，写 `-port.json`
    - 完成判据：`<A>/kiro-s6-portability-<stamp>.json`
    - _Requirements: 6.8, 7.9_
  - [ ] 8.4 Legacy_Replay 重跑【后台】
    - 对冻结后代码运行 `replay-legacy.py`/`replay-portable.R`；代码未改且旧收据仍现行的分支（SHAP、回归评价）保留原收据不改
    - 完成判据：`<A>/kiro-s6-legacy-replay-<stamp>.json`
    - _Requirements: 9.4, 9.5, 7.10_
  - [x] 8.5 79 模块加载审计【后台】
    - 运行 `<A>/scripts/codex_module_load_audit.py`（source-only，确认 Fixed_Source 零副作用），输出新时间戳文件，可断点续跑
    - 完成判据：`<A>/codex-module-load-<stamp>.json` 79/79 有结果
    - _Requirements: 9.7_
  - [ ] 8.6 收据指针与官方状态快照
    - 用 `select-receipts.py` 更新 `<B>/wiki` 页面实现的收据指针；运行 `codex_method_state_audit.py isolated`；在页面中区分"历史 not_run""当前缺包""未探测"
    - 完成判据：`<A>/codex-method-states-isolated-<stamp>.json`
    - _Requirements: 7.7, 7.8, 15.3, 15.5_
  - [ ]* 8.7 属性测试：收据完整且只追加（真实全集）
    - **Property 11: 收据完整且只追加**
    - 在 `test_receipt_shape.py` 中加真实全集穷举模式：本轮全部收据字段完整；与 S0 快照比对，旧收据字节不变
    - **Validates: Requirements 7.4, 7.6, 8.4, 9.6**
  - [ ]* 8.8 属性测试：缺包原因精确
    - **Property 22: 缺包原因精确**
    - 在 `test_receipt_shape.py` 中独立测试函数；穷举缺包 not_run 收据，断言含精确包名与原始错误，且该包确实不在 `R_LIBS_USER` 与系统库（Python 包同理）
    - **Validates: Requirements 15.1**

- [ ] 9. Checkpoint - 收据重跑
  - 汇总 passed / not_run（按缺包、缺材料、超时、无比较分列）/ invalid 计数；确认 `kiro_freeze_check.py` 无漂移、79 模块加载审计完成；确保全部通过，有疑问时询问用户。

- [ ] 10. S7 去向表与知识编译
  - [ ] 10.1 去向表 v2 生成（C6）
    - 重写 `<B>/scripts/wiki-map.py` 输出部分：按 D1 schema 生成 `<B>/coverage/wiki-map.json` 与 `<B>/coverage/wiki-map.md`；官方状态从 Wiki_CLI `implementation_status` 读取；具名形态覆盖 `branches.json` 全部行；GeneConvert、PrepareDB 记为函数；`state_fact` 取受控值；counts 中代签核/模板化/ready 暂为 0，待 21.2 更新
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 15.4, 15.5_
  - [x] 10.2 去向表校验器
    - 新建 `<B>/scripts/validate-wiki-map.py`，机检 D1 字段约束表全部规则；悬空引用、空去向、"稍后整理"/"TODO" 类占位一律报错
    - 完成判据：对 10.1 输出零错误，结果写 `<A>/kiro-s7-wiki-map-check-<stamp>.json`
    - _Requirements: 2.10_
  - [ ]* 10.3 属性测试：去向表结构完整
    - **Property 1: 去向表结构完整**
    - 文件 `test_wiki_map.py`；真实去向表穷举 + 按 seed 单字段变异（删除、置空、占位、悬空引用）断言校验器拒绝；含 GeneConvert/PrepareDB 示例
    - **Validates: Requirements 2.1, 2.2, 2.4, 2.5, 2.6, 2.8, 2.10, 15.4, 15.5**
  - [ ]* 10.4 属性测试：去向表状态等于官方派生值
    - **Property 2: 去向表状态等于官方派生值**
    - 同文件独立测试函数；穷举全部带实现记录，对照官方 `implementation_status`，断言分支状态只来自自身收据
    - **Validates: Requirements 2.3, 15.3**
  - [ ] 10.5 家族归属与对照表
    - 在 `<B>/wiki/methods/*.md` 正文写每个分析类 Module 的归属判定依据（研究问题、输入语义、行/样本单位、估计目标、算法假设）；保留 PAGA/Palantir/WOT→trajectory-inference（WOT 注明真实时间输运边界）、Integration_SCP→workflow、Count-recovery 独立 draft、RunFR 图布局、LargeVis R uwot；旧 SCP 实现页保留旧 ID、`source/` 与作者备注并链接规范家族；`purposes`/`tags` 只用 `rwiki/method_taxonomy.py` 词表；多后端家族逐后端登记实现与状态；纯绘图与辅助函数移出 `implementations`；新家族仅在出现新分析目的时提议并写差异
    - 完成判据：`<A>/kiro-family-map-<stamp>.md`（旧页/来源 → 规范家族 → 具体实现 → 原始来源，覆盖全部受影响页面）；对 `<B>/wiki` 运行 `codex_impl_identity_audit.py` 与 `codex_doc_calls_audit.py` 新时间戳输出零违规
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_
  - [ ]* 10.6 属性测试：分析家族实现边界
    - **Property 19: 分析家族实现边界**
    - 文件 `test_family_boundary.py`；穷举 `method_kind=analysis` 页面
    - **Validates: Requirements 3.3, 3.8**

- [x] 11. S8 可视化结构去重清单
  - [x] 11.1 生成并逐项判定结构清单（C7）
    - 新建 `<B>/scripts/build-visual-structures.py`：从 `exports.json` 的 22 个 visualization 入口、`branches.json` 具名形态与源码结构性参数生成初稿；逐项读 `<SRC>` 源码，与 17 个 SCP 模板及正式库其他 ready 模板比较视觉编码与附属结构，填写 `dedupe`（new/reuse/param_of 及差异）、`batch`（v1-heatmap … v8-3d）、预分配 `fig18+` 条目 id、`chart_type`、`interface`；3D 两项填 `interactive`；CellDimPlot lineage 叠加标原生失败
    - 完成判据：`<B>/coverage/visual-structures.json` 与人读版 `<A>/kiro-visual-structures-<stamp>.md`（确数与每项判定依据）
    - _Requirements: 10.1, 10.9_
  - [x] 11.2 结构清单校验器
    - 新建 `<B>/scripts/validate-visual-structures.py`：按 D2 状态取值与性质 13 的不变量机检；支持读取 `<B>/coverage/visual-batches/*.json` 批次状态
    - _Requirements: 10.1, 10.3, 10.5, 10.8_

- [ ] 12. S9 原生材料与流水线工具
  - [ ] 12.1 原生材料生成框架（C8）
    - 新建 `<B>/scripts/native-visual-oracles.R`（框架）与 `<B>/scripts/native-cases/`（每批一个 case 文件）：每 case 新进程调用原生函数，保存 PNG/SVG（或 HTML+依赖目录），同时导出模板接口 CSV（同输入同参数下原生函数内部使用的数据），写 `references.json`（参数、尺寸 8×6 in、150 dpi、种子 11、输入/输出 sha256、对象未改断言、错误原文）；原生失败写 `state=reference_failed`，不重画；输出到 `E:/research-wiki-env/work/kiro-scp-native/<batch>/`
    - _Requirements: 8.2, 8.4, 8.6, 10.5, 10.12_
  - [x] 12.2 画廊条目构建器（C9）
    - 新建 `<B>/scripts/build-gallery-entry.py`：依次调用 `<sfr>/scripts/dedupe.py --dry-run`、`init_entry.py`（来源必须为 PNG）、填 `meta.json`（`panel_map` 恰好一项、chart_types、scenarios、provenance、files）、`original_code/`（源函数片段原字节 + `provenance.json`）、`data/<interface>.csv`、`output/replica.*`、`make_compare.py`、`qa_check.py`、README/qa_report 写软件夹具声明；状态写 `review`；最后 `build_index.py`；`--gallery` 参数切换 B 画廊或正式画廊
    - _Requirements: 10.2, 10.10, 10.11_
  - [x] 12.3 原生对照工具
    - 新建 `<B>/scripts/compare-native.py`：栅格逐像素（同尺寸；确定原因时允许写明容差与依据，且须同时通过 SVG 结构比较）、SVG 元素类型计数/文本节点集合/路径数、plotly trace 的 x/y/z/type/mode/name/text/marker 全等 + 外部 `plotly_build` 与 HTML 保存；输出 `verify/native-comparison.json`
    - _Requirements: 8.2, 8.3, 10.7_
  - [x] 12.4 代签核与模板化执行器（C10）
    - 新建 `<B>/scripts/delegated-template-pipeline.py`，子命令 `ingest`、`signoff`、`scaffold`、`verify`、`ready`：签核前置检查（`native.state=generated` 且证据 sha256 与清单一致；只接受清单内 `2026-10-22-scp-example__fig18+` 条目，R10）；签核经 `POST /api/layouts/<id>/signoff`（端口参数化：彩排 8882、正式 8765）；审计写 `--audit <jsonl>`（D3 字段）、页面 `## 代签核记录` 节（agent 正文区）与 `save` 提交消息，不调用 `/note`；`ready` 先 `check-entry` 再 `mark-ready`；未过写 `action=not_ready`；`verify` 前设 `R_LIBS_USER`、清空 `LANG/LC_*`；批次状态写 `<B>/coverage/visual-batches/<batch>.json`
    - _Requirements: 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 12.4_
  - [x] 12.5 浏览器检查工具
    - 新建 `<B>/scripts/kiro_browser_check.py`：用本机 Edge/Chrome 无头模式 + 远程调试协议（D:/anaconda 的 websocket-client，不安装新包）打开本机 URL 或本地 HTML，固定窗口尺寸与默认相机截图；对 plotly 图执行图例项点击隐藏/再点击恢复并读取 trace `visible` 状态；输出 JSON 证据与截图路径
    - _Requirements: 8.7, 10.13, 14.3_
  - [ ] 12.6 隔离彩排环境
    - 用 psutil 核对是否已有 `<B>` 配置的 Wiki_Server（8882）实例，复用或按 B 配置启动；确认 B 画廊根与 `config.json` 指向 B；记录进程命令行；彩排结束（21 之后）停止
    - 完成判据：`<A>/kiro-s10-rehearsal-env-<stamp>.json`
    - _Requirements: 14.1, 14.8_
  - [x]* 12.7 流水线守卫单元测试
    - 文件 `test_pipeline_guards.py`：`reference_failed` 结构被拒签；非 fig18+ 或清单外条目被拒；审计记录字段完整且 sha256 与文件一致；页面代签核节位于作者区块之外且作者区块字节不变；3D 结构 `ready` 子命令被拒
    - _Requirements: 10.3, 10.4, 10.5, 10.8_

- [ ] 13. S10 彩排 V1：热图批次（GroupHeatmap 4 结构：add_violin、flip、split.by 分列、细胞注释条；FeatureHeatmap 按 S8 判定 0–1） （2026-10-27 需求 17 修订：不再新做 CSV 模板；本批仅保留已完成成果，其余形态改由 28.x 逐形态验证）
  - [ ] 13.1 原生材料
    - 写 `<B>/scripts/native-cases/v1-heatmap.R`：GroupHeatmap 4 结构复用已有原生输出（核对 sha256，导出接口 CSV）；FeatureHeatmap 若判为 new 则生成；fig17 资产只读
    - 完成判据：`kiro-scp-native/v1-heatmap/references.json`、`<B>/coverage/visual-batches/v1-heatmap.json`
    - _Requirements: 8.2, 8.5, 10.2, 10.9_
  - [ ] 13.2 画廊条目与 ingest
    - 对本批 new 结构运行 `build-gallery-entry.py --gallery <B>/gallery` 与 `delegated-template-pipeline.py ingest`
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 13.3 代签核与审计
    - `delegated-template-pipeline.py signoff --port 8882 --audit <A>/delegated-approvals-rehearsal.jsonl`
    - _Requirements: 10.3, 10.4_
  - [ ] 13.4 scaffold-template 与模板代码
    - `pipeline scaffold` 后按 fig17 结构写 `code/render.R`、`core.R`、`<native>.R`（`source.modifications` 逐条记录）、`sizing.R`、`runtime.json`（最小依赖，不加载 Seurat/SCP）、`example/style.json`（原生参数），模板正文写软件夹具声明与代签核含义
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 13.5 回放、原生对照与 ready 判定
    - `pipeline verify` → `compare-native.py` → 换数据与规模（≥ 2 种组数、长标签、显式顺序）→ 异目录迁移（`verify/runtime-portability.json`）→ bindings 出图比较 → 全部通过则 `pipeline ready`，否则保持 draft 并写精确原因与 `not_ready` 审计
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 12.4_

- [ ] 14. S10 彩排 V2：FeatureStatPlot 5 结构（violin、box、bar、dot、col；按 S8 判定是否合并） （需求 17 修订：已完成的 6 个 CSV 模板走本批彩排流程）
  - [ ] 14.1 原生材料
    - 写 `native-cases/v2-featurestat.R`：复用 5 种已有原生输出，核对 sha256 并导出接口 CSV
    - _Requirements: 8.2, 8.5, 10.2_
  - [ ] 14.2 画廊条目与 ingest
    - 同 13.2，批次 `v2-featurestat`
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 14.3 代签核与审计
    - 同 13.3
    - _Requirements: 10.3, 10.4_
  - [ ] 14.4 scaffold-template 与模板代码
    - 同 13.4；5 个结构共用绘图核心时只在 `core.R` 共享，模板各自声明入口
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 14.5 回放、原生对照与 ready 判定
    - 同 13.5
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 12.4_

- [ ] 15. S10 彩排 V3：CellDimPlot / FeatureDimPlot / FeatureCorPlot（基础分组散点、分组圈选、嵌入图分组统计小图、lineage 叠加；单特征连续色、多特征混色；FeatureCorPlot 1） （需求 17 修订：已完成的 5 个 CSV 模板走本批彩排流程；stat-inset 原生失败不入）
  - [ ] 15.1 原生材料
    - 写 `native-cases/v3-dim.R`：基础与 4 种圈选、单特征、FeatureCorPlot 复用已有；统计小图与混色生成；lineage 叠加重跑一次确认原生失败并记录精确错误（grobs list-matrix），标 `reference_failed`，不重画
    - _Requirements: 8.2, 8.5, 8.6, 10.2, 10.5_
  - [ ] 15.2 画廊条目与 ingest
    - 同 13.2（不含 `reference_failed` 结构）
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 15.3 代签核与审计
    - 同 13.3；lineage 叠加记 `blocked_native_failure`，不签核
    - _Requirements: 10.3, 10.4, 10.5_
  - [ ] 15.4 scaffold-template 与模板代码
    - 同 13.4
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 15.5 回放、原生对照与 ready 判定
    - 同 13.5
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 12.4_

- [ ] 16. S10 彩排 V4：DynamicPlot / DynamicHeatmap / LineagePlot / GraphPlot （需求 17 修订：不再新做 CSV 模板，改由 28.x）
  - [ ] 16.1 原生材料
    - 写 `native-cases/v4-trajectory-graph.R`：DynamicPlot、DynamicHeatmap、GraphPlot（straight/curved）复用已有；LineagePlot 用已有 Slingshot 对象生成
    - _Requirements: 8.2, 8.5, 10.2_
  - [ ] 16.2 画廊条目与 ingest
    - 同 13.2
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 16.3 代签核与审计
    - 同 13.3
    - _Requirements: 10.3, 10.4_
  - [ ] 16.4 scaffold-template 与模板代码
    - 同 13.4；GraphPlot 模板必要包为 ggplot2、grid、reshape2、rlang
    - _Requirements: 6.1, 6.3, 6.4, 6.5, 6.6, 10.6, 10.11_
  - [ ] 16.5 回放、原生对照与 ready 判定
    - 同 13.5
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 12.4_

- [ ] 17. S10 彩排 V5：EnrichmentPlot 7 结构（bar、dot、lollipop、network、enrichmap、wordcloud、comparison） （需求 17 修订：不再新做 CSV 模板，改由 28.x）
  - [ ] 17.1 原生材料
    - 写 `native-cases/v5-enrichment.R`：先在 R_Runtime 探测 clusterProfiler 与注释库可用性；可用则生成，缺包按精确包名与原始错误记 `missing_package`
    - _Requirements: 8.2, 10.2, 10.12, 15.1_
  - [ ] 17.2 画廊条目与 ingest
    - 同 13.2（只处理 `native.state=generated` 的结构）
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 17.3 代签核与审计
    - 同 13.3
    - _Requirements: 10.3, 10.4_
  - [ ] 17.4 scaffold-template 与模板代码
    - 同 13.4
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 17.5 回放、原生对照与 ready 判定
    - 同 13.5；未产出结构在对应技术页写真实实现、参数说明与精确 not_run 原因
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 10.12, 12.4_

- [ ] 18. S10 彩排 V6：GSEAPlot（line、bar、comparison；network/enrichmap/wordcloud 按 S8 判定复用 V5 或新增） （需求 17 修订：不再新做 CSV 模板，改由 28.x）
  - [ ] 18.1 原生材料
    - 写 `native-cases/v6-gsea.R`；缺包同 17.1 处理
    - _Requirements: 8.2, 10.2, 10.12, 15.1_
  - [ ] 18.2 画廊条目与 ingest
    - 同 13.2
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 18.3 代签核与审计
    - 同 13.3
    - _Requirements: 10.3, 10.4_
  - [ ] 18.4 scaffold-template 与模板代码
    - 同 13.4；与 V5 共用几何时复用其绘图核心
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 18.5 回放、原生对照与 ready 判定
    - 同 17.5
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 10.12, 12.4_

- [ ] 19. S10 彩排 V7：ProjectionPlot / PAGAPlot / VelocityPlot（raw 箭头、grid 箭头、stream 流线） （需求 17 修订：不再新做 CSV 模板，改由 28.x）
  - [ ] 19.1 原生材料
    - 写 `native-cases/v7-projection-paga-velocity.R`：先查 `<B>` 与 Native_Oracle 中是否已有参考映射、PAGA、速度上游真实对象；有则生成；没有记 `missing_material` 与缺少的具体对象，stream 记 `missing_package`（metR）；不合成上游结果
    - _Requirements: 8.2, 10.2, 10.12, 15.1, 15.2_
  - [ ] 19.2 画廊条目与 ingest
    - 同 13.2；本批若无 generated 结构，在批次文件记"本批无可签核结构"并结束
    - _Requirements: 10.2, 10.10, 10.11_
  - [ ] 19.3 代签核与审计
    - 同 13.3（仅 generated 结构）
    - _Requirements: 10.3, 10.4_
  - [ ] 19.4 scaffold-template 与模板代码
    - 同 13.4（仅已代签核结构）
    - _Requirements: 6.1, 6.3, 6.5, 6.6, 10.6, 10.11_
  - [ ] 19.5 回放、原生对照与 ready 判定
    - 同 17.5
    - _Requirements: 8.2, 8.4, 10.7, 10.8, 10.12, 12.4_

- [ ] 20. S10 彩排 V8：3D（CellDimPlot3D、FeatureDimPlot3D，建模板停在 draft）
  - [ ] 20.1 原生材料与来源截图
    - 写 `native-cases/v8-3d.R`：复用已有原生 HTML 与依赖目录、trace 导出，核对 sha256；导出 3D 坐标与分组/特征值接口 CSV；用 `kiro_browser_check.py` 对原生 HTML 截图为 PNG（`kind=browser_screenshot`，注明仅为来源参考图）
    - _Requirements: 8.3, 8.5, 10.2, 10.13_
  - [ ] 20.2 画廊条目与 ingest
    - `build-gallery-entry.py` 以截图为 `init_entry.py --source`；README、`figure.caption` 写"截图仅为来源参考图，原生输出是交互 HTML"与"作者 2026-10-26 决定下的范围外收录"；`output/` 放提炼版 HTML 与其截图，`qa_check` 的 PDF/SVG 缺项如实记"交互输出不适用"；再 `pipeline ingest`
    - _Requirements: 10.2, 10.10, 10.11, 10.13_
  - [ ] 20.3 代签核与审计
    - `pipeline signoff`，审计 `evidence` 列 trace 字段比对、外部 `plotly_build`/HTML 保存、原生 HTML 浏览器检查三类证据
    - _Requirements: 10.3, 10.4_
  - [ ] 20.4 scaffold-template 与模板代码
    - `pipeline scaffold`；`code/render.R` 读接口 CSV 输出 `figure.html` + 依赖目录；不补静态重画图；正文"未 ready 原因"节写"交互输出，官方回放（PNG/PDF/SVG）不支持，未 ready"及已完成证据路径与 sha256
    - _Requirements: 6.1, 6.3, 10.6, 10.8, 10.11, 10.13_
  - [ ] 20.5 回放、对照与交互检查（不 mark-ready）
    - 运行 `pipeline verify` 并如实记录失败；`compare-native.py` 做 trace 字段比对与外部 `plotly_build`/HTML 保存；`kiro_browser_check.py` 对提炼版 HTML 做渲染与图例隐藏/恢复检查；写 `templates/<tid>/verify/native-comparison.json`（`kind=plotly_trace`）、`<A>/kiro-3d-browser-check-<stamp>.json` 与 `not_ready` 审计；不执行 `mark-ready`
    - _Requirements: 8.3, 8.7, 10.8, 10.13_

- [ ] 21. S10 彩排汇总
  - [ ] 21.1 合并批次状态
    - 把 `<B>/coverage/visual-batches/*.json` 合并进 `<B>/coverage/visual-structures.json`，运行 `validate-visual-structures.py` 零错误；确认 fig17 资产哈希与 S0 快照一致
    - _Requirements: 10.1, 10.9_
  - [ ] 21.2 更新计数与彩排报告
    - 用 `wiki-map.py` 更新 counts（代签核、模板化、ready 分别计数），重跑 `validate-wiki-map.py`；写 `<A>/kiro-s10-rehearsal-summary-<stamp>.json`：每结构的批次、代签核、模板状态、ready / 未 ready 及原因、原生失败与缺包/缺材料清单，以及增量合入用的官方命令序列；停止隔离 Wiki_Server 8882
    - _Requirements: 2.9, 10.8, 12.3, 15.6_
  - [ ]* 21.3 属性测试：可视化结构状态机不变量
    - **Property 13: 可视化结构状态机不变量**
    - 文件 `test_visual_structures.py`；真实清单穷举 + 按 seed 单字段变异；含 fig17 未变与 3D 固定 draft 示例
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.5, 10.6, 10.7, 10.8**
  - [ ]* 21.4 属性测试：计数由记录派生
    - **Property 3: 计数由记录派生**
    - 在 `test_wiki_map.py` 中独立测试函数；断言 counts 等于按定义筛选的去重计数，SCP 模板总数 = 17 + `template.state != none` 结构数
    - **Validates: Requirements 2.9, 12.3**
  - [ ]* 21.5 属性测试：审计记录与官方动作一一对应
    - **Property 14: 审计记录与官方动作一一对应**
    - 文件 `test_audit_log.py`；对 `--audit` 指定的 jsonl 与对应 Wiki 的 `log.md`/Git 提交穷举核对（先用彩排日志，S11 后对正式日志重跑）
    - **Validates: Requirements 10.4**
  - [ ]* 21.6 属性测试：来源图不在 Wiki 重复存放
    - **Property 18: 来源图不在 Wiki 重复存放**
    - 在 `test_visual_structures.py` 中独立测试函数；穷举新条目来源图 sha256 与 Wiki 目录文件；模板 `preview.png` 只来自回放输出
    - **Validates: Requirements 10.10**

- [ ] 28. 需求 17：Seurat 输入绘图模板逐形态验证（插在 22 之前执行）
  - [ ] 28.1 上游对象生成
    - 用原生 SCP 在 pancreas_sub 上生成并保存 RDS：RunDEtest(group_by=CellType)、RunEnrichment 与 RunGSEA（自定义 TERM2GENE，不联网）、RunSlingshot + RunDynamicFeatures（lineage 拟合）；记录参数、sha256 与原始错误；缺包/缺材料（scvelo、scanpy）写 missing_*
    - 输出 `E:/research-wiki-env/work/kiro-scp-upstream/`，汇总写 <A>/kiro-upstream-objects-<stamp>.json
    - _Requirements: 17.4, 17.5_
  - [ ] 28.2 逐形态用例与原生对照
    - 对 22 个入口在 branches.json 中的每个形态值建一个用例（其余参数默认），生成原生 PNG（交互图 traces），写入暂存用例目录后合并进 coverage/cases；原生失败记 expect_native_failure
    - _Requirements: 17.2, 17.3_
  - [ ] 28.3 重新冻结并运行可视化家族收据【后台】
    - 新冻结记录（只改 cases），kiro_run_all_cases.py 只跑 scp-viz-* 家族；select-receipts
    - _Requirements: 17.2, 7.1_
  - [ ] 28.4 页面：形态表、上游链路、形态图样、应用场景、与 CSV 模板互链
    - 改 fill-pages2.py（页面文字编译器，不在冻结清单内）或新编译脚本，形态图样取自收据输出
    - _Requirements: 17.5, 17.6, 17.7, 17.8_
  - [ ] 28.5 Checkpoint：逐形态统计（verified / native_failure / missing_* / not_probed），并入 22 的汇报
- [ ] 22. Checkpoint - 彩排结果
  - 报告 S10 统计：新增结构数、代签核数、模板化数、ready 数、未 ready 数（按原因分列，含 2 个 3D draft）、原生失败与缺包/缺材料结构；运行全部已写测试；确保全部通过，有疑问时询问用户。

- [ ] 23. S11 受控合入正式库
  - [x] 23.1 Baseline 快照与对比工具（C12）
    - 新建 `<B>/scripts/baseline-snapshot.py`（复用 `codex_method_state_audit.py formal` 的官方读取方式，记录家族 status/ready_for_use、实现状态与 portability、模板 status/replay_available/acceptance_stale、页面与实现 ID 全集）与 `baseline-diff.py`（状态序 ready/verified > draft/stale/not_run > invalid，任一下降即非零退出）
    - _Requirements: 12.1, 12.2, 12.5, 12.6_
  - [x]* 23.2 属性测试：Baseline 单调不降
    - **Property 16: Baseline 单调不降**
    - 文件 `test_merge_protection.py`；按 seed 生成快照对与增量序列，断言 `baseline-diff.py` 判定与参考模型一致
    - **Validates: Requirements 12.1, 12.2**
  - [ ] 23.3 合入器与合入计划（C11、D5）
    - 新建 `<B>/scripts/merge-increment.py`：按 D5 生成 `<A>/merge-plan-<stamp>.json`；每增量前核对 `formal_pre_sha256`（不一致即停止该增量）、复制目标到 `<A>/backup-<stamp>/<inc-id>/`、执行官方命令序列、合入后保护比对与 Baseline diff；既有页 `status`/`favorite`/`tags` 与作者区块取正式库当前值，`facts` 交 `save` 重建；永不复制 B 的 `index.md`、`log.md`、fig17 相关文件与早于正式 fig17 发布的状态
    - 先在 `<tmp>/kiro-scp-merge-dryrun/`（正式 Wiki 的 `git clone --local` 副本，不触碰正式库）干跑全部增量
    - _Requirements: 12.5, 13.1, 13.2, 13.4, 13.5_
  - [ ]* 23.4 属性测试：合入保护
    - **Property 15: 合入保护**
    - 在 `test_merge_protection.py` 中独立测试函数；对 23.3 干跑副本穷举增量前后：Fixed_Source、开发代码、既有画廊字节不变（允许清单除外）、作者区块字节一致、既有 status 不变、ID 超集、只改 SCP 相关页面、`index.md`/`log.md` 只由 `save` 改
    - **Validates: Requirements 3.5, 10.4, 11.10, 12.4, 13.2, 13.3, 13.4, 13.5**
  - [ ] 23.5 合入前备份与 Baseline 快照（只写 A）
    - 用 psutil 精确命令行核对正式 Wiki_Server 8765，复用已运行实例或按原配置重启，不另起重复服务；记录正式 Wiki Git `HEAD`；备份全部增量目标路径到 `<A>/backup-<stamp>/`；运行 `baseline-snapshot.py`（before）、`codex_protection_audit.py`、`wiki.py gh protect-baseline --check`
    - 完成判据：`<A>/baseline-before-<stamp>.json`、`<A>/kiro-protection-before-<stamp>.json`、`<A>/kiro-s11-backup-<stamp>.json`（备份位置与 HEAD）
    - _Requirements: 12.6, 13.1, 13.3, 14.1_
  - [ ] 23.6 【写正式库】增量 1–3：内容页与方法页
    - 用 `merge-increment.py` 依次合入：接口页与图型页内容；既有方法/技术页正文与资产；新方法/技术页（先 `scaffold-method` 建骨架再填内容，保持 draft）；每增量后 `save` 与 Baseline diff，下降即按回退表回退该增量并定位原因
    - _Requirements: 12.5, 13.2, 13.4, 13.5_
  - [ ] 23.7 【写正式库】增量 4–5：V1–V4 可视化结构
    - 按 21.2 的命令序列在正式画廊 `<G>` 只新增 `2026-10-22-scp-example/figures/fig18+` 目录（`build-gallery-entry.py --gallery <G>`），`build_index.py`；正式 Wiki `ingest-figure`；经 8765 签核 API 代签核；`scaffold-template`、放资产、`verify-template`、原生对照、`check-entry`、`mark-ready` 或保持 draft；审计写 `<A>/delegated-approvals.jsonl`；每结构后 Baseline diff
    - _Requirements: 10.2, 10.3, 10.4, 10.6, 10.7, 10.8, 12.4, 12.5_
  - [ ] 23.8 【写正式库】增量 4–5：V5–V7 可视化结构
    - 同 23.7，覆盖富集、GSEA、Projection/PAGA/Velocity 中已在彩排代签核的结构
    - _Requirements: 10.2, 10.3, 10.4, 10.6, 10.7, 10.8, 10.12, 12.4, 12.5_
  - [ ] 23.9 【写正式库】增量 4–5：V8 3D 结构（停在 draft）
    - 同 23.7 至 `verify-template` 与对照为止；不执行 `mark-ready`；写 `not_ready` 正式审计记录
    - _Requirements: 10.3, 10.4, 10.8, 10.13_
  - [ ] 23.10 【写正式库】合入后核对与必要回退
    - 运行 `baseline-snapshot.py`（after）与 `baseline-diff.py`、`codex_protection_audit.py`、`protect-baseline --check`、`codex_impl_identity_audit.py`；SCP 模板总数 = 17 + 新增数；任何下降或保护差异：回退对应增量（备份恢复或 API 归档，不用 `git reset --hard`），记录原因
    - 完成判据：`<A>/baseline-after-<stamp>.json`、`<A>/baseline-diff-<stamp>.json`、`<A>/kiro-protection-after-<stamp>.json`
    - _Requirements: 12.1, 12.2, 12.3, 12.5, 12.6, 13.3, 13.4_
  - [ ] 23.11 【条件】五处全局安装同步
    - 先判定本轮是否改动 research-wiki 规则或产品代码（`<skill>` 与规则文档的 Git diff）；无改动则只在 `<A>/kiro-global-sync-decision-<stamp>.json` 记录"仅内容改动，不同步"（预计如此）
    - 有改动时：先备份五处（.agents、.codex、.claude、.cc-switch、.config/opencode）再同步，并逐文件哈希核验
    - _Requirements: 13.10, 13.11_

- [ ] 24. S12 官方验收命令
  - [ ] 24.1 【写正式库】check-entry、lint、pending、save
    - 对全部受影响页面执行 `check-entry --record`；执行 `lint`，有 ERROR 即修页面后重跑直到无 ERROR（不放宽规则）；执行 `pending --json` 与 `save`
    - 完成判据：`<A>/kiro-s12-acceptance-<stamp>.json`（每条命令输出摘要与最终 lint 结果）
    - _Requirements: 13.6, 13.7, 12.4_

- [ ] 25. S13 API 与浏览器核验
  - [ ] 25.1 API 与 CLI 一致性核对
    - 新建 `<B>/scripts/kiro_api_parity.py`：经 8765 读取 `/api/page?path=methods/<id>.md`、`/api/templates/<id>/code-files`、`/api/methods/<id>/code-files`，与 CLI `implementation_status`、模板状态逐字段比对；确认服务只监听本机地址
    - 完成判据：`<A>/kiro-api-parity-<stamp>.json` 零差异
    - _Requirements: 14.2, 14.4, 14.8_
  - [ ]* 25.2 属性测试：API 与 CLI 状态一致
    - **Property 21: API 与 CLI 状态一致**
    - 文件 `test_api_cli_parity.py`（需 Wiki_Server 运行）；穷举受影响方法页与模板页
    - **Validates: Requirements 14.2**
  - [ ] 25.3 浏览器核验
    - 用 `kiro_browser_check.py` 检查：方法目录只把满足门槛的 analysis 家族显示为可执行推荐；代码查看器逐分支状态（共享文件 `mixed`，无收据分支不提升）；新 layout 显示 approved 与代签核标识；新模板状态与原因和 CLI 一致；来源参考图标识；`methods/scp-local-source.md` 显示为技术资料；两个提炼版 3D HTML 的渲染与图例隐藏/恢复
    - 完成判据：`<A>/kiro-frontend-review-<stamp>.json` 与截图目录 `<A>/kiro-frontend-screens-<stamp>/`；交互未完成项标"未验收"，不以截图替代
    - _Requirements: 8.7, 10.13, 14.3, 14.4, 14.5, 14.6, 14.7_

- [ ] 26. Final checkpoint
  - 运行 `<B>/scripts/tests` 全部测试（含 21.5 对正式审计日志重跑）、`validate-wiki-map.py`、`validate-visual-structures.py`、`kiro_freeze_check.py`、`baseline-diff.py`；确保全部通过，有疑问时询问用户。

- [ ] 27. S14 交付
  - [ ] 27.1 交付报告
    - 写 `<A>/kiro-delivery-report-<stamp>.md`：五个覆盖指标与代签核数/模板化数/ready 数；入库完整、当前可运行、原生图形验证通过、真实课题科学有效（本轮不评估）、代签核清单（含审计记录指针）、未达 ready 模板清单与原因；复用证据来源；全部未闭合项；存在未闭合项时不宣称全库入库完成
    - _Requirements: 2.9, 9.1, 15.6, 15.7_
  - [ ] 27.2 清理与收尾
    - 删除本轮在 `<tmp>` 下创建的 `kiro-scp-*` 临时文件（保留已写入 `<A>` 的证据）；在 `<A>/task-state.json` 记录完成时间与报告路径
    - _Requirements: 16.5_

## Notes

- 标 `*` 的子任务是可选测试，可跳过以加快进度；核心实现任务不可跳过。R 相关性质测试（2.4–2.8）每次迭代开新 Rscript 进程，需后台运行。
- 1.1 必须先于任何对 A/B 的写入；脚本先写在 `<tmp>`，核对通过后才复制进 B。
- 2.x、3.x、4.x 只在临时构建与干跑输出上验证；6.2 宣布 Code_Freeze 后，7.1 只重建与整合一次。之后任何代码、helper、资源或 `runtime.json` 变化都由 `kiro_freeze_check.py` 发现，受影响收据视为 stale 并回到 8.2 重验，不再整体重建。
- 13–21 的隔离彩排必须全部完成并通过 22 的 Checkpoint 后，才开始 23 的正式合入；正式合入按彩排得到的官方命令序列重放，不复制带状态的 frontmatter。
- 标【写正式库】的任务（23.6、23.7、23.8、23.9、23.10、24.1）会修改正式库、正式画廊或调用正式 Wiki_Server 签核 API。执行任何一项之前必须已完成 23.5 的合入前备份与 Baseline 快照；23.10 完成合入后 Baseline 快照。
- 23.11 是条件任务：只有本轮改动了 research-wiki 规则或产品代码才同步五处全局安装，且先备份；本轮预计只改内容，不需要同步。
- 预计最耗时：8.2 全量收据重跑、8.5 79 模块加载审计、2.4–2.8 R 性质测试、8.3/8.4 迁移与回放、13–20 各批次的原生材料与回放；以上均为【后台】、可断点续跑、单命令不超过 1800 秒。
- 每批次 x.2–x.5 都会对隔离 Wiki 执行 `save`，Git 写入必须串行，因此批次之间按顺序执行；各批次的原生材料（x.1）彼此独立，可并行。

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.3"] },
    { "id": 2, "tasks": ["2.1"] },
    { "id": 3, "tasks": ["2.2", "2.4"] },
    { "id": 4, "tasks": ["2.3", "2.5"] },
    { "id": 5, "tasks": ["2.10", "2.6", "2.7"] },
    { "id": 6, "tasks": ["2.9", "2.11", "2.8"] },
    { "id": 7, "tasks": ["3.1", "3.4"] },
    { "id": 8, "tasks": ["3.2", "3.3", "3.5"] },
    { "id": 9, "tasks": ["3.6", "3.8"] },
    { "id": 10, "tasks": ["3.7", "4.1"] },
    { "id": 11, "tasks": ["4.2", "4.3"] },
    { "id": 12, "tasks": ["6.1"] },
    { "id": 13, "tasks": ["6.2"] },
    { "id": 14, "tasks": ["7.1"] },
    { "id": 15, "tasks": ["8.1"] },
    { "id": 16, "tasks": ["8.2"] },
    { "id": 17, "tasks": ["8.3", "8.4", "8.5"] },
    { "id": 18, "tasks": ["8.6"] },
    { "id": 19, "tasks": ["8.7", "10.1"] },
    { "id": 20, "tasks": ["10.2", "10.5", "8.8"] },
    { "id": 21, "tasks": ["10.3", "10.6", "11.1"] },
    { "id": 22, "tasks": ["11.2", "12.1", "12.2", "12.3", "12.5", "10.4"] },
    { "id": 23, "tasks": ["12.4"] },
    { "id": 24, "tasks": ["12.6", "12.7", "13.1", "14.1", "15.1", "16.1", "17.1", "18.1", "19.1", "20.1"] },
    { "id": 25, "tasks": ["13.2"] },
    { "id": 26, "tasks": ["13.3"] },
    { "id": 27, "tasks": ["13.4"] },
    { "id": 28, "tasks": ["13.5"] },
    { "id": 29, "tasks": ["14.2"] },
    { "id": 30, "tasks": ["14.3"] },
    { "id": 31, "tasks": ["14.4"] },
    { "id": 32, "tasks": ["14.5"] },
    { "id": 33, "tasks": ["15.2"] },
    { "id": 34, "tasks": ["15.3"] },
    { "id": 35, "tasks": ["15.4"] },
    { "id": 36, "tasks": ["15.5"] },
    { "id": 37, "tasks": ["16.2"] },
    { "id": 38, "tasks": ["16.3"] },
    { "id": 39, "tasks": ["16.4"] },
    { "id": 40, "tasks": ["16.5"] },
    { "id": 41, "tasks": ["17.2"] },
    { "id": 42, "tasks": ["17.3"] },
    { "id": 43, "tasks": ["17.4"] },
    { "id": 44, "tasks": ["17.5"] },
    { "id": 45, "tasks": ["18.2"] },
    { "id": 46, "tasks": ["18.3"] },
    { "id": 47, "tasks": ["18.4"] },
    { "id": 48, "tasks": ["18.5"] },
    { "id": 49, "tasks": ["19.2"] },
    { "id": 50, "tasks": ["19.3"] },
    { "id": 51, "tasks": ["19.4"] },
    { "id": 52, "tasks": ["19.5"] },
    { "id": 53, "tasks": ["20.2"] },
    { "id": 54, "tasks": ["20.3"] },
    { "id": 55, "tasks": ["20.4"] },
    { "id": 56, "tasks": ["20.5"] },
    { "id": 57, "tasks": ["21.1"] },
    { "id": 58, "tasks": ["21.2"] },
    { "id": 59, "tasks": ["21.3", "21.4", "21.5"] },
    { "id": 60, "tasks": ["21.6", "23.1", "23.3"] },
    { "id": 61, "tasks": ["23.2"] },
    { "id": 62, "tasks": ["23.4", "23.5"] },
    { "id": 63, "tasks": ["23.6"] },
    { "id": 64, "tasks": ["23.7"] },
    { "id": 65, "tasks": ["23.8"] },
    { "id": 66, "tasks": ["23.9"] },
    { "id": 67, "tasks": ["23.10"] },
    { "id": 68, "tasks": ["23.11"] },
    { "id": 69, "tasks": ["24.1"] },
    { "id": 70, "tasks": ["25.1", "25.3"] },
    { "id": 71, "tasks": ["25.2"] },
    { "id": 72, "tasks": ["27.1"] },
    { "id": 73, "tasks": ["27.2"] }
  ]
}
```
