# QA：2026-10-22-scp-example__fig16-cell-density

- Source SHA256：`72a7a07ac71b45fbe7f5db2e3c13aae6f1c8d166f4928af925f4d79dc3206b7e`
- Replica SHA256：`72a7a07ac71b45fbe7f5db2e3c13aae6f1c8d166f4928af925f4d79dc3206b7e`
- Source/replica 像素差：0（PIL）
- Table half：`plot_data_identical: true`，列/行/顺序/分组水平一致（见 `source/compare.json`）
- 模板 fixed：与 source 同 SHA256；adaptive small 5.5×3.9、large 14.39×7.4；max_width/max_height 正确拒绝；输入不变；异目录复制通过
- SVG 与 source 一致；PDF 尾部压缩流不同
- 未验证：真实 Seurat→CSV→模板流水线、flip/reverse/x_order 非默认值、CJK 标签
