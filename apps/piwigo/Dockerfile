
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:17312da6b52fe7ab6e3bdc8e4a1f99df63c2494b2bad4f4b634a9065d585898e

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
    php8.5-cgi \
    php8.5-common \
    php8.5-curl \
    php8.5-xml \
    php8.5-gd \
    php8.5-ldap \
    php8.5-mysql \
    php-pear \
    php-imagick \
    php8.5-xsl \
    php8.5-zip \
    poppler-utils \
    re2c && \
  echo "**** modify php-fpm process limits ****" && \
  if [ -f /etc/php85/php-fpm.d/www.conf ]; then sed -i 's/pm.max_children = 5/pm.max_children = 32/' /etc/php85/php-fpm.d/www.conf; fi && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php85/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php85/php-fpm.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php85/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php85/php-fpm.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php85/php-fpm.conf; fi && \
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


# ports and volumes
EXPOSE 80 443

VOLUME /config
VOLUME /gallery

WORKDIR /config
