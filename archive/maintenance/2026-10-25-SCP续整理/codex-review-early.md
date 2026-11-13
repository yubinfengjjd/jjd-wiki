# 第一批途中独立审查（仅候选工作区，不改正式库）

本轮编码角色还在运行；此文件待本轮结束后交同会话修复，不能因文件存在就认为Devin已读。

## 作者后续指向（必须优先承接）

作者已答优先顺序问题：“最近没有课题，之前完成了一批还有没完成的。好像是groupheatmap开始”。不要再围绕新课题选方向；本次是原SCP整理的续做，后续以GroupHeatmap未覆盖分支起接旧清单。既有ht1默认模板保留；不要重建16个已入库模板。另有E:/research-wiki-env/work/scp-heatmap历史原生/重画候选可只读核对，尤其GroupHeatmap add_dot；Codex实际打开其source/native.png和preview.png，主题/横轴/注释/比例和图例有明显差异，旧“函数测试通过”不能证明原生复现。先完成当前有界修复轮并交结果，再做GroupHeatmap，不把下一整轮都用来展开DE的其他算法。

## DE副作用独立复现补充

Codex将当前候选2文件复制到维护记录codex-de-smoke/code，在独立R进程实际连续调用2次同一函数：第一次7956行，第二次NormalizeData→LogNormalize.V3Matrix→LogNorm错误“Expecting a single value: [extent=0]”。完整栈见logs/codex-de-two-calls-checkpoint.log。说明简单删除新增options后会破坏已加载namespace依赖的初始化默认值，不能只让单次恢复检查绿就交付。

原生RunDEtest会在data槽被识别为raw counts时按norm.method执行NormalizeData；本次pancreas测试确有警告。保留并说明这是原算法行为，不隐改；不把该示例写成已证实历史标准化或真实课题科学验证。后续修复应保留显式调用者option优先，不全局常驻包默认值、不unload namespace；任何兼容性默认值须来自当前实际包版本和代码依据，诊断记真实前后状态。

## Coverage必须修正

- 独立NAMESPACE提取142个export。候选160行coverage将多个公开入口压在一行：导出表无法精确join、也无法证明每个export均处理。保留语义归组，但另加一张一行一个canonical export的明示映射（去掉export字符串两侧引号后规范化，保留原字符串/来源），包括CellStatPlot与StatPlot、两种中缀operator及geom/helpers；写covered_by行id/排除理由，不靠模糊substring宣称全部覆盖。不要为满足覆盖而造家族。
- 正式analysis家族15个，其中13个含SCP来源，另外2个为SHAP/回归评估。当前汇总“14个规范家族”及把cell-type-annotation放入非SCP行有误。
- 独立执行installed.packages()实证：现有隔离R库scDblFinder MISSING、SingleR MISSING、monocle MISSING，NMF0.28、slingshot2.16.0存在。候选db_scDblFinder行“已装”是假事实；必须更正为本次实际缺包证据。其他声称“Python后端缺”的行也要区分实际探测/历史not_run/尚未探测，不能由旧收据猜当前全环境。
- “covered本轮无缺口”不能从一个实现verified推出同函数所有分支都覆盖。增加实际收据路径/验证case和scope；例如RunDimReduction默认PCA/UMAP不能批准NMF/PHATE等。动态Gaussian测试范围也不外推其他family。历史算法通过、独立性与本轮实跑分别列，不把当前自己未跑的条目写成本轮新通过。
- RunHarmony2按目的应审查归属批次校正，不因它在Seurat-function.R就标降维；RunKNNPredict要按源码具体作用及单位核查，而非只看名字认领细胞注释。其余存在性由语义判断，不强行重分。

## 受控标签规则的实际执行缺口

AGENTS88/145/333行规范键措辞和ingest.py84-85真实key→label行为不一致：gallery.scenarios存规范英文key，Wiki.tags存taxonomy当前label；purposes是另一受控表。rwiki/lint.py metadata_errors仅检查tags为字符串列表，acceptance.entry_errors只调用此处；server.tags只strip/dedup后finish。独立检查正式页面的未知label为0。

后续修复应先在隔离库复现未知tag被lint/check-entry/API接受，再补统一、配置驱动的受控label验证（不能复制枚举，不能改为自由tag，不能把英文key和中文label混为一谈）；API拒绝应是清楚的4xx而非500/部分写；旧合法标签/空列表/keywords/作者状态和文件内容在拒绝后保持，未知taxonomy配置需具体报错。同步正式候选wiki/AGENTS、staged/assets/AGENTS及相关SKILL/reference，当前调用签名兼容及测试范围先列明确方案再编码。此属于本次“按新规则入库”必要的一致性修复，无需向作者重复索要常规授权。未做时不要在最终报告声称已有校验。
