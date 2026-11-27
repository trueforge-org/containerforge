# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

USER root
WORKDIR /app

# Download the release tarball and check it against the per-arch SHA-256 from the release checksum file.
# Only amd64 and arm64 are in scope.
RUN case "${TARGETARCH}" in \
        amd64) sha256="785524df829f847f55126baab67bf554dbf3413efd29ea7a643c4f57a655c1dc" ;; \
        arm64) sha256="73e3478f386e06fb6ce85fc4d0c031247752bf82acbdf59564cd57eea2bb7461" ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/portainer.tar.gz "https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-${TARGETARCH}.tar.gz" \
    && echo "${sha256}  /tmp/portainer.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/portainer.tar.gz -C /app --strip-components=1 \
    && rm -f /tmp/portainer.tar.gz \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /var/lib/apt/lists/* /tmp/*
# UNVERIFIED: the tarball listing shows no LICENSE file. Ship the repo LICENSE from the 2.45.4 tag to
# /usr/share/licenses/portainer/ once it has been fetched, and say where it came from in the PR.

COPY --chmod=0755 start.sh /start.sh

ENV TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 9000 9443 8000
VOLUME /config

CMD ["/start.sh"]
