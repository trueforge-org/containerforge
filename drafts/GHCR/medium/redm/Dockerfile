FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# amd64 only: the FiveM/RedM proot runtime is built for x86_64 and no arm64 build is confirmed.
RUN test "${TARGETARCH}" = "amd64" || { echo "redm: amd64 only (got ${TARGETARCH})"; exit 1; }

# hadolint ignore=DL3008,DL3015
# curl and ca-certificates are assumed present in the ubuntu base.
RUN apt-get update && \
    apt-get install -y --no-install-recommends xz-utils && \
    mkdir -p /config && \
    chown apps:apps /config && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# UNVERIFIED: the runtime artifact is downloaded at first start by start.sh, not baked in, so VERSION is a placeholder.
# UNVERIFIED: the web console (gotty) from the upstream image is not included in this draft.
# UNVERIFIED: the upstream license text is not fetched, so no license file is shipped yet.
ENV HOME=/config \
    SRV_ADR="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/" \
    SERVER_DIR=/config/serverfiles

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: 30120 is in the plan and the chart; 40120 (txAdmin) is only in the plan, confirm on the first run.
EXPOSE 30120
EXPOSE 40120

VOLUME /config
