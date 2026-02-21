FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:f49900e6e09e1e782e80a9281d2e559a8520ec90c3d46e8714013b12c593c369 AS go

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8ba5cf93d8f36593fc5dcc55bdccc40f581008ab4732dca1f7c520daae9f145b

ARG VERSION
ARG TARGETARCH

# Copy Go from the first stage
COPY --from=go /usr/local/go /usr/local/go

ENV GOTOOLCHAIN=local
ENV GOPATH=/config/go
ENV PATH="/usr/local/go/bin:${PATH}"

LABEL dev.containers.features="common"

USER root
COPY --chmod=0755 . /

# Core dependencies (duplicates removed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        age bind9-dnsutils direnv fzf \
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

# Add newest fish version
RUN apt-add-repository ppa:fish-shell/release-4 && \
    apt update && \
    apt install -y  --no-install-recommends fish

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
# renovate: datasource=github-releases depName=getsops/sops
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
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ENV kubectlVersion=1.35.1
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize
ENV kustomizeVersion=5.8.0
# renovate: datasource=github-releases depName=helm/helm
ENV helmVersion=4.1.1
# WATCH OUT: this needs to be kept for backward compatibility with older helm charts
ENV oldhelmVersion=3.12.1
# renovate: datasource=github-releases depName=instrumenta/kubeval
ENV kubevalVersion=0.16.1
# renovate: datasource=github-releases depName=yannh/kubeconform
ENV kubeconformVersion=0.7.0
# renovate: datasource=github-releases depName=open-policy-agent/conftest
ENV conftestVersion=0.66.0
# renovate: datasource=github-releases depName=mikefarah/yq
ENV goyqVersion=4.52.4
# renovate: datasource=github-releases depName=rancher/cli
ENV rancherVersion=2.13.2
# renovate: datasource=github-releases depName=tilt-dev/tilt
ENV tiltVersion=0.36.3
# renovate: datasource=github-releases depName=GoogleContainerTools/skaffold
ENV skaffoldVersion=2.17.2
# renovate: datasource=github-releases depName=zegl/kube-score
ENV kubeScoreVersion=1.20.0
# renovate: datasource=github-releases depName=helm/chart-releaser
ENV chartReleaserVersion=1.8.1
# renovate: datasource=github-releases depName=helm/chart-testing
ENV chartTestingVersion=3.14.0
# renovate: datasource=github-releases depName=derailed/k9s
ENV k9sVersion=0.50.18
# renovate: datasource=github-releases depName=starship/starship
ENV starshipVersion=1.24.2

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
            kubeval) url="https://github.com/instrumenta/kubeval/releases/download/v${version}/kubeval-linux-${TARGETARCH}.tar.gz"; ;; \
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
            forgetool) url="https://github.com/trueforge-org/forgetool/releases/download/v${version}/forgetool_${VERSION}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="forgetool"; ;; \
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
    download_and_copy "forgetool" "$VERSION"; \
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
RUN mkdir -p /root/.config/fish/completions \
             /root/.config/fish/conf.d

# Add completions only if the command exists
RUN for tool in cilium flux helm helmfile k9s kubectl kustomize talhelper talosctl; do \
      if command -v "$tool" >/dev/null 2>&1; then \
        $tool completion fish > "/root/.config/fish/completions/${tool}.fish" || true; \
      fi; \
    done && \
    gh completion --shell fish > /root/.config/fish/completions/gh.fish || true && \
    stern --completion fish > /root/.config/fish/completions/stern.fish || true && \
    yq shell-completion fish > /root/.config/fish/completions/yq.fish || true

# Fish hooks, aliases and fish promt -> Needs to be done in one file in /etc/fish/config.fish
# Otherwise root won't pick it up
RUN printf '%s\n' \
    "if status is-interactive" \
    "    set -x KREW_ROOT $HOME/.krew" \
    "    set -x PATH $KREW_ROOT/bin $PATH" \
    "    direnv hook fish | source" \
    "    starship init fish | source" \
    "end" \
    # Auto-allow current repo .envrc
    "if test -f .envrc " \
    "    direnv allow . " \
    " end" \
    "alias kubectl kubecolor" \
    "alias k kubectl" \
    "alias task go-task" \
    "set fish_greeting" \
    > /etc/fish/config.fish

# Install fisher plugins
RUN /usr/bin/fish -c "curl -sL https://git.io/fisher | source; \
    fisher install jorgebucaran/fisher; \
    fisher install decors/fish-colored-man; \
    fisher install edc/bass; \
    fisher install jorgebucaran/autopair.fish; \
    fisher install nickeb96/puffer-fish; \
    fisher install PatrickF1/fzf.fish"

# Install kubectl plugins via krew
RUN krew install pv-mounter \
    && krew install cnpg \
    && krew install df-pv
