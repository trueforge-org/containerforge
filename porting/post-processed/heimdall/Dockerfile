
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php84-dom \
    php84-intl \
    php84-opcache \
    php84-pdo_mysql \
    php84-pdo_pgsql \
    php84-pdo_sqlite \
    php84-tokenizer && \
  echo "**** configure nginx ****" && \
  echo 'fastcgi_param  PHP_AUTH_USER      $remote_user; # Heimdall user authorization' >> \
    /etc/nginx/fastcgi_params && \
  echo 'fastcgi_param  PHP_AUTH_PW        $http_authorization; # Heimdall user authorization' >> \
    /etc/nginx/fastcgi_params && \
  echo "**** configure php opcache ****" && \
  echo 'opcache.validate_timestamps=0' >> \
    /etc/php84/conf.d/00_opcache.ini && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php84/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php84/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php84/php-fpm.d/www.conf; fi && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php84/php-fpm.conf && \
  echo "**** install heimdall ****" && \
  mkdir -p \
    /heimdall && \
  curl -o \
    /tmp/heimdall.tar.gz -L \
    "https://github.com/linuxserver/Heimdall/archive/v${VERSION}.tar.gz" && \
  mkdir -p \
    /app/www-tmp && \
  tar xf \
    /tmp/heimdall.tar.gz -C \
    /app/www-tmp --strip-components=1 && \
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
