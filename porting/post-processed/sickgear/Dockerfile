
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# set python to use utf-8 rather than ascii.
ENV PYTHONIOENCODING="UTF-8"

RUN \
  echo "**** install build packages ****" && \
  apt-get add --no-cache --virtual=build-dependencies \
    build-base && \
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
  apt-get del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache

# copy local files
USER apps
COPY . /
COPY ./root /




# ports and volumes
EXPOSE 8081

VOLUME /config

WORKDIR /config
