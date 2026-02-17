# wikijs: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-wikijs:amd64 .`
- Result: FAIL
- Reason: 5.634 E: Unable to locate package openssh
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 finalizing in-progress batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in Wiki.js release fetch/install stage after package normalization.
- Full log: `amd64-build.log`
