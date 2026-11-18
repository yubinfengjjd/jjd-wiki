# 2026-11-19-hdwgcna-network__fig02 — hdWGCNA 模块 GO 富集分面条图（Panel B）

## 来源与选定范围

- **来源文章**：`scRNA-hdWGCNA共表达网络分析【2】:富集分析及大型球体网络图构建可视化`（公众号：`KS生信科研课`，作者：`TS的美梦`，发布：`2026-08-10`）
- **选定单 panel**：完整原图 `source/full_original.png`（`1080×725` px）的右半 **Panel B** 裁图 `source/fig02.png`（bbox `[715, 0, 1080, 722]`，SHA-256 `c49a402d29ae5996c3f06a2f638acd096ed99d70f8b479c0cff115e25c5d4496`）；左半 **Panel A** 球体网络见同帖 `fig01`，完整拼图汇编脚本与对比图见 `../../composite/`。

## 数据与代码来源说明

- **数据来源（`estimated`）**：依据 Panel B 原图 0–8 线性刻度条长估读全部 14 模块 × Top 5 GO 词条与 `-log10(P-value)`（`data/enrich_plot_dat.csv`、`data/estimated_data.csv`）；个别超宽 GO 词条右端在原图分面框边缘有截断。
- **代码来源（`adapted`）**：核心 `ggplot2` (`geom_col` + 条内右起 `geom_text`) 与来源正文节 1 代码一致；由于本地环境未安装 `ggh4x`，改用 `patchwork` 拼接各模块彩色 strip 分面面板，同时修正了原图 strip 色条与柱子配色错位、深色底黑字难辨的缺陷并去除了公众号水印。

## 运行方法

```powershell
& "D:\R-4.5.0\bin\Rscript.exe" code/replica.R --data data --out output
```
