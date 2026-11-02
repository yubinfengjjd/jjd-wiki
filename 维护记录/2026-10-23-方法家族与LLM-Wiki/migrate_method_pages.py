"""Compile the 15 analysis families and reclassify the 13 old method pages.

The script preserves <!-- user:... --> bytes, leaves status untouched, removes
primary figure_relations from old source/technical pages, and moves the
semantically relevant relations to the real analysis families.
"""
from pathlib import Path
import copy
import re
import sys
import textwrap

import yaml

WIKI = Path("E:/research-wiki/知识库")
sys.path.insert(0, "E:/research-wiki/开发/staged/research-wiki")
from rwiki.pages import read_page, write_page, get_block  # noqa: E402

SCP = {"kind": "repo", "url": "https://github.com/zhanghao-njmu/scp",
       "commit": "b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0"}
SCP_CITE = ["SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)"]


def clean(text):
    return textwrap.dedent(text).strip()


def sections(items):
    return "\n\n".join(f"## {title}\n\n{clean(body)}" for title, body in items)


def render_body(title, facts, body_sections, user_block):
    return (f"# {title}\n\n<!-- facts:start -->{facts}<!-- facts:end -->\n\n"
            f"{body_sections}\n\n{user_block}\n")


def get_user_block(body):
    start = body.index("<!-- user:start -->")
    end = body.index("<!-- user:end -->") + len("<!-- user:end -->")
    return body[start:end]


def replace_section(body, title, text):
    user = get_user_block(body)
    masked = body.replace(user, " " * len(user))
    pattern = re.compile(rf"^## {re.escape(title)}[ \t]*\r?\n(.*?)(?=^## |\Z)", re.M | re.S)
    match = pattern.search(masked)
    if match:
        return body[:match.start(1)] + "\n" + clean(text) + "\n\n" + body[match.end(1):]
    marker = "<!-- user:start -->"
    return body.replace(marker, f"## {title}\n\n{clean(text)}\n\n{marker}", 1)


def load_relations(page):
    meta, _ = read_page(WIKI / f"methods/{page}.md")
    return meta.get("figure_relations", [])


def relation(page, needle, family, reason=None, adaptation=None):
    for item in load_relations(page):
        if needle in item["figure"]:
            record = copy.deepcopy(item)
            if reason:
                record["reason"] = reason
            if adaptation:
                record["adaptation"] = adaptation
            evidence = [f"methods/{family}.md#输出", f"methods/{page}.md#知识关联检查"]
            evidence += [p for p in record.get("evidence", []) if p not in evidence]
            record["evidence"] = evidence
            record["verification"] = {
                "state": "not_run",
                "scope": "2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。",
                "evidence": [],
            }
            return record
    raise KeyError(f"{page}: relation {needle} not found")


def impl(iid, title, language, entrypoint, dependencies, verification):
    return {"id": iid, "title": title, "language": language,
            "entrypoint": entrypoint, "dependencies": dependencies,
            "verification": verification}


FAMILIES = {}

FAMILIES["cell-quality-control"] = dict(
    title="单细胞质量控制",
    summary="按显式阈值计算逐细胞 UMI、基因数与线粒体/核糖体比例，标记 Pass/Fail，不把 QC 指标当生物学分组。",
    keywords=["QC", "nCount", "nFeature", "percent.mito", "percent.ribo", "低质量细胞", "SCP"],
    contract={"input": "Seurat RNA assay 的原始 counts（基因×细胞）；每个细胞一列，每个基因一行。",
              "output": "每细胞一行的 QC 结果：nCount_RNA、nFeature_RNA、percent.mito、percent.ribo、CellQC=Pass/Fail。"},
    implementations=[impl("scp-runcellqc", "SCP RunCellQC 封装", "R",
                          "code/analysis.R:run_cell_quality_control",
                          ["Seurat", "SeuratObject"], "verification/scp-runcellqc.json")],
    relations=[
        relation("scp-cellqc-doublet", "fig01-cns-umap", "cell-quality-control",
                 "QC 的 Pass/Fail 或指标可作为 UMAP 着色变量；模板只画表，不计算 QC。",
                 "导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group=CellQC 或样本）；模板不读 RDS。"),
        relation("scp-cellqc-doublet", "fig04-cell-proportion", "cell-quality-control",
                 "按样本/条件统计 QC Pass/Fail 比例，可复用比例堆叠与流带模板；模板不做统计检验。",
                 "导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。"),
        relation("scp-cellqc-doublet", "fig06-pathway-violin", "cell-quality-control",
                 "QC 指标按样本或细胞类型分组的分布可用分组小提琴展示；模板不重算阈值。",
                 "导出 render-grouped-values.csv 和可选的 render-group-summaries.csv。"),
    ],
    body=[
        ("用途", """
         在进入归一化、整合、降维之前，逐细胞计算文库大小、检出基因数、线粒体/核糖体读段比例，并按课题预先规定的阈值标记 Pass/Fail。结果用于决定哪些细胞进入下游，不是把 QC 指标当作细胞类型或生物学分组。
        """),
        ("原理与选择", """
         破损细胞常表现为低 UMI、低基因数或高线粒体比例；双细胞、环境 RNA、物种混合是不同问题，需分别检测。阈值受组织、建库版本和测序深度影响，不能照搬固定值。SCP `RunCellQC` 把 UMI、基因数、线粒体、核糖体、ribo/mito 比、离群点和双细胞组合成 `CellQC`；本页只验证了 UMI/基因数/线粒体阈值分支，双细胞与离群点分支未运行。
        """),
        ("适用", """
         - 原始 counts，且基因标识与物种明确；可按样本分别检查。
         - 需要把细胞级 QC 失败原因记录并带入后续分析，而不是静默删细胞。
         - 阈值由课题数据分布、组织类型、建库协议和既往经验共同确定，并写入方法。
        """),
        ("不适用", """
         - 已归一化/积分的表达值不能直接当 raw counts 计算这些指标。
         - 不能仅凭 QC 指标给细胞定型，也不能把 Pass/Fail 当作处理组或生物学差异。
         - 不同物种/建库方案共用固定阈值、或跨样本比较未标准化的线粒体比例，容易得出误导结论。
        """),
        ("输入", """
         Seurat 对象（`RNA` assay 的 `counts`），或能转为同样基因×细胞矩阵的对象；`qc_metrics`、`UMI_threshold`、`gene_threshold`、`mito_threshold`、`ribo_threshold` 等参数显式传入。每个细胞是一行结果，不是每个样本一行。
        """),
        ("怎么做", """
         1. 按样本查看 nCount、nFeature、percent.mito 的分布，结合组织与建库记录确定阈值；不要先看下游聚类再倒推阈值。
         2. 显式列出要计算的指标；本页已验证 UMI、基因数、线粒体阈值。
         3. 运行 `RunCellQC`，保留 Pass/Fail 及每个失败原因；若决定过滤，记录过滤前后细胞数和样本组成。
         4. 对边界细胞做敏感性分析（保留/剔除各跑一次下游），不要把单次阈值当唯一真值。
         5. 双细胞、离群点、物种混合按各自方法单独处理；本页不把它们的阈值混入 UMI/基因数结论。
        """),
        ("代码", """
         入口 `methods/cell-quality-control/code/analysis.R:run_cell_quality_control(srt, bundle, parameters)`。`bundle` 指向复制到课题的完整 `SCP-local` 目录，函数按固定哈希校验后 source，不写死知识库路径；依赖 Seurat、SeuratObject。参数与 SCP `RunCellQC` 同名，统计逻辑未改。

         验证：2026-10-23 在 `pancreas_sub` 的 80 个细胞上实际调用，封装与上游 `CellQC` 一致，输入对象未被修改；scope 仅软件调用，不代表科学有效或真实课题阈值合理。双细胞/离群点分支未运行，缺失原因见对应家族页。
        """),
        ("输出", """
         返回 `list(result=Seurat, diagnostics=...)`。`result@meta.data` 增加 `nCount_RNA`、`nFeature_RNA`、`percent.mito`、`percent.ribo`、`CellQC`（Pass/Fail）等字段；一行一个细胞。没有强制 CSV；出图前由课题显式导出对应接口表。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 `templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap`、`fig04-cell-proportion-flow--stacked-bar-flow`、`fig06-pathway-violin--violin`。QC Pass/Fail 或指标可作为 UMAP 着色、样本比例、分组分布；模板不计算 QC，关系为 adaptable。没有 direct：模板不读 Seurat 对象，需先导出 `render-umap-groups`、`render-cell-proportions`、`render-grouped-values` 等接口。双细胞图不在此页直连，见 [[methods/doublet-detection]]。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用 `pancreas_sub` 80 细胞做软件调用、输入不变和上游一致性检查；未做真实课题阈值决策。
        """),
    ],
)

