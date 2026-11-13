"""Record the author's existing confirmation for the two legacy single-panel sources.

The old ingest code advanced these pages to ``pending_template`` without writing
``signedoff_version``.  The current requirements index records that the author
confirmed both sources and their two function templates; this one-time migration
writes that existing fact, without changing status, body, gallery or templates.
"""
from pathlib import Path
import sys

SKILL = Path(r"E:\research-wiki\开发\staged\research-wiki")
sys.path.insert(0, str(SKILL))

from rwiki.config import load_config
from rwiki.pages import read_page, write_page
from rwiki.store import save

config = load_config(SKILL / "config.json")
ids = [
    "2026-10-19-regression-stability__fig03-density-panel",
    "2026-10-19-regression-stability__fig04-boxplot-panel",
]
for entry_id in ids:
    page = config.wiki_root / "layouts" / f"{entry_id}.md"
    meta, body = read_page(page)
    assert meta["status"] == "pending_template", (entry_id, meta["status"])
    assert meta["gallery_version"] == 1, (entry_id, meta["gallery_version"])
    assert "signedoff_version" not in meta, entry_id
    meta["signedoff_version"] = meta["gallery_version"]
    write_page(page, meta, body)
save(config, "record existing author signoff for two legacy single-panel sources")
print("migrated", len(ids))
