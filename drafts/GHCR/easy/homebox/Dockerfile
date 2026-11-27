FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

ENV HOME=/config

USER root

# The release tarball is checked against the release checksums.txt.
# UNVERIFIED: the binary name inside the tarball is assumed to be "homebox"; check with tar tzf at build time.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) arch=x86_64 ;; \
        arm64) arch=arm64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/sysadminsmedia/homebox/releases/download/v${VERSION}"; \
    mkdir -p /tmp/homebox-src /app /usr/share/licenses/homebox; \
    cd /tmp/homebox-src; \
    curl -fsSLO "${base}/homebox_Linux_${arch}.tar.gz"; \
    curl -fsSLO "${base}/checksums.txt"; \
    grep " homebox_Linux_${arch}.tar.gz\$" checksums.txt | sha256sum -c -; \
    tar -xzf "homebox_Linux_${arch}.tar.gz"; \
    install -m 0755 homebox /app/homebox; \
    if [ -f LICENSE ]; then install -m 0644 LICENSE /usr/share/licenses/homebox/LICENSE; fi; \
    chown -R apps:apps /app; \
    cd /; \
    rm -rf /tmp/homebox-src

USER apps
COPY --chmod=0755 . /

EXPOSE 7745
VOLUME /config

ENTRYPOINT ["/start.sh"]