FAMILIES["doublet-detection"] = dict(
    title="双细胞检测",
    summary="识别同一液滴中两个及以上细胞的转录组，按样本和预期双细胞率标记，供 QC 与下游过滤决策。",
    keywords=["doublet", "scDblFinder", "Scrublet", "DoubletDetection", "scds", "双细胞", "SCP"],
    contract={"input": "Seurat RNA assay 的原始 counts；通常按样本分别运行，并显式给出预期双细胞率。",
              "output": "每细胞一行的 doublet class/score（运行成功时）；当前分支未运行，未产生结果。"},
    implementations=[impl("scp-rundoublet", "SCP RunDoubletCalling 的 scDblFinder 分支", "R",
                          "code/analysis.R:run_doublet_detection",
                          ["Seurat", "scDblFinder"], "verification/scp-rundoublet.json")],
    relations=[
        relation("scp-cellqc-doublet", "fig01-cns-umap", "doublet-detection",
                 "双细胞标签可作为 UMAP 着色变量检查分布；模板不检测双细胞。",
                 "导出 render-umap-groups.csv（group=doublet class 或样本）；标签只作描述。"),
        relation("scp-cellqc-doublet", "fig04-cell-proportion", "doublet-detection",
                 "按样本统计双细胞比例可复用比例图；模板不做双细胞检测或统计检验。",
                 "导出 render-cell-proportions.csv（group=样本, celltype=doublet class, proportion）。"),
    ],
    body=[
        ("用途", """
         在 QC 阶段识别同一液滴中两个及以上细胞，避免双细胞在聚类、差异表达和轨迹分析中形成假中间态。输出是细胞级 doublet 标签/分数，供过滤或敏感性分析使用。
        """),
        ("原理与选择", """
         scDblFinder 等方法用模拟双细胞或表达距离判断异常液滴；预期双细胞率通常随上样细胞数变化，需按样本和建库协议给出。SCP `RunDoubletCalling` 可分发 scDblFinder、Scrublet、DoubletDetection、scds 等分支；本页只封装 scDblFinder 分支，其他分支没有在本机运行。
        """),
        ("适用", """
         - 10x 等液滴 scRNA-seq 原始 counts，按样本分别处理。
         - 有可解释的预期双细胞率，或至少有同批阴性对照/上样量记录。
         - 双细胞标签用于过滤和敏感性分析，而不是作为生物学分组。
        """),
        ("不适用", """
         - 已聚合的伪 bulk、无细胞级 counts 的数据不能直接使用。
         - 不同样本双细胞率差异很大时，不能用一个固定阈值跨样本删除。
         - doublet score 不是细胞类型或疾病状态；不能把高分细胞直接解释为某种生物学亚群。
        """),
        ("输入", """
         Seurat 对象的原始 counts、`assay`、`db_method`、`db_rate`；按样本运行时，每个样本一个对象或显式分组。输出每行一个细胞，需保留样本身份和检测方法。
        """),
        ("怎么做", """
         1. 按样本确认上样细胞数和建库批次，给出预期双细胞率；没有记录时先与作者确认，不猜一个“标准”比例。
         2. 运行 scDblFinder 分支，保留 score 和 class，不要只保留最终删除列表。
         3. 查看 score 分布与样本间差异；阈值改变时重跑下游，记录对聚类/差异分析的影响。
         4. 双细胞过滤后仍应检查高线粒体、低 UMI 和物种混合；这些不是同一问题。
        """),
        ("代码", """
         入口 `methods/doublet-detection/code/analysis.R:run_doublet_detection(srt, bundle, parameters)`，参数显式传入 SCP `RunDoubletCalling`。依赖 scDblFinder；本机 R 库没有该包，函数保留但未运行。

         验证状态：`not_run`。实际错误为 `Missing R dependency: scDblFinder; automatic installation is disabled`。加载器和 `check_R` 只做缺包报告，不触发安装；不能把函数存在当作检测通过。
        """),
        ("输出", """
         运行成功时返回 SCP 上游对象/列表，含每细胞 doublet class 与 score；当前未运行，因此没有任何可用于出图或过滤的结果。不要用其他样本的 doublet 标签冒充本数据结果。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组图与细胞比例图模板。双细胞标签可作为 UMAP 着色或样本比例，模板不执行检测，关系为 adaptable；没有 direct。双细胞 score 的分布图本库暂无专用模板，不能把 UMAP 分组图当作 doublet score 图。
        """),
        ("使用记录", """
         2026-10-23：核对 SCP 分支与本机依赖；scDblFinder 缺失，保留 not_run，未安装。
        """),
    ],
)

FAMILIES["batch-integration"] = dict(
    title="单细胞批次整合",
    summary="在保留生物差异的前提下对齐样本/技术批次，产出整合嵌入与聚类，供跨样本比较。",
    keywords=["batch", "integration", "Seurat", "Harmony", "锚点", "批次校正", "SCP"],
    contract={"input": "含明确 batch 列的 Seurat 原始 counts（batch 是样本/技术批次，不是生物学分组）。",
              "output": "整合后的 Seurat 对象（Seuratpca、SeuratUMAP2D、Seuratclusters）或每细胞嵌入表。"},
    implementations=[
        impl("scp-seurat", "SCP Seurat_integrate 锚点分支", "R",
             "code/analysis.R:run_seurat_integration", ["Seurat", "SeuratObject"],
             "verification/scp-seurat.json"),
        impl("scp-harmony", "SCP Harmony_integrate 分支", "R",
             "code/analysis.R:run_batch_integration", ["Seurat", "harmony"],
             "verification/scp-harmony.json"),
    ],
    relations=[
        relation("scp-integration", "fig01-cns-umap", "batch-integration",
                 "整合后的嵌入可按 batch 或 celltype 着色，复用现有 UMAP 单 panel；模板不做整合。",
                 "导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）；模板不读 RDS。"),
        relation("scp-integration", "fig04-cell-proportion", "batch-integration",
                 "按 batch/样本统计细胞类型比例，可检查整合前后组成是否被过度改变；模板不做统计检验。",
                 "导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。"),
    ],
    body=[
        ("用途", """
         把来自不同样本、测序批次或技术平台的细胞放进同一个嵌入，减少批次带来的分离，同时保留真实的细胞类型和状态差异。输出是整合对象、嵌入和聚类，供跨样本比较与出图。
        """),
        ("原理与选择", """
         Seurat 锚点法先找跨批次相互最近的细胞对，再校正表达；Harmony 在 PCA 空间迭代校正。两者都假设批次间存在可对齐的共享细胞类型；如果批次与疾病/处理完全混杂，整合不能替代研究设计。SCP `Integration_SCP` 还提供 scVI、MNN、fastMNN、Scanorama、BBKNN、CSS、LIGER、Conos、ComBat 等分支；本页只验证 Seurat 分支，Harmony 分支因缺包未运行。
        """),
        ("适用", """
         - 多个样本/技术批次，存在重叠细胞类型，且 batch 列与生物学分组可区分。
         - 需要联合聚类、跨样本 UMAP 或比较细胞类型比例。
         - 有明确的批次定义和足够的跨批次锚点。
        """),
        ("不适用", """
         - 只有单一批次，或 batch 与疾病/处理完全重合：整合会掩盖真实差异。
         - 细胞类型完全不重叠、物种不同或基因标识不可比时，锚点法不适用。
         - 不能用整合后的“混合得更好”证明生物学差异消失或数据质量更高。
        """),
        ("输入", """
         一个带 `batch` 元数据列的 Seurat 对象（原始 counts），或按批次拆分的对象列表；`batch` 必须显式给出，不能从文件名猜。每个细胞一行嵌入，需保留原始样本/批次身份。
        """),
        ("怎么做", """
         1. 明确 batch 是技术批次还是样本；检查 batch 与分组是否完全混杂。
         2. 按 SCP/Seurat 分支做归一化、HVF、锚点、整合、PCA/UMAP；参数（HVF 数、dims、k.weight）显式记录。
         3. 同时看整合前后 batch 混合、细胞类型 marker 是否保留、比例是否被过度改变。
         4. 与未整合/其他方法做敏感性比较；不能只挑混合最好的一张图。
         5. Harmony、scVI 等分支只有在依赖可用且实际运行后才可声称支持。
        """),
        ("代码", """
         - Seurat 分支：`methods/batch-integration/code/analysis.R:run_seurat_integration(srt, batch, bundle, parameters)`，封装 SCP `Seurat_integrate`。2026-10-23 在 `pancreas_sub` 120 细胞、两个显式批次、300 HVF、20 PC、`k.weight=30` 上实际调用；封装与上游 UMAP 一致，输出 `Seuratpca`、`SeuratUMAP2D`、`Seuratclusters`。scope 仅软件夹具。
         - Harmony 分支：同文件 `run_batch_integration(srt, bundle, parameters)`，封装 `Harmony_integrate`；本机无 harmony，`not_run`，精确错误 `Missing R dependency: harmony; automatic installation is disabled`。

         两个分支独立验证；Seurat 分支通过不批准 Harmony 分支。
        """),
        ("输出", """
         Seurat 分支返回 `list(result=Seurat, diagnostics=...)`；`result` 含整合 assay、`Seuratpca`、`SeuratUMAP2D`、`Seuratclusters`。可另导出每细胞 `cell_id, batch, umap_1, umap_2` 供模板使用。Harmony 分支当前无输出。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组图与细胞比例图。整合嵌入可按 batch/celltype 着色，比例图可检查组成变化；两者都是 adaptable，模板不执行整合。没有 direct。不能把“整合后 UMAP 混合”当作批次校正成功的唯一证据，仍需 marker 与比例检查。
        """),
        ("使用记录", """
         2026-10-23：Seurat 分支在隔离 R 环境实际运行并与上游比较；Harmony 分支缺包保留 not_run，未安装。
        """),
    ],
)

