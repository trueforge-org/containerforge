# wireguard: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- Dockerfile mixes Ubuntu base images with Alpine `apt-get` package commands and needs Dockerfile fixes before migration.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.
