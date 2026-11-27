FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG VENDOR
ARG TARGETARCH
USER root

# Static release tarballs from amule-org/amule, sha256 from the GitHub release asset digests.
# Tarball layout is UNVERIFIED: binaries are located with find.
RUN \
  echo "**** fetch and verify ****" && \
  case "${TARGETARCH}" in \
    amd64) ARCH=x64; SHA256=f78bbe4b2dd765a02c267ef36be4970e1d3c0d2e02b86727f188e3e4042d3567 ;; \
    arm64) ARCH=arm64; SHA256=8348f84aa074d5b53518077882c04164a76fa81eb9842365ab4298e65427d0b1 ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/amule.tar.gz \
    "https://github.com/amule-org/amule/releases/download/${VERSION}/aMule-${VERSION}-Linux-${ARCH}-static.tar.gz" && \
  echo "${SHA256}  /tmp/amule.tar.gz" | sha256sum -c - && \
  mkdir -p /tmp/amule-extract && \
  tar -xzf /tmp/amule.tar.gz -C /tmp/amule-extract && \
  echo "**** install binaries ****" && \
  for bin in amuled amuleweb amulecmd; do \
    found="$(find /tmp/amule-extract -type f -name "${bin}" | head -n 1)"; \
    test -n "${found}"; \
    install -m 0755 "${found}" "/usr/local/bin/${bin}"; \
  done && \
  echo "**** licence ****" && \
  mkdir -p /usr/share/licenses/amule && \
  lic="$(find /tmp/amule-extract -maxdepth 3 -type f -iname 'COPYING*' | head -n 1)" && \
  test -n "${lic}" && \
  install -m 0644 "${lic}" /usr/share/licenses/amule/COPYING && \
  echo "**** config dir ****" && \
  install -d -o apps -g apps /config && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

ENV HOME=/config

# ports: 4711 web (amuleweb), 4712 remote GUI, 4662 ed2k tcp, 4665 and 4672 ed2k udp
EXPOSE 4711/tcp 4712/tcp 4662/tcp 4665/udp 4672/udp

# copy local files
USER apps
COPY --chmod=0755 . /

VOLUME /config

WORKDIR /config
