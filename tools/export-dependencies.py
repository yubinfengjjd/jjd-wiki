"""Export declared dependencies without importing scientific packages or installing anything."""
import argparse
import csv
import hashlib
import json
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE_R = {"base", "compiler", "datasets", "graphics", "grDevices", "grid", "methods", "parallel",
          "splines", "stats", "stats4", "tcltk", "tools", "utils"}
ALIASES = {"p": "Dynamic package variable recorded by static extraction; not an install target.",
           "org_sp": "Dynamic species-annotation namespace; resolve species/build before use.",
           "idconvert": "Feature flag in gene-set-enrichment/code/analysis.R (not a package); its real dependencies are biomaRt, AnnotationDbi, R.cache, reshape2 and data.table."}


def description(text):
    result, key = {}, None
    for line in text.splitlines():
        if line and not line[0].isspace() and ":" in line:
            key, value = line.split(":", 1)
            result[key] = value.strip()
        elif key:
            result[key] += " " + line.strip()
    return result


def write_tsv(path, rows, fields):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fields, delimiter="\t", lineterminator="\n", extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def collect(root):
    sys.path.insert(0, str(root / "开发/staged/research-wiki"))
    from rwiki.adapters import required_packages, declared_only
    from rwiki.pages import read_page
    records = defaultdict(lambda: {"refs": set(), "runtime": False, "pending": False})
    inputs, excluded = {}, []

    def read(path):
        data = path.read_bytes()
        inputs[path.relative_to(root).as_posix()] = hashlib.sha256(data).hexdigest()
        return data.decode("utf-8")

    pending_file = root / "文档/迁移验证清单-20261102/unverified-branches.json"
    pending = {(r["method_id"], r["implementation"]) for r in json.loads(read(pending_file))}

    def add(language, package, scope, reference, runtime=False, waiting=False):
        row = records[language, package]
        row["refs"].add(scope + ":" + reference)
        row["runtime"] |= runtime
        row["pending"] |= waiting

    for path in sorted((root / "知识库").glob("*/*/runtime.json")):
        runtime = json.loads(read(path))
        for branch in runtime.get("implementations", [runtime]):
            reference = path.relative_to(root).as_posix() + "#" + branch.get("id", runtime["id"])
            waiting = (runtime["id"], branch.get("id")) in pending
            for scope in ("required_packages", "optional_packages"):
                for language, packages in branch.get(scope, {}).items():
                    for package in packages:
                        add(language, package, scope, reference, True, waiting)
    for path in sorted((root / "知识库/recipes").glob("*.md")):
        read(path)
        meta, _ = read_page(path)
        for package in required_packages(meta.get("packages", {})):
            add("R", package, "recipe-used", path.relative_to(root).as_posix(), True)
        for package in declared_only(meta.get("packages", {})):
            excluded.append({"package": package, "reference": path.relative_to(root).as_posix(),
                             "reason": "Install-script declaration unused by recipe code; not required here."})
    for path in sorted((root / "知识库/sources").glob("*/items.jsonl")):
        for line in read(path).splitlines():
            item = json.loads(line)
            for package in required_packages(item.get("packages", {})):
                add("R", package, "L0-candidate", path.parent.name + ":" + str(item.get("id", "")))
    for path in sorted((root / "依赖清单/source-rules").glob("*.DESCRIPTION")):
        meta = description(read(path))
        for field in ("Depends", "Imports", "LinkingTo", "Suggests"):
            for item in meta.get(field, "").split(","):
                package = re.sub(r"\s*\(.*?\)", "", item).strip()
                if package and package != "R":
                    add("R", package, "source-" + field, meta["Package"])
    path = root / "知识库/methods/scop-source-catalog/core-install-plan.json"
    for target in json.loads(read(path))["targets"]:
        add("R", target["package"], "source-core", "scop")
    for package in ("BiocManager", "remotes", "BPCells"):
        add("R", package, "batch-bootstrap", "R installer / monocle3 prerequisite", True, True)
    provenance = root / "依赖清单/python/source-provenance.json"
    if provenance.is_file():
        source = json.loads(read(provenance))["scp_legacy"]
        read(root / source["source"])
        if inputs[source["source"]] != source["sha256"]:
            raise ValueError("SCP source changed: refresh the Python profiles before exporting")
    return records, inputs, excluded


