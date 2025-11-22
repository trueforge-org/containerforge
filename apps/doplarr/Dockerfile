

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:641913567ee5df1ea91a56cb093a605103a1a21a6267be5522862f6105ee6148
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
