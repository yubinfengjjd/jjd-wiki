# v2生成器后续审查点（生成中只读核对，待本轮返回后提交）

1. 固定源DESCRIPTION第8行为`License: GPL (>= 3)`，LICENSE.md是GNU GPLv3。assemble-modules2.py仍硬编码license='MIT'，已生成RunNMF runtime也如此，必须纠正全部生成物并保留正确许可证文件/来源。此项是来源事实，不是作者新决策。
2. 固定源SCP-analysis.R的5个Python后端仍调用`system.file("python", package="SCP", mustWork=TRUE)`。复制Python文件到resources但不修正这个定位调用，未来依赖补齐也会要求安装SCP。请用模块私有的明确资源解析，核对全部SCP包路径/命名空间/编译符号引用。Python本文件多数import在函数内部，至少不能因此加载不相关后端的包；最终manifest要声明Python模块依赖及资源，不能只写未被正式parser读取的python字段。
3. `asMatrix`原RcppExports是`_SCP_asMatrix`编译符号，不随源码复制。当前RunNMF模块把它复制进闭包；即使当前dense路径没有调用，也不能据此声称所有输入都独立。可复用旧本地化包已按src/asMatrix.cpp忠实翻译的纯R实现，记录基础设施变动并做真实稀疏/稠密对照，不引入新算法，也不要求安装SCP。
4. 泛型模块和具体算法分支不能混淆。若NMF算法已实跑、默认RcppML缺包，canonical implementation不得把“整个RunNMF默认可执行”呈现为verified。优先绑定清晰的NMF分支入口/默认参数，保留RcppML单独not_run；RunDimReduction、CellScoring和富集DB等同理。一条示例通过不能批准所有具名后端。
5. 对矩阵NMF，实际科学主体只需要NMF和SeuratObject返回类；Seurat输入适配可额外依赖Seurat，但不要强制矩阵输入加载整个Seurat。跨其他core/Seurat适配器也检查此界限；既有monocle2/3 core入口等可复用。
6. 22个可视化入口/具名形态必须能从Wiki/图库发现并读到实际模块，不只是coverage/extracted文件夹和technical正文中的孤立文件路径。已有图样/模板复用；有本地真实原生图像的新增来源做单panel目录草稿并链接真实native实现。缺材料的如实记录，不能用文字条目冒充已回放的模板，更不能把3D截图当交互。

待最终真实复制测试后再验收，不重复前轮helper小例。全任务继续，不能在本文件或单个模块完成时停止。

## 2026-10-26续做与全量范围（用户最新再次明确）
上一ACP进程已经不在；pass3-state仍running是中断残留，不是另一个编码者。继续wakeful-ravioli同一任务，不重新发明计划、不启动任何子代理。
用户确认是SCP全部分析方法和全部可视化，不单单GroupHeatmap一个图。P0点阵已由Codex在正式库正常确认ready，B快照较旧，绝不改它或把状态覆盖回正式库。
请先看当前文件恢复上轮实质进度；修好本文问题和上轮未完安全/运行缺陷后，直接完成全部55分析/后端+22可视化，以及2workflow与其余导出分类映射。写入B/wiki规范家族的实际实现资产/源映射、技术绘图目录的实际模块和分支契约，不停在coverage生成器/清单。不必把每个导出变成一个家族；先查现有家族，语义去重。未运行分支有实质代码、准确依赖/数据要求/参数/返回契约和not_run证据；安装情况未知不得称缺包。新图需要作者确认的不代签，不能因此停止其他内容。
核对正式runtime_contract.py与method_implementations.py规则，所有新manifest实际用官方parser验证，无效不能称standalone完成。算法验证的passed必须有实际输出断言和原版对照；不能all(empty checks)视为通过、不能仅called_ok就写passed。不依靠旧输出重绑新哈希，测试命令应可复制重放。算法按具体后端独立收据，默认缺包不能获verified。
避免再用超过大半轮时间调一个例子。以真实交付为先：全部源码闭包/语义页/实现映射先补齐，再按现有环境逐批验证。原生参考与已有成熟core可复用，不重写算法。已有source/作者/status/id不变；新页面用正式scaffold（隔离配置）创建。无真实来源图时不能手建layout/template页，可用规范technical目录展示真实代码/契约与尚无回放。
更新progress.md/result.md/verification-matrix.md/source-map.md和机器可读coverage，把每个导出映射到真实Wiki页/资产/分支状态，不再重复第一轮清单当全任务完成。本轮可用3000秒，持续执行并定期保存检查点；不需要用户再次说继续。只写B，不安装/联网下载/部署/改正式库/读取paper-harness。