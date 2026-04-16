

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x86_64}

ENV WEBUI_PORTS="7476/tcp,7476/udp"

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/autobrr/qui/releases/download/v${VERSION}/qui_${VERSION}_linux_${TARGETARCH}.tar.gz" | tar xzf - -C "/app" --strip-components=0 && \
    chmod -R u=rwX,go=rX "/app" && \
    chmod +x "/app/qui" && \
    chown -R apps:apps "/app"


EXPOSE 7576

USER apps
COPY --chmod=0755 . /
WORKDIR /config
