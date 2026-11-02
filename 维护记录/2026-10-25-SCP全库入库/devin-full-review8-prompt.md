# 同一SCP全库任务，接续被监控文件锁异常中断的review7

继续原会话pickle-gorgonzola。上一进程11208已结束，无其他编码者在运行；不是任务完成。所有改动仅B=E:/research-wiki-env/work/scp-full-ingest-20261025。你是唯一编码者，Codex只审查/验证；不子代理、不安装/下载、不碰paper-harness、不写正式Wiki/画廊、不代签。审查证据A=E:/research-wiki/维护记录/2026-10-25-SCP全库入库，只读。

先读B/codex-review8-new-evidence.md及本轮原prompt中的剩余要求（A/devin-full-review7-prompt.md）。**现在不要继续扩写AST生成器或再次整库盘点，先实际source一个模块并执行公开MDS/NMF，修复真实RED。**

## 优先阻断

1. 当前v3全部79个模块source都失败！Codex逐模块、异目录、新R进程复制清单实测：A/codex-module-load-20261026T065620.json（source-only，非算法），0/79 loaded，且所有snapshot_still_current=true。错误是`.lazy_sym`的delayedAssign第一个参数被替成符号而不是字符串；非标准操作符报object '%>%'/'%+replace%'/'%v%' not found，普通符号报invalid first argument。修成真正延迟绑定，不改原算法。先用公开MDS和NMF真实调用确认修复，然后再生成全部。
2. 原公开算法probe A/codex-module-probe-20261026T065106.json也是RED，R exit0仅因tryCatch写错误。复用A/scripts/codex_module_probe.py的思路，切勿私有default绕过公开entry。新原生LargeVis对照已成功：E:/research-wiki-env/work/codex-scp-native-largevis/largevis-native.rds及json，40观察x60真实基因、uwot::lvish，参数perplexity3/neighbors10/epochs100/threads1/seed11。不能继续说LargeVis缺Python包。
3. v3的新AST仍未递归外层命名空间call的head（pkg::fn(...)）；普通call head已补，勿重复改错。声明可能漏uwot等真实包。用真实函数而不是凭rowcount验证。
4. asMatrix纯R shim索引有误：原src/asMatrix.cpp对rp、cp均0-based；现shim只rp+1，cp未+1。不改原始source，也不顺手修原as_matrix源码中inherits(matrix...)的上游bug；只校正你新写的兼容shim并记录范围。现调用通常走原as.matrix分支，不能因为未触发而说shim已等价。

## 冻结并完成剩余交付（上轮花太久在生成器，尚未做）

- 真正的最小闭包：只按调用分支加载，Slingshot show_plot=FALSE不加载绘图，Monocle成熟core复用；同一个函数的不同分支不能用默认大闭包声称最小依赖。算法包传递依赖正常保留。
- 修scripts/integrate-wiki.py的元数据/分类/收据路径，scripts/fill-pages.py的科学说明。RunFR力导向图布局、RunLargeVis R uwot、CellScoring三种method、PAGA/Palantir并入既有trajectory-inference、WOT明确时间输运、Integration_SCP归workflow，RunDEtest pairwise非受试者配对，RecoverCounts真实Seurat/counts层与推断假设。检查每入口矩阵方向。
- 恢复11旧页作者user区块原始字节（A/codex-protection-current.json）；不要read_text->write_text规范化/增长CRLF；status/id/favorite不变，不写SHAP/回归伪SCP内容。用正式pages helpers和原始user块比较，依赖仅required R+Python，空列表[]。
- 收据必须在**最终family assets**冻结后，实际复制该清单文件至异目录运行，算法/portability分开；不要把coverage/modules的旧receipt原样复制进family或重绑hash。保留13旧verified和12ready_for_use能力，真实重跑必要旧入口，A/codex-legacy-verified-replay-map.json有可重放线索。
- 22可视化逐项真实契约/签名/最小例/来源/验证范围；用现有真实原生图准备来源草稿，官方ingest，未作者确认不scaffold-template/ready。保持正式17个旧模板；不能22个code目录代替图样入库。
- 142映射helpers要真实消费者/路径，不是“见consumers”而无字段；GeneConvert/PrepareDB是函数不是数据。状态从官方provider派生，不用临时passed数组填绿。
- 先少量公开真实case→再冻结最终整合→重跑旧能力→必要官方check-entry一次，别反复重造生成器。记录未完成准确项，但不要因完成一个helper/清单自称全库完成。

请持续执行到本轮可审查成果，不再只写计划。最终更新progress/result/verification-matrix及真实机器映射，保留所有旧失败证据。Codex独立审查，尚未通过不部署。
