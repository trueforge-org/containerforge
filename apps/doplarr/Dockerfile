

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:96536476198b2e7039618cc20c7644574619ddce100629c1733555eb69f1deb5
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
