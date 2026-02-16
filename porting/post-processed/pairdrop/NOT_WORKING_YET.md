# pairdrop: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install pairdrop ****\" &&   mkdir -p /app &&   curl -o     /tmp/pairdrop.tar.gz -L     \"https://github.com/schlagmichdoch/PairDrop/archive/refs/tags/v${VERSION}.tar.gz\" &&   tar xf     /tmp/pairdrop.tar.gz -C     ./ --strip-components=1 &&   cd /app &&   chown -R apps:apps ./ &&   su -s /bin/sh apps -c 'HOME=/tmp NODE_ENV=production npm ic' &&   chown -R apps:apps /app && chmod -R 755 /app &&   echo \"**** cleanup ****\" &&   rm -rf     $HOME/.cache     /tmp/*     /tmp/.npm" did not complete successfully: exit code: 1
