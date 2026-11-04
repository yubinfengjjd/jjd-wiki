"""Adopt six independently reviewed receipts without save/commit or runtime edits."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys

from public_python_replay import sha256, write_json


def protected_blocks(content: bytes, kind: str):
    return re.findall(rb"<!-- " + kind.encode("ascii") + rb":start -->.*?<!-- " + kind.encode("ascii") + rb":end -->", content, flags=re.S)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", type=Path, required=True)
    parser.add_argument("--dev", type=Path, required=True)
    args = parser.parse_args()
    sys.path.insert(0, str(args.dev / "staged/research-wiki"))
    from rwiki.pages import read_page
    from rwiki.method_implementations import implementation_status
    from rwiki.runtime_contract import _evidence, closure_hash
    base = Path(__file__).resolve().parent
    index = json.loads((base / "receipt-candidates/index.json").read_text(encoding="utf-8"))
    candidates = index["candidates"]
    if len(candidates) != 6:
        raise ValueError("Expected the six independently reviewed public-case candidates")
    methods = args.vault / "知识库/methods"
    target_methods = sorted({row["method"] for row in candidates})
    target_keys = {(row["method"], row["implementation"]) for row in candidates}
    adopted_at = datetime.now(timezone.utc).isoformat()
    review = {"agent_task": "migration_spec_review", "verdict": "PASS",
              "source": "Independent review final report, explicitly supplied by the primary agent in the adoption instruction",
              "authorization": "Primary agent authorized formal adoption of these six groups after independent review"}

    def statuses():
        result = {}
        for page in sorted(methods.glob("*.md")):
            for status in implementation_status(page):
                result[page.stem + ":" + status["id"]] = status
        return result

    before = statuses()
    original_pages = {method: (methods / (method + ".md")).read_bytes() for method in target_methods}
    original_meta = {method: read_page(methods / (method + ".md"))[0] for method in target_methods}
    runtimes = {method: sha256(methods / method / "runtime.json") for method in target_methods}
    old_evidence = {str(path.relative_to(methods)).replace("\\", "/"): sha256(path)
                    for method in target_methods for path in (methods / method / "verification").rglob("*") if path.is_file()}
    candidate_bytes = {name: sha256(base / "receipt-candidates" / name) for row in candidates
                       for name in (row["algorithm"], row["portability"], row["comparison"])}
    writes = []
    for row in candidates:
        asset = methods / row["method"]
        for field in ("algorithm", "portability", "comparison"):
            source = base / "receipt-candidates" / row[field]
            destination = asset / "verification" / row[field]
            if destination.exists():
                raise ValueError(f"Refusing to overwrite existing evidence: {destination}")
            receipt = json.loads(source.read_text(encoding="utf-8"))
            if receipt.get("state") != "passed" or receipt.get("implementation") != row["implementation"]:
                raise ValueError("Candidate does not bind the actual reviewed branch")
            if field != "comparison":
                if not all(sha256(asset / name) == digest for name, digest in receipt["files"].items()):
                    raise ValueError("Current code no longer matches the executed bytes")
            receipt.update(promotion="adopted", adopted_at=adopted_at, independent_review=review,
                           source_candidate_sha256=candidate_bytes[row[field]])
            writes.append((destination, receipt))
    planned_pages = {}
    for method in target_methods:
        original = original_pages[method].decode("utf-8")
        newline = "\r\n" if "\r\n" in original else "\n"
        front = re.match(r"\A---\r?\n.*?\r?\n---\r?\n", original, flags=re.S)
        if not front:
            raise ValueError("Frontmatter boundary not found")
        changed_front = front.group(0)
        selected = [row for row in candidates if row["method"] == method]
        for row in selected:
            pattern = re.compile(r"(^- id: " + re.escape(row["implementation"]) + r"\r?\n)(.*?)(?=^- id: |\Z)", re.M | re.S)
            match = pattern.search(changed_front)
            if not match:
                raise ValueError("Target implementation stanza not found")
            stanza, count = re.subn(r"(?m)^(  verification: )[^\r\n]+", lambda match: match.group(1) + "verification/" + row["algorithm"], match.group(0))
            if count != 1:
                raise ValueError("Expected exactly one algorithm verification pointer per target stanza")
            changed_front = changed_front[:match.start()] + stanza + changed_front[match.end():]
        body = original[front.end():]
        if "## 公开数据功能补充验证（2026-11-04）" in body:
            raise ValueError("Adoption section already present")
        if method == "local-omics-analysis-guide":
            lines = ["## 公开数据功能补充验证（2026-11-04）", "",
                     "经独立审查 migration_spec_review 最终 PASS 后，当前五个 Python 评价分支的算法收据指针采用公开乳腺癌软件功能用例。真实 569 例按 seed 11 分层切分为训练 426 例、留出 143 例；仅训练集标准化并拟合 LogisticRegression(max_iter=2000)。保留原标签 0=malignant、1=benign，正类为 benign；留出评价固定阈值 0.5，Youden 只测试训练概率，bootstrap 保留 n_boot=1000、seed=42。五个原始函数 AST、原版数值结果与独立闭包新进程调用一致，输入、模型与代码哈希未变。", "",
                     "该公开用例不替代旧 UC/哮喘私有课题联调，不授予完整 stacking 流程或临床有效性结论；全部旧收据继续保留。runtime.json 保持原字节，因此其默认独立性 evidence.portability 仍指向既有 20261102b 证据。新公开用例的独立性收据作为补充链接如下，不替换或冒用旧默认指针。", ""]
        else:
            lines = ["## 公开数据功能补充验证（2026-11-04）", "",
                     "经独立审查 migration_spec_review 最终 PASS 后，py-roc-render 当前算法收据采用已批准的公开乳腺癌软件功能用例。消费同一已拟合模型的预计算训练/留出 FPR、TPR 与 AUC，明确正类为 benign；不在绘图入口拟合、猜标签或反转方向。原生绘图 helper 与构图片段、提取版曲线数据、RGBA 及 PNG 完全一致，实际成图已检查；保留原 inset_axes/tight_layout 提示。", "",
                     "本用例不替代旧 UC/哮喘私有输入的联调，也不将训练曲线作为独立队列或临床验收。全部旧收据保留；runtime.json 保持原字节，其默认独立性 evidence.portability 继续使用既有 20261102b 证据。下列新公开补充独立性收据单独链接，不改写默认指针。", ""]
        for row in selected:
            lines.append("- `" + row["implementation"] + "`：[公开用例补充独立性收据](" + method + "/verification/" + row["portability"] + ")；[实际原版对照](" + method + "/verification/" + row["comparison"] + ")。")
        lines.extend(["", "该补充验证只覆盖上述具体函数、真实公开输入及记录环境；其余分支状态不因本轮采用而提升。", "", ""])
        marker = "<!-- user:start -->"
        if body.count(marker) != 1:
            raise ValueError("Expected one protected author block")
        body = body.replace(marker, newline.join(lines) + marker, 1)
        planned_pages[method] = (changed_front + body).encode("utf-8")
        for kind in ("user", "facts"):
            if protected_blocks(planned_pages[method], kind) != protected_blocks(original_pages[method], kind):
                raise AssertionError("Protected author/generated block changed")
    before_path = base / "formal-adoption-before-20261104.json"
    if before_path.exists():
        raise ValueError("Baseline already exists; refuse an ambiguous repeat adoption")
    write_json(before_path, {"captured_at": adopted_at, "review": review, "official_statuses": before,
                             "runtime_sha256": runtimes, "old_evidence_sha256": old_evidence,
                             "candidate_sha256": candidate_bytes,
                             "page_sha256": {method: sha256(methods / (method + ".md")) for method in target_methods}})
    for destination, receipt in writes:
        write_json(destination, receipt)
    for method, content in planned_pages.items():
        page = methods / (method + ".md")
        if page.read_bytes() != original_pages[method]:
            raise RuntimeError("Concurrent page edit detected; refusing to overwrite it")
        page.write_bytes(content)
    after = statuses()
    non_target_changes = [key for key in before if tuple(key.split(":", 1)) not in target_keys and before[key] != after.get(key)]
    if non_target_changes or set(before) != set(after):
        raise AssertionError("Non-target official implementation status changed: " + repr(non_target_changes))
    supplements = []
    for row in candidates:
        key = row["method"] + ":" + row["implementation"]
        if after[key]["state"] != "verified":
            raise AssertionError("Adopted algorithm pointer did not parse as verified: " + key)
        asset = methods / row["method"]
        runtime = json.loads((asset / "runtime.json").read_text(encoding="utf-8"))
        branch = next(item for item in runtime["implementations"] if item["id"] == row["implementation"])
        supplemental_branch = {**branch, "evidence": {"portability": "verification/" + row["portability"]}}
        parsed = _evidence(asset, supplemental_branch, closure_hash(asset, branch))
        if parsed["state"] != "verified" or parsed["issues"]:
            raise AssertionError("Supplemental portability receipt failed official parser: " + repr(parsed))
        if before[key]["runtime"] != after[key]["runtime"]:
            raise AssertionError("Default runtime/portability facts changed for target branch")
        supplements.append({"method": row["method"], "implementation": row["implementation"],
                            "algorithm_state": after[key]["state"], "supplemental_portability": parsed,
                            "default_runtime_facts_unchanged": True})
    for method in target_methods:
        if sha256(methods / method / "runtime.json") != runtimes[method]:
            raise AssertionError("Runtime bytes changed")
        current_meta = read_page(methods / (method + ".md"))[0]
        expected_meta = original_meta[method]
        for item in expected_meta["implementations"]:
            row = next((row for row in candidates if row["method"] == method and row["implementation"] == item["id"]), None)
            if row:
                item["verification"] = "verification/" + row["algorithm"]
        if current_meta != expected_meta:
            raise AssertionError("Unexpected frontmatter change")
    if not all(sha256(methods / relative) == digest for relative, digest in old_evidence.items()):
        raise AssertionError("Old evidence changed")
    if not all(sha256(base / "receipt-candidates" / name) == digest for name, digest in candidate_bytes.items()):
        raise AssertionError("Original candidate changed")
    write_json(base / "formal-adoption-after-20261104.json", {"adopted_at": adopted_at, "independent_review": review,
               "adopted_groups": supplements, "official_implementation_count": len(after),
               "non_target_implementations_compared": len(before) - len(target_keys), "non_target_status_changes": non_target_changes,
               "all_status_labels_unchanged": all(before[key]["state"] == after[key]["state"] for key in before),
               "runtime_bytes_unchanged": True, "old_evidence_unchanged": True, "original_candidates_unchanged": True,
               "protected_blocks_unchanged": True, "only_six_frontmatter_verification_pointers_changed": True,
               "new_verification_files": [str(path.relative_to(methods)).replace("\\", "/") for path, _ in writes],
               "save_or_commit": "not_run; primary agent owns final save/commit", "official_statuses": after})
    print(json.dumps({"adopted_groups": 6, "new_verification_files": len(writes), "non_target_status_changes": non_target_changes,
                      "runtime_bytes_unchanged": True, "save_or_commit": "not_run"}))


if __name__ == "__main__":
    main()
