

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5e17d35aea5a235316958f3cb7d6c4ea7fb2026199c797d66e4a2b91eef2db51
ARG TARGETARCH
ARG VERSION

USER root
WORKDIR /app

# Install dependencies
RUN mkdir -p /app/bin && \
    curl -fsSL "https://github.com/autobrr/tqm/releases/download/${VERSION}/tqm_${VERSION#*v}_linux_${TARGETARCH}.tar.gz" \
        | tar xzf - -C /app/bin && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY . /

USER apps:apps
WORKDIR /config
