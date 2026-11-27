# Source: Organizr/docker-organizr Dockerfile (commit 53b8b05)

Source URL(s) + date: https://raw.githubusercontent.com/Organizr/docker-organizr/53b8b05/Dockerfile (fetched 2026-11-27; blob variant listed in urls.txt not fetched separately)

## Build (complete file, 261 bytes)
- `ARG BASE_IMAGE`, `ARG ARCH`.
- `FROM ${BASE_IMAGE:-ghcr.io/organizr/base:2026-11-20_10}-${ARCH:-linux-amd64}`.
- LABEL maintainer "christronyxyocum,Roxedus".
- `ENV fpm="false" branch="v2-master"`.
- `COPY root/ /`.
- `EXPOSE 80`; `VOLUME /config`.
- No RUN, no USER, no ENTRYPOINT/CMD in this file (inherited from base).

## Runtime deps
- Base ghcr.io/organizr/base (Alpine + s6 overlay per README; PHP/nginx come from base, not traced further).

## Env vars
| Var | Default | Notes |
| --- | --- | --- |
| fpm | false | php-fpm mode switch (meaning not documented in fetched files) |
| branch | v2-master | README: valid values v2-master, master, v2-develop, develop, dev |

## Ports
- 80.

## Volumes
- /config.

## Gotchas
- The image does NOT contain Organizr source: README says it is fetched at container start, so the image does not pin the 1.90 release.
- `branch` env selects the Organizr branch fetched at runtime (default v2-master).
