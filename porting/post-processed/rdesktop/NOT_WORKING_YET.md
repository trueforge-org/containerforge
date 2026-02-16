# rdesktop: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build deps ****\" &&   sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list &&   apt-get update &&   apt-get install -y     build-essential     devscripts     dpkg-dev     git     libpulse-dev     meson     pulseaudio &&   apt build-dep -y     pulseaudio     xrdp" did not complete successfully: exit code: 4