FAMILIES["differential-expression"] = dict(
    title="差异表达分析",
    summary="在明确对比组之间检验基因表达差异，输出效应量、p 值与阳性比例；细胞级 p 值不等于样本级推断。",
    keywords=["DE", "FindMarkers", "Wilcoxon", "avg_log2FC", "p_val_adj", "差异基因", "SCP"],
    contract={"input": "已标准化/注释的 Seurat 对象 + 分组列；比较组与参照组显式给出，组内细胞数足够。",
              "output": "SCP tools 中的 gene×contrast 表：gene、group1、group2、avg_log2FC、p_val、p_val_adj、pct.1、pct.2。"},
    implementations=[impl("scp-detest", "SCP RunDEtest 封装", "R",
                          "code/analysis.R:run_differential_expression",
                          ["Seurat", "BiocParallel"], "verification/scp-detest.json")],
    relations=[
        relation("scp-de-enrichment-dynamic", "fig03-topjournal-bubble", "differential-expression",
                 "DE 选出的 marker 可整理成 group/feature/avg_expression/pct_expressed，复用气泡点图；模板不重算 DE。",
                 "导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。"),
        relation("scp-de-enrichment-dynamic", "fig01-volcano", "differential-expression",
                 "DE 表可整理成 render-de-results，火山图模板消费该表；模板不重跑检验。",
                 "从 AllMarkers 表导出 gene、avg_log2FC、p_val_adj 等字段到 render-de-results。"),
    ],
    body=[
        ("用途", """
         在两组细胞之间找出表达差异的基因，输出效应量、p 值、校正后 p 值和两组阳性比例。用于生成候选 marker、检查注释是否合理，或为富集分析提供基因列表。
        """),
        ("原理与选择", """
         SCP `RunDEtest` 默认调用 Seurat `FindMarkers` 的 Wilcoxon 分支，并按指定方法重新校正 p 值；它支持自定义细胞组、 conserved/disturbed marker 等分支。细胞级检验把每个细胞当独立观测，适合筛选描述性 marker，但不能直接当作样本/患者水平的组间推断；后者需要伪 bulk 或按样本聚合。检验方法、`only.pos`、`fc.threshold`、`min.pct` 都必须显式记录。
        """),
        ("适用", """
         - 已标准化/注释的 Seurat 对象，比较组和参照组明确。
         - 组内细胞数足够（SCP 要求每组至少 3 个细胞），且细胞类型/状态相对一致。
         - 用于 marker 筛选、注释检查或为 ORA/GSEA 提供排序列表。
        """),
        ("不适用", """
         - 把细胞级 p 值当作患者/样本级显著性或组间因果证据。
         - 分组与批次、供体或处理完全混杂时，DE 结果不可解释为处理效应。
         - 只用 p 值排序、不看效应量和阳性比例；或反复改分组直到得到想要的基因。
        """),
        ("输入", """
         已标准化/注释的 Seurat 对象、`group_by` 列、`group1`/`group2`（不指定 group2 时与其余细胞比较）。每个基因×对比一行结果；细胞身份和分组必须在对象中可追踪。
        """),
        ("怎么做", """
         1. 先明确对比：哪两组、参照是谁、是否只看正向 marker；把分组和批次写进分析记录。
         2. 在课题环境检查数据是否为 log-normalized；按需设置 `test.use`、`only.pos`、`fc.threshold`、`min.pct`。
         3. 运行 `RunDEtest`，从 `tools$DEtest_custom$AllMarkers_<test>` 取表；检查 gene、group1/2、avg_log2FC、p_val_adj、pct.1/2。
         4. 用效应量和阳性比例筛选，不只用 p 值；对关键结论做 pseudobulk/样本级敏感性分析。
         5. 把筛选规则和完整表一起保存；富集分析的输入基因列表要能追溯到这里。
        """),
        ("代码", """
         入口 `methods/differential-expression/code/analysis.R:run_differential_expression(srt, bundle, parameters)`，封装 SCP `RunDEtest`，统计逻辑未改。2026-10-23 在 `pancreas_sub` 全数据、`Ductal` vs `Endocrine`、wilcox 上实际调用；封装与上游 `AllMarkers_wilcox` 表一致。scope 仅软件调用，不代表这些基因在真实研究中显著或可重复。

         输出对象是 Seurat；DE 表在 `result$result@tools$DEtest_custom$AllMarkers_wilcox`，不是直接 CSV。页面不把对象存在当成科学结论。
        """),
        ("输出", """
         `AllMarkers_<test>` 为 data.frame，一行一个 gene×对比，含 `gene`、`group1`、`group2`、`avg_log2FC`、`p_val`、`p_val_adj`、`pct.1`、`pct.2` 等列。可另导出为 CSV；出图模板读取的是整理后的 `render-dotplot-long` 或 `render-de-results`，不是这个原始对象。
        """),
        ("知识关联检查", """
         2026-10-23 检查了气泡点图和火山图模板。DE marker 可整理为 group×feature 的平均表达/阳性比例，或 gene×effect/p 值的火山图输入；两者均为 adaptable，模板不重算 DE。没有 direct：模板不读 Seurat tools 槽。细胞级 p 值不能直接标注为样本级显著性，图注需说明检验层级。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用 `pancreas_sub` 实际运行并与上游表比较；未做真实课题的 pseudobulk 或样本级推断。
        """),
    ],
)

FAMILIES["gene-set-enrichment"] = dict(
    title="基因集富集分析",
    summary="用显式基因列表和背景检验基因集过代表（ORA），GO/KEGG 是资源，GSEA 是另一种策略且本页未实现。",
    keywords=["ORA", "GSEA", "GO", "KEGG", "clusterProfiler", "enrichment", "基因集", "SCP"],
    contract={"input": "geneID 向量（可选分组）+ 显式 TERM2GENE/TERM2NAME，或由 DE 表派生的基因列表；背景/物种/ID 类型明确。",
              "output": "每个基因集一行的 ORA 表：ID、Description、GeneRatio、BgRatio、pvalue、p.adjust、qvalue、geneID、Count。"},
    implementations=[impl("scp-enrichment", "SCP RunEnrichment 的 ORA 分支", "R",
                          "code/analysis.R:run_gene_set_enrichment",
                          ["clusterProfiler", "DOSE", "Seurat"], "verification/scp-enrichment.json")],
    relations=[],
    body=[
        ("用途", """
         给定一组候选基因（例如 DE 上调基因）和明确的基因集资源，检验哪些 GO/KEGG/自定义基因集被过代表。输出是基因集级结果表，用于描述候选基因集的生物学主题，不是通路活性或因果证明。
        """),
        ("原理与选择", """
         ORA 用超几何/富集检验比较列表内外的基因集命中；GSEA 则使用全基因排序和基因集内基因的位置。两者不是同一策略：GO、KEGG 只是资源，ORA/GSEA 才是方法。SCP `RunEnrichment` 封装 clusterProfiler/DOSE 的 ORA 分支，也支持自定义 `TERM2GENE`；本页只验证了自定义基因集的 ORA，在线 GO/KEGG 数据库下载和 GSEA 未运行。
        """),
        ("适用", """
         - 有一个定义清楚的基因列表（来源、阈值、方向可追溯）和一个合适的背景/宇宙。
         - 基因 ID 类型、物种与基因集资源一致；自定义基因集可显式提供 `TERM2GENE`/`TERM2NAME`。
         - 用于描述主题或生成假设，后续用独立数据验证。
        """),
        ("不适用", """
         - 没有背景基因集、把全转录组当列表、或混合不同 ID 类型/物种。
         - 把 ORA 的 p 值当作通路活性、因果机制或治疗靶点证据。
         - 用同一批数据反复筛选基因列表和基因集，再报告“显著”。
        """),
        ("输入", """
         `geneID` 向量（可带 `geneID_groups`），`IDtype`、`species`、`minGSSize`/`maxGSSize`，以及 `TERM2GENE`/`TERM2NAME` 或数据库参数。每个基因集一行结果；背景和基因列表版本必须记录。
        """),
        ("怎么做", """
         1. 明确基因列表来源（DE 对比、阈值、方向）和背景/宇宙；不要把整个基因组默认当背景而不说明。
         2. 统一基因 ID 与物种；自定义基因集先检查 term-gene 对和重复。
         3. 运行 `RunEnrichment` 的 ORA 分支，设置基因集大小范围；检查 `GeneRatio`、`BgRatio`、`p.adjust` 和命中基因。
         4. 对基因列表阈值、背景和基因集版本做敏感性分析；不要只报告最显著的通路。
         5. 若要 GSEA，另建排序列表和相应实现；不能把 ORA 结果改称 GSEA。
        """),
        ("代码", """
         入口 `methods/gene-set-enrichment/code/analysis.R:run_gene_set_enrichment(gene_ids, bundle, parameters)`，封装 SCP `RunEnrichment`，统计逻辑未改。2026-10-23 用两个显式自定义基因集和 7 个基因实际调用；封装结果表与上游一致。scope 仅软件调用，基因集是合成示例，不代表真实通路结论。

         在线 GO/KEGG 注释下载、GSEA、GO simplify 分支未运行；缺失时保留函数与 not_run 说明，不安装依赖。
        """),
        ("输出", """
         `result$result$results` 是每个分组/物种组合的 `enrichResult` 列表；取 `@result` 得到 data.frame，一行一个基因集，含 `ID`、`Description`、`GeneRatio`、`BgRatio`、`pvalue`、`p.adjust`、`qvalue`、`geneID`、`Count`。可另导出 CSV；本页不强制统一 CSV。
        """),
        ("知识关联检查", """
         2026-10-23 检查了现有单 panel 模板。ORA 结果是 gene-set×ontology 表，现有 dotplot 的 group×feature 语义不匹配，分组小提琴也不表达富集比例；本库暂无 ORA/GSEA 专用模板，因此不建立 figure_relations。无图原因：缺少语义匹配的富集图模板，不用“结构像”强行直连。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用自定义 TERM2GENE/TERM2NAME 实际运行 ORA 并与上游比较；未运行在线 GO/KEGG 或 GSEA。
        """),
    ],
)

