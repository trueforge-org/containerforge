# crazy-max/docker-firefox-syncserver Dockerfile

Source URL: https://raw.githubusercontent.com/crazy-max/docker-firefox-syncserver/45fc9e0a5fa863fb109d5f4ae34b5d5e4656ee11/Dockerfile (commit 45fc9e0, fetched 2026-11-27)

## Base
- `FROM --platform=${TARGETPLATFORM:-linux/amd64} python:2.7-alpine3.10` (Python 2.7 on Alpine 3.10)
- LABEL maintainer CrazyMax

## ENV
| Name | Value |
| --- | --- |
| SYNCSERVER_VERSION | 1.8.0 |
| SHA1_COMMIT | 5932c464d70ec9cf0344b1d3e970b3711de6a98e |
| TZ | UTC |
| PUID | 1000 |
| PGID | 1000 |

## Build steps
- Runtime apk: bash, curl, libffi, libressl, libstdc++, mariadb-client, postgresql-client, shadow, su-exec, tzdata
- Build apk (removed after): build-base, gcc, git, libffi-dev, libressl-dev, mariadb-dev, musl-dev, postgresql-dev, python-dev
- `git clone https://github.com/mozilla-services/syncserver app`; `git reset --hard $SHA1_COMMIT`
- `pip install --upgrade --no-cache-dir -r requirements.txt` and `-r dev-requirements.txt`; `pip install psycopg2 pymysql`
- `apk del build-dependencies`; `python ./setup.py develop`
- `COPY entrypoint.sh /entrypoint.sh`
- RUN: chmod +x entrypoint; `mkdir -p /data /opt/syncserver`; `addgroup -g ${PGID} syncserver`; `adduser -u ${PUID} -G syncserver -h /data -s /bin/sh -D syncserver`; `chown -R syncserver. /data /opt/syncserver`

## Ports / volumes / entry
- EXPOSE 5000
- VOLUME ["/data"]
- ENTRYPOINT ["/entrypoint.sh"]
- CMD ["/usr/local/bin/gunicorn", "--paste", "/opt/syncserver/syncserver.ini"]

## User
- No USER directive. Syncserver user created at build time with PUID/PGID (1000:1000 default). entrypoint.sh not fetched.

## Gotchas
- Upstream source is the mozilla-services/syncserver repo pinned by SHA1_COMMIT (no release tarball).
- Python 2.7 and Alpine 3.10 are EOL.
