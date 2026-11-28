
# UNVERIFIED: the ubuntu:26.04 digest comes from plan.md section 3; confirm it on ghcr.io before the first build.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG BUILD
ARG TARGETARCH

ENV HOME=/config

USER root

# The tarball bundles its own Temurin 21 JDK, so no java base or apt packages are needed.
RUN echo "*** Installing Nexus Repository OSS ***" && \
  case "${TARGETARCH}" in \
    amd64) NEXUS_ARCH=x86_64 ;; \
    arm64) NEXUS_ARCH=aarch_64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  U="https://download.sonatype.com/nexus/3/nexus-${VERSION}-${BUILD}-linux-${NEXUS_ARCH}.tar.gz" && \
  curl -fsSL -o /tmp/nexus.tar.gz "${U}" && \
  echo "$(curl -fsSL "${U}.sha256" | awk '{print $1}')  /tmp/nexus.tar.gz" | sha256sum -c - && \
  tar -xzf /tmp/nexus.tar.gz -C /app && \
  mv "/app/nexus-${VERSION}-${BUILD}" /app/nexus && \
  rm -rf /app/sonatype-work/nexus3 /tmp/nexus.tar.gz && \
  ln -s /config /app/sonatype-work/nexus3 && \
  echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/nexus-oss && \
  cp /app/nexus/OSS-LICENSE.txt /app/nexus/NOTICE.txt /usr/share/licenses/nexus-oss/ && \
  echo "*** Making /app read-only for the runtime user ***" && \
  chown -R root:root /app && \
  chmod -R a+rX /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8081

VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
