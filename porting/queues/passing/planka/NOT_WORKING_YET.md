# planka: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Uses Alpine-style `apt-get add/del --no-cache` commands, which fail on Debian/Ubuntu base images.

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-planka:amd64 .`
- Result: FAIL
- Reason: ERROR: failed to build: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install packages ****\" &&   apt-get update && apt-get install -y --no-install-recommends     giflib     libgsf     nodejs     vips &&   apt-get update && apt-get install -y --no-install-recommends     build-essential     npm     py3-setuptools &&   echo \"**** install planka ****\" &&   mkdir -p /build &&   curl -o     /tmp/planka.tar.gz -L     \"https://github.com/plankanban/planka/archive/v${VERSION}.tar.gz\" &&   tar xf     /tmp/planka.tar.gz -C     /build --strip-components=1 &&   cd /build/server &&   npm install pnpm@9 --global &&   pnpm import &&   pnpm install --prod &&   cd /build/client &&   pnpm import &&   pnpm install --prod &&   DISABLE_ESLINT_PLUGIN=true npm run build &&   echo \"**** cleanup ****\" &&   apt-get autoremove -y &&   rm -rf     $HOME/.cache     $HOME/.local     $HOME/.npm     /tmp/*" did not complete successfully: exit code: 100
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 remediation rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Source tarball URL for configured VERSION resolves to HTTP 400 during fetch.
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 continuous batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build reaches dependency install but fails in frontend build (`node-sass`/node-gyp requiring distutils in this environment).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in frontend dependency compilation (`node-sass`/node-gyp toolchain incompatibility).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 auto-batch rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in frontend dependency compilation (`node-sass`/node-gyp toolchain incompatibility).
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-17 next large batch)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: Build still fails in node-sass/node-gyp compile path under current dependency set.
- Full log: `amd64-build.log`
