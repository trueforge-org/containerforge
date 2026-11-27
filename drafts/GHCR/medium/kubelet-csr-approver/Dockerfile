FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
# sha256 of the v${VERSION} source tarball, fetched 2026-11-27 (re-check at build)
ARG KUBELET_CSR_APPROVER_SHA256=7248e09685406e7756c256dbf8f26769f4846de2fcb904c681b36231f63fbd8e
USER root

ENV \
  GOPATH=/tmp/go \
  GOCACHE=/tmp/go-build \
  GOMODCACHE=/tmp/go/pkg/mod \
  GOTOOLCHAIN=local \
  CGO_ENABLED=0

# UNVERIFIED: the ubuntu base provides the Go toolchain (as hishtory-server relies on). go.mod needs go 1.26.0.
RUN go version

RUN curl -fsSL -o /tmp/src.tar.gz "https://github.com/postfinance/kubelet-csr-approver/archive/refs/tags/${VERSION}.tar.gz" && \
    echo "${KUBELET_CSR_APPROVER_SHA256}  /tmp/src.tar.gz" | sha256sum -c - && \
    mkdir -p /build/src && \
    tar xzf /tmp/src.tar.gz -C /build/src --strip-components=1

RUN cd /build/src && \
    go mod download && \
    GOOS=linux GOARCH="${TARGETARCH}" go build \
      -trimpath \
      -ldflags "-s -w" \
      -o /out/kubelet-csr-approver \
      ./cmd/kubelet-csr-approver && \
    rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=builder /out/kubelet-csr-approver /app/kubelet-csr-approver
COPY --from=builder /build/src/LICENSE /usr/share/licenses/kubelet-csr-approver/LICENSE

RUN chown -R root:root /app && \
    chmod -R 755 /app && \
    mkdir -p /config && \
    chown -R apps:apps /config

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

# metrics (8080) and health probe (8081), from upstream internal/cmd defaults
EXPOSE 8080 8081

VOLUME /config

WORKDIR /config
