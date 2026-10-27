# v2 精简与 FigureYa 入库：交付报告（2026-10-27）

计划：`文档/v2精简与FigureYa入库/计划.md`；作者选择 1=a、2=a、3=a；第一批装包已批准（“R-4.3.1 里有就用，没有的话批准安装”）。

## 结果

| 阶段 | 结果 | 验证 |
|---|---|---|
| P1 规则 | `AGENTS.md` 120 行、`SKILL.md` 75 行，新增 `references/sources-and-recipes.md`；知识库 `AGENTS.md` 已经 `init` 同步 | `test_rule_docs` 通过 |
| P2 工具 | 开发仓库本地 `main` = fd03bf1（4 个提交），未推送 | 全量 pytest 761 passed / 3 skipped（唯一失败为知识库 AGENTS.md 未同步，`init` 后通过）；v2 测试 16 个通过；前端 build 与测试通过 |
| P2 修正 | ① 依赖以代码 `library()/require()/pkg::` 为准，上游安装清单只作提示（FigureYa 清单里有 `blueviolet`、`phylum` 等非包名）；② 运行器改在全局环境 knit（survminer、rms 的 datadist 在全局环境找数据，原先因此失败） | 各有回归测试 |
| P7 部署 | 6 处（含 `.kiro`），manifest `source_commit=fd03bf1`、`source_ref=main` | `deploy --verify-only` 一致；新进程经 PATH 跑 `rwiki find`（cmd）与 `rwiki show`（Git Bash） |
| P3 L0 | `sources/figureya.md`（commit 8d7a02c7，CC-BY-NC-SA-4.0，trusted），`items.jsonl` 313 行 | 行数 = 快照 `FigureYa*` 目录数 |
| P4 L1 | 30 个配方页（draft）；27 pass、2 fail、1 not_run | 收据 `recipes/<id>/runs/`；预览图目视抽查 6 张 |
| P5 L2 | 3 个模板（draft）：`figureya-1survivalcurve-update--km-curve`、`figureya-6rhrsv2--forest`、`figureya-59volcanov2--volcano`；新接口 4 个 | `verify-template` 全部成功；`check-entry` 无 ERROR；换数据见下 |
| P6 场景页 | 7 页 | `find 生存曲线` 前 4 条均为场景首选 |
| P8 收尾 | SCP 规格标“暂停，待 v2 重排” | 全量 `lint` 0 ERROR |

## 装包

- 装进 `E:\research-wiki-env\R-lib\figureya`（R 4.5）。没有直接用 `D:\R-4.3.1\library`：R 4.3 编译的包（rms、GSVA、gbm、BART、randomForestSRC、magick 等含 C/C++ 代码）在 R 4.5 里不能保证二进制兼容，混用库容易出现难查的崩溃；4.3.1 里也缺 forestplot、smoothHR、ggstatsplot 等 8 个包。4.3.1 本身未改动。
- CRAN/Bioc 装上 25 个；CRAN 已下架的 survMisc、regplot、km.ci 从 CRAN Archive 源码装上；ggcor 用模块自带的 tar 包装上。
- 仍缺：CoxBoost。GitHub 和 CRAN Archive 都只有源码，需要编译，本机没有 Rtools，所以 293machineLearning 记为 not_run。

## L1 运行结果（30 个）

- pass 27 个。173fancybar、196PanPie、76corrgram、138NiceCalibration、143survCor、193RiskTable、85timeROC、99smoothHR 直接写 PDF，没有 PNG 预览，预期 PDF 均已生成。11bubble（dot.png/dot.tiff）、13GSEA（ppoint2.pdf）有声明输出未生成，收据如实记录。
- fail 2 个，都是上游代码与当前包版本不兼容，没有改上游：
  - 153ccgraph：`group_by(.dots=)` 在 dplyr 1.0 以后已经不能用。
  - 61GSVA：GSVA 2.x 改用 `gsvaParam()`，旧的 `gsva(expr, gset)` 调用方式失效。第一次运行时 msigdbr 下载数据还遇到过 zenodo 504。
- not_run 1 个：293machineLearning，缺 CoxBoost。

## L2 模板换数据与异目录检查

`use` 复制到临时课题目录后，在新进程里用 `Rscript code/render.R` 运行：
- KM：换成上游的两组数据（easy_input_2），P = 0.041，风险表 2 行，高度回到基准；给错 labels/palette 时直接报错，不会循环取色。
- 森林图：只取前 7 行、去掉 P 列，图高 4.86 in（26 行时 9.88 in），P 列自动隐藏。
- 火山图：取 3000 个基因、classic 模式、不给标注表，正常出图。

这些检查没有按 `minimal-runtime.md` 的格式写独立性收据，所以 lint 和 check-entry 还提示“独立声明尚无独立性证据”（WARN）。临时目录已删除。

与上游的差异写在各模板的 `runtime.json` 和“知识关联检查”里。统计量都没有改：survfit/log-rank 与上游相同，森林图只画上游给定的效应量，火山图仍按原始 P 分级。

## 待作者确认

- 30 个配方与 3 个模板都是 draft。看过后可以批量 `mark-ready`。
- 61GSVA、153ccgraph 要不要改写成适配新版包的 L2（会改动上游代码）。
- CoxBoost 要不要装 Rtools 后编译。

只做了本地提交，未推送。
