# UNVERIFIED (draft): the upstream image is Alpine with s6-overlay. This draft runs nginx and php-fpm on ubuntu as apps.
# The app version follows docker-bake.hcl (5.1.1). The plan originally pinned 5.0.0.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TASMOADMIN_SHA256=""
USER root

ENV HOME=/config \
  TASMO_DATADIR=/config/data/ \
  TASMO_TMPDIR=/tmp/tasmoadmin/

# UNVERIFIED: nginx and PHP 8.5 package names on ubuntu 26.04 (plan section 3). php8.5 matches apps/phpmyadmin.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm \
    php8.5-curl \
    php8.5-mbstring \
    php8.5-xml \
    php8.5-zip && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no upstream checksum is published. TASMOADMIN_SHA256 must come from a verified download. The build fails while it is unset.
# UNVERIFIED: the tarball's top-level directory (strip-components=1 assumed).
RUN set -eux; \
  test -n "${TASMOADMIN_SHA256}" || { echo "TASMOADMIN_SHA256 is not set" >&2; exit 1; }; \
  curl -fsSL -o /tmp/tasmoadmin.tar.gz "https://github.com/TasmoAdmin/TasmoAdmin/releases/download/v${VERSION}/tasmoadmin_v${VERSION}.tar.gz"; \
  echo "${TASMOADMIN_SHA256}  /tmp/tasmoadmin.tar.gz" | sha256sum -c -; \
  mkdir -p /var/www/tasmoadmin; \
  tar xzf /tmp/tasmoadmin.tar.gz -C /var/www/tasmoadmin --strip-components=1; \
  rm -f /tmp/tasmoadmin.tar.gz

# UNVERIFIED: the app's data directory and how the app picks it (plan section 1 and 7). Assumed: the app reads ./data.
RUN rm -rf /var/www/tasmoadmin/data && \
  ln -s /config/data /var/www/tasmoadmin/data && \
  install -D /var/www/tasmoadmin/LICENSE /usr/share/licenses/tasmoadmin/LICENSE && \
  chown -R apps:apps /var/www/tasmoadmin && \
  chmod -R 755 /var/www/tasmoadmin

USER apps
COPY --chmod=0755 . /

# nginx and php-fpm configs are rendered to /tmp by start.sh, because /etc is read-only for apps.
EXPOSE 8080
VOLUME /config
