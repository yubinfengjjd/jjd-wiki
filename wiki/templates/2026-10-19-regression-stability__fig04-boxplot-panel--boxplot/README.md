# 箱线、散点与均值（单 panel）

复制code/为box_panel后调用plot_panel(tables,style)，或用原render入口读取spec约定CSV。无训练/统计计算。

数据：points=render-category-points.csv；summaries=render-box-summaries.csv

点与摘要须来自同一真实分析；图不计算分位数/均值/须或生成抖动。jitter显式提供且绝对值小于0.5；逐类摘要须满足 low≤q1≤median≤q3≤high。点可在须外，图不另重复画fliers。

默认 W=左右留白+n×每组最小0.8英寸，长标签还可增宽并增加底边距；n为实际任意合法类别数，无白名单。默认无宽度上限、不分面、不缩字；自定义色表不足报错，默认超出来源色数时按n生成颜色而不循环。可覆盖 sizing.item_width_in、plot_height_in、width_in、max_width_in 等。

示例点值、箱体与均值是独立估读，横向抖动为固定合成展示位置；它们不能作为一致的原始验证数据进行统计推断。换数据时由课题分析先准备同源点与摘要。

2026-10-21 作者确认模板回放，状态ready。详见同名Wiki页面与verify/目录。
