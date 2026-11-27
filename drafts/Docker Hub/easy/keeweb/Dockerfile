FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION

USER root
WORKDIR /tmp

# Fetch the prebuilt web release, verify it against the upstream checksum,
# and place it in the nginx web root. The architecture-independent zip serves amd64 and arm64.
RUN set -eux; \
    cd /tmp; \
    curl -fsSLO "https://github.com/keeweb/keeweb/releases/download/v${VERSION}/KeeWeb-${VERSION}.html.zip"; \
    curl -fsSLo Verify.sha256 "https://github.com/keeweb/keeweb/releases/download/v${VERSION}/Verify.sha256"; \
    grep " \*KeeWeb-${VERSION}.html.zip\$" Verify.sha256 | sha256sum -c -; \
    rm -rf /usr/share/nginx/html/*; \
    unzip -q "KeeWeb-${VERSION}.html.zip" -d /usr/share/nginx/html; \
    mkdir -p /usr/share/licenses/keeweb; \
    curl -fsSLo /usr/share/licenses/keeweb/LICENSE "https://raw.githubusercontent.com/keeweb/keeweb/v${VERSION}/LICENSE"; \
    chown -R 568:568 /usr/share/nginx/html; \
    find /usr/share/nginx/html -type d -exec chmod 755 {} +; \
    find /usr/share/nginx/html -type f -exec chmod 644 {} +; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /
EXPOSE 8080
VOLUME /config
WORKDIR /usr/share/nginx/html
