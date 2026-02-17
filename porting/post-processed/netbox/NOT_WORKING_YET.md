# netbox: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-netbox:amd64 .`
- Result: FAIL
- Reason: 4.663 E: Unable to locate package zlib-dev
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large-batch completion)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build/install phase remains unstable due network/index resolution during extensive pip dependency install.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 completed large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build/install remains constrained by long pip dependency resolution/network access in this environment.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 global-fix validation pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Still constrained by long pip dependency/index resolution network issues during install.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 next large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds in this batch without additional Dockerfile changes.
- Full log: `amd64-build.log`
