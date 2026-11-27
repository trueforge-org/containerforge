
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

ENV \
  NPM_CONFIG_CACHE=/tmp/npm \
  SHARP_FORCE_GLOBAL_LIBVIPS=1 \
  npm_config_build_from_source=true

# UNVERIFIED: Ubuntu package names for the upstream alpine vips/heif/raw packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      unzip \
      build-essential \
      python3 \
      libvips-dev \
      libheif-dev \
      libraw-dev \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fL -o /tmp/pigallery2-release.zip \
      "https://github.com/bpatrik/pigallery2/releases/download/${VERSION}/pigallery2-release.zip" \
  && echo "cbfd61b898feee112004ffcf00ef9ed2488d56a98c8863c2f3168d048c0e618c  /tmp/pigallery2-release.zip" | sha256sum -c - \
  && unzip -q /tmp/pigallery2-release.zip -d /tmp/src \
  && rm /tmp/pigallery2-release.zip

# Rebuild native modules (sharp, sqlite) for this architecture instead of trusting the zip's node_modules.
# UNVERIFIED: the release zip ships a package-lock.json; if not, use npm install --omit=dev
WORKDIR /tmp/src
RUN npm ci --omit=dev \
  && rm -rf /tmp/npm

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# UNVERIFIED: Ubuntu runtime package names for the upstream alpine ffmpeg/vips runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
      libvips42 \
      ffmpeg \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/src /app/pigallery2
# UNVERIFIED: LICENSE is present in the release zip (API reports MIT)
RUN mkdir -p /usr/share/licenses/pigallery2 \
  && cp /app/pigallery2/LICENSE /usr/share/licenses/pigallery2/LICENSE \
  && chown -R root:root /app && chmod -R 755 /app

# Upstream data paths remapped to /config (persistent) and /tmp (ephemeral).
# The default-* names are the ones the upstream image sets in its ENV.
ENV \
  NODE_ENV=production \
  PI_DOCKER=true \
  HOME=/config \
  default-Database-dbFolder=/config/db \
  default-Media-folder=/config/images \
  default-Media-tempFolder=/tmp \
  default-Extensions-folder=/config/config/extensions

USER apps
COPY --chmod=0755 . /

WORKDIR /app/pigallery2
# Upstream listens on 80. Non-root cannot bind it, so the port is set in defaults/config.json (UNVERIFIED key).
EXPOSE 8080

VOLUME /config
