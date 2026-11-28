
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# git commit SHA of TheDavidDelta/lingva-translate (no releases upstream)
ARG VERSION

# UNVERIFIED: Next.js inlines NEXT_PUBLIC_* values at `next build`, so these are build-time values here.
# Set them with docker-bake.hcl variables. Upstream defaults for the theme and languages are UNVERIFIED (README: auto / en).
ARG SITE_DOMAIN=""
ARG FORCE_DEFAULT_THEME=""
ARG DEFAULT_SOURCE_LANG="auto"
ARG DEFAULT_TARGET_LANG="en"

USER root

ENV NEXT_TELEMETRY_DISABLED=1 \
    YARN_CACHE_FOLDER=/tmp/yarn-cache \
    npm_config_cache=/tmp/npm-cache \
    npm_config_update_notifier=false

# build at image time so the runtime does not need a writable /app
RUN echo "*** Installing lingva-translate ${VERSION} ***" && \
  mkdir -p /tmp/src /app/lingva && \
  curl -fsSL -o /tmp/src.tgz "https://github.com/TheDavidDelta/lingva-translate/archive/${VERSION}.tar.gz" && \
  tar -xzf /tmp/src.tgz -C /tmp/src --strip-components=1 && \
  cd /tmp/src && \
  # UNVERIFIED: that the repo pins yarn in package.json (packageManager); otherwise install the yarn the lockfile needs
  corepack enable && \
  yarn install --frozen-lockfile && \
  NEXT_PUBLIC_SITE_DOMAIN="${SITE_DOMAIN}" \
  NEXT_PUBLIC_FORCE_DEFAULT_THEME="${FORCE_DEFAULT_THEME}" \
  NEXT_PUBLIC_DEFAULT_SOURCE_LANG="${DEFAULT_SOURCE_LANG}" \
  NEXT_PUBLIC_DEFAULT_TARGET_LANG="${DEFAULT_TARGET_LANG}" \
  yarn build && \
  cp -a /tmp/src/. /app/lingva/ && \
  rm -rf /app/lingva/.next/cache && \
  ln -s /tmp/next-cache /app/lingva/.next/cache && \
  install -d /usr/share/licenses/lingva && \
  cp /tmp/src/LICENSE /usr/share/licenses/lingva/LICENSE && \
  chown -R root:root /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/lingva
