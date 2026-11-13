# GroupHeatmap点阵续整理：独立验收与草稿入库

日期：2026-10-25。作者指定从GroupHeatmap继续。Devin CLI swe-2-max单会话实现（valley-handsaw），Codex审查、独立验证、知识整理和受控发布；没有启动Codex子代理，没有安装依赖，没有访问paper-harness。

## 交付状态

**本批软件与图样候选验收通过，已入正式画廊/知识库，作者签核尚未完成。** 这不是全SCP入库完成，也不是课题科学结论。

- 新图样：`layouts/2026-10-22-scp-example__fig17-group-heatmap-dot.md`，title分组表达点阵热图，status=pending_signoff，gallery=draft，未代签、未生成正式模板。正式服务8765可见，来源图明确标只读溯源。
- 复用候选：`E:/research-wiki-env/work/scp-ingestion-20261025/candidates/group-heatmap-dot/`。绘图不加载SCP/Seurat；支持原生add_dot、可选reticle与多矩阵，独立运行清单绑定当前闭包`c474e19d0f9c45a8202e9b710fd0cd04f5566b0ddee2cdc18d595f5c5b15a5a4`。准备层仅为原版对照，仍依赖历史源码环境，不能声称也已独立。
- 共用render-group-heatmap接口，修正联合主键/序号/比例语义；同步heatmap图型判断和scp-visualization-interface技术页，未新建分析家族，也未把绘图技术资料重新塞入analysis。
- 源码/画廊→技术资料→具体候选→原始函数的对照见隔离工作区source-map.md；后续范围见`文档/SCP持续入库与新规则/remaining-gaps.md`。142个导出的一对一机械索引已完成，不把文字命中当分支验证；初轮160行coverage草稿因错误未采用。

## 独立验证证据

| 维度 | 本次实际结果 | 证据 |
|---|---|---|
| 原生来源 | Codex独立重跑固定SCP 0.5.6 GroupHeatmap原函数；逐细胞比例与聚合变换矩阵一致 | codex-native-reference/、logs/codex-native-reference.log |
| 数值/输入/加载边界 | 16项Codex独立检查通过：嵌套加载、公开入口、原生矩阵、重复调用、输入不变、factor/非法序号/冲突/重复键/百分制拒绝、普通引号标签 | codex-dot-review2/checks.json、scripts/codex_dot_review.R |
| 原生输出 | 单矩阵、reticle、双矩阵共3张PNG；1m/2m共2张SVG与独立上游运行字节一致 | codex-artifacts.json |
| PDF | 1m/2m以同一pdftoppm转换至1200像素后像素一致；未声称PDF内部对象结构完全相同 | codex-artifacts.json、pdf-raster/ |
| 异目录真实运行 | Codex仅复制清单文件/资源，两个新Rscript --vanilla进程：默认表、数字字符身份表均输出PNG/PDF/SVG；输入哈希不变，默认PNG匹配上游，001/01在实际SVG保留 | codex-portable-final.json、codex-portable-final/ |
| 实际网页 | 隔离8880与正式8765真实Chrome点击查看代码、复用/原始切换，预览可读，来源panel引用画廊 | browser-isolated.json/png、browser-formal.json/png |
| 正式CLI | 原ht1模板按当前接口重新实际verify；check-entry新图样及技术页--record；save、lint、pending执行成功 | logs/publish-*.log |
| 原件/作者保护 | 固定源231文件不变，旧画廊900文件仅全局index.html/json更新，Wiki旧原始文件62个不变；78既有页作者区块/id/status/favorite等不变；开发296文件及其暂存索引不变 | codex-post-publication.json |

人工目检覆盖固定单矩阵、双矩阵和长标签变体，未见明显裁切。原生点阵的背景白，点颜色为变换表达，点直径按percent线性缩放；没有为视觉喜好改变原生几何。percent从逐细胞表达经声明的lib_normalize后、聚合/zscore前求阈值比例，不能从聚合value反推。

## 已查出的缺陷与处理

Devin按Codex审查修复：最外层ofile误定位、helper泄漏、因子转level code、非法/冲突顺序被静默接受、假draw(rect)声明、闭包收据不匹配、字符串经eval(parse)插入代码、svglite虚假可选、CSV猜测损坏前导零、原始摘录附加header导致非原字节。原始摘录现为固定源码7911–9036行的精确字节切片，来源元数据另存；旧注释版保留在隔离evidence/history。

中间一次Devin达到有界等待时限，代码未因此视作失败/完成；确认旧进程结束后同会话resume，无并发重复编码。旧失败/失效收据与日志保留。作者保护核查最初使用Git blob受到CRLF规范化影响，最终改用实际初始SHA及发布前原字节备份，通过后未对正式作者内容作任何“修复”。

## 发布与回退材料

发布前备份在`before-publication/`；实际发布白名单、当前闭包和范围见draft-release-review.json、draft-publication.json。没有复制隔离环境的index/log覆盖正式历史，正式CLI重新生成索引并追加日志。原ht1的旧收据由正常verify历史和发布前备份保留，代码、示例与PNG未改。画廊原件只新增本条，既有条目未覆盖。

本批无应用后端/前端/skill代码变更，因此没有五处技能重新部署或正式服务重启。使用现行research-wiki八步入库、最小运行闭包、分类/映射和sci-figure-replica签核规则；实际正式API已验证，未用“文件存在”替代运行。Wiki规则文字与tags API强制验证之间的既有缺口另记remaining-gaps，未声称本批修复。

## 剩余边界与下一步

- 等作者确认当前图样，再按正常signoff→scaffold-template→组装候选→verify-template→作者模板确认流程继续；不能为了清空队列改变状态。
- GroupHeatmap add_violin、flip、split、annotation和enrichment注释未完成；S4+其他图型按remaining-gaps逐批做。不扩大当前add_dot收据范围。
- reticle SVG、PDF对象结构、超容量调色板、非zscore分支和真实课题端到端均未验证。包会附加到R search，推荐CLI新进程隔离，不声称共享会话零副作用。
- scDblFinder/SingleR/monocle等缺包分支维持not_run。DE共享会话生命周期候选已拒绝并恢复基线，另列维护，不假称修好。
- pending --json仍有细胞注释、双细胞检测、RNA速度的既有实现待验证项；作者确认图样与这些agent动作分开，不为清零而跳过。
