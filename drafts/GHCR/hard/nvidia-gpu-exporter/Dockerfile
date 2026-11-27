FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/tmp

# Upstream release asset names use x86_64 for amd64 and arm64 for arm64.
RUN echo "*** Installing NVIDIA GPU Exporter ${VERSION} ***" && \
  case "${TARGETARCH}" in amd64) ARCH=x86_64 ;; arm64) ARCH=arm64 ;; *) exit 1 ;; esac && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/checksums.txt \
    "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/checksums.txt" && \
  curl -fsSL -o /tmp/exporter.tar.gz \
    "https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/nvidia_gpu_exporter_${VERSION}_linux_${ARCH}.tar.gz" && \
  cd /tmp && grep " nvidia_gpu_exporter_${VERSION}_linux_${ARCH}.tar.gz$" checksums.txt | sha256sum -c - && \
  tar -xzf /tmp/exporter.tar.gz -C /tmp nvidia_gpu_exporter && \
  install -m 0755 /tmp/nvidia_gpu_exporter /app/nvidia_gpu_exporter && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/checksums.txt /tmp/exporter.tar.gz /tmp/nvidia_gpu_exporter
# UNVERIFIED: the LICENSE file is not in the tarball and is not fetched yet, so no license file is shipped.
# The exec backend needs nvidia-smi on PATH. The NVIDIA runtime injects it, so the image may not need it.

USER apps
COPY --chmod=0755 . /

EXPOSE 9835
