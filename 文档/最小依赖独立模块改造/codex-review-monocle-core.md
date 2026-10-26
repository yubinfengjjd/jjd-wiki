# Monocle 核心提取的静态对照补充

2026-10-23，审查修复过程中查看 pilot3/trajectory-inference/code 的新核心。以下依据固定SCP原代码与新提取版逐语句比较；本机缺monocle/monocle3，不把静态审查当真实算法验证。

## M1 — 保留 Monocle2 两次 ordering 的计算步骤

原 RunMonocle2 在 reduceDimension 后先 `cds <- orderCells(cds)`，产生初步 State/轨迹；随后根据 root_state 再 `cds <- orderCells(cds, root_state=root_state)`。新 monocle2_core.R 当前只有第二次调用，遗漏第一步。显式 root_state 是前一步产生的 State 标签，不能假设新构造的cds已经有State；这也不是单纯删除绘图。

请保留原有初步排序→显式根排序的计算步骤；输入根由作者明确给出，不通过select.list或静默猜根。根状态如何获得写清楚，可以让调用者基于同一数据/特征/seed的探索结果确定，但不能把它冒充细胞类型标签。去绘图后的随机数消费差异仍记待验证，缺包保持not_run。

## M2 — Monocle3 的已有嵌入条件不能丢失

SCP适配版复用Seurat中已有的嵌入；新core默认reduced_dim=NULL，却随后调用cluster_cells/learn_graph。当前core没有preprocess_cds/reduce_dimension计算路径，也不应为补齐而擅自新增一套降维算法。

明确声明并检查该入口需要已有UMAP/对应细胞的嵌入（及实际必需参数），或严格复用已具备这些数据的原生对象；不要声称仅counts就可以完成目前未实现的步骤。测试缺必需嵌入给出清楚错误，合法输入到达精确缺包门槛即可标not_run，不能伪造本机执行。

此补充不要求安装包、换轨迹算法或新建方法家族；只是保证真实分析步骤和输入契约没有因解耦而遗漏。
