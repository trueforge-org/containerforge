# Initial draft. BLOCKER (plan section 10): PBS daemons expect root and user `backup`; rootless operation is UNVERIFIED.
# Debian trixie debs are installed on ubuntu 26.04 through apt, so dependency resolution is UNVERIFIED.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# ayufan packaging release (VERSION in docker-bake.hcl, e.g. 4.2.0-1)
ARG VERSION
ARG TARGETARCH
# UNVERIFIED: per-arch SHA-256 of the release asset, copied from the GitHub API digest at port time.
# Left empty on purpose so the build fails until they are filled in in docker-bake.hcl.
ARG PBS_SHA256_AMD64
ARG PBS_SHA256_ARM64

ENV TZ=Etc/UTC \
    HOME=/config

USER root

RUN set -eux; \
    curl -fsSL -o /tmp/pbs.tgz "https://github.com/ayufan/pve-backup-server-dockerfiles/releases/download/v${VERSION}/proxmox-backup-server-v${VERSION}-${TARGETARCH}.tgz"; \
    case "${TARGETARCH}" in \
        amd64) want="${PBS_SHA256_AMD64}" ;; \
        arm64) want="${PBS_SHA256_ARM64}" ;; \
        *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    test -n "${want}" || { echo "PBS_SHA256 for ${TARGETARCH} is not set" >&2; exit 1; }; \
    echo "${want}  /tmp/pbs.tgz" | sha256sum -c -; \
    mkdir -p /tmp/pbs; \
    tar -xzf /tmp/pbs.tgz -C /tmp/pbs; \
    rm -f /tmp/pbs.tgz

# Install the packaged .debs through apt so Ubuntu equivalents of Debian dependencies are resolved.
# Do NOT run the tarball ./install script (it expects systemd and a host).
# UNVERIFIED: which debs are in the tarball and whether they resolve on ubuntu 26.04.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/pbs/*.deb; \
    pbs_ver="$(dpkg-query -W -f='${Version}' proxmox-backup-server)"; \
    case "${pbs_ver}" in "${VERSION%-*}"*) ;; *) echo "version mismatch: ${pbs_ver}" >&2; exit 1 ;; esac; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/pbs

# Keep the package-provided state as seed copies, then point the state dirs at /config and /tmp.
# UNVERIFIED: PBS tolerates symlinked state dirs and its ownership checks (see plan section 9).
RUN set -eux; \
    mkdir -p /usr/share/proxmox-backup-defaults; \
    cp -a /etc/proxmox-backup /usr/share/proxmox-backup-defaults/etc; \
    cp -a /var/lib/proxmox-backup /usr/share/proxmox-backup-defaults/lib; \
    rm -rf /etc/proxmox-backup /var/lib/proxmox-backup /var/log/proxmox-backup /run/proxmox-backup; \
    ln -s /config/etc /etc/proxmox-backup; \
    ln -s /config/lib /var/lib/proxmox-backup; \
    ln -s /config/log /var/log/proxmox-backup; \
    ln -s /tmp/run /run/proxmox-backup

# Licences: UNVERIFIED path of the package copyright file.
RUN set -eux; \
    mkdir -p /usr/share/licenses/proxmox-backup-server; \
    cp /usr/share/doc/proxmox-backup-server/copyright /usr/share/licenses/proxmox-backup-server/copyright

EXPOSE 8007

USER apps
COPY --chmod=0755 . /

VOLUME ["/config"]

CMD ["/start.sh"]
