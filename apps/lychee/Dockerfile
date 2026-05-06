FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:fdcc4e24cd12eed53bb1338ab6dd5651f5326bcbb98920aa3e8f0c8f5c9b2458

ARG VERSION
ARG TARGETARCH

LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.source="https://lycheeorg.github.io/"

USER root

# Install PHP 8.4 and dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg2 && \
  add-apt-repository ppa:ondrej/php && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libimage-exiftool-perl \
    ffmpeg \
    imagemagick \
    jpegoptim \
    php8.4-cli \
    php8.4-fpm \
    php8.4-bcmath \
    php8.4-xml \
    php8.4-dom \
    php8.4-gd \
    php8.4-intl \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-sqlite3 \
    php8.4-zip \
    php8.4-ldap \
    php8.4-curl \
    php8.4-mbstring \
    php8.4-opcache \
    php8.4-redis \
    php-imagick \
    postgresql-client \
    unzip \
    curl && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** configure imagemagick policy ****" && \
  sed -i '/<\/policymap>/i \  <policy domain="coder" rights="read|write" pattern="PDF" \/>' /etc/ImageMagick-6/policy.xml && \
  echo "**** install composer ****" && \
  curl -sS https://getcomposer.org/installer | php8.4 -- --install-dir=/usr/local/bin --filename=composer && \
  update-alternatives --set php /usr/bin/php8.4

WORKDIR /app/www

# Download and extract Lychee
RUN curl -o /tmp/lychee.zip -L \
    "https://github.com/LycheeOrg/Lychee/releases/download/v${VERSION}/Lychee.zip" && \
  unzip -q /tmp/lychee.zip -d /tmp && \
  cp -a /tmp/Lychee/. /app/www/ && \
  rm -rf /tmp/lychee.zip /tmp/Lychee

# Install composer dependencies
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --optimize-autoloader && \
  echo "**** remove bloat ****" && \
  find vendor \( -iname "*.md" -o -iname "test" -o -iname "tests" \) -exec rm -rf {} + 2>/dev/null || true && \
  rm -rf /app/www/storage/framework/cache/data/* \
    /app/www/storage/framework/sessions/* \
    /app/www/storage/framework/views/* \
    /app/www/storage/logs/*

# Configure PHP
RUN echo "upload_max_filesize=128M" > /etc/php/8.4/cli/conf.d/99-lychee.ini && \
  echo "post_max_size=128M" >> /etc/php/8.4/cli/conf.d/99-lychee.ini && \
  echo "memory_limit=1024M" >> /etc/php/8.4/cli/conf.d/99-lychee.ini && \
  echo "max_execution_time=3000" >> /etc/php/8.4/cli/conf.d/99-lychee.ini

# Set up directories and permissions
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    public/dist \
    /config && \
  touch /app/www/public/dist/user.css \
    /app/www/public/dist/custom.js && \
  chown -R apps:apps /app /config && \
  chmod -R 775 storage bootstrap/cache public/dist /config && \
  chmod 644 /app/www/public/dist/user.css /app/www/public/dist/custom.js

# Copy local files
COPY --chmod=0755 . /

USER apps

# Ports and volumes
EXPOSE 8000
VOLUME /config

WORKDIR /config
