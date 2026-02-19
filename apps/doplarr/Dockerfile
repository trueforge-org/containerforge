

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:6b3e1bd1015409c669b4be72fec26bace52b313cc243562438d0d1ff51ce73b7
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
COPY container-test.yaml /container-test.yaml
WORKDIR /config
