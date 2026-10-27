FROM ghcr.io/trueforge-org/golang:1.27.3@sha256:ec94dd78082e15d55a503673cf38f8a8eb44ddfafe30af4fbaf64de5a87cd003 AS go

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

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
        bzip2 \
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
ENV SOPS_VERSION=3.13.3

RUN wget https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${TARGETARCH} -O /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Install Pre-Commit
RUN apt-get update && \
    apt-get install -y --no-install-recommends pre-commit && \
    rm -rf /var/lib/apt/lists/*

### Kubernetes-Tools Installer
# renovate: datasource=github-releases depName=kubernetes/kubernetes
ENV kubectlVersion=1.37.1
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize
ENV kustomizeVersion=5.8.0
# renovate: datasource=github-releases depName=helm/helm
ENV helmVersion=4.3.1
# WATCH OUT: this needs to be kept for backward compatibility with older helm charts
ENV oldhelmVersion=3.12.1
# renovate: datasource=github-releases depName=instrumenta/kubeval
ENV kubevalVersion=0.16.1
# renovate: datasource=github-releases depName=yannh/kubeconform
ENV kubeconformVersion=0.8.0
# renovate: datasource=github-releases depName=open-policy-agent/conftest
ENV conftestVersion=0.71.1
# renovate: datasource=github-releases depName=mikefarah/yq
ENV goyqVersion=4.54.1
# renovate: datasource=github-releases depName=rancher/cli
ENV rancherVersion=2.15.2
# renovate: datasource=github-releases depName=tilt-dev/tilt
ENV tiltVersion=0.37.8
# renovate: datasource=github-releases depName=GoogleContainerTools/skaffold
ENV skaffoldVersion=2.25.0
# renovate: datasource=github-releases depName=zegl/kube-score
ENV kubeScoreVersion=1.20.0
# renovate: datasource=github-releases depName=helm/chart-releaser
ENV chartReleaserVersion=1.9.0
# renovate: datasource=github-releases depName=helm/chart-testing
ENV chartTestingVersion=3.15.0
# renovate: datasource=github-releases depName=derailed/k9s
ENV k9sVersion=0.51.0
# renovate: datasource=github-releases depName=starship/starship
ENV starshipVersion=1.27.0
# renovate: datasource=github-releases depName=trueforge-org/clustertool
ENV clustertoolVersion=4.0.0

### Cluster maintenance tools
# renovate: datasource=github-releases depName=fluxcd/flux2
ENV fluxVersion=2.10.0
# renovate: datasource=github-releases depName=siderolabs/talos
ENV talosctlVersion=1.14.5
# renovate: datasource=github-releases depName=budimanjojo/talhelper
ENV talhelperVersion=3.1.17
# renovate: datasource=github-releases depName=helmfile/helmfile
ENV helmfileVersion=1.8.2
# renovate: datasource=github-releases depName=kubecolor/kubecolor
ENV kubecolorVersion=0.8.0
# renovate: datasource=github-releases depName=kubernetes-sigs/krew
ENV krewVersion=0.5.0
# renovate: datasource=github-releases depName=go-task/task
ENV taskVersion=3.54.0
# renovate: datasource=github-releases depName=cilium/cilium-cli
ENV ciliumVersion=0.20.1
# renovate: datasource=github-releases depName=cilium/hubble
ENV hubbleVersion=1.20.2
# renovate: datasource=github-releases depName=stern/stern
ENV sternVersion=1.35.0
# renovate: datasource=github-releases depName=cloudnative-pg/cloudnative-pg
ENV cnpgVersion=1.30.1
# renovate: datasource=github-releases depName=cert-manager/cmctl
ENV cmctlVersion=2.6.2
# renovate: datasource=github-releases depName=velero-io/velero
ENV veleroVersion=1.18.4
# renovate: datasource=github-releases depName=restic/restic
ENV resticVersion=0.19.1
# renovate: datasource=github-releases depName=kopia/kopia
ENV kopiaVersion=0.23.1
# renovate: datasource=github-releases depName=home-operations/flate
ENV flateVersion=0.6.5

### Container image tools
# renovate: datasource=docker depName=docker.io/library/docker versioning=docker
ENV dockerVersion=29.9.2
# renovate: datasource=github-releases depName=docker/buildx
ENV buildxVersion=0.38.1
# renovate: datasource=github-releases depName=docker/compose
ENV composeVersion=5.6.1
# renovate: datasource=github-releases depName=hadolint/hadolint
ENV hadolintVersion=2.15.1
# renovate: datasource=github-releases depName=google/go-containerregistry
ENV craneVersion=0.22.1
# renovate: datasource=github-releases depName=sigstore/cosign
ENV cosignVersion=3.1.4
# renovate: datasource=github-releases depName=aquasecurity/trivy
ENV trivyVersion=0.76.1
# renovate: datasource=github-releases depName=koalaman/shellcheck
ENV shellcheckVersion=0.11.0

### Helm chart tools
# renovate: datasource=github-releases depName=norwoodj/helm-docs
ENV helmDocsVersion=1.14.2
# renovate: datasource=github-releases depName=databus23/helm-diff
ENV helmDiffVersion=3.15.15
# renovate: datasource=github-releases depName=helm-unittest/helm-unittest
ENV helmUnittestVersion=1.2.1

ARG XARCH=${TARGETARCH/arm64/arm64}
ARG XARCH=${TARGETARCH/amd64/x86_64}

ARG AARCH=${TARGETARCH/arm64/aarch64}
ARG AARCH=${TARGETARCH/amd64/x86_64}

# Versioned download of Kubernetes tools (no duplicates)
RUN set -eux; \
    mkdir -p /tools/bin; \
    download_and_extract() { \
        url=$1; dest_dir=$2; command_path=$3; \
        curl -fL "$url" -o temp_archive; \
        if [[ "$url" == *.tar.gz || "$url" == *.tgz ]]; then \
            tar -xzf temp_archive -C "$dest_dir" --strip-components=$(dirname "$command_path" | grep -o "/" | wc -l) || tar -xvpf temp_archive -C "$dest_dir" --strip-components=$(dirname "$command_path" | grep -o "/" | wc -l); \
        elif [[ "$url" == *.zip ]]; then \
            unzip temp_archive -d "$dest_dir"; \
        elif [[ "$url" == *.bz2 ]]; then \
            bunzip2 -c temp_archive > "$dest_dir/$(basename "$command_path")"; \
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
            forgetool) url="https://github.com/trueforge-org/forgetool/releases/download/v${version}/forgetool_${version}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="forgetool"; ;; \
            clustertool) url="https://github.com/trueforge-org/clustertool/releases/download/v${version}/clustertool_${version}_linux_${TARGETARCH}.tar.gz"; command_path_in_package="clustertool"; ;; \
            flux) url="https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            talosctl) url="https://github.com/siderolabs/talos/releases/download/v${version}/talosctl-linux-${TARGETARCH}"; ;; \
            talhelper) url="https://github.com/budimanjojo/talhelper/releases/download/v${version}/talhelper_linux_${TARGETARCH}.tar.gz"; ;; \
            helmfile) url="https://github.com/helmfile/helmfile/releases/download/v${version}/helmfile_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            kubecolor) url="https://github.com/kubecolor/kubecolor/releases/download/v${version}/kubecolor_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            krew) url="https://github.com/kubernetes-sigs/krew/releases/download/v${version}/krew-linux_${TARGETARCH}.tar.gz"; command_path_in_package="krew-linux_${TARGETARCH}"; ;; \
            task) url="https://github.com/go-task/task/releases/download/v${version}/task_linux_${TARGETARCH}.tar.gz"; ;; \
            cilium) url="https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-linux-${TARGETARCH}.tar.gz"; ;; \
            hubble) url="https://github.com/cilium/hubble/releases/download/v${version}/hubble-linux-${TARGETARCH}.tar.gz"; ;; \
            stern) url="https://github.com/stern/stern/releases/download/v${version}/stern_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            kubectl-cnpg) url="https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v${version}/kubectl-cnpg_${version}_linux_${XARCH}.tar.gz"; ;; \
            cmctl) url="https://github.com/cert-manager/cmctl/releases/download/v${version}/cmctl_linux_${TARGETARCH}"; ;; \
            velero) url="https://github.com/velero-io/velero/releases/download/v${version}/velero-v${version}-linux-${TARGETARCH}.tar.gz"; command_path_in_package="velero-v${version}-linux-${TARGETARCH}/velero"; ;; \
            restic) url="https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_${TARGETARCH}.bz2"; ;; \
            kopia) url="https://github.com/kopia/kopia/releases/download/v${version}/kopia-${version}-linux-${TARGETARCH/amd64/x64}.tar.gz"; command_path_in_package="kopia-${version}-linux-${TARGETARCH/amd64/x64}/kopia"; ;; \
            flate) url="https://github.com/home-operations/flate/releases/download/v${version}/flate_${version}_linux_${TARGETARCH}.tar.gz"; ;; \
            hadolint) url="https://github.com/hadolint/hadolint/releases/download/v${version}/hadolint-linux-${XARCH}"; ;; \
            crane) url="https://github.com/google/go-containerregistry/releases/download/v${version}/go-containerregistry_Linux_${XARCH}.tar.gz"; ;; \
            cosign) url="https://github.com/sigstore/cosign/releases/download/v${version}/cosign-linux-${TARGETARCH}"; ;; \
            trivy) url="https://github.com/aquasecurity/trivy/releases/download/v${version}/trivy_${version}_Linux-$([ "${TARGETARCH}" = "amd64" ] && echo 64bit || echo ARM64).tar.gz"; ;; \
            shellcheck) url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.linux.${AARCH/arm64/aarch64}.tar.gz"; command_path_in_package="shellcheck-v${version}/shellcheck"; ;; \
            docker) url="https://download.docker.com/linux/static/stable/${AARCH/arm64/aarch64}/docker-${version}.tgz"; command_path_in_package="docker/docker"; ;; \
            docker-buildx) url="https://github.com/docker/buildx/releases/download/v${version}/buildx-v${version}.linux-${TARGETARCH}"; ;; \
            docker-compose) url="https://github.com/docker/compose/releases/download/v${version}/docker-compose-linux-${AARCH/arm64/aarch64}"; ;; \
            helm-docs) url="https://github.com/norwoodj/helm-docs/releases/download/v${version}/helm-docs_${version}_Linux_${XARCH}.tar.gz"; ;; \
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
    download_and_copy "clustertool" "$clustertoolVersion"; \
    download_and_copy "forgetool" "$VERSION"; \
    download_and_copy "flux" "$fluxVersion"; \
    download_and_copy "talosctl" "$talosctlVersion"; \
    download_and_copy "talhelper" "$talhelperVersion"; \
    download_and_copy "helmfile" "$helmfileVersion"; \
    download_and_copy "kubecolor" "$kubecolorVersion"; \
    download_and_copy "krew" "$krewVersion"; \
    download_and_copy "task" "$taskVersion"; \
    download_and_copy "cilium" "$ciliumVersion"; \
    download_and_copy "hubble" "$hubbleVersion"; \
    download_and_copy "stern" "$sternVersion"; \
    download_and_copy "kubectl-cnpg" "$cnpgVersion"; \
    download_and_copy "cmctl" "$cmctlVersion"; \
    download_and_copy "velero" "$veleroVersion"; \
    download_and_copy "restic" "$resticVersion"; \
    download_and_copy "kopia" "$kopiaVersion"; \
    download_and_copy "flate" "$flateVersion"; \
    download_and_copy "hadolint" "$hadolintVersion"; \
    download_and_copy "crane" "$craneVersion"; \
    download_and_copy "cosign" "$cosignVersion"; \
    download_and_copy "trivy" "$trivyVersion"; \
    download_and_copy "shellcheck" "$shellcheckVersion"; \
    download_and_copy "helm-docs" "$helmDocsVersion"; \
    download_and_copy "docker" "$dockerVersion"; \
    download_and_copy "docker-buildx" "$buildxVersion"; \
    download_and_copy "docker-compose" "$composeVersion"; \
    # Docker CLI only (no daemon): use the host socket, or the daemon the actions-runner image adds \
    mkdir -p /usr/local/lib/docker/cli-plugins; \
    ln -sf /tools/bin/docker-buildx /usr/local/lib/docker/cli-plugins/docker-buildx; \
    ln -sf /tools/bin/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        download_and_copy "kubeval" "$kubevalVersion"; \
    fi; \
    # Keep the paths these tools had when they were installed via jpillora (used by downstream images) \
    for tool in flux talosctl talhelper helmfile kubecolor krew; do \
        ln -sf "/tools/bin/${tool}" "/usr/local/bin/${tool}"; \
    done; \
    # kubectl finds plugins as kubectl-<name> on PATH, so this makes "kubectl krew" work \
    ln -sf /tools/bin/krew /tools/bin/kubectl-krew; \
    # The fish config aliases task to go-task \
    ln -sf /tools/bin/task /tools/bin/go-task;

ENV PATH="/tools/bin:${PATH}"

# chart-testing needs its default configs (chart_schema.yaml, lintconf.yaml) in /etc/ct
RUN mkdir -p /etc/ct && \
    curl -fsSL "https://github.com/helm/chart-testing/releases/download/v${chartTestingVersion}/chart-testing_${chartTestingVersion}_linux_${TARGETARCH}.tar.gz" \
        | tar -xzf - -C /etc/ct --strip-components=1 etc/

# Helm plugins in a fixed location, so they work regardless of $HOME (devcontainer, actions-runner)
ENV HELM_PLUGINS=/opt/helm/plugins
RUN mkdir -p "${HELM_PLUGINS}/unittest" && \
    curl -fsSL "https://github.com/databus23/helm-diff/releases/download/v${helmDiffVersion}/helm-diff-linux-${TARGETARCH}.tgz" \
        | tar -xzf - -C "${HELM_PLUGINS}" && \
    curl -fsSL "https://github.com/helm-unittest/helm-unittest/releases/download/v${helmUnittestVersion}/helm-unittest-linux-${TARGETARCH}-${helmUnittestVersion}.tgz" \
        | tar -xzf - -C "${HELM_PLUGINS}/unittest" && \
    chmod -R a+rwX /opt/helm

# Python based tools (yamllint and yamale are required by chart-testing)
# renovate: datasource=pypi depName=yamllint
ENV yamllintVersion=1.38.0
# renovate: datasource=pypi depName=yamale
ENV yamaleVersion=6.1.0
RUN pip install --no-cache-dir \
        "yamllint==${yamllintVersion}" \
        "yamale==${yamaleVersion}"

# Install homebrew
# renovate: datasource=github-releases depName=Homebrew/brew
ENV brewVersion=7.0.11
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
      mkdir -p /usr/local/Homebrew && \
      curl -fsSL "https://github.com/Homebrew/brew/archive/refs/tags/${brewVersion}.tar.gz" | tar xz --strip 1 -C /usr/local/Homebrew && \
      ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew; \
    fi

# Create Fish config directories
RUN mkdir -p /root/.config/fish/completions \
             /root/.config/fish/conf.d

# Add completions only if the command exists
RUN for tool in cilium flux helm helmfile k9s kubectl kustomize talhelper talosctl hubble crane cosign trivy velero cmctl docker kubectl-cnpg flate; do \
      if command -v "$tool" >/dev/null 2>&1; then \
        $tool completion fish > "/root/.config/fish/completions/${tool}.fish" || true; \
      fi; \
    done && \
    gh completion --shell fish > /root/.config/fish/completions/gh.fish || true && \
    stern --completion fish > /root/.config/fish/completions/stern.fish || true && \
    task --completion fish > /root/.config/fish/completions/task.fish || true && \
    yq shell-completion fish > /root/.config/fish/completions/yq.fish || true

# Fish hooks, aliases and fish promt -> Needs to be done in one file in /etc/fish/config.fish
# Otherwise root won't pick it up
RUN printf '%s\n' \
    "if status is-interactive" \
    "    set -x KREW_ROOT $HOME/.krew" \
    "    fish_add_path -g \$KREW_ROOT/bin" \
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
# decors/fish-colored-man has no releases or tags, so it stays on its default branch
# renovate: datasource=github-releases depName=jorgebucaran/fisher
ENV fisherVersion=4.4.8
# renovate: datasource=github-releases depName=edc/bass versioning=loose
ENV bassVersion=v1.0
# renovate: datasource=github-releases depName=jorgebucaran/autopair.fish
ENV autopairVersion=1.0.4
# renovate: datasource=github-tags depName=nickeb96/puffer-fish
ENV pufferFishVersion=v1.1.0
# renovate: datasource=github-releases depName=PatrickF1/fzf.fish versioning=loose
ENV fzfFishVersion=v11.0
RUN /usr/bin/fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/${fisherVersion}/functions/fisher.fish | source; \
    fisher install jorgebucaran/fisher@${fisherVersion}; \
    fisher install decors/fish-colored-man; \
    fisher install edc/bass@${bassVersion}; \
    fisher install jorgebucaran/autopair.fish@${autopairVersion}; \
    fisher install nickeb96/puffer-fish@${pufferFishVersion}; \
    fisher install PatrickF1/fzf.fish@${fzfFishVersion}"

# Install kubectl plugins via krew (cnpg is installed pinned as kubectl-cnpg above)
ENV KREW_ROOT=/config/.krew
ENV PATH="${KREW_ROOT}/bin:${PATH}"
RUN krew install pv-mounter \
    && krew install df-pv
