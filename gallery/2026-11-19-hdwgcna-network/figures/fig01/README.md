# 2026-11-19-hdwgcna-network__fig01 — hdWGCNA 共表达模块球体网络图（Panel A）

## 来源与选定范围

- **来源文章**：`scRNA-hdWGCNA共表达网络分析【2】:富集分析及大型球体网络图构建可视化`（公众号：`KS生信科研课`，作者：`TS的美梦`，发布：`2026-08-10`）
- **原文链接**：https://mp.weixin.qq.com/s/LOpSnqiK3nfG-wVU8urzVw （子文章链接见 `sub_post_2_source.md`）
- **选定单 panel**：完整原图 `source/full_original.png`（`1080×725` px，SHA-256 `bcff089d113f65e38619f43a8ae373d8eb63149ad5400a31f2c8bd136249c73e`）的左半 `Panel A` 裁图 `source/fig01.png`（bbox `[0, 0, 692, 660]`，SHA-256 `8e3c5d63cad8b2e670a69c21d862188219ee3ad0464cb939f1a25442bec6d7bd`）。
- **未选面板**：右侧 `Panel B`（14 模块 GO 富集分面水平条图）仅在完整原图中作溯源保留，不纳入本单 panel 复刻交付。

## 数据与代码来源说明（重要诚实边界）

- **数据来源（`synthetic`）**：原文章未公开 `Agrp_hdWGCNA_obj.rds` 与 `edge_file.csv` / `gene_module.csv`。本条目依据原文章第 2 节提取逻辑（`gene_name`, `module`, `color`, `from`, `to`），按原图可见 14 个模块（`Agrp_M1`–`Agrp_M14`）、采样色值及视觉集群比例，使用固定种子 `42` 合成 `data/gene_module.csv`（675 节点）与 `data/edge_file.csv`（6,881 条连边），**属 `synthetic visual approximation`，不可替代真实样本 TOM 推断结果**。
- **代码来源（`reconstructed`）**：原文章的球体网络绘图自定义函数仅以 VIP 群/截图形式提及，未公开函数文本；`code/replica.R` 基于 R `igraph::layout_with_fr` 加权模块内聚+跨模块桥接拓扑与 `ggplot2` + `ggrepel` 径向引导线重建，支持任意模块数 `n` 与外部数据表替换，**已去除原图公众号水印并消除了原图 `M1/M10`、`M11/M8` 的局部文字重叠**。

## 运行方法

```powershell
& "D:\R-4.5.0\bin\Rscript.exe" code/replica.R --data data --out output
```

- 运行环境：`D:\R-4.5.0\bin\Rscript.exe`（`ggplot2`, `igraph`, `ggrepel`, `dplyr`, `readr`, `stringr`, `jsonlite`）。
- 导出警告：当前 R 环境未安装 `svglite`，`output/replica.svg` 由 `grDevices::svg` 回退导出（文本可能转为矢量路径，`replica.pdf` 由 `cairo_pdf` 正常生成）。
