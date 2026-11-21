FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

# All runtime caches live in /tmp so the image works with a read-only rootfs
ENV DOCUSAURUS_PORT=3000 \
    WEBSITE_NAME="MyWebsite" \
    TEMPLATE="classic" \
    RUN_MODE="development" \
    AUTO_UPDATE="true" \
    npm_config_cache=/tmp/.npm \
    npm_config_update_notifier=false \
    YARN_CACHE_FOLDER=/tmp/.yarn-cache \
    DOCUSAURUS_TELEMETRY_DISABLED=1

# Install the site scaffolder into /app (read-only at runtime)
RUN \
  npm install --no-fund --no-audit --prefix /app/create-docusaurus "create-docusaurus@${VERSION}" && \
  rm -rf /tmp/* "${HOME}/.npm"

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
# First start scaffolds the site and installs its dependencies before serving
HEALTHCHECK --start-period=10m CMD ["/healthcheck.sh"]
VOLUME /config

WORKDIR /config
