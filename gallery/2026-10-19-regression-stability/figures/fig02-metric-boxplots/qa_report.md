# QA report

2026-10-21T07:31:49.169584Z

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
| original 可打开 | PASS | PNG 1080×315 px |
| replica 可打开 | PASS | PNG 7200×2100 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×140 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（本轮已评定）

图形检查依据：原图、第二轮成图及等高并排。以下不等于作者签核。

| 项目 | 状态 | 证据与限制 |
|---|---|---|
| 画布与比例 | PASS | PNG为7200×2100；原图1080×315，宽高比一致。 |
| 布局 | PASS | 与原图并排查看：RMSE、R²、MAE从左至右，模型次序分别保留。 |
| 面板标签 | PASS | 原图没有字母；仅元数据分配逻辑面板编号，成图没有新增字母。 |
| 颜色 | WARN | 各指标按原图位置使用青/灰/黄/蓝/粉/灰；未做独立ΔE00≤10验证。 |
| 字体 | WARN | PNG文字可见无裁切；实际Arial及数学DejaVu，来源字体文件未知，不能证明同源字体。 |
| 坐标轴与刻度 | WARN | 主要范围及刻度已核对，R²顶部1.00在复刻中显示1.0；箱体、须和点的数值为估读。 |
| 图例与色标 | WARN | 白色菱形、中位线、散点及首模型背景保留；原文没有独立图例，未新增。 |
| 数据形状 | WARN | 点值、箱体统计、均值菱形分别估读；横向抖动为固定种子合成，不能恢复成一致的原始折数据。 |
| 注释 | WARN | 标题Explained variance按原图保留，实际轴为R²，不能据标题改算为explained_variance_score。 |
| 导出 | WARN | PNG已打开目视；PDF单页结构、字体嵌入及可提取文字通过；SVG XML与text节点通过。详见compare/vector-check.json。未用独立渲染器逐页目视PDF/SVG，不保证全部文字可编辑。 |

## 迭代与签核

两轮有界渲染均exit_code=0，无stderr。第一轮及修改理由保存在iterations/round-01/；第二轮机械检查0 FAIL，视觉近似保留WARN。

作者/签核日期/结论：待作者确认。status=review，不是approved；知识库版式为pending_signoff，不是ready。
