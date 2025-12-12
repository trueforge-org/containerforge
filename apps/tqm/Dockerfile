

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f4f97014103ddd97cb710e71b9c6df79d4537dd0ce53d56c175fadd4c28139eb
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
