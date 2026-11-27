# Upstream server image: the only source of the compiled server (venv, Rust binary, web bundle).
# UNVERIFIED: the image tag is not checked against the registry and no digest is pinned yet.
ARG VERSION
FROM ghcr.io/goauthentik/server:${VERSION} AS upstream

# UNVERIFIED BLOCKER: upstream venv is built for Python 3.14.10 under the upstream image paths.
# This base is Python 3.14.8 (same minor, used by other apps in this repo). The venv interpreter
# symlinks may point at upstream paths and must be checked after the first build.
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

ARG VERSION
USER root

# Runtime libraries from the upstream final stage. UNVERIFIED package names on this base.
RUN \
    echo "**** install runtime libs ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libkadm5clnt-mit12 \
        libltdl7 \
        libmaxminddb0 \
        libpq5 \
        libxslt1.1 && \
    echo "**** filesystem setup (upstream /certs, /data, /media remapped to /config, see start.sh) ****" && \
    mkdir -p /config /blueprints && \
    ln -s /config/certs /certs && \
    ln -s /config/data /data && \
    ln -s /config/media /media && \
    chown apps:apps /config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Server files from the upstream image. UNVERIFIED: the full list (plan section 4 step 4).
COPY --from=upstream /ak-root/.venv /ak-root/.venv
COPY --from=upstream /authentik /authentik
COPY --from=upstream /lifecycle /lifecycle
COPY --from=upstream /blueprints /blueprints
COPY --from=upstream /web/dist /web/dist
COPY --from=upstream /web/authentik /web/authentik
COPY --from=upstream /bin/authentik /bin/authentik
COPY --from=upstream /geoip /geoip
COPY --from=upstream /manage.py /manage.py
COPY --from=upstream /pyproject.toml /pyproject.toml
COPY --from=upstream /schemas /schemas
COPY --from=upstream /locale /locale
COPY --from=upstream /packages /packages

# License of the core project (MIT). Upstream website/ and authentik/enterprise/ notices go here too.
RUN mkdir -p /usr/share/licenses/authentik && \
    echo "UNVERIFIED: copy the core LICENSE text from the upstream source tree here." > /usr/share/licenses/authentik/NOTICE

ENV TMPDIR=/tmp \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    GOFIPS=1 \
    RUST_BACKTRACE=full \
    HOME=/tmp

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 9000 9443
VOLUME /config
