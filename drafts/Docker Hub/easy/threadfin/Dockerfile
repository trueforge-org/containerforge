
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

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
