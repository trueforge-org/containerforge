FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Release tarball, verified against the checksums.txt asset of the v6.18.0 release (plan section 1).
# The upstream image is alpine (musl). This is a static Go build, so it is used on glibc ubuntu instead.
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) ARCH=x86_64; SHA256=e675f829a0fb85774ff6040f14b982cb78a8bbd8c3cbe5099cbdaf2615af98a2 ;; \
    arm64) ARCH=arm64; SHA256=a5ffd3e136aea3b213ef432791fea85e91df6b27af0ff5ce3d0eae3e954d32d4 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/ddns-go.tar.gz \
    "https://github.com/jeessy2/ddns-go/releases/download/v${VERSION}/ddns-go_${VERSION}_linux_${ARCH}.tar.gz"; \
  echo "${SHA256}  /tmp/ddns-go.tar.gz" | sha256sum -c -; \
  mkdir -p /tmp/ddns-go-extract /app /usr/share/licenses/ddns-go; \
  tar xzf /tmp/ddns-go.tar.gz -C /tmp/ddns-go-extract; \
  install -m 0755 /tmp/ddns-go-extract/ddns-go /app/ddns-go; \
  # UNVERIFIED: the LICENSE member path inside the tarball. Check with `tar tzf` in the build step.
  install -m 0644 /tmp/ddns-go-extract/LICENSE /usr/share/licenses/ddns-go/LICENSE; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9876
VOLUME /config
