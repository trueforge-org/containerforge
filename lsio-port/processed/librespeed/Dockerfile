
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG VERSION

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    php84-gd \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite && \
  echo "**** install librespeed ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/librespeed/speedtest/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
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
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
