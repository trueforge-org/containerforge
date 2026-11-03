FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

USER root

# Download redis_exporter, verify it against the published checksums, and keep its license
RUN ARCHIVE="redis_exporter-v$VERSION.$TARGETOS-$TARGETARCH" && \
    wget "https://github.com/oliver006/redis_exporter/releases/download/v$VERSION/$ARCHIVE.tar.gz" && \
    wget "https://github.com/oliver006/redis_exporter/releases/download/v$VERSION/sha256sums.txt" && \
    grep " $ARCHIVE.tar.gz\$" sha256sums.txt | sha256sum -c - && \
    tar xzf "$ARCHIVE.tar.gz" && \
    mv "$ARCHIVE/redis_exporter" /usr/local/bin/redis_exporter && \
    chmod +x /usr/local/bin/redis_exporter && \
    mkdir -p /usr/share/licenses/redis-exporter && \
    mv "$ARCHIVE/LICENSE" /usr/share/licenses/redis-exporter/LICENSE && \
    rm -rf "$ARCHIVE" "$ARCHIVE.tar.gz" sha256sums.txt

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/usr/local/bin/redis_exporter"]
