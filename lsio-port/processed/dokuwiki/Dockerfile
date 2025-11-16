
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG VERSION
ARG DOKUWIKI_RELEASE

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    xmlstarlet && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    imagemagick \
    php84-bz2 \
    php84-dom \
    php84-gd \
    php84-ldap \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite \
    php84-pecl-imagick \
    php84-sqlite3 && \
  echo "**** install dokuwiki ****" && \
  if [ -z ${DOKUWIKI_RELEASE+x} ]; then \
    DOKUWIKI_RELEASE=$(wget https://download.dokuwiki.org/rss -O - 2>/dev/null | \
      xmlstarlet sel -T -t -v '/rss/channel/item[1]/link' | \
      cut -d'-' -f2-4 | cut -d'.' -f1 ); \
  fi && \
  curl -o \
  /tmp/dokuwiki.tar.gz -L \
    "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DOKUWIKI_RELEASE}.tgz" && \
  mkdir -p \
    /app/www/public && \
  tar xf \
    /tmp/dokuwiki.tar.gz -C \
    /app/www/public --strip-components=1 && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
