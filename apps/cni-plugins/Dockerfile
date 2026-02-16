

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5348eb7725294e8090c15b7b495e517f82f4b31497d3bb9de71bbe37476e7454
ARG TARGETARCH
ARG VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CNI_BIN_DIR=/host/opt/cni/bin

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        rsync \
    && mkdir -p /plugins \
    && curl -fsSL "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-${TARGETARCH}-${VERSION}.tgz" \
        | tar xzf - -C /plugins --strip-components=1 \
    && apt-get remove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

CMD rsync -av --exclude=LICENSE --exclude=README.md /plugins/* $CNI_BIN_DIR
