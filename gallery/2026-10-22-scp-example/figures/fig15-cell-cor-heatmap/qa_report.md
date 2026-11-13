# QA：2026-10-22-scp-example__fig15-cell-cor-heatmap

- Source SHA256：`6f96f3c2d6d42e8e7e1cbe916ee335db8b04a9f9ecee307948eaa779e53f6bf7`
- Replica SHA256：`6f96f3c2d6d42e8e7e1cbe916ee335db8b04a9f9ecee307948eaa779e53f6bf7`
- Source/replica 像素差：0
- 表半：`identical(simil_matrix)`，8×8；`simil_name` 一致
- 模板 fixed：与 source 同 SHA256；adaptive、max 拒绝、输入不变、异目录复制通过
- P1：`RunKNNPredict()` metadata 名称 patch，相似度矩阵不变
- 未验证：panc8 参考集、细胞级不折叠、nlabel/label_cutoff、annotation、flip/cluster、CJK 标签
