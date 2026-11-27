# Draft from plan.md (mkvcleaver). Not built or tested. UNVERIFIED items are marked.
# MKVCleaver is a Windows x64 app run under Wine. There is no arm64 build (plan section 1).
# Upstream is the jlesage Alpine GUI base with s6. This image runs as apps on the trueforge Ubuntu base (plan section 3).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
ARG MKVTOOLNIX_VERSION=33.1.0
ARG MEDIAINFO_VERSION=26.01
# Record each sha256 at build time from a trusted download. No checksum is published upstream (plan section 10).
ARG MKVCLEAVER_SHA256=""
ARG MKVTOOLNIX_SHA256=""
ARG MEDIAINFO_SHA256=""
ARG AUTOIT_SHA256=""

USER root
# UNVERIFIED: package names on 26.04 (plan section 4). Pin the Wine version once it is checked.
RUN echo "*** Installing Wine and the GUI stack ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    wine p7zip-full unzip xvfb x11-utils x11vnc novnc websockify fonts-dejavu-core && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: blogs.sapib.ca returned 403 to automated fetches, so the MKVCleaver download may fail at build time.
# Winetricks is skipped until a test shows a missing runtime. Licence texts of the Windows archives are not yet shipped.
RUN set -eu; \
  [ "${TARGETARCH:-amd64}" = "amd64" ] || { echo "MKVCleaver is x64 only" >&2; exit 1; }; \
  verify() { if [ -n "$2" ]; then echo "$2  $1" | sha256sum -c -; fi; }; \
  mkdir -p /opt/mkvcleaver /opt/mkvtoolnix /opt/autoit; \
  curl -fL -o /tmp/MKVCleaver.exe "https://blogs.sapib.ca/apps/download/d47a70b2339c4809edd842ebc45d2efc/MKVCleaver_x64_v${VERSION}.exe"; \
  verify /tmp/MKVCleaver.exe "${MKVCLEAVER_SHA256}"; \
  mv /tmp/MKVCleaver.exe /opt/mkvcleaver/MKVCleaver.exe; \
  curl -fL -o /tmp/mkvtoolnix.7z "https://mkvtoolnix.download/windows/releases/${MKVTOOLNIX_VERSION}/mkvtoolnix-64-bit-${MKVTOOLNIX_VERSION}.7z"; \
  verify /tmp/mkvtoolnix.7z "${MKVTOOLNIX_SHA256}"; \
  7z x -y -o/opt/mkvtoolnix /tmp/mkvtoolnix.7z; \
  curl -fL -o /tmp/mediainfo.7z "https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_Windows_x64_WithoutInstaller.7z"; \
  verify /tmp/mediainfo.7z "${MEDIAINFO_SHA256}"; \
  7z x -y -o/opt/mkvtoolnix /tmp/mediainfo.7z; \
  curl -fL -o /tmp/autoit.zip "https://www.autoitscript.com/files/autoit3/autoit-v3.zip"; \
  verify /tmp/autoit.zip "${AUTOIT_SHA256}"; \
  unzip -q /tmp/autoit.zip -d /opt/autoit; \
  rm -rf /tmp/*

# Wine prefix is ephemeral (/tmp), recreated each start. The choice is open (plan section 9).
ENV HOME=/config \
  WINEPREFIX=/tmp/wine \
  WINEDEBUG=-all \
  DISPLAY=:0

USER apps
COPY --chmod=0755 . /

EXPOSE 5800 5900
VOLUME /config
CMD ["/start.sh"]
