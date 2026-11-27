# UNVERIFIED: the vendor .deb targets Ubuntu 24.04 (upstream base); 26.04 dependency resolution is untested
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG VERSION
ARG TARGETARCH
# UNVERIFIED: SHA256 of onlyoffice-documentserver_{amd64,arm64}.deb, computed and pinned at implementation time
ARG ONLYOFFICE_SHA256_AMD64
ARG ONLYOFFICE_SHA256_ARM64
USER root
ENV DEBIAN_FRONTEND=noninteractive DS_DOCKER_INSTALLATION=true DS_PLUGIN_INSTALLATION=false
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl debconf-utils locales netcat-openbsd postgresql-client jq supervisor \
    && rm -rf /var/lib/apt/lists/*
# Accept the msttcorefonts EULA non-interactively, as upstream does
RUN echo "msttcorefonts msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
# Install the vendor .deb (Community edition). policy-rc.d stops services from starting during install.
RUN set -eux; \
    case "${TARGETARCH}" in amd64) sha="${ONLYOFFICE_SHA256_AMD64}" ;; arm64) sha="${ONLYOFFICE_SHA256_ARM64}" ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac; \
    [ -n "${sha}" ] || { echo "ONLYOFFICE_SHA256 not pinned for ${TARGETARCH}" >&2; exit 1; }; \
    curl -fsSL -o /tmp/ds.deb "https://github.com/ONLYOFFICE/DocumentServer/releases/download/v${VERSION}/onlyoffice-documentserver_${TARGETARCH}.deb"; \
    echo "${sha}  /tmp/ds.deb" | sha256sum -c -; \
    printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d; chmod 0755 /usr/sbin/policy-rc.d; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/ds.deb; \
    rm -f /usr/sbin/policy-rc.d /tmp/ds.deb; \
    dpkg-query -W -f='${Version}' onlyoffice-documentserver | grep -q "^${VERSION}"; \
    rm -rf /var/lib/apt/lists/*
# Runtime-written paths move to /config (read-only rootfs). local.json becomes a symlink to /config.
# UNVERIFIED: /etc/onlyoffice/documentserver/nginx/ds.conf and the listen directives in it
RUN set -eux; \
    rm -f /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/default; \
    sed -i -E 's/(listen +(\[::\]:)?)80\b/\18080/' /etc/onlyoffice/documentserver/nginx/ds.conf; \
    rm -f /etc/onlyoffice/documentserver/local.json; \
    ln -s /config/ds/local.json /etc/onlyoffice/documentserver/local.json; \
    rm -rf /var/log/onlyoffice /var/lib/onlyoffice /var/www/onlyoffice/Data; \
    ln -s /config/logs /var/log/onlyoffice; \
    ln -s /config/lib /var/lib/onlyoffice; \
    ln -s /config/data /var/www/onlyoffice/Data; \
    mkdir -p /usr/share/licenses/onlyoffice-document-server; \
    cp /var/www/onlyoffice/documentserver/LICENSE.txt /var/www/onlyoffice/documentserver/3rd-Party.txt /usr/share/licenses/onlyoffice-document-server/ || true
# UNVERIFIED: build-time font and static cache generation (vendor script names) is not in this draft

# Copy configuration files into container (start.sh, scripts/, etc/onlyoffice-ds/)
COPY --chmod=0755 . /

ENV HOME=/config
EXPOSE 8080
VOLUME /config
WORKDIR /config
USER apps
CMD ["/start.sh"]
