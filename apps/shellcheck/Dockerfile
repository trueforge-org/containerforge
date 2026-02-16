FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:128e24cac8026983dcd46413896d467cc1ffae9d933164f758866e7519eae606

ARG VERSION
ARG TARGETARCH

ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG TARGETARCH=${TARGETARCH/amd64/x86_64}
USER root

RUN \
    echo "**** download shellcheck binary ****" && \
    curl -L -o /tmp/shellcheck.tar.xz \
        https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}.linux.${TARGETARCH}.tar.xz && \
    tar -xJf /tmp/shellcheck.tar.xz -C /usr/local/bin --strip-components=1 shellcheck-v0.11.0/shellcheck && \
    chmod +x /usr/local/bin/shellcheck && \
    chown -R apps:apps /app && chmod -R 755 /app

USER apps

COPY ./ /
