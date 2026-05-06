
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:0ddd714cd20cf10c41ba76066e9579cfc785579f1b801c3656b4bc0ceb151442

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    software-properties-common && \
  add-apt-repository ppa:ondrej/php -y && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.4-xml \
    php8.4-gd \
    php8.4-intl \
    php8.4-fpm \
    composer \
    php8.4-zip \
    php8.4-sqlite3 && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.4/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.4/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.4/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.4/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.4/fpm/php-fpm.conf; fi && \
  echo "**** install cops ****" && \
  curl -fL -o \
    /tmp/cops.tar.gz \
    "https://github.com/mikespub-org/seblucas-cops/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/cops.tar.gz \
    "https://github.com/mikespub-org/seblucas-cops/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p \
    /app/www/public && \
  tar xf /tmp/cops.tar.gz -C \
    /app/www/public --strip-components=1 && \
  cd /app/www/public && \
  composer \
    install --no-dev --optimize-autoloader && \
  echo "***install kepubify" && \
  if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
    KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /usr/bin/kepubify -L \
    "https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit" && \
  chmod 755 /usr/bin/kepubify && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* && \
  apt-get clean && rm -rf /var/lib/apt/lists/*


# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
