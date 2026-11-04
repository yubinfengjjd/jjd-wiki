"""Adopt hash-checked template replays and refresh repaired recipe receipts.

No save/commit is performed here. Source originals and existing receipt bytes
are checked before and after; historical recipe pruning is explicitly disabled.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kind", choices=("templates", "recipes"))
    args = parser.parse_args()
    audit = Path(__file__).resolve().parent
    vault = audit.parents[1]
    environment = vault.parent / "research-wiki-env"
    skill = vault.parent / "jjd-wiki-dev/staged/research-wiki"
    sys.path.insert(0, str(skill))
    from rwiki.config import load_config
    config = load_config(skill / "config.json")
    os.environ.update(TEMP=str(environment / "tmp"), TMP=str(environment / "tmp"),
                      MPLCONFIGDIR=str(environment / "tmp/mpl"), LANG="English_United States.utf8",
                      LC_ALL="", LC_CTYPE="", R_USER_CACHE_DIR=str(environment / "profiles/recipe61/cache"))
    if args.kind == "templates":
        from rwiki.verification import start_replay, record_preview, replay_available
        current = {}
        for name, run in (("template-python-replay2.json", "template-python-pass2"),
                          ("template-r-replay2.json", "template-r-pass2"),
                          ("template-display-fixes/replay-pass4.json", "template-display-pass4"),
                          ("template-display-fixes/replay-pass5.json", "template-display-pass5"),
                          ("template-display-fixes/replay-pass6.json", "template-display-pass6")):
            for row in json.loads((audit / name).read_text(encoding="utf-8"))["cases"]:
                assert row["state"] == "passed", row["id"]
                current[row["id"]] = (row, name, run)
        assert len(current) == 30
        results = []
        for identity, (row, report, run) in sorted(current.items()):
            target = config.wiki_root / "templates" / identity
            for name, expected in row["copied_inputs_sha256"].items():
                assert digest(target / name) == expected, (identity, name)
            generated = environment / "work" / run / identity / "output"
            for name, expected in row["outputs_sha256"].items():
                assert digest(generated / name) == expected
            old = target / "verify/verify.json"
            old_hash = digest(old)
            inputs = start_replay(target)
            for name in ("figure.png", "figure.pdf", "figure.svg", "sizing.json"):
                if (generated / name).is_file():
                    shutil.copy2(generated / name, target / "verify" / name)
            record_preview(target, inputs=inputs, executable=(
                "<ENV_ROOT>/ml-python/Scripts/python.exe" if "python" in report else "<ENV_ROOT>/R-4.5.0/bin/x64/Rscript.exe"))
            assert replay_available(target)
            assert any(digest(path) == old_hash for path in (target / "verify/history").glob("*.json"))
            results.append({"id": identity, "current_replay_available": True,
                            "old_receipt_preserved": True, "actual_replay_report": report,
                            "new_receipt_sha256": digest(old), "visual_review": "See visual-qa/review-pass2.md and template-display-fixes/review.md; warnings are preserved."})
        (audit / "template-evidence-adoption.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
        print("30 template current replays verified; all old receipts retained", flush=True)
    else:
        from rwiki import recipes
        identifiers = ["figureya-11bubble", "figureya-13gsea-java-update", "figureya-59volcanov2",
                       "figureya-92immune-gene-update", "figureya-153ccgraph", "figureya-61gsva",
                       "figureya-193risktable", "figureya-228linkcor", "figureya-236circgroup"]
        old = {path: digest(path) for identity in identifiers
               for path in (config.wiki_root / "recipes" / identity / "runs").glob("*.json")}
        # Production defaults prune history. This audit must preserve it instead.
        recipes.KEEP_RECEIPTS = len(old) + len(identifiers) + 1

        def execute(identity):
            profile = {"figureya-153ccgraph": "recipe153", "figureya-61gsva": "recipe61"}.get(identity)
            selected = load_config(environment / "profiles" / profile / "config.json") if profile else config
            result = recipes.run_recipe(selected, identity, timeout=1800)
            assert result["state"] == "pass" and not result["missing_outputs"], (identity, result.get("error"))
            print(identity, result["state"], result["duration_s"], flush=True)
            return {"id": identity, "state": result["state"], "run_id": result["run_id"], "profile": profile or "Wiki R 4.5/Bioc3.21"}

        with ThreadPoolExecutor(max_workers=3) as pool:
            results = list(pool.map(execute, identifiers))
        assert all(digest(path) == expected for path, expected in old.items())
        (audit / "recipe-current-evidence.json").write_text(json.dumps({"cases": results,
            "all_historical_receipts_unchanged": True}, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
