FROM ghcr.io/trueforge-org/golang:1.25.1@sha256:e5250f0fd0808141f88c5b1ed491f9c91e19a79db9f830141368cfc5822a8c34 AS go

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6119b5ecab933bfd4ceb9c7e56b8c93379b830d6a5af0aa9cb7b014e1078be8f

ARG VERSION
ARG TARGETARCH

# Copy Go from the first stage
COPY --from=go /usr/local/go /usr/local/go

ENV GOTOOLCHAIN=local
ENV GOPATH=/go
ENV PATH="/usr/local/go/bin:${PATH}"

LABEL dev.containers.features="common"

USER root

# Core dependencies (duplicates removed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        age bind9-dnsutils direnv fish fzf \
        gettext git gh iputils-ping \
        moreutils openssh-client openssl \
        sshfs fuse3 sq webp \
        git \
        gh \
        unzip \
        jo \
        moreutils \
        zstd \
        && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependencies and GitHub CLI
RUN apt-get update && \
    apt-get install -y curl gnupg lsb-release && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Download and install SOPS
ENV SOPS_VERSION=3.11.0

RUN wget https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${TARGETARCH} -O /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Install additional CLI tools via jpillora scripts
RUN for app in \
    "budimanjojo/talhelper!!?as=talhelper&type=script" \
    "fluxcd/flux2!!?as=flux&type=script" \
    "helmfile/helmfile!!?as=helmfile&type=script" \
    "kubecolor/kubecolor!!?as=kubecolor&type=script" \
    "kubernetes-sigs/krew!!?as=krew&type=script" \
    "siderolabs/talos!!?as=talosctl&type=script"; \
  do \
    echo "=== Installing ${app} ==="; \
    curl -fsSL "https://i.jpillora.com/${app}" | bash; \
  done

