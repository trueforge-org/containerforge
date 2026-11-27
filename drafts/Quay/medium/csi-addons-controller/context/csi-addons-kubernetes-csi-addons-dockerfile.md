# csi-addons/kubernetes-csi-addons Dockerfile (pinned c9203233 and main)

Source URL(s): https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/c92032331fe7fb165dd1a40dfb7ebb6c83a3b5cb/Dockerfile (blob variant maps here) ; https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/main/Dockerfile (fetched 2026-11-27)

## Pinned commit c920323 (verbatim directives)
```
FROM golang:1.26 AS builder
COPY . /workspace/go/src/github.com/csi-addons/kubernetes-csi-addons
ENV GOPATH=/workspace/go CGO_ENABLED=0
WORKDIR /workspace/go/src/github.com/csi-addons/kubernetes-csi-addons
RUN make build
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder .../bin/csi-addons-manager .
USER 65532:65532
ENTRYPOINT ["/csi-addons-manager"]
```

## main (differences)
- Builder: FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.26 AS builder
- ARG TARGETOS TARGETARCH TARGETVARIANT ; ENV GOOS=$TARGETOS GOARCH=$TARGETARCH (cross-build)
- Runtime still gcr.io/distroless/static:nonroot, USER 65532:65532, ENTRYPOINT /csi-addons-manager.

## Facts
- Output binary: bin/csi-addons-manager (built by `make build`).
- Runtime user: 65532 (nonroot). No EXPOSE. No healthcheck in Dockerfile.
- Read-only rootfs compatible (static, no writes needed by Dockerfile).
