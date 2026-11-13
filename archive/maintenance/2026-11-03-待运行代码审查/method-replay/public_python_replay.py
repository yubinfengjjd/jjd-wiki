"""Approved public breast-cancer software replay; never a private-project rerun.

Only the coordinator fits the explicitly approved bounded logistic model.
Reference workers execute AST-selected preserved functions. Production workers
receive only the declared closure, frozen public inputs, and fitted model.
"""
from __future__ import annotations

import argparse
import ast
from datetime import datetime, timezone
import hashlib
import importlib.metadata
import importlib.util
import json
import os
from pathlib import Path
import pickle
import shutil
import subprocess
import sys
import tempfile

CASE_ID = "breast-cancer-public-software-case"
DATA_SHA256 = "ff5fc1f247213db5fd49539610bcd5a98033bbd0307524fde3127251752aa073"
FUNCTIONS = {"py-eval-binary": "eval_binary", "py-compute-specificity": "compute_specificity",
             "py-youden-threshold": "youden_threshold", "py-bootstrap-ci-auc": "bootstrap_ci_auc",
             "py-get-proba": "get_proba"}
METRIC_IMPORTS = "from sklearn.metrics import roc_auc_score, roc_curve, average_precision_score, accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, brier_score_loss"


def sha256(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def write_json(path, value):
    Path(path).write_text(json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n", encoding="utf-8")


def timestamp():
    return datetime.now(timezone.utc).isoformat()


def environment():
    versions = {}
    for name in ("numpy", "pandas", "scikit-learn", "scipy", "matplotlib", "joblib", "pillow"):
        try:
            versions[name] = importlib.metadata.version(name)
        except importlib.metadata.PackageNotFoundError:
            continue
    return {"Python": sys.version.split()[0], "platform": sys.platform, "packages": versions,
            "automatic_installation": False, "MPLBACKEND": os.environ.get("MPLBACKEND")}


def load_module(path):
    spec = importlib.util.spec_from_file_location("case_module", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def array_hash(value):
    import numpy as np
    value = np.asarray(value)
    digest = hashlib.sha256(str((value.dtype.str, value.shape)).encode("ascii"))
    digest.update(np.ascontiguousarray(value).tobytes())
    return digest.hexdigest()


def object_hash(value):
    return hashlib.sha256(pickle.dumps(value, protocol=5)).hexdigest()


def function_nodes(path, names):
    tree = ast.parse(path.read_text(encoding="utf-8-sig"))
    # Last top-level definition is Python's actual binding for duplicate names.
    found = {node.name: node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name in names}
    if set(found) != set(names):
        raise ValueError(f"Missing original functions: {set(names) - set(found)}")
    return found


def ast_hash(node):
    return hashlib.sha256(ast.dump(node, include_attributes=False).encode("utf-8")).hexdigest()


def extract_metric_reference(original, extracted, output):
    original_nodes = function_nodes(original, FUNCTIONS.values())
    extracted_nodes = function_nodes(extracted, FUNCTIONS.values())
    comparisons = {name: {"original_ast_sha256": ast_hash(original_nodes[name]),
                          "extracted_ast_sha256": ast_hash(extracted_nodes[name]),
                          "ast_equal": ast_hash(original_nodes[name]) == ast_hash(extracted_nodes[name]),
                          "original_line": original_nodes[name].lineno}
                   for name in FUNCTIONS.values()}
    if not all(row["ast_equal"] for row in comparisons.values()):
        raise AssertionError("Original and extracted evaluation function AST differs; investigate without changing algorithm")
    header = "from __future__ import annotations\nfrom typing import Dict, Tuple\nimport numpy as np\n" + METRIC_IMPORTS + "\n"
    output.write_text(header + "\n\n".join(ast.unparse(original_nodes[name]) for name in FUNCTIONS.values()) + "\n", encoding="utf-8")
    return comparisons


def extract_plot_reference(original, extracted, output):
    helpers = function_nodes(original, ("style_axes", "draw_auc_strip"))
    extracted_helpers = function_nodes(extracted, helpers)
    comparison = {name: {"ast_equal": ast_hash(node) == ast_hash(extracted_helpers[name]),
                         "original_ast_sha256": ast_hash(node), "original_line": node.lineno}
                  for name, node in helpers.items()}
    if not all(row["ast_equal"] for row in comparison.values()):
        raise AssertionError("Native plot helper AST differs")
    tree = ast.parse(original.read_text(encoding="utf-8-sig"))
    main = next(node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == "main")
    gene_loop = next(node for node in main.body if isinstance(node, ast.For) and ast.unparse(node.target) == "gene")
    # Retain the original figure, diagonal, labels, helper calls, legend and layout.
    start = next(index for index, node in enumerate(gene_loop.body) if isinstance(node, ast.Assign) and ast.unparse(node.targets[0]) == "(fig, ax)")
    suffix_start = next(index for index, node in enumerate(gene_loop.body) if isinstance(node, ast.Expr) and ast.unparse(node.value).startswith("ax.set_title("))
    suffix_end = next(index for index, node in enumerate(gene_loop.body) if isinstance(node, ast.Expr) and ast.unparse(node.value) == "fig.tight_layout()")
    cohort_loop = next(node for node in gene_loop.body if isinstance(node, ast.For) and ast.unparse(node.target) == "(c_name, c_df)")
    block = next(node for node in cohort_loop.body if isinstance(node, ast.Try))
    native_drawing = [node for node in block.body if
                      (isinstance(node, ast.Assign) and ast.unparse(node.targets[0]) == "color") or
                      (isinstance(node, ast.Expr) and ast.unparse(node.value).startswith("ax.plot("))]
    if len(native_drawing) != 2:
        raise ValueError("Unexpected original ROC drawing structure")
    prefix = gene_loop.body[start:start + 2]
    suffix = gene_loop.body[suffix_start:suffix_end + 1]
    # Parameters replace only original external data/name/color bindings. No ROC
    # estimation, label guessing or score inversion is copied into this renderer.
    body = [ast.parse("COHORT_COLORS = cohort_colors").body[0], ast.parse("gene = case_label").body[0],
            *prefix, ast.For(target=ast.parse("c_name, (fpr, tpr)", mode="eval").body,
                            iter=ast.parse("curves.items()", mode="eval").body, body=native_drawing, orelse=[]),
            *suffix, ast.Return(value=ast.parse("fig, ax", mode="eval").body)]
    function = ast.FunctionDef(name="render_reference", args=ast.parse("def f(curves, aucs, cohort_colors, case_label): pass").body[0].args,
                               body=body, decorator_list=[])
    ast.fix_missing_locations(function)
    header = "from __future__ import annotations\nfrom typing import Dict\nimport matplotlib.pyplot as plt\nimport matplotlib.patches as patches\nfrom mpl_toolkits.axes_grid1.inset_locator import inset_axes\n"
    output.write_text(header + "\n\n".join(ast.unparse(node) for node in [*helpers.values(), function]) + "\n", encoding="utf-8")
    return {"helpers": comparison, "native_drawing_lines": [node.lineno for node in native_drawing],
            "native_prefix_lines": [node.lineno for node in prefix], "native_suffix_lines": [node.lineno for node in suffix],
            "boundary": "Original visual body consumes fixed precomputed curves; source loading, label inference, score inversion and AUC fitting are excluded."}


def eval_result(module, branch, arrays, model):
    import numpy as np
    if branch == "py-get-proba":
        return module.get_proba(model, arrays["X_test"])
    if branch == "py-eval-binary":
        return module.eval_binary(arrays["y_test"], arrays["prob_test"], threshold=0.5)
    if branch == "py-compute-specificity":
        return float(module.compute_specificity(arrays["y_test"], (arrays["prob_test"] >= 0.5).astype(int)))
    if branch == "py-youden-threshold":
        return list(module.youden_threshold(arrays["y_train"], arrays["prob_train"]))
    if branch == "py-bootstrap-ci-auc":
        return list(module.bootstrap_ci_auc(arrays["y_test"], arrays["prob_test"], n_boot=1000, seed=42))
    raise ValueError(f"Unknown approved branch: {branch}")


def plot_result(module, arrays, output, reference):
    import numpy as np
    import matplotlib.pyplot as plt
    curves = {"Train": (arrays["fpr_train"], arrays["tpr_train"]),
              "Held-out": (arrays["fpr_test"], arrays["tpr_test"])}
    aucs = {"Train": float(arrays["auc_train"]), "Held-out": float(arrays["auc_test"])}
    colors = {"Train": "#2874C5", "Held-out": "#d62728"}
    label = CASE_ID + " (positive=benign)"
    if reference:
        fig, ax = module.render_reference(curves, aucs, colors, label)
    else:
        fig, ax = module.render_roc_curves(curves, aucs, colors, "ROC: " + label)
    fig.canvas.draw()
    rgba = np.asarray(fig.canvas.buffer_rgba()).copy()
    np.save(output / "rgba.npy", rgba)
    fig.savefig(output / "plot.png", bbox_inches="tight", dpi=150)
    fig.savefig(output / "plot.pdf", bbox_inches="tight", dpi=150)
    result = {"rgba_sha256": array_hash(rgba), "axes_count": len(fig.axes),
              "line_data": [{"x": np.asarray(line.get_xdata()).tolist(), "y": np.asarray(line.get_ydata()).tolist(),
                             "label": line.get_label(), "color": line.get_color()} for line in ax.lines],
              "auc_text": [text.get_text() for axis in fig.axes for text in axis.texts]}
    plt.close(fig)
    return result


def worker(args):
    import numpy as np
    import joblib
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    arrays = dict(np.load(args.data, allow_pickle=False))
    before_arrays = {key: array_hash(value) for key, value in arrays.items()}
    input_files = {str(path): sha256(path) for path in (args.data, args.module) if path}
    model = joblib.load(args.model) if args.model else None
    before_model = object_hash(model) if model is not None else None
    if args.model:
        input_files[str(args.model)] = sha256(args.model)
    module = load_module(args.module)
    if args.worker == "reference":
        result = {}
        for branch in FUNCTIONS:
            value = eval_result(module, branch, arrays, model)
            if branch == "py-get-proba":
                np.save(output / "get-proba.npy", value)
                result[branch] = {"array_sha256": array_hash(value), "shape": list(value.shape)}
            else:
                result[branch] = value
    elif args.worker == "evaluation":
        value = eval_result(module, args.implementation, arrays, model)
        if args.implementation == "py-get-proba":
            np.save(output / "get-proba.npy", value)
            result = {"array_sha256": array_hash(value), "shape": list(value.shape)}
        else:
            result = value
    else:
        result = plot_result(module, arrays, output, args.worker == "reference-plot")
    checks = {"actual_invocation": True, "input_arrays_unchanged": before_arrays == {key: array_hash(value) for key, value in arrays.items()},
              "model_unchanged": before_model == (object_hash(model) if model is not None else None),
              "input_and_code_files_unchanged": all(sha256(Path(path)) == digest for path, digest in input_files.items())}
    if not all(checks.values()):
        raise AssertionError("Input/model/code changed during actual function call")
    write_json(output / "result.json", {"case_id": CASE_ID, "state": "executed", "implementation": args.implementation,
                                       "result": result, "checks": checks, "array_hashes": before_arrays,
                                       "model_object_sha256": before_model, "input_sha256": input_files,
                                       "environment": environment(), "executed_at": timestamp()})


def launch(argv, cwd, env):
    with (cwd / "stdout.log").open("wb") as stdout, (cwd / "stderr.log").open("wb") as stderr:
        completed = subprocess.run(argv, cwd=cwd, env=env, stdout=stdout, stderr=stderr, timeout=300, check=False)
    if completed.returncode:
        raise RuntimeError(f"Worker exited {completed.returncode}; inspect {cwd / 'stderr.log'}")
    return completed.returncode


def coordinator(args):
    from replay import closure_hashes
    from importlib.resources import files
    import numpy as np
    import joblib
    from sklearn.datasets import load_breast_cancer
    from sklearn.linear_model import LogisticRegression
    from sklearn.metrics import roc_auc_score, roc_curve
    from sklearn.model_selection import train_test_split
    from sklearn.pipeline import make_pipeline
    from sklearn.preprocessing import StandardScaler
    vault = args.vault.resolve()
    if args.run_root.resolve() == vault or vault in args.run_root.resolve().parents:
        raise ValueError("Public data/model execution directory must be outside the repository")
    if not args.run_root.is_dir():
        raise ValueError("Create the external --run-root explicitly before invoking this driver")
    if not args.approved_public_case:
        raise ValueError("This bounded fit requires the approved-public-case flag")
    root = Path(tempfile.mkdtemp(prefix=CASE_ID + "-", dir=args.run_root.resolve()))
    source_driver = Path(__file__).resolve()
    external_driver = root / "public_python_replay.py"
    shutil.copy2(source_driver, external_driver)
    # Worker mode never imports discovery/replay modules, and cannot access the
    # source repository via its argv. Keep orchestration imports lazy at the top.
    dataset = load_breast_cancer()
    # Recent sklearn returns a resource basename in dataset.filename.
    csv_path = Path(str(files("sklearn.datasets").joinpath("data/breast_cancer.csv")))
    if sha256(csv_path) != DATA_SHA256:
        raise ValueError("Bundled public dataset bytes differ from the approved inspected fixture")
    np.testing.assert_array_equal(dataset.target_names, ["malignant", "benign"])
    indices = np.arange(len(dataset.target))
    train, test = train_test_split(indices, test_size=0.25, stratify=dataset.target, random_state=11)
    assert not set(train) & set(test) and len(set(train) | set(test)) == 569
    model = make_pipeline(StandardScaler(), LogisticRegression(max_iter=2000, random_state=11))
    model.fit(dataset.data[train], dataset.target[train])
    np.testing.assert_array_equal(model.classes_, [0, 1])
    np.testing.assert_allclose(model[0].mean_, dataset.data[train].mean(axis=0), rtol=0, atol=0)
    prob_train = model.predict_proba(dataset.data[train])[:, 1]
    prob_test = model.predict_proba(dataset.data[test])[:, 1]
    fpr_train, tpr_train, _ = roc_curve(dataset.target[train], prob_train)
    fpr_test, tpr_test, _ = roc_curve(dataset.target[test], prob_test)
    inputs = root / "inputs.npz"
    np.savez_compressed(inputs, X_train=dataset.data[train], X_test=dataset.data[test], y_train=dataset.target[train],
                        y_test=dataset.target[test], train_indices=train, test_indices=test, feature_names=dataset.feature_names,
                        prob_train=prob_train, prob_test=prob_test, fpr_train=fpr_train, tpr_train=tpr_train,
                        fpr_test=fpr_test, tpr_test=tpr_test, auc_train=roc_auc_score(dataset.target[train], prob_train),
                        auc_test=roc_auc_score(dataset.target[test], prob_test))
    model_file = root / "model.joblib"
    joblib.dump(model, model_file, compress=3)
    input_hashes = {"inputs.npz": sha256(inputs), "model.joblib": sha256(model_file), "bundled_breast_cancer.csv": sha256(csv_path)}
    methods = vault / "知识库/methods"
    analysis = methods / "local-omics-analysis-guide"
    visual = methods / "local-omics-visualization-guide"
    original_metrics = analysis / "code/stacking_original.py"
    original_plot = visual / "source/d421312f0c2a8f10c25837c95ecf085235d036db2d200dab5b4e8e32a8793fe0.py"
    original_hashes = {original_metrics: sha256(original_metrics), original_plot: sha256(original_plot)}
    original_hashes.update({path: sha256(path) for directory in (analysis / "code", visual / "code") for path in directory.rglob("*") if path.is_file() and "__pycache__" not in path.parts})
    metric_reference = root / "reference_functions.py"
    plot_reference = root / "reference_plot.py"
    ast_checks = extract_metric_reference(original_metrics, analysis / "code/binary_evaluation.py", metric_reference)
    plot_ast_checks = extract_plot_reference(original_plot, visual / "code/roc_render.py", plot_reference)
    write_json(root / "source-comparison.json", {"functions": ast_checks, "plot": plot_ast_checks,
                                               "original_metrics_sha256": original_hashes[original_metrics],
                                               "original_plot_sha256": original_hashes[original_plot]})
    env = os.environ.copy()
    env.update(PYTHONDONTWRITEBYTECODE="1", MPLBACKEND="Agg", MPLCONFIGDIR=str(root / "mpl-config"),
               OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1", PYTHONHASHSEED="11",
               TEMP=str(root), TMP=str(root))
    env.pop("PYTHONPATH", None)
    ref_dir = root / "reference-evaluation"
    ref_dir.mkdir()
    prefix = [sys.executable, "-B", "-X", "utf8", str(external_driver)]
    ref_argv = [*prefix, "--worker", "reference", "--module", str(metric_reference), "--data", str(inputs), "--model", str(model_file), "--output", str(ref_dir)]
    launch(ref_argv, ref_dir, env)
    expected = json.loads((ref_dir / "result.json").read_text(encoding="utf-8"))
    plot_ref_dir = root / "reference-plot"
    plot_ref_dir.mkdir()
    plot_ref_argv = [*prefix, "--worker", "reference-plot", "--module", str(plot_reference), "--data", str(inputs), "--output", str(plot_ref_dir)]
    launch(plot_ref_argv, plot_ref_dir, env)
    plot_expected = json.loads((plot_ref_dir / "result.json").read_text(encoding="utf-8"))
    results = []
    for branch in [*FUNCTIONS, "py-roc-render"]:
        asset = visual if branch == "py-roc-render" else analysis
        manifest_path = asset / "runtime.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        runtime = next(row for row in manifest["implementations"] if row["id"] == branch)
        closure = closure_hashes(asset, runtime)
        isolated = root / ("isolated-" + branch)
        isolated.mkdir()
        for member in closure:
            destination = isolated / member
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(asset / member, destination)
        shutil.copy2(inputs, isolated / "inputs.npz")
        if branch != "py-roc-render":
            shutil.copy2(model_file, isolated / "model.joblib")
        worker_kind = "plot" if branch == "py-roc-render" else "evaluation"
        argv = [*prefix, "--worker", worker_kind, "--implementation", branch, "--module", str(isolated / runtime["entry"]),
                "--data", str(isolated / "inputs.npz"), "--output", str(isolated)]
        if branch != "py-roc-render":
            argv.extend(["--model", str(isolated / "model.joblib")])
        launch(argv, isolated, env)
        actual = json.loads((isolated / "result.json").read_text(encoding="utf-8"))
        reference_result = plot_expected["result"] if branch == "py-roc-render" else expected["result"][branch]
        comparison = {"exact_result_equal": actual["result"] == reference_result,
                      "input_model_code_preserved": all(actual["checks"].values()),
                      "copied_closure_preserved": all(sha256(isolated / member) == digest for member, digest in closure.items())}
        if branch == "py-roc-render":
            np.testing.assert_array_equal(np.load(plot_ref_dir / "rgba.npy"), np.load(isolated / "rgba.npy"))
            comparison["rendered_rgba_exact_equal"] = True
            comparison["png_file_exact_equal"] = sha256(plot_ref_dir / "plot.png") == sha256(isolated / "plot.png")
        if branch == "py-get-proba":
            np.testing.assert_array_equal(np.load(ref_dir / "get-proba.npy"), np.load(isolated / "get-proba.npy"))
            comparison["positive_probability_arrays_exact_equal"] = True
        if not all(comparison.values()):
            write_json(isolated / "comparison.json", comparison)
            raise AssertionError(f"Original/extracted public case differs for {branch}; algorithms left unchanged")
        write_json(isolated / "comparison.json", {"case_id": CASE_ID, "implementation": branch, "state": "passed", "checks": comparison,
                                                   "original_reference": reference_result, "isolated_result": actual["result"]})
        full_code = {str(path.relative_to(asset)).replace("\\", "/"): digest for path, digest in original_hashes.items() if asset in path.parents and "code" in path.relative_to(asset).parts}
        receipt = {"schema_version": 1, "kind": "public-software-method-replay-audit", "case_id": CASE_ID,
                   "method": asset.name, "implementation": branch, "state": "passed", "promotion": "pending primary review; no Wiki receipt/status modified",
                   "scope": "Approved real public breast-cancer bounded fit, original/native visual-body comparison and new-process declared-closure replay only. Does not reproduce private UC/asthma cases or validate clinical performance.",
                   "command": argv, "reference_command": plot_ref_argv if branch == "py-roc-render" else ref_argv,
                   "case": {"seed": 11, "test_fraction": 0.25, "stratified": True, "train_count": len(train), "test_count": len(test),
                            "positive_class": "1=benign", "threshold": 0.5, "youden_input": "training probabilities only",
                            "bootstrap_n": 1000, "bootstrap_seed": 42, "model": "train-only StandardScaler + LogisticRegression(max_iter=2000, random_state=11)"},
                   "checks": comparison, "environment": actual["environment"], "files": full_code,
                   "runtime_manifest_sha256": sha256(manifest_path), "runtime_closure_files": closure,
                   "input_sha256": input_hashes, "model_object_sha256": actual["model_object_sha256"],
                   "output_sha256": {path.name: sha256(path) for path in isolated.iterdir() if path.is_file() and path.name not in {"inputs.npz", "model.joblib"}},
                   "comparison": "comparison.json", "executed_at": timestamp(), "visual_review": "pending" if branch == "py-roc-render" else "not_applicable"}
        write_json(isolated / "audit.json", receipt)
        results.append({"method": asset.name, "implementation": branch, "state": "passed", "audit": str(isolated / "audit.json"),
                        "comparison_sha256": sha256(isolated / "comparison.json")})
    if not all(sha256(path) == digest for path, digest in original_hashes.items()):
        raise AssertionError("Original source/code tree changed during replay")
    if sha256(inputs) != input_hashes["inputs.npz"] or sha256(model_file) != input_hashes["model.joblib"]:
        raise AssertionError("Prepared public inputs/model changed")
    summary = {"schema_version": 1, "case_id": CASE_ID, "state": "passed", "scope": "six individually called public software branches only",
               "run_root": str(root), "environment": environment(), "source_and_input_files_unchanged": True,
               "input_sha256": input_hashes, "source_ast_comparison": ast_checks, "plot_source_comparison": plot_ast_checks,
               "results": results, "executed_at": timestamp()}
    write_json(root / "summary.json", summary)
    print(json.dumps(summary, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", type=Path)
    parser.add_argument("--run-root", type=Path)
    parser.add_argument("--approved-public-case", action="store_true")
    parser.add_argument("--worker", choices=("reference", "evaluation", "reference-plot", "plot"))
    parser.add_argument("--implementation")
    parser.add_argument("--module", type=Path)
    parser.add_argument("--data", type=Path)
    parser.add_argument("--model", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.worker:
        worker(args)
    else:
        coordinator(args)


if __name__ == "__main__":
    main()
