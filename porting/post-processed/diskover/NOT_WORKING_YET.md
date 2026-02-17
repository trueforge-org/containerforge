# diskover: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` does not currently hand off to a long-running process via `exec`, so runtime behavior is not yet validated.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to resolve source metadata for ghcr.io/trueforge-org/node:20.5.1: ghcr.io/trueforge-org/node:20.5.1: not found

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-diskover:amd64 .`
- Result: FAIL
- Reason: 19.66 /bin/bash: line 1: /etc/php83/php-fpm.d/www.conf: No such file or directory
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 remediation rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Diskover source tag download fails (HTTP 404) after release/tag fallback logic.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 continuous batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after pip/venv and source fallback fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after venv/pip and source fallback fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after venv/pip and source fallback fixes.
- Full log: `amd64-build.log`
