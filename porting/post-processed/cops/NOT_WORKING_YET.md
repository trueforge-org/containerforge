# cops: porting status

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
- Reason: E: Unable to locate package php8.4-gd

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-cops:amd64 .`
- Result: FAIL
- Reason: 15.84 sed: can't read /etc/php/8.3/fpm/pool.d/www.conf: No such file or directory
- Full log: `amd64-build.log`
