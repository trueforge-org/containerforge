# feed2toot: porting status

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
- Result: PASS

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-feed2toot:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install feed2toot ****\" &&   python3 -m venv /config/venv &&   pip install -U --no-cache-dir     pip     wheel &&   pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/     feed2toot==\"${VERSION}\" &&   echo \"**** cleanup ****\" &&   rm -rf     /tmp/*     $HOME/.cache" did not complete successfully: exit code: 1
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 large batch + base-policy pass)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds after Debian/Ubuntu wheel index and venv pip-path fix.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 next large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Build succeeds with Ubuntu wheel-index and venv-pip path updates.
- Full log: `amd64-build.log`
