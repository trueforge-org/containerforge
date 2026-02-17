# emulatorjs: porting status

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
- Reason: E: List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-emulatorjs:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&   apt-get update &&   apt-get install -y --no-install-recommends     p7zip-full     zip &&   rm -rf /var/lib/apt/lists/*" did not complete successfully: exit code: 100
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 remediation rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Runtime package install fails because `ipfs-kubo` package is unavailable in Ubuntu apt repos.
- Full log: `amd64-build.log`
