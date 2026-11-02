"""Capture the current dirty baseline and make a disposable coding workspace."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess

ROOT = Path("E:/research-wiki")
RECORD = ROOT / "维护记录/2026-10-24-跨领域课题复用闭环"
WORK = Path("E:/research-wiki-env/work/wiki-cross-domain-20261024")
DEV = ROOT / "开发"
PROJECT = Path("E:/青光眼单细胞")
SKIP = {".git", "node_modules", "__pycache__", ".pytest_cache", ".claude"}

def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def walk(root, skip=SKIP):
    for folder, dirs, files in __import__("os").walk(root):
        dirs[:] = [name for name in dirs if name not in skip]
        for name in files:
            path = Path(folder) / name
            if not path.is_symlink():
                yield path

def main():
    if (RECORD / "baseline.json").exists():
        raise SystemExit("Baseline already captured; refusing to replace it.")
    before = RECORD / "before"
    before.mkdir(parents=True, exist_ok=True)
    baseline = {"development": {}, "sources": {}, "project": {}, "author_pages": {}}
    for component in ["staged/research-wiki", "frontend"]:
        src = DEV / component
        target = WORK / "development" / component
        if target.exists():
            raise SystemExit("Isolated target already exists: " + str(target))
        shutil.copytree(src, target, ignore=shutil.ignore_patterns(*SKIP))
        for path in walk(src):
            relative = path.relative_to(DEV)
            baseline["development"][relative.as_posix()] = digest(path)
            saved = before / "development" / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, saved)
    for path in walk(ROOT / "知识库"):
        relative = path.relative_to(ROOT)
        if "source" in relative.parts or "original_code" in relative.parts:
            baseline["sources"][relative.as_posix()] = digest(path)
        if path.suffix == ".md":
            text = path.read_text(encoding="utf-8")
            if "<!-- user:start -->" in text:
                user = text.split("<!-- user:start -->", 1)[1].split("<!-- user:end -->", 1)[0]
                fields = [line for line in text.splitlines() if line.startswith(("id:", "status:", "favorite:"))]
                baseline["author_pages"][relative.as_posix()] = {"fields": fields, "user": user}
    for path in PROJECT.iterdir():
        if path.is_file() and path.suffix.lower() in {".r", ".rds", ".rdata", ".pdf", ".csv"}:
            baseline["project"][path.name] = {"sha256": digest(path), "size": path.stat().st_size}
    for repo, name in [(DEV, "development"), (ROOT, "wiki")]:
        result = subprocess.run(["git", "-C", str(repo), "status", "--porcelain=v1"], capture_output=True, text=True)
        (RECORD / (name + "-baseline-status.txt")).write_text(result.stdout, encoding="utf-8")
    (RECORD / "baseline.json").write_text(json.dumps(baseline, ensure_ascii=False, indent=2), encoding="utf-8")
    (WORK / "probe").mkdir(exist_ok=True)
    print(json.dumps({"workspace": str(WORK), "development_files": len(baseline["development"]),
                      "protected_sources": len(baseline["sources"]),
                      "protected_pages": len(baseline["author_pages"]),
                      "project_files": len(baseline["project"])}, ensure_ascii=False))

if __name__ == "__main__":
    main()
