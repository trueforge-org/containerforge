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

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-rdesktop:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build deps ****\" &&   sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list &&   apt-get update &&   apt-get install -y     build-essential     devscripts     dpkg-dev     git     libpulse-dev     meson     pulseaudio &&   apt build-dep -y     pulseaudio     xrdp" did not complete successfully: exit code: 4
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 remediation rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build fails in runtime dependency setup stage after package installation (non-zero exit in long RUN chain).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 continuous batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after package and proot-apps URL fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after source/release handling fixes.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64 after release asset handling and package fixes.
- Full log: `amd64-build.log`
