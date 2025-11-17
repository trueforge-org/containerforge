
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    php84-gd \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite && \
  echo "**** install librespeed ****" && \
  mkdir -p \
    /app/www/public && \
  curl -o \
    /tmp/librespeed.tar.gz -L \
    "https://github.com/librespeed/speedtest/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/librespeed.tar.gz -C \
    /app/www/public --strip-components=1 && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config
