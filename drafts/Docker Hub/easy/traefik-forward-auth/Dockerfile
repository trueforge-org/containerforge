FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
USER root

# The base sets GOPATH=/config/go, so Go state is moved under /tmp. Nothing from this stage is kept except /out.
# UNVERIFIED: the base's Go toolchain must satisfy go.mod (go 1.22). GOTOOLCHAIN=local is set by the base.
ENV \
  GOPATH=/tmp/go \
  GOCACHE=/tmp/go-build \
  CGO_ENABLED=0

# No checksum is published for the source archive. Module checksums are verified against go.sum.
RUN echo "*** Building traefik-forward-auth ***" && \
  curl -fsSL -o /tmp/tfa.tar.gz \
    "https://github.com/thomseddon/traefik-forward-auth/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /build /out && \
  tar xzf /tmp/tfa.tar.gz -C /build --strip-components=1 && \
  cd /build && \
  GOOS=linux GOARCH="${TARGETARCH}" go build -trimpath -ldflags="-s -w" -o /out/traefik-forward-auth ./cmd && \
  cp /build/LICENSE.md /out/LICENSE.md && \
  rm -rf /tmp/tfa.tar.gz /build /tmp/go /tmp/go-build

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

COPY --from=builder --chmod=0755 /out/traefik-forward-auth /app/traefik-forward-auth
COPY --from=builder /out/LICENSE.md /usr/share/licenses/traefik-forward-auth/LICENSE.md

USER apps
COPY --chmod=0755 . /

EXPOSE 4181

VOLUME /config
WORKDIR /config
