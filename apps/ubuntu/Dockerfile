


FROM docker.io/library/ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

ARG VERSION
ARG TARGETARCH
ARG VENDOR

# https://github.com/intel/compute-runtime/releases
# >= Gen12 graphics (current)
# IGC2_VER is derived from the NEO release notes at build time; can be
# overridden by passing --build-arg IGC2_VER=<x.y.z>.
ARG IGC2_VER=""
ARG NEO_VER
# <= Gen11 graphics (legacy)
ARG IGC1_LEGACY_VER
ARG NEO_LEGACY_VER


ENV DEBIAN_FRONTEND="noninteractive" \
    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
     # Enable detection of dotnet running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    XDG_CONFIG_HOME=/config \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    HOME=/config

USER root

WORKDIR /app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create group and user "apps" with UID and GID 568
RUN groupadd -g 568 apps && \
    useradd -m -u 568 -g 568 -s /bin/bash apps; \
    usermod -aG 10,20,29,44,39,101,107,129 568; \
    mkdir -p /home/apps; \
    chown -R apps:apps /home/apps

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        bash \
        ca-certificates \
        tini \
        coreutils \
        curl \
        git \
        jq \
        nano \
        tzdata \
        uuid-runtime \
        xmlstarlet \
        libicu-dev \
        gettext-base \
        grep \
        tar \
        wget \
        libssl3 \
        sed \
        software-properties-common \
        sudo \
        gnupg \
        dirmngr \
        xz-utils \
        locales \
        fontconfig \
        p11-kit \
        unzip \
        ocl-icd-libopencl1 \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && update-ca-certificates \
    && locale-gen en_US.UTF-8 C.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && mkdir /config /data /cache /docker-entrypoint.d \
    && chown -R apps:apps /app /config /data /cache /docker-entrypoint.d && chmod -R 755 /app /config /data /cache /docker-entrypoint.d \
    && chmod 777 /cache \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH} -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq \
    && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/

RUN if [ "${TARGETARCH}" = "amd64" ]; then \
    mkdir intel-compute-runtime && cd intel-compute-runtime; \
    \
    # Fetch the NEO release once (used for GMMLIB version and IGC2 version discovery)
    NEO_RELEASE=$(curl -s https://api.github.com/repos/intel/compute-runtime/releases/tags/${NEO_VER}); \
    \
    # Fetch GMMLIB_VER from a specific NEO release
    GMMLIB_VER=$(echo "${NEO_RELEASE}" \
                  | jq -r '.assets[].name' \
                  | grep 'libigdgmm12_.*_amd64.deb' \
                  | sed -E 's/libigdgmm12_(.*)_amd64.deb/\1/'); \
    \
    # Derive IGC2_VER from the NEO release notes when not provided as build arg.
    # Matches the upstream release body reference, e.g.:
    #   intel/intel-graphics-compiler@v2.30.1
    # or the wget download URL for intel-igc-core-2.
    if [ -z "${IGC2_VER}" ]; then \
      IGC2_VER=$(echo "${NEO_RELEASE}" \
                   | jq -r '.body | capture("intel-graphics-compiler@v(?<igc>[0-9]+\\.[0-9]+\\.[0-9]+)")? | .igc // empty'); \
    fi; \
    if [ -z "${IGC2_VER}" ]; then \
      IGC2_VER=$(echo "${NEO_RELEASE}" \
                   | jq -r '.body | capture("intel-graphics-compiler/releases/download/v(?<igc>[0-9]+\\.[0-9]+\\.[0-9]+)/")? | .igc // empty'); \
    fi; \
    if [ -z "${IGC2_VER}" ]; then \
      echo "Failed to determine IGC2_VER from NEO release ${NEO_VER}" >&2; \
      exit 2; \
    fi; \
    echo "Using IGC2_VER=${IGC2_VER} (NEO_VER=${NEO_VER})"; \
    \
    # Fetch IGC2_BUILD from a specific IGC2 release
    IGC2_BUILD=$(curl -s https://api.github.com/repos/intel/intel-graphics-compiler/releases/tags/v${IGC2_VER} \
                   | jq -r '.assets[].name' \
                   | grep 'intel-igc-core-2_.*\+.*_amd64.deb' \
                   | sed -E 's/.*\+([0-9]+)_amd64.deb/\1/'); \
    \
    # Download the debs for the specific versions
    curl -LO https://github.com/intel/compute-runtime/releases/download/${NEO_VER}/libigdgmm12_${GMMLIB_VER}_amd64.deb \
         -LO https://github.com/intel/intel-graphics-compiler/releases/download/v${IGC2_VER}/intel-igc-core-2_${IGC2_VER}+${IGC2_BUILD}_amd64.deb \
         -LO https://github.com/intel/intel-graphics-compiler/releases/download/v${IGC2_VER}/intel-igc-opencl-2_${IGC2_VER}+${IGC2_BUILD}_amd64.deb \
         -LO https://github.com/intel/compute-runtime/releases/download/${NEO_VER}/intel-opencl-icd_${NEO_VER}-0_amd64.deb \
         -LO https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC1_LEGACY_VER}/intel-igc-core_${IGC1_LEGACY_VER}_amd64.deb \
         -LO https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC1_LEGACY_VER}/intel-igc-opencl_${IGC1_LEGACY_VER}_amd64.deb \
         -LO https://github.com/intel/compute-runtime/releases/download/${NEO_LEGACY_VER}/intel-opencl-icd-legacy1_${NEO_LEGACY_VER}_amd64.deb; \
    \
    apt-get install --no-install-recommends --no-install-suggests -y ./*.deb; \
    cd ..; \
    rm -rf intel-compute-runtime; \
    apt-get clean autoclean --yes; \
    apt-get autoremove --yes; \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*; \
    fi



# Use a safe non-root user
# Note: nobody:nogroup does not map to the same uid:gid on every (host/share) distro!
USER apps
COPY --chmod=0755 . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

#Copy root files
COPY --chmod=0775 . /
COPY --chmod=0775  container-test.yaml /container-test.yaml

WORKDIR /config

HEALTHCHECK CMD ["/healthcheck.sh"]

# PID 1 with tini, handoff to entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