FAMILIES["gene-set-scoring"] = dict(
    title="基因集与通路签名打分",
    summary="按命名基因集给每个细胞打相对签名分数，用于描述状态差异；分数不是通路活性或富集显著性。",
    keywords=["AddModuleScore", "AUCell", "UCell", "ssGSEA", "singscore", "pathway score", "SCP"],
    contract={"input": "Seurat 对象 + 命名基因集列表；同一数据集、同一 assay/slot 内比较。",
              "output": "每细胞×基因集的相对分数（Seurat metadata）或长表；不产出富集 p 值。"},
    implementations=[impl("scp-cellscoring", "SCP CellScoring 的 Seurat/AddModuleScore 分支", "R",
                          "code/analysis.R:run_gene_set_scoring",
                          ["Seurat", "BiocParallel"], "verification/scp-cellscoring.json")],
    relations=[
        relation("scrna-pathway-signature-ensemble", "fig06-pathway-violin", "gene-set-scoring",
                 "通路签名分数按细胞类型/组展示分布，可复用小提琴模板；模板不重算分数或检验。",
                 "导出 render-grouped-values.csv 和可选的 render-group-summaries.csv；细胞级 p 只作描述。"),
    ],
    body=[
        ("用途", """
         用一组先验基因给每个细胞计算相对签名分数，描述细胞在某个通路/状态上的相对高低。常用于在 UMAP 或分组分布中查看候选签名，不用于证明通路被激活或组间有统计差异。
        """),
        ("原理与选择", """
         Seurat `AddModuleScore` 用同表达量分箱的对照基因校正背景；AUCell/UCell/ssGSEA/singscore 是其他打分策略。不同方法的尺度不可直接比较，同一方法跨数据集也受测序深度和基因集覆盖影响。SCP `CellScoring` 支持 Seurat、AUCell、UCell 分支；本页只验证 Seurat 分支，AUCell/UCell 因缺包未运行。原始课题脚本把五种分数直接相加，是本课题的特定组合，不是通用标准实现，本页不复制该求和逻辑。
        """),
        ("适用", """
         - 有明确的基因集定义、基因标识与表达矩阵；同一数据集内做相对比较。
         - 用于探索性可视化、聚类注释辅助或生成假设。
         - 需要比较多个签名时，使用同一打分方法和同一背景。
        """),
        ("不适用", """
         - 把分数当绝对通路活性、因果机制或临床生物标志物。
         - 跨数据集/平台直接比较分数绝对值；或把不同打分方法的分数相加/平均而不说明。
         - 基因集与细胞类型 marker 完全重叠时，把分数差异当作独立通路证据。
        """),
        ("输入", """
         Seurat 对象、命名基因集列表（list）、`assay`/`slot`；基因集内基因需与对象基因标识一致。输出每行一个细胞×基因集；细胞身份、基因集版本和打分方法必须保留。
        """),
        ("怎么做", """
         1. 明确基因集来源、版本和基因标识；检查基因在对象中的覆盖率。
         2. 选择一种打分方法，固定 assay/slot 和参数；本页 Seurat 分支调用时显式 `name="X"`，避免上游空 name 在 Seurat 5 下产生列名不匹配。
         3. 运行后检查分数分布、与 marker 表达的一致性、批次/测序深度影响。
         4. 组间比较优先在样本级汇总或使用适当模型；细胞级检验只作描述。
         5. 不把五种分数相加的课题脚本冒充通用实现；需要组合时单独说明权重与验证。
        """),
        ("代码", """
         入口 `methods/gene-set-scoring/code/analysis.R:run_gene_set_scoring(srt, bundle, parameters)`，封装 SCP `CellScoring` 的 Seurat 分支。2026-10-23 在 `pancreas_sub` 80 细胞、两个命名基因集上实际调用，封装分数与上游一致；调用参数含 `name="X"`，这是对上游空 name 列名缺陷的显式适配，不改变打分算法。

         AUCell、UCell 分支未运行（本机缺包）；原始课题的五种分数求和脚本保留在来源页，不作为本页通用实现。
        """),
        ("输出", """
         返回 Seurat 对象；`result@meta.data` 增加 `X_<基因集>` 分数列，一行一个细胞。可整理为长表 `cell_id, set, score` 供小提琴/热图模板；本页不强制 CSV。
        """),
        ("知识关联检查", """
         2026-10-23 检查了分组小提琴模板。签名分数可按 celltype/group 展示分布，关系为 adaptable；模板不重算分数或检验。没有 direct：模板不读 Seurat metadata，需先导出 `render-grouped-values`。细胞级 p 值不能当样本级推断，图注需说明。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用两个命名基因集实际运行 Seurat 打分并与上游比较；AUCell/UCell 未运行，未安装。
        """),
    ],
)

FAMILIES["trajectory-inference"] = dict(
    title="拟时序与轨迹推断",
    summary="在低维嵌入上连接细胞群，推断 lineage 与 pseudotime；轨迹是模型假设，不是真实时间。",
    keywords=["Slingshot", "pseudotime", "lineage", "Monocle", "PAGA", "轨迹", "SCP"],
    contract={"input": "Seurat 对象 + 稳定低维嵌入 + cluster 标签 + 起点/终点；cluster 是轨迹状态，不是细胞类型断言。",
              "output": "每细胞 lineage pseudotime 与 BranchID（Seurat metadata）；曲线对象在 tools。"},
    implementations=[impl("scp-slingshot", "SCP RunSlingshot 封装", "R",
                          "code/analysis.R:run_trajectory_inference",
                          ["Seurat", "slingshot"], "verification/scp-slingshot.json")],
    relations=[
        relation("scp-trajectory-velocity", "fig01-cns-umap", "trajectory-inference",
                 "轨迹分组/lineage 标签可作为 UMAP 着色变量；现有模板不画 lineage 曲线。",
                 "导出 render-umap-groups.csv（group=cluster/lineage）；曲线需另建模板。"),
        relation("scp-trajectory-velocity", "fig02-marker-feature-umap", "trajectory-inference",
                 "pseudotime 可作为 feature 长表画在 UMAP 上；模板不拟合轨迹。",
                 "导出 render-umap-feature-long.csv（feature=pseudotime, value=Lineage1）。"),
        relation("scp-trajectory-velocity", "fig06-pathway-violin", "trajectory-inference",
                 "pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。",
                 "导出 render-grouped-values.csv（celltype/group, value=pseudotime）。"),
    ],
    body=[
        ("用途", """
         在细胞群之间建立有序轨迹，给每个细胞一个 lineage 上的 pseudotime 和分支标签，用于描述分化、激活或损伤修复等连续过程。输出是模型推断的顺序，不是采样时间。
        """),
        ("原理与选择", """
         Slingshot 在嵌入空间对 cluster 建最小生成树，再拟合 lineage 曲线；Monocle2/3、PAGA、Palantir、WOT 等是其他实现，假设和输入不同。SCP `RunSlingshot` 封装 slingshot，需指定 `group.by`、`reduction`、`dims` 和可选起点/终点。轨迹方向依赖起点和 cluster 结构，换嵌入/分辨率可能改变结论。
        """),
        ("适用", """
         - 有连续过程假设、相对稳定的嵌入和 cluster，且 cluster 能覆盖轨迹上的状态。
         - 起点/终点有生物学依据或明确说明是探索性选择。
         - 用于生成 pseudotime 供动态特征分析，而不是单独证明分化方向。
        """),
        ("不适用", """
         - 离散细胞类型、没有连续过程假设，或 cluster 主要由批次/技术因素驱动。
         - 把 pseudotime 当真实时间、把 lineage 当因果谱系；没有谱系追踪时不能证明祖先关系。
         - 只选一个起点/嵌入报告结果，不做敏感性分析。
        """),
        ("输入", """
         Seurat 对象、`group.by` cluster 列、`reduction`（如 UMAP/PCA）、`dims`、可选 `start`/`end`。每个细胞一行 pseudotime；cluster 标签和嵌入必须同源。
        """),
        ("怎么做", """
         1. 先确定轨迹假设和 cluster 分辨率；检查嵌入是否被批次主导。
         2. 指定起点/终点（或有依据地探索），运行 Slingshot；保留 lineage 曲线和 BranchID。
         3. 检查 pseudotime 与关键 marker 的单调性、lineage 是否覆盖预期状态；换嵌入/分辨率做敏感性分析。
         4. 轨迹结果再交给动态特征分析；不要用 pseudotime 反向证明 cluster 注释正确。
         5. Monocle2/3、PAGA 等分支未在本页实现，不能因 Slingshot 通过就声称支持。
        """),
        ("代码", """
         入口 `methods/trajectory-inference/code/analysis.R:run_trajectory_inference(srt, bundle, parameters)`，封装 SCP `RunSlingshot`。2026-10-23 在 `pancreas_sub` 80 细胞、CellType 分组、UMAP 1:2 上实际调用；封装与上游 `Lineage1`、`BranchID` 一致。scope 仅软件调用，起点和 cluster 结构是示例，不代表真实轨迹。

         Monocle2/Monocle3/PAGA 等分支未运行。
        """),
        ("输出", """
         Seurat metadata 增加 `Lineage1`（pseudotime）和 `BranchID`；`result@tools` 保存 Slingshot 对象/曲线。可导出 `cell_id, pseudotime, branch, umap_1, umap_2` 供模板；本页不强制 CSV。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组、特征 UMAP 和分组小提琴模板。cluster/lineage 可着色 UMAP，pseudotime 可作 feature 或分组分布；均为 adaptable。现有模板不画 lineage 曲线/箭头，不能把普通 UMAP 分组图当作轨迹图。动态特征分析见 [[methods/dynamic-feature-analysis]]。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用 `pancreas_sub` 80 细胞实际运行 Slingshot 并与上游比较；未做真实轨迹方向论证。
        """),
    ],
)

FAMILIES["rna-velocity"] = dict(
    title="RNA 速度分析",
    summary="利用 spliced/unspliced 计数推断转录动态方向；当前 Python 后端缺失，函数保留但未运行。",
    keywords=["RNA velocity", "scVelo", "spliced", "unspliced", "latent time", "SCP"],
    contract={"input": "含 spliced/unspliced layers 的 Seurat 对象或 AnnData；同一细胞集合的剪接/未剪接计数。",
              "output": "velocity 图、latent time、velocity confidence（运行成功时）；当前未产生结果。"},
    implementations=[impl("scp-scvelo", "SCP RunSCVELO 分支", "R",
                          "code/analysis.R:run_rna_velocity",
                          ["Seurat", "reticulate", "scvelo"], "verification/scp-scvelo.json")],
    relations=[],
    body=[
        ("用途", """
         从剪接（spliced）和未剪接（unspliced）计数估计每个细胞的转录速率方向，在嵌入上显示速度箭头、latent time 或驱动基因。用于提出方向性假设，不是直接观测细胞命运。
        """),
        ("原理与选择", """
         scVelo 等模型假设剪接动力学可解释未剪接/剪接比例；steady-state、stochastic、dynamical 等模式对数据和先验要求不同。SCP `RunSCVELO` 通过 reticulate 调 Python scVelo，需要 spliced/unspliced layers、速度基因和合适的降维。本页只封装该分支；本机没有 reticulate 可用的 Python 后端和 scvelo/scanpy，函数未运行。
        """),
        ("适用", """
         - 有真实的 spliced/unspliced 计数（例如 velocyto、STARsolo 等产出），且与表达矩阵同一细胞。
         - 数据深度足够、速度基因可识别；有明确的嵌入和细胞群。
         - 用于方向性探索，并用独立时间点/谱系信息验证。
        """),
        ("不适用", """
         - 只有成熟 mRNA counts、没有 intron/unspliced 信息；或不同样本/平台的层定义不一致。
         - 把速度箭头当作因果方向、真实时间或细胞命运决定。
         - 数据稀疏、速度基因很少时，强行解释箭头。
        """),
        ("输入", """
         Seurat 对象的 `spliced`/`unspliced` assay/layers，或 AnnData；需显式 `assay_X`、`assay_layers`、`group_by` 和降维。每个细胞一行速度/潜时间结果（运行成功时）。
        """),
        ("怎么做", """
         1. 核对 spliced/unspliced 的来源、参考基因组和细胞条码一致性；确认不是把 total counts 复制成两层。
         2. 在课题 Python 环境准备 scVelo/scanpy，设置 `RETICULATE_PYTHON`；知识库不安装。
         3. 按 scVelo 流程做过滤、moments、速度基因和速度图；记录模式、kNN、PC 数。
         4. 检查速度与已知 marker/时间点的一致性，做参数敏感性分析；没有验证时只报告探索性方向。
         5. 若只有 R 环境，不要用其他算法的输出冒充 RNA velocity。
        """),
        ("代码", """
         入口 `methods/rna-velocity/code/analysis.R:run_rna_velocity(srt, bundle, parameters)`，封装 SCP `RunSCVELO`。本机执行时在 `check_Python("scvelo")` 处停止，精确错误为 `Set RETICULATE_PYTHON to an existing project interpreter; installation disabled`；未设置后端、未安装 scvelo/scanpy，函数保留为 `not_run`。

         该分支不能由其他家族的通过结果批准；即使以后设置 Python 后端，也需重新运行并写独立收据。
        """),
        ("输出", """
         运行成功时由 scVelo 生成速度图、latent time、velocity confidence 和驱动基因表；当前没有输出。不得用普通 UMAP 分组图冒充速度图。
        """),
        ("知识关联检查", """
         2026-10-23 检查了现有 UMAP/特征图模板。它们不能画 velocity 箭头、流线或 latent time 场，普通分组 UMAP 也不表达速度方向；本库暂无速度专用模板，因此不建立 figure_relations。无图原因：缺少语义匹配的速度图模板，不用“结构像”强行直连。
        """),
        ("使用记录", """
         2026-10-23：核对 SCP RunSCVELO 与本机 reticulate/Python 依赖；后端缺失，保留 not_run，未安装。
        """),
    ],
)

