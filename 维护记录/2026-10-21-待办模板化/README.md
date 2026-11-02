# 两个单 panel 待办：实现与验收

日期：2026-10-21。正式知识库：`E:\research-wiki\知识库`。

## 当前结果

已从两条已签核的单 panel 来源制作可复制、独立调用的绘图模板；两个模板均完成 `verify-template` 和公开 `render` 入口回放。目前状态为 `draft`，等待作者确认本次模板回放，尚未执行 `mark-ready`。来源图样保持 `pending_template`；单模板使用不要求整图或 layout 回放。

- `2026-10-19-regression-stability__fig03-density-panel--density-scatter`：密度着色散点与预先计算的边缘柱分布。
- `2026-10-19-regression-stability__fig04-boxplot-panel--boxplot`：箱线、散点与均值。

源归档与复用代码分开保存；源代码是此前的复刻/重建版本，并非缺失的原作者完整实现。代码卡片支持按文件查看、复制与下载。实际前端截图：`模板卡片前端.jpg`、`模板代码前端.jpg`。

## 复用能力与边界

`code/panel.py` 提供 `plot_panel(tables, style=None)`，返回 figure、绘图对象和尺寸记录；保留 `draw(fig, rect, tables, style)` 与 render 入口，三者共用绘图核心。整个 code 目录可复制到课题使用，不依赖 Wiki 路径、spec 文件或原工作目录。

箱线图依据数据中的任意合法正整数类别数 n 编排。宽度按留白加 n×每组宽度增长，长标签可增加所需宽高；默认保留单 panel、字号与间距，没有宽度上限，不静默分面或缩字。默认配色随 n 生成，显式色表不足会报错；系数和顺序均可覆盖。测试中选择若干边界及规模案例，不构成组数白名单，也不宣称穷举全部 n。

散点图不因样本行数增多而无限扩宽。复用默认不带原示例模型名、拟合线、指标或色标含义。需要的拟合/摘要/密度颜色/边缘分布由调用方明确提供；绘图没有新增训练、统计计算、随机抖动或分析算法。

本次沿用作者已选择的估读数据；箱线图横向抖动是固定合成展示位置。点值、箱体与均值为独立估读，不能作为一致的原始验证数据进行统计推断。真实课题须先准备来自同一分析的点与摘要。原图右侧边缘分布与既有单 panel 的刻度差异沿用此前来源记录，未改动原始画廊。

## 知识关联与接口

新增四个严格的绘图输入契约：`render-scatter-rgb`、`render-marginal-bars`、`render-category-points`、`render-box-summaries`，写明每行含义和与原科学结果表的区别。

在现有回归模型重采样评估方法侧记录两条 `adaptable` 关系，图页和网络反向派生。原预测结果到 RGB/边缘分布、逐折指标到选定指标及摘要，仍需明确上游分析规则；未把表结构相似标成已直接跑通。关系的真实分析流水线验证状态为 `not_run`。没有为连接网络硬连 SHAP 等不适用方法。

## 已运行的验证

`function-verification.json`：15 项绘图与可移植性检查通过。包括原版/封装版画布及数据图元等价（绝对容差 1e-12）、输入未修改、复制到另一工作目录调用、n 与样本数变化、长标签、列映射与顺序、配色不足、显式尺寸及用户上限、无效输入拒绝、组合区域不足拒绝、默认参数与 spec 一致。回放 PNG 已实际查看；PDF/SVG 已检查导出结构，未做独立阅读器视觉验收。

`wiki-verification.json`：正式内容检查通过。249 个原画廊文件哈希、61 个既有资产文件及16个作者区块保持不变；两模板各15个真实代码文件可读取；公开 CLI render 产图与预览哈希一致；三处全局安装共用同一个 E 盘 Wiki。

`wiki.py lint` 返回 `OK`。这些证据仅证明已记录的绘图功能和示例回放，不证明真实课题分析、统计有效性或未实现的方法分支。

## 最后一步

依据 `知识库/AGENTS.md`：“每个模板 `verify-template` 单独回放，对照选定裁图检查并交作者确认；确认后 `mark-ready <模板 id>`”。待作者明确接受这两张回放后，通过 Wiki 命令标为可用，不手改状态。不需要重做整组图。

## 复核入口

- `verify_functions.py` / `function-verification.json`：绘图复用检查及结果。
- `verify_wiki.py` / `wiki-verification.json`：保护范围、接口、关系与正式入口检查。
- `cli-render-density/`、`cli-render-boxplot/`：公开 render 入口产物。
- `baseline.json`、`baseline/`：本轮前的核查基线。
- `prepare_templates.py`、`finish_notes.py`：本次一次性实现记录；后续代码已有修复和溯源整理，不应直接重跑以免覆盖最终实现。
