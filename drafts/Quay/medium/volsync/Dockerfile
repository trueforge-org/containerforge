# UNVERIFIED: pin the golang:1.26 build image digest (resolve with docker buildx imagetools inspect)
FROM golang:1.27@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS build

ARG VERSION
ARG RCLONE_VERSION
ARG RCLONE_GIT_HASH
ARG SYNCTHING_VERSION
ARG SYNCTHING_GIT_HASH
ARG DISKRSYNC_VERSION
ARG DISKRSYNC_GIT_HASH

ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod \
    GOFLAGS=-mod=readonly \
    CGO_ENABLED=1

WORKDIR /src

# Download the volsync source at the pinned tag (UNVERIFIED: tarball URL pattern and source tree layout)
RUN set -eux; \
    mkdir -p /src/volsync /out/bin /out/licenses/volsync; \
    curl -fsSL -o /tmp/volsync.tar.gz "https://github.com/backube/volsync/archive/refs/tags/${VERSION}.tar.gz"; \
    tar -xzf /tmp/volsync.tar.gz -C /src/volsync --strip-components=1; \
    rm -f /tmp/volsync.tar.gz; \
    cp /src/volsync/LICENSE /out/licenses/volsync/LICENSE

# Operator (manager). UNVERIFIED: main package path at the tag
RUN set -eux; \
    cd /src/volsync; \
    go build -ldflags "-s -w" -o /out/manager ./cmd

# rclone mover, pinned by tag and commit hash as upstream does
RUN set -eux; \
    git clone --depth 1 --branch "${RCLONE_VERSION}" https://github.com/rclone/rclone.git /src/rclone; \
    test "$(git -C /src/rclone rev-parse HEAD)" = "${RCLONE_GIT_HASH}"; \
    make -C /src/rclone rclone; \
    install -m 0755 /src/rclone/rclone /out/bin/rclone; \
    mkdir -p /out/licenses/third-party/rclone; \
    cp /src/rclone/COPYING /out/licenses/third-party/rclone/

# syncthing mover, pinned by tag and commit hash
RUN set -eux; \
    git clone --depth 1 --branch "${SYNCTHING_VERSION}" https://github.com/syncthing/syncthing.git /src/syncthing; \
    test "$(git -C /src/syncthing rev-parse HEAD)" = "${SYNCTHING_GIT_HASH}"; \
    cd /src/syncthing; \
    go run build.go -no-upgrade; \
    install -m 0755 /src/syncthing/syncthing /out/bin/syncthing; \
    mkdir -p /out/licenses/third-party/syncthing; \
    cp /src/syncthing/LICENSE /out/licenses/third-party/syncthing/

# diskrsync, pinned by tag and commit hash. UNVERIFIED: upstream repo URL
RUN set -eux; \
    git clone --depth 1 --branch "${DISKRSYNC_VERSION}" https://github.com/dop251/diskrsync.git /src/diskrsync; \
    test "$(git -C /src/diskrsync rev-parse HEAD)" = "${DISKRSYNC_GIT_HASH}"; \
    cd /src/diskrsync; \
    go build -ldflags "-s -w" -o /out/bin/diskrsync .; \
    mkdir -p /out/licenses/third-party/diskrsync; \
    cp /src/diskrsync/LICENSE /out/licenses/third-party/diskrsync/

# restic mover, built from the copy of restic in the volsync tree. UNVERIFIED: path and build steps at the tag
RUN set -eux; \
    cd /src/volsync/mover-restic/restic; \
    go run build.go --enable-cgo; \
    install -m 0755 ./restic /out/bin/restic; \
    mkdir -p /out/licenses/third-party/restic; \
    cp ./LICENSE /out/licenses/third-party/restic/

# diskrsync-tcp helper from the volsync tree. UNVERIFIED: path at the tag
RUN set -eux; \
    cd /src/volsync/diskrsync-tcp; \
    go build -ldflags "-s -w" -o /out/bin/diskrsync-tcp .

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ENV SYNCTHING_DATA_TRANSFERMODE=sendreceive

USER root

# Runtime tools used by the movers. UNVERIFIED: Ubuntu package names and whether the base already ships any of them
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        acl \
        findutils \
        openssh-client \
        openssl \
        rsync \
        stunnel4 \
        tar \
    ; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /out/manager /manager
COPY --from=build /out/bin/ /usr/local/bin/
COPY --from=build /out/licenses/ /usr/share/licenses/volsync/

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/manager"]
CMD ["--health-probe-bind-address=:8081", "--metrics-bind-address=:8443", "--metrics-secure=true", "--metrics-require-rbac=false", "--leader-elect"]
