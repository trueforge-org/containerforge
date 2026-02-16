# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5348eb7725294e8090c15b7b495e517f82f4b31497d3bb9de71bbe37476e7454

ARG VERSION

USER root

# hadolint ignore=DL3008,DL3015,SC2086,SC2155
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        valkey-tools \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps:apps
