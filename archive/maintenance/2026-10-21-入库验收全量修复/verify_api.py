"""Verify the restarted formal service exposes the repaired workflow and assets."""
from pathlib import Path
import json
import urllib.request

BASE = "http://127.0.0.1:8765"
STAGED = Path(r"E:\research-wiki\开发\staged\research-wiki")
OUT = Path(__file__).resolve().parent / "api-verification.json"
OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}))


def get(path: str) -> bytes:
    with OPENER.open(BASE + path, timeout=10) as response:
        assert response.status == 200, (path, response.status)
        return response.read()


def get_json(path: str):
    return json.loads(get(path))


pages = get_json("/api/pages")
by_path = {item["path"]: item for item in pages}
templates = [p for p in by_path.values() if p["meta"]["type"] == "template"]
methods = [p for p in by_path.values() if p["meta"]["type"] == "method"]
layouts = [p for p in by_path.values() if p["meta"]["type"] == "layout"]
assert len(templates) == 5, len(templates)
assert len(methods) >= 2, len(methods)
for item in templates:
    assert item["meta"]["status"] == "ready", item["path"]
    assert item["workflow"]["stage"] == "complete", (item["path"], item["workflow"])
for item in methods:
    if item["meta"]["status"] == "ready":
        assert item["workflow"]["stage"] == "complete", (item["path"], item["workflow"])
assert not [p for p in by_path.values() if (p.get("workflow") or {}).get("queue") == "agent"], \
    "agent queue is not empty"
relations = get_json("/api/relations")
assert len(relations) >= 3, len(relations)
assert all(item["method_status"] == "ready" for item in relations), relations

bar = "2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar"
code = get_json(f"/api/templates/{bar}/code-files")
assert code["files"], code
reusable = next(item for item in code["files"] if item["variant"] == "reusable")
body = get(f"/api/templates/{bar}/code?variant=reusable&path={reusable['path']}")
assert body, reusable

index = get("/").decode("utf-8")
expected = (STAGED / "app/index.html").read_text(encoding="utf-8")
assert index == expected, "served app shell differs from staged build"
assert any(name in index for name in ("index-",)), index[:200]

report = {
    "pages": len(pages), "templates": len(templates), "methods": len(methods),
    "layouts": len(layouts), "relations": len(relations),
    "template_statuses": {p["path"]: p["workflow"]["stage"] for p in templates},
    "method_statuses": {p["path"]: p["workflow"]["stage"] for p in methods if p["meta"]["status"] == "ready"},
    "agent_queue": [], "code_files": len(code["files"]),
    "app_matches_staged_build": True,
}
OUT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(report, ensure_ascii=False, indent=2))
