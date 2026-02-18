FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408

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
