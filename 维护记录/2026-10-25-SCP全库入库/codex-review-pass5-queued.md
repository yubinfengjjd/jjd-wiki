# 公开入口和嵌套source实际失败（Codex独立复现，待本轮返回修复）

证据`codex-module-checkpoint2.json`、`scripts/codex_module_probe.py`，独立复制路径`E:/research-wiki-env/work/codex-scp-full-probe`，只复制runtime.files，新进程真实counts矩阵。

1. **公开S3入口失败**：`source('RunMDS/code/module.R',local=env); env$RunMDS(x,assay='RNA',nmds=3,verbose=FALSE)`报`no applicable method for RunMDS ... matrix,array,double,numeric`。RunNMF公开入口同样失败。直接取`attr(entry,'scp_module_env')$RunMDS.default`却成功。因此验证器用call_method绕过公开入口时，不能据此授予公开entry可执行。需修复私有S3分派/注册，保持原generic/Seurat/Assay/default语义；对30个S3注册对应模块核查。公开入口和依赖它的RunDimReduction真实调用是验收，不是只call_method。
2. **嵌套课题driver找错根**：新建nested.R仅`source('RunMDS/code/module.R',local=environment())`，最外driver再source nested.R，报`.../codex-scp-full-probe/fns/asMatrix.R is not an existing file`。`.find_ofile`从1递增返回第一个外层ofile，须拿当前最内层source文件，不能只测直接source或直接Rscript。独立两模块先后加载的公开入口各调用也要测试，不能因private default有函数就称完成。
3. 当前coverage/modules混存旧v1与v2：98目录，19旧manifest仍kind错误/无implementations。例如BBKNN_integrate旧目录与bbknn-integrate新目录同时在。保留历史证据不等于把旧无效模块仍算交付；最终权威index/coverage/Wiki复制必须只认当前有效目录，旧证据移到明示历史目录（不删证据）或明确exclude，不能造成大小写/下划线名称查找错取旧版本。
4. scope检查：native plot公开入口应与algorithm公开入口相同验收严度；源码加载、私有helper检查、退出0不能替代公开API实际使用。

这些是具体可复现工程修复，不需要作者新决定。修复仍由Devin同会话完成，Codex不修改实现。继续全部SCP入库而非停在两例。

5. 本轮16:08UTC新写`coverage/modules/runnmf/verify/nmf_method_NMF.json`仍state=passed但checks里`search_unchanged=False`；outputs为空，未保存实际NMF输出，case也未声明immut_inputs，不能称输入不变已查。不要把diagnostic false当装饰文字；要恢复允许副作用/明确失败，并在真实checks gate中计入。NMF加载其成熟包引起attach可隔离/恢复；用户原有包保持。该收据仍绕private default而非公开入口，上面R1未解决时不合格。算法数值对照本身通过可保留精确范围，但不能误绑定到公开入口verified。
6. 原始check_R会自动安装/升级，check_Python亦可触发环境操作；exports.json把它们描述为仅缺包stop，混淆了原版与本轮guard。技术目录应写真实原版风险与提炼guard差异，不把原件描述为安全guard。compute_velocity_on_grid是绘图辅助网格计算，不得因coverage分类analysis_backend而写成RNA velocity科学算法implementation/计数；isOutlier为QC所属子步骤，同样不新造独立分析家族。