FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: Ubuntu 26.04 golang-go version. Check the go directive in go.mod at the pinned commit.
RUN echo "*** Installing Go toolchain ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends golang-go ca-certificates curl && \
  rm -rf /var/lib/apt/lists/*

ENV GOCACHE=/tmp/go-cache \
  GOPATH=/tmp/go \
  GOFLAGS=-mod=mod

RUN echo "*** Building plaxt ${VERSION} ***" && \
  mkdir -p /tmp/src /out && \
  curl -fL -o /tmp/plaxt.tar.gz \
    "https://github.com/XanderStrike/goplaxt/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/plaxt.tar.gz -C /tmp/src --strip-components=1 && \
  cd /tmp/src && \
  CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -ldflags="-s -w" -o /out/plaxt .

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV HOME=/config

RUN echo "*** Installing plaxt ***" && \
  mkdir -p /app/plaxt/static /usr/share/licenses/plaxt

COPY --from=buildstage /out/plaxt /app/plaxt/plaxt
COPY --from=buildstage /tmp/src/static /app/plaxt/static
COPY --from=buildstage /tmp/src/LICENSE.txt /usr/share/licenses/plaxt/LICENSE

RUN chown -R apps:apps /app/plaxt && chmod -R 755 /app/plaxt && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config
WORKDIR /config
