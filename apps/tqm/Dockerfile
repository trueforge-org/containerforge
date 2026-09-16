

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:fe30ffe7e0841a2e19f3a508d9ae62b594feada6829d9b78d21cd534a8e8ac8b
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


USER apps
COPY --chmod=0755 . /
WORKDIR /config
