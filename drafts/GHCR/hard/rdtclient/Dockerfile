
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# UNVERIFIED: ASP.NET Core 10.0 runtime for glibc. Upstream only ships a musl tarball. Confirm the package name and availability on ubuntu 26.04 (Microsoft feed or archive). If neither works, stop: the app cannot be built on this base.
# UNVERIFIED: the ASPNETCORE_URLS bind address. Remove it if the app already listens on all interfaces.
ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config/xdg \
  ASPNETCORE_URLS=http://0.0.0.0:6500

RUN echo "*** Installing ASP.NET Core runtime and unzip ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    aspnetcore-runtime-10.0 \
    unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Upstream publishes no checksum for this asset.
# UNVERIFIED: the sha256 below must be self-computed from the first download and pinned before merge.
RUN echo "*** Installing RDT Client v${VERSION} ***" && \
  curl -fsSL -o /tmp/RealDebridClient.zip \
    "https://github.com/rogerfar/rdt-client/releases/download/v${VERSION}/RealDebridClient.zip" && \
  mkdir -p /app && \
  unzip -q /tmp/RealDebridClient.zip -d /app && \
  rm /tmp/RealDebridClient.zip && \
  chown -R apps:apps /app && chmod -R 755 /app

# UNVERIFIED: the release zip has no LICENSE file, so it is fetched from the tag.
RUN install -d /usr/share/licenses/rdtclient && \
  curl -fsSL -o /usr/share/licenses/rdtclient/LICENSE \
    "https://raw.githubusercontent.com/rogerfar/rdt-client/v${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 6500

VOLUME /config
