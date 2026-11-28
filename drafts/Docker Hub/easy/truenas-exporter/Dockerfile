FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETOS
ARG TARGETARCH

USER root

# Download the release tarball, verify it against the published sha256sums.txt, and keep its license and notice.
# The static Go binary is installed. getool from the same tarball is not installed.
RUN cd /tmp && \
    ARCHIVE="graphite_exporter-${VERSION}.${TARGETOS}-${TARGETARCH}" && \
    curl -fsSLO "https://github.com/prometheus/graphite_exporter/releases/download/v${VERSION}/${ARCHIVE}.tar.gz" && \
    curl -fsSLO "https://github.com/prometheus/graphite_exporter/releases/download/v${VERSION}/sha256sums.txt" && \
    grep " ${ARCHIVE}.tar.gz\$" sha256sums.txt | sha256sum -c - && \
    tar xzf "${ARCHIVE}.tar.gz" && \
    install -m 0755 "${ARCHIVE}/graphite_exporter" /usr/local/bin/graphite_exporter && \
    mkdir -p /usr/share/licenses/truenas-exporter && \
    install -m 0644 "${ARCHIVE}/LICENSE" "${ARCHIVE}/NOTICE" /usr/share/licenses/truenas-exporter/ && \
    rm -rf "${ARCHIVE}" "${ARCHIVE}.tar.gz" sha256sums.txt

USER apps
COPY --chmod=0755 . /

EXPOSE 9108 9109 9109/udp
VOLUME /config
