# 单panel：herb 稳健排序点图

状态：review，待作者目视签核。机械 QA 0 失败；复刻与来源几乎一致。

## 来源

- 选定代表：`E:\青光眼单细胞\axisnet_separate_panels_clean\Panel_D_bootstrap_CV_robust_ranking_clean.png`。
- 代码来源：`E:\青光眼单细胞\AxisNet_separate_panels_clean_and_code\generate_axisnet_panels_clean.py`（Panel D）。
- 数据来源：`E:\青光眼单细胞\axisnet_rd_v8\outputs\rankings\cv_results.json`（真实输出）。
- 选定裁图/完整原图：`source/fig08.png`、`source/full_original.png`。
- SHA-256（图）：`de6acc99798c2be2c50e75f72e2e48277d649931838a90d0768f5d6ac85a4cc3`；数据：`5f2e12d93d0f127af5ffc3f948fbc3639061c42951bd01190d9698b547ad5169`
- bbox：`[0, 0, 2248, 1586]`。

## 数据

- `data/cv_results.json`：真实 `cv_results.json` 副本。
- `data/herb-robustness.csv`：top10 herbs 的 `herb, herb_id, robust, mean, std, rank`；herb ID → 名称使用来源脚本的 known 字典。
- `data/estimated_data.csv`：同一表的副本，仅为满足 QA 的默认文件名；**不是合成数据**。
- 关键限制：`xerr = std * 0.5` 是来源脚本的展示选择，不是 95% CI；`robust = mean − 0.5 × SD` 是启发式稳健分，不是显著性检验。

## 代码与运行

- `code/make_data.py`：从 `cv_results.json` 生成 herb 表。
- `code/core.py`：`plot_herb_robustness()`，返回 matplotlib figure/axes；不读文件、不保存。
- `code/replica.py`：读取 herb 表，导出 PNG/PDF/SVG；DejaVu Sans，300 dpi。
- 输出：7.6×5.4 in，`bbox_inches="tight"`，PNG 2247×1589（来源 2248×1586）。

## 保真重点与差异

- 保留：10 个 herb 的横向排序、点 + x 误差棒、x 轴 Robust score、y 轴 Herb、水平网格、无标题。
- 差异：几乎无；PNG 尺寸差 1–3 px（tight bbox 舍入）。
- 未验证：真实 5 次留出重跑未在本机执行；本图只消费已有 `cv_results.json`。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：误差棒含义与稳健分局限；作者签核待完成。
