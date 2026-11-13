---
type: method
id: figureya-multilanguage-assets
title: 交互绘图与多语言工具索引
status: ready
tags:
- transcriptomics
- single-cell
- survival-analysis
inputs: []
outputs: []
source:
  kind: written
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
favorite: false
method_kind: technical
summary: 登记 FigureYa 压缩包中 10 个非 Rmd 工具的原始入口、输入与未运行边界；另提示 R/Python 混合模块，不能作为可执行分析推荐。
keywords:
- FigureYa
- Python
- Notebook
- ipynb
- Shiny
- HTML
- 交互式
- 火山图
- 桑基图
- 饼图
- 热图
- 列线图
- 方差分解
- cell2location
- FigureYa107ChIPheatmap
- FigureYa108RNAseqChIP
- FigureYa196Plus_PanPie_py
- FigureYa25Plus_Sankey_py
- FigureYa245Plus_VarDecompose
- FigureYa309cell2location
- FigureYa30Plus_nomogram_app
- FigureYa59Plus_volcano_shiny
- FigureYa104GEOmining
- FigureYa133m6Apeak_update
- FigureYa111markerGene
- FigureYa130coxSVM
- FigureYa226scRNA_cNMF
data_contract:
  input: 依模块分别为样本分类表、差异分析结果、BED/bigWig、单细胞/空间 AnnData、既有方差分解表或固定模型字段。没有统一接口；本文不做转换、补值或重算。
  output: 来源已有的 PDF/PNG/HTML 与分析中间对象；本次没有生成或验证新输出。
---
# 交互绘图与多语言工具索引

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：CC-BY-NC-SA-4.0
- 引用：Lu X, et al. (2025). FigureYa. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 标签：transcriptomics、single-cell、survival-analysis
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

让 `rwiki find` 能找到 Rmd 扫描器未覆盖的交互式可视化与多语言工具。本文为技术资料（technical），仅提供入口与适用判断，不声明实现已验证，不新增分析方法家族。完整来源、版本、许可与逐文件哈希见 [[sources/figureya-archive-20251223|压缩包增量来源]]。

## 适用

需要 Python 交互桑基图、临床分组饼图、ChIP/ATAC 同序热图、空间丰度展示、方差分解查询、列线图网页或 Shiny 火山图时，先查下表，再读取原始模块。只有本次真正用到、确认输入与依赖后，才复制到课题进行适配和验证。

## 不适用

本页没有可调用的 `code/`，不能作为 `--runnable` 分析推荐；Notebook、网页现成输出和来源参考图都不是本机运行收据。不要把固定示例模型用于未经验证的人群；不要将数据处理/文献检索辅助工具计作已验证的可视化模板。

## 输入

每行代表一个独立模块。统计单位、分类含义、表达量类型、参考基因组与模型字段分别核对，不存在跨模块通用列映射。

