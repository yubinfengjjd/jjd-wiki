# 当前短审查（只追加未闭合项，已通过不返工）

2026-10-26 08:44 UTC附近。先完成loader小改并用公开MDS/NMF/Graph/3D短回归，再做其他交付。自由符号扫描的NSE列名/局部变量不等于真正隐式依赖，不必逐个把所有变量绑定到包；优先受控baseenv+明确标准包函数/NAMESPACE真实导入，实际调用缺符号再按源码补。不要为此重写整个解析器或又花一轮整库盘点。

两个硬复现仍为handoff #1：用户全局matrix变量污染；detach固定两次留下package:generics。不要改原as_matrix源算法、不要要求作者预先删变量或手动detach。已有两个3D的外部build/HTML、Graph两种像素、MDS/NMF原生数值已通过，不再复活“删除所有新增options”做法；namespace新默认项如实记录，原有选项保护，算法临时新增选项另处理。

GraphPlot当前清单必要包是ggplot2/grid/reshape2/rlang，未声明Seurat；不要凭同一测试进程加载过3D就给Graph额外加Seurat。最终应有独立新进程/清单复制的真实Graph调用证据。

正式库尚未合入本轮候选。最后源素材/142真去向表/旧12ready-13verified/官方验收仍是整体目标，不能在source或单helper阶段声称完成。按handoff完成全部实物，未运行/缺依赖继续准确保留。

08:52正式前端只读复核：源码本地化页正确显示“方法库/技术资料”“笔记已确认”，默认方法目录仅15分析家族、12含已验证实现，来源页已不冒充分析可用；此处不需重写前端。**但源码页正文仍有旧句“6个分析族和可视化都引用这个本地包”**，会让后续agent继续选整库。请在B/wiki/methods/scp-local-source.md的agent正文更新为现行判断：整库为历史归档/审计/原版对照，当前课题优先各规范家族声明的standalone闭包，实际验证以分支receipt为准；历史兼容说明保留并标历史，不删除原source、不动user/status/旧ID。别复制这句过时说明到新页。A/native-oracles/formal-source-classification.png是本轮UI证据。
