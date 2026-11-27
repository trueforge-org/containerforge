
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Single-node binary tarball (not the -cluster tarball). The sha256 is checked against the release's checksums file.
RUN echo "*** Installing VictoriaMetrics ***" && \
  cd /tmp && \
  BASE="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION#v}" && \
  FILE="victoria-metrics-linux-${TARGETARCH}-v${VERSION#v}.tar.gz" && \
  curl -fsSL -o "/tmp/${FILE}" "${BASE}/${FILE}" && \
  curl -fsSL -o /tmp/checksums.txt "${BASE}/victoria-metrics-linux-${TARGETARCH}-v${VERSION#v}_checksums.txt" && \
  grep " ${FILE}\$" /tmp/checksums.txt | (cd /tmp && sha256sum -c -) && \
  tar xzf "/tmp/${FILE}" -C /app && \
  mkdir -p /usr/share/licenses/victoriametrics && \
  curl -fsSL -o /usr/share/licenses/victoriametrics/LICENSE \
    "https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v${VERSION#v}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8428

VOLUME /config
