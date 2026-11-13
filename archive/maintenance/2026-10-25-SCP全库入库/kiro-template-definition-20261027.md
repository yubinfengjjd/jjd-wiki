# 模板定义（作者 2026-10-27 采访结果，取代方案 B）

采访记录：`E:/research-wiki/.kiro/specs/scp-full-ingest/template-definition-interview.md`。答案：1A 2A 3A 4A 5A 6A；7 = a、b、f，另加"agent 先组织方法，再自主选图样绘图"；8B。

## 定义
1. **绘图模板的输入**：Seurat 对象及上游分析结果（如 srt@tools 中 RunEnrichment/RunGSEA/RunDEtest/RunDynamicFeatures 的结果、RunSlingshot 的 lineage 列）。直接调用原生绘图函数（已拆成独立模块），不改写成读表。依赖 Seurat 可以；不依赖 SCP 包本身。
2. **覆盖范围**：一个可视化入口 = 一个绘图模板（即现有 22 个可视化模块实现）。所有形态（plot_type、mark_type、edge_line、color_blend_mode、exp_method、split_method 等具名形态）都是参数，**每个形态单独验证**：一形态一用例，其余参数取默认值，不做笛卡尔积。
3. **验收**：同输入同参数下，与原生 SCP 输出逐像素一致（PNG），交互图比 plotly trace 字段；数值输出 all.equal。原生调用本身失败的形态记 native_failure，不入"已验证"。
4. **链路**：每个绘图模板写明上游方法和需要的对象槽位（例如"先 RunEnrichment（gene-set-enrichment 家族）→ srt@tools$Enrichment_<group_by>_<method>，再 EnrichmentPlot"）。验证用的输入对象由原生上游方法生成并以 RDS 保存，收据记录其 sha256。
5. **存放位置**：方法页（`methods/scp-viz-*`）下的可视化实现，沿用实现/收据/代码查看机制；不改 research-wiki 产品代码，不做五处同步。每个形态的验证输出图作为该页的"形态图样"展示（来自回放输出，不是来源原图）。
6. **CSV 表驱动模板**：已有 17 个和本轮做好的 11 个都保留（走画廊 → 代签核 → 模板流程），与 Seurat 版共存，服务"数据不是 Seurat"（7f）的场景；页面互相链接并说明各自适用场景。不再新开发 CSV 模板。

## 应用场景（写进页面"适用"与技术页使用说明）
- a. 自然语言出图：agent 按页面"形态图样"和适用说明选入口与形态，复制模块到课题，接课题 Seurat 对象出图。
- b. 已知函数：直接取模块代码与依赖清单（runtime.json），按收据判断哪些形态已验证。
- f. 非 Seurat 数据：用 CSV 表驱动模板（接口页列出列定义）。
- agent 自主组织：先按方法家族组织分析（方法模块 + 收据），再按链路找到能消费该结果的绘图模板，自主挑选形态出图。
- 使用记录（8B）：出图后由 agent 提议记录，作者确认后才执行 record-use / record-method-use。

## 对执行计划的影响
- S10 画廊/代签核/模板流程只用于 11 个已完成的 CSV 模板（及 3D 两个 draft，按原决定）。
- 新增主线：为 22 个可视化入口的每个具名形态补齐原生对照用例并运行收据；页面写形态表（参数值、状态、收据、形态图样）与上游链路。
