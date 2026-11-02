# QA report

2026-10-21T08:50:48.583113Z

机械检查只核查文件、像素尺寸与宽高比；不判断视觉像不像，不代表作者签核。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| README.md | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/figure_spec.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/estimated_data.csv | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.pdf | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.svg | PASS | 文件存在且非空；不等于格式或视觉验收 |
| compare/side_by_side.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| thumb.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| run.log | PASS | 文件存在且非空；不等于格式或视觉验收 |
| 复刻代码 | PASS | 需要 replica.py 或 replica.R |
| 原图存档 | PASS | source/figNN.png |
| original 可打开 | PASS | PNG 872×777 px |
| replica 可打开 | PASS | PNG 4200×3742 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×428 px |
| 宽高比 | PASS | 相对误差 0.0115%，阈值 ≤2% |

## 人工视觉 QA（agent已逐项目视；不是作者签核）

| 项目 | 结论 | 证据与限制 |
|---|---|---|
| 画布与宽高比 | PASS | 原图整幅单panel；导出4200×3742，约600dpi；机械宽高比误差≤2%。 |
| panel布局 | PASS | 单panel、六类分组、背景首组高亮，均值菱形和圆点保留。 |
| panel标签 | PASS | 模型顺序ET/RF/XGB/MLP/GB/AdaBoost和标题保留。 |
| 颜色与发散方向 | WARN | 目视方向/配色接近；未独立测量DeltaE00中位数≤10，不宣称该阈值通过。 |
| 字体 | WARN | 实际Arial.ttf，源字体未知；本图英文，不含中文字符。字号为单图调整，非逐字像素等价。 |
| 坐标轴与刻度 | PASS | y范围5.9..15.3，刻度6.0,7.5,..15.0；类别45度旋转，无裁切。 |
| 图例与色标 | PASS | 未添加原图不存在的图例；颜色与各组一一对应。 |
| 数据形状与来源 | WARN | 60个y估读、6组箱体及均值独立估读；合成横向抖动逐值保留，不构成一致原始折数据。 |
| 注释 | PASS | Prediction error/Test RMSE(SR)与模型标签保留；均值作为独立估读输入。 |
| 导出与矢量文字 | WARN | PNG已打开并目视对比；PDF单页、字体全部嵌入；SVG含15个text节点。PDF/SVG独立查看器视觉和Illustrator编辑未测。 |

目视依据：source单图、output/review-preview.png、compare/side_by_side.png。

函数验证11项通过，见 compare/function-verification.json；不是统计或科学有效性检查。

needs_author：目视接受估读/字体/颜色近似及上述差异。作者姓名/日期/签核结论尚无，status=review。自动渲染共1轮，未降低检查阈值。
