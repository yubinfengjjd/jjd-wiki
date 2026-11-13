# v2生成器后续审查点（生成中只读核对，待本轮返回后提交）

1. 固定源DESCRIPTION第8行为`License: GPL (>= 3)`，LICENSE.md是GNU GPLv3。assemble-modules2.py仍硬编码license='MIT'，已生成RunNMF runtime也如此，必须纠正全部生成物并保留正确许可证文件/来源。此项是来源事实，不是作者新决策。
2. 固定源SCP-analysis.R的5个Python后端仍调用`system.file("python", package="SCP", mustWork=TRUE)`。复制Python文件到resources但不修正这个定位调用，未来依赖补齐也会要求安装SCP。请用模块私有的明确资源解析，核对全部SCP包路径/命名空间/编译符号引用。Python本文件多数import在函数内部，至少不能因此加载不相关后端的包；最终manifest要声明Python模块依赖及资源，不能只写未被正式parser读取的python字段。
3. `asMatrix`原RcppExports是`_SCP_asMatrix`编译符号，不随源码复制。当前RunNMF模块把它复制进闭包；即使当前dense路径没有调用，也不能据此声称所有输入都独立。可复用旧本地化包已按src/asMatrix.cpp忠实翻译的纯R实现，记录基础设施变动并做真实稀疏/稠密对照，不引入新算法，也不要求安装SCP。
4. 泛型模块和具体算法分支不能混淆。若NMF算法已实跑、默认RcppML缺包，canonical implementation不得把“整个RunNMF默认可执行”呈现为verified。优先绑定清晰的NMF分支入口/默认参数，保留RcppML单独not_run；RunDimReduction、CellScoring和富集DB等同理。一条示例通过不能批准所有具名后端。
5. 对矩阵NMF，实际科学主体只需要NMF和SeuratObject返回类；Seurat输入适配可额外依赖Seurat，但不要强制矩阵输入加载整个Seurat。跨其他core/Seurat适配器也检查此界限；既有monocle2/3 core入口等可复用。
6. 22个可视化入口/具名形态必须能从Wiki/图库发现并读到实际模块，不只是coverage/extracted文件夹和technical正文中的孤立文件路径。已有图样/模板复用；有本地真实原生图像的新增来源做单panel目录草稿并链接真实native实现。缺材料的如实记录，不能用文字条目冒充已回放的模板，更不能把3D截图当交互。

待最终真实复制测试后再验收，不重复前轮helper小例。全任务继续，不能在本文件或单个模块完成时停止。
