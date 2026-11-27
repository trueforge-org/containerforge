# Stage 1: build Notea from its release tag. Upstream publishes no binaries or checksums (UNVERIFIED).
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS notea

ARG VERSION
USER root

ENV NEXT_TELEMETRY_DISABLED=1 \
  NODE_OPTIONS=--openssl-legacy-provider \
  YARN_CACHE_FOLDER=/tmp/yarn

RUN \
  echo "**** build notea ${VERSION} ****" && \
  mkdir -p /src /out/notea /out/licenses && \
  curl -fsSL -o /tmp/notea.tar.gz \
    "https://github.com/QingWei-Li/notea/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/notea.tar.gz -C /src --strip-components=1 && \
  rm /tmp/notea.tar.gz && \
  cd /src && \
  corepack enable && \
  yarn install --frozen-lockfile && \
  yarn build && \
  yarn install --production --frozen-lockfile && \
  cp -r public .next node_modules package.json /out/notea/ && \
  (cp /src/next.config.* /out/notea/ 2>/dev/null || true) && \
  cp LICENSE /out/licenses/notea-LICENSE && \
  rm -rf /tmp/*

# Stage 2: build MinIO from its last source tag. Release binaries are no longer served (410 Gone).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS minio

ARG MINIO_VERSION
USER root

RUN \
  echo "**** build minio ${MINIO_VERSION} ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    golang-go && \
  go version && \
  mkdir -p /src /out/licenses && \
  curl -fsSL -o /tmp/minio.tar.gz \
    "https://github.com/minio/minio/archive/refs/tags/${MINIO_VERSION}.tar.gz" && \
  tar xzf /tmp/minio.tar.gz -C /src --strip-components=1 && \
  rm /tmp/minio.tar.gz && \
  cd /src && \
  CGO_ENABLED=0 GOCACHE=/tmp/gocache GOPATH=/tmp/gopath GOFLAGS=-trimpath \
    go build -o /out/minio . && \
  cp LICENSE /out/licenses/minio-LICENSE && \
  (cp NOTICE /out/licenses/minio-NOTICE 2>/dev/null || true) && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# Final stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG MINIO_VERSION
USER root

COPY --from=notea /out/notea /app/notea
COPY --from=notea /out/licenses/ /usr/share/licenses/notea/
COPY --from=minio /out/minio /usr/local/bin/minio
COPY --from=minio /out/licenses/ /usr/share/licenses/minio/

# Next writes its build cache under .next/cache, which must not live in the read-only /app.
RUN \
  rm -rf /app/notea/.next/cache && \
  ln -s /tmp/next-cache /app/notea/.next/cache && \
  chmod -R a+rX /app

ENV HOME=/tmp/home \
  NODE_ENV=production \
  NEXT_TELEMETRY_DISABLED=1 \
  NODE_OPTIONS=--openssl-legacy-provider \
  CONFIG_FILE=/config/notea.yml

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 9000

VOLUME /config

WORKDIR /app/notea
