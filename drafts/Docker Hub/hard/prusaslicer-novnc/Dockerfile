# UNVERIFIED: base tag and digest copied from the openaudible plan (ghcr.io manifest read 2026-11-24); re-check before building.
# Inherits KasmVNC (openbox, 3000/3001, /config as HOME) from apps/kasmvnc, which owns /start.sh.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:7e96ef6465ad32c153f71fdff80fa4e2cb8fdfce1ab79dd269f08c7647505275

ARG VERSION
# UNVERIFIED: the exact Ubuntu 26.04 apt version of prusa-slicer, from `apt-cache policy prusa-slicer`. Empty fails the build on purpose.
ARG PACKAGE_VERSION
USER root

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "prusa-slicer=${PACKAGE_VERSION}" && \
    mkdir -p /usr/share/licenses/prusaslicer-novnc && \
    cp /usr/share/doc/prusa-slicer/copyright /usr/share/licenses/prusaslicer-novnc/ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV MESA_SHADER_CACHE_DIR=/tmp/mesa \
    XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001
