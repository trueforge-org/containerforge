
# Draft: UMS is a Java 17 jar. The java17 base already provides the JRE,
# so the upstream openjdk-17-jre-headless package is not installed here.
FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
ARG TARGETARCH

# UNVERIFIED: the upstream flag list was truncated in the fetched copy. Copy it exactly from the upstream Dockerfile for tag ${VERSION}.
ENV JDK_JAVA_OPTIONS="--add-modules=jdk.incubator.vector --add-opens java.base/sun.nio.ch=ALL-UNNAMED -Dfile.encoding=UTF-8 -Djava.net.preferIPv4Stack=true -Djna.nosys=true"

# Profile (UMS.conf and state) lives on /config, replacing upstream /profile.
ENV UMS_PROFILE=/config/profile

USER root

# install needed packages (base already has Java 17 and curl)
# Package versions are not pinned here: ffmpeg is not tied to VERSION.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ffmpeg \
      mediainfo \
      fonts-dejavu \
 && rm -rf /var/lib/apt/lists/* \
 \
 # download the UMS release tarball for this architecture
 # UNVERIFIED: tarball internal layout (top-level folder, jar name); no checksum is published for this release
 && case "${TARGETARCH}" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && mkdir -p /app/ums /tmp/ums-src \
 && curl -fsSL -o /tmp/ums.tgz \
      "https://github.com/UniversalMediaServer/UniversalMediaServer/releases/download/${VERSION}/UMS-Linux-${VERSION}-${arch}.tgz" \
 && tar -xzf /tmp/ums.tgz -C /tmp/ums-src \
 && cp -a /tmp/ums-src/. /app/ums/ \
 && rm -rf /tmp/ums.tgz /tmp/ums-src \
 \
 # license: ship the upstream LICENSE with the software
 && install -d /usr/share/licenses/universal-media-server \
 && if [ -f /app/ums/LICENSE ]; then \
      cp /app/ums/LICENSE /usr/share/licenses/universal-media-server/LICENSE; \
    else \
      curl -fsSL -o /usr/share/licenses/universal-media-server/LICENSE \
        "https://raw.githubusercontent.com/UniversalMediaServer/UniversalMediaServer/${VERSION}/LICENSE"; \
    fi \
 \
 # permissions: /app stays read-only at runtime
 && chown -R root:root /app \
 && chmod -R 755 /app

# run as 568
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]

EXPOSE 9001/tcp 9002/tcp 5001/tcp 5353/udp 1900/udp
