FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e

ARG VERSION

ENV \
  OPENHAB_HOME=/app/openhab \
  OPENHAB_CONF=/config/conf \
  OPENHAB_USERDATA=/config/userdata \
  OPENHAB_LOGDIR=/config/userdata/logs \
  OPENHAB_BACKUPS=/config/userdata/backup \
  OPENHAB_HTTP_PORT=8080 \
  OPENHAB_HTTPS_PORT=8443 \
  CRYPTO_POLICY=limited \
  HOME=/config

USER root

# UNVERIFIED: check which of these the java21 base already provides (dpkg -l) before the first build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fontconfig \
        iputils-ping \
        procps && \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: top-level layout of openhab-<version>.tar.gz (flat conf/, runtime/ assumed).
# UNVERIFIED: no checksum is published on the release. A SHA256 for the asset is still to be computed and pinned.
RUN set -eux; \
    mkdir -p /app/openhab /defaults /tmp/openhab; \
    curl -fsSL -o /tmp/openhab/openhab.tar.gz \
        "https://github.com/openhab/openhab-distro/releases/download/${VERSION}/openhab-${VERSION}.tar.gz"; \
    tar -xzf /tmp/openhab/openhab.tar.gz -C /app/openhab; \
    find /app/openhab \( -name '*.bat' -o -name '*.ps1' -o -name '*.psm1' \) -delete; \
    mv /app/openhab/conf /defaults/conf; \
    rm -rf /app/openhab/addons; \
    ln -s /config/addons /app/openhab/addons; \
    mkdir -p /usr/share/licenses/openhab; \
    cp /app/openhab/LICENSE /usr/share/licenses/openhab/; \
    chown -R root:root /app/openhab /defaults; \
    chmod -R 755 /app/openhab /defaults; \
    rm -rf /tmp/openhab

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/openhab
