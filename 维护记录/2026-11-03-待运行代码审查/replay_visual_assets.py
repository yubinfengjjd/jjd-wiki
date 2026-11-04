"""Replay copied Wiki recipes/templates without changing original assets or receipts."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def tree_hashes(root):
    return {path.relative_to(root).as_posix(): digest(path)
            for path in sorted(root.rglob("*")) if path.is_file()
            and "__pycache__" not in path.parts}


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def sanitize(value, roots):
    if isinstance(value, dict):
        return {sanitize(key, roots): sanitize(item, roots) for key, item in value.items()}
    if isinstance(value, list):
        return [sanitize(item, roots) for item in value]
    if isinstance(value, str):
        for root, token in roots:
            value = value.replace(str(root), token).replace(root.as_posix(), token)
    return value


def invoke(command, cwd, env, log, timeout):
    started = datetime.now(timezone.utc)
    try:
        result = subprocess.run(command, cwd=cwd, env=env, capture_output=True,
                                text=True, encoding="utf-8", errors="replace", timeout=timeout,
                                creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        text = result.stdout + "\n" + result.stderr
        code = result.returncode
    except subprocess.TimeoutExpired as error:
        stdout = error.stdout or b""
        stderr = error.stderr or b""
        text = (stdout.decode("utf-8", "replace") if isinstance(stdout, bytes) else stdout)
        text += (stderr.decode("utf-8", "replace") if isinstance(stderr, bytes) else stderr)
        text += f"\nAudit timeout after {timeout} seconds.\n"
        code = None
    log.write_text(text, encoding="utf-8")
    return {"command": command, "exit_code": code, "started_at": started.isoformat(),
            "duration_s": round((datetime.now(timezone.utc) - started).total_seconds(), 3),
            "log_tail": text.splitlines()[-15:]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill", type=Path, required=True)
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument("--env-root", type=Path, required=True)
    parser.add_argument("--run-root", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--kind", choices=("recipes", "templates"), required=True)
    parser.add_argument("--ids", nargs="*")
    parser.add_argument("--timeout", type=int, default=900)
    parser.add_argument("--plan", action="store_true")
    args = parser.parse_args()
    # Children run outside the repository; resolve caller-relative paths first.
    for name in ("skill", "config", "env_root", "run_root", "report"):
        setattr(args, name, getattr(args, name).resolve())
    sys.path.insert(0, str(args.skill.resolve()))
    from rwiki.config import load_config
    from rwiki.pages import read_page

    config = load_config(args.config)
    pages = sorted((config.wiki_root / args.kind).glob("*.md"))
    if args.ids:
        selected = set(args.ids)
        pages = [path for path in pages if path.stem in selected]
        missing = selected - {path.stem for path in pages}
        if missing:
            parser.error("Unknown asset ids: " + ", ".join(sorted(missing)))
    if args.plan:
        print(json.dumps({"kind": args.kind, "count": len(pages),
                          "ids": [path.stem for path in pages]}, ensure_ascii=False, indent=2))
        return 0
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    # A unique root makes stale outputs unable to satisfy a new run.
    args.run_root.mkdir(parents=True, exist_ok=False)
    env = dict(os.environ)
    env.update(PYTHONUTF8="1", PYTHONDONTWRITEBYTECODE="1", LANG="English_United States.utf8",
               LC_ALL="", LC_CTYPE="", TEMP=str(args.env_root / "tmp"),
               TMP=str(args.env_root / "tmp"), MPLCONFIGDIR=str(args.env_root / "tmp/mpl"),
               R_LIBS_USER=os.pathsep.join(str(path) for path in config.r_libs),
               RETICULATE_USE_MANAGED_VENV="no")
    for name in ("R_HOME", "R_ARCH"):
        env.pop(name, None)
    roots = [(args.run_root.resolve(), "<run>"), (config.wiki_root.resolve(), "<wiki>"),
             (args.skill.resolve(), "<skill>"), (args.env_root.resolve(), "<env>"),
             (Path.home(), "<home>")]
    records = []
    cli = [sys.executable, "-X", "utf8", str(args.skill / "wiki.py"), "--config", str(args.config)]
    for page in pages:
        meta, _ = read_page(page)
        asset = page.with_suffix("")
        case = args.run_root / page.stem
        case.mkdir()
        row = {"id": page.stem, "kind": args.kind, "scope": "isolated-public-example-replay",
               "scientific_validation": False, "state": "not_run"}
        original_root = asset / ("source" if args.kind == "recipes" else "code")
        original_hashes = tree_hashes(original_root)
        try:
            if args.kind == "templates":
                isolated = case / "wiki" / "templates" / page.stem
                isolated.mkdir(parents=True)
                for folder in ("code", "example"):
                    shutil.copytree(asset / folder, isolated / folder,
                                    ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
                for filename in ("runtime.json", "spec.json"):
                    if (asset / filename).is_file():
                        shutil.copy2(asset / filename, isolated / filename)
                shutil.copy2(page, isolated.parent / page.name)
                spec = json.loads((isolated / "spec.json").read_text(encoding="utf-8"))
                interfaces = case / "wiki/interfaces"
                interfaces.mkdir()
                for interface in {table["interface"] for table in spec.get("tables", {}).values()}:
                    source = config.wiki_root / "interfaces" / f"{interface}.md"
                    shutil.copy2(source, interfaces / source.name)
                row["interface_sha256"] = tree_hashes(interfaces)
                row["copied_inputs_sha256"] = tree_hashes(isolated)
                output = case / "output"
                command = [*cli, "--wiki-root", str(case / "wiki"), "render", page.stem,
                           "--data", str(isolated / "example"), "--out", str(output)]
                style = isolated / "example/style.json"
                if style.is_file():
                    command += ["--style", str(style)]
                row.update(invoke(command, args.env_root / "tmp", env, case / "render.log", args.timeout))
                outputs = {path.name: digest(path) for path in sorted(output.glob("figure.*"))
                           if path.is_file()}
                complete = all(f"figure.{ext}" in outputs for ext in ("png", "pdf", "svg"))
                after = tree_hashes(isolated)
                unchanged = all(after.get(name) == expected
                                for name, expected in row["copied_inputs_sha256"].items())
                row["additional_runtime_files"] = sorted(after.keys() - row["copied_inputs_sha256"].keys())
                row.update(outputs_sha256=outputs, copied_inputs_unchanged=unchanged)
                row["state"] = "passed" if row["exit_code"] == 0 and complete and unchanged else "failed"
            else:
                use_command = [*cli, "use", page.stem, "--project", str(case), "--name", "asset"]
                row["copy"] = invoke(use_command, args.env_root / "tmp", env, case / "use.log", 180)
                if row["copy"]["exit_code"] != 0:
                    raise RuntimeError("Wiki use failed; see copy log")
                copied = case / "wiki-use/asset"
                reference = case / "upstream-output-reference"
                # Preserve supplied result artifacts elsewhere, so they cannot count as new outputs.
                reference.mkdir()
                for relative in meta.get("outputs", []):
                    path = (copied / relative).resolve()
                    if not path.is_relative_to(copied.resolve()):
                        raise ValueError("Declared output escapes the copied asset")
                    if path.is_file():
                        target = reference / relative
                        target.parent.mkdir(parents=True, exist_ok=True)
                        path.rename(target)
                command = [*cli, "run", "--dir", str(copied), "--timeout", str(args.timeout)]
                row.update(invoke(command, args.env_root / "tmp", env, case / "run.log", args.timeout + 60))
                receipts = sorted((copied / "rwiki-runs").glob("*.json"))
                if not receipts:
                    raise RuntimeError("Recipe did not produce a run receipt")
                receipt = json.loads(receipts[-1].read_text(encoding="utf-8"))
                row["receipt"] = receipt
                row["state"] = ("passed" if receipt["state"] == "pass"
                                and not receipt.get("missing_outputs") else receipt["state"])
                if receipt["state"] == "pass" and receipt.get("missing_outputs"):
                    row["state"] = "failed"
                    row["error"] = "knit returned success but declared outputs were not regenerated"
        except Exception as error:
            row["error"] = f"{type(error).__name__}: {error}"
        row["original_files_sha256"] = original_hashes
        row["original_files_unchanged"] = original_hashes == tree_hashes(original_root)
        if not row["original_files_unchanged"]:
            row["state"] = "failed"
            row["error"] = "Original asset bytes changed during execution"
        records.append(sanitize(row, roots))
        write_json(args.report, {"kind": args.kind, "cases": records,
                                "completed": len(records), "total": len(pages)})
        print(f"{args.kind}/{page.stem}: {row['state']}", flush=True)
    return int(any(row["state"] != "passed" for row in records))


if __name__ == "__main__":
    raise SystemExit(main())
