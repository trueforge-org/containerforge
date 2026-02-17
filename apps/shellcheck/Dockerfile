FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a

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
