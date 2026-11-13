# 单panel：疾病模块轴数分组柱

状态：review，待作者目视签核。机械 QA 0 失败；复刻与来源几乎一致。

## 来源

- 选定代表：`E:\青光眼单细胞\axisnet_separate_panels_clean\Panel_C_disease_module_distribution_clean.png`。
- 代码来源：`E:\青光眼单细胞\AxisNet_separate_panels_clean_and_code\generate_axisnet_panels_clean.py`（Panel C）。
- 数据来源：`E:\青光眼单细胞\axisnet_rd_v8\outputs\rankings\enhanced_axis_ranking_v8.csv`（真实输出，1000 axes）。
- 选定裁图/完整原图：`source/fig07.png`、`source/full_original.png`。
- SHA-256（图）：`85f7339030568f8af3427d2d11b30697caeabd301755d680f031c1e3029f4bde`；数据：`fd19021a3286aee445cabb61c7f49b6eb293c5124efd96eac6fbf1065cb5f18d`
- bbox：`[0, 0, 2189, 1523]`。

## 数据

- `data/ranking.csv`：真实 `enhanced_axis_ranking_v8.csv` 副本。
- `data/module-counts.csv`：按 `disease_module` 统计的 all / top20 计数；top20 为按 rank 排序的前 20 行。
- `data/estimated_data.csv`：同一计数的副本，仅为满足 QA 的默认文件名；**不是合成数据**。
- 计数：TM/IOP 526、ECM/TGFβ/EMT 85、RGC neurodegeneration 13、Inflammation/Complement 324、Mitochondria/Ferroptosis 52；top20：10、7、0、2、1。

## 代码与运行

- `code/make_data.py`：从 ranking CSV 生成计数表。
- `code/core.py`：`plot_module_counts()`，返回 matplotlib figure/axes；不读文件、不保存。
- `code/replica.py`：读取计数表，导出 PNG/PDF/SVG；DejaVu Sans，300 dpi。
- 输出：7.4×5.2 in，`bbox_inches="tight"`，PNG 2189×1527（来源 2189×1523）。

## 保真重点与差异

- 保留：5 个模块顺序、All vs Top 20 双柱、柱宽 0.38、黑边、顶部图例、水平网格、换行标签。
- 差异：几乎无；PNG 高度比来源多 4 px（tight bbox 舍入）。
- 未验证：真实模型训练/排序流程未在本机重跑；本图只消费已存在的 ranking CSV。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：作者签核待完成。
