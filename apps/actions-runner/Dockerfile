

FROM ghcr.io/trueforge-org/devcontainer:3.0.2@sha256:f180323c710192928c0c5dc85cf59ba4763e0d53c4892938f7b07e4f849309db

USER root

ENV RUNNER_MANUALLY_TRAP_SIG=1 \
    ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=1 \
    ImageOS=ubuntu22 \
    HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    RUNNER_ALLOW_RUNASROOT="1" \
    GOPATH="/tmp/go"


# ---------------------------
# Step 1: Create runner user early
# ---------------------------
RUN groupadd docker --gid 123 \
    && usermod -aG sudo apps \
    && usermod -aG docker apps \
    && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers \
    mkdir -p /home/runner /config/helm /go /config/go /tmp/go \
    chown -R apps:docker /home/runner /config/helm /go /tmp/go /config/go \
    chmod -R 777 /home/runner /config/helm /go /tmp/go /config/go

WORKDIR /home/runner

ARG TARGETOS=linux
ARG VERSION
ARG RUNNER_CONTAINER_HOOKS_VERSION
ARG DOCKER_VERSION
ARG BUILDX_VERSION

# Architecture mappings
ARG TARGETARCH
ARG RUNNER_ARCH=${TARGETARCH/arm64/arm64}
ARG RUNNER_ARCH=${TARGETARCH/amd64/x64}
ARG DOCKER_ARCH=${TARGETARCH/arm64/aarch64}
ARG DOCKER_ARCH=${TARGETARCH/amd64/x86_64}

# ---------------------------
# Step 2: Install dependencies, Docker, and add keyrings/repositories
# ---------------------------
RUN set -eux; \
    mkdir -p -m 755 /etc/apt/keyrings; \
    \
    # GitHub CLI key
    out=$(mktemp); \
    wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg; \
    cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null; \
    \
    # Docker official repo
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    \
    # Git PPA
    add-apt-repository -y ppa:git-core/ppa; \
    \
    apt-get update -y; \
    \
    # Install packages
    apt-get install -y --no-install-recommends --no-install-suggests \
        gcc \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin; \
    # yq
    cp /tools/bin/go-yq /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# ---------------------------
# Step 3: Download and extract GitHub Actions runner
# ---------------------------
RUN curl -fsSL -o runner.tar.gz "https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-${TARGETOS}-${RUNNER_ARCH}-${VERSION}.tar.gz" \
    && tar xzf runner.tar.gz && rm runner.tar.gz \
    && chown -R apps:docker /home/runner

# ---------------------------
# Step 4: Download and extract container hooks
# ---------------------------
RUN curl -fsSL -o runner-container-hooks.zip "https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip" \
    && unzip runner-container-hooks.zip -d ./k8s \
    && rm runner-container-hooks.zip \
    && chown -R apps:docker /home/runner/k8s

USER apps
COPY container-test.yaml /container-test.yaml
