"""Fill the missing knowledge-link review section on the three SHAP template pages.

Only the agent-editable body is changed; frontmatter, facts and user blocks are preserved.
"""
from pathlib import Path
import sys

SKILL = Path(r"E:\research-wiki\开发\staged\research-wiki")
sys.path.insert(0, str(SKILL))

from rwiki.config import load_config
from rwiki.pages import read_page, write_page
from rwiki.store import save

config = load_config(SKILL / "config.json")
root = config.wiki_root

common_tail = (
    "- 未关联原因与边界：示例为估读/合成数据，回放只证明当前代码与示例可运行；"
    "真实课题须重新计算 SHAP，并核对模型、解释对象、背景分布和单位。"
    "未验证其他模型或任意 n 的适配。\n"
)

bar = f"""## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源蜂群图与环形贡献图、`interfaces/shap-summary`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为特征级平均绝对 SHAP 及占比对应汇总图契约），并与蜂群图、环形贡献图并列。本模板不重复维护关系，反向展示由方法页派生。
- 一图多方法：当前仅 `shap-explanation` 的汇总图契约直接使用 `shap-summary`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：条形图与环形贡献图读取同一 `shap-summary` 接口，是同一数据的不同表达；可按版式需要选用，但不能把两图当作两份独立证据。
{common_tail}"""

beeswarm = f"""## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源条形图与环形贡献图、`interfaces/shap-samples`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为逐样本×特征的带符号 SHAP 与着色特征值对应蜂群图契约），并与条形图、环形贡献图并列。本模板不重复维护关系。
- 一图多方法：当前仅 `shap-explanation` 的逐样本解释契约使用 `shap-samples`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：蜂群图与条形图/环形图来自同一 SHAP 分析，分别表达逐样本分布和特征级汇总；不能把不同 panel 当作独立样本或独立证据。
{common_tail}"""

radial = f"""## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源条形图与蜂群图、`interfaces/shap-summary`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为特征级平均绝对 SHAP 及占比对应汇总图契约），并与条形图、蜂群图并列。本模板不重复维护关系。
- 一图多方法：当前仅 `shap-explanation` 的汇总图契约直接使用 `shap-summary`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：环形贡献图与条形图读取同一 `shap-summary` 接口，是同一数据的不同表达；可按版式需要选用，但不能把两图当作两份独立证据。
{common_tail}"""

pages = {
    "2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar": bar,
    "2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm": beeswarm,
    "2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar": radial,
}

for entry_id, section in pages.items():
    page = root / "templates" / f"{entry_id}.md"
    meta, body = read_page(page)
    if "## 知识关联检查" in body:
        raise SystemExit(f"already has a review section: {entry_id}")
    if "## 使用记录" not in body:
        raise SystemExit(f"missing 使用记录 heading: {entry_id}")
    body = body.replace("## 使用记录", section + "\n## 使用记录", 1)
    write_page(page, meta, body)

save(config, "add knowledge-link review to SHAP single-panel templates")
print("updated", len(pages))
