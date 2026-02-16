# tvheadend: porting status

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
- Reason: failed to fetch anonymous token: unexpected status from GET request to https://ghcr.io/token?scope=repository%3Atrueforge-org%2Fpicons-builder%3Apull&service=ghcr.io: 403 Forbidden

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-tvheadend:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: failed to fetch anonymous token: unexpected status from GET request to https://ghcr.io/token?scope=repository%3Atrueforge-org%2Fpicons-builder%3Apull&service=ghcr.io: 403 Forbidden
- Full log: `amd64-build.log`
