# 必须先修正的运行保护与可移植性（Codex已停止本轮执行）

Codex精确停止了ACP45284；当时未发现本任务活动Rscript进程。旧文件保留，未发布。R-lib-scp目录最近写入仍为10月22日，未见本次新增包。停止原因是下面实际代码缺陷，修正后继续同一全库任务，不结束、不安装、不启子代理。

## R1 生成代码把禁止安装保护覆盖掉了

coverage/modules/RunNMF/module.R先定义env$check_R为no-install，随后又eval原始utils/check_R.R，后者会调用BiocManager/devtools/install.packages并覆盖安全函数！其他模块同样有风险。check_Python及PrepareEnv等也要防止覆盖。**在解决并实测guard之前不得再执行这些模块的可缺包分支。**

先移除原安装/建环境函数从有效运行闭包与复制清单；生成无安装guard，并在全部原函数装载后最终绑定且可锁定，确认没有后续覆盖。Python guard必须先要求显式存在的RETICULATE_PYTHON，再调用reticulate，不能让reticulate自行下载/创建解释器。检查版本不满足时也只报错，不升级。对不存在的假包/模块做真实拒绝测试，拦截installer调用验证从未触发；测试前后包目录不变。保留现有真实原始source档案，不运行里面的安装器。

## R2 当前“standalone”实际仍回读整个工作区

module.R硬编码E:/.../coverage/extracted/及coverage/resources绝对路径，runtime.files指向这些外部树中路径却不在该module根下，连入口module.R都不在files里。异目录只复制声明文件根本无法运行。run-module-case.R名叫verify-iso却仍source原始B/coverage/modules，没复制清单，不能作为独立性证明。

每个模块真实自包含：code/入口+必要原函数/局部helper+data资源，所有路径相对本模块。source路径用当前最内层ofile或显式module_root，不能依赖CWD/原工作区。只复制runtime列明文件和资源到无来源路径的全新目录，新Rscript实际调用并记录，错误与未测如实。测试驱动/输入可在复制包之外，但任何运行函数/资源不能回读B的extracted树。不要用打包整个SCP或把B目录当隐含安装依赖糊弄。

## R3 必须使用正式runtime_contract，而不是自造JSON

现在kind='scp-module'、language='R'、required_packages为列表、resources为字符串、files缺入口、evidence.portability='declared'都不是正式Schema。请直接读B/development/staged/research-wiki/rwiki/runtime_contract.py及已有家族runtime.json，使用kind method/template、language r、required_packages {R:[...]}, resources对象、真实文件列表/入口函数、独立运行收据指针。规范id小写，与最终家族/implementation一致。逐模块用官方load/implementation_runtime/runtime_facts核对，再说声明/verified；测试失败不得重绑旧输出。

## R4 当前收据字段不是真校验

run-module-case.R把tools::md5sum写在module_sha256和outputs.*.sha256下面，这是32字符MD5，不能冒充SHA256。另cs$checks静态文字和“未抛错就passed”不证明原版等价、输入不变或算法正确。请真实计算SHA256，记录原输入/代码/输出；对图运行原版与提炼版同输入比较，对算法比较实际结果或规定等价量。expected_error/native_failure不能升级为算法passed。官方算法/portability分开；原source成功也不能替代最小模块执行。

## R5 模块隔离与相关依赖

所有模块当前暴露共同全局.scp_module_env，入口函数运行时从这个共享名字取函数，第二模块加载可破坏第一模块。应让每个公开入口闭包捕获自己的private env，helper和imports不放全局。正反顺序加载两个不同模块后实际各调用。对ggplot返回后才求值的包引用保留在模块私有导入环境，不能靠把所有潜在包永久attach到用户search；更不能detach(unload=TRUE)卸载作者已加载的namespace。新进程为默认隔离方式，如有共享会话局限如实写，不假恢复。

相关依赖按选定后端/功能分支：RunNMF的NMF分支不应要求缺失的RcppML，矩阵输入也不应强制完整Seurat（CreateDimReducObject在SeuratObject）。绘图bar不要求venn等可选包。相关成熟包的传递依赖保留，不用regex猜测一大堆名字后全部attach当作最小依赖。原check_R安装器引入的BiocManager/devtools不属于算法必需依赖。

## 已澄清的NMF参考，必须读取

Codex新实测`native-oracles/nmf-native-minimal.json`：固定源RunNMF.default函数体未改，原as_matrix未改，最小NMF+SeuratObject导入，在干净新进程对真实counts矩阵成功返回DimReduc；参考nmf-native-minimal.rds可比较。直接NMF::nmf干净进程也成功。之前整库加载上下文报错不是NMF不可用，见上一审查文件新增补充，不把它误判成包/算法失败。

## 继续全库而非再次只修helper

修好生成器保护/格式/真实复制后，一次生成全部55分析后端+22可视化的正式可复制模块，补真实Wiki家族implementation/入口和简洁中文契约/限制。这仍是全SCP任务，不单独停在生成器。新图未确认保持draft，但其他方法/图继续做。已有已验证实现因新增code文件需实际重跑旧有效例；不伪造签核/收据、不放宽验证器来隐藏问题。

先跑无安装保护、矩阵MDS/NMF与一个原生绘图的实际独立拷贝检查，通过后批量推进，不要把所有时间用在重复读源码/报告措辞。3000秒有界轮次；保存实质进度检查点供Codex续做，无需等用户再说继续。只写B，仍不部署、不改正式库、不访问paper-harness。
