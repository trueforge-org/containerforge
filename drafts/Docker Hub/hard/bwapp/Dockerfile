# LICENSING BLOCKER (see plan.md section 10): bWAPP is CC BY-NC-ND 4.0. Confirm with the maintainers
# before this image is published. This draft repackages the upstream zip unmodified.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
ARG VERSION
# UNVERIFIED: SHA256 of bWAPPv${VERSION}.zip, computed and pinned at implementation time (no published checksum)
ARG BWAPP_SHA256
USER root
ENV DEBIAN_FRONTEND=noninteractive
# UNVERIFIED: package names and PHP version on ubuntu 26.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends apache2 libapache2-mod-php php-mysql php-gd php-xml php-mbstring php-curl ca-certificates curl unzip \
    && a2dismod mpm_event mpm_worker || true \
    && a2enmod mpm_prefork \
    && rm -rf /var/lib/apt/lists/*
# Apache runtime files go to /tmp (read-only rootfs, non-root)
ENV HOME=/config APACHE_RUN_DIR=/tmp/apache APACHE_LOCK_DIR=/tmp/apache APACHE_PID_FILE=/tmp/apache/apache2.pid APACHE_LOG_DIR=/tmp/apache/log
# UNVERIFIED: download URL (SourceForge direct link) and zip layout (bWAPP/ top-level folder assumed)
RUN set -eux; \
    [ -n "${BWAPP_SHA256}" ] || { echo "BWAPP_SHA256 not pinned" >&2; exit 1; }; \
    curl -fsSL -o /tmp/bwapp.zip "https://downloads.sourceforge.net/project/bwapp/bWAPP/bWAPPv${VERSION}/bWAPPv${VERSION}.zip"; \
    echo "${BWAPP_SHA256}  /tmp/bwapp.zip" | sha256sum -c -; \
    mkdir -p /tmp/bwapp-src /app/www; \
    unzip -q /tmp/bwapp.zip -d /tmp/bwapp-src; \
    cp -a /tmp/bwapp-src/bWAPP/. /app/www/; \
    rm -rf /tmp/bwapp.zip /tmp/bwapp-src; \
    # Writable folders live in /config through symlinks, /app stays read-only
    for d in passwords images documents logs; do \
      rm -rf "/app/www/${d}"; \
      ln -s "/config/bwapp/${d}" "/app/www/${d}"; \
    done; \
    mkdir -p /usr/share/licenses/bwapp; \
    find /app/www -maxdepth 1 -iname 'license*' -exec cp {} /usr/share/licenses/bwapp/ \; ; \
    chown -R root:root /app; \
    chmod -R a+rX /app
# Apache config (listen 8080, no User directive) and PHP overrides, shipped in /defaults
# Copy configuration files into container (defaults/, start.sh)
COPY --chmod=0755 . /

ENV HOME=/config
EXPOSE 8080
VOLUME /config
WORKDIR /config
USER apps
CMD ["/start.sh"]
