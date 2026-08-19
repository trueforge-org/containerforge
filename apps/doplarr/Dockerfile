

FROM ghcr.io/trueforge-org/java21:21.0.8@sha256:df4eec744a26838072b6462f0bf787843e85f6920ce4f13526235660af855c5e
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
