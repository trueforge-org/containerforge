# Digest taken from the sibling apps/adguardhome-sync (ubuntu:26.04). The plan's 19cb2ce... digest is not in the repo.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Static Go binary from the upstream release. The sha256 comes from the release's checksums.txt, which is the upstream-published checksum.
RUN case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; esac && \
  curl -fsSL -o /tmp/agh.tar.gz \
    "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${VERSION#v}/AdGuardHome_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o /tmp/checksums.txt \
    "https://github.com/AdguardTeam/AdGuardHome/releases/download/v${VERSION#v}/checksums.txt" && \
  expected="$(awk -v f="./AdGuardHome_linux_${TARGETARCH}.tar.gz" '$2==f {print $1}' /tmp/checksums.txt)" && \
  echo "${expected}  /tmp/agh.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/agh.tar.gz -C /tmp && \
  mkdir -p /app /usr/share/licenses/adguard-home && \
  mv /tmp/AdGuardHome/AdGuardHome /app/AdGuardHome && \
  mv /tmp/AdGuardHome/LICENSE.txt /usr/share/licenses/adguard-home/ && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

# No setcap: a file capability makes exec fail when the container's bounding set lacks NET_BIND_SERVICE.
USER apps
COPY --chmod=0755 . /

EXPOSE 3000/tcp
# DNS ports open only after the setup wizard has written the config
EXPOSE 53/tcp 53/udp
VOLUME /config
