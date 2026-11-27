
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

ENV npm_config_cache=/tmp/npm

# Source tarball only (no release assets, no published checksum)
RUN mkdir -p /app \
  && curl -fsSL -o /tmp/rss.tar.gz \
    "https://github.com/BoKKeR/RSS-to-Telegram-Bot/archive/refs/tags/${VERSION}.tar.gz" \
  && tar xzf /tmp/rss.tar.gz -C /app --strip-components=1 \
  && rm /tmp/rss.tar.gz

# Keep devDependencies: the prisma CLI is run by start_bot.sh at runtime.
# UNVERIFIED: Node 26 builds this Node 16 (NestJS 8, Prisma 3) project; if it fails, record it in the PR.
WORKDIR /app
RUN npm ci \
  && npm run build \
  && rm -rf /tmp/npm

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# start_bot.sh uses the sqlite3 CLI for the legacy database migration
RUN apt-get update && apt-get install -y --no-install-recommends \
      sqlite3 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app

# start_bot.sh writes config/... relative to /app. Point that at /config, which is the only writable path at runtime.
RUN ln -sfn /config /app/config \
  && mkdir -p /usr/share/licenses/rss-to-telegram \
  && cp /app/LICENSE /usr/share/licenses/rss-to-telegram/LICENSE \
  && chown -R root:root /app && chmod -R 755 /app

ENV HOME=/config TZ=Etc/UTC

USER apps
COPY --chmod=0755 . /

WORKDIR /app

VOLUME /config
