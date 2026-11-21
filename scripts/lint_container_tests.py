#!/usr/bin/env python3
"""Validate every apps/*/container-test.yaml and lint it for weak tests.

Schema violations are always errors. The other rules already have many findings, so they are
ratcheted: the findings that exist today are listed in .github/lint/container-test-baseline.json
and only a *new* finding fails. Fixing a finding makes its baseline entry stale (reported as a
notice); refresh the file with `--update-baseline`.

Rules (finding key format):
  port-no-probe:<app>:<port>   settings.yaml declares a tcp port that no http/tcp probe covers
  trivial-only:<app>           no http/tcp/healthCommands probe and no runner with expectedOutput
  deps-not-narrowed:<app>      settings.yaml has hard dependencies but the test has no "# narrowed:" comment

The schema in .github/schemas/container-test.schema.json is a copy of
https://github.com/trueforge-org/forgetool/blob/main/pkg/containers/test/container-test.schema.json.
Requires: PyYAML and jsonschema.
"""
import argparse
import glob
import json
import os
import sys

import jsonschema
import yaml

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SCHEMA = os.path.join(ROOT, ".github", "schemas", "container-test.schema.json")
BASELINE = os.path.join(ROOT, ".github", "lint", "container-test-baseline.json")


def load_yaml(path):
    with open(path, encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def collect():
    """Return (schema errors, set of finding keys)."""
    with open(SCHEMA, encoding="utf-8") as handle:
        validator = jsonschema.Draft202012Validator(json.load(handle))

    errors = []
    keys = set()
    for path in sorted(glob.glob(os.path.join(ROOT, "apps", "*", "container-test.yaml"))):
        app = os.path.basename(os.path.dirname(path))
        rel = os.path.relpath(path, ROOT)
        test = load_yaml(path)
        with open(path, encoding="utf-8") as handle:
            text = handle.read()

        for error in validator.iter_errors(test):
            where = "/".join(str(part) for part in error.absolute_path) or "<root>"
            errors.append(f"{rel}: {where}: {error.message[:160]}")

        settings_path = os.path.join(os.path.dirname(path), "settings.yaml")
        settings = load_yaml(settings_path) if os.path.exists(settings_path) else {}

        probes = (test.get("http") or []) + (test.get("tcp") or [])
        probed_ports = {str(probe.get("port")) for probe in probes}
        has_probe = bool(probes or test.get("healthCommands"))

        for port in settings.get("ports") or []:
            if str(port.get("protocol", "tcp")).lower() == "tcp" and str(port.get("port")) not in probed_ports:
                keys.add(f"port-no-probe:{app}:{port.get('port')}")

        if not has_probe and not any(r.get("expectedOutput") for r in test.get("runners") or []):
            keys.add(f"trivial-only:{app}")

        if (settings.get("dependencies") or []) and "narrowed:" not in text:
            keys.add(f"deps-not-narrowed:{app}")
    return errors, keys


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--update-baseline", action="store_true", help="rewrite the baseline with the current findings")
    args = parser.parse_args()

    errors, keys = collect()

    if args.update_baseline:
        with open(BASELINE, "w", encoding="utf-8") as handle:
            json.dump(sorted(keys), handle, indent=2)
            handle.write("\n")
        print(f"baseline written: {len(keys)} findings")
        return 1 if errors else 0

    with open(BASELINE, encoding="utf-8") as handle:
        baseline = set(json.load(handle))
    new = sorted(keys - baseline)
    stale = sorted(baseline - keys)

    for message in errors:
        print(f"::error::schema: {message}")
    for key in new:
        print(f"::error::new container-test finding not in the baseline: {key}")
    for key in stale:
        print(f"::notice::baseline entry no longer applies, run scripts/lint_container_tests.py --update-baseline: {key}")

    summary = (
        f"container-test lint: {len(errors)} schema errors, {len(new)} new findings, "
        f"{len(keys & baseline)} baselined findings, {len(stale)} stale baseline entries"
    )
    print(summary)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as handle:
            handle.write(f"### {summary}\n")
    return 1 if errors or new else 0


if __name__ == "__main__":
    sys.exit(main())
