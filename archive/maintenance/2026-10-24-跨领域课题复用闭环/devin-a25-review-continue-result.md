继续同一会话。先读试用版本地 skill 及其 config/AGENTS.md，确认隔离副本的 wiki_root 与工具路径（不再用 development/staged 的 wiki.py）。读三个候选方法页与 runtime.json（detest / cellscoring / runcellqc）。两个最强候选：`scp-detest`（DE→火山图）与 `scp-cellscoring`（签名打分→小提琴）。先查关键依赖 BiocParallel/rlang 是否在库，并看 analysis.R 入口签名。看 add-task / add-observation 的参数字段，确定修正机制（observation 的 claim/subject，或 task 重登记规则）。修正机制确认：tasks 只能新增不能改，修正走新的 revision 事件（observation/decision）。建任务清单后开始执行：先按 runtime.json 清单复制 `scp-detest` 闭包并核对 sha256 与收据一致。闭包两文件与 verified 收据 sha256 逐字节一致。写课题 runner（显式参数、只读输入、导出结果+诊断+检查）。运行完成（两输出已写、进程已退出）。看诊断与结果表头几行。真实数据核查通过：7403 行、gene 唯一、仅 **71 行** p_val_adj=0（下溢），最小正值 8.05e-319，pct/log2FC 范围正常。映射规则定为：列改名 + 0→最小正值/2 的显式下溢下界（写进映射报告）。看 render 命令签名。批量执行修正观察 + 新任务 + 两次 run 登记。该条观察被拒——record-use 回退改记在 REVIEW-RESPONSE.md 与交接文档中。继续登记 DE 任务与运行。登记完成。更新交接文档前先读现有版本。批量更新交接文档与检查文件。先改 `figure-input-check.md`（加更正节 + 火山图检查节）。更新 `context.json`（工具路径换试用版、新增两轮 run、边界修正）。更新 `recommendations.md`：DE 移入主线已完成、修正打分列表述、富集转为探索补充。写 REVIEW-RESPONSE.md — 复核响应与证据索引。check 通过：DE 分支在副本库中解析为 verified，新任务 ok。看 artifacts 区与最终 status。完成，停止待复核。本轮工作与修正如下。

## 实际执行的 Wiki 已验证分支

- **选支**：`differential-expression/scp-detest`（副本库中 ready + verified standalone；细胞类型间 marker 刻画，天然兼容 GSM-only 描述性范围）。DESeq2 分支缺包如实保留。
- **闭包**：仅复制 runtime.json 声明的 2 文件 → `scripts/wiki-scp-detest/`；sha256 `d551f051…/a4eea98f…` 与 verified 收据 executed_files **逐字节一致**。
- **执行**：新进程显式调用 `run_differential_expression`（`celltype`：RGC_like 702 cells vs others 9398，wilcox+bonferroni，seed=11，SerialParam）→ `analysis/de-rgclike-vs-others-allmarkers.csv`（7403 行，约 8 min 内）。
- **出图**：显式映射（仅改名 + 71 行 p_adj 下溢下界，全部记录在 `render-de-results-mapping.txt`）→ `render-de-results.csv` → 火山图模板 → `figures/de-rgclike-volcano/{png,pdf,svg}`。顶部平直带即下溢点的诚实呈现。agent 图像读取核对已写入收据检查项，仍标待复核确认。
- **登记**：`task-de-rgclike` 正确绑定 family+impl；两个 completed run；`project check` 中该分支在副本库解析为 `implementation: verified`。

## 修正（均走 revision 事件，收据未动）

- `obs-correction-propgsm-binding`：task-prop-gsm 为未绑定课题聚合，旧 family 绑定不成立。
- `obs-correction-figcheck`：fig04 实际核对者=Codex；补流带≠轨迹、无重复/疾病推断边界。
- `obs-correction-objprops` / `obs-correction-scorecols`：词表与打分列的证据分级。
- record-use 回退（04c1f767f815）已写进 HANDOVER/mapping/context/REVIEW-RESPONSE；对应 state 观察登记被用户拒绝，改记文档。

## 已知缺口

`de-rgclike-vs-others-diagnostics.json` 为 0 字节（进程内写出未完成，warnings/恢复未捕获）；结果表完整并经机器核查（`de-rgclike-vs-others-checks.txt`）。

状态：revision 48，tasks completed 4 / planned 3 / blocked 3，artifacts current 15，lessons pending 2（新增 `lesson-task-binding`）。详见 `REVIEW-RESPONSE.md`。