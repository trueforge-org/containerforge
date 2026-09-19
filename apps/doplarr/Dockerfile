

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:7bbf7aa5ef5900808e33991a21d3557cef8da6d07d1f1b4de5d3cf108e7ef24d
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
