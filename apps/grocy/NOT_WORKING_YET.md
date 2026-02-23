# grocy: porting status

This container remains in `/porting/post-processed` for now.

## Why it is not marked working in `/apps` yet
- Not yet migrated into `/apps`, so it is not covered by the normal app build/test workflow.
- `start.sh` still contains TODO placeholders and needs app-specific runtime startup logic.
- `start.sh` does not currently hand off to a long-running process via `exec`, so runtime behavior is not yet validated.
- No app-specific `container-test.yaml` exists yet for CI runtime verification after migration.

## Next step
- Finish app-specific runtime validation and add `apps/<app>/container-test.yaml` before moving this container into `/apps`.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: FAIL
- Reason: failed to solve: process "/bin/bash -o pipefail -c echo \"**** install build packages ****\" &&     apt-get update &&     apt-get install -y --no-install-recommends         yarn &&     echo \"**** install runtime packages ****\" &&     apt-get install -y --no-install-recommends         php8.3-gd         php8.3-intl         php8.3-ldap         php8.3-opcache         php8.3-sqlite3         php8.3-tokenizer &&     echo \"**** configure php-fpm to pass env vars ****\" &&     sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf &&     grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf || echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf &&     echo \"**** install grocy ****\" &&     mkdir -p /app/www &&     curl -o         /tmp/grocy.tar.gz -L         \"https://github.com/grocy/grocy/archive/v${VERSION}.tar.gz\" &&     tar xf         /tmp/grocy.tar.gz -C         /app/www/ --strip-components=1 &&     cp -R /app/www/data/plugins         /defaults/plugins &&     echo \"**** install composer packages ****\" &&     composer install -d /app/www --no-dev &&     echo \"**** install yarn packages ****\" &&     cd /app/www &&     yarn --production &&     yarn cache clean &&     echo \"**** cleanup ****\" &&     apt-get remove -y --purge         yarn &&     apt-get autoremove -y &&     rm -rf         /tmp/*         $HOME/.cache         $HOME/.composer &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*" did not complete successfully: exit code: 1

## AMD64 build check (2026-02-16 rerun)
- Command: `docker build --progress=plain --platform linux/amd64 -t porting-grocy:amd64 .`
- Result: FAIL
- Reason: 14.04 /bin/bash: line 1: /etc/php/8.3/fpm/pool.d/www.conf: No such file or directory
- Full log: `amd64-build.log`

## AMD64 build check (2026-02-16 post-fix rerun)
- Command: `docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local`
- Result: PASS
- Reason: Container builds correctly for linux/amd64.
- Full log: `amd64-build.log`
