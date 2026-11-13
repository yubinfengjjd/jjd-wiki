"""Round-2: separate 2026-10-22 environment history from current family evidence."""
from pathlib import Path
import sys

sys.path.insert(0, "E:/research-wiki/开发/staged/research-wiki")
from rwiki.pages import read_page, write_page  # noqa: E402

WIKI = Path("E:/research-wiki/知识库/methods")

REPLACEMENTS = {
    "scp-annotation-projection.md": [
        (
            "- 本轮未在安装 Seurat/SCP 依赖的环境中运行；注释准确率、投影质量和参考适用性未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；注释准确率、投影质量和参考适用性未验证。2026-10-23 当前规范家族验证：SingleR 分支 `not_run`（缺包）；Seurat 标签转移 `verified`；SCP `RunSeuratMap` UMAP 投影 `not_run`（`dim.` 错误）。见 [[methods/cell-type-annotation]]、[[methods/reference-mapping]]；旧记录不扩为所有注释/投影分支可用。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；注释/投影函数依赖未安装，未运行。不宣称标签准确率或投影质量已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时注释/投影依赖未安装、未运行。2026-10-23 当前范围见 [[methods/cell-type-annotation]] 与 [[methods/reference-mapping]] 的收据：SingleR not_run；标签转移 verified；UMAP 投影 not_run。",
        ),
    ],
    "scp-cellqc-doublet.md": [
        (
            "- 本轮没有在安装 Seurat/SCP 依赖的环境中运行；默认参数的真实表现未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；默认参数的真实表现未验证。2026-10-23 当前规范家族：QC 的 UMI/基因数/线粒体阈值分支 `verified`；scDblFinder `not_run`（缺包）；DoubletFinder 未函数化。见 [[methods/cell-quality-control]]、[[methods/doublet-detection]]。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；SCP 的 QC 函数依赖 Seurat/SCP 未安装，未运行。因此不宣称阈值、双细胞率或细胞数在真实数据上已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 QC 函数依赖未安装、未运行。2026-10-23 当前收据见 [[methods/cell-quality-control]]（`verified`）与 [[methods/doublet-detection]]（`not_run`）；不宣称阈值/双细胞率在真实数据已验证。",
        ),
    ],
    "scp-de-enrichment-dynamic.md": [
        (
            "- 本轮未在安装 Seurat/SCP 依赖的环境中运行；数据库、GAM、打分和 p 值均未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；数据库、GAM、打分和 p 值未验证。2026-10-23 当前规范家族：DE wilcox、ORA（自定义 TERM2GENE）、Seurat/AddModuleScore、Gaussian 动态特征有 `verified` 收据；GSEA/在线 GO/KEGG/AUCell/UCell/计数 family 仍 `not_run`。见四个家族页。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；DE/富集/GSEA/GAM/打分依赖未安装，未运行。不宣称 p 值、富集条目或动态特征已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时依赖未安装、未运行。2026-10-23 当前范围见 [[methods/differential-expression]]、[[methods/gene-set-enrichment]]、[[methods/gene-set-scoring]]、[[methods/dynamic-feature-analysis]] 的收据；GSEA/在线库/其他打分分支未运行。",
        ),
    ],
    "scp-integration.md": [
        (
            "- 本轮未在安装 Seurat/SCP 依赖的环境中运行；方法可用性和数值表现未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；方法可用性和数值表现未验证。2026-10-23 当前规范家族：Seurat 锚点分支 `verified`；Harmony `not_run`（缺包）；scVI/MNN/fastMNN/Scanorama/BBKNN/CSS/LIGER/Conos/ComBat 未运行。见 [[methods/batch-integration]]。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；`Integration_SCP()` 及 12 种方法依赖未安装，未运行。不宣称任何方法的批次混合/细胞类型保留已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 `Integration_SCP()` 及 12 种方法依赖未安装、未运行。2026-10-23 当前收据见 [[methods/batch-integration]]：Seurat verified、Harmony not_run；其他方法未运行。",
        ),
    ],
    "scp-local-source.md": [
        (
            "- 不能证明数值等价或科学有效：本轮未安装 Seurat/SCP 依赖，未运行 SCP 算法；`verify_local.R` 只检查加载、补丁完整性和少数无 Seurat 依赖的函数。",
            "- 不能证明数值等价或科学有效：2026-10-22 历史记录当时未安装 Seurat/SCP 依赖，未运行 SCP 算法；`verify_local.R` 只检查加载、补丁完整性和少数无 Seurat 依赖的函数。2026-10-23 当前隔离库已有 Seurat 5.6.0/SeuratObject 5.4.0、slingshot、clusterProfiler；部分规范家族分支已实际调用并有收据，缺依赖分支仍 `not_run`。见各家族页；不宣称所有算法已运行或数值等价。",
        ),
        (
            "- `code/SCP-local/verify_local.R`：可重复的静态/免 Seurat 运行检查；当前 61 PASS / 0 FAIL。",
            "- `code/SCP-local/verify_local.R`：可重复的静态/免 Seurat 运行检查；2026-10-22 记录 61 PASS / 0 FAIL，2026-10-23 未重跑该脚本。",
        ),
        (
            "- `code/SCP-local/verification.md`：命令、覆盖范围、未覆盖项与当前环境缺失依赖。",
            "- `code/SCP-local/verification.md`：2026-10-22 命令、覆盖范围、未覆盖项与环境清单；当前算法范围另见各家族收据。",
        ),
        (
            "代码状态：本地包已实际 `source()` 通过（`SCP_local` 236 个对象），并执行了 `isOutlier()`、`capitalize()`、`as_matrix()` 与 `asMatrix()` 的小数据检查。随后在隔离库安装 Seurat 5.6.0/SeuratObject 5.4.0，用 `pancreas_sub` 示例数据跑通了 `CellDimPlot`、`FeatureDimPlot`、`CellStatPlot`、`FeatureStatPlot`、`CellDensityPlot`、`GroupHeatmap`、`VolcanoPlot` 等图；SCP 的 `RunDEtest`/部分富集/轨迹函数仍受 Seurat 5 API 变化影响，未全部跑通。不宣称数值等价或所有算法可用。",
            "代码状态：2026-10-22/23 记录本地包已实际 `source()` 通过（`SCP_local` 236 个对象），并执行了 `isOutlier()`、`capitalize()`、`as_matrix()` 与 `asMatrix()` 的小数据检查；隔离库已有 Seurat 5.6.0/SeuratObject 5.4.0，`pancreas_sub` 示例上跑通了 `CellDimPlot`、`FeatureDimPlot`、`CellStatPlot`、`FeatureStatPlot`、`CellDensityPlot`、`GroupHeatmap`、`VolcanoPlot` 等图。2026-10-23 规范家族补验：DE、Slingshot、Seurat_integrate 等分支通过；RunSeuratMap 投影、部分富集/轨迹/速度分支仍 `not_run`，见各家族页与收据。不宣称数值等价或所有算法可用。",
        ),
    ],
    "scp-standard-workflow.md": [
        (
            "- `leiden` 需要 reticulate + `leidenalg`；当前环境未安装，未验证。",
            "- `leiden` 需要 reticulate + `leidenalg`；2026-10-22 记录当前环境未安装、未验证；2026-10-23 未重新验证 leiden。",
        ),
        (
            "- 本轮未在安装 Seurat/SCP 依赖的环境中运行；默认参数的真实表现未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；默认参数真实表现未验证。2026-10-23 当前规范家族：PCA/UMAP `verified`、FindClusters `verified`；Standard_SCP 全流程未运行。见 [[methods/dimensionality-reduction]]、[[methods/cell-clustering]]。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；`Standard_SCP()` 依赖 Seurat/uwot 等未安装，未运行。不宣称降维/聚类数值或稳定性已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 Standard_SCP 依赖未安装、未运行。2026-10-23 当前范围见 [[methods/dimensionality-reduction]]（RunDimReduction verified）与 [[methods/cell-clustering]]（FindNeighbors/FindClusters verified）；Standard_SCP 组合流程本身未重新运行。",
        ),
    ],
    "scp-trajectory-velocity.md": [
        (
            "- 本轮未在安装 Seurat/SCP/Python 依赖的环境中运行；拓扑、pseudotime 和速度未验证。",
            "- 2026-10-22 历史记录：当时未在安装 Seurat/SCP/Python 依赖的环境中运行；拓扑、pseudotime 和速度未验证。2026-10-23 当前规范家族：Slingshot `verified`；scVelo `not_run`（Python 后端缺失）；Monocle/PAGA/Palantir/WOT 未运行。见 [[methods/trajectory-inference]]、[[methods/rna-velocity]]。",
        ),
        (
            "- 验证状态：本地源码可 `source()`；`verify_local.R` 通过；所有轨迹/速度函数依赖未安装，未运行。不宣称拓扑、pseudotime 或速度已验证。",
            "- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时所有轨迹/速度函数依赖未安装、未运行。2026-10-23 当前范围见 [[methods/trajectory-inference]]（Slingshot verified）与 [[methods/rna-velocity]]（scVelo not_run）；其他轨迹/速度分支未运行。",
        ),
    ],
    "scp-visualization-interface.md": [
        (
            "- 不能保证全家族视觉等价：当前只对 ring（`CellStatPlot`）和 volcano（`VolcanoPlot`）的原生绘图分支做了实际运行与逐字节比对；其余函数虽可加载，颜色、布局、字体、panel 尺寸未逐一对照。",
            "- 不能保证全家族视觉等价：2026-10-22 记录当时只对 ring（`CellStatPlot`）和 volcano（`VolcanoPlot`）的原生绘图分支做了实际运行与逐字节比对；2026-10-23 表适配层 25 PASS，但其余 SCP 绘图函数的颜色、布局、字体、panel 尺寸和视觉等价仍未逐一对照。",
        ),
        (
            "- 验证状态：本地绘图函数已定义并可加载；表适配函数用合成数据通过。`CellStatPlot` 的 ring/bar/pie/rose/trend/area/dot/sankey/chord/venn/upset 分支、`VolcanoPlot`、`GroupHeatmap` ht1、`FeatureHeatmap`、`CellCorHeatmap` 与 `CellDensityPlot` 已在隔离库用 `pancreas_sub` 实际运行，并由原生 core + 表/绘图拆分模板复现（固定示例同哈希）；sankey/venn/cell-cor 的依赖兼容补丁已记录在对应画廊 `PATCHES.md`；其余绘图函数未在 Seurat/ComplexHeatmap 环境逐一运行，视觉/数值等价未验证。",
            "- 验证状态：2026-10-22 记录本地绘图函数已定义并可加载；`CellStatPlot` 的 ring/bar/pie/rose/trend/area/dot/sankey/chord/venn/upset 分支、`VolcanoPlot`、`GroupHeatmap` ht1、`FeatureHeatmap`、`CellCorHeatmap` 与 `CellDensityPlot` 已在隔离库用 `pancreas_sub` 实际运行，并由原生 core + 表/绘图拆分模板复现（固定示例同哈希）；sankey/venn/cell-cor 的依赖兼容补丁记录在对应画廊 `PATCHES.md`。2026-10-23 表适配层 25 PASS / 0 FAIL；其余绘图函数未逐一运行，视觉/数值等价仍未验证。",
        ),
    ],
    "scrna-marker-annotation.md": [
        (
            "- 当前 R 环境 Seurat 加载失败（Matrix 版本冲突），原脚本未在当前机器重跑；SCpubr 本身可加载，但不能替代 Seurat 对象。",
            "- 2026-10-22 历史记录：当时 R 4.3.1 的 Seurat 因 Matrix 版本冲突无法加载，原脚本未重跑；SCpubr 可加载但不能替代 Seurat 对象。2026-10-23 当前隔离库 Seurat 5.6.0 可加载，但 `annotation.R` 仍未函数化/重跑；规范家族状态见 [[methods/cell-type-annotation]]（SingleR not_run；marker 来源未验证）。",
        ),
        (
            "- 当前验证状态：SCpubr/ggunchull 在 R 4.3.1 可加载，但 Seurat 因 Matrix 版本冲突无法加载；原脚本未在当前机器重跑。点图/气泡图/特征图/比例图的 ggplot2 核心可改为消费表，供图模板使用。",
            "- 验证状态：2026-10-22 记录 SCpubr/ggunchull 在 R 4.3.1 可加载，Seurat 因 Matrix 冲突无法加载，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但 `annotation.R` 仍未函数化/验证；点图/气泡图/特征图/比例图的 ggplot2 核心仍只作图表适配，见 [[methods/cell-type-annotation]]。",
        ),
    ],
    "scrna-pathway-signature-ensemble.md": [
        (
            "- 当前验证状态：Seurat 因 Matrix 版本冲突无法加载；AUCell/GSVA/UCell/singscore 等包是否可加载需逐项检查，本页未在当前机器重跑。只归档原脚本，不声称数值已验证。",
            "- 验证状态：2026-10-22 历史记录：当时 Seurat 因 Matrix 版本冲突无法加载；AUCell/GSVA/UCell/singscore 等包未逐项检查，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但五分数脚本仍未函数化/重跑，其他打分包是否有当前证据需另查；规范家族 Seurat/AddModuleScore 分支见 [[methods/gene-set-scoring]]（verified），不扩为五种分数已验证。",
        ),
    ],
    "scrna-preprocess-doublet-qc-harmony.md": [
        (
            "- 当前 R 环境 Seurat 加载失败（Matrix 版本冲突），本页不声称脚本已在当前机器重跑通过。",
            "- 2026-10-22 历史记录：当时 R 4.3.1 的 Seurat 因 Matrix 版本冲突无法加载，本页不声称脚本已重跑通过。2026-10-23 当前 Seurat 5.6.0 可加载，但 `preprocess.R` 仍未函数化/重跑；DoubletFinder/harmony 仍缺。规范家族状态见 [[methods/cell-quality-control]]、[[methods/doublet-detection]]、[[methods/batch-integration]] 等。",
        ),
        (
            "- 当前验证状态：R 4.3.1 的 Matrix 1.5-4.1 低于 SeuratObject 要求的 1.6.4，Seurat/SCP 无法加载；因此本页只归档原脚本，未在当前机器重跑。若要验证，需要先与作者确认是否更新 Matrix/安装 Seurat（可能影响其他 R 项目）。",
            "- 验证状态：2026-10-22 记录 R 4.3.1 的 Matrix 1.5-4.1 低于 SeuratObject 要求，Seurat/SCP 无法加载，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但脚本未函数化/重跑，DoubletFinder/harmony 缺失；只归档原脚本，不声称已在当前机器验证。见规范家族收据。",
        ),
    ],
}


def main():
    for name, pairs in REPLACEMENTS.items():
        page = WIKI / name
        meta, body = read_page(page)
        for old, new in pairs:
            count = body.count(old)
            if count != 1:
                raise SystemExit(f"{name}: expected 1 match, got {count}: {old[:60]}")
            body = body.replace(old, new)
        write_page(page, meta, body)
        print("updated", name)


if __name__ == "__main__":
    main()
