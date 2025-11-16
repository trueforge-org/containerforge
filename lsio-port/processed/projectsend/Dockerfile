
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG VERSION

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php84-bcmath \
    php84-bz2 \
    php84-cli \
    php84-dom \
    php84-gd \
    php84-gettext \
    php84-gmp \
    php84-mysqli \
    php84-pdo \
    php84-pdo_dblib \
    php84-pdo_mysql \
    php84-pecl-apcu \
    php84-pecl-memcached \
    php84-soap \
    php84-xmlreader && \
  echo "**** install projectsend ****" && \
  mkdir -p /app/www/public && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -s https://api.github.com/repos/projectsend/projectsend/releases/latest | jq -r '. | .tag_name'); \
  fi && \
  curl -fso \
    /tmp/projectsend.zip -L \
    "https://github.com/projectsend/projectsend/releases/download/${VERSION}/projectsend-${VERSION}.zip" || \
  curl -fso \
    /tmp/projectsend.zip -L \
    "https://github.com/projectsend/projectsend/releases/download/${VERSION}/projectsend.zip" && \
  unzip \
    /tmp/projectsend.zip -d \
    /app/www/public && \
  mv /app/www/public/upload /defaults/ && \
  echo "**** cleanup ****" && \
    rm -rf \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
