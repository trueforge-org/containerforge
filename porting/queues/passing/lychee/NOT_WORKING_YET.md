# lychee: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- `start.sh` does not currently hand off to a long-running process via `exec`, so runtime behavior is not yet validated.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to compute cache key: failed to calculate checksum of ref ntgcosadh0xpbpttq2x5wsvla::y4dbd02b4gjmq5xfn9zd5x5nd: "/lychee.pub": not found

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-lychee:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: failed to compute cache key: failed to calculate checksum of ref ntgcosadh0xpbpttq2x5wsvla::ni03yifssxhrpya2dv9c5evrv: "/lychee.pub": not found
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 post-passing-snapshot batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after removing missing cosign key mount dependency and Debian package/path fixes.
- Full log: `amd64-build.log`
