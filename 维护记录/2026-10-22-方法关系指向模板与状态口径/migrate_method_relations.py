"""Make the ready callable templates the primary method relations.

The two source-layout relations are removed; the two template relations already
carry the layout pages in their evidence.  No body text, author block, status or
gallery data is changed.
"""
from pathlib import Path
import sys

SKILL = Path(r"E:\research-wiki\开发\staged\research-wiki")
sys.path.insert(0, str(SKILL))

from rwiki.config import load_config
from rwiki.pages import read_page, write_page
from rwiki.relations import relation_errors
from rwiki.store import save

config = load_config(SKILL / "config.json")
page = config.wiki_root / "methods/regression-resampling-evaluation.md"
meta, body = read_page(page)
kept = [record for record in meta.get("figure_relations", [])
        if str(record.get("figure", "")).startswith("templates/")]
assert len(kept) == 2, len(kept)
for record in kept:
    assert any(str(item).startswith("layouts/") for item in record.get("evidence", [])), record
meta["figure_relations"] = kept
errors = relation_errors(config, meta)
assert not errors, errors
write_page(page, meta, body)
save(config, "make ready templates the primary method relations")
print("relations", len(kept), "errors", errors)
