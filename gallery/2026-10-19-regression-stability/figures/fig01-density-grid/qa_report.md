# QA report

2026-10-21T07:31:45.687142Z

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
| original 可打开 | PASS | PNG 1080×649 px |
| replica 可打开 | PASS | PNG 7200×4326 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×288 px |
| 宽高比 | PASS | 相对误差 0.0154%，阈值 ≤2% |

## 人工视觉 QA（本轮已评定）

图形检查依据：原图、第二轮成图及等高并排。以下不等于作者签核。

| 项目 | 状态 | 证据与限制 |
|---|---|---|
| 画布与比例 | PASS | PNG为7200×4326；原图1080×649，比值误差0.0154%。 |
| 布局 | PASS | 与原图并排查看：2×3主图，每图含上方及右侧直方图。 |
| 面板标签 | PASS | 原图没有字母；仅元数据分配逻辑面板编号，成图没有新增字母。 |
| 颜色 | WARN | 绿低红高的色标方向与边缘直方图颜色保持；散点RGB来自源图估读。未做独立ΔE00≤10验证。 |
| 字体 | WARN | PNG文字可见无裁切；实际Arial及数学DejaVu，来源字体文件未知，不能证明同源字体。 |
| 坐标轴与刻度 | WARN | 线性像素估读的轴校准、末端范围与直方图高度为近似；单位SR与主刻度已核对。 |
| 图例与色标 | WARN | 原图Frequency名称与0/1/2/>3刻度保留；原始核密度归一化未知，无法从RGB恢复实际频数。 |
| 数据形状 | WARN | 点遮挡与抗锯齿不能恢复真实样本；图形检测数不是原始样本数，点坐标不用于统计分析。 |
| 注释 | WARN | 数字为原图转录的舍入值，未从估读散点重新计算；个别小于1的SD省略了前导0，数值含义不变。 |
| 导出 | WARN | PNG已打开目视；PDF单页结构、字体嵌入及可提取文字通过；SVG XML与text节点通过。详见compare/vector-check.json。未用独立渲染器逐页目视PDF/SVG，不保证全部文字可编辑。 |

## 迭代与签核

两轮有界渲染均exit_code=0，无stderr。第一轮及修改理由保存在iterations/round-01/；第二轮机械检查0 FAIL，视觉近似保留WARN。

作者/签核日期/结论：待作者确认。status=review，不是approved；知识库版式为pending_signoff，不是ready。
