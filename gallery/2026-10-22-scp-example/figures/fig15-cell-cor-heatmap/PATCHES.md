# PATCHES

## P1：RunKNNPredict metadata 名称

- 上游：`RunKNNPredict()` 把 `match_best[query_index]` 写回 `srt_query[[...]]`，向量名是分组标签，与 SeuratObject >= 5.4 的 cell-name 校验不兼容。
- 处理：在拆分副本中对四个写回调用加 `unname()`；值、顺序、距离矩阵与相似度矩阵不变。
- 证明：`identical(scp_cellcor_simil()$simil_matrix, CellCorHeatmap()$simil_matrix)` 为 TRUE；PNG 逐字节一致。

## 拆分与 namespace

- 表半/绘图半拆分；ComplexHeatmap 构造、配色、注释、标题和尺寸计算保留。
- 本地 `theme_scp`/`palette_scp` 与 `palette_list.rda`；不调用安装的 SCP 包。