FAMILIES["cell-type-annotation"] = dict(
    title="细胞类型注释",
    summary="用参考数据集或标记基因给查询细胞分配类型标签，并检查注释置信度与 marker 一致性。",
    keywords=["SingleR", "cell type", "annotation", "参考注释", "marker", "SCP"],
    contract={"input": "query/reference Seurat 对象 + reference 标签列；query 与 ref 同物种、同基因标识且共享特征。",
              "output": "每细胞 predicted label 与 score（运行成功时）；当前 SingleR 分支未运行。"},
    implementations=[impl("scp-singler", "SCP RunSingleR 分支", "R",
                          "code/analysis.R:run_cell_type_annotation",
                          ["Seurat", "SingleR"], "verification/scp-singler.json")],
    relations=[
        relation("scp-annotation-projection", "fig01-cns-umap", "cell-type-annotation",
                 "预测细胞类型可作为 UMAP 着色变量；模板不执行注释。",
                 "导出 render-umap-groups.csv（group=predicted celltype）。"),
        relation("scp-annotation-projection", "fig02-marker-feature", "cell-type-annotation",
                 "用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。",
                 "导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。"),
        relation("scp-annotation-projection", "fig03-topjournal-bubble", "cell-type-annotation",
                 "预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。",
                 "导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。"),
        relation("scp-annotation-projection", "fig04-cell-proportion", "cell-type-annotation",
                 "按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。",
                 "导出 render-cell-proportions.csv（group, celltype, proportion）。"),
    ],
    body=[
        ("用途", """
         把查询数据集的细胞分配到已知细胞类型，输出每细胞标签和置信度，再用 marker 表达和组成检查注释是否合理。用于跨样本比较、参考图谱映射和后续分群解释。
        """),
        ("原理与选择", """
         SingleR 用参考数据集的标签和差异基因给查询细胞打分；scmap、Seurat label transfer、Symphony 等是其他参考映射/注释策略。它们都依赖参考与查询的组织、物种、平台和基因标识可比。SCP `RunSingleR` 支持 cell-level 和 cluster-level 注释；本页只封装 SingleR 分支，本机缺包，未运行。
        """),
        ("适用", """
         - 有一个与查询组织/物种匹配、标签可靠的参考数据集，且共享足够基因。
         - 查询与参考的预处理和基因标识可对齐；需要每细胞或每 cluster 的标签与分数。
         - 注释后用 marker、组成和独立方法交叉检查。
        """),
        ("不适用", """
         - 参考与查询组织/物种/平台差异大，或参考标签本身不可靠；novel 细胞类型可能被强行分配到最近标签。
         - 没有参考、只靠聚类编号或 marker 名字猜类型；或把预测标签当已验证的生物学身份。
         - 把注释分数当分类概率的绝对校准。
        """),
        ("输入", """
         query/reference Seurat 对象、`ref_group` 标签列、`query_assay`/`ref_assay`；两者需同物种、同基因标识并共享特征。输出每细胞一行标签/分数（运行成功时）。
        """),
        ("怎么做", """
         1. 核对参考来源、标签定义、物种和平台；检查 query/ref 基因交集与数据尺度。
         2. 选择 cell-level 或 cluster-level 注释；显式设置 `ref_group`、assay 和 SingleR 参数。
         3. 运行后检查每类分数、pruned label、marker 表达和样本组成；对低置信度细胞保留“未定/待定”。
         4. 用另一种注释方法或独立 marker 复核；novel 类型不要强行套已知标签。
         5. 注释结果再进入 UMAP/比例图；不要让注释反过来证明聚类正确。
        """),
        ("代码", """
         入口 `methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle, parameters)`，封装 SCP `RunSingleR`。本机 R 库没有 SingleR，执行时在 `check_R` 处停止，精确错误为 `Missing R dependency: SingleR; automatic installation is disabled`；函数保留为 `not_run`，未安装。

         该分支不能由 reference-mapping 的 Seurat 标签转移通过结果批准；两者是不同算法和不同证据。
        """),
        ("输出", """
         运行成功时返回 SCP 上游对象/列表，含每细胞 `singler_annotation`、`singler_score` 等；当前没有输出。不得把参考标签直接复制给查询细胞冒充注释结果。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组、特征 UMAP、气泡点图和细胞比例模板。预测标签可着色 UMAP、检查 marker、展示组成；均为 adaptable，模板不执行注释。没有 direct：模板不读 Seurat 注释结果。注释与参考映射的区别见 [[methods/reference-mapping]]。
        """),
        ("使用记录", """
         2026-10-23：核对 SCP RunSingleR 与本机依赖；SingleR 缺失，保留 not_run，未安装。
        """),
    ],
)

FAMILIES["reference-mapping"] = dict(
    title="参考图谱映射",
    summary="把查询细胞映射到参考标签并返回预测分数；Seurat 标签转移已验证，UMAP 投影分支未通过。",
    keywords=["reference mapping", "label transfer", "FindTransferAnchors", "TransferData", "Seurat", "SCP"],
    contract={"input": "query/reference Seurat 对象 + reference 标签列；reference 有 PCA，query/ref 共享特征。",
              "output": "每 query 细胞 predicted_id、max_score、margin；不包含 UMAP 投影（该分支未通过）。"},
    implementations=[
        impl("seurat-label-transfer", "Seurat 锚点标签转移分支", "R",
             "code/transfer.R:run_reference_label_transfer", ["Seurat", "SeuratObject"],
             "verification/seurat-label-transfer.json"),
        impl("scp-runseuratmap", "SCP RunSeuratMap UMAP 投影分支", "R",
             "code/analysis.R:run_reference_mapping", ["Seurat"],
             "verification/scp-runseuratmap.json"),
    ],
    relations=[
        relation("scp-annotation-projection", "fig01-cns-umap", "reference-mapping",
                 "查询细胞可按预测标签着色自身 UMAP；这不是参考 UMAP 投影，模板也不执行映射。",
                 "导出 render-umap-groups.csv（group=predicted label）；不得把查询 UMAP 说成参考投影。"),
        relation("scp-annotation-projection", "fig04-cell-proportion", "reference-mapping",
                 "按样本统计预测标签比例，检查映射组成；模板不做映射或检验。",
                 "导出 render-cell-proportions.csv（group=样本, celltype=predicted label, proportion）。"),
    ],
    body=[
        ("用途", """
         把查询数据集的细胞映射到参考图谱的标签空间，返回每细胞预测类型、置信分数和 margin。用于跨数据集注释、参考图谱复用和数据整合前的标签检查。
        """),
        ("原理与选择", """
         Seurat 锚点法在 query/ref 之间找相互最近邻，再用 `TransferData` 把参考标签和分数传给查询细胞；SCP `RunSeuratMap` 还包含把查询投影到参考 UMAP 的分支。KNNMap、Symphony、scmap、CSS 等是其他映射策略。本页把“标签转移”和“UMAP 投影”分开：前者已验证，后者在 Seurat 5.6 下失败，不能混为一个通过。
        """),
        ("适用", """
         - query/ref 同物种、共享特征，参考有可靠标签和 PCA；查询与参考的预处理可比。
         - 需要每细胞预测标签和分数，用于注释或跨数据集比较。
         - 有独立 marker/组成检查验证映射结果。
        """),
        ("不适用", """
         - 参考与查询组织/平台差异大、共享特征很少，或参考标签不可靠；novel 类型可能被强行映射。
         - 把标签转移分数当校准概率或因果身份；或把查询 UMAP 着色说成参考投影。
         - 用映射结果替代聚类、marker 检查和实验验证。
        """),
        ("输入", """
         query/reference Seurat 对象、`ref_group_col` 标签列、`dims`；reference 需有 PCA（没有时函数会计算）。每个 query 细胞一行预测；query 顺序必须保留。
        """),
        ("怎么做", """
         1. 核对 query/ref 物种、基因标识、预处理和标签定义；检查共享特征与参考 PCA。
         2. 运行 `FindTransferAnchors` + `TransferData`，保留 `predicted.id`、每类分数和 margin；不要只看标签。
         3. 用 marker、组成和独立注释方法复核；低 margin 的细胞标为待定。
         4. 若要投影到参考 UMAP，单独验证 `RunKNNMap`/UMAP 分支；本页的投影分支当前失败，不能声称可用。
         5. 与 cell-type-annotation 区分：本页是参考映射，不是通用 marker 注释。
        """),
        ("代码", """
         - 标签转移分支：`methods/reference-mapping/code/transfer.R:run_reference_label_transfer(query, reference, ref_group_col, ...)`，从 SCP `RunSeuratMap` 提取 `FindTransferAnchors` + `TransferData`。2026-10-23 在 `pancreas_sub` 300 参考/700 查询细胞上实际运行，返回每 query 细胞预测、顺序和 anchor 数；scope 仅软件调用。该分支不包含 UMAP 投影。
         - UMAP 投影分支：`methods/reference-mapping/code/analysis.R:run_reference_mapping(...)`，封装 SCP `RunSeuratMap`；在 Seurat 5.6 下报 `Argument 'dim.' must be an integer vector of length two`，保留 `not_run`。

         两个分支独立验证；标签转移通过不批准 UMAP 投影分支。
        """),
        ("输出", """
         标签转移返回 `list(table=..., scores=..., anchors=...)`：`table` 每行一个 query 细胞，含 `cell_id`、`predicted_id`、`max_score`、`margin`；`scores` 为每类预测分数。没有 UMAP 投影输出。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组和细胞比例模板。预测标签可着色 query 自身 UMAP、展示样本组成；均为 adaptable，模板不执行映射。没有 direct：模板不读 Seurat，也不产生参考投影。不能把 query UMAP 的标签着色图称为“参考图谱投影图”。
        """),
        ("使用记录", """
         2026-10-23：标签转移分支在隔离 R 环境实际运行；SCP RunSeuratMap 投影分支在 Seurat 5.6 下失败，保留 not_run。
        """),
    ],
)

