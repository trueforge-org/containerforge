# davos: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** Install build requirements ****\" &&   echo \"**** Download Davos ****\" &&   curl -o /tmp/davos.tar.gz -L \"https://github.com/linuxserver/davos/archive/${VERSION}.tar.gz\" &&   echo \"**** Build Davos For Release ****\" &&   mkdir -p /app/davos/ &&   tar xf /tmp/davos.tar.gz -C /app/davos/ --strip-components=1 &&   cd /app/davos/ &&   ./gradlew -Penv=release clean build &&   echo \"**** Copy Finished Jar ****\" &&   cp build/libs/*.jar /davos.jar &&   chmod 755 /davos.jar" did not complete successfully: exit code: 1
