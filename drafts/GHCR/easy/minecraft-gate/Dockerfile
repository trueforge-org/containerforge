FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

USER root

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/gate-cache

# The upstream release ships a raw binary and a checksums.txt. Verify the binary before installing it.
RUN echo "*** Installing Gate ${VERSION} ***" && \
    mkdir -p /tmp/gate-dl && \
    curl -fL -o "/tmp/gate-dl/gate_${VERSION}_linux_${TARGETARCH}" \
      "https://github.com/minekube/gate/releases/download/v${VERSION}/gate_${VERSION}_linux_${TARGETARCH}" && \
    curl -fL -o /tmp/gate-dl/checksums.txt \
      "https://github.com/minekube/gate/releases/download/v${VERSION}/checksums.txt" && \
    cd /tmp/gate-dl && \
    grep " gate_${VERSION}_linux_${TARGETARCH}$" checksums.txt | sha256sum -c - && \
    mkdir -p /app && \
    install -m 0755 "gate_${VERSION}_linux_${TARGETARCH}" /app/gate && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    echo "*** Cleaning Up ***" && \
    rm -rf /tmp/gate-dl

USER apps
COPY --chmod=0755 . /

EXPOSE 25565

VOLUME /config
