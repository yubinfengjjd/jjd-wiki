# 单 panel：箱线、散点与均值

本轮根据作者确认，仅做两类样式各一个代表；此条目为其中一个。旧六模型/三指标组图保持原样。2026-10-21，状态 review，尚无作者目视签核。

## 来源、范围与缺口

来源 [原帖](https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg)，Python机器学习AI，2026-10-19。原帖称模拟数据，未提供 Excel、完整绘图函数、OOF 数据生成和完整多模型评估。7 段原帖代码在 original_code/ 原样归档，未执行；previous_reconstruction.py 为先前 agent 重建代码，不是作者绘图函数。未知许可证，仅供个人研究参考。

代表图为原帖独立单图全文，bbox=(0,0,872,777)，没有遗漏其他模型 panel。source/fig04.png 与 full_original.png 字节一致；两份的独立哈希、原帖候选编号、旧估读数据及旧 renderer 哈希见 source/provenance.json。选定单位去重 dry-run 判为 new。数据沿用旧条目，不重新估读，不补训练/分析算法。

## 输入与统计边界

- `points`：一行一个估读圆点，`model,value,jitter`；60 行，每组10个。
- `summaries`：一行一个分组，`model,q1,median,q3,low,high,mean`；6 行。
- `columns={'category':'model'}` 为本次列映射；其他列也可在 columns 中改名。
- 箱体、须、均值与圆点 y 为独立估读，不能声称它们来自一致的10折原始数据。
- 横向 jitter 为旧 CSV 中固定种子20261021生成的合成展示位置；此次逐值保留，函数内不重新抽样。
- 适用真实新数据时，须先由课题分析代码算出统计表、声明须规则及观测点范围，再交给绘图函数；此函数不推断离群点。dots 可包含须外点，不另外重复画 fliers。

数据文件：points.csv + summaries.csv。estimated_data.csv 为 points.csv 的兼容副本。

## 可复制的函数入口

把本条目 `code/` 整个目录复制为课题 `scripts/boxplot_panel/`（保留 __init__.py、panel.py、panels.py）。在课题自己的环境安装已有依赖要求：Python3、numpy、pandas、matplotlib。示例导出还用 Pillow；不需要 sklearn 或原模型包。函数不读文件、不写文件、不训练、不联网、不安装包、不修改输入、无隐式随机数。

```python
import pandas as pd
from boxplot_panel.panels import plot_panel
tables = {'points': pd.read_csv('analysis/points.csv'),
          'summaries': pd.read_csv('analysis/summaries.csv')}
# 本次 style 可从 data/figure_spec.json 读取；换课题时明确替换列名、标签、范围和标注。
fig, handles = plot_panel('boxplot', tables, style)
fig.savefig('figure.png', dpi=600)
```

`style` 为显式字典：columns（语义列名→实际列名）、canvas_px、labels/annotation、坐标范围和视觉参数，见 figure_spec.json 与 panels.py 的 docstring。box 使用 order/title/ylabel，density 使用 xlabel/ylabel/fit/label；不存在通用 labels 键。返回 Figure 和轴/图形对象，可继续组合或导出。缺列、非有限值和非法 RGB/箱体顺序会明确报错。

`panel.draw(fig, rect, tables, style)` 采用包内相对导入，rect 为 figure 归一化区域，和独立 `plot_panel` 共用核心。已直接验证 adapter；正式 wiki `render` 尚未运行，需作者签核来源后再 scaffold/verify-template，不把接口兼容写成完成正式 render 验收。

## 本例运行与结果

```powershell
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
& 'C:\Users\86186\.codex\venvs\sci-figure-replica\Scripts\python.exe' -X utf8 'E:\research-wiki\画廊\2026-10-19-regression-stability\figures\fig04-boxplot-panel\code\replica.py'
```

PNG/PDF/SVG 均导出，PNG 长边4200 px，600 dpi；实际字体 C:/Windows/Fonts/arial.ttf，源字体未知。运行退出码0，命令、版本见 run.log。并排见 compare/side_by_side.png。独立 PDF/SVG 查看器视觉尚未测，结构检查不代替视觉签核。

实际隔离回放旧 renderer 与函数版比较：数据坐标、行序、颜色/拟合线/边缘条，或点/抖动/箱体/均值均在绝对容差1e-12内一致；字号、标记大小及布局按单 panel 调整。复制到不同工作目录、换列名、换输入规模/分组、缺列/NaN失败检查、共享 draw 核心通过。完整11项见 compare/function-verification.json。验证脚本需本机参考数据，仅复用函数不需要该脚本。

## 分析方法联想

原文用法：回归验证预测或划分间误差分布。迁移方法文字笔记见 [知识库笔记](E:\research-wiki\知识库\methods\repeated-benchmark-distribution.md)；源用途、编码支持的迁移及待验证设想分别说明，尚未实现迁移分析算法。

## 未决项

needs_author：目视签核；接受估读/合成展示限制；源字体/独立色差证据缺失；独立矢量查看器视觉。所有估读值不支持科学模型结论。仅本单 panel 待签核，不要求重做旧组图。
