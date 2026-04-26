## Move to our an own container
FROM ghcr.io/trueforge-org/node:24.15.0@sha256:4bca93d03032d86c7fe416b234838df556eb5d945e1d716dfc98b8fff38470ad

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:fdcc4e24cd12eed53bb1338ab6dd5651f5326bcbb98920aa3e8f0c8f5c9b2458

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libimage-exiftool-perl \
    ffmpeg \
    libgd-dev \
    imagemagick \
    jpegoptim \
    php8.3-bcmath \
    php8.3-xml \
    php8.3-gd \
    php8.3-intl \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-sqlite3 \
    php-imagick \
    php-redis \
    postgresql-client \
    composer && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi; fi && \
  echo "**** install lychee ****" && \
  if [ -z "v${VERSION}" ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/LycheeOrg/Lychee/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/lychee.zip -L \
    "https://github.com/LycheeOrg/Lychee/releases/download/v${VERSION}/Lychee.zip" && \
  unzip -q /tmp/lychee.zip -d /app && \
  mv /app/Lychee /app/www && \
  echo "**** install composer dependencies ****" && \
  composer install \
    -d /app/www \
    --no-interaction \
    --no-dev \
    --prefer-dist && \
  echo "**** remove bloat ****" && \
  find . -wholename '*/[Tt]ests/*' -delete && \
  find . -wholename '*/[Tt]est/*' -delete && \
  rm -rf /app/www/storage/framework/cache/data/* && \
  rm -rf /app/www/storage/framework/sessions/* && \
  rm -rf /app/www/storage/framework/views/* && \
  rm -rf /app/www/storage/logs/* && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer \
    $HOME/.npm

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
