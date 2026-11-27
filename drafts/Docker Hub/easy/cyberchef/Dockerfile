# Static CyberChef bundle on the ContainerForge nginx base. No start.sh: the base CMD and its
# docker-entrypoint.d hooks seed /config/nginx.conf and /config/sites/default.conf.
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION

USER root

# The release asset name contains the tagged commit sha, so resolve it from the tag.
# The sha256 comes from the GitHub release page (no checksum file is published).
# UNVERIFIED: git and unzip are present in the base image.
RUN set -eux; \
    commit="$(git ls-remote https://github.com/gchq/CyberChef "refs/tags/${VERSION}^{}" | cut -f1)"; \
    test -n "${commit}"; \
    curl -fsSLo /tmp/cyberchef.zip "https://github.com/gchq/CyberChef/releases/download/${VERSION}/CyberChef_${commit}.zip"; \
    expected="$(curl -fsSL "https://github.com/gchq/CyberChef/releases/expanded_assets/${VERSION}" | grep -o -E 'sha256:[0-9a-f]{64}' | head -n1 | cut -d: -f2)"; \
    test -n "${expected}"; \
    echo "${expected}  /tmp/cyberchef.zip" | sha256sum -c -; \
    rm -rf /usr/share/nginx/html/*; \
    unzip -q /tmp/cyberchef.zip -d /usr/share/nginx/html; \
    cp "/usr/share/nginx/html/CyberChef_${VERSION}.html" /usr/share/nginx/html/index.html; \
    mkdir -p /usr/share/licenses/cyberchef; \
    curl -fsSLo /usr/share/licenses/cyberchef/LICENSE "https://raw.githubusercontent.com/gchq/CyberChef/${VERSION}/LICENSE"; \
    chown -R 568:568 /usr/share/nginx/html; \
    find /usr/share/nginx/html -type d -exec chmod 755 {} +; \
    find /usr/share/nginx/html -type f -exec chmod 644 {} +; \
    rm -f /tmp/cyberchef.zip

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
