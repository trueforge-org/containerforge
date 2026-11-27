# github jhthorsen/app-mojopaste Dockerfile (pinned 246642c)

Source URL(s): https://raw.githubusercontent.com/jhthorsen/app-mojopaste/246642c/Dockerfile (fetched 2026-11-27)

## Build
- base: `FROM alpine:3.5` (old, unmaintained)
- `mkdir -p /app/data`
- apk add (runtime): curl openssl perl perl-io-socket-ssl perl-net-ssleay wget
- apk add --virtual builddeps: build-base perl-dev
- source: `curl -L https://github.com/jhthorsen/app-mojopaste/archive/main.tar.gz | tar xvz` (branch main, not pinned)
- cpanm bootstrap via https://cpanmin.us; `cpanm -M https://cpan.metacpan.org Text::CSV`; `cpanm --installdeps ./app-mojopaste-main`
- cleanup: apk del builddeps curl; rm /root/.cpanm, /var/cache/apk/*

## Runtime
- perl (Mojolicious app, App::mojopaste)
- ENV: MOJO_MODE=production, PASTE_DIR=/app/data, PASTE_ENABLE_CHARTS=1
- EXPOSE 8080
- ENTRYPOINT: `/usr/bin/perl /app-mojopaste-main/script/mojopaste prefork -l http://*:8080`
- note: source extracted to `/app-mojopaste-main` (root path, not /app)

## Env vars
| var | value | notes |
| --- | --- | --- |
| MOJO_MODE | production | |
| PASTE_DIR | /app/data | paste storage |
| PASTE_ENABLE_CHARTS | 1 (Dockerfile) / 0 (chart) | CSV chart feature, needs Text::CSV |

## Ports
- 8080 (listen http://*:8080)

## Volumes/paths
- /app/data (paste storage; created in image)

## Config (from README)
- Config via MOJO_CONFIG file: paste_dir, enable_charts, hypnotoad.listen
- Other modes: `mojopaste daemon --listen http://*:8080`; hypnotoad option supported

## Healthcheck
- none in Dockerfile

## Gotchas
- Image uses perl-based Mojolicious; base alpine:3.5 is EOL
- Source fetched from branch `main` tarball, not pinned commit
- No USER directive: runs as root
