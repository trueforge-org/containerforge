

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348
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
