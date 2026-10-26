# 密度散点与边缘分布（单 panel）

复制code/为density_panel后调用plot_panel(tables,style)，或用原render入口读取spec约定CSV。无训练/统计计算。

数据：points=render-scatter-rgb.csv；histograms=render-marginal-bars.csv

输入已有坐标、RGB和边缘条；不拟合、不算KDE/直方图、不从RGB倒推频数。1:1线要求两轴同定义同量纲。需要色标时显式传 show_colorbar=True、color_range、color_label，确保上游颜色策略一致；默认不假定颜色是频数。

散点不随点数无限增长。默认7×6.2215英寸，预留上下刻度边距；很长的轴标题等可能需显式增加尺寸/边距，固定比例越界会报错。图形回放 example/style.json 使用原比例、原刻度与原标注。

示例点/RGB/边缘条均为旧估读；拟合线、指标、Test(XGBoost)只在 example/style.json 中，未由点重新计算。右边缘保留旧0..40，原单图为0..20，沿用前次已说明的差异。默认复用不带这些旧标注。

2026-10-21 作者确认模板回放，状态ready。详见同名Wiki页面与verify/目录。
