FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
# renovate: datasource=pypi depName=flask
ARG FLASK_VERSION=3.1.3
# renovate: datasource=pypi depName=uWSGI
ARG UWSGI_VERSION=2.0.31
USER root

# No upstream checksum; the commit SHA in VERSION is content-addressed.
# UNVERIFIED: uWSGI 2.0.31 compiles against this Python (gcc comes from the base).
RUN \
  echo "**** install shortipy ****" && \
  mkdir -p /app/shortipy /usr/share/licenses/shortipy && \
  curl -fsSL "https://github.com/maschhoff/shortipy/archive/${VERSION}.tar.gz" | tar xz -C /app/shortipy --strip-components=1 && \
  cp /app/shortipy/LICENSE.md /usr/share/licenses/shortipy/ && \
  pip install --no-cache-dir "flask==${FLASK_VERSION}" "uWSGI==${UWSGI_VERSION}" && \
  rm -rf /app/shortipy/data /app/shortipy/.github /tmp/* && \
  chown -R root:root /app && \
  chmod -R a+rX,go-w /app

COPY --chmod=0755 . /

EXPOSE 4321
WORKDIR /config
VOLUME /config

USER apps
