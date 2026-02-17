
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.3-xml \
    php8.3-gd \
    php8.3-intl \
    composer \
    php8.3-zip \
    php8.3-sqlite3 && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf; fi && \
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
    /root/.composer \
    /tmp/* && \
  apt-get clean && rm -rf /var/lib/apt/lists/*


# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
