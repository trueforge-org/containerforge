# influxdata/influxdata-docker: chronograf/1.11 (upstream image build)

Source URL(s) + fetch date:
- https://github.com/influxdata/influxdata-docker/blob/master/chronograf/1.11/Dockerfile (raw variant, fetched 2026-11-26)
- https://github.com/influxdata/influxdata-docker/blob/f49180e6d0f4acee8c9f8672342cf4496d81b99b/chronograf/1.11/Dockerfile (raw variant at pinned commit, fetched 2026-11-26)
- https://raw.githubusercontent.com/influxdata/influxdata-docker/master/chronograf/1.11/entrypoint.sh (fetched 2026-11-26)

## Dockerfile (master)
- `FROM debian:bookworm-slim`.
- `ENV CHRONOGRAF_VERSION 1.11.8`.
- Arch from `dpkg --print-architecture`; supports amd64, arm64, armhf, armel; others exit 1 ("Unsupported architecture").
- Packages: gnupg, ca-certificates, dirmngr (first step); ca-certificates, curl (second step), apt lists removed.
- GPG: creates ~/.gnupg, appends `disable-ipv6` to dirmngr.conf, fetches key `24C975CBA61A024EE1B631787C3D57159FC2F927` from `hkp://keyserver.ubuntu.com`.
- Downloads `https://dl.influxdata.com/chronograf/releases/chronograf_${CHRONOGRAF_VERSION}_${ARCH}.deb` and `.deb.asc` with `curl -SLO`; verifies with `gpg --batch --verify <asc> <deb>`; `dpkg -i`; removes the files.
- `COPY LICENSE /usr/share/chronograf/LICENSE`, `COPY agpl-3.0.md /usr/share/chronograf/agpl-3.0.md`, `COPY entrypoint.sh /entrypoint.sh`.
- `EXPOSE 8888`, `VOLUME /var/lib/chronograf`, `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["chronograf"]`.
- No `USER` instruction: runs as root in the upstream image.

## Dockerfile (pinned commit f49180e)
- Same structure with `ENV CHRONOGRAF_VERSION 1.11.7` and an apt `purge` referencing an undefined `$buildDeps` (no-op). Same EXPOSE, VOLUME, ENTRYPOINT, CMD.

## entrypoint.sh (master)
- `#!/bin/bash`, `set -e`.
- If the first arg starts with `-`, prepends `chronograf` (`set -- chronograf "$@"`).
- For `chronograf`: `export BOLT_PATH=${BOLT_PATH:-/var/lib/chronograf/chronograf-v1.db}`. No other exports.
- If `$(id -u)` is not 0, or `CHRONOGRAF_AS_ROOT=true`, it execs as-is. Otherwise `exec setpriv --reuid chronograf --regid chronograf --init-groups "$@"`.

## Gotchas
- Upstream image default BOLT_PATH is `/var/lib/chronograf/...`, not the docs' `./chronograf-v1.db`.
- Pinned variant and master differ only by version and the purge line; master's version is newer than the draft's pin.
- Contradicts nothing in plan.md; plan's entrypoint summary matches.
