

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:4199c1486b3e46e0d990afe382130d196c0aae8b76948bc73997b46e44b0caba
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
