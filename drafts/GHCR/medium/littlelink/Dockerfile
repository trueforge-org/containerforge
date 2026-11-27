# Upstream: techno-tim/littlelink-server @ e7fa7db (Node standalone build, alpine/musl).
# Adapted: glibc python-node base, source built in /tmp, runtime tree in /app, USER apps.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# NODE_ENV is set only for the runtime, because yarn skips devDependencies under production.
ENV NEXT_TELEMETRY_DISABLED=1

# The source is pinned by commit SHA (no releases or tags upstream).
# The build runs in /tmp, so only the standalone output and static files reach /app.
# UNVERIFIED: Node 24+ is required and the base's node major is not confirmed.
RUN echo "*** Installing littlelink ***" && \
  npm install -g yarn@1.22.22 && \
  mkdir -p /tmp/littlelink /app && \
  curl -fsSL -o /tmp/littlelink.tar.gz \
    "https://github.com/techno-tim/littlelink-server/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/littlelink.tar.gz -C /tmp/littlelink --strip-components=1 && \
  rm /tmp/littlelink.tar.gz && \
  cd /tmp/littlelink && \
  yarn install --frozen-lockfile --network-timeout 600000 --cache-folder /tmp/yarn && \
  yarn build && \
  cp -a .next/standalone/. /app/ && \
  mkdir -p /app/.next && \
  cp -a .next/static /app/.next/static && \
  cp -a public /app/public && \
  install -d /usr/share/licenses/littlelink && \
  cp LICENSE* /usr/share/licenses/littlelink/ && \
  echo "*** Cleaning Up ***" && \
  cd / && \
  rm -rf /tmp/* /tmp/.[!.]* /root/.cache /var/lib/apt/lists/*

ENV NODE_ENV=production \
  HOSTNAME=0.0.0.0 \
  PORT=3000

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

WORKDIR /app
