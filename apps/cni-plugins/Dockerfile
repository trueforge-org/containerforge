

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520
ARG TARGETARCH
ARG VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CNI_BIN_DIR=/host/opt/cni/bin

USER root
COPY container-test.yaml /container-test.yaml

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        rsync \
    && mkdir -p /plugins \
    && curl -fsSL "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-${TARGETARCH}-${VERSION}.tgz" \
        | tar xzf - -C /plugins --strip-components=1 \
    && apt-get remove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

CMD rsync -av --exclude=LICENSE --exclude=README.md /plugins/* $CNI_BIN_DIR
