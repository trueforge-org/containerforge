
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# Friendica is arch-independent PHP, so TARGETARCH is not used
ARG VERSION
USER root

ENV \
  PHP_MEMORY_LIMIT=512M \
  PHP_UPLOAD_LIMIT=512M \
  HOME=/config

# UNVERIFIED: php8.5 extension package names on ubuntu 26.04 (check with apt-cache policy)
RUN echo "*** Installing PHP, nginx and Friendica dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bzip2 \
    gnupg \
    mariadb-client \
    msmtp-mta \
    nginx \
    php8.5-apcu \
    php8.5-bcmath \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-gmp \
    php8.5-imagick \
    php8.5-intl \
    php8.5-ldap \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-redis \
    php8.5-xml \
    php8.5-zip \
    rsync

# UNVERIFIED: tarball layout (assumed to have one top-level directory, hence --strip-components=1)
# UNVERIFIED: view/smarty3 and proxy directories exist in the tarball
RUN echo "*** Installing Friendica ${VERSION} ***" && \
  export GNUPGHOME="$(mktemp -d)" && \
  curl -fsSL -o /tmp/friendica.tar.gz \
    "https://files.friendi.ca/friendica-all-in-one-${VERSION}.tar.gz" && \
  curl -fsSL -o /tmp/friendica.tar.gz.asc \
    "https://files.friendi.ca/friendica-all-in-one-${VERSION}.tar.gz.asc" && \
  gpg --batch -q --keyserver keyserver.ubuntu.com --recv-keys 08656443618E6567A39524083EE197EF3F9E4287 && \
  gpg --batch -q --verify /tmp/friendica.tar.gz.asc /tmp/friendica.tar.gz && \
  mkdir -p /app/www && \
  tar -xzf /tmp/friendica.tar.gz -C /app/www --strip-components=1 && \
  echo "*** Making writable paths point at /config and /tmp ***" && \
  mv /app/www/config /app/config-dist && \
  ln -s /config/config /app/www/config && \
  ln -s /tmp/smarty3 /app/www/view/smarty3 && \
  ln -s /tmp/proxy /app/www/proxy && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/friendica && \
  cp /app/www/LICENSE* /usr/share/licenses/friendica/ && \
  chmod -R a+rX /app && \
  echo "*** Cleaning Up ***" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
