# 青光眼真实材料：独立复用可行性核验

2026-10-24，Codex独立验证；不是产品发布、A25自然语言agent入口验收或科学结论。

## 实际完成

- 原生输入：原课题annotated RDS，17,918基因×10,100细胞；使用原课题缓存的6个AP1基因，不查询数据库。
- 只复制gene-set-scoring运行清单中的2份R文件，未提供SCP bundle/源码库路径、未安装完整SCP或任何新包。
- 使用现有隔离R4.5.0/Seurat5.6.0/BiocParallel1.42.0，固定seed=11、SerialParam、method=Seurat、classification=FALSE、name=Audit，实际调用两次。
- 两次得到相同的Audit_AP1分数，10,100个值均有限；细胞身份/顺序、输入对象的metadata/counts不变，search恢复；原项目25文件及36来源文件的基线哈希核对无变化。
- 输出的每个细胞分数通过显式bindings映射至render-cell-feature-values；所有10,100个cell/group/value逐项原样保留，无聚合、补值、单位换算或p值检验。
- 选择现有、已声明最小清单的SCP CellDensity山脊线模板，复制6个清单文件及spec/runtime控制元数据，实际从本次结果生成PNG/PDF/SVG和sizing.json。
- 图显示9类既有声明注释，合并展示两个GSM样本的细胞分布，标明描述性任意单位；不沿用有争议的Control/Glaucoma疾病解释。

## 证据与复放

解释器启动前读取现有`E:/research-wiki-env/work/scp-runtime.ps1`，不修改持久环境。

1. `scripts/check_glaucoma_scoring.R`：实际输入/基因表/复制入口/输出路径为日志同名命令；日志`logs/codex-glaucoma-scoring.log`，退出0。两次函数调用共4.24秒（不含读盘/进程启动）。
2. `scripts/check_glaucoma_plot.py`：复制模板清单、创建显式映射及逐值断言，退出0。
3. 调用复制的`native-probe/density-template/code/render.R --data native-probe/plot-bound --out native-probe/figure --style native-probe/density-style.json`（各路径以E:/research-wiki-env/work/wiki-cross-domain-20261024为根）；日志`logs/codex-glaucoma-plot.log`，退出0。
4. `scripts/inspect_native_ridge.R`与`logs/codex-native-ridge-inspection.log`：9组、4608个核密度绘制点；第一条山脊线紧贴边框，计算峰顶与panel上界均为9.5118，超界点0，未证实裁切。图已打开检查，文字/图例/单位/分组完整；留白仍可按实际交付需求调整。
5. 运行产物位于`E:/research-wiki-env/work/wiki-cross-domain-20261024/native-probe/`，含`out/verification.json`、`plot-mapping-verification.json`和`figure/`。它们目前是隔离核验产物，并未写回正式Wiki或覆盖课题文件。

最初独立驱动用了sys.source，未建立当前wrapper所依赖的ofile，加载时未找到本地helper；改用文档中的source后运行通过。保留`logs/codex-glaucoma-scoring-redloader.log`，没有为此修改产品方法源码。

## 不能由此授予

- Seurat单分支不等同原课题历史五分支签名求和；没有复现后者。
- 不能据此批准注释正确性、疾病分组、差异/因果结论、其他签名/打分分支或任何其他领域算法。
- 目前没有证据证明原课题某个PDF来自真实数据还是demo；本次图仅使用本次实际计算结果。
- 老青光眼UMAP/小提琴模板没有runtime.json，不能称为清单已核实；本次选择了另一条真实具有清单的模板，而未猜闭包。
- 本次未修改方法配图关系或全库verified状态；正式skill入口、状态/影响/恢复/回写、前后端规则同步仍是本轮实施的后续验收项。
