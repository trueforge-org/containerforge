

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:816a1c5c740271d8c0e08191bbbed4e9e4aef3c1c755156f8b7fba13c2c43cff
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/kiranshila/Doplarr/releases/download/v${VERSION}/doplarr.jar" > "/app/doplarr.jar" && \
    curl -fsSL "https://raw.githubusercontent.com/kiranshila/Doplarr/v${VERSION}/config.edn" > "/app/config.edn" && \
    chmod -R u=rwX,go=rX /app \
    && chown -R apps:apps /app


USER apps
COPY --chmod=0755 . /
WORKDIR /config