FAMILIES["dimensionality-reduction"] = dict(
    title="单细胞降维分析",
    summary="在标准化/缩放后的表达上计算 PCA 与 UMAP，为聚类、可视化和轨迹提供低维表示。",
    keywords=["PCA", "UMAP", "RunDimReduction", "HVF", "降维", "SCP"],
    contract={"input": "已标准化、选 HVF 并缩放的 Seurat 对象；features 或 reduction_use 显式。",
              "output": "PCA/UMAP 嵌入，每细胞一行坐标。"},
    implementations=[impl("scp-dimreduction", "SCP RunDimReduction 封装", "R",
                          "code/analysis.R:run_dimensionality_reduction",
                          ["Seurat", "SeuratObject"], "verification/scp-dimreduction.json")],
    relations=[
        relation("scp-standard-workflow", "fig01-cns-umap", "dimensionality-reduction",
                 "Standard_SCP 产出 StandardUMAP2D，可作为 UMAP 分组着色；模板只画表，不降维。",
                 "导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group）。"),
        relation("scp-standard-workflow", "fig02-marker-feature", "dimensionality-reduction",
                 "降维嵌入可与 marker 表达长表拼成特征 UMAP 网格；模板不重做降维或表达。",
                 "导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。"),
    ],
    body=[
        ("用途", """
         把高维表达压缩到 PCA/UMAP，用于可视化、聚类和轨迹。PCA 保留线性方差结构，UMAP 强调局部邻域；两者都是表示，不是生物学距离的绝对度量。
        """),
        ("原理与选择", """
         SCP `RunDimReduction` 支持 PCA/SVD/ICA/NMF/MDS/glmpca 等线性降维和 UMAP/tSNE/DM/PHATE 等非线性降维；本页只验证 PCA + UMAP。非线性降维需要先有 features 或已有 reduction；数据未缩放时 Seurat 会拒绝。HVF 数、PC 数、邻居数和 UMAP 参数都会改变图形，必须记录。
        """),
        ("适用", """
         - 已归一化、选 HVF 并缩放的 Seurat 对象；需要低维表示做聚类/可视化。
         - 有明确的 features 或已存在的 reduction；参数可追溯。
         - 用于探索结构和生成假设，后续用 marker/独立数据验证。
        """),
        ("不适用", """
         - raw counts 未标准化/缩放，或基因数远少于目标 PC 数。
         - 把 UMAP 欧氏距离当真实转录距离、把 UMAP 分离当细胞类型差异。
         - 只展示一个随机种子/参数的结果，不检查稳定性。
        """),
        ("输入", """
         Seurat 对象、`features` 或 `reduction_use`/`reduction_dims`、`linear_reduction`、`nonlinear_reduction`、dims 和 seed。每个细胞一行嵌入；细胞身份必须保留。
        """),
        ("怎么做", """
         1. 完成归一化、HVF 和缩放；检查 HVF 是否被批次/技术基因主导。
         2. 选择线性/非线性方法和维度；显式设置 `features` 或已有 reduction。
         3. 运行后检查 PCA 方差、UMAP 邻域结构、参数/种子敏感性；与已知 marker 对照。
         4. 把嵌入交给聚类/轨迹，但不要用 UMAP 图形反推统计显著性。
         5. 其他降维方法未在本页验证，不能因 PCA/UMAP 通过就声称全部支持。
        """),
        ("代码", """
         入口 `methods/dimensionality-reduction/code/analysis.R:run_dimensionality_reduction(srt, bundle, parameters)`，封装 SCP `RunDimReduction`。2026-10-23 在 `pancreas_sub` 200 细胞、100 HVF、20 PC 上实际调用；封装与上游 UMAP 一致。scope 仅软件调用；测试数据已显式缩放，函数本身不替调用方做预处理。

         其他线性/非线性分支未运行。
        """),
        ("输出", """
         Seurat 对象增加 `PCA`/`UMAP` 等 reduction；每细胞一行坐标。可导出 `cell_id, umap_1, umap_2` 供模板；本页不强制 CSV。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组和特征 UMAP 模板。降维坐标可按 cluster/样本着色，或与 marker 长表拼成特征网格；均为 adaptable。没有 direct：模板不读 Seurat reduction，需先导出接口表。UMAP 图不证明聚类或生物学差异显著。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用 `pancreas_sub` 200 细胞实际运行 PCA/UMAP 并与上游比较；未做真实课题参数选择。
        """),
    ],
)

FAMILIES["cell-clustering"] = dict(
    title="单细胞聚类分析",
    summary="在低维嵌入上构建邻居图并划分 cluster；cluster 是分析单位，不是细胞类型。",
    keywords=["FindClusters", "Louvain", "Leiden", "resolution", "cluster", "SCP"],
    contract={"input": "已有 PCA/UMAP 嵌入的 Seurat 对象；dims、resolution、algorithm 显式。",
              "output": "每细胞 cluster 标签；cluster 不是细胞类型。"},
    implementations=[impl("seurat-findclusters", "SCP Standard_SCP 聚类分支", "R",
                          "code/clustering.R:run_seurat_clustering",
                          ["Seurat", "SeuratObject"], "verification/seurat-findclusters.json")],
    relations=[
        relation("scrna-marker-annotation", "fig01-cns-umap", "cell-clustering",
                 "cluster 标签可作为 UMAP 着色变量；模板不聚类。",
                 "导出 render-umap-groups.csv（group=cluster）；cluster 编号不是细胞类型。"),
        relation("scrna-marker-annotation", "fig04-cell-proportion", "cell-clustering",
                 "按样本/条件统计 cluster 比例，检查组成；模板不做聚类或检验。",
                 "导出 render-cell-proportions.csv（group=样本, celltype=cluster, proportion）。"),
    ],
    body=[
        ("用途", """
         在降维嵌入上把细胞分成离散 cluster，作为 marker 检查、注释和组成比较的分析单位。输出是每细胞 cluster 标签；cluster 本身不是细胞类型。
        """),
        ("原理与选择", """
         Seurat 先 `FindNeighbors` 构建 SNN 图，再用 Louvain/Leiden 等算法划分；`resolution` 控制 cluster 数，算法和随机种子会影响结果。SCP `Standard_SCP`/`Seurat_integrate` 内部使用同一套 FindNeighbors/FindClusters 分支；本页把它显式抽出，不包含预处理、降维或整合。
        """),
        ("适用", """
         - 已有稳定 PCA/UMAP 嵌入的 Seurat 对象；需要 cluster 做注释/组成分析。
         - 明确 resolution、dims、algorithm 和 seed，并做敏感性分析。
         - cluster 结果用 marker 和独立注释验证。
        """),
        ("不适用", """
         - raw counts 或未降维数据；或把 cluster 编号直接当细胞类型。
         - 只报一个 resolution/seed，把 cluster 数当生物学真相。
         - 用 cluster 比例差异直接做样本级统计推断而不考虑样本重复。
        """),
        ("输入", """
         Seurat 对象、`reduction`、`dims`、`resolution`、`algorithm`、`seed`。每个细胞一行 cluster；嵌入必须来自同一对象。
        """),
        ("怎么做", """
         1. 先检查嵌入质量和 dims；确定 resolution 扫描范围。
         2. 运行 FindNeighbors/FindClusters，保留 cluster 标签和参数。
         3. 做 resolution/seed 敏感性分析；用 marker 检查每个 cluster 是否可解释。
         4. 注释后比较样本/条件组成；细胞级比例只作描述，样本级推断需按样本汇总。
         5. 不把 cluster 通过当成注释或治疗分组通过。
        """),
        ("代码", """
         入口 `methods/cell-clustering/code/clustering.R:run_seurat_clustering(object, reduction, dims, resolution, algorithm, seed)`，显式复用 SCP `Standard_SCP` 中的 FindNeighbors/FindClusters 分支；不包含预处理、降维或整合。2026-10-23 在 `pancreas_sub` 200 细胞、PCA 1:20、resolution 0.5 上实际运行，并与相同 Seurat 调用逐标签比较；scope 仅软件调用。

         该分支不是独立 SCP 函数封装；说明见 `code/clustering.R` 的 source mapping。
        """),
        ("输出", """
         data.frame，一行一个细胞：`cell_id`、`cluster`、`reduction`、`resolution`。cluster 为字符型，避免被误当连续变量；可另导出 UMAP 分组表或比例表。
        """),
        ("知识关联检查", """
         2026-10-23 检查了 UMAP 分组和细胞比例模板。cluster 可着色 UMAP、展示样本组成；均为 adaptable。没有 direct；cluster 编号不等于细胞类型，图注必须说明 resolution 和注释来源。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用 `pancreas_sub` 200 细胞实际运行并与相同 Seurat 调用比较；未做真实课题 resolution 选择。
        """),
    ],
)

