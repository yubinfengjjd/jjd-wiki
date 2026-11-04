"""Deploy the research-wiki skill from 开发/staged to all six local installs.

Single entry point replacing the per-record copies under 维护记录/. Usage:

    python tools/deploy.py <maintenance-record-dir> "<one-line update note>" [--sync-config]
    python tools/deploy.py --verify-only

部署前先过来源门禁（治理 v2）：开发仓库工作区干净，且 HEAD 等于本地 main（refs/heads/main）、
fetch 后的 origin/main，或恰为一个已推送 tag；fetch 失败（离线）时只认本地 main。否则中止并报告
当前分支与提交。manifest 记录 source_commit、source_ref（main / origin/main / tag 名）与 source_tag。
--verify-only 只比较 staged 与 6 处副本的哈希，按 missing / different / extra 打印差异清单，
不写入、不检查门禁。

Every overwritten or removed installed file is first copied to <record>/backup/<host>/.
Installed files that staged no longer has are removed anywhere in the skill directory
(config.json, the manifest, __pycache__, .pytest_cache and *.pyc are left alone) and the
directories this empties are pruned; each install gets a fresh installation-manifest.json and
is verified by SHA-256. The deployed config.json must already equal the staged one; with
--sync-config the staged config.json is copied over instead (after the backup).
sci-figure-replica is not handled here (its source lives outside this project).
"""
import hashlib
import argparse
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from machine_paths import resolve_dev_root

HOME = Path.home()
try:
    DEV = resolve_dev_root(Path(__file__).resolve().parents[1])
    SOURCE = DEV / "staged/research-wiki"
except ValueError:
    # Allow --dev-root to be parsed before reporting a missing default checkout.
    DEV = SOURCE = None
SKIP = {".git", "__pycache__", ".pytest_cache", "node_modules"}
HOSTS = (".agents", ".codex", ".claude", ".cc-switch", ".config/opencode", ".kiro")
MANIFEST = "installation-manifest.json"
CONFIG = "config.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_git(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", "-C", str(DEV), *args], capture_output=True, text=True, encoding="utf-8")


def dev_git(*args: str, check: bool = True) -> str:
    result = run_git(*args)
    if check and result.returncode:
        sys.exit(f"git {' '.join(args)} 失败：{result.stderr.strip()}")
    return result.stdout.strip() if result.returncode == 0 else ""


def source_gate() -> dict:
    """只允许从本地 main、fetch 后的 origin/main 或已推送 tag 部署。"""
    head = dev_git("rev-parse", "HEAD")
    # git < 2.22 lacks ``branch --show-current``; rev-parse covers older versions.
    branch = dev_git("branch", "--show-current", check=False) \
        or dev_git("rev-parse", "--abbrev-ref", "HEAD", check=False)
    branch = "（分离 HEAD）" if branch in ("", "HEAD") else branch
    where = f"当前分支: {branch}\nHEAD: {head}"
    if dev_git("status", "--porcelain"):
        sys.exit(f"部署来源门禁未通过：开发仓库有未提交改动\n{where}")
    main = dev_git("rev-parse", "--verify", "-q", "refs/heads/main", check=False)
    if head == main:
        return {"commit": head, "ref": "main", "tag": None}
    fetched = run_git("fetch", "origin")
    if fetched.returncode:
        sys.exit(f"部署来源门禁未通过：fetch origin 失败（离线？），此时只允许 HEAD 等于本地 main\n"
                 f"{where}\n本地 main: {main or '（不存在）'}\ngit: {fetched.stderr.strip()}")
    origin = dev_git("rev-parse", "--verify", "-q", "refs/remotes/origin/main", check=False)
    if head == origin:
        return {"commit": head, "ref": "origin/main", "tag": None}
    tag = dev_git("describe", "--exact-match", "--tags", "HEAD", check=False)
    if tag and dev_git("ls-remote", "--tags", "origin", f"refs/tags/{tag}"):
        return {"commit": head, "ref": tag, "tag": tag}
    sys.exit(f"部署来源门禁未通过：HEAD 既不是本地 main、origin/main，也不是已推送 tag\n{where}\n"
             f"本地 main: {main or '（不存在）'}\norigin/main: {origin or '（不存在）'}")


