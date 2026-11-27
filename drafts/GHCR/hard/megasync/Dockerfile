FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS megasync-fetch

ARG VERSION
ARG TARGETARCH
USER root

# Fetch the vendor .deb for the target arch. Both URLs were HTTP 200 in the plan's check.
# UNVERIFIED: amd64 comes from the Debian 12 repo, and arm64 from the xUbuntu 24.04 repo. Runtime on 26.04 is untested.
# UNVERIFIED: no checksum is published for the .deb.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) REPO="https://mega.nz/linux/repo/Debian_12/amd64" ;; \
        arm64) REPO="https://mega.nz/linux/repo/xUbuntu_24.04/arm64" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/megasync.deb "${REPO}/megasync_${VERSION}_${TARGETARCH}.deb"

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# Runtime paths: config and caches on /config and /tmp. HOME is /config so MEGAsync keeps its settings there.
ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    DATA_DIR=/config/megasync \
    CUSTOM_RES_W=750 \
    CUSTOM_RES_H=550 \
    CUSTOM_DEPTH=16

COPY --from=megasync-fetch /tmp/megasync.deb /tmp/megasync.deb

# The deb pulls in its own Qt and library dependencies through apt.
# The VNC/noVNC stack is Ubuntu's packaged TigerVNC, noVNC and websockify.
# UNVERIFIED: all package names and the Qt major version on 26.04.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        /tmp/megasync.deb \
        tigervnc-standalone-server \
        novnc \
        websockify \
        x11-xserver-utils \
        fontconfig \
        fonts-dejavu-core \
        ca-certificates; \
    rm -f /tmp/megasync.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

# UNVERIFIED: whether the deb ships a licence file. Copy it if present, otherwise note it in the PR.
RUN set -eux; \
    mkdir -p /usr/share/licenses/megasync; \
    if [ -d /usr/share/doc/megasync ]; then \
        cp -a /usr/share/doc/megasync/. /usr/share/licenses/megasync/ || true; \
    fi

# Upstream runs as root with a chown of DATA_DIR. The rootless plan drops that.
# /usr/bin/megasync is the expected path from the deb (UNVERIFIED until the image is built).
USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
