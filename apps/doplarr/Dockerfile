

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:c2818c9e670595678fb7173a537ec26fbd55a73c36dfc076a7c7cfb4e09e5342
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/kiranshila/Doplarr/releases/download/v${VERSION}/doplarr.jar" > "/app/doplarr.jar" && \
    curl -fsSL "https://raw.githubusercontent.com/kiranshila/Doplarr/v${VERSION}/config.edn" > "/app/config.edn" && \
    chmod -R u=rwX,go=rX /app \
    && chown -R apps:apps /app

COPY --chmod=0755 . /

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml
WORKDIR /config
