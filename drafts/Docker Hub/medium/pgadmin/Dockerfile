FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV PIP_CACHE_DIR=/tmp/pip-cache \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# UNVERIFIED: libmagic1 is inferred from upstream, drop it if ldd shows no need
RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libmagic1 \
    libpq5 && \
  echo "**** install pgadmin ****" && \
  mkdir -p /app/pgadmin && \
  /usr/local/bin/python -m venv /app/pgadmin/venv && \
  # UNVERIFIED: pin the PyPI sha256 for pgadmin4 with --require-hashes (not read yet)
  /app/pgadmin/venv/bin/pip install --no-cache-dir \
    "pgadmin4==${VERSION}" \
    gunicorn==23.0.0 && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/pgadmin && \
  curl -fL -o /usr/share/licenses/pgadmin/LICENSE \
    "https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-$(echo "${VERSION}" | tr . _)/LICENSE" && \
  chown -R root:root /app/pgadmin && \
  chmod -R 755 /app/pgadmin && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5050
VOLUME /config
WORKDIR /config
