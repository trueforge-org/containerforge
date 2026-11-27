
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  LISTEN_ADDR=0.0.0.0:8080

# Release binary is fetched and verified against the per-asset .sha256 published on the release.
# UNVERIFIED: upstream docs semantics beyond the chart's env usage (see plan.md section 10).
RUN echo "*** Installing Miniflux ***" && \
  case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac && \
  mkdir -p /app/miniflux && \
  curl -fL -o \
    /tmp/miniflux \
    "https://github.com/miniflux/v2/releases/download/${VERSION}/miniflux-linux-${TARGETARCH}" && \
  curl -fL -o \
    /tmp/miniflux.sha256 \
    "https://github.com/miniflux/v2/releases/download/${VERSION}/miniflux-linux-${TARGETARCH}.sha256" && \
  echo "$(cut -d' ' -f1 /tmp/miniflux.sha256)  /tmp/miniflux" | sha256sum -c - && \
  install -D -m 0755 /tmp/miniflux /app/miniflux/miniflux && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/miniflux && \
  curl -fL -o \
    /usr/share/licenses/miniflux/LICENSE \
    "https://raw.githubusercontent.com/miniflux/v2/${VERSION}/LICENSE" && \
  chown -R apps:apps /app/miniflux && chmod -R 755 /app/miniflux && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/miniflux /tmp/miniflux.sha256

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
