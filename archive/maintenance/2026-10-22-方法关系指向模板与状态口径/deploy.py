"""Deploy the reviewed research-wiki and sci-figure-replica rules to the three hosts.

Copies the canonical staged research-wiki tree (including the built app), removes
stale app bundles, and updates each installation manifest.  Backups of every
overwritten/removed file are kept under this maintenance record.
"""
from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime, timezone

TASK = Path(__file__).resolve().parent
HOME = Path(r"C:\Users\86186")
SOURCE = Path(r"E:\research-wiki\开发\staged\research-wiki")
REPLICA = Path(r"E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica")
SKIP = {".git", "__pycache__", ".pytest_cache", "node_modules"}
HOSTS = (".agents", ".codex", ".claude")
UPDATE = "Template-primary method relations, effective workflow status, and an adaptable-template list"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def files_under(root: Path) -> list[Path]:
    return [p for p in root.rglob("*")
            if p.is_file() and not (set(p.relative_to(root).parts) & SKIP)
            and p.name != "installation-manifest.json" and p.suffix not in {".pyc", ".pyo"}]


def backup(host: str, skill: str, relative: Path) -> None:
    target = HOME / host / "skills" / skill / relative
    if not target.is_file():
        return
    out = TASK / "backup" / host / skill / relative
    out.parent.mkdir(parents=True, exist_ok=True)
    if not out.exists():
        shutil.copy2(target, out)


def deploy_research_wiki(host: str, source_files: list[Path]) -> dict:
    target = HOME / host / "skills" / "research-wiki"
    assert target.resolve() == target.absolute()
    records, changed, removed = [], [], []
    for source in source_files:
        relative = source.relative_to(SOURCE)
        destination = target / relative
        assert destination.resolve().is_relative_to(target)
        if not destination.is_file() or sha(destination) != sha(source):
            backup(host, "research-wiki", relative)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
            changed.append(relative.as_posix())
        assert sha(destination) == sha(source)
        records.append({"path": relative.as_posix(), "source": str(source),
                        "target": str(destination), "sha256": sha(source)})
    allowed = {p.relative_to(SOURCE).as_posix() for p in source_files
               if p.is_relative_to(SOURCE / "app")}
    for destination in sorted((target / "app").rglob("*")):
        if destination.is_file() and destination.relative_to(target).as_posix() not in allowed:
            assert destination.resolve().is_relative_to((target / "app").resolve())
            backup(host, "research-wiki", destination.relative_to(target))
            removed.append(destination.relative_to(target).as_posix())
            destination.unlink()
    manifest_path = target / "installation-manifest.json"
    backup(host, "research-wiki", Path("installation-manifest.json"))
    manifest_path.write_text(json.dumps({
        "skill": "research-wiki", "source": str(SOURCE), "target": str(target),
        "installed_at": datetime.now(timezone.utc).isoformat(),
        "maintenance_record": str(TASK), "update": UPDATE, "files": records,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    assert all(sha(Path(item["target"])) == item["sha256"] for item in records)
    return {"host": host, "skill": "research-wiki", "files_verified": len(records),
            "changed": changed, "stale_app_removed": removed}


def deploy_sci_figure(host: str) -> dict:
    target = HOME / host / "skills" / "sci-figure-replica"
    assert target.resolve() == target.absolute()
    backup(host, "sci-figure-replica", Path("SKILL.md"))
    shutil.copy2(REPLICA / "SKILL.md", target / "SKILL.md")
    manifest_path = target / "installation-manifest.json"
    backup(host, "sci-figure-replica", Path("installation-manifest.json"))
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    matches = [item for item in manifest["files"] if item["path"] == "SKILL.md"]
    assert len(matches) == 1
    matches[0]["sha256"] = sha(target / "SKILL.md")
    manifest.update(installed_at=datetime.now(timezone.utc).isoformat(),
                    maintenance_record=str(TASK),
                    update="Align Wiki ingestion acceptance and knowledge-link review")
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                             encoding="utf-8")
    assert all(sha(Path(item["target"])) == item["sha256"] for item in manifest["files"])
    assert sha(target / "SKILL.md") == sha(REPLICA / "SKILL.md")
    return {"host": host, "skill": "sci-figure-replica",
            "files_verified": len(manifest["files"]), "changed": ["SKILL.md"]}


def main() -> None:
    source_files = files_under(SOURCE)
    # The deployed configuration must remain the canonical one.
    for host in HOSTS:
        target_config = HOME / host / "skills" / "research-wiki" / "config.json"
        assert target_config.read_bytes() == (SOURCE / "config.json").read_bytes(), target_config
    reports = []
    for host in HOSTS:
        reports.append(deploy_research_wiki(host, source_files))
        reports.append(deploy_sci_figure(host))
    (TASK / "deployment-verification.json").write_text(
        json.dumps(reports, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps([{"host": r["host"], "skill": r["skill"],
                       "verified": r["files_verified"], "changed": len(r["changed"])}
                      for r in reports], ensure_ascii=False))


if __name__ == "__main__":
    main()
