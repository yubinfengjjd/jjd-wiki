"""Orchestration tests only; none count as a scientific method execution."""
from pathlib import Path
import json
import unittest

from discover import AUTHOR_DEFERRED, PANCREAS_SHA256, PORTABLE_CASES, SYNTHETIC, classify, tokens
from replay import assess, closure_hashes, safe_member


class ReplayTests(unittest.TestCase):
    def test_manifest_rejects_path_escape(self):
        asset = Path(__file__).resolve().parent
        for path in ("../discover.py", "code/../discover.py", "/discover.py", "code\\discover.py", ".hidden.py"):
            with self.subTest(path=path), self.assertRaises(ValueError):
                safe_member(asset, path)

    def test_manifest_rejects_duplicate_or_missing_entry(self):
        asset = Path(__file__).resolve().parent
        for manifest in ({"entry": "driver.R", "files": ["discover.py"]},
                         {"entry": "driver.R", "files": ["driver.R", "driver.R"]}):
            with self.subTest(manifest=manifest), self.assertRaises(ValueError):
                closure_hashes(asset, manifest)

    def test_zero_exit_does_not_grant_execution_or_algorithm_pass(self):
        result = assess(0, {}, True)
        self.assertEqual(result["execution_state"], "not_run")
        self.assertEqual(result["algorithm_verification_state"], "not_run")

    def test_empty_r_failure_checks_still_produce_a_not_run_receipt(self):
        child = {"state": "not_run", "checks": [], "error": "Missing R dependency: scrapper"}
        result = assess(1, child, True)
        self.assertEqual(result["execution_state"], "not_run")
        self.assertEqual(result["algorithm_verification_state"], "not_run")
        self.assertEqual(result["checks"], {"source_and_input_files_unchanged": True})

    def test_actual_checks_required_and_file_mutation_rejected(self):
        child = {"state": "executed", "checks": {"actual_invocation": True,
                 "input_object_unchanged": True, "output_assertions": True}}
        self.assertEqual(assess(0, child, True)["execution_state"], "executed")
        self.assertEqual(assess(0, child, False)["execution_state"], "not_run")
        self.assertEqual(assess(1, child, True)["execution_state"], "not_run")
        self.assertEqual(assess(0, child, True)["algorithm_verification_state"], "not_run")

    def test_synthetic_and_unjustified_cases_never_allowlisted(self):
        for implementation in SYNTHETIC:
            self.assertNotIn(implementation, {key[1] for key in PORTABLE_CASES})
            category, blockers, driver = classify("test", implementation, {}, {})
            self.assertEqual(category, "author_deferred" if implementation in AUTHOR_DEFERRED else "scientific_input_or_choice_required")
            self.assertTrue(blockers)
            self.assertIsNone(driver)

    def test_plot_no_eval_or_derived_tokens(self):
        for token in ("@eval:greal$node", "@traj", "@meta_synth"):
            _, _, driver = classify("scp-viz-test", "test", {"case": {"args": {"srt": token}}}, {})
            self.assertIsNone(driver)
        _, blockers, driver = classify("scp-viz-test", "test", {"case": {"args": {"srt": "@pancreas_sub"}}}, {})
        self.assertEqual(blockers, [])
        self.assertEqual(driver["kind"], "recorded_plot")

    def test_real_velocity_input_is_not_misclassified_as_missing(self):
        category, blockers, driver = classify("rna-velocity", "scp-scvelo", {}, {})
        self.assertEqual(category, "public_input_backend_required")
        self.assertEqual(driver["kind"], "recorded_velocity")
        self.assertEqual(driver["case"]["parameters"]["assay_layers"], ["spliced", "unspliced"])
        self.assertTrue(any("SCP_analysis" in blocker for blocker in blockers))

    def test_mapping_covers_inventory_and_preserves_no_run_state(self):
        mapping = json.loads(Path(__file__).with_name("replay-map.json").read_text(encoding="utf-8"))
        self.assertEqual(len(mapping["pages"]), 43)
        self.assertEqual(len(mapping["implementations"]), 85)
        self.assertTrue(all(row["historical_case_replay_state"] == "not_run" for row in mapping["implementations"]))
        for row in mapping["implementations"]:
            self.assertEqual(row["current_execution_state"], "executed_public_case" if row.get("additional_public_case") else "not_run")
        self.assertEqual(mapping["public_fixture"]["sha256"], PANCREAS_SHA256)
        for row in mapping["implementations"]:
            driver = row.get("driver")
            if driver and driver["kind"] == "recorded_plot":
                self.assertEqual(tokens(driver["case"]["args"]), {"@pancreas_sub"})


if __name__ == "__main__":
    unittest.main(verbosity=2)
