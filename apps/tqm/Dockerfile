

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a
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
