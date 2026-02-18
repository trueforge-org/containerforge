

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:9d529cc572e6c2ffe419b40fca6d23d48d6c7787dc78bb6a82420159f29b9db3
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

USER apps
WORKDIR /config
