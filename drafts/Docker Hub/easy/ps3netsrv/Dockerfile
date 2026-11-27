
# Build stage: amd64 uses the upstream static binary, arm64 is compiled from the tag tarball.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: checksums are pinned from the plan for VERSION 20261110. Bump them together with VERSION.
ARG ZIP_SHA256=47b8cb4dfdd6aabad011cefaf4e27e36e4f2d3d4e796b76472fc0b86b296b081
ARG TARBALL_SHA256=1fb045b529ecab451e07b49aac6e15f6558d71fc01ec3e328f0405fddafde90c
USER root

# unzip, curl and dpkg-deb come with the ubuntu base. Only the arm64 compiler is added, in this build stage.
RUN echo "*** Installing build tools (build stage only) ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Building ps3netsrv ${VERSION} for ${TARGETARCH} ***" && \
  mkdir -p /out /tmp/ps3netsrv && \
  case "${TARGETARCH}" in \
    amd64) \
      curl -fsSL -o /tmp/ps3netsrv/linux.zip \
        "https://github.com/aldostools/ps3netsrv/releases/download/${VERSION}/ps3netsrv_${VERSION}_linux.zip" && \
      echo "${ZIP_SHA256}  /tmp/ps3netsrv/linux.zip" | sha256sum -c - && \
      unzip -j /tmp/ps3netsrv/linux.zip "ps3netsrv_${VERSION}/ps3netsrv_ubuntu-latest_amd64.deb" -d /tmp/ps3netsrv && \
      dpkg-deb -x /tmp/ps3netsrv/ps3netsrv_ubuntu-latest_amd64.deb /tmp/ps3netsrv/root && \
      install -D -m 0755 /tmp/ps3netsrv/root/usr/local/bin/ps3netsrv /out/ps3netsrv ;; \
    arm64) \
      curl -fsSL -o /tmp/ps3netsrv/src.tar.gz \
        "https://github.com/aldostools/ps3netsrv/archive/refs/tags/${VERSION}.tar.gz" && \
      echo "${TARBALL_SHA256}  /tmp/ps3netsrv/src.tar.gz" | sha256sum -c - && \
      mkdir -p /tmp/ps3netsrv/src && \
      tar xzf /tmp/ps3netsrv/src.tar.gz -C /tmp/ps3netsrv/src --strip-components=1 && \
      make -C /tmp/ps3netsrv/src -f Makefile.linux BUILD_DATE="${VERSION}" && \
      # UNVERIFIED: the output name ps3netsrv after make -f Makefile.linux is taken from the plan, not run.
      install -D -m 0755 /tmp/ps3netsrv/src/ps3netsrv /out/ps3netsrv ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /out/LICENSE.TXT \
    "https://raw.githubusercontent.com/aldostools/ps3netsrv/${VERSION}/LICENSE.TXT" && \
  rm -rf /tmp/ps3netsrv

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

COPY --from=build /out/ps3netsrv /app/ps3netsrv
COPY --from=build /out/LICENSE.TXT /usr/share/licenses/ps3netsrv/LICENSE.TXT

RUN echo "*** Setting up ps3netsrv ***" && \
  chmod 0755 /app/ps3netsrv && \
  mkdir -p /games /config && \
  chown apps:apps /games /config

USER apps
COPY --chmod=0755 . /

EXPOSE 38008

VOLUME /config
