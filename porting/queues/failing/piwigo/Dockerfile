
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    exiftool \
    ffmpeg \
    imagemagick \
    libheif1 \
    libjpeg-turbo-progs \
    mediainfo \
    php-apcu \
    php8.3-cgi \
    php8.3-common \
    php8.3-curl \
    php8.3-xml \
    php8.3-exif \
    php8.3-gd \
    php8.3-ldap \
    php8.3-mysql \
    php-pear \
    php-imagick \
    php8.3-xsl \
    php8.3-zip \
    poppler-utils \
    re2c && \
  echo "**** modify php-fpm process limits ****" && \
  if [ -f /etc/php83/php-fpm.d/www.conf ]; then sed -i 's/pm.max_children = 5/pm.max_children = 32/' /etc/php83/php-fpm.d/www.conf; fi && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php83/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf; fi && \
  echo "**** download piwigo ****" && \
  mkdir -p /app/www/public && \
  curl -o \
    /tmp/piwigo.zip -L \
    "https://piwigo.org/download/dlcounter.php?code=${VERSION}" && \
  unzip -q /tmp/piwigo.zip -d /tmp && \
  mv /tmp/piwigo/* /app/www/public && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config
VOLUME /gallery

WORKDIR /config
