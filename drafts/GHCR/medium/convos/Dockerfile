FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

# build variables
ARG VERSION
USER root

# UNVERIFIED: exact apt package list for the upstream Alpine apk packages (build-base, perl-dev, ...)
RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cpanminus \
    curl \
    libperl-dev \
    libssl-dev \
    perl \
    zlib1g-dev && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no published checksum for the v8.07 tag tarball; pin the commit 63572e5cc48d821e9fe0d85b84dcea4ec837b466 and record the SHA-256 in the PR
RUN \
  echo "**** fetch convos ${VERSION} ****" && \
  mkdir -p /app && \
  curl -fL "https://github.com/convos-chat/convos/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar -xz -C /app --strip-components=1

# UNVERIFIED: whether 'convos install' writes into /app or needs PERL_CPANM_HOME
RUN \
  echo "**** install convos dependencies ****" && \
  cd /app && \
  CONVOS_DEPENDENCIES=all perl script/convos install --all && \
  echo "**** license ****" && \
  mkdir -p /usr/share/licenses/convos && \
  cp /app/LICENSE /usr/share/licenses/convos/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf /root/.cpanm /tmp/* /var/tmp/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

# UNVERIFIED: exact runtime perl packages the installed modules need
RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    perl && \
  rm -rf /var/lib/apt/lists/*

# add convos application and its licence
COPY --from=build /app /app
COPY --from=build /usr/share/licenses/convos/ /usr/share/licenses/convos/

# add local files
USER apps
COPY --chmod=0755 . /

ENV CONVOS_HOME=/config \
    CONVOS_NO_ROOT_WARNING=1 \
    MOJO_MODE=production \
    HOME=/config

# ports and volumes
EXPOSE 3000

WORKDIR /app
VOLUME /config
