## Move to our an own container
FROM ghcr.io/sigstore/cosign/cosign:latest@sha256:b29487e48205d875c324c79583e2806d9d269c0fa299e0861bbec023d8430c8b AS cosign-bin

FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN --mount=type=bind,from=cosign-bin,source=/ko-app/cosign,target=/usr/local/bin/cosign \
    --mount=type=bind,source=/lychee.pub,target=/config/lychee.pub \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libimage-exiftool-perl \
    ffmpeg \
    libgd-dev \
    imagemagick \
    jpegoptim \
    php8.4-bcmath \
    php8.4-xml \
    php8.4-gd \
    php8.4-intl \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-sqlite3 \
    php-imagick \
    php-redis \
    php-sodium \
    postgresql-client && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php84/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php84/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php84/php-fpm.d/www.conf; fi && \
  echo "**** install lychee ****" && \
  if [ -z "v${VERSION}" ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/LycheeOrg/Lychee/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/lychee.zip -L \
    "https://github.com/LycheeOrg/Lychee/releases/download/v${VERSION}/Lychee.zip" && \
  curl -o \
    /tmp/lychee.zip.sigstore.json -L \
    "https://github.com/LycheeOrg/Lychee/releases/download/v${VERSION}/Lychee.zip.sigstore.json" && \
  cosign verify-blob --key /config/lychee.pub --bundle /tmp/lychee.zip.sigstore.json /tmp/lychee.zip && \
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
