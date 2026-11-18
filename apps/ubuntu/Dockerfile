


FROM docker.io/library/ubuntu:26.04@sha256:d66b366dac61b575bee2aef07e9c26e8070096fbe84a3d4d3eb0da069b5d76db

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

## Install Node

ARG NODE_VERSION
ARG YARN_VERSION

USER root

ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}


RUN set -ex; \
  mkdir -p /app/nodehome; \
  chmod 777 /app/nodehome; \
  # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
  export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && for key in \
    5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do \
      { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
      { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$TARGETARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$NODE_VERSION-linux-$TARGETARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$TARGETARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$TARGETARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && rm -rf /tmp/*

RUN set -ex \
  # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
  export GNUPGHOME="$(mktemp -d)" \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || \
    { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && echo "$YARN_VERSION" > /YARN_VERSION.txt \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && rm -rf /tmp/*



# Use a safe non-root user
# Note: nobody:nogroup does not map to the same uid:gid on every (host/share) distro!
USER apps
COPY --chmod=0755 . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:9f1d78bb7c2439ae5938f73c294b17dbc2b9f61b8260eae91bd0a004c1de2198 /usr/bin/unrar-ubuntu /usr/bin/unrar

#Copy root files
COPY --chmod=0775 . /
COPY --chmod=0775  container-test.yaml /container-test.yaml

WORKDIR /config

HEALTHCHECK CMD ["/healthcheck.sh"]

# PID 1 with tini, handoff to entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
