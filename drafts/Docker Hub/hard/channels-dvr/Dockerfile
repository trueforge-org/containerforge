FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV HOME=/config

# Channels DVR is closed source (vendor EULA, no licence file in the download). The vendor installer
# (setup.sh, DOWNLOAD_ONLY) fetches the per-arch server, ffmpeg, ffprobe, comskip and ffmpeg-dl from
# https://cdn.channelsdvr.net/dvr/<version>/ and the matching <os>-<arch>.sha256 file, but does not check it.
# The sha256 file is verified here. UNVERIFIED: shared libraries the bundled ffmpeg needs for /dev/dri
# (run ldd on the binaries and add only the apt packages that are missing).
RUN echo "*** Installing Channels DVR Server ${VERSION} ***" && \
  mkdir -p /app && \
  cd /app && \
  export DVR_VERSION="${VERSION}" && \
  curl -fsS https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh && \
  echo "*** Verifying checksums ***" && \
  cd "/app/channels-dvr/${VERSION}" && \
  sha256sum -c --ignore-missing ./*.sha256 && \
  test -x channels-dvr && \
  cd /app && \
  echo "*** Moving the server data directory to /config ***" && \
  rm -rf /app/channels-dvr/data && \
  ln -s /config /app/channels-dvr/data && \
  chown -R root:root /app && \
  chmod -R a+rX /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8089

VOLUME /config
