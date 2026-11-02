# 全库第一轮审查：继续实际实现，不在清单停步

142导出唯一、22可视化入口及主要plot_type枚举已由Codex独立核对，未缺项。代码/笔记全库交付仍远未完成；不能以P1完成结束用户任务。以下是下一轮的实施要求，不是让你只写意见。

## 必须先修的真实闭包漏洞

1. 你的impl-contracts把RunNMF、RunMDS等UseMethod泛型闭包写为0，却遗漏NAMESPACE注册的S3 Seurat/Assay/default方法。NAMESPACE有30条S3method注册；应逐一核对闭包与真实分派，不能只抽泛型三行。需私有分派/注册方式，不能向作者全局注入一堆方法。RunNMF还要分别声明RcppML/NMF后端。S3代码存在不等于使用泛型真的可以到达。
2. RunDimReduction闭包只有invoke，Integration_SCP动态invoke(<backend>_integrate)等也不能靠词法函数扫描穷尽。按真实分派枚举并加入实际被调用方法/后端，按选中分支延迟查包。缺少导入绑定、ggproto对象、数据和Python资源同样会使“闭包”不闭合。
3. 不要把原check_R的安装器带来的BiocManager/devtools列成科学函数必需包，或真运行安装器。先将安装/下载/建环境基础设施替换为明确无安装的依赖检查，再计算有效调用闭包；不能在每个绘图/分析入口加载所有包。保持原始函数算法，修改基础设施需记录。

## 从清单推进到全库代码、契约和知识入库

目前77条analysis/analysis_backend/visualization导出没有实际可调用资产/runtime/收据映射。coverage提取片段与静态JSON不是交付给课题的完整模块。下一轮重点完成所有分析后端的实际模块与现有家族implementation，再完成22种原生可视化的可调用模块与可发现目录；不能继续把大部分时间用在isOutlier/调色板等helper上。

- 优先一次写可复现生成/装配工具，生成每个入口或家族的真实私有模块、必要局部资源、runtime.json、参数/输入输出/依赖/限制与not_run证据，再逐个运行可用例。不能复制整个SCP-local充数，也不能只有README和TODO。
- 一个原生对象入口合理时保留对象；只有原实现需要Seurat才依赖Seurat，不把额外全SCP包作为前提。Python后端实际探测既有隔离解释器，未探测不能写缺失。
- 非法“unprobed:scanorama”等同时notes写“缺Python包”必须修正。实际未探测、缺包、缺数据、上游运行失败分别记录。
- 原有13个SCP家族仅在其自身代码与收据仍有效范围内复用，不降级或覆盖旧通过实现。需要新增backend时新id及独立当前收据，修改代码影响兄弟收据要正确重验。
- 缺依赖也把真实原代码及可复制模块、调用契约和有用的中文判断写进Wiki，不保留“稍后整理”空骨架。图样来源待签核时继续其他对象，不因此停全库。

## 独立参考及新增事实

Codex用真实pancreas_sub独立运行了CellDimPlot、FeatureDimPlot、FeatureStatPlot五种形态、FeatureCorPlot和MDS cmdscale原版，输入不变。参考位于`E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles/`，命令脚本同维护记录/scripts/codex_native_oracles.R。你可只读参考和复用真实输入，不把这等同于你的提炼版已验证。FeatureCorPlot是相关性矩阵+边缘分布的复合原生输出，P值基于细胞，不能作独立生物样本推断。

NMF0.28虽已安装，Codex真实调用SCP RunNMF.default(nmf.method='NMF')及直接NMF::nmf，同一真实counts子矩阵都报`'what' must be a function or character string`；证据logs/codex-nmf-oracle-probe.log。不要仅因为installed就标verified，也不要临时替换算法/修统计来凑通过；如尚未排除环境原因明确记录原版运行失败，继续其他分支。RcppML缺包是另一分支的不同事实。

作者已确认的fig17已由Codex完成正式scaffold/verify/mark-ready，正式API ready、独立性verified。不要用你旧快照的pending状态覆盖回去；本轮不再修改它。全库方法/可视化才是主线。

## 随后补充的NMF独立实测（优先于前段早期故障口径）

Codex进一步隔离后发现：**干净R进程中的NMF::nmf实际成功**，只读固定源码原样RunNMF.default函数体、原样as_matrix，加其真正所需的NMF/SeuratObject导入后也实际返回DimReduc成功。详见native-oracles/nmf-native-minimal.json、nmf-native-minimal.rds和scripts/codex_nmf_native_minimal.R。前述错误来自整库加载后的环境上下文，不能据此断言NMF包或原算法不可用；恰恰要避免整库环境干扰。参考输入仍同一真实counts子矩阵，未换数据或算法。NMF可作为本轮可运行分支继续验证；RcppML仍缺包，二者状态分开。

另外现后端实现收据要求files覆盖当前code/全部文件，向既有家族code/增文件会使旧收据失效；必须实际重跑受影响旧verified分支并保留原证据，不只把新增文件hash塞进旧收据。不要为绕过此要求擅自放宽验证器或伪造旧运行，优先复用其已有验证脚本并核实当前实际调用路径。

## 下一轮产出

实现优先，至少把55条分析/后端及22可视化入口的**实际可调用模块和中文知识映射**推进到完整资产，而不是再次只报清单。继续现有同一会话wakeful-ravioli；2400秒有界等待，到界限保存可续检查点，不说全完成。不要为报告措辞耗几百次工具；实际文件、命令、测试与被编译的Wiki判断才重要。Codex随后独立审查；不部署、不代签新图、不安装、不启子代理、不访问paper-harness。
