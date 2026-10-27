# v2 精简与 FigureYa 入库：交付报告（2026-10-27）

计划：`文档/v2精简与FigureYa入库/计划.md`；作者选择 1=a、2=a、3=a。

## 已完成

| 阶段 | 结果 | 验证 |
|---|---|---|
| P1 规则 | `AGENTS.md` 120 行、`SKILL.md` 75 行，新增 `references/sources-and-recipes.md`；知识库 `AGENTS.md` 已经 `init` 同步 | `test_rule_docs` 通过 |
| P2 工具 | 开发仓库 3 个提交（7cd88f0、913560c、066698e），本地 `main` 快进到 066698e，未推送 | 全量 pytest：761 passed / 3 skipped，唯一失败是知识库 AGENTS.md 未同步，`init` 后复跑通过；前端 `build` 与测试通过 |
| P2 修正 | 依赖判定改为以代码里的 `library()/require()/pkg::` 为准，上游 `install_dependencies.R` 只作提示：FigureYa 的安装清单里有颜色名、数据列名（`blueviolet`、`phylum`、`order`），原逻辑会让这些模块永远 not_run | 新增 `test_required_packages_follow_code_not_install_list` |
| P7 部署 | 6 处（含 `.kiro`）部署，manifest `source_commit=066698e`、`source_ref=main`；维护记录 `维护记录/2026-10-27-v2精简与FigureYa入库/` | `deploy --verify-only` 6 处 missing/different/extra 均为 0；新进程经 PATH 运行 `rwiki find 火山图`（cmd）和 `rwiki show`（Git Bash）正常 |
| P3 L0 | 来源页 `sources/figureya.md`（commit 8d7a02c7，CC-BY-NC-SA-4.0，trusted），`items.jsonl` 313 行 | 行数 = 快照中 `FigureYa*` 目录数 313；`find 生存曲线` 命中 |
| P4 L1（部分） | 30 个配方页已建（draft，含中文标题、图型、适用/不适用）；12 个原样运行 pass | 收据 `recipes/<id>/runs/`；目视看过 141risk、162boxViolin、39bar 预览图，与上游示例一致 |
| P6 场景页 | 7 页：临床预测与生存、差异与富集、相关性、组间比较、组成与流向、降维与单细胞、模型解释 | `find 生存曲线` 前 4 条均为“场景首选”；`show` 列出首选表 |
| P8 收尾 | SCP 规格（requirements/tasks）标“暂停，待 v2 重排” | 全量 `lint`：0 ERROR，36 WARN（18 个待运行配方 + 既有 SCP not_run 分支） |
| 端到端 | `use figureya-162boxviolin --project <临时目录>` → `run --dir` | state pass、scope other-dir；临时目录已删 |

12 个 pass：141risk、31lasso、102multipanelROC、39bar、13GSEA_Java、11bubble、76corrgram、37correlationV2、162boxViolin、173fancybar、227boxdensity、196PanPie。其中 173fancybar、196PanPie、76corrgram 用 base 图形直接写 PDF，knitr 没有捕获 PNG，所以没有 `preview.png`；预期 PDF 都已生成。11bubble 的 `dot.png/dot.tiff`、13GSEA 的 `ppoint2.pdf` 记为 missing_outputs（上游对应代码块未执行），收据如实记录。

## 等作者批准：第一批装包清单

另外 18 个配方缺包，装包前须作者批准一次。批准后执行 `rwiki deps <下列配方> --install --github`，只装进 `E:\research-wiki-env\R-lib\figureya`。

| 配方 | 缺包 |
|---|---|
| 1survivalCurve | survminer |
| 284pairwiseLogrank | survminer、ggpp |
| 6rHRs、193RiskTable | forestplot |
| 30nomogram | rms、regplot、nomogramEx |
| 138NiceCalibration | rms、ResourceSelection |
| 33DCA | magick |
| 85timeROC | timeROC |
| 99smoothHR | smoothHR（会带上 rms） |
| 293machineLearning | randomForestSRC、plsRcox、superpc、gbm、survivalsvm、BART、miscTools、compareC、ggbreak；CoxBoost（GitHub binderh/CoxBoost） |
| 59volcano | ggthemes |
| 61GSVA | GSVA（Bioconductor）、msigdbr |
| 153ccgraph | GOplot |
| 228linkCor | GSVA、ggcor（模块自带 ggcor-master.tar.gz，本地安装） |
| 92immune_gene | ggstatsplot（依赖较重） |
| 143survCor | survMisc |
| 25Sankey | ggalluvial |
| 236circGroup | SimDesign |

共 29 个包。nomogramEx 已从 CRAN 归档，可能装不上；ggcor 需要从本地 tar 包安装（`deps --install` 目前不处理本地 tar，需要单独执行一条命令，也要批准）。

## 未完成

- P4 剩余 18 个配方：装包后运行。
- P5 L2 示范三个模板（KM+风险表、亚组森林图、火山图）：分别依赖 survminer、forestplot、ggthemes，需在装包后做。
- 30 个配方仍为 draft，需作者看过后 `mark-ready`（可批量）。
- 只做了本地提交，没有推送。
