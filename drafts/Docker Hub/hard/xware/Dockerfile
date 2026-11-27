
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG XWARE_REF
ARG XWARE_SHA256
ARG TARGETARCH
USER root

# The Xunlei binaries are 32-bit x86 (i386) ELF executables and need the i386 glibc.
# No license exists upstream. See the NOTICE file written below and the plan's licensing blocker.
ENV HOME=/tmp

# UNVERIFIED: i386 package names on ubuntu 26.04 (libc6-i386, lib32z1) were not checked.
RUN echo "*** Installing i386 runtime libraries ***" && \
  if [ "${TARGETARCH}" != "amd64" ]; then echo "xware binaries are x86 only"; exit 1; fi && \
  case "${XWARE_REF}" in "${VERSION}"*) ;; *) echo "VERSION must be a prefix of XWARE_REF"; exit 1 ;; esac && \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bzip2 \
    libc6-i386 \
    lib32z1 \
    procps && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing Xware ***" && \
  curl -fsSL -o /tmp/xware.tar.bz \
    "https://github.com/caiguai/docker-xware/raw/${XWARE_REF}/xware.tar.bz" && \
  echo "${XWARE_SHA256}  /tmp/xware.tar.bz" | sha256sum -c - && \
  mkdir -p /app/xware && \
  tar xjf /tmp/xware.tar.bz -C /app/xware && \
  rm -rf /app/xware/cfg /app/xware/TDDOWNLOAD && \
  ln -s /config/cfg /app/xware/cfg && \
  ln -s /config/TDDOWNLOAD /app/xware/TDDOWNLOAD && \
  echo "*** Writing NOTICE ***" && \
  mkdir -p /usr/share/licenses/xware && \
  printf '%s\n' \
    'Xware binaries (portal, vod_httpserver, ETMDaemon, EmbedThunderManager) are from' \
    "https://github.com/caiguai/docker-xware at commit ${XWARE_REF}." \
    'Proprietary Xunlei software. No license file upstream; redistribution rights not established.' \
    "Archive sha256: ${XWARE_SHA256}" \
    > /usr/share/licenses/xware/NOTICE && \
  echo "*** Cleaning Up ***" && \
  chown -R root:root /app && chmod -R a+rX /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /


EXPOSE 9000

VOLUME /config

WORKDIR /app/xware
CMD ["/start.sh"]
