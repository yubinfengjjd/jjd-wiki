# 第二轮：独立运行后的剩余问题

上一轮已修的嵌套加载、factor误转换、顺序一对多、联合键冲突均已在Codex新进程复核。Codex另独立重跑固定上游原函数，值矩阵和比例矩阵与当前候选identical，重复调用成功，输入不变。以下仍需修复，禁止扩展DE/后端/其他函数。

1. **序号契约未执行**。直接函数与CLI共享的build_matrices仍接受NA、Inf、小数、负数序号，违背接口int且从1起。Codex真实RED：logs/codex-dot-review1-corrected.log，四项均未拒绝。matrix_order/group_order/feature_order均需finite、非缺失、正整数；联合键三列为非空非缺失字符串，拒绝重复列名与空表，避免静默认领。不要改变合法整数顺序（不要求连续）。
2. **普通合法标签带单引号即失败**。Patient's ductal cells实际报panel_fun eval(parse) unexpected symbol。同样matrix名和reticle/style字符串也嵌入了代码。把这几个用户字符串当字面值处理，用安全引号或原生闭包捕获，保持绘图几何/顺序/图例和原生固定PNG/SVG一致；不执行数据字符串。用引号/反斜线/双引号/中文及像代码但只能显示的标签测试，记录source-faithful compatibility change。
3. **svglite依赖虚假可选**。render.R无条件device=svglite::svglite，但runtime标可选并声称有svg fallback。本批为字节保真优先，直接将svglite列required、文档同源且运行前检查缺包清楚报错；不要引入未经对照的fallback。同步新闭包并真实重跑回执。
4. **文义有误**。实际native layer_fun把格背景画白，zscore映射圆点fill，不是“zscore底色每格叠加空心/实心点”。README/layout/source-map/接口请写圆点颜色=聚合变换表达、点的直径=percent（原式size=dot_size*perc，非面积正比），背景白；顶部色条仅分组身份。percent来自原逐细胞表达经原调用声明的lib_normalize后、聚合/zscore前的>exp_cutoff比例，不能写成聚合value列>cutoff。只有1m、2mSVG对照，reticle仅PNG，不能写三分支SVG均有。PDF未比较不能写结构一致。正式版式正文不要留下不明的candidates/相对路径，指向对应画廊code/与本工作区候选的完整路径，仍说明无正式模板。
5. **保护旧证据**。接口columns描述修正可保留，但已修改旧ht1 verify.json和verify输出。保留原baseline旧收据到本批history再接受新真跑收据，不覆盖后假称没变。不要改旧status/user/id/favorite或原生源码。新画廊含spec.json的render入口、replica入口须实际可运行且输出一致。

通过后更新当前候选/画廊对应文件、真实命令和官方runtime_facts。仍draft/pending_signoff、无scaffold越门、不部署。核心library()会附加依赖包到search；不可声称零共享会话副作用或options已恢复，文档明确CLI新进程是隔离推荐方式。不要花时间重构旧ht1或整库包生命周期。当前固定图已做Codex视觉检查，长标签未见明显裁切；作者签核仍独立。
