# Codex 早期审查：最小模块样板

本记录是审查要求，修复由 Claude 完成。2026-10-23，当前对象 pilot/cellqc/code/analysis.R；最终实现若已改变须重新复现，不能把样板缺陷直接视为最终状态。

## E1 — 嵌套课题脚本 source 时定位错误（已复现，需修）

入口通过遍历 sys.frame 并取第一个 ofile 定位模块。这会取到外层课题 driver.R，而不是当前 analysis.R。课题中 source(driver.R)，driver 再用绝对路径 source(analysis.R)，就去 driver 所在目录找 cellqc_native.R。

RED：维护记录/2026-10-23-最小依赖独立模块/codex-source-probe-red.log；复现脚本 scripts/codex-source-probe.R。直接 source 成功，nested_project_source 失败，准确错误是 project/cellqc_native.R 不存在。脚本没有安装包或运行算法，只验证真实文件定位。

修复：选取真实当前模块路径/显式代码根，不能依赖 cwd 或最外层脚本；对所有后续 R 模块共用正确模式。验证直接 source、课题 driver 嵌套 source、异 cwd、local 私有环境。若不支持 sys.source 说明限制；若声明支持则一起验证。

## E2 — 多模块同一课题加载的名称隔离（已用两个真实模块复现，需修）

样板顶层定义 .scp_impl、.scp_impl_dir、.scp_run 等通用名称，wrapper 在调用时从所在全局环境取这些名字。若后续多个独立模块使用相同模式且用户按说明 source 到同一环境，后加载模块可能覆盖先前模块的引擎/调度器。

不要只用每个模块各自 new.env 的测试避开日常调用。必须把至少两个不同分析模块依次 source 到同一新环境，之后再调用第一个；以及在各自私有环境调用。若最终入口本身封装为私有闭包，此项可关闭并写证据。不得要求用户通过碰巧的 source 顺序保持正确。

实际 RED：pilot2/cell-quality-control 与 pilot2/gene-set-scoring 先后 source 到同一新环境，然后调用保留的 run_cell_quality_control 函数，报 `'what' must be a function or character string`。证据 codex-multi-module-red.log、scripts/codex-multi-module-probe.R（退出1）。仅 source 顺序变更即可触发，属于日常组合使用的实际故障。须把引擎、辅助函数和分支选择逻辑封装在每模块私有闭包，既支持 source(local=env) 也支持直接source后组合调用。

## 独立对照基线已具备

Codex 原版 QC80细胞、Seurat基因集评分80细胞、差异分析（SCP示例数据）均完成原版实际调用和输入不变检查，codex-reference-final.log 退出0，结果 codex-reference.rds。评分/DE明确传 SerialParam，不是修改统计默认。初次多worker失败与参数环境对象保存的递归失败日志保留。该RDS只存普通参数与结果，运行时再构造SerialParam；不能直接序列化带执行环境的BPPARAM到该对照文件。

没有由此验证新模块，也不是实际课题/科学验证。最终 Codex 会使用这些结果独立比较。

## E3 — 临时 attach 的依赖未完全恢复（已复现，需修）

Codex 将 QC 样板代码复制到独立目录，未传 bundle，80细胞运行结果与原版完全一致、输入不变，说明该样板算法调用确已脱离整库。但 search() 没有恢复：调用前为新R进程默认搜索路径，调用后遗留 package:SeuratObject、package:sp。原因是 library(Seurat) 自动 attach Depends，清理只追踪主动请求包且逆序顺序不满足依赖关系，detach 的失败被 try(silent=TRUE) 隐藏。

证据：维护记录/2026-10-23-最小依赖独立模块/codex-qc-pilot.log（退出1），scripts/codex-qc-probe.R，codex-qc-pilot.rds（含源文件指纹）。数值/输入/无bundle三项PASS，SEARCH_RESTORED=FALSE，future选项恢复为TRUE。

修复应避免污染搜索路径，或完整跟踪本次自动附加的包并以正确依赖顺序恢复，不detach用户原先已attach的包，不unload正在使用的namespace。成功与异常路径均验证；diagnostics不能声称none而实际残留。不同方法共用同一模式时应统一修复。

## E4 — Monocle 分支仍混合分析、绘图、交互与对象转换（不符合核心目标，需处理）

当前 code/monocle2_native.R 的 RunMonocle2 原样包含无条件 monocle::plot_ordering_genes/CellDimPlot/FeatureDimPlot/print/Sys.sleep，以及 root_state=NULL 时的 select.list；静态提取还带入 Sankey、PAGA、Velocity、通用绘图等大量辅助函数。当前入口没有 show_plot 开关，运行该分析不能避开 SCP 绘图闭包，也可能在无交互课题脚本中等待选择。它是脱离整库的一个进步，但仍未满足作者“运行monocle2就只需该方法必要依赖，绘图单独给输入运行”的目标。

按已确认设计分离分析核心、Seurat输入/输出适配和可选绘图。可在保留兼容入口的同时提供实际使用底层CDS/counts+必要元数据的核心入口，保留SCP固定源的计算步骤/参数和原有辅助算法，不自行换轨迹算法。核心结果包含cds/细胞顺序/State/Pseudotime/嵌入等真实内容；图层接结果单独调用。Seurat只在Seurat适配入口必要时检查，不把它伪装为原生monocle输入的必要包。

无交互运行必须显式处理根状态：需要作者给root_state等条件时明确拒绝并提示，不自动猜根/静默替换科学选择；保留旧交互/绘图行为时注明是兼容分支，不能作为最小分析核心。Monocle3同查。由此改变默认绘图/交互行为要在modifications写明；绘图移除可能影响随机数消费，缺包时保留未验证差异，不承诺同seed数值等价，等真实运行后再验证。

同类实现核对可选数据库/ID转换/绘图功能是否被无条件加入必要依赖。例如自定义TERM2GENE的ORA不能仅因同文件有GeneConvert，就要求加载biomaRt/R.cache及两个物种所有数据库。按真正被调用的功能拆必要/可选闭包，保留成熟包自身合法的传递依赖。
