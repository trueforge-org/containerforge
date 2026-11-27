# Upstream kiwix-tools docker/server: Dockerfile + start.sh (3.8.2)

## Source URL(s) + date

- https://raw.githubusercontent.com/kiwix/kiwix-tools/3.8.2/docker/server/Dockerfile (raw of listed blob URL)
- https://raw.githubusercontent.com/kiwix/kiwix-tools/3.8.2/docker/server/start.sh (raw of listed blob URL)
- https://api.github.com/repos/kiwix/kiwix-tools/releases/latest: tag `3.8.2`, published 2026-03-02T08:24:42Z
- Fetched 2026-11-27

## Build (Dockerfile)

- `ARG VERSION=latest`.
- `FROM ghcr.io/kiwix/kiwix-tools:$VERSION` (upstream image is the base; kiwix-tools is multi-arch).
- `LABEL org.opencontainers.image.source=https://github.com/openzim/kiwix-tools`.
- `RUN addgroup -S -g 1001 user && adduser -S -u 1001 user -G user` (alpine-style syntax).
- `RUN chown user:user /data`; `USER user`.
- `COPY ./start.sh /usr/local/bin/`.
- `ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/start.sh"]`.

## Entrypoint / flags

- start.sh: if `DOWNLOAD` set, requires `/data` writable (else exit 1), `wget $DOWNLOAD -O <basename>`; if no args given, uses the downloaded file as arg.
- `PORT` default 8080 if empty.
- Runs `/usr/local/bin/kiwix-serve --port=$PORT $@` (args default empty; pass `*.zim` or file names).
- On failure (non-zero exit) prints `find /data -type f`.

## Env vars

| Var | Default | Use |
| --- | --- | --- |
| DOWNLOAD | unset | ZIM URL, fetched with wget into `/data` |
| PORT | 8080 | `--port` |

## Ports

- `EXPOSE 8080`.

## Volumes / paths

- `VOLUME /data`, `WORKDIR /data`. ZIM files live in `/data`.

## User / UID

- `user` uid 1001, gid 1001 (`addgroup -S -g 1001`, `adduser -S -u 1001`). `USER user`.

## Healthcheck

- None.

## Version / asset naming

- Tag `3.8.2` is the upstream release (releases/latest). Release asset list not checked here.

## Gotchas

- Dockerfile syntax is alpine (`addgroup`/`adduser -S`), so base is musl-based.
- start.sh uses `wget` for download; no checksum verification.
