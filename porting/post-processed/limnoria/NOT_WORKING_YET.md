# limnoria: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: PASS

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-limnoria:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&     apt-get update &&     apt-get install -y --no-install-recommends         build-essential         cargo         libffi-dev         libssl-dev         python3-venv &&     echo \"**** install runtime packages ****\" &&     echo \"**** install app ****\" &&     python3 -m venv /config/venv &&     /config/venv/bin/pip install -U --no-cache-dir         pip         wheel &&     /config/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/         -r https://raw.githubusercontent.com/ProgVal/Limnoria/master/requirements.txt &&     /config/venv/bin/pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.21/         limnoria==\"${VERSION}\" &&     echo \"**** cleanup ****\" &&     apt-get purge -y --auto-remove         build-essential         cargo         libffi-dev         libssl-dev &&     rm -rf         /var/lib/apt/lists/*         /tmp/*         $HOME/.cache         $HOME/.cargo" did not complete successfully: exit code: 1
- Full log: `amd64-build.log`
