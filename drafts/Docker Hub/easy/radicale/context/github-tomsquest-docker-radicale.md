# tomsquest/docker-radicale (GitHub, third-party Docker image)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/tomsquest/docker-radicale/blob/master/Dockerfile (raw master fetched)
- https://github.com/tomsquest/docker-radicale/blob/3.9.2.0/Dockerfile (tag 3.9.2.0 fetched)
- https://github.com/tomsquest/docker-radicale (repo; README not fetched)

## What it is
Enhanced Docker image for Radicale (CalDAV/CardDAV). Read-only capable, non-root, data in /data, config in /config, uses a Python venv.

## Dockerfile (tag 3.9.2.0; master text matches apart from formatting)
```
FROM alpine:3
ARG COMMIT_ID
ENV COMMIT_ID=${COMMIT_ID}
ARG VERSION
ENV VERSION=${VERSION:-3.9.2}
ARG BUILD_UID
ENV BUILD_UID=${BUILD_UID:-2999}
ARG BUILD_GID
ENV BUILD_GID=${BUILD_GID:-2999}
ARG TAKE_FILE_OWNERSHIP
ENV TAKE_FILE_OWNERSHIP=${TAKE_FILE_OWNERSHIP:-true}
LABEL ... (maintainer Thomas Queste; org.label-schema.* ; vcs-url https://github.com/tomsquest/docker-radicale)
RUN apk add --no-cache --virtual=build-dependencies gcc musl-dev libffi-dev python3-dev \
    && apk add --no-cache curl git openssh-client-default shadow su-exec tzdata wget python3 py3-pip \
    && python -m venv /venv \
    && /venv/bin/pip install --no-cache-dir radicale==$VERSION passlib[bcrypt] argon2-cffi pytz ldap3 \
    && apk del --purge build-dependencies \
    && addgroup -g $BUILD_GID radicale \
    && adduser -D -s /bin/false -H -u $BUILD_UID -G radicale radicale \
    && mkdir -p /config /data && chmod -R 770 /data && chown -R radicale:radicale /data \
    && rm -fr /root/.cache
HEALTHCHECK --interval=30s --retries=3 CMD curl --fail http://localhost:5232 || exit 1
VOLUME /config /data
EXPOSE 5232
COPY config /config/config
COPY update_config_from_env.py /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/venv/bin/radicale", "--config", "/config/config"]
```
- No WORKDIR, no USER. Privilege drop presumably in docker-entrypoint.sh (su-exec installed); that script was not fetched.
- Base alpine:3 (floating major). pip packages unpinned except radicale.

## Runtime deps
- Python 3 venv at /venv; packages radicale==3.9.2, passlib[bcrypt], argon2-cffi, pytz, ldap3; system: curl, git, openssh-client-default, shadow, su-exec, tzdata, wget.

## Env vars
- `VERSION` (default 3.9.2), `BUILD_UID` (2999), `BUILD_GID` (2999), `TAKE_FILE_OWNERSHIP` (true; set false to skip chown). `UID`/`GID` runtime override (per Docker Hub page, incompatible with read-only).
- `RADICALE_CONFIG` is not set in this image; CMD passes `--config /config/config`.

## Ports
- 5232 (EXPOSE).

## Volumes/paths
- `/config` (custom config; CMD reads `/config/config`), `/data` (data; collections at `/data/collections` per Docker Hub page).

## User/UID
- Default user and group radicale, uid/gid 2999 (build args). Chart runs as 2999 (see truecharts-radicale.md).

## Healthcheck
- `curl --fail http://localhost:5232` every 30s, 3 retries.

## Version/release info
- Image tag scheme: `<radicale version>.<increment>` per Docker Hub page (example `3.0.6.0`), plus arch prefix tags on the Docker Hub page for older examples. Draft uses wrapper tag `3.9.2.0`.
