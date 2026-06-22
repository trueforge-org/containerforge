

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5cb91be3e738ebbd91b616dc8ec0dd21d25980038f39d6b941f30a0b106d1ecf
ARG TARGETARCH
ARG VENDOR
ARG VERSION


ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV WEBUI_PORTS="4545/tcp,4545/udp"

USER root
WORKDIR /app

RUN mkdir "/app/bin" && \
    curl -fsSL "https://github.com/thomst08/requestrr/releases/download/V${VERSION}/requestrr-linux-${TARGETARCH}.tar.gz" | tar xzf - -C "/app/bin" --strip-components=1 && \
    chmod -R u=rwX,go=rX "/app" && \
    chown -R apps:apps "/app"


EXPOSE 4545

USER apps
COPY --chmod=0755 . /
WORKDIR /config