FAMILIES["dynamic-feature-analysis"] = dict(
    title="拟时序动态特征分析",
    summary="沿 pseudotime 拟合每个特征的平滑趋势，输出变化显著性、解释度和峰/谷时间。",
    keywords=["GAM", "mgcv", "pseudotime", "dynamic features", "RunDynamicFeatures", "SCP"],
    contract={"input": "Seurat 对象 + pseudotime/lineage 列 + 候选 features；pseudotime 必须来自轨迹推断。",
              "output": "每 feature 的 GAM 表：features、exp_ncells、r.sq、dev.expl、peaktime、valleytime、pvalue、padjust。"},
    implementations=[impl("scp-dynamicfeatures", "SCP RunDynamicFeatures 封装", "R",
                          "code/analysis.R:run_dynamic_feature_analysis",
                          ["Seurat", "mgcv", "BiocParallel"], "verification/scp-dynamicfeatures.json")],
    relations=[
        relation("scp-de-enrichment-dynamic", "fig02-marker-feature", "dynamic-feature-analysis",
                 "动态特征值可作为 feature 长表画在 UMAP 上；模板只画值，不拟合 GAM。",
                 "导出 render-umap-feature-long.csv（feature=基因/特征, value=表达或拟合值）。"),
        relation("scp-trajectory-velocity", "fig06-pathway-violin", "dynamic-feature-analysis",
                 "动态特征或 pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。",
                 "导出 render-grouped-values.csv（group=cluster/lineage, value=特征值/pseudotime）。"),
    ],
    body=[
        ("用途", """
         在轨迹 pseudotime 上拟合每个基因/特征的平滑趋势，找出随轨迹显著变化的特征，输出解释度、p 值、峰/谷时间和拟合曲线。用于描述分化/激活过程中的动态基因，不是因果或时间序列证据。
        """),
        ("原理与选择", """
         SCP `RunDynamicFeatures` 用 mgcv GAM（默认 `s(x, bs="cs")`）拟合特征随 pseudotime 的变化；计数数据可用负二项等 family，连续/归一化数据用 Gaussian。pseudotime 来自轨迹模型，其不确定性不会自动传入 GAM；特征选择、family、细胞数和光滑度都会影响结果。本页只验证了归一化数据/Gaussian 分支和软件夹具 pseudotime。
        """),
        ("适用", """
         - 已有轨迹 pseudotime/lineage，且细胞覆盖轨迹主要区间。
         - 特征在足够细胞中表达/可测；需要描述趋势和峰/谷时间。
         - 结果用独立时间点、marker 或扰动实验验证。
        """),
        ("不适用", """
         - 没有可靠 pseudotime，或把离散分组当连续轨迹。
         - 用 GAM p 值证明因果、真实时间或治疗效应；pseudotime 本身不确定。
         - 细胞数很少、特征稀疏时强行拟合复杂曲线；或只看 p 值不看解释度和曲线。
        """),
        ("输入", """
         Seurat 对象、`lineages`（pseudotime 列名，可多个）、`features`、`slot`、family 参数。每个 feature×lineage 一行结果；pseudotime 必须与细胞身份同源。
        """),
        ("怎么做", """
         1. 先完成轨迹推断并检查 pseudotime 覆盖和不确定性；不要把 cluster 序号当 pseudotime。
         2. 选择候选特征（HVF/先验基因）和 family；计数与归一化数据的 family 不同。
         3. 运行 `RunDynamicFeatures`，检查 `pvalue`、`padjust`、`r.sq`、`dev.expl`、峰/谷时间和拟合曲线。
         4. 做特征集、平滑度、pseudotime 版本敏感性分析；用独立数据验证关键趋势。
         5. 本页未验证计数/负二项分支；需要时另行运行并写收据。
        """),
        ("代码", """
         入口 `methods/dynamic-feature-analysis/code/analysis.R:run_dynamic_feature_analysis(srt, bundle, parameters)`，封装 SCP `RunDynamicFeatures`。2026-10-23 在 `pancreas_sub` 80 细胞、显式 fixture pseudotime、`Gcg`/`Krt19` 上实际调用；封装与上游 `DynamicFeatures` 表一致。fixture pseudotime 只用于软件验证，不代表真实轨迹；scope 仅此。

         计数/负二项、多个 lineage、特征自动选择分支未运行。
        """),
        ("输出", """
         `result@tools$DynamicFeatures_<lineage>$DynamicFeatures` 为 data.frame，一行一个 feature，含 `features`、`exp_ncells`、`r.sq`、`dev.expl`、`peaktime`、`valleytime`、`pvalue`、`padjust`；同一 tools 还保存 raw/fitted/upr/lwr 矩阵。没有强制 CSV；出图前显式导出长表。
        """),
        ("知识关联检查", """
         2026-10-23 检查了特征 UMAP 和分组小提琴模板。动态特征值可作 feature 长表或分组分布；均为 adaptable，模板不拟合 GAM 或轨迹。没有 direct；pseudotime/动态特征图不能替代轨迹曲线或因果验证。
        """),
        ("使用记录", """
         2026-10-23：在隔离 R 环境用软件夹具 pseudotime 实际运行并与上游比较；未做真实轨迹或计数模型验证。
        """),
    ],
)

# ----- SHAP and regression (existing analysis pages) -----
SHAP_BODY = sections([
    ("用途", """
     对既定模型输出作特征归因，分别保存逐样本带符号贡献和特征级平均绝对贡献。此页是有条件的方法家族说明；家族范围、代码分支、实际验证三个维度分开。解释训练模型的行为，不提供因果或临床效用结论。
    """),
    ("原始实现与家族范围", """
     来源是公众号的 XGBoost＋SHAP 示例；原生片段只保留在画廊条目 `2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f` 的 `original_code/`，manifest 记录字节哈希。Wiki 的 `code/shap_explain.py` 是历史复用脚本，保留原字节和旧行为；`code/explain_model.py` 是本次新增的纯函数封装，不训练、不划分、不调参。

     可推广的核心是“明确模型输出→选择适用解释器/背景→计算归因→整理结果”，而非承诺所有模型都支持同一入口：
     - 树分支：TreeExplainer 支持列出的模型家族，输出模式与特征依赖假设有条件。
     - 线性分支：LinearExplainer 可解释线性模型，背景与特征相关性处理影响归因。
     - 通用分支：Explainer 依据模型、masker 和算法选择估计器；成本与解释含义须核对。
    """),
    ("适用", """
     已明确研究任务、训练好的模型、特征处理、背景/解释样本及模型输出。`explain_model` 面向数值表格的回归/分类；真实课题先审查训练/验证边界、类别编码、缺失值与重复测量。标签名或模型名不能代替这些前提。
    """),
    ("不适用", """
     不能直接据此处理多分类、多输出、时序/分组划分或任意原生类别特征；需要另核接口和实现。特征归因不等于因果、预测校准、外部验证或模型临床有效性。相关特征与背景选择必须说明，不能仅看排名定机制。
    """),
    ("输入", """
     `explain_model(model, background, samples, ...)` 接收已拟合模型、背景 DataFrame 和解释样本 DataFrame；两者特征列必须同名同序、非空、有限数值。`explainer_kind` 取 `tree`/`linear`/`model_agnostic`；分类通用分支用 `predict_proba[:, output_index]`。训练、数据划分、样本选择和背景定义都由调用方负责，函数不隐式重做。
    """),
    ("怎么做", """
     1. 在课题中先固定模型、特征处理、背景和解释样本；不要用全数据回代或测试集调参后的模型冒充独立解释。
     2. 选择与实际模型匹配的解释器；树/线性/通用分支的前提不同。
     3. 显式传入 `task`、`output_index`、`top_n`、`min_mean_abs_shap` 和解释器/调用参数；随机方法要传 seed。
     4. 运行后检查 SHAP 矩阵形状、summary 百分比、样本表行数和特征顺序；用已知线性模型做数值 sanity check。
     5. 解释图只描述模型行为；需要因果/临床结论时另做设计和验证。
    """),
    ("代码", """
     入口 `methods/shap-explanation/code/explain_model.py:explain_model`，依赖 numpy、pandas、shap。2026-10-23 用解析线性模型验证：SHAP 值与闭式解一致、summary 百分比合计 100、samples 行数为样本×特征、输入和模型系数未变、特征顺序不一致会报错。scope 仅软件/数值夹具，不代表真实模型或临床有效性。

     `code/shap_explain.py` 是历史脚本，未改字节；本轮没有把它当作已验证实现。
    """),
    ("输出", """
     `values`：样本×特征 SHAP 矩阵；`summary`：feature、shap（平均绝对归因）、percent（筛选前总贡献占比）；`samples`：每行样本×特征的带符号 shap 和 feature_value（解释样本内各特征 min/max 缩放，常量=0）；`diagnostics`：解释器、任务、输出索引、样本/背景数、特征顺序、shap 版本等。TOP_N/MIN_MEAN_ABS_SHAP 筛选后不重新归一化 percent。
    """),
    ("使用记录", """
     2026-10-21：方法边界、代码来源和关系核查，未运行真实课题分析。
     2026-10-23：新增 `explain_model` 并用解析线性模型做数值验证；未运行真实模型或课题出图。
    """),
    ("知识关联检查", """
     2026-10-23 检查现存方法页、单 panel 来源、模板与接口，包括另一来源的回归评估。SHAP 汇总可配条形/环形，逐样本贡献可配蜂群，同一方法对应多图，关系唯一记在 frontmatter，反向由程序派生。三个历史模板为 direct（表结构无需改名/整形），但不证明上游分支或当前课题已联调；模板仍为历史固定尺寸。

     [[methods/regression-resampling-evaluation]] 与 SHAP 是互补参考：前者评估预测，后者归因。预测/指标表没有 SHAP 所需模型、特征及背景，不能直接串联；未发现第二个有依据的现存方法可直接读取 SHAP 图表契约。
    """),
])

REGRESSION_CODE = """
`code/summarize_predictions.py` 是本次新写的可复用指标汇总代码，依赖 `numpy`、`pandas`，不训练模型，也不联网。参数集中在文件开头：

| 参数 | 含义 |
|---|---|
| `INPUT` | 课题导出的 `regression-predictions.csv` |
| `OUTPUT` | 输出目录，通常为课题的 `analysis/` |
| `EXPECTED_IDS` | 可选样本清单 CSV，含 `sample_id`；K 折时用于检查每次重复全覆盖 |

训练及内层调参使用课题原有代码。Python 可用 scikit-learn 的 KFold/RepeatedKFold/GroupKFold/TimeSeriesSplit 与 Pipeline；R 可用相应重采样框架，最终导出相同接口。这里没有将原帖缺失的模型代码当成可运行实现。

验证：2026-10-23 用合成预测表检查手算 RMSE/MAE/R2/r、常数预测的 r 未定义、输入不变和完整 coverage 拒绝；收据为 `verification/summarize-predictions.json`。scope 仅指标与表格处理，不证明真实模型有效。
"""

