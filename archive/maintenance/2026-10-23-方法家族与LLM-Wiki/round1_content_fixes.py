"""Round-1 review fixes: cross-source strategy tables and two family rewrites."""
from pathlib import Path
import re
import sys
import textwrap

sys.path.insert(0, "E:/research-wiki/开发/staged/research-wiki")
from rwiki.pages import read_page, write_page, get_block  # noqa: E402

WIKI = Path("E:/research-wiki/知识库")


def clean(text):
    return textwrap.dedent(text).strip()


def sections(items):
    return "\n\n".join(f"## {title}\n\n{clean(body)}" for title, body in items)


def user_block(body):
    start = body.index("<!-- user:start -->")
    end = body.index("<!-- user:end -->") + len("<!-- user:end -->")
    return body[start:end]


def render(title, facts, body_sections, user):
    return f"# {title}\n\n<!-- facts:start -->{facts}<!-- facts:end -->\n\n{body_sections}\n\n{user}\n"


def insert_after_section(body, title, text):
    user = user_block(body)
    masked = body.replace(user, " " * len(user))
    pattern = re.compile(rf"^## {re.escape(title)}[ \t]*\r?\n(.*?)(?=^## |\Z)", re.M | re.S)
    match = pattern.search(masked)
    if not match:
        return body.replace("<!-- user:start -->", f"## {title}\n\n{clean(text)}\n\n<!-- user:start -->", 1)
    return body[:match.end(1)] + "\n\n" + clean(text) + "\n" + body[match.end(1):]


