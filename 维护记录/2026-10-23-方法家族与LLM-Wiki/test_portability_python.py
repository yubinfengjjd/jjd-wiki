"""Run the Python checks against code copied outside the wiki tree."""
from pathlib import Path
import shutil
import subprocess
import sys

wiki = Path(sys.argv[1])
tmp = Path(sys.argv[2])
tmp.mkdir(parents=True, exist_ok=True)
for family in ("shap-explanation", "regression-resampling-evaluation"):
    source = wiki / "methods" / family / "code"
    target = tmp / family / "code"
    if target.exists():
        shutil.rmtree(target)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(source, target)
script = Path("E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki/test_scientific_python.py")
run = subprocess.run([sys.executable, "-X", "utf8", str(script), str(tmp)],
                     text=True, capture_output=True, encoding="utf-8")
print(run.stdout, end="")
if run.returncode:
    print(run.stderr, file=sys.stderr)
    raise SystemExit(run.returncode)
print("PASS: SHAP and regression run from copied code outside the wiki")
