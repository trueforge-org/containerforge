FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

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
