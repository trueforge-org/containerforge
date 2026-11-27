FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

# set version label
ARG VERSION
USER root

# Build stage: fetch the source, install PHP and Node dependencies and build the frontend.
# UNVERIFIED: PHP 8.5 package names for gnupg, imagick and mailparse, and whether composer.json accepts PHP 8.5 (upstream tests on 8.4).
# UNVERIFIED: Node major on ubuntu 26.04 against package.json engines.
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    composer \
    curl \
    git \
    nodejs \
    npm \
    php8.5-cli \
    php8.5-curl \
    php8.5-gd \
    php8.5-gmp \
    php8.5-gnupg \
    php8.5-imagick \
    php8.5-intl \
    php8.5-mailparse \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-redis \
    php8.5-xml \
    php8.5-zip && \
  echo "**** fetch anonaddy ****" && \
  mkdir -p /build && \
  curl -fL -o /tmp/anonaddy.tar.gz \
    "https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/anonaddy.tar.gz -C /build --strip-components=1 && \
  echo "**** install PHP and frontend dependencies ****" && \
  cd /build && \
  COMPOSER_HOME=/tmp/composer composer install --no-dev --optimize-autoloader --no-interaction --no-progress --no-scripts && \
  npm ci --ignore-scripts --no-audit --no-fund --cache /tmp/npm && \
  npm run production && \
  rm -rf node_modules && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

ENV \
  HOME=/config \
  GNUPGHOME=/config/gnupg

# Runtime stage: web tier only (nginx, php-fpm). Postfix and rspamd are not part of this image.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-gmp \
    php8.5-gnupg \
    php8.5-imagick \
    php8.5-intl \
    php8.5-mailparse \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-redis \
    php8.5-xml \
    php8.5-zip && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /build /app/www

RUN \
  echo "**** prepare application paths ****" && \
  mkdir -p /usr/share/licenses/anonaddy && \
  cp /app/www/LICENSE /usr/share/licenses/anonaddy/LICENSE && \
  rm -rf /app/www/.git /app/www/tests /app/www/storage /app/www/bootstrap/cache /app/www/.env && \
  ln -s /config/storage /app/www/storage && \
  ln -s /tmp/bootstrap-cache /app/www/bootstrap/cache && \
  ln -s /config/.env /app/www/.env && \
  chown -R apps:apps /app && \
  chmod -R a+rX /app && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8000
VOLUME /config
WORKDIR /app/www
CMD ["/start.sh"]
