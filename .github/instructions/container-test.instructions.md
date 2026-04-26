---
description: "container-test.yaml rules: follow the JSON schema in testhelpers/container-test-schema.json, prefer real port/HTTP/file assertions, never weaken tests to make them pass."
applyTo: "apps/**/container-test.yaml"
---

# container-test.yaml Rules (apps/**/container-test.yaml)

## Schema

- MUST follow the schema at `testhelpers/container-test-schema.json`.
- Keep the `# yaml-language-server: $schema=...` header used by sibling apps so editors validate live.

## Real assertions

- Tests MUST exercise actual runtime behavior: open TCP ports declared in `settings.yaml`, HTTP probes where applicable, file/process existence.
- Do NOT weaken or remove assertions to make a failing build pass. Fix the real defect (Dockerfile, start.sh, defaults) instead.

## Timeouts

- Use a `timeoutSeconds` value reasonable for the app's startup (look at sibling apps of the same family).

## Coverage minimum

- Every port listed in `settings.yaml` SHOULD have a corresponding `tcp` (or higher-level) probe here.
