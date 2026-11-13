# post01 Fig. 4 · SHAP 特征驱动机制六面板复刻

状态：**review**（作者视觉签核待定）。数据为图中印刷值的候选转录 + 蜂群合成近似；不是原始观测或模型重训结果。

## 文件

- `source/fig01.png`：原图；`source/source.md`：帖子全文；`source/article.html`：原始 HTML（在帖子层 `source/`）。
- `data/estimated_data.csv`：A/D 条形值与 C/F 百分比；`data/estimated_beeswarm.csv`：B/E 合成点；`data/figure_spec.json`：面板、色板、字体、色标与来源；`data/transcription_notes.md`：初录→放大图修正对照与 uncertain 项。
- `code/replica.py`：自包含复刻代码（模板已打包在 `code/templates/`）；运行方法见 `code/README.md`。
- `output/replica.png|pdf|svg`：成图；`compare/side_by_side.png`：并排对比；`thumb.png`：索引缩略图。
- `original_code/`：原帖 4 段代码原字节归档；`original_code/README.md` 说明它们是通用示例，不是目标图生成代码。
- `qa_report.md`、`run.log`、`render.log`、`source_crop/`：QA 与运行证据。

## 运行

```powershell
$py = 'C:\Users\86186\.codex\venvs\sci-figure-replica\Scripts\python.exe'
Set-Location 'E:\桌面\科研绘图画廊\2026-08-17-shap-feature-mechanism\figures\fig01-shap-a-f'
& $py -X utf8 code\replica.py
```

## 已知 WARN

- A/D inset 开口略大、C/F 略小；A2/D1/F1 等数字末位与 C/F 百分比 uncertain。
- B/E 为固定种子合成近似点，不是原始样本。
- 字体实际 Arial，源字体文件未知；PDF 页级独立查看器视觉待作者确认。
- 原帖代码是 XGBoost + SR 的通用示例，不是 Fig. 4 的 LightGBM/CatBoost 生成代码。
