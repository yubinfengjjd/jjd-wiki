# 复现工程归档源码（`melanoma-spatial-immunoediting-workflow`）

- `00_sample_data.py` 从 HTA-MELATLAS-1 S3（`MEL02/05/09/11/12`）、GEO `GSE171888`（PickSeq 222 mROIs）与 UCSC Xena TCGA-SKCM 拉取公开真实数据，并按 `seed = 42` 执行分层/连续 FOV 抽样（2,500 细胞分层抽样、1,642 细胞 4 个完整连续物理 FOV、`120` mROIs、`120` TCGA-SKCM 患者）。
- `01_cycif_qc_rescale_phenotype.py` 至 `05_spatial_lag_tcc.py` 执行 CyCIF 轮间 DNA 质控（`r >= 0.8`）、MIT `scimap` GMM 0–1 重标度、Table S5 Panel 2 层级表型注释、UMAP 降维与肿瘤 PCA、20 μm 局部邻域 Spatial LDA + K-means 30 → RCN1–10 聚簇、Shapely 有限 Voronoi 多边形、1,000 次置换共现检验、10 μm 邻近体积得分与 20 μm 空间滞后 TCC1–10 分簇。
- `06_mrseq_deseq2_pca_gsea.R` 与 `07_s100b_network_tcga_survival.R` 执行 PickSeq `DESeq2` 标准化与差异分析（对齐 Table S6）、PCA、ssGSEA、GSEA、`S100B` Pearson 共表达网络（`r >= 0.6`）及 TCGA-SKCM 生存/Cox 检验。
- `08_extract_visual_spec.py` 提取原版主附图尺寸、宽高比与主色调规格至 `review/palette_and_layout_spec.json`。
- `figures/panels/_fig_common.py` 与 `figures/panels/{fig,sfig}*.py`（60 个独立 Panel 脚本）及 `figures/{fig,sfig}*.py`（13 张整图拼图脚本）生成全部 1:1 复刻图与并排审图图版。

## 运行约定（零硬编码路径）

- `PAPER_ROOT` 环境变量指向含 `data_small/`、`runs/`、`extracted/` 与 `review/` 的独立论文工程目录（默认当前工作目录 `.`）。
- Python 侧建议通过独立生信虚拟环境运行，并设置 `PYTHONNOUSERSITE=1` 及工程内 `TMP`/`TEMP`/`MPLCONFIGDIR`。
- R 侧可通过 `RWIKI_R_LIBS` 传入额外 R 库路径（按平台路径分隔符拼接）。

## 严格数据与排除边界

1. **Panel 2 S3 公开单细胞表代理边界**：S3 公开的 `MEL02..MEL13` 量化特征表采用 CyCIF Panel 2（21-plex），故 Panel 1/3/4/5 独有蛋白（`S100B`、`MITF`、`KI67`、`PMEL`、`CD63`、`IRF1`、`MIF`、`CD74`、`CCNE2/A2/B1`、`pHH3`、`pRB`）在 S3 表中缺测；对应空间/分型面板以实测 Panel 2 标志物（`S100a`、`MART1`、`SOX10`、`CCND1`、`HLADPB1`）作为 `proxy` 并在图中显式标注。
2. **PickSeq 120 mROIs 代理 GeoMx 70 mROIs**：`GSE171888` 仅公开发布 222 例 PickSeq 40 μm mROI 计数矩阵，NanoString GeoMx 70 mROIs 原始计数未公开沉积于 GEO、S3 或 Table S6；原标注 GeoMx 的面板以同解剖位点 PickSeq mROI 数据运行并标注 `proxy`。
3. **Cohort 2 原文目视计数**：`Fig. 4F` 中 Cohort 1（n=5）为本地 S3 实测重算，Cohort 2（n=25）原文仅报告人工目视分箱百分比（未上传 S3 单细胞表），按原文分箱忠实绘制。
4. **TCGA-SKCM 缺测基因**：`Fig. S6F` 中 8 个基因基于 UCSC Xena TCGA-SKCM（n=120）实测重算（`PMEL` 从旧名 `SILV` 映射）；`MT-ND2` 在 Legacy HiSeqV2 RSEM 矩阵中缺失，诚实记录不伪造。
5. **排除清单**：
   - `excluded_imaging`：整张 `Fig. S4`（100% 荧光显微图像），以及 `1B, 1C, 1F, 1G, 1H, 1I-left, 1J, 3B, 3C-bottom, 4A, 4C, 4D, 4E, 4G, 5A, 5E-bottom-left, 6H, 7A, 7C, 7D, 7G-middle, S1A/B/D/E/F/G/I, S2C-mid/bottom, S3A, S5E, S6B, S6D-images, S7D-left, S7I-images`。
   - `excluded_schematic`：`1A, 7I, 7J, S2A, S2B`。
   - `unavailable_pixel_linescan`：`1I-right, S1H`（60× 3D 突触 0–16 μm 像素线扫描强度未包含在 S3 单细胞特征 CSV 中）。
