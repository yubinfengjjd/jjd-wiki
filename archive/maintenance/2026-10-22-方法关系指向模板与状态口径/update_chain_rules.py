"""Record the chain-completeness and read-interface rule."""
from pathlib import Path
import shutil

ROOT = Path(r"E:\research-wiki")
STAGE = ROOT / "开发/staged/research-wiki"
SCI = Path(r"E:\桌面\ARIS\sci-figure-replica-dev-20261020/staged/sci-figure-replica")

agents_rule = """

### 链条完整性与读取接口（2026-10-22）

- 方法页“接口结构匹配”必须显示结构匹配模板；若没有直接消费声明输出的模板，必须另列“语义关联的模板（需适配）”，不能只留“暂无”。
- 每个结构匹配/需适配模板都要标出实际读取的接口（如 `render-scatter-rgb`）；适配关系要在 `输出` 或 `知识关联检查` 正文列出这些接口与准备步骤。`lint` 对“adaptable 关系的模板读取接口未在正文说明”报 WARN。
- 结构匹配只按已声明接口计算；语义关联/需适配模板不是结构直连，不能把适配模板标成 direct，或据此宣称方法已能直接出图。
- 方法输出接口没有结构模板也没有语义模板关系时，在 `知识关联检查` 写明无图原因并处理 `lint` WARN；不为凑链条伪造接口。
"""

skill_rule = """

### 链条完整性与读取接口（2026-10-22）

方法页必须显示结构匹配模板和需适配模板；每个模板标出读取接口；适配关系在正文写实际 `render-*` 等接口与准备步骤。结构匹配为空时不能只留“暂无”。`lint` 对未说明读取接口的 adaptable 关系报 WARN；结构匹配不是语义直连。
"""

link_rule = """

方法页链条：结构匹配模板与“语义关联的模板（需适配）”都要显示；每个模板标出读取接口；适配关系在正文列出模板实际接口与准备步骤；`lint` 对缺失说明报 WARN。结构匹配只按已声明接口计算，需适配不是 direct。
"""

sci_rule = """

方法页链条同时展示结构匹配与需适配模板；每个模板标出读取接口，不能只留“暂无”。
"""

doc_rule = """

## 链条完整性与读取接口（2026-10-22）

作者确认：方法页链条必须展示结构匹配模板与“语义关联的模板（需适配）”；每个模板标出读取接口；适配关系在正文列出实际接口与准备步骤。结构匹配为空不能只显示“暂无”；`lint` 对未说明读取接口的 adaptable 关系报 WARN。回归方法的两个模板读取接口（`render-scatter-rgb`/`render-marginal-bars`、`render-category-points`/`render-box-summaries`）已写入输出与知识关联检查。详见 `维护记录/2026-10-22-方法关系指向模板与状态口径/`。
"""


def append(path: Path, text: str, marker: str):
    current = path.read_text(encoding="utf-8")
    assert marker not in current, f"already updated: {path}"
    path.write_text(current.rstrip() + text + "\n", encoding="utf-8", newline="\n")


append(ROOT / "知识库/AGENTS.md", agents_rule, "### 链条完整性与读取接口（2026-10-22）")
shutil.copyfile(ROOT / "知识库/AGENTS.md", STAGE / "assets/AGENTS.md")
append(STAGE / "SKILL.md", skill_rule, "### 链条完整性与读取接口（2026-10-22）")
append(STAGE / "references/knowledge-linking.md", link_rule, "方法页链条：结构匹配模板与")
append(SCI / "SKILL.md", sci_rule, "方法页链条同时展示结构匹配与需适配模板")
append(ROOT / "文档/当前要求与同步核查.md", doc_rule, "## 链条完整性与读取接口（2026-10-22）")
print("updated chain rules")
