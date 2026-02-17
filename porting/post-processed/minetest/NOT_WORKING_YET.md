# minetest: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- Dockerfile mixes Ubuntu base images with Alpine `apt-get` package commands and needs Dockerfile fixes before migration.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-minetest:amd64 .`
- Result: FAIL
- Reason: 6.103 E: Unable to locate package zstd-dev
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large-batch completion)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in deep multi-source compile chain; requires larger upstream/toolchain adjustments.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 completed large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in deep multi-component compile chain; requires broader upstream/toolchain adjustments.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 global-fix validation pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Still failing in deep multi-component compile chain; requires broader upstream/toolchain adaptation.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 next large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in deep compile chain with non-localized upstream/toolchain issues.
- Full log: `amd64-build.log`
