
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

# build variables
ARG VERSION
ARG TARGETARCH
USER root

# go build caches go to /tmp, never /config or /app
ENV GOCACHE=/tmp/gocache \
    GOPATH=/tmp/gopath \
    CGO_ENABLED=0

# UNVERIFIED: golang-go on ubuntu 26.04 must satisfy `go 1.27.3` from go.mod. If not, use a pinned golang build stage.
# UNVERIFIED: no checksum fetched for the source tarball; add one once the upstream digest is confirmed.
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends golang-go && \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/external-dns && \
  curl -fL -o /tmp/external-dns-src.tar.gz \
    "https://github.com/kubernetes-sigs/external-dns/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/external-dns-src.tar.gz -C /tmp/external-dns --strip-components=1 && \
  echo "**** compile external-dns ****" && \
  cd /tmp/external-dns && \
  GOOS=linux GOARCH="${TARGETARCH}" go build -trimpath \
    -ldflags="-s -w -X sigs.k8s.io/external-dns/pkg/version.Version=${VERSION}" \
    -o /tmp/external-dns-bin . && \
  install -Dm0644 /tmp/external-dns/LICENSE /usr/share/licenses/external-dns/LICENSE && \
  rm -rf \
    /tmp/external-dns \
    /tmp/external-dns-src.tar.gz \
    /tmp/gocache \
    /tmp/gopath \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add external-dns binary and licence
COPY --from=buildstage --chmod=0755 /tmp/external-dns-bin /app/external-dns
COPY --from=buildstage /usr/share/licenses/external-dns /usr/share/licenses/external-dns

# add local files
USER apps
COPY --chmod=0755 . /

# metrics and health endpoint (chart-defined; see container-test.yaml)
EXPOSE 7979
VOLUME /config
