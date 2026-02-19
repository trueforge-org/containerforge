

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:873b2b4d49f2832da16d7f1a4e5985dd418d783e3cdde81a815fba52799735f6
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
