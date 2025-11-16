
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG VERSION

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php84-ftp \
    php84-gd \
    php84-intl \
    php84-ldap \
    php84-mysqli \
    php84-pdo_mysql \
    php84-pdo_sqlite \
    php84-sqlite3 \
    php84-tokenizer && \
  echo "**** install xbackbone ****" && \
    mkdir -p /app/www/public && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/SergiX44/XBackBone/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/xbackbone.zip -L \
    "https://github.com/SergiX44/XBackBone/releases/download/${VERSION}/release-v${VERSION}.zip" && \
  unzip -q -o /tmp/xbackbone.zip -d /app/www/public/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
