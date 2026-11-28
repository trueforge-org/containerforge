
# renovate-tracked via docker-bake.hcl VERSION
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
# UNVERIFIED: signing key URL for the ZoneMinder apt repository, confirm at https://zmrepo.zoneminder.com/
ARG ZM_REPO_KEY_URL=""
USER root

RUN \
  echo "**** install zoneminder apt repository ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg && \
  test -n "${ZM_REPO_KEY_URL}" || { echo "ZM_REPO_KEY_URL is UNVERIFIED, set it before building"; exit 1; } && \
  install -d -m 0755 /etc/apt/keyrings && \
  curl -fsSL "${ZM_REPO_KEY_URL}" | gpg --dearmor -o /etc/apt/keyrings/zoneminder.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/zoneminder.gpg] https://zmrepo.zoneminder.com/debian/release-1.38/resolute/ ./" \
    > /etc/apt/sources.list.d/zoneminder.list && \
  apt-get update && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    zoneminder=${VERSION}+resolute1 \
    apache2 \
    libapache2-mod-php \
    mariadb-client \
    ffmpeg && \
  echo "**** verify pinned version ****" && \
  dpkg-query -W -f='${Version}' zoneminder | grep -q "^${VERSION}" || { echo "zoneminder version mismatch"; exit 1; } && \
  echo "**** configure apache ****" && \
  a2enmod rewrite headers cgi expires && \
  a2dissite 000-default && \
  sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf && \
  sed -i \
    -e 's#/var/run/apache2#/tmp/apache2#g' \
    -e 's#/var/lock/apache2#/tmp/apache2/lock#g' \
    -e 's#/var/log/apache2#/tmp/apache2/log#g' \
    -e 's#^export APACHE_RUN_USER=.*#export APACHE_RUN_USER=apps#' \
    -e 's#^export APACHE_RUN_GROUP=.*#export APACHE_RUN_GROUP=apps#' \
    /etc/apache2/envvars && \
  echo "ServerName localhost" > /etc/apache2/conf-available/containerforge.conf && \
  a2enconf containerforge zoneminder && \
  echo "**** configure php sessions ****" && \
  for ini in /etc/php/*/apache2/php.ini; do \
    sed -i -E 's#^;?[[:space:]]*session\.save_path[[:space:]]*=.*#session.save_path = "/tmp"#' "${ini}"; \
  done && \
  echo "**** relocate zoneminder config and writable paths ****" && \
  mkdir -p /usr/share/zoneminder/conf.d-default && \
  cp -a /etc/zm/conf.d/. /usr/share/zoneminder/conf.d-default/ && \
  rm -rf /etc/zm/conf.d && \
  ln -s /config/zm/conf.d /etc/zm/conf.d && \
  rm -rf /var/log/zm && \
  ln -s /tmp/zm/log /var/log/zm && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/zoneminder && \
  cp /usr/share/doc/zoneminder/copyright /usr/share/licenses/zoneminder/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# copy local files
USER apps
ENV HOME=/config \
    TMPDIR=/tmp
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
