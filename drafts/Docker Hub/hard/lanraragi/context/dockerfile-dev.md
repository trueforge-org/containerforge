# Difegue/LANraragi tools/build/docker/Dockerfile (dev branch)

Source URL(s): https://raw.githubusercontent.com/Difegue/LANraragi/dev/tools/build/docker/Dockerfile (blob: https://github.com/Difegue/LANraragi/blob/dev/tools/build/docker/Dockerfile). Fetched 2026-11-26. Differs from pinned add16039 (see dockerfile-add16039.md).

## Stages
- `FROM alpine:3.24` (stage `base`), then stages `build` and `runtime` from base. Header DOCKER-VERSION 0.3.4.

## Base stage
- ENV as pinned, plus no EV_EXTRA_DEFS / S6_KILL_GRACETIME listed in this summary (not checked)
- LC_ALL/LANG/LANGUAGE=en_US.UTF-8; LRR_UID/GID=9001; LRR_NETWORK=http://*:3000; MOJO_PROXY=1; MOJO_REVERSE_PROXY=1; LRR_AUTOFIX_PERMISSIONS=1; S6_KEEP_ENV=1; S6_BEHAVIOUR_IF_STAGE2_FAILS=1
- User `koyomi` uid 9001 (group 9001 created if absent)
- WORKDIR `/home/koyomi/lanraragi`
- apk add --no-cache: tzdata valkey valkey-cli perl perl-io-socket-ssl perl-local-lib libffi vips vips-jxl vips-heif vips-poppler shadow s6-overlay procps-ng
- chown koyomi:koyomi `.`

## Build stage
- apk add --no-cache: g++ make pkgconf wget curl nodejs npm perl-dev libarchive-dev linux-headers libffi-dev patch perl-config-autoconf
- COPY (koyomi): cpanfile, install.pl, `install-perl-deps.sh` -> tools/
- `USER koyomi`; `./tools/install-perl-deps.sh`
- COPY package.json, package-lock.json; `perl ./tools/install.pl install-front`; delete `*.map` in `public/js/vendor`, `public/css/vendor`

## Runtime stage
- COPY s6-rc.d and cont-init.d/01-lrr-setup (as pinned)
- COPY --from=build (koyomi): `/home/koyomi/perl5/lib`, `public/css/vendor`, `public/css/webfonts`, `public/js/vendor`
- COPY (koyomi): redis.conf, lrr.conf, script, tools/openapi.yaml, package.json, locales, templates, public, lib
- No USER in runtime (runs root; s6 handles privilege drop)
- VOLUME: content, thumb, database, `lib/LANraragi/Plugin/Sideloaded`, `lib/LANraragi/Plugin/Managed`
- EXPOSE 3000; ENTRYPOINT `["//init"]`; no CMD
- HEALTHCHECK 1m / 10s / 3 retries: wget spider http://127.0.0.1:3000
- Notes: valkey replaces redis (config still named redis.conf); libvips instead of ImageMagick.
