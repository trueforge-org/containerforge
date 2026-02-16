# syslog-ng: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- Dockerfile mixes Ubuntu base images with Alpine `apt-get` package commands and needs Dockerfile fixes before migration.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: `apt-get -U --update --no-cache add ...` failed with `E: Command line option 'U' [from -U] is not understood in combination with the other options.`

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-syslog-ng:amd64 .`
- Result: FAIL
- Reason: 4.682 E: Unable to locate package syslog-ng-xml
- Full log: `amd64-build.log`
