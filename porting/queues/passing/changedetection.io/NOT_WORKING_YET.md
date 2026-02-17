# changedetection.io: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Package libjpeg62-turbo is not available, but is referred to by another package.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-changedetection.io:amd64 .`
- Result: FAIL
- Reason: 16.27 fatal: Remote branch  not found in upstream origin
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 bigger batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails due venv path/layout mismatch in later playwright install step.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 larger debian-style batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Still fails in venv/playwright install path handling; requires focused python-venv path refactor.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch + base-policy pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after base-policy alignment to python-node and venv/playwright path fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 next large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after python-node alignment and venv/playwright path fixes.
- Full log: `amd64-build.log`
