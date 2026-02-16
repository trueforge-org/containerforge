# unrar: porting status

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
- Reason: failed to compute cache key: failed to calculate checksum of ref ntgcosadh0xpbpttq2x5wsvla::ktn6ewu5n9j7wfijjvurp6ffi: "/data.rar": not found

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-unrar:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: failed to compute cache key: failed to calculate checksum of ref ntgcosadh0xpbpttq2x5wsvla::nzd8o5d7c1aydfj5rejoo2sv6: "/data.rar": not found
- Full log: `amd64-build.log`
