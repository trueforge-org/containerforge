# grafana-image-renderer 5.12.11 (AGPL-3.0-only) on the ContainerForge ubuntu base.
# The upstream release binary is used as is. Chromium comes from Playwright, not Debian (see the plan: the Ubuntu chromium package is a snap stub).
# Upstream: https://github.com/grafana/grafana-image-renderer (no checksum file; the per-asset digest comes from the GitHub release API at build time).
# UNVERIFIED: Playwright install-deps and install on Ubuntu 26.04, and the font package names. Drop any that do not resolve and record it in the PR.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG PLAYWRIGHT_VERSION

ENV HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/.config \
    XDG_CACHE_HOME=/tmp/.cache \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PLAYWRIGHT_BROWSERS_PATH=/app/browsers \
    CHROME_BIN=/usr/local/bin/chromium

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-liberation fonts-noto-cjk fonts-freefont-ttf fonts-wqy-zenhei fonts-thai-tlwg \
        fonts-kacst-one fonts-unifont fonts-open-sans fonts-roboto fonts-inter libnss3-tools libxss1 && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    [ -n "${PLAYWRIGHT_VERSION}" ] || { echo "PLAYWRIGHT_VERSION is empty"; exit 1; }; \
    npx --yes "playwright@${PLAYWRIGHT_VERSION}" install-deps chromium; \
    npx --yes "playwright@${PLAYWRIGHT_VERSION}" install chromium; \
    chrome="$(find /app/browsers -type f -name chrome -path '*linux*' | head -n 1)"; \
    test -x "${chrome}"; \
    ln -s "${chrome}" /usr/local/bin/chromium; \
    chmod -R a+rX /app/browsers; \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Release binary, verified against the digest the GitHub release API reports for the matching asset.
RUN set -eux; \
    tag="v${VERSION#v}"; \
    asset="grafana-image-renderer-linux-${TARGETARCH}"; \
    sha="$(curl -fsSL "https://api.github.com/repos/grafana/grafana-image-renderer/releases/tags/${tag}" | jq -r --arg n "${asset}" '.assets[] | select(.name == $n) | .digest' | sed 's/^sha256://')"; \
    test -n "${sha}"; \
    curl -fsSL -o /usr/local/bin/grafana-image-renderer "https://github.com/grafana/grafana-image-renderer/releases/download/${tag}/${asset}"; \
    echo "${sha}  /usr/local/bin/grafana-image-renderer" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/grafana-image-renderer

RUN install -d /usr/share/licenses/grafana-image-renderer && \
    curl -fsSL -o /usr/share/licenses/grafana-image-renderer/LICENSE "https://raw.githubusercontent.com/grafana/grafana-image-renderer/v${VERSION#v}/LICENSE"

USER apps
COPY --chmod=0755 . /

WORKDIR /tmp

EXPOSE 8081

VOLUME /config

USER apps
