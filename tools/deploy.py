"""Deploy the research-wiki skill from 开发/staged to all five local installs.

Single entry point replacing the per-record copies under 维护记录/. Usage:

    python tools/deploy.py <maintenance-record-dir> "<one-line update note>"
    python tools/deploy.py --verify-only

部署前先过来源门禁：开发仓库工作区干净，且 HEAD 等于 fetch 后的 origin/main，或 HEAD 恰为
一个已推送 tag；否则中止并报告当前分支与提交。manifest 记录 source_commit 与 source_tag。
--verify-only 只比较 staged 与 5 处副本的哈希并打印差异清单，不写入、不检查门禁。

Every overwritten or removed installed file is first copied to <record>/backup/<host>/;
stale app bundles are removed; each install gets a fresh installation-manifest.json and is
verified by SHA-256. The deployed config.json must already equal the staged one.
sci-figure-replica is not handled here (its source lives outside this project).
"""
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
SOURCE = Path(__file__).resolve().parents[1] / "开发" / "staged" / "research-wiki"
DEV = SOURCE.parents[1]
SKIP = {".git", "__pycache__", ".pytest_cache", "node_modules"}
HOSTS = (".agents", ".codex", ".claude", ".cc-switch", ".config/opencode")
MANIFEST = "installation-manifest.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dev_git(*args: str, check: bool = True) -> str:
    result = subprocess.run(["git", "-C", str(DEV), *args], capture_output=True, text=True, encoding="utf-8")
    if check and result.returncode:
        sys.exit(f"git {' '.join(args)} 失败：{result.stderr.strip()}")
    return result.stdout.strip() if result.returncode == 0 else ""


def source_gate() -> dict:
    """只允许从已推送的 origin/main 或已推送 tag 部署。"""
    head = dev_git("rev-parse", "HEAD")
    branch = dev_git("branch", "--show-current") or "（分离 HEAD）"
    if dev_git("status", "--porcelain"):
        sys.exit(f"部署来源门禁未通过：开发仓库有未提交改动\n当前分支: {branch}\nHEAD: {head}")
    dev_git("fetch", "origin")
    main = dev_git("rev-parse", "--verify", "-q", "refs/remotes/origin/main", check=False)
    if head == main:
        return {"commit": head, "tag": None}
    tag = dev_git("describe", "--exact-match", "--tags", "HEAD", check=False)
    if tag and dev_git("ls-remote", "--tags", "origin", f"refs/tags/{tag}"):
        return {"commit": head, "tag": tag}
    sys.exit(f"部署来源门禁未通过：HEAD 既不是 origin/main 也不是已推送 tag\n"
             f"当前分支: {branch}\nHEAD: {head}\norigin/main: {main or '（不存在）'}")


def source_files() -> list[Path]:
    return sorted(p for p in SOURCE.rglob("*")
                  if p.is_file() and not (set(p.relative_to(SOURCE).parts) & SKIP)
                  and p.name != MANIFEST and p.suffix not in {".pyc", ".pyo"})


def verify_only() -> int:
    """打印 5 处副本与 staged 的差异清单；不一致返回 1。"""
    files = source_files()
    wanted = {p.relative_to(SOURCE).as_posix(): sha(p) for p in files}
    report, differs = [], False
    for host in HOSTS:
        target = HOME / host / "skills" / "research-wiki"
        installed = {p.relative_to(target).as_posix() for p in target.rglob("*")
                     if p.is_file() and not (set(p.relative_to(target).parts) & SKIP)
                     and p.name != MANIFEST and p.suffix not in {".pyc", ".pyo"}} if target.is_dir() else set()
        entry = {"host": host,
                 "missing": sorted(set(wanted) - installed),
                 "different": sorted(name for name in set(wanted) & installed
                                     if sha(target / name) != wanted[name]),
                 "extra": sorted(installed - set(wanted))}
        differs = differs or any(entry[key] for key in ("missing", "different", "extra"))
        report.append(entry)
    print(json.dumps({"consistent": not differs, "hosts": report}, ensure_ascii=False, indent=2))
    return 1 if differs else 0


def deploy(host: str, files: list[Path], record: Path, note: str, gate: dict) -> dict:
    target = HOME / host / "skills" / "research-wiki"
    assert target.resolve() == target.absolute(), f"{target} is a link"
    backup_root = record / "backup" / host / "research-wiki"

    def backup(relative: Path) -> None:
        installed = target / relative
        saved = backup_root / relative
        if installed.is_file() and not saved.exists():
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(installed, saved)

    records, changed, removed = [], [], []
    for source in files:
        relative = source.relative_to(SOURCE)
        destination = target / relative
        if not destination.is_file() or sha(destination) != sha(source):
            backup(relative)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
            changed.append(relative.as_posix())
        records.append({"path": relative.as_posix(), "source": str(source),
                        "target": str(destination), "sha256": sha(source)})
    # Old hashed bundles would otherwise accumulate in app/.
    wanted = {p.relative_to(SOURCE).as_posix() for p in files if p.is_relative_to(SOURCE / "app")}
    for installed in sorted((target / "app").rglob("*")):
        relative = installed.relative_to(target)
        if installed.is_file() and relative.as_posix() not in wanted:
            backup(relative)
            installed.unlink()
            removed.append(relative.as_posix())
    backup(Path(MANIFEST))
    (target / MANIFEST).write_text(json.dumps({
        "skill": "research-wiki", "source": str(SOURCE), "target": str(target),
        "installed_at": datetime.now(timezone.utc).isoformat(),
        "source_commit": gate["commit"], "source_tag": gate["tag"],
        "maintenance_record": str(record), "update": note, "files": records,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    bad = [r["path"] for r in records if sha(Path(r["target"])) != r["sha256"]]
    assert not bad, f"{host}: hash mismatch {bad}"
    return {"host": host, "verified": len(records), "changed": changed, "stale_removed": removed}


def main() -> None:
    if sys.argv[1:] == ["--verify-only"]:
        sys.exit(verify_only())
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    gate = source_gate()
    record, note = Path(sys.argv[1]).resolve(), sys.argv[2]
    for host in HOSTS:
        config = HOME / host / "skills" / "research-wiki" / "config.json"
        assert config.read_bytes() == (SOURCE / "config.json").read_bytes(), f"config differs: {config}"
    record.mkdir(parents=True, exist_ok=True)
    files = source_files()
    reports = [deploy(host, files, record, note, gate) for host in HOSTS]
    (record / "deployment-verification.json").write_text(
        json.dumps(reports, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps([{k: (len(v) if isinstance(v, list) else v) for k, v in r.items()} for r in reports],
                     ensure_ascii=False))


if __name__ == "__main__":
    main()
