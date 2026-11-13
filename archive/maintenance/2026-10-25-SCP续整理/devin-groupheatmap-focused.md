你是本次唯一Devin编码者，模型swe-2-max，Codex负责审查。上一会话已被明确停止，相关R进程已结束；不是并发/重复派单。这是新的、严格聚焦的交付阶段。

作者最新说：“最近没有课题，之前完成了一批还有没完成的。好像是groupheatmap开始。”因此本阶段只做GroupHeatmap续整理，**禁止再做DE/options修复、NMF、全库新算法、标签后端改造或重新规划新课题**。先写progress.md更新阶段。旧DE修复不被接受，已由Codex将本工作区DE analysis.R精确恢复初始hash，失败尝试在维护记录保存；别碰它。

写范围唯一为E:/research-wiki-env/work/scp-ingestion-20261025（下面称B）。正式库/画廊/原开发/全局安装/旧工作区都是只读。不开任何子代理，不安装/下载依赖，不读取/调用E:/paper-harness，不提交/部署/代签作者。原始源码和原代码字节、现有id/status/favorite/user区域全保护。

先读B/wiki/AGENTS.md、B/development/staged/research-wiki/SKILL.md及references/{minimal-runtime,input-binding}.md，C:/Users/86186/.agents/skills/sci-figure-replica/SKILL.md（只读）。Wiki Python=C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8；所有Wiki命令用B/development/staged/research-wiki/wiki.py（其config已指B/wiki和B/gallery/8880），绝不用全局默认CLI写正式库。R启动前读取E:/research-wiki-env/work/scp-runtime.ps1，R=D:/R-4.5.0/bin/x64/Rscript.exe。源固定E:/research-wiki-env/sources/scp-2026-10-22，commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0。

**要交付的唯一具体分支：原生GroupHeatmap点阵版（add_dot=TRUE）。**

既有B/wiki/templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap只覆盖ht1默认热图，保留原样，不重复建同义模板。输入接口已有render-group-heatmap（matrix/feature/group/value/percent/matrix_order/group_order/feature_order），percent=0–1；联合主键是matrix×feature×group，不是feature单独唯一；percent源自原始每细胞表达阈值比例，不能从zscore组均值推导。检查实现再决定复用接口或必要增量，不复制新接口凑数。

可用只读历史材料：E:/research-wiki-env/work/scp-native-claude/{STATUS.md,SOURCE_TO_OUTPUT.md}、E:/research-wiki-env/work/scp-heatmap/{prepare.R,GroupHeatmap/source/native.png,GroupHeatmap/preview.png,core-template.R}。后者preview与原生图在布局、标注、坐标轴、图例上差别明显，是候选重画，**不得当原生完成品直接入库**。其真实原生调用/捕获表可参考，但必须本次重跑核查。其他历史模板16个不能重做。

执行顺序：
1. 阅读固定原函数GroupHeatmap及既有ht1拆分代码，确定点阵构造的最小原生代码区块/必要helper/palette资源。使用真实pancreas_sub.rda（只读）和一组明确marker（例如Sox9/Anxa2/Neurog3/Hes6/Fev/Neurod1/Rbp4/Pyy/Ins1/Gcg/Sst/Ghrl），group.by=CellType。选择原函数默认布局/主题/色板，add_dot=TRUE；add_reticle若开需在对照调用中显式一致，避免旧prepare强制show_row_names=TRUE造成重复行标签。不要靠新画法修成看起来像；原函数本次运行生成的单panel才是黄金参考（明确此来源，不假称裁自别的静态图）。
2. 准备层调用原函数捕获真实mat_list/mat_perc/顺序/绘图对象。绘图层只消费实际已计算表，保留原构造/几何/图例/布局，返回原生R plot/grob/Heatmap对象。清单只复制局部绘图闭包/必要资源，绘图不依赖Seurat/SCP整包/知识库路径；准备层可需要Seurat，与绘图依赖分开。原函数作为比较参考可以只读加载本地SCP源码，但独立模块验证绝不能提供该路径。禁止粘贴参考PNG冒充可换数据函数。
3. 实际生成原始参考与提炼输出PNG/PDF/SVG，same device/size/font/seed，逐项比较数值/顺序、固定PNG/视觉结构（不得以旧测通过代替），输入文件哈希不变。再测另一合法规模/长标签/顺序和显式尺寸，palette不足明确拒绝；不偷换分组/不补pct、不隐式聚合/统计/单位换算。只复制runtime声明文件/资源到异目录、新R进程、不提供bundle路径，实际换合法表运行。记录确切参数、命令、包版本、输出hash、失败/未测范围，不宣称所有GroupHeatmap分支已支持。add_violin/split/annotation本阶段只列后续，别再展开别的整项实现。
4. 在B/gallery用sci-figure-replica init_entry --gallery <B/gallery>建立一个单panel **review/draft** 条目，原始来源/源码/palette/许可证/hash保持；id先检查避免冲突，标题如“分组表达点阵热图”，不堆项目名。现有源/作者/旧状态不能修改。source panel仍在gallery，Wiki只用指针。
5. 尽可能准备全部候选模板资产（code/spec/example/runtime、独立调用说明、真实回放/独立性证据）和简洁编译说明，优先放B/candidates/group-heatmap-dot或该review画廊条目的适当路径。用隔离CLI ingest-figure形成pending_signoff来源和可查看的代码/来源图；**如果scaffold-template合法要求来源先签核，就停在具体作者门，不伪造approved/ready或手工造符合签核资格的页面**。候选函数可全部实现/验证，留待签核后用已有流程组装，不能只因这个门就停在一个空骨架。
6. 记录实际兼容性、输入语义、percent尺度、与既有ht1/普通气泡图区别和已有方法的candidate/adaptable关系建议。纯绘图包装不进入analysis implementations、不新建“SCP方法”。有依据才写技术说明，不把来源图搬进Wiki。需要库级接口含义澄清可用CLI更新隔离副本，保留user区块。

每个实际计算<=10min，出错留日志、不自动安装、不运行青光眼原课题。不要再引入隐式tempdir状态缓存、重跑包.onLoad或把残留副作用写restored=true。绘图本阶段在新R进程运行，但检查做过/没做过如实说，不外推共享会话无副作用。

阶段完成写result.md、groupheatmap-verification-matrix.md和source-map（来源/拆分入口/清单/参考/产物/证据/作者门），更新progress。原coverage文件只是上一阶段候选，可在报告标注存在待校正项，不需要本阶段花时间重写它。不改后端、不跑全库长回归。模型无图像读取能力则把目检留给Codex，不能记未做的检查；Codex会实际打开原图和提炼图并独立复核。完成一项可审的真实点阵分支后就返回，停止在审查点。
