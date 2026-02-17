# mariadb: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Canonical container already exists in `/apps/mariadb`; this porting copy is kept only as a post-processing artifact.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: E: Version '11.4.8-r0' for 'mariadb-server' was not found

## AMD64 build check (2026-02-17 failing-unattempted batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds in this batch without additional Dockerfile changes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 failing-unattempted follow-up batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds in this batch without additional Dockerfile changes.
- Full log: `amd64-build.log`
