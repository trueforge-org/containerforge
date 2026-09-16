FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:fe30ffe7e0841a2e19f3a508d9ae62b594feada6829d9b78d21cd534a8e8ac8b
ARG VERSION
ARG TARGETARCH
USER root
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends xvfb && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
