
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# sha256 of the static docker-${VERSION}.tgz per arch, from docker-library/docker @70cd6b5 (29/dind/Dockerfile).
# Renovate cannot update these: bump by hand together with VERSION.
ARG DOCKER_SHA256_AMD64=7c1ebadc65c716cdc6d35fc78759ed0e4317debf43c21dd12f066f2006999def
ARG DOCKER_SHA256_ARM64=6e5159e8b5615e0c0c2954a2a1a2a12bc65f5d9b603595dba24a10cb367408cd
USER root

# Rootless dockerd: runs as apps with rootlesskit, no privileged container. Needs a seccomp/AppArmor
# profile that allows user namespaces (UNVERIFIED in this environment, see plan section 10).
RUN echo "*** Installing rootless dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    e2fsprogs \
    fuse-overlayfs \
    iptables \
    kmod \
    openssl \
    pigz \
    slirp4netns \
    uidmap \
    xz-utils && \
  rm -rf /var/lib/apt/lists/* && \
  echo "apps:100000:65536" >> /etc/subuid && \
  echo "apps:100000:65536" >> /etc/subgid

RUN echo "*** Installing Docker ${VERSION} (static bundle + rootless extras) ***" && \
  case "${TARGETARCH}" in \
    amd64) DOCKER_ARCH=x86_64; DOCKER_SHA="${DOCKER_SHA256_AMD64}" ;; \
    arm64) DOCKER_ARCH=aarch64; DOCKER_SHA="${DOCKER_SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  cd /tmp && \
  curl -fsSLO "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${VERSION}.tgz" && \
  echo "${DOCKER_SHA}  docker-${VERSION}.tgz" | sha256sum -c - && \
  curl -fsSLO "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-rootless-extras-${VERSION}.tgz.sha256" && \
  curl -fsSLO "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-rootless-extras-${VERSION}.tgz" && \
  sha256sum -c "docker-rootless-extras-${VERSION}.tgz.sha256" && \
  tar xzf "docker-${VERSION}.tgz" --strip-components=1 --no-same-owner -C /usr/local/bin && \
  tar xzf "docker-rootless-extras-${VERSION}.tgz" --strip-components=1 --no-same-owner -C /usr/local/bin && \
  dockerd --version && \
  echo "*** Installing licenses (UNVERIFIED: tag v${VERSION} must exist in moby/moby) ***" && \
  mkdir -p /usr/share/licenses/docker && \
  curl -fsSL -o /usr/share/licenses/docker/LICENSE "https://raw.githubusercontent.com/moby/moby/v${VERSION}/LICENSE" && \
  curl -fsSL -o /usr/share/licenses/docker/NOTICE "https://raw.githubusercontent.com/moby/moby/v${VERSION}/NOTICE" && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/docker-*.tgz /tmp/docker-*.tgz.sha256

ENV \
  HOME=/config \
  XDG_RUNTIME_DIR=/tmp/run \
  DOCKER_HOST=unix:///tmp/run/docker.sock \
  DOCKER_TLS_CERTDIR=/config/certs

USER apps
COPY --chmod=0755 . /

EXPOSE 2376

VOLUME /config

WORKDIR /config