# Install Pre-Commit
RUN apt-get update && \
    apt-get install -y --no-install-recommends pre-commit && \
    rm -rf /var/lib/apt/lists/*

### Kubernetes-Tools Installer
ENV kubectlVersion=1.21.0
ENV kustomizeVersion=4.4.1
ENV helmVersion=3.14.4
ENV oldhelmVersion=3.12.1
ENV kubevalVersion=0.15.0
ENV kubeconformVersion=0.4.12
ENV conftestVersion=0.25.0
ENV goyqVersion=4.44.1
ENV rancherVersion=2.12.1
ENV tiltVersion=0.33.14
ENV skaffoldVersion=1.28.0
ENV kubeScoreVersion=1.18.0
ENV chartReleaserVersion=1.6.1
ENV chartTestingVersion=3.11.0
ENV k9sVersion=0.27.1
ENV starshipVersion=1.23.0

ARG XARCH=${TARGETARCH/arm64/arm64}
ARG XARCH=${TARGETARCH/amd64/x86_64}

ARG AARCH=${TARGETARCH/arm64/aarch64}
ARG AARCH=${TARGETARCH/amd64/x86_64}


# Versioned download of Kubernetes tools (no duplicates)
RUN set -eux; \
    mkdir -p /tools/bin; \
    download_and_extract() { \
        url=$1; dest_dir=$2; command_path=$3; \
        curl -L "$url" -o temp_archive; \
        if [[ "$url" == *.tar.gz || "$url" == *.tgz ]]; then \
            tar -xzf temp_archive -C "$dest_dir" --strip-components=$(dirname "$command_path" | grep -o "/" | wc -l) || tar -xvpf temp_archive -C "$dest_dir" --strip-components=$(dirname "$command_path" | grep -o "/" | wc -l); \
        elif [[ "$url" == *.zip ]]; then \
            unzip temp_archive -d "$dest_dir"; \
        else \
            cp temp_archive "$dest_dir/$(basename "$command_path")"; \
        fi; \
        rm temp_archive; \
    }; \
    download_and_copy() { \
        tool=$1; version=$2; rename="${3:-$tool}"; \
        url=""; command_path_in_package="$(basename $tool)"; \
        CTYPE=gnu; \
        if [[ "${TARGETARCH}" == "arm64" ]]; then \
         CTYPE=musl; \
        fi; \
        case "$tool" in \
            kubectl) url="https://dl.k8s.io/release/v${version}/bin/linux/${TARGETARCH}/kubectl"; ;; \
            kustomize) url="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${version}/kustomize_v${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            helm) url="https://get.helm.sh/helm-v${version}-linux-${TARGETARCH}.tar.gz"; command_path_in_package="linux-${TARGETARCH}/helm"; ;; \
            kubeval) url="https://github.com/instrumenta/kubeval/releases/download/${version}/kubeval-linux-${TARGETARCH}.tar.gz"; ;; \
            kubeconform) url="https://github.com/yannh/kubeconform/releases/download/v${version}/kubeconform-linux-${TARGETARCH}.tar.gz"; ;; \
            conftest) url="https://github.com/open-policy-agent/conftest/releases/download/v${version}/conftest_${version}_Linux_${XARCH}.tar.gz"; ;; \
            go-yq) url="https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_${TARGETARCH}"; command_path_in_package="yq_linux_${TARGETARCH}"; ;; \
            rancher) url="https://github.com/rancher/cli/releases/download/v${version}/rancher-linux-${TARGETARCH}-v${version}.tar.gz"; command_path_in_package="rancher-v${version}/rancher"; ;; \
            tilt) url="https://github.com/tilt-dev/tilt/releases/download/v${version}/tilt.${version}.linux.${XARCH}.tar.gz"; ;; \
            skaffold) url="https://storage.googleapis.com/skaffold/releases/v${version}/skaffold-linux-${TARGETARCH}"; command_path_in_package="skaffold-linux-${TARGETARCH}"; ;; \
            kube-score) url="https://github.com/zegl/kube-score/releases/download/v${version}/kube-score_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            chart-releaser) url="https://github.com/helm/chart-releaser/releases/download/v${version}/chart-releaser_${version}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="cr"; rename="cr"; ;; \
            chart-testing) url="https://github.com/helm/chart-testing/releases/download/v${version}/chart-testing_${version}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="ct"; rename="ct"; ;; \
            k9s) url="https://github.com/derailed/k9s/releases/download/v${version}/k9s_Linux_${TARGETARCH}.tar.gz"; command_path_in_package="k9s"; ;; \
            starship) url="https://github.com/starship/starship/releases/download/v${version}/starship-${AARCH/arm64/aarch64}-unknown-linux-${CTYPE}.tar.gz"; command_path_in_package="starship"; ;; \
            clustertool) url="https://github.com/trueforge-org/truecharts/releases/download/v${version}/clustertool_${VERSION}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="clustertool"; ;; \
            *) echo "Unknown tool: $tool"; exit 1 ;; \
        esac; \
        mkdir -p /tools/${tool}; \
        download_and_extract "$url" "/tools/${tool}" "$command_path_in_package"; \
        cp "/tools/${tool}/$command_path_in_package" "/tools/bin/$rename"; \
        rm -rf "/tools/${tool}"; \
        chmod +x "/tools/bin/$rename"; \
    }; \
    download_and_copy "kubectl" "$kubectlVersion"; \
    download_and_copy "kustomize" "$kustomizeVersion"; \
    download_and_copy "helm" "$helmVersion"; \
    download_and_copy "helm" "$oldhelmVersion" "oldhelm"; \
    download_and_copy "kubeconform" "$kubeconformVersion"; \
    download_and_copy "conftest" "$conftestVersion"; \
    download_and_copy "go-yq" "$goyqVersion"; \
    download_and_copy "rancher" "$rancherVersion"; \
    download_and_copy "tilt" "$tiltVersion"; \
    download_and_copy "skaffold" "$skaffoldVersion"; \
    download_and_copy "kube-score" "$kubeScoreVersion"; \
    download_and_copy "chart-releaser" "$chartReleaserVersion"; \
    download_and_copy "chart-testing" "$chartTestingVersion"; \
    download_and_copy "k9s" "$k9sVersion"; \
    download_and_copy "starship" "$starshipVersion"; \
    download_and_copy "clustertool" "$VERSION"; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        download_and_copy "kubeval" "$kubevalVersion"; \
    fi;

ENV PATH="/tools/bin:${PATH}"

# Install homebrew
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
      mkdir -p /usr/local/Homebrew && \
      curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /usr/local/Homebrew && \
      ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew; \
    fi


# Create Fish config directories
RUN mkdir -p /home/vscode/.config/fish/completions \
             /home/vscode/.config/fish/conf.d

# Add completions only if the command exists
RUN for tool in cilium flux helm helmfile k9s kubectl kustomize talhelper talosctl; do \
      if command -v "$tool" >/dev/null 2>&1; then \
        $tool completion fish > "/home/vscode/.config/fish/completions/${tool}.fish" || true; \
      fi; \
    done && \
    gh completion --shell fish > /home/vscode/.config/fish/completions/gh.fish || true && \
    stern --completion fish > /home/vscode/.config/fish/completions/stern.fish || true && \
    yq shell-completion fish > /home/vscode/.config/fish/completions/yq.fish || true

# Fish hooks
RUN printf '%s\n' \
    "if status is-interactive" \
    "    direnv hook fish | source" \
    "    starship init fish | source" \
    "end" \
    > /home/vscode/.config/fish/conf.d/hooks.fish

# Fish aliases
RUN printf '%s\n' \
    "alias kubectl kubecolor" \
    "alias k kubectl" \
    "alias task go-task" \
    > /home/vscode/.config/fish/conf.d/aliases.fish

# Custom fish prompt
RUN echo "set fish_greeting" > /home/vscode/.config/fish/conf.d/fish_greeting.fish

# Direnv whitelist
RUN mkdir -p /home/vscode/.config/direnv && \
    tee /home/vscode/.config/direnv/direnv.toml > /dev/null <<EOF
[whitelist]
prefix = [ "/workspaces" ]
EOF

# Fix permissions for devcontainer user
RUN groupadd -r vscode && useradd -m -r -g vscode vscode;\
    chown -R vscode:vscode /home/vscode/ && chmod -R 755 /home/vscode/

