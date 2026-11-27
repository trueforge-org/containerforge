
# Build stage on the ubuntu base (Go 1.27.4 and node 26.13.1 are in the base).
# UNVERIFIED: upstream v4.4.0 builds the UI with node:24 and the server on golang:1.27-alpine (musl).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
USER root

ENV \
  HOME=/tmp \
  GOPATH=/tmp/go \
  GOCACHE=/tmp/go-build \
  NPM_CONFIG_CACHE=/tmp/npm

RUN echo "*** Fetching Watcharr ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential && \
  rm -rf /var/lib/apt/lists/* && \
  curl -fL -o /tmp/watcharr.tar.gz \
    "https://github.com/sbondCo/Watcharr/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /build/watcharr && \
  tar xzf /tmp/watcharr.tar.gz -C /build/watcharr --strip-components=1 && \
  rm /tmp/watcharr.tar.gz

# Go server. go-sqlite3 needs cgo, as in upstream.
RUN cd /build/watcharr/server && \
  CGO_ENABLED=1 CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux \
  go build -trimpath -ldflags="-s -w" -o /out/watcharr/watcharr .

# UI. Runtime deps are installed in /out/watcharr/ui, as in upstream's runner stage.
RUN cd /build/watcharr && \
  npm install && \
  npm run build && \
  mkdir -p /out/watcharr/ui && \
  cp -r build/. /out/watcharr/ui/ && \
  cp package.json package-lock.json /out/watcharr/ui/ && \
  cd /out/watcharr/ui && \
  npm ci --omit=dev --ignore-scripts

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV \
  HOME=/config \
  WATCHARR_DATA=/config/data \
  PORT=3080 \
  TMPDIR=/tmp

COPY --from=builder /out/watcharr /app/watcharr
COPY --from=builder /build/watcharr/LICENSE /usr/share/licenses/watcharr/LICENSE

RUN chown -R apps:apps /app/watcharr && \
  chmod -R 755 /app/watcharr

USER apps
COPY --chmod=0755 . /

EXPOSE 3080

VOLUME /config
