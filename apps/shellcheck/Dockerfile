FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:5fa3c2cf644e1cf005b5ee0feac4b0d0041f65850fb1991bef3926c45a9a371c

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
COPY --chmod=0755 . /

COPY ./ /
