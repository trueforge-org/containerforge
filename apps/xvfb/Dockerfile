FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348
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
