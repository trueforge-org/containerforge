
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# sha256 values from the upstream CHECKSUMS.txt for Audacity-4.0.2
ARG SHA256_X86_64=a5f8787aa13cdb500a60fc013403b986776876b960cca962bc6e7fff066172f3
ARG SHA256_AARCH64=88b1e16dd40a5b7d36bec5789b03f66bda34a7b964e19f338951bf6034d9db9c
USER root

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp

# UNVERIFIED: runtime libraries. The upstream linuxserver image installs libnss3, libatk1.0, libatk-bridge2.0, libportaudio2 and python3-xdg. Package names on 26.04 may need a t64 suffix. Confirm with ldd on the extracted binary and install only what is missing.
RUN echo "*** Installing Audacity ***" && \
  case "$TARGETARCH" in \
    amd64) AUDACITY_ARCH=x86_64; AUDACITY_SHA256="${SHA256_X86_64}" ;; \
    arm64) AUDACITY_ARCH=aarch64; AUDACITY_SHA256="${SHA256_AARCH64}" ;; \
    *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/audacity.AppImage \
    "https://github.com/audacity/audacity/releases/download/Audacity-${VERSION}/audacity-linux-${VERSION}-${AUDACITY_ARCH}.AppImage" && \
  echo "${AUDACITY_SHA256}  /tmp/audacity.AppImage" | sha256sum -c - && \
  chmod +x /tmp/audacity.AppImage && \
  cd /tmp && /tmp/audacity.AppImage --appimage-extract && \
  mv /tmp/squashfs-root /app/audacity && \
  chown -R apps:apps /app/audacity && chmod -R 755 /app/audacity && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/audacity && \
  cp /app/audacity/usr/share/doc/audacity/LICENSE.txt /usr/share/licenses/audacity/LICENSE.txt && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/audacity.AppImage

# UNVERIFIED: the license path inside the AppImage is not checked. Find the real LICENSE.txt in the extracted tree before the first build. The cp above fails the build if the path is wrong.

USER apps
COPY --chmod=0755 . /

VOLUME /config
