
# Build stage: Next.js standalone build from the tagged source.
# Upstream builds on node:24-slim and runs on node:24-alpine. Both stages here use the python-node base (Node 24 expected, UNVERIFIED: confirm with node -v).
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS builder

# set version label
ARG VERSION
USER root

# do not set CI=true: upstream skips install and build when CI is true
ENV NEXT_TELEMETRY_DISABLED=1

RUN \
  echo "**** fetch source ****" && \
  mkdir -p /src/config && \
  curl -fL -o /tmp/homepage.tar.gz \
    "https://github.com/gethomepage/homepage/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/homepage.tar.gz -C /src --strip-components=1 && \
  rm -f /tmp/homepage.tar.gz && \
  echo "**** install and build ****" && \
  cd /src && \
  corepack enable && \
  corepack prepare pnpm@latest --activate && \
  pnpm install --frozen-lockfile && \
  pnpm run build && \
  rm -rf /tmp/* $HOME/.cache

# final stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

# runtime tree from the standalone output (UNVERIFIED: LICENSE exists at the tag root)
COPY --from=builder /src/.next/standalone /app
COPY --from=builder /src/.next/static /app/.next/static
COPY --from=builder /src/public /app/public
COPY --from=builder /src/LICENSE /usr/share/licenses/homepage/LICENSE

# /app must stay read-only at runtime, so link the writable paths at build time.
# /app/config -> /config matches upstream's runtime symlink. /app/.next/cache -> /tmp (UNVERIFIED that Next writes here at runtime).
RUN \
  echo "**** link writable paths ****" && \
  ln -s /config /app/config && \
  ln -s /tmp/next-cache /app/.next/cache

ENV NODE_ENV=production \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    HOME=/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /app
