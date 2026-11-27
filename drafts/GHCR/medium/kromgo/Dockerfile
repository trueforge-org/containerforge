
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
# UNVERIFIED: sha256 of the tag tarball, computed once by the maintainer. No checksum is published upstream.
ARG KROMGO_SHA256
# UNVERIFIED: pnpm version, take it from the upstream Dockerfile ARG PNPM_VERSION.
ARG PNPM_VERSION
USER root

ENV \
  HOME=/tmp \
  GOPATH=/tmp/go \
  GOCACHE=/tmp/go-build \
  GOMODCACHE=/tmp/go/pkg/mod

RUN echo "*** Fetching kromgo ${VERSION} ***" && \
  : "${KROMGO_SHA256:?KROMGO_SHA256 must be set}" && \
  curl -fL -o /tmp/kromgo.tar.gz \
    "https://github.com/home-operations/kromgo/archive/refs/tags/${VERSION}.tar.gz" && \
  echo "${KROMGO_SHA256}  /tmp/kromgo.tar.gz" | sha256sum -c - && \
  mkdir -p /build/kromgo && \
  tar xzf /tmp/kromgo.tar.gz -C /build/kromgo --strip-components=1 && \
  rm /tmp/kromgo.tar.gz

WORKDIR /build/kromgo

# Node and Go (>= 1.27, go.mod says 1.27.0) come from the ubuntu base.
RUN echo "*** Building kromgo ${VERSION} ***" && \
  : "${PNPM_VERSION:?PNPM_VERSION must be set}" && \
  npm install --global --ignore-scripts pnpm@${PNPM_VERSION} && \
  pnpm install --frozen-lockfile --store-dir /tmp/pnpm-store && \
  go run ./cmd/genassets && \
  CGO_ENABLED=0 go build -trimpath \
    -ldflags "-s -w -X main.Version=${VERSION}" \
    -o /out/kromgo ./cmd/kromgo

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV \
  HOME=/config

COPY --from=builder /out/kromgo /app/kromgo
COPY --from=builder /build/kromgo/LICENSE /usr/share/licenses/kromgo/LICENSE

RUN chown apps:apps /app/kromgo && chmod 0755 /app/kromgo

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 8081

VOLUME /config
