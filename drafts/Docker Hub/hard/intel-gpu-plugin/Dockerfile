
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: the ubuntu base ships Go 1.27 (go.mod says go 1.27.0). Check with `go version` on the first build.
ENV \
  GOCACHE=/tmp/go-build \
  GOPATH=/tmp/go \
  GOFLAGS=-trimpath \
  CGO_ENABLED=0

RUN echo "*** Building Intel GPU device plugin ***" && \
  go version && \
  curl -fsSL -o \
    /tmp/intel-gpu-plugin.tar.gz \
    "https://github.com/intel/intel-device-plugins-for-kubernetes/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /build/src && \
  tar xzf \
    /tmp/intel-gpu-plugin.tar.gz -C \
    /build/src --strip-components=1 && \
  cd /build/src/cmd/gpu_plugin && \
  go build \
    -ldflags "-w -s" \
    -gcflags "all=-spectre=all" \
    -asmflags "all=-spectre=all" \
    -o /out/intel_gpu_device_plugin . && \
  mkdir -p /out/licenses/intel-gpu-plugin && \
  cp /build/src/LICENSE /out/licenses/intel-gpu-plugin/LICENSE && \
  if [ -d /build/src/licenses/gpu_plugin ]; then \
    cp -r /build/src/licenses/gpu_plugin /out/licenses/intel-gpu-plugin/third-party; \
  fi && \
  rm -f /tmp/intel-gpu-plugin.tar.gz

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

COPY --from=builder /out/intel_gpu_device_plugin /app/intel_gpu_device_plugin
COPY --from=builder /out/licenses/intel-gpu-plugin /usr/share/licenses/intel-gpu-plugin

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

VOLUME /config
