FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libmagic1 && \
  echo "**** fetch maloja ****" && \
  mkdir -p \
    /tmp/maloja \
    /app/maloja \
    /usr/share/licenses/maloja && \
  curl -fL -o \
    /tmp/maloja.tar.gz \
    "https://github.com/krateng/maloja/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/maloja.tar.gz -C \
    /tmp/maloja --strip-components=1 && \
  echo "**** create venv and install dependencies ****" && \
  /usr/local/bin/python -m venv /app/maloja/venv && \
  /app/maloja/venv/bin/pip install --requirement /tmp/maloja/requirements.txt && \
  /app/maloja/venv/bin/pip install /tmp/maloja && \
  cp /tmp/maloja/LICENSE /usr/share/licenses/maloja/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV MALOJA_DATA_DIRECTORY=/config \
    MALOJA_SKIP_SETUP=yes

# ports and volumes
EXPOSE 42010
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
