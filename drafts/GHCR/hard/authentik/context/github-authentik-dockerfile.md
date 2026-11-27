# authentik upstream container Dockerfile (commit 98ec4a7684fcb0cccfe78888a12df1df1ad938be)

Source URL(s) + date: https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/lifecycle/container/Dockerfile (fetched 2026-11-27)

## Stages
| Stage | Base |
| --- | --- |
| pnpm | ghcr.io/pnpm/pnpm:11.20.0 |
| node-builder | docker.io/library/node:26.12.1-trixie-slim (web UI build, /work/web) |
| geoip | ghcr.io/maxmind/geoipupdate:v8.0.0 (GeoIP DB) |
| rust-toolchain | ghcr.io/goauthentik/fips-debian:trixie-slim-fips |
| uv | ghcr.io/astral-sh/uv:0.13.4 |
| python-base | ghcr.io/goauthentik/fips-python:3.14.10-p1-slim-trixie-fips |
| rust-builder | python-base + rust, builds /bin/authentik (AWS-LC FIPS, clang) |
| python-deps | python-base, `uv sync --locked --no-install-project --no-dev` into /ak-root/.venv |
| final-image | python-base |

- Upstream builds its own Python 3.14.10 venv; the server binary `/bin/authentik` is built from source in rust-builder.
- python-deps: `UV_NO_BINARY_PACKAGE="cryptography lxml python-kadmin-rs xmlsec"`, `UV_PYTHON_DOWNLOADS=0`.

## Final image
- Runtime apt: libpq5 libmaxminddb0 ca-certificates libkadm5clnt-mit12 libkadm5clnt7t64-heimdal libltdl7 libxslt1.1. Purges curl and libcurl4t64.
- User: `adduser --system --no-create-home --uid 1000 --group --home /authentik authentik`. `USER 1000`.
- Dirs: /certs /data /media /blueprints (chown authentik), /data/media -> /media, /authentik/.ssh, /ak-root.
- Copies: /authentik (python package), /lifecycle, /blueprints, /schemas, /locale, /tests, manage.py, pyproject.toml, uv.lock, /bin/authentik, /ak-root/packages, /ak-root/.venv, /web/dist, /web/authentik, /geoip (GeoIP DBs).
- Krb5 config copied to /etc/krb5.conf.
- ENV: TMPDIR=/dev/shm/, PYTHONDONTWRITEBYTECODE=1, PYTHONUNBUFFERED=1, GOFIPS=1, RUST_BACKTRACE=full, VENV_PATH=/ak-root/.venv (python-base), PATH includes /lifecycle and venv bin.
- ARGs: VERSION, GIT_BUILD_HASH (labels, `org.opencontainers.image.version=${VERSION}`).
- WORKDIR /.
- HEALTHCHECK: `--interval=30s --timeout=30s --start-period=120s --retries=3 CMD [ "ak", "healthcheck" ]`.
- ENTRYPOINT: `[ "dumb-init", "--", "ak" ]`. No CMD (chart passes `server` / `worker`).
- No EXPOSE, no VOLUME.

## Gotchas
- Upstream expects /dev/shm for TMPDIR.
- Upstream FIPS base images (fips-python, fips-debian) are used; ContainerForge plan uses ghcr.io/trueforge-org/ubuntu base (see plan).
