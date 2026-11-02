# 公开入口和嵌套source实际失败（Codex独立复现，待本轮返回修复）

证据`codex-module-checkpoint2.json`、`scripts/codex_module_probe.py`，独立复制路径`E:/research-wiki-env/work/codex-scp-full-probe`，只复制runtime.files，新进程真实counts矩阵。

1. **公开S3入口失败**：`source('RunMDS/code/module.R',local=env); env$RunMDS(x,assay='RNA',nmds=3,verbose=FALSE)`报`no applicable method for RunMDS ... matrix,array,double,numeric`。RunNMF公开入口同样失败。直接取`attr(entry,'scp_module_env')$RunMDS.default`却成功。因此验证器用call_method绕过公开入口时，不能据此授予公开entry可执行。需修复私有S3分派/注册，保持原generic/Seurat/Assay/default语义；对30个S3注册对应模块核查。公开入口和依赖它的RunDimReduction真实调用是验收，不是只call_method。
2. **嵌套课题driver找错根**：新建nested.R仅`source('RunMDS/code/module.R',local=environment())`，最外driver再source nested.R，报`.../codex-scp-full-probe/fns/asMatrix.R is not an existing file`。`.find_ofile`从1递增返回第一个外层ofile，须拿当前最内层source文件，不能只测直接source或直接Rscript。独立两模块先后加载的公开入口各调用也要测试，不能因private default有函数就称完成。
3. 当前coverage/modules混存旧v1与v2：98目录，19旧manifest仍kind错误/无implementations。例如BBKNN_integrate旧目录与bbknn-integrate新目录同时在。保留历史证据不等于把旧无效模块仍算交付；最终权威index/coverage/Wiki复制必须只认当前有效目录，旧证据移到明示历史目录（不删证据）或明确exclude，不能造成大小写/下划线名称查找错取旧版本。
4. scope检查：native plot公开入口应与algorithm公开入口相同验收严度；源码加载、私有helper检查、退出0不能替代公开API实际使用。

这些是具体可复现工程修复，不需要作者新决定。修复仍由Devin同会话完成，Codex不修改实现。继续全部SCP入库而非停在两例。

5. 本轮16:08UTC新写`coverage/modules/runnmf/verify/nmf_method_NMF.json`仍state=passed但checks里`search_unchanged=False`；outputs为空，未保存实际NMF输出，case也未声明immut_inputs，不能称输入不变已查。不要把diagnostic false当装饰文字；要恢复允许副作用/明确失败，并在真实checks gate中计入。NMF加载其成熟包引起attach可隔离/恢复；用户原有包保持。该收据仍绕private default而非公开入口，上面R1未解决时不合格。算法数值对照本身通过可保留精确范围，但不能误绑定到公开入口verified。
6. 原始check_R会自动安装/升级，check_Python亦可触发环境操作；exports.json把它们描述为仅缺包stop，混淆了原版与本轮guard。技术目录应写真实原版风险与提炼guard差异，不把原件描述为安全guard。compute_velocity_on_grid是绘图辅助网格计算，不得因coverage分类analysis_backend而写成RNA velocity科学算法implementation/计数；isOutlier为QC所属子步骤，同样不新造独立分析家族。
## 续做执行要求：先修证据保留，然后实际入库全量
Codex已精确停止pass4 ACP29800及其孤儿graphplot nn_graph测试，其他进程不动。停止原因：assemble-modules2.py第395行shutil.rmtree(mdir)每次重建抹掉verify/verify-iso证据。现存可复制收据已保存在A/pass4-prestop-evidence；旧iso临时目录与事件日志仍在。不得再删除历史证据，必须先把每次真实调用收据/日志/代码闭包快照保存到稳定独立run_id路径，新代码只让旧收据过期、不改写/删除旧失败/通过证据。覆盖code可先版本备份，正式源/作者字节绝不覆盖。
必须修正本文件公开S3入口、最内层ofile和false diagnostic门槛，再一次稳定重建全模块。别再每修一个case就删除全树并只跑私有helper。你说MDS dispatch passed并不能推翻独立公开调用失败，复现脚本已给。case args必须查真实公开签名，例如GraphPlot需node+edge，不接受srt/graph_name/group.by，不能把坏driver归not_run缺科学材料。末尾无相应entry的expheatmap等假名字也不要混进覆盖。
接下来主要交付应是B/wiki真实规范页/implementation资产与22视觉技术目录，不是再一整轮仅调生成器。可运行分支精确标当前真证据，不合格/缺包/缺材料分支保留not_run并继续收录。源码完整闭包和输入/参数/输出/单位/前提/限制都须实际写齐。
按顺序：1安全稳定生成和上面公开入口/双模块/嵌套测试；2整合55分析后端去重映射与22可视化资产/契约、helpers/environment/resource/reexport归属目录；3给已跑分支真实对照、其他分支准确not_run；4官方lint/check-entry并生成完整机器可读映射。不能先用半小时重复跑故障case再留Wiki空白。已有可用实现受新增code使旧收据过期，需实际重跑相应旧例，不放宽验证器。
Codex补充原生参考在E:/research-wiki-env/work/codex-scp-native-structures（9个额外结构PNG/SVG/真实对象不变），脚本A/scripts/codex_native_structural_oracles.R。5个GroupHeatmap（violin两种/flip/split-reticle/annotation）和4个CellDimPlot圈选。它们仅source reference，不是提炼分支验证；可用同输入/参数逐个比较。最初mark误传改为add_mark，失败证据另留。不要从这些图片直接代签新模板。violin原生默认各特征差异很大导致大多分布挤平，flip默认缺feature轴文字，字节一致不代表视觉可用；保留限制，不静默改统计。
本轮3000秒持续做完能做的全量入库和检查点，无需用户再说继续。Codex审查后才正式合并。只写B；不装包、不用子代理、不访问paper-harness、不写正式Wiki。原session wakeful-ravioli。