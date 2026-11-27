FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV PYTHONDONTWRITEBYTECODE=1 \
    HOME=/config

USER root

# Installs into the system site-packages under /usr/local (not /app/venv, which is read-only at runtime).
# The gevent wsgi extra provides sqlite_wsgi. PyPI checksums are not enforced here (see plan section 1).
# UNVERIFIED: gevent on Python 3.15 is not built yet; fall back to sqlite_web if it fails.
RUN pip install --no-cache-dir "sqlite-web[wsgi]==${VERSION}" && \
    mkdir -p /usr/share/licenses/sqlite-web && \
    curl -fsSL -o /usr/share/licenses/sqlite-web/LICENSE "https://raw.githubusercontent.com/coleifer/sqlite-web/${VERSION}/LICENSE" && \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8080
VOLUME /config
