# phpmyadmin: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- Dockerfile mixes Ubuntu base images with Alpine `apt-get` package commands and needs Dockerfile fixes before migration.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- `start.sh` does not currently hand off to a long-running process via `exec`, so runtime behavior is not yet validated.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-phpmyadmin:amd64 .`
- Result: FAIL
- Reason: 5.146 /bin/bash: line 1: /etc/php84/conf.d/phpmyadmin-misc.ini: No such file or directory
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails during release signature verification (GPG keyserver retrieval/verification path in this environment).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails during upstream signature-verification path in this environment (GPG keyserver-dependent step).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch + base-policy pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Still fails in phpMyAdmin artifact/signature acquisition path under current network/keyserver conditions.
- Full log: `amd64-build.log`
