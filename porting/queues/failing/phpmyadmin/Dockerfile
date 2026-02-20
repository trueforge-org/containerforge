
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ARG PHPMYADMIN_RELEASE_GPG_KEY="3D06A59ECE730EB71B511C17CE752F178259BD92"
ENV MAX_EXECUTION_TIME=600
ENV MEMORY_LIMIT=512M
ENV UPLOAD_LIMIT=8192K

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    gpg \
    gpg-agent \
    dirmngr && \
  apt-get update && apt-get install -y --no-install-recommends \
    php8.3-bz2 \
    php8.3-xml \
    php8.3-gd \
    php8.3-mysql \
    php8.3-opcache \
    php-uploadprogress && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf; fi && \
  echo "**** setup php opcache ****" && \
  mkdir -p /etc/php/8.3/cli/conf.d && \
  { \
      echo 'opcache.memory_consumption=128'; \
      echo 'opcache.interned_strings_buffer=8'; \
      echo 'opcache.max_accelerated_files=4000'; \
      echo 'opcache.revalidate_freq=2'; \
      echo 'opcache.fast_shutdown=1'; \
  } > /etc/php/8.3/cli/conf.d/opcache-recommended.ini; \
  \
  { \
      echo 'session.cookie_httponly=1'; \
      echo 'session.use_strict_mode=1'; \
  } > /etc/php/8.3/cli/conf.d/session-strict.ini; \
  \
  { \
      echo 'allow_url_fopen=Off'; \
      echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
      echo 'max_input_vars=10000'; \
      echo 'memory_limit=${MEMORY_LIMIT}'; \
      echo 'post_max_size=${UPLOAD_LIMIT}'; \
      echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
  } > /etc/php/8.3/cli/conf.d/phpmyadmin-misc.ini && \
  echo "**** install phpmyadmin ****" && \
  mkdir -p /app/www/public && \
  curl -s -o \
    /tmp/phpmyadmin.tar.xz -L \
    "https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.xz" && \
  curl -s -o \
    "/tmp/phpmyadmin.tar.xz.asc" -L \
    "https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.xz.asc" && \
  export GNUPGHOME="$(mktemp -d)" && \
  if gpg --batch -q --keyserver keyserver.ubuntu.com --recv-keys "$PHPMYADMIN_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver pgp.mit.edu --recv-keys "$PHPMYADMIN_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver keyserver.pgp.com --recv-keys "$PHPMYADMIN_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver keys.openpgp.org --recv-keys "$PHPMYADMIN_RELEASE_GPG_KEY"; then \
    gpg --batch -q --verify "/tmp/phpmyadmin.tar.xz.asc" "/tmp/phpmyadmin.tar.xz"; \
  else \
    echo "Skipping phpMyAdmin GPG verification (keyserver unavailable)"; \
  fi && \
  tar xf \
    /tmp/phpmyadmin.tar.xz -C \
    /app/www/public/ --strip-components=1 && \
  sed -i "s@'configFile' =>.*@'configFile' => '/config/phpmyadmin/config.inc.php',@" "/app/www/public/libraries/vendor_config.php" && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    /app/www/public/setup

USER apps
COPY --chmod=0755 . /
COPY ./root /

EXPOSE 80 443

WORKDIR /config
VOLUME /config
