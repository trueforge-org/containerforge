

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:01cc09f895d289305f12087ced3d9b01ad74ec5e958384d3274a7caa87a94c37
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
