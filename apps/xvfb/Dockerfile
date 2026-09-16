FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:82ba374994be0491824b19f17ba1f47ffa97ba2feac1d6614285bb9d82e5b69b
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
