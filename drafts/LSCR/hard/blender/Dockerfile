# UNVERIFIED: the plan cited ubuntu digest 19cb2cee...; the repo's ubuntu:26.04 siblings use f01a4295... (used here).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# UNVERIFIED package names beyond the linuxserver set: check each against the base before keeping it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      xvfb \
      ocl-icd-libopencl1 \
      libxkbcommon0 \
      libxi6 \
      libsm6 \
      libegl1 \
 && apt-get clean

# amd64: upstream tarball, checked against the combined sha256 file (only valid for 5.0.1).
# arm64: Ubuntu archive package (no official arm64 tarball).
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) \
        curl -fL -o /tmp/blender.tar.xz \
          "https://download.blender.org/release/Blender${VERSION%.*}/blender-${VERSION}-linux-x64.tar.xz"; \
        echo "8019580ee1b7262e505f4196a00237ccf743c88d205b38d34201510676e60b09  /tmp/blender.tar.xz" | sha256sum -c -; \
        mkdir -p /app/blender; \
        tar xf /tmp/blender.tar.xz -C /app/blender --strip-components=1; \
        chmod -R 755 /app/blender; \
        ln -s /app/blender/blender /usr/bin/blender; \
        ;; \
      arm64) \
        apt-get update; \
        apt-get install -y --no-install-recommends "blender=5.0.1+dfsg-1ubuntu1"; \
        ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

# BLOCKED (plan section 10): the web viewer on 3001 (kasmvnc pattern) is not added yet.
# UNVERIFIED: license files from the tarball are not copied yet.

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp \
    TITLE=Blender

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3001
VOLUME /config
