# UNVERIFIED (draft): upstream builds on ghcr.io/m1k1o/neko/base, which was not read.
# This draft uses the ContainerForge ubuntu base. The desktop stack is not confirmed to work,
# and the base decision (plan section 3) is still open. Browser sidecars are separate apps.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# UNVERIFIED: package names on ubuntu 26.04 (xorg, openbox, pulseaudio, supervisor) are not checked.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    xorg \
    openbox \
    pulseaudio \
    supervisor \
    ca-certificates \
    curl && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: release asset name, licence path and checksum are not checked (plan section 4, step 2).
RUN echo "*** Installing neko server ***" && \
  curl -o /tmp/neko.tar.gz -L \
    "https://github.com/m1k1o/neko/releases/download/${VERSION}/neko-${VERSION#v}-linux-${TARGETARCH}.tar.gz" && \
  mkdir -p /app && \
  tar xzf /tmp/neko.tar.gz -C /app/ && \
  mkdir -p /usr/share/licenses/neko && \
  curl -o /usr/share/licenses/neko/LICENSE -L \
    "https://raw.githubusercontent.com/m1k1o/neko/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/neko.tar.gz

# UNVERIFIED: Xorg, the neko server and the browsers need rework to run as apps (plan section 9).
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
# WebRTC media range (plan section 9: needs host networking or explicit port mapping at runtime).
EXPOSE 52000-52100/udp

VOLUME /config
