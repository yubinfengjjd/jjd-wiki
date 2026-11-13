# 辅助绘图与分析实现的边界补充

2026-10-23，审查修复中已观察到 trajectory-inference 的 analysis 页新增 scp-monocle2-plot/scp-monocle3-plot 两个 implementations，runtime.json也将其列为method实现；代码返回ggplot，未进行轨迹推断。

## A1 — 绘图辅助入口不能成为分析推荐的实现证据

现有 verified_implementations/ready_for_use 对 analysis 页的所有 implementations 统一计入可执行分析门槛，没有辅助绘图角色过滤。因此将纯绘图函数放进这里，会让一个仅绘图通过的分支将来批准“轨迹分析可用”，还把辅助函数算成分析实现数量。这会重新产生作者本轮最初要求解决的“绘图包装混入分析方法”。

保留分析核心和Seurat适配的明确入口，纯绘图移出 analysis.implementations 与算法verified计数/推荐门槛。可作为已有技术资料（例如 scp-visualization-interface）的辅助代码/说明，或仅在正文独立列辅助入口；正式图模板仍走既有单panel/来源/作者流程，不凭这次拆解新造图样。运行清单可以说明辅助功能，但不能用它的通过代替分析算法通过。不必为这两个函数新造一套平台。

同步正式/staged AGENTS、SKILL/references的边界：代码函数是运行单元，不等于每个函数都是分析实现；分析、对象适配、绘图各自声明能力，统计/算法门槛只接受真实分析入口的证据。

## A2 — 新写 Monocle2 绘图 helper 目前有可见数据/美学错误

当前 code/monocle2_plot.R 在 DDRTree 情况把 `t(cds@reducedDimK)`（主图节点坐标）同时作为细胞点坐标，却配上每细胞的 `cds[['State']]`。图节点数与细胞数一般不同，可能报长度错误或回收值。原SCP使用细胞 reducedDimS 画点，再使用 reducedDimK 画轨迹边，两者不能混为一张表。

此外 label=TRUE 分支 `geom_text(data=centers, aes(label=State), inherit.aes=FALSE)` 没有提供x/y，实际构图时缺必需美学。该helper不是已验证的原SCP绘图核心，不能当作最小依赖迁移已经完成。

最小范围处理优先直接复用底层Monocle官方绘图入口，或忠实提取原SCP对应绘图逻辑，明确输入和依赖；不要为解耦另写一个未经选择/验证的新样式。若保留本地辅助图，须修正细胞/节点两种粒度，实际验证并明确它不是原SCP样式；在当前缺包条件下不能宣称真实CDS绘图已通过。16个既有SCP模板及其原生核心不因本补充重写。

以上是本轮新生成代码的审查，不要求删除原始来源、安装包或改变轨迹算法。未认可的新helper可保留在维护快照中，实际交付保持最小且准确。
