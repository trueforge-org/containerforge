# build stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
# matches the upstream default for the WASM analyzer API version
ARG WASM_API_VER=v3
USER root

ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go \
    GOMODCACHE=/tmp/go/pkg/mod

RUN \
  echo "**** fetch source ****" && \
  mkdir -p /tmp/go-playground && \
  curl -fL -o \
    /tmp/src.tar.gz \
    "https://github.com/x1unix/go-playground/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/src.tar.gz -C \
    /tmp/go-playground --strip-components=1

# UNVERIFIED: upstream also sets VITE_GO_VERSION and VITE_PREV_GO_VERSION; base Node and Go versions are untested
RUN \
  echo "**** build ui ****" && \
  cd /tmp/go-playground/web && \
  export NODE_ENV=production \
    VITE_VERSION="${VERSION}" \
    VITE_GITHUB_URL="https://github.com/x1unix/go-playground" \
    VITE_WASM_API_VER="${WASM_API_VER}" \
    VITE_WASM_BASE_URL=/wasm && \
  yarn install --silent && \
  yarn build

RUN \
  echo "**** build server and wasm analyzer ****" && \
  cd /tmp/go-playground && \
  go build -ldflags="-X 'main.Version=${VERSION}'" -o ./server ./cmd/playground && \
  GOOS=js GOARCH=wasm go build -o ./analyzer@${WASM_API_VER}.wasm ./cmd/wasm/analyzer && \
  mkdir -p ./data && \
  go run ./tools/pkgindexer imports -o ./data/imports.json && \
  go run ./tools/pkgindexer index -o ./data/go-index.json

RUN \
  echo "**** assemble app ****" && \
  mkdir -p \
    /app/go-playground/public/wasm \
    /app/go-playground/public/data && \
  cp -r /tmp/go-playground/web/build/. /app/go-playground/public/ && \
  cp /tmp/go-playground/server /app/go-playground/server && \
  cp /tmp/go-playground/*.wasm /app/go-playground/public/wasm/ && \
  # UNVERIFIED: upstream also copies its *.js files (likely wasm_exec.js) into public/wasm; not reproduced yet
  cp -r /tmp/go-playground/data/. /app/go-playground/public/data/ && \
  chmod -R 755 /app/go-playground && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/src.tar.gz \
    /tmp/go-cache \
    /tmp/go \
    /root/.cache \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# the server compiles user code, so the Go toolchain from the base image is needed at runtime
ENV GOROOT=/usr/local/go \
    PATH=/usr/local/go/bin:${PATH} \
    GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go \
    APP_CLEAN_INTERVAL=10m \
    APP_DEBUG=false \
    APP_PLAYGROUND_URL=https://go.dev/_ \
    APP_GTAG_ID=""

COPY --from=build /app/go-playground/ /app/go-playground/

# add license from the build stage
COPY --from=build /tmp/go-playground/LICENSE /usr/share/licenses/go-playground/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8000
VOLUME /config
