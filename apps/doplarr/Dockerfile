

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:4f40cd39a8df3fb89552299ea9aa6d30aa65f393a5f360fa3a29e1b54fd7bd12
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/kiranshila/Doplarr/releases/download/v${VERSION}/doplarr.jar" > "/app/doplarr.jar" && \
    curl -fsSL "https://raw.githubusercontent.com/kiranshila/Doplarr/v${VERSION}/config.edn" > "/app/config.edn" && \
    chmod -R u=rwX,go=rX /app \
    && chown -R apps:apps /app

COPY . /

USER apps:apps
WORKDIR /config
