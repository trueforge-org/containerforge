# DRAFT NOTES (see plan.md section 10 and the "Fix attempt" section):
# - multus-daemon needs host networking, host PID, root and hostPath writes. The chart runs it as
#   root and privileged. This image ships the upstream release binaries with USER apps, and the
#   chart must override the security context. Maintainer exception authorised for this draft.
# - Not built or run. The `--version` flag of multus-daemon is unverified, so it is not tested.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
ARG TARGETARCH
ARG VERSION
ARG SHA256_AMD64=6775a43348e17d08b1be6dea2fc2185af418ece7149a94a469c0787f2e486ad8
ARG SHA256_ARM64=2af3dd587a87423be74a70c23f1ddee56dedc424fde9d7edbcf330131fe9db10

USER root

# Checksums above come from the release's checksums.txt (SHA-256) and belong to VERSION in docker-bake.hcl.
RUN set -eu; \
    case "${TARGETARCH}" in \
        amd64) SHA256="${SHA256_AMD64}" ;; \
        arm64) SHA256="${SHA256_ARM64}" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    BARE="${VERSION#v}"; \
    mkdir -p /usr/src/multus-cni/bin /usr/share/licenses/multus-cni; \
    curl -fsSL -o /tmp/multus.tar.gz "https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/${VERSION}/multus-cni_${BARE}_linux_${TARGETARCH}.tar.gz"; \
    echo "${SHA256}  /tmp/multus.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/multus.tar.gz -C /tmp; \
    DIR="/tmp/multus-cni_${BARE}_linux_${TARGETARCH}"; \
    install -m 0755 "${DIR}/multus" "${DIR}/multus-daemon" "${DIR}/multus-shim" /usr/src/multus-cni/bin/; \
    cp "${DIR}/LICENSE" /usr/share/licenses/multus-cni/LICENSE; \
    cp "${DIR}/LICENSE" /usr/src/multus-cni/LICENSE; \
    rm -rf /tmp/*

COPY --chmod=0755 . /

USER apps
WORKDIR /config

ENTRYPOINT ["/usr/src/multus-cni/bin/multus-daemon"]
