# PATCHES

本条目没有改变绘图几何的补丁。拆分副本只做了：
- 表半/绘图半拆分，Seurat 输入改为显式 cell-level 表；
- namespace 限定与本地 `theme_scp`/`palette_scp`（替代 SCP 包导出）；
- `check_R()` 不在模板中调用，改用已安装依赖的 `requireNamespace()`。

Source 与 replica 使用同一 core，固定 8×6@150 PNG 逐字节一致。
