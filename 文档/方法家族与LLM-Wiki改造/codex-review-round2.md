# Codex 复核：第二轮（2026-10-23）

第一轮五项修复已检查到实际内容：八步规则、15页来源对照、迁移表与共享分支显示均已落地。前端30+9检查/typecheck/build由Codex重跑通过，source/user/status完整性和正式/staged规则相等通过。正在重跑修复版435项与R分析，不要把进行中检查标为最终通过。

真实IAB浏览器在审查服务127.0.0.1:8786确认默认目录15家族、辅助11项；整合页首屏用途、对象与各分支范围正确。截图API不可用，AX证据已保存维护记录/browser-{methods,batch,source}-ax.txt。

## 两个明确遗留（只修这两类，禁止扩大范围）

1. **资料类型仍被标成“分析方法”（P2，实际复现）**：SCP源码本地化页正文说技术资料，但面包屑仍为“方法库 / 分析方法”；批次整合页反向链接把源码/流程页的title tooltip也标为“分析方法”。位置：frontend/src/views/PageView.tsx约94和219，使用TYPE_LABEL[b.type]/TYPE_LABEL[meta.type]，type=method不能代表method_kind。请让面包屑、反向链接等按method_kind显示“分析家族/组合流程/技术资料/待分类”，保留旧路由和id。检查知识网络中相同类型说明，不改变图谱拓扑。加真实source/workflow页SSR断言，npm test/typecheck/build。
2. **历史环境断言仍冒充当前事实（P2）**：实际source页AX中“不适用”仍说“本轮未安装Seurat/SCP依赖，未运行SCP算法”；技术页/旧流程还保留Matrix环境失败等“当前/本轮”描述，与本次R环境实测矛盾。保留旧原始代码字节、user/status，但编译正文是agent可维护层，不能只在loader verification.md顶端加说明。请检查11个旧技术/流程页，将这类旧环境/旧验证语句明确标为2026-10-22历史记录并链接当前规范家族验证范围；没有现证据的分支保留not_run。不要广泛改科学说明或删除历史；不得把“后来安装/测试过部分”扩为所有算法已运行。重新save/记录必要验收指纹，不改作者状态。

执行仍由Claude单进程完成、不安装依赖、不部署、不调用Codex子代理。写claude-review-round2-result.md并更新总报告；只跑受影响前端/规则/内容检查，未改算法不重复科学测试。此前Codex独立R和pytest仍在运行且不会与你改的正文争写。
