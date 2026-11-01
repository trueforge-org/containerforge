---
description: "container-test.yaml rules: follow the JSON schema of forgetool, prefer real port/HTTP/file assertions, never weaken tests to make them pass."
applyTo: "apps/**/container-test.yaml"
---

# container-test.yaml Rules (apps/**/container-test.yaml)

## Schema

- MUST follow the schema of `forgetool`, in the `# yaml-language-server: $schema=...` header of sibling apps.
- Keep the `# yaml-language-server: $schema=...` header used by sibling apps so editors validate live.

## Real assertions

- Tests MUST exercise actual runtime behavior: open TCP ports declared in `settings.yaml`, HTTP probes where applicable, file/process existence.
- Do NOT weaken or remove assertions to make a failing build pass. Fix the real defect (Dockerfile, start.sh, defaults) instead.

## What the test can't see

- The test runs the image without any environment variables, and it has no key to set them. An image MUST still start without them, so code that only runs when a password is set is not tested at all. Add such files to `filePaths`, and run that path yourself per the build, run and test protocol.
- `tcp` and `http` checks run against the container itself, so they pass when a server only listens on localhost. They do not prove that another container can connect.

## Timeouts

- Use a `timeoutSeconds` value reasonable for the app's startup (look at sibling apps of the same family).

## Coverage minimum

- Every port listed in `settings.yaml` SHOULD have a corresponding `tcp` (or higher-level) probe here.
