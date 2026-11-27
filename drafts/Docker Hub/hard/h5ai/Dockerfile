FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION
ARG H5AI_SHA256
USER root

# UNVERIFIED: php8.5-exif is not confirmed as a separate package (exif may ship in php8.5-common)
RUN echo "*** Installing PHP and media tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.5-fpm php8.5-cli php8.5-gd php8.5-xml php8.5-mbstring php8.5-intl php8.5-zip php8.5-imagick \
    ffmpeg imagemagick zip unzip && \
  rm -rf /var/lib/apt/lists/*

# H5AI_SHA256 is manually maintained (renovate cannot update it) and must match h5ai-${VERSION}.zip.
# UNVERIFIED: value not yet known; the build fails until it is set in docker-bake.hcl.
RUN echo "*** Installing h5ai ${VERSION} ***" && \
  curl -fsSL -o /tmp/h5ai.zip \
    "https://github.com/lrsjng/h5ai/releases/download/v${VERSION#v}/h5ai-${VERSION#v}.zip" && \
  echo "${H5AI_SHA256}  /tmp/h5ai.zip" | sha256sum -c - && \
  mkdir -p /app/h5ai && \
  unzip -q /tmp/h5ai.zip -d /app/h5ai && \
  # Writable state goes to /tmp (created by start.sh); /app stays read-only at runtime.
  # UNVERIFIED: cache and conf directory names inside the zip (check with unzip -l)
  mkdir -p /app/h5ai/_h5ai/private/conf && \
  rm -rf /app/h5ai/_h5ai/public/cache /app/h5ai/_h5ai/private/cache && \
  ln -s /tmp/h5ai/public-cache /app/h5ai/_h5ai/public/cache && \
  ln -s /tmp/h5ai/private-cache /app/h5ai/_h5ai/private/cache && \
  # Options live in /config; the link target may not exist yet, h5ai then uses built-in defaults (UNVERIFIED)
  rm -f /app/h5ai/_h5ai/private/conf/options.json && \
  ln -s /config/options.json /app/h5ai/_h5ai/private/conf/options.json && \
  # UNVERIFIED: LICENSE path inside the zip
  install -d /usr/share/licenses/h5ai && \
  cp /app/h5ai/LICENSE* /usr/share/licenses/h5ai/ && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/h5ai.zip

USER apps
COPY --chmod=0755 . /

WORKDIR /app/h5ai

EXPOSE 8080

VOLUME /config
