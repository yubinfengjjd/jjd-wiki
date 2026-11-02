"""Record the template-primary relation rule and the effective-status rule."""
from pathlib import Path
import shutil

ROOT = Path(r"E:\research-wiki")
STAGE = ROOT / "开发/staged/research-wiki"
SCI = Path(r"E:\桌面\ARIS\sci-figure-replica-dev-20261020/staged/sci-figure-replica")

agents_rule = """

### 方法关系的模板优先（2026-10-22）

- 模板 ready 后，方法的 `figure_relations` 主记录指向可调用模板；来源 layout 只放在 evidence/正文溯源，不再作为主关系。
- 若方法关系仍指向 layout，而该 layout 已有 ready 覆盖模板，`lint` 报 ERROR；确认/推荐前改为模板关系，并保留 layout 证据。
- 方法声明输出与模板输入接口不一致时，关系写 `adaptable`；方法页在“接口结构匹配”旁另列“语义关联的模板（需适配）”，给出模板链接与适配动作。结构匹配栏只列真正消费声明输出的模板。
- 关系卡的状态显示目标页的有效 workflow（如“模板已就绪”），不把来源的 `pending_template` 当成模板未完成；原始状态只作详情。
- 归档/删除模板后重新审计关系；不因归档把 layout 关系恢复为主关系。
"""

skill_rule = """

### 方法关系与有效状态（2026-10-22）

模板 ready 后，方法 `figure_relations` 的主记录指向模板；来源 layout 只作 evidence。方法仍指向 layout 而该 layout 有 ready 覆盖模板时 `lint` 报错。方法声明输出与模板输入不一致时标 `adaptable`，方法页另列“语义关联的模板（需适配）”并写适配动作；结构匹配栏只显示真正消费输出的模板。关系卡的可用状态取目标页的有效 workflow（如“模板已就绪”），不把来源 `pending_template` 显示成未完成。
"""

link_rule = """

模板 ready 后，方法主关系应指向模板；来源 layout 只作 evidence/溯源。仍指向 layout 且有 ready 覆盖模板时 `lint` 报错。声明输出与模板输入不一致时用 `adaptable`，并在方法页单列“语义关联的模板（需适配）”；结构匹配栏只显示真正消费输出的模板。关系卡显示目标页的有效 workflow，不把来源 `pending_template` 当成模板未完成。
"""

sci_rule = """

模板 ready 后，方法主关系指向模板，来源 layout 只作 evidence；方法页关系卡显示有效 workflow（如“模板已就绪”），不把来源 `pending_template` 当未完成。声明输出与模板输入不一致时标 `adaptable`，在方法页单列需适配模板。
"""

doc_rule = """

## 方法关系与状态口径（2026-10-22）

作者确认：模板 ready 后，方法 `figure_relations` 以模板为主，来源 layout 只作 evidence；方法页关系卡显示有效 workflow（如“模板已就绪”），不把来源 `pending_template` 当成未完成；方法声明输出与模板输入不一致时，在“接口结构匹配”旁另列“语义关联的模板（需适配）”，结构匹配栏只列真正消费输出的模板。`lint` 对“方法→layout 且存在 ready 覆盖模板”报错。回归方法的两条 layout 主关系已迁移到两个模板，layout 仍保留在 evidence；详见 `维护记录/2026-10-22-方法关系指向模板与状态口径/`。
"""

def append(path: Path, text: str, marker: str):
    current = path.read_text(encoding="utf-8")
    assert marker not in current, f"already updated: {path}"
    path.write_text(current.rstrip() + text + "\n", encoding="utf-8", newline="\n")

append(ROOT / "知识库/AGENTS.md", agents_rule, "### 方法关系的模板优先（2026-10-22）")
shutil.copyfile(ROOT / "知识库/AGENTS.md", STAGE / "assets/AGENTS.md")
append(STAGE / "SKILL.md", skill_rule, "### 方法关系与有效状态（2026-10-22）")
append(STAGE / "references/knowledge-linking.md", link_rule, "模板 ready 后，方法主关系应指向模板")
append(SCI / "SKILL.md", sci_rule, "模板 ready 后，方法主关系指向模板")
append(ROOT / "文档/当前要求与同步核查.md", doc_rule, "## 方法关系与状态口径（2026-10-22）")
print("updated AGENTS, assets/AGENTS, SKILL, knowledge-linking, sci-figure SKILL, current index")
