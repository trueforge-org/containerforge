FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520

ARG VERSION
ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/amd64}

USER root

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git ca-certificates && \
    \
    # Download kubectl
    curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    kubectl version --client --output=yaml && \
    \
    # Download cmctl
    curl -fsSL -o cmctl.tar.gz "https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cmctl-linux-${TARGETARCH}.tar.gz" && \
    tar xzf cmctl.tar.gz && \
    mv cmctl /usr/local/bin/ && \
    \
    # Cleanup
    rm -rf /var/lib/apt/lists/* kubectl* cmctl.tar.gz

USER apps
COPY container-test.yaml /container-test.yaml