def export(root):
    out = root / "依赖清单"
    records, inputs, excluded = collect(root)
    routes_path = out / "repository-snapshot.json"
    routes = json.loads(routes_path.read_text(encoding="utf-8"))
    inputs[routes_path.relative_to(root).as_posix()] = hashlib.sha256(routes_path.read_bytes()).hexdigest()
    rows, base_rows = [], []
    for (language, package), item in sorted(records.items()):
        reference = ";".join(sorted(item["refs"]))
        if language == "R" and (package in BASE_R or package in ALIASES):
            base_rows.append({"package": package, "reference": reference,
                              "reason": ALIASES.get(package, "Ships with R; do not install separately.")})
            continue
        route = routes["packages"].get(package, {}) if language == "R" else {}
        desc = route.get("description", {})
        depends = ",".join(desc.get(k, "") for k in ("Depends", "Imports", "LinkingTo"))
        depends = ",".join(re.sub(r"\s*\(.*?\)", "", p).strip() for p in depends.split(",") if p.strip())
        rows.append({"ecosystem": language, "package": package, "runtime": int(item["runtime"]),
                     "pending": int(item["pending"]), "installer": route.get("installer", "pip" if language == "Python" else "unresolved"),
                     "spec": route.get("spec", package), "catalog_version": route.get("version", ""),
                     "source_url": route.get("url", ""), "depends_on": depends, "references": reference})
    fields = ["ecosystem", "package", "runtime", "pending", "installer", "spec", "catalog_version", "source_url", "depends_on", "references"]
    write_tsv(out / "packages.tsv", rows, fields)
    write_tsv(out / "R/plan.tsv", [r for r in rows if r["ecosystem"] == "R"], fields)
    write_tsv(out / "R/unresolved.tsv", [r for r in rows if r["ecosystem"] == "R" and r["installer"] == "unresolved"], fields)
    write_tsv(out / "excluded-or-built-in.tsv", base_rows + excluded, ["package", "reference", "reason"])
    for profile in ("runtime", "pending", "all"):
        names = [r["package"] for r in rows if r["ecosystem"] == "R" and (profile == "all" or r[profile])]
        (out / f"R/{profile}.txt").write_text("\n".join(names) + "\n", encoding="utf-8")
    frontend = root / "开发/frontend/package-lock.json"
    data = json.loads(frontend.read_text(encoding="utf-8"))
    inputs[frontend.relative_to(root).as_posix()] = hashlib.sha256(frontend.read_bytes()).hexdigest()
    node_rows = []
    for category in ("dependencies", "devDependencies"):
        for name, spec in data["packages"][""].get(category, {}).items():
            node_rows.append({"package": name, "requirement": spec, "locked_version": data["packages"]["node_modules/" + name]["version"], "role": category})
    write_tsv(out / "node-direct.tsv", node_rows, ["package", "requirement", "locked_version", "role"])
    summary = {"schema_version": 1, "generated_on": "2026-11-03", "scope": "Declared runtime + used recipe + L0/source candidates; no installation or algorithm execution.",
               "counts": {"R": sum(r["ecosystem"] == "R" for r in rows), "Python_declared": sum(r["ecosystem"] == "Python" for r in rows),
                          "R_runtime": sum(r["ecosystem"] == "R" and r["runtime"] for r in rows),
                          "R_pending": sum(r["ecosystem"] == "R" and r["pending"] for r in rows),
                          "R_unresolved_runtime": sum(r["ecosystem"] == "R" and r["runtime"] and r["installer"] == "unresolved" for r in rows),
                          "R_unresolved_pending": sum(r["ecosystem"] == "R" and r["pending"] and r["installer"] == "unresolved" for r in rows),
                          "node_direct": len(node_rows), "node_locked_entries": len(data["packages"]) - 1},
               "inputs_sha256": dict(sorted(inputs.items())), "version_policy": "Repository snapshot and observed versions are not a solved environment lock. SCP legacy, ML/UI and scop environments must remain separate."}
    summary["generated_on"] = datetime.now(timezone(timedelta(hours=8))).date().isoformat()
    summary["artifacts_sha256"] = {
        p.relative_to(out).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(out.rglob("*")) if p.is_file() and p.name != "manifest.json"
    }
    (out / "manifest.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary["counts"], ensure_ascii=False))
    return summary


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    export(parser.parse_args().root.resolve())
