FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# build variables
ARG VERSION
ARG TARGETARCH
USER root

# Mozilla ships linux-x86_64 tarballs only; arm64 would need a source build (out of scope).
RUN \
  if [ "${TARGETARCH}" != "amd64" ]; then \
    echo "thunderbird ${VERSION}: only linux/amd64 is supported" >&2; exit 1; \
  fi

# desktop stack: Xvfb display, x11vnc, noVNC on 8080 (package names UNVERIFIED for this base release)
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    bzip2 \
    fonts-dejavu-core \
    libasound2t64 \
    libdbus-glib-1-2 \
    libgtk-3-0t64 \
    novnc \
    websockify \
    x11vnc \
    xauth \
    xvfb \
    xz-utils && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** install thunderbird ${VERSION} ****" && \
  mkdir -p /app && \
  # UNVERIFIED: SHA-512 checksum from Mozilla SHA512SUMS (release directory) not yet verified here
  curl -fL -o /tmp/thunderbird.tar.xz \
    "https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/${VERSION}/linux-x86_64/en-US/thunderbird-${VERSION}.tar.xz" && \
  tar xJf /tmp/thunderbird.tar.xz -C /app && \
  rm -f /tmp/thunderbird.tar.xz && \
  # UNVERIFIED: confirm the license file name inside the tarball, then copy it to /usr/share/licenses/thunderbird/
  chmod -R 755 /app/thunderbird

RUN \
  echo "**** set permissions ****" && \
  mkdir -p /config && \
  chown -R apps:apps /config

# add local files
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080

WORKDIR /config
VOLUME /config
