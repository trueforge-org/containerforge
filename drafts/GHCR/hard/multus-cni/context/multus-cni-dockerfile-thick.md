# Source: k8snetworkplumbingwg/multus-cni images/Dockerfile.thick (v4.3.2)

Source URL(s) + date: https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/v4.3.2/images/Dockerfile.thick (fetched 2026-11-27)

## Build
- Stage 1: `FROM --platform=$BUILDPLATFORM golang:1.26 AS build`; ADD . /usr/src/multus-cni; `./hack/build-go.sh` in that dir (ARG TARGETPLATFORM declared).
- Stage 2: `FROM debian:stable-slim`.
- COPY from build: /usr/src/multus-cni/bin, LICENSE, and bin/cert-approver to `/`.
- LABEL org.opencontainers.image.source=https://github.com/k8snetworkplumbingwg/multus-cni
- WORKDIR /

## Entrypoint
- `ENTRYPOINT [ "/usr/src/multus-cni/bin/multus-daemon" ]` (no CMD, no USER, no EXPOSE).

## Runtime deps
- debian:stable-slim base only; multus binaries built from Go source.

## Gotchas
- Header comment: image on DockerHub is built from this Dockerfile (ghcr tag used by chart is `v4.3.2-thick`).
- Runs as root by default (no USER directive).