| 模块 | 用途 | 原始入口 | 输入含义 | 依赖/资源 | 边界 |
|---|---|---|---|---|---|
| `FigureYa107ChIPheatmap` | ChIP/ATAC 同序热图 | `FigureYa107ChIPheatmap.ipynb` | BED 区域、各样本 bigWig；按 ChIP 聚类固定行序再画 ATAC | deepTools、bedtools；输入 bigWig 不全在包内 | 上游参考图，未回放 |
| `FigureYa108RNAseqChIP` | RNA 表达顺序对应的 ChIP 热图 | `FigureYa108RNAseqChIP.ipynb + mergeInR.R` | 表达聚类对应的基因顺序、启动子 BED、bigWig；基因组版本必须一致 | deepTools、bedtools、R；外部 bigWig | 上游参考图，未回放 |
| `FigureYa196Plus_PanPie_py` | 临床分组饼图矩阵 | `FigureYa196Plus_PanPie_py.ipynb` | easy_input.txt：每行一个样本；sample ID、Risk(high/low)、临床分类列 | pandas、numpy、matplotlib、scipy、IPython | Python 实现，未与既有 R 配方比对 |
| `FigureYa25Plus_Sankey_py` | 交互式桑基图 | `FigureYa25Plus_Sankey_py.ipynb` | easy_input.txt：至少两列分类变量，各列表示一个层次；权重与重复行按源码定义 | pandas、plotly、IPython | HTML 是上游输出，未回放 |
| `FigureYa245Plus_VarDecompose` | 基因方差分解查询网页 | `index.html` | lmm_var_dcp_with_groups.csv：已有的人鼠同源基因方差分解结果及分组 | 浏览器 JavaScript；前端资源与上传格式未运行核验 | 查询既有结果，不是通用方差分解算法 |
| `FigureYa309cell2location` | 细胞空间丰度可视化 | `01 至 04 的四个 ipynb，绘图入口 04_cell2location_plot.ipynb` | 空间 AnnData、单细胞参考 counts 和细胞注释、空间图像、模型后验丰度；基因/切片标识需对齐 | scanpy、cell2location、torch 等；外部数据/模型资源未核验 | 包括训练与映射，不能把绘图本身当作模型验证 |
| `FigureYa30Plus_nomogram_app` | 列线图与预测结果网页 | `index.html + js/nomogram-viz.js` | 网页临床字段与固定示例 Cox 系数；字段单位和类别编码必须按源码核对 | 浏览器 JavaScript/PWA；未启动 | 固定示例模型展示，不作为已验证临床预测工具 |
| `FigureYa59Plus_volcano_shiny` | 交互式差异表达火山图 | `app.R` | easy_input_limma.csv：基因、logFC、P.Value；可选 easy_input_selected.csv：gsym、pathway | shiny、ggplot2、ggrepel、ggthemes、gridExtra、DT；启动代码会尝试装包 | 未启动，不能直接执行自动装包或公开监听脚本 |
| `FigureYa104GEOmining` | GEO 文献来源检索辅助 | `FigureYa104GEOmining.ipynb` | GEO 数据集标识；联网查询来源文献 | Biopython、bs4、metapub、pytablewriter 等与网络 | 文献检索辅助，非出图模块；旧影响因子不视为当前值 |
| `FigureYa133m6Apeak_update` | m6A peak 数据处理辅助 | `callPeak.R + longest.trans.R` | 基因组区域/基因注释、IP/input 计数及总 reads 等命令行参数 | tidyverse、dplyr；列顺序与基因组版本按原脚本核验 | 数据处理辅助，未提炼新分析家族 |

## 怎么做

1. 原始文件位于 `<sources_root>/figureya-compressed-20251223-raw/<模块名>/`。在 `sources/figureya-archive-20251223/ingestion-manifest.json` 找到模块及所有文件的 SHA-256，复制前核验。
2. 本页 10 个非 Rmd 模块不支持 `rwiki use/run`；按表选择入口，待课题需要时将该模块复制到课题目录，再做环境与输入审查。不要在来源目录内运行或改文件。
3. Rmd 能被扫描不代表跨语言流程完整：`FigureYa111markerGene` 的 R/Seurat 步骤后还需 Scanpy Notebook；`FigureYa130coxSVM` 的 R 步骤后还需 Python 特征选择；`FigureYa226scRNA_cNMF` 还包含外部 cNMF 工具链。其 L0 位于本包来源，不能只运行第一份 Rmd 就声称整模块通过。
4. Notebook 和 Shiny 的安装命令、联网请求、示例临床解释和部署建议只是来源内容，本次没有执行。装包仍须按库规则列清单后获批；Web/ Shiny 若后续运行，保持本机监听，先处理自动安装逻辑。

## 代码

原始 R、Notebook、HTML/JS/CSS 和参考图只保存在外部来源快照中；本次没有重写算法、封装 `code/`、执行上游代码或复制图片进 Wiki。本文是自行编译的来源与边界说明，`source.kind=written` 不代表上游代码由本 agent 编写。

## 输出

本次输出是本技术索引、来源目录、330 项对应表和逐文件哈希。上游自带 PDF/PNG/HTML 保留为来源参考；本次运行状态统一为“未运行”，没有伪造算法或可移植性收据。

## 知识关联检查

已通过 `rwiki find FigureYa --kind method` 检查，没有现存同类技术索引。已有 [[recipes/figureya-25sankey-update|R 桑基图配方]]、[[recipes/figureya-196panpie|R 临床分期扇形矩阵]]、[[recipes/figureya-59volcanov2|R 火山图配方]] 与 [[recipes/figureya-30nomogram-update|R 列线图配方]] 为优先复用入口；Python、Shiny、网页实现未与这些配方做数值或视觉等价验证，不授予相同状态。

单细胞/空间与特征筛选模块先按来源资料保留，后续若提炼分析实现，必须再按研究问题、输入、估计目标与已有家族做语义去重。technical 页不维护 `figure_relations`，也不建立结构相似即科学直连的关系。

## 使用记录


## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
