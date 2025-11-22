

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:435d3cfa071624ce5e12c531ede975f9ba55b0acd5b5d20c3f8e082a745b639e
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# TODO readd chromaprint
RUN echo "test"

COPY . /

USER apps:apps
WORKDIR /config
