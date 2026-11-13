"""Profile an unchanged public RiskTable recipe in a fresh external copy."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


def hashes(root):
    return {path.relative_to(root).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(root.rglob("*")) if path.is_file()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("skill", "config", "env-root", "run-root", "report"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=1800)
    args = parser.parse_args()
    sys.path.insert(0, str(args.skill.resolve()))
    from rwiki.config import load_config
    from rwiki import recipes

    cfg = load_config(args.config)
    recipe_id = "figureya-193risktable"
    source = cfg.wiki_root / "recipes" / recipe_id / "source"
    before = hashes(source)
    args.run_root.mkdir(parents=True, exist_ok=False)
    os.environ.update(TEMP=str(args.env_root / "tmp"), TMP=str(args.env_root / "tmp"),
                      MPLCONFIGDIR=str(args.env_root / "tmp/mpl"), PYTHONUTF8="1",
                      PYTHONDONTWRITEBYTECODE="1", LANGUAGE="en")
    for name in ("R_HOME", "R_ARCH"):
        os.environ.pop(name, None)
    cli = [sys.executable, "-X", "utf8", str(args.skill / "wiki.py"), "--config", str(args.config)]
    subprocess.run([*cli, "use", recipe_id, "--project", str(args.run_root), "--name", "asset"],
                   check=True, capture_output=True, timeout=180,
                   creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    copied = args.run_root / "wiki-use/asset"
    expected_pdf = copied / "forestplot of risk table.pdf"
    reference = args.run_root / "upstream-output-reference"
    reference.mkdir()
    if expected_pdf.is_file():
        expected_pdf.rename(reference / expected_pdf.name)
    original_runner = recipes.RUNNER.read_text(encoding="utf-8")
    instrumentation = '''# Timing hooks and sampling only; recipe source and parameters are unchanged.
library(knitr)
knitr::opts_chunk$set(audit_stage = TRUE)
knitr::knit_hooks$set(audit_stage = function(before, options, envir) {
  message(format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3%z"), " ",
          if (before) "START " else "END ", options$label)
  invisible(NULL)
})
Rprof("audit-Rprof.out", interval = 0.05)
'''
    finish = '''
Rprof(NULL)
profile <- summaryRprof("audit-Rprof.out")
utils::write.table(head(profile$by.total, 40), "audit-profile-total.tsv", sep = "\\t", quote = FALSE)
utils::write.table(head(profile$by.self, 40), "audit-profile-self.tsv", sep = "\\t", quote = FALSE)
'''
    runner = args.run_root / "profiled_runner.R"
    runner.write_text(instrumentation + original_runner + finish, encoding="utf-8")
    recipes.RUNNER = runner
    started = datetime.now(timezone.utc)
    receipt = recipes.run_dir(cfg, copied, timeout=args.timeout)
    unchanged = before == hashes(source)
    report = {
        "id": recipe_id, "scope": "isolated-public-example-profiled-replay",
        "scientific_validation": False, "started_at": started.isoformat(),
        "state": "passed" if receipt["state"] == "pass" and not receipt["missing_outputs"] and unchanged else receipt["state"],
        "instrumentation": "Knitr chunk timing hooks and Rprof sampling; no source, data or statistical parameter edits.",
        "source_sha256": before, "original_files_unchanged": unchanged,
        "reference_outputs_quarantined": [expected_pdf.name], "receipt": receipt,
        "stage_log": (copied / "rwiki-stderr.txt").read_text(encoding="utf-8", errors="replace").splitlines(),
    }
    for key in ("audit-profile-total.tsv", "audit-profile-self.tsv"):
        path = copied / key
        if path.is_file():
            report[key] = path.read_text(encoding="utf-8").splitlines()
    roots = [(args.run_root.resolve(), "<run>"), (args.env_root.resolve(), "<env>"),
             (args.skill.resolve(), "<skill>"), (cfg.wiki_root.resolve(), "<wiki>"), (Path.home(), "<home>")]

    def clean(value):
        if isinstance(value, dict):
            return {clean(key): clean(item) for key, item in value.items()}
        if isinstance(value, list):
            return [clean(item) for item in value]
        if isinstance(value, str):
            for root, token in roots:
                value = value.replace(str(root), token).replace(root.as_posix(), token)
        return value

    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(clean(report), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"id": recipe_id, "state": report["state"], "duration_s": receipt["duration_s"]}))
    return 0 if report["state"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