# ----- old page metadata and pointers -----
ALL_FAMILIES = list(FAMILIES) + ["shap-explanation", "regression-resampling-evaluation"]
FAMILY_LINKS = "、".join(f"[[methods/{mid}|{FAMILIES[mid]['title']}]]" if mid in FAMILIES else
                         ("[[methods/shap-explanation|基于 SHAP 的模型解释]]" if mid == "shap-explanation"
                          else "[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]")
                         for mid in ALL_FAMILIES)

OLD = {
    "scp-annotation-projection": dict(
        kind="technical", summary="SCP 自动注释与参考投影的原始脚本和作者实现记录；分析问题见细胞类型注释与参考映射家族。",
        contract={"input": "SCP/Seurat 查询与参考对象、作者提供的参考标签列；原脚本参数在 source/ 中。",
                  "output": "原始 SCP 注释/投影对象与结果表；本页不重新运行，不产生新的分析结论。"},
        links=["cell-type-annotation", "reference-mapping"]),
    "scp-cellqc-doublet": dict(
        kind="technical", summary="SCP QC 与双细胞检测的原始脚本和作者实现记录；分析问题见质量控制与双细胞检测家族。",
        contract={"input": "Seurat 原始 counts 与样本元数据；原脚本参数在 source/ 中。",
                  "output": "SCP QC/双细胞对象和标签；本页不重新运行。"},
        links=["cell-quality-control", "doublet-detection"]),
    "scp-de-enrichment-dynamic": dict(
        kind="technical", summary="SCP 差异表达、富集和动态特征的原始脚本与作者实现记录；分析问题见四个对应家族。",
        contract={"input": "Seurat 对象、分组列、基因集和 pseudotime；原脚本参数在 source/ 中。",
                  "output": "SCP DE/富集/动态特征对象与表；本页不重新运行。"},
        links=["differential-expression", "gene-set-enrichment", "gene-set-scoring", "dynamic-feature-analysis"]),
    "scp-integration": dict(
        kind="technical", summary="SCP 单细胞多样本整合的原始脚本与作者实现记录；分析问题见批次整合家族。",
        contract={"input": "含 batch 列的 Seurat 对象或批次对象列表；原脚本参数在 source/ 中。",
                  "output": "SCP 整合对象与嵌入；本页不重新运行。"},
        links=["batch-integration"]),
    "scp-local-source": dict(
        kind="technical", summary="SCP v0.5.6 源码本地化与加载器资料；不是可执行分析，也不是独立方法家族。",
        contract={"input": "SCP v0.5.6 原始源码、DESCRIPTION 和依赖包。",
                  "output": "可 source 的 SCP_local 环境、加载器和补丁说明；不产生分析结果。"},
        links=list(FAMILIES)),
    "scp-standard-workflow": dict(
        kind="workflow", summary="SCP 标准预处理、降维与聚类的组合流程记录；单步方法见质量控制、降维、聚类和整合家族。",
        contract={"input": "原始 counts 的 Seurat 对象；流程参数在 source/ 中。",
                  "output": "Standardpca/StandardUMAP2D/Standardclusters 等流程对象；本页不重新运行。"},
        links=["dimensionality-reduction", "cell-clustering", "cell-quality-control", "doublet-detection", "batch-integration"]),
    "scp-trajectory-velocity": dict(
        kind="technical", summary="SCP 轨迹与 RNA 速度的原始脚本和作者实现记录；分析问题见轨迹、速度和动态特征家族。",
        contract={"input": "Seurat 对象、UMAP、cluster/pseudotime 及 spliced/unspliced layers；原脚本参数在 source/ 中。",
                  "output": "SCP 轨迹/速度对象与结果；本页不重新运行。"},
        links=["trajectory-inference", "rna-velocity", "dynamic-feature-analysis"]),
    "scp-visualization-interface": dict(
        kind="technical", summary="SCP 绘图函数到 Wiki 图表接口的映射与适配资料；不是分析方法。",
        contract={"input": "SCP/Seurat 分析对象或已导出的表。",
                  "output": "render-* 接口 CSV；适配层不重算分析或绘图统计。"},
        links=list(FAMILIES)),
    "scrna-marker-annotation": dict(
        kind="technical", summary="青光眼 scRNA 课题的 marker 注释与聚类检查实现记录；分析问题见细胞类型注释与聚类家族。",
        contract={"input": "GSE251716 预处理后的 Seurat 对象、marker 列表和 cluster 标签。",
                  "output": "作者脚本的 celltype 标签、marker 图和注释检查；本页不重新运行。"},
        links=["cell-type-annotation", "cell-clustering"]),
    "scrna-pathway-signature-ensemble": dict(
        kind="technical", summary="青光眼课题的通路签名打分与组间比较实现记录；五种分数相加是课题特定组合，不是通用标准。",
        contract={"input": "GSE251716 表达矩阵、GO/KEGG/标记基因集和细胞元数据。",
                  "output": "作者脚本的 AddModuleScore/AUCell/ssGSEA/UCell/singscore 分数及求和；本页不重新运行。"},
        links=["gene-set-scoring"]),
    "scrna-preprocess-doublet-qc-harmony": dict(
        kind="workflow", summary="青光眼课题的预处理、QC、双细胞与 Harmony 组合流程记录；单步方法见对应家族。",
        contract={"input": "GSE251716 原始计数和样本元数据；流程参数在 source/ 中。",
                  "output": "预处理 Seurat 对象、UMAP/cluster 和作者流程结果；本页不重新运行。"},
        links=["cell-quality-control", "doublet-detection", "batch-integration", "dimensionality-reduction", "cell-clustering"]),
}


def family_link_text(ids):
    names = {"shap-explanation": "基于 SHAP 的模型解释",
             "regression-resampling-evaluation": "回归模型的重采样评估与折外预测"}
    return "、".join(f"[[methods/{i}|{FAMILIES[i]['title'] if i in FAMILIES else names[i]}]]" for i in ids)


def update_family(mid, spec):
    page = WIKI / f"methods/{mid}.md"
    meta, body = read_page(page)
    facts = get_block(body, "facts")
    user = get_user_block(body)
    meta.update({
        "title": spec["title"],
        "method_kind": "analysis",
        "summary": spec["summary"],
        "data_contract": spec["contract"],
        "implementations": spec["implementations"],
        "tags": ["单细胞分析"] if mid not in ("gene-set-enrichment", "gene-set-scoring", "dynamic-feature-analysis")
                else ["单细胞分析", "转录组"],
        "keywords": spec["keywords"],
        "source": dict(SCP),
        "license": "GPL-3",
        "cite": SCP_CITE,
        "inputs": [],
        "outputs": [],
        "figure_relations": spec["relations"],
    })
    # Keep existing status: scaffolds are draft; do not promote without author.
    body_sections = sections(spec["body"])
    write_page(page, meta, render_body(spec["title"], facts, body_sections, user))


def update_shap():
    page = WIKI / "methods/shap-explanation.md"
    meta, body = read_page(page)
    facts = get_block(body, "facts")
    user = get_user_block(body)
    meta.update({
        "method_kind": "analysis",
        "summary": "对既定模型输出作 SHAP 归因，输出汇总表和逐样本贡献表；不训练、不划分数据。",
        "data_contract": {
            "input": "已拟合模型、背景 DataFrame、解释样本 DataFrame；特征列同名同序、有限数值。",
            "output": "样本×特征 SHAP 矩阵、summary 表（feature/shap/percent）、samples 长表；不产生训练或预测指标。"},
        "implementations": [impl("shap-explain-model", "SHAP 纯函数封装", "Python",
                                 "code/explain_model.py:explain_model",
                                 ["shap", "numpy", "pandas"], "verification/shap-explain-model.json")],
    })
    write_page(page, meta, render_body(meta["title"], facts, SHAP_BODY, user))


def update_regression():
    page = WIKI / "methods/regression-resampling-evaluation.md"
    meta, body = read_page(page)
    meta.update({
        "method_kind": "analysis",
        "summary": "汇总已有折外回归预测，计算逐折 RMSE/MAE/R2/r；不训练模型、不生成重采样。",
        "data_contract": {
            "input": "折外预测表 regression-predictions：sample_id/model/repeat/fold/y_true/y_pred/split_design；一行一个验证样本。",
            "output": "逐折指标表：model/repeat/fold/n_test/RMSE/MAE/R2/r/split_design；另可输出描述性均值/SD。"},
        "implementations": [impl("summarize-predictions", "折外预测指标汇总", "Python",
                                 "code/summarize_predictions.py:summarize",
                                 ["numpy", "pandas"], "verification/summarize-predictions.json")],
    })
    body = replace_section(body, "代码", REGRESSION_CODE)
    write_page(page, meta, body)


def update_old(mid, spec):
    page = WIKI / f"methods/{mid}.md"
    meta, body = read_page(page)
    meta.update({
        "method_kind": spec["kind"],
        "summary": spec["summary"],
        "data_contract": spec["contract"],
    })
    meta.pop("figure_relations", None)
    links = family_link_text(spec["links"])
    banner = (f"> **资料类型：{'组合流程' if spec['kind'] == 'workflow' else '技术/来源资料'}，不是默认分析家族。**\n"
              f"> 当前分析问题见：{links}。原代码与作者备注保留；本页不再作为分析推荐卡片。")
    if "> **资料类型" not in body:
        body = body.replace("<!-- facts:end -->", f"<!-- facts:end -->\n\n{banner}", 1)
    knowledge = (
        f"2026-10-23 分类为{'组合流程' if spec['kind'] == 'workflow' else '技术/来源资料'}：旧 id、`source/` 原字节和作者备注保留，"
        f"但不再作为默认分析家族推荐。语义配图关系已迁往 {links}；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。"
        "原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。"
    )
    body = replace_section(body, "知识关联检查", knowledge)
    write_page(page, meta, body)


def main():
    for mid, spec in FAMILIES.items():
        update_family(mid, spec)
        print("family", mid)
    update_shap()
    print("family shap-explanation")
    update_regression()
    print("family regression-resampling-evaluation")
    for mid, spec in OLD.items():
        update_old(mid, spec)
        print("old", mid)


if __name__ == "__main__":
    main()
