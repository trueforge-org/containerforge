FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# The upstream scratch image is not used: this image needs a glibc binary, a USER apps runtime and /config.
# UNVERIFIED: license file names at tag v${VERSION} (plan.md section 4 step 5). The README names LICENSE-MIT and LICENSE-APACHE on master.
RUN echo "*** Installing static-web-server ***" && \
  case "${TARGETARCH}" in \
    amd64) sws_arch=x86_64 ;; \
    arm64) sws_arch=aarch64 ;; \
    *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  asset="static-web-server-v${VERSION}-${sws_arch}-unknown-linux-gnu.tar.gz" && \
  mkdir -p /tmp/sws /app && \
  cd /tmp/sws && \
  curl -fsSL -o "${asset}" \
    "https://github.com/static-web-server/static-web-server/releases/download/v${VERSION}/${asset}" && \
  curl -fsSL -o SHA256SUM \
    "https://github.com/static-web-server/static-web-server/releases/download/v${VERSION}/static-web-server-v${VERSION}-SHA256SUM" && \
  grep " ${asset}$" SHA256SUM | sha256sum -c - && \
  tar -xzf "${asset}" -C /tmp/sws && \
  install -m 0755 "$(find /tmp/sws -type f -name static-web-server | head -n 1)" /app/static-web-server && \
  mkdir -p /usr/share/licenses/static-web-server && \
  curl -fsSL -o /usr/share/licenses/static-web-server/LICENSE-MIT \
    "https://raw.githubusercontent.com/static-web-server/static-web-server/v${VERSION}/LICENSE-MIT" && \
  curl -fsSL -o /usr/share/licenses/static-web-server/LICENSE-APACHE \
    "https://raw.githubusercontent.com/static-web-server/static-web-server/v${VERSION}/LICENSE-APACHE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/sws

USER apps
COPY --chmod=0755 . /

# Port 8080 instead of the upstream default 80: an unprivileged user cannot bind port 80 (plan.md section 6).
EXPOSE 8080

VOLUME /config
