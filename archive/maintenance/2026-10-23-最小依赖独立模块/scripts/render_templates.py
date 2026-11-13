"""Render each SCP template from an isolated copy and compare output hashes.

Usage: D:/anaconda/python.exe -X utf8 scripts/render_templates.py
"""
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WIKI = Path("E:/research-wiki/知识库/templates")
DEST = ROOT / "portability" / "templates"
RSCRIPT = Path("D:/R-4.5.0/bin/Rscript.exe")
ENV = dict(os.environ)
ENV.update({
    "R_LIBS_USER": "E:/research-wiki-env/R-lib-scp/4.5",
    "TEMP": "E:/research-wiki-env/tmp",
    "TMP": "E:/research-wiki-env/tmp",
    "MPLCONFIGDIR": "E:/research-wiki-env/tmp/mpl",
})


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    evidence = {}
    for src in sorted(WIKI.glob("2026-10-22-scp-example__*")):
        if not src.is_dir():
            continue
        target = DEST / src.name
        if target.exists():
            shutil.rmtree(target)
        target.mkdir(parents=True)
        shutil.copy2(src / "spec.json", target / "spec.json")
        shutil.copytree(src / "code", target / "code")
        shutil.copytree(src / "example", target / "example")
        out = target / "out"
        log = target / "render.log"
        command = [str(RSCRIPT), "--vanilla", str(target / "code" / "render.R"),
                   "--data", str(target / "example"), "--out", str(out)]
        style = target / "example" / "style.json"
        if style.is_file():
            command += ["--style", str(style)]
        started_at = datetime.datetime.now(datetime.timezone.utc).isoformat()
        with open(log, "w", encoding="utf-8") as stream:
            proc = subprocess.run(
                command, cwd=str(Path("E:/research-wiki-env/tmp")),
                env=ENV, stdout=stream, stderr=subprocess.STDOUT,
            )
        state = "passed" if proc.returncode == 0 else "not_run"
        executed_at = datetime.datetime.now(datetime.timezone.utc).isoformat()
        code_sha256 = {path.relative_to(target).as_posix(): sha256(path)
                       for path in (target / "code").rglob("*") if path.is_file()}
        item = {"state": state, "exit_code": proc.returncode, "outputs": {},
                "command": subprocess.list2cmdline(command),
                "isolated_dir": str(target), "code_dir": str(target / "code"),
                "example_dir": str(target / "example"), "out_dir": str(out),
                "working_directory": "E:/research-wiki-env/tmp",
                "started_at": started_at, "executed_at": executed_at,
                "code_sha256": code_sha256}
        for name in ("figure.png", "figure.pdf", "figure.svg", "sizing.json"):
            path = out / name
            item["outputs"][name] = sha256(path) if path.is_file() else None
        verify = src / "verify" / "verify.json"
        if verify.is_file() and state == "passed":
            old = json.loads(verify.read_text(encoding="utf-8")).get("outputs", {})
            item["previous_outputs"] = old
            item["same_as_previous"] = {
                key: old.get(key) == item["outputs"].get({"png": "figure.png", "pdf": "figure.pdf", "svg": "figure.svg"}[key])
                for key in ("png", "pdf", "svg")
            }
        if state != "passed":
            tail = (log.read_text(encoding="utf-8", errors="replace").splitlines() or [""])[-6:]
            item["error_tail"] = tail
        evidence[src.name] = item
        print(src.name, state, proc.returncode,
              item.get("same_as_previous", ""))
    out_file = ROOT / "portability" / "templates-evidence.json"
    out_file.write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("wrote", out_file)


if __name__ == "__main__":
    main()
