FROM ghcr.io/trueforge-org/postgresql-client:1.1.0

ARG VERSION
ARG TARGETARCH
USER root
ARG MONICA_RELEASE_GPG_KEY="BDAB0D0D36A00466A2964E85DE15667131EA6018"
ENV MEMORY_LIMIT 512M


RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    bzip2 \
    gpg \
    gpg-agent && \
  apt-get update && apt-get install -y --no-install-recommends \
    memcached \
    php-apcu \
    php8.3-bcmath \
    php8.3-xml \
    php8.3-gd \
    php8.3-gmp \
    php8.3-intl \
    php-memcached \
    php8.3-mysql \
    php-redis \
    php8.3-common \
    php8.3-soap \
    php8.3-xml && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin:/" >> /etc/php83/php-fpm.conf && \
  echo "**** setup php opcache ****" && \
  { \
      echo '[opcache]'; \
      echo 'opcache.enable=1'; \
      echo 'opcache.revalidate_freq=0'; \
      echo 'opcache.validate_timestamps=0'; \
      echo 'opcache.max_accelerated_files=20000'; \
      echo 'opcache.memory_consumption=192'; \
      echo 'opcache.max_wasted_percentage=10'; \
      echo 'opcache.interned_strings_buffer=16'; \
      echo 'opcache.fast_shutdown=1'; \
  } > /etc/php83/conf.d/opcache-recommended.ini; \
  \
  echo 'apc.enable_cli=1' >> /etc/php83/conf.d/docker-php-ext-apcu.ini; \
  \
  { \
      echo 'memory_limit=${MEMORY_LIMIT}'; \
  } > /etc/php83/conf.d/memory-limit.ini && \
  echo "**** install monica ****" && \
  mkdir -p /app/www && \
  curl -s -o \
    /tmp/monica.tar.bz2 -L \
    "https://github.com/monicahq/monica/releases/download/v${VERSION}/monica-v${VERSION}.tar.bz2" && \
  curl -s -o \
    "/tmp/monica.tar.bz2.asc" -L \
    "https://github.com/monicahq/monica/releases/download/v${VERSION}/monica-v${VERSION}.tar.bz2.asc" && \
  export GNUPGHOME="$(mktemp -d)" && \
  gpg --batch -q --keyserver keyserver.ubuntu.com --recv-keys "$MONICA_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver pgp.mit.edu --recv-keys "$MONICA_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver keyserver.pgp.com --recv-keys "$MONICA_RELEASE_GPG_KEY" \
      || gpg --batch -q --keyserver keys.openpgp.org --recv-keys "$MONICA_RELEASE_GPG_KEY" && \
  if ! gpg --batch -q --verify "/tmp/monica.tar.bz2.asc" "/tmp/monica.tar.bz2"; then \
    echo "File signature mismatch" \
    exit 1; \
  fi && \
  tar xf \
    /tmp/monica.tar.bz2 -C \
    /app/www --strip-components=1 && \
  cd /app/www && \
  composer install \
    --no-dev \
    --no-interaction && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

USER apps
COPY . /
COPY ./root /

EXPOSE 80 443

VOLUME /config

WORKDIR /config