def deployable(path: Path, root: Path) -> bool:
    """参与部署与比较的文件：跳过仓库/缓存目录、manifest 与 .pyc/.pyo。"""
    return (path.is_file() and not (set(path.relative_to(root).parts) & SKIP)
            and path.name != MANIFEST and path.suffix not in {".pyc", ".pyo"})


def source_files() -> list[Path]:
    return sorted(p for p in SOURCE.rglob("*") if deployable(p, SOURCE))


def installed_files(target: Path) -> set[str]:
    if not target.is_dir():
        return set()
    return {p.relative_to(target).as_posix() for p in target.rglob("*") if deployable(p, target)}


def verify_only() -> int:
    """打印 6 处副本与 staged 的差异清单（missing / different / extra）；不一致返回 1。"""
    wanted = {p.relative_to(SOURCE).as_posix(): sha(p) for p in source_files()}
    report, differs = [], False
    for host in HOSTS:
        target = HOME / host / "skills" / "research-wiki"
        installed = installed_files(target)
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
    # staged 已没有的旧文件（整个技能目录）：先备份再删除，再清掉因此变空的目录。
    # 先清理后复制：Windows 上只改了大小写的文件会按 staged 的新名字重新写入。
    wanted = {p.relative_to(SOURCE).as_posix() for p in files}
    for name in sorted(installed_files(target) - wanted - {CONFIG}):
        stale = target / name
        backup(Path(name))
        stale.unlink()
        removed.append(name)
        parent = stale.parent
        while parent != target and not any(parent.iterdir()):
            parent.rmdir()
            parent = parent.parent
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
    backup(Path(MANIFEST))
    (target / MANIFEST).write_text(json.dumps({
        "skill": "research-wiki", "source": str(SOURCE), "target": str(target),
        "installed_at": datetime.now(timezone.utc).isoformat(),
        "source_commit": gate["commit"], "source_ref": gate["ref"], "source_tag": gate["tag"],
        "maintenance_record": str(record), "update": note, "files": records,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    bad = [r["path"] for r in records if sha(Path(r["target"])) != r["sha256"]]
    assert not bad, f"{host}: hash mismatch {bad}"
    return {"host": host, "verified": len(records), "changed": changed, "stale_removed": removed}


def main() -> None:
    global SOURCE, DEV
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("record", nargs="?", type=Path)
    parser.add_argument("note", nargs="?")
    parser.add_argument("--sync-config", action="store_true")
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--dev-root", type=Path)
    args = parser.parse_args()
    if args.dev_root is not None or SOURCE is None:
        try:
            DEV = resolve_dev_root(Path(__file__).resolve().parents[1], args.dev_root)
        except ValueError as exc:
            parser.error(str(exc))
        SOURCE = DEV / "staged/research-wiki"
    if args.verify_only:
        if args.record is not None or args.note is not None or args.sync_config:
            parser.error("--verify-only cannot be combined with deployment arguments")
        sys.exit(verify_only())
    if args.record is None or args.note is None:
        parser.error("deployment requires a maintenance record directory and update note")
    gate = source_gate()
    record, note = args.record.resolve(), args.note
    staged_config = (SOURCE / CONFIG).read_bytes()
    configs = [HOME / host / "skills" / "research-wiki" / CONFIG for host in HOSTS]
    differ = [str(path) for path in configs if not path.is_file() or path.read_bytes() != staged_config]
    if differ and not args.sync_config:
        sys.exit("部署中止：以下 config.json 与 staged 不同（或缺失）\n  " + "\n  ".join(differ)
                 + "\n核对 staged config.json 后加 --sync-config 重跑：各处原文件先备份到"
                   " <record>/backup/<host>/ 再覆盖。")
    record.mkdir(parents=True, exist_ok=True)
    files = source_files()
    reports = [deploy(host, files, record, note, gate) for host in HOSTS]
    (record / "deployment-verification.json").write_text(
        json.dumps(reports, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps([{k: (len(v) if isinstance(v, list) else v) for k, v in r.items()} for r in reports],
                     ensure_ascii=False))


if __name__ == "__main__":
    main()
