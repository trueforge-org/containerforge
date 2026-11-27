# iv-org/invidious docker/Dockerfile (pinned commit 4e9d20dd)

Source URL(s): https://raw.githubusercontent.com/iv-org/invidious/4e9d20ddae3c23e4764df056d2e820aee04feef7/docker/Dockerfile (blob variant maps here; fetched 2026-11-27)

## Stages
1. dependabot-crystal: FROM 84codes/crystal:1.22.3-alpine (build base).
2. openssl-builder: builds OpenSSL 3.6.5 from source (ARG OPENSSL_VERSION=3.6.5, SHA256 a2157c28...df98 verified). Configure: --openssldir=/etc/ssl no-apps. Reason: Crystal/OpenSSL memory leak (upstream issue 1438).
3. builder: apk add sqlite-static yaml-static; apk del openssl-dev openssl-libs-static; shards install --production; crystal build ./src/invidious.cr with --static, --link-flags "-lxml2 -llzma -no-pie"; --release when build arg release=1. Build args: release, OPENSSL_VERSION, OPENSSL_SHA256.
4. runtime: FROM alpine:3.24. apk add rsvg-convert ttf-opensans tini tzdata.
   - user/group: invidious uid/gid 1000 (system users via addgroup/adduser -S).
   - copies config/config.* to ./config, mv config.example.yml to config.yml, sed host 127.0.0.1|localhost -> invidious-db.
   - copies config/sql, locales, assets from builder; binary /invidious/invidious.
   - EXPOSE 3000; USER invidious; ENTRYPOINT ["/sbin/tini","--"]; CMD ["/invidious/invidious"].

## Build inputs
- Requires .git directory present at build (version info). Needs shard.yml, shard.lock, src/, scripts/, assets/, videojs-dependencies.yml.

## Gotchas
- Container runs as uid 1000 (USER invidious), while the TrueCharts chart forces runAsUser 0. Chart overrides user.
- Default listen port in image is 3000 (EXPOSE); chart service uses 10594 via config external_port.

## Master Dockerfile (raw master, same repo)
- https://raw.githubusercontent.com/iv-org/invidious/master/docker/Dockerfile fetched; directives checked (FROM, EXPOSE 3000, USER invidious uid 1000, ENTRYPOINT tini, CMD binary) match the pinned copy. Not saved as a separate file.
