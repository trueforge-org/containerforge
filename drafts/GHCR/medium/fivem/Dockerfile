FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# The Cfx runtime is an x86_64 glibc binary. Upstream ships no arm64 build.
# UNVERIFIED: the runtime is fetched at container start (start.sh), not at build time.
RUN if [ "${TARGETARCH}" != "amd64" ]; then \
      echo "fivem: unsupported architecture ${TARGETARCH}, amd64 only" >&2; \
      exit 1; \
    fi

ENV \
  DATA_DIR=/config \
  SERVER_DIR=/config/server \
  TMPDIR=/tmp \
  HOME=/tmp \
  UMASK=002

# UNVERIFIED: xz-utils and unzip are provided by the ubuntu base, so no apt install here.
# gotty and screen are not shipped in v1 (web console dropped, see plan section 4).

USER apps
COPY --chmod=0755 . /

EXPOSE 30120/tcp 30120/udp

VOLUME /config

WORKDIR /config
