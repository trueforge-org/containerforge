

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:c0ba6093c592bdd00ecb278a126ba560369caec1a953adbb923810cd08d8b481
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
