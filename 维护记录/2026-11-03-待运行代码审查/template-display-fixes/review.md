# 模板显示修复与复核

本轮 30 个模板全部从隔离副本生成新 PNG、PDF、SVG。正式 `verify/` 采用经输入和输出 SHA256 核对的本轮产物；旧 `verify.json` 逐份保存在 `verify/history/`，没有以已有预览充当复跑结果。完整初检见 `../visual-qa/review-pass2.md`，正式采用清单见 `../template-evidence-adoption.json`。

七项显示修复经重新运行和 PNG/PDF 联检：marker UMAP 增加轴文字边距；ring 标签启用排斥；rose 增加极坐标边距和标签排斥；trend、area、bar 增加轴留白；dot 示例纵轴标题由 Percentage 更正为 Phase。area 最终修复位于实际使用的非 dot 分支，依据 `replay-pass6.json`。自定义标题入口保留。原始来源、示例观测值、分组、统计公式没有改动。

执行通过不等于没有可读性限制。marker UMAP 的浅色点对比度仍较低；rose 中心计数密集，ring 的零值标签及 volcano 的大量基因标签也须结合输出尺寸阅读。未删减标签、筛除观测或更换统计定义以掩盖这些限制。模板结果不代表新生物学结论。

独立只读复核覆盖 30 项输入/输出/新收据哈希及旧收据保存，并联检七项修复后的正式 PNG/PDF；结论和具体检查记录另见 `../final-review/`。本记录仅总结实际观察，保留初检和各次重跑文件，失败的运行器尝试也没有改写为通过。
