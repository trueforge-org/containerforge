
# Build stage: compile the emulator from the upstream tag tarball
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

ARG VERSION

USER root

# UNVERIFIED: build steps follow dlandon/z80pack 1.37 (cpmsim/srcsim Makefile.linux); confirm for 1.38 at the build round
RUN echo "*** Building z80pack ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential libncurses-dev libncursesw5-dev curl ca-certificates && \
  mkdir -p /tmp/src /app/z80pack && \
  curl -fsSL -o /tmp/z80pack.tar.gz \
    "https://github.com/udo-munk/z80pack/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/z80pack.tar.gz -C /tmp/src --strip-components=1 && \
  make -C /tmp/src/cpmsim/srcsim -f Makefile.linux && \
  make -C /tmp/src/cpmsim/srctools && \
  cp -a /tmp/src/cpmsim /app/z80pack/ && \
  rm -rf /tmp/src /tmp/z80pack.tar.gz && \
  rm -rf /var/lib/apt/lists/*

# Runtime stage: no compiler, only the web terminal and the built emulator tree
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

ENV HOME=/tmp \
    TERM=xterm \
    LANG=C.UTF-8

USER root

RUN echo "*** Installing shellinabox ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends shellinabox ncurses-bin ca-certificates && \
  rm -rf /var/lib/apt/lists/*

COPY --from=buildstage /app/z80pack/ /app/z80pack/

RUN mkdir -p /usr/share/licenses/z80pack && \
  curl -fsSL -o /usr/share/licenses/z80pack/LICENSE \
    "https://raw.githubusercontent.com/udo-munk/z80pack/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 4200

VOLUME /config
WORKDIR /config
