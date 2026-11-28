FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# XDG_DATA_HOME keeps Caddy certificate and ACME state on the persistent /config volume.
# XDG_CACHE_HOME keeps caches on /tmp. UNVERIFIED that the binary honours both variables.
ENV HOME=/config \
    XDG_DATA_HOME=/config \
    XDG_CACHE_HOME=/tmp

# The release ships a raw binary and a checksums.txt. Verify the binary before installing it.
RUN echo "*** Installing Muximux ${VERSION} ***" && \
    curl -fsSL -o /tmp/muximux "https://github.com/mescon/Muximux/releases/download/${VERSION}/muximux-linux-${TARGETARCH}" && \
    curl -fsSL -o /tmp/checksums.txt "https://github.com/mescon/Muximux/releases/download/${VERSION}/checksums.txt" && \
    awk -v f="muximux-linux-${TARGETARCH}" '$2==f {print $1"  /tmp/muximux"}' /tmp/checksums.txt > /tmp/muximux.sha256 && \
    test -s /tmp/muximux.sha256 && \
    sha256sum -c /tmp/muximux.sha256 && \
    mkdir -p /app && \
    install -m 0755 /tmp/muximux /app/muximux && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    echo "*** Installing license ***" && \
    mkdir -p /usr/share/licenses/muximux && \
    curl -fsSL -o /usr/share/licenses/muximux/LICENSE "https://raw.githubusercontent.com/mescon/Muximux/${VERSION}/LICENSE" && \
    echo "*** Cleaning Up ***" && \
    rm -f /tmp/muximux /tmp/checksums.txt /tmp/muximux.sha256

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
