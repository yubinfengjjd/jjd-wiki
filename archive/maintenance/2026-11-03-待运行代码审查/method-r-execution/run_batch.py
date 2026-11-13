"""Execute reviewed public R cases without modifying source assets or receipts."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import time


VAULT = Path(__file__).resolve().parents[3]
ENV_ROOT = VAULT.parent / "research-wiki-env"
DEV = VAULT.parent / "jjd-wiki-dev"
SUPPORT = Path(__file__).resolve().parent.parent / "method-replay"
OUTPUT = Path(__file__).resolve().parent
MAPPING = SUPPORT / "replay-map.json"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sanitize(value):
    if isinstance(value, dict):
        return {key: sanitize(item) for key, item in value.items()}
    if isinstance(value, list):
        return [sanitize(item) for item in value]
    if isinstance(value, str):
        for path, replacement in ((ENV_ROOT, "<ENV_ROOT>"), (VAULT, "<VAULT>"),
                                  (DEV, "<DEV>"), (Path.home(), "<HOME>")):
            for spelling in (str(path), path.as_posix()):
                for escaped in (spelling, spelling.replace("\\", "\\\\"),
                                spelling.replace("\\", "\\\\\\\\")):
                    value = value.replace(escaped, replacement)
        return value
    return value


def write_json(path, value):
    path.write_text(json.dumps(sanitize(value), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    dependency_log = ENV_ROOT / "dependency-reports/scDblFinder-retry.log"
    if dependency_log.read_text(encoding="utf-8", errors="replace").strip().splitlines()[-1] != "scDblFinder namespace loaded":
        raise RuntimeError("scDblFinder namespace completion marker is missing")
    library = ENV_ROOT / "R-lib-4.5-3.21"
    locks = list(library.glob("00LOCK*"))
    if locks:
        raise RuntimeError("Dependency installation locks remain: " + ", ".join(path.name for path in locks))
    rows = [row for row in json.loads(MAPPING.read_text(encoding="utf-8"))["implementations"]
            if row.get("driver") and row["driver"]["kind"] != "recorded_velocity"]
    if len(rows) != 20:
        raise RuntimeError(f"Expected 20 reviewed candidates, found {len(rows)}")
    external_root = ENV_ROOT / "method-runs"
    external_root.mkdir(exist_ok=True)
    batch_root = Path(tempfile.mkdtemp(prefix="public-r-20261104-", dir=external_root))
    evidence_root = OUTPUT / batch_root.name
    evidence_root.mkdir()
    results = []
    batch = {"started_at": datetime.now(timezone.utc).isoformat(), "mapping_sha256": digest(MAPPING),
             "runner_sha256": digest(Path(__file__)), "batch_root": str(batch_root),
             "environment_restored": True, "algorithm_verification_state": "not_run", "results": results}
    for index, row in enumerate(rows, 1):
        method, implementation = row["method"], row["implementation"]
        timeout = 600 if method in {"cell-quality-control", "differential-expression"} else 300
        argv = [sys.executable, "-B", "-X", "utf8", str(SUPPORT / "replay.py"),
                "--vault", str(VAULT), "--dev", str(DEV), "--mapping", str(MAPPING),
                "--method", method, "--implementation", implementation,
                "--fixture", str(ENV_ROOT / "public-data/pancreas_sub.rda"),
                "--run-root", str(batch_root), "--rscript", str(ENV_ROOT / "R-4.5.0/bin/x64/Rscript.exe"),
                "--r-libs", str(library), "--timeout", str(timeout), "--environment-restored"]
        print(f"START {index}/20 {method}/{implementation} timeout={timeout}s", flush=True)
        started = time.monotonic()
        process = subprocess.run(argv, cwd=VAULT, capture_output=True, text=True, encoding="utf-8", errors="replace")
        result = {"method": method, "implementation": implementation, "driver": row["driver"],
                  "timeout_seconds_per_child": timeout, "duration_seconds": round(time.monotonic() - started, 2),
                  "replay_returncode": process.returncode, "execution_state": "not_run",
                  "algorithm_verification_state": "not_run"}
        raw = batch_root / f"{index:02d}-{implementation}-orchestration.json"
        raw.write_text(json.dumps({"argv": argv, "stdout": process.stdout, "stderr": process.stderr},
                                  ensure_ascii=False, indent=2), encoding="utf-8")
        try:
            reply = json.loads(process.stdout.strip().splitlines()[-1])
            receipt = Path(reply["receipt"])
            audit = json.loads(receipt.read_text(encoding="utf-8"))
            result.update({key: audit.get(key) for key in ("execution_state", "returncode", "error", "checks")})
            result["external_run_directory"] = str(receipt.parent)
            evidence = {"execution_audit": audit, "log_tails": {}}
            for name in ("stdout.log", "stderr.log", "result.json"):
                target = receipt.parent / name
                if target.is_file():
                    evidence["log_tails"][name] = "\n".join(target.read_text(encoding="utf-8", errors="replace").splitlines()[-60:])
            write_json(evidence_root / f"{index:02d}-{implementation}.json", evidence)
        except (ValueError, KeyError, IndexError, OSError) as error:
            result["error"] = f"Replay orchestration failed: {error}; {process.stderr[-4000:]}"
            write_json(evidence_root / f"{index:02d}-{implementation}.json", {"result": result,
                       "orchestration_stdout": process.stdout, "orchestration_stderr": process.stderr})
        results.append(result)
        batch["completed_at"] = datetime.now(timezone.utc).isoformat()
        batch["counts"] = {"completed": len(results), "executed": sum(item["execution_state"] == "executed" for item in results),
                           "not_run": sum(item["execution_state"] != "executed" for item in results)}
        write_json(evidence_root / "summary.json", batch)
        print(f"DONE {index}/20 {method}/{implementation} state={result['execution_state']} duration={result['duration_seconds']}s error={sanitize(result.get('error'))}", flush=True)
    print(f"BATCH {evidence_root}", flush=True)


if __name__ == "__main__":
    main()
