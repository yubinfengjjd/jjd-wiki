# 复刻代码

本目录是自包含的 post01 Fig. 4 复刻代码。模板与脚本已随条目打包。

在条目根目录运行：

```powershell
$py = 'C:\Users\86186\.codex\venvs\sci-figure-replica\Scripts\python.exe'
& $py -X utf8 code\replica.py
```

输入：`source/fig01.png`、`data/estimated_data.csv`、`data/estimated_beeswarm.csv`。
输出：`output/replica.png|pdf|svg`、`compare/side_by_side.png`、`qa_report.md`、`figure_spec.json`。
代码来源：按图重建（`reconstructed`）；原帖 4 段代码仅归档（`example_not_target`）。
