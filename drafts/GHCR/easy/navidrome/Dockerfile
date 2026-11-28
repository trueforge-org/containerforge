
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  ND_MUSICFOLDER=/music \
  ND_DATAFOLDER=/config \
  ND_CONFIGFILE=/config/navidrome.toml \
  ND_PORT=4533

# UNVERIFIED: tar member name "navidrome" and the static glibc build; confirm with `tar tzf` at build time.
# UNVERIFIED: ffmpeg and mpv are bundled by the upstream image for transcoding, but not installed here.
RUN echo "*** Installing Navidrome ***" && \
  NAVIDROME_VERSION="${VERSION#v}" && \
  curl -fsSL -o \
    /tmp/navidrome.tar.gz \
    "https://github.com/navidrome/navidrome/releases/download/${VERSION}/navidrome_${NAVIDROME_VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o \
    /tmp/navidrome_checksums.txt \
    "https://github.com/navidrome/navidrome/releases/download/${VERSION}/navidrome_checksums.txt" && \
  awk -v f="navidrome_${NAVIDROME_VERSION}_linux_${TARGETARCH}.tar.gz" \
    '$2==f {print $1"  /tmp/navidrome.tar.gz"}' /tmp/navidrome_checksums.txt > /tmp/navidrome.sha256 && \
  test -s /tmp/navidrome.sha256 && \
  sha256sum -c /tmp/navidrome.sha256 && \
  tar xzf \
    /tmp/navidrome.tar.gz -C \
    /app/ navidrome && \
  chmod 0755 /app/navidrome && \
  chown apps:apps /app/navidrome && \
  mkdir -p /usr/share/licenses/navidrome && \
  curl -fsSL -o \
    /usr/share/licenses/navidrome/LICENSE \
    "https://raw.githubusercontent.com/navidrome/navidrome/${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/navidrome.tar.gz /tmp/navidrome_checksums.txt /tmp/navidrome.sha256

USER apps
COPY --chmod=0755 . /

EXPOSE 4533

VOLUME ["/config", "/music"]
