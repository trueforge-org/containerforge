FROM ghcr.io/trueforge-org/node:24.22.0@sha256:b395d720cdb6414b24f023a8ab796f0506644f02c792ca452990d5f05b9db2fd

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
