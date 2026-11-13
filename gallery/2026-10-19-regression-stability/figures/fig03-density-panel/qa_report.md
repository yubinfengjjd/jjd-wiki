# QA report

2026-10-21T08:50:48.370090Z

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
| original 可打开 | PASS | PNG 1043×927 px |
| replica 可打开 | PASS | PNG 4200×3732 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×427 px |
| 宽高比 | PASS | 相对误差 0.0237%，阈值 ≤2% |

## 人工视觉 QA（agent已逐项目视；不是作者签核）

| 项目 | 结论 | 证据与限制 |
|---|---|---|
| 画布与宽高比 | PASS | 原图整幅单panel；导出4200×3732，约600dpi；机械宽高比误差≤2%。 |
| panel布局 | PASS | 密度主轴+两个边缘分布+内部色标为单逻辑panel，共4轴。 |
| panel标签 | PASS | 无新增A/B分面标签；Test(XGBoost)保留。 |
| 颜色与发散方向 | WARN | 目视方向/配色接近；未独立测量DeltaE00中位数≤10，不宣称该阈值通过。 |
| 字体 | WARN | 实际Arial.ttf，源字体未知；本图英文，不含中文字符。字号为单图调整，非逐字像素等价。 |
| 坐标轴与刻度 | WARN | 主轴0..100刻度保留；右边缘旧估读为0..40，源单图0..20，差异明确保留；y上限从旧组图110调至109以贴近单图。 |
| 图例与色标 | WARN | 绿低红高、0/1/2/>3和Frequency保留；RGB来自图形估读，不由独立频数重建，归一化含义未验证。 |
| 数据形状与来源 | WARN | 507图形检测，非原始样本；重叠/图像压缩造成不确定；边缘条保留旧估读。 |
| 注释 | PASS | 拟合式、R²/RMSE/MAE/r、n_split为来源标签转录，未声称重算结果。 |
| 导出与矢量文字 | WARN | PNG已打开并目视对比；PDF单页、字体全部嵌入；SVG含34个text节点。PDF/SVG独立查看器视觉和Illustrator编辑未测。 |

目视依据：source单图、output/review-preview.png、compare/side_by_side.png。

函数验证11项通过，见 compare/function-verification.json；不是统计或科学有效性检查。

needs_author：目视接受估读/字体/颜色近似及上述差异。作者姓名/日期/签核结论尚无，status=review。自动渲染共1轮，未降低检查阈值。
