# pydio-cells: porting status

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
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-pydio-cells:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&   apt-get update && apt-get install -y --no-install-recommends     build-essential     golang-go     openssl &&   echo \"**** fetch source code ****\" &&   mkdir -p     /tmp/src/github.com/pydio/cells &&   curl -o     /tmp/cells-src.tar.gz -L     https://github.com/pydio/cells/archive/v${VERSION}.tar.gz &&   tar xf     /tmp/cells-src.tar.gz -C     /tmp/src/github.com/pydio/cells --strip-components=1 &&   echo \"**** compile cells  ****\" &&   cd /tmp/src/github.com/pydio/cells &&   GOARCH=$TARGETARCH GOOS=linux go build -trimpath     -ldflags \"    -X github.com/pydio/cells/v4/common.version=${VERSION:1}     -X github.com/pydio/cells/v4/common.BuildStamp=${BUILD_DATE}     -X github.com/pydio/cells/v4/common.BuildRevision=v${VERSION}\"     -o /app/cells -x . &&   echo \"**** cleanup ****\" &&   apt-get autoremove -y &&   rm -rf     /tmp/*     \"${HOME}\"/.cache     \"${HOME}\"/go" did not complete successfully: exit code: 100
- Full log: `amd64-build.log`
