
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get add --no-cache \
    exiftool \
    ffmpeg \
    imagemagick \
    imagemagick-heic \
    libjpeg-turbo-utils \
    mediainfo \
    php83-apcu \
    php83-cgi \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-gd \
    php83-ldap \
    php83-mysqli \
    php83-mysqlnd \
    php83-pear \
    php83-pecl-imagick \
    php83-xsl \
    php83-zip \
    poppler-utils \
    re2c && \
  echo "**** modify php-fpm process limits ****" && \
  sed -i 's/pm.max_children = 5/pm.max_children = 32/' /etc/php83/php-fpm.d/www.conf && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf; fi && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf && \
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config
VOLUME /gallery

WORKDIR /config
