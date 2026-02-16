# kasmvnc: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: E: List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-kasmvnc:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build deps ****\" &&     apt-get update &&     apt-get install -y --no-install-recommends         build-essential         cmake         g++         gcc         make         libpulse-dev         python3.11 &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*" did not complete successfully: exit code: 100
- Full log: `amd64-build.log`
