

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:9ec5de91a1fb401ba4739f36a6b8dfaf70fd8dc75735fdf608e23392f9be29ba
ARG TARGETARCH
ARG VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CNI_BIN_DIR=/host/opt/cni/bin

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        rsync \
    && mkdir -p /plugins \
    && curl -fsSL "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-${TARGETARCH}-${VERSION}.tgz" \
        | tar xzf - -C /plugins --strip-components=1 \
    && apt-get remove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/*

CMD rsync -av --exclude=LICENSE --exclude=README.md /plugins/* $CNI_BIN_DIR
