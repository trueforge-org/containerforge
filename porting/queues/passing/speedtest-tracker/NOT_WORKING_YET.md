# speedtest-tracker: porting status

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
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-speedtest-tracker:amd64 .`
- Result: FAIL
- Reason: 4.533 /bin/bash: line 1: /etc/php84/conf.d/php-misc.ini: No such file or directory
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after php package/path fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after php package/path fixes and syntax correction.
- Full log: `amd64-build.log`
