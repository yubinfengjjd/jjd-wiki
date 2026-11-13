# 代码复用、方法理论与前端同步验收（2026-11-02）

作者要求：以后每次入库默认同时整理代码复用层与方法理论层，并同步前端展示。本次修复新组学资料只在折叠区可见、方法搜索不查 technical/workflow、技术详情隐藏实现表、图库没有绘图代码入口的问题。

## 最终行为

- 方法库默认展示各类条目，可选分析理论、组合流程、代码与技术资料；关键字搜索技术实现、函数/依赖、来源和理论资料。规范分析家族仍为 15，workflow/technical 不被冒充为新家族。
- 图库保留单 panel 图样/可调用模板，新增“绘图代码”入口，按显式 code_roles 展示原有方法页。两个组学资料页进入此处；理论关联仅作导航，不是假定接口直连。
- 代码卡显示笔记状态、逐分支验证数量、理论链接、说明与查看代码；技术详情也展示 18/22 个实现的依赖、入口、独立性和验证范围。
- CodeViewer 原始版/复用版及共享文件分支状态独立展示。irGSEA/SCP/CellChat 缺包分支继续 not_run，没有继承 Seurat/闭包的通过结果。
- 前端新增“同步知识库”操作；六处安装的前端构建和技能/规则均经 tools/deploy.py 备份部署并哈希一致核对。
- 同一次方法状态计算只校验一遍全页运行清单；下次调用重新校验当前文件，不跨调用保留通过状态。

## 实际核查

浏览器：原 DotPlotScores 搜索显示“没有匹配的方法”、资料折叠；部署后直接显示两个资料页及理论链接。图库→绘图代码可见 2 个入口，显示 12/22 与 7/18；技术详情实现表 18 行可见。已打开复用代码 dependency_plot.R，清晰显示 irGSEA/SCP/CellChat 未运行及 Seurat 已验证。下载响应逐字节 SHA-256 与当前文件匹配。

前端 npm test、TypeScript typecheck 与 Vite build 通过；相关后端 111 passed、2 skipped（保留跳过，不记为通过）。两个方法页 check-entry 通过。全库 lint：0 ERROR、71 WARN、末行 OK；保留明确未运行和历史问题，详见 lint-final.txt。六处部署最终验证 consistent=true。原291份代码、953份既有记录及214个页面作者/身份区块通过完整性检查，19/40个限定分支状态未提升或降级；本轮未改算法、未装包、未改 ready。

证据：frontend-tests.txt、frontend-build-final.txt、backend-tests-final.txt、api-audit.json、runtime-performance.json、integrity-final.json、deploy-verify-final.json、绘图代码前端.png。旧代码复用层收据在原 verification/ 中，未覆盖。

正式服务为本轮验证启动的本机 127.0.0.1:8765，PID 见 server-final.pid；采用既有 Wiki 环境的依赖路径，由 D:\anaconda\python.exe 启动，未安装新依赖。原文件和图数据继续留在原项目。仅本地提交，未推送。

{
  "vault": "340b8cea42eaf1f48a554514c4174eaa3cb6a1b3",
  "dev": "22f3f21d67b0b0606b954f9a9a3e71b901ef0930"
}