TABLE = {
    "cell-quality-control": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunCellQC`：UMI、基因数、线粒体/核糖体比例、可选双细胞/离群点 | [[methods/scp-cellqc-doublet]]；`SCP-local/R/SCP-cellqc.R` | 原始 counts，按样本；输出细胞级 QC 指标与 CellQC | UMI/基因数/线粒体阈值分支已封装并 verified；双细胞/离群点未运行 |
| 青光眼 `preprocess.R`：Seurat 指标 + MAD 3× 离群点 | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | 原始 counts，按样本；MAD 阈值 | 原脚本未函数化，未在本库验证；阈值是课题设定 |
""",
    "doublet-detection": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDoubletCalling` 的 scDblFinder 分支 | [[methods/scp-cellqc-doublet]]；`SCP-local/R/SCP-cellqc.R` | 原始 counts、按样本、预期双细胞率；输出 class/score | 已封装；scDblFinder 缺失，`not_run` |
| 青光眼 `preprocess.R` 的 DoubletFinder | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | 预处理对象、按样本；paramSweep 选 pK、modelHomotypic、7.5% 预期率 | 原脚本未函数化；DoubletFinder 缺失，未验证 |
| SCP 的 Scrublet / DoubletDetection / scds 分支 | `SCP-local/R/SCP-cellqc.R` | 原始 counts；不同算法假设不同 | 未实现、未运行；不能与 scDblFinder 互换 |
""",
    "batch-integration": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `Seurat_integrate` 锚点法 | [[methods/scp-integration]]；`SCP-local/R/SCP-workflow.R` | 含 batch 列的 counts；整合嵌入与聚类 | 已封装并 verified（120 细胞/2 批） |
| SCP `Harmony_integrate` | 同上 | PCA + batch；Harmony 嵌入 | 已封装；harmony 缺失，`not_run` |
| 青光眼 `preprocess.R` 的 Harmony | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程 + Harmony | 原脚本未函数化；未在本库验证 |
""",
    "differential-expression": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDEtest`：Seurat `FindMarkers` + p 校正 | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | 标准化 Seurat、分组列；gene×contrast 表 | 已封装并 verified（Ductal vs Endocrine） |
| conserved/disturbed marker 等分支 | 同上 | 多分组/配对设计 | 未实现、未运行 |
| 青光眼课题 | `source/` 中未发现独立 DE 脚本；旧 SCP 技术页只归档 SCP 实现 | — | 不声称有独立课题实现 |
""",
    "gene-set-enrichment": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunEnrichment` 的 ORA + 显式 TERM2GENE | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | 基因列表/背景、基因集；ORA 表 | 已封装并 verified（两个自定义基因集） |
| 在线 GO/KEGG 数据库、GO simplify、GSEA | 同上 | 物种/ID 资源、排序列表 | 未运行；GSEA 是不同策略，未实现 |
| 青光眼 `score_pathway_signatures.R` | [[methods/scrna-pathway-signature-ensemble]] | GO/KEGG 用于构建签名基因集，随后打分 | 是打分来源，不是 ORA 实现；未函数化为富集 |
""",
    "gene-set-scoring": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `CellScoring` 的 Seurat/AddModuleScore 分支 | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | Seurat + 命名基因集；每细胞分数 | 已封装并 verified（显式 `name="X"`） |
| AUCell / UCell 分支 | 同上 | 排序或签名分数 | 未运行；依赖缺失 |
| 青光眼 `score_pathway_signatures.R` 的五种分数相加 | [[methods/scrna-pathway-signature-ensemble]]；`source/score_pathway_signatures.R` | AddModuleScore/AUCell/ssGSEA/UCell/singscore 求和 | 课题特定组合，不是通用标准；原脚本未函数化、未验证 |
""",
    "trajectory-inference": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunSlingshot` | [[methods/scp-trajectory-velocity]]；`SCP-local/R/SCP-analysis.R` | 嵌入 + cluster + 起点/终点；lineage/pseudotime | 已封装并 verified（80 细胞，CellType 分组） |
| Monocle2 / Monocle3 / PAGA / Palantir / WOT | 同上 | 不同轨迹模型与输入 | 未实现、未运行；不能与 Slingshot 互换 |
| 青光眼课题 | `source/` 中未发现独立轨迹脚本 | — | 不声称有独立课题实现 |
""",
    "rna-velocity": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunSCVELO`（scVelo） | [[methods/scp-trajectory-velocity]]；`SCP-local/R/SCP-analysis.R` | spliced/unspliced + 降维；速度/潜时间 | 已封装；RETICULATE_PYTHON/scVelo 缺失，`not_run` |
| 其他 velocity 实现 | — | 需不同层/模型 | 未实现；不以其他算法冒充 |
| 青光眼课题 | `source/` 中未发现独立 velocity 脚本 | — | 不声称有独立课题实现 |
""",
    "cell-type-annotation": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 参考标签注释：SCP `RunSingleR`（cell/cluster level） | [[methods/scp-annotation-projection]]；`SCP-local/R/SCP-cell_annotation.R` | query/reference Seurat + ref 标签；预测标签/分数 | 已封装；SingleR 缺失，`not_run` |
| 青光眼 marker 手工注释 | [[methods/scrna-marker-annotation]]；`source/annotation.R` | 预处理对象、作者 marker 列表/`celltype_map`；手动标签 | 原脚本硬编码 marker/映射，未函数化、未验证；不是 SingleR 替代品 |
| 参考图谱映射（Seurat 标签转移） | [[methods/reference-mapping]] | query/reference + 参考标签；预测/分数 | 属参考映射家族；本页不重复实现，也不把它当 SingleR |
""",
    "reference-mapping": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| Seurat `FindTransferAnchors` + `TransferData` 标签转移 | [[methods/scp-annotation-projection]]；`SCP-local/R/SCP-projection.R` 的 `RunSeuratMap` 分支 | query/reference + ref 标签；预测标签/分数 | 已从源码提取并 verified（300 ref/700 query）；不含 UMAP 投影 |
| SCP `RunSeuratMap` 的 UMAP 投影 | 同上 | query 投影到参考 UMAP | 投影分支在 Seurat 5.6 下报 `dim.` 错误，`not_run` |
| 青光眼 marker 手工注释 | [[methods/scrna-marker-annotation]] | marker→类型 | 是注释策略，不是参考映射；不混为同一实现 |
""",
    "dimensionality-reduction": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDimReduction` 的 PCA + UMAP | [[methods/scp-standard-workflow]]；`SCP-local/R/SCP-workflow.R` | 标准化/缩放对象/HVF；嵌入 | 已封装并 verified（200 细胞/100 HVF/20 PC） |
| 其他线性/非线性分支 | 同上 | ICA/NMF/tSNE/DM/PHATE 等 | 未运行；不能因 PCA/UMAP 通过而声称全部支持 |
| 青光眼 `preprocess.R` 的 PCA/UMAP/Harmony | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程 | 原脚本未函数化；未在本库验证 |
""",
    "cell-clustering": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 显式 Seurat `FindNeighbors` + `FindClusters`（SCP Standard_SCP 分支） | [[methods/scp-standard-workflow]]；`SCP-local/R/SCP-workflow.R` | 已有 PCA/UMAP、dims/resolution；cluster 标签 | 已提炼并 verified（200 细胞/PCA 1:20） |
| 青光眼 `preprocess.R` 的 FindClusters/clustree | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | Seurat 流程、多分辨率 | 原脚本未函数化；未在本库验证 |
| Louvain/Leiden/SLM | Seurat 分支 | 图聚类算法 | 仅验证默认 Louvain 分支；其他未运行 |
""",
    "dynamic-feature-analysis": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDynamicFeatures` 的 mgcv GAM | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | Seurat + pseudotime/lineage + features；GAM 表 | 已封装并 verified（80 细胞 + 夹具 pseudotime，Gaussian） |
| 计数/负二项 family、多个 lineage、自动 HVF | 同上 | counts/多个轨迹 | 未运行；不能因 Gaussian 通过而声称全部支持 |
| 青光眼课题 | `source/` 中未发现独立动态特征脚本 | — | 不声称有独立课题实现 |
""",
    "shap-explanation": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 原帖 XGBoost + SHAP 示例 | 画廊 `2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f` `original_code/`；旧复用脚本 `code/shap_explain.py` | 训练/预测/归因的组合脚本 | 原字节保留；历史脚本未提升为已验证实现 |
| 纯函数 `explain_model` | 本次从旧脚本归因分支提炼；`code/explain_model.py` | 已拟合模型 + background + samples；values/summary/samples | verified：解析线性模型数值、顺序、输入不变 |
| 树/线性/通用解释器 | 同上 | 不同模型/输出 | 代码分支存在；真实模型/课题未运行 |
""",
    "regression-resampling-evaluation": """
| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 原帖回归 + 重采样示例 | 画廊 `2026-10-19-regression-stability/figures/fig03-density-panel`；原帖链接见 frontmatter | 训练、验证、绘图组合 | 原始材料只作来源；训练/重采样未在本库实现 |
| `summarize_predictions` | `code/summarize_predictions.py` | 已有折外预测表 → 逐折指标 | verified：手算指标、coverage、输入不变 |
| 训练/调参/验证划分 | 课题原有代码 | 模型与重采样 | 本库不训练、不重采样；不能由汇总脚本声称已完成 |
""",
}


def update_full(mid, title, summary, contract, keywords, body_items):
    page = WIKI / "methods" / f"{mid}.md"
    meta, body = read_page(page)
    facts = get_block(body, "facts")
    user = user_block(body)
    meta.update({
        "summary": summary,
        "data_contract": contract,
        "keywords": keywords,
    })
    write_page(page, meta, render(title, facts, sections(body_items), user))


def update_table(mid, after="原理与选择"):
    page = WIKI / "methods" / f"{mid}.md"
    meta, body = read_page(page)
    table = TABLE[mid].strip()
    if "## 来源与实现选择" not in body:
        body = insert_after_section(body, after, "## 来源与实现选择\n\n" + table)
        write_page(page, meta, body)


def main():
    update_full(
        "cell-type-annotation", "细胞类型注释",
        "综合参考标签与 marker 集合给细胞分配类型；SingleR 分支未运行，青光眼 marker 手工注释尚未函数化。",
        {"input": "query Seurat；参考标签分支需 reference Seurat + ref_group，marker 分支需预先定义的 marker→类型映射；同物种/同基因标识。",
         "output": "每细胞 predicted label 与分数（SingleR 成功时），或手工 marker 注释标签表；当前无已验证输出。"},
        ["SingleR", "marker", "cell type", "annotation", "参考注释", "手工注释", "SCP", "GSE251716"],
        [
            ("用途", """
             把查询数据集的细胞分配到已知或预先定义的细胞类型。可由参考数据集的标签学习（SingleR 等），也可由作者预先定义的 marker→类型映射做手工注释；两条路线都需用 marker 表达、组成和独立方法复核，不能把标签当已验证的生物学身份。
            """),
            ("原理与选择", """
             参考标签路线用参考数据集的差异基因/标签给 query 打分（SingleR），要求 query/ref 组织、物种、平台和基因标识可比。Marker 路线用一组先验 marker 检查 cluster/细胞的表达并人工指定类型，依赖 marker 特异性和作者判断；它不需要参考数据，但不能自动发现 novel 类型。Seurat label transfer 属于 reference-mapping 家族，不应与 SingleR 或手工注释混为同一算法。
            """),
            ("来源与实现选择", TABLE["cell-type-annotation"]),
            ("适用", """
             - 参考路线：有匹配组织/物种、标签可靠的 reference，且 query/ref 共享足够基因。
             - Marker 路线：有组织/状态特异的 marker 列表和可解释的 cluster；作者能说明 marker→类型的依据。
             - 两条路线都用 marker、组成、独立方法或人工复核交叉检查；novel 类型允许保留“未定”。
            """),
            ("不适用", """
             - SingleR 没有合适 reference 时不适用；这不等于“无参考就不能注释”，可改用有依据的 marker 路线，但必须明确其主观性和局限。
             - 参考/查询组织、物种、平台差异大，或参考标签本身不可靠；novel 类型可能被强行分配到最近标签。
             - 只靠 cluster 编号或单个 marker 名字猜类型；把预测标签或手工标签当已验证的生物学身份、分类概率或因果结论。
            """),
            ("输入", """
             参考路线：query/reference Seurat、`ref_group` 标签列、assay；marker 路线：query Seurat、命名 marker 列表或 `celltype_map`、cluster/细胞标签。两条路线都需同物种、同基因标识和可追踪的细胞身份。
            """),
            ("怎么做", """
             1. 先选路线：有可靠 reference 时可用 SingleR；没有 reference 但有组织特异 marker 时可用 marker 路线；两者都不可行时不要强行命名。
             2. 参考路线：核对参考来源/标签/物种/平台，检查基因交集和数据尺度，运行 SingleR，保留每细胞/每 cluster 分数和 pruned label。
             3. Marker 路线：先固定 marker 列表和类型映射，检查 marker 在 cluster/细胞中的表达与特异性；按预先规则分配，记录人工判断和不确定项。
             4. 用 UMAP、marker 点图、样本组成和独立方法复核；低置信度/混合群保留“未定/待定”。
             5. 注释结果再进入图样；不要让注释反过来证明聚类正确，也不要把手工注释写成自动算法验证。
            """),
            ("代码", """
             - 参考路线：`methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle, parameters)` 封装 SCP `RunSingleR`。本机 R 库没有 SingleR，实际错误为 `Missing R dependency: SingleR; automatic installation is disabled`，状态 `not_run`。
             - Marker 路线：青光眼 `annotation.R` 是硬编码 marker 列表和 `celltype_map` 的课题脚本，保留在 [[methods/scrna-marker-annotation]] 的 `source/`；本轮未函数化、未验证，不提供可执行入口。
             - 参考图谱映射见 [[methods/reference-mapping]]；它是另一家族，不因本页 SingleR 未运行而自动可用。
            """),
            ("输出", """
             参考路线成功时返回 SCP 上游对象/列表，含 `singler_annotation`、`singler_score` 等；marker 路线应输出 cell/cluster、label、依据 marker 和不确定标记。当前没有已验证输出；不得把参考标签或手工标签直接复制成“自动注释结果”。
            """),
            ("知识关联检查", """
             2026-10-23 检查了 UMAP 分组、特征 UMAP、气泡点图和细胞比例模板。预测标签或手工标签都可着色 UMAP、检查 marker、展示组成；均为 adaptable，模板不执行注释。没有 direct：模板不读 Seurat 注释结果。来源页 [[methods/scrna-marker-annotation]] 提供 marker 手工注释原始脚本，[[methods/scp-annotation-projection]] 提供 SCP SingleR/投影来源；双向链接已建立。注释与参考映射的区别见 [[methods/reference-mapping]]。
            """),
            ("使用记录", """
             2026-10-23：核对 SCP RunSingleR、青光眼 marker 注释脚本与本机依赖；SingleR 缺失、marker 脚本未函数化，均未写成已验证实现。
            """),
        ])
    update_full(
        "doublet-detection", "双细胞检测",
        "按样本识别双细胞；scDblFinder 与 DoubletFinder 是不同算法，当前均未在本机跑通，保留来源与精确缺失原因。",
        {"input": "按样本的 Seurat 原始 counts；显式预期双细胞率；scDblFinder 或 DoubletFinder 分支及其预处理前提。",
         "output": "每细胞 doublet class/score（运行成功时）；当前两条路线均未产生结果。"},
        ["doublet", "scDblFinder", "DoubletFinder", "Scrublet", "DoubletDetection", "scds", "双细胞", "SCP"],
        [
            ("用途", """
             在 QC 阶段识别同一液滴中两个及以上细胞，避免双细胞在聚类、差异表达和轨迹分析中形成假中间态。输出是细胞级 doublet 标签/分数，供过滤或敏感性分析使用。
            """),
            ("原理与选择", """
             scDblFinder 通过模拟双细胞/表达距离并参考预期双细胞率判断异常液滴；DoubletFinder 先做参数扫描选 pK，再用同型双细胞比例校正预期数（青光眼脚本用 7.5%），每样本独立运行。两者都依赖原始 counts、样本结构和预期率，但模型/参数不同，不能把一者的阈值或结果直接套到另一者。SCP `RunDoubletCalling` 还可分发 Scrublet、DoubletDetection、scds；本页只封装 scDblFinder，其他未实现。
            """),
            ("来源与实现选择", TABLE["doublet-detection"]),
            ("适用", """
             - 10x 等液滴 scRNA-seq 原始 counts，按样本分别处理。
             - 有可解释的预期双细胞率，或至少有同批上样量/阴性对照记录。
             - 双细胞标签用于过滤和敏感性分析，而不是作为生物学分组。
            """),
            ("不适用", """
             - 已聚合的伪 bulk、无细胞级 counts 的数据不能直接使用。
             - 不同样本/建库协议双细胞率差异大时，不能用一个固定比例跨样本删除。
             - doublet score 不是细胞类型或疾病状态；不能把高分细胞直接解释为某种生物学亚群。
             - scDblFinder 与 DoubletFinder 结果不一致时，不能静默选一个；要说明算法差异和敏感性。
            """),
            ("输入", """
             按样本的 Seurat 原始 counts、`assay`、预期双细胞率；scDblFinder 分支用 `db_method="scDblFinder"`/`db_rate`，DoubletFinder 分支需要预处理对象、PC 数、pN、预期率和同型校正。输出每行一个细胞，保留样本、方法和参数。
            """),
            ("怎么做", """
             1. 按样本确认上样细胞数、建库批次和预期双细胞率；没有记录时先与作者确认，不猜“标准”比例。
             2. 选算法：scDblFinder 或 DoubletFinder；说明选择依据，不把两者当可互换。
             3. scDblFinder：按样本运行并保留 class/score；DoubletFinder：Normalize/HVG/PCA/FindNeighbors/FindClusters/UMAP → paramSweep → 最优 pK → 同型校正 → doubletFinder，保留参数。
             4. 查看 score 分布和样本差异；阈值改变时重跑下游，记录对聚类/差异分析的影响。
             5. 双细胞过滤后仍检查高线粒体、低 UMI 和物种混合；这些不是同一问题。
            """),
            ("代码", """
             - scDblFinder：`methods/doublet-detection/code/analysis.R:run_doublet_detection(srt, bundle, parameters)` 封装 SCP `RunDoubletCalling`。本机缺 scDblFinder，精确错误为 `Missing R dependency: scDblFinder; automatic installation is disabled`，状态 `not_run`。
             - DoubletFinder：青光眼 `preprocess.R` 的 paramSweep/modelHomotypic/7.5% 逻辑保留在 [[methods/scrna-preprocess-doublet-qc-harmony]] 的 `source/`；本轮未函数化、未验证，DoubletFinder 也未安装。
             - 两条路线都不能因另一条通过/失败而升级；当前没有任何 verified 双细胞分支。
            """),
            ("输出", """
             运行成功时输出每细胞 doublet class 与 score、方法和参数；当前没有结果。不得用其他样本的 doublet 标签或另一种算法的结果冒充本数据输出。
            """),
            ("知识关联检查", """
             2026-10-23 检查了 UMAP 分组图与细胞比例图模板。双细胞标签可作为 UMAP 着色或样本比例，模板不执行检测，关系为 adaptable；没有 direct。双细胞 score 的分布图本库暂无专用模板。来源页 [[methods/scp-cellqc-doublet]] 与 [[methods/scrna-preprocess-doublet-qc-harmony]] 提供 SCP 与 DoubletFinder 原始实现，双向链接已建立。
            """),
            ("使用记录", """
             2026-10-23：核对 SCP scDblFinder 分支与青光眼 DoubletFinder 脚本；scDblFinder/DoubletFinder 均缺失，保留 not_run/未函数化，不安装。
            """),
        ])
    for mid in TABLE:
        if mid not in ("cell-type-annotation", "doublet-detection"):
            update_table(mid, "原始实现与家族范围" if mid in ("shap-explanation", "regression-resampling-evaluation") else "原理与选择")
    # Add DoubletFinder keyword on the doublet page (already set in update_full).
    print("round1 content updated")


if __name__ == "__main__":
    main()
