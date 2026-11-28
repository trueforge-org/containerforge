
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC

# BLOCKED (plan section 10): Double Commander is a GUI and needs an X display. The display stack is not chosen. No checksum is published upstream, so integrity rests on the pinned version over HTTPS.
RUN echo "*** Installing Double Commander ***" && \
  case "$TARGETARCH" in \
    amd64) DC_ARCH=x86_64 ;; \
    arm64) DC_ARCH=aarch64 ;; \
    *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/doublecmd.tar.xz \
    "https://github.com/doublecmd/doublecmd/releases/download/v${VERSION}/doublecmd-${VERSION}.gtk2.${DC_ARCH}.tar.xz" && \
  mkdir -p /app/doublecommander && \
  # UNVERIFIED: --strip-components=1, confirm the archive's top-level folder on the first build
  tar -xJf /tmp/doublecmd.tar.xz -C /app/doublecommander --strip-components=1 && \
  chown -R apps:apps /app/doublecommander && chmod -R 755 /app/doublecommander && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/doublecmd.tar.xz

# UNVERIFIED: runtime libraries. Start from the upstream extras (libsmbclient, libssh2, libunrar, p7zip-full, xz-utils). Check ldd on /app/doublecommander/doublecmd and install only what is missing, pinned to 26.04.
# UNVERIFIED: arj, unace and zpaq are dropped unless the Ubuntu archive has them. Do not install the Debian doublecmd-gtk package.
# UNVERIFIED: the license file name in the tarball. Copy it to /usr/share/licenses/doublecommander/ and fail if missing.

USER apps
COPY --chmod=0755 . /

# EXPOSE is left open until the display stack is decided (plan section 6).

VOLUME /config
