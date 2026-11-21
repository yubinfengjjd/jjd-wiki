# Nirmal et al. (2022) 原发性黑色素瘤空间进展与免疫编辑 1:1 全图复刻画廊

- **文献**：Nirmal AJ et al., *Cancer Discovery* 12(6):1518–1541 (2022), DOI: `10.1158/2159-8290.CD-21-1357` (PMCID: `PMC9167783`)
- **作者开源仓库**：`https://github.com/labsyspharm/scimap`（MIT License, commit `0b7aaabcce80815a295aec1c1238f974f117fb33`）
- **流程总览页**：`wiki/methods/melanoma-spatial-immunoediting-workflow.md`
- **本地工作区**：`<sources_root>/papers/pmc9167783/`
- **许可与版权边界**：原论文正文与配图采用 `CC BY-NC-ND` 许可，画廊对照图仅用于个人科研知识库内部学习、复现核验与出处溯源，不作商业或公开再分发；作者 `scimap` 开源算法遵循 `MIT` 许可。

## 数据边界与排除范围（严格诚实记录）

1. **Panel 2 S3 公开单细胞表代理边界**：HTA-MELATLAS-1 S3 公开的 `MEL02/05/09/11/12` 单细胞特征表为 CyCIF Panel 2（21-plex），故 Panel 1/3/4/5 独有蛋白（如 `S100B`、`MITF`、`KI67`、`PMEL`、`CD63`、`IRF1`、`MIF`、`CD74`、`CCNE2/A2/B1`、`pHH3`、`pRB`）在 S3 表中缺测，相关 CyCIF 空间面板使用 Panel 2 实测同谱系/同通路标志物（`S100a`、`MART1`、`SOX10`、`CCND1`、`HLADPB1`）作为 `proxy` 并于图注显式标注。
2. **PickSeq 120 mROIs 代理 GeoMx 70 mROIs**：`GSE171888` 仅公开发布 222 例 PickSeq 40 μm mROI 计数矩阵（分层抽样 120 例），NanoString GeoMx 70 mROIs 原始计数未公开存放在 GEO/S3/Table S6，故原标注 GeoMx 的面板（`6A`, `7H`, `S6E`, `S7A`, `S7C`, `S7H` 等）诚实以同位点 PickSeq mROI 数据运行并标注 `proxy`。
3. **Cohort 2 原文目视计数**：`Fig. 4F` 中 Cohort 1（n=5）为 S3 实测重算，Cohort 2（n=25）原文仅以人工目视分箱报告而未上传单细胞 CSV，复刻时忠实引用原文报告分箱并区分来源。
4. **TCGA-SKCM 缺测基因边界**：`Fig. S6F` 基于 UCSC Xena TCGA-SKCM（分层抽样 n=120）重算，8 个核心展示基因与 `MT-ND2` 差异为 `MT-ND2` 在 Legacy HiSeqV2 RSEM 矩阵中缺失（`PMEL` 从旧名 `SILV` 映射）。
5. **排除清单（不复刻纯显微与概念图）**：
   - `excluded_imaging`：整张 **Supp. Fig. 4（100% 荧光显微图像，故画廊仅归档 13 组图）**，以及 `1B, 1C, 1F, 1G, 1H, 1I-left, 1J, 3B, 3C-bottom, 4A, 4C, 4D, 4E, 4G, 5A, 5E-bottom-left, 6H, 7A, 7C, 7D, 7G-middle, S1A/B/D/E/F/G/I, S2C-mid/bottom, S3A, S5E, S6B, S6D-images, S7D-left, S7I-images`。
   - `excluded_schematic`：`1A, 7I, 7J, S2A, S2B`。
   - `unavailable_pixel_linescan`：`1I-right, S1H`（60× 3D 突触 0–16 μm 像素线扫描强度未包含在 S3 单细胞量化 CSV 中）。

## 13 张 1:1 复刻对比图（13/13 PASS，覆盖全部 60 个非显微定量面板；Supp. Fig. 4 整图排除）

### Fig. 1 (D, E; 1A schematic & 1B/C/F/G/H/I-left/J imaging excluded; 1I-right linescan unavailable) — Multimodal profiling of cutaneous melanoma
- 复刻图：`figures/fig01_replica.png` (2160x2958 px)
- 原图并排对比：`figures/fig01_side_by_side.png` (1426x960 px)

