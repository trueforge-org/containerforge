# intel-gpu-plugin upstream Dockerfile

Source URL(s): https://raw.githubusercontent.com/intel/intel-device-plugins-for-kubernetes/v0.37.1/build/docker/intel-gpu-plugin.Dockerfile (blob variant: https://github.com/intel/intel-device-plugins-for-kubernetes/blob/v0.37.1/build/docker/intel-gpu-plugin.Dockerfile). Fetched 2026-11-26.

## Stages / base images
- Builder: `FROM ${GOLANG_BASE} AS builder`, default `GOLANG_BASE=golang:1.27-trixie`
- Final: `FROM ${FINAL_BASE}`, default `FINAL_BASE=registry.access.redhat.com/ubi9-micro:latest`
- Project build-image.sh default FINAL_BASE: `gcr.io/distroless/static`

## ARG
- Global: `CMD=gpu_plugin`, `FINAL_BASE`, `GOLANG_BASE`
- Builder: `DIR=/intel-device-plugins-for-kubernetes`, `GO111MODULE=on`, `LDFLAGS="all=-w -s"`, `GOFLAGS="-trimpath"`, `GCFLAGS="all=-spectre=all"`, `ASMFLAGS="-spectre=all"`, `GOLICENSES_VERSION` (no default), `EP=/usr/local/bin/intel_gpu_device_plugin`

## Build (builder)
- `WORKDIR ${DIR}`, `COPY . .`
- In `cmd/${CMD}`: `CGO_ENABLED=0 go install` with the GO flags above
- `install -D /go/bin/${CMD} /install_root${EP}`
- License: `install -D ${DIR}/LICENSE /install_root/licenses/intel-device-plugins-for-kubernetes/LICENSE`
- If `licenses/$CMD` absent: `go run github.com/google/go-licenses@${GOLICENSES_VERSION} save "./cmd/$CMD" --save_path /install_root/licenses/$CMD/go-licenses`; else copy `licenses/$CMD/*` into go-licenses dir
- Verify: `test -e /install_root/licenses/$CMD/go-licenses`
- No apt commands

## Final stage
- `COPY --from=builder /install_root /`
- `ENTRYPOINT ["/usr/local/bin/intel_gpu_device_plugin"]`, no CMD
- USER not set; EXPOSE none; ENV none

## LABEL
- vendor/maintainer "Intel®", `org.opencontainers.image.source=https://github.com/intel/intel-device-plugins-for-kubernetes`, `version='0.37.1'`, `release='1'`, `name='intel-gpu-plugin'`, `summary='Intel® GPU device plugin for Kubernetes'`

## Version / arch
- Generated from `build/docker/templates/intel-gpu-plugin.Dockerfile.in`
- License Apache 2.0
