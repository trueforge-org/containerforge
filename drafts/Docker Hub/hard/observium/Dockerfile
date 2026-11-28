
# UNVERIFIED: the plan cited ubuntu 26.04 digest f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...; the repo apps use f01a4295... (used by 92 apps), so that digest is used here.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
# UNVERIFIED: upstream publishes no checksum. Value is the sha256 of observium-community-latest.tar.gz inspected 2026-11-24 (plan section 1). Update together with VERSION.
ARG OBSERVIUM_SHA256=01f4bec0bb01c49afe07e26f2b3f79d4eeeabf412ce5f15193df4ed7fc77d715
USER root

# Apt packages are not version-pinned to the app; the app version is pinned by OBSERVIUM_SHA256.
# UNVERIFIED: package names for ubuntu 26.04 (php8.5, php-apcu) and whether the base already ships any of them.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php8.5 \
    php8.5-cli \
    php8.5-mysql \
    php8.5-gd \
    php8.5-bcmath \
    php8.5-mbstring \
    php8.5-curl \
    php8.5-opcache \
    php-apcu \
    php-pear \
    snmp \
    fping \
    rrdtool \
    whois \
    mtr-tiny \
    ipmitool \
    graphviz \
    imagemagick \
    python3 \
    python3-pymysql \
    mariadb-client \
    netcat-openbsd && \
  echo "**** fetch and verify observium ****" && \
  curl -fsSL -o \
    /tmp/observium.tar.gz \
    "https://www.observium.org/observium-community-latest.tar.gz" && \
  echo "${OBSERVIUM_SHA256}  /tmp/observium.tar.gz" | sha256sum -c - && \
  mkdir -p /app && \
  tar xzf \
    /tmp/observium.tar.gz -C \
    /app && \
  # UNVERIFIED: exact format of the VERSION file; check on first build.
  grep -q "${VERSION}" /app/observium/VERSION && \
  echo "**** license files ****" && \
  mkdir -p /usr/share/licenses/observium && \
  cp /app/observium/LICENSE.COMMUNITY /usr/share/licenses/observium/ && \
  echo "**** make tree read-only friendly ****" && \
  rm -rf /app/observium/rrd /app/observium/logs && \
  ln -s /config/rrd /app/observium/rrd && \
  ln -s /config/logs /app/observium/logs && \
  ln -s /config/config.php /app/observium/config.php && \
  chown -R root:root /app && \
  chmod -R a+rX /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# copy local files (etc/observium/apache2.conf, defaults/config.php, start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
