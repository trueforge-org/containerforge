
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# UNVERIFIED: the server bundles its own ffmpeg, ffprobe and comskip (setup.sh), but the shared libraries they
# need (libva, intel-media-va-driver for /dev/dri) are not confirmed. Run ldd on the binaries and add apt packages only if missing.
# UNVERIFIED: setup.sh downloads $os-$arch.sha256 but does not check it. No checksum is pinned here.
# UNVERIFIED: no EULA or license file is shipped in the download. Add /usr/share/licenses/channels-dvr/ once one is confirmed.
RUN echo "*** Installing Channels DVR Server ${VERSION} ***" && \
  mkdir -p /app && \
  cd /app && \
  export DVR_VERSION="${VERSION}" && \
  curl -fsS https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh && \
  echo "*** Checking the server binary ***" && \
  /app/channels-dvr/latest/channels-dvr --version && \
  chown -R apps:apps /app && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8089

VOLUME /config
