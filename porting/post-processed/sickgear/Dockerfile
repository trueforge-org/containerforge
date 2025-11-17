
FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# set python to use utf-8 rather than ascii.
ENV PYTHONIOENCODING="UTF-8"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    python3 && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/sickgear/ && \
  curl -o \
    /tmp/sickgear.tar.gz -L \
    "https://github.com/sickgear/sickgear/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/sickgear.tar.gz -C \
    /app/sickgear/ --strip-components=1 && \
  cd /app/sickgear && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r recommended.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache

# copy local files
USER apps
COPY . /
COPY ./root /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8081

VOLUME /config
