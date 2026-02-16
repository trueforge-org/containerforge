# flexget: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: E: Unable to locate package libboost-python3-dev

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-flexget:amd64 .`
- Result: FAIL
- Reason: Build command still contains unresolved `$SELECTION_PLACEHOLDER$`, which executes as `$` and fails with `/bin/bash: line 1: $: command not found`.
- Full log: `amd64-build.log`
