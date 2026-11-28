# Source: Python 3 fork https://github.com/bassings/CouchPotatoServer (the original
# CouchPotato/CouchPotatoServer is Python 2 only and archived). Unreviewed draft, not built.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    CP_DOCKER=1

USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    mediainfo \
    7zip && \
  echo "**** install couchpotato ****" && \
  mkdir -p /app/couchpotato /usr/share/licenses/couchpotato && \
  curl -fL -o /tmp/couchpotato.tar.gz \
    "https://github.com/bassings/CouchPotatoServer/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf /tmp/couchpotato.tar.gz -C /app/couchpotato --strip-components=1 && \
  echo "**** install python dependencies ****" && \
  pip install -r /app/couchpotato/requirements.txt && \
  printf "VERSION = '%s'\nBRANCH = 'master'\nBUILD_DATE = 0\n" "${VERSION}" > /app/couchpotato/version.py && \
  cp /app/couchpotato/LICENSE /usr/share/licenses/couchpotato/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/couchpotato/tests \
    /app/couchpotato/QA \
    /app/couchpotato/docs \
    /app/couchpotato/specs \
    /app/couchpotato/.github && \
  chown -R root:root /app/couchpotato && \
  chmod -R a+rX /app/couchpotato && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5050
VOLUME /config

WORKDIR /config
