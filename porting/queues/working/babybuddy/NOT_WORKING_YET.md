# babybuddy: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Package libjpeg62-turbo is not available, but is referred to by another package.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-babybuddy:amd64 .`
- Result: FAIL
- Reason: 10.46 tar: Child returned status 1
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 bigger batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after resilient GitHub tag fallback and venv pip path usage.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 larger debian-style batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds with Debian-style package flow plus resilient GitHub tag fallback and venv pip path updates.
- Full log: `amd64-build.log`

## AMD64 manual runtime check (2026-02-19)
- Build command: `docker build --progress=plain --platform linux/amd64 --build-arg VERSION=2.7.1 -t porting-babybuddy:amd64 .`
- Run command: `docker run --rm -d --name porting-babybuddy-test -e TZ=UTC -p 18000:8000 porting-babybuddy:amd64`
- HTTP probe: `curl http://127.0.0.1:18000/` returned `302`
- Result: PASS
- Reason: Container starts, migrations complete, and gunicorn listens on `0.0.0.0:8000`.
- Runtime log: `run.log`
