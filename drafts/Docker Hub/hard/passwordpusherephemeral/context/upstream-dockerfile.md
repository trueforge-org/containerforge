# Upstream pwpush production Dockerfile (containers/docker/Dockerfile, master)

Source URL: https://raw.githubusercontent.com/pglombardo/PasswordPusher/master/containers/docker/Dockerfile (fetched; follow-up, not pinned)

## Stages
- build-env: ruby:4.0.10-alpine; final: ruby:4.0.10-alpine

## Global/build args
- BUNDLE_WITHOUT=development:test, BUNDLE_DEPLOYMENT=true (redeclared per stage)
- Final stage: UID=1000, GID=1000
- TARGETARCH used in build stage but not declared there (bootsnap precompile only when amd64)

## Packages
- build (apk): git, build-base, musl-dev, libc6-compat, libpq-dev, mariadb-dev, nodejs, sqlite-dev, tzdata, yaml-dev, yarn, pkgconf, openssl-dev, libffi-dev
- final (apk): bash, curl, libc6-compat, libpq, mariadb-connector-c, nodejs, tzdata, yarn, jemalloc

## Build steps
- APP_ROOT=/opt/PasswordPusher; RACK_ENV/RAILS_ENV=production
- bundle install (gem cache/.git cleanup); yarn install --frozen-lockfile
- bootsnap precompile (amd64 only); `SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile`
- removes tmp cache/pids/sockets, some images, .do, .github, containers, test, ct.yaml

## Final stage
- ENV: LC_CTYPE=UTF-8, LC_ALL=en_US.UTF-8, APP_ROOT, RACK_ENV=production, RAILS_ENV=production, LD_PRELOAD=/usr/lib/libjemalloc.so.2, SOLID_QUEUE_SUPERVISOR_MODE=async
- SECRET_KEY_BASE NOT set in image; must be supplied at runtime
- WORKDIR /opt/PasswordPusher
- User/group pwpusher, UID/GID 1000; `USER pwpusher`; app owned pwpusher:pwpusher
- mkdir storage/db; chown storage
- /usr/local/bin/docker-entrypoint (from containers/docker/entrypoint.sh); /usr/local/bin/docker-worker-entrypoint (worker-entrypoint.sh)
- empty .env.production owned by pwpusher
- EXPOSE 80 443 5100
- ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]; no CMD
- No VOLUME, no HEALTHCHECK
- entrypoint.sh contents not shown (comment: validates/generates SECRET_KEY_BASE)

## Gotchas
- Non-root UID 1000 (pwpusher); storage dir must be writable.