### Fig. 2 — Recurrent cellular neighborhoods (RCN1-10) associated with melanoma progression
- 复刻图：`figures/fig02_replica.png` (2160x2772 px)
- 原图并排对比：`figures/fig02_side_by_side.png` (1520x960 px)

### Fig. 3 (A, C-top, D-F; 3B & 3C-bottom imaging excluded) — Spatial topology, progression axis Voronoi neighborhoods, and distance shifts to RCN10
- 复刻图：`figures/fig03_replica.png` (2160x2892 px)
- 原图并排对比：`figures/fig03_side_by_side.png` (1610x1062 px)

### Fig. 4 (B, F; 4A/C/D/E/G imaging excluded) — PDL1+ myeloid and PD1+ CTL co-occurrence across progression and Cohort 1/2 PDL1 bins
- 复刻图：`figures/fig04_replica.png` (2160x2199 px)
- 原图并排对比：`figures/fig04_side_by_side.png` (1910x960 px)

### Fig. 5 (B-F; 5A & 5E-bottom-left imaging excluded) — Single-cell spatial lag analysis defining tumor cellular communities (TCC1-10) in invasive melanoma
- 复刻图：`figures/fig05_replica.png` (2160x2694 px)
- 原图并排对比：`figures/fig05_side_by_side.png` (1564x960 px)

### Fig. 6 (A-G, I-K; 6H imaging excluded) — Microregional transcriptomics (PickSeq proxy for GeoMx), KRAS/EMT signatures, and S100B co-expression module
- 复刻图：`figures/fig06_replica.png` (2160x2346 px)
- 原图并排对比：`figures/fig06_side_by_side.png` (1791x960 px)

### Fig. 7 (B, E-H; 7A/C/D/G-middle imaging & 7I/J schematic excluded) — Localized IFN-gamma/chemokine gradients, tumor-stroma boundary immunoediting, and compartment composition
- 复刻图：`figures/fig07_replica.png` (2160x2754 px)
- 原图并排对比：`figures/fig07_side_by_side.png` (1616x1015 px)

### Supp. Fig. 1 (S1C; S1A/B/D-G/I imaging excluded; S1H linescan unavailable) — Hierarchical CyCIF phenotyping decision tree (Table S5 rules) and synapse boundary
- 复刻图：`figures/sfig01_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig01_side_by_side.png` (1801x1150 px)

### Supp. Fig. 2 (S2C-top, S2D, S2E; S2A/B schematic & S2C-mid/bottom imaging excluded) — RCN1 Voronoi spatial validation, K-means elbow curve, and direct spatial_count 30-cluster comparison
- 复刻图：`figures/sfig02_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig02_side_by_side.png` (2033x1300 px)

### Supp. Fig. 3 (S3B-E; S3A imaging excluded) — RCN9 stage frequency, 10 um proximity volume score, RCN2/3/4 maps, and pairwise stage P-values
- 复刻图：`figures/sfig03_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig03_side_by_side.png` (2033x1300 px)

### Supp. Fig. 5 (S5A-D; S5E imaging excluded) — Tumor cell PCA scree/loadings, spatial contour maps, TCC-immune co-occurrence, and 2D state quadrants
- 复刻图：`figures/sfig05_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig05_side_by_side.png` (2033x1300 px)

### Supp. Fig. 6 (S6A, S6C, S6D-table, S6E, S6F; S6B & S6D-images excluded) — Proliferation markers, EMT GSEA, mROI counts, DDX58 expression, and TCGA-SKCM 8-gene survival grid
- 复刻图：`figures/sfig06_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig06_side_by_side.png` (2033x1300 px)

### Supp. Fig. 7 (S7A-I computational; S7D-left & S7I-images excluded) — IFNG/JAK-STAT signaling, boundary gradient, IRF1, MIF/CD74, CXCL12/CXCR4, and compartment composition
- 复刻图：`figures/sfig07_replica.png` (2160x2796 px)
- 原图并排对比：`figures/sfig07_side_by_side.png` (2033x1300 px)
