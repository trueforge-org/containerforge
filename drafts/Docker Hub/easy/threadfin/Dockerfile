
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# ffmpeg is an optional stream helper. UNVERIFIED: VLC and jellyfin-ffmpeg7 from upstream are left out on purpose.
RUN echo "*** Installing ffmpeg ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ffmpeg && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published upstream, so the download is verified by TLS and the release tag only.
RUN echo "*** Installing Threadfin ${VERSION} ***" && \
  curl -fsSL -o /app/threadfin \
    "https://github.com/Threadfin/Threadfin/releases/download/${VERSION}/Threadfin_linux_${TARGETARCH}" && \
  chmod 0755 /app/threadfin && \
  chown root:root /app/threadfin && \
  mkdir -p /usr/share/licenses/threadfin && \
  curl -fsSL -o /usr/share/licenses/threadfin/LICENSE \
    "https://raw.githubusercontent.com/Threadfin/Threadfin/${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 34400

VOLUME /config

WORKDIR /config
